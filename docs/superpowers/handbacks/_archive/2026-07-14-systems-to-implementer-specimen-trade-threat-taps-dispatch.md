---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH] specimen 交易+威脅 tap——建在 execlock 分支(隨其 merge);R②CLEAN;TDD"
---

# Dispatch：specimen 交易執行 + 威脅來源 tap

spec（讀全文）：`docs/superpowers/specs/2026-07-14-specimen-trade-threat-taps.md`
R② CLEAN：`docs/superpowers/handbacks/2026-07-14-reviewer-to-systems-specimen-trade-threat-taps-r2-clean.md`（file:line 全驗）

## 在哪：execlock 分支（隨其 merge，零額外 churn）
worktree `.worktrees/survival-execution-lock`（`feat/survival-execution-lock` @ `1f5a8764`）。這 2 tap 是讓 execlock 故事可判的配套 → 建在此分支，execlock merge 時一起進 main。先 `git fetch && git merge origin/main` 確認含最新 main（觀測工具已在）。

## 觸及檔（2 檔，純觀測 tap）
1. **`scripts/simulation/decision/decision_engine.gd`**：`capture_options` 兩呼點加傳 ctx：
   - `:18`（`rank_scored`，ctx 在 `:16`）→ `SpecimenTracer.capture_options(state, team, scored, ctx)`
   - `:124`（`rank_survival`，ctx 在 `:106`）→ 同加 ctx
2. **`scripts/debug/specimen_tracer.gd`**：
   - `capture_options` 簽名加 `ctx: DecisionContext` → 存 `_scratch(team_id)["threat"] = {threat_id, threat_pos, threat_react}`（純讀 ctx）。
   - `capture_decision` 組 entry「想什麼」block 加 `scr.get("threat")`。
   - `_snapshot` 加交易執行欄：讀 `team.active_orders` → `active_buy_food_qty`（buy+food 的 qty_remaining）+ `orders`（{kind,res,qty_rem} 列）+ `at_market`（讀 tile.outpost_level>0）。
   - `write_jsonl` 自然涵蓋新欄（逐 entry 序列化，無需另改）。

## 守則
- **純觀測**：只讀 team.active_orders/tile/ctx，append entry。零 state mutation、零 RNG、零行為改（加 ctx 參數不進 rank util 運算）。
- **no-op-unless-specimen**：新欄掛在 `is_specimen` gate 後（非 specimen 零成本），不重蹈 observer-changes-observed。

## TDD
1. specimen 跑一次 → 斷言 jsonl entry 含 `active_buy_food_qty`/`at_market`/`orders`（交易）+「想什麼」含 `threat_id`/`threat_react`（威脅）。
2. determinism：同 seed 兩跑 jsonl hash 相同（純觀測不破確定性）。
3. 標準：憲法 sites=29；headless 零新增。

## 完成後
→ measurer 重跑可解釋 specimen（Team20 同世界，看缺口①換皮 vs tap-miss）+ **一份團滅 specimen（死透 team_id，驗死得連貫）** → QA 複判 → blueprint 批 execlock。
完成判定 = systems + reviewer/QA，非自判。scope 疑義走 `to:systems`（不自標 REDO）。
