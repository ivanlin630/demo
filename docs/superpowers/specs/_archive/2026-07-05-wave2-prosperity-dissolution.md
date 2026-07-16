# Spec：wave2 序5 — prosperity-attack cascade 溶入引擎

> arc wave2 原傷（藍圖 arc-order 標「+gen 重校壓此後」）。arc 最大最險 slice。**溶=融合非刪**。北極星：攻擊=遭遇的一個結局，朝 encounter 評估收斂。系統 owner。

## 1. 目標
**現況違憲**（constitution-audit 序5）：`_evaluate_prosperity_attack`（fai:259-349）= gate cascade（archetype/attack_score/readiness/find_prey/scout-defer 硬閘）prescribe `TASK_ATTACK`，無 option 競爭。

**目標**：cascade **決策**（是否/攻誰）溶進引擎 攻擊 option（征服 intent_fit + capability + readiness/attack_score weight）；**保留 means-end scaffolding**（scout-verify 降不確定、富 prey 選）；刪 cascade + 序2 yield 閘 + unified reroute。

## 2. 現 repertoire（融合驗錨——征服鏈必保）
FORCE-archetype 獨立隊，idle → 過 5 閘 → 攻擊弱 prey（scout 查證後）。鏈：**FORCE + 好戰/野心 + 夠 ready + 有富弱 prey + 情報夠**（否則先 scout）→ 攻擊。
- **關鍵戲**：①**readiness 閘**（沒本錢不出征）②**scout-verify**（慎重者情報不足先派斥候→親見塌不確定→攻；莽者照衝→假情報誘殺=S4 ambush）③**富 prey 選**（richness×貪婪 + weakness×殘忍 + border×野心 / eta × logistics，非只挑最弱）④**hunger_relief**（越餓門檻越低=豁出去搶糧）。
- **probe 驗魂**：`g3.scout_dispatch`（S3）、`conq.prosperity_reached`（征服鏈起點）、`prosp.*` funnel。

## 3. 引擎現況（已覆蓋 vs 缺）
| cascade 元素 | 引擎現況 | 序5 動作 |
|---|---|---|
| G1 archetype=FORCE | 攻擊 applicable 有 `intent=="征服"`；FORCE archetype≈征服 disposition | 對齊（征服 intent 驅動，非 archetype label 硬閘）|
| G2 attack_score(野心0.4+好戰0.4−信義0.4) | intent_fit 征服 boost 用 野心/好戰 | 補 信義 penalty 進 attack weight or intent_fit |
| G3 readiness(pop/skill/food/weapon mean + threshold, hunger_relief) | capability_factor=self_armed_ratio（部分）| **★新 readiness term/gate**（缺，序5 補）|
| G4 find_prosperity_prey（富選）| 攻擊 to_task=`_nearest_independent`（弱）；`find_prosperity_prey` 存在但只 cascade 用 | **征服攻擊 target 改用 find_prosperity_prey** |
| G5 scout-verify（belief-risk defer）| 無 | **保為 scaffolding**（dispatch-time gate，非 option）|
| yield 閘（序2 框架債）| solo/unified yield 給 cascade | **刪**（FORCE 隊改主 rank 選攻擊）|

## 4. 設計

### 4a. readiness → 引擎 term（★核心新增）
cascade G3 readiness = 軍力就緒度（pop/skill/food/weapon）。引擎 capability_factor 只 self_armed。序5 加 `readiness_gate`：征服攻擊的 applicable/eval 吃 readiness——沒本錢（低 pop/糧/武器）不出征。
- 選項 A（gate）：攻擊 applicable 的 征服路加 `ctx.readiness >= readiness_threshold_eff`（含 hunger_relief 滑降）。
- 選項 B（weight）：readiness 進 intent_fit 征服 eval 當乘子（低 readiness→util 趨 0）。
- **裁定：B（weight，合憲法「身分/狀態=權重非硬閘」）** + hunger_relief 保（餓→門檻降=intent_fit 征服 magnitude 隨飢餓升）。`ctx.readiness` = `calc_readiness` 移入 ctx（pop/skill/food/weapon mean）。intent_fit 征服 × `clampf(readiness / readiness_thr_eff, 0, 1)`。

### 4b. 富 prey targeting（征服攻擊 target）
攻擊 to_task 征服驅動時 target 用 `find_prosperity_prey`（richness/border/own/logistics/eta 富選 + capability weakness），非 `_nearest_independent`。ctx 加 `prosperity_prey_id`（gather 呼 find_prosperity_prey）。to_task 攻擊多源：faction_attack > intent(prosperity_prey) > feud。

