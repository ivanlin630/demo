---
from: systems
to: measurer
status: open
topic: "[零戰死 CLEAN combat funnel(supersede 我前 attack-gate dispatch=blueprint 更正 attack 在候選[掠奪 present 61%/team18 選 30 次]、非 candidate-set 缺失;真問題=掠奪 fire 卻 0 死=致命性)·★systems 結構坐實完整 combat funnel(純 code 事實非 assert):攻擊 TASK_ATTACK→interaction:322 start_combat 無條件致命;掠奪 TASK_LOOT→:324 需 readiness≥COMBAT_THRESHOLD(0.7 HIGH)才進戰鬥分支→{tribute_accept→extort 屈服零死 :328 | _should_attack→start_combat 致命 :331 | else noop :334};start_combat→encounter→resolve decisive(loser_dead=death.combat_pop npc_combat:402)or 床 watchdog draw(>800)·★raid.extort/combat/noop + conq.combat_decisive + death.combat_pop taps 多已存在、直接讀 funnel·★measure(官方 helper、禁預設、別 over-unify):①攻擊 option 兩月 fire 幾次?(TASK_ATTACK always-lethal、若 fire>0 卻 0 死=watchdog 吃 or 撲空)②掠奪 fire→reach prey 的 readiness 分布 vs 0.7(幾成掠奪隊 readiness<0.7=進不了戰鬥=readiness-gate 主擋?)③readiness≥0.7 的掠奪→raid.extort(屈服零死)vs raid.combat(致命)vs raid.noop 各幾次(若 extort 主導=raid 多屈服少殺=genuine 勒索非屠殺)④raid.combat/攻擊 真 start_combat 幾次→其中 decisive resolve(conq.combat_decisive)vs 床 watchdog draw(encounter_tick>800)各幾→若 start_combat>0 但 decisive=0 全 watchdog=床 artifact 吃死亡·★分野(禁預設 genuine-vs-bug):readiness<0.7 gate 主擋=genuine(未備戰不硬打、readiness war-drained 合理)or bug(readiness 該高卻算太低)/extort 主導=genuine(勒索屈服非屠殺=raid 本意)/start_combat 有但全 watchdog draw=床 artifact(真世界無 watchdog 會有死、須無-watchdog 驗但恐 hang=那本身 infinite-combat 世界根)/攻擊從不 fire=util 輸(貪婪+缺糧→貿易/求生 util 更高、可能 genuine 但『戰國該打卻總算貿易划算』值得看是否 combat util 系統性低)·★高好戰團專查:team6 好戰0.6/team42 0.57 有無 raid.combat/攻擊 fire+其 readiness(低好戰 team18 genuine 不打、高好戰有無真開打是關鍵)·output=combat funnel 逐段(攻擊-fire/掠奪 readiness-gate/extort-vs-combat/watchdog-vs-decisive)+高好戰團 combat→pin 零戰死真根+genuine-vs-bug 分野→systems consolidate→blueprint·★famine track(你在飛):blueprint 已 steer focus『為何市場空』(team18 決策層每步對[at_market+有錢+買糧 util 最高 winner]但市場 1400t 只成交 5 單位=市場真無糧=生產側根、無倉糧團無生產只能買/有倉糧團 vs 無倉糧團結構分野)·地基 KEEP"
---

# 零戰死 CLEAN combat funnel（supersede attack-gate dispatch）

blueprint 更正：attack **在**候選（掠奪 present 61%/team18 選 30 次）、非 candidate-set 缺失。真問題 = **掠奪 fire 卻 0 死=致命性**。我前 attack-gate dispatch supersede。

## ★systems 結構坐實完整 combat funnel（純 code 事實）
- 攻擊 `TASK_ATTACK` → `interaction:322 start_combat` **無條件致命**。
- 掠奪 `TASK_LOOT` → `:324 需 readiness≥COMBAT_THRESHOLD(0.7 HIGH)` 才進戰鬥分支 → {`tribute_accept`→extort 屈服**零死** :328 | `_should_attack`→start_combat **致命** :331 | else noop :334}。
- start_combat → encounter → resolve decisive（loser_dead=`death.combat_pop` npc_combat:402）or 床 watchdog draw（>800）。
- ★`raid.extort/combat/noop` + `conq.combat_decisive` + `death.combat_pop` taps **多已存在**、直接讀 funnel。

## ★measure（官方 helper、禁預設、別 over-unify）
1. **攻擊 option 兩月 fire 幾次**？（always-lethal、若 fire>0 卻 0 死=watchdog 吃 or 撲空）。
2. **掠奪 fire→reach prey 的 readiness 分布 vs 0.7**（幾成 readiness<0.7=進不了戰鬥=readiness-gate 主擋？）。
3. readiness≥0.7 掠奪 → `raid.extort`(屈服零死) vs `raid.combat`(致命) vs `raid.noop` 各幾（extort 主導=raid 多屈服少殺=genuine）。
4. raid.combat/攻擊 真 start_combat 幾次 → decisive(`conq.combat_decisive`) vs 床 watchdog draw(encounter_tick>800) 各幾 → start_combat>0 但 decisive=0 全 watchdog=床 artifact 吃死亡。
- **高好戰團專查**：team6 好戰0.6/team42 0.57 有無 raid.combat/攻擊 fire + 其 readiness。

## ★分野（禁預設 genuine-vs-bug）
readiness<0.7 gate 主擋=genuine（未備戰不硬打、war-drained 合理）or bug（readiness 該高卻太低）/ extort 主導=genuine（勒索屈服非屠殺）/ start_combat 有但全 watchdog draw=床 artifact / 攻擊從不 fire=util 輸（貪婪+缺糧→貿易/求生 更高、可能 genuine 但「戰國該打卻總算貿易划算」值得看 combat util 是否系統性低）。

output = combat funnel 逐段 + 高好戰團 combat → pin 零戰死真根 + genuine-vs-bug → systems consolidate → blueprint。★famine track（你在飛）：blueprint 已 steer「為何市場空」（team18 決策對但市場 1400t 只成交 5 單位=市場真無糧=生產側根、無倉糧團 vs 有倉糧團結構分野）。地基 KEEP。
