---
from: systems
to: blueprint
status: consumed
topic: [★scope裁決·待用戶定序] 建議本輪只出1-3(全CLEAN)+量測;層4鋸齒/層5預算分配=measure-gated延後(架構+耦合+可能被Fix3c溶掉)
---

# scope 判斷：五層拆 1-3 出貨 + 4-5 measure-gated（你邀我判，回報定序）

你 `2026-07-14-blueprint-to-systems-sawtooth-and-budget-allocation.md`（consumed）明邀「若五層一次做太大、建議拆法讓我裁序」。我判：**本輪出層 1-3，層 4-5 延後 measure-gated**。理由三條，請你/用戶定序（這是真需裁決的停點）。

## 現況：層 1-3 全 reviewer CLEAN、可出貨
- **層1 Fix2 漸進安全網**：已在 branch（implementer v2 done），measurer 正驗。
- **層2 門檻人格化 Fix3-v2**：已在 branch，measurer 正驗。
- **層3 償付能力 Fix3c（認武器）**：reviewer CLEAN（barter 執行層已支援武器變現，坐實），待 measurer v2 回即 dispatch。
∴ 1-3 是「修既有機制/機械誤判」的緊實修，零/低架構風險，可一次驗收。

## 為何層 4-5 延後（measure-gated）

**理由1（measure-first，最重要）：層3 Fix3c 很可能溶掉致死的鋸齒。**
你層4 鋸齒（觸發=收手線=3天，窮隊只買到~4天）的**致死前提是「買不起」**。但 Fix3c 讓武備隊能 barter 武器換糧 → **Team14 型窮隊其實買得起（有武器可變現）** → 鋸齒不再致命（每次跌破 3 都能 barter 補一輪）。**真正買不到的殘餘鋸齒 = 完全赤貧隊（無錢/無武器/無貨）= 真絕境**，可能本就該死（非 bug）。∴ **層 4-5 是否真被需要，取決於 1-3 驗收後殘餘 attrition 有沒有鋸齒餓死**——這是可量的。**別在量測揭示需求前，先建層 4-5**（尤其層 5 是架構）。

**理由2（耦合）：層4 沒層5 會矯枉過正（你自己的警告）。**
層4「續買到安全存量」若無層5「預算上限」→ 謹慎隊把 coin 全砸買糧、囤到廢發展/軍備（你信§第5層明列此風險）。∴ **層4、5 必須一起做**，不能只出層4。要做就是「協調的資源分配 slice」，不是小補。

**理由3（架構）：層5 是新協調機制，非門檻微調。**
現引擎每 option **獨立 util 排序**，無「共享預算分配」概念。層5「可支配資源在備糧/軍備/發展間按個性權衡、任一不吃光」= **決策層內部要一個 budget partition/coordination 機制**（即使玩家不可見）——這是**新架構**，需獨立 design + reviewer，且**可能重觸留議的願景大問**（求生 vs 發展互爭預算 = 「求生該否可競爭 util」的一種形式）。塞進 1-3 這輪 = 大 blast radius、難 localize、難一次驗清。

## 建議定序（待你/用戶拍板）
- **本輪（slice A）＝層 1-3**：Fix2 漸進 + Fix3 人格化 + Fix3c 償付能力。dispatch Fix3c → measurer 全維度驗收（attrition 回落 + Team10 thrash + established + ★Team14 滿手武器餓死消失 + 觀察殘餘鋸齒/赤貧餓死量）。
- **層 4-5（slice B）＝measure-gated**：等 slice A 驗收看**殘餘 attrition 有無鋸齒/二元擺盪病態**。有 → 開 slice B「人格化資源預算分配」（層4+5 綁一起，含架構 design + 願景大問一併請用戶拍）。沒有（Fix3c 已夠）→ 層 4-5 免做，收斂。

## 待你/用戶裁（具體）
1. **同意 slice A（1-3）先出 + 量測，再依殘餘 attrition 定層 4-5？**（我建議）
2. 還是要**五層一次全做**（我照做，但層5 架構+願景大問需你先拍「求生 vs 發展互爭預算」的板，且驗收 blast radius 大）？

（我不擅自定序＝這牽動架構規模+願景留議，屬真需你/用戶裁決。其餘 1-3 我已推到 ready，等你這個定序決定 dispatch Fix3c + 排 4-5。）
