---
from: systems
to: implementer
status: open
topic: [工單] 立國redesign—機械B-gate→意圖層argmax;spec+R①R②CLEAN;疊新worktree feat/establish-intent-redesign;established鏈最後一哩
---

# 工單：立國 redesign（機械 B-gate → 意圖層 argmax）

spec：`docs/superpowers/specs/2026-07-13-establish-intent-redesign-technical.md`（R①+R② CLEAN）。established 鏈最後一哩:立國目前純機械四重 AND 閘（不在 argmax），加意圖層——立國成 faction 戰略 intent 競 argmax,B2/B3/B4 硬閘降軟 modifier。**新 worktree `feat/establish-intent-redesign` 疊當前 main（已 push，含 plan-layer S1-S4）。**

## 做（照 spec §1-§5）
1. **§4 常數**（faction_ai 頂）：ESTABLISH_MIN_MEMBERS=2 / ESTABLISH_AMBITION_W=0.4 / ESTABLISH_COMMAND_W=0.4 / ESTABLISH_RDY_FLOOR=0.5 / ESTABLISH_PHASE_BONUS=0.2 / ESTABLISH_COMMITMENT_BONUS=0.15（全 TEST VALUE）。
2. **§1 立國進 faction argmax**：`_select_intent:902` 建構 scores 後、argmax 前，加立國 intent（僅 `not is_established and members≥ESTABLISH_MIN_MEMBERS`）+ `_establish_intent_score` helper（見 spec §1 完整 code）。**★統領用 `leader_p.skills.get("統領")`（skill）非 values；野心用 `values.get("野心")`（value）——別混**（R² 特別點）。
3. **§2 移除舊硬 gate + intent emit**：
   - 移除 `faction_ai:973-980` 分離立國硬 AND 閘（R² 確認 `_emit_goal(...,"立國")` 唯一 call site 全在此區塊）。
   - 立國 emit 改由意圖執行段（比照 `:1006 "征服": _emit_goal(...)` 同款 match-block）：`"立國": _emit_goal(state, f, "立國", "立國", "野心稱王(intent argmax)", "establish")`。
   - **`:1378 consume 立國 goal → _declare_established` 不動**。
4. **§3 ESTABLISH phase 接線**：取 A——ESTABLISH phase 在 `_establish_intent_score` 加 `ESTABLISH_PHASE_BONUS`（已含 §1 code）。`_phase_option_bias(ESTABLISH)` 維持 `{}`（立國=goal 非 option,phase→intent 非 phase→option）。

## 順帶清理（R² 標）
- **舊孤兒常數**：`ESTABLISH_COMMAND`/`ESTABLISH_AMBITION`（faction_ai:11-12）移除硬 gate 後變孤兒 → **刪除**（`ESTABLISH_READINESS` 保留當 rdy_mod 分母）。grep 確認無其他 code 依賴（`establishment_diagnose.gd` 只 comment 提及非 code 依賴,不影響編譯）。
- **stale 探針**：`establish.gate_fail_b2/b3/b4` 硬閘探針移除後會 stale（spec §驗收③預期退役）——warring_harness 那些 key 可留（fire=0）或標退役,measurer 改看立國 intent argmax 勝率。**別花力氣大清探針,標退役即可。**

## TDD + 驗收
- 加 headless_test 斷言：①高野心+高統領+ESTABLISH phase 隊 → 立國 intent 贏 argmax → emit 立國 goal → is_established ②低統領+低戰備隊 → 立國 score 低 → 輸其他 intent（非人人立國）③<2 成員 → 立國不入 scores。
- 完成 → handback **to:measurer**（驗收見 spec §驗收：★established>0 / 非人人立國(intent 勝率合理) / determinism byte-identical + baseline 位移 / 融合閘 / plan-layer 不回歸）。

## 註
- **established 鏈最後一哩**——立國入口從機械閘接上意圖層。
- 誠實:established 完整還受上游（faction 形成需 ≥2 成員+食足=pop/consolidation arc）——立國入口通了但要有夠格 faction 才觸得到。measurer 若見「入口通但 faction 形成仍卡」→ 標「立國入口 done，上游 pop arc 待」。
- 卡點 → to:systems（如 plan-layer 那樣 trace 抓設計問題→呈報裁決）。
