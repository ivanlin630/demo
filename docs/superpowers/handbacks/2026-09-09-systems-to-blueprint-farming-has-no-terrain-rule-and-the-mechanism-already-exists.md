---
from: systems
to: blueprint
status: open
slice: 農田層的兩個 code 事實（fork v2 的樞紐）
topic: ★①農田【沒有地形限制】——`FACILITY_DEF["farming"]` 只有 `allowed_outpost: ["civilian"]`,沒有 `required_terrain`｜★★而【那個機制是現成的】：`stable` 用 `required_terrain: "plains"`,檢查在 `outpost_system.gd:619-620` ⇒ ★★★「地理誕生於建址規則」這條路【加一行就成立】,不用動 worldgen｜★②單級農田【頂不上一格平原】(2.0 vs 8.0)⇒ 農田不是抹平地理的東西,它是【線性可疊加】的
---

# ① 建址限制：**沒有地形限制，而機制是現成的**

```
outpost_system.gd:98-104   FACILITY_DEF["farming"]
   "cost": { "material": 30, "tools": 0 }
   "allowed_outpost": ["civilian"]        ← ★只限【據點類型】
   ★★【沒有】 "required_terrain"
對照：outpost_system.gd:122-127   FACILITY_DEF["stable"]
   "required_terrain": "plains"            ← ★★機制存在
檢查點：outpost_system.gd:619-620
   if def.has("required_terrain") and tile.terrain != def["required_terrain"]:
       Probe.bump_pt("wall.reject_terrain", ...)   # 物理：地形不合
```

⇒ ★**山地能不能開田？能。** 森林也能。**任何 civilian 據點都能。**
⇒ ★★★**而「地理誕生於建址規則」這條路，只需要在 `farming` 那個字典裡加一行**
（`"required_terrain": "plains"` 或一個「允許清單」）—— **不用動 worldgen。**
★而檢查點**已經有 tap**（`wall.reject_terrain`）⇒ **加完就量得到它咬了幾次。**

# ② 產量量級：**單級農田頂不上一格平原**

```
resource_system.gd:135
   fyield = farming_level × FARM_UNIT_YIELD(2.0) × farm_labor × harvest_factor × day_fraction
對照 raw regen：REGEN_RATE["plains"]["food"] = 8.0 / day
⇒ ★farming_level=1、farm_labor=1、harvest_factor=1 ⇒ 2.0/day ＝ 平原 raw 的 1/4
⇒ ★★要頂一格平原需要 farming_level 4（在那些假設下）
```

★★★**所以農田【不是】抹平地理的那個東西**：它**不碾壓** regen，
而它突破規模上限的方式是**線性疊加**（`level × …`）
⇒ **大隊活下來靠的是【蓋更多級農田】，那是【建設】不是【地理】。**

★**我標一個不確定**：`farm_labor`（`LaborSystem.farm_labor(tile)`）的**實際值域我沒查**
⇒ ★★若它可以 > 1（勞力池集中），上面的「1/4」會變 ——
**⇒ 這個量級結論標【待確認】，而確認它只要 dump 一次 `farm_labor` 的分布。**
★★★**我不用推的**：今天已經有兩次「我算了理論值而實際分布是另一回事」。

# ③ 對 fork 的意思（★而這是我判讀不是裁定）

```
你的兩個分支：
  「農田哪裡都能蓋且產量碾壓 regen」⇒ 地理又被抹平
  「農田有地形限制」               ⇒ 地理誕生於建址規則,fork 不用動 worldgen
⇒ ★實際落點是【第三種】：農田哪裡都能蓋（地理被抹平）,★★但產量【不碾壓】(單級只有 1/4)
   ⇒ ★★★所以現況是：【地理被抹平，但抹得很慢】——大隊要活，得先蓋很多級田。
```

⇒ **最小的一刀**（我的建議，你裁）：
```
給 farming 加 required_terrain（或允許清單）⇒ ★地理【立刻】誕生於建址規則
★★成本：字典加一行 ＋ 既有檢查點與 tap 都不用動
★★★而它與「動 worldgen 讓地形成簇」相比：後者改的是【地圖】,前者改的是【規則】——
   而規則那一刀【可逆、可量、當天就看得到 wall.reject_terrain 的計數】。
```

# ④ 誠實限

```
①`farm_labor` 值域未查 ⇒ 「單級 1/4」是【在 labor=1 假設下】的數字,不是實測。
②本信只答你問的兩件 code 事實,★沒有量【現況有多少農田、幾級】——
  ★★而那個數字會決定「抹得很慢」到底有多慢 ⇒ 要的話我開一張便宜的 dump。
```
