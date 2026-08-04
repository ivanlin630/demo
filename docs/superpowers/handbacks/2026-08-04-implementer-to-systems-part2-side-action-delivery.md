---
from: implementer
to: systems
status: consumed
topic: "[資訊網 Part2 (a) side-action 交付·求援/偵察脫主 argmax→平行 side-dispatch(de-patch)·feat/info-network-whole ea8d4dbd·TDD sideaction6/6+part2 7/7+herald4/4+scout4/4·headless 3=baseline·constitution 74·determinism 3 跑 byte-identical 9ACAC8D7·mini-util 錨真值(RELIEF_EXPECT/ANON_COST DERIVED)·深餓務實派/傲慢撐死 emergent]。★emergent teams 84→120 attrition 0→1.35(info-net→存活互動)。⚠★perf-watch:warring 1mo ~900s(累積+teams 成長)→measurer 需長 timeout/resume+恐 perf follow-up。待你 R²→measurer re-measure(herald_dispatched>0+distribute 連動+人格分化+主 argmax determinism)→QA。"
branch: feat/info-network-whole
commit: ea8d4dbd
base: main（續 whole build）
---

# 資訊網 Part2 (a) side-action — 求援/偵察 脫主 argmax → 平行 side-dispatch

diagnostic 確認 root：求援 applicable 但每 food 級輸 argmax rank 3/4（輸返家補給/求生）、從沒 reach dispatch。逼進單 task argmax=category error（派信使≠放棄自救、村莊邊覓食邊派人求救）。**⑥distribute 下游於 herald 已證**（distress 達領主→distribute util 0.659 fire）。

## 做（de-patch 精神、同勞力池 facility 脫 current_task）
1. **主 argmax 零改**=移除 求援/偵察 出 `options.gd REGISTRY`（移除本就 rank 3/4 loser、determinism-neutral、主 winner 不變）。
2. **新 tick step `_step6b2_info_dispatch`**（sim_runner 置 faction_ai 後、shape teams、LOD_BOTH）→ `faction_ai.info_side_dispatch_all`：每 team（非子隊/非戰鬥）**★cadence-gate（每日/team 錯開、perf）**評 herald/scout + **throttle 一隊一 in-flight**（task_reason help_call/info_scout）。
3. **mini-util = severity(或 staleness) × 人格 `_pmult` × INFO_RELIEF_EXPECT − INFO_ANON_COST**（send if >0）。
4. herald+scout 皆 **anon 1 人 empty-handed**（★scout 亦 anon 化、不再 named subteam）；dead `_dispatch_help_herald`/`_dispatch_info_scout`/delegate 分支移除。

## ★2 R² 追蹤（硬守）
1. **calibration 錨真值**：`INFO_RELIEF_EXPECT = DESPERATION_DAYS × FOOD_PER_PERSON_PER_DAY`（3×0.8=2.4、求助買回絕境門檻食價）；`INFO_ANON_COST = FOOD_PER_PERSON_PER_DAY`（0.8、1 anon 日食耗/邊際）。**皆 DERIVED 自食物常數、禁 invent「能讓求援 fire」常數**（同 idle-labor PER_HAND 紀律）。TEST VALUE 標 + rationale 註。
2. **scope 硬限**：寫死 herald/scout 兩條 1-anon 資訊跑腿（**非可插拔/註冊式 side-task 框架繞 argmax 後門**）。

## 守
- **主 argmax 零改**（REGISTRY 移 loser→主 winner 不變、determinism byte-identical 除 herald 世界效果）。
- **mini-util genuine 非 crank、人格 MODULATE**：★per-team dump 分化——深餓務實(求生欲1)mini>0 **派**；深餓傲慢(野心1)mini<0 **撐**（傲慢撐死 emergent）；輕度餓 severity 低 mini<0 不派（cost-benefit 不值 1 anon）。
- anon 零特權守 5 界（只送 distress、名冊 position-only）；零新 randf（mini-util 算術、cadence current_tick、spawn 確定性）。

## 驗（全綠）
- TDD **sideaction 6/6**（①argmax-neutral REGISTRY 無求援/偵察 ②深餓務實派 ③深餓傲慢撐 ④輕度餓不派 ⑤throttle ⑥scout anon）+ **part2 7/7** + **herald 4/4** + **scout 4/4**。
- **headless 3=baseline**、**constitution PASS 74**、**determinism 3 跑 byte-identical MD5 9ACAC8D7**。
- ★**emergent**：teams 84→**120** + attrition 0→**1.35**（info-network→help/trade→更多存活互動；1mo warring）。

## ★待你 / 交 measurer
- ⚠**★perf-watch（硬 flag）**：warring 1mo ~900s（info-network 累積 board relay/peer trade/herald 旅行 + teams 84→120 成長 compounding；cadence-gate 已治 per-tick O(teams²) 爆但整體仍重）→ **measurer 需長 timeout/resume tooling**；恐需 **perf follow-up**（tile→teams index / scout O(teams) scan 優化 / LOD）。
- re-measure whole：`help.herald_dispatched > 0`（餓 resident 平行派信使）+ `distribute.dispatch/food_delivered > 0`（症1 真通）+ 人格分化（per-team mini-util dump）+ **主 argmax determinism**（移 loser 後主決策不變）+ Part1+3 不退 + fog + economy 不爆。canonical harness 掛 specimen → QA 故事稽核 → blueprint JUDGE → 用戶驗收。
- **vestigial flag**（cleanup follow-up）：ctx help/scout/can_send 欄 + terms help_drive/scout_drive term/weight——REGISTRY 已不讀（side-dispatch 用 _pmult 沿人格），可 de-patch cleanup（同 TASK_MANUFACTURE vestigial）。

★誠實 measured 才宣稱（[[feedback_verify_execution_end]]）。待你 R² → measurer whole → QA → blueprint。
