# Spec：絕境經濟 fix（① survival 保序完整 + ② 絕境階梯 famine-amplifier escalation）

> B 前置 blocker（世界 sustain N 隊）。真根 code-坐實（翻 PRIO_COMBAT/source-block/proactive_camp 3 假說 + QA 故事稽核 + measurer 精確 locate 後）：真 3 隊飢荒死（count 去灌水）——① team19 survival 保序不完整、② team14/27 絕境階梯無 escalation。[[project_desperation_economy]]。

## ① survival 保序=單一源（team19，B-class，★blueprint 裁:別 whack-a-mole 收單一源）
- **根（code 坐實）**：cause1 fix（survival-class @PRIO_SURVIVAL 80）**只做 `_decide_unified:1553`，沒做 `_evaluate_solo:1902`**（後者 try_set 一律 @PRIO_DISPATCH 50）。team19（非 unified/非 subteam→走 _evaluate_solo）survival @50 preempt 不了 安頓(invite_settle)@50 → 凍餓死。
- **★fix=單一源非逐路補（blueprint:別 whack-a-mole，已 2 路第 3 會冒；survival 優先序=散落常數=統一 arc 正靶）**：
  - 建 **option→priority 單一源**（e.g. `DecisionOptions.priority_for(opt)` or `TaskArbiter.option_priority(opt)`）：survival-class(SURVIVAL_OPTION_SET+"survival"/FLEE)→`PRIO_SURVIVAL`、threat-class(備戰/迎戰/求和)→`PRIO_THREAT`、else→`PRIO_DISPATCH`。
  - **所有 dispatch 路一律讀此源**：`_decide_unified:1553`（現有 threat/survival 邏輯收進源）、`_evaluate_solo:1902`（現硬 @50 改讀源）、`_trigger_survival:3370`（現 @80 收進源）、**★第 4 路=`faction_ai_system.gd:1774 _decide_subteam`（R² 明確點名;現一律 @PRIO_DISPATCH 50 沒依 opt 分流→同 team19 凍死 bug 換子隊,收單一源）**。**★單一源被驗證對:reviewer 找到 :1774 是 whack-a-mole 會漏的第 4 路,單一源全收**。impl 再 grep 全 survival-class try_set 確認無第 5 路。
  - **不變量（入 invariants）：survival 保序 = 命運不看走哪條 dispatch 路；solo/unified/subteam survival-class commit priority 一致（皆 PRIO_SURVIVAL）。** 消散落常數=統一矩陣程序（單一源 oracle）。
- **detector**：統一後 trivial（掃「survival-class try_set 是否全讀單一源/=PRIO_SURVIVAL」一處查）。我原「跨路一致性 scan」= 沒收單一源前的 backstop（blueprint）。
- 小統一 refactor。

## ② 絕境階梯 famine-amplifier escalation（team14/27，blueprint ② intent 定案）
- **根（code 坐實）**：`terms.gd:105-146` SURVIVAL_OPTION_SET util——紮營=常數/乞食=常數/掠奪=看武裝/併入=看名聲，**全與 food_days/famine_days 無關**；買糧唯一讀 food_days 但觸底飽和。→ argmax 進危機就 static 凍，買糧失敗不升級。
- **blueprint ② intent（6 點，鏡射 threat-severity 結構）**：
  1. **famine 深度=amplifier**（food_days→0 整個絕境 category urgency 升，util 隨絕境重排非 static）。
  2. **方向=人格閘**：掠奪←好戰/貪婪/殘忍、乞討←慎重/榮譽、投靠←低野心/高求生欲、覓食←baseline。
  3. **失敗升級=自然湧現不需計數器**：買糧失敗→續餓→famine 深→amplifier 強→更絕境 option 蓋過（無 retry counter）。
  4. **無固定普適序**：序由人格排（軍閥搶先於乞、農夫乞先於搶）。
  5. **框架約束**：`amplifier = famine_days × 人格`，**禁全域 ramp 死常數**（同 threat-oracle defiance 教訓:人格化非全域 boost）。
  6. **產自限 attrition**（每 rung 是行動非被動餓死）。
