# Reproducible Windows build

This guide rebuilds upstream `v1.6.2.post1` for an RTX 3090-class `sm_86`
target. It is intended for a clean, disposable virtual environment.

## Prerequisites

- Windows x64 with a supported NVIDIA driver.
- Python 3.12 and a virtual environment containing PyTorch `2.10.0+cu128`.
- CUDA Toolkit 12.8 with `nvcc` available on `PATH`.
- Visual Studio 2022 Build Tools with the C++ desktop workload.
- Git and PowerShell.

The helper does not download or install Python, PyTorch, CUDA, drivers, or
Visual Studio. Check those versions yourself before building.

## Build

```powershell
git clone https://github.com/vaservaga/causal-conv1d-windows-builds.git
Set-Location causal-conv1d-windows-builds
.\scripts\build_windows.ps1 -Python python
```

The helper clones upstream at `v1.6.2.post1` to `upstream-source`, applies the
included patch, removes only `upstream-source\build`, then builds a wheel into
`artifacts`. It sets `TORCH_CUDA_ARCH_LIST=8.6` and forces a fresh extension
build. It stops if the build directory remains after cleaning.

For a pre-existing upstream checkout, pass `-SourceDir` and make sure that it
is exactly the intended upstream revision before applying the patch.

## Verify the artifact

```powershell
Get-FileHash .\artifacts\causal_conv1d-1.6.2.post1-cp312-cp312-win_amd64.whl -Algorithm SHA256
```

Install and test only in an isolated environment. The release checksum applies
to the published artifact; a locally rebuilt wheel can differ by build metadata
or toolchain and must be validated independently.
