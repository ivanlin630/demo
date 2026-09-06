---
from: implementer
to: systems
status: consumed
slice: S4b-event-wake
topic: S4b 事件瞬醒短路 + 意圖遷 T3（覆蓋對帳 210 格）
---

## 做了什麼（① + ②，兩件同時落地）

**①九個閘位加 is_pending 短路**，形狀照抄 `faction_ai_system.gd:3211 _should_reeval`（`is_pending` → 記一筆 → 當作可以跑），沒發明第二種寫法。

| 支別 | 閘位 | actor scope |
|---|---|---|
| GOAL | `reaction_system.gd` | person → `person.team_id` |
| LADDER | `faction_ai_system.gd`（ambition） | team |
| STRATEGIC | `strategic_ai_system.gd`（早退式） | faction |
| ALLIANCE | `strategic_ai_system.gd` | faction |
| BETRAY | `faction_ai_system.gd` | faction |
| INFRA | `faction_ai_system.gd` | faction |
| FACTION_UPDATE | `faction_ai_system.gd` | faction |
| INDEP_INFRA（INFRA 第二站） | `faction_ai_system.gd` | team |
| INTENT（②） | `faction_ai_system.gd` | faction |

**②意圖併遷 T3**：`INTENT_CADENCE` → `DecisionTier.C_INTENT`（舊值寫在 `decision_tier.gd` 同一行註解，回滾仍是改一個檔）。順手把裸 `current_tick + CADENCE` 換成 `CadenceStagger`（S3 已判過的同批到期病根）。

## 三件必須先講的（不是順利的部分）

### (a) `pending_rethink` 是 team-id 索引，而五支是 faction 級
加了 `WorldEvents.is_pending_faction(state, faction)`。**這不是第二套機制**——它讀的是同一份 `pending_rethink`，只是換 scope。語意寫死：**任一成員隊被喚醒 ⇒ 該勢力本 tick 重想**。

### (b) INTENT 不能照抄別支「種開場那批」——被測試打回來的
別支都在 `next_tick == 0` 時先種一個錯開的 tick。我照抄，`headless_test._test_strategic_reads_ladder` 直接紅：`應該有 intent, got={ }`。
根因：`f.intent` 初值是空字典而下游每 tick 都在讀，種下去 = 開局最多 3 日沒有意圖。
⇒ INTENT **刻意不種**：預設 0 ⇒ tick 0 全體 fire 一次，之後立刻各自錯峰散開。理由寫在 code 裡。

### (c) LADDER 有一個【已知不對稱】，沒有遮蓋
別支的重排寫在閘旁邊（`if _due:` 才排），所以事件喚醒不動 cadence 時鐘。
**LADDER 的重排寫在 callee 裡**（`ambition_ladder.gd:126/156`）⇒ 事件喚醒的那一次**也會**把 cadence 往後排。
沒有伸手進 callee 壓它：那等於在 `AmbitionLadder` 外面長出第二條排程路徑，而「只能有一條排程路徑」正是 S3 整支的前提。
**待你裁**：接受這個不對稱，還是要把 LADDER 的重排搬出 callee（那是另一票）。

## 誠實界限（不准當成 T0 做完）

- **不能宣稱「T0 完成」**：LOD-same-body / 輪詢退場那一半沒做。這一刀是「只加不減」——cadence 輪詢照舊，pending 只是額外喚醒來源。
- **210 格只涵蓋【已宣告的 30 個 kind】**：S4a 的界限照舊——能證沒漏掉任何一個有名字的，證不了世界上沒有別的 burst。
- **執行軌有結構性上限**：閘裡沒有 kind 判斷（`is_pending` 只問「這隊有沒有被標記」不問誰標的）⇒ 執行軌**分不開** kind A 和 kind B 的醒。它證的是「醒得起來」；「每個 kind 都能叫醒」靠靜態軌（零 kind 過濾）+ emit 的 subjects 都是隊 id。

## 數字

落地：`docs/measurements/2026-08-28-s4b-wake-coverage-warring_states.txt`（win=600 正本）
＋ `...-win60.txt`（保留，見下方 (d)）
重跑：`$env:BED_CONFIG='warring_states'; $env:BED_WIN='600'; $env:GODOT_TIMEOUT='3600'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\old-growth --script scripts/debug/s4b_wake_coverage.gd`

### ④ 覆蓋對帳：核心 **210/210 全部 woken**，NOT_WOKEN=0、no_run=0、no_actor=0
（全 270 格＝9 支×30 kind 也是 270 woken。actor 母體 person=137 team=67 faction=8 indep=26）

### ③ 靜態：閘上 kind 過濾 = **0 處** ⇒ 預設全通、零例外，沒有需要寫理由的格子
補一條靜態證據（票沒要求但缺了會有洞）：**13 個 `WorldEvents.emit` 呼叫點全部傳隊 id**
（`belief_system.gd:208` 的 `obs_id` 是 `state.team_intel` 的觀察者隊；`message_system.gd:58`
的 `_subjects` = 發起隊 + params 隊 id）⇒ 沒有哪個 kind 因為 subjects 型別錯而永遠標不到人。

### ②/B 對比（注射 vs 陰性對照，同樣 600 tick 窗）

| 支別 | 注射 event（最小/中位/最大，30 kind） | 對照 event | 倍數 |
|---|---|---|---|
| STRATEGIC / ALLIANCE / BETRAY / INFRA / FACTION_UPDATE | 82 / 87 / 88 | 7 | ~12× |
| INTENT | 72 / 87 / 88 | 7 | ~12× |
| GOAL | 110 / 123 / 139 | 30 | ~4× |
| INDEP_INFRA | 286 / 329 / 360 | 7 | ~47× |
| LADDER | 748 / 927 / 1092 | 21 | ~44× |

