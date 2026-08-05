---
from: systems
to: implementer
status: open
topic: "[dispatch build faction-cohesion(R² CLEAN+必查項整併已納、新 slice branch feat/faction-cohesion off 更新後 main)·spec docs/superpowers/specs/2026-08-05-faction-cohesion-HOW.md·grounding=exit-attribution 證 defect GENUINE(unrest-gated distress 非 honor cliff)→主刀 P4 真好處接留走秤非 de-patch·PRIMARY:①新 _faction_stay_benefit(state,team)=relief_memory(benefactor memory 被救過自我記憶)×W_RELIEF + heard_reputation(known_reputations[領主]belief)×W_REP、人格 modulate(義氣/信義高更重領主恩義)②★新 write:distribute relief 送達 resident settle 成功點 interaction:877-886→member leader 寫 benefactor memory(領主 team_id,tick)=P4 地基·defect refine:event_faction_defect.check 硬 cliff(honor/trust<0.35)→連續 defect_util=distress(unrest)×loyalty_deficit(honor,trust 連續)−_faction_stay_benefit,fire if>0(★保 unrest>=20 precondition 不動=measurer 證 genuine gate);execute clear_team_faction 不動(走側保留)·★整併第三點:_trigger_defection_evaluation:4626-4627 a_score 的 has_benefactor_memory flat+0.3→改 honor+_faction_stay_benefit(三決策點統一 stay-benefit、觸發仍 ledger domain 不碰)·SECONDARY uprising:_evaluate_uprising 3 前置門(avg_loy/unrest_turns/stress_sources)→連續 polish+★後果秤(Path A 守城後別無條件 clear、秤換領主留 vs 脫;Path B 流亡保留脫)·立國 goal:1820 查根(grep 立國寫入 f.goals 點+為何 founding 路 never assign→小順修/大歸立國 arc 記檔)·contact-loss DEFER→ledger·★守:感知鐵律零 god-view(stay_benefit 讀自身 benefactor memory+known_reputations belief、禁全知 relief 統計)/§1 防crank 雙向(禁 boost 逼留+禁刪真走 exit 保留只加 stay-side、無配額)/人格非死常數/determinism byte-identical/constitution 74·TDD:分化(餵飽+被救過低 honor 留 vs 餓+沒被救走)/好領主 vs 爛領主壽命/relief→benefactor write/god-view 硬驗/uprising 後果秤/該散的散/determinism·完成 handback to:systems R²+measurer 量分化·地基 KEEP"
---

# dispatch build faction-cohesion（R² CLEAN + 必查項整併已納）

reviewer R² CLEAN（Seam 全親驗坐實）+ 必查項（第三決策點）已整併入 spec。branch `feat/faction-cohesion` off 更新後 main。spec：`2026-08-05-faction-cohesion-HOW.md`。

## PRIMARY：P4 真好處接留走秤
1. **新 `_faction_stay_benefit(state, team) -> float`**：`relief_memory`（benefactor memory 被救過自我記憶）×W_RELIEF + `heard_reputation`（`known_reputations[領主]` belief）×W_REP、**人格 modulate**（義氣/信義高更重領主恩義）。
2. **★新 write**：distribute relief 送達 resident settle 成功點（`interaction:877-886`）→ member leader 寫 `benefactor` memory（領主 team_id, tick）＝**P4 地基**（沒它 stay_benefit 讀不到 relief 史）。

## defect refine（`event_faction_defect.check`）
硬 cliff（honor/trust<0.35）→ 連續 `defect_util = distress(unrest) × loyalty_deficit(honor,trust 連續) − _faction_stay_benefit`，fire if >0。**★保 `unrest>=20` precondition 不動**（measurer 證 genuine gate）。`execute clear_team_faction` **不動**（走側保留）。

## ★整併第三決策點
`_trigger_defection_evaluation:4626-4627` a_score 的 `has_benefactor_memory` flat+0.3 → 改 `a_score = honor + _faction_stay_benefit(state, team)`（三決策點 defect/uprising/defection-eval 統一 stay-benefit）。**觸發（contact-loss `_evaluate_owner_contact`）仍 ledger domain、不碰**；只升 stay-benefit 讀法。

## SECONDARY：uprising（`_evaluate_uprising`）
- 3 前置門（`avg_loy>=0.2`/`unrest_turns<60`/`stress_sources<2`）→ 連續 polish。
- **★後果秤**：Path A 守城後**別無條件 `clear`**、秤換領主留勢力 vs 脫（reuse `_faction_stay_benefit` + 人格）；Path B 流亡保留脫。

## 立國 goal:1820 查根 + contact-loss
- **立國**：grep「立國」寫入 `f.goals` 點 + 為何 founding 路（envoy found_ally→g2.faction_found=0）never assign → 小順修 / 大歸立國 arc 記檔。
- **contact-loss DEFER → ledger arc**（不碰）。

## 守 + TDD
- **零 god-view**（stay_benefit 讀 self-memory+belief、禁全知 relief 統計）/ **§1 防crank 雙向**（禁 boost 逼留 + 禁刪真走 exit 保留只加 stay-side、無配額）/ 人格非死常數 / determinism byte-identical / constitution 74。
- **TDD**：①分化（餵飽+被救過低 honor **留** vs 餓+沒被救 **走**、RED stay_benefit neuter→皆走）②好領主 vs 爛領主壽命③relief→benefactor write④god-view 硬驗⑤uprising 後果秤⑥該散的散（暴君 member 真餓仍 defect、stay_benefit 低）⑦determinism。
- 完成 → handback `to:systems`（R²）+ measurer 量分化（好領主 vs 爛領主壽命、該散的散、下游解鎖 rep 床不秒崩）。地基 KEEP。
