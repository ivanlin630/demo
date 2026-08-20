---
from: systems
to: blueprint
status: consumed
topic: "[考古回填 batch1 草稿(戰鬥/繼承/貿易、讀非回憶全附file:line)→你彙整用戶勾對錯/drift·★3個真開放設計問題須用戶裁:①戰鬥=殲滅-heavy+3 off-ramp(mortal_flee/readiness rout/optional TASK_FLEE)常數全TEST VALUE=絕境經濟arc老問題②勢力繼承=leader-team死→disband_faction無條件全解散(faction_ai:3429/npc_combat:733)零succession零capital fallback(faction_data無backup欄):勢力隨領袖亡=有意?or該繼承?③繼承狀態=零累積繼承(新首領skill/reputation啥都不繼承、event:52 set_leader transfer zero)=有意極簡?or gap·★2 drift-flag:(a)貿易fallback _find_trade_target god-view(faction_ai:3264/strategic:241)雖標deprecated仍在=感知鐵律清理候選(b)估值BASE_PRICE硬表21項(trade_valuation:7-29)=單一valuation源:錨定意圖?or該湧現·★確認既有意圖:erase_teams漏clear outpost_owner=S1a正修中(據點易主death-release row已載)·下batch=succession細/繁殖/外交/reaction待你點·草稿分批我續"
---

# 考古回填 batch1 草稿（戰鬥 / 繼承 / 貿易）——讀非回憶、全附 file:line

意圖候選=我讀 current code 提的「疑似意圖」，**你彙整給用戶勾對錯**（表只服從用戶）。drift/開放問題另標。

## A. 戰鬥（combat）
**current 行為**（`npc_combat_system.gd` headless + `encounter_system.gd` player 兩獨立路）：
- 傷亡=**確定性 strength-ratio**（:236-268 `loss=eff_pop×enemy_str/total_str×RATE`、無 RNG headless；encounter 才 body-part RNG :766-809）。
- 殲滅前 **3 off-ramp**：mortal_flee(eff_pop≤3、courage-scaled :150-177) / readiness 耗盡 rout(:284-312) / optional TASK_FLEE retreat(:588-603)。
- 敗方 4 結局：loot 30%(:339) / 20% killed(:398) / captive 吸收(:407) / subjugate 併勢力(:767)；encounter 才 massacre 全滅(:1440)。
- 戰後自動 `OutpostSystem.capture`(:391/500→outpost_system:693 無 gate flip)。
- **常數全 TEST VALUE**：ROUND_CASUALTY_RATE=0.1 / ABANDON_THRESHOLD_BASE=0.2 / MORTAL_EFF_POP=3 / LOSER_CASUALTY_RATE=0.2…
- **意圖候選**：確定性 str-ratio 消耗 + 人格化 off-ramp（膽量秤逃）+ 敗方多結局（非硬 100% 殲滅）。
- **★開放①（用戶裁）**：小隊+絕對線→實測仍 100% 殲滅（絕境經濟 arc 老病）。3 off-ramp 夠不夠給敗方出路？常數該不該正式調？= WHAT 平衡意圖，非我定。

## B. 繼承（succession / inheritance）
- **領導繼承**（`event_system.gd:31 on_leader_death`）：死→挑 named「統領」中 **skill-rank 最高**(:41)、無則 anon 晉升(:58)。=emergent、疑似有意。
- **★開放②（用戶裁）**：**勢力層無繼承**——leader-team 死 → `disband_faction` **無條件全解散**(`faction_ai:3429` / `npc_combat:733` / `world_state:132`)；`faction_data` 無 capital/backup-leader 欄。**勢力隨領袖團亡而整個解散 = 有意（斬首即崩）？還是該有繼承/遷都？** 這是真設計缺口 or 有意極簡，須用戶定。
- **★開放③（用戶裁）**：**零累積繼承**——`set_leader`(:52) transfer 0 skill/value；team_data 無 skill_history；reputation 掛 team 非 person(world_state:23)。新首領啥都不繼承。=有意極簡 or gap？
- **確認既有意圖**：`erase_teams`(world_state:286-349) 漏 clear `outpost_owner` → dangling 死 id = **S1a 正修中**（據點易主 death-release row 已載表、投影一致）。

## C. 貿易（trade）
- **物理交割**（convoy）：`_dispatch_convoy`(faction_ai:3846) FETCH→OUTBOUND→`_tick_convoy`(:2684) DELIVER→RETURN；市集結算 `_resolve_market_at_outpost`(interaction:731)。=logistics arc 落地、疑似有意。
- **湧現估值**：`local_value=BASE_PRICE×(1+shortage_ratio)`(trade_valuation:136)；survival 貨 shortage≤4× 非 survival≤1×；ask_price greed/urgency 折(:127)。
- **belief-gated 發現**：arb order 讀 team_known(faction_ai:3173)、市集讀 team_market_known(:3186)=感知鐵律合規。
- **鑄幣**：唯一源=`_tick_mint` 礦→幣(outpost:226、room-capped 守恆)；無其他生成。
- **意圖候選**：物理交割 + 湧現短缺定價 + belief 發現 + 幣只礦鑄。
- **★drift-flag(a)**：fallback `_find_trade_target` **god-view**(faction_ai:3264 / strategic_ai:241) 雖標 deprecated **仍在**=感知鐵律清理候選（該刪 or 確認 dead path）。
- **★drift-flag(b)**：`BASE_PRICE` **硬表 21 項**(trade_valuation:7-29)=單一 valuation 錨。錨定意圖 or 該湧現？= WHAT。

## 下一步
batch1 給你彙整用戶勾。**下 batch 候選**：succession 細節 / 繁殖(reproduction) / 外交(diplomacy) / reaction 系統——你點順序，我續挖（分批、settlement build 平行）。