**INTENT 的 event-woken > 0**（票明列的驗收條件）：對照 7、注射 72–88。

### ① 死水三欄（A 相 7200 tick 正常跑，未注射）

| 支別 | event | both | cadence | 合計 |
|---|---|---|---|---|
| GOAL | 595 | 25 | 63 | 683 |
| LADDER | 303 | 0 | 19 | 322 |
| STRATEGIC | 111 | 0 | 4 | 115 |
| ALLIANCE | 111 | 0 | 4 | 115 |
| BETRAY | 72 | 0 | 4 | 76 |
| INFRA | 72 | 0 | 4 | 76 |
| FACTION_UPDATE | 72 | 0 | 4 | 76 |
| INDEP_INFRA | 103 | 0 | 16 | 119 |
| INTENT | 72 | 0 | 12 | 84 |

**每一支都是 event >> cadence（GOAL 595:63、LADDER 303:19、勢力五支 72:4）。**
⇒ 這一刀之後，七支的重評**主要由事件驅動**，週期只是兜底。
★這也是 S3 把它們拉到 T3（3 日）之所以還能反應的機制解釋——不是「反應變慢了但可接受」，
而是「慢的那條路現在只佔 6–20%」。

### (d) 為什麼保留 win=60 那份
第一版窗長取 1 tick，結果 262/270 NOT_WOKEN。**那是床錯不是 code 錯**：宿主 pass 粒度
（LOD／各 loop 走訪節奏）讓多數 actor 那 tick 根本沒被走到，而「沒被走到」和「醒不了」
長得一模一樣。win=60 那份留著當量化證據：GOAL 27 no_run / 3 woken = 10%，
正好 = 窗長 60 ÷ `FAR_ZONE_INTERVAL` 600。win=600 之後 no_run 歸零。

### B 相世界狀態的誠實界定
B 相是**刻意過載**的：窗內每 tick 對全部隊重注 pending。所以那 210 格答的是
**「叫得醒嗎」**，不是「正常世界裡多常醒」——後者是 ① 那張表。

## docs 我沒動（owner 不是我）

T0 事件瞬醒是**跨系統規則**（哪些支必須接事件、事件喚醒不重排 cadence）⇒ 該寫進 `invariants.md`，
而那份的 owner 是你，不是我。同理 `progress.md`。兩份都沒動，內容備在這封信裡等你落。

順帶一筆既有漂移（不是我造的、也沒改）：`message_system.gd:50` 註解寫「全 17 型別」，
`WorldEvents.MESSAGE_KINDS` 實際 **18** 個。

## 既有 tap 的獨立佐證（票明文要求：用既有 reeval.event，不加新 tap）

`reeval.event`（無後綴）＝ `faction_ai_system.gd:3213 _should_reeval` 本來就有的那顆，
量的是**決策支**（`_decide_unified`），**這一刀完全沒碰它**。

| | 對照（不注射，600 tick） | 注射（1 kind × 600 tick） |
|---|---|---|
| `reeval.event` | 23 | **525** |

落地 `docs/measurements/2026-08-28-s4b-legacy-tap-evidence.txt`。
★講清楚為什麼還是加了 `reeval.event.<支>`：那七支在這一刀之前**一個喚醒路徑都沒有**，
沒有既有 tap 可重用；而票同時要求的死水**分支別**三欄也非有後綴不可。

## 閘（全綠）

| 閘 | 結果 |
|---|---|
| bed-parse-gate | PASS：305 支床全部載入成功 |
| constitution_gate | **PASS**（sites=74, removed=1） |
| bare-tick-gate | **PASS**：母體 168，NEEDS_HUMAN=**0**（母體從 169 掉到 168 = INTENT 那顆裸 `current_tick + CADENCE` 被換掉） |
| headless Q1 跑完了嗎 | **YES**（`[TEST-SUITE-COMPLETE]`） |
| headless Q2 新失敗 | 實測 8 vs baseline 7 —— 唯一多的是 **g1a 礦村未鑄幣**，那是進來前就在的未歸屬項，與這一刀無關 |
| `--import` | 已跑（新 `class_name` 無新增，但 `DecisionTier` 加了 static func） |
| fp（warring_states, 1000 tick） | `f7f09077…` → **`2ede39b144a18f99f951af7aebbce821`**，**三跑 byte-identical** |

**fp 該變、且是哪一種**：①讓七支在事件到達的當 tick 就重評（以前要等 cadence）⇒
決策時序真的變了 ⇒ 世界分岔。這是**預期分岔**不是不確定性——三跑同 fp 已證。
`tap_wake` 是 `Probe.enabled` 閘掉的（關掉零成本、不耗 RNG），`is_pending` 純讀字典。

## commit

- `8aeb1ff9` ①②本體 + 覆蓋床 + win=60/win=600 兩份對帳

## 下一步問你的兩件

1. **LADDER 的不對稱**（重排在 callee）——接受，還是開票把它搬出來？
2. **輪詢退場（A2）**要不要接著排？現在的數字站得住：正常世界裡七支的 event:cadence
   已經是 595:63 / 303:19 / 72:4，**週期那條路只佔 6–20%**。
   ★但我不會自己把它讀成「可以砍輪詢了」——那 6–20% 是誰、砍掉會漏掉什麼，沒量過。
