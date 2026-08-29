$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'p04_project_initializer.ps1')
. (Join-Path $PSScriptRoot 'p04_orchestrator.ps1')

function Write-P04InteractionJsonAtomic {
    param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)]$Value)
    $full=[IO.Path]::GetFullPath($Path);[void](New-Item -ItemType Directory -Path (Split-Path -Parent $full) -Force)
    $temp=$full+'.tmp';Write-P04Json $temp $Value;[IO.File]::Move($temp,$full,$true)
}

function Get-P04InteractionClassification {
    param([Parameter(Mandatory)][string]$DecisionCode)
    if($DecisionCode -eq 'terminal'){return 'terminal'}
    if($DecisionCode -eq 'tier3-exception'){return 'tier3'}
    if($DecisionCode -eq 'tier2-confirmation'){return 'tier2'}
    if($DecisionCode -in @('source-drift','double-current','missing-evidence','non-unique-next','research-blocking','no-progress','unsafe-scope','over-read','partial-write','writer-lease-conflict','capability-invoker-missing','owner-dispatch-required','invalid-tier2-binding','invalid-tier3-binding')){return 'internal-stop'}
    'tier1'
}

function New-P04Tier2Prompt {
    param([Parameter(Mandatory)]$Binding)
    [pscustomobject][ordered]@{
        kind='content-confirmation';current_object=$Binding.object_ref;scope=$Binding.scope
        change_summary=$Binding.change_summary;not_included=@($Binding.not_included)
        request="请明确确认 $($Binding.object_ref)；泛泛的‘继续/可以/好/不错’不会被视为内容确认。"
        confirmation_token=$Binding.confirmation_token
    }
}

function New-P04Tier3Prompt {
    param([Parameter(Mandatory)]$Binding)
    $forbidden=@($Binding.non_grants) -join '、'
    $statement="我授权 $($Binding.authorization_token)：仅对 $($Binding.object_ref) 执行 $($Binding.action)；范围为 $($Binding.scope)；禁止 $forbidden；若 $($Binding.fail_closed) 则立即 fail-closed；完成后释放本次运行上下文并记录 checkpoint。"
    [pscustomobject][ordered]@{
        kind='tier3-exception';current_object=$Binding.object_ref;action=$Binding.action;impact=$Binding.impact
        reversible=[bool]$Binding.reversible;recommendation=$Binding.recommendation;authorization_statement=$statement
    }
}

function New-P04InternalStopSummary {
    param([Parameter(Mandatory)][string]$Code,[Parameter(Mandatory)][string]$Owner,[Parameter(Mandatory)][string]$Next)
    [pscustomobject][ordered]@{kind='internal-stop';result=$Code;protected_state='no unsupported status granted';user_action='none';owner=$Owner;unique_next=$Next;authorization_statement=$null}
}

function Add-P04InteractionEvent {
    param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)]$Event)
    $raw=$Event|ConvertTo-Json -Depth 20 -Compress
    $schema=Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p04-interaction-event.schema.json'
    if(Get-Command Test-Json -ErrorAction SilentlyContinue){if(-not($raw|Test-Json -SchemaFile $schema)){throw 'interaction-event-invalid'}}
    [void](New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($Path))) -Force)
    [IO.File]::AppendAllText([IO.Path]::GetFullPath($Path),$raw+[Environment]::NewLine,[Text.UTF8Encoding]::new($false))
}

