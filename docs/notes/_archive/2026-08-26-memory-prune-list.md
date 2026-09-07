# auto-memory 清理清單

status: NOTE（非 owned doc）
from: 影子 blueprint session（不發信、不寫 memory、不消費信箱）
to: **systems**（auto-memory 單寫者；我不能動）
scanned_at: 2026-08-26 / `C:\Users\I12\.claude\projects\A--GDS-demo\memory\`
現況: **87 個 .md ／ 86 條索引**

---

## §1 機械垃圾 —— 零判斷，直接處理

### 1a. 死連結 ＋ 重複索引（刪 1 行）

```
MEMORY.md:67   - [補丁閘優先查](feedback-patch-gate-first.md)   ← 檔案不存在（連字號版）
MEMORY.md:56   - [補丁閘優先查](feedback_patch_gate_first.md)   ← 檔案在（底線版）
```
⇒ **刪 `:67`**。同名同義，且指向不存在的檔。

### 1b. 索引漏列（3 個檔）—— 現在是最糟狀態：佔空間、recall 看不到

| 檔 | 日期 | 主旨 |
|---|---|---|
| `feedback_freeze_which_field_check.md` | 2026-07-28 | 「凍結/停滯」要看**哪個欄位**凍＋其他生命徵象動不動 |
| `feedback_no_execution_scheduling_asks.md` | 2026-08-01 | 別為量測/驗證跑法的排程時間問用戶 |
| `project_food_flow_runway.md` | 2026-07-30 | 糧流感知 arc（runway-aware），WHAT 定案 + 用戶核可 |

⇒ **補索引，或確認沒用直接刪檔。** 二選一，不要維持現狀。

---

## §2 內容已被推翻 —— 優先於「已完成」，因為它會**誤導**

| 檔 | 行 | 它說 | 現況 | 處置 |
|---|---|---|---|---|
| **`feedback_pipeline_workflow.md`** | 22 | 「2026-07-06 全 pipeline…**auto-memory 單寫者改 orchestrator**」 | **2026-07-08 已切回多終端**（`00_roles:3`），單寫者回 systems | **刪** |
| **`feedback_workflow.md`** | 31 | v1 工作流 | `feedback_workflow_v2.md` 的 description **原文寫「取代舊 feedback_workflow」** | **刪** |
| `feedback_session_roles.md` | 28 | 「**四**角色…QA 驗收官（判決 + **release gate**）」 | **六**角色；QA release-gate **2026-07-09 已砍**（pass 權→藍圖） | **訂正**（不刪，角色表本身仍有用） |
| `project_orchestrator_machine.md` | 59 | langgraph 機器軌 | `00_roles` 判「**少用**」；`07_orchestrator_machine.md` 已瘦到 28 行 | **降成一行併別處** |

★ `feedback_pipeline_workflow` 是**最該先刪**的：它不只是過期，它記載的是一個**已經被 revert 的決定**，而且內容直接跟現行單寫者規則衝突。

---

## §3 已完成的 arc —— 照 `feedback_memory_hygiene` 的「完成 arc／consumed verdict 刪」

⚠ **兩個有尾巴，不能整檔刪**：

| 檔 | 行 | 狀態 | 處置 |
|---|---|---|---|
| `project_recovery_path_arc.md` | 26 | description 自稱 **COMPLETE**，三動詞全 merged | **刪**（先確認無尾巴） |
| `project_economy_arc.md` | 72 | 「plumbing+統一商業+coin+生產框架**全 merged**」**但**「剩 deal 側成交牆（死法②）＝**下個 arc**」 | **⚠ 保留那一行**，其餘刪 |
| `project_reverse_engineering_arc.md` | 32 | 「A2a/A2b/A2c-1/A2c-2 **全 merged**」**但** FA7/FA8 留 | **⚠ 保留 FA7/FA8**，其餘刪 |

---

## §4 疑似可併（要判斷，不急）

`feedback_mailbox_trigger` ／ `feedback_terminal_never_close_reply_systems` ／ `feedback_landed_needs_notify`
—— 三條都在講**信箱與送達**。而 2026-08-25 的殭屍事件（`fb9f4687`「after three failed handback deliveries」）
剛好給了它們一個共同的、更準的骨架：

> **活著（lock 心跳）≠ 前進（RUNNING）≠ 送達（管道活著）**

⇒ 若要合併，用這句當標題比三條散著好。**但這是新增判斷，不在本清單的「純刪」範圍。**

---

## §5 執行摘要

| 動作 | 數量 |
|---|---|
| 刪索引行 | **1**（`:67` 死連結） |
| 補索引（或刪檔） | **3** |
| 整檔刪 | **3**（`pipeline_workflow` / `workflow`(v1) / `recovery_path_arc`） |
| 保尾巴後刪 | **2**（`economy_arc` / `reverse_engineering_arc`） |
| 訂正內容 | **1**（`session_roles`：四→六角色、QA gate 已砍） |
| 降級併入 | **1**（`orchestrator_machine`） |

⇒ **87 檔 → 約 82 檔**，而且**移除三處會誤導的過期資訊**。

---

## §6 為什麼這件事值得做

`feedback_memory_hygiene` 自己寫著：**「無自動 GC，靠單寫者 prune」**。
⇒ 沒有人定期跑，就只會單向長 —— 跟 `docs/` 那邊的病同源（見 `9e3816f9`）。

而 memory 的傷害比 doc 更直接：**它每個 session 開頭自動注入**，過期條目不是「查到錯的」，是**被主動餵給每一個角色**。

★ 本清單裡最毒的是 `feedback_pipeline_workflow` —— 它記著「單寫者是 orchestrator」，
而現行規則是「單寫者是 systems」。**一條記憶跟現行流程規則直接衝突，且每 session 都被注入。**
