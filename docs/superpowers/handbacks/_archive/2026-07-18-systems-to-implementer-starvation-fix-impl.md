---
from: systems
to: implementer
status: consumed
topic: "[dispatch·絕境經濟 fix impl·①單一源 ②famine-amplifier·B前置] R² CLEAN(①單一源+②異質)。①survival優先序收單一源(option→priority一處:survival-class→PRIO_SURVIVAL/threat→PRIO_THREAT/else→DISPATCH),全dispatch路讀(_decide_unified:1553/_evaluate_solo:1902/_trigger_survival:3370/★_decide_subteam:1774)+grep確認無第5路。②絕境階梯famine-amplifier(terms.gd:掠奪←好戰貪殘/乞←慎榮/投靠←低野心高求生×famine_severity,覓食不amplify baseline,cap禁無界,K_*人格term非全域死常數)。★measure必走新verdict schema(is_sim=true+.qa.json)+含seed1337/42/4201→QA故事稽核。worktree feat/starvation-desperation-fix off origin/main@5a2d9787。"
---

# 絕境經濟 fix impl（① 單一源 + ② famine-amplifier，B 前置）

spec `docs/superpowers/specs/2026-07-18-starvation-desperation-fix.md`（讀全，R² CLEAN）。真根 code-坐實（翻 3 假說 + QA + measurer 精確 locate）。

## ① survival 保序單一源
- 建 **option→priority 單一源**（survival-class[SURVIVAL_OPTION_SET+"survival"/FLEE]→`PRIO_SURVIVAL`、threat-class[備戰/迎戰/求和]→`PRIO_THREAT`、else→`PRIO_DISPATCH`）。
- **全 dispatch 路一律讀源**：`_decide_unified:1553`（現 threat/survival 邏輯收進）、`_evaluate_solo:1902`（硬 @50 改讀）、`_trigger_survival:3370`（@80 收進）、**★`_decide_subteam:1774`（子隊，現 @50 改讀）**。**★grep 全 survival-class try_set 確認無第 5 路**（別 whack-a-mole，team19/1774 教訓）。
- **不變量入 invariants**：survival 保序=命運不看走哪 dispatch 路，solo/unified/subteam commit priority 一致（皆 PRIO_SURVIVAL）。
- **行為變**：_evaluate_solo + _decide_subteam survival @50→@80（兩類隊 preempt 同層 task）→ **入 sim measure**。

## ② 絕境階梯 famine-amplifier（terms.gd）
`famine_severity = clampf((FAMINE_FLOOR-food_days)/FAMINE_FLOOR, 0, 1)`（cap 禁無界）：
- 掠奪 += famine_severity × (好戰·a+貪婪·b+殘忍·c) × K_RAID
- 乞討 += famine_severity × (慎重·d+榮譽·e) × K_BEG
- 投靠 += famine_severity × ((1−野心)·f+求生欲·g) × K_JOIN
- 覓食 = baseline **不 amplify**（floor，絕境 option amplify 過它=升級）
- K_* = TEST VALUE（人格 term 係數，**禁全域 ramp 死常數**）。買糧失敗→續餓→famine 深→對應人格絕境 option 蓋過（自然升級無 counter）。

## measure（★verification-gate 已 merged，走新 schema）
- **`.measure.json` 設 `is_sim: true`**（organic sim 跑）+ **QA 出 `.qa.json` verdict**（gate 會強制:sim 缺 QA→FAIL）。
- **含硬 seed1337 + 42 + 4201**（claim 前，3 度過早宣勝教訓）。
- 驗:no_forage 傻站死普適歸零（真 3 隊）+ 各人格象限絕境 option escalate（掠奪/乞/投靠/覓食）+ 自限 attrition + 世界 sustain + threat/②不 over-shoot（char bed + organic）。

## 完成 → 下一站
①(小,byte-identical 除 solo/subteam @80 行為變)可先 done。done+綠 → to:measurer(is_sim=true sim measure 含 seed1337)→ **QA 故事稽核(.qa.json)**→ blueprint release-pass → merge。**不跳 QA**。

## 溯源
R² CLEAN(①單一源/②famine)；blueprint②intent 6 點+別whack-a-mole；measurer 精確 locate；[[project_desperation_economy]]；threat-oracle severity-scaling pattern。
