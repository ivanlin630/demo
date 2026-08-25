---
from: systems
to: implementer
status: consumed
slice: convoy-return-task-authority
topic: ★v2 CLEAN,可動工 — 三件定案;★另補一條 acceptance:「被卸除次數下降」有兩種原因必須分開報,否則誤擋正當退場會長得像成功
---

# v2 **CLEAN**，動工

reviewer 親讀 spec §L/§M ＋ **親驗 `_detect_survival_stall` 實碼**
（`faction_ai_system:5148`，`stall_patience_factor × STALL_BASE_DAYS` 存在、與我聲稱一致）⇒ **可轉你。**

## 定案三件
1. ★**hold 讀「未完成的承諾」這個【事實】**，不再只讀 `current_task` 這個**會被 `release` 清掉的代理**
   ⛔ **59 個 caller 不改**；**`release-first` idiom 保留**（正當退場照走）
2. ★**latch 解藥 ＝ 獨立 stall-detector**（比照 `_detect_survival_stall` 的建設版）：
   **讀進度事實**（`construction_ticks_left` 有沒有在減少／convoy 有沒有接近終點）、
   **人格化耐性**、**含 recover-restarve 邊界**。
   ⛔ **不要指望失敗磚順便解決** —— 那條我撤回了（**決策層與仲裁層互不相通**）。
3. ★**承諾欄位【不要用白名單】**：**列舉所有承載未完成承諾的狀態欄位 ＋ 寫成掃描**
   （同 `estimator-lineage-scan.sh` 形狀：**新增承諾欄位而 hold 沒讀 ⇒ 紅**）⇒ **覆蓋構造性。**

## ★★我另外補了一條 acceptance（§N），**這條很容易踩**
hold 變硬後「**施工中隊被卸除的次數**」**一定會下降** —— **但下降有兩種原因**：
| 原因 | |
|---|---|
| ★**②「我想換 task」被擋住** | ✅ 正是要的 |
| ★**①正當退場也被誤擋** | ❌ **是回歸**（latch 前兆） |

★**只看總數，兩者長得一模一樣。**
⇒ ★**必須分兩欄報**：**①合法退場次數（不該下降）** ／ **②被 hold 擋下的次數（該上升）**。
★**若①也跟著掉 ⇒ 立刻紅燈。**
（同族：`05_acceptance §margin 稀釋` —— **「症狀計數變 0」要問是修好還是容忍度變寬**。）

**主指標**（margin 轉不動的）：**convoy ＝ RETURN 期間 `task=運輸` 佔比**；
**建設 ＝ 開工後「工地被自己隊放掉」的事件數（且與①分開）**。

## ★latch 監測（假設不靜默）
**stall-detector 的觸發率要當常設 tap**：
**長期零觸發、同時①合法退場也掉 ⇒ latch 已發生而沒人知道 ⇒ 紅燈。**
★**「解藥有沒有在運作」本身要可觀測** —— 不能只寫在 spec 上假設它會動。

## 順序
失敗磚那條照常走（等 measurer 驗收）。本票可以並行，**但兩張都動 arbiter 附近，merge 前請告訴我先後。**
