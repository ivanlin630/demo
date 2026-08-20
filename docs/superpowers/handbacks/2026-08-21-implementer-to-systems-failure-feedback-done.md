---
from: implementer
to: systems
status: open
slice: failure-feedback
topic: 失敗反饋 Phase 0 DONE — 機制+接線表落地；★gate6 並排結果＝症狀 290→290 完全沒動、抑制量卻 64（正是 §2 警告的形狀）
branch: feat/failure-feedback
commit: 167d6922
---

# 執行失敗反饋機制 Phase 0（A1 五族的形狀）

## 落地內容（當通用機制做，非單點修）

| 件 | 位置 | 說明 |
|---|---|---|
| 儲存 | `TeamData.recent_failures` | `"<option>\|<target>" → {tick,count,ttl}`；隊層非 leader `p.memory`；**入 `state_fingerprint`**（直接因果態，同 `breed_progress` 判準）；`prune` 讀寫時清過期＝bounded |
| 折價 | `FailureMemory.mult()` | 連續乘數（非硬 cooldown）；freshness 線性衰減過期歸零；count 有上限；**clamp 到 FLOOR** |
| 掛法 | `decision_engine` util 迴圈 | 乘在 `_coeff` 之後、**survival/threat 加法 boost 之前** → 絕境仍壓得過折價（FLOOR + 加法 boost 雙保險，不得絕對否決）；**不新增 term 線** |
| 失效 vs 劣勢 | `record()` / `record_invalidation()` | 劣勢只折價；失效額外 `WorldEvents.emit("plan_invalidated")` 當 tick 喚醒。**kind 已登記 `FUNC_KINDS`**（照 R² 要求②，否則 T0 對帳守衛看不到新來源） |
| ★接線表 | `FailureMemory.OPTION_FAIL_KEY` | **A1 其餘四族照抄的就是這張表**：`{"買糧": ["買單","food"], "買料": ["買單","material"]}`。**未列的 option 恆 1.0 ＝ 對其餘決策空間零行為** |
| 示範族 | `order_system` 過期迴圈 | 買單到期未成交 → 記 `買單\|<res>`，**TTL＝`ORDER_LIFETIME`**（相對錨定，零新全域絕對天數常數）；★**劣勢非失效**：市場這次沒送到 ≠ 計畫不可行 → 只折價、不升 T0 |

★**一個形狀瑕疵我順手修掉**：原設 `INTENSITY 0.25 × CAP 3 = 0.75` 剛好讓乘數落在 `FLOOR 0.25` 上
→ **count 上限與 floor 重合＝上限變裝飾**。改 `INTENSITY 0.2`（cap 咬在 0.4、FLOOR 0.25 才是真安全網），兩個機制各司其職。

## ★★gate 6：症狀與抑制量【同一份報告並排】（peaceful_economy / seed 1337 / 30 天）

| | main | branch |
|---|---|---|
| `order.placed` | 357 | 356 |
| `order.filled` | **3** | **3** |
| **`order.abandoned`** | **290** | **290** |
| `failure.recorded.order_abandoned_buy` | — | **169** |
| **`failure.suppressed.買單`** | — | **64**（最深折價 0.595）|
| `decision.opt_chosen.買糧` | 36 | **29**（−19%）|
| `decision.opt_applicable.買糧` | 49 | 52 |

**★誠實判讀（這正是你 §2 + R² 加固要防的組合，只是方向跟預想的相反）**：
機制真的在動（169 記錄 / 64 次折價生效），被折價的 option 真的少被選（36 → 29），
但**症狀一動也沒動（290 → 290、filled 3 → 3）**。
根因：**掛單是機械的**——`tick_team_orders` 每 tick 依 surplus/shortfall 直接 `post_order`，**不經 util**。
∴ 折價只壓得到「**跑一趟市場**」這個決策，壓不到「掛單」本身；GATE-B（填單率 **3/357 = 0.8%**）一點沒被碰到。

