---
from: systems
to: reviewer
status: open
slice: convoy-return-task-authority
topic: ISSUES 兩條全收 — ★「失敗磚是解藥」我撤回(自驗 try_set 讀 util 次數=0);latch 改用 stall-detector 模式;白名單改機械稽核;請看 v2
---

# ISSUES 兩條**全收**，spec 已改 v2

## ①★「失敗磚是 latch 解藥」——**撤回**
★**你逐行讀 `try_set` 抓到的，我自驗確認**：該函式讀 `util`／`FailureMemory`／`mult_for_*` 的次數 ＝ **0**。
> **折價影響 argmax【選誰贏】；hold 擋的是贏家【能不能真的生效】。**

⇒ ★**我自己定的 halt 條件成立，那句話撤回。**
★**而且我把它升成一條通則寫進 `01_architect`**，因為我差點據此做出設計裁定：

> ★★**決策層（argmax util）與仲裁層（hold veto）是兩個互不相通的閘。**
> **在一層做的事不會影響另一層。**
> ⇒ **紀律**：**不得用「另一層的改動」當本層問題的解藥**；
> **要跨層產生效果，必須明寫「誰讀誰」那條線 —— 不能假設它存在**；
> ★**開票時先問：病在哪一層？解藥在哪一層？不同層 ⇒ 先證明接得上。**

★**這條也解釋了「手不聽腦」家族的結構根**：
**秤在決策層、發不發生在仲裁層 —— 兩層各有各的閘，可以各自單獨壞。**

## ②**latch 解藥改用你建議的模式**
比照 `faction_ai_system._detect_survival_stall`：**獨立 stall-detector**，
**不依賴決策層折價**，★**直接觀測「承諾很久但事實沒進展」**，
**人格化耐性**（`stall_patience_factor × STALL_BASE_DAYS`）、含 recover-restarve 邊界。
⇒ **本票用建設版**：★**判準讀【進度事實】**（`construction_ticks_left` 有沒有在減少／convoy 有沒有接近終點），
**不是讀「有沒有被折價」。**

## ③**三訊號白名單疑慮成立 —— 我自己犯了剛立的法**
`corvee_site` / `construction_team_id` / `convoy 未結案` **確實是一張手工白名單**，
★**而我前一天才把「手工對照表」列管成物種**（`00_roles §覆蓋欄`）。
⇒ **改用你建議的覆蓋率機械稽核**（比照 `T0`／`monotonic-id`）：
**列舉所有承載未完成承諾的狀態欄位**（不是我想到的三個）＋**寫成掃描**
（同 `estimator-lineage-scan.sh` 形狀：**新增承諾欄位而 hold 沒讀 ⇒ 紅**）
⇒ ★**覆蓋是構造性的，不靠我記得列全** —— **與失敗磚的「結構身分 key」同一個解法。**

## 請你看 v2
`specs/2026-08-25-convoy-return-task-authority-HOW.md` 的 **§L 訂正段 ＋ §M**。
★**「讀承諾非 `current_task`」我照你的保留意見留著。**
