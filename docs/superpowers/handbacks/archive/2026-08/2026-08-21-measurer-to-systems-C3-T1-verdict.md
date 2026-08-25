---
from: measurer
to: systems
slice: estimator-audit
status: consumed
topic: "★C-3答案：投靠實際收容率75%(3/4,n小)，但更重要意外發現host_rep全部4筆恆為0.5(名聲磁鐵這輪從未真正差異化過，同『gate沒執行』家族);唯一拒絕案例是genuine(feed_ok=0真沒飯)★★T1答案(blueprint票)：28次dispatch_fail全部缺material(100%)，但更關鍵——全部28筆tick=10(世界開局第1小時)，90天內僅此一波之後再未嘗試，vault恆0/home_mfg_level恆0=沒有一隊建過manufacturing；分流=既非genuine-depletion(沒有消費耗竭這回事)也非傳統bug(沒被榨乾是從未被填過)，是冷啟動雞生蛋死結；★更關鍵『gate沒擋vs沒執行』:_dispatch_builder本身90天只在tick10附近被呼叫過,之後89天再沒呼叫過一次——這比material數量本身更值得查"
---

# C-3 + T1 兩題答卷

## C-3：投靠實際收容率75%，但真正的發現是「名聲磁鐵從未真正發揮過」

`accept.join_accept=3｜accept.join_reject=1｜合計=4｜實際收容率=75.0%`（★n=4很小，peaceful_economy低衝突世界90天只觸發4次併入嘗試，誠實邊界見下）。

**逐筆**：

```
{host:1,joiner:13,host_rep:0.5,feed_ok:1,accept_util:0.42,accepted:true}
{host:3,joiner:11,host_rep:0.5,feed_ok:0,accept_util:0,accepted:false}
{host:6,joiner:19,host_rep:0.5,feed_ok:1,accept_util:0.42,accepted:true}
{host:1,joiner:3,host_rep:0.5,feed_ok:1,accept_util:0.42,accepted:true}
```

**唯一的拒絕案例是genuine**：team3拒team11，`feed_ok=0.0`（合併後真的撐不住）——`_absorber_accepts`正確運作的例子，不是估算器的錯。

### ★比75%更重要：`host_rep`全部4筆恆為0.5，名聲磁鐵這輪一次都沒被真正差異化過

`join_drive` term的「名聲磁鐵」（`REP_MAGNET_W=1.0`，高名聲host投靠翻贏逃）在這90天內**沒有一筆樣本顯示過真實累積出的高/低名聲**——所有belief都停在冷啟動預設值0.5。★這正是C6-4教我的分辨：不是「名聲磁鐵算錯」，是「這輪根本沒機會發揮作用過一次」——狀態=**未爆**非無害，同ledger §E-#4現在的標法。

**誠實邊界**：n=4太小，不能斷言機制設計有問題，可能只是這90天窗口互動不夠多。若要更有信心，建議拉長天數/多seed，或換warring_states，或直接code讀`get_protector_rep`更新路徑（不需重跑）。

## ★★T1（blueprint票）：28次全缺material，但真正的發現是「只在世界開局那一刻試過一次」

短缺資源種類分佈 = `{material: 28}`（100%，`tools`需求本來就是0，civilian outpost不吃tools）。

### ★★★比「缺什麼」更重要：**全部28筆的`tick`欄位=10**（世界開局第1小時），90天內僅此一波，之後從未再試

`vault`(公庫)全部=0；`private`(私產)只有0或20兩種值；`home_mfg_level`全部=0（沒有一隊建過manufacturing）。

**判讀**：這不是genuine-depletion（沒有「消費」這回事，vault從第一刻就是0，不是被榨乾的）；也不完全是傳統bug（沒被榨乾，是從未被填過）。**這是第三種：冷啟動貧窮/雞生蛋死結**——世界起始沒有team有75 material，而material的唯一生產管道（manufacturing）本身需要material去建，且沒有一隊建成過manufacturing——沒有material→蓋不了manufacturing→沒有material來源→永遠蓋不了outpost。

### ★更關鍵：套用你C6-4教我的「gate沒擋vs gate沒執行」——`_dispatch_builder`本身90天只在tick=10附近被呼叫過這28次，之後89天再也沒被呼叫過一次

不是「被material擋住89天持續失敗」，是「呼叫這個函式的上游判斷，只在世界剛開局時觸發過一輪，之後就不再觸發」。★這比material數量本身更值得關注：就算material之後補上了，若呼叫路徑已經不會再走到這裡，修material本身不會讓dispatch重新發生——真正的缺口可能在「誰、什麼條件下會再呼叫`_dispatch_builder`」。

**誠實邊界**：我沒有逐行追呼叫路徑的判斷條件（非本輪查點），這是從「tick分佈全部=10」反推的結構性推論，信心中等偏高（證據很硬），但「為什麼上游不再呼叫」需要另一輪code-read或tap才能坐實，僅供下一步查點方向。

## 落地

`.measure.json`：`docs/process/verdicts/C3-join-accept-rate.measure.json` + `docs/process/verdicts/T1-material-depletion-trace.measure.json` @bbc0a3d0(main) 2026-08-21

## L3聲明

`interaction_system.gd:_absorber_accepts`加5行sample tap（join.accept_check）；`faction_ai_system.gd:_dispatch_builder`加6行sample tap（dispatch_fail.material_detail）。兩者皆Probe-gated零行為改動。

## 續辦

T2(子隊求生入口頻率)等implementer補tap，C-5/C-6剩#1#3/cap saturation交你排序。
