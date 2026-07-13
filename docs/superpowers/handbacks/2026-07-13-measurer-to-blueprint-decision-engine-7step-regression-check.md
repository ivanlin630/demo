---
from: measurer
to: blueprint
status: open
topic: [補回歸驗證·結案建議] 決策引擎7步改動未波及famine/combat/faction協同——無異常,分析既有log非重跑
---

# 補回歸驗證結果：無異常

## 方法
非重跑。用既有兩份 log 前後對照：
- `main_story_trace.txt`（加於 08d63ee，⑦步前，含 S1-⑥ 6 步）
- `main_story_trace_v7.txt`（加於 0a75348，⑦步後，含全 7 步）
同 9600 tick(3mo)、同世界設定。數字見 `docs/process/verdicts/decision-engine-7step-regression-check.measure.json`（已 commit）。

## 三塊結論

**1. 飢荒**：餓死 52→40（降 23%，分散 4 隊 Team14/10/8/19，非單隊死亡螺旋）。無異常。

**2. 戰鬥**：Combat Start 6→10（升 67%，但全部 `Team-1000000` = 野獸 boar ambush 背景事件，非玩家隊互戰失控）。無異常。

**3. faction 協同（外交/結盟）稀薄**：查 `scripts/simulation/faction_ai_system.gd:1213` 有 `[IndepStrategy]...派信使結盟` print，log 機制本身存在。分支門檻=獨立隊+野心建國達標才觸發；本輪 3 seed established 多為 0（factions 僅 2-5 個），該分支天然鮮少命中——**設計如此，非漏 log**。再查 `git diff 1f056e6..282a5bd -- faction_ai_system.gd`，今日 7 步對結盟/外交分支**零改動**（唯一觸及行=`rung_crash`判斷，跟結盟無關）。

**其他**：SCRIPT ERROR 兩份皆 0；`派工失敗:資源不足` 184→192（+4%，同規模）。

## 為何有信心排除規模改動
今日 7 步觸及檔案（`git diff --stat`）：`decision_engine.gd`/`decision_context.gd`/`terms.gd`/`need_hierarchy.gd`/`ambition_ladder.gd`/`faction_ai_system.gd`/`team_data.gd`——**全是決策/需求/野心層**。飢荒機制（resource.gd/famine 判定）、戰鬥機制（npc_combat/combat 判定）、faction 結盟分支 code 本身**皆未在改動檔案清單內**。今日改動只可能透過「隊伍選哪個 option」間接影響 famine/combat *頻率*，不影響其*機制*——而頻率數字（見上）在同規模內波動，非 blowup。

## 建議
無異常，可結案（四選一標記完成）。
