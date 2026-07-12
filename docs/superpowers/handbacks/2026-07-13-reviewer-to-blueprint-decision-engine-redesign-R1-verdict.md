---
from: reviewer
to: blueprint
status: consumed
topic: [R①verdict/框外] 決策引擎架構重構 = issues，四框外疑慮全成立，打回大幅簡化範圍
---

# R①對抗 + 框外挑框 verdict — 決策引擎架構重構（需求金字塔）

## verdict: issues（非premise_contradiction，架構範圍嚴重超支，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "候選池「真篩選」（真的排除不相關option，非只加分）是本次架構的核心機制之一",
      "file_line": "specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md:49,64",
      "truth": "疑慮成立，且是最危險一項。§驗收（:64）把「征服intent下幾乎不選貿易」當正向驗收指標，等於把硬gate寫進驗收準則。這與本專案反覆修過的「硬gate→某條件永遠不fire」同構bug（本session已見多次：worldgen §3全域地板漏項/defarm-depatch呼叫端結構/establishment B門硬AND閘死鎖——皆是「條件過不了=永遠不可能」的變體）。把gate改名叫「候選池」不改變其僵化本質——急需某排除option救急卻結構性選不到的死鎖，架構上保證會發生。"
    },
    {
      "claim": "威脅/安全需求「不是外掛插斷系統，是金字塔裡一層，用同一套主腦邏輯判定」",
      "file_line": "specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md:32,36",
      "truth": "自相矛盾成立。既有`_evaluate_survival`是PRIO_SURVIVAL繞過argmax的插隊機制（TaskArbiter priority-gate，非rank_scored內競秤）。spec要嘛拆掉PRIO_SURVIVAL整併進金字塔（範圍碰到TaskArbiter優先權結構，遠超spec自稱的『決策term層』改動），要嘛保留插斷（則『非外掛』的主張是嘴上整合手上留外掛）。spec通篇沒交代這個拆解，且:36讓威脅走EWMA累積——與『車子突然衝過來要立即反應』的緊急語意直接衝突（累積=延遲，跟即時插斷矛盾）。範圍被嚴重低估。"
    },
    {
      "claim": "既有機制可直接複用：EWMA趨勢+crash-bypass（rung機制）複用給needs金字塔active層判定",
      "file_line": "specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md:19,35-36 vs ambition_ladder.gd（S1 rung事件驅動邏輯）",
      "truth": "概念不匹配，非真複用。EWMA+crash-bypass原為單一遞增整數（rung階梯，0~4一條線性尺）的漸進/劇變判定設計；needs金字塔是多層同時存在、需要選哪層主導的優先序判定問題，形狀根本不同——『趨勢窗』機制無法直接產出『當前active需求層是哪個』這個判定核心，需要重新設計判定邏輯，非複用既有函式。"
    },
    {
      "claim": "found_score/weak_enemy可直接複用當「賭命跳關」的通用目標價值判準",
      "file_line": "specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md:41 vs faction_ai_system.gd（found_score/_conquest_viable既有語意）",
      "truth": "答非所問的偽複用。found_score/weak_enemy是『建國』/『打弱敵』情境專用分，硬套成『任意上層需求追求標的的通用價值判準』是語意飛躍——例如賭命跳關想跳去『歸屬（結盟）』層時，found_score根本不衡量結盟標的的價值。看似省工，實則概念錯配，需另設計。"
    }
  ],
  "note": "本reviewer自查premise 1-3（file:line）+ 異質框外審（別模型代跑，refute-by-default）四疑全數成立。premise本體（1-3，見下）大致坐實，問題出在架構設計本身的範圍蔓延與複用可信度，非事實造假。" }
```

## 本reviewer自查：premise 1-3（file:line）

1. **「N個獨立term瞎子投票，只在最後加總」——部分成立，需訂正措辭**：讀完整`terms.gd`（254行全文），確認每個term函式**不互相呼叫、不讀彼此的eval()輸出**——這點精確成立。但spec的強論述「每個term各自從原始世界資料獨立推導」**略為誇大**：實際上多個term（`intent_fit`讀`ctx.intent`、`plan_phase_drive`讀`ctx.plan_phase_drive_map`、`join_drive`讀`ctx.best_protector_rep`、`absorb_drive`讀`ctx.resource_slack`/`ctx.absorb_yield`）消費的是**共享`gather()`階段預先算好的衍生欄位**，非各自從零散原始資料獨立推導。真正吻合spec舉例症狀（「征服intent跟成長phase各自獨立算，沒人協調」）的具體斷言在premise②，那個是精確的。

2. **「select_strategic_intent跟derive_plan_phase各自獨立算，沒人協調」——精確坐實**：`decision_context.gd:119-130 derive_plan_phase`函式體只讀`team.parent_team_id`/`team.food_flow_avg`/`team.population`/`team.faction_id`+成員數，**零處讀取`ctx.intent`或`f.intent`**。`c.intent`（`:269,273`）在同一`gather()`內由`FactionAISystem._solo_type`/`fi.intent`設定，與`plan_phase`是兩條完全獨立、互不參照的計算路徑。claim精確。

3. **「統一決策框架歷史上只解決『不要有第二引擎』，非語意統一」——坐實**：查`2026-07-10-consolidation-unified-decision-design.md`本體，其宣稱範圍明確是「核心驅力統一於rank_scored效用秤...收進rank_scored真term秤」，即避免hardcoded/flat/bespoke機制在rank_scored之外競爭，非任何語意層協調的宣稱。claim精確。

## 框外挑框（別模型代跑，四疑全成立）
1. **分層污染/範圍蔓延**：spec自身「自審」（:68）把判準降格成「最終仍只餵訊號給rank_scored一個函式做argmax」——這是文字遊戲，任何決策系統（含完整行為樹）最後都輸出單一action，這句話不能證偽「非第二引擎」。真正決定「是不是第二個引擎」的是判斷邏輯的所在地——active需求判定+候選池篩選+賭命跳關＝三段獨立於rank_scored的前置決策，rank_scored退化成「在別人已經圈好的池子裡加總」。這跟計畫層被抓到「披偏置外衣的state machine」同一種病，範圍更大（四機制疊加）。
2. **候選池真篩選**：見上issue，最危險項。
3. **威脅=金字塔一層**：見上issue，自相矛盾成立，範圍嚴重低估（碰TaskArbiter優先權結構）。
4. **複用可信度**：三項複用兩項概念不匹配（EWMA/found_score，見上issue），僅前瞻偏置延伸`plan_phase_drive`相對誠實可信（主要加常數+進度比值曲線，非重新設計判定核心）。

## 結論與建議
方向（語意層協調確有真問題，intent與phase各自為政的具體症狀精確坐實）**不必推翻**，但「一次上四機制（需求判定+候選池真篩選+賭命跳關+威脅整併）」的打包必須拆。**建議打回大幅簡化、分階段驗證**：
1. **第一階段只做「需求判定→intent導出」**，且候選池**只降權不排除**（先證明趨勢判定能穩定產出連貫intent、determinism byte-identical成立）。
2. **明確砍掉「賭命跳關」**（found_score複用概念錯配，需另設計或延後）。
3. **威脅整併需獨立處理**——先出一份PRIO_SURVIVAL/TaskArbiter優先權結構的premise/factcheck，確認到底要不要拆既有插斷機制，這是完全不同量級的改動，非本次「決策term層」範圍能涵蓋。
4. **前瞻偏置可留待第二階段**（相對可信但非急迫）。

halt，待blueprint重新設計縮小範圍後回reviewer重審。
