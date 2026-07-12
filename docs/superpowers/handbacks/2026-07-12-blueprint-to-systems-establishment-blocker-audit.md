---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] de-patch merge後established仍恆0——立國真根未解,farming死鎖只是貢獻因子非唯一根，需下一層file:line
---

# established恆0 —— 下一層真根待查（de-patch merge後）

## 背景
de-patch建造權（`feat/depatch-build-rights` @fdbeacb）驗收CLEAN：獨立隊farming死鎖確實解開（0/7→5/12），attrition改善(-6~9pp)，存活人口1.3-2倍。**但12月深度對照，established（立國）兩個seed全年恆0，完全沒變**（見`depatch-build-rights-acceptance.md`）。

**de-patch 解的是「獨立隊能不能餵飽自己」，不是「世界能不能立國」——farming死鎖只是攔路石之一，非立國全根。**

## 待查（零跑，file:line）
原始死鎖分析提過建國兩門：
1. **累積建國門**：需7日食物盈餘（`2026-07-12-HANDOFF`提及，麻煩查確切常數/門檻位置）。
2. **征服建國門**：需戰力打贏。

de-patch後獨立隊能蓋farm了，但established仍0——追問：
- 累積門的「7日盈餘」在改善後的存活曲線下，實際有沒有達到過？還是**門檻本身不只food**（例如還卡pop數/material/tick timing/某cadence）？請查`_evaluate_independent_strategy:1109`附近建國判定的**完整條件清單**（非只food一項）。
- 若food已非瓶頸但established仍0——真根可能在其他前置（人口門檻/material門檻/事件觸發窗/與其他隊的距離判定等），需 file:line 逐條列出「建國需要同時滿足的所有條件」，如同之前建造條件表的做法。
- 是否有「時間常數過長」問題——例如7日盈餘要求在12個月窗內本來就難達成（tick cadence/評估頻率過慢），使得就算食物解了，建國仍來不及觸發。

## 為何現在查（非緩）
用戶主線=修「玩家世界從沒活過」，de-patch只是地基第一塊。若不追下一層真根，下輪brainstorm會失焦。且measurer已標記「經濟長程診斷（月1急性危機+月10二次惡化週期）仍待查」——這兩條線（建國門檻 + 長程週期）可能共享同一結構性根因（時間常數/評估cadence過慢），值得一起看。

## 序
零跑純讀出完整建國條件表 to:blueprint → 我看清楚 → 待用戶裁下一步方向（是否比照這輪流程：brainstorm→對抗→spec→build→測）。
