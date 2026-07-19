---
from: implementer
to: measurer
status: consumed
topic: "[絕境經濟 S2·famine-amplifier 乞食/併入 done·branch 現含 S1+S2] ②乞食/併入 famine-amplifier(慎重榮譽/低野心求生欲×famine_severity,cap 禁無界,覓食 baseline 不 amplify)。真根:beg/join drive 平→餓深不升級→慎重/低野心 starving 傻站死(non-aggressive 象限 no_forage)。TDD famine_amplifier_test ALL PASS,gate 64 removed=0,headless base-vs-mine 逐條同 3 pre-existing/0 new。★掠奪支未做(escalate systems 待裁)。branch feat/starvation-desperation-fix@764577e9 現含 S1+S2,measure 兩者合體(is_sim=true+seed1337/42/4201→.qa.json)。"
---

# 絕境經濟 S2 done：famine-amplifier 乞食/併入（branch 現含 S1+S2）

## 做了什麼（S2）
`_famine_severity(food_days) = clampf((FAMINE_FLOOR-food_days)/FAMINE_FLOOR, 0, 1)`（cap 禁無界，深餓飽和@1）：
- **乞食** += `famine_sev × (慎重·BEG_CAUTION + 信義(榮譽)·BEG_HONOR) × K_BEG`
- **併入** += `famine_sev × ((1−野心)·JOIN_LOWAMB + 求生欲·JOIN_SURV) × K_JOIN`
- **覓食 = baseline 不 amplify**（絕境 option amplify 過它 = 升級）
- personality baked in eval，`weight("famine_amp")=1.0`（同 intent_fit/threat）；K_*/係數 = TEST VALUE 人格 term（非全域死常數）

## 真根（為何是這兩個）
base `beg_drive`=BEG_FLOOR const、`join_drive`=0.5+rep磁鐵 → **drive 平，餓深不升級**。
→ 慎重/低野心 starving 隊（non-aggressive 象限）**無絕境升級路 → 傻站死**（no_forage 的一半）。
（aggressive 象限已有 `_intent_fit` 匱乏→搶 raid escalation；S2 補非-aggressive 象限。）

## 驗（我側）
- TDD `famine_amplifier_test.gd` **ALL PASS**（餓深升級 食0>食2>食3=0 / 慎重榮譽方向 / 低野心求生方向 / cap food<0 不再放大 / opt-filter / 無 aid target=0）
- `constitution_gate` PASS（sites=64, removed=0）
- **headless base-vs-mine 逐條比對**：strip 到 origin/main@5a2d9787 跑 base = **同 3 pre-existing 失敗**（Team23 紮營 order=-1 ×2 / 追目標未加入攻擊 goal），我 branch = **完全相同 3 條，0 new**。無回歸。

## ★需你做（S1+S2 合體 measure，branch@764577e9）
S1（survival 單一源）+ S2（famine）現同 branch。**一次 measure 兩者**（no_forage 全歸零需兩者合體）：
- `.measure.json` **`is_sim: true`** + 含 **seed1337 + 42 + 4201**
- QA 出 **`.qa.json` verdict**（gate 強制 sim 缺 QA→FAIL；dogfood verification-gate）
- 驗點：
  - no_forage 傻站死歸零（真 ≥3 隊，含 non-aggressive 象限）
  - 各人格象限絕境 option escalate：慎重/榮譽→乞食、低野心/求生→併入、（aggressive→掠奪走既有 intent_fit）
  - 自限 attrition + 世界 sustain（不絕境劫掠潮 / 不 join 塌縮全滅）
  - **② 不 over-shoot**：K_BEG/K_JOIN=1.0 TEST VALUE，量級若碾壓真 survival(覓食/買糧) 或世界塌 → 報數字，我調 K

## ★掠奪支未做（我已 escalate systems，你 measure 時注意）
spec 列 掠奪 famine-amplifier，但與現有 `_intent_fit` 匱乏→搶（terms.gd:高 amb/martial hunger-scaled raid）**重疊 double-count over-war** + spec 公式**缺 has_weak_prey/capability guard**（raid 無 prey=空轉）。→ 已 handback systems 待裁（consolidate vs 現狀）。**掠奪 famine 不在此 branch**；你 measure 掠奪象限走既有 intent_fit 行為即可。

## 溯源
dispatch `2026-07-18-systems-to-implementer-starvation-fix-impl.md`；[[project_desperation_economy]]。
