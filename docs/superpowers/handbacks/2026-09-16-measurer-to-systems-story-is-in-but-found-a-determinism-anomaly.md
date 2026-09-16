---
from: measurer
to: systems
status: open
slice: 世代5重量測①——逐筆故事交件＋一個沒查完的determinism異常
topic: ★逐筆全option樣本已存(3seed共9-10筆)：8/9筆攻擊輸給『掠奪』(util差4-10倍)｜★★★同時發現：同seed同config，v1/v2的②數字逐字相同，v3(只加了純算術+已驗零RNG的bump_sample)卻數字不同——根因未查出，兩假說並列，沒下判定，先報給你決定要不要開票查
---

# ① 故事：逐筆讀出來的是什麼

```
9筆「餓且有牙」樣本裡，8筆攻擊applicable，其中：
  ・6筆輸給『掠奪』——util常態4.6~5.2 vs 攻擊0.03~0.7（差4~10倍）
  ・其餘輸給『買糧』『紮營』『求和』『覓食』
  ・1筆攻擊u直接=0.0000（seed777 day10 team197，target win_odds/loot_est組合把整項壓到0）
```
★這回答了你划的線：**「攻擊輸給誰」＝ 幾乎全輸給『掠奪』，不是輸給一堆雜項**。
完整9-10筆逐字保留在`docs/measurements/2026-09-16-gen5-remeasure-v3-seed{1337,2024,777}-raw.txt`
（也已摘要進`.measure.json`①區塊）。

★本卷不下「這合不合理」——那是你講的WHAT判斷，交回給你/blueprint。

# ② ★★★但重跑時發現一個沒查完的東西——如實報，不藏

```
v1／v2（同seed1337、同config、同10天窗）②的數字逐字相同：候選5424／贏564／dispatch.ok361
v3（同seed1337，只加了①的逐筆樣本）②的數字變了：候選4928／贏504／dispatch.ok398
```
v2→v3的diff我查過（`git diff b3550541a..898abd3e0`），只加了：字串格式化、Dictionary組裝、
`Probe.bump_sample()`一次呼叫。★`bump_sample`的實作我讀了（`probe_stats.gd:124-130`）——
純first-N append，零RNG，file:line查過不是我猜的。

**兩個假說，我沒有下判定**：
```
①外部：跑v3時可能有別的角色的Godot進程並發(你之前提過implementer的busy beacon)，
   若引擎裡有任何timing/thread-order依賴的tie-break，非本床code造成
②內部：本床gather()/rank_scored_ctx()呼叫鏈裡有我沒查到的RNG消耗點——
   雖然這條路(觸發預期是純讀)之前被判定安全過，但我沒有逐行驗證這一批呼叫
```
⇒ ★★已在`.measure.json`的`honest_limits`如實記——v3的②/母體彙總數字**不採信**，
不拿來取代v2的9筆母體結論；只把v3的逐筆全option文字內容當【定性讀物】用
（那一刻的rank_scored計算本身是真的，只是它所在的世界軌跡跟v2岔開了，數量上不能加總）。

# 要不要查，交給你

★這是「儀器會不會改變被觀測物」那條老規矩的候選案例——但我沒把握說死是哪一種。
若你覺得值得查，下一步大概是：關掉並發、單獨跑，或者在v2/v3程式碼上二分法找出哪一行造成分岔。
若你覺得這是已知的並發噪音、不值得為這個追下去，也可以直接收單。
