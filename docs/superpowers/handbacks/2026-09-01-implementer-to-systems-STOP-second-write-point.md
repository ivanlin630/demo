---
from: implementer
to: systems
status: consumed
slice: tracer-observe-purity
tier: infra
topic: ★★★照驗收③停下來報:R² 的「只剩 idle_employ 一處」有洞——我構造了一個情境,呼【一次】gather(advance=false) 就改了【3 個欄位】,而★★R² 指名的那一顆這次根本沒觸發 ⇒ 不是「還有第二個」,是【被指名的那個不是主要的】;★最嚴重的是 :273 ensure_fresh 會 WorldEvents.emit("labor_crisis") ⇒ 觀測路徑可以【叫醒隊伍重新思考】;★我沒有動修法,commit 26732a8a 只有證據
---

# ★★★①構造式實證（★不靠隨機跑撞窄觸發，照你驗收②的精神先用在診斷上）

```
呼【一次】DecisionContext.gather(state, team)   ← advance 預設 false ＝ 觀測路徑走的那條
⇒ 變動欄位 3：
   labor_eval_next_tick        0 → 4320    （cadence 重排）
   labor_alloc_size            0 → 2       （LaborSystem.rebalance 真寫入）
   consolidate_eval_next_tick  0 → 1440    （cadence 重排）
```
★★★**而 R² 指名的那一顆（`idle_employ` 快取）這一跑【根本沒觸發】**（`ctx.idle_labor = 0`）
⇒ ★**所以結論不是「還有第二個寫點」，是【被指名的那個不是主要的】。**
⇒ ★★如果照票直接去擋 idle_employ，驗收①（三跑 byte-identical）**會失敗**，
   而失敗的原因會看起來像「修法沒生效」——★★★**實際上是修錯地方**。

# ★★②code 佐證（★`advance` 只擋 EWMA，:703；其餘寫點無閘）

```
:273  LaborSystem.ensure_fresh(state, _btile)
:286-287  idle_employ_cached / idle_employ_next_tick      ← R² 指名的那顆（需 idle_labor>0）
:381-384  expand_eval_next_tick / expand_site_cached
:640-650  consolidate_target_cache / absorb_target_cache / consolidate_eval_next_tick
```

## ★★★而 :273 那一顆比其他三顆嚴重一個量級
```
labor_system.gd:19-30 ensure_fresh：
  :22-27  for 共址 PRODUCE 隊：food_runway 跌破危機線 ⇒ WorldEvents.emit(state, "labor_crisis", [_tid])
  :28     if 未到 cadence 且 labor_alloc 非空 ⇒ return      ← ★早退【在 emit 之後】
  :30     rebalance(state, tile)
```
⇒ ★**emit 在早退之前** ⇒ 每呼一次 `ensure_fresh` 都可能發事件
⇒ ★★而 `labor_crisis` 是 T0 喚醒 ⇒ ★★★**觀測路徑可以【叫醒隊伍重新思考】**
   —— 那不是「快取被寫髒」，是**觀測直接改變了誰在什麼時候做決策**。

# ★③這不是 R² 失敗 —— 是負斷言的老問題，我把它講清楚

```
R² 查的是：「29 個 to_task handler 有沒有【讀】 idle_employ_value」⇒ 答案：沒有
★而那證明的是【那顆快取對觀測路徑沒用】
★★不是【gather 沒有別的寫點】
⇒ ★★★兩個命題不同，而它們讀起來很像 —— 而票把前者當成了後者的證據
```
★**同一族**：`known_issues:653` 的「三項副作用」也是這樣被我們沿用成現況的（你已入 cases）。
★★**而這次的差別是：我們有一個【機械的反證方式】**——構造一次呼叫、比欄位。
★★★**建議把它變成驗收的一部分**：不只驗「tracer 開關三跑相同」，
   也驗「gather(advance=false) 呼一次，指定欄位集合零變動」——
   ★後者失敗時直接指出【是哪一欄】，而前者只會說「不一樣」。

# ★④我沒有動修法
```
commit 26732a8a：只有 scripts/debug/gather_purity_probe_bed.gd（構造床）＋ 一份 artifact
★production diff = 0 行
```

# ★⑤要你裁的（★修法的形狀變了，所以我不自己選）
```
①★第 4 案（源頭擋一個寫點）現在【不成立】—— 至少要擋 4 組，而 :273 那組還會 emit 事件
②★★而「擋 4 組」就是黑名單，正是 spec §2 自己判為反面教材的形狀
   ⇒ ★★★所以候選回到 B（pure 投影）或 C（snapshot/restore），或【A：tracer 不呼 to_task】
③★我的傾向：先問「tracer 到底要 to_task 的什麼」——
   R² 已經幫你查過一半（29 個 handler 不讀 idle_employ_value）
   ⇒ 若 tracer 只要「這個候選會派成什麼 task」，那是 to_task 的【回傳值】，
     而回傳值不需要那些快取 —— ★★那就回到 A/B，而不是擋寫點
④★★★但這是設計選擇，我只把新事實擺出來
```

# ⑥誠實限
```
★我的欄位清單是【我列的】⇒ 這是下界；我另附了 pending_rethink 大小當全域證據，
  但那一欄這次沒變（因為 food_runway 沒跌破危機線）——★★沒變不等於不會變，
  ★★★而 :273 的 emit 就掛在那個條件上：構造一支瀕餓 PRODUCE 隊就會看到它。
  ⇒ 我沒有再構造那一個，因為到這裡已經足夠讓你重裁修法形狀了。
```
