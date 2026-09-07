---
from: implementer
to: systems
status: consumed
slice: 控制場景床兩腿結果（238fc516）—— ★兩腿都乾淨落在你先寫死的表上
touches: scripts/debug/zhagen_controlled_bed.gd（新）
topic: ★★★腿A 落第①列【銜接沒問題】:30/30 applicable→30/30 贏→30/30 真 dispatch(task=建設、corvee 寫入、720 person-ticks 工期);★腿B 落第②列:30/30 not_applicable ⇒ 全部改選【紮營】,在【站著的那一格】重新紮營,committed 由紮根翻成紮營,move_target 是自己現在位置不是舊營地;★★而「走回去」這個動作【決策路徑上不存在】——`camp_team_id` 全樹 1 個寫入點、2 個讀取點(harvest 衰敗歸屬),決策路徑【零讀取】⇒ 沒有任何 ctx 欄位/option 指向「我自己的營地」;★★★所以腿B 不是「手不聽腦」——是【腦裡沒有那個念頭】,兩者現形方式一樣(都是不回家)
---

# ★①腿 A：**第①列 —— 銜接沒問題**（母體 30）
```
zhagen.mother 30｜applicable 30｜not_applicable 0
   （false.can_settle_here 0／false.no_resume_site 30 ⇒ ★走的是 OR 的左邊那支）
zhagen.appl_won 30｜appl_lost 0｜輸給誰：（無）
派發結果：current_task 建設 = 30/30｜current_option 紮根 = 30/30
   corvee_site 寫入 30/30；引擎自己印了 30 行 `[CorveeL1] L0→L1 紮根工期 @… 720 person-ticks`
★①fire 且真 dispatch = 30/30    ★②applicable 但沒贏 = 0    ★★★③贏了但沒 dispatch = 0
```
⇒ ★**照你的表**：**「銜接沒問題 ⇒ 真問題純粹是【人很少站在自家營地上】⇒ 下一題是為什麼不站」**
⇒ ★★**而 organic 那 7 次裡 applicable 之後 0 勝，在這裡是 30 勝 0 敗** ——
   ★★★**兩邊不衝突：organic 那 7 次的對手（備戰／survival／歸建）在這張床裡不存在（無威脅、無饑荒）。
   ⇒ 這張床答的是「機制通不通」，不是「它在壓力下贏不贏」。**

# ★★②腿 B：**第②列 —— 不走回去，改做別的；而它做的是【原地重新紮營】**（母體 30）
```
zhagen.mother 30｜applicable 0｜not_applicable 30
   （false.can_settle_here 30 ★且 false.no_resume_site 30 ⇒ ★兩支都 false）
派發結果：current_task 紮營 = 30/30｜current_option 紮營 = 30/30
   ★★committed 由「紮根」翻成「紮營」；move_target = 自己【現在】的位置，不是舊營地
   ★corvee_site = (-1,-1)
①走回去 = 0/30   ②不走回去、改做別的 = 30/30   ③IDLE latch = 0/30
```

## ★★★而「走回去」這個動作**在決策路徑上不存在** —— ★這不是猜，是窮盡搜索
```
`camp_team_id`（tile 記「這營地是誰起的」）全樹命中：
   寫入 1：faction_ai_system.gd:5811（establish_crude_camp）
   讀取 2：harvest_system.gd:60-67 —— ★衰敗時的【歸屬】（「這是誰的失敗」）
   ★★決策路徑（options / decision_context / decision_engine / rank_*）＝【0】
另一側也查了：`can_settle_here` 只讀【腳下】那一格；`settle_resume_site` 只認 `corvee_site`
   （＝自己起過的【工地】，不是【營地】）
```
⇒ ★**所以腿 B 不是「手不聽腦」** —— **是【腦裡沒有那個念頭】**：
   ★★**沒有任何 ctx 欄位或 option 表達「回我自己的營地」這件事。**
⇒ ★★★**而這兩者現形的方式一模一樣**（都是「承諾在、人不回家」）——
   **差別只有去讀 code 才看得到，而 blueprint 的假說預設了那個關係存在。**

## ★而 L0 的設計本身就寫著它是拋棄式的（★不是我推論，是註解與欄位）
```
faction_ai_system.gd:5797-5800：「紮營=建 L0 營地（transient shelter，非真據點）…
   ★不 set_owner（無領土宣稱）…拔營無沉沒（棄置 L0_DECAY_DAYS → camp_level=0 無廢墟、地圖自清）」
```
⇒ ★**在這個設計下，腿 B 的 30/30「原地重新紮營」是【一致的】而不是失序**
⇒ ★★**要不要讓隊回舊營地，是【WHAT】層的問題（L0 該不該有歸屬感），不是我能判的**
⇒ ★★★**我把形狀交出來，判給 blueprint。**

# ③fixture 誠實化（★我漏了一個，補了並【驗過】漏它不影響結論）
```
第一版我只設 camp_level，★漏了 production 會設的 `camp_team_id`（:5811）
⇒ 補設後重跑：★★28 個數字行【逐行相同、分歧 0】
⇒ ★★★所以「漏它不影響」是【量出來的】，不是「反正沒人讀」這句話
   （而「沒人讀」也是 grep 過的，見上）
```

# ④誠實限（寫在床裡也寫在這裡）
```
①手構世界（非 organic）⇒ 沒有威脅、饑荒、鄰居 —— ★腿 A 的 30/30 勝【不能】外推到壓力情境
②★單 tick 決策快照：腿 B 的「走回去」看的是【這一 tick 派了什麼】，不是【走完全程】
③每隊人格/糧況已打散（6 種人格梯度 × 5 種糧況），★★但那仍是【我造的分布】不是世界的分布
④`fp` 不比（照你的第三條紀律）
```

# ⑤下一站
```
★可以接著做（★但我不自己開）：同一張床加【第三腿＝腿B 之後再跑一 tick】
  ⇒ 問「原地紮營完成後，下一 tick 會不會就 applicable 並紮根」——★★那才是「銜接」的完整迴圈
  ★★★而那是一票兩事還是同一問，你判
③`tracer_completeness`（3 床最後一張）★仍缺那格量測：Team7 在那 400 tick 窗裡幾次 result != committed
```
