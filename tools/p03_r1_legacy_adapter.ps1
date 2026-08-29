$ErrorActionPreference='Stop'

function Get-P03R1LegacyStrictJson {
    param([Parameter(Mandatory)][string]$Path)
    $strict=[System.Text.UTF8Encoding]::new($false,$true)
    return ([System.IO.File]::ReadAllText($Path,$strict)|ConvertFrom-Json -Depth 100)
}

function Copy-P03R1LegacyObject {
    param([Parameter(Mandatory)]$Value)
    return (($Value|ConvertTo-Json -Depth 100)|ConvertFrom-Json -Depth 100)
}

function Get-P03R1LegacyCanonicalJson {
    param([Parameter(Mandatory)]$Value)
    function Normalize($node){
        if($null-eq$node){return $null}
        if($node-is[string]-or$node-is[ValueType]){return $node}
        if($node-is[System.Collections.IDictionary]){$o=[ordered]@{};foreach($k in @($node.Keys|Sort-Object)){$o[$k]=Normalize $node[$k]};return $o}
        if($node-is[System.Collections.IEnumerable]-and$node-isnot[string]){return @($node|ForEach-Object{Normalize $_})}
        $o=[ordered]@{};foreach($p in @($node.PSObject.Properties.Name|Sort-Object)){$o[$p]=Normalize $node.$p};return $o
    }
    return ((Normalize $Value)|ConvertTo-Json -Depth 100 -Compress)
}

function Get-P03R1LegacySha256Text {
    param([Parameter(Mandatory)][string]$Text)
    $bytes=[System.Text.UTF8Encoding]::new($false).GetBytes($Text)
    return [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes))
}

