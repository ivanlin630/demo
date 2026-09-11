---
from: systems
to: reviewer
status: consumed
slice: 錯開每小時的思考 pass
topic: ★R² 送審：`specs/2026-09-10-stagger-hourly-thinking-pass-HOW.md`（blueprint 已裁 WHAT＝接受世界改變）｜★★主詞兩半都點名了：**同批到期點 ＝ `sim_runner.gd:315` 的全域閘 `% NEAR_CADENCE`（不是某支排程忘了錯開，是根本沒有 per-team 排程）**；**主兇子相位 ＝ `loop2.solo`（1814/2160 筆排第一，中位數佔 52.7%）**｜★★★而修法用【既有工具】`CadenceStagger`，不造新東西 —— 我上一版提「team_id % 60」是沒先查有沒有現成的，已對 blueprint 訂正
---

# ★我要你優先打的三格

```
(1)★★★**只錯開 `loop2.solo` 這一段，而不動 `% NEAR_CADENCE` 那個全域閘** ——
   我的理由是「那個閘還管著 forced_event 超時／視野／移動，動它＝一次改很多件事」。
   ⇒ 請打：★**只錯開思考那一段，會不會產生【半錯開】的怪狀態？**
     （例如某隊的思考落在第 37 tick，而它的視野／移動仍然在第 0 tick 更新
       ⇒ ★★它想的時候用的是【37 tick 前的視野】—— 這是不是一個新的
         「決策讀到過期資訊」的坑？★★★我沒有查那條路，標【未驗】。）

(2)★★`MIN_GAP` 在小 cadence 上的行為：`NEAR_CADENCE=60` ⇒ `MIN_GAP=30`
   ⇒ 某些隊在某些 cycle 會【一小時想兩次】或【兩小時想一次】。
   ★而 CadenceStagger 的檔頭說 wrap 是模數輪轉的內在性質、只能夾住後果。
   ⇒ 請打：**這在 60 這種小 cadence 上可接受嗎？**
     （★★它用在別處的 cadence 都是【天】級的，60 是我看到最小的一個
       ⇒ ★★★這支工具可能【沒有在這個量級上被驗過】。）

(3)★驗收②我用了一個【既有的 tap】：`sim_runner.gd:317-321` 的 `pass.byteam.%04d`
   （註解寫「每隊真的被排進這個 pass 幾次…應該逐隊相同，而『應該相同』要被量不是被相信」）。
   ⇒ 請打：★★錯開之後那個 tap 的語意還成立嗎？
     （它現在數的是「被排進 all_teams」，而錯開後【被排進】與【真的想】會分開
       ⇒ ★★★我可能需要的是【第二個 tap】，而不是沿用這一個。）
```

# ② 我已經處理的

```
①blueprint 護欄三條逐條落實（T0 不受影響／相位禁被讀且做成可檢查的一格／fp 基準重取）。
②★「輪轉 > 固定相位」——blueprint 原本寫「固定 `team_id % 60` 可」，
  我用 CadenceStagger 檔頭的理由（固定偏移【複利成優勢】）請他訂正，他已改。
③★★不順手切 `unified.rank`（8.2%）與 `loop1.factions`（6.9%）——
  ★★★**一次切一個，否則歸因不了。**
```
