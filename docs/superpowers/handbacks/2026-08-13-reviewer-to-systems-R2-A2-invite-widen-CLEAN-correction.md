---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN+2必查項(citation過claim訂正+filter語意範圍收窄)] A2 invite-widen fix——親讀_try_invite_nearby_exile(faction_ai_system.gd:596-616)逐字確認現況filter`:600 if not(\"流亡\" in t.tags): continue`+belief-legal結構(:597 state.team_discovered來源/:605-606 BeliefSystem.belief_pos+INVITE_RANGE gate)皆屬實,MIN_PARENT_POP_AFTER_DISPATCH=10(:143)+:576 gate親讀坐實;★但★親grep全『流亡』tag發現handback『流亡tag只faction_ai:5194 uprising_exile專屬』這句過claim——實際至少4個獨立producer:faction_ai:5163(uprising_exile,handback引的行號差了~30行但同一個)、event_tag_shift.gd:14(tag_shift:gain_exile,獨立事件系統)、population_system.gd:60(overflow_split人口溢出分裂)、reaction_system.gd:320(solo_exile反應)——一般wanderer理論上並非結構不可能拿到這個tag,只是實測樣本(250/250)裡剛好都沒有,這是empirical現象非『結構不可能』的citation誤述,要求訂正措辭(非否定250/250這個量測結果本身,是要求不要用『結構不可能』這種比實際情況更強的因果語言描述);★filter語意範圍收窄必查項:新filter`t.tags.has(TAG_PRODUCE) or t.parent_team_id!=-1: continue`是排除式(非production非subteam即納入候選)——這比handback自己講的意圖(『只邀非生產隊[wanderer/流亡]』)寬得多,一支正在TASK_ATTACK的TAG_MILITARY solo戰隊、或roam-trade的TAG_MERCHANT商隊,只要不是TAG_PRODUCE也不是subteam,一樣會通過這個filter被當成『可邀請安頓』的候選——這跟『邀請流亡/wanderer進駐』的直覺語意有落差(邀一支現正劫掠的戰隊來當安分居民,語意上怪),要求HOW明確決定:(a)filter刻意排除combat-active候選(加task/tag排除如current_task!=TASK_ATTACK且非TAG_MILITARY-active)或(b)明講這是刻意的『任何遊蕩非生產個體皆可邀,含前戰隊』設計選擇並記錄理由;感知鐵律/rate-limit/dispatch-gate-genuine/scope不外擴四點親驗皆合理成立;判決=CLEAN+2必查項(citation措辭訂正+filter語意範圍決定)→implementer+measurer bounded gate"
---

# R②判決：A2 invite-widen fix — CLEAN + 2必查項

## 現況 filter + 診斷坐實

親讀 `_try_invite_nearby_exile`（`faction_ai_system.gd:596-616`）逐字確認現況 filter `:600` `if not ("流亡" in t.tags): continue`；候選來源 `state.team_discovered.get(team.team_id, [])`（`:597`，belief-known）+ 距離 gate 用 `BeliefSystem.belief_pos`（`:605-606`，明確 comment「禁 live t.tile_pos」）——belief-legal 結構屬實。`MIN_PARENT_POP_AFTER_DISPATCH=10`（`:143`）+ 使用點 `:576` 親讀坐實，dispatch 路的自保 gate 真實存在。

## ★必查項①：「流亡 tag 只 uprising_exile 專屬」是 citation 過 claim

親 grep 全「流亡」發現這句話不精確。**至少 4 個獨立 producer**：
- `faction_ai_system.gd:5163`（`uprising_exile`，handback 引的行號 `:5194` 差了約 30 行但確實是同一機制）
- `event_tag_shift.gd:14`（`tag_shift:gain_exile`，**獨立的一般性事件系統**）
- `population_system.gd:60`（`overflow_split`，人口溢出分裂）
- `reaction_system.gd:320`（`solo_exile`，反應系統）

一般 wanderer 理論上**並非結構不可能**拿到這個 tag，只是實測樣本（250/250）裡剛好都沒有——這是**empirical 現象**，不是「結構不可能」這種更強的因果宣稱。**要求**訂正措辭（非否定 250/250 這個量測結果本身、也不影響修法方向，只是不要用比實際情況更強的因果語言描述現況，避免下次有人以為這個 tag 真的單一來源）。

## ★必查項②：新 filter 語意範圍比宣稱的意圖寬——需要 HOW 明確決定

新 filter `t.tags.has(TAG_PRODUCE) or t.parent_team_id != -1: continue` 是排除式（非生產隊、非子隊即納入候選）——這比 handback 自己講的意圖「只邀非生產隊 [wanderer/流亡]」寬得多。一支**正在 `TASK_ATTACK` 的 `TAG_MILITARY` solo 戰隊**、或**roam-trade 的 `TAG_MERCHANT` 商隊**，只要不是 `TAG_PRODUCE` 也不是子隊，一樣會通過這個 filter 被當成「可邀請安頓」的候選——這跟「邀請流亡/wanderer 進駐」的直覺語意有落差（邀一支現正劫掠的戰隊來當安分居民，語意上怪）。

**要求** HOW 明確二選一：
(a) filter 額外排除 combat-active 候選（例如加 `current_task != TASK_ATTACK` 且非 `TAG_MILITARY`-active 這類條件）；或
(b) 明講這是刻意的「任何遊蕩中的非生產個體皆可邀、含曾經是戰隊的」設計選擇，並記錄理由（例如：既然 diplomacy accept 那層已經有人格判斷會不會答應，讓判斷交給那層而非在候選池就先篩掉也是合理設計，但要明講是刻意的，非沒想到）。

## 其餘四點——親驗合理

**感知鐵律**：filter 讀 `t.tags` 是結構/身分屬性讀取（非 live 位置/資源），跟既有 `is_resident_static`/`_faction_roster_pos` 一路的 tag-read 慣例一致；候選來源+距離 gate 兩處都沒被這次修改碰到，belief-legal 保持。

**over-invite/rate-limit**：`invite_cooldown`（拒絕 7 天/接受 `RESIDENCY_COOLDOWN×4`）+ `INVITE_RANGE=8` + diplomacy accept 判斷——多層節流，跟這 session 其他地方的 `_has_inflight_info`/`_has_inflight_letter` 節流慣例一致，合理。

**dispatch pop gate 保留**：`MIN_PARENT_POP_AFTER_DISPATCH` 這個自保下限不動，符合這 session「genuine 保留、非逢缺必補」的一貫判準。

**scope 不外擴**：`establish_crude_camp`（第三槓桿）明確留給量完再評，本 slice 只動 invite filter 這一處，範圍守得住。

## 判決
**CLEAN + 2必查項（①citation 措辭訂正、②filter 語意範圍決定）→ dispatch implementer + measurer bounded gate。** 修法方向正確（250/250 卡在過窄 filter 這個診斷本身可信），必查項不擋 dispatch，但要求 implementer 落地時一併決定 filter 要不要排除 combat-active 候選、非事後才發現语意比想的寬。
