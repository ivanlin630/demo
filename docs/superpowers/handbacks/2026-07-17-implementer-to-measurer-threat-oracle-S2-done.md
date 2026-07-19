---
from: implementer
to: measurer
status: consumed
topic: "[threat-oracle S2 交付·行為變大] threat util severity-scaled 重設計(備戰/迎戰/求和/FLEE)+ winnable modulate + break-top boost(ramp-from-floor,capped<survival)。零 fall-through 四象限 char 綠 + 2 R² 場景綠。branch feat/threat-oracle-s2 HEAD d5a83163 off origin/main@3a429632。★非 byte-identical=行為驗證:請中性複核四象限率×severity分層/winnable/survival保序/感知鐵律/2 R² 場景。winnable 方向 systems 已裁(A)。"
---
# Hand Back：threat-oracle S2 severity-scaled threat util（行為變大）

**branch** `feat/threat-oracle-s2`（已 push）**HEAD `d5a83163`**，off origin/main `3a429632`（含 S1/S1.5）。

## 實作摘要（spec §目標 revised）
- **`decision_context.gd`**：加 `ctx.winnable = clampf(self_armed_ratio / maxf(perceived_power_ratio, WINNABLE_PPR_FLOOR), 0, 1)`（隨 ppr↓；★systems 裁定 (A) 方向，dispatch 的 `×` 是筆誤）。感知鐵律:self 真值×敵 belief。
- **`terms.gd`** 4 threat term 重設計（severity=`clampf(threat_react, 0, SEVERITY_MAX=1.5)` CAPPED）：
  - **備戰** `(慎·0.6+好·0.2)×(1+sev·0.5)`（普遍隨威脅升，慎重-weighted）。
  - **迎戰** `好戰×sev×lerp(winnable,1,1−慎重)`（慎重高 respect winnable / 慎重低 override=魯莽死戰）。
  - **求和** `(貪·0.5+信·0.3−好·0.3)×sev×(1−winnable)`（outlet）。
  - **★FLEE=threat_pressure rewrite（finding5，:75-80）** `膽量秤(求生欲0.7,(1−好戰)0.3)×sev×(1−winnable)+panic×0.4`（保 threat gate + survival_pressure 絕境層分離不動）。
- **`decision_engine.gd` break-top boost**（finding3 單term-多term）：`threat_react≥THREAT_BOOST_FLOOR(0.6)` → THREAT_OPTION_SET +boost **ramp-from-floor**（剛過 floor→≈0，→SEVERITY_MAX→MAX=1.2）**capped < SURVIVAL_BOOST_MAX(2.5)**。鏡射 survival boost。
- 常數全 TEST VALUE（systems approve；measure 校）。

## ★零 fall-through 四象限（char bed 12/12 全綠）
`scripts/debug/threat_oracle_s2_test.gd`（手構 ctx→rank_scored_ctx 統一路含 boost）：
- **proud-doomed**(好戰高慎重低·不可勝)→**迎戰**(reckless override 死戰)✓
- **cautious-hawk**(好戰高慎重高·不可勝)→**備戰**(respect winnable,迎戰低)✓
- **coward**(好戰低求生欲高)→**FLEE/survival**(膽量秤)✓
- **weak-pragmatic**(好戰低求生欲低貪婪信義高)→**求和**✓
- + severity-scaled(備戰升)/winnable-modulate(cautious respect vs reckless override)/FLEE 讀 winnable/severity capped。
- **★2 R² 場景**：(1) **boost≠偽裝硬閘**:中 severity+決定性貿易機會→**貿易勝**(threat 非恆勝)✓；(2) **真零 fall-through**:極端全低人格向量→仍主導 threat response✓。
  - ★**ramp-from-floor 修**:初版 boost=severity/MAX 使中 severity 也碾非-threat（R²(1) 抓到=偽裝硬閘）→改 ramp `(sev−FLOOR)/(MAX−FLOOR)`，中 severity boost≈0 修正。

## 驗證
- **constitution_gate PASS sites=65 removed=0**（boost 的 `≥FLOOR` threshold 在 rank_scored_ctx 已有 survival boost 同 fingerprint；terms/context 加項非 dfunc/rng→零新 fingerprint）。
- **full headless**：`=== DONE ===`；**3 pre-existing baseline**（15529/7075/13979，無新增）。★**2 舊公式測遷移**（S2 behavior 變）：`_test_t5_intra_layer`(prepare base 0.7→0.5+梯度) + `_test_flee_threat_gate`(rewrite 新 threat_pressure 讀 winnable/panic)。
- **threat_dissolution_check ALL PASS**（★遷移:`_mk_ctx` 設 winnable=0.1 不可勝前提 + PACIFY archetype→真 weak-pragmatic 低求生欲0.2/低慎重0.2 使求和主導；DEFEND/PREPARE/FLEE/居民守衛/unified/rate 皆綠）。
- **survival 保序**：`reaction_dissolution_check:80-99` **ORDER gate 綠**（真絕境 2.694 > panic-only FLEE 0；threat boost 1.2 < survival 2.5 保序）。
- ★**reaction_dissolution 另 1 FAIL=pre-existing**（`潰散隊未出 FLEE`，team_panic 未接入決策）——**baseline 3a429632 同 FAIL**（非 S2；panic-only 無 threat→threat_pressure gate 返 0，新舊皆然）。

## 待確認 / 下一站（★measurer 行為驗證，非 byte-identical）
- 四象限 dispatch 率 × severity 分層、winnable gating（虛張案:winnable 用 self 真值×敵 belief 不偷看敵真戰力）、survival 保序、感知鐵律、**2 R² 場景**（boost≠偽裝硬閘 / 真零 fall-through）、severity capped（threat 不無限碾 trade）。
- seeded delta 合理判（threat 反應行為變大，非大回歸；four-quadrant 覆蓋）。
- 綠 → to:systems 判 merge。**S3 收斂 + preempt 明確化待 S2 merged 後 dispatch**（rank_threat 退役→threat 進 rank_scored 全 pool；含 rank_threat 硬編 survival 統一到 threat_pressure=finding5 收官）。
- **★flag（S3 相關）**：rank_threat 的 survival(FLEE) 仍**硬編**`求生欲×0.8+(threat_react−0.5)×0.3`（未讀 winnable/膽量秤）——S2 只改 term 公式，rank_threat survival 待 S3 收斂到 threat_pressure。interim rank_threat 用新非-survival term + 舊硬編 survival（threat_dissolution 已遷移涵蓋）。

## 溯源
dispatch `2026-07-17-...S2-util.md`；systems winnable 裁定 `...S2-winnable-confirm.md`(A)；spec §目標 revised + 零fall-through + 2 R² 場景；`terms.gd:75-80/172-185`；`decision_engine.gd:37`；[[project_desperation_economy]] 膽量秤；[[feedback_frame_challenge]]（R² 異質框外審值回票價，boost ramp 修=R² 測抓）。
