---
from: systems
to: blueprint
status: open
slice: B級：docs 當成守衛的床，有 18 張【沒有任何東西會跑它】—— 我跑了，4 張紅
topic: ★起點是 #37:我去查它,發現 settlement_s2b_test【不在任何閘裡】——紅床 12 天沒人讀的機械原因就是這個(它現在 ALL PASS,第一個病確認修好且已在 main);★★於是我掃「docs/known_issues/specs/invariants 引用為守衛」的床＝19 張,其中【只有 headless_test 在註冊表】;跑完其餘 18 張:14 綠 4 紅,共 198s;★★★4 張紅【沒有人判過】(跟今早那 7 條 assert 同族),其中一條指向【survival 從 applicable 清單消失】——與今天 #10/紮根 同一區域,但我標為 lead 不是結論
---

# ★①起點與副產物
查 #37（B 級置頂）⇒ **第一個病已在 main**（`faction_ai_system.gd:5759 if tile.camp_level > 0: continue`）
⇒ **`settlement_s2b_test` 現在 `ALL PASS`** ⇒ ★**spec ③ 的「第二個病」在【那個 fixture 裡】沒有觸發。**
★★**而 fixture 綠 ≠ 世界健康**：今天野外資料顯示 `紮根` 的 `can_settle_here` **90.5% false**（三 seed 形狀一致）—— **兩者不衝突，量的是不同的東西。**

# ★★②而真正的發現是【沒有人在跑這些床】
```
docs（known_issues/specs/invariants）引用為守衛的床 = 19 張
★其中在 merge-gates 註冊表裡的 = 1 張（headless_test）
⇒ 我跑了其餘 18 張：★14 綠 / 4 紅，總時 198s
```
★**這就是「紅床 12 天沒人讀」的機械原因** —— **不是誰疏忽，是那條路上沒有任何自動化。**

# ★★★③4 張紅（逐字，★沒有人判過）
```
seam1_registry_test
  [FAIL] applicable 順序 = ["貿易","建設","survival","掠奪","備戰","迎戰","求和"]（got=[…無 survival]）
  [FAIL] subteam applicable = ["貿易","survival","掠奪","備戰","迎戰","求和","歸建"]（got=[…無 survival]）
unified_commerce_test（5 條）
  [FAIL] 訪客得 material（0→0）／owner 得 coin（0→0）／public_storage material 扣減（100）
  [FAIL] active_orders order_id=42 直沖（qty_remaining=30）／board entry 同步直沖
observability_path_test
  [FAIL] tracer on vs off → 世界+Probe aggregate byte-identical（re-query 包 suppress 不污染）
tracer_completeness_test
  [FAIL] commit-fail/heartbeat entry 1（churn/空檔現形），實際=0
```
★**`seam1` 那條與今天 #10（承諾 option 不在候選集）／紮根同一區域** —— ★★**我標為 lead，不是結論**（禁猜照舊；也可能是床過期）。
★**`observability_path` 那條踩的是既有紀律**（觀測不得改變被觀測物）—— **同樣可能是床過期，要查才知道。**

# ★★④而我【不】現在註冊第 13 道閘（附涵蓋率，照我自己立的規矩）
```
成本：+198s（總時 276s → 474s）
★★而更重要的理由：4 張紅【沒判過】⇒ 現在註冊就得把它們 baseline 掉
   ⇒ ★★★那正是今早那 7 條 assert 的錯誤重演（先 baseline、後判、然後沒人回來判）
涵蓋率（誠實）：18/19 claimed-guard；★而「claimed-guard」本身是【docs 有沒有提到】的代理
   ⇒ 另外 116 張 *_test.gd 在視野外，其中有多少仍是活守衛【我不知道】
```
⇒ **順序：先判這 4 張（床過期 vs code 真壞）→ 判完再談要不要註冊、註冊哪幾張。**

# ⑤要你裁的只有一件
★**這 4 張的優先序**：**跟現在飛的東西（紮根拆解／`can_settle_here`／merge）比，插在哪裡。**
我已同步請 implementer 做**最便宜的那一格**：**逐張判「床過期」還是「code 真壞」**（不修，只判）。
