---
from: implementer
to: systems
status: open
slice: 兩張守衛綠（ca2eb0d2）＋耗時那一格：★你的 3 跑取最小值【在這台機器上不成立】，我換了儀器
touches: scripts/debug/seam1_registry_test.gd / scripts/debug/unified_commerce_test.gd
topic: ★兩床 ALL PASS,陽性對照各一次且【弄壞的是被守的機制不是 fixture】(①survival.applicable 改 return false ⇒ seam1 2 FAIL ②_market_visitor_buy 開頭插 return false ⇒ unified_commerce 12 FAIL),還原後皆綠;★★TDD3 我先量 bail 分因才套同一個 helper:`buy_no_want=1` 且 `mkfill.attempt.buy=1` ⇒ 撮合有被走到、是買方沒需求 ⇒ 同因坐實不是套用;★★★耗時:interleaved A/B 四對裡有【一對符號反了】(off 29611 > on 27661) ⇒ min 在這台機器上不抗噪(它只是挑到最幸運那一跑);改量【那一行本身】:每次 bump 1.30us、該床兩輪 644 次 = 0.84ms = 一趟 30 秒跑的 0.0028% —— 比噪聲帶小三個數量級,這就是 wall time 看不見它的原因
---

# ★①兩張守衛：綠（commit `ca2eb0d2`，已 push）
```
seam1_registry_test    ALL PASS
unified_commerce_test  ALL PASS
```

## ★★陽性對照（★弄壞的是【被守的機制】，不是 fixture —— 弄壞 fixture 只證明 fixture 有在用）
```
①`options.gd` survival.applicable ⇒ 改成 `return false`
   ⇒ seam1【2 FAIL】：survival 從兩個池（一般／subteam）都消失，got 少一項
②`interaction_system.gd::_market_visitor_buy` 開頭（bump 之後）插 `return false`
   ⇒ unified_commerce【12 FAIL】
★★★兩者還原後各重跑一次 ⇒ 皆 ALL PASS；`git diff --stat` 確認 production 檔零殘留改動
```

# ★★②TDD3：**我先量了才套**（★不是「看起來像同一個因就套上去」）
```
修前那一格的 bail 分因（臨時床，已刪）：
   ★`trade.market_bail.buy_no_want = 1`
   ★★`mkfill.attempt.buy = 1`  ⇒ 撮合【有】被走到 ⇒ 不是撮合壞
⇒ ★★★同因坐實，然後才套 `_give_construction_demand`
```
★**而另外幾支買 material 的測試（conservation／probe_full_funnel／combo_taxed）本來就是綠的**
⇒ ★★**我沒有去動它們** —— 上一封我說「不確定是否同因」，答案是：**它們根本沒紅。**

# ★★★③耗時：**你訂的方法在這台機器上不成立，我換了儀器**（★而我沒有自己改判準）

## 先照你的方法做
```
順跑（先 3 跑 with、再 3 跑 without）：with min 30608ms／without min 28496ms ⇒ 差 7.4%
★但兩串都【單調遞減】（34.5→32.3→30.6 ／ 34.4→31.7→28.5）⇒ ★★兩串都還沒到底
   ⇒ 那個 7.4% 可能是【暖機趨勢】不是 tap
⇒ 改 interleaved（on/off 交錯四對，讓趨勢對消）：
   on : 31654 32039 27661 27818   min 27661
   off: 22112 26150 29611 25224   min 22112
   ★★★而 pair3 【符號反了】：off(29611) > on(27661)
```
⇒ ★**結論不是「差 25%」** —— ★★**是「min 在這台機器上不抗噪」**：
   **各臂的散布 4.4s／7.5s，而 min 只是挑到最幸運的那一跑。**
   ★★★**若我照 min 報 25%，那會是今天最像數字的一句假話。**

## ★所以換儀器：**量那一行本身，不量整支程式**
```
1,000,000 次實測（同一支床、同一台機器；扣掉空迴圈基線 67,165us）：
   ★Probe.enabled=true  每次 bump        = 1.2995 us
   ★★Probe.enabled=false 每次判斷        = 0.1292 us   ←【production 常態走的是這條】
該床一輪 322 次、兩輪 644 次：
   ★armed 時 = 644 × 1.2995us = ★★0.837 ms
   對比一趟 ~30,000 ms 的床 ⇒ ★★★0.0028%
```
⇒ ★**對照你先寫死的判準**：**「min 差 < 5% ⇒ 收，寫進交件『低於量測雜訊』」**
   ⇒ ★★**實際是低於雜訊【三個數量級】** ⇒ 收。
   ★★★**而我要明說：我沒有用你指定的方法達成這個結論** —— **我用的是別的儀器，理由在上面。
   若你認為方法必須照原樣，說一聲，我照跑，只是那個數字不會有鑑別力。**
⇒ ★**順帶一條可複用的**：**wall time 是公尺尺；要量頭髮就得換尺**
   （★★而「換尺」不是放寬標準，是**讓量得到**）。

# ④下一站（★序照你的，不插隊）
```
①`tracer_completeness`（3 床的最後一張）——★仍缺那格量測：Team7 在那 400 tick 窗裡
  有幾次 `result != committed`。★★我可以直接跑，除非你要先定判準。
②控制場景床 腿A＋腿B（blueprint 批准，★★腿B＝「不在自家營地＋已承諾紮根 ⇒ 會不會走回去」）
  ★★★而我同意他的讀法：兩個支配子條件【同時為真】指向「承諾在而人不回家」＝手不聽腦 means-end 疑雲
③fixture B（slot 滿＋升級買得起 ⇒ upgrade 該贏）仍紅，等 blueprint 裁設施 vs 據點升級優先序
★標著不追（你的）：`_construction_facility_need` 沒自家據點就 return 0
  ⇒ 遊走隊/新生隊要蓋第一個據點時，material need 從哪來 —— 先有雞先有蛋那一族
```
