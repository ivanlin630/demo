---
from: systems
to: implementer
status: consumed
topic: "[dispatch·threat-oracle S2·util 重設計·行為變大] R² CLEAN(6 findings 解+blueprint 補裁)。terms.gd 備戰/迎戰/求和/FLEE(★含 :75-80 threat_pressure)改 severity-CAPPED + winnable-modulate(lerp 非硬gate,慎重-override 魯莽死戰) + threat break-top boost(capped,<survival)。ctx winnable=self_armed_ratio × perceived_power_ratio(S1.5 已曝)。零 fall-through 不變量。measure=行為驗證(2 具體場景:boost≠偽裝硬閘/真零fall-through)。worktree feat/threat-oracle-s2 off origin/main@3a429632。"
---

# threat-oracle S2：threat util severity-scaled 重設計（行為變大）

## scope（讀 spec §目標 revised + §交付切片 S2 全文）
spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md`。core=`terms.gd` threat util 重設計 per §目標式：
- **severity = `clampf(ctx.threat_react, 0, SEVERITY_MAX)`**（★CAPPED=零殘留硬要求,uncapped=偽裝硬閘）。saturating,速率可人格化(神經質高估)=HOW-tuning。
- **winnable = f(self_armed_ratio, ctx.perceived_power_ratio)**（S1.5 已曝 perceived_power_ratio,clean;**禁拿 threat_react 當 proxy**）。[0,1]。
- **備戰** `(慎重·a+好戰·b)×(1+severity·k_prep)`（普遍隨威脅升）。
- **迎戰** `好戰×severity×modulate_win`,`modulate_win=lerp(winnable,1.0,1−慎重)`（慎重高 respect winnable/慎重低 override=魯莽死戰）。
- **求和** `(貪婪·c+信義·d−好戰·e)×severity×(1−winnable)`（outlet）。
- **★FLEE=rewrite `terms.gd:75-80 threat_pressure`**（finding5,非只改 :176/180/184）→ `膽量秤(求生欲,1−好戰)×severity×(1−winnable)` 意圖（保 survival_pressure 絕境層分離,threat_pressure 是 threat-repertoire FLEE)。
- **★threat break-top boost（REQUIRED,解單term-多term）**：severity≥THREAT_BOOST_FLOOR 時最佳 threat option 得 additive boost ∝ severity,**capped 且相對強度 < survival boost（`SURVIVAL_BOOST_MAX=2.5`）**（threat 不必然勝,極佳機會可 edge 過）。鏡射 `decision_engine.gd:37` survival boost 模式,gate on threat_react floor。

## ★不變量（spec 須落地驗）
- **零 fall-through**：四象限各有主導(proud-doomed→迎戰死戰/cautious→備戰/coward→逃/pragmatic→求和)。
- **感知鐵律**：winnable 只吃 self 真值(自知)+ 敵 belief(perceived_power_ratio),虛張生效。
- **survival 保序**：`reaction_dissolution_check.gd:80-99` 真絕境>panic-FLEE 不被 threat util 破。
- **不碰收斂**（S3 才退役 rank_threat/收斂進 rank_scored）。本 slice 只改 util 公式+boost（threat 仍走現 dispatch 路,util 變）。

## TDD + measure（★2 R² 場景必列）
1. char bed 各人格象限 util（proud-doomed/cautious/coward/pragmatic + 各 severity 分層）→ 驗方向+零 fall-through。
2. **★measure 場景(1) boost≠偽裝硬閘**：中等 severity + 決定性非-threat 機會(高值貿易/建國臨門)→ 非-threat 選項**偶爾仍勝**(非 threat 恆勝)。
3. **★measure 場景(2) 真零 fall-through**：極端全低人格向量(慎重≈好戰≈貪婪≈信義≈求生欲≈0)壓力測試 or 引 `person_generator.gd` 人格 floor 佐證退化象限架構不可達。
4. survival 保序(引 reaction_dissolution_check:80-99)+ 感知鐵律(虛張案)+ 迎戰隨威脅升(winnable 高)/備戰普遍升。
5. git commit per green。

## 完成 → 下一站
done+綠 → to:measurer(行為驗證:4 象限主導/2 R² 場景/survival 保序/感知鐵律/severity capped;非 byte-identical=行為變合理判準,同 S1.5)。measurer 綠 → to:systems 判 merge。**S3 收斂待 S2 merged 後 dispatch**（+preempt 明確化,seam#1 finding4;含 R④ preempt 收斂後保審）。

## 溯源
threat-oracle R² CLEAN;blueprint 補裁;spec §目標 revised;`terms.gd:75-80/172-185`;`decision_engine.gd:35-39`;`decision_context.gd`(perceived_power_ratio/self_armed_ratio);`reaction_dissolution_check.gd:80-99`;[[project_desperation_economy]]。
