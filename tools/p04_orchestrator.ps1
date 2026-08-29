$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'p04_project_initializer.ps1')

function New-P04OrchestrationDimension([string]$Value,[string]$Evaluation='evaluated') {[ordered]@{value=$Value;evaluation=$Evaluation}}

function ConvertTo-P04OrchestratedRegistry {
    param([Parameter(Mandatory)][string]$RegistryPath)
    $r=Get-Content -Raw -Encoding UTF8 $RegistryPath|ConvertFrom-Json -Depth 40
    if($r.schema_version -eq 'P04-PROJECT-REGISTRY-SCHEMA@v002'){return $r}
    if($r.schema_version -ne 'P04-PROJECT-REGISTRY-SCHEMA@v001'){throw 'unsupported-project-registry-schema'}
    $r.schema_version='P04-PROJECT-REGISTRY-SCHEMA@v002';$r.registry_version='v002'
    $stage=[ordered]@{work=(New-P04OrchestrationDimension 'not-started');gate=(New-P04OrchestrationDimension 'not-evaluated' 'not-evaluated');confirmation=(New-P04OrchestrationDimension 'not-confirmed' 'not-evaluated');sync=(New-P04OrchestrationDimension 'not-synced' 'not-evaluated');risk=(New-P04OrchestrationDimension 'normal')}
    $r|Add-Member orchestration ([pscustomobject][ordered]@{current_stage='P01';stages=[pscustomobject][ordered]@{P01=($stage|ConvertTo-Json -Depth 10|ConvertFrom-Json);P02=($stage|ConvertTo-Json -Depth 10|ConvertFrom-Json);P03=($stage|ConvertTo-Json -Depth 10|ConvertFrom-Json)};signals=[pscustomobject][ordered]@{recovery_pending=$false;source_drift=$false;double_current=$false;missing_evidence=$false;non_unique_next=$false;tier2_pending=$false;tier3_pending=$false;research_blocking=$false;change_pending=$false;sync_pending=$false;confirmation_pending=$false;blocker_fingerprint=$null;blocker_repeats=0};processed_requests=@();run_count=0;last_checkpoint=$null})
    $r.unique_next=[pscustomobject][ordered]@{kind='route';action='run P01 case-design capability';owner='p01-controller';scope="project-control/$($r.project.project_id)/P01"}
    $r
}

function Initialize-P04OrchestrationState {
    param([Parameter(Mandatory)][string]$RegistryPath,[Parameter(Mandatory)][string]$ExpectedSha256)
    $path=[IO.Path]::GetFullPath($RegistryPath);$actual=(Get-FileHash -Algorithm SHA256 $path).Hash;if($actual-ne$ExpectedSha256){throw 'source-drift'}
    $lock=$path+'.orch.lock';try{$stream=[IO.File]::Open($lock,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None);$stream.Dispose()}catch{throw 'writer-lease-conflict'}
    try{$r=ConvertTo-P04OrchestratedRegistry $path;$temp=$path+'.orch.init.tmp';Write-P04Json $temp $r;if((Get-FileHash -Algorithm SHA256 $path).Hash-ne$actual){Remove-Item $temp -Force;throw 'cas-drift-before-commit'};[IO.File]::Move($temp,$path,$true);[pscustomobject]@{status='committed';schema_version=$r.schema_version;registry_version=$r.registry_version;registry_sha256=(Get-FileHash -Algorithm SHA256 $path).Hash;unique_next=$r.unique_next.action}}
    finally{if(Test-Path $lock){Remove-Item $lock -Force}}
}

function Test-P04StageExit($Stage) {
    $Stage.work.value -eq 'completed' -and $Stage.work.evaluation -eq 'evaluated' -and $Stage.gate.value -eq 'yes' -and $Stage.gate.evaluation -eq 'evaluated' -and $Stage.confirmation.value -eq 'confirmed' -and $Stage.confirmation.evaluation -eq 'evaluated' -and $Stage.sync.value -eq 'synced' -and $Stage.sync.evaluation -eq 'evaluated'
}

function Apply-P04SelectiveInvalidation {
    param([Parameter(Mandatory)]$Registry,[Parameter(Mandatory)][ValidateSet('P01','P02','P03')][string]$SourceStage,[Parameter(Mandatory)][string[]]$Dimensions)
    $allowed=@('work','confirmation','sync','risk','gate');foreach($d in $Dimensions){if($d-notin$allowed){throw "unsupported-invalidation-dimension:$d"}}
    $order=@('P01','P02','P03');$start=[array]::IndexOf($order,$SourceStage)
    foreach($stageId in $order[$start..2]){$stage=$Registry.orchestration.stages.$stageId;foreach($d in $Dimensions){switch($d){'work'{$stage.work=New-P04OrchestrationDimension $(if($stageId-eq$SourceStage){'in-progress'}else{'stale'})};'confirmation'{$stage.confirmation=New-P04OrchestrationDimension 'not-confirmed' 'not-evaluated'};'sync'{$stage.sync=New-P04OrchestrationDimension 'not-synced' 'not-evaluated'};'risk'{$stage.risk=New-P04OrchestrationDimension 'needs-revisit'};'gate'{$stage.gate=New-P04OrchestrationDimension 'not-evaluated' 'not-evaluated'}}}}
    $Registry.orchestration.current_stage=$SourceStage;$Registry.orchestration.signals.change_pending=$false;$Registry.unique_next=[pscustomobject][ordered]@{kind='route';action="re-run affected $SourceStage capability";owner='change-owner';scope="project-control/$($Registry.project.project_id)/$SourceStage"};$Registry
}

