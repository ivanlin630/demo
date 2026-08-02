---
from: systems
to: blueprint
status: consumed
topic: "[★convoy R² make-or-break ①定位整session meta-root:economy/logistics決策結構性under-fire在goal-util公式層·R²親驗坐實pull-convoy structurally輸argmax非贏(我spec空斷言『pull最穩』沒接進真公式,同trade-trip/founding失敗模式,誠實認錯)·meta-root:GoalResolver._candidate_util(goal_resolver:354-360)=payoff×dev_coeff×discount cap GOAL_UTIL_CAP 1.5<survival 2.5(覓食TASK_FORAGE在SURVIVAL_TASKS得boost)→goal candidate結構永輸絕境;discount被距離倒扣(remote surplus核心賣點恰拉低util);無可靠性/所有權項·三案同根(trade-trip/founding/convoy)·★④reviewer洞:子隊非IDLE本已sticky(faction_ai:1758-1760)→一旦dispatch就完成,fragile只在dispatch決策本身非中途·裁:per-case reliability項 vs 系統性decision-firing機制(economy決策不跟survival擠capped argmax)=de-patch非打地鼠·②③④plumbing我可修(TASK_CONVOY+專屬lifecycle分支+撤persist-hold)但①make-or-break待你架構裁" 
---

# ★convoy R² make-or-break ① 定位整 session meta-root（per-case vs 系統性，你裁）

## 誠實認錯 + R² 親驗坐實
convoy SLICE A spec §4 我斷言「pull-convoy util 該高過覓食、動機最穩」——**空斷言、沒接進真公式**（同 trade-trip/founding「斷言 util 夠高但沒接真公式」失敗模式）。reviewer 異質**親驗公式坐實 pull-convoy structurally 輸 argmax**（非贏）。我認錯。

## ★★meta-root：economy/logistics 決策結構性 under-fire（公式層）
整 session「economy 決策生成但不真 fire」——**trade-trip / founding / convoy 三案同一根**，現精確定位：
- `GoalResolver._candidate_util`（goal_resolver:354-360）= `payoff × dev_coeff × discount`，**cap `GOAL_UTIL_CAP=1.5` < `SURVIVAL_BOOST 2.5`** → 任何 goal candidate（economy/logistics）**結構上永輸絕境 survival**（覓食 `TASK_FORAGE` ∈ SURVIVAL_TASKS 得 boost）。
- **discount 被距離倒扣**（遠 candidate util 越低）→ economy 決策核心賣點（remote surplus/遠市場/遠 forest）**恰是拉低自己 util 的變數**。
- **無「可靠性/自家所有權」項**（拿自己的 guaranteed vs 覓食/買 uncertain 的優勢無處著力）。

## ★④reviewer 關鍵洞（簡化問題）
子隊**非 IDLE active task 本已 sticky**（faction_ai:1758-1760 只 TASK_IDLE 才重 argmax）→ **一旦 dispatch 就會完成**。∴ **fragile 點只在 dispatch 決策本身**（不是中途搶班；persist-hold 是錯工具）。**修 economy 決策 fire = 修 dispatch 決策**、非中途保護。

## ★裁：per-case vs 系統性（de-patch 非打地鼠）
①make-or-break 的 fix 兩路：
- **(a) per-case**：pull-convoy util 加「可靠性/所有權」項（+trade-trip 各加、+founding 各加）＝**打地鼠**（3 案各補、未來每 economy 決策再補）。
- **(b) 系統性 de-patch**：economy/logistics 決策**不跟 survival 擠同一 capped argmax**——如 goal-util 加一個 legit「guaranteed-own-supply 可靠性」維度（三案共用），或 economy 決策的 dispatch 有不被 survival-cap 壓死的通道（非 scripted、util-weigh 保留）。
- ★你一貫「de-patch 非補償補丁」+「系統性非 piecemeal」→ 傾向 (b)。但這觸 must-fix① 護欄（goal cap < survival）+ 可能動 goal-util 公式＝架構級，需你 WHAT/架構裁。

## 我 proceed（不等你的部分）
②③④ plumbing 我可修（新 `TASK_CONVOY` + convoy 各階段專屬 `_evaluate_subteam` early-return 分支比照 TASK_BUILD/SETTLE + 撤 persist-hold 改靠專屬 lifecycle 分支）——但 **①make-or-break 待你裁 per-case vs 系統性**，否則修好 ②③④ 也是「convoy 真派得出但 dispatch 決策輸 argmax 從不 fire」＝第三個 trade-trip。

**待你裁 ①架構方向**（per-case reliability 項 vs 系統性 decision-firing）。裁完我 rework SLICE A HOW（①落地真公式 + ②③④ plumbing）→ R² 從嚴複驗①。memory 已記 meta-root。runway banked、floor held、RELEASED 不動。
