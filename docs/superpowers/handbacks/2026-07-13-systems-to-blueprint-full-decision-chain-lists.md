---
from: systems
to: blueprint
status: open
topic: [完整清單·零跑] 決策鏈四表:intent選單6項/rung0-4/milestone累進表/archetype 3型—視覺化用,file:line齊
---

# 決策鏈完整四清單（file:line，視覺化用）

## ① 目標錨 = 戰略 intent 選單（`select_strategic_intent:870` + `_intent_scores`/`_intent_why:891`）
argmax 全菜單。前 4 項基礎（`AmbitionLadder.disposition_scores:32-35` + faction viability 疊加），後 2 項條件觸發：

| intent | 分數公式（人格驅動） | 觸發條件 | 需 target |
|---|---|---|---|
| **守成** | base 0.25 | 恆在（無強驅動預設） | 否 |
| **征服** | 野心×0.4 + 好戰×0.4 − 義氣×0.4 | 有 viable 弱敵（belief 打得贏 + readiness≥ATTACK_MIN 0.75） | ✓ |
| **致富** | 貪婪×0.6 + 野心×0.1 | 恆在 | 否 |
| **防衛** | 慎重×0.4 + 義氣×0.2 | 恆在 | 否 |
| **建國** | = found_score（累積+路徑+人格 caller 折入） | **僅 fid==−1 + can_found**（野心≥0.55+pop≥8+7日食盈餘+可達盟） | 否 |
| **擴張** | 0.3 + 野心×0.3 | **武力 archetype + rung≥EXPAND + 有 target**（領土 pressure 包圍） | ✓ |

（faction 版 `_select_intent:902` 同選單,補 viability/hysteresis;獨立版 `_evaluate_independent_strategy:1197` 用同 `select_strategic_intent`。**注意:立國非 intent**——它是分離機械 gate `faction_ai:974`，不在此 argmax，見前 established 查。）

## ② rung 0-4 定義（`ambition_ladder.gd:3-7`）
| rung | 常數 | 名稱 | 野心 cap 門（`derive_cap:54`） |
|---|---|---|---|
| 0 | RUNG_SURVIVE | 生存 | （地板，恆可達） |
| 1 | RUNG_ACCUMULATE | 積累 | 野心 <0.3 封頂此 |
| 2 | RUNG_EXPAND | 擴張 | 野心 0.3–0.55 封頂此 |
| 3 | RUNG_STATE | 立國 | 野心 0.55–0.8 封頂此 |
| 4 | RUNG_HEGEMON | 稱霸 | 野心 ≥0.8 封頂此 |

（`ambition_cap` = 野心決定終極能爬多高;實際 rung = milestone 達成爬升，capped by cap。）

## ③ milestone 完整表（`milestone_met:S1 merged` + 常數 `:18-21`）——累進條件
「夠格在 rung N」的條件（高階含低階，全維度）：

| rung | milestone 條件（累進） | 常數 |
|---|---|---|
| 0 生存 | 恆 true（地板） | — |
| 1 積累 | **food_flow_avg ≥ 0.5** | ACCUMULATE_FLOW_MIN=0.5 |
| 2 擴張 | ＋ **pop ≥ 8** | EXPAND_MIN_POP=8 |
| 3 立國 | ＋ **faction teams ≥ 2** | STATE_MIN_FACTION_TEAMS=2 |
| 4 稱霸 | ＋ **faction teams ≥ 4** | HEGEMON_MIN_FACTION_TEAMS=4 |

（**只 3 維度**：food_flow / pop / faction 規模。無其他隱藏維度。升=`milestone_met(rung+1)`，降=連續 K 次失守 `milestone_met(current)`，S1 事件驅動。）

## ④ archetype 完整清單（`ambition_ladder.gd:9-11` + `derive_archetype:40`）——3 型
由 `disposition_scores` argmax 映射（人格導出）：

| archetype | 常數 | 由哪個 disposition 勝出 | 行為傾向 |
|---|---|---|---|
| **武力** | ARCHETYPE_FORCE | 征服 勝 | 練兵/征服/擴張（可選擴張 intent） |
| **商業** | ARCHETYPE_TRADE | 致富 勝 | 貿易/囤積 |
| **定居** | ARCHETYPE_SETTLE | 防衛 或 守成 勝 | 生產/建設（能立國路） |

（平手序 **武力 > 商業 > 定居**（`derive_archetype:45` 等分先 FORCE）。3 型窮盡——非「商隊/定居/子隊/獨立野心」那種混合口語分類，那是 archetype × 隊形式（parent/faction/fid）交叉的描述，**基礎 archetype 只此 3 型**。）

## 視覺化補充（決策鏈全貌串接）
```
人格值(野心/貪婪/好戰/慎重/義氣) 
  → disposition_scores(守成/征服/致富/防衛) → argmax → archetype(武力/商業/定居) + ambition_cap(rung 上限)
  → milestone_met 事件驅動 → rung 0-4(生存→積累→擴張→立國→稱霸)
  → derive_plan_phase(缺口:糧/人/勢) → plan_phase(求糧/成長/聚勢/立國) → plan_phase_drive 偏置 option
  → select_strategic_intent(argmax 6 intent) → 行動
  → rank_scored(唯一求解器:intent_fit + plan_phase_drive + train_drive + survival + threat…) → option
（立國 = 分離機械 B-gate,不在 intent argmax,立國-redesign 待填 ESTABLISH phase 空偏置）
```

## 序
- 四表交你更新視覺化。**S4 續不受影響。**
- 記入 [[project_established_chain]]（決策鏈全貌串接圖）。