function Get-P04OrchestrationDecision {
    param([Parameter(Mandatory)]$Registry,[Parameter(Mandatory)]$Catalog)
    $s=$Registry.orchestration.signals
    $currentDupes=@($Registry.current_pointers|Group-Object pointer_key|Where-Object Count -gt 1)
    if($currentDupes.Count-gt0 -or $s.double_current){return [pscustomobject]@{kind='stop';code='double-current';owner='state-owner';next='repair project registry'}}
    foreach($pair in @(@('source_drift','source-drift'),@('missing_evidence','missing-evidence'),@('non_unique_next','non-unique-next'))){if($s.($pair[0])){return [pscustomobject]@{kind='stop';code=$pair[1];owner='state-owner';next='repair and re-evaluate'}}}
    if($s.recovery_pending){return [pscustomobject]@{kind='route';code='recover';owner='recovery-owner';next='resume from current checkpoint'}}
    if($s.tier3_pending){return [pscustomobject]@{kind='stop';code='tier3-exception';owner='user';next='request explicit exception authorization'}}
    if($s.tier2_pending -or $s.confirmation_pending){return [pscustomobject]@{kind='stop';code='tier2-confirmation';owner='user';next='request exact content confirmation'}}
    if($s.research_blocking){return [pscustomobject]@{kind='stop';code='research-blocking';owner='research-owner';next='complete scoped research or adopt fallback'}}
    if($s.change_pending){return [pscustomobject]@{kind='route';code='change';owner='change-owner';next='run selective impact analysis'}}
    if($s.sync_pending){return [pscustomobject]@{kind='route';code='sync';owner='sync-owner';next='run required structural sync'}}
    if($Registry.orchestration.current_stage -eq 'COMPLETE'){return [pscustomobject]@{kind='stop';code='terminal';owner='agent-controller';next='evaluate whole project handoff'}}
    $stageId=$Registry.orchestration.current_stage;$stage=$Registry.orchestration.stages.$stageId
    if(Test-P04StageExit $stage){$next=if($stageId-eq'P01'){'P02'}elseif($stageId-eq'P02'){'P03'}else{'COMPLETE'};return [pscustomobject]@{kind='route';code="handoff-$($stageId.ToLower())-$($next.ToLower())";owner='agent-controller';next="advance current stage to $next"}}
    $cap=$Catalog.stages.$stageId
    [pscustomobject]@{kind='route';code=$cap.route;owner=$cap.owner;skill=$cap.primary_skill;capability_id=$cap.capability_id;required_context=$cap.required_context;not_read=$cap.forbidden_context;next="dispatch $($cap.capability_id)"}
}

function Apply-P04AdapterResult {
    param($Registry,$Request,$Decision)
    $result=$Request.adapter_result;if($null-eq$result){throw 'adapter-result-missing'}
    if($Decision.capability_id -ne $result.capability_id){throw 'adapter-capability-mismatch'}
    if(@($result.evidence_refs).Count-eq0){throw 'adapter-evidence-missing'}
    $stage=$Registry.orchestration.stages.($Registry.orchestration.current_stage)
    switch($result.outcome){
      'success' {if($result.stage_exit_ready){$stage.work=New-P04OrchestrationDimension 'completed';$stage.gate=New-P04OrchestrationDimension 'yes';$stage.confirmation=New-P04OrchestrationDimension 'confirmed';$stage.sync=New-P04OrchestrationDimension 'synced'}else{$stage.work=New-P04OrchestrationDimension 'in-progress'}}
      'research-blocked' {$Registry.orchestration.signals.research_blocking=$true;$stage.risk=New-P04OrchestrationDimension 'blocked'}
      'tier2-pending' {$Registry.orchestration.signals.tier2_pending=$true;$stage.confirmation=New-P04OrchestrationDimension 'pending' 'evaluated'}
      'tier3-pending' {$Registry.orchestration.signals.tier3_pending=$true}
      'failed' {$Registry.orchestration.signals.missing_evidence=$true;$stage.risk=New-P04OrchestrationDimension 'blocked'}
    }
}

