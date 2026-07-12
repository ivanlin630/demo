---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] B3野心門查——組合修後B2出現裂縫(seed7 4.2%通過)但B3(ambition≥0.6)接力卡死,established仍恆0;patch-gate-first查B3是否也是同型雞生蛋
---

# B3(野心門)查——established調查鏈第六層

## 背景
forage-floor-tune(急性崩緩解) + command-tenure(統領日常成長) 組合重測：B2(統領技能門)首次出現裂縫(seed7 212次/4.2%通過,非100%全等)，假說「上游修緩解→leader活久→tenure累積→B2鬆動」**部分成立**。但established仍全程恆0——**B3(`gate_fail_b3_ambition`)接力卡死**（seed7: 5003=gate_b1_ok，100%卡）。見`2026-07-12-measurer-to-blueprint-combined-established-retest-result.md`。

四層門非一起鬆，是**接力卡**：B2鬆一點，B3補上卡死。

## 待查（零跑，file:line，patch-gate-first：先查是否同型雞生蛋，非猜tuning）
1. **B3門檻**：`ESTABLISH_AMBITION − 0.1`常數值+位置（`faction_ai:978`附近）。
2. **野心(ambition)怎麼漲/初始分布**——比照B2查法：野心是否也只有單一成長路徑（例如也綁某個繁榮/擴張reaction）？還是野心是static人格屬性、開局生成後不太變？查`PersonGenerator`野心初始分布 vs B3門檻的差距。
3. **若野心是靜態人格屬性（幾乎不變）**——B3可能不是「累積型」門（不像B2那樣需要時間爬），而是「初始人格分布」問題：只有野心夠高的人選一開始就能過，其他人選structurally過不了。這跟B2(累積但被打斷)是不同型的瓶頸，修法方向會不同。
4. **是否有既有成長路徑但同樣被繁榮閘鎖**（同B2那種P4_expand pattern）——若有，那是同型第五層雞生蛋；若無成長路徑純看初始值，那是另一種問題（人格生成分布 vs 門檻沒對齊）。

## 為何現在查
established調查鏈已到第六層，每層都遵循patch-gate-first先查是否死常數/機制斷裂再開藥的紀律——B3不查清楚，可能重蹈B2單獨測「修了但沒觸及真根」的覆轍。

## 序
零跑出B3真根（累積型 vs 靜態分布型）→ to:blueprint → 我判方向 → 若需用戶裁 → brainstorm→對抗→spec。12mo長窗續跑先擱置，等B3查清楚再一起看要不要跑（避免像B2那樣先花大窗測到接力卡的下一層才知道還沒完）。
