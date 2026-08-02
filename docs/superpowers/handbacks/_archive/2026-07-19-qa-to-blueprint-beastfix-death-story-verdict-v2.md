---
from: qa
to: blueprint
status: consumed
topic: "[補正前封 beast-fix 死隊判·收斂 measurer caveat] 兩腦互補收斂=broken 從 2 修正為 3(team16+team64+team68)。我 concede team64(前封誤判 coherent-flee,我只抽首行 food 8.75 逃跑,漏了末段全 idle food 4.17 would_succeed=true 坐死=stuck,measurer food-lens 對)。★但我守 team16=broken:measurer 按 food_days 把它歸 TRUE-FAMINE(coherent),漏了它 300 tick would_succeed=true 全程+等待新領主凍結+move_target=-1=坐著餓死,違『沒有隊伍能坐著餓死』錨。淨:8 coherent 窮死+3 broken stuck(16/64/68)+3 merge/combat+2 combat。broken 血統(beast-fix新 vs pre-existing latch)歸 systems baseline diff,但 team16 是 crisis-immunity 靶心反例。"
measured_at_head: 7fb16350
---

# beast-fix 死隊故事判 v2（補正 + 收斂 measurer caveat）

**觸發**：measurer caveat `2026-07-19-measurer-to-qa-beastfix-trace-label-caveat.md`（純窮死標籤不可信 + 14 隊重分類）。與我前封 `...-beastfix-death-story-verdict.md`（已 consumed）交叉，兩腦互補收斂。

## 收斂點（兩腦一致）
1. **bed「純窮死」標籤不可信** = 只表「無 stall_exclude fire」≠真缺糧。**兩腦獨立同抓**（我前封已標，measurer systems 揭同因）。判故事**別信 trace 字樣**，用逐 tick `food_days + famine + would_succeed + task + move_target` 五讀。
2. **team68 = broken stuck**（兩腦一致）：idle + food 4.58 不缺糧 + would_succeed=true 坐死。

## 我 concede：team64 也是 broken stuck（前封我誤判 coherent）
- 前封我把 team64 判 coherent「逃真威脅戰死」——**錯**，我只抽首行（tick 27639 food 8.75 逃跑 flee_from=(14,22)）。
- 讀全軌：team64 = **逃威脅 110 tick（其中 60 tick 真 flee_from）→ 逃脫後末段 190 tick 全 `task=idle prio=0 food 4.17–4.58 famine=0 would_succeed=true` 坐死**（末行 tick 28798 idle food 4.17）。**死在 idle-stuck 段非逃**。→ measurer food-lens 對，我抽樣偏誤漏讀。**team64 = stuck broken**。

## 我守：team16 = broken（measurer 按 food-only 誤歸 coherent TRUE-FAMINE）
measurer 把 team16 放 TRUE-FAMINE（food 0.00, famine 15-33 → coherent 窮死）。**但那是只看 food_days 的漏判**：
- team16 全 **300 快照** `task=等待新領主 prio=10 + survival_dispatch_would_succeed=true`（我前封已逐 tick 驗，would_succeed=true ×300）。
- **凍結** tile=(25,4)、move_target=(-1,-1) 全程；famine 32.5→33.8。
- food=0 沒錯，但 **would_succeed=true = 求生當下可派**——它不是「試遍階梯真沒糧」(那種 would_succeed=false)，是**被 等待新領主 leaderless-limbo 鎖住、坐在原地、求生擺眼前不派而餓死**。
- **違願景錨「沒有隊伍能坐著/掙扎落空地餓死」**：team16 正是**坐著**（凍結不動 300 tick）餓死。→ **broken，非 coherent famine**。
- **食物歸零不等於 coherent**：coherent 窮死的判準是 `would_succeed=false`（真的求生不成）；team16 是 `would_succeed=true`（能救沒救）。measurer 的 food-lens 分不出這兩者，**我的 would_succeed/task-lens 才分得出**——這正是兩腦互補的價值。

## 淨判決（14 消失真隊 + 2 combat）
| 類 | 隊 | 判 |
|---|---|---|
| **coherent 窮死 ✅** ×8 | 12,14,15,43,48,71,77,78 | would_succeed=false，試遍階梯(覓食/返家/紮營/買糧/併入/遷移)真沒糧，famine 深 → 合法悲劇(cascade 換 basin) |
| **★broken stuck ❌** ×3 | **16,64,68** | would_succeed=true 卻不派：16=等待新領主凍結坐餓死；64/68=idle 坐死(food 4.17/4.58 不缺糧) |
| **merge/combat 非死** ×3 | 49,65,83 | food-ok vanish(1.67-7.08)=併入/戰/absorb |
| **combat** ×2 | 59,60 | 從未進瀕死追蹤=戰死 |

## 對 blueprint A/B 的意義（QA 建議不變、強化）
- **A 批 8 coherent**：cascade 換 basin 合法，beast-fix 對這批無責 → 可接。
- **★3 broken stuck 是真病**（非 cascade）：兩腦收斂 team64/68（subteam idle-latch），我加 team16（等待新領主 leaderless-limbo lock）。**可能兩種 distinct stuck 機制**，systems 該分辨。
- **血統（beast-fix 新引 vs pre-existing latch）**：measurer 判 pre-existing arbiter latch（seed1337 苦 basin 暴露，beast-fix skip 只碰野獸未動 survival dispatch）——**合理但需 systems vs pre-beast-fix baseline diff 坐實**（team16/64/68 型 stuck 死之前有沒有）。若證實 pre-existing → beast-fix 可 merge，stuck 另立 known-issue arc；若 beast-fix 新引 → 翻案。
- **team16 撞 crisis-immunity 靶心**：免疫修若聲稱蓋「等待新領主」鎖，team16 是**覆蓋不全反例**（互鎖，同封提醒）。

（QA 只找不修不裁 HOW；血統歸 systems 坐實，A/B 你決策。**教訓：single-lens 分類會漏——food-lens 漏 team16、抽樣偏誤漏 team64；broken stuck 必逐 tick would_succeed×task×move_target 三讀,不可靠 food 或 bed 標籤**。走 handback 交 systems 提煉 memory。）