function Invoke-P04OrchestrationStep {
    param([Parameter(Mandatory)][string]$RequestPath,[Parameter(Mandatory)][string]$CatalogPath,[ValidateSet('none','before-commit')][string]$InjectFailure='none')
    $raw=Get-Content -Raw -Encoding UTF8 $RequestPath;$schema=Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p04-orchestration-request.schema.json';if(Get-Command Test-Json -ErrorAction SilentlyContinue){if(-not($raw|Test-Json -SchemaFile $schema)){throw 'orchestration-request-invalid'}};$req=$raw|ConvertFrom-Json -Depth 30
    $registryPath=[IO.Path]::GetFullPath($req.registry_path);if(-not(Test-Path $registryPath -PathType Leaf)){throw 'registry-missing'};$actual=(Get-FileHash -Algorithm SHA256 $registryPath).Hash
    $r=Get-Content -Raw -Encoding UTF8 $registryPath|ConvertFrom-Json -Depth 50;if($r.project.project_id-ne$req.project_id){throw 'project-id-mismatch'}
    $catalog=Get-Content -Raw -Encoding UTF8 $CatalogPath|ConvertFrom-Json -Depth 30;$fingerprint=Get-P04Sha256Text (($req|ConvertTo-Json -Depth 30 -Compress));$seen=@($r.orchestration.processed_requests|Where-Object idempotency_key -eq $req.idempotency_key)
    if($seen.Count-gt0){if($seen[0].request_fingerprint-ne$fingerprint){throw 'idempotency-conflict'};return [pscustomobject]@{status='replayed';writes=0;decision=$seen[0].decision;registry_sha256=$actual}}
    if($actual-ne$req.expected_registry_sha256){throw 'source-drift'}
    $lock=$registryPath+'.orch.lock';try{$stream=[IO.File]::Open($lock,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None);$stream.Dispose()}catch{throw 'writer-lease-conflict'}
    try{
      $decision=Get-P04OrchestrationDecision $r $catalog
      if($req.mode-eq'apply-adapter-result'){
        if($decision.kind-ne'route'-or-not$decision.capability_id){throw "adapter-not-allowed:$($decision.code)"};Apply-P04AdapterResult $r $req $decision;$decision=Get-P04OrchestrationDecision $r $catalog
      } elseif($decision.code-like'handoff-*') {$from=$r.orchestration.current_stage;$to=if($from-eq'P01'){'P02'}elseif($from-eq'P02'){'P03'}else{'COMPLETE'};$r.orchestration.current_stage=$to;$decision=Get-P04OrchestrationDecision $r $catalog}
      if($decision.kind-eq'stop'-and$decision.code-notin@('terminal','tier2-confirmation','tier3-exception')){$block=Get-P04Sha256Text "$($decision.code)|$($decision.owner)";if($r.orchestration.signals.blocker_fingerprint-eq$block){$r.orchestration.signals.blocker_repeats=[int]$r.orchestration.signals.blocker_repeats+1}else{$r.orchestration.signals.blocker_fingerprint=$block;$r.orchestration.signals.blocker_repeats=1};if($r.orchestration.signals.blocker_repeats-ge2){$decision=[pscustomobject]@{kind='stop';code='no-progress';owner=$decision.owner;next='route blocker to named owner'}}}
      $r.orchestration.run_count=[int]$r.orchestration.run_count+1;$r.orchestration.processed_requests=@($r.orchestration.processed_requests)+@([pscustomobject][ordered]@{idempotency_key=$req.idempotency_key;request_fingerprint=$fingerprint;decision=$decision.code;evidence_refs=@($req.adapter_result.evidence_refs)})
      $r.orchestration.last_checkpoint=[pscustomobject][ordered]@{checkpoint_id="CP-$($req.project_id)-ORCH-$($r.orchestration.run_count)";source_sha256=$actual;decision=$decision.code;owner=$decision.owner;unique_next=$decision.next}
      $r.unique_next=[pscustomobject][ordered]@{kind=$decision.kind;action=$decision.next;owner=$decision.owner;scope="project-control/$($req.project_id)/orchestration"}
      $number=[int]($r.registry_version.Substring(1));$r.registry_version=('v{0:D3}'-f($number+1));$temp=$registryPath+'.orch.tmp';Write-P04Json $temp $r
      if($InjectFailure-eq'before-commit'){Remove-Item -LiteralPath $temp -Force;throw 'injected-before-commit'}
      if((Get-FileHash -Algorithm SHA256 $registryPath).Hash-ne$actual){Remove-Item -LiteralPath $temp -Force;throw 'cas-drift-before-commit'}
      [IO.File]::Move($temp,$registryPath,$true);$post=Get-Content -Raw -Encoding UTF8 $registryPath|ConvertFrom-Json -Depth 50;if($post.unique_next.action-ne$decision.next){throw 'post-read-mismatch'}
      [pscustomobject]@{status='committed';writes=1;decision=$decision.code;kind=$decision.kind;owner=$decision.owner;unique_next=$decision.next;registry_sha256=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;checkpoint=$post.orchestration.last_checkpoint.checkpoint_id}
    } finally {if(Test-Path $lock){Remove-Item -LiteralPath $lock -Force}}
}
