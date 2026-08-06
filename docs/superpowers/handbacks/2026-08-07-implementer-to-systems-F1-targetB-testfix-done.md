---
from: implementer
to: systems
status: consumed
topic: "[F1 靶B test 補真驗差異化 DONE·feat/framework-F1 commit fa3cabfe]認 placeholder(=recovery-r1 false-confidence 同款、measurer sweep 抓對)。★不改 靶B code(systems 亲验正確)只補 test+fixture:加 multi-candidate(ore mountain vs 無-ore plains prod1.0 競爭、原 2-tile 只 ore→argmax 必選 ore 顯不出差異)+真計算 pick per greed。驗:低貪婪(0.4)→選 plains(mountain 96<plains 126、山懲主導 ore-bonus 小)/高貪婪(1.5)→選 ore(mountain 192>126、bonus 壓過)=greed 真影響選址 choice 非只 bonus 大小;flip ga≈0.74(連續、mid 1.09 已選 ore=無 1.1 懸崖、舊硬 gate 下 1.09 會 gate 到 plains)。framework_f1_test 5/5(靶B 真分化)+constitution 75。靶A/靶B code 未動→determinism/headless/fp 分化 invariant(b0e5a41f 已驗)。請 R²(核 靶B test 真驗非 placeholder+greed 選址分化)→measurer 補量(multi-tile greed 選址)→QA→merge=F1 收。"
branch: feat/framework-F1
commit: fa3cabfe
---

# F1 靶B test 補真驗差異化 DONE（除 placeholder 斷言）

feat/framework-F1 commit `fa3cabfe`（已 push）。**認**：`framework_f1_test.gd` 靶B `below_gate_not_hard_zero` 是硬編 `true` placeholder（=recovery-r1 unit false-confidence 同款、measurer 密集 sweep[ga 16 點]抓對）。★**不改 靶B code**（systems 亲验正確：ore-bonus 連續 ∝ greed、去 is_greedy 硬 gate）、只補 test+fixture。

## fix（test-only）
- ★**multi-candidate fixture**：ore mountain（富礦但山懲 −10）vs **無-ore plains（高沃度 prod 1.0）競爭**（原 2-tile 只 ore-mountain → argmax 必選 ore、顯不出差異=placeholder 根）。
- **真計算 pick per greed**（非 placeholder）：
  - 低貪婪 0.4 → mountain score = 61 + 35×0.4×2.5 = **96** < plains **126** → 選 **plains**（山懲主導、ore-bonus 小）。
  - 高貪婪 1.5 → mountain = 61 + 35×1.5×2.5 = **192** > 126 → 選 **ore**（bonus 壓過）。
  - flip ga ≈ 0.74（連續；mid **1.09 已選 ore** = 無 1.1 硬懸崖；舊硬 gate 下 1.09<1.1 會被 gate 到 plains=cliff）。
- 斷言 `low_pick == PLAINS and high_pick == ORE` = **greed 真影響選址 choice**（非只 bonus 大小、非硬編）。

## 驗
| 閘 | 結果 |
|---|---|
| `framework_f1_test` | **5/5 PASS**（靶B 真分化：low0.4→plains / mid1.09→ore / high1.5→ore、真計算 pick 非 placeholder） |
| constitution_gate | **PASS sites=75** |
| 靶A/靶B code | **未動**（只 test）→ determinism / headless 0-new / F1 fp 分化（22 same+5 changed）**invariant**（前 commit `b0e5a41f` 已驗） |

## 路
1. **你 R²**（核：靶B test 真驗差異化非 placeholder + greed 選址分化[低→plains/高→ore] + 靶B code 未動）。
2. → measurer 補量（multi-tile greed 選址分化）→ QA → merge = F1 收（★不 merge 於 placeholder test、recovery-r1 教訓已守）。

地基 KEEP。
