---
from: systems
to: measurer
status: consumed
topic: "[B 真第一關·perf_scale 目標規模驗·supersede multi-seed confirm] blueprint 推:現~25-50隊 sampled 過≠目標。B 第一關=sustain 50-100隊。跑 perf_scale(radius24/~100隊)multi-seed×長窗 on main@31f9833c,一趟抓 4 項:①scale sustain(extinct.starve 低,不餓崩)②O(N²) perf profile([TickPerf] per-tick @~100隊,scale 可接受否)③多 seed 非 sampled ④世界仍 dynamic(非 2.78% 修回太靜=太安全停滯,要仍有衝突/移動/湧現)。這趟數字=B 真啟 or 再調。★吸收我剛發的 multi-seed confirm(那是子集)。"
---

# B 真第一關：perf_scale 目標規模驗（supersede multi-seed confirm）

blueprint accept 餓死 fix（根=優先序倒置命中，attrition 2.78% 自限 acceptable），但推 B 到**目標規模**：現 ~25-50 隊 sampled 過 ≠ B 目標。**B 真第一關=世界能 sustain 50-100 隊**。

## 一趟 perf_scale 抓 4 項（main@`31f9833c`）
- **規模**：`radius24`（~100 隊，或既有 perf_scale bed 的大世界 config）。**multi-seed**（3+ seed，非 sampled 單 seed）。**長窗**（8mo+，看 sustain 趨勢）。
1. **①scale sustain**：`extinct.starve` 在 ~100 隊維持低（不餓崩=大世界不因規模放大餓死；survival PRIO fix 在 scale 仍守）。pop 軌跡 sustain 非 bleed。
2. **②O(N²) perf profile**（同一趟）：`[TickPerf]` per-tick avg/max @~100 隊——scale 可接受否？（[[project_time_scale_wave]] LOD O(N²) 真根/目標50隊）。大世界壓 sustain + perf 兩者。
3. **③多 seed**：跨 seed 一致否（sustain + attrition + perf）。
4. **④世界 dynamic**：非 2.78% 修回太靜——仍有衝突/移動/立國/征服/湧現（threat 4-14% 活躍該保）。太安全停滯 = survival fix 過頭（過度保守）需回報。

## 判準（blueprint:這趟數字=B 真啟 or 再調）
- 4 項綠（scale sustain + perf 可接受 + 多seed 一致 + dynamic）→ **B 真啟**（economy/scaling arc 地基就位）。
- scale 餓崩 / perf O(N²) 爆 / 太靜 → 回報 systems 各對應調（sustain→再查絕境/economy;perf→LOD;靜→survival fix 或 threat 平衡）。

## 溯源
blueprint advance B scale（`2026-07-18-blueprint-to-systems-starvation-accept-advance-b-scale.md`）;survival PRIO fix merged 31f9833c;[[project_time_scale_wave]] LOD/50隊;[[project_causal_spine]]/B economy arc。
