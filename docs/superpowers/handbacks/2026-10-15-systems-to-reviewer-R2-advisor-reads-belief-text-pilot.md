---
from: systems
to: reviewer
status: open
slice: 顧問讀信念＋文本外置試點（玩家可見批，游標即選中之後）
topic: R² 請審 spec 2026-10-15-advisor-reads-belief-and-text-externalization-pilot-HOW｜重點三處：①UI 直呼改成玩家指令（今天問顧問會耗全域 RNG）②雜訊走雜湊不擲骰＋人格偏移③兩支守衛對帳兩檔
---

# 請審
spec：`docs/superpowers/specs/2026-10-15-advisor-reads-belief-and-text-externalization-pilot-HOW.md`

## 我最想被挑的地方
1. **§1a 改走指令**：問顧問因此要推進 1 tick（與打聽同形）。這算不算玩家可感的退步？我判不算：今天 UI 直呼會改世界亂數，是更大的病。
2. **§1b 五情境的讀法**：有沒有哪一格偷讀了真值。特別是 diplomatic 的 feud 邊：我讀的是自家成員對目標**隊長** person_id 的邊，而目標隊長是誰本身可能是真值。若你判這是 god-view，改成只讀 `known_reputations`。
3. **§1c 雜訊**：`observation_noise01` 的 salt 用 target_id，無目標的情境用負數情境序。兩種 salt 會不會撞到別處同一個 (tick, observer, target) 三元組，使兩個系統的雜訊相關？observer 是 advisor 的 **person** id；既有呼叫點用的是**隊** id，id 空間是否重疊要你核。
4. **§2d 鍵對帳**：靠「`"advisor_` 字面只准出現在 TEXT_KEYS 那一行」的結構 grep。它會不會被字串拼接繞過而恆綠？
5. **§2c**：刪兩個常數改一支函式。既有床有沒有直接讀 `ObserverEventText.RES_NAMES`／`TeamUiHelper.RESOURCE_NAME` 的？（我沒 grep 床。）

## 現況斷言我已讀過的
advisor_system.gd 全檔、text_bank.gd 全檔、sim_bridge.gd:573、text_ui_main.gd:3438-3470 與 3618-3685、player_api_mapper.gd:220 與 915-990、belief_system.gd:40-280、path_system.gd:277。
「主動警報三組零呼叫者」是 grep `advisor_food_critical|advisor_enemy_approaching|advisor_faction_betrayed` 全 scripts，只命中 text_bank.gd。
