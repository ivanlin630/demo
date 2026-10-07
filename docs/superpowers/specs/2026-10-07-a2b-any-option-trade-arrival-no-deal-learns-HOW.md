# A2b：任何 option 派出的貿易 task，到場零成交都要學到（HOW，小票；R① 先核前提）

```
票源：C2′ 實量（實作端 2026-10-07，713c86bd6，seed 1337，30 天）：到場零成交 41 隊·日＝option「貿易」10＋其他 option 派出 TASK_TRADE 31
  （maintain_tools:resource 11、maintain_food:resource 8、build_workshop:resource 4、囤貨 3、混合 4、買糧 1）
  例：Team11 day28–29 maintain_food 停在 (10,6) 市集，整天只有 eat_team
前提（逐字）：
  sim_runner.gd:928 失敗記號只在 `String(_t.current_option) == "貿易"` 時記（A2 刻意收窄）
  failure_memory.gd:196 mult_for_option：option 不在 OPTION_FAIL_KEY ⇒ 1.0（maintain_*:resource 等動態 option 全不在）
  goal_resolver.gd:971/981/1086 資源目標的手段候選 ＝ {"task": TASK_TRADE, "target": market_pos}——目標市集在【候選】裡，不在 ctx
⇒ 31 筆：到場什麼都沒有 ⇒ 放手 ⇒ 下一輪同一個 option 對同一個市集照樣 1.0 ⇒ 可能重撞（Team11 連兩天）
```

## 做什麼（形狀；R① 核完再鎖）
```
①記：sim_runner:928 的條件從「option==貿易」改成「current_option ≠ 領取」（領取有 A3 自己的落空記號）
   key ＝ (current_option, 到場那格 tile_id)；reason trade_arrived_no_deal 照舊
②讀：折價要知道【這一個候選要去哪個市集】
   今天 mult_for_option(opt, ctx) 只拿 option 字串＋ctx ⇒ 拿不到候選的 target
   ⇒ 候選路徑（goal_resolver 產出、帶 dispatch target 的）在引擎乘折價那一處（decision_engine.gd:371）改傳候選的 target tile；
     OPTION_FAIL_KEY 新增一種目標寫法 "cand:target"（＝候選 dispatch 的 target 那格）
   ★「貿易」本身維持 ctx:trade_target_tile_id（A2 已驗）
③粒度：key 帶 option ⇒「買糧在這市集撲空」不會讓「賣貨去這市集」也折價（接太粗＝一次撲空對所有用途折價）
```

## R① 請核（前提未驗）
```
(a) decision_engine.gd:371 那一處手上有沒有候選的 dispatch dict（還是只有 option 字串）——決定 ② 要改幾層
(b) 動態 option 名（maintain_food:resource 等）在 FailureMemory 的 unmapped 計數裡是否已出現（failure.unmapped.*）——母體是否就是這 31 筆的那幾種
(c) 還有沒有別的 option 派 TASK_TRADE 而不經 goal_resolver（options.gd:27/55/492/510/548 那幾處）
```

## 驗收（草）
```
P1 C2′ 床拆兩行：「其他 option」那一行改後下降（同 seed；先量，不預測數字）
P2 佈置：maintain_food 撞空同一市集兩次 ⇒ 該 option 對該市集折價 <1；對另一市集 =1；「貿易」option 對該市集不受影響
P3 反向：把 ① 改回只記「貿易」⇒ P2 必紅
P4 world-fp 會變 ⇒ 先量、同 commit 換基準
```

## ★R① 結果（366881451）：premise_contradiction ⇒ HALT，「做什麼」那節作廢待重寫
```
(a) 成立：decision_engine.gd:310 `_applicable` 是純 String 陣列，:371 只有 opt＋ctx ⇒ 拿候選 target 要改不只一層
(b) 不成立：failure.unmapped.* 對所有未接線 option 都數 ⇒ 母體比 31 大，讀碼答不出
(c) 致命：「買糧」options.gd:477-493、「囤貨」:534-556 不經 goal_resolver，target 在 to_task（派出那一刻）才算 ⇒「候選帶 target」那條路接不到它們 ⇒ 違反票名「任何 option」
⇒ 重寫前先決定學在哪一層（兩案，都要先量）：
   (甲) 學在 option 的 util（今天 A2 的做法）：每個派 TRADE 的 option 都要能在評估時說出「我會去哪個市集」——買糧／囤貨要把 target 計算從 to_task 前移成純函式（先驗它無副作用、評估與派出算出同一格）
   (乙) 學在選市集那一步：失敗記號 key＝(用途, 市集)；所有挑 market_pos 的地方（goal_resolver 三處、options 五處）都經同一支「挑市集」函式並讀折價 ⇒ 撞空的市集排到後面；沒有別的市集時 option util 才折價
   我傾向 (乙)：一支挑市集函式收掉八處各自挑（今天就是八份），而失敗學習本來就該讓人換地方，不是讓人放棄目的
下一步：量測員量 (b)＋各 option 派出貿易到場零成交的次數與「同一市集重撞」比例（多 seed）——重撞率低就不值得做
序：深層批（不擋第五輪）
```
