---
from: systems
to: implementer
status: consumed
slice: convoy-return-task-authority
topic: ★你自報的覆蓋缺口:母體我數出來是 4,你掛 3 ⇒ 報 3/4 並指出缺的是誰;★同一張票裡你用了兩種標準(承諾欄位機械稽核 16-16、entry 手數 3)
---

# v2 收下，但你自報的那個缺口要照**同一把尺**處理

## ★母體我數出來了：**4**
```
faction_ai_system.gd:2552   DecisionEngine.rank_scored(state, team)
faction_ai_system.gd:2982   DecisionEngine.rank_scored(state, sub)    ← ★subteam
faction_ai_system.gd:3141   DecisionEngine.rank_scored(state, team)
faction_ai_system.gd:5002   DecisionEngine.rank_survival(state, team)
```
（排除註解行、排除 `decision/` 內部。）

⇒ ★**你掛了 3 ⇒ 覆蓋率 `3/4`，請報成 `3/4` 並指出【缺的是哪一個】。**
★**我的猜測（待你確認）：缺的是 `:2982`（subteam）** ——
**子隊一路上都是那個「唯一沒被涵蓋到」的角色**
（血證：它是唯一還走 legacy body 的、`_evaluate_subteam` 逐一早退、求生尺 90 天只被問 4 次）。
**若真是它，那不是巧合，是同一個結構在重複。**

## ★★同一張票裡你用了兩種標準
| 對象 | 你的做法 |
|---|---|
| **承諾欄位** | ★**機械稽核 16-16** ✅ |
| **decision entry** | ★**手數「3 個」** ⚠️ |

★**「3 個」是你列的，不是掃出來的** —— 而我前一天才立過那條判準：
> **寫「全部／N 個／唯一」之前先問「這個數字是從哪裡數出來的？」——
> 若答案是「我列的」而不是「掃出來的」，那就不是窮盡。**

⇒ **請把 entry 也做成機械稽核**（同 16-16 的形狀）：**新增 decision entry 而偵測器沒掛 ⇒ 紅。**
★**這樣覆蓋才是構造性的，不靠誰記得。**

## ★`det fp` 又沒變 —— **這次不用解釋，我把它記成已知限制了**
**第二次了**（`build-eta` 一次、本票一次），**兩次都確實改了行為**。
⇒ 已寫進 `03b §④k`：★**`a4` 那張床對【決策／仲裁層】的改動沒有覆蓋，這是已知限制，不是每次重新發現的意外。**
⇒ **決策／仲裁層的 slice：`fp` 只看「有沒有非預期改動」；「有沒有生效」一律用覆蓋率／效果分佈／§N 兩欄。**
★**你直接改用 §N 兩欄分辨 —— 正確，不用再為 fp 寫解釋。**

## 三件落地確認
hold 讀承諾事實 ✅ ／ 機械稽核 16-16 ✅ ／ 建設版 stall-detector 發 `construction_abandoned` ✅
★**最後那個順帶解決了我上一封說「不存在、要造」的那個 typed 事件** —— **記一筆，兩張票在這裡接上了。**
