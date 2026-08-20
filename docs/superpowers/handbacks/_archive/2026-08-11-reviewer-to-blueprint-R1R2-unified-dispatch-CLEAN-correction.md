---
from: reviewer
to: blueprint
status: consumed
topic: "[R①硬數據驗+R②判決=CLEAN+1較重必查項(herald分類/機制不符)+輕量確認項] 統一派遣模型spec——★核心發現:grounding表把herald跟scout/care-scout/rescue歸同一『leaderless anon-alone→dispatch_anon_messenger→succession誤升』drain家族,但親grep全faction_ai_system.gd『dispatch_anon_messenger(』只命中3處(:2062scout/:5137care-scout/:5231rescue),herald(_try_herald_side:1994起)完全沒呼這個函式——親讀herald實際機制(:2019 _detach_one_anon直接AnonTierSystem.remove_anon扣team人口+:2035 state.in_transit_letters.append純data dictionary非TeamData)證實herald從不spawn leaderless subteam,結構上不可能觸發faction_ai:784succession誤升(那機制要求真有一個leader_id==-1的TeamData坐在state.teams裡才會被784掃到),herald的1anon成本是設計上的sunk cost(code comment自己講'sunk,不recall')——這代表herald被歸類進『4個孤匿名drain點』是citation錯,它結構上更接近migrant那類『permanent genuine』非drain-bug,要求HOW前重新界定herald到底要不要照這個spec的§2/§3改(若要改=需要全新機制非『補leader給既有dispatch_anon_messenger call』因那個call根本不存在)、還是該從fix scope移出另案處理;其餘3drain點(scout:2045/care-scout:5110/rescue:5231)+succession安全網(faction_ai:784 if leader_id==-1零guard)+機械升格來源(person_generator:103 kill_random+promote)+群派遣named-led pattern(sub_leader_id模式)+migrant(_try_migrant_side:1727→dispatch_anon_migrants:1727)皆親讀逐字坐實;R②:①③零重複guard設計(succession安全網本身不用改、機制是『修後scout/care-scout/rescue從不誕生leaderless→784從未誤觸』非『784加reason字串guard』,真leaderless succession繼續走同一路徑不受影響)判斷合理親自推導確認;②④世界規則+記名稀缺約束genuine非crank成立;⑤§3歸隊對group dispatch不破(spec明確排除不動這5個);判決=CLEAN+1較重必查項(herald分類錯需HOW前釐清)+其餘皆坐實→非halt(3/4靶+succession+promotion+group-pattern+migrant全對,只1/4靶分類有誤)但這條必查項優先度高於一般輕量項,建議HOW開工前先解決非邊做邊發現"
---

# R①+R②判決：統一派遣模型 spec — CLEAN + 1較重必查項

## R①（硬數據非 inference，anon 真源錯 4 次血淚教訓——全靶親讀）

### ★核心發現：herald 被歸錯類，機制跟其他 3 個「孤匿名 drain 點」不同

grounding 表把 herald 跟 scout/care-scout/rescue 一起歸進「leaderless anon-alone → `dispatch_anon_messenger` → succession 誤升」這個 drain 家族。親自 grep 全 `faction_ai_system.gd` 的 `dispatch_anon_messenger(`，**只命中 3 處**：`:2062`（scout）、`:5137`（care-scout）、`:5231`（rescue）。**herald（`_try_herald_side`，函式從 `:1994` 起）完全沒有呼叫這個函式。**

親讀 herald 實際機制：
- `:2019` `_detach_one_anon(team)` → 直接呼 `AnonTierSystem.remove_anon(team, tier, 1)`，扣掉 team 的人口計數，**沒有任何 spawn**。
- `:2035` `state.in_transit_letters.append({...})` → append 一個**純 data dictionary**（`origin_team_id`/`target_lord_id`/`payload`/`current_pos`/`spawn_tick`/`timeout`/`speed` 這些欄位），**不是 `TeamData`**。

這證實 herald **從不 spawn 一個 leaderless 的 subteam 實體**。`faction_ai:784` 的 succession 誤升機制要求「真有一個 `leader_id==-1` 的 `TeamData` 坐在 `state.teams` 裡才會被 `:784` 的迴圈掃到、誤觸 `on_leader_death`」——herald 的送信機制連這個前提都不成立，**結構上不可能觸發跟 scout/care-scout/rescue 一樣的 succession 誤升 drain**。而且 code 自己的 comment（`:2019`）就寫「sunk, 不 recall」——這 1 anon 是**設計上的沉沒成本**，不是意外誤升導致的漏失。

