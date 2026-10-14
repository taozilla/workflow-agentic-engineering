[CmdletBinding()]
param(
    [switch]$FullVerify
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Find-RepositoryRoot {
    try {
        $root = (& git rev-parse --show-toplevel 2>$null)

        if ($LASTEXITCODE -eq 0 -and $root) {
            return $root.Trim()
        }
    }
    catch {
        # Fall back to the current directory.
    }

    return (Get-Location).Path
}

function Test-CommandExists {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-PackageManager {
    if (Test-Path "pnpm-lock.yaml") {
        return "pnpm"
    }

    if (Test-Path "yarn.lock") {
        return "yarn"
    }

    if (
        (Test-Path "bun.lock") -or
        (Test-Path "bun.lockb")
    ) {
        return "bun"
    }

    return "npm"
}

function Test-PackageScript {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $packageJson = Get-Content `
        -Path "package.json" `
        -Raw |
        ConvertFrom-Json

    if ($null -eq $packageJson.scripts) {
        return $false
    }

    return $null -ne $packageJson.scripts.PSObject.Properties[$Name]
}

function Invoke-PackageScript {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Host ""
    Write-Host "==> Running: $Name" -ForegroundColor Cyan

    switch ($script:PackageManager) {
        "pnpm" {
            & pnpm.cmd run $Name
        }

        "yarn" {
            & yarn.cmd $Name
        }

        "bun" {
            & bun.exe run $Name
        }

        "npm" {
            & npm.cmd run $Name
        }

        default {
            throw "Unsupported package manager: $script:PackageManager"
        }
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Script '$Name' failed with exit code $LASTEXITCODE."
    }
}

function Invoke-FirstAvailableScript {
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if (Test-PackageScript -Name $candidate) {
            Invoke-PackageScript -Name $candidate
            return
        }
    }

    Write-Host "SKIP: $GroupName - no matching script found." `
        -ForegroundColor Yellow
}

function Invoke-VerificationGroup {
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [string[]]$Candidates
    )

    try {
        Invoke-FirstAvailableScript `
            -GroupName $GroupName `
            -Candidates $Candidates

        return $true
    }
    catch {
        Write-Host ""
        Write-Host "FAILED: $GroupName" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red

        return $false
    }
}

$repositoryRoot = Find-RepositoryRoot
Set-Location $repositoryRoot

if (-not (Test-Path "package.json")) {
    Write-Host "No package.json found in: $repositoryRoot" `
        -ForegroundColor Red
    Write-Host "Use the repository's native verification commands."
    exit 2
}

if (-not (Test-CommandExists -Name "node")) {
    Write-Host "Node.js is not available in PATH." `
        -ForegroundColor Red
    exit 2
}

$script:PackageManager = Get-PackageManager

if (-not (Test-CommandExists -Name $script:PackageManager)) {
    Write-Host "$($script:PackageManager) is not available in PATH." `
        -ForegroundColor Red
    exit 2
}

$failedGroups = [System.Collections.Generic.List[string]]::new()

Write-Host "Repository: $repositoryRoot"
Write-Host "Package manager: $script:PackageManager"
Write-Host "Full verification: $FullVerify"

$verificationGroups = @(
    @{
        Name       = "format check"
        Candidates = @(
            "format:check",
            "check:format",
            "prettier:check"
        )
    },
    @{
        Name       = "lint"
        Candidates = @(
            "lint",
            "check:lint"
        )
    },
    @{
        Name       = "type check"
        Candidates = @(
            "typecheck",
            "type-check",
            "check:types",
            "types"
        )
    },
    @{
        Name       = "tests"
        Candidates = @(
            "test:ci",
            "test",
            "check:test"
        )
    }
)

foreach ($group in $verificationGroups) {
    $passed = Invoke-VerificationGroup `
        -GroupName $group.Name `
        -Candidates $group.Candidates

    if (-not $passed) {
        $failedGroups.Add($group.Name)
    }
}

if ($FullVerify) {
    $fullVerificationGroups = @(
        @{
            Name       = "build"
            Candidates = @(
                "build",
                "check:build"
            )
        },
        @{
            Name       = "end-to-end tests"
            Candidates = @(
                "test:e2e",
                "e2e",
                "playwright:test"
            )
        }
    )

    foreach ($group in $fullVerificationGroups) {
        $passed = Invoke-VerificationGroup `
            -GroupName $group.Name `
            -Candidates $group.Candidates

        if (-not $passed) {
            $failedGroups.Add($group.Name)
        }
    }
}
else {
    Write-Host ""
    Write-Host `
        "SKIP: build and end-to-end checks require -FullVerify." `
        -ForegroundColor Yellow
}

Write-Host ""

if ($failedGroups.Count -gt 0) {
    Write-Host `
        "Verification failed in $($failedGroups.Count) group(s):" `
        -ForegroundColor Red

    foreach ($groupName in $failedGroups) {
        Write-Host "- $groupName" -ForegroundColor Red
    }

    exit 1
}

Write-Host "All discovered verification checks passed." `
    -ForegroundColor Green

exit 0