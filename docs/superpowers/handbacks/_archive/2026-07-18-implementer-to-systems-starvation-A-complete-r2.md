---
from: implementer
to: systems
status: consumed
topic: "[絕境經濟 impl A 完·待你 pre-merge R²] 照裁 A 收尾:紮營 famine-amplifier 第三支加(camp_famine=野心/求生欲×famine_sev,連貫階梯高野心自立紮營 vs 低野心併入)。掠奪原封留 intent_fit(spec §掠奪作廢,更 comment)。①survival單一源 already done 全5路(1132bf0c,你信提「剩①solo/subteam@80」=已完,S1 handback 走了 measurer 你沒見)。四出路全隨飢餓升級:暴力 prey-gate(intent_fit)/非暴力 famine-drive(紮營/乞食/併入)。TDD ALL PASS,gate 64 removed=0,headless base-vs-mine 逐條 IDENTICAL(0 new)。★紮營人格軸(野心/求生欲)我 derive(你只命名 option 未給公式)→請 R² 確認。branch@ebf4489b。R² 綠 → measure(is_sim+seed1337/42/4201)→QA→release。"
---

# 絕境經濟 impl A 完（待 pre-merge R²）

照裁 A 全收尾。branch `feat/starvation-desperation-fix@ebf4489b`。

## 終 diff（三 commit，scope 收窄非擴）
- **`1132bf0c` ① survival 單一源**：`DecisionOptions.priority_for(opt)` 一處定 priority，全 **5 dispatch 路**讀（`_decide_unified`/`_decide_subteam`/`_try_join_target`[grep 捕第 5 路]/`_evaluate_solo`/`_trigger_survival`）。→ **你信提「剩 ① solo/subteam@80」= 已完**（S1 handback 走了 measurer，你可能沒見；此處補告）。
- **`764577e9` ② 乞食/併入 famine-amplifier**：非暴力 clean-gap，base drive 平→餓深不升級→傻站死。
- **`ebf4489b` ②b 紮營 famine + 掠奪支作廢**：照裁 A。

## 照裁 A 三點逐條
1. **famine-amplifier 只作用 紮營/乞食/併入**：✅ 三支全 done（camp_famine/beg_famine/join_famine，weight famine_amp=1.0，cap 禁無界，覓食 baseline 不 amplify）。
2. **掠奪支不動，留 intent_fit**：✅ terms.gd/options.gd 掠奪原封（loot_drive + intent_fit 匱乏→搶 未碰）。
3. **移除無 guard 掠奪公式**：✅ 未實作該公式；terms.gd:48-52 comment 更新反映裁 A（連貫階梯：暴力 prey-gate / 非暴力 famine-drive，兩軸不同源）。

## ★需你 R² 確認：紮營人格軸（我 derive）
裁定命名 紮營 為第三支但**未給人格公式**。我 derive：
`camp_famine = famine_sev × (野心·CAMP_AMB(0.5) + 求生欲·CAMP_SURV(0.5)) × K_CAMP(1.0)`
- **理由**：(a) mirror 既有 `weight("camp")` = 野心×0.4+統領×0.3+求生欲×0.3（野心-dominant）；(b) **完成階梯象限**——低野心→併入(投靠), **高野心+求生欲→紮營(自立墾荒,不投靠)**；求生欲=保命通用。gate `has_farmable_tile` 鏡射 camp_drive。
- **未用 統領**（camp weight 有）：統領 default=0.0，多數 leader 無→camp_famine 近零 rarely fire；改用 野心（default 0.5，且是階梯區分軸 vs 併入）。
- 若你要別的軸（如 慎重/統領）→ 我改。這是唯一設計-defining 猜測點。

## 驗（我側）
- TDD `famine_amplifier_test.gd`（+紮營支）**ALL PASS**（餓深升級 / 各象限人格方向 / cap food<0 不再放大 / opt-filter / 各 gate=0）
- `survival_single_source_test.gd` ALL PASS
- `constitution_gate` PASS（sites=64, removed=0）
- **headless base-vs-mine 逐條比對**：strip 到 origin/main@5a2d9787 跑 base → `diff` = **IDENTICAL**（同 3 pre-existing：Team23 紮營 order=-1 ×2 / 追目標未加入攻擊 goal，0 new）

## 下一站（照你裁定 flow）
R² 綠 → measurer measure（is_sim=true + seed1337/42/4201 → .qa.json 故事稽核）→ 藍圖 release-pass → merge。**不跳 QA**。
（我已先送 S1+S2 給 measurer；紮營加入後 branch 更新，measurer 應等你 R² 綠再跑，或我可再 ping。）

## 溯源
裁 A ruling `2026-07-18-systems-to-implementer-starvation-raid-branch-ruling.md`；[[project_desperation_economy]]（殲滅-heavy 敏感）；[[project_unification_matrix]]（①單一源）。
