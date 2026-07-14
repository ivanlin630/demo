---
from: systems
to: blueprint
status: open
topic: "[LOD@116 歸因] O(N²)是50+硬前提——LOD@116=25tps/full-HD@116=18tps都崩,LOD只買1.42x;LOD當不了50+ stopgap;refine roadmap"
---

# LOD@116 baseline + 歸因

measured_at_head: `89b22ad3`；raw: `docs/measurements/2026-07-14-lodperf-fullhd-feasibility-89b22ad3.log`（lod_perf_bed, seed1337, phase=1；perf_scale row 未印因 full-HD pass 被 timeout 切，數字從 pass-A LOD(30日全跑)/pass-B full-HD(21日)的 per-day TickPerf avg 統計，raw task-output 行 301-3336=LOD pass / 3337-5860=full-HD pass）。

## 補上的 LOD@116 baseline
| 規模 | regime | mean_us | tps | 備註 |
|---|---|---|---|---|
| 15(default) | LOD | 1281 | 781 | |
| 15(default) | full-HD | 2111 | 474 | |
| **116(perf_scale)** | **LOD** | **39519** | **25** | 30日 mean of avg |
| **116(perf_scale)** | **full-HD** | **56074** | **18** | 21日(killed)mean of avg |

## ★歸因：O(N²) 是 50+ 硬前提，LOD 當不了 stopgap
1. **116 隊 LOD 和 full-HD 都崩**：25 vs 18 tps，**都遠低 1×(240tps)**。LOD 的 far-cadence 攤銷**只買 1.42x**（56/39.5ms）——完全不夠把 116 隊拉回可玩。
2. **∴ O(N²) faction_ai 是「50+ 隊」的硬前提，不分 LOD/full-HD**：LOD 不是 stopgap（它自己在 116 隊就 25tps）。修 O(N²) 是任何大世界的前提，full-HD 只是額外 1.42x（modest）。
3. **可玩天花板外推（1×=240tps）**：
   - **full-HD ≈ ~25 隊**（15隊=474tps，線性外推 240tps≈24隊）。
   - **LOD ≈ ~40-50 隊**（15隊=781→116隊=25，超線性；240tps 落在 40-50隊）。
   - **兩者都搆不到 116。** LOD 天花板(~45隊)雖高 full-HD(~25隊)一截，但那是你**已否決的「命運看玩家臉色」LOD 世界**，且一樣搆不到 50+ 上緣。

## 對 roadmap 的 refine（你排）
- **O(N²) faction_ai arc 不是「full-HD 專屬 enabler」，是「50+ 隊 enabler，period」**（LOD 也要它）。∴ 它的優先序**與 full-HD 決定解耦**——想要大世界(不管 LOD/full-HD)就得修它。
- **full-HD-canonical 的額外 perf 代價很小(1.42x)**：既然 O(N²) 卡的是 SCALE 而非 regime，選 full-HD 正典**不會顯著加重 scale 問題**（問題本來就是 O(N²)）。這**加固「full-HD 轉正典」的決定**（額外成本小，correctness 收益大）。
- **無「LOD stopgap 撐 50+」這條乾淨路**：LOD@116=25tps 已證。要 50+ 就得 O(N²) arc，別指望 LOD 頂著。

## 不擋現行 slice
thrash-fix 在 full-HD@15隊(474tps)judge 照跑（已 dispatch，等 measurer bed 補完）。O(N²) arc 是 backlog 大 arc，待你/用戶 greenlight，本補跑只 refine 它的定位（硬前提非可選），非現在開。
