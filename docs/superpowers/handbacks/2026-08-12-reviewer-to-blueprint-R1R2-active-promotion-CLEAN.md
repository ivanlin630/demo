---
from: reviewer
to: blueprint
status: consumed
topic: "[R①硬數據驗+R②判決=CLEAN+1輕量必查項] 主動升匿名spec——R①三靶皆坐實且證據比預期更強:靶①(promotion機制是否綁死succession)親grep generate_for_team(全scripts確認至少6處獨立caller(event_system.gd:58succession/player_command_system.gd:216玩家_action_promote_anon手動拔擢/faction_ai_system.gd:582settler派遣/faction_ai_system.gd:3594facility-builder顧問/population_system.gd:70/headless_test多處)——這函式從來就不是succession專屬,是single-source-of-truth的通用晉升原語,已有player手動觸發路徑(_action_promote_anon)證明AI-side deliberate觸發只是第7個caller,機制風險低;靶②(夠格候選有無資質訊號)親讀anon_cohort.gd確認4真實tier(平民/新兵/老兵/菁英,TIER_ORDER)+person_generator.gd:33 PROMOTE_TIER_WEIGHT(0.2/0.6/1.5/3.0)偏高tier加權挑選+:110 _apply_promotion_skills依src_tier灌技能——非同質、真有可挑依據,現有機制已在用這套訊號;靶③(loyalty/values哪來)親讀generate()內archetype hi_v/lo_v randf_range賦值(:75-80)確認被提者拿到獨立genuine人格值非複製繼承——未來忠誠風險賭注結構上成立(跟這session已審過的defect_util/_faction_stay_benefit是同一套人格驅動機制,promoted個體日後可能走一樣的路);R②:①genuine非crank親確認generate_for_team內部呼AnonTierSystem.kill_random真的扣anon pool、代價機械強制非裝飾;②結構上不會跟機械誤升bug混——promote是『既有team.add_member加成員』非『spawn新孤立subteam』,跟unified-dispatch那個bug完全不同機制路徑,不會重新引入孤匿名或誤觸;③④⑤皆WHAT層級待HOW定案/spec已明講optional texture parked+量測禁預設,合理;★輕量必查項(呼應iii spec②那條同款要求,非新發現而是一致套用同標準):領主提拔util秤要求HOW demonstrate bounded非crank(絕境被迫提/野心樂提/多疑吝嗇提三種人格分化要真的從util競秤湧現,非簡化成『named不夠就必然觸發』的變相自動補滿,跟§1『禁自動補滿』字面矛盾的risk點在HOW公式定案時才會現形,要求HOW階段自證);判決=CLEAN+1輕量必查項→鎖→systems寫HOW"
---

# R①+R②判決：主動升匿名 spec — CLEAN + 1輕量必查項

## R①（硬數據，anon 4×over-claim 血淚教訓——三靶全查，證據比預期更充分）

**靶①：promotion 機制是否綁死 succession？——不是，是通用原語，證據比預期更強**

親 grep `generate_for_team(` 全 `scripts/`，確認這是一個**至少 6 處獨立 caller** 共用的 single-source-of-truth 通用晉升原語：
- `event_system.gd:58`（succession，`on_leader_death` 觸發）
- `player_command_system.gd:216`（**玩家手動** `_action_promote_anon`，已有現成手動拔擢動作、`headless_test.gd:8469` 有測試）
- `faction_ai_system.gd:582`（settler 派遣領隊指定）
- `faction_ai_system.gd:3594`（facility-builder 顧問）
- `population_system.gd:70`
- 多處 `headless_test.gd` 測試用例

這函式**從來就不是 succession 專屬**。玩家側早就有一條手動觸發路徑（`_action_promote_anon`）證明「拔擢一個 anon」這個動作本身完全可行、獨立於 succession 之外——AI 側 deliberate 觸發只是第 **7 個** caller，機制可承載性風險低，這不是要新建的能力，是複用已經被多方驗證過的既有原語。

