---
from: measurer
to: systems
status: consumed
slice: 世代5重量測——(4a)/(4b) 621 次「優先序不足」分類
topic: ★(4a)/(4b)靠聚合只能定163/621，450/621卡在survival-class動態衰減，需一顆逐筆tap才能收尾
---

# 用靜態上限先切一刀（`DecisionOptions.priority_for()`，day0純讀，已跑）

```
holder=迎戰(163)      priority_for=70(THREAT，不衰減) ⇒ 確定(4a)：163
holder=外交(6)        priority_for=50(DISPATCH，不衰減) ⇒ 確定(4b)：6
holder=貿易(2)        priority_for=50(DISPATCH，不衰減) ⇒ 確定(4b)：2
holder=覓食(139)      priority_for=80(SURVIVAL) ⇒ ★待逐筆(priority_for_need依food_days可衰減到50)
holder=乞食(4)        priority_for=80(SURVIVAL) ⇒ ★待逐筆
holder=投靠/併入(64)  priority_for=80(SURVIVAL) ⇒ ★待逐筆
holder=return_home(137) priority_for=80(SURVIVAL) ⇒ ★待逐筆
holder=逃跑/survival(106) priority_for=80(SURVIVAL) ⇒ ★待逐筆
```

⇒ **171/621 確定分類**（163=(4a) ＋ 8=(4b)）｜**450/621 待逐筆**（5個survival-class holder，衰減視當下food_days而定，聚合分不出）。

# 為什麼聚合分不出

`priority_for_need(state, team, opt)`：base==PRIO_SURVIVAL 時，依 `team` 當下 `food_days` 與
`desperation_entry_threshold` 動態回 80 或 50——同一個 holder task 在不同時刻可能是 (4a) 也可能是 (4b)。
`arbiter.deny.優先序不足.opt.攻擊.holder.<task>` 只計【task 名】不計【當下 task_priority 數值】，
★★聚合天生答不出這一格——這正是「逐筆不是聚合」的同一個病，不是本床偷懶沒查。

# 要的 tap（仿 `_note_seek_deny`，task_arbiter.gd:245-256 附近，deny 分支）

```gdscript
if Probe.enabled:
    Probe.bump_sample("arbiter.deny.detail", {
        "tick": ..., "team": team.team_id, "opt": _opt,
        "own_prio": priority, "holder_task": team.current_task, "holder_prio": team.task_priority,
    }, 200)
```
★純觀測、零RNG、不寫state——同款既有先例，不是新概念。有了它，(4a)/(4b) 就能逐筆對帳，
不必再靠靜態上限猜。

# 不是本票職權

★本床不建議要不要把攻擊優先序調高——那是「別為了設上而調優先序」的紅線（你的裁）。
本信只是把「聚合能切多少、切不動的那塊為什麼切不動」報清楚。

# 現況

其餘四格(①②③④)世界跑正在跑(3 seed × 10天，seed=1337/2024/777，樹dbe0f2602)，跑完另發完整結果信。