function Test-P03R1LegacyInventoryObject {
    param([Parameter(Mandatory)]$Inventory,[Parameter(Mandatory)][string]$WorkspaceRoot)
    $errors=[System.Collections.Generic.List[string]]::new()
    if($Inventory.inventory_id-ne'P03-R1-LEGACY-INVENTORY@v001'){$errors.Add('LAD-INVENTORY-IDENTITY')}
    if($Inventory.state_ceiling-ne'historical-reference-only'){$errors.Add('LAD-STATE-CEILING')}
    $sources=@($Inventory.sources)
    if($sources.Count-ne9){$errors.Add('LAD-SOURCE-COUNT')}
    $ids=@($sources.source_id)
    if(@($ids|Sort-Object -Unique).Count-ne$ids.Count){$errors.Add('LAD-DUPLICATE-IDENTITY')}
    if((@($ids|Sort-Object)-join'|')-ne(@($Inventory.expected_exact_set|Sort-Object)-join'|')){$errors.Add('LAD-EXACT-SET')}
    $root=[System.IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\')
    foreach($source in $sources){
        if($source.classification-ne'historical-evidence'-or$source.state_ceiling-ne'historical-only'){$errors.Add("LAD-CLASSIFICATION:$($source.source_id)")}
        if($source.provenance_owner-ne'legacy-adapter'){$errors.Add("LAD-PROVENANCE-OWNER:$($source.source_id)")}
        $full=[System.IO.Path]::GetFullPath((Join-Path $root $source.relative_path))
        if(-not$full.StartsWith($root+'\',[System.StringComparison]::OrdinalIgnoreCase)){$errors.Add("LAD-PATH-ESCAPE:$($source.source_id)")}
        $relative=[System.IO.Path]::GetRelativePath($root,$full).Replace('\','/')
        if($relative-match'(^|/)(章节|03-稿件|formal|candidate|protected-source)(/|$)'-or$relative-match'FROZEN-BASELINE'-or$relative-match'BRPM-'){$errors.Add("LAD-FORBIDDEN:$($source.source_id)")}
        if($source.sha256-notmatch'^[A-F0-9]{64}$'-or[long]$source.bytes-le0){$errors.Add("LAD-FINGERPRINT:$($source.source_id)")}
        if(@($source.expected_tokens).Count-eq0){$errors.Add("LAD-PARSE-CONTRACT:$($source.source_id)")}
    }
    $phases=@($Inventory.stage_claims.phase)
    if((@($phases|Sort-Object)-join'|')-ne'P01|P02|P03'){$errors.Add('LAD-PHASE-EXACT-SET')}
    foreach($claim in @($Inventory.stage_claims)){
        if(@($claim.source_ids).Count-ne3-or@($claim.source_ids|Where-Object{$_-notin$ids}).Count){$errors.Add("LAD-CLAIM-SOURCES:$($claim.phase)")}
        if($claim.phase-eq'P03'-and($claim.gate-ne'no'-or$claim.baseline-ne'not-created')){$errors.Add('LAD-P03-BOUNDARY')}
    }
    return [pscustomobject][ordered]@{valid=($errors.Count-eq0);errors=@($errors|Sort-Object -Unique);sources=$sources.Count;phases=@($phases|Sort-Object -Unique).Count}
}

function Test-P03R1LegacyInventory {
    param([Parameter(Mandatory)][string]$InventoryPath,[Parameter(Mandatory)][string]$WorkspaceRoot,[string]$SchemaPath=(Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p03-r1-legacy-adapter.schema.json'))
    $errors=[System.Collections.Generic.List[string]]::new()
    try{$raw=[System.IO.File]::ReadAllText($InventoryPath,[System.Text.UTF8Encoding]::new($false,$true));$inventory=$raw|ConvertFrom-Json -Depth 100}catch{return [pscustomobject]@{valid=$false;errors=@('LAD-INVALID-JSON');sources=0;phases=0}}
    if(Get-Command Test-Json -ErrorAction SilentlyContinue){try{if(-not($raw|Test-Json -SchemaFile $SchemaPath -ErrorAction Stop)){$errors.Add('LAD-SCHEMA')}}catch{$errors.Add('LAD-SCHEMA')}}
    $semantic=Test-P03R1LegacyInventoryObject -Inventory $inventory -WorkspaceRoot $WorkspaceRoot
    foreach($e in @($semantic.errors)){$errors.Add($e)}
    return [pscustomobject][ordered]@{valid=($errors.Count-eq0);errors=@($errors|Sort-Object -Unique);sources=$semantic.sources;phases=$semantic.phases}
}

function Invoke-P03R1LegacyInventoryScan {
    param([Parameter(Mandatory)][string]$InventoryPath,[Parameter(Mandatory)][string]$WorkspaceRoot)
    $validation=Test-P03R1LegacyInventory -InventoryPath $InventoryPath -WorkspaceRoot $WorkspaceRoot
    if(-not$validation.valid){throw "LAD-INVENTORY-INVALID:$($validation.errors-join',')"}
    $inventory=Get-P03R1LegacyStrictJson $InventoryPath
    $records=[System.Collections.Generic.List[object]]::new();$parsed=@{};$sequence=0
    foreach($source in @($inventory.sources|Sort-Object source_id)){
        $path=Join-Path $WorkspaceRoot $source.relative_path
        if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "LAD-MISSING:$($source.source_id)"}
        $bytes=[System.IO.File]::ReadAllBytes($path);$hash=[Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes))
        if($hash-ne$source.sha256-or$bytes.Length-ne[long]$source.bytes){throw "LAD-DRIFT:$($source.source_id)"}
        $text=[System.Text.UTF8Encoding]::new($false,$true).GetString($bytes)
        foreach($token in @($source.expected_tokens)){if(-not$text.Contains($token)){throw "LAD-TOKEN-MISMATCH:$($source.source_id)"}}
        $sequence++;$records.Add([pscustomobject][ordered]@{sequence=$sequence;source_id=$source.source_id;phase=$source.phase;role=$source.role;relative_path=$source.relative_path;classification='historical-evidence';result='read';bytes=$bytes.Length;observed_sha256=$hash;state_ceiling='historical-only'})
        $parsed[$source.source_id]=$true
    }
    $projectionRows=foreach($claim in @($inventory.stage_claims|Sort-Object phase)){
        [pscustomobject][ordered]@{phase=$claim.phase;lifecycle='historical';work=$claim.work;gate=$claim.gate;baseline=$claim.baseline;located=$true;parsed=(@($claim.source_ids|Where-Object{-not$parsed.ContainsKey($_)}).Count-eq0);provenance_bound=$true;current_eligible=$false;source_ids=@($claim.source_ids|Sort-Object);supports=@($claim.supports);does_not_establish=@($claim.does_not_establish)}
    }
    $ledger=[pscustomobject][ordered]@{inventory_id=$inventory.inventory_id;records=@($records);allowed_reads=@($inventory.sources.source_id|Sort-Object);actual_reads=@($records.source_id|Sort-Object);not_read=@();over_reads=@();writes=@();forbidden_reads=@($inventory.forbidden_selectors);legacy_mutation=0;novel_reads=0;novel_writes=0}
    $projection=[pscustomobject][ordered]@{projection_id='P03-R1-LEGACY-PROJECTION@v001';adapter_schema='P03-R1-LEGACY-ADAPTER@s001';state_ceiling='historical-reference-only';phases=@($projectionRows);current_grants=@();nonclaims=@($inventory.nonclaims)}
    $result=[pscustomobject][ordered]@{inventory=$inventory;ledger=$ledger;projection=$projection}
    $result|Add-Member -NotePropertyName inventory_fingerprint -NotePropertyValue (Get-P03R1LegacySha256Text (Get-P03R1LegacyCanonicalJson $inventory))
    $result|Add-Member -NotePropertyName ledger_fingerprint -NotePropertyValue (Get-P03R1LegacySha256Text (Get-P03R1LegacyCanonicalJson $ledger))
    $result|Add-Member -NotePropertyName projection_fingerprint -NotePropertyValue (Get-P03R1LegacySha256Text (Get-P03R1LegacyCanonicalJson $projection))
    return $result
}

function Test-P03R1LegacyProjection {
    param([Parameter(Mandatory)]$Projection)
    $errors=[System.Collections.Generic.List[string]]::new()
    if($Projection.state_ceiling-ne'historical-reference-only'){$errors.Add('LAD-PROJECTION-CEILING')}
    if(@($Projection.phases).Count-ne3){$errors.Add('LAD-PROJECTION-PHASES')}
    foreach($phase in @($Projection.phases)){if($phase.lifecycle-ne'historical'-or$phase.current_eligible-or-not$phase.located-or-not$phase.parsed-or-not$phase.provenance_bound){$errors.Add("LAD-PROJECTION-STATE:$($phase.phase)")}}
    if(@($Projection.current_grants).Count){$errors.Add('LAD-PROJECTION-CURRENT-GRANT')}
    return [pscustomobject][ordered]@{valid=($errors.Count-eq0);errors=@($errors|Sort-Object -Unique)}
}
