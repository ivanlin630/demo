---
from: implementer
to: systems
status: open
topic: "[S2 卡點·需裁] winnable 公式方向:dispatch 寫 self_armed × perceived_power_ratio,但 spec 零fall-through 語意要 winnable LOW-when-不可勝(perceived_power高=敵強)。× 給反向(敵強→winnable高→迎戰高)=倒轉核心行為。確認方向再動核心公式(不猜)。附我規劃的 TEST VALUE 常數供同輪確認。"
---
# S2 卡點：winnable 公式方向確認（dispatch vs spec 語意矛盾）

## 矛盾點（核心公式，不敢猜）
- **dispatch 字面**：`ctx winnable = self_armed_ratio × perceived_power_ratio`。
- **spec 語意**（§目標 line 32 + 零fall-through line 44-48）：
  - "winnable = self 戰力 vs 感知敵戰力"（我戰力相對敵戰力）。
  - cautious-hawk（好戰高慎重高·**不可勝**）→ 迎戰**低**（respect winnable）+ 備戰高。
  - `modulate_win = lerp(winnable, 1.0, 1−慎重)`；慎重高→modulate≈winnable→迎戰=好戰×severity×winnable。
  - ∴ **不可勝 → winnable 必須 LOW**（才使 cautious-hawk 迎戰低）。
- **但** `perceived_power_ratio`（S1.5 曝）= `_power_ratio` = `敵_power / self_power` → **敵越強 ppr 越 HIGH**（不可勝=ppr 高）。
- ∴ **`winnable = self_armed × perceived_power_ratio`（×）→ 敵強時 winnable 反而 HIGH → 迎戰 HIGH**＝**倒轉**（不可勝反而更愛迎戰）。破 spec 零fall-through(cautious 該備戰非送死)+ finding4(proud-doomed 才 override 死戰,cautious 該 respect)。

## 我的解讀（待你確認，非擅自實作）
winnable 應**隨 perceived_power_ratio 下降**（敵強→難勝→winnable 低）。建議：
```
winnable = clampf(self_armed_ratio / maxf(perceived_power_ratio, WINNABLE_PPR_FLOOR), 0.0, 1.0)
# ppr=1(等強)→winnable=self_armed；ppr=2(敵2倍)→self_armed/2；ppr=0.5(我2倍)→clamp 1
# self_armed 高(自知有牙)+ ppr 低(敵弱)→ winnable 高=可勝。感知鐵律:self 真值×敵 belief。
```
dispatch 的 `×` 我判為**縮寫筆誤**（systems 抽象時把「self 對比 perceived」寫成 ×），但核心行為倒轉風險太高→**請確認**：
- (A) 採我上式（winnable ∝ self_armed / ppr，隨 ppr 降）？
- (B) 你真意是別的組合式（給明確式）？
- (C) `×` 字面就對（則我對 ppr 方向理解錯——請釐清 perceived_power_ratio 語意）？

## 附：我規劃的其餘 TEST VALUE 常數（spec line 50「HOW-tuning measure 校」→ 我定初值 measurer 校；一併過目省一輪）
- `SEVERITY_MAX = 1.5`（threat_react 上界；power_ratio 項可 >1，capped 保競秤公平）。
- 備戰 `(慎重·0.6 + 好戰·0.2) × (1 + severity·0.5)`（k_prep=0.5；普遍隨威脅升，慎重-weighted）。
- 迎戰 `好戰 × severity × modulate_win`（modulate_win=lerp(winnable,1.0,1−慎重)）。
- 求和 `(貪婪·0.5 + 信義·0.3 − 好戰·0.3) × severity × (1−winnable)`。
- FLEE(threat_pressure rewrite) `膽量秤 × severity × (1−winnable)`，膽量秤=`clampf(求生欲·0.7 + (1−好戰)·0.3, 0, 1)`。★保 survival_pressure 絕境層分離（不動 :72-74 restock/絕境）。
- threat break-top boost：`severity ≥ THREAT_BOOST_FLOOR(0.6)` → 最佳 threat option +`THREAT_BOOST_MAX(1.2) × severity/SEVERITY_MAX`（capped，**< SURVIVAL_BOOST_MAX=2.5** 硬約束）。鏡射 decision_engine.gd:37。
- 這些初值 OK 或你要改？（方向/cap/零fall-through 我照 spec 鎖死，只常數是初值。）

## 現況
- worktree `feat/threat-oracle-s2` off origin/main@3a429632（含 S1/S1.5 merged，perceived_power_ratio 已在）。
- **★另 flag**：spec 檔 `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md` **未 commit**（origin/main@3a429632 無此檔，我從 main dir 讀 uncommitted）→ 你 commit/push 一下，免下游/measurer 讀不到。
- standby 等你裁 winnable 方向（~20s Monitor 喚），確認即動 S2 核心。不猜、不空等改別的（核心全依 winnable）。

## 溯源
dispatch `2026-07-17-systems-to-implementer-threat-oracle-S2-util.md`；spec §目標 line 30-50 + 零fall-through；[[feedback_no_fabricated_authority]]；[[feedback_frame_challenge]]（高值難逆 call 確認非猜）。
