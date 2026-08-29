param([string]$InputJson)

$ErrorActionPreference = 'Stop'

function Get-P03R1Bool {
    param([object]$Action, [string]$Name)
    $property = $Action.PSObject.Properties[$Name]
    if ($null -eq $property) { return $false }
    return [bool]$property.Value
}

function New-P03R1Decision {
    param([string]$ActionId, [string]$Decision, [string[]]$Reasons)
    $userStop = $Decision -in @('tier2-confirmation','tier3-explicit-authorization')
    $prompt = switch ($Decision) {
        'tier1-autonomous' { 'none' }
        'tier2-confirmation' { 'confirmation' }
        'tier3-explicit-authorization' { 'authorization' }
        default { 'blocked-status' }
    }
    return [pscustomobject][ordered]@{
        action_id = $ActionId
        decision = $Decision
        reason_codes = @($Reasons | Sort-Object -Unique)
        user_stop = $userStop
        prompt_kind = $prompt
        audit_detail_required = ($Decision -ne 'tier1-autonomous')
    }
}

function Get-P03R1ActionDecision {
    param([Parameter(Mandatory=$true)][object]$Action)

    $allowed = @(
        'action_id','in_scope','reversible','target_exact',
        'safety_blocking','evidence_blocking','source_drift',
        'external_effect','protected_source_write','destructive',
        'new_private_data_scope','independent_agent_l6','synthetic_clean_session','project_payload_read',
        'critical_truth_change','act_structure_or_ending_change','significant_cost_or_risk',
        'candidate_content_confirmation','creative_direction_choice','chapter_content_confirmation','full_book_final_confirmation'
    )
    $required = @('action_id','in_scope','reversible','target_exact')
    $names = @($Action.PSObject.Properties.Name)
    $missing = @($required | Where-Object { $_ -notin $names })
    $unknown = @($names | Where-Object { $_ -notin $allowed })
    $actionId = if ('action_id' -in $names) { [string]$Action.action_id } else { '<missing>' }

    if ($missing.Count -gt 0 -or $unknown.Count -gt 0 -or [string]::IsNullOrWhiteSpace($actionId)) {
        return New-P03R1Decision $actionId 'fail-closed/internal-blocked' @('B-INVALID-INPUT')
    }
    if (-not (Get-P03R1Bool $Action 'target_exact')) {
        return New-P03R1Decision $actionId 'fail-closed/internal-blocked' @('B-UNTARGETED')
    }
    if ((Get-P03R1Bool $Action 'synthetic_clean_session') -and (Get-P03R1Bool $Action 'project_payload_read')) {
        return New-P03R1Decision $actionId 'fail-closed/internal-blocked' @('B-INVALID-INPUT')
    }

    $blocked = [System.Collections.Generic.List[string]]::new()
    if (Get-P03R1Bool $Action 'safety_blocking') { $blocked.Add('B-SAFETY') }
    if (Get-P03R1Bool $Action 'evidence_blocking') { $blocked.Add('B-EVIDENCE') }
    if (Get-P03R1Bool $Action 'source_drift') { $blocked.Add('B-SOURCE-DRIFT') }
    if ($blocked.Count -gt 0) {
        return New-P03R1Decision $actionId 'fail-closed/internal-blocked' $blocked.ToArray()
    }

    $tier3 = [System.Collections.Generic.List[string]]::new()
    if (-not (Get-P03R1Bool $Action 'in_scope')) { $tier3.Add('T3-SCOPE-EXPANSION') }
    if (-not (Get-P03R1Bool $Action 'reversible')) { $tier3.Add('T3-IRREVERSIBLE-OR-DESTRUCTIVE') }
    if (Get-P03R1Bool $Action 'external_effect') { $tier3.Add('T3-EXTERNAL-EFFECT') }
    if ((Get-P03R1Bool $Action 'protected_source_write') -or (Get-P03R1Bool $Action 'destructive')) { $tier3.Add('T3-IRREVERSIBLE-OR-DESTRUCTIVE') }
    if ((Get-P03R1Bool $Action 'new_private_data_scope') -or (Get-P03R1Bool $Action 'significant_cost_or_risk')) { $tier3.Add('T3-SCOPE-PRIVACY-L6-RISK') }
    if ((Get-P03R1Bool $Action 'independent_agent_l6') -and -not (Get-P03R1Bool $Action 'synthetic_clean_session')) { $tier3.Add('T3-SCOPE-PRIVACY-L6-RISK') }
    if ((Get-P03R1Bool $Action 'critical_truth_change') -or (Get-P03R1Bool $Action 'act_structure_or_ending_change')) { $tier3.Add('T3-CRITICAL-CONTENT-CHANGE') }
    if ($tier3.Count -gt 0) {
        return New-P03R1Decision $actionId 'tier3-explicit-authorization' $tier3.ToArray()
    }

    $tier2 = [System.Collections.Generic.List[string]]::new()
    if ((Get-P03R1Bool $Action 'candidate_content_confirmation') -or (Get-P03R1Bool $Action 'chapter_content_confirmation') -or (Get-P03R1Bool $Action 'full_book_final_confirmation')) { $tier2.Add('T2-CONTENT-CONFIRMATION') }
    if (Get-P03R1Bool $Action 'creative_direction_choice') { $tier2.Add('T2-CREATIVE-DIRECTION') }
    if ($tier2.Count -gt 0) {
        return New-P03R1Decision $actionId 'tier2-confirmation' $tier2.ToArray()
    }

    if ((Get-P03R1Bool $Action 'in_scope') -and (Get-P03R1Bool $Action 'reversible')) {
        $reason = if ((Get-P03R1Bool $Action 'independent_agent_l6') -and (Get-P03R1Bool $Action 'synthetic_clean_session')) { 'T1-SYNTHETIC-CLEAN-SESSION' } else { 'T1-IN-SCOPE-REVERSIBLE' }
        return New-P03R1Decision $actionId 'tier1-autonomous' @($reason)
    }

    return New-P03R1Decision $actionId 'fail-closed/internal-blocked' @('B-UNCLASSIFIED')
}

if (-not [string]::IsNullOrWhiteSpace($InputJson)) {
    $action = $InputJson | ConvertFrom-Json
    Get-P03R1ActionDecision -Action $action | ConvertTo-Json -Depth 4 -Compress
}
