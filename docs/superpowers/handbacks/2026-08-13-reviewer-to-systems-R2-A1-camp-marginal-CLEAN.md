---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] A1 camp_marginal HOW-detail(正規化命門)——禁crank核心命門親算驗證:camp_drive=clampf(camp_marginal/daily_need,0,CAMP_CAP)×urgency,camp_marginal本身已含maxf(0,_inflow_est(est)−forage_floor)這層anti-crank——0/daily_need=0、clampf(0,0,CAMP_CAP)=0,除法+clamp這層正規化不會把0變非0、山地(或低regen地)瀕餓不紮這個結構性anti-crank性質在正規化後親算確認保留,非在正規化這層悄悄漏出crank縫;感知鐵律親讀decision_context.gd確認has_farmable_tile(:52,由_find_unowned_farmable_tile:291-292算)+food_days(:10,167算)皆現有既存欄位,camp_target_est建構點全部複用已存在的DecisionContext基礎設施非發明新未驗證管道;親讀_find_unowned_farmable_tile(faction_ai_system.gd:4643-4653)確認只掃團自己腳下鄰近7格world.tiles地形/ownership(地理/世界資料非讀他隊live state)+明確排除mountain地形——這代表『瀕餓+山地』這個anti-crank情境有雙重防線(has_farmable_tile gate本身在純山地環境就會false、camp_marginal自己的maxf(0,·)對低regen地也會收斂到0),兩層獨立都收斂到0非單一脆弱防線;審點(4)term正規化vs改領主側硬gate的架構選擇——親自給design opinion非迴避:應該維持term(soft-weight)非改gate,理由=跟這session一路de-patch硬persona-gate(F1 MINING_GREED_THRESHOLD/DESPERATION_DAYS entry gate personify)+promote_util系列一路要求bounded-非-gate的既定doctrine完全一致,改成硬marg>0 gate會是開倒車,把紮營跟其他survival-class option的正常argmax競爭關係拆掉、退化成二元able/unable判斷,喪失『瀕餓時camp值中等但買糧值更高該選買糧』這類真實trade-off的表達力;判決=CLEAN(含明確design recommendation:term非gate)→dispatch implementer+measurer bounded四象限gate(mountain→0 machine-demonstrate)"
---

# R②判決：A1 camp_marginal HOW-detail — CLEAN

## 禁 crank 核心命門——正規化這層親算驗證，非只信「合理」二字

`camp_drive = clampf(camp_marginal/daily_need, 0, CAMP_CAP) × urgency`——systems 自己點名「正規化是 crank-vector 所在」，我沒有輕輕放過。`camp_marginal` 本身已經含 `maxf(0, _inflow_est(est) − forage_floor)` 這層 anti-crank（山地/低 regen 地 → 負值或近零 → clamp 到 0）。往下走正規化這層：`0 / daily_need = 0`（除以任何正數，0 還是 0）；`clampf(0, 0, CAMP_CAP) = 0`（clamp 的下界本來就是 0，不會把 0 抬高）。**除法+clamp 這層正規化不會把 0 變非 0**——山地/瀕餓不紮這個結構性 anti-crank 性質，正規化後親算確認**保留**，不是在這一層悄悄漏出一條 crank 縫。

## 感知鐵律——親讀確認 camp_target_est 全部複用既有 DecisionContext 欄位，非發明新管道

親讀 `decision_context.gd` 確認 `has_farmable_tile`（`:52`，由 `_find_unowned_farmable_tile`（`:291-292`）算）跟 `food_days`（`:10`，`:167` 算）**皆現有既存欄位**——`camp_target_est` 的建構點全部複用已經在跑、已經審過的基礎設施，不是憑空冒出來的新資料來源。

親讀 `_find_unowned_farmable_tile`（`faction_ai_system.gd:4643-4653`）確認只掃團**自己腳下鄰近 7 格**的 `world.tiles` 地形/ownership（讀的是地理/世界資料，非另一隊的 live state）、且**明確排除 mountain 地形**（`:4651`）。這代表「瀕餓+山地」這個 anti-crank 情境有**雙重防線**：純山地環境下 `has_farmable_tile` gate 本身就會是 false（camp_drive 在 term 頂端直接返回 0，根本不會走到 `camp_marginal` 那段計算）；而對非純山地但低 regen（如森林）的情況，`camp_marginal` 自己的 `maxf(0,·)` 會收斂到接近 0。**兩層獨立防線都收斂到 0，不是單一脆弱防線**。

## 審點(4) term 正規化 vs 改領主側硬 gate——給明確 design opinion，非迴避

**建議維持 term（soft-weight），不要改成硬 `marg>0` gate。** 理由：這跟這 session 一路 de-patch 硬 persona-gate 的既定 doctrine 完全一致——F1 那輪把 `MINING_GREED_THRESHOLD` 硬 gate 改連續 weight、把 `DESPERATION_DAYS` entry-gate 人格化；`promote_util` 系列一路要求 bounded-非-gate（need-driven 不 fire、非硬檻卡人）。改成硬 `marg>0` gate 會是開倒車——把紮營跟其他 survival-class option（買糧/覓食/投靠）的正常 argmax 競爭關係拆掉，退化成二元 able/unable 判斷，喪失「瀕餓時 camp 值中等但買糧值更高、該選買糧」這類真實 trade-off 的表達力。維持 term 正規化才是跟本 arc/整個決策引擎架構一致的整合方式。

## 判決
**CLEAN（含明確 design recommendation：term 非 gate）→ dispatch implementer + measurer bounded 四象限 gate（mountain→0 machine-demonstrate=anti-crank 真閘）。**
