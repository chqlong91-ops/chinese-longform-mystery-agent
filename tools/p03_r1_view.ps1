$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'p03_r1_registry.ps1')

function Get-P03R1ViewStringSha256 {
    param([Parameter(Mandatory)][string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([System.BitConverter]::ToString($sha.ComputeHash([System.Text.UTF8Encoding]::new($false).GetBytes($Text)))).Replace('-','') }
    finally { $sha.Dispose() }
}

function Resolve-P03R1ViewPath {
    param([Parameter(Mandatory)][string]$Root, [Parameter(Mandatory)][string]$RelativePath)
    if ([System.IO.Path]::IsPathRooted($RelativePath)) { throw 'absolute-view-path' }
    $base = [System.IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $base $RelativePath))
    if (-not $resolved.StartsWith($base + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'view-path-outside-root' }
    return $resolved
}

function Get-P03R1ViewContent {
    param([Parameter(Mandatory)]$Registry, [Parameter(Mandatory)]$View, [Parameter(Mandatory)][string]$RegistryHash, [Parameter(Mandatory)][string]$TemplateVersion)
    $currentRefs = @($Registry.current_pointers | Sort-Object pointer_key | ForEach-Object object_ref)
    $lines = [System.Collections.Generic.List[string]]::new()
    switch ($View.kind) {
        'current-summary' {
            $lines.Add('# P03-R1 Current State')
            $lines.Add('')
            $lines.Add("- registry: ``$($Registry.registry_id)@$($Registry.registry_version)``")
            $lines.Add("- registry SHA-256: ``$RegistryHash``")
            $lines.Add("- template: ``$TemplateVersion``")
            $lines.Add("- lifecycle/evaluation: ``$($Registry.registry_state.lifecycle)/$($Registry.registry_state.evaluation)``")
            $lines.Add("- current objects: ``$($currentRefs.Count)``")
            foreach ($ref in $currentRefs) { $lines.Add("- current: ``$ref``") }
            $lines.Add("- unique next: ``$($Registry.unique_next.action)``")
        }
        'task-summary' {
            $lines.Add('# P03-R1 Task State')
            $lines.Add('')
            $lines.Add("- registry SHA-256: ``$RegistryHash``")
            foreach ($object in @($Registry.objects | Where-Object { $_.object_type -eq 'task-state' -and $_.lifecycle -eq 'current' } | Sort-Object scope,object_ref)) {
                $lines.Add("- ``$($object.object_ref)``: work=``$($object.states.work.value)``; sync=``$($object.states.sync.value)``; risk=``$($object.states.risk.value)``; gate=``$($object.states.gate.value)``")
            }
            $lines.Add("- unique next: ``$($Registry.unique_next.action)``")
        }
        'recovery-summary' {
            $lines.Add('# P03-R1 Recovery Summary')
            $lines.Add('')
            $lines.Add("- registry: ``$($Registry.registry_id)@$($Registry.registry_version)``")
            $lines.Add("- registry SHA-256: ``$RegistryHash``")
            $lines.Add("- owner: ``$($Registry.registry_state.owner)``")
            $lines.Add("- stop code: ``$($Registry.registry_state.stop_code)``")
            $lines.Add("- unique next kind: ``$($Registry.unique_next.kind)``")
            $lines.Add("- unique next: ``$($Registry.unique_next.action)``")
            $lines.Add("- next owner: ``$($Registry.unique_next.owner)``")
            $lines.Add("- next scope: ``$($Registry.unique_next.scope)``")
        }
        default { throw "unknown-view-kind:$($View.kind)" }
    }
    return (($lines -join "`n") + "`n")
}

function Build-P03R1DerivedView {
    param(
        [Parameter(Mandatory)][string]$RegistryPath,
        [Parameter(Mandatory)][string]$ViewSpecPath,
        [Parameter(Mandatory)][string]$OutputRoot
    )
    $validation = Test-P03R1Registry -RegistryPath $RegistryPath
    if (-not $validation.valid) { throw "registry-invalid:$($validation.errors -join ',')" }
    $specRaw = [System.IO.File]::ReadAllText($ViewSpecPath, [System.Text.UTF8Encoding]::new($false, $true))
    $schemaPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p03-r1-derived-view.schema.json'
    if (Get-Command Test-Json -ErrorAction SilentlyContinue) {
        if (-not ($specRaw | Test-Json -SchemaFile $schemaPath -ErrorAction Stop)) { throw 'view-spec-invalid' }
    }
    $spec = $specRaw | ConvertFrom-Json -Depth 20
    $targets = @($spec.views | ForEach-Object target_relative)
    if (($targets | Select-Object -Unique).Count -ne $targets.Count) { throw 'duplicate-view-target' }
    $registry = Read-P03R1Registry -Path $RegistryPath
    $registryHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $RegistryPath).Hash
    $payloadRoot = Join-Path $OutputRoot 'payload'
    [void](New-Item -ItemType Directory -Path $payloadRoot -Force)
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $records = @()
    foreach ($view in @($spec.views | Sort-Object view_id)) {
        if (-not $view.target_relative.StartsWith('state/p03-r1/views/')) { throw 'view-target-outside-managed-root' }
        $content = Get-P03R1ViewContent -Registry $registry -View $view -RegistryHash $registryHash -TemplateVersion $spec.template_version
        $payloadRelative = "payload/$($view.view_id).md"
        $payloadPath = Resolve-P03R1ViewPath -Root $OutputRoot -RelativePath $payloadRelative
        [System.IO.File]::WriteAllText($payloadPath, $content, $utf8)
        $records += [ordered]@{
            view_id = $view.view_id
            kind = $view.kind
            target_relative = $view.target_relative
            payload_relative = $payloadRelative
            sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $payloadPath).Hash
            bytes = (Get-Item -LiteralPath $payloadPath).Length
        }
    }
    $bundleBasis = "$registryHash|$($spec.template_version)|" + (@($records | ForEach-Object { "$($_.view_id):$($_.sha256):$($_.bytes)" }) -join '|')
    $bundleHash = Get-P03R1ViewStringSha256 $bundleBasis
    $manifest = [ordered]@{
        view_set_id = $spec.view_set_id
        template_version = $spec.template_version
        registry_id = $registry.registry_id
        registry_version = $registry.registry_version
        registry_sha256 = $registryHash
        bundle_hash = $bundleHash
        views = $records
    }
    $manifestPath = Join-Path $OutputRoot 'view-manifest.json'
    [System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 20), $utf8)
    [pscustomobject]@{ manifest_path=$manifestPath; bundle_hash=$bundleHash; registry_hash=$registryHash; views=@($records) }
}

