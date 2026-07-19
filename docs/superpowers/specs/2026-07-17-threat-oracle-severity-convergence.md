# Spec：threat-oracle（severity-scaling util + 收斂）——真統一 3 收斂 arc 之一（序3）

> stream② registry 收官後首個**真統一收斂 arc**。seam#1 結論:threat filtered subset 編碼真選擇語意（量級壓小×gate選×PRIO70×preempt×自 FLEE 公式），需 threat-oracle 4 前置齊才 sound 收斂進統一 rank。blueprint 已裁 threat-severity 行為意圖（`2026-07-17-blueprint-to-systems-threat-severity-ruling.md`，durable game-design.md §threat-severity）。
> ★行為變 arc（非 byte-identical）：measure=行為驗證。R² 建議**異質框外審**（核心 redirect 大 arc，觸發三對齊）。

## 前提（systems 逐 code 坐實 2026-07-17，seam#3 教訓全讀非 grep-sample）
- **threat_react = 感知威脅** ✓：`threat_assessment.gd:18-19` `raw=approach*1.0+hostility*1.0+(power_ratio-1.0)*0.5`；`_power_ratio`(`:41`) 讀 `BeliefSystem.best_estimate`=belief 非 god-view。`decision_context.gd:180` c.threat_react=belief。**blueprint 約束③「severity=感知」已滿足**（threat_react 直接可當 severity amplifier）。
- **可勝性 pieces 齊**：`self_armed_ratio`（`decision_context.gd:39,193` = `_calc_own_armed/pop`）+ perceived `power_ratio`（belief 敵 pop/self）→ **可勝性可組**（self 戰力 vs 感知敵戰力）。
- **GAP = util 公式**（`terms.gd:176/180/184` 沒善用 severity/可勝性）：備戰 threat-invariant、迎戰 threat-**down**、求和 threat-invariant。

## blueprint 意圖（WHAT，durable game-design.md §threat-severity）
severity=amplifier 拉量級，方向=人格×可勝性，**三支不同方向非單一 monotone**：
1. **備戰 = 隨威脅普遍升**（連謹慎/怯懦者被威脅也備戰=低後悔對沖）；人格調幅度非方向。
2. **迎戰 = `好戰高 AND 可勝` 才隨威脅升**；否則 severity 導流 逃/求和。
3. **逃/求和 = outlet**（膽量秤:好戰低/不可勝→此，[[project_desperation_economy]]）。
4. severity=感知(belief)；emergent cost（過度軍事化→餓民→流串）不設閘。

