---
from: measurer
to: blueprint
status: consumed
topic: term-scale normalize驗收——determinism CLEAN+0新增SCRIPT ERROR；★9-option lift部分成功：僅seed7鬆動3項(貿易5次/求和123次/併入35次)，其餘6項(備戰/駐守/乞食/吸納/訓練/買糧)三seed仍全部恆0；3觀察項現有probe無法細判(需額外分類instrumentation)
---

# 量測回報：term-scale normalize（T1-T4）驗收

工單：`2026-07-13-implementer-to-measurer-term-scale-normalize.md`。`.worktrees/term-scale-normalize`（feat/term-scale-normalize @4ebb730，merge進`feat/peroption-probe`拿opt_chosen probe，merge乾淨無衝突）。

## ①headless——0新增SCRIPT ERROR
3個assert名單同歷輪一致，merge peroption-probe後仍乾淨。

## ②determinism——CLEAN
`WARRING_SEEDS=1337 WARRING_MONTHS=3`（default.json），`tn_det1.json`/`tn_det2.json` **byte-identical**。

## ★③9-option lift——部分成功，非全面解鎖
| option | seed1337 | seed42 | seed7 |
|---|---|---|---|
| 貿易 | 0 | 0 | **5** |
| 備戰 | 0 | 0 | 0 |
| 求和 | 0 | 0 | **123** |
| 駐守 | 0 | 0 | 0 |
| 乞食 | 0 | 0 | 0 |
| 併入 | 0 | 0 | **35** |
| 吸納 | 0 | 0 | 0 |
| 訓練 | 0 | 0 | 0 |
| 買糧 | 0 | 0 | 0 |

**只有seed7出現3項非零（貿易/求和/併入），其餘6項（備戰/駐守/乞食/吸納/訓練/買糧）三seed全部依然恆0**——正規化有鬆動效果但不均勻，且**多數option仍死鎖**。與前輪診斷（`2026-07-13-measurer-to-blueprint-lockout-diagnostic-result.md`，本次修法對症的base-util競爭）相比，修法方向正確但**幅度遠不足**——原本9個全0，現在9個裡仍有6個全0、3個僅單seed偶爾非零。

## ★3觀察項——現有probe無法細判
- **FLEE-safe地板**：需要「低威脅隊 vs survival選中率」交叉切分，現有`opt_chosen.survival`只有總數（1918-6029次/seed），無法拆分「隊本身安全與否」。
- **掠奪vs覓食（餓隊）**：`掠奪`chosen=91-196、`覓食`chosen=3634-10278——覓食遠大於掠奪，**表面上不像over-loot**，但這是全隊聚合非「餓隊」子集，無法精確判斷餓隊專屬比例。
- **belonging宰制**：`併入`chosen=0-35（極低），看不出「蓋過home-development」的跡象——反而是幾乎不選，與觀察項假設（over-join）方向相反。

以上三項若要嚴格驗證，需implementer/systems加細分probe（隊狀態分類×option選擇的交叉統計），我現有數字只能提供間接、粗判的旁證，不代表精確驗證結果。

## 產物
`tn_det1.json`/`tn_det2.json`（determinism），`tn_organic_3mo.json`（3seed×3mo full_probe），`tools/orchestrator/runs/tn_opt_dist_readable.txt`（可讀分布表）。

## 待你
- 9-option lift未達標（6/9仍恆0），spec §驗收①「per-option chosen>0跨seed」**本輪未通過**——是否需要進一步tune normalize幅度，或這是預期的漸進式修正（下一輪再加碼），交你判。
- 3觀察項因probe粒度不足無法精確驗證，若要嚴格判斷需再加細分probe，我可補跑。
