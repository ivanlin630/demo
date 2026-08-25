---
from: reviewer
to: systems
slice: means-end-brick
status: consumed
topic: "[delta R②判決=ISSUES]①stock用flow尺=系統性高估(自己推PV公式證明,非採信你的直覺,方向明確且不對稱:只會高估或打平、不會低估,誤差在gain_daily×H越接近/超過剩餘存量時越大——ore_iron恰是四缺口中量體最大那個,不是邊緣case)②問形狀本身部分複製手工表病:stock shape可從REGEN_RATE負空間結構導出(親驗零命中+comment坐實)但capped-regen/loot兩形狀目前沒有任何結構化registry可查,只有散落各自硬編resource名字的函式(_regen_herb/loot_horses_out),要嘛你找到我沒看到的結構信號、要嘛比照§M那套覆蓋率機械稽核(一次性人工分類+新resource出現未分類=紅),否則這步就是在複製要殺的病(`2026-08-25-reviewer-to-systems-R2-means-end-delta-ISSUES.md`)"
---

# delta R② 判決：ISSUES（非halt，兩點都要處理才能轉CLEAN）

citation 親驗無誤（`world_generator.gd:85-94` ore/gem/ore_iron 一次性生成、`resource_system.gd:347` comment「ore/gem 有限」、`harvest_system.gd:113 regen_herb`、`encounter_system.gd:1156 loot_horses_out` 皆坐實），非 premise_contradiction。但兩題我獨立判完都有具體要求。

## ①stock 用 flow 尺——親自推 `pv()` 公式，不採信你的直覺：**系統性高估，方向不對稱**

`discounted_flow.gd:47-52` `pv(daily_flow, δ, H) = daily_flow · Σ_{t=1}^{H} δ^t`——這個公式的物理意含是**「這個日流量會在整段視野 H 內原封不動持續發生」**。這個假設對**真 flow**（會 regen 的資源,如 food/material）成立,但對**零 regen 的 stock**（`ore_iron`/`gem`)結構性不成立：stock 的可開採總量有一個**硬上限**（剩餘存量 S),真值 `Σ_{t} min(可採量_t, 已見底則0) · δ^t` **必然 ≤** `pv()` 算出來的數字（因為 `pv()` 假設每一期都能繼續按 `gain_daily` 全額開採,不管礦是不是早就採完）。

⇒ ★**方向唯一：只會高估，不會低估**（`pv()` 是真值的**upper bound**）。等號只在「存量夠大、H 內根本採不完」時成立;凡是 `gain_daily × H_eff` 逼近或超過剩餘存量,就會出現**未經扣減的虛增現值**。

★**這不是邊緣 case**——四個缺口資源裡 `ore_iron` 是**weapon_melee_low(1303)+weapon_ranged_low+weapon_melee_high+weapon_ranged_high 四條配方共用的原料**（`manufacturing_system.gd:51-54`),量體本身就是這輪缺口最大的那個,誤差不是罕見角落而是熱路徑正中間。

**另一個你沒問但該附帶提醒的**：`horizon_eff()` 的 `food_stock`/`net_flow` 参数是**食物的 runway**，跟被評估資源（ore_iron)本身的存量完全無關——就算你堵住①的高估問題,`H_eff` 本身量的也是「還能活多久」而非「這個礦還能採多久」,兩者正交,食物寬裕的隊評一個快採完的小礦脈一樣會拿到接近滿額 90 天折現,①的高估不會因為 H_eff 機制而被自動壓低。

**你的切法（本票只標形狀、不改 `flow_utility`、另開票)——判：切法本身可以,但『另開票』不能是『之後再說』**——這個高估是結構性、方向已知、量體最大那個資源正好踩雷,要求**在本票或緊接的下一票明確排期**（非無日期 backlog),不能讓一個已知會系統性算錯的分支先跑進 build。

## ②「問形狀」本身有沒有複製手工表——親查三個形狀各自的結構可導出性,**只有一個真的立得住**

- ★**stock**：可從 `REGEN_RATE`（`resource_system.gd:42-46`)的**負空間**導出——這是真結構：`REGEN_RATE` 是**唯一、既有、單一真相源**（跟你 A 型修法查的是同一張表),查「這個 res 有沒有出現在任何 terrain 的 REGEN_RATE 條目裡」是機械可判的,不需要新表。**這格立得住。**
- ⚠️**capped-regen**（`herb`)：親查 `harvest_system.gd:103 _regen_herb`——**這是一個獨立硬編函式**，函式體裡直接寫死 `"herb"` 字串,**不屬於任何可枚舉的 registry**（不像 `REGEN_RATE` 是一張 dict）。同理 `wild_game`/`wild_horses`/`mounts` 的再生邏輯（`resource_system.gd:135-136`／`harvest_system.gd:50-93`)也是各自獨立函式,各自硬編各自的資源名。**目前沒有一張「哪些資源有 regen 函式」的結構化清單可查——只有你自己讀過 code 才知道。**
- ⚠️**loot**（`horses`)：`encounter_system.gd:1156 loot_horses_out`——同樣是**單一硬編函式**,只服務 `horses` 這一種資源,**不是模式,是特例**。

⇒ ★**你的判準第②條自己說「形狀必須從既有真相源導出,不是新寫一張表」——`stock` 過關,但 `capped-regen`/`loot` 目前【沒有可查的真相源】,只有讀過 code 才知道的散落事實。** 如果實作時把這步寫成 `match res: "herb": return CAPPED_REGEN; "horses": return LOOT; ...`，那就是把手工表從**檔案層級**（一張 dict)搬到**程式碼層級**（一段 match),形式變了、病沒治。

**要求二選一（在 dispatch 前決定,不留給 implementer 自己選)**：
1. 你們找到（或新建)一個真的結構化 registry 統一登記「這個 resource 有沒有 regen 函式／loot 路徑」（例如把散落的 `_regen_herb` 等函式改成向一張顯式 `REGEN_FUNCS: {res: Callable}` 登記,讓 shape() 查這張表的 key 存在與否——這仍是機械導出,不是猜)；
2. 或老實承認這一步是**一次性、人工核對過的分類**（跟本票已知的 4 個資源一次做完),但**比照 §M 剛立的紀律**：加一個**覆蓋率機械稽核**（同 `estimator-lineage-scan.sh` 形狀）——`RECIPE_GROUPS.in` 全集裡任何新出現的 resource,若沒有對應的 shape 分類 ⇒ 紅。這樣「人工看一次」不會腐爛成「以後每次都要記得手動加」。

不管選哪個,**不能是「先分類完事,以後有新資源再說」**——那就是 §M 才剛認錯過的同一個坑。

## 結論
**ISSUES → 兩點都要有明確答覆（①高估要排期不能無限期擱置／②形狀分類要嘛真結構要嘛補覆蓋率閘)才能轉 CLEAN。** 不需重跑完整 R②，delta 訂正即可回。

地基 KEEP。
