[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $repoRoot 'tools/p04_project_initializer.ps1')
. (Join-Path $repoRoot 'tools/p04_orchestrator.ps1')
. (Join-Path $repoRoot 'tools/evaluate_p03_r1_action.ps1')

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
$tempRoot = Join-Path $tempBase ("medium-long-mystery-smoke-" + [Guid]::NewGuid().ToString('N'))
$outputRoot = Join-Path $tempRoot 'projects'
$requestRoot = Join-Path $tempRoot 'requests'
[void](New-Item -ItemType Directory -Path $outputRoot -Force)
[void](New-Item -ItemType Directory -Path $requestRoot -Force)

try {
    $request = [ordered]@{
        request_id = 'P04-INIT-RELEASE-SMOKE@v001'
        idempotency_key = 'release-smoke-v001'
        project_id = 'NOVEL-RELEASE-SMOKE'
        display_name = '发布包冒烟项目'
        slug = 'release-smoke'
        output_root = $outputRoot
        template_version = 'P04-PROJECT-TEMPLATE@v001'
        brief = [ordered]@{
            seed = '一条合成种子，只用于验证初始化，不构成小说正文'
            target_length = 'medium'
            mystery_mode = '社会派悬疑'
            notes = 'synthetic/no novel payload'
        }
    }
    $requestPath = Join-Path $requestRoot 'init.json'
    [IO.File]::WriteAllText($requestPath, (($request | ConvertTo-Json -Depth 10) + "`n"), [Text.UTF8Encoding]::new($false))

    $created = Invoke-P04ProjectInitializer -RequestPath $requestPath
    $replayed = Invoke-P04ProjectInitializer -RequestPath $requestPath
    $projectCheck = Test-P04InitializedProject -ProjectRoot $created.project_root
    if (-not $projectCheck.valid) { throw "initializer-invalid:$($projectCheck.errors -join ',')" }
    if ($replayed.status -ne 'replayed') { throw 'initializer-idempotency-failed' }

    $registryPath = Join-Path $created.project_root '04-state/project-registry.json'
    $registry = ConvertTo-P04OrchestratedRegistry -RegistryPath $registryPath
    $catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repoRoot 'config/p04-stage-capability-catalog-v001.json') | ConvertFrom-Json -Depth 30
    $decision = Get-P04OrchestrationDecision -Registry $registry -Catalog $catalog
    if ($decision.kind -ne 'route' -or [string]::IsNullOrWhiteSpace($decision.capability_id)) { throw 'orchestration-route-missing' }

    $tier1Action = [pscustomobject]@{
        action_id='SMOKE-T1';in_scope=$true;reversible=$true;target_exact=$true;external_effect=$false;protected_source_write=$false
        destructive=$false;new_private_data_scope=$false;significant_cost_or_risk=$false;independent_agent_l6=$false
        synthetic_clean_session=$false;critical_truth_change=$false;act_structure_or_ending_change=$false
        candidate_content_confirmation=$false;chapter_content_confirmation=$false;full_book_final_confirmation=$false
        creative_direction_choice=$false;safety_blocking=$false;evidence_blocking=$false;source_drift=$false
    }
    $tier1 = Get-P03R1ActionDecision -Action $tier1Action
    if ($tier1.decision -ne 'tier1-autonomous') { throw 'tier1-classification-failed' }

    $wrapperJson = & (Join-Path $repoRoot 'scripts/new-project.ps1') `
        -OutputRoot $outputRoot `
        -ProjectId 'NOVEL-WRAPPER-SMOKE' `
        -DisplayName '入口脚本冒烟项目' `
        -Slug 'wrapper-smoke' `
        -Seed '只用于入口验证的合成种子'
    $wrapper = $wrapperJson | ConvertFrom-Json -Depth 10
    if ($wrapper.status -ne 'committed' -or -not (Test-Path -LiteralPath $wrapper.project_root -PathType Container)) {
        throw 'public-new-project-wrapper-failed'
    }
    $nextJson = & (Join-Path $repoRoot 'scripts/show-next-step.ps1') -ProjectRoot $wrapper.project_root
    $next = $nextJson | ConvertFrom-Json -Depth 10
    if (-not $next.read_only -or $next.code -ne 'p01-case-design') {
        throw 'public-show-next-wrapper-failed'
    }

    $validationText = & (Join-Path $repoRoot 'tools/validate-release.ps1') -RepositoryRoot $repoRoot
    $validation = $validationText | ConvertFrom-Json -Depth 10
    if (-not $validation.pass) { throw 'release-validation-failed' }

    [pscustomobject]@{
        test = 'MEDIUM-LONG-MYSTERY-RELEASE-SMOKE@v001'
        initializer = 'pass'
        idempotency = 'pass'
        project_exact_set = 'pass'
        orchestrator_route = $decision.code
        action_policy = $tier1.decision
        public_new_project = 'pass'
        public_show_next = $next.code
        release_validator = 'pass'
        novel_payload_io = '0/0'
        pass = $true
    } | ConvertTo-Json -Depth 10
}
finally {
    $safe = [IO.Path]::GetFullPath($tempRoot)
    if ($safe.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $safe).StartsWith('medium-long-mystery-smoke-', [StringComparison]::Ordinal)) {
        Remove-Item -LiteralPath $safe -Recurse -Force -ErrorAction SilentlyContinue
    }
}
