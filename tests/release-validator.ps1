[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
$fixture = Join-Path $tempBase ('mystery-release-validator-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $fixture)
$pwsh = (Get-Process -Id $PID).Path
$checks = [Collections.Generic.List[string]]::new()
function Assert-Validation([string]$Name, [string]$ExpectedError) {
    $output = & $pwsh -NoProfile -File (Join-Path $repoRoot 'tools/validate-release.ps1') -RepositoryRoot $fixture
    $code = $LASTEXITCODE
    $result = ($output -join "`n") | ConvertFrom-Json
    if ($ExpectedError) {
        if ($code -eq 0 -or $result.pass -or $ExpectedError -notin $result.errors) { throw "negative-check-failed:$Name" }
    } elseif ($code -ne 0 -or -not $result.pass) { throw "positive-check-failed:$Name" }
    $checks.Add($Name)
}
try {
    Get-ChildItem -LiteralPath $repoRoot -Force | Where-Object Name -ne '.git' | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $fixture -Recurse -Force
    }
    Assert-Validation 'clean-package' ''
    $control = Join-Path $fixture 'docs/CONTROL-WORKFLOW.md'
    Move-Item -LiteralPath $control -Destination ($control + '.hold')
    Assert-Validation 'missing-control-guide' 'missing-required-file:docs/CONTROL-WORKFLOW.md'
    Move-Item -LiteralPath ($control + '.hold') -Destination $control
    $runtime = Join-Path $fixture 'docs/CURRENT-RUNTIME.md'
    Move-Item -LiteralPath $runtime -Destination ($runtime + '.hold')
    Assert-Validation 'missing-runtime-entry' 'missing-required-file:docs/CURRENT-RUNTIME.md'
    Move-Item -LiteralPath ($runtime + '.hold') -Destination $runtime
    $citation = Join-Path $fixture 'CITATION.cff'
    $original = [IO.File]::ReadAllText($citation)
    [IO.File]::WriteAllText($citation, ($original -replace '(?m)^version:.*$', 'version: "0.0.0"'))
    Assert-Validation 'stale-version' 'version-mismatch:CITATION.cff'
    [IO.File]::WriteAllText($citation, $original)
    $entry = Join-Path $fixture 'AGENTS.md'
    $original = [IO.File]::ReadAllText($entry)
    [IO.File]::WriteAllText($entry, ($original + "`n[missing](docs/not-shipped.md)`n"))
    Assert-Validation 'broken-entry-link' 'broken-entry-link:AGENTS.md:docs/not-shipped.md'
    [IO.File]::WriteAllText($entry, $original)
    Assert-Validation 'restored-package' ''
    [pscustomobject]@{test='release-validator-regression';checks=@($checks);pass=$true} | ConvertTo-Json
} finally {
    $safe = [IO.Path]::GetFullPath($fixture)
    if ($safe.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $safe).StartsWith('mystery-release-validator-', [StringComparison]::Ordinal)) {
        Remove-Item -LiteralPath $safe -Recurse -Force
    }
}
