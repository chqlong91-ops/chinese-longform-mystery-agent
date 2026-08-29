$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'p03_r1_registry.ps1')
. (Join-Path $PSScriptRoot 'p03_r1_legacy_adapter.ps1')

function Build-P03R1CompatibilityViews {
    param([Parameter(Mandatory)][string]$RegistryPath,[Parameter(Mandatory)][string]$ProjectionPath,[Parameter(Mandatory)][string]$OutputRoot,[string]$ViewId='P03-R1-COMPATIBILITY-VIEW@v001')
    $rv=Test-P03R1Registry -RegistryPath $RegistryPath;if(-not$rv.valid){throw "registry-invalid:$($rv.errors-join',')"}
    $registry=Read-P03R1Registry -Path $RegistryPath
    $projection=Get-P03R1LegacyStrictJson $ProjectionPath
    $pv=Test-P03R1LegacyProjection -Projection $projection;if(-not$pv.valid){throw "projection-invalid:$($pv.errors-join',')"}
    [void](New-Item -ItemType Directory -Path $OutputRoot -Force)
    $registryHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $RegistryPath).Hash
    $current=@($registry.current_pointers|Sort-Object pointer_key|ForEach-Object object_ref)
    $lifecycleRef=@($registry.current_pointers|Where-Object scope -eq 'agent-control/lifecycle'|ForEach-Object object_ref)
    $adapterRef=@($registry.current_pointers|Where-Object scope -eq 'agent-control/legacy-adapter'|ForEach-Object object_ref)
    $control=@("# P03-R1 Current Control","","- registry: ``$($registry.registry_id)@$($registry.registry_version)``","- registry SHA-256: ``$registryHash``","- lifecycle: ``$($lifecycleRef -join ', ')``","- adapter: ``$($adapterRef -join ', ')``","- current objects: ``$($current.Count)``")
    foreach($ref in $current){$control+=@("- current: ``$ref``")}
    $control+=@("- unique next: ``$($registry.unique_next.action)``","","This view is generated. It cannot write back to the registry or grant novel state.")
    $compat=@("# P01-P03 Historical Compatibility","","- projection: ``$($projection.projection_id)``","- state ceiling: ``$($projection.state_ceiling)``","- current grants: ``$(@($projection.current_grants).Count)``")
    foreach($row in @($projection.phases|Sort-Object phase)){$compat+=@("- ``$($row.phase)``: lifecycle=``$($row.lifecycle)``; work=``$($row.work)``; gate=``$($row.gate)``; baseline=``$($row.baseline)``; current-eligible=``$($row.current_eligible.ToString().ToLowerInvariant())``")}
    $compat+=@("","Historical compatibility does not grant current, rewrite source bytes, or establish novel status.")
    $utf8=[System.Text.UTF8Encoding]::new($false)
    $files=[ordered]@{'current-control.md'=($control-join"`n")+"`n";'legacy-compatibility.md'=($compat-join"`n")+"`n"}
    $rows=@();foreach($name in $files.Keys){$path=Join-Path $OutputRoot $name;[System.IO.File]::WriteAllText($path,$files[$name],$utf8);$rows+=@([pscustomobject][ordered]@{relative_path=$name;sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash;bytes=(Get-Item $path).Length})}
    $manifest=[pscustomobject][ordered]@{view_id=$ViewId;registry_sha256=$registryHash;projection_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $ProjectionPath).Hash;files=@($rows|Sort-Object relative_path);source_of_truth='canonical-registry';write_back='forbidden';nonclaims=@('historical rows are not current','no novel state','no L6-P')}
    $manifestPath=Join-Path $OutputRoot 'view-manifest.json';[System.IO.File]::WriteAllText($manifestPath,($manifest|ConvertTo-Json -Depth 20),$utf8)
    return [pscustomobject][ordered]@{manifest_path=$manifestPath;files=$rows;registry_sha256=$registryHash}
}

function Test-P03R1CompatibilityViews {
    param([Parameter(Mandatory)][string]$ManifestPath,[Parameter(Mandatory)][string]$ViewRoot,[Parameter(Mandatory)][string]$RegistryPath,[Parameter(Mandatory)][string]$ProjectionPath)
    $errors=[System.Collections.Generic.List[string]]::new();$m=Get-P03R1LegacyStrictJson $ManifestPath
    if($m.registry_sha256-ne(Get-FileHash -Algorithm SHA256 -LiteralPath $RegistryPath).Hash){$errors.Add('CV-REGISTRY-DRIFT')}
    if($m.projection_sha256-ne(Get-FileHash -Algorithm SHA256 -LiteralPath $ProjectionPath).Hash){$errors.Add('CV-PROJECTION-DRIFT')}
    foreach($row in @($m.files)){$p=Join-Path $ViewRoot $row.relative_path;if(-not(Test-Path -LiteralPath $p)-or(Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash-ne$row.sha256-or(Get-Item $p).Length-ne$row.bytes){$errors.Add("CV-FILE-DRIFT:$($row.relative_path)")}}
    return [pscustomobject][ordered]@{valid=($errors.Count-eq0);errors=@($errors);drift_count=$errors.Count}
}