## ★R② HALT（2026-07-17 異質框外審 reviewer[Sonnet]+skeptic[Sonnet] 綜合，v1 FLAWED）
兩獨立非-Opus 審互補命中 6 缺口（我 Opus v1 盲點，同-Opus 審抓不到）：
1. **god-view 洩漏（reviewer 命中，systems 逐 code 驗）**：`_power_ratio`（`threat_assessment.gd:42`）`intel.get("population_est", other.population)` 無 belief fallback **讀真 pop**，違 `invariants.md:171`，不在已補 5 處名單，正是 blueprint 裁定信自己警告的缺口。→ **S1.5 修:無 belief→保守（fallback self_team.population 視等強，比照 invariants.md:173 已補 5 處法），禁讀 other.population**。
2. **power_ratio 未曝為 ctx（skeptic）**：現只 `threat_react`（blend approach+hostility+power）曝 ctx，`_power_ratio` 是 private 只 score() 呼叫。我 premise「可勝性 pieces 齊」**overclaim**——S2 須新 plumbing 曝 raw power_ratio。★風險:implementer 拿 threat_react 當 winnable proxy（錯,conflate）。
3. **★單term vs 多term 結構不匹配（skeptic，最深）**：備戰/迎戰/求和 各單term（max~0.8-1.2），pool 對手掠奪(`loot_drive+intent_fit`~2.0)/攻擊(`faction_duty+attack_drive+intent_fit+feud_pull` stack>3.0)多term累加。**severity-scaling 單term 無論 k 多大結構上無法匹配多term stack**。→ 純 severity-scaling 不足收斂,**需 break-top boost（鏡射 survival `:37` 加法破頂,gate on threat_react floor）或 threat util 多term 化**。此 arc 核心設計必解。
4. **高好戰-不可勝 fall-through（skeptic + 我原 flag）**：迎戰 winnable-gate off/求和 `-好戰` 抑/FLEE 低好戰抑 → 剩備戰,但備戰 base `慎重*0.9+好戰*0.2` 慎重-主導 → 魯莽武者(低慎重高好戰)備戰低(~0.38)輸野心(1.2)=**落穿所有 outlet**（正是需出路 profile）。→ **blueprint intent 缺口:proud-doomed 該迎戰(死戰,膽量秤)/逃/最後一搏? 路由 blueprint**。
5. **FLEE=threat_pressure 不在 GAP（skeptic，TOP RISK）**：FLEE 由 `terms.gd:75-80 threat_pressure`(`clampf(ctx.threat+panic*0.4)`)驅,**非我 GAP 列的 :176/180/184**。S3 退役 rank_threat 後唯一 FLEE driver=threat_pressure,照字面 implementer 不接 winnable/severity=靜默破意圖3/4。measure「逃/求和 outlet 活」淺 check 過不了此洞。→ **S2 scope 含 threat_pressure,明列 FLEE-formula-references-winnable check**。
6. **severity 上界未定（reviewer）**：`clampf(ctx.threat_react, ...)` 空白,`ThreatAssessment.score` power_ratio 項無上界。→ **定明確上界**（severity 有界=util 競秤公平;emergent cost 不設閘=下游資源後果不cap 非 util 無界,兩事）。暫定 `severity=clampf(threat_react, 0, SEVERITY_MAX)`,SEVERITY_MAX measure 校。
- **通過**:三支方向忠實 blueprint（攻擊點③,reviewer+skeptic 皆確認,除迎戰-down bug 已抓修）。
- **survival 保序具體閘（skeptic）**:`reaction_dissolution_check.gd:80-99`「真絕境 top util>panic-only FLEE util」——k_flee-scaled FLEE 若 unbounded 可 invert,非回歸須具體引此閘（非泛稱）。
- **S1 probe 先接不受阻**（byte-identical,不碰 _power_ratio/util）→ 可先 dispatch。**S2 擋**待上述修 + blueprint fall-through 答。

## 目標：threat util severity-scaled + 可勝性 gated（terms.gd 重設計）
```
可勝性 winnable = clampf(self_armed_ratio / maxf(perceived_power_ratio, WINNABLE_PPR_FLOOR), 0,1)  # ★↓with ppr(敵強→難勝);↑with self_armed。ppr=敵/self(S1.5 曝,belief)
severity = clampf(ctx.threat_react, ...)                       # 感知，已 belief

severity = clampf(ctx.threat_react, 0.0, SEVERITY_MAX)   # ★CAPPED(blueprint② 零殘留硬要求:uncapped=偽裝硬閘)。saturating,速率可人格化(神經質高估)

備戰 prepare = (慎重·a + 好戰·b) × (1 + severity·k_prep)         # 普遍隨 severity 升(慎重-weighted 幅度);每象限被威脅都備戰
迎戰 confront = 好戰 × severity × modulate_win(winnable, 慎重)   # ★winnable MODULATE 非硬gate
   modulate_win = lerp(winnable, 1.0, 1−慎重)                   # 慎重高→respect winnable(不可勝→迎戰低);慎重低→override(魯莽照打=死戰last-stand)
求和 pacify  = (貪婪·c + 信義·d − 好戰·e) × severity × (1−winnable)  # outlet:不可勝 + 低好戰 → 求和
FLEE        = 膽量秤(求生欲, 1−好戰) × severity × (1−winnable)      # outlet:怯/絕境。★rewrite terms.gd:75-80 threat_pressure(finding5)非只 :176/180/184
```
- **★defiance term 替全域 boost（blueprint 拆假張力 2026-07-17，last-stand 走窄人格閘）**：~~原全域 break-top boost（severity-gate 常數）~~ **廢——它本身是全域 severity-boost 死常數=框架清潔 arc 中的自我違憲照妖鏡**（blueprint 硬約束:禁全域 severity-boost 死常數）。改**人格化 defiance term 加進迎戰**：
  ```
  defiance = 好戰 × (1−慎重) × (1−winnable) × severity × K_DEFIANCE   # 綁人格值(first-class),非全域常數
  迎戰 += defiance
  ```
  - **狂徒-last-stand 窄閘**：只在 好戰高 AND 慎重低 AND 不可勝(winnable低) AND 高severity **四者齊** 才 spike（product ~0 除非全高）→ 狂徒玉碎 defiance；**對非狂徒（慎重高→(1−慎重)低 / winnable高→(1−winnable)低 / 低威脅→severity低）≈0**。
  - **★張力消失**：defiance 對非狂徒≈0 → **不可能碾平 trade**（只狂徒迎戰 spike，狂徒罕）；一般 threat 競秤由 base severity-scaled util 管（迎戰/備戰/求和 base，moderate）。
  - **照妖鏡 clean**：defiance 綁 好戰/慎重/winnable（人格+state），K_DEFIANCE 是 term 係數（同 k_prep/k_conf/weight("attack")）非全域 severity-gate 常數 → 合框架清潔（blueprint 硬約束滿足）。**若驗發現只能靠 tuned 全域常數才成立 → flag+defer（不加死常數）**。
  - 單term-多term（skeptit finding3）:一般 threat 競秤靠 base util moderate（threat 本該小眾非碾平多term）;狂徒 last-stand 靠 defiance 個案 spike。**非全域拉高所有 threat**。
