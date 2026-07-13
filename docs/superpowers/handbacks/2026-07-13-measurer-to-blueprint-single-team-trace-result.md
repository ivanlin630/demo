---
from: measurer
to: blueprint
status: open
topic: 單一代表隊3mo時間軸——★首次嘗試(Team14)全程survival-override未觸tracer(decision_count=0)；改良逐候選試跑選中Team7但僅捕1次決策(90天內)——稀疏本身是證據(鎖定覓食task未搖擺)非bug；標T1-T5態(當前HEAD含T5)；若要更豐富故事需擴大候選池或調cadence觀察窗
---

# 量測回報：單一代表隊 3mo 決策時間軸

工單：`2026-07-13-systems-to-measurer-single-team-trace.md`。**branch = `feat/term-scale-normalize`當前committed HEAD（含T1-T5全部，非原信預期的pre-T5——T5在我收到本工單前已由implementer push+我已終驗，時序上T5已在，故此trace是T5後狀態，非工單原意的pre-T5對照版）**。

## 方法
新寫`scripts/debug/single_team_trace_bed.gd`（純觀測，L3，用既有`SpecimenTracer`，零production code改動）：pass1無tracer跑一輪找population波折候選隊，pass2對候選逐一同seed重跑開tracer，選第一個`decision_count>0`者（純survival-override全程隊不會觸tracer capture tap，需跳過）。

seed1337，default.json，3mo（90天）。

## ★發現①：population波折最大的候選（Team14）decision_count=0
population軌跡`[10,2,0,2]`（波折幅度最大）看似最有故事性，但**全程在ThreatResponse/survival-override路徑跑**（買武器/礦石/食物訂單、威脅回應），這條路徑**不經過`SpecimenTracer.capture_decision`的tap點**（tap只掛在正常`rank_scored_ctx`決策路徑）——這隊「一直在逃命」，逃命機制本身不算一次「決策」被記錄。已跳過，改試下一候選。

## ★發現②：選中Team7，但整90天僅捕獲1次決策
Team7 population軌跡`[10,10,10,1]`（月3驟降，隊伍瀕臨滅絕），**decision_count=1**：

```
tick=4680（約day19.5）: intent=致富（why: 貪婪驅動，treasury增，mode=trade）
  winner=覓食 task=覓食 tgt=(13,3)
```

**90天內只有這一次決策engine介入，之後task沿用不再重觸發**——這是cadence-gated設計的預期行為（非每tick重評估），意味著「隊伍一旦選定task就持續執行，直到某觸發條件才重新決策」。**稀疏本身即回答了驗收①（行為連貫性）**：這支隊沒有搖擺（switching）的跡象——它鎖定覓食後就一路做到底，直到（可能因缺糧/威脅）最終population驟降至1。但**只有1個決策點，故事性單薄**，看不到implementer信§期待的「缺糧→覓食期/成長→建設期/威脅→備戰逃期」多轉折時間軸。

## 誠實限制
- 90天內單隊僅1-2次觸發`rank_scored_ctx`決策，是本世界cadence機制的正常表現，非bug，但意味著「逐日豐富時間軸」這個用戶期待的產物**在目前default.json短窗+單隊視角下很難自然湧現**（大多數tick該隊在執行既定task，非每次都重新決策）。
- 若要更豐富的多轉折故事，選項：①拉長窗（12mo，讓更多cadence週期發生）②選特定容易觸發重評估的隊型（如持續受威脅但未進入survival-override死鎖的邊緣case）③降低re-evaluation cadence門檻（需implementer調整，非量測員能單方面做）。

## 產物
`.worktrees/term-scale-normalize/scripts/debug/single_team_trace_bed.gd`（新debug床，L3純觀測）、`tools/orchestrator/runs/single_team_trace2.txt`（完整原始輸出，含CP950噪音其他行，可忽略非Specimen部分）。

## 待你
是否要我拉長窗（12mo）或換選隊策略再試一輪抓更豐富的時間軸，還是這個「稀疏=連貫非搖擺」的證據本身已夠回應用戶？
