---
from: systems
to: measurer
status: open
topic: "[零戰死 root REFINE(blueprint 硬證揭 candidate-set 無攻擊=upstream 於床 watchdog、我上封 watchdog dispatch 仍有效當排除但這才是真根)·★systems 結構坐實:combat options 存在(掠奪/佔村/攻擊/迎戰)但 target-gated——攻擊 applicable=faction_attack_target≠-1 OR(intent==征服 and intent_target≠-1)OR feud;掠奪 applicable=has_weak_prey;佔村=has_occupy_target·關鍵鏈:has_weak_prey=_find_weakest_prey≠-1(decision_context:272)、征服 fallback intent_target=_prey(若 has_weak_prey、:435)→∴無 weak_prey→掠奪+攻擊(prey fallback)全不 applicable→零攻擊候選→零 initiate→零戰死(床 watchdog moot、攻擊從不開打)·★這是 candidate-set 層真根 upstream 於 watchdog·★pin(官方 helper、禁預設、★別 over-unify 成同 #3 belief 根=各 gate-input 獨立測):dump 領主/好戰隊(非只 strided、含 faction leader+team6/42 好戰0.6)的攻擊 gate-inputs 逐項:①has_weak_prey 幾隊幾 tick true?(_find_weakest_prey≠-1)——若恆 false=無 prey 真根②_find_weakest_prey 內部為何 -1:候選 team 數(range 內有幾隊)→belief-discovered 過濾掉幾(team_discovered gate)→capability/weakness 過濾掉幾(prey_armed vs self)→pin 是 range 無鄰/belief 沒發現/全非-weaker 哪個③faction_attack_target 兩月曾≠-1 否(faction 攻擊 directive 有無下)④intent_target 征服隊曾≠-1 否(faction target_id or prey fallback)·★分野:若 _find_weakest_prey 候選有但 belief-discovered 濾光=belief-gap(可能連 info-net、但獨立驗別預設)/若候選有但全非-weaker=genuine(周圍沒弱雞可打)/若 range 內無鄰=genuine 稀疏 or 世界太散/若 faction_attack_target 恆-1=faction 征服 intent 不下攻擊 directive=directive-wiring 斷·★禁預設 genuine-vs-bug·★床 watchdog 排除仍跑(次要、驗即使 attack 有 initiate 會不會被 watchdog 吃、但 candidate-set 無 attack 是主根)·output=攻擊 gate-input 逐項哪個擋+_find_weakest_prey 內部 breakdown→pin 零戰死真根(no-prey genuine / belief-gap / directive-斷)→systems consolidate→blueprint·specimen 送 QA·地基 KEEP"
---

# 零戰死 root REFINE：candidate-set 無攻擊（upstream 於床 watchdog）

blueprint 硬證揭：好戰0.6 隊攻擊從不在候選 = candidate-set 層真根、**upstream 於床 watchdog**（我上封 watchdog dispatch 仍當排除跑、但這才是真根）。

## ★systems 結構坐實
combat options **存在**（掠奪/佔村/攻擊/迎戰）但 **target-gated**：
- 攻擊 applicable = `faction_attack_target≠-1` OR (`intent==征服 and intent_target≠-1`) OR feud。
- 掠奪 applicable = `has_weak_prey`。佔村 = `has_occupy_target`。
- 關鍵鏈：`has_weak_prey = _find_weakest_prey≠-1`（decision_context:272）、征服 fallback `intent_target=_prey`（若 has_weak_prey、:435）→ ∴**無 weak_prey → 掠奪+攻擊(prey fallback)全不 applicable → 零攻擊候選 → 零 initiate → 零戰死**（床 watchdog moot、攻擊從不開打）。

## ★pin（官方 helper、禁預設、★別 over-unify 成同 #3 belief 根=各 gate-input 獨立測）
dump 領主/好戰隊（非只 strided、含 faction leader + team6/42 好戰0.6）的攻擊 gate-inputs 逐項：
1. **has_weak_prey** 幾隊幾 tick true？（_find_weakest_prey≠-1）——若恆 false=無 prey 真根。
2. **_find_weakest_prey 內部為何 -1**：候選 team 數（range 內有幾隊）→ belief-discovered 過濾掉幾（team_discovered gate）→ capability/weakness 過濾掉幾（prey_armed vs self）→ pin 是 range 無鄰 / belief 沒發現 / 全非-weaker 哪個。
3. **faction_attack_target** 兩月曾≠-1 否（faction 攻擊 directive 有無下）。
4. **intent_target** 征服隊曾≠-1 否（faction target_id or prey fallback）。

## ★分野
- `_find_weakest_prey` 候選有但 belief-discovered 濾光 = **belief-gap**（可能連 info-net、但獨立驗別預設）。
- 候選有但全非-weaker = **genuine**（周圍沒弱雞可打）。
- range 內無鄰 = **genuine 稀疏 / 世界太散**。
- `faction_attack_target` 恆-1 = **faction 征服 intent 不下攻擊 directive = directive-wiring 斷**。

★**禁預設 genuine-vs-bug**。★床 watchdog 排除仍跑（次要、驗即使 attack 有 initiate 會不會被 watchdog 吃、但 candidate-set 無 attack 是主根）。output = 攻擊 gate-input 逐項哪個擋 + _find_weakest_prey 內部 breakdown → pin 零戰死真根（no-prey genuine / belief-gap / directive-斷）→ systems consolidate → blueprint。specimen 送 QA。地基 KEEP。
