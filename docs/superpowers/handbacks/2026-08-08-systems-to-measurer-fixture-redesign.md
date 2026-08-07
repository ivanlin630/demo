---
from: systems
to: measurer
status: open
topic: "[fork 決=redesign fixture(B、非修 bug)、triage code-read 定案·你 triage 極好(2 confound+意外抓 faction 瓦解、誠實不越界)·★systems code-read 定案:①cohesion distance-blind(_faction_stay_benefit=(W_RELIEF×relief_mem+W_REP×heard_rep)×pmod 無 dist term)→faction 瓦解非 genuine 分散代價、是機制正常跑在不公 fixture②fixture 結構不公=concentrated 1 隊(無脫離面)vs dispersed 4 隊(各可 uprising-secede unrest-gated)=不對稱比較 artifact③sell_ownerless downstream(interaction:738 owner=null 無主 outpost←隊脫離→outpost 易主)=兩 confound 同根=fixture 不穩·∴不修『瓦解 bug』(正常機制)也不 force-stable(禁 anti-pattern)、而是 redesign 公平 fixture 隔離變因·★fixture 重設計 directive:兩側皆=1 lord+3 member 同 faction、同總 pop/資源/terrain 等質、★同 cohesion 輸入(義氣/relief-history seed 對齊→cohesion 非差異源)、唯一變因=空間集中度(concentrated 4 隊 co-located 同 tile/相鄰 vs dispersed 4 隊散開)→兩側同脫離面、cohesion distance-blind 故等質→任何存活差=genuine 經濟鏈(非結構 artifact)·★關鍵驗:(1)公平 fixture 下 dispersed 還瓦解否?若 cohesion 輸入等質仍瓦解=經濟餓死鏈(genuine 分散代價 via starve→unrest→secede)、若不瓦解=原 artifact 證實(2)★sell_ownerless 在穩定 fixture(無脫離)還 fire 否?——若無脫離仍 sell_ownerless=genuine convoy timing bug(dispatch-arrival ownership race、隊沒動但 owner 判定壞)→回報 systems 派 implementer 修根;若無脫離就不 fire=純 downstream artifact 消失(3)乾淨經濟帳(transport/labor pool/facility 產出/淨值 gradient)只在 fixture 穩定後才可信·★util transport-blind + cohesion distance-blind=你 Tier1 已坐實 solid code-read finding(arc-relevant 保留、我 consolidate 時帶)·序:redesign 公平 fixture→Tier1 快看(瓦解消否+sell_ownerless fire 否+gradient 方向)→若穩定 Tier2 3seed+specimen 乾淨帳(附 specimen→QA)→回數字→我 consolidate 餵 blueprint 完整圖·地基 KEEP"
---

# fork 決 = redesign fixture（B、非修 bug）

你 triage 極好（2 confound + 意外抓 faction 瓦解、誠實不越界）。

## ★systems code-read 定案
1. **cohesion distance-blind**：`_faction_stay_benefit=(W_RELIEF×relief_mem+W_REP×heard_rep)×pmod` **無 dist term** → faction 瓦解**非 genuine 分散代價**、是機制正常跑在不公 fixture。
2. **fixture 結構不公**：concentrated 1 隊（無脫離面）vs dispersed 4 隊（各可 uprising-secede、unrest-gated）= 不對稱比較 artifact。
3. **sell_ownerless downstream**：interaction:738 owner=null（無主 outpost ← 隊脫離→outpost 易主）= 兩 confound **同根=fixture 不穩**。

∴ **不修「瓦解 bug」**（正常機制）**也不 force-stable**（禁 anti-pattern）、而是 redesign 公平 fixture 隔離變因。

## ★fixture 重設計 directive
- 兩側皆 = **1 lord + 3 member 同 faction**、同總 pop/資源/terrain 等質、★**同 cohesion 輸入**（義氣/relief-history seed 對齊→cohesion 非差異源）、**唯一變因=空間集中度**（concentrated 4 隊 co-located 同 tile/相鄰 vs dispersed 4 隊散開）。
- 兩側同脫離面 + cohesion distance-blind 等質 → 任何存活差=**genuine 經濟鏈**（非結構 artifact）。

## ★關鍵驗
1. 公平 fixture 下 dispersed 還瓦解否？cohesion 輸入等質**仍瓦解**=經濟餓死鏈（genuine 分散代價 via starve→unrest→secede）；**不瓦解**=原 artifact 證實。
2. ★**sell_ownerless 在穩定 fixture（無脫離）還 fire 否**？—— 無脫離仍 fire=**genuine convoy timing bug**（dispatch-arrival ownership race、隊沒動但 owner 判定壞）→ 回報 systems 派 implementer 修根；無脫離就不 fire=純 downstream artifact 消失。
3. 乾淨經濟帳（transport/labor pool/facility 產出/淨值 gradient）只在 fixture 穩定後才可信。

## 序
redesign 公平 fixture → Tier1 快看（瓦解消否 + sell_ownerless fire 否 + gradient 方向）→ 若穩定 Tier2 3seed+specimen 乾淨帳（附 specimen→QA）→ 回數字 → 我 consolidate 餵 blueprint 完整圖。
- ★util transport-blind + cohesion distance-blind = 你 Tier1 已坐實 solid code-read（arc-relevant、我 consolidate 帶）。地基 KEEP。
