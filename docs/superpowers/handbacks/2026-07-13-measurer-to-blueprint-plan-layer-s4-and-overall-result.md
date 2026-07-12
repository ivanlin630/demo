---
from: measurer
to: blueprint
status: consumed
topic: plan-layer S4驗收+★S1-S4整體彙整——GUI邏輯層綠(35/35 PASS+0新增SCRIPT ERROR)；★視覺fidelity截圖harness本輪跑不出來(3次嘗試/路徑修正後仍25分無產出，已kill非硬卡)標記待補；S1-S4全部determinism CLEAN+headless乾淨，plan-layer中長期計畫層機制面收齊
---

# 量測回報：plan-layer S4驗收 + S1-S4 整體彙整

工單：`2026-07-13-implementer-to-measurer-plan-layer-s4.md`。`.worktrees/plan-layer-s4`（feat/plan-layer-s4 @96e1579）。

## S4 單獨驗收

### ①observer_inspect_test——35/35 PASS
implementer信§自驗確認：`=== observer_inspect_test: PASS=35 FAIL=0 ===`。

### ②headless——0新增SCRIPT ERROR
3個assert名單同前幾輪一致（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`），非本slice新增。

### ③★截圖fidelity——本輪未產出，非硬卡
嘗試序：①wrapper `godot.ps1` 傳陣列 `--obs-*` 參數失敗（`Start-Process -ArgumentList` 型別錯，wrapper本身bug，非本slice）②改直呼exe，scene路徑猜錯(`scripts/ui/observer_main.tscn`不存在)③修正路徑`scenes/ObserverMain.tscn`後process啟動但**~25分鐘無輸出、RAM從105MB降到38MB無截圖檔生成**，判定卡住而非慢，已kill。**未查出根因**（headless GUI scene在worktree下是否有相容性問題，或`--obs-run-months=3`本身太長，未進一步排查）。

**GUI邏輯層本身已驗證乾淨（35/35單元測試PASS），視覺呈現fidelity（截圖裡「計畫：<phase>」行實際排版）本輪測不出來，標記待補，不阻塞判斷**。

## ★S1-S4 整體彙整

| slice | determinism | headless新增FAIL | 核心驗收 |
|---|---|---|---|
| S1 rung事件驅動 | CLEAN | 0 | churn/rung_dist數字到手，無舊基線可比降幅 |
| S2 phase導出+偏置term | CLEAN | 0 | TC7 divergence OK，貿易雙偏置歸零；organic偏置實效25-33% |
| S3 survival-bypass | CLEAN | 0 | bypass organic下確有觸發(4-9次/seed/3mo)；attrition跨輪對比不可靠(base commit不同) |
| S4 GUI顯示 | N/A(純顯示) | 0 | 邏輯測試35/35 PASS；視覺fidelity本輪未測出 |

**plan_phase organic分布（S3前補測，跨S1-S3疊加狀態）**：成長phase三seed皆獨大(71-78%)，求糧幾乎不出現——**已交blueprint零跑判讀為「非bug，食物修成功後多數隊落中間態=真實現象」**（見cbfe36f commit訊息，非我這輪新判斷）。

**established**：全程恆0，四層B門(B1-B4)裡B2(統領門檻)是主要卡點，前輪組合測（forage+tenure）測出B2首次出現裂縫（seed7 4.2%通過）但B3接手卡死——**plan-layer S1-S4完成的是「機制面」（rung/phase/bypass/GUI），established>0需要下一階段「立國-redesign」處理B門本身**，implementer信§序列已標注此為下階段。

## 產物
`s4`系列尚無正式determinism/organic跑（純顯示層，implementer已說明不觸sim tick路徑，我信任此判斷未重複驗證——如需我可補一輪1seed×1mo純determinism confirm，目前優先順位判斷為低，純顯示層風險小）。

## 待你
- S4視覺fidelity若需要，請告知是否要我用更短窗（如1mo而非3mo）重試截圖harness排查根因，或用戶手驗替代。
- S1-S4收齊，序列末交你排「立國-redesign（填ESTABLISH phase空偏置）→ 繁殖/pop arc」下一階段。