function Get-P04TelemetryMetrics {
    param([Parameter(Mandatory)][string[]]$EventPaths,[int]$InvalidConfirmationAttempts=0,[int]$HumanRepairActions=0,[int]$RecoveryElapsedMs=0)
    $events=@(foreach($path in $EventPaths){if(Test-Path -LiteralPath $path){Get-Content -Encoding UTF8 -LiteralPath $path|Where-Object {$_}|ForEach-Object{$_|ConvertFrom-Json -Depth 20}}})
    $tier1=@($events|Where-Object classification -eq 'tier1').Count;$tier2=@($events|Where-Object classification -eq 'tier2').Count;$tier3=@($events|Where-Object classification -eq 'tier3').Count;$internal=@($events|Where-Object classification -eq 'internal-stop').Count;$terminal=@($events|Where-Object classification -eq 'terminal').Count;$budget=@($events|Where-Object classification -eq 'budget-pause').Count
    $actionable=$tier1+$tier2+$tier3+$internal
    [pscustomobject][ordered]@{
        events=$events.Count;tier1_steps=$tier1;tier2_stops=$tier2;tier3_stops=$tier3;internal_stops=$internal;terminal_events=$terminal;budget_pauses=$budget
        automatic_progress_rate=$(if($actionable -eq 0){0}else{[math]::Round($tier1/$actionable,4)})
        internal_authorization_requests=@($events|Where-Object internal_authorization_request).Count
        authorization_requests=@($events|Where-Object authorization_requested).Count
        invalid_confirmation_attempts=$InvalidConfirmationAttempts;recovery_elapsed_ms=$RecoveryElapsedMs;human_repair_actions=$HumanRepairActions
    }
}

function Get-P04UserSummary {
    param([Parameter(Mandatory)]$SessionResult)
    [pscustomobject][ordered]@{
        result=$SessionResult.result;current_object=$SessionResult.current_object;actual_change=$SessionResult.actual_change
        validation=$SessionResult.validation;user_action=$SessionResult.user_action;unique_next=$SessionResult.unique_next
    }
}

function Test-P04Tier2ConfirmationResponse {
    param([Parameter(Mandatory)]$Response,[Parameter(Mandatory)]$Binding)
    if($Response.response_type -ne 'explicit-confirmation'){return [pscustomobject]@{valid=$false;code='confirmation-type-invalid'}}
    if($Response.user_text -match '^\s*(继续|可以|好|不错|收到|ok|okay)\s*[。！!]?\s*$'){return [pscustomobject]@{valid=$false;code='ambiguous-confirmation'}}
    if($Response.confirmation_token -ne $Binding.confirmation_token){return [pscustomobject]@{valid=$false;code='confirmation-token-mismatch'}}
    if($Response.object_ref -ne $Binding.object_ref -or $Response.object_fingerprint -ne $Binding.object_fingerprint -or $Response.scope -ne $Binding.scope){return [pscustomobject]@{valid=$false;code='confirmation-object-mismatch'}}
    if($Response.user_text -notmatch [regex]::Escape($Binding.object_ref)){return [pscustomobject]@{valid=$false;code='confirmation-object-not-explicit'}}
    [pscustomobject]@{valid=$true;code='explicit-object-bound-confirmation'}
}

function Confirm-P04Tier2Content {
    param([Parameter(Mandatory)][string]$ResponsePath)
    $raw=Get-Content -Raw -Encoding UTF8 -LiteralPath $ResponsePath;$schema=Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p04-content-confirmation-response.schema.json'
    if(Get-Command Test-Json -ErrorAction SilentlyContinue){if(-not($raw|Test-Json -SchemaFile $schema)){throw 'confirmation-response-invalid'}};$response=$raw|ConvertFrom-Json -Depth 20
    $registryPath=[IO.Path]::GetFullPath($response.registry_path);$actual=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;if($actual -ne $response.expected_registry_sha256){throw 'source-drift'}
    $registry=Get-Content -Raw -Encoding UTF8 $registryPath|ConvertFrom-Json -Depth 60;if($registry.project.project_id -ne $response.project_id){throw 'project-id-mismatch'}
    if($null -eq $registry.interaction -or $null -eq $registry.interaction.pending_confirmation){throw 'confirmation-not-pending'};$binding=$registry.interaction.pending_confirmation
    $check=Test-P04Tier2ConfirmationResponse $response $binding;if(-not $check.valid){throw $check.code}
    if(@($registry.interaction.confirmation_receipts|Where-Object confirmation_token -eq $binding.confirmation_token).Count -gt 0){throw 'confirmation-replay'}
    $lock=$registryPath+'.orch.lock';try{$stream=[IO.File]::Open($lock,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None);$stream.Dispose()}catch{throw 'writer-lease-conflict'}
    try{
        $stage=$registry.orchestration.stages.($registry.orchestration.current_stage);$stage.confirmation=New-P04OrchestrationDimension 'confirmed' 'evaluated'
        $registry.orchestration.signals.tier2_pending=$false;$registry.orchestration.signals.confirmation_pending=$false
        $receipt=[pscustomobject][ordered]@{receipt_id="CONF-$($binding.confirmation_token)";confirmation_token=$binding.confirmation_token;object_ref=$binding.object_ref;object_fingerprint=$binding.object_fingerprint;scope=$binding.scope;status='confirmed/evaluated'}
        $registry.interaction.confirmation_receipts=@($registry.interaction.confirmation_receipts)+@($receipt);$registry.interaction.pending_confirmation=$null
        $registry.unique_next=[pscustomobject][ordered]@{kind='route';action='resume autonomous downstream processing';owner='agent-controller';scope="project-control/$($registry.project.project_id)/interaction"}
        $number=[int]$registry.registry_version.Substring(1);$registry.registry_version=('v{0:D3}' -f ($number+1));$temp=$registryPath+'.confirm.tmp';Write-P04Json $temp $registry
        if((Get-FileHash -Algorithm SHA256 $registryPath).Hash -ne $actual){Remove-Item -LiteralPath $temp -Force;throw 'cas-drift-before-commit'};[IO.File]::Move($temp,$registryPath,$true)
        [pscustomobject]@{status='confirmed';writes=1;receipt=$receipt;registry_sha256=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;unique_next=$registry.unique_next.action}
    } finally {if(Test-Path $lock){Remove-Item -LiteralPath $lock -Force}}
}

