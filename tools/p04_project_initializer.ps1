$ErrorActionPreference = 'Stop'

function Get-P04Sha256Text {
    param([Parameter(Mandatory)][string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($sha.ComputeHash([Text.UTF8Encoding]::new($false).GetBytes($Text)))).Replace('-','') }
    finally { $sha.Dispose() }
}

function Write-P04Utf8 {
    param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)][string]$Text)
    [void](New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force)
    [IO.File]::WriteAllText($Path,$Text,[Text.UTF8Encoding]::new($false))
}

function Write-P04Json {
    param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)]$Value)
    Write-P04Utf8 -Path $Path -Text (($Value | ConvertTo-Json -Depth 40) + "`n")
}

function Resolve-P04ChildPath {
    param([Parameter(Mandatory)][string]$Root,[Parameter(Mandatory)][string]$Relative)
    if ([IO.Path]::IsPathRooted($Relative)) { throw 'absolute-child-path' }
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $resolved = [IO.Path]::GetFullPath((Join-Path $base $Relative))
    if (-not $resolved.StartsWith($base + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'path-escape' }
    $resolved
}

function Read-P04InitializerRequest {
    param([Parameter(Mandatory)][string]$Path)
    $raw = [IO.File]::ReadAllText($Path,[Text.UTF8Encoding]::new($false,$true))
    $schema = Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p04-project-initializer-request.schema.json'
    if (Get-Command Test-Json -ErrorAction SilentlyContinue) {
        if (-not ($raw | Test-Json -SchemaFile $schema -ErrorAction Stop)) { throw 'request-schema-invalid' }
    }
    $r = $raw | ConvertFrom-Json -Depth 20
    if ($r.request_id -notmatch '^P04-INIT-[A-Z0-9-]+@v[0-9]{3}$') { throw 'request-id-invalid' }
    if ($r.idempotency_key -notmatch '^[A-Za-z0-9._-]{8,80}$') { throw 'idempotency-key-invalid' }
    if ($r.project_id -notmatch '^NOVEL-[A-Z0-9-]{3,48}$') { throw 'project-id-invalid' }
    if ($r.slug -notmatch '^[a-z0-9][a-z0-9-]{1,47}$') { throw 'slug-invalid' }
    if ($r.slug -in @('con','prn','aux','nul','com1','lpt1')) { throw 'reserved-slug' }
    if ($r.template_version -ne 'P04-PROJECT-TEMPLATE@v001') { throw 'template-version-unsupported' }
    $r
}

function Get-P04RequestFingerprint {
    param([Parameter(Mandatory)]$Request)
    $basis = [ordered]@{
        request_id=$Request.request_id; idempotency_key=$Request.idempotency_key; project_id=$Request.project_id
        display_name=$Request.display_name; slug=$Request.slug; output_root=([IO.Path]::GetFullPath($Request.output_root))
        template_version=$Request.template_version
        brief=[ordered]@{seed=$Request.brief.seed;target_length=$Request.brief.target_length;mystery_mode=$Request.brief.mystery_mode;notes=$Request.brief.notes}
    }
    Get-P04Sha256Text (($basis | ConvertTo-Json -Depth 10 -Compress))
}

function Get-P04RequiredPaths {
    @(
        'AGENTS.md','README.md','00-workspace-guide/WORKSPACE-GUIDE.md','00-workspace-guide/RECOVERY.md',
        '01-outline/README.md','02-rules/CHANGELOG.md','03-setting/README.md','04-state/project-registry.json',
        '04-state/views/CURRENT.md','04-state/views/TASK.md','04-state/views/RECOVERY.md',
        '05-drafts/raw/README.md','05-drafts/revised/README.md','08-manuscript/formal/README.md',
        'bootstrap/CHECKPOINT.json'
    )
}

function New-P04ProjectRegistry {
    param([Parameter(Mandatory)]$Request,[Parameter(Mandatory)][string]$ProjectRoot,[Parameter(Mandatory)][string]$Fingerprint,[Parameter(Mandatory)][string]$ExactSetHash)
    [ordered]@{
        registry_id="PCR-$($Request.project_id)"; schema_version='P04-PROJECT-REGISTRY-SCHEMA@v001'; registry_version='v001'
        project=[ordered]@{project_id=$Request.project_id;display_name=$Request.display_name;slug=$Request.slug;root=$ProjectRoot;brief=$Request.brief}
        coverage=[ordered]@{included=@("project-control/$($Request.project_id)");excluded=@('other projects','Agent canonical registry','unadmitted novel payloads','external publishing')}
        state=[ordered]@{
            work=[ordered]@{value='initialized';evaluation='evaluated'}
            confirmation=[ordered]@{value='not-required';evaluation='not-applicable'}
            sync=[ordered]@{value='synced';evaluation='evaluated'}
            risk=[ordered]@{value='normal';evaluation='evaluated'}
            gate=[ordered]@{value='not-evaluated';evaluation='not-evaluated'}
            lifecycle=[ordered]@{value='current';evaluation='evaluated'}
            governance_decision=[ordered]@{value='tier1-autonomous';evaluation='evaluated'}
        }
        objects=@([ordered]@{object_ref="PROJECT-$($Request.project_id)@v001";object_type='project-state';scope="project-control/$($Request.project_id)";lifecycle='current'})
        current_pointers=@([ordered]@{pointer_key='project-state';object_ref="PROJECT-$($Request.project_id)@v001"})
        unique_next=[ordered]@{kind='task-review';action='建立 P01 项目简报与案件设计入口';owner='agent-controller';scope="project-control/$($Request.project_id)/P01"}
        bootstrap=[ordered]@{request_id=$Request.request_id;request_fingerprint=$Fingerprint;template_version=$Request.template_version;exact_set_hash=$ExactSetHash}
    }
}

function Get-P04ProjectViewText {
    param([Parameter(Mandatory)]$Registry,[Parameter(Mandatory)][string]$RegistryHash,[Parameter(Mandatory)][ValidateSet('CURRENT','TASK','RECOVERY')][string]$Kind)
    switch ($Kind) {
        'CURRENT' { "# Current Project State`n`n- project: ``$($Registry.project.project_id)```n- registry: ``$($Registry.registry_id)@$($Registry.registry_version)```n- registry SHA-256: ``$RegistryHash```n- lifecycle: ``$($Registry.state.lifecycle.value)```n- gate: ``$($Registry.state.gate.value)```n- unique next: ``$($Registry.unique_next.action)```n" }
        'TASK' { "# Current Task`n`n- project: ``$($Registry.project.project_id)`` `n- work: ``$($Registry.state.work.value)```n- confirmation: ``$($Registry.state.confirmation.value)```n- sync: ``$($Registry.state.sync.value)```n- risk: ``$($Registry.state.risk.value)```n- next owner: ``$($Registry.unique_next.owner)```n" }
        'RECOVERY' { "# Recovery View`n`n- registry SHA-256: ``$RegistryHash```n- read first: ``AGENTS.md`` then ``00-workspace-guide/RECOVERY.md`` then ``04-state/project-registry.json```n- unique next: ``$($Registry.unique_next.action)```n- do not read: other projects, future manuscript, old chat`n" }
    }
}

function Build-P04ProjectViews {
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $registryPath = Join-Path $ProjectRoot '04-state/project-registry.json'
    $registry = [IO.File]::ReadAllText($registryPath,[Text.UTF8Encoding]::new($false,$true)) | ConvertFrom-Json -Depth 30
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $registryPath).Hash
    foreach ($kind in @('CURRENT','TASK','RECOVERY')) {
        Write-P04Utf8 -Path (Join-Path $ProjectRoot "04-state/views/$kind.md") -Text (Get-P04ProjectViewText -Registry $registry -RegistryHash $hash -Kind $kind)
    }
    [pscustomobject]@{registry_hash=$hash;view_count=3}
}

