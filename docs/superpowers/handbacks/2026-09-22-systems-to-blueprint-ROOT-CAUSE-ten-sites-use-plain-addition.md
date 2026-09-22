---
from: systems
to: blueprint
status: consumed
slice: 凍結根因 —— **找到了，而且是結構性的**
topic: ★★★**10 處 cadence 用【純加法】`current_tick + CONST` 而不是 `CadenceStagger`** —— 而**純加法會把已經同相的隊【永遠鎖在一起】**｜★**你的假說對了，而我兩輪靜態沒找到它**：它的形狀既不是「整點取模」也不是「經過時間比較」，是**一句看起來完全無害的加法**｜★★**對照：33 處走錯開、10 處純加法** —— 而**尖峰佔六成隊（72／63 隊，61.5%／62.4%）**
---

# 一、★★★根因（機制，不是相關）

```
`CadenceStagger.next_tick()` ＝ `(cycle+1)*cadence + _mix(team_id, cycle) % cadence`
   ⇒ ★**offset 逐 cycle 變化** ⇒ 同相的隊**下一輪就分開**
**而純加法** ＝ `next = current_tick + CONST`
   ⇒ ★★**同一 tick 決策的隊，下一次【還是同一 tick】** ⇒ **相位永遠不變**
   ⇒ ★★★**而世界生成時所有隊幾乎同時出生 ⇒ 它們【從一開始就同相】⇒ 永遠不分開**
⇒ **這解釋了 62%**：那幾個欄位把六成的隊鎖在同一個相位上，**而錯開機制在別的 33 處好好地跑著**
```

# 二、★那 10 處（★逐一列出，這就是票的清單）

```
faction_ai_system.gd:630   threat_eval_next_tick      = current_tick + THREAT_CADENCE
faction_ai_system.gd:862   residency_eval_next_tick   = current_tick + RESIDENCY_CADENCE
faction_ai_system.gd:2706  info_eval_next_tick        = current_tick + INFO_DISPATCH_CADENCE
faction_ai_system.gd:4163  subteam_eval_next_tick     = current_tick + SUBTEAM_CADENCE
faction_ai_system.gd:4379  decision_eval_next_tick    = current_tick + DECISION_CADENCE
labor_system.gd:162        labor_eval_next_tick       = current_tick + LABOR_CADENCE
decision_context.gd:614    idle_employ_next_tick      = current_tick + LaborSystem.LABOR_CADENCE
decision_context.gd:870    expand_eval_next_tick      = current_tick + FactionAISystem.INFRA_…
decision_context.gd:1330   consolidate_eval_next_tick = current_tick + FactionAISystem.C…
goal_resolver.gd:28        goal_eval_next_tick        = current_tick + GOAL_EVAL_CADENCE
```
★★**而 implementer 的歸因欄命中的四個（`expand`／`prosperity`／`subteam`／`report`）裡，
`expand` 與 `subteam` 就在這份清單上** —— ★**歸因與機制在同一個地方對上了。**

# 三、★★我兩輪靜態沒找到它 —— **而原因值得記**

```
我掃的是：①`% TICKS_PER_HOUR == 0` 的整點掃描 ②「經過時間比較而附近沒有 CadenceStagger」
⇒ ★★**兩個都零命中，因為它的形狀是【一句加法】** —— `next = now + C`
⇒ ★★★**它不長得像一個排程 bug，它長得像【正確的排程】** ——
   **而「看起來正確」正是它躲過兩輪掃描的原因。**
★真正抓到它的是：**implementer 量出四個具名欄位** ⇒ 我拿那四個名字去讀 code ⇒ 一眼看到差異
   ⇒ **量測給了名字，靜態才找得到路。**
```

# 四、★要你裁的三件

```
①**修法形狀**：那 10 處改用 `CadenceStagger.next_tick` ⇒ ★**改變決策時刻 ＝ 改變世界** ⇒ 世界改變窗
   ★★而它**便宜**：10 個賦值點，且 helper 已存在、已被 33 處使用
②★★★**要不要加一支閘**（禁 `*_eval_next_tick = current_tick + …`）——
   ★我**不自己加**：你今天定過「已有 hook 覆蓋的不准再加第二支」。
   ⇒ 而**這裡沒有既有 hook 覆蓋**，且**前例就在旁邊**（`bed-arm` 閘就是「新床不得自己拼順序」）
   ⇒ **我建議加，但那是你的裁定**
③**序**：這一票是否插在指令佇列化之前 —— ★我建議**插前面**：它更便宜、而且**它可能讓分片整個不必要**
```
