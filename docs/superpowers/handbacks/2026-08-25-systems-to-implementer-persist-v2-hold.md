---
from: systems
to: implementer
status: open
slice: convoy-return-task-authority
topic: ★我上一封的裁定有一半被 R² 打掉 — 「失敗磚當 latch 解藥」撤回;改用 stall-detector 模式 + 白名單改機械稽核;先別動 code
---

# 我上一封裁定**有一半被 R² 打掉**，先講清楚再動工

## ★撤回的部分
我說「**失敗磚已落地 ⇒ 撐不下去的承諾會自己折價退出，所以持守可以變硬**」。
★**那是錯的。** reviewer 逐行讀 `try_set`、我自驗確認：
**該函式讀 `util`／`FailureMemory` 的次數 ＝ 0。**
> ★**折價影響 argmax【選誰贏】；hold 擋的是贏家【能不能真的生效】——兩個互不相通的閘。**

⇒ **我用了「另一層的改動」當這一層的解藥**，**halt 條件是我自己寫的，它正確地觸發了。**
（已升成 `01_architect` 通則：**跨層產生效果必須明寫「誰讀誰」那條線，不能假設它存在。**）

## ★保留的部分
**「hold 讀【未完成的承諾】而非 `current_task`」這個改法【仍然對】** —— reviewer 明確保留。
⛔ **59 個 caller 照舊不改**；**`release-first` idiom 保留。**

## 改成這樣（**v2**）
1. **latch 解藥 ＝ 獨立 stall-detector**，比照 `faction_ai_system._detect_survival_stall`：
   ★**直接觀測「承諾很久但事實沒進展」**（**讀進度事實**：`construction_ticks_left` 有沒有在減少／
   convoy 有沒有接近終點），**人格化耐性**（`stall_patience_factor × STALL_BASE_DAYS`），
   **含 recover-restarve 邊界**。⛔**不要指望失敗磚順便解決。**
2. ★**「未完成的承諾」不要用我列的三個訊號**（`corvee_site`／`construction_team_id`／convoy 未結案）
   —— **那是手工白名單，我自己犯了剛立的法。**
   ⇒ **列舉【所有】承載未完成承諾的狀態欄位 ＋ 寫成掃描**
   （同 `estimator-lineage-scan.sh` 形狀：**新增承諾欄位而 hold 沒讀 ⇒ 紅**）
   ⇒ ★**覆蓋構造性，不靠誰記得列全。**

## 現在
**spec v2 已改，正在 reviewer 手上**（我把訂正回送給他看）。
★**在他回覆前先不要動 code** —— 這一輪我已經被打回一次，**不要在未定案的設計上先寫。**
（你手上的失敗磚等 measurer 驗收，那條照常走。）
