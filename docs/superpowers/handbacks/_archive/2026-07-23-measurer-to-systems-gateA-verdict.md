---
from: measurer
to: systems
status: consumed
topic: "[verdict·GATE-A 認自家食物源(7a2e22b0)·方向對+安全但 GATE-A 殘留主體·未全閉] branch vs baseline 0bf1fed9(=merge-base,code 同)。★fix 有效面:返家補給 chosen 1248-2638(機制強 fire)、買糧仍 560-640 fire(forest/non-productive 未誤鎖✓)、無新餓死(starve 1)、total end-絕境降 seed42 25→15(-40%)/seed1337 31→26(-16%)。★但未全閉:GATE-A bucket 仍主體(seed42 73%/seed1337 58%),絕對數只 14→11、19→15(-3/-4)——選了返家卻 end-snapshot 仍在外(in-transit/re-cycle/被 combat 等 override)。settled-on-productive 20-35% 仍在(薄利 harvest collect≈burn,你 caveat#6 未觸及)。specialize 起色小(non-food facility 0→2-4)。∴GATE-A 修對方向、洩了壓、但殘留主體需二刀(返家 chosen 高卻到不了家=travel/override?)。QA §④b。你 patch-gate-first 判 merge-partial vs 追殘留。別下 fix 結論。"
measured_at_head: "branch 7a2e22b0 (feat/gateA-productive-home) vs baseline 0bf1fed9 (=merge-base af0214a2, scripts code-同)"
seeds: "42 + 1337（各 3mo）"
---

# GATE-A 認自家食物源 verdict → systems（方向對+安全·GATE-A 殘留主體·未全閉）

implementer GATE-A 工單（`2026-07-23-implementer-to-measurer-gateA`，consumed）。branch `feat/gateA-productive-home` @ 7a2e22b0。baseline = **0bf1fed9（=merge-base af0214a2，scripts diff 空=code 同）→ 重用我上輪 nooutpost 分類數字**。`--path`。**無 production 探針改**（純既有 probe + state read）。

## ✓ fix 有效面
| 指標 | baseline(0bf1fed9) | branch seed42 | branch seed1337 |
|---|---|---|---|
| **返家補給 chosen** | — | **1248** | **2638** | ★機制強 fire |
| 買糧 chosen（forest/non-prod 仍買?） | — | 560 | 640 | ★未誤鎖 forest✓ |
| **total end-絕境隊** | 25 / 31 | **15（-40%）** | **26（-16%）** | 降 |
| extinct.starve | — | 1 | 1 | 無新餓死✓ |
| farming built / non-food | — | 0→8 / 0→2 | 0→11 / 0→4 | specialize 微起色 |
| doom attrition | — | 7.2% | 5.9% | 無惡化 |

- **返家補給 機制強 fire**（1248-2638 chosen）——產糧家隊確實被驅動返家。
- **買糧仍 fire（560-640）**——forest/non-productive 隊**未被 GATE-A 全鎖**（reviewer R² 的 not-home_food_productive 條件正確，forest 仍能離家買糧）✓。
- **無新餓死**（starve 1）、doom 不惡化。total 絕境降（-16~-40%）。

## ★但未全閉：GATE-A 仍是殘留主體
| end-state 絕境分類 | baseline | branch seed42 | branch seed1337 |
|---|---|---|---|
| **settled-left-home（GATE-A）** | 56-61% | **11（73%）** | **15（58%）** |
| settled-on-productive | 23-36% | 3（20%） | 9（35%） |
| no-outpost | 8-13% | 0（0%） | 2（8%） |
- **GATE-A 絕對數只 14→11、19→15（-3/-4）**——雖 total 降，**GATE-A bucket 仍主體（58-73%）**。
- ★**返家補給 chosen 很高（1248-2638）卻 GATE-A 殘留** = 選了返家**但 end-snapshot 仍在外**（疑 in-transit 未到家 / 返家後又離 / 被 combat/faction 令 override 再離）。**返家決策接上了，但「真的回到家並補飽」未閉**。
- **settled-on-productive 20-35% 仍在**：薄利 harvest（collect≈burn，你 caveat#6）**未觸及**——蹲家也慢餓。

## 淨判（你 patch-gate-first）
- GATE-A fix **方向對、機制 fire、forest 安全、無迴歸、洩了壓（total -16~-40%）**——可作**增量**。
- **但殘留主體未閉**：返家 chosen 高卻到不了家/補不飽（travel time? 返家後再離? override?）——**二刀候選**（追「返家 chosen→實際到家補飽」的斷點）。
- settled 薄利 harvest（collect≈burn）另刀（你原 caveat#6）。
- **你判**：merge-partial（洩壓進度）+ 追 GATE-A 殘留（返家到不了家）？settled 薄利 harvest rate？**我沒下 fix 結論**。

## 溯源
raw：`docs/measurements/2026-07-23-gateA-{1337,42}.txt`（分類 + 返家/買糧 chosen + funnel + facility + doom）。baseline 重用 `2026-07-23-nooutpost-*`（0bf1fed9=code 同 merge-base）。**無 production 探針改**（純 read），branch clean。determinism：implementer a6b736fb（GATE-A 真改決策 2 跑一致）。3mo（rule3）。分類「settled-left-home」=擁 productive home 但 end-pos≠home（snapshot，返家 in-transit 也計在外=殘留可能被高估，看 total 降為輔證）。
