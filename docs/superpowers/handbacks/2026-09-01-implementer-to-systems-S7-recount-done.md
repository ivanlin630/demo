---
from: implementer
to: systems
status: open
slice: S7-seven-disease-recount
tier: probe
topic: ★S7 盤點交件 b825e20f（已 push）——★★production 改動【0 行】;★★★七條有【五條】與抄本不符，而抄本錯過的地方我另列六處；優先序依「語意是否隨根靜默改變」排，不依醜的程度
---

# ★①產出：`docs/measurements/2026-09-01-s7-seven-disease-recount.txt`

★**`git diff --stat -- scripts/simulation scripts/data scripts/ui` = 0 行**（只盤不修，可驗）。

# ★★②七條現況（三欄，★第③欄是重點）

| 病 | ①現況 | ②現值 file:line | ③★換根後語意 |
|---|---|---|---|
| **7** | ★還在，**病大小 10×→60×** | `ui_logic_test.gd:77` `TICKS_PER_DAY := 24.0` | 真值 1440 ⇒ 該床算的天數是真值 **60 倍**；★**它是 local const，沒有任何東西比對它與真值** |
| **6c** | ★還在（**A 群唯一真漂的**） | `health_system.gd:12` `HP_REGEN_PER_TICK = 0.5` | 真語意是**每次 cadence 回 0.5**；換根改變每日呼叫次數 ⇒ ★**每日回復量靜默改變，而名字說它是 per-tick**（命名騙人＋語意漂移**疊加**） |
| **2** | ★**變形**（不是消失） | `need_hierarchy.gd:19` `α=0.25`；唯一呼叫端 `decision_context.gd:686` | 抄本的「near/far 不等價」**前提已不成立**（只剩一條路）；★★**但 α 仍是隱含時間常數**：平滑半衰期 = f(α, 呼叫頻率) ⇒ 換根時**平滑窗真實時長靜默改變** |
| **3** | ★還在，`:525`→**`:896`** | `goal_resolver.gd:896` `MOVE_TILES_PER_DAY = 2.0` | 物理真值 `MOVE_TICKS_PER_HEX 240` ⇒ **6 hex/天**；誤差 2.5×→**3×**。★★**標為【接線病】非數值病**（照你先裁：改成 6.0＝手抄物理常數，禁） |
| **5a** | ★還在但**已導出** | `sim_runner.gd:300` / `:346` `% (TICKS_PER_DAY/4)` | 分母是根 ⇒ 自動跟隨；★病是**重複兩處**，改一處會漏另一處 |
| **5e** | ★還在（**三處**，窮盡確認） | `faction_ai_system.gd:2736 / 3355 / 5429` | `DECISION_CADENCE / 4` 已導出；★病是**「危機想快 4 倍」這個決定寫了三遍** |
| **6a/6b/5c** | ★還在但**不隨根變** | `encounter_system.gd:10`／`trade_valuation.gd:54`／`day_night_system.gd:10-12` | 命名誤導／量係數叫 TICKS／一天內比例。★★**6b 的危險點**：若有人「順手乘 6 對齊新根」，儲備量放大 6 倍而**測試不會紅** |
| **1 / 4 / 5b / 5d / 5f** | ★★**可移除** | — | 見下 |

# ★★★③抄本錯過的地方（★下次會再錯的地方）

```
1. 病1 已修一半（sim_bridge 在 S2 收掉；★sim_runner 全檔已無 turn 概念）
2. 病4 標「[?] 須核對」⇒ ★答案是【不必 ×day_fraction】：產線只在 NEAR pass，
   沒有兩條路 ⇒ 不等價問題不存在；而每日產量估算已從根導出
3. 病5b player_trade 1000t ⇒ ★已改用 TimeScale.hours(100)，已從根導出
4. 病5d 月長 30 ⇒ ★★抄本把【刻意不縮放的曆法結構】誤判成病
5. 病5f「2 天 timeout 6 處」⇒ ★窮盡搜索 480/2880：production 只剩一行【註解】
6. ★★★病7「food_ledger_bed 鏡常數 ×2 處」⇒ 實查那兩顆是
   FOOD_PER_PERSON_PER_DAY / PROVISION_DAYS ——【per-day 語意、不隨根縮放】
   ⇒ 與 ui_logic_test 那顆【不是同一種病】，抄本把兩種混成一條
   ⇒ ★而這正是你抽驗時打掉的那個「×2 處」—— ★★同一族的錯又出現一次
```

# ★★★★④優先序（依第③欄，★不依醜的程度 —— 這是你要的排法）

```
高 ★語意隨根靜默改變：6c HP_REGEN_PER_TICK ／ 7 ui_logic_test(60×) ／ 2 α 的隱含時間窗
中 ★接線錯且誤差隨根放大：3 MOVE_TILES_PER_DAY（★接線病，修法是改接線不是改數值）
低 ★重複但已導出（改一處會漏）：5a(2 處) ／ 5e(3 處)
最低 ★不隨根變，純命名/美觀：6a ／ 6b ／ 5c
可移除：1 ／ 4 ／ 5b ／ 5d ／ 5f
```

# ⑤紀律（照你 ③ 逐條）
- ★**窮盡搜索**：全域 grep，**無 head、無 glob 截斷**；計數先 `wc -l` 再列項。
- ★★**只盤不修**：production diff **0 行**（可驗）。
- ★★★**抄本與現況衝突以現況為準**，且**衝突已明列六處**（見③）。

# ⑥我沒做的
★**沒有修任何一條** —— 包含病3（你已先裁修法形狀，但那是另一票）。
★★**沒有把「可移除」那五條從抄本刪掉** —— 抄本是 spec，owner 是你。
