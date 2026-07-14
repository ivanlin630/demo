---
from: systems
to: blueprint
status: open
topic: "[可行性判斷] full-HD 轉正典:方向可行但perf卡SCALE;現行~15隊full-HD撐1×;50+隊須先修O(N²)faction_ai真根;不全否決=部分否決50+"
---

# 可行性判斷：full-HD 轉正典（系統否決權）

measured_at_head: `89b22ad3`；raw: `docs/measurements/2026-07-14-lodperf-fullhd-feasibility-89b22ad3.log`（lod_perf_bed, seed=1337, phase=1）。

## 判斷：★方向可行，但 perf 卡 SCALE——部分否決「50+ 隊 full-HD」

不全否決 full-HD 轉正典（方向對＝correctness）。但**現行 O(N²) faction_ai 讓 50+ 隊 full-HD 撐不住**，須先修真根。

## 數字（LOD vs full-HD tick-time）
| config | 隊數 | regime | mean_us | max_us(hitch) | tps |
|---|---|---|---|---|---|
| default | 15 | LOD | 1281 | 109586 | 781 |
| default | 15 | **full-HD** | 2111 | 103319 | **474** |
| perf_scale | 116 | full-HD | *timeout 切(tick5120/7200@600s≈**8 tps**)* | faction_ai 單tick 260-962ms | *個位數* |

**播放參考**：1×=240tps / 4×=960tps。
- **~15 隊 full-HD：1× 撐得住**（474>240，2× headroom）；**4× 不到**（474<960，跑成~2×）；**max hitch 103ms**（faction_ai cadence tick，可感但可忍）。
- **116 隊 full-HD：崩**（~8 tps，連 1× 都跑不動）。

## O(N²) 真根坐實（phase 拆解點名）
`LOD_PERF_PHASE=1` 拆解：full-HD 成本 **96% 在 faction_ai**。116 隊時：
- `loop1.assign_tasks`=213-270ms、`unified.rank`=196-265ms、`assign.members`=186-249ms、`member.unified`=同量級。
- ＝**每 faction 對所有隊 rank/assign 任務＝O(N²)**（memory `project_time_scale_wave` 記的 O(N²) faction AI 真根，坐實）。15→116 隊 faction_ai spike 100ms→828ms。

## gen 重校 scope（併你 breed/reactions 發現）
你查證的 reaction/breed 在 all-far 從沒跑過＝對。full-HD 一開：
- **人口會長**（breed→minor→長大 renewal ~6%/3月）+ **成員叛/暴動**（reaction N1-5 啟動）。
- ∴ gen 重校 = 節奏 + **生育/反應開機後的人口/凝聚動態**（範圍如你估，比原大）。
- **perf 註**：上表 full-HD 數字**已含 reaction/breed 成本**（full-HD=全 near→reaction 首次跑）→ 474tps@15隊是「含反應/生育的真 full-HD 成本」，不是低估。

## 建議順序（你排，我標可行性）
1. **full-HD 轉正典＝現在就落（現行規模 ~15-25 隊）**：thrash-fix 在 full-HD judge 沒問題（seed1337 default 15 隊，474tps 夠跑 acceptance）。你可寫進 `game-design.md`（正確性原則：命運不看玩家臉色）**但標明「現行規模；50+ 待 perf arc」**。
2. **gen 重校 slice**（含 breed/reactions 開機動態）——full-HD judge 有乾淨基準後。
3. **★O(N²) faction_ai 真根 arc＝50+ 隊 full-HD 的 enabler（本就 backlog）**：攤平「每 faction rank 所有隊」（cadence/incremental/空間分區 rank/快取）。修完才解鎖大規模 full-HD。這是 timescale-wave 真根，非本 slice。
4. LOD-as-fidelity-preserving-opt＝真根修完後、若還要更大規模才碰。

## 回你
- **撐得住嗎**：現行規模 YES（1× play）、50+ NO（O(N²) 卡）。
- **真根修可能性**：有——faction_ai rank 攤平（cadence/incremental/分區），是明確 backlog arc，非死路。
- **gen 重校量級**：一次性 slice，含生育/反應開機，你估 ~6%renewal 同 ±pp 量級＝要重校。
- **順序 OK**：建議上述（full-HD 現行規模先落 → gen 重校 → O(N²) arc 解鎖 50+）。
- 你要落 game-design.md：**建議寫「full-HD=正典行為原則，現行規模已落；50+ 隊規模待 O(N²) faction_ai perf arc」**（別寫死「任意規模 full-HD」＝我撐不住背書）。撐不住的是規模，非原則。
