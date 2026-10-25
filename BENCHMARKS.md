# Benchmark and profiler evidence

Numbers below are measured evidence for the stated test machine only, not a
general performance promise. The latency benchmark and profiler are separate
experiments and must not be compared as equivalent timings.

## BF16 channel-last backward harness

The upstream `tests\benchmark_determinism_kernels.py` harness was run with
channel-last BF16 parameters `B=4, D=4128, L=4096, W=4`.

| Mode | Backward latency | Peak memory |
| --- | ---: | ---: |
| Default | 0.668 ms | 390.2 MB |
| Deterministic | 0.790 ms | 400.3 MB |

The deterministic mode was 18.3% slower and used 2.6% more peak memory in this
harness. This is not an end-to-end production-model benchmark.

## Nsight Compute kernel profile

Nsight Compute 2026.3.1 profiled one launch of the channel-last backward
specialization on the RTX 3090. Both modes used `BFloat16,float`,
`128,4,128,1,1` traits and 38,160 bytes static shared memory.

| Metric | Default | Deterministic |
| --- | ---: | ---: |
| Registers per thread | 229 | 175 |
| Achieved occupancy | 16.35% | 16.08% |
| Active warps per cycle | 7.85 | 7.72 |
| DRAM throughput | 357.66 GB/s | 633.89 GB/s |
| DRAM % of peak sustained | 65.70% | 67.43% |
| L1 hit rate | 5.62% | 10.62% |
| L2 hit rate | 35.68% | 37.11% |
| Local-memory spills | 0 | 0 |

Register and shared-memory limits permitted two resident blocks for this
specialization. Hardware counters showed no local-memory spilling; the low
achieved occupancy is therefore a resource characteristic of this specialization,
not proof of a defect. The dominant sampled stall was long scoreboard
(3.47% default, 3.88% deterministic).

The profile was deliberately filtered to `causal_conv1d_channellast_bwd_kernel`;
third-party PyTorch kernels were excluded. Counter collection performs replay,
so profiler duration is not reported as application latency.
