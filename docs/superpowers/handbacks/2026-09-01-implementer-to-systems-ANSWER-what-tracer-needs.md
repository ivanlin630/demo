---
from: implementer
to: systems
status: open
slice: tracer-observe-purity
tier: probe
topic: ★★★答案:tracer 需要 to_task 的只有【靜態 option 的 task/target 兩欄】→ 一個 bool nd → 而 nd 的唯一消費者是 dump 裡的【一個 ✗ 字元】;★★而 production 在 faction_ai:2804 用【一模一樣的表達式】對同一批候選算同一個判斷,只是晚一個迴圈 ⇒ tracer 不需要自己呼,它要的東西 production 待會就會算出來;★A 案成立,形狀＝把 nd 改成 dispatch 時順手戳記(零額外呼叫⇒零寫入⇒不需要任何黑名單);★★★代價我誠實列了一項
---

# ★★★①答案（一句話）
> **tracer 需要 `to_task` 的，只有【靜態 option 的 `task` 與 `target` 兩欄】，
> 用來算【一個 bool `nd`】，而 `nd` 的唯一消費者是 dump 字串裡的【一個 ✗ 字元】。**

```
specimen_tracer.gd:99-102   var td = DecisionOptions.to_task(...)
                            nd = (task == IDLE) or (target == (-1,-1) and task != FLEE)
specimen_tracer.gd:110      _cd["nd"] = nd
specimen_tracer.gd:388      "✗" if c.get("nd", false) else ""     ← ★唯一消費者
```
★**交叉驗**（`nd` 只有兩個字母，怕 grep 撈不乾淨）：我用 `get("nd"` 與 `["nd"]` 兩個**字面**再查一次
⇒ ★★production／床／判決檔**零讀取**。它就是給 QA 人眼看的一個標記。

# ★★②而動態 candidate【早就不呼叫了】
```
specimen_tracer.gd:96-102
  var _ctt0 = e["cand"]["to_task"]                  ← candidate 自帶
  if not _ctt0.is_empty(): nd = (target == (-1,-1)) ← ★零呼叫
  else:                    nd = ...to_task(...)     ← ★★只剩這條會呼（靜態 option）
```
★同函式另外兩處用 `to_task` 的（`要做的事`、means-end 標記）**全是純讀 candidate 自帶的 dict**。
⇒ ★★**所以「tracer 呼 to_task」的面積，比我們一路以來假設的小很多。**

# ★★★③關鍵事實：production 自己【晚一個迴圈】算的是同一件事

```
tracer      specimen_tracer.gd:99     DecisionOptions.to_task(state, team, opt)
production  faction_ai_system.gd:2804 var td = (e["cand"]["to_task"]) if e.has("cand")
                                         else DecisionOptions.to_task(state, team, opt)
            faction_ai_system.gd:2822 if tgt == (-1,-1) and td["task"] != TASK_FLEE: continue
                                         ↑★這就是 nd 的判斷式本身
```
★**同一個表達式、同一個判斷、同一批候選** —— 差別只有時間點：
  tracer 在 `rank_scored`（decision_engine:53）內算；production 在 dispatch 迴圈算。
⇒ ★★★**tracer 不需要自己呼：它要的東西，production 待會就會算出來。**

# ★④所以 A 案成立，形狀具體
```
把 nd 從【capture 時自己算】改成【dispatch 時由 production 順手戳記】
⇒ 零額外呼叫 ⇒ ★零額外 gather ⇒ ★★不需要任何黑名單（沒有寫入要抑制）
```
★★★**而這解掉了三次失敗的根**：
```
前三次都在問「要抑制【哪些】寫入」 —— 而那個問法保證會漏，因為它要枚舉
★正確的問題是「為什麼要走那條會寫的路」 —— 而答案是【不必走】
```

# ★⑤代價（★誠實列，這是唯一的損失）
```
dispatch 迴圈在【第一個可派候選】就 return
⇒ 排在它後面的候選拿不到 nd ⇒ dump 上不會有 ✗
★★而 nd 的用途正是解釋「util 最高的那個為什麼沒被派」⇒ 關心的是【前段】
⇒ ★★★損失落在【本來就沒有故事價值】的那一格：
   排在已派候選之後的選項，production 根本沒考慮它們，「可不可派」對故事沒有意義
```
★**若 QA 真的要後段的 ✗**，那不是「順手戳記」給得起的 ⇒ 需要 B 案（真的 pure 投影）
⇒ ★★而那是另一個決定，我不在本票裡替你選。

# ⑥誠實限
```
①★「沒有東西讀 nd」是【負斷言】：全域 grep + 兩個字面交叉驗
   ★★仍是下界 —— 若有人用動態 key（c[k] 迴圈）讀它，我看不到
②★本票 production diff = 0 行（A 案實作不在這票，你說只查不修）
③★★我沒有再列一次「有哪些寫入」——你明說那條路已經失敗三次
```

# ⑦落地
```
docs/measurements/2026-09-01-what-tracer-needs-from-to_task.txt（commit e837f575，已 push）
```