- **★零 fall-through 不變量（blueprint①，spec 須證每象限有主導 response）**：
  - proud-doomed（好戰高慎重低·不可勝）→ **迎戰**（reckless-override winnable，死戰）✓
  - cautious-hawk（好戰高慎重高·不可勝）→ 迎戰低(respfor winnable)+**備戰**高(慎重-weighted) ✓
  - coward（低好戰·高求生欲）→ **FLEE**（膽量秤）✓
  - weak-pragmatic（低好戰·低求生欲）→ **求和**（貪婪/信義）✓
- **收斂整合**：severity-scaled + break-top boost → threat 選項在全 pool 競秤 → 退役 rank_threat filtered-hard，threat 進 rank_scored（seam#1 收斂達成）。
（k_*/a-e/SEVERITY_MAX/THREAT_BOOST_FLOOR = HOW-tuning，measure 校;方向+cap+零 fall-through 鎖死。）

## threat-oracle 4 前置（seam#1 flagged，本 arc 逐一）
1. **severity-scaling util**（上，S2 核心）。 2. **break-top boost**（S2，measure 判需否）。 3. **preempt 明確化**（S3）。 4. **probe 先接**（S1，觀測不變量，收斂前）。

## 交付切片
- **S1 probe 先接（byte-identical，觀測不變量前置）**：`_decide_unified` commit site 接 `threat.dispatch.*`（現唯一 tap 在 `_evaluate_threat:405` preempt loop 內，收斂後正常路無 tap=seam#1 finding5 盲點）。**先於任何 threat 行為變**。byte-identical（純加 probe）。
- **S1.5 god-view fix + power_ratio 曝（R² finding1/2，S2 前置）**：(a) `_power_ratio`（`threat_assessment.gd:42`）無 belief fallback `other.population` → 改**保守 self_team.population（視等強）**，比照 `invariants.md:173` 已補 5 處法（禁讀 god-view，虛張生效）。(b) `ctx` 曝 `perceived_power_ratio`（clean，供 winnable 用；禁 implementer 拿 threat_react 當 winnable proxy=finding2 風險）。**行為變（首接觸不再讀真 pop）→ measure:虛張/偽裝在無 belief 窗口生效 + 首接觸 threat 評估變保守**。連 `invariants.md:173` 補入已修名單。
- **S2 threat util severity-scaled 重設計（行為變，含 blueprint 補裁）**：`terms.gd` 備戰/迎戰/求和/FLEE(**含 :75-80 threat_pressure，finding5**) 改 §目標式（severity-CAPPED + winnable **modulate 非硬gate** + 慎重-override 魯莽死戰 + threat **break-top boost** capped）。`ctx` 補 winnable（self_armed_ratio × ctx.perceived_power_ratio，S1.5 曝）。measure=行為驗證:**零 fall-through 四象限各有主導**（proud-doomed→迎戰/cautious→備戰/coward→逃/pragmatic→求和）、severity capped（threat 不無限碾 trade）、survival 保序（**具體引 `reaction_dissolution_check.gd:80-99` 真絕境>panic-FLEE**）、感知鐵律。**★R² 補 2 具體 measure 場景（S2 完工驗收）**：(1) **boost≠偽裝硬閘**:「中等 severity + 決定性非-threat 機會（高值貿易/建國臨門）→ 非-threat 選項**偶爾仍勝**（非 threat 恆勝）」;(2) **真零 fall-through**:「極端全低人格向量（慎重≈好戰≈貪婪≈信義≈求生欲≈0）壓力測試」**或**引 `person_generator.gd` 人格 floor 佐證此退化象限架構性不可達（非只驗 4 代表角）。
- **S3 收斂（★R² HALT 後 surgical 切割 KEEP/RETIRE/FIX，2026-07-17）**：溶決策非刪 scaffolding（憲法孖 arc 老區分）。逐項：
  - **KEEP scaffolding**：`_evaluate_threat` **`:364-379` release 監控**（cadence gate + REVOLT release + DEFEND/PREPARE/FLEE/HOLD 威脅消失 or FLEE-timeout→`TaskArbiter.release`）=task lifecycle world-mechanic，**serves 全隊含 unified**（`:389` 註「release 檢查對 unified 亦成立」）。整函式退役會靜默丟它→unified 隊 threat task 無人 release=永久卡死（R² finding）。→ **抽成 release-only scaffolding 保留**。
  - **RETIRE decision**：`:385-407` 非統一 `rank_threat` argmax dispatch（手派選哪 threat option）→ 全隊 threat 決策走 `_decide_unified` rank_scored（unified idle 隊 `:390` 已如此，擴全隊）。退役 rank_threat filtered subset。
  - **KEEP preempt trigger, route decision to unified**：`:380-395` busy-preempt(壓境威脅打斷忙碌隊)=**唯一即時感知路**，保 trigger，但**決策 route 到 `_decide_unified`（非 rank_threat）**→ preempt 語意保、決策統一。
  - **★FIX task_arbiter self-replace（`task_arbiter.gd:57` finding）**：現 self-replace 只認 `PRIO_DISPATCH`→threat @`PRIO_THREAT 70` 隊換 threat option（迎戰→求和）做不到=卡死。→ **擴 self-replace 認 PRIO_THREAT**（engine-sourced 同層換 threat option），保 70 黏性(finding3)+可換。
  - **gate**：`_evaluate_threat` decision dispatch + `rank_threat` 控制流 fingerprint removed（零殘留;release scaffolding 留=gate-ok task-lifecycle）。measure=threat 率保(迎戰/備戰/求和/FLEE vs S2 similar)+preempt 保(忙碌隊仍應強威脅)+release 保(threat task 不卡死)+PRIO 黏性+gate 減。

