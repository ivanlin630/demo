---
from: implementer
to: measurer
status: consumed
topic: [撤回·HALT] 立國redesign 驗收暫停——用戶轉優先決策引擎架構重構;branch擱置別驗別merge
---
# ★撤回：立國 redesign 驗收暫停（HALT）

**systems HALT（`2026-07-13-systems-to-implementer-establish-redesign-HALT`）**：用戶轉優先決策引擎架構重構，established 鏈全項暫停。branch `feat/establish-intent-redesign` **擱置——別驗收、別 merge**。code 已完成 push 但停於此，架構定案後可能以新框架重做或作廢。**measurer 勿花力氣驗此 branch。** 下方原交付內容保留備查。

---
# Hand Back: 立國 redesign（意圖層 argmax）— 已撤回驗收

branch `feat/establish-intent-redesign`（已 push，疊 main 86618c0 含 plan-layer S1-S4）。spec `docs/superpowers/specs/2026-07-13-establish-intent-redesign-technical.md`。

## 實作摘要（`scripts/simulation/faction_ai_system.gd`）
- **常數**：移除孤兒 `ESTABLISH_COMMAND`/`ESTABLISH_AMBITION`（硬門，grep 確認移 gate 後無 code 依賴）；保 `ESTABLISH_READINESS`（rdy_mod 分母）；+`ESTABLISH_MIN_MEMBERS=2`/`AMBITION_W=0.4`/`COMMAND_W=0.4`/`RDY_FLOOR=0.5`/`PHASE_BONUS=0.2`/`COMMITMENT_BONUS=0.15`。
- **移除舊硬 AND 閘**（`_update_goals` :973-980 分離立國 gate）。
- **立國進 argmax**：`_select_intent` +`ctx.can_establish`（未立國+≥2 成員）/`establish_score`（**mirror 建國 `can_found`/`found_score` 注入模式**——functionally 同 spec §1「scores 加立國」，更框架一致：立國 faction-only 邏輯留 faction 版 `_select_intent`，注入既有共享 `select_strategic_intent`）。
- `_establish_intent_score`：`野心×AMBITION_W + 統領×COMMAND_W`（★統領=`skills.get("統領")`/野心=`values.get("野心")`，未混）× `rdy_mod`（readiness 軟折扣 floor 0.5）+ ESTABLISH phase bonus + 承諾 hysteresis。
- `select_strategic_intent`：`can_establish` → `scores["立國"]`（第 7 意圖競 argmax）。
- **執行段**：`match itype` +`"立國"` → `_emit_goal(state,f,"立國","立國","野心稱王(intent argmax)","establish")`。`:1378 consume → _declare_established` **不動**。
- `_intent_why` +「立國」case。

## ★§3 ESTABLISH phase 接線（取 A）
- ESTABLISH phase → `_establish_intent_score` +`ESTABLISH_PHASE_BONUS`（phase→intent，非 phase→option）。`_phase_option_bias(ESTABLISH)` 維持 `{}`（立國=goal 非 option）→ 填 plan-layer ESTABLISH 空偏置。

## 我方自驗（供參）
- headless `=== DONE ===`，3 新 test [OK]：①高野心+統領+ESTABLISH phase → 立國贏 argmax + emit 立國 goal；②低統領+低戰備 → 立國輸（非人人立國）；③<2 成員 → 立國不入 scores。
- **0 新增 SCRIPT ERROR**：3 = pre-existing（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，同 main baseline）。
- **determinism byte-identical**（`WARRING_SEEDS=1337 WARRING_MONTHS=1` 兩跑 `cmp`；`_establish_intent_score` 純算術零 randf）。
- constitution_gate PASS（sites=29，removed=0；移 gate + 加 intent sites 核平）。

## 待驗收（spec §驗收，blueprint 判）
1. **★established > 0**（最後一哩核心）：default.json 12mo（或右尺寸）——established 從恆0 → 有 faction 立國。
2. **非人人立國**：established 隊 = 立國 intent 真贏 argmax 的（高野心/統領/戰備）；`intent.sel_立國` vs faction 總數比例合理（少數強傾向立國，非爆滿）。
3. **B 門 funnel 退役**：舊 `establish.gate_fail_b2/b3/b4` 硬 funnel 探針退役（fire=0，可留可標）→ 改看立國 intent argmax 勝率分布。
4. **determinism** byte-identical + baseline 位移標記。
5. **融合閘** + **plan-layer 不回歸**（ESTABLISH phase 隊真傾向立國，phase bonus 生效）。

## 連動風險 / 誠實
- **established 完整仍受上游 faction 形成**（≥2 成員+食足=pop/consolidation arc）——立國入口通了，但要有夠格 faction 才觸得到立國 intent。**若見「入口通但 faction 形成仍卡」→ 標「立國入口 done，上游 pop arc 待」**（spec 已預告）。
- 立國進 argmax → faction 意圖分布位移（守成/征服/致富…此消彼長）= baseline 位移。