- 只看 `order.abandoned` → 會下結論「這機制沒效」。
- 只看 `failure.suppressed` → 會下結論「有效、有在抑制」。
- **並排才看得出真相**：折價作用在**另一個地方**，病（貨到不了）完全沒動。

★**因此我要呈報一個 spec 假設與 code 現實的落差**：
spec T4 寫「折價下輪**同 res 掛單 util**」——但**掛單沒有 util**（全樹 `post_order` 4 個呼點都在 `order_system` 機械層）。
我把折價掛在**依賴市場取得該 res 的決策 option**（買糧/買料），因為那是唯一有 util 的對應面；
**沒有**去把 `post_order` 改成 util-gated（那會是新硬閘/新機制，超出本票且違「禁 fix」精神）。
若你要的是「真的少掛單」，那是另一張票的裁定（而且我建議先確認那是不是我們想要的——少掛單＝經濟更死）。

## 其餘 gate

| gate | 結果 |
|---|---|
| ①同因降分 + count 觸頂 | TDD：0.80 → 0.60 → 0.40，第 3 次後不再加深 ✔ |
| ②★FLOOR 不得絕對否決 | TDD：折價後 ≥ FLOOR，且絕境加法 boost（+1.25）壓過折價 ✔ |
| ③TTL 過期恢復 | TDD：過期 → 乘數回 1.0（非永久黑名單）✔ |
| ④失效升 T0 | TDD：`record_invalidation` → 該隊當 tick `pending_rethink` ✔；kind 已登記 ✔ |
| ⑤可觀測 | live：`failure.recorded.* 169`、`failure.suppressed.買單 64`、`failure.pruned 3`、最深折價 0.595 ✔ |
| ⑥並排報告 | 見上表 ✔（★結論是「症狀沒動」，不是「變好」——照你「不預設方向」的要求報）|
| ⑦det/憲法/headless/fp | det×3 **`8ab0ce8f2c8a1acc385cdce95e326c68`** 穩定 ≠ main `165399d1…` ＝ **intended-change** ✔；憲法 **PASS 74**；headless **0-new**（3 FAIL + 6 assert）✔ |

TDD `failure_feedback_test.gd` **14/14 PASS**。

## R6 保鮮期
- **commit** `167d6922`（branch `feat/failure-feedback`，基於 `origin/main` 3f196d44）／**日期** 2026-08-21
- **重跑（gate6 並排數字）**：
  ```powershell
  cd A:\GDS\demo\.worktrees\failure-feedback
  $env:GODOT_TIMEOUT='1200'; $env:PERF_SEED='1337'; $env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='30'
  $env:PERF_OUT='A:/GDS/demo/.worktrees/failure-feedback/ff_branch30.txt'
  .\tools\godot.ps1 --headless --script scripts/debug/failure_feedback_measure_bed.gd
  ```
  baseline 同指令但在 `.worktrees/convoy-baseline`（origin/main + 同一份 bed）。

## 未做（明確劃界）
- **其餘四族未接**（convoy 七站／JOIN／建設 `try_set` noop／trade market bail）——照 spec 只接一族。
  A1 接線時只需在 `OPTION_FAIL_KEY` 加一列 + 在該族失敗點呼 `record()`／`record_invalidation()`。
- **未附 specimen**：本票結論是**聚合帳 + TDD**（機制是否 fire、症狀是否動），沒有下「世界因此變好/變壞」的 behavior 因果宣稱。
  若你要據此裁 A1 方向，我可以補一支 specimen 走 QA 故事稽核。

## 下一站
`2026-08-21-systems-to-implementer-convoy-chase-diagnostic.md`（porter 追家 7 次 + T1 為何沒 fire，**只產答案不產修法**）——你標明排在本票之後，我接著開。
★另：`feat/specimen-lineage-scope` 還沒進 main，convoy branch 目前仍拿不到血緣修；你 merge 後說一聲我再 rebase 一次給 measurer。
