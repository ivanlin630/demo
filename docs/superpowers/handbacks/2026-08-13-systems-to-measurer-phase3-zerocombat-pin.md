---
from: systems
to: measurer
status: consumed
topic: "[#新A 零戰死 pin(先排除床 watchdog artifact=blueprint 對、systems 結構坐實)·★systems 結構坐實:death.combat_pop(loser_dead)是 decisive-win-gated(npc_combat:402、有 winner/loser 才 bump、loser_dead=loser_anon×LOSER_CASUALTY_RATE)→DRAW 路徑不走 winner/loser 判定→跳過 death.combat_pop→床 watchdog(phase3_bed:74 encounter_tick>800→resolve_encounter_end draw)force-draw 慢戰=零 combat 死亡即使真在打·∴零戰死高度可疑=床 artifact、先排除·★measure(官方 helper 勿手設 specimen):①watchdog-hit 率=encounter 幾次撞 encounter_tick>800 被床 force-draw vs 幾次自然 decisive resolve(conq.combat_decisive 計數=決勝戰、npc_combat:405 bump)→若多數撞 watchdog=床把慢戰全判和局=artifact(死亡被床吃)/若 watchdog 少撞但仍零 decisive=combat 沒 initiate or 沒 resolve②encounter 有無 initiate=state.encounter_active 兩月觸發幾次(conquer intent×4→有無真 encounter?若 encounter 數=0=combat 根本不 initiate=更上游根[intent→encounter 斷])③若 encounter 有+撞 watchdog=量 encounter_tick 分布(慢戰多久?若恆>800=combat 無自然 decisive 終結者=世界 infinite-combat 真根、watchdog 只遮;若<800 自然結但零死=非致命)·★分野定#新A根:床 artifact(watchdog 太aggressive、真 sim 無此 watchdog 會有死)vs 世界(intent 不轉 encounter=不 initiate / encounter 不 decisive=infinite-combat / decisive 但非致命)·★禁預設(別預設 artifact 也別預設世界壞、數據說)·★注:此 watchdog 是 phase3 bed 特有(debug 床)、headless/production 無→若 artifact 則零戰死是床的鍋、真世界戰死待無-watchdog 驗(但無 watchdog 床恐 hang 若 combat 真 infinite=那本身是世界根)·output=watchdog-hit 率+encounter initiate 數+encounter_tick 分布→分床-artifact vs 世界(哪段斷)→systems consolidate→blueprint·specimen 送 QA·地基 KEEP"
---

# #新A 零戰死 pin（先排除床 watchdog artifact）

blueprint「先排除床 watchdog」完全對。★systems 結構坐實。

## ★systems 結構坐實
`death.combat_pop`(loser_dead) 是 **decisive-win-gated**（`npc_combat:402`、有 winner/loser 才 bump、`loser_dead=loser_anon×LOSER_CASUALTY_RATE` 敗方損耗）→ **DRAW 路徑不走 winner/loser 判定 → 跳過 death.combat_pop**。∴床 watchdog（`phase3_bed:74 encounter_tick>800→resolve_encounter_end draw`）force-draw 慢戰 = **零 combat 死亡即使真在打**。∴零戰死高度可疑=床 artifact、**先排除**。

## ★measure（官方 helper 勿手設 specimen）
1. **watchdog-hit 率** = encounter 幾次撞 `encounter_tick>800` 被床 force-draw vs 幾次自然 decisive resolve（`conq.combat_decisive` 計數=決勝戰、npc_combat:405）→ 多數撞 watchdog=床把慢戰全判和局=**artifact**（死亡被床吃）/ watchdog 少撞但仍零 decisive=combat 沒 initiate or 沒 resolve。
2. **encounter 有無 initiate** = `state.encounter_active` 兩月觸發幾次（conquer intent×4→有無真 encounter？若 encounter 數=0=combat **根本不 initiate**=更上游根[intent→encounter 斷]）。
3. 若 encounter 有+撞 watchdog = 量 **encounter_tick 分布**（慢戰多久？若恆>800=combat **無自然 decisive 終結者**=世界 infinite-combat 真根、watchdog 只遮；若<800 自然結但零死=非致命）。

## ★分野定 #新A 根
床 artifact（watchdog 太 aggressive、真 sim 無此 watchdog 會有死）vs 世界（intent 不轉 encounter=不 initiate / encounter 不 decisive=infinite-combat / decisive 但非致命）。

★**禁預設**（別預設 artifact 也別預設世界壞、數據說）。★注：此 watchdog 是 phase3 bed 特有（debug 床）、headless/production 無 → 若 artifact 則零戰死是床的鍋；真世界戰死待無-watchdog 驗（但無 watchdog 床恐 hang 若 combat 真 infinite=那本身是世界根）。

output = watchdog-hit 率 + encounter initiate 數 + encounter_tick 分布 → 分床-artifact vs 世界（哪段斷）→ systems consolidate → blueprint。specimen 送 QA。地基 KEEP。
