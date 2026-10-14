---
from: measurer
to: systems
status: consumed
slice: A2b 追量——「貿易」75~80% 重撞的兩個可能分開量完
topic: ★兩個可能都量到了：(i)判法確實會污染(方向不只一邊，兩個seed各污染一邊)；(ii)★更關鍵——A2 的 FailureMemory.record 對「貿易」幾乎從未被呼到，不是折價沒生效而是記號本身沒寫（production自己的計數器交叉驗證，不靠本床key重建）。重撞率在換成C2′判法後仍極高(seed7：87.3%)。
---

# 一、(i) 判法污染——兩個seed各自證明一個方向，不是只有一種誤算

```
舊判法＝當日coin淨額==0；新(C2′)判法＝當日沒有任何market_*/trade_goods_*(含coin與貨物)流動。
「貿易」事件數（舊→新）：
  seed1337：16 → 9（舊判法多算7筆——那幾天其實有貨/有別的coin流動被淨額抵銷成0）
  seed2024： 3 → 5（★方向相反：舊判法少算2筆——那幾天coin淨額≠0是別的收入,真實貿易仍是0成交）
  seed7   ：157 → 110（舊判法多算47筆）
★兩個方向都真實發生，不是只有「以貨易貨被誤算成零成交」那一種污染。
```

# 二、(ii) ★A2 的失敗記號本身幾乎沒被寫入——不是本床key對不上，是production自己的計數器證實的

```
三個seed，「貿易」零成交(C2′判法)事件數 vs. recent_failures同拍真的寫入「貿易|市集」的筆數：
  seed1337：9 筆事件，0 筆記號
  seed2024：5 筆事件，0 筆記號
  seed7   ：110 筆事件，0 筆記號
```

交叉驗證（不經本床任何key重建，直接讀production自己在同一行bump的Probe計數器）：

| seed | trade.arrived_no_deal（同拍會呼record的那個條件） | trade.meet_nodeal（dealt=false的通用計數） | trade.deal_market+resident | trade.release_at_dest（≈到場母體） |
|---|---|---|---|---|
| 1337 | 3 | 154 | 46+50 | 60 |
| 2024 | 0 | 406 | 17+44 | 92 |
| 7 | 1 | 722 | 14+13 | 296 |

★★★`trade.meet_nodeal`（真的沒成交）在三個seed都是三位數，而`trade.arrived_no_deal`
（sim_runner.gd:927-929，跟FailureMemory.record寫在同一行的那個計數器）只有0~3次——
缺口在`if not _dealt and String(_t.current_option)=="貿易"`這個gate：`current_option`
在到場那一拍絕大多數【不是】字面"貿易"（常是means-end路徑的"maintain_food:resource"之類，
或已經被決策引擎換成別的option）——★本床只確認這個gate幾乎沒通過,不判為什麼current_option
在那一刻不是"貿易"（那是下一步的事，交你）。

重撞前折價值（用上一拍snapshot重算`FailureMemory.mult`公式）：seed7 96對重撞裡印出的樣本
全部是 **1.000**（沒有任何折價）——這是(ii)的直接後果：記號沒寫進去，折價當然恆為1.0。
★誠實限：96這個數字有重複——同一天內同隊同市集多次邊緣觸發會把同一組day-pair算進去好幾次
（seed7樣本裡看到同一個team=14/market=5006/day16→17出現5次）,真正【不同日期組合】的重撞對
比96小,但方向不影響結論（折價值不管算幾次都是1.000）。

# 三、重撞率換成C2′判法後的結論（純數字，不下因果）

```
option=貿易：seed1337 9筆/0重撞(0%)｜seed2024 5筆/0重撞(0%)｜seed7 110筆/96重撞(87.3%)
★seed1337/2024樣本太小(n=9,5)看不出率；seed7樣本夠大，而87.3%比第一輪的79.6%更高，
不是變好——(i)判法修正後問題沒有變小，跟(ii)的0記號一致。
```

# 四、母體小落差（誠實記錄，不影響結論方向）

```
`trade.release_at_dest` 應≈本床「TASK_TRADE到場邊緣觸發」計數，三個seed都有小落差
（seed2024：92 vs 86，seed7：296 vs 293）——約2~7%，可能是遭遇戰等中斷造成的邊緣偵測
時序差一拍，沒有深究（量級不影響(i)(ii)的結論）。
```

# 五、落地

```
床：scripts/debug/a2b_recollision_rate.gd（同一支床修改，未開新檔）
產物：docs/measurements/a2b-recollision-seed{1337,2024,7}.jsonl（逐筆事件含old_zero/new_zero/
      a2_recorded/mult_before四個欄位並列）
跑法：.\tools\godot.ps1 --headless --script scripts/debug/a2b_recollision_rate.gd
（純聚合+計數器交叉驗證，非行為因果結論，不需QA故事稽核）
```
