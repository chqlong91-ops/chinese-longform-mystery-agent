[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $repoRoot 'tools/p04_orchestrator.ps1')

$registryPath = Join-Path ([IO.Path]::GetFullPath($ProjectRoot)) '04-state/project-registry.json'
$catalogPath = Join-Path $repoRoot 'config/p04-stage-capability-catalog-v001.json'
if (-not (Test-Path -LiteralPath $registryPath -PathType Leaf)) { throw 'project-registry-missing' }
if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) { throw 'capability-catalog-missing' }

$registry = Get-Content -Raw -Encoding UTF8 -LiteralPath $registryPath | ConvertFrom-Json -Depth 50
if ($registry.schema_version -eq 'P04-PROJECT-REGISTRY-SCHEMA@v001') {
    $registry = ConvertTo-P04OrchestratedRegistry -RegistryPath $registryPath
}
$catalog = Get-Content -Raw -Encoding UTF8 -LiteralPath $catalogPath | ConvertFrom-Json -Depth 30
$decision = Get-P04OrchestrationDecision -Registry $registry -Catalog $catalog

[pscustomobject]@{
    project_id = $registry.project.project_id
    registry_version = $registry.registry_version
    read_only = $true
    kind = $decision.kind
    code = $decision.code
    owner = $decision.owner
    skill = $decision.skill
    capability_id = $decision.capability_id
    next = $decision.next
    required_context = @($decision.required_context)
    not_read = @($decision.not_read)
} | ConvertTo-Json -Depth 10

