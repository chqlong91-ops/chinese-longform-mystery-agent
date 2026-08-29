$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'p03_r1_registry.ps1')

function Get-P03R1FileSha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
}

function Read-P03R1JsonFile {
    param([Parameter(Mandatory)][string]$Path)
    $strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $raw = [System.IO.File]::ReadAllText($Path, $strictUtf8)
    return $raw | ConvertFrom-Json -Depth 100
}

function Write-P03R1JsonFile {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)]$Value)
    $parent = Split-Path -Parent $Path
    if ($parent) { [void](New-Item -ItemType Directory -Path $parent -Force) }
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, ($Value | ConvertTo-Json -Depth 100), $utf8)
}

function Resolve-P03R1TransactionPath {
    param([Parameter(Mandatory)][string]$WorkspaceRoot, [Parameter(Mandatory)][string]$RelativePath)
    if ([System.IO.Path]::IsPathRooted($RelativePath)) { throw 'absolute-path-not-allowed' }
    $root = [System.IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $root $RelativePath))
    $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'path-outside-workspace' }
    return $resolved
}

function Get-P03R1TransactionPaths {
    param([Parameter(Mandatory)]$Request, [Parameter(Mandatory)][string]$WorkspaceRoot)
    $safeId = $Request.transaction_id -replace '[^A-Za-z0-9._-]', '_'
    $txRoot = Resolve-P03R1TransactionPath -WorkspaceRoot $WorkspaceRoot -RelativePath 'state/p03-r1/transactions'
    [pscustomobject]@{
        transaction_root = $txRoot
        stage = Join-Path $txRoot "staging/$safeId"
        committed = Join-Path $txRoot "committed/$safeId"
        lease = Join-Path $txRoot 'writer-lease.json'
        current_registry = Resolve-P03R1TransactionPath -WorkspaceRoot $WorkspaceRoot -RelativePath $Request.expected_registry.path
        proposed_registry = Resolve-P03R1TransactionPath -WorkspaceRoot $WorkspaceRoot -RelativePath $Request.proposed_registry.path
    }
}

function New-P03R1TransactionResult {
    param(
        [bool]$Valid,
        [string]$TransactionId,
        [string]$Status,
        [bool]$Committed,
        [string]$StopCode,
        [string]$ExpectedHash,
        [string]$ActualHash,
        [string]$LeaseDisposition,
        [int]$WritesVisible,
        [string]$UniqueNext,
        [string[]]$Errors = @()
    )
    [pscustomobject]@{
        valid = $Valid
        transaction_id = $TransactionId
        status = $Status
        committed = $Committed
        stop_code = $StopCode
        expected_registry_hash = $ExpectedHash
        actual_registry_hash = $ActualHash
        lease_disposition = $LeaseDisposition
        writes_visible = $WritesVisible
        unique_next = $UniqueNext
        errors = @($Errors)
    }
}

