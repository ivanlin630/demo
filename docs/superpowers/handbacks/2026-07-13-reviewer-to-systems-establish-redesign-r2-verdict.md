---
from: reviewer
to: systems
status: consumed
topic: [R②verdict] 立國redesign實作設計 = CLEAN，可dispatch implementer
---

# R② 審判 verdict — 立國 redesign 實作設計

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "7項checklist皆驗過。舊emit唯一call site完全包含在待移除區塊，無孤兒/雙路風險。establishment_diagnose.gd只comment提及舊常數非code依賴，不影響編譯，該診斷工具的舊探針退役已被spec §驗收③預期，非審查遺漏。" }
```

## file:line 驗證
1. **硬gate移除乾淨**：grep `_emit_goal(...,"立國",...)` 全codebase只有一個call site（`:980`），完全包含在待移除的`:973-980`區塊內。移除後§2新增執行段emit是唯一新來源，無孤兒/雙路風險。
2. **intent emit接線**：`:1006`區域`match itype: "征服": _emit_goal(state,f,"攻擊","征服",...)`確認existing pattern，spec提案`if f.intent.type=="立國": _emit_goal(...)`可直接對齊同款match-block插入。`:1378 consume→_declare_established`保持不動確認（spec §2明講）。
3. **統領skill非value**：spec code明確`leader_p.skills.get("統領",0.0)`（非`.values.get`），與野心用`.values.get("野心")`正確區分skill vs value兩種資料源。
4. **B1 gate對稱**：條件式加key（`scores["立國"]=...`只在B1滿足時執行），不滿足時該key不存在於dict，argmax不受污染。
5. **determinism**：`_establish_intent_score`純算術零randf；`plan_phase`讀取確認S2已merged穩定存在。
6. **範圍鎖**：`ESTABLISH_COMMAND`/`ESTABLISH_AMBITION` grep全`faction_ai_system.gd`只在待移除`:977-979`區塊使用，移除後變孤兒常數（spec自陳「刪或留備查」，非隱藏遺漏）。`ESTABLISH_READINESS`正確保留當`rdy_mod`分母。額外查證`scripts/debug/establishment_diagnose.gd`提及這兩常數但只在comment非code依賴，不影響編譯；該工具讀的`gate_fail_b2/b3/b4`探針移除硬閘後會stale，但spec §驗收③已預期退役，非本輪遺漏。
7. **框架內冗餘**：同①，單一emit source完全包在移除區塊，無雙重立國判定殘留。

CLEAN，dispatch implementer `feat/establish-intent-redesign`。
