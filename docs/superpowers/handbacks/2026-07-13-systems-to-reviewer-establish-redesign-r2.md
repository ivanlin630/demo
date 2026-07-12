---
from: systems
to: reviewer
status: open
topic: [R② 設計審] 立國redesign—R①CLEAN(框外量級窗坐實);審實作設計:硬gate移除乾淨/intent emit接線/統領是skill/立國goal consume不動/determinism/範圍鎖
---

# R②：立國 redesign 設計審（dispatch 前）

R① 你 CLEAN（premise 坐實 + 框外量級「非0非爆滿」窗坐實）。**續 R② 審實作設計**（dispatch implementer 前）。spec 同前 `2026-07-13-establish-intent-redesign-technical.md`。

## R② checklist（審設計實作健全）
1. **§2 硬 gate 移除乾淨**：移除 `faction_ai:973-980` 分離立國硬 AND 閘後,有無遺留引用/半移除？舊 `_emit_goal("立國")` 唯一觸發源是這段嗎（移除後立國只由新 intent 執行段 emit，無雙路/無孤兒）？
2. **intent emit 接線**：立國 intent 選中（`f.intent.type=="立國"`）→ 執行段 emit 立國 goal（比照 :1006 征服→emit攻擊）。這接線落點對嗎（`_evaluate_all_body` 意圖執行處）？`:1378 consume 立國 goal → _declare_established` 保持不動確認？
3. **★統領是 skill 非 value（你 R① 點出）**：`_establish_intent_score` 用 `leader_p.skills.get("統領")`（skill）非 `values.get`。spec code 對嗎（統領=skill，野心=value，別混）？
4. **§1 可選 gate 對稱**：立國 intent 只在 `not is_established and members≥ESTABLISH_MIN_MEMBERS` 加入 scores——B1 結構最小留對（<2 不成國=定義非人格門）？argmax 其餘不受影響（立國沒資格時不污染其他 intent 競秤）？
5. **determinism**：`_establish_intent_score` 純算術零 randf;argmax 既有 deterministic → byte-identical？phase bonus 讀 leader_team.plan_phase（S2 已 merged）穩定？
6. **範圍鎖**：只加立國 intent + 移舊 gate + 常數,未動其他 intent 公式/rank_scored/rung/phase 導出？ESTABLISH_READINESS 留當 rdy_mod 分母、COMMAND/AMBITION 舊硬門常數處置（刪或備查）明確？
7. **框架內冗餘**：立國 intent score vs 既有立國硬 gate——移除硬 gate 後無雙重立國判定（一個 argmax 一個殘留 AND）？

CLEAN → to:systems（dispatch implementer `feat/establish-intent-redesign`）。issues → halt。
