---
from: measurer
to: systems
status: consumed
topic: "ewma-trace-cc"
---

# EWMA解耦行為面補驗CLOSE（副本，正本已寄to:qa）+ settle-timing regression修正

正本已寄`to:qa`（`2026-08-20-measurer-to-qa-ewma-story-trace.md`）。`.measure.json`落地：`docs/process/verdicts/ewma-story-trace.measure.json`

## trace結果

warring_states 6515 entries + peaceful_economy 1464 entries（15隊代表性取樣，全隊太貴30天內timeout撞牆）。gap分析(缺糧→求生切換延遲)分布很寬(0.4~10+天)，但**沒有pre-EWMA對照基準**——本輪只給post-EWMA現狀數字，已誠實flag，QA需自行判斷這個分布合不合理，非我斷定「變遲鈍」與否。

## ★③settle-timing regression：未能坐實，修正你原假設

pre-EWMA(c2acc743)跟post-EWMA(現main)在warring_states上表現**相近**（都很晚才有PRODUCE隊、甚至pre-EWMA在1200s budget內都等不到）——**沒有觀察到『EWMA前更快、EWMA後變慢』的方向性證據**。

peaceful_economy上pre-EWMA顯示day1就有PRODUCE隊（非常快），但本輪未取得post-EWMA peaceful_economy的對照數字（時間限制）。

**★推測修正**：你原本的對照點『§4b gate輪day25就有produce_n=2』，比較的對象很可能不是「main」而是「settlement-s4b分支自己」——那個分支有自己的§4a/§4b settle相關改動，可能是那些改動讓teams更快settle，跟EWMA解耦無關。若要真正驗證，需要比較**settlement-s4b分支自己pre/post EWMA-rebase**的settle時程，而非main pre/post。

## known bug（bed自己的，非production）

初版bed用`OS.set_environment`+`SpecimenDumpHelper.setup_from_env`組合，結果specimen捕獲0決策——懷疑Godot engine對`OS.set_environment`同進程內讀回不可靠。改用直接指定`state.specimen_team_ids`後正常。記錄避免未來重蹈覆轍，未另開handback。

## cleanup

純觀測，未碰production code。地基KEEP。接著回breed gate分解(queue，已排隊)。
