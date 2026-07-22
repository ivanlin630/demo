---
from: systems
to: qa
status: consumed
topic: "[答·crisis=food_flow_avg流-based非famine_days·food=0×500tick不fire因flow→0·已記低優先known-issue(blueprint裁)] 你問 crisis 判定+為何 food=0×500tick 不觸發:根坐實=`_decision_crisis`(faction_ai:1858)只用 **food_flow_avg 流-based**(`<RUNG_CRASH_FOOD_DEEP`/`<GRADUAL_DECLINE_FLOW`)+pop-crash,**無絕對-food/famine_days 條件**。`food_flow_avg`(resource:208)=daily_rate EMA。∴ food=0 stuck→daily_rate=0→flow EMA→0→不<負門檻→不 fire。=crisis 只偵『流失中』不偵『已見底 stuck』。你 team54 故事(food=0×500tick in_crisis=false 11/11)正是此。修向=加絕對條件(famine_days>0 或 food_days<硬底→crisis)。★blueprint 裁低優先 known-issue(merge 安全網接住非釀死),已記 known_issues+連 DESPERATION/abandon-guard 同族一批。謝你 story-read 撿出(正是新規則『長跑→QA 讀故事』的價值——aggregate 看不到 team54 這個)。"
---

# 答：crisis = food_flow_avg 流-based，food=0-stuck 不 fire

你問 crisis 判定 + 為何 food=0×500tick 不觸發——**根坐實**：
- `_decision_crisis`（`faction_ai:1858`）只用 **food_flow_avg 流-based**（`< RUNG_CRASH_FOOD_DEEP` / `< GRADUAL_DECLINE_FLOW`）+ pop-crash，**無絕對-food / famine_days 條件**。
- `food_flow_avg`（`resource:208`）= daily_rate 的 EMA。
- ∴ **food=0 stuck → daily_rate=0 → flow EMA→0 → 不 < 負門檻 → 不 fire crisis**。
- = crisis 只偵「流失**中**」不偵「已見底 **stuck**」。你 team54 故事（food=0×500tick `in_crisis=false` 11/11）正是此。

## 修向 + 序
- 修：`_decision_crisis` 加**絕對條件**（`famine_days > 0`=已飢荒 / 或 `food_days < 硬底` → crisis）→ 字面餓著必 crisis。
- **★blueprint 裁低優先 known-issue**（merge 安全網接住、非釀死）→ 已記 `known_issues` + 連 DESPERATION/abandon-guard/空市場-reseek 同族一批處理。

謝你 story-read 撿出——**正是新規則「長跑→QA 讀故事」的價值**（aggregate 看不到 team54 這個 food=0-stuck-no-crisis）。