function Publish-P03R1DerivedView {
    param([Parameter(Mandatory)][string]$ViewManifestPath, [Parameter(Mandatory)][string]$WorkspaceRoot)
    $manifest = [System.IO.File]::ReadAllText($ViewManifestPath, [System.Text.UTF8Encoding]::new($false, $true)) | ConvertFrom-Json -Depth 20
    $manifestRoot = Split-Path -Parent $ViewManifestPath
    # A committed transaction archives the manifest inside its payload directory,
    # while payload_relative remains transaction-root relative (payload/...).
    # Resolve against the transaction root in that layout; keep the original
    # behavior for pre-commit manifests stored beside their payload directory.
    if ((Split-Path -Leaf $manifestRoot) -eq 'payload') {
        $manifestRoot = Split-Path -Parent $manifestRoot
    }
    foreach ($view in @($manifest.views)) {
        if (-not $view.target_relative.StartsWith('state/p03-r1/views/')) { throw 'view-target-outside-managed-root' }
        $source = Resolve-P03R1ViewPath -Root $manifestRoot -RelativePath $view.payload_relative
        if ((Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash -ne $view.sha256) { throw "view-payload-drift:$($view.view_id)" }
        $target = Resolve-P03R1ViewPath -Root $WorkspaceRoot -RelativePath $view.target_relative
        [void](New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force)
        $temp = $target + '.view.tmp'
        Copy-Item -LiteralPath $source -Destination $temp -Force
        [System.IO.File]::Move($temp, $target, $true)
    }
}

function Test-P03R1DerivedView {
    param(
        [Parameter(Mandatory)][string]$RegistryPath,
        [Parameter(Mandatory)][string]$ViewManifestPath,
        [Parameter(Mandatory)][string]$WorkspaceRoot
    )
    $errors = [System.Collections.Generic.List[string]]::new()
    $manifest = [System.IO.File]::ReadAllText($ViewManifestPath, [System.Text.UTF8Encoding]::new($false, $true)) | ConvertFrom-Json -Depth 20
    $registryHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $RegistryPath).Hash
    if ($registryHash -ne $manifest.registry_sha256) { $errors.Add('registry-view-manifest-drift') }
    $manifestRoot = Split-Path -Parent $ViewManifestPath
    if ((Split-Path -Leaf $manifestRoot) -eq 'payload') {
        $manifestRoot = Split-Path -Parent $manifestRoot
    }
    foreach ($view in @($manifest.views)) {
        try {
            $payload = Resolve-P03R1ViewPath -Root $manifestRoot -RelativePath $view.payload_relative
            $target = Resolve-P03R1ViewPath -Root $WorkspaceRoot -RelativePath $view.target_relative
            if (-not (Test-Path -LiteralPath $payload -PathType Leaf)) {
                $payloadDirectory = Split-Path -Parent $payload
                $payloadLeaf = Split-Path -Leaf $payload
                $archived = @(Get-ChildItem -LiteralPath $payloadDirectory -File | Where-Object { $_.Name -match ('^\d{3}-' + [regex]::Escape($payloadLeaf) + '$') })
                if ($archived.Count -eq 1) { $payload = $archived[0].FullName }
            }
            if (-not (Test-Path -LiteralPath $payload -PathType Leaf) -or (Get-FileHash -Algorithm SHA256 -LiteralPath $payload).Hash -ne $view.sha256) { $errors.Add("payload-drift:$($view.view_id)") }
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { $errors.Add("view-missing:$($view.view_id)") }
            elseif ((Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash -ne $view.sha256) { $errors.Add("view-drift:$($view.view_id)") }
        }
        catch { $errors.Add("view-check-failed:$($view.view_id)") }
    }
    [pscustomobject]@{ valid=($errors.Count -eq 0); drift_count=$errors.Count; errors=@($errors); registry_hash=$registryHash; bundle_hash=$manifest.bundle_hash }
}
