[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath($RepositoryRoot)
$errors = [Collections.Generic.List[string]]::new()

$requiredFiles = @(
    'README.md','AGENTS.md','DEPENDENCIES.md','LICENSE','LICENSE-STATUS.md','NOTICE.md','CHANGELOG.md',
    'CONTRIBUTING.md','SECURITY.md','SUPPORT.md','CODE_OF_CONDUCT.md','CITATION.cff','VERSION',
    '.gitignore','.gitattributes','.editorconfig',
    'config/p04-stage-capability-catalog-v001.json',
    'tools/p04_project_initializer.ps1','tools/p04_orchestrator.ps1','tools/p04_interaction_runtime.ps1',
    'tools/p03_r1_registry.ps1','tools/p03_r1_transaction.ps1','tools/p03_r1_view.ps1',
    'scripts/new-project.ps1','scripts/show-next-step.ps1','tests/smoke.ps1',
    'release-evidence/P04-FROZEN-BASELINE-v001.json','release-evidence/PUBLIC-RELEASE-MANIFEST-v001.json',
    'docs/60-P04阶段验收报告与产品交接.md'
)
foreach ($relative in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        $errors.Add("missing-required-file:$relative")
    }
}

$requiredDirectories = @('config','docs','examples','schemas','templates','tools','scripts','tests','release-evidence','.github')
foreach ($relative in $requiredDirectories) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Container)) {
        $errors.Add("missing-required-directory:$relative")
    }
}

$forbiddenDirectories = @('pilots','work','state','任务','evals')
foreach ($relative in $forbiddenDirectories) {
    if (Test-Path -LiteralPath (Join-Path $root $relative)) {
        $errors.Add("forbidden-release-directory:$relative")
    }
}

$gitRoot = Join-Path $root '.git'
$files = @(Get-ChildItem -LiteralPath $root -Recurse -File -Force | Where-Object {
    -not $_.FullName.StartsWith($gitRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
})
foreach ($file in $files) {
    if ($file.Length -eq 0) { $errors.Add("empty-file:$($file.FullName.Substring($root.Length + 1))") }
    if ($file.Length -gt 5MB) { $errors.Add("oversized-file:$($file.FullName.Substring($root.Length + 1))") }
}

foreach ($file in $files | Where-Object Extension -eq '.json') {
    try { $null = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName | ConvertFrom-Json -Depth 100 }
    catch { $errors.Add("invalid-json:$($file.FullName.Substring($root.Length + 1))") }
}

foreach ($file in $files | Where-Object Extension -eq '.ps1') {
    $tokens = $null
    $parseErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
    if (@($parseErrors).Count -gt 0) {
        $errors.Add("powershell-parse-error:$($file.FullName.Substring($root.Length + 1))")
    }
}

$textExtensions = @('.md','.json','.jsonl','.ps1','.txt','.tmpl','.cff','.yml','.yaml')
foreach ($file in $files | Where-Object { $_.Extension -in $textExtensions -or $_.Name -in @('VERSION','.gitignore','.gitattributes','.editorconfig') }) {
    try { $text = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false,$true)) }
    catch { $errors.Add("invalid-utf8:$($file.FullName.Substring($root.Length + 1))"); continue }
    if ($text -match 'C:\\Users\\[^\\]+\\' -or $text -match 'D:\\codex_project\\' -or $text -match 'D:\\codex\\_project\\') {
        $errors.Add("absolute-local-path:$($file.FullName.Substring($root.Length + 1))")
    }
    if ($text -cmatch '(?<![A-Za-z])sk-[A-Za-z0-9_-]{20,}' -or $text -match 'BEGIN [A-Z ]*PRIVATE KEY' -or $text -match '(?i)authorization\s*[:=]\s*bearer\s+[A-Za-z0-9._-]{12,}') {
        $errors.Add("secret-like-content:$($file.FullName.Substring($root.Length + 1))")
    }
}

$version = if (Test-Path -LiteralPath (Join-Path $root 'VERSION')) { (Get-Content -Raw -LiteralPath (Join-Path $root 'VERSION')).Trim() } else { $null }
$baseline = $null
if (Test-Path -LiteralPath (Join-Path $root 'release-evidence/P04-FROZEN-BASELINE-v001.json')) {
    try { $baseline = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'release-evidence/P04-FROZEN-BASELINE-v001.json') | ConvertFrom-Json -Depth 100 }
    catch { $errors.Add('baseline-invalid-json') }
}
if ($baseline -and ($baseline.ac_verdict -ne '12/12 yes/evaluated' -or $baseline.stage_verdict -ne 'yes/evaluated')) {
    $errors.Add('baseline-verdict-mismatch')
}

$result = [pscustomobject]@{
    validator = 'MEDIUM-LONG-MYSTERY-RELEASE-VALIDATOR@v001'
    version = $version
    files = $files.Count
    bytes = ($files | Measure-Object Length -Sum).Sum
    p04 = if ($baseline) { $baseline.stage_verdict } else { 'missing' }
    novel_payload_included = $false
    license = 'Apache-2.0'
    errors = @($errors | Sort-Object -Unique)
    pass = ($errors.Count -eq 0)
}
$result | ConvertTo-Json -Depth 10
if (-not $result.pass) { exit 1 }