function Test-P03R1StateTransaction {
    param(
        [Parameter(Mandatory)][string]$RequestPath,
        [Parameter(Mandatory)][string]$WorkspaceRoot
    )
    $errors = [System.Collections.Generic.List[string]]::new()
    try {
        $root = [System.IO.Path]::GetFullPath($WorkspaceRoot)
        $requestResolved = [System.IO.Path]::GetFullPath($RequestPath)
        if (-not $requestResolved.StartsWith($root.TrimEnd('\','/') + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) { $errors.Add('request-outside-workspace') }
        $raw = [System.IO.File]::ReadAllText($requestResolved, [System.Text.UTF8Encoding]::new($false, $true))
        $schemaPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'schemas/p03-r1-state-transaction.schema.json'
        if (Get-Command Test-Json -ErrorAction SilentlyContinue) {
            try { if (-not ($raw | Test-Json -SchemaFile $schemaPath -ErrorAction Stop)) { $errors.Add('request-schema-invalid') } }
            catch { $errors.Add('request-schema-invalid') }
        }
        $request = $raw | ConvertFrom-Json -Depth 100
    }
    catch {
        $errors.Add('request-invalid-or-missing')
        return [pscustomobject]@{ valid=$false; errors=@($errors); request=$null; request_hash=$null }
    }

    $paths = $null
    try { $paths = Get-P03R1TransactionPaths -Request $request -WorkspaceRoot $WorkspaceRoot }
    catch { $errors.Add($_.Exception.Message) }
    if ($null -eq $paths) { return [pscustomobject]@{ valid=$false; errors=@($errors); request=$request; request_hash=(Get-P03R1FileSha256 $RequestPath) } }

    foreach ($path in @($paths.current_registry, $paths.proposed_registry)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $errors.Add("missing-file:$path") }
    }
    if ($errors.Count -eq 0) {
        $actualSourceHash = Get-P03R1FileSha256 $paths.current_registry
        $actualProposedHash = Get-P03R1FileSha256 $paths.proposed_registry
        if ($actualSourceHash -ne $request.expected_registry.sha256) { $errors.Add('expected-registry-hash-drift') }
        if ($actualProposedHash -ne $request.proposed_registry.sha256) { $errors.Add('proposed-registry-hash-drift') }
        if ($actualSourceHash -eq $actualProposedHash) { $errors.Add('no-op-registry-proposal') }

        $sourceValidation = Test-P03R1Registry -RegistryPath $paths.current_registry
        $proposedValidation = Test-P03R1Registry -RegistryPath $paths.proposed_registry
        if (-not $sourceValidation.valid) { $errors.Add('source-registry-invalid') }
        if (-not $proposedValidation.valid) { $errors.Add('proposed-registry-invalid') }
        if ($sourceValidation.valid -and $proposedValidation.valid) {
            $source = Read-P03R1Registry -Path $paths.current_registry
            $proposed = Read-P03R1Registry -Path $paths.proposed_registry
            $sourceRefs = @($source.current_pointers | ForEach-Object object_ref | Sort-Object)
            $expectedRefs = @($request.expected_registry.current_refs | Sort-Object)
            if (($sourceRefs -join '|') -ne ($expectedRefs -join '|')) { $errors.Add('expected-current-drift') }
            if ($proposed.unique_next.action -ne $request.unique_next_expected) { $errors.Add('unique-next-mismatch') }
            $coverageMatched = $false
            foreach ($included in @($source.coverage.included)) {
                if ($request.coverage -eq $included -or ($source.coverage.prefix_policy -eq 'declared-prefix' -and $request.coverage.StartsWith($included + '/'))) { $coverageMatched = $true }
            }
            if (-not $coverageMatched) { $errors.Add('coverage-not-included') }
        }
    }

    $targets = @($request.write_set | ForEach-Object target)
    if (($targets | Select-Object -Unique).Count -ne $targets.Count) { $errors.Add('duplicate-write-target') }
    $commitPoints = @($request.write_set | Where-Object commit_point)
    if ($commitPoints.Count -ne 1) { $errors.Add('commit-point-count') }
    foreach ($item in @($request.write_set)) {
        try {
            $sourcePath = Resolve-P03R1TransactionPath -WorkspaceRoot $WorkspaceRoot -RelativePath $item.source
            [void](Resolve-P03R1TransactionPath -WorkspaceRoot $WorkspaceRoot -RelativePath $item.target)
            if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { $errors.Add("missing-write-source:$($item.source)"); continue }
            if ((Get-P03R1FileSha256 $sourcePath) -ne $item.sha256) { $errors.Add("write-source-hash-drift:$($item.target)") }
            if ((Get-Item -LiteralPath $sourcePath).Length -ne $item.bytes) { $errors.Add("write-source-size-drift:$($item.target)") }
        }
        catch { $errors.Add("invalid-write-path:$($item.target)") }
    }
    if ($commitPoints.Count -eq 1) {
        $cp = $commitPoints[0]
        if ($cp.kind -ne 'registry' -or $cp.mode -ne 'replace' -or $cp.target -ne $request.expected_registry.path -or $cp.source -ne $request.proposed_registry.path) { $errors.Add('invalid-commit-point') }
    }
    if ($request.test_injection) {
        $leaf = Split-Path -Leaf ([System.IO.Path]::GetFullPath($WorkspaceRoot))
        if (-not $leaf.StartsWith('p03-r1-s04-')) { $errors.Add('test-injection-outside-synthetic-root') }
    }

    [pscustomobject]@{
        valid = ($errors.Count -eq 0)
        errors = @($errors | Sort-Object -Unique)
        request = $request
        request_hash = Get-P03R1FileSha256 $RequestPath
        paths = $paths
    }
}

function Acquire-P03R1WriterLease {
    param([Parameter(Mandatory)]$Request, [Parameter(Mandatory)]$Paths, [Parameter(Mandatory)][string]$RequestHash)
    [void](New-Item -ItemType Directory -Path $Paths.transaction_root -Force)
    $lease = [ordered]@{
        transaction_id = $Request.transaction_id
        request_hash = $RequestHash
        owner = $Request.writer_owner
        coverage = $Request.coverage
        fencing_token = $Request.epoch
        expected_registry_hash = $Request.expected_registry.sha256
        acquired_utc = [DateTime]::UtcNow.ToString('o')
        expires_utc = [DateTime]::UtcNow.AddMinutes(10).ToString('o')
    }
    try {
        $stream = [System.IO.File]::Open($Paths.lease, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        try {
            $bytes = [System.Text.UTF8Encoding]::new($false).GetBytes(($lease | ConvertTo-Json -Depth 10))
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush($true)
        }
        finally { $stream.Dispose() }
        return $lease
    }
    catch [System.IO.IOException] {
        throw 'writer-conflict'
    }
}

function Release-P03R1WriterLease {
    param([Parameter(Mandatory)]$Request, [Parameter(Mandatory)]$Paths)
    if (-not (Test-Path -LiteralPath $Paths.lease)) { return }
    $lease = Read-P03R1JsonFile $Paths.lease
    if ($lease.transaction_id -ne $Request.transaction_id -or $lease.owner -ne $Request.writer_owner) { throw 'lease-owner-mismatch' }
    Remove-Item -LiteralPath $Paths.lease -Force
}

function Publish-P03R1TransactionBundle {
    param([Parameter(Mandatory)]$Request, [Parameter(Mandatory)]$Paths, [Parameter(Mandatory)][string]$RequestHash)
    if (-not (Test-Path -LiteralPath $Paths.committed -PathType Container)) {
        if (Test-Path -LiteralPath $Paths.stage) { Remove-Item -LiteralPath $Paths.stage -Recurse -Force }
        [void](New-Item -ItemType Directory -Path (Join-Path $Paths.stage 'payload') -Force)
        $index = 0
        foreach ($item in @($Request.write_set)) {
            $sourcePath = Resolve-P03R1TransactionPath -WorkspaceRoot (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Paths.transaction_root))) -RelativePath $item.source
            $payloadName = ('{0:D3}-{1}' -f $index, (Split-Path -Leaf $item.target))
            Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $Paths.stage "payload/$payloadName")
            $index++
        }
        $journal = [ordered]@{ transaction_id=$Request.transaction_id; request_hash=$RequestHash; status='staged'; fencing_token=$Request.epoch; write_count=@($Request.write_set).Count }
        Write-P03R1JsonFile -Path (Join-Path $Paths.stage 'journal.json') -Value $journal
    }
}

