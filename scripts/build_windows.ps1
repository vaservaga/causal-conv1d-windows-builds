[CmdletBinding()]
param(
    [Parameter()]
    [string]$Python = "python",

    [Parameter()]
    [string]$SourceDir = (Join-Path $PSScriptRoot "..\upstream-source"),

    [Parameter()]
    [string]$OutputDir = (Join-Path $PSScriptRoot "..\artifacts")
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$patchFile = Join-Path $repoRoot "patches\windows-sm86.patch"
$upstreamUrl = "https://github.com/Dao-AILab/causal-conv1d.git"
$upstreamTag = "v1.6.2.post1"

function Invoke-Checked {
    param([Parameter(Mandatory = $true)][string]$FilePath,
          [Parameter(Mandatory = $true)][string[]]$Arguments)
    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed ($LASTEXITCODE): $FilePath $($Arguments -join ' ')"
    }
}

if (-not (Get-Command $Python -ErrorAction SilentlyContinue)) {
    throw "Python command not found: $Python"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required."
}
if (-not (Get-Command nvcc -ErrorAction SilentlyContinue)) {
    throw "CUDA Toolkit 12.8 nvcc must be available on PATH."
}

& $Python -c "import torch; assert torch.__version__ == '2.10.0+cu128', torch.__version__; assert torch.version.cuda == '12.8', torch.version.cuda"
if ($LASTEXITCODE -ne 0) { throw "Expected PyTorch 2.10.0+cu128 with CUDA 12.8." }

$nvccVersion = (& nvcc --version) -join "`n"
if ($nvccVersion -notmatch "release 12\.8") { throw "Expected CUDA Toolkit 12.8." }

if (-not (Test-Path -LiteralPath $SourceDir)) {
    Invoke-Checked git @("clone", "--branch", $upstreamTag, "--depth", "1", $upstreamUrl, $SourceDir)
}

$sourcePath = (Resolve-Path $SourceDir).Path
Push-Location $sourcePath
try {
    $head = (& git rev-parse HEAD).Trim()
    if ($head -ne "4f6ae4e26ae5fe8af9372f8d312ab25cc4595223") {
        throw "Source is not upstream v1.6.2.post1 commit 4f6ae4e26ae5fe8af9372f8d312ab25cc4595223."
    }
    Invoke-Checked git @("apply", "--check", $patchFile)
    Invoke-Checked git @("apply", $patchFile)

    $buildDir = Join-Path $sourcePath "build"
    if (Test-Path -LiteralPath $buildDir) {
        Remove-Item -LiteralPath $buildDir -Recurse -Force
    }
    if (Test-Path -LiteralPath $buildDir) {
        throw "Clean failed: build directory still exists."
    }

    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    $env:TORCH_CUDA_ARCH_LIST = "8.6"
    $env:CAUSAL_CONV1D_FORCE_BUILD = "TRUE"
    Invoke-Checked $Python @("setup.py", "bdist_wheel", "--dist-dir", (Resolve-Path $OutputDir).Path)
}
finally {
    Pop-Location
}
