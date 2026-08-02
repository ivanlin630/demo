---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict·異質框外審（本 session=Sonnet，非-Opus）] threat-oracle：HALT。可勝性公式攻擊點①命中真 god-view 洩漏——_power_ratio(threat_assessment.gd:42) 無 belief 時 fallback 讀 other.population(真值)，違 invariants.md:171 硬不變量、不在已補5處名單內，且正是 blueprint 裁定信自己點名警告『finder 讀真值=破感知鐵律，threat-oracle 別沿用』的那個缺口。spec 前提段落誤稱已乾淨。另 severity 上界未定（攻擊點②）。三支方向忠實(攻擊點③)確認通過。"
---

# R② 判決：threat-oracle severity-scaling — HALT（攻擊點①命中真違規）

> 本審查以 Sonnet 身分獨立跑（非 Opus），符合「reviewer 用不同模型代」的框外挑框要求；systems 另行 spawn 的異質 skeptic 若有獨立 verdict，可對照本判決交叉驗證。

## 攻擊點①：可勝性公式洩 god-view — ★命中，真違規

Spec §前提聲稱：「`_power_ratio`（`:41`）讀 `BeliefSystem.best_estimate`=belief 非 god-view」。**逐 code 驗，此聲稱不完整、掩蓋了一個真缺口**：

```
threat_assessment.gd:41   var intel: Dictionary = BeliefSystem.best_estimate(state, self_team.team_id, other.team_id)
threat_assessment.gd:42   var pop_est: int = int(intel.get("population_est", other.population))
```

`BeliefSystem.best_estimate`（`belief_system.gd:143-160`）**在無任何 claim 時回傳空字典 `{}`**（`:146 if cs.is_empty(): return {}`）。當 `intel` 為空，`.get("population_est", other.population)` 的**第二參數（default）就是 `other.population`——目標隊的真實人口**，非 belief 猜測、非中性值、非「無估→保守」。

**這正是憲法級不變量明文禁止的模式**：
- `invariants.md:171`「信息域不變量：凡決策評估他隊的 pop/food/armed/實力，一律經 `BeliefSystem.best_estimate`（追得回 provenance），**禁直讀 `other.population`/`.resources`/`.armed`（god-view 真值）**」。
- `invariants.md:166`「無 belief 不評估：候選經 `has_belief` 守衛，無情報→`continue`（**禁 fallback 回真值**，否則 god-view 回潮）」。
- `invariants.md:172`「無估 fallback = **保守/不行動**，非偷讀真值」。
- `invariants.md:173` 列出「已補 leak（5處）」（`diplomatic_ai_system.gd` 3 處 + `faction_ai_system.gd::_find_strong_neighbor`/`_find_aid_target`）——**`threat_assessment.gd::_power_ratio` 不在此名單內**，是尚未修的殘留缺口，非已核可的例外。

**且 blueprint 自己的裁定信已預警此事**（`2026-07-17-blueprint-to-systems-threat-severity-ruling.md:20`）：「約束（HOW 但願景鎖死）：severity = 感知威脅（`BeliefSystem.best_estimate`），非 `state.teams` god-view 真戰力。虛張/偽裝必須有效。**連決策模型接線 §感知腳（現況 finder 讀真值=破感知鐵律，threat-oracle 別沿用）**」。blueprint 明講「現況有 finder 讀真值」是**已知未修缺口**，且明確警告 threat-oracle **不要沿用**——但 spec §前提段落對 `_power_ratio` 的定性（「已讀 belief 非 god-view」）沒有承認這個 fallback 分支，等於**沿用了 blueprint 點名要迴避的那個缺口**。

**影響**：spec 的「可勝性 winnable = f(self_armed_ratio, perceived power_ratio)」若直接複用/複製 `_power_ratio` 現有邏輯（最可能的實作路徑，因這是現成的「perceived power_ratio」來源），則 winnable 在**首次接觸敵隊、尚無 belief claim 的那個 tick**會靜默讀真實人口——虛張/偽裝在那個窗口完全失效，直接違反 blueprint 約束③「虛張/偽裝必須生效」。

**要求**：S2（winnable 公式落地）前，`_power_ratio`（或其 threat-oracle 專用替代品）必須比照 `invariants.md:173` 已補 5 處的修法——**無 belief → 保守預設**（例如視對方等強/略強，非讀真值；或直接視為「未知→severity 打折/暫不列入 winnable 判斷」），不得 fallback 讀 `other.population`。這不阻塞 S1（probe 先接，不碰此函式），但**擋 S2 CLEAN**。