function Invoke-P04ProjectInitializer {
    param([Parameter(Mandatory)][string]$RequestPath,[ValidateSet('none','after-stage','before-commit')][string]$InjectFailure='none')
    $request = Read-P04InitializerRequest $RequestPath
    $output = [IO.Path]::GetFullPath($request.output_root)
    if (-not (Test-Path -LiteralPath $output -PathType Container)) { throw 'output-root-missing' }
    if ((Get-Item -LiteralPath $output).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'output-root-reparse-point' }
    $target = Resolve-P04ChildPath -Root $output -Relative $request.slug
    $fingerprint = Get-P04RequestFingerprint $request
    if (Test-Path -LiteralPath $target) {
        $manifestPath = Join-Path $target 'bootstrap/BOOTSTRAP.json'
        if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'target-collision-unmanaged' }
        $manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json -Depth 20
        if ($manifest.request_fingerprint -ne $fingerprint -or $manifest.project_id -ne $request.project_id) { throw 'target-collision-different-request' }
        return [pscustomobject]@{status='replayed';committed=$true;project_root=$target;request_fingerprint=$fingerprint;exact_set_hash=$manifest.exact_set_hash;writes=0}
    }
    $control = Join-Path $output '.p04-initializer'
    [void](New-Item -ItemType Directory -Path $control -Force)
    $lock = Join-Path $control "$($request.slug).lock"
    try { $stream=[IO.File]::Open($lock,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None); $stream.Dispose() }
    catch { throw 'writer-lease-conflict' }
    $stage = Join-Path $output ".p04-stage-$($request.slug)-$($request.idempotency_key)"
    try {
        if (Test-Path -LiteralPath $stage) { throw 'staging-collision' }
        [void](New-Item -ItemType Directory -Path $stage)
        $templateRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'templates/P04-project-v001'
        foreach ($file in Get-ChildItem -LiteralPath $templateRoot -Recurse -File | Sort-Object FullName) {
            $relative = $file.FullName.Substring($templateRoot.Length).TrimStart('\','/').Replace('\','/') -replace '\.tmpl$',''
            $text = [IO.File]::ReadAllText($file.FullName,[Text.UTF8Encoding]::new($false,$true))
            $text = $text.Replace('{{DISPLAY_NAME}}',$request.display_name).Replace('{{PROJECT_ID}}',$request.project_id).Replace('{{REQUEST_ID}}',$request.request_id)
            Write-P04Utf8 -Path (Resolve-P04ChildPath -Root $stage -Relative $relative) -Text $text
        }
        $required = Get-P04RequiredPaths
        $pathHash = Get-P04Sha256Text (($required | Sort-Object) -join "`n")
        $registry = New-P04ProjectRegistry -Request $request -ProjectRoot $target -Fingerprint $fingerprint -ExactSetHash $pathHash
        Write-P04Json -Path (Join-Path $stage '04-state/project-registry.json') -Value $registry
        [void](Build-P04ProjectViews -ProjectRoot $stage)
        $checkpoint=[ordered]@{checkpoint_id="CP-$($request.project_id)-BOOTSTRAP@v001";project_id=$request.project_id;registry_ref="$($registry.registry_id)@$($registry.registry_version)";unique_next=$registry.unique_next;status='committed-with-project'}
        Write-P04Json -Path (Join-Path $stage 'bootstrap/CHECKPOINT.json') -Value $checkpoint
        $actual = @(Get-ChildItem -LiteralPath $stage -Recurse -File | ForEach-Object { $_.FullName.Substring($stage.Length).TrimStart('\','/').Replace('\','/') } | Sort-Object)
        if ((Compare-Object ($required|Sort-Object) $actual).Count -ne 0) { throw 'template-exact-set-mismatch' }
        if ($InjectFailure -eq 'after-stage') { throw 'injected-after-stage' }
        $records=@(foreach($rel in $actual){$p=Resolve-P04ChildPath -Root $stage -Relative $rel;[ordered]@{path=$rel;sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash;bytes=(Get-Item -LiteralPath $p).Length}})
        $manifest=[ordered]@{manifest_id="PBM-$($request.project_id)@v001";request_id=$request.request_id;request_fingerprint=$fingerprint;project_id=$request.project_id;project_root=$target;template_version=$request.template_version;status='committed';commit_point='atomic-directory-rename';files=$records;exact_set_hash=$pathHash}
        Write-P04Json -Path (Join-Path $stage 'bootstrap/BOOTSTRAP.json') -Value $manifest
        if ($InjectFailure -eq 'before-commit') { throw 'injected-before-commit' }
        Move-Item -LiteralPath $stage -Destination $target
        [pscustomobject]@{status='committed';committed=$true;project_root=$target;request_fingerprint=$fingerprint;exact_set_hash=$pathHash;writes=($records.Count+1)}
    }
    catch {
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
        throw
    }
    finally { if (Test-Path -LiteralPath $lock) { Remove-Item -LiteralPath $lock -Force } }
}

function Test-P04InitializedProject {
    param([Parameter(Mandatory)][string]$ProjectRoot)
    $errors=[Collections.Generic.List[string]]::new()
    $manifestPath=Join-Path $ProjectRoot 'bootstrap/BOOTSTRAP.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { return [pscustomobject]@{valid=$false;errors=@('manifest-missing')} }
    $manifest=Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath|ConvertFrom-Json -Depth 30
    $required=Get-P04RequiredPaths
    if ($manifest.exact_set_hash -ne (Get-P04Sha256Text (($required|Sort-Object)-join "`n"))) {$errors.Add('required-exact-set-hash-mismatch')}
    foreach($f in @($manifest.files)){$p=Resolve-P04ChildPath -Root $ProjectRoot -Relative $f.path;if(-not(Test-Path -LiteralPath $p -PathType Leaf)){$errors.Add("missing:$($f.path)")}elseif((Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash -ne $f.sha256){$errors.Add("drift:$($f.path)")}}
    $declared=@($manifest.files|ForEach-Object path|Sort-Object)
    $actual=@(Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File|ForEach-Object{$_.FullName.Substring($ProjectRoot.Length).TrimStart('\','/').Replace('\','/')}|Where-Object{$_ -ne 'bootstrap/BOOTSTRAP.json'}|Sort-Object)
    if((Compare-Object $declared $actual).Count -ne 0){$errors.Add('project-exact-set-mismatch')}
    $registryPath=Join-Path $ProjectRoot '04-state/project-registry.json'
    $registry=Get-Content -Raw -Encoding UTF8 -LiteralPath $registryPath|ConvertFrom-Json -Depth 30
    $dupes=@($registry.current_pointers|Group-Object pointer_key|Where-Object Count -gt 1)
    if($dupes.Count -gt 0){$errors.Add('double-current')}
    if($registry.project.root -ne [IO.Path]::GetFullPath($ProjectRoot)){$errors.Add('project-root-mismatch')}
    [pscustomobject]@{valid=($errors.Count-eq 0);errors=@($errors);project_id=$registry.project.project_id;unique_next=$registry.unique_next.action;double_current=$dupes.Count}
}
