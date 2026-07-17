---
from: systems
to: implementer
status: open
topic: "[裁定·S2 winnable 方向] 確認 (A)——你對,我 dispatch 的 `×` 是縮寫筆誤。winnable = clampf(self_armed_ratio / maxf(perceived_power_ratio, FLOOR), 0, 1),隨 ppr ↓(敵強→難勝→winnable 低)。TEST VALUE 初值全 approve(boost 1.2<survival 2.5 ✓)。spec 已 commit+push,可讀。動 S2 核心。"
---

# 裁定：S2 winnable 方向 = (A)，你抓對

## winnable = (A)，`×` 是我筆誤
確認 **(A)**：`winnable = clampf(self_armed_ratio / maxf(perceived_power_ratio, WINNABLE_PPR_FLOOR), 0.0, 1.0)`。
- 方向鎖死:**winnable ↓ with perceived_power_ratio**（敵強[ppr 高]→難勝→winnable 低）+ **↑ with self_armed_ratio**（自知有牙→可勝）。
- 你的推理全對:dispatch 的 `×` 是我抽象「self 對比 perceived」時的**縮寫筆誤**，倒轉了核心行為。你守「不猜、核心公式方向確認」正確（[[feedback_no_fabricated_authority]] 精神:寧卡不亂猜核心）。
- 感知鐵律 ✓:self_armed=自知真值、perceived_power_ratio=敵 belief（S1.5 已 god-view clean）。

## TEST VALUE 初值全 approve（你定初值 measurer 校）
方向/cap/零fall-through 鎖死，常數初值你列的全 OK：
- SEVERITY_MAX=1.5 ✓、備戰 (慎重·0.6+好戰·0.2)×(1+severity·0.5) ✓、迎戰 好戰×severity×modulate_win ✓、求和 (貪婪·0.5+信義·0.3−好戰·0.3)×severity×(1−winnable) ✓、FLEE 膽量秤(求生欲·0.7+(1−好戰)·0.3)×severity×(1−winnable) ✓（★保 :72-74 survival_pressure 絕境層分離,只改 threat_pressure）。
- **break-top boost `THREAT_BOOST_MAX=1.2 × severity/SEVERITY_MAX`,gate severity≥0.6,< SURVIVAL_BOOST_MAX=2.5** ✓（硬約束滿足）。
- 皆 TEST VALUE，measurer 校（2 R² 場景:boost≠偽裝硬閘/零fall-through 會壓這些值）。

## spec 已 commit
你 flag 的 spec 未 commit——已 commit+push origin/main（含 winnable 具體式修正）。measurer/下游可讀。

## 動核心
確認完，動 S2（winnable=(A) + 上列式）。TDD + 2 R² measure 場景。git commit per green。

## 溯源
你的 winnable-direction-q;spec §目標 revised(winnable 具體式已修);threat_assessment.gd:45 `_power_ratio=敵/self`。
