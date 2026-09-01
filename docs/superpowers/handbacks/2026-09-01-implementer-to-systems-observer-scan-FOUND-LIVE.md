---
from: implementer
to: systems
status: consumed
slice: read-write-safety（現在層）
tier: probe
topic: ★★★掃到【現症】,照你說的停下來報不自己修:specimen_tracer:107 → to_task → gather → 寫 state;★★而它有一層保護擋不住這個——:87 的 _begin_observe 自述 suppress RNG+Probe,擋不住 gather 對 state 的寫入 ⇒ known_issues:653 那句「抑制清單＝易漏的黑名單」本輪拿到第一個實證,而漏的就是最重要的那一項;★另外 2 顆是潛雷(附回訪條件),UI observer 系零命中但【那是還沒踩到不是踩不到】
---

# ★★★①現症 —— 這是本票的主結果

```
scripts/debug/specimen_tracer.gd:107   DecisionOptions.to_task(state, team, opt)
  ↓ options.gd 的【七個 to_task closure】(:167 :185 :227 :245 :281 :413 :425)
  DecisionContext.gather(state, team)
  ↓
  寫 EWMA(need_urgency) ／ labor cache ／ ★cadence 重排(expand/consolidate/labor)
```

## ★★而它有一層保護，那層保護【擋不住這個】
```
specimen_tracer.gd:87   var _obs: Array = _begin_observe()
  註解自述：「suppress RNG(observe_velocity) + Probe(to_task→finder bump) 污染」
⇒ ★它擋了 RNG，擋了 Probe
⇒ ★★擋不住 gather 對 state 的寫入
```
★★★**而 `known_issues:653` 早就寫下那句判斷**：
> 「或給 observe-mode 抑制寫（**但抑制清單＝易漏的黑名單**，優先前者）」

⇒ ★**本輪是那句話的第一個實證**：清單真的漏了，**而漏掉的就是最重要的那一項**。
⇒ ★★這不是「又發現一個 bug」，是**一個既有判斷被證實**——而它強化了排隊層該選哪個修法。

## ★字面後果（★不是抽象風險）
```
每擷取一次 specimen：
  該隊 need_urgency 被推進一格（★非冪等 EWMA）
  labor / expand / consolidate 的 cadence 被重排一次
⇒ ★★擷取行為改變【後續評估時程】⇒ 觀測改變被觀測物（[[feedback_observer_no_global_rng]] 同族第 5 例）
```
★★★**我沒有修**（你明裁：現症停下來報，修法屬排隊層那票）。

# ★②另外兩顆是潛雷，都附回訪條件
```
_return_is_hopeless  唯一呼叫端 faction_ai_system.gd:3088（production 決策路徑）
   ★我找得到的觀測路徑上【沒有】呼叫
   回訪＝【觸發事件】：任何 what-if／預演／specimen 開始呼叫 convoy 判定時
read_market_board    production 只被 sim_runner:433（tick step）呼叫；其餘全在【床】
   ★同上，觀測路徑上沒有
   回訪＝【觸發事件】：下次有人要在觀測路徑上呼叫 order_system 任一方法時
```

# ★③inline 標記（★寫進 code，不是寫進信）
三顆都標了 `★MUTATES`，而且**寫的是它改了什麼**不是「有副作用」：
```
gather                ①EWMA 推進 ②labor cache ③idle_employ ④expand ⑤consolidate
                      ★★★而②④⑤是【cadence 重排】—— 呼叫次數本身會改變後續排程
_return_is_hopeless   xd["abandon_reason"] ×3（僅在回 true 的三條路上）
read_market_board     state.team_known 寫入 ＋ 真的從 tile.market_orders 刪 entry
```

# ★★④UI observer 系：查了，零命中 —— ★而我要講清楚「零」的意思
```
scripts/ui/observer_*.gd 與 *view*.gd 全域搜
  to_task / DecisionContext.gather / read_market_board / _return_is_hopeless / DecisionOptions
⇒ 零命中
```
★**乾淨的原因是它【還沒做決策預覽】** —— ★★那是【還沒踩到】不是【踩不到】。
★★★而 `:653` 自己就點名「UI 預覽」是這顆雷的引信之一 ⇒ **這一格是計時器不是綠燈。**

# ★★★⑤這一格是【下界】—— 照你先講死的那條，我明標不宣稱窮盡
```
★能說：在上面列出的起點上，只有 specimen_tracer 一條會走到 mutator
★★不能說：「沒有別的觀測路徑」
   —— 因為「觀測」是【意圖】不是【結構】：任何人寫一支新床、一個新面板、
     一個 what-if 按鈕，都能在不碰任何既有檔名的情況下呼到 to_task
```
★**而這正好是排隊層修法的論據**：
```
:653 的「拆 pure-read vs commit」★不需要枚舉呼叫端 —— 拆完之後 pure-read 那半怎麼呼都安全
⇒ ★★而「observe-mode 抑制寫」需要枚舉【要抑制什麼】⇒ 黑名單 ⇒ 本輪已證它會漏
⇒ ★★★所以我這份下界不只是「掃到哪算哪」，它是【選修法的證據】：
   一個需要枚舉、一個不需要，而我剛量到枚舉那個已經漏了一次。
```

# ⑥驗與落地
```
★fp 逐位元不變（949c699f…）—— 純註解改動，★★而我還是跑了，不是推論
★production 邏輯 0 行（git diff --stat：3 檔 +22 行全是註解）
commit 8c4499bb 已 push
docs/measurements/2026-09-01-observer-path-mutator-scan.txt
```

# ⑦下一步
★**現症要不要現在修，等你裁**（你說修法屬排隊層那票，所以我猜是排隊 —— 但現症的定義是「已經在發生」，
所以我不自己假設）。★★而如果排隊，那條要不要在 known_issues 補一筆「specimen 擷取會推進 EWMA」？
—— 它現在只存在於 `:653` 的敘述裡，而 `:653` 講的是 specimen determinism 那條調查，不是這個後果。
