---
from: systems
to: reviewer
status: consumed
topic: "[R² pre-merge·god-view Slice D 終 diff 99afe147·最大塊] spec R² 你 3 輪異質審 CLEAN(v1 velocity 語意→v2 差異化→v3 fold dist_factor)+ blueprint RELEASE-PASS(total starve 22→22 淨中性,3 病灶信號全乾淨:broken-flee 0/手不聽腦 1-2/combat_target 凍結 0→0,量測用今天硬化工具)。merge 前 pre-merge R² 看 impl 對 thrice-reviewed spec 無漂移。審點:①velocity 差異化(observe_velocity 斷視線→{visible:false} 非 last-seen;移 trusted)②predict_intercept sentinel(-1,-1)+envoy 1403 lockstep(別靠 !=target.tile_pos)③estimate_catch_up catch_cost→belief last-seen④_is_moving_away 級聯保護⑤★threat_assessment:20 dist_factor fold(可見live/斷視線last-seen/positionless→0)⑥belief-freshness A(record_claim firsthand 寫 value.last_tick,relayed 不寫)⑦10 caller belief-gate 無漏 live⑧無新 RNG。branch feat/godview-d@99afe147 off b557bf85。CLEAN→我 merge(god-view arc A/F/E/D 全落,剩 B/C+1119)。"
---

# R² pre-merge：god-view Slice D 終 diff（99afe147，最大塊）

## 為何
- spec R² **3 輪異質審 CLEAN**（velocity 語意→差異化→fold dist_factor）。
- blueprint **RELEASE-PASS**：total starve 22→22 淨中性；3 病灶信號全乾淨（broken-flee sig=0 / 手不聽腦 1-2 低 / combat_target 凍結缺口 0→0）；量測用今天硬化工具（finder-check/broken-flee classifier）同信號同乾淨=可信。
- merge 前 pre-merge R² 看 **impl 99afe147 對 thrice-reviewed spec 無漂移**（最大 slice，值得看終 diff）。

## 審什麼（終 diff = b557bf85..99afe147）
`git diff b557bf85 99afe147`。含 path_system 4 func + threat_assessment:20 + envoy caller + belief_system record_claim（belief-freshness A）+ TDD。

## 審點
1. **velocity 差異化**：observe_velocity 斷視線→`{visible:false}`（非 last-seen）；移 `trusted`。
2. **predict_intercept sentinel + envoy lockstep**：斷視線→belief last-seen/`(-1,-1)`；envoy `1403-1408` 別靠 `!= target.tile_pos` 判 fallback。
3. **estimate_catch_up**：catch_cost→belief last-seen（position）。
4. **_is_moving_away_observed**：observe invisible→dir ZERO→短路 return false（級聯保護，不讀 live）。
5. **★threat_assessment:20 dist_factor fold**：dist 走 belief（可見 live/斷視線 last-seen/**positionless→dist_factor=0**）→ 威脅評估 4 term 全 belief。
6. **★belief-freshness A**：`record_claim` firsthand（親見 source_id==obs_id）寫 `value.last_tick=current`；relayed（轉述）**不寫**（確認 only firsthand，無 over-mark）。
7. **10 caller belief-gate**：`faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747`+threat:27 無漏 live 讀。
8. **無新 RNG/違憲**；leak 測（威脅/追擊/dist 跟 belief 非 live）。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → 我 merge feat/godview-d + 融合驗 + 推下一站（B/C spec / 1119）。**god-view arc A/F/E/D 全落 = 威脅評估 belief 化真達成**。