## 非回歸
- **survival 保序**（絕境 FLEE/覓食 rank_scored boost 奪 argmax，不被 threat util 蓋）。
- **感知鐵律**（severity=belief，虛張/偽裝生效；禁讀 god-view 真戰力——winnable 用 self_armed（自知）× perceived power（belief 敵），不偷看敵真值）。
- **敗北出路**（逃/求和 outlet 在不可勝下 fire，連 [[project_desperation_economy]] 膽量秤）。
- **PRIO_THREAT 黏性**（收斂後 threat commit 不掉 70→50 失黏，seam#1 finding3）。
- **觀測**（S1 probe 先接，收斂後 threat dispatch 可量）。

## 閘
- **R② 建議異質框外審**（核心 redirect 大 arc，behavior 變，三對齊:blueprint 意圖×systems util×真統一）。重點審:可勝性公式（self_armed×perceived power 是否洩 god-view）、severity-scaling 是否足以收斂（break-top 需否）、三支方向是否忠實 blueprint 意圖、preempt 收斂後保。
- premise 坐實（逐 code:threat_react belief/capability pieces）→ R① 免。
- **measure=行為驗證非 byte-identical**（S1 除外）：備戰/迎戰/逃/求和 率 × 威脅嚴重度分層、winnable gating、survival 保序、感知鐵律（虛張案）、敗北出路。

## 溯源
seam#1 threat 收斂 FLAWED 結論（`specs/2026-07-17-seam1-control-flow-convergence.md` §R²）；blueprint threat-severity 裁定；`terms.gd:172-185`/`threat_assessment.gd:18-41`/`decision_context.gd:39,180,193`；[[project_unification_matrix]] 序3 threat-oracle；[[project_desperation_economy]] 膽量秤；[[feedback_full_transient_observability]] probe 先接。
