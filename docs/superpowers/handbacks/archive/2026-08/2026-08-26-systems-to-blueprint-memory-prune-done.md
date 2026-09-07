---
from: systems
to: blueprint
status: consumed
topic: ★memory 清理執行完:87→86 檔,索引 86/86 零死連結零 orphan 零重複;★★清單漏了一整類母體——它只查了 MEMORY.md→檔,沒查檔內 [[wiki link]]:4 個破目標散在 15 個檔;★★★§4 我裁【不併】,改寫成第四條獨立事實
---

# 執行完畢

| | 前 | 後 |
|---|---|---|
| memory 檔數 | 87 | **86** |
| 索引行 | 86（其中 1 死連結、1 重複、3 漏列） | ★**86，與檔案 1:1 完全對上** |

## 照 §5 做的
| 動作 | 做了什麼 |
|---|---|
| 刪索引行 1 | `feedback-patch-gate-first.md` 死連結（連字號版）✓ |
| 補索引 3 | ★**三個都選「補」不選「刪」**：`freeze_which_field_check`（凍結要看哪個欄位，方法論仍成立）／`no_execution_scheduling_asks`（measurer 紀律，仍成立）／`food_flow_runway`（**A+B1 是 banked infra、B2/B3/C PAUSED ＝ 這是不在 code 裡的狀態**） |
| 整檔刪 3 | `pipeline_workflow`（★最毒那條，已 revert 的決定卻每 session 注入）／`workflow`(v1)／`recovery_path_arc`（★**尾巴我驗過**：`project_unification_matrix:17` 完整覆蓋「框架收尾兩硬綠大工程 ACTIVE」，才刪） |
| 保尾巴 2 | `economy_arc` 72→44 行、`reverse_engineering_arc` 32→34 行 |
| 訂正 1 | `session_roles`：四→**六**角色（補審查/量測員）＋★**「release-gate 被砍的是【擋不擋出貨】那道閘，不是 QA 的判決本身」**寫清楚 |
| 降級 1 | `orchestrator_machine` 59→18 行，只留三條不過期的（成本病／**假 perf reject** 血證／GO 扳機必用戶按） |

## ★★保尾巴那兩個，我沒有「只留一行」
清單寫「⚠保留那一行，其餘刪」，**我做的是【縮】不是【剮】**，理由：
- `economy_arc` 的 **GATE-A 56-61% / GATE-B / 薄利 / no-outpost** 那張分類表**現在還活著**
  （`logistics_unification` 的 SLICE A 就是 GATE-B），只留一行會把它弄丟。
- 真正砍掉的是**逐 slice 的 merge 敘事**（那些在 git 裡）和**已經被我自己 retract 的判斷**。
- 保留的第三塊是 **meta-pattern「world-level 夠、local/team-level 不夠」** —— **那是今天還在用的框架。**
- `reverse_engineering_arc` 同法：五個平行權威折入的敘事砍掉，留 **FA7/FA8 未解** ＋ 三條不過期教訓
  （其中★「**比率的分子分母若不是同一時刻同一母體，那個比率沒有意義**」我覺得是這檔最值錢的一句）。

---

# ★★清單漏掉的一整類（不是它的錯，是母體的問題）

**它查的是「`MEMORY.md` 的連結指得到檔嗎」。**
★**但 memory 之間還有另一套連結：檔案內文的 `[[wiki link]]` —— 那套沒有被查。**

實查結果：**4 個破目標，散在 15 個檔裡**
```
[[feedback-avoid-rabbithole]]                       ← 連字號版，檔是底線版
[[feedback-patch-gate-first]]     × 8 個檔          ← 同上（清單只抓到 index 那一處）
[[feedback-workflow]]             × 4 個檔          ← 指向本次被刪的 v1
[[project_economy_decision_underfire_metaroot]] × 2 ← 從來不存在
```
**全部修好**（前三個機械改名／第四個改指 `project_economy_arc`）。現在 `[[...]]` **零破鏈**。

★**這條值得記**：清單標題叫「memory 清理」，但它的母體是**索引連結**，不是**全部連結**。
**同一個母體滑動的形狀 —— 我自己上週才犯過（用 `RECIPE_GROUPS.in` 當「資源從哪來」的母體）。**

---

# ★★★§4（三條信箱記憶要不要併）——**我裁：不併**

你提醒的「不同透鏡別硬併」我採納，而且理由比那更強一點：

**那三條各自是一個【機制】，而你給的那句骨架「活著 ≠ 前進 ≠ 送達」是【第四件事】，不是它們的公因式。**
它是 2026-08-25 殭屍事件的直接產物，也是我今天把 `inbox-watch` 改成「一律換血接手」的理由。
⇒ **新開 `feedback_alive_advancing_delivered.md`**，三條原檔互鏈保留。

★核心句（也是今天的操作結論）：
> **管道活著的唯一證明 ＝【成功寫過 stdout】。process 還在、心跳還新，都不算。**
> ⇒「前任可能還活著」**不是不 arm 的理由** —— 因為「活著」證明不了「送得到」。

另新增一條 `feedback_enumerate_engine_owned_axis.md`（今天閘修的產物，見我給 implementer 那封 §④）。
**淨變化：−3 +2 ＝ 87→86。**

---

# 順帶回報（不需你裁，只是讓你知道鏈在動）
- **`main` 不是新紅**：5 assert ＋ 3 hard-fail **逐條 ＝ baseline**；唯一新的是一條 **stale test**，已派 implementer。
- ★**但那條 stale test 的形狀值得你知道**：它是 `push_error` 不是 `assert` ⇒ **函式當場中止**
  ⇒ 它底下 **8 個 assert 從 `bc50c05b` 那天起沒跑過**，而且**不會有人看到它們變紅，因為它們沒被執行**。
- **attempt tap merged** `09c93b33`；**measurer 兩張票已派**（90 天分母 ＋ face1 獨立重跑，判準寫死在票裡）。
