---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] SLICE A refine——DELIVER賣full cargo繞reserve，親讀`interaction_system.gd:807-829`確認根因精準、唯一call site(758)零遺漏風險、qty capping(817)保證即使繞reserve conservation仍airtight，implementer開工"
---

# R②判決：SLICE A refine — DELIVER 賣 full cargo（繞 porter reserve）— CLEAN

窄範圍、機械式修正，親讀現況code直接驗，不需召異質。

## 根因——親讀`interaction_system.gd:807-820`確認精準
`_market_visitor_sell`：`surplus=effective_holding(visitor,res)−reserve(visitor,res)`(812-813)——porter扛著待交付的cargo，被這行當成「自己的持有量」去扣自己的reserve，等於系統誤把「要送出去的貨」當「自己想留著的存量」，扣完所剩無幾→`sell_no_surplus`bail。跟spec描述的根因逐字對上，非猜測。

## fix安全性——親驗三點
1. **唯一call site**：`grep`全專案確認`_market_visitor_sell`只有一處呼叫(:758，在`_resolve_market_at_outpost`內部)——新增optional參數`deliver_cargo:float=-1.0`不會有第二個呼叫點被漏改、也不會有「以為改了其實沒改到」的風險，這條修改的影響面精確可控。
2. **normal sell零影響是結構性保證，非靠小心**：既然只有一個call site，且fix明確要求該call site依`visitor.task_extra_data.has("convoy_phase")`分流傳-1或真cargo qty——非convoy訪客(正常貿易隊)天生沒有這個key，自動落到-1路，`surplus=holding−reserve`原樣不變，不是「改完後要注意別影響到別的地方」，是結構上不可能影響到。
3. **conservation airtight，繞reserve不等於繞交易上限**：親讀:817`qty=min(order_rem,surplus,ocoin/bid)`——即使`surplus`被`deliver_cargo`取代成整批cargo量，真正成交的`qty`依然被買方剩餘訂單量+買方coin負擔能力兩個獨立上限夾住；:822`TileBank.deposit`跟:825`ResourceSystem.spend_holding`用的都是這個capped後的`qty`/`q`，不是原始`deliver_cargo`——賣不完的cargo繼續留在porter身上，隨RETURN帶回母隊(上輪已驗證的merge conservation路)。繞reserve只是放寬「porter自己能不能賣這麼多」的上限，不影響「買方到底吃得下多少」這個獨立、真正決定實際成交量的夾點。

## 語意——cargo=待交付非scripted override
這批cargo的數量本身是上兩輪審過的`_deliver_candidates`util秤決策決定要派送的量(非隨手定的)，繞reserve只是承認「這是已經決定要送出去的貨，不該再被porter自己的個人消費儲備邏輯攔一次」，是語意修正非硬繞過決策層。

## 判決
**CLEAN → implementer（deliver_cargo param + convoy傳cargo + TDD送達率measured真升）。** 送達率26%→?這條照spec要求measurer必須實測(sell_no_surplus降/deliver_settled升/cargo_delivered比率升/fulfilled>4)，不能假設refine有效就通過——這點spec自己已經寫進TDD，我沒有額外要加的。
