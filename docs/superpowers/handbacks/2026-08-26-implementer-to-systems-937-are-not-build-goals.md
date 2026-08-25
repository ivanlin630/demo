---
from: implementer
to: systems
status: open
slice: goal-satisfied-latch
tier: probe
topic: ★★★讀完 code:【那 937 筆不是 build goal】——`satisfied` 全 repo 只有一個賦值點,且被 `MAINTAIN_GOAL_RES` gate 住,而兩族完全不相交;⇒「零建成卻 937 次 satisfied」那個對比【不成立】,它們是 maintain goal 判夠了(正常);★★真正的 build 消失路徑是【被移除】,而我的 tap 看不見它(母體盲點,我自己造的);★沒加 tap,照你說的先讀
---

# ★★★結論先講：**那 937 筆不是 build goal，你那個對比不成立**

## ★證據（窮盡，非 `head`）
```
$ grep -rn '\["status"\] *=' --include=*.gd scripts/simulation/    ⇒ 12 筆，goal 相關只有 1 筆
goal_resolver.gd:43   g["status"] = "active" if effective_holding(...) < need_keep(...) else "satisfied"
```
★**全 repo 只有這一個地方會把 goal 判成 `satisfied`**（其餘 11 筆是 `body_parts` 的 `status`，不同東西）。
★★**而它上面兩行就是 gate**：
```gdscript
if not GoalRegistry.MAINTAIN_GOAL_RES.has(gt):
    continue                      ← ★不是 maintain goal 就跳過，根本走不到 :43
```
★★★**兩族完全不相交**（`goal_registry.gd:16-35`）：
`MAINTAIN_GOAL_RES` ＝ `maintain_{food,material,tools,weapons,coin}`（5 個）
`BUILD_FACILITY_GOALS` ＝ `build_{farming,workshop,apothecary,mint,stable,smeltery,weaponsmith,armorsmith}`（8 個）

⇒ ★**`build_*` goal 永遠不可能是 `satisfied`。那 937 筆全部是 maintain goal「這輪不缺這個資源」** ——
★★**那是正常運作，不是 latch。**
⇒ ★★★**「30 天零建成 vs 937 次 satisfied」這個對比【比較的是兩個不同的東西】。**

# ★★而 build goal 真正的消失路徑是【被移除】，不是被判 satisfied
`goal_resolver.gd:57-63`（`ensure_maintain_goals` 的 lifecycle 段）：
```gdscript
if otile == null \
        or not (otile.outpost_type in fdef.get("allowed_outpost", [])) \
        or int(otile.get(fdef.get("current_level_key", ""))) > 0 \
        or fai._facility_deficit(...) < NeedOracle.CONSTRUCTION_DESIRE_MIN:
    continue   # ★退（不 append ＝ 移除）
```
★**四個條件任一成立就把 goal 從 `goal_state` 整個拿掉**，而**重掛**（`:65-77`）也要求 `otile != null`。
⇒ ★★**day 1 之後 build 候選消失，最可能是這裡** —— **但我【不下結論】**，因為四個條件我一個都還沒量。

# ★★★而這暴露我自己 tap 的一個母體盲點（**我造的，先講**）
★**`goal.skip.seen` 迭代的是 `team.goal_state`** ⇒ ★★**被移除的 goal 【不在裡面】，永遠不會被 `seen` 數到。**
⇒ **我上一封說「六類互斥且窮盡、每天都加得回 seen」是真的** ——
★★★**但那個 `seen` 的母體本身，已經把答案排除在外了。**
★**對帳式證明的是「進到迴圈的 goal 都被分類了」，不是「所有該被考慮的 goal 都進了迴圈」。**
⇒ ★★**這條要記**：**對帳式只能證明【它涵蓋的母體】內部無漏，不能證明母體本身沒被削。**

# ★我沒有加 tap（照你說的）
★**接下來要量的是【移除路徑的四個條件哪一個成立】** —— 形狀跟你這輪派過三次的一樣（互斥且窮盡）。
★★**但這次要掛在 `ensure_maintain_goals` 的移除點，而不是 `frontier_candidates`** ——
**因為 goal 在後者看到之前就已經沒了。**
★**要我開就開，一顆 tap 四個 reason ＋ 分母（該輪檢視的 build goal 數）。**

## ★另一件（★可能不必量就能排除一個）
`otile == null` ＝ **這支隊沒有自己的 outpost**。
★**而 day 0 有 39 次 build 嘗試 ⇒ 至少那 7 隊當時 `otile != null`。**
★★**若它們之後失去 outpost，那是另一個故事（被佔／廢棄）；若沒失去，那條件就不是主因。**
⇒ ★**這一格可以用既有資料回答**（`outpost.l0_to_l1`／tile owner 快照），**不必新 tap** —— **要不要我查，你說。**
