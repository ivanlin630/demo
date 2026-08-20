---
from: systems
to: implementer
status: open
topic: "[dispatch breed funnel characterization(★evidence-only、禁 fix、blueprint 明令先報)·背景:QA 故事審坐實 reaction.breed 整 12 個月【零次 fire】;先前以為的人口成長其實是 world-gen minor 存量按 population_system:13-22 每月機械保底 +1 出清、耗盡即永久靜止=【12mo 零繁殖】是新頭號經濟症·★要什麼:temp 漏斗 tap 把 reaction_system:191-215 的生育 gate【逐道計數】,答『到底哪一道在擋、擋掉多少』——①safe(needs.safety>0.7)②fed(needs.food>0.7)③surplus(t.food_flow_avg>BREED_FLOW_MIN=1.2 持續淨盈餘)④minor<cap(population×0.25)⑤_breed_balance>0(該隊 named 中兩性皆有、單性→0 直接不生)⑥最後 randf<chance·每道記【進來幾人次/被擋幾人次】,跑 peaceful_economy 與 warring 各一短窗(1-2 個月足夠、禁長跑)·★重點懷疑(補丁閘優先查家族、但【不要先入為主】):BREED_FLOW_MIN=1.2 是死常數絕對門檻,而本輪世界 57-62% 隊 daily_rate 為負→這道可能結構性擋掉幾乎所有人;⑤單性也可能在小村(named 1-3 人)結構性歸零·但真相要數字說,別預設·★另外量一項:有多少隊【連迴圈都進不去】(team.population 或 named 為 0/該隊沒有 named person)·★禁止:改任何門檻/常數/邏輯(這是 evidence-only slice、blueprint 明令先報再議);temp tap 用完 revert·出:每道 gate 的通過/攔截數 + 兩 config 對照 → handback to:systems(我彙整後呈 blueprint 裁 WHAT)·地基KEEP"
---

# dispatch：breed funnel characterization（★evidence-only、**禁 fix**）

**背景**：QA 故事審坐實 `reaction.breed` **整 12 個月零次 fire**。先前以為的人口成長，其實是 **world-gen minor 存量**按 `population_system:13-22` 每月**機械保底 +1** 出清、耗盡即永久靜止 → **「12mo 零繁殖」是新頭號經濟症**。

**★要什麼**：temp 漏斗 tap 把 `reaction_system:191-215` 的生育 gate **逐道計數**，回答「**到底哪一道在擋、擋掉多少**」：
1. `safe`（`needs.safety > 0.7`）
2. `fed`（`needs.food > 0.7`）
3. `surplus`（`t.food_flow_avg > BREED_FLOW_MIN = 1.2` **持續淨盈餘**）
4. `minor < cap`（`population × 0.25`）
5. `_breed_balance > 0`（該隊 **named 中兩性皆有**；單性 → 0 直接不生）
6. 最後 `randf < chance`

每道記「**進來幾人次／被擋幾人次**」，跑 `peaceful_economy` 與 `warring_states` **各一短窗**（1–2 個月足夠、**禁長跑**）。

**★重點懷疑（補丁閘優先查家族——但不要先入為主）**：`BREED_FLOW_MIN=1.2` 是**死常數絕對門檻**，而本輪世界 **57–62% 隊 `daily_rate` 為負** → 這道可能結構性擋掉幾乎所有人；⑤單性也可能在小村（named 1–3 人）結構性歸零。**但真相要數字說，別預設。**

**★另外量一項**：有多少隊**連迴圈都進不去**（該隊沒有 named person）。

**★禁止**：改任何門檻/常數/邏輯（evidence-only、blueprint 明令**先報再議**）；temp tap 用完 revert。
**出**：每道 gate 的通過/攔截數 + 兩 config 對照 → handback to:systems（我彙整後呈 blueprint 裁 WHAT）。地基 KEEP。
