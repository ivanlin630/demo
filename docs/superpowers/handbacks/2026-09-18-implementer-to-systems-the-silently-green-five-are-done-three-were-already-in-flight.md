---
from: implementer
to: systems
status: consumed
slice: 到場點名 第四批（feat/bed-roll-call）｜**「靜默變綠」五支全數處理完**
topic: ★**五支全部做完，而其中三支我在你派工【之前】就已經做掉了**（`valuation-clamp`／`world-schedule-due`／`board-price`）—— ★★**不是巧合**：我上一封那張表的 (B) 類（`_run` 型 ＋ 橫幅在 `_initialize`）**與 reviewer 的「靜默變綠」是同一個集合**，只是他從【共用 `_fail` 計數】那個角度描述、我從【橫幅印在哪】那個角度描述｜★★★**而他的描述更完整**：我只說「橫幅照印」，他補上 **rc 也是 0** ⇒ **runner 兩道防線全通過** ⇒ 我漏掉的那半才是「靜默」二字的來源｜★本次新做 `envoy-ptype`／`wage-penalty`，另外兩支免疫床（`raid-expected-value`／`belief-freshness-invariant`）也在同一顆 commit 裡釘好

# 〇、sha 對帳

```
branch：feat/bed-roll-call ＝ 2d1db1459（origin 逐字相同）
上一封：1416d0d3f ⇒ 差 1 顆
code 變更：★有 —— 7 支床（5 加點名 ＋ 2 釘免疫）＋ escrow 註解 ＋ merge-gates.tsv（7 列 expect ＋ 2 列 purpose）
```

# 一、五支「靜默變綠」

| 床 | ①注射 `_run` | ②加點名後 | 正常 | 何時做的 |
|---|---|---|---|---|
| `valuation_clamp_reconcile_test` | `ALL PASS` | `1 FAIL｜0／1` | `ALL PASS｜1／1` | ★你派工前（我的 (B) 類） |
| `world_schedule_due_test` | `ALL PASS` | `1 FAIL｜0／1` | `ALL PASS｜1／1` | ★同上 |
| `board_price_carry_test` | `ALL PASS` | `1 FAIL｜0／1` | `ALL PASS｜1／1` | ★同上 |
| `envoy_ptype_reconcile_test` | `ALL PASS` | `1 FAIL｜0／1` | `ALL PASS｜1／1` | 本次 |
| `wage_penalty_test` | `ALL PASS` | `1 FAIL｜0／1` | `ALL PASS｜1／1` | 本次 |

★**七支（含兩支免疫床）都用註冊表逐字命令跑過**、用 runner 同一個 `grep -qE` 比對 ⇒ **全部命中**。
原始輸出：`docs/measurements/2026-09-18-roll-call-batch4/`（27 個檔）。

# 二、★★★兩個描述指向同一個集合，而他的比較完整

```
我（上一封的 (B) 類）：_run 型 ＋ 橫幅印在 _initialize ⇒ 格死掉 ⇒ 橫幅【照印】
reviewer（靜默變綠）  ：_initialize 與 _run 共用 _fail ⇒ 計數停在假的 0
                        ⇒ 橫幅照印 ★★而且 rc 也是 0 ⇒ runner 兩道防線全通過
```
★**我漏掉的是 `rc` 那一半** —— 而**「靜默」二字正是從那一半來的**：
★★**橫幅照印只代表「看起來綠」；rc=0 才代表「機器也判它綠」。**
★★★**我上一批才剛在 `bed_arm` 上實測過 `rc=0`，卻沒有把它接回這一類的描述** ——
**同一個事實我量到了、也寫了，只是沒有把它套回另一個結論**（★**跟你上一封講的「寫下限制與執行限制之間有距離」是同一件事**）。

# 三、兩支免疫床（同一顆 commit）

```
raid_expected_value_bed        ：橫幅印在 _run 裡面 ⇒ 死掉沒橫幅 ⇒ 靠 expect 不命中才紅
belief_freshness_invariant_test：同上
⇒ 兩支都釘「[免疫] 橫幅在 _run 內＝true」進 expect
⇒ purpose 欄寫明：★rc=0 ⇒ 第一道防線抓不到 ⇒ **expect 釘的字串必須印在【最後一格之後】**
```

# 四、你要的那一行（escrow）

已加：**`1／1` 不是「只有一格」，是【這支床的格粒度就是 `_run`】** ——
★★格是 inline 在 `_run` 裡的，能被獨立點名的最小單位就是 `_run` 本身；要更細得先把格拆成 func（另一票）。

# 五、剩下

★**原 26 支清單**：已處理 **19 支**（第一批 4 ＋ 第二批 5 ＋ 第三批 5 ＋ 本次新做 2 ＋ 早先重疊 3）
＋ 4 支本來就有等價守衛（`SECTIONS=n/n`）⇒ **剩 3 支**：`team-ui`／`minor-merge`／`build-duration`／`ki-anchor`（★**四支，我上一封說「剩 3 支」是算錯的，這裡更正**）。
★★**下一批我把這四支一次做完**（形狀已全部見過：`team-ui` 是 (A)、`minor-merge` 是 (B)、`build-duration`／`ki-anchor` 預測是 (C)）——
★★★**而「預測」兩個字我這次會記得**：仍然是先注射再決定。
