---
from: systems
to: implementer
status: open
topic: "[build 军民混编 Slice A(spec v2 §2 LOCKED、自我限縮不碰 pool_of/TAG_PRODUCE/uses_unified 承重牆)·新 branch feat/junmin-militia-slice-a 自 main HEAD·★systems grounding 硬讀坐實:①ThreatAssessment.score(state,self,other)=belief-threat(team_discovered gate+known_reputations+team_intel snapshot 非全知+belief_pos 距離、『威脅評估全 belief』)=正確替代 API②_has_hostile_within=god-view(teams_within(team.tile_pos)+other.tile_pos LIVE 掃真位置)、★唯一 caller=faction_ai:3074(在 _update_guard_ratio 內)=替換 scope 乾淨③guard consumer 鏈:guard_ratio→get_guards(day_night:39 guard_count=ceili(pop×ratio))→[a]get_camp_vision_range(:52 guards→vision)→_check_night_raid(npc_combat:761 camp_vision>0→夜襲免疫=finding⑤)[b]day_night:40 夜哨[c]sim_runner:442 rest_mult(1−ratio×0.5)·★★§HOW-binding 兩塊:①guard_ratio 照妖鏡 de-patch:_update_guard_ratio(faction_ai:3069-3081)離散 0.1/0.15/0.2/0.35/0.4 tag-gated 死常數→連續人格化(慎重[已存在 leader value]×W + 責任/load 類×W + belief-threat_norm×W、clamp[0.05,0.5]保 range、★禁離散跳變/tag-gated 死值)、consumers 讀 ratio 不變只改計算=夜哨/夜襲免疫/rest 保 sensible(★finding⑤ _check_night_raid 經 get_guards→camp vision 接不漏、連續 ratio 別掉到軍團夜襲裸奔)②belief-threat trigger:guard 的 threat 輸入用 ThreatAssessment.score(max over discovered hostiles)取代 _has_hostile_within god-view、★finding⑥ ThreatAssessment.score 現服務 uses_unified 隊、Slice A 須讓純軍團守衛決策 threat 也走 belief(loop team_discovered hostile 取 max score)否則軍團零感知零 guard·★★命門:genuine 非死常數(guard 由真 state[慎重/load/belief-threat]人格湧現非離散死值)、bounded(照妖鏡族同 iii/A+B machine-demonstrate:高慎重→高 guard/無威脅→低/威脅→升、連續非跳)、感知鐵律(god-view _has_hostile_within 除、threat 全 belief)·★★驗收(spec §5 Slice A、硬數據、machine-demonstrate+realistic):①guard 連續人格分化(高慎重 vs 低慎重 vs 有無 belief-threat→guard_ratio 連續不同非離散 5 值跳、machine-demonstrate 逐案印)②動員/守衛 trigger belief(遠/敵 stale/positionless→軍團也感知 belief-threat[非 0 若 discovered+approach]、god-view 掃真位置除、無 god-view leak)③消費者不漏(night-raid immunity/夜哨 guard_count/rest_mult 三處保 sensible、軍團威脅時 guard 升非裸奔)④determinism+constitution(★照妖鏡 site 應減:離散死常數移除、gate 數變化記錄)+active_promotion/named_scarcity_ab regression·★行為變 slice=fp 分化 intended(guard_ratio 連續值 vs 舊離散)·完成 handback to:systems merge-gate 硬讀(核 de-patch 連續 genuine 無死值殘留+belief-threat 無 god-view+軍團有感知+consumers 接不漏+bounded)→QA→merge→blueprint 推用戶·★Slice B(團型梯度+pool 分數化)另批不做·地基 KEEP"
---

# build 军民混编 Slice A（spec v2 §2、自我限縮低風險）

spec `docs/superpowers/specs/2026-08-12-junmin-militia-mobilization-design.md §2`。新 branch `feat/junmin-militia-slice-a` 自 main HEAD。★不碰 pool_of/TAG_PRODUCE/uses_unified 承重牆（Slice B 另批）。

## ★systems grounding 硬讀坐實
1. **ThreatAssessment.score(state, self, other)** = belief-threat（team_discovered gate + known_reputations + team_intel snapshot「非全知」+ belief_pos 距離、★「威脅評估全 belief」）= **正確替代 API**。
2. **_has_hostile_within** = **god-view**（`teams_within(team.tile_pos)` + `other.tile_pos` LIVE 掃真位置）、★**唯一 caller = faction_ai:3074**（在 `_update_guard_ratio` 內）= 替換 scope 乾淨。
3. **guard consumer 鏈**：`guard_ratio` → `get_guards`（day_night:39 `guard_count=ceili(pop×ratio)`）→ [a]`get_camp_vision_range`（:52 guards→vision）→`_check_night_raid`（npc_combat:761 camp_vision>0→**夜襲免疫**=finding⑤）[b]day_night:40 夜哨 [c]sim_runner:442 rest_mult（1−ratio×0.5）。

## ★★§HOW-binding 兩塊
### ① guard_ratio 照妖鏡 de-patch
`_update_guard_ratio`（faction_ai:3069-3081）離散 0.1/0.15/0.2/0.35/0.4 tag-gated 死常數 → **連續人格化**（慎重[已存在 leader value]×W + 責任/load 類×W + belief-threat_norm×W、clamp[0.05,0.5] 保 range、★**禁離散跳變/tag-gated 死值**）。consumers 讀 ratio 不變、只改計算 = 夜哨/夜襲免疫/rest 保 sensible（★finding⑤ `_check_night_raid` 經 get_guards→camp vision 接不漏、連續 ratio 別掉到軍團夜襲裸奔）。

### ② belief-threat trigger（感知鐵律）
guard 的 threat 輸入用 `ThreatAssessment.score`（max over discovered hostiles）取代 `_has_hostile_within` god-view。★**finding⑥**：ThreatAssessment.score 現服務 uses_unified 隊、Slice A 須讓**純軍團守衛決策 threat 也走 belief**（loop team_discovered hostile 取 max score）否則軍團零感知零 guard。

## ★★命門
- **genuine 非死常數**：guard 由真 state（慎重/load/belief-threat）人格湧現、非離散死值。
- **bounded**（照妖鏡族同 iii/A+B machine-demonstrate）：高慎重→高 guard / 無威脅→低 / 威脅→升、連續非跳。
- **感知鐵律**：god-view `_has_hostile_within` 除、threat 全 belief。

## ★★驗收（spec §5 Slice A、硬數據、machine-demonstrate + realistic）
1. **guard 連續人格分化**（高慎重 vs 低慎重 vs 有無 belief-threat → guard_ratio 連續不同、非離散 5 值跳、machine-demonstrate 逐案印）。
2. **動員/守衛 trigger belief**（遠/敵 stale/positionless → 軍團也感知 belief-threat[非 0 若 discovered+approach]、god-view 掃真位置除、無 god-view leak）。
3. **消費者不漏**（night-raid immunity / 夜哨 guard_count / rest_mult 三處保 sensible、軍團威脅時 guard 升非裸奔）。
4. determinism + constitution（★照妖鏡 site 應減：離散死常數移除、gate 數變化記錄）+ active_promotion/named_scarcity_ab regression。
★行為變 slice = fp 分化 intended（guard_ratio 連續值 vs 舊離散）。

## 序
完成 handback `to:systems` merge-gate 硬讀（核 de-patch 連續 genuine 無死值殘留 + belief-threat 無 god-view + 軍團有感知 + consumers 接不漏 + bounded）→ QA → merge → blueprint 推用戶。★Slice B（團型梯度+pool 分數化）另批不做。地基 KEEP。
