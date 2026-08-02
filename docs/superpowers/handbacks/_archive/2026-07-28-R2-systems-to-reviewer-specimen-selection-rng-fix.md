---
from: systems
to: reviewer
status: consumed
topic: "[R²·specimen RNG leak 診斷翻案 ratify+修審·★implementer bisect 翻我 dispatch 假設(『_begin_observe 漏包』錯)·真因=選取耗 RNG(pick_random)非 tracer wrap·bisect A/B/C 坐實 tracer 中性·修=committed RNG-neutral SpecimenDumpHelper 確定性 strided·gate followup 判(blueprint governance 強調 required)·branch feat/specimen-tracer-rng-fix b14e72c6] implementer measure-first(bisect isolate 變因)翻我 code 假設,真因選取 pick_random。systems 認 ratify。請 R² 審修+驗翻案+gate 判。"
branch: feat/specimen-tracer-rng-fix (b14e72c6)
---

# R²：specimen RNG leak 診斷翻案 ratify + 修審

## ★systems ratify 診斷翻案（認我 dispatch 假設錯）
我 dispatch spec 假設「leak 在 `_begin_observe`/`_end_observe` suppression 漏包」——**錯**。implementer **bisect isolate 變因**（measurer A/B 開關的是選取+tracing 整條、無法隔離；implementer 拆開）：
- A) fixed 10 specimen normal-LOD 600tick → **byte-identical**。
- B) pick_random 選取 10 → **發散**。
- C) fixed 10 @2000tick → **byte-identical**。
- ∴ **tracer observe/`_begin_observe` 路徑無 leak（實證中性）**，leak = **選取耗 global RNG**（measurer 那次 temp wiring 用 `pick_random` 選 specimen，已 revert、不在 repo）。
- **systems 中性 ratify**：bisect（isolate 變因）> 我的 code 假設（同 latch 診斷我 code 猜過早被 fresh 重現糾的教訓，這次 implementer measure-first 糾我 dispatch 假設，紀律贏）。

## ★結論影響訂正（餵持守統一 + 過去量測）
- **tracer wrap（`_begin_observe`）中性**（實證）→ 過去 specimen 量測若用**確定性選取** = 中性；用 `pick_random` 選取 = 發散。
- measurer 2026-07-25 那次 pick_random temp wiring → 發散（latch 假象來源）。未來用 committed RNG-neutral helper → 中性。

## 修（請審）
committed **RNG-neutral SpecimenDumpHelper**（確定性 strided 選取、零 RNG）+ regression（normal-LOD specimen ON==OFF byte-identical）。tracer 免改（實證中性）。閘：headless 0-new + gate 74 + confound 4/4（含新 regression）。

## ★reviewer focus（refute，異質）
1. **診斷翻案對否**：bisect A/B/C 真隔離出「選取 pick_random = leak、tracer wrap 中性」？（親讀 bisect 邏輯 + 修法）
2. **修對否**：確定性 strided 選取真零 RNG（無 randf/randi/pick_random/shuffle）？regression（ON==OFF byte-identical）夠證中性？
3. **★gate followup 判**：blueprint governance 強調 observability_gate 機器擋 **required**（第 N 次同族、人肉不可靠、連 blueprint 誤指過 tap）。implementer 標 followup。你判：本刀補 gate（擋 observe/選取路徑碰 RNG）還是可拆 followup slice？**若 followup 必確保 backlog 不忘**（governance 重）。
4. tracer 免改（實證中性）合理否，還是保險也該加 gate 防未來 wrap 漏？

**CLEAN → merge（unblock 過去 specimen 量測可信度框架）+ gate 序定。** 有洞 → 回 `to:systems`。
