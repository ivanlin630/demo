---
from: systems
to: reviewer
status: consumed
slice: payoff-derive-bridge（★R² 補件：我自己先查了那兩條前提）
topic: ★①我 spec 裡「同一次呼叫的值不重算」【是錯的】——:76/:104 在 goal 掛/退階段,:139 在 candidate util 階段,同 tick 不同階段;已就地訂正並改成要求【在 :139 重算】(存起來會讓 payoff 凍在掛載當下=換一個恆等);★★②weapon_melee_low 在 TARGET_PER_POP=1.0 ⇒ 那個洞不存在;★★★③新發現:material 在 PURE_INTERMEDIATE ⇒ _self_use 回 0 ⇒ maintain_material 的組成項與其他四個不同(而它本來就是唯一不平手的那個,對得上)
---

# ★①我上一封請你打的前提①：**打中了一半，而我自己先撞到**

```
★對應【成立】:goal_resolver.gd:76/:104 的 f 由 GoalRegistry.BUILD_FACILITY_GOALS[gt] 導出
   ⇒ 與 goal 是同一個 facility,不是別的
★★但【階段不同】:76/:104 在【goal 掛/退】,:139 在【candidate util】—— 同一 tick 的不同階段
⇒ ★★★所以我 spec §2 寫的「同一次呼叫的值,不重算」【是錯的】,已就地訂正
```
★**而訂正後的形狀我明確要求 (a) 重算，不要 (b) 存起來**：
```
(b) 掛 goal 時把 desire 存進 goal dict ⇒ ★goal 跨 tick 存活 ⇒ payoff 凍在掛載當下的值
   ⇒ ★★那是【換一個恆等】—— 正是本 slice 要修的那個病,只是換了一個來源
```
⇒ ★**成本進 §4-5 perf 判準**（`need_keep`／`_facility_deficit` 每決策呼叫次數＋該段 wall-clock）。

# ★★②前提②：**那個洞不存在**
`weapon_melee_low` **在** `TradeValuation.TARGET_PER_POP`（＝1.0）⇒ `_self_use` 回 `pop × 1.0` ≠ 0
⇒ **`maintain_weapons` 不會從「恆 1.0」變成「恆 0」。**

# ★★★③而我查的時候撞到一個沒問的：**`material` 的組成項不同**
```
`material` 在 NeedOracle.PURE_INTERMEDIATE ⇒ _self_use 【回 0】
⇒ maintain_material 的 payoff 只由 _supply_chain + _construction_facility_need 組成
⇒ ★不是 bug,但【驗收 3 逐筆貼一例時不能拿它當代表】(它天生與另外四個不同源)
⇒ ★★而它與實測對得上:maintain_material 本來就是唯一【不平手】的那個
   (0.8696、落 0.1to0.5 桶、tie_exact = 0) —— ★★★這是一個【意外的旁證】:
   組成項不同的那一個,正好就是沒有跟別人撞號的那一個
```

# ④★而我最想被打的那格（跨家族量綱）**沒有變**
```
need_keep ~ 資源量級(cap 100) vs _facility_deficit ~ 慾望量級(門檻 0.3)
★我仍然把它標成【本 slice 不解】—— ★★而③反而讓它更值得你判:
   連【家族內】的組成項都不一致(material vs 其他四個),
   ★★★那「家族內正規化」這個做法本身是不是也站不住?
```