function Invoke-P04InteractionSession {
    param([Parameter(Mandatory)][string]$RequestPath,[scriptblock]$CapabilityInvoker,[ValidateSet('none','after-step-before-checkpoint')][string]$InjectFailure='none')
    $requestRaw=Get-Content -Raw -Encoding UTF8 -LiteralPath $RequestPath;$schema=Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p04-interaction-session-request.schema.json'
    if(Get-Command Test-Json -ErrorAction SilentlyContinue){if(-not($requestRaw|Test-Json -SchemaFile $schema)){throw 'interaction-request-invalid'}};$request=$requestRaw|ConvertFrom-Json -Depth 30
    $registryPath=[IO.Path]::GetFullPath($request.registry_path);$catalogPath=[IO.Path]::GetFullPath($request.catalog_path);$sessionRoot=[IO.Path]::GetFullPath($request.session_root)
    if(-not(Test-Path $registryPath -PathType Leaf) -or -not(Test-Path $catalogPath -PathType Leaf)){throw 'interaction-input-missing'}
    $projectRoot=Split-Path -Parent (Split-Path -Parent $registryPath);$rootPrefix=$projectRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar;if(-not $sessionRoot.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)){throw 'unsafe-session-root'}
    [void](New-Item -ItemType Directory -Path $sessionRoot -Force);if($request.resume_checkpoint){$resumePath=[IO.Path]::GetFullPath($request.resume_checkpoint);if(-not $resumePath.StartsWith($sessionRoot.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or -not(Test-Path $resumePath -PathType Leaf)){throw 'resume-checkpoint-invalid'};$resume=Get-Content -Raw -Encoding UTF8 $resumePath|ConvertFrom-Json -Depth 30;if($resume.project_id -ne $request.project_id -or $resume.result -notin @('paused','stopped')){throw 'resume-checkpoint-mismatch'}};$safe=$request.session_id -replace '[^A-Za-z0-9._-]','_';$checkpointPath=Join-Path $sessionRoot "$safe.checkpoint.json";$eventPath=Join-Path $sessionRoot "$safe.events.jsonl";$fingerprint=Get-P04Sha256Text ($request|ConvertTo-Json -Depth 30 -Compress)
    if(Test-Path $checkpointPath){$old=Get-Content -Raw -Encoding UTF8 $checkpointPath|ConvertFrom-Json -Depth 30;if($old.request_fingerprint -ne $fingerprint){throw 'session-idempotency-conflict'};return [pscustomobject]@{status='replayed';writes=0;result=$old.result;classification=$old.classification;checkpoint=$checkpointPath;events=$eventPath;unique_next=$old.unique_next}}
    $actual=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;if($actual -ne $request.expected_registry_sha256){throw 'source-drift'};$registry=Get-Content -Raw -Encoding UTF8 $registryPath|ConvertFrom-Json -Depth 60;if($registry.project.project_id -ne $request.project_id){throw 'project-id-mismatch'}
    $sessionLock=Join-Path $sessionRoot '.interaction.lock';try{$stream=[IO.File]::Open($sessionLock,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None);$stream.Dispose()}catch{throw 'interaction-session-conflict'}
    $watch=[Diagnostics.Stopwatch]::StartNew();$steps=0;$writes=0;$sequence=0;$final=$null;$injected=$false
    try{
        while($true){
            $stepResult=$null;$registry=Get-Content -Raw -Encoding UTF8 $registryPath|ConvertFrom-Json -Depth 60;$catalog=Get-Content -Raw -Encoding UTF8 $catalogPath|ConvertFrom-Json -Depth 30;$decision=Get-P04OrchestrationDecision $registry $catalog;$classification=Get-P04InteractionClassification $decision.code
            if($classification -eq 'tier1'){
                if($steps -ge $request.budgets.max_steps -or $writes -ge $request.budgets.max_writes -or $watch.ElapsedMilliseconds -ge $request.budgets.max_elapsed_ms){$classification='budget-pause';$decision=[pscustomobject]@{code='run-budget-exhausted';owner='agent-controller';next='resume from interaction checkpoint'} }
                elseif($decision.capability_id){
                    if($null -eq $CapabilityInvoker){$classification='internal-stop';$decision=[pscustomobject]@{code='capability-invoker-missing';owner=$decision.owner;next='bind capability invoker and resume'}}
                    else{
                        $adapter=& $CapabilityInvoker $decision $steps;if($null -eq $adapter){$classification='internal-stop';$decision=[pscustomobject]@{code='capability-invoker-missing';owner=$decision.owner;next='supply adapter result and resume'}}
                        else{$orch=[ordered]@{request_id="P04-ORCH-$($request.project_id.Replace('_','-'))-IX$('{0:D2}' -f ($steps+1))@v001";idempotency_key="$($request.idempotency_key)-s$('{0:D2}' -f ($steps+1))";project_id=$request.project_id;registry_path=$registryPath;expected_registry_sha256=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;mode='apply-adapter-result';adapter_result=$adapter};$orchPath=Join-Path $sessionRoot "$safe.step-$('{0:D2}' -f ($steps+1)).json";Write-P04Json $orchPath $orch;$stepResult=Invoke-P04OrchestrationStep $orchPath $catalogPath;$steps++;$writes+=$stepResult.writes;$decision=[pscustomobject]@{code=$stepResult.decision;owner=$stepResult.owner;next=$stepResult.unique_next};$classification=Get-P04InteractionClassification $stepResult.decision}
                    }
                } elseif($decision.code -like 'handoff-*'){
                    $orch=[ordered]@{request_id="P04-ORCH-$($request.project_id.Replace('_','-'))-IX$('{0:D2}' -f ($steps+1))@v001";idempotency_key="$($request.idempotency_key)-s$('{0:D2}' -f ($steps+1))";project_id=$request.project_id;registry_path=$registryPath;expected_registry_sha256=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;mode='route-only'};$orchPath=Join-Path $sessionRoot "$safe.step-$('{0:D2}' -f ($steps+1)).json";Write-P04Json $orchPath $orch;$stepResult=Invoke-P04OrchestrationStep $orchPath $catalogPath;$steps++;$writes+=$stepResult.writes;$decision=[pscustomobject]@{code=$stepResult.decision;owner=$stepResult.owner;next=$stepResult.unique_next};$classification=Get-P04InteractionClassification $stepResult.decision
                } else {$classification='internal-stop';$decision=[pscustomobject]@{code='owner-dispatch-required';owner=$decision.owner;next=$decision.next}}
            } elseif($classification -in @('tier2','tier3','internal-stop')){
                $orch=[ordered]@{request_id="P04-ORCH-$($request.project_id.Replace('_','-'))-IX$('{0:D2}' -f ($steps+1))@v001";idempotency_key="$($request.idempotency_key)-s$('{0:D2}' -f ($steps+1))";project_id=$request.project_id;registry_path=$registryPath;expected_registry_sha256=(Get-FileHash -Algorithm SHA256 $registryPath).Hash;mode='route-only'};$orchPath=Join-Path $sessionRoot "$safe.step-$('{0:D2}' -f ($steps+1)).json";Write-P04Json $orchPath $orch;$stepResult=Invoke-P04OrchestrationStep $orchPath $catalogPath;$steps++;$writes+=$stepResult.writes;$decision=[pscustomobject]@{code=$stepResult.decision;owner=$stepResult.owner;next=$stepResult.unique_next};$classification=Get-P04InteractionClassification $stepResult.decision
            }
            if($InjectFailure -eq 'after-step-before-checkpoint' -and -not $injected -and $writes -gt 0){$injected=$true;throw 'injected-after-step-before-checkpoint'}
            $registry=Get-Content -Raw -Encoding UTF8 $registryPath|ConvertFrom-Json -Depth 60
            if($classification -eq 'tier2' -and ($null -eq $registry.interaction -or $null -eq $registry.interaction.pending_confirmation)){$classification='internal-stop';$decision=[pscustomobject]@{code='invalid-tier2-binding';owner='state-owner';next='repair confirmation binding'}}
            if($classification -eq 'tier3' -and ($null -eq $registry.interaction -or $null -eq $registry.interaction.pending_exception)){$classification='internal-stop';$decision=[pscustomobject]@{code='invalid-tier3-binding';owner='state-owner';next='repair exception binding'}}
            $sequence++;$userAction=$classification -in @('tier2','tier3');$authRequested=$classification -eq 'tier3';$internalAuth=$authRequested -and $decision.code -notin @('tier3-exception')
            $event=[pscustomobject][ordered]@{event_id="EV-$($request.session_id)-$('{0:D3}' -f $sequence)";session_id=$request.session_id;sequence=$sequence;project_id=$request.project_id;classification=$classification;decision=$decision.code;owner=$decision.owner;writes=$(if($null -eq $stepResult){0}else{$stepResult.writes});user_action_required=$userAction;authorization_requested=$authRequested;internal_authorization_request=$internalAuth;checkpoint=$(if($null -eq $stepResult){$null}else{$stepResult.checkpoint});elapsed_ms=[int]$watch.ElapsedMilliseconds};Add-P04InteractionEvent $eventPath $event
            if($classification -eq 'tier1'){continue}
            $prompt=$null
            if($classification -eq 'tier2'){$prompt=New-P04Tier2Prompt $registry.interaction.pending_confirmation}
            elseif($classification -eq 'tier3'){$prompt=New-P04Tier3Prompt $registry.interaction.pending_exception}
            elseif($classification -eq 'internal-stop'){$prompt=New-P04InternalStopSummary $decision.code $decision.owner $decision.next}
            $result=$(if($classification -eq 'terminal'){'completed'}elseif($classification -eq 'budget-pause'){'paused'}else{'stopped'});$final=[ordered]@{session_id=$request.session_id;project_id=$request.project_id;request_fingerprint=$fingerprint;result=$result;classification=$classification;decision=$decision.code;steps=$steps;writes=$writes;current_object=$(if($prompt){$prompt.current_object}else{$registry.orchestration.current_stage});actual_change="$writes canonical step writes";validation='checkpointed';user_action=$(if($classification -eq 'tier2'){'confirm current content object'}elseif($classification -eq 'tier3'){'decide on explicit exception'}else{'none'});unique_next=$decision.next;prompt=$prompt;event_path=$eventPath};Write-P04InteractionJsonAtomic $checkpointPath $final;break
        }
        [pscustomobject]@{status='completed';writes=$writes;result=$final.result;classification=$final.classification;decision=$final.decision;steps=$steps;checkpoint=$checkpointPath;events=$eventPath;prompt=$final.prompt;unique_next=$final.unique_next}
    } finally {$watch.Stop();if(Test-Path $sessionLock){Remove-Item -LiteralPath $sessionLock -Force}}
}