**靶②：「夠格匿名候選」有無資質訊號？——有，4-tier 真實差異化**

親讀 `anon_cohort.gd` 確認 `TIER_ORDER = [平民, 新兵, 老兵, 菁英]` 4 個真實 tier（讀 `encounter_system.gd`/`training_system.gd` 的用法看，這是戰鬥經驗累積出的老兵化梯度，非隨機標籤）。`person_generator.gd:33` `PROMOTE_TIER_WEIGHT := {"平民":0.2, "新兵":0.6, "老兵":1.5, "菁英":3.0}` 偏高 tier 加權挑選、`:110` `_apply_promotion_skills` 依來源 tier 灌技能下限——anon 群體**非同質**，「較有能力的匿名」這個挑選依據是真實存在的，不需要新增資料結構，現有機制（succession/player 拔擢）就已經在用這套訊號。

**靶③：被提者的 loyalty/values 哪來？——親讀 generate() 內 archetype 賦值，genuine 獨立人格**

親讀 `generate()`（person_generator.gd 內，:75-80 archetype 區塊）確認被提者的 `p.values[v]`（含義氣/信義/野心等）是按 archetype 的 hi/lo 範圍 `rng.randf_range(...)` **獨立生成**，不是從 anon 群體某個平均值複製過來的扁平副本。這代表「未來忠誠風險」這個賭注框架結構上成立——promoted 個體拿到的是跟這 session 已經審過很多輪的 `defect_util`/`_faction_stay_benefit` 同一套人格驅動機制會吃的真實值，日後真的可能走上跟其他角色一樣的叛離/忠誠曲線，不是裝飾性敘事。

## R②

**①genuine 非 crank——代價機械強制，坐實**：親讀確認 `generate_for_team` 內部呼 `AnonTierSystem.kill_random(...)` 真的把 1 個 anon 從 tier-pool 扣掉——「脫離可替換勞力池」這個代價是機械強制發生的，不是文字宣稱的裝飾。

**②不會跟機械誤升 bug 混——結構上路徑完全不同**：這個 promotion 是「既有 team 呼 `state.add_member` 加一個成員」，不是「spawn 一個新的孤立 subteam」——跟 unified-dispatch spec 那批要除掉的機械誤升 bug（leaderless subteam 被 succession 誤觸）走的是完全不同的機制路徑，不會重新引入孤匿名或誤觸風險，這條邊界守得住。

**③④⑤**：named-scarcity 分化/成本 texture/前後對照量測，spec 已明講交給 HOW util 公式定案 + optional texture 明確 parked + §5 量測禁預設 payoff——這些都是 WHAT 層級該留給 HOW/量測的部分，合理。

**★輕量必查項（呼應 iii spec 那輪②的同款要求，非新發現，是一致套用同一標準）**：領主提拔的 util 秤——要求 HOW 明確 demonstrate 這是真的 bounded、非 crank：絕境被迫提/野心樂提/多疑吝嗇提這三種人格分化必須是從 util 競秤真的湧現出來的結果，不能簡化成「named 不夠就幾乎必然觸發」這種變相的自動補滿（那會跟 §1 自己寫的「禁自動補滿」字面矛盾）。這條 risk 只有在 HOW 定案具體公式常數時才會真的現形，這輪 WHAT 層級看不出違反，但要求 HOW 階段自證公式在低 util 情境下確實不會提拔、在多疑/窮領主情境下確實持續缺人手。

## 判決
**CLEAN + 1輕量必查項 → 鎖 → systems 寫 HOW。** 這輪三個 R① 靶的證據比預期更充分（promotion 機制不只是「理論上可以另路觸發」，是已經有 6 個獨立 caller 在用的成熟原語；tier 差異化跟人格獨立生成都有扎實 code 支持），設計方向乾淨、跟機械誤升 bug 的邊界劃得很清楚。唯一必查項是跟 iii spec 那輪同款的「genuine util 秤需要 HOW 階段自證 bounded」標準要求。