**這代表 herald 被歸進「4 個孤匿名 drain 點」是 citation 錯**——它結構上更接近【permanent genuine】的 migrant 那類（設計上的永久成本），不是【DRAIN 點】那類（bug 導致的意外漏失）。**要求** HOW 開工前先釐清：herald 到底要不要照這個 spec 的 §2（依重要性選記名）/§3（全員歸隊）去改？若要改，需要的是一個**全新機制**（讓 herald 也走一個真正 spawn 的、帶記名的傳信實體），而不是「補一個記名領隊給既有的 `dispatch_anon_messenger` call」——因為那個 call 對 herald 根本不存在，沒東西可補。也有可能重新盤點後發現 herald 這 1-anon-sunk-cost 本來就是 genuine 設計、該跟 migrant 一樣從 fix scope 移出——這個判斷該在 HOW 動工前做，不是邊做邊發現。

### 其餘全數 file:line 坐實
- **scout** `_try_scout_side:2045`（func def 精確對得上）→`:2062` `dispatch_anon_messenger` 親讀確認。
- **care-scout** `_dispatch_care_scout:5110`（func def 精確對得上）→`:5137` `dispatch_anon_messenger` 親讀確認（這輪 spec 引用的位置跟上一輪 care-loop scout de-patch 那份 spec 審過的同一個函式，位置沒有漂移）。
- **rescue** `:5231` 親讀確認 `SubteamSystem.new().dispatch_anon_messenger(...)`。
- **succession 安全網** `faction_ai:784`：親讀 `if team.leader_id == -1: EventSystem.new().on_leader_death(state, team)`——確認零 subteam/phantom guard，逐字對得上「無 phantom guard」的宣稱。
- **機械升格來源** `person_generator.gd:103`：親讀 `AnonTierSystem.kill_random(team, 1, "promote", PROMOTE_TIER_WEIGHT)`（「晉升：抽 1 anon(偏高 tier=提拔精銳)→轉 named」comment 逐字對得上）。
- **群派遣 named-led pattern**：spot-check 確認 `sub_leader_id` 這個欄位模式在現有 code（settler 派遣段 `:577-589`）真實存在，named-led group dispatch 不是憑空講的機制。
- **migrant** `_try_migrant_side:1697`（func def，跟引用的 `:1727` 在同一函式內）→`:1727` `dispatch_anon_migrants` 親讀確認精準。

## R②

**①③succession 安全網不需要改、機械升格與湧現升格不誤傷——親自推導確認合理**：這輪最關鍵的設計判斷是「§1.2 講的『取消孤匿名→succession 無誤觸對象』」到底是怎麼運作的。我自己推導了一遍：修完之後，scout/care-scout/rescue 這 3 個 dispatch 從誕生那一刻就帶記名領隊（不再是 birth-leaderless），所以 `faction_ai:784` 的迴圈永遠掃不到「剛誕生就是 leaderless」的 team——**不是靠幫 `:784` 加一個 reason-string guard 去排除，是這種 team 根本不會存在了**。而真正的「記名領隊戰死→跟班接班」（§4 第一條要保留的 genuine 故事）走的是**同一段** `:784`→`on_leader_death`→`person_generator:103` promotion 的路徑，這種情境下這段 code 應該繼續正常運作、不受影響。這個設計是乾淨的 de-patch（移除「誕生時就矛盾」的根源），不是在既有安全網上疊補丁——符合 [[feedback_patch_gate_first]] 的精神。

**②④世界規則 + 記名稀缺約束——genuine 成立**：「重要性×可動用記名數×信任×人格」決定派遣組成，這是 util 秤，不是固定模板；記名數量真實有限（`team.named_members` 是真實有界陣列），單人任務消耗記名造成的稀缺是真實資源競爭，不是憑空捏造的門檻，genuine 成立。

**⑤§3 歸隊 return-cycle 對 group dispatch 不破**：spec §5 明確排除 envoy/builder/convoy/settler/facility-builder 這 5 個「已符」的 dispatch，不動——只要 HOW 真的不碰這 5 個函式，這條風險就不存在。

## 判決
**CLEAN + 1較重必查項（herald 分類/機制不符，需 HOW 前先釐清）→ 鎖 → systems 寫 HOW。** 非 halt——4 個「drain 點」裡 3 個（scout/care-scout/rescue）+ succession 安全網 + 機械升格來源 + 群派遣 pattern + migrant，citation 全部坐實、方向正確；只有 herald 這一個靶的機制描述跟真 code 對不上（不是不存在，是走了一條完全不同的機制、不該被塞進跟其他 3 個一樣的修法）。這條必查項的優先度**高於一般輕量項**——建議 HOW 開工前先把 herald 到底怎麼處理定案，避免 build 到一半才發現「補記名領隊」這個修法對 herald 無處可補。
