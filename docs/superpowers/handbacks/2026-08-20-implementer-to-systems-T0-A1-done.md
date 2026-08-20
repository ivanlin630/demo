---
from: implementer
to: systems
status: consumed
topic: "[T0-A1 事件匯流排+瞬醒 done·branch feat/t0-event-bus @619ab04c·T1 WorldEvents(emit/is_pending/consume_and_clear、★升序消費、★單 tick 清空掛 tick 結尾兩個出口)·T2 三類掛點全掛(①18 型別經 emit_message 單 chokepoint 一次掛齊②五個函式 chokepoint 含★_execute_betrayal 受害方③三個狀態跨線新增偵測點)·T3 cadence OR pending + ★在途不想·T4 對帳守衛 t0_hookpoint_gate(18/18 PASS、★注入假 type→FAIL＝有牙)·gate 全綠:TDD 9 條 ALL PASS、det×3 fp=a5d25c38a4696d26cdef2acd8ae16db6、constitution 75、headless 0-new·★⑥量化照實報(對齊 7 日窗、序列跑):wall/day 98.0→133.1ms(+35.8%)、決策 2732→3938(+44.1%)、event 喚醒 443、cadence 843→529、skip_in_transit 11、t0.emit 2805]"
branch: feat/t0-event-bus
commit: 619ab04c
---

# T0-A1 事件匯流排 + 瞬醒 done

## T1 匯流排
`scripts/simulation/world_events.gd`：`emit(state, kind, subjects)` → `state.pending_rethink[team_id]=true`；`is_pending`；`consume_and_clear`（**依 team_id 升序**消費、禁 Dictionary 迭代序）。
**★單 tick 清空**掛在 **tick 結尾的兩個出口**（encounter 路 + 一般路）→ 不分批、不跨 tick 存活＝`pending_rethink` 不入 fingerprint 的正當性基礎。
（記帳：我第一版誤放在 tick **開頭**＝pending 會跨 tick 存活，違反你明文要求，自查時改掉。）

## T2 掛點（三類、不挑食）
1. **訊息型**：`emit_message` 是單一 chokepoint → **18 個 type 一次掛齊**（`order_` 動態前綴展開成 `order_buy`/`order_sell`）；subjects ＝ 發起隊 + params 內出現的隊 id。
2. **函式 chokepoint 五個**：`start_combat`（雙方）／`on_leader_death`／`_on_team_extinct`（**同格目睹 + 同 faction 成員**）／`erase_teams`（同批死者的 faction 同僚）／**`_execute_betrayal`（受害方 `ally_team`）**。
3. **狀態跨線（新增偵測點）**：`famine_crossed`（`famine_days` 0→正）／`labor_crisis`（共址 PRODUCE 隊 `food_runway` 跌破 `LABOR_CRISIS_FOOD_DAYS`）／`intel_arrived`（belief **首見該目標** 或 **已知位置改變**）。

## T3 決策迴圈
`cadence 到期 OR pending`（只加不減）。**★在途不想**：移動中的 travel task 隊不因 cadence 重評（`reeval.skip_in_transit`），**但事件喚醒在最前面**＝被襲/情報/餓線照樣瞬醒；到達後恢復 cadence。

## T4 對帳守衛
`scripts/debug/t0_hookpoint_gate.gd`：掃 production 的 `emit_message` type 集合 vs `WorldEvents.MESSAGE_KINDS` → **18/18 PASS**；**注入假 type → 掃到 19 vs 表 18 → FAIL**＝**有牙**。
**誠實邊界**（照 spec §5 寫進檔頭）：只結構性保護 ①；②③ 無結構性保護——**背叛正是從那個缺口漏的**。

## gate
| gate | 結果 |
|---|---|
| ①事件瞬醒真發生 | TDD 對照：cadence 未到 → 不重評（舊行為）；`emit` 後**當 tick 可思考** |
| ②★守衛有牙 | 假 type 注入 → **FAIL**（19 vs 18） |
| ③順序穩定 + 單 tick 清空 | 升序 `[1,2]`；`consume_and_clear` 後 pending 空、不殘留；**det 三跑 byte-identical** `a5d25c38a4696d26cdef2acd8ae16db6` |
| ④在途不想 | 移動中不因 cadence 重評、**被襲仍瞬醒**、到達後恢復 |
| ⑤constitution / headless / fp | **75** / **0-new** / **intended-change** |
| **⑥★量化（照實報）** | 對齊 **7 日窗**、**序列跑**（避免第二個 Godot 進程的 contention）：**wall/day 98.0 → 133.1 ms（+35.8%）**、**決策次數 2732 → 3938（+44.1%）**；細分：`reeval.event` **443**、`reeval.cadence` 843→**529**、`reeval.skip_in_transit` **11**、`t0.emit` **2805** |

**⑥ 的讀法**：兩者都增＝**符合這一刀的定位**（加反應性、不是省算力）。值得注意的是 `cadence` 從 843 **降到 529**——那是「在途不想」真的少跑了一批空轉重評；但 `event` 443 補回來還有餘，淨值仍是 +44%。**這組數字就是 A2（輪詢退場）的對照基線**。
量測坑記帳：前兩次我跑出 +21.6%／+70% 都是**假的**——一次是 branch 檔還在寫（7 天 vs 10 天不同窗），一次是舊 process 的尾巴寫進我剛刪的檔案。改成**全新檔名 + 序列跑 + 同 ADHOC_TICKS** 才得到可比的 +35.8%。

地基 KEEP。**待命中。**
