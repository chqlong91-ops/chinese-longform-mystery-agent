$ErrorActionPreference = 'Stop'

function Read-P03R1Registry {
    param([Parameter(Mandatory)][string]$Path)
    $strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $raw = [System.IO.File]::ReadAllText($Path, $strictUtf8)
    return ($raw | ConvertFrom-Json -Depth 100)
}

function Test-P03R1Registry {
    param(
        [Parameter(Mandatory)][string]$RegistryPath,
        [string]$SchemaPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p03-r1-canonical-state-registry.schema.json')
    )

    $errors = [System.Collections.Generic.List[string]]::new()
    $strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
    try { $raw = [System.IO.File]::ReadAllText($RegistryPath, $strictUtf8) }
    catch { $errors.Add('invalid-utf8-or-missing'); return [pscustomobject]@{ valid=$false; errors=@($errors) } }

    try { $registry = $raw | ConvertFrom-Json -Depth 100 }
    catch { $errors.Add('invalid-json'); return [pscustomobject]@{ valid=$false; errors=@($errors) } }

    if (Get-Command Test-Json -ErrorAction SilentlyContinue) {
        try {
            $schemaOk = $raw | Test-Json -SchemaFile $SchemaPath -ErrorAction Stop
            if (-not $schemaOk) { $errors.Add('schema-invalid') }
        }
        catch { $errors.Add('schema-invalid') }
    }

    $requiredTop = @('registry_id','schema_version','registry_version','coverage','objects','current_pointers','evidence','relations','transition_intents','registry_state','unique_next','nonclaims')
    $topNames = @($registry.PSObject.Properties.Name)
    foreach ($name in $requiredTop) { if ($name -notin $topNames) { $errors.Add("missing-top:$name") } }
    foreach ($name in $topNames) { if ($name -notin $requiredTop) { $errors.Add("unknown-top:$name") } }
    if ($errors.Count -gt 0 -and (-not $registry.objects)) { return [pscustomobject]@{ valid=$false; errors=@($errors) } }

    $scopePattern = '^[a-z0-9][a-z0-9-]*(/[a-zA-Z0-9][a-zA-Z0-9-]*)*$'
    $included = @($registry.coverage.included)
    $excluded = @($registry.coverage.excluded)
    if (($included | Select-Object -Unique).Count -ne $included.Count) { $errors.Add('duplicate-included-coverage') }
    if (($excluded | Select-Object -Unique).Count -ne $excluded.Count) { $errors.Add('duplicate-excluded-coverage') }
    foreach ($scope in @($included) + @($excluded)) { if ($scope -notmatch $scopePattern) { $errors.Add("invalid-scope:$scope") } }
    foreach ($scope in $included) { if ($scope -in $excluded) { $errors.Add("coverage-overlap:$scope") } }

    $objectFields = @('namespace','object_type','object_id','object_ref','version','record_revision','scope','lifecycle','predecessor_ref','owners','states','evidence_refs','relation_refs','nonclaims')
    $stateDimensions = @('work','confirmation','sync','risk','gate','governance_decision')
    $allowedValues = @{
        work=@('not-started','in-progress','candidate','completed','blocked','stale')
        confirmation=@('not-required','pending','confirmed','rejected','stale','conflict')
        sync=@('not-required','unsynced','partial','synced','stale','conflict')
        risk=@('unknown','normal','review-required','blocking','accepted-with-limitations')
        gate=@('yes','partial','no','not-evaluated','not-applicable','stale','conflict')
        governance_decision=@('tier1-autonomous','tier2-confirmation','tier2-autonomous-with-checkpoint','tier3-authorization','internal-blocked','not-evaluated')
    }
    $objects = @($registry.objects)
    $objectRefs = @($objects | ForEach-Object { $_.object_ref })
    if (($objectRefs | Select-Object -Unique).Count -ne $objectRefs.Count) { $errors.Add('duplicate-object-ref') }
    $evidenceIds = @($registry.evidence | ForEach-Object { $_.evidence_id })
    if (($evidenceIds | Select-Object -Unique).Count -ne $evidenceIds.Count) { $errors.Add('duplicate-evidence-id') }

    foreach ($object in $objects) {
        $names = @($object.PSObject.Properties.Name)
        foreach ($field in $objectFields) { if ($field -notin $names) { $errors.Add("missing-object-field:$($object.object_ref):$field") } }
        foreach ($field in $names) { if ($field -notin $objectFields) { $errors.Add("unknown-object-field:$($object.object_ref):$field") } }
        if ($object.object_ref -ne "$($object.object_id)@$($object.version)") { $errors.Add("object-ref-mismatch:$($object.object_ref)") }
        if ($object.scope -notmatch $scopePattern) { $errors.Add("invalid-object-scope:$($object.object_ref)") }
        if ($object.predecessor_ref -and $object.predecessor_ref -notin $objectRefs) { $errors.Add("orphan-predecessor:$($object.object_ref)") }
        foreach ($ownerField in @('authority_owner','state_owner','evidence_owner','next_owner')) {
            if ([string]::IsNullOrWhiteSpace($object.owners.$ownerField)) { $errors.Add("missing-owner:$($object.object_ref):$ownerField") }
        }
        foreach ($dimension in $stateDimensions) {
            $claim = $object.states.$dimension
            if ($null -eq $claim) { $errors.Add("missing-state:$($object.object_ref):$dimension"); continue }
            if ($claim.value -notin $allowedValues[$dimension]) { $errors.Add("invalid-state-value:$($object.object_ref):$dimension") }
            if ([string]::IsNullOrWhiteSpace($claim.owner)) { $errors.Add("missing-state-owner:$($object.object_ref):$dimension") }
            foreach ($evidenceRef in @($claim.evidence_refs)) { if ($evidenceRef -notin $evidenceIds) { $errors.Add("orphan-state-evidence:$($object.object_ref):$evidenceRef") } }
        }
        foreach ($evidenceRef in @($object.evidence_refs)) { if ($evidenceRef -notin $evidenceIds) { $errors.Add("orphan-object-evidence:$($object.object_ref):$evidenceRef") } }
    }

    foreach ($evidence in @($registry.evidence)) {
        if ([string]::IsNullOrWhiteSpace($evidence.owner)) { $errors.Add("missing-evidence-owner:$($evidence.evidence_id)") }
        if ($evidence.source_fingerprint -notmatch '^[A-F0-9]{64}$') { $errors.Add("invalid-evidence-fingerprint:$($evidence.evidence_id)") }
        if (@($evidence.supports).Count -eq 0) { $errors.Add("missing-supports:$($evidence.evidence_id)") }
        if (@($evidence.does_not_establish).Count -eq 0) { $errors.Add("missing-nonclaim:$($evidence.evidence_id)") }
    }

    $pointerKeys = @($registry.current_pointers | ForEach-Object { $_.pointer_key })
    if (($pointerKeys | Select-Object -Unique).Count -ne $pointerKeys.Count) { $errors.Add('duplicate-current-pointer') }
    foreach ($pointer in @($registry.current_pointers)) {
        $expectedKey = "$($pointer.namespace)|$($pointer.object_type)|$($pointer.scope)"
        if ($pointer.pointer_key -ne $expectedKey) { $errors.Add("pointer-key-mismatch:$($pointer.pointer_key)") }
        $target = @($objects | Where-Object object_ref -eq $pointer.object_ref)
        if ($target.Count -ne 1) { $errors.Add("current-target-count:$($pointer.pointer_key)"); continue }
        if ($target[0].lifecycle -ne 'current') { $errors.Add("current-target-not-current:$($pointer.pointer_key)") }
        if ($target[0].namespace -ne $pointer.namespace -or $target[0].object_type -ne $pointer.object_type -or $target[0].scope -ne $pointer.scope) { $errors.Add("pointer-target-mismatch:$($pointer.pointer_key)") }
    }
    foreach ($object in @($objects | Where-Object lifecycle -eq 'current')) {
        if (@($registry.current_pointers | Where-Object object_ref -eq $object.object_ref).Count -ne 1) { $errors.Add("current-object-pointer-count:$($object.object_ref)") }
    }

    $relationIds = @($registry.relations | ForEach-Object { $_.relation_id })
    if (($relationIds | Select-Object -Unique).Count -ne $relationIds.Count) { $errors.Add('duplicate-relation-id') }
    foreach ($relation in @($registry.relations)) {
        if ($relation.source_ref -notin $objectRefs) { $errors.Add("orphan-relation-source:$($relation.relation_id)") }
        if ($relation.target_ref -notin $objectRefs) { $errors.Add("orphan-relation-target:$($relation.relation_id)") }
        foreach ($evidenceRef in @($relation.evidence_refs)) { if ($evidenceRef -notin $evidenceIds) { $errors.Add("orphan-relation-evidence:$($relation.relation_id)") } }
    }

    foreach ($object in $objects) {
        $seen = [System.Collections.Generic.HashSet[string]]::new()
        $cursor = $object
        while ($cursor -and $cursor.predecessor_ref) {
            if (-not $seen.Add($cursor.object_ref)) { $errors.Add("lineage-cycle:$($object.object_ref)"); break }
            $cursor = @($objects | Where-Object object_ref -eq $cursor.predecessor_ref)[0]
        }
    }

    $intentIds = @($registry.transition_intents | ForEach-Object { $_.intent_id })
    if (($intentIds | Select-Object -Unique).Count -ne $intentIds.Count) { $errors.Add('duplicate-intent-id') }
    foreach ($intent in @($registry.transition_intents)) {
        if ($intent.target_pointer_key -notin $pointerKeys) { $errors.Add("intent-pointer-missing:$($intent.intent_id)") }
        if ($intent.expected_current_ref -and $intent.expected_current_ref -notin $objectRefs) { $errors.Add("intent-expected-missing:$($intent.intent_id)") }
        if ($intent.proposed_current_ref -notin $objectRefs) { $errors.Add("intent-proposed-missing:$($intent.intent_id)") }
        foreach ($evidenceRef in @($intent.evidence_refs)) { if ($evidenceRef -notin $evidenceIds) { $errors.Add("orphan-intent-evidence:$($intent.intent_id)") } }
    }

    if ($registry.registry_state.lifecycle -eq 'current' -and $registry.registry_state.evaluation -ne 'evaluated') { $errors.Add('current-registry-not-evaluated') }
    if ([string]::IsNullOrWhiteSpace($registry.unique_next.action) -or [string]::IsNullOrWhiteSpace($registry.unique_next.owner)) { $errors.Add('invalid-unique-next') }
    if ($registry.unique_next.kind -eq 'blocked' -and [string]::IsNullOrWhiteSpace($registry.unique_next.remedy)) { $errors.Add('blocked-next-missing-remedy') }
    if ($registry.unique_next.kind -eq 'action' -and $registry.unique_next.remedy) { $errors.Add('action-next-has-remedy') }

    [pscustomobject]@{
        valid = ($errors.Count -eq 0)
        errors = @($errors | Sort-Object -Unique)
        objects = $objects.Count
        current_pointers = @($registry.current_pointers).Count
        evidence = @($registry.evidence).Count
        relations = @($registry.relations).Count
        intents = @($registry.transition_intents).Count
    }
}

function Get-P03R1RegistryQuery {
    param(
        [Parameter(Mandatory)][string]$RegistryPath,
        [string]$Namespace,
        [string]$ObjectType,
        [string]$Scope,
        [switch]$CurrentOnly
    )

    $validation = Test-P03R1Registry -RegistryPath $RegistryPath
    if (-not $validation.valid) { throw "registry invalid: $($validation.errors -join ',')" }
    $registry = Read-P03R1Registry -Path $RegistryPath
    $result = @($registry.objects)
    if ($Namespace) { $result = @($result | Where-Object namespace -eq $Namespace) }
    if ($ObjectType) { $result = @($result | Where-Object object_type -eq $ObjectType) }
    if ($Scope) { $result = @($result | Where-Object scope -eq $Scope) }
    if ($CurrentOnly) {
        $currentRefs = @($registry.current_pointers | ForEach-Object object_ref)
        $result = @($result | Where-Object object_ref -in $currentRefs)
    }
    return @($result | Sort-Object namespace,object_type,scope,version)
}
