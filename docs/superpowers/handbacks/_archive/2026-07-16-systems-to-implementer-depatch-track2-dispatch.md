---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH·de-patch軌2值閘·R²CLEAN] 續gate v2同worktree。de-patch:閘1 _threat_recent→intent/好戰軍備·閘5 tribute FLEE override(diplomatic:40)→膽識-絕望秤·閘6 _calc_diplomacy硬門檻→軟化·try_proactive_diplomacy(124)陡化(0.2~0.7→性格推兩端)。gate-ok標baseline:閘2a consider_betrayal/閘3 _check_discipline/閘4 _maybe_request_join+A類~60(canonical rank_*/taskarbiter lifecycle/world-rule threshold/early_return guards)。刪閘7 calc_attack_score孤兒。de-patch後對應閘從baseline removed。行為變非byte-identical→per-gate commit+Tier1。完成handback→measurer乾淨全量。禁AskUserQuestion"
---

# [DISPATCH] de-patch 軌2 值閘（R² round2 CLEAN）

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

R² round2 CLEAN（reviewer 親算曲線吻合）。**續 gate v2 同 worktree `feat/constitution-gate-strengthen`。** spec `docs/superpowers/specs/2026-07-16-depatch-track2-value-gates.md`。

## de-patch（行為閘→人格/情境秤，per-gate commit）
1. **閘1 `_threat_recent`**（`faction_ai:3125`,caller weaponsmith`:3087`/armorsmith`:3090`）→ 軍備需求由 **intent(征服/野心)+好戰+感知威脅** 秤（主動軍閥備戰/和平農夫不備），拆反應式「近期被打才備」硬 gate。
2. **閘5 tribute FLEE override**（`diplomatic:40` 逃跑必屈服）→ **膽識(低→屈服)+絕望度+戰力差** 秤（邊逃邊拒=絕境戲），拆「逃跑=必屈服」硬 override。
3. **閘6 `_calc_diplomacy_score::threshold`** 硬 score 門檻 → **人格 util 軟化**（連續秤非硬切）。
4. **`try_proactive_diplomacy`（`:124`）陡化**（★非拆 RNG，改曲線）：`randf() > 慎重×0.5+0.2`（0.2~0.7 平）→ **性格推兩端**（極謹慎 never proactive、大膽近乎每 tick，骰只斷中間）。RNG 案③合法-IF-陡。

## gate-ok 標 baseline（legit，systems 授權+驗過）
`constitution_baseline_v2.txt` 逐行加 `# gate-ok:<理由>`：
- **閘2a `consider_betrayal`**（已陡:driver≥HARD→100%、中間 margin 才 randf=案③）/ **閘3 `_check_discipline`**（fail-under-stress=案②outcome）/ **閘4 `_maybe_request_join`**（randi=event-ID 非決策）。
- **A 類 ~60**：canonical `rank_*` 引擎 dispatch_entry/internal / taskarbiter lifecycle scaffolding 28（outpost/player_command/sim_runner/interaction/_try_*）/ world-rule threshold（`_facility_terrain_fit`/`_facility_deficit`食/`_evaluate_new_outpost_location`hex距/可達性）/ early_return guards（null/0-pop/無據點/combat中）。

## 刪
- **閘7 `calc_attack_score`**（`faction_ai`,production/征服 arc 零 caller 孤兒）→ 刪函式。

## baseline 更新
de-patch/刪的閘 **從 baseline removed**（gate 印 removed=零殘留進度）。剩 baseline = gate-ok（legit）+ 軌1 seam#1 待收（route/dispatch_entry 控制流，下 slice）。

## 非回歸（★行為變非 byte-identical）
- 世界 outcome RNG 保留（判準案②）；感知鐵律（決策讀 belief/自家人格）；守恆 CoinAudit/InvariantAudit=0；headless≥1000 tick。
- de-patch 後 constitution_gate v2 跑：對應閘 removed、無新增、gate-ok 標的不誤刪。

## 完成 → 交回
軌2 done（per-gate Tier1 + gate v2 跑印 removed 數 + baseline gate-ok 標）→ handback `[DONE]` `to:systems`（各閘 de-patch 摘要 + removed 數 + head）→ measurer 乾淨全量（行為分化:軍閥備戰/絕境屈服人格分化、try_proactive 陡曲線、無回歸、閘 removed）→ 批。軌1 seam#1 控制流收斂另大 slice。