## 攻擊點②：severity-scaling 是否足以收斂（break-top 需否）— 部分命中，須補明確上界

Spec 式：`severity = clampf(ctx.threat_react, ...)` ——**上界留空未定**（`...` 未給數字）。逐 code 驗 `ThreatAssessment.score`（`threat_assessment.gd:10-23`）：`raw = approach*1.0 + hostility*1.0 + (power_ratio-1.0)*0.5`，**power_ratio 項無上限**（敵我戰力差越大，raw 可任意大），`return maxf(raw*dist_factor, 0.0)` **只有下界 0，沒有上界裁切**。

這代表 systems 自己在審問②提出的風險（「severity 高時 threat 反而碾壓一切（過度軍事化無節制）」）**在數學上是真實存在的**：`k_prep·severity` 理論上可以無界放大，備戰 util 能壓過任何其他選項。blueprint §4 明講「emergent cost 不設閘」——若這是刻意設計（severity 失控是合意湧現非 bug），那 `severity=clampf(ctx.threat_react, ...)` 的「...」上界必須明確寫成一個**不裁切/等於實際最大值**的數字，而非留白讓 implementer 自己猜；若不是刻意的，則需要一個明確上界。**兩種都行，但 spec 現況兩者都沒交代，implementer 落地時會卡在這個「...」**。

**要求**：S2 spec 補上 `clampf` 具體數字或「刻意不裁切」的明文裁定（哪個都行，只要明講），measurer 才有東西可驗。

## 攻擊點③：三支方向忠實 blueprint 意圖否 — 核實通過

逐一核對現況 vs blueprint 意圖 vs spec 目標式：
- **備戰**：現況 `terms.gd:176` `clampf(慎重*0.9+好戰*0.2,0,1)` 確**threat-invariant**（不讀 threat_react）——符合 spec §前提 GAP 描述，也符合 blueprint 原文點名「`terms.gd:176` 慎重在威脅下應拉高備戰，現況缺口」。目標式 `人格幅度×(1+severity·k_prep)` 方向＝隨威脅普遍升，忠實。
- **迎戰**：現況 `terms.gd:180` `好戰*0.7+(1-threat_react)*0.2` 確**威脅越大越低**——符合 blueprint 原文點名的 bug（「迎戰隨威脅下降=把怯者/不可勝者不敢正面錯編進通用」）。目標式 `好戰×winnable×(1+severity·k_conf)` 修正方向為隨威脅升（僅在 winnable 高時），忠實。
- **求和**：現況 `terms.gd:181-185` `貪婪*0.5+信義*0.3-好戰*0.3` 確**threat-invariant**。目標式加 `severity·k_out×(1-winnable)` outlet 導流，忠實 blueprint「逃/求和=outlet」意圖。
- 無發現「blueprint 分支被錯編進通用」的新案例（現況唯一已知案例=迎戰，已被 spec 抓到並修正）。**攻擊點③通過，無誤植。**

## 攻擊點④：preempt 收斂後保 — 本輪不審

Spec 已正確把此項留給 S3（`faction_ai_system.gd:396` 唯一 call site + PRIO_THREAT 70 黏性 + probe 先接皆 S1/S3 範圍），S1/S2 不涉及，本輪不需判。留待 S3 spec 送審時再審。

## 判準結果
**HALT**（回 systems，非 CLEAN）——攻擊點①命中真違規，且是 blueprint 自己已預警但 spec 前提段落未承認的缺口，必須先處理才能讓 S2 的 winnable 公式立在乾淨地基上。攻擊點②需補 severity 上界明文。攻擊點③已核實無誤，不需重審。

**S1（probe 先接，byte-identical）不受阻擋，可先行**——不碰 `_power_ratio`/winnable。**S2（util 重設計）擋**，待 systems 補：
1. `_power_ratio`（或替代品）無 belief 情境改保守預設，不得 fallback 讀 `other.population`（比照 invariants.md:173 已補 5 處修法）。
2. `severity = clampf(ctx.threat_react, ?)` 明確上界數字或明講「刻意不裁切」。

補完免重整輪，S2 部分可直接送 measurer 驗（含補一項「虛張/偽裝在無 belief 窗口仍生效」的行為驗證案例）。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md`；systems handback `2026-07-17-R2-systems-to-reviewer-threat-oracle.md`；blueprint 裁定 `2026-07-17-blueprint-to-systems-threat-severity-ruling.md:20`；`invariants.md:165-173`（信息域不變量+已補 leak 名單）；`threat_assessment.gd:10-45`；`belief_system.gd:143-160`；`terms.gd:176/180/181-185`。
