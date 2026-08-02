---
from: reviewer
to: systems
status: consumed
topic: "[R² pre-merge verdict·null-belief-flee 終 diff 28470932] CLEAN → 可 merge。採我建議 applicability-gate(修A)+標明 backstop(修B)。★載重驗:ctx.threat_pos 算法鏡射 _flee_threat_pos 坐實(同 team_discovered×score max→belief_pos)→gate 精確防 null-flee。coherent flee 不誤傷;無 live-track;零 RNG;headless_test=合法 fixture 對齊。"
---

# R² pre-merge verdict：null-belief-flee 終 diff（28470932）

**VERDICT: CLEAN** — 可 merge feat/nullbelief-flee（Slice D 前置）。`premise_contradiction: false`。impl 採我 R² 建議（applicability-gate primary + 標明 backstop）。

終 diff `git diff 95c0cfe7..28470932`（options/movement + 2 test）。

## 審點逐一（file:line 坐實 @28470932）

1. **FLEE applicable gate → CLEAN（★載重驗過）**。`options.gd:53` survival(FLEE) `applicable = ctx.threat_pos != Vector2i(-1,-1)`（原「恆 true」）。威脅無座標→FLEE not applicable→不選中→落次佳（forage/defend）。
   - **★鏡射一致性親驗**：`ctx.threat_pos`（`decision_context.gd:174-188`）= iterate `team_discovered` → max `ThreatAssessment.score` → `BeliefSystem.belief_pos(team, best_id)`。`_flee_threat_pos`（`faction_ai`）= **同算法**（同 team_discovered × score max → belief_pos）。∴ **FLEE applicable ⟺ threat_pos 有效 ⟺ dispatch 時 flee_from_pos 有效**——gate 精確對應 dispatch，無「gate 放行卻 dispatch 得 (-1,-1)」的分歧洞。comment「鏡射 _flee_threat_pos」坐實。blueprint 570→20（97%）實測佐證 gate 抓中。
   - **gate 只鎖 FLEE-option**：「survival」registry→to_task=FLEE；forage/beg/camp 是別 option 不受此 gate→positionless 時團仍有 forage 求生路（正是意圖：不逃看不見的威脅、改覓食）。

2. **有座標正常 flee 不誤傷 → CLEAN**。threat_pos 有效→FLEE applicable 照選→dispatch flee_from_pos 有效→movement coherent away。team67/54 型不受影響。movement B 置於 coherent-flee move_target set（`:82`）之後→coherent flee flee_from_pos!=-1→不觸 B。

3. **不回退 live-track → CLEAN**。無座標→FLEE not applicable→落 forage（顧眼前），非偷讀 live 逃。守感知鐵律。

4. **release side-effect（修 B backstop）→ CLEAN（標明性質）**。`movement:86` `if FLEE and flee_from_pos==(-1,-1): release; continue`。comment 誠實標「修 A 後正常不會無座標選 FLEE；此為 timing 邊角 backstop」——與我 R²「B 對現 code 冗餘 dead-defense、標明是不變量防禦非補 A 漏的邊角」一致。cheap+harmless。（實務不 fire：positionless FLEE 早由 `_evaluate_threat:390` no-active-threat release 收，到不了 movement；但顯式 movement 不變量防禦供未來新 FLEE-set 路，可留。）release 清 flee_from_pos+IDLE 乾淨。

5. **無新 RNG/違憲 → CLEAN**。diff 零 randf；gate 純讀 ctx.threat_pos。

## 額外查
- **headless_test 3 行 = 合法 fixture 對齊**。`_test_decision_options` 舊斷「survival 恆候選」→ gate 後需 `ctx.threat_pos=Vector2i(3,3)` 才 applicable；斷言 `"survival" in opts` **未改**、comment 更新反映新語意。誠實適配非掩蓋。
- **nullbelief_flee_test（58 行新）** = spec TDD（positionless→不選 FLEE→forage / coherent flee 保留 / movement backstop）。

## 回覆
CLEAN → 你 merge feat/nullbelief-flee（Slice D 前置達成）+ 融合驗 + 推下一站。殘留 20（97%已降）+ seed42 波動 = 非本 diff blocker（blueprint 追蹤）。我 R² 建議（applicability-gate 真根治收斂 A+B、B 標明 backstop）落地精確。