- **設計（HOW，鏡射 threat-oracle severity-scaling）**：
  ```
  famine_severity = clampf((FAMINE_FLOOR - food_days)/FAMINE_FLOOR, 0, 1)   # food_days→0 升(capped,禁全域無界)
  # 掠奪 = 不加 famine 項(intent_fit 已 hunger-scale+guard,單一源;systems 裁 2026-07-18 排除,防 double-count over-war)
  乞討 util += famine_severity × (慎重·d+榮譽·e) × K_BEG            # 慎/榮 escalate 乞
  投靠 util += famine_severity × ((1−野心)·f+求生欲·g) × K_JOIN     # 低野心/高求生 escalate 投靠
  覓食 = baseline **不 amplify（R² 裁定：純 baseline floor，絕境 option amplify 過它=升級;覓食是 rung1 默認、乞/投靠是 famine 深化+人格 amplify 蓋過的高 rung。measure 若 baseline 覓食 teams 仍卡再議弱 amplify）**
  ```
  - **★掠奪支排除單一源（systems 裁 2026-07-18,`starvation-raid-branch-ruling`）**：`_intent_fit` 已 hunger-scale raid（SCARCITY_RAID_MIN+has_weak_prey+capability guard）→ famine-amp 再加掠奪=同型重複 double-count（impl grep 坐實）。∴ **famine-amp 只 紮營/乞討/投靠(非暴力)；掠奪留 intent_fit 不動**。因:①單一源②殲滅-heavy 敏感 double-raid=over-war 錯敗態③連貫階梯:暴力由 prey-gate、非暴力由 famine(餓+無 prey→beg/join 非自殺 raid)④least-change 保 calibrated raid=不需藍圖簽。gate-extension(貪婪/殘忍納 intent_fit)=defer measure-first。
  - famine 深→對應人格的**非暴力**絕境 option 蓋過買糧（自然升級，無序無 counter）;掠奪由 intent_fit hunger-scale（餓+有弱 prey 才 raid）。K_* = TEST VALUE（measurer 校，禁全域死常數=各是人格 term 係數同 threat k）。
  - **famine_severity capped**（禁無界=偽裝硬閘，threat-oracle blueprint② 教訓）。

## 交付切片
- **S1 ① survival 保序單一源**（option→priority 收單一源，全 dispatch 路讀）：**★行為變（R² 要求納 measure 非排除）**——`_evaluate_solo`（solo 隊 survival @50→@80 preempt 安頓）**+ `_decide_subteam:1774`（子隊 survival @50→@80 也 preempt 同層 task）**兩路皆行為變，**皆入 sim measure**（非「其餘路不變」）；`_decide_unified`/`_trigger_survival` 已 @80 收源後不變。sim measure 驗兩類隊（solo+subteam）survival preempt 正確 + 不誤傷。
- **S2 ② famine-amplifier**（terms.gd util 加 famine 項 × 人格）：行為變大。

## 閘
- **R²**：① 標準（保序一致性）；**② 建議異質框外審**（behavior-design，util-magnitude 風險同 threat-oracle over-shoot/last-stand，人格閘方向/famine cap/無死常數）。
- **★measure（verification-gate 將強制）：sim measure 含硬 seed1337 + 42 + 4201 → QA 故事稽核（thrash❌/窮死✅/自限 attrition 判準）→ blueprint release-pass → merge**。不跳 QA，含 seed1337 才 claim（3 度過早宣勝教訓）。

## 溯源
QA 故事稽核 + measurer 精確 locate（team19=B/_evaluate_solo@50、team14/27=util static）;blueprint ② intent 6 點;[[project_desperation_economy]] 絕境階梯;[[feedback_symptom_vs_root_retry]] ②升級;threat-oracle severity-scaling pattern reuse;[[feedback_patch_gate_first]]。
