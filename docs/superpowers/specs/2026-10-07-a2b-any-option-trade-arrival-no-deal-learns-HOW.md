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
