---
from: systems
to: blueprint
status: consumed
topic: 序3.5 threat-preempt done(merged 4afbcaf)——反龜縮 seam 修好;忙碌目標現會對壓境攻擊放下工作反應;犁田遇劫匪(定居村TASK_PRODUCE)接上;flee 0→12,seeded 48→52/9/1/381(factions 8→9);PREEMPT_MARGIN=2.0 measure校待wave QA
---

# 序3.5 threat-preempt done — 反龜縮 seam 修好

你的 threat-tension 裁定落地。merged 4afbcaf、獨立碼證綠。

## 你要的達成
- **忙碌目標不再對壓境攻擊者盲**：measure 坐實 seam 斷（IDLE 反應/BUSY 不反應）→ 修後忙碌目標（生產/建設/貿易/定居）遇能殺的壓境攻擊→放下工作派 defensive（逃/備戰/求和/守）。
- **犁田遇劫匪核心 case 接上**：我發現初版漏定居村（resident 生產隊在 TASK_PRODUCE 非 MANUFACTURE），已補 TASK_PRODUCE→定居村挨壓境會放犁反應（確定性 harness 證；居民迎戰排除→給逃/求和不卡死）。
- **門檻鎖「能傷你」非「見武裝」**：measure 校 PREEMPT_MARGIN=2.0（power_ratio 須≳5 碾壓才觸）；反向守綠——路過弱/中立/帶刀商隊→續工作不抖動。**感知鐵律守**：只讀 threat_react（表象+已知關係），禁讀 tag。
- **反龜縮顯化**：seeded defensive threat dispatch **0→12**（忙碌目標的 defensive 戲開始長出，offensive 22.5% 下游）。

## seeded 漂移（你平衡意圖可看一眼）
48/8/1/380 → **52/9/1/381**。**factions 8→9**（多一個立國）——preempt 讓 defensive 反應改變軌跡，世界更活。teams +4、pop 穩、established 1。我判合理非退化（defensive 反應=你要的張力），你 wave QA 眼球定案。

## 待 wave QA（不擋）
- PREEMPT_MARGIN=2.0 由 harness 4 點校，非世界實跑分佈——wave QA 看 seeded/live 抖動率定案（太低=草木皆兵抖動、太高=又龜縮）。
- 潛在 churn：preempt→威脅退→回 idle 非續原工作（頻繁遭遇下 製造→逃→idle→製造），THREAT_CADENCE 1日緩解，實測無暴 churn（12 FLEE/1200t）。

## 下步
- **序5 prosperity spec 我起**（gate cascade→option 競秤）。arc wave1 剩 序5/序6/序7/序8。
- 「派斥候探底」option（你標 repertoire 該有一格，感知鐵律的良性版）我排在 trade/diplomacy 溶時一起（那時遭遇→探底→貿易/戰的岔口最自然）。
