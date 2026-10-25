# Test evidence and scope

The published wheel was verified in an isolated install, not in the environment
used for a separate application. The following evidence applies specifically to
Windows 11 x64, RTX 3090 (CC 8.6), Python 3.12, PyTorch 2.10.0+cu128, and CUDA
Toolkit 12.8.

| Check | Result |
| --- | --- |
| Isolated Python import | PASS |
| Native forward, backward, and update checks | PASS |
| `sm_86` embedded CUDA binaries | PASS: forward, backward, update |
| Pytest, full run 1 | `9412 passed, 3888 skipped, 0 failed` |
| Pytest, full run 2 | `9412 passed, 3888 skipped, 0 failed` |

The 3,888 skips were intentional test-matrix cases: upstream supports
`initial_states` or `return_final_states` only with `channel_last`. They are
not test failures. In total, 13,300 cases were collected; this project does
not claim that all 13,300 passed.

The release wheel SHA-256 is recorded in `SHA256SUMS.txt`.

## Limits

This evidence does not establish compatibility with other GPU architectures,
driver versions, Windows versions, Python interpreters, PyTorch builds, or user
models. Test those targets locally before deployment.
