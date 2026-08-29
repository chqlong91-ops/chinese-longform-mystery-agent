$ErrorActionPreference='Stop'

. (Join-Path $PSScriptRoot 'p03_r1_recovery_manifest_v2.ps1')

function Get-P03R1RuntimeStrictJson {
    param([Parameter(Mandatory)][string]$Path)
    $strict=[System.Text.UTF8Encoding]::new($false,$true)
    return ([System.IO.File]::ReadAllText($Path,$strict)|ConvertFrom-Json -Depth 100)
}

function Get-P03R1RuntimeCanonicalJson {
    param([Parameter(Mandatory)]$Value)
    function Normalize($node) {
        if($null -eq $node){return $null}
        if($node -is [string] -or $node -is [ValueType]){return $node}
        if($node -is [System.Collections.IDictionary]){
            $ordered=[ordered]@{}
            foreach($key in @($node.Keys|Sort-Object)){ $ordered[$key]=Normalize $node[$key] }
            return $ordered
        }
        if($node -is [System.Collections.IEnumerable] -and $node -isnot [string]){return @($node|ForEach-Object{Normalize $_})}
        $ordered=[ordered]@{}
        foreach($property in @($node.PSObject.Properties.Name|Sort-Object)){ $ordered[$property]=Normalize $node.$property }
        return $ordered
    }
    return ((Normalize $Value)|ConvertTo-Json -Depth 100 -Compress)
}

function Get-P03R1RuntimeFingerprint {
    param([Parameter(Mandatory)]$Value)
    return Get-P03R1Rmv2TextSha256 -Text (Get-P03R1RuntimeCanonicalJson $Value)
}

