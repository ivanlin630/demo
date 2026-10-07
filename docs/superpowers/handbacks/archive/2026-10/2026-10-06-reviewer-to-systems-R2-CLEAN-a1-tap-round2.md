---
from: reviewer
to: systems
status: consumed
slice: A1 建設「為什麼沒開工」的只觀測 tap
topic: R② 第二輪（`8b838fbe3`）＝ **CLEAN**｜兩列都落地，行號與既有函式核對正確；`construction_funnel_bed.gd` 確認不在 `merge-gates.tsv`／`.claude/hooks/` 任何一處，是支沒掛進電池的診斷床，支持「先跑它」優先於「重建」的判斷
---

# 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "兩列都核過：§0③ 改成有範圍聲明＋P0 驗證假設（不再是無範圍負斷言）；T2′ 重用既有命名與既有床，T2 原文保留當『若答不出來才做』的備案，結構乾淨。可派。" }
```

# 核對

```
①_evaluate_infrastructure def :6183／_evaluate_independent_infrastructure def :6113
  —— 跟我自己 awk 找到的定義行完全一致。
  home_count ≡ state.own_outpost_count(team_id)（world_state.gd:323，函式存在）—— 映射正確。
  P0 把「推論」換成「先量」，不是我要求的字面重複，是真的把判斷順序倒過來（先驗證假設才用它），對。
②「9 處」：我重算 git grep -n "funnel.build_gate\." 自己的結果也是 9 行
  （:5378/:5383/:5409/:5410/:5415/:5430/:5448/:5454/:5510）—— cost 那一道有兩行（泛用＋逐資源）,
  9 行對應 8 個獨立閘家族，跟我上一輪的描述一致，不是矛盾，只是用了不同的計數單位。
  construction_funnel_bed.gd 核過：@bed-kind: diagnostic，grep 遍 merge-gates.tsv 與 .claude/hooks/
  都找不到它 —— 確認是支沒被電池常態跑的診斷床，這支持「先跑它」比「重建一份」更該優先的判斷，
  也解釋了為什麼這個現成答案一直沒被人看到。
③(ii) 改成前閘狀態＋交叉核 tile_occupied —— 落地文字跟我建議的一致。
```

⇒ 可派（排序你自己定）。
