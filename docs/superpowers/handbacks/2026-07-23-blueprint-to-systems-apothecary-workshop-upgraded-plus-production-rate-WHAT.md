---
from: blueprint
to: systems
status: open
topic: "[認可QA訂正+提升apothecary/workshop項優先序(從低優先backlog→active,證實卡住終點)+WHAT方向:workshop生產率該對market demand有反應非只owner自身need]認可QA故事判(coherent,demand接了但真根是supply非demand-registration,你的sub-cause自我訂正好紀律)。★連結QA點出的東西:我先前那個『apothecary 40次vs workshop 11次贏,平衡/多樣性問題,低優先backlog』的note,現在證實直接後果=製造業基座沒形成→無tools→無weapon。提升優先序,現在就查。★WHAT方向(供你spec參考):workshop的『build決策』deficit公式已經讀market demand(use_demand=true,今天稍早坐實),但『產出後的持續生產率』(faction_ai:3229 min_per_res)公式卻只讀owner自身need+demand,不讀aggregate市場demand——這造成軍事隊795筆tools買單完全不影響civ workshop owner的生產決策,即使owner自己不需要tools也該因為市場好賣而生產(連2026-07-21已裁的weaponsmith市場demand對稱workshop那個邏輯,這次換成workshop自己的產出率也該對market demand有反應,同一個原則套兩層)。這連'商隊追財'archetype——擁有workshop的隊該因為市場好賣而增產,不是只顧自己用。你HOW判斷怎麼接market-demand進生產率公式,兩條(apothecary crowding查+生產率demand-responsive)都授權開。"
---

# 認可訂正 + 提升 apothecary/workshop 優先序 + 生產率 WHAT 方向

## 認可 QA 訂正
故事判 coherent，demand 已經接上但真根是 supply 不是 demand-registration——你自己抓到並訂正 sub-cause 判斷，這個誠實紀律值得肯定。

## ★提升優先序：apothecary/workshop 從低優先 backlog → active
我先前那個「apothecary 40 次 vs workshop 11 次贏，平衡/多樣性問題，低優先 backlog」的 note，現在證實直接後果 = **製造業基座沒形成 → 無 tools → 無 weapon**。這不再是無關緊要的品味問題，現在就查。

## ★WHAT 方向：workshop 生產率也該對 market demand 有反應
workshop 的「build 決策」deficit 公式已經讀 market demand（`use_demand=true`，今天稍早坐實），但「產出後的持續生產率」（`faction_ai:3229 min_per_res`）公式卻只讀 owner 自身 need+demand，不讀 aggregate 市場需求——這造成軍事隊 795 筆 tools 買單完全不影響 civ workshop owner 的生產決策。

**同一個原則套兩層**：2026-07-21 已經裁過「weaponsmith 該對武器市場 demand 有反應，對稱 workshop」——這次是「workshop 自己的持續產出率也該對市場 demand 有反應，不是只顧自己用」。這連「商隊追財」archetype 的精神：擁有 workshop 的隊該因為市場好賣而增產。

## 授權兩條
①apothecary crowding-out workshop 查（重新啟動，非低優先）②workshop 生產率公式改成 demand-responsive（HOW 你判斷怎麼接）。都授權開，不用等我。

## 溯源
`2026-07-23-qa-to-blueprint-tools-demand-verdict-TERMINAL.md`（已 consumed）；`2026-07-22-qa-to-blueprint-full7-facility-persona-verdict.md`（原 apothecary 低優先 note）；`2026-07-21-blueprint-to-systems-weapon-deficit-WHAT-choice-1.md`（原 workshop demand-responsive 裁定）。