function Test-P03R1RuntimeTargetRoot {
    param([Parameter(Mandatory)][string]$Target,[Parameter(Mandatory)][string]$AllowedRoot)
    $targetFull=[System.IO.Path]::GetFullPath($Target).TrimEnd('\')
    $allowedFull=[System.IO.Path]::GetFullPath($AllowedRoot).TrimEnd('\')
    if(-not $targetFull.StartsWith($allowedFull+'\',[System.StringComparison]::OrdinalIgnoreCase)){throw 'RMV2-TARGET-OUTSIDE-ALLOWED-ROOT'}
}

function New-P03R1RecoveryPackage {
    param(
        [Parameter(Mandatory)][string]$ProfilePath,
        [Parameter(Mandatory)][string]$OutputDirectory,
        [Parameter(Mandatory)][string]$AllowedOutputRoot,
        [string]$WorkspaceRoot=(Split-Path -Parent $PSScriptRoot)
    )
    Test-P03R1RuntimeTargetRoot -Target $OutputDirectory -AllowedRoot $AllowedOutputRoot
    if(Test-Path -LiteralPath $OutputDirectory){throw 'RMV2-PACKAGE-TARGET-EXISTS'}
    $sourceValidation=Test-P03R1RecoveryManifestV2 -ManifestPath $ProfilePath -WorkspaceRoot $WorkspaceRoot
    if(-not $sourceValidation.valid){throw "RMV2-SOURCE-MANIFEST-INVALID:$($sourceValidation.errors -join ',')"}
    $manifest=Copy-P03R1Rmv2Object (Get-P03R1RuntimeStrictJson $ProfilePath)
    $manifestDir=Split-Path -Parent ([System.IO.Path]::GetFullPath($ProfilePath))
    $profileDir=Join-Path $OutputDirectory 'profile'
    $resourceDir=Join-Path $OutputDirectory 'resources'
    [void](New-Item -ItemType Directory -Path $profileDir,$resourceDir -Force)
    $resourceRows=[System.Collections.Generic.List[object]]::new()
    $resourcePathById=@{}
    foreach($resource in @($manifest.project_payload_reads)+@($manifest.environment_reads)){
        if($resource.locator.type -ne 'filesystem'){throw 'RMV2-S06-FILESYSTEM-ONLY-SYNTHETIC'}
        $source=Resolve-P03R1Rmv2FilesystemPath -Locator $resource.locator -ManifestDirectory $manifestDir -WorkspaceRoot $WorkspaceRoot
        $extension=[System.IO.Path]::GetExtension($source)
        if([string]::IsNullOrWhiteSpace($extension)){$extension='.txt'}
        $name="$($resource.resource_id)$extension"
        $target=Join-Path $resourceDir $name
        Copy-Item -LiteralPath $source -Destination $target
        $resource.locator.base='manifest-root'
        $resource.locator.value="../resources/$name"
        $resourcePathById[$resource.resource_id]=$resource.locator.value
    }
    foreach($dependency in @($manifest.runtime_required_dependencies)){
        if(-not $resourcePathById.ContainsKey($dependency.resolved_resource_id)){throw 'RMV2-MISSING-DEPENDENCY'}
        $dependency.locator.base='manifest-root'
        $dependency.locator.value=$resourcePathById[$dependency.resolved_resource_id]
    }
    $manifestPath=Join-Path $profileDir 'manifest.json'
    [System.IO.File]::WriteAllText($manifestPath,($manifest|ConvertTo-Json -Depth 100),[System.Text.UTF8Encoding]::new($false))
    $packageValidation=Test-P03R1RecoveryManifestV2 -ManifestPath $manifestPath -WorkspaceRoot $WorkspaceRoot
    if(-not $packageValidation.valid){throw "RMV2-BUILT-MANIFEST-INVALID:$($packageValidation.errors -join ',')"}
    $contentPaths=@($manifestPath)+@(Get-ChildItem -LiteralPath $resourceDir -File|Sort-Object Name|ForEach-Object FullName)
    foreach($path in $contentPaths){
        $relative=[System.IO.Path]::GetRelativePath($OutputDirectory,$path).Replace('\','/')
        $resourceRows.Add([pscustomobject][ordered]@{relative_path=$relative;sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash;bytes=(Get-Item -LiteralPath $path).Length})
    }
    $rows=@($resourceRows|Sort-Object relative_path)
    $exact=Get-P03R1Rmv2TextSha256 -Text (($rows|ForEach-Object{"$($_.relative_path)|$($_.sha256)|$($_.bytes)"}) -join "`n")
    $descriptor=[pscustomobject][ordered]@{
        package_id="RPK-$($manifest.profile.project_id)"
        package_version='v001'
        manifest_id=$manifest.manifest_id
        manifest_version=$manifest.manifest_version
        profile_class=$manifest.profile.class
        project_id=$manifest.profile.project_id
        manifest_relative='profile/manifest.json'
        content_files=$rows
        content_file_count=$rows.Count
        content_exact_set_sha256=$exact
        resolution_fingerprint=$packageValidation.resolution_fingerprint
        semantic_assertion_ids=@($manifest.semantic_assertions.assertion_id)
        unique_next=$manifest.unique_next
        evidence_ceiling='L6-S'
        nonclaims=@('builder output is not clean recovery','no L6-P','no novel payload')
    }
    $descriptorPath=Join-Path $OutputDirectory 'PACKAGE.json'
    [System.IO.File]::WriteAllText($descriptorPath,($descriptor|ConvertTo-Json -Depth 50),[System.Text.UTF8Encoding]::new($false))
    return [pscustomobject][ordered]@{package_root=[System.IO.Path]::GetFullPath($OutputDirectory);package_id=$descriptor.package_id;descriptor_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $descriptorPath).Hash;content_exact_set_sha256=$exact;content_file_count=$rows.Count;resolution_fingerprint=$packageValidation.resolution_fingerprint}
}

function New-P03R1RuntimeReceipt {
    param([string]$RunId,[string]$ContextId,[string]$PackageId,[string]$Profile,[string]$Status,[string[]]$StopCodes,$Ledger,$Assertions,$UniqueNext,[bool]$Disposed,[string]$EvidenceLevel)
    $grants=[System.Collections.Generic.List[string]]::new()
    if($Status -eq 'pass'){$grants.Add($EvidenceLevel)}
    $receipt=[pscustomobject][ordered]@{
        run_id=$RunId;context_id=$ContextId;package_id=$PackageId;profile=$Profile;status=$Status
        stop_codes=@($StopCodes|Sort-Object -Unique);ledger=$Ledger;assertions=@($Assertions);unique_next=$UniqueNext
        context_disposed=$Disposed;permit='released';lease='released';state_grants=$grants
        evidence_level=$EvidenceLevel;owner=if($Status -eq 'pass'){'s06-recovery-controller'}else{'s06-recovery-remediator'}
        nonclaims=@('no L6-P','no novel status','no legacy migration','no R1 final acceptance')
    }
    $fingerprintBasis=[pscustomobject][ordered]@{package_id=$PackageId;profile=$Profile;status=$Status;stop_codes=@($StopCodes|Sort-Object -Unique);ledger=$Ledger;assertions=@($Assertions);unique_next=$UniqueNext;context_disposed=$Disposed;state_grants=$grants;evidence_level=$EvidenceLevel}
    $receipt|Add-Member -NotePropertyName receipt_fingerprint -NotePropertyValue (Get-P03R1RuntimeFingerprint $fingerprintBasis)
    return $receipt
}

function Invoke-P03R1SyntheticRecovery {
    param(
        [Parameter(Mandatory)][string]$PackageRoot,
        [ValidateSet('none','over-read','write-attempt','assertion-conflict','next-nonunique','disposal-failure')][string]$Injection='none',
        [string]$InjectedReadPath,
        [string]$RunId=("RUN-"+[guid]::NewGuid().ToString('N')),
        [string]$ContextId=("CTX-"+[guid]::NewGuid().ToString('N')),
        [string]$WorkspaceRoot=(Split-Path -Parent $PSScriptRoot)
    )
    $records=[System.Collections.Generic.List[object]]::new()
    $writes=[System.Collections.Generic.List[object]]::new()
    $stop=[System.Collections.Generic.List[string]]::new()
    $contents=@{}
    $sequence=0
    try{
        $packagePath=Join-Path $PackageRoot 'PACKAGE.json'
        if(-not(Test-Path -LiteralPath $packagePath -PathType Leaf)){throw 'RMV2-PACKAGE-MISSING'}
        $descriptor=Get-P03R1RuntimeStrictJson $packagePath
        $declared=@('PACKAGE.json')+@($descriptor.content_files.relative_path)
        $actual=@(Get-ChildItem -LiteralPath $PackageRoot -Recurse -File|ForEach-Object{[System.IO.Path]::GetRelativePath($PackageRoot,$_.FullName).Replace('\','/')}|Sort-Object)
        if((($declared|Sort-Object)-join '|') -ne (($actual|Sort-Object)-join '|')){throw 'RMV2-PACKAGE-EXACT-SET-DRIFT'}
        foreach($row in @($descriptor.content_files)){
            $path=Join-Path $PackageRoot $row.relative_path
            if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw 'RMV2-MISSING-DEPENDENCY'}
            if((Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash -ne $row.sha256 -or (Get-Item -LiteralPath $path).Length -ne $row.bytes){throw 'RMV2-HASH-DRIFT'}
        }
        $rows=@($descriptor.content_files|Sort-Object relative_path)
        $exact=Get-P03R1Rmv2TextSha256 -Text (($rows|ForEach-Object{"$($_.relative_path)|$($_.sha256)|$($_.bytes)"}) -join "`n")
        if($exact -ne $descriptor.content_exact_set_sha256){throw 'RMV2-PACKAGE-EXACT-SET-DRIFT'}
        $manifestPath=Join-Path $PackageRoot $descriptor.manifest_relative
        $manifest=Get-P03R1RuntimeStrictJson $manifestPath
        $manifestValidation=Test-P03R1RecoveryManifestV2 -ManifestPath $manifestPath -WorkspaceRoot $WorkspaceRoot
        if(-not $manifestValidation.valid){throw $manifestValidation.errors[0]}
        $resources=@($manifest.project_payload_reads)+@($manifest.environment_reads)
        $resourceMap=@{};foreach($resource in $resources){$resourceMap[$resource.resource_id]=$resource}
        $allowed=@($resources.canonical_identity|Sort-Object -Unique)
        foreach($stage in @($manifest.load_graph|Sort-Object order)){
            foreach($id in @($stage.resource_ids)){
                if(-not $resourceMap.ContainsKey($id)){throw 'RMV2-MISSING-DEPENDENCY'}
                $resource=$resourceMap[$id]
                $path=Resolve-P03R1Rmv2FilesystemPath -Locator $resource.locator -ManifestDirectory (Split-Path -Parent $manifestPath) -WorkspaceRoot $WorkspaceRoot
                $sequence++
                $bytes=[System.IO.File]::ReadAllBytes($path)
                $hash=[Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes))
                $category=if($resource.origin_dependency_id){'environment'}else{'project-payload'}
                $records.Add([pscustomobject][ordered]@{sequence=$sequence;stage=$stage.stage_id;requested_identity=$id;canonical_identity=$resource.canonical_identity;category=$category;dependency_id=$resource.origin_dependency_id;result='read';bytes=$bytes.Length;observed_fingerprint=$hash})
                if($hash -ne $resource.fingerprint.value -or $bytes.Length -ne $resource.bytes){$stop.Add('RMV2-HASH-DRIFT')}else{$contents[$id]=[System.Text.UTF8Encoding]::new($false,$true).GetString($bytes)}
            }
        }
        if($Injection -eq 'over-read'){
            if([string]::IsNullOrWhiteSpace($InjectedReadPath)){throw 'RMV2-INJECTION-PATH-MISSING'}
            $sequence++;$bytes=[System.IO.File]::ReadAllBytes($InjectedReadPath);$hash=[Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bytes))
            $records.Add([pscustomobject][ordered]@{sequence=$sequence;stage='injected';requested_identity='INJECTED-EXTRA';canonical_identity='synth-extra://over-read';category='undeclared';dependency_id=$null;result='read';bytes=$bytes.Length;observed_fingerprint=$hash})
            $stop.Add('RMV2-OVER-READ')
        }
        if($Injection -eq 'write-attempt'){$writes.Add([pscustomobject][ordered]@{target='synth-write://blocked';result='blocked-before-write'});$stop.Add('RMV2-WRITE-ATTEMPT')}
        $actualIds=@($records.canonical_identity|Sort-Object -Unique)
        $notRead=@($allowed|Where-Object{$_ -notin $actualIds})
        $over=@($actualIds|Where-Object{$_ -notin $allowed})
        foreach($identity in $actualIds){foreach($selector in @($manifest.forbidden_reads)){if(Test-P03R1Rmv2ForbiddenMatch -Identity $identity -Selector $selector){$over+=@($identity);$stop.Add('RMV2-OVER-READ')}}}
        if($notRead.Count){$stop.Add('RMV2-MISSING-DEPENDENCY')}
        $assertions=foreach($assertion in @($manifest.semantic_assertions)){
            $missing=@($assertion.required_resource_ids|Where-Object{-not $contents.ContainsKey($_) -or [string]::IsNullOrWhiteSpace($contents[$_])})
            $matched=($missing.Count -eq 0)
            if($Injection -eq 'assertion-conflict'){$matched=$false}
            if(-not $matched){$stop.Add('RMV2-ASSERTION-CONFLICT')}
            [pscustomobject][ordered]@{assertion_id=$assertion.assertion_id;expected=$assertion.expected;actual=if($matched){$assertion.expected}else{'conflict'};matched=$matched;required_resource_ids=@($assertion.required_resource_ids);nonclaims=@($assertion.nonclaims)}
        }
        $next=$manifest.unique_next
        if($Injection -eq 'next-nonunique'){$next=@($manifest.unique_next,[pscustomobject]@{action='conflict';owner='other';scope='other'});$stop.Add('RMV2-NEXT-NONUNIQUE')}
        $disposed=($Injection -ne 'disposal-failure')
        if(-not $disposed){$stop.Add('RMV2-CONTEXT-DISPOSAL-FAILED')}
        $ledger=[pscustomobject][ordered]@{records=@($records);allowed_reads=$allowed;actual_reads=$actualIds;not_read=@($notRead);environment_reads=@($manifest.environment_reads|ForEach-Object canonical_identity);forbidden_reads=@($manifest.forbidden_reads|ForEach-Object canonical_identity);over_reads=@($over|Sort-Object -Unique);writes=@($writes);not_applicable_dependencies=@()}
        $status=if($stop.Count -eq 0){'pass'}else{'fail-closed'}
        $contents.Clear()
        return New-P03R1RuntimeReceipt -RunId $RunId -ContextId $ContextId -PackageId $descriptor.package_id -Profile $manifest.profile.project_id -Status $status -StopCodes @($stop) -Ledger $ledger -Assertions @($assertions) -UniqueNext $next -Disposed $disposed -EvidenceLevel 'L3-local-runtime'
    }
    catch{
        $code=$_.Exception.Message
        if($code -notmatch '^RMV2-'){$code='RMV2-RUNTIME-FAILURE'}
        $contents.Clear()
        $ledger=[pscustomobject][ordered]@{records=@($records);allowed_reads=@();actual_reads=@($records.canonical_identity|Sort-Object -Unique);not_read=@();environment_reads=@();forbidden_reads=@();over_reads=@();writes=@($writes);not_applicable_dependencies=@()}
        return New-P03R1RuntimeReceipt -RunId $RunId -ContextId $ContextId -PackageId 'unknown' -Profile 'unknown' -Status 'fail-closed' -StopCodes @($code) -Ledger $ledger -Assertions @() -UniqueNext ([pscustomobject]@{action='repair package then rebuild';owner='s06-recovery-remediator';scope='agent-control/p03-r1/synthetic'}) -Disposed $true -EvidenceLevel 'none'
    }
}
