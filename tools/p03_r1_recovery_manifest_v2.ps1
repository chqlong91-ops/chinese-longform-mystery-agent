$ErrorActionPreference = 'Stop'

function Get-P03R1Rmv2Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Get-P03R1Rmv2TextSha256 {
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes($Text)
    $hash = [System.Security.Cryptography.SHA256]::HashData($bytes)
    return [Convert]::ToHexString($hash)
}

function Copy-P03R1Rmv2Object {
    param([Parameter(Mandatory)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100)
}

function Resolve-P03R1Rmv2FilesystemPath {
    param(
        [Parameter(Mandatory)]$Locator,
        [Parameter(Mandatory)][string]$ManifestDirectory,
        [Parameter(Mandatory)][string]$WorkspaceRoot
    )
    if ($Locator.type -ne 'filesystem') { return $null }
    $base = if ($Locator.base -eq 'manifest-root') { $ManifestDirectory } elseif ($Locator.base -eq 'workspace-root') { $WorkspaceRoot } else { throw 'RMV2-LOCATOR-AMBIGUOUS' }
    if ([System.IO.Path]::IsPathRooted($Locator.value)) { throw 'RMV2-LOCATOR-AMBIGUOUS' }
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $base $Locator.value))
    return $resolved
}

function Test-P03R1Rmv2ForbiddenMatch {
    param([string]$Identity, $Selector)
    if ($Selector.match -eq 'exact') { return $Identity -eq $Selector.canonical_identity }
    return $Identity.StartsWith($Selector.canonical_identity, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-P03R1RecoveryManifestObject {
    param(
        [Parameter(Mandatory)]$Manifest,
        [Parameter(Mandatory)][string]$ManifestDirectory,
        [Parameter(Mandatory)][string]$WorkspaceRoot,
        [switch]$SkipSchema
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $schemaPath = Join-Path $WorkspaceRoot 'schemas/p03-r1-recovery-manifest-v2.schema.json'
    $raw = $Manifest | ConvertTo-Json -Depth 100
    if (-not $SkipSchema -and (Get-Command Test-Json -ErrorAction SilentlyContinue)) {
        try { if (-not ($raw | Test-Json -SchemaFile $schemaPath -ErrorAction Stop)) { $errors.Add('RMV2-SCHEMA-INVALID') } }
        catch { $errors.Add('RMV2-SCHEMA-INVALID') }
    }

    if ($Manifest.profile.class -eq 'L6-S') {
        if (-not $Manifest.profile.project_id.StartsWith('SYNTH-')) { $errors.Add('RMV2-L6-CLASS-CONFLICT') }
        if ($Manifest.profile.evidence_ceiling -ne 'L6-S') { $errors.Add('RMV2-L6-CLASS-CONFLICT') }
    }
    elseif ($Manifest.profile.class -eq 'L6-P') {
        if ($Manifest.profile.project_id.StartsWith('SYNTH-') -or $Manifest.profile.evidence_ceiling -ne 'L6-P') { $errors.Add('RMV2-L6-CLASS-CONFLICT') }
    }

    if ($Manifest.bootstrap_core.schema_sha256 -ne (Get-P03R1Rmv2Sha256 $schemaPath)) { $errors.Add('RMV2-HASH-DRIFT') }
    if ($Manifest.bootstrap_core.schema_locator -ne 'schemas/p03-r1-recovery-manifest-v2.schema.json') { $errors.Add('RMV2-LOCATOR-AMBIGUOUS') }

    $project = @($Manifest.project_payload_reads)
    $environment = @($Manifest.environment_reads)
    $dependencies = @($Manifest.runtime_required_dependencies)
    $allResources = @($project + $environment)
    $resourceIds = @($allResources | ForEach-Object resource_id)
    $canonicalIds = @($allResources | ForEach-Object canonical_identity)
    $dependencyIds = @($dependencies | ForEach-Object dependency_id)

    if (($resourceIds | Select-Object -Unique).Count -ne $resourceIds.Count) { $errors.Add('RMV2-RESOURCE-ID-CONFLICT') }
    if (($canonicalIds | Select-Object -Unique).Count -ne $canonicalIds.Count) { $errors.Add('RMV2-CLASSIFICATION-CONFLICT') }
    if (($dependencyIds | Select-Object -Unique).Count -ne $dependencyIds.Count) { $errors.Add('RMV2-DEPENDENCY-ID-CONFLICT') }

    foreach ($resource in $allResources) {
        if ($resource.locator.value -match '[*?]' -or $resource.canonical_identity -match '[*?]') { $errors.Add('RMV2-LOCATOR-AMBIGUOUS'); continue }
        if ($resource.locator.type -eq 'filesystem') {
            try {
                $path = Resolve-P03R1Rmv2FilesystemPath -Locator $resource.locator -ManifestDirectory $ManifestDirectory -WorkspaceRoot $WorkspaceRoot
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $errors.Add('RMV2-MISSING-DEPENDENCY'); continue }
                if ((Get-P03R1Rmv2Sha256 $path) -ne $resource.fingerprint.value -or (Get-Item -LiteralPath $path).Length -ne $resource.bytes) { $errors.Add('RMV2-HASH-DRIFT') }
            }
            catch { $errors.Add($_.Exception.Message) }
        }
        elseif ($resource.locator.base -ne 'provider' -or [string]::IsNullOrWhiteSpace($resource.locator.authority)) {
            $errors.Add('RMV2-LOCATOR-AMBIGUOUS')
        }
    }

    foreach ($p in $project) {
        if ($null -ne $p.origin_dependency_id -or $p.proximity -notin @('near-field','far-field-structural')) { $errors.Add('RMV2-CLASSIFICATION-LAUNDERING') }
    }
    foreach ($e in $environment) {
        if ([string]::IsNullOrWhiteSpace($e.origin_dependency_id) -or $e.proximity -notin @('runtime','environment')) { $errors.Add('RMV2-CLASSIFICATION-LAUNDERING') }
    }

    foreach ($dep in $dependencies) {
        $resolved = @($environment | Where-Object resource_id -eq $dep.resolved_resource_id)
        if ($resolved.Count -ne 1) { $errors.Add('RMV2-MISSING-DEPENDENCY'); continue }
        if ($resolved[0].origin_dependency_id -ne $dep.dependency_id -or $resolved[0].fingerprint.value -ne $dep.fingerprint.value) { $errors.Add('RMV2-DEPENDENCY-RESOLUTION-CONFLICT') }
        if ($dep.requiredness -eq 'mandatory' -and $null -ne $dep.condition) { $errors.Add('RMV2-CONDITION-INVALID') }
        if ($dep.requiredness -eq 'conditional' -and [string]::IsNullOrWhiteSpace($dep.condition)) { $errors.Add('RMV2-CONDITION-UNRESOLVED') }
        if ($null -ne $dep.parent_dependency_id) {
            $parent = @($dependencies | Where-Object dependency_id -eq $dep.parent_dependency_id)
            if ($parent.Count -ne 1 -or $dep.dependency_id -notin @($parent[0].transitive_resource_ids)) { $errors.Add('RMV2-DEPENDENCY-LINEAGE-CONFLICT') }
        }
        foreach ($childId in @($dep.transitive_resource_ids)) {
            $child = @($dependencies | Where-Object dependency_id -eq $childId)
            if ($child.Count -ne 1 -or $child[0].parent_dependency_id -ne $dep.dependency_id) { $errors.Add('RMV2-DEPENDENCY-LINEAGE-CONFLICT') }
        }
    }

    foreach ($dep in $dependencies) {
        $seen = [System.Collections.Generic.HashSet[string]]::new()
        $cursor = $dep
        while ($null -ne $cursor -and $null -ne $cursor.parent_dependency_id) {
            if (-not $seen.Add($cursor.dependency_id)) { $errors.Add('RMV2-DEPENDENCY-CYCLE'); break }
            $cursor = @($dependencies | Where-Object dependency_id -eq $cursor.parent_dependency_id)[0]
        }
    }

    foreach ($resource in $allResources) {
        foreach ($selector in @($Manifest.forbidden_reads)) {
            if (Test-P03R1Rmv2ForbiddenMatch -Identity $resource.canonical_identity -Selector $selector) { $errors.Add('RMV2-FORBIDDEN-INTERSECTION') }
        }
    }

    $expectedStages = @('bootstrap','runtime-dependencies','project-payload','state-evidence','assertions')
    $actualStages = @($Manifest.load_graph | Sort-Object order | ForEach-Object stage_id)
    if (($actualStages -join '|') -ne ($expectedStages -join '|')) { $errors.Add('RMV2-LOAD-GRAPH-INVALID') }
    $runtimeStage = @($Manifest.load_graph | Where-Object stage_id -eq 'runtime-dependencies')
    $projectStage = @($Manifest.load_graph | Where-Object stage_id -eq 'project-payload')
    if ((@($runtimeStage.dependency_ids | Sort-Object) -join '|') -ne (@($dependencyIds | Sort-Object) -join '|')) { $errors.Add('RMV2-LOAD-GRAPH-INCOMPLETE') }
    if ((@($runtimeStage.resource_ids | Sort-Object) -join '|') -ne (@($environment.resource_id | Sort-Object) -join '|')) { $errors.Add('RMV2-LOAD-GRAPH-INCOMPLETE') }
    if ((@($projectStage.resource_ids | Sort-Object) -join '|') -ne (@($project.resource_id | Sort-Object) -join '|')) { $errors.Add('RMV2-LOAD-GRAPH-INCOMPLETE') }

    $fileCount = $allResources.Count
    $byteCount = [int64](($allResources | Measure-Object -Property bytes -Sum).Sum)
    $tokenEstimate = [int][Math]::Ceiling($byteCount / 3.0)
    if ($fileCount -gt $Manifest.context_budget.max_files -or $byteCount -gt $Manifest.context_budget.max_bytes -or $tokenEstimate -gt $Manifest.context_budget.max_estimated_tokens) { $errors.Add('RMV2-BUDGET-OVERFLOW') }

    $assertionIds = @($Manifest.semantic_assertions | ForEach-Object assertion_id)
    if (($assertionIds | Select-Object -Unique).Count -ne $assertionIds.Count) { $errors.Add('RMV2-ASSERTION-CONFLICT') }
    foreach ($assertion in @($Manifest.semantic_assertions)) {
        if ([string]::IsNullOrWhiteSpace($assertion.owner)) { $errors.Add('RMV2-ASSERTION-CONFLICT') }
        foreach ($id in @($assertion.required_resource_ids)) { if ($id -notin $resourceIds) { $errors.Add('RMV2-ASSERTION-CONFLICT') } }
    }

    $requiredLedgerFields = @('sequence','stage','requested_identity','canonical_identity','category','dependency_id','result','bytes','observed_fingerprint')
    $requiredSummaryFields = @('actual_reads','not_read','environment_reads','forbidden_reads','over_reads','writes','not_applicable_dependencies')
    if (@($requiredLedgerFields | Where-Object { $_ -notin @($Manifest.read_ledger_contract.record_fields) }).Count -ne 0) { $errors.Add('RMV2-LEDGER-CONTRACT-INCOMPLETE') }
    if (@($requiredSummaryFields | Where-Object { $_ -notin @($Manifest.read_ledger_contract.summary_fields) }).Count -ne 0) { $errors.Add('RMV2-LEDGER-CONTRACT-INCOMPLETE') }
    if ($Manifest.write_policy.mode -ne 'forbidden' -or @($Manifest.write_policy.allowed_writes).Count -ne 0) { $errors.Add('RMV2-WRITE-POLICY-CONFLICT') }
    if (@($Manifest.stop_policy.codes).Count -lt 16 -or $Manifest.stop_policy.no_progress_threshold -ne 2) { $errors.Add('RMV2-STOP-POLICY-INCOMPLETE') }
    if ([string]::IsNullOrWhiteSpace($Manifest.unique_next.action) -or [string]::IsNullOrWhiteSpace($Manifest.unique_next.owner)) { $errors.Add('RMV2-NEXT-NONUNIQUE') }

    $resolutionRows = @($allResources | Sort-Object resource_id | ForEach-Object { "$($_.resource_id)|$($_.canonical_identity)|$($_.fingerprint.value)|$($_.bytes)" })
    $resolutionFingerprint = Get-P03R1Rmv2TextSha256 -Text ($resolutionRows -join "`n")
    return [pscustomobject]@{
        valid = ($errors.Count -eq 0)
        errors = @($errors | Sort-Object -Unique)
        manifest_id = $Manifest.manifest_id
        profile_class = $Manifest.profile.class
        project_payload_count = $project.Count
        environment_count = $environment.Count
        dependency_count = $dependencies.Count
        forbidden_count = @($Manifest.forbidden_reads).Count
        resolved_files = $fileCount
        resolved_bytes = $byteCount
        estimated_tokens = $tokenEstimate
        resolution_fingerprint = $resolutionFingerprint
        unique_next = $Manifest.unique_next.action
    }
}

function Test-P03R1RecoveryManifestV2 {
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [string]$WorkspaceRoot = (Split-Path -Parent $PSScriptRoot)
    )
    try {
        $strict = [System.Text.UTF8Encoding]::new($false, $true)
        $raw = [System.IO.File]::ReadAllText($ManifestPath, $strict)
        $manifest = $raw | ConvertFrom-Json -Depth 100
    }
    catch {
        return [pscustomobject]@{ valid=$false; errors=@('RMV2-MANIFEST-INVALID'); manifest_id=$null; resolution_fingerprint=$null }
    }
    return Test-P03R1RecoveryManifestObject -Manifest $manifest -ManifestDirectory (Split-Path -Parent ([System.IO.Path]::GetFullPath($ManifestPath))) -WorkspaceRoot ([System.IO.Path]::GetFullPath($WorkspaceRoot))
}

function Get-P03R1RecoveryManifestResolution {
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [string]$WorkspaceRoot = (Split-Path -Parent $PSScriptRoot)
    )
    $result = Test-P03R1RecoveryManifestV2 -ManifestPath $ManifestPath -WorkspaceRoot $WorkspaceRoot
    if (-not $result.valid) { throw "manifest-invalid:$($result.errors -join ',')" }
    return $result
}