### 4c. scout-verify scaffolding（保留，非 option）
means-end「高風險行動前降不確定」= 世界機制（合憲法，如 threat trigger）。dissolve 後：engine rank 出 攻擊(征服) → **dispatch-time scout-verify wrapper**：`confident_enough(prey, caution)`？→ 是 attack、否 dispatch TASK_SCOUT（既有 flow）。放在 to_task 攻擊征服 dispatch 路 or 一個 `_commit_conquest_attack` helper（保 scout dispatch/release/converge + timeout + probe g3.scout_*）。**莽者(caution 低)→confident_enough 恆真→照衝→S4 誘殺保**。
- 北極星：此 scaffolding 是「派斥候探底」option 的前身；option 化排 trade/diplomacy 溶時（藍圖裁），序5 只保機制。

### 4d. 刪 cascade + yield 閘 + reroute
- 刪 `_evaluate_prosperity_attack`（fai:259-349，決策部分；scout/prey helper 移為 engine-called scaffolding）。
- 刪序2 yield 閘（fai:1755-1763，`_evaluate_solo` 的 FORCE-yield）——FORCE 隊改主 rank 選攻擊(征服)。**框架債縫#3 部分結清**（序5 起，序6 續 loop3 全溶）。
- 刪 unified reroute（fai:1521-1531，攻擊 winner→cascade）——攻擊 winner 直走 to_task（含 scout-verify wrapper）。
- loop3 prosperity invoke（fai:754-759）移除；prosperity_eval_next_tick cadence 收編（攻擊決策改主 rank cadence）。

## 5. 融合驗（`prosperity_dissolution_check.gd`，征服鏈 parity）
- **repertoire 沒少**：①FORCE 好戰野心隊 + ready + 富弱 prey + 情報夠 → rank_scored 首選攻擊、target=富 prey ②readiness 閘——沒本錢（低 pop/糧/武器）FORCE 隊攻擊 util 趨 0 不出征 ③scout-verify——慎重隊情報不足 → 派斥候（`g3.scout_dispatch`）、非直攻 ④莽者情報不足 → 照衝（S4 誘殺路保）⑤hunger_relief——餓隊門檻降豁出去 ⑥富 prey——richness/border 影響選誰（非只最弱）。
- **framework S3 scout / S4 ambush 不 DORMANT**（probe 移引擎）。
- **★征服率 parity（gen 重校前哨）**：seeded `conq.prosperity_reached` 率 before/after——融合改分佈允許但征服鏈不得歸零/暴衝。記錄。
- **回歸**：seeded（現 52/9/1/381，漂移允許 QA wave）+ framework PASS=7 + threat/solo/rung/vendetta/preempt 融合驗+live-seam 不破 + 憲法閘。

## 6. 憲法閘
cascade 刪 → `faction_ai_system.gd::_evaluate_prosperity_attack` 指紋消（removed=arc 進度）。scout dispatch 移入 helper（新指紋 or 併既有 func）→ 實作跑閘定 removed/add，同 commit 更新 baseline 標 `# 序5 prosperity`。

## 7. 藍圖裁定（seq5-greenlight，2026-07-05）—— 序5 已 greenlit
1. **★征服率尺重框**：**雪球/一統≠fail**（軍事易得，正統難守，傳承更難=容易的一章非結局）；動盪由未開的**正統/繼承/叛亂維度**製造，**非靠壓征服率**。**唯一真 fail=龜縮凍死**。established count 不執著=**有動有起落**（churn）即健康。→ **序5 的活=融合非刪 yes/no**；征服率絕對值 wave QA 只看「有沒有凍死」，不追某數。**parity 哨降級**：只驗征服鏈**不歸零**（repertoire 沒少），**不需保 rate**（暴衝也 OK=雪球非 fail）。
2. **gen 重校 = churn 目標非 rate 目標**（follow-up）：據序5 後 measure 定，目標=世界別凍死（有 churn），非湊某征服%/並立數。
3. **★B 照妖鏡（決策模型/孿生條驗收標準）**：序5 引入的閾（`readiness_thr_eff`/`FEUD_ATTACK_MIN`/`VIABLE_ARMED_RATIO`）——凡塑造行為者，歸宿=人格/記憶/現況 or 世界代價，非全域常數。`readiness_thr_eff` 已含慎重（`calc_readiness_threshold` 用慎重）=部分人格化✓。殘餘全域常數標 B-債（arc 尾/另軌「常數人格化」收，不擋序5）。**驗收隱性標準**：征服行為真穿過人格(野心/好戰/慎重)/現況(readiness/capability)的秤，非全域 gate 直達。
4. **plan de-risk 分階**（系統 HOW）：Phase1 upgrade engine 攻擊到 parity（cascade 雙路對照）→ Phase2 拆。藍圖認可。

## 8. 後序
spec → plan（分階 de-risk，征服鏈 parity 驗 first）→ 子 session。序5 綠 + 征服率 measure → gen 重校 follow-up → 序6 faction dispatch（loop3 全溶，框架債縫#3 結清）。
