[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$OutputRoot,
    [Parameter(Mandatory)][string]$ProjectId,
    [Parameter(Mandatory)][string]$DisplayName,
    [Parameter(Mandatory)][string]$Slug,
    [Parameter(Mandatory)][string]$Seed,
    [ValidateSet('medium','long')][string]$TargetLength = 'long',
    [string]$MysteryMode = '社会派悬疑',
    [string]$Notes = '由公开发行包初始化'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $repoRoot 'tools/p04_project_initializer.ps1')

$resolvedOutput = [IO.Path]::GetFullPath($OutputRoot)
if (-not (Test-Path -LiteralPath $resolvedOutput)) {
    [void](New-Item -ItemType Directory -Path $resolvedOutput -Force)
}
if (-not (Test-Path -LiteralPath $resolvedOutput -PathType Container)) {
    throw 'output-root-is-not-a-directory'
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\','/')
$tempRoot = Join-Path $tempBase ("medium-long-mystery-release-" + [Guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $tempRoot)
$requestPath = Join-Path $tempRoot 'initializer-request.json'
$request = [ordered]@{
    request_id = "P04-INIT-$($ProjectId.Replace('NOVEL-',''))@v001"
    idempotency_key = "release-$($ProjectId.ToLowerInvariant())-v001"
    project_id = $ProjectId
    display_name = $DisplayName
    slug = $Slug
    output_root = $resolvedOutput
    template_version = 'P04-PROJECT-TEMPLATE@v001'
    brief = [ordered]@{
        seed = $Seed
        target_length = $TargetLength
        mystery_mode = $MysteryMode
        notes = $Notes
    }
}

try {
    [IO.File]::WriteAllText(
        $requestPath,
        (($request | ConvertTo-Json -Depth 10) + "`n"),
        [Text.UTF8Encoding]::new($false)
    )
    $result = Invoke-P04ProjectInitializer -RequestPath $requestPath
    $check = Test-P04InitializedProject -ProjectRoot $result.project_root
    if (-not $check.valid) { throw "initialized-project-invalid:$($check.errors -join ',')" }
    [pscustomobject]@{
        status = $result.status
        project_root = $result.project_root
        registry_sha256 = $result.registry_sha256
        next = '在生成目录中打开 Codex，并从案件设计方向开始。'
    } | ConvertTo-Json -Depth 5
}
finally {
    $safe = [IO.Path]::GetFullPath($tempRoot)
    if ($safe.StartsWith($tempBase + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $safe).StartsWith('medium-long-mystery-release-', [StringComparison]::Ordinal)) {
        Remove-Item -LiteralPath $safe -Recurse -Force -ErrorAction SilentlyContinue
    }
}