function Invoke-P03R1StateTransaction {
    param(
        [Parameter(Mandatory)][string]$RequestPath,
        [Parameter(Mandatory)][string]$WorkspaceRoot,
        [Parameter(Mandatory)][ValidateSet('Plan','Commit','Recover')][string]$Mode
    )
    $preflight = Test-P03R1StateTransaction -RequestPath $RequestPath -WorkspaceRoot $WorkspaceRoot
    $appliedWrites = [System.Collections.Generic.List[object]]::new()
    $request = $preflight.request
    if ($Mode -eq 'Recover' -and -not $preflight.valid -and $null -ne $request -and $null -ne $preflight.paths) {
        $recoverable = @($preflight.errors | Where-Object { $_ -notin @('expected-registry-hash-drift','no-op-registry-proposal') })
        if ($recoverable.Count -eq 0 -and (Get-P03R1FileSha256 $preflight.paths.current_registry) -eq $request.proposed_registry.sha256) {
            $preflight.valid = $true
        }
    }
    if ($null -ne $request -and $null -ne $preflight.paths) {
        $earlyManifestPath = Join-Path $preflight.paths.committed 'commit-manifest.json'
        if (Test-Path -LiteralPath $earlyManifestPath) {
            $earlyManifest = Read-P03R1JsonFile $earlyManifestPath
            if ($earlyManifest.request_hash -ne $preflight.request_hash) {
                return New-P03R1TransactionResult -Valid $false -TransactionId $request.transaction_id -Status 'blocked' -Committed $false -StopCode 'idempotency-conflict' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $preflight.paths.current_registry) -LeaseDisposition 'none' -WritesVisible 0 -UniqueNext 'use a new transaction identity'
            }
            if ($earlyManifest.status -eq 'committed' -and (Get-P03R1FileSha256 $preflight.paths.current_registry) -eq $request.proposed_registry.sha256) {
                return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'committed' -Committed $true -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash $request.proposed_registry.sha256 -LeaseDisposition 'released' -WritesVisible @($request.write_set).Count -UniqueNext $request.unique_next_expected
            }
        }
    }
    if (-not $preflight.valid) {
        return New-P03R1TransactionResult -Valid $false -TransactionId $request.transaction_id -Status 'blocked' -Committed $false -StopCode 'preflight-failed' -ExpectedHash $request.expected_registry.sha256 -ActualHash $null -LeaseDisposition 'none' -WritesVisible 0 -UniqueNext 'repair transaction request' -Errors $preflight.errors
    }
    if ($Mode -eq 'Plan') {
        return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'validated' -Committed $false -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $preflight.paths.current_registry) -LeaseDisposition 'not-acquired' -WritesVisible 0 -UniqueNext 'commit validated transaction'
    }

    $paths = $preflight.paths
    $manifestPath = Join-Path $paths.committed 'commit-manifest.json'
    if (Test-Path -LiteralPath $manifestPath) {
        $existing = Read-P03R1JsonFile $manifestPath
        if ($existing.request_hash -ne $preflight.request_hash) {
            return New-P03R1TransactionResult -Valid $false -TransactionId $request.transaction_id -Status 'blocked' -Committed $false -StopCode 'idempotency-conflict' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'none' -WritesVisible 0 -UniqueNext 'use a new transaction identity'
        }
        if ($existing.status -eq 'committed' -and (Get-P03R1FileSha256 $paths.current_registry) -eq $request.proposed_registry.sha256) {
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'committed' -Committed $true -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash $request.proposed_registry.sha256 -LeaseDisposition 'released' -WritesVisible @($request.write_set).Count -UniqueNext $request.unique_next_expected
        }
    }

    if ($Mode -eq 'Recover') {
        $actualHash = Get-P03R1FileSha256 $paths.current_registry
        if ($actualHash -eq $request.proposed_registry.sha256) {
            $manifest = [ordered]@{ transaction_id=$request.transaction_id; request_hash=$preflight.request_hash; status='committed'; proposed_registry_hash=$request.proposed_registry.sha256; fencing_token=$request.epoch; recovered=$true }
            Write-P03R1JsonFile -Path $manifestPath -Value $manifest
            if (Test-Path -LiteralPath $paths.lease) { Release-P03R1WriterLease -Request $request -Paths $paths }
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'committed' -Committed $true -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash $actualHash -LeaseDisposition 'released' -WritesVisible @($request.write_set).Count -UniqueNext $request.unique_next_expected
        }
        if ($actualHash -ne $request.expected_registry.sha256) {
            return New-P03R1TransactionResult -Valid $false -TransactionId $request.transaction_id -Status 'blocked' -Committed $false -StopCode 'recovery-ambiguous' -ExpectedHash $request.expected_registry.sha256 -ActualHash $actualHash -LeaseDisposition 'retained' -WritesVisible 0 -UniqueNext 'inspect transaction journal'
        }
        if ((Test-Path -LiteralPath $paths.stage) -and -not (Test-Path -LiteralPath $paths.committed)) {
            Remove-Item -LiteralPath $paths.stage -Recurse -Force
            if (Test-Path -LiteralPath $paths.lease) { Release-P03R1WriterLease -Request $request -Paths $paths }
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'aborted' -Committed $false -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash $actualHash -LeaseDisposition 'released' -WritesVisible 0 -UniqueNext 'retry transaction'
        }
        if (-not (Test-Path -LiteralPath $paths.committed)) {
            if (Test-Path -LiteralPath $paths.lease) { Release-P03R1WriterLease -Request $request -Paths $paths }
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'aborted' -Committed $false -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash $actualHash -LeaseDisposition 'released' -WritesVisible 0 -UniqueNext 'retry transaction'
        }
        if (Test-Path -LiteralPath $paths.lease) { Release-P03R1WriterLease -Request $request -Paths $paths }
        $request.test_injection = $null
    }

    try {
        [void](Acquire-P03R1WriterLease -Request $request -Paths $paths -RequestHash $preflight.request_hash)
    }
    catch {
        return New-P03R1TransactionResult -Valid $false -TransactionId $request.transaction_id -Status 'blocked' -Committed $false -StopCode $_.Exception.Message -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'conflict' -WritesVisible 0 -UniqueNext 'recover or release current writer'
    }
    if ($request.test_injection -eq 'after-lease') {
        return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'recovery-required' -Committed $false -StopCode 'injected-after-lease' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'retained' -WritesVisible 0 -UniqueNext 'recover transaction'
    }

    try {
        Publish-P03R1TransactionBundle -Request $request -Paths $paths -RequestHash $preflight.request_hash
        if ($request.test_injection -eq 'after-stage') {
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'recovery-required' -Committed $false -StopCode 'injected-after-stage' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'retained' -WritesVisible 0 -UniqueNext 'recover transaction'
        }
        if (-not (Test-Path -LiteralPath $paths.committed)) {
            [void](New-Item -ItemType Directory -Path (Split-Path -Parent $paths.committed) -Force)
            Move-Item -LiteralPath $paths.stage -Destination $paths.committed
        }
        $manifest = [ordered]@{ transaction_id=$request.transaction_id; request_hash=$preflight.request_hash; status='prepared'; proposed_registry_hash=$request.proposed_registry.sha256; fencing_token=$request.epoch; write_count=@($request.write_set).Count }
        Write-P03R1JsonFile -Path $manifestPath -Value $manifest
        if ($request.test_injection -eq 'after-bundle') {
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'recovery-required' -Committed $false -StopCode 'injected-after-bundle' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'retained' -WritesVisible 0 -UniqueNext 'recover transaction'
        }

        $index = 0
        foreach ($item in @($request.write_set)) {
            if ($item.commit_point) { $index++; continue }
            $payloadName = ('{0:D3}-{1}' -f $index, (Split-Path -Leaf $item.target))
            $payloadPath = Join-Path $paths.committed "payload/$payloadName"
            $targetPath = Resolve-P03R1TransactionPath -WorkspaceRoot $WorkspaceRoot -RelativePath $item.target
            [void](New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force)
            if (Test-Path -LiteralPath $targetPath) {
                if ($item.mode -eq 'create') {
                    if ((Get-P03R1FileSha256 $targetPath) -ne $item.sha256) { throw 'immutable-target-conflict' }
                }
                elseif ($item.mode -eq 'replace') {
                    $backupDirectory = Join-Path $paths.committed 'backups'
                    [void](New-Item -ItemType Directory -Path $backupDirectory -Force)
                    $backupPath = Join-Path $backupDirectory ('{0:D3}-{1}' -f $index, (Split-Path -Leaf $item.target))
                    Copy-Item -LiteralPath $targetPath -Destination $backupPath -Force
                    $tempPath = $targetPath + '.' + ($request.transaction_id -replace '[^A-Za-z0-9._-]','_') + '.replace.tmp'
                    Copy-Item -LiteralPath $payloadPath -Destination $tempPath -Force
                    [System.IO.File]::Move($tempPath, $targetPath, $true)
                    $appliedWrites.Add([pscustomobject]@{target=$targetPath;existed=$true;backup=$backupPath})
                }
            }
            else {
                Copy-Item -LiteralPath $payloadPath -Destination $targetPath
                $appliedWrites.Add([pscustomobject]@{target=$targetPath;existed=$false;backup=$null})
            }
            $index++
        }
        if ($request.test_injection -eq 'before-registry') {
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'recovery-required' -Committed $false -StopCode 'injected-before-registry' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'retained' -WritesVisible (@($request.write_set | Where-Object { -not $_.commit_point }).Count) -UniqueNext 'recover transaction'
        }
        if ((Get-P03R1FileSha256 $paths.current_registry) -ne $request.expected_registry.sha256) { throw 'cas-drift-before-commit' }
        $registryItemIndex = [array]::IndexOf(@($request.write_set), @($request.write_set | Where-Object commit_point)[0])
        $registryItem = @($request.write_set | Where-Object commit_point)[0]
        $registryPayload = Join-Path $paths.committed ("payload/{0:D3}-{1}" -f $registryItemIndex, (Split-Path -Leaf $registryItem.target))
        $tempRegistry = $paths.current_registry + '.' + ($request.transaction_id -replace '[^A-Za-z0-9._-]','_') + '.tmp'
        Copy-Item -LiteralPath $registryPayload -Destination $tempRegistry
        [System.IO.File]::Move($tempRegistry, $paths.current_registry, $true)
        if ($request.test_injection -eq 'after-registry') {
            return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'recovery-required' -Committed $true -StopCode 'injected-after-registry' -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'retained' -WritesVisible @($request.write_set).Count -UniqueNext 'recover transaction'
        }
        $manifest.status = 'committed'
        $manifest | Add-Member -NotePropertyName committed_utc -NotePropertyValue ([DateTime]::UtcNow.ToString('o'))
        Write-P03R1JsonFile -Path $manifestPath -Value $manifest
        Release-P03R1WriterLease -Request $request -Paths $paths
        return New-P03R1TransactionResult -Valid $true -TransactionId $request.transaction_id -Status 'committed' -Committed $true -StopCode $null -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'released' -WritesVisible @($request.write_set).Count -UniqueNext $request.unique_next_expected
    }
    catch {
        $stop = $_.Exception.Message
        try {
            if ($null -ne $request -and $null -ne $paths -and (Test-Path -LiteralPath $paths.current_registry) -and (Get-P03R1FileSha256 $paths.current_registry) -eq $request.expected_registry.sha256) {
                $rollbackWrites = @($appliedWrites)
                [array]::Reverse($rollbackWrites)
                foreach ($applied in $rollbackWrites) {
                    if ($applied.existed -and (Test-Path -LiteralPath $applied.backup -PathType Leaf)) {
                        Copy-Item -LiteralPath $applied.backup -Destination $applied.target -Force
                    }
                    elseif (-not $applied.existed -and (Test-Path -LiteralPath $applied.target)) {
                        Remove-Item -LiteralPath $applied.target -Force
                    }
                }
            }
        }
        catch {}
        if (Test-Path -LiteralPath $paths.stage) { Remove-Item -LiteralPath $paths.stage -Recurse -Force -ErrorAction SilentlyContinue }
        try { Release-P03R1WriterLease -Request $request -Paths $paths } catch {}
        return New-P03R1TransactionResult -Valid $false -TransactionId $request.transaction_id -Status 'aborted' -Committed $false -StopCode $stop -ExpectedHash $request.expected_registry.sha256 -ActualHash (Get-P03R1FileSha256 $paths.current_registry) -LeaseDisposition 'released' -WritesVisible 0 -UniqueNext 'repair and retry transaction'
    }
}
