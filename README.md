# causal-conv1d Windows community builds

Unofficial community Windows builds and reproducible build instructions for
[`causal-conv1d`](https://github.com/Dao-AILab/causal-conv1d). This project is
not affiliated with, endorsed by, or supported by Dao-AILab.

## Release covered by this repository

The `windows-sm86-v1` release distributes a prebuilt wheel for upstream
`causal-conv1d` `v1.6.2.post1`, with a small Windows-only build-configuration
patch. No CUDA algorithms, C++ kernels, or Python API code were changed.

The wheel was built and tested on:

| Component | Verified configuration |
| --- | --- |
| Operating system | Windows 11 x64 |
| GPU | NVIDIA GeForce RTX 3090 (compute capability 8.6) |
| Python | 3.12 |
| PyTorch | 2.10.0+cu128 |
| CUDA Toolkit | 12.8 |
| Compiled target | `sm_86` |

Only this configuration and GPU were tested. Other Windows versions, Python or
PyTorch versions, and GPUs are untested and may require a local rebuild.

## Install the released wheel

Download the wheel and `SHA256SUMS.txt` from the
[release page](../../releases), verify its hash, then install it into a
compatible environment:

```powershell
Get-FileHash .\causal_conv1d-1.6.2.post1-cp312-cp312-win_amd64.whl -Algorithm SHA256
python -m pip install .\causal_conv1d-1.6.2.post1-cp312-cp312-win_amd64.whl
```

Do not install it into a production environment before testing it there.

## What is here

- `patches/windows-sm86.patch` — the minimal patch applied to upstream.
- `scripts/build_windows.ps1` — a parameterized local build helper; it does
  not contain machine-specific paths.
- `BUILD.md` — prerequisites and reproducible build steps.
- `TESTING.md` — verification evidence and scope.
- `BENCHMARKS.md` — measured synthetic benchmark and profiler evidence.
- `THIRD_PARTY_NOTICES.md` and `LICENSE` — upstream attribution and license.

The repository intentionally excludes local virtual environments, build
directories, logs, backups, audit reports, and the wheel itself. The wheel is
provided only as a release asset.

## Security and compatibility notes

Verify the SHA-256 checksum before installation. This package includes a native
CUDA extension; use it only in an environment you control. The release is a
community artifact, not an official upstream binary distribution.

## Upstream

Upstream source and issue tracker: <https://github.com/Dao-AILab/causal-conv1d>
