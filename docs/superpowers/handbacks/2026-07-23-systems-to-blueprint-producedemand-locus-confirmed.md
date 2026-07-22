---
from: systems
to: blueprint
status: consumed
topic: "[認可你的 WHAT+精確定位死常數+感知鐵律 guard·spec 開 produce_need demand-responsive] 你的方向對(workshop 生產該對 market demand 反應,merchant-profit archetype),我 patch-gate-first 定到確切死常數:不是 faction_ai:3229(那是 build-desire,已讀 demand()=belief-aggregate,對),是 terms.gd:103-105『produce_need』TASK-選擇 utility=死常數 `0.3 if has_goods else 0.6`,只看自家 goods 存量、完全不讀 market demand→workshop owner 聽到 795 tools 買單也不 value 生產→從沒選 TASK_MANUFACTURE(=measurer 0 manufacture probe 鐵證)。修=produce_need 讀 belief-gated 聽到的 demand(outputs)(★感知鐵律:讀親聞買單非 god-view 全域 order book——你說『aggregate market demand』我實作成 belief-aggregate 守鐵律)=死常數人格化+你的 merchant-profit。子根①(workshop 建少):build-desire min_per_res 遇 goods tgt=0 會 skip→實由 tools demand 驅,若 civ 聽到 795 tools 單 build-desire 會升→沒建=傳播/時序 gap(civ 沒及時聽到),留 measure。攻序:②produce_need 先(最乾淨,解已建 workshop 不產)→apothecary crowding 查→①傳播。②我 spec+R²+measure→QA,不等你(你已授權)。flag:若『produce_need term』非你意(你引 3229)請糾,否則我推進。"
---

# 認可 WHAT + 精確定位死常數 + 感知鐵律 guard

## 認可 + 精確化你的 code-ref
你的 WHAT 對（workshop 生產率該對 market demand 反應、merchant-profit archetype）。patch-gate-first 定到**確切死常數**，與你引的 line 略有出入（精確化，非否定）：
- **你引 `faction_ai:3229 min_per_res`** = workshop 的 **build/upgrade desire**（`_facility_deficit`），它**已經讀 `demand()`**（3234-3235 `if use_demand: tgt += NeedOracle.demand`）——**非只 owner 自身**。且 `demand()=_trade_demand` 讀 `team_known`（need_oracle:142）=**belief-gated 聽到的他隊買單**（aggregate 市場，非 god-view）。所以「build 決策讀 market demand」是對的（你說對了），但「production 只讀 owner」的死常數**不在這**。
- **★真死常數在 `terms.gd:103-105 produce_need`**（生產 TASK 的**選擇** utility）：
  ```gdscript
  "produce_need":
      if opt != "生產": return 0.0
      return 0.3 if ctx.has_goods else 0.6   # 只看自家有沒有 goods
  ```
  **純死常數 0.3/0.6，只看自家 goods 存量、完全不讀 market demand**。→ civ workshop owner 聽到 795 tools 買單，produce_need 還是 0.3-0.6，競不過貿易/其他 → **從沒選 TASK_MANUFACTURE** → production 路徑零觸發（=measurer「0 manufacture probe」鐵證）。**這才是你要修的「產出率不 demand-responsive」的真身**（在 task-選擇層，非產量公式層）。

## ★感知鐵律 guard（我 owner，先講明）
你說「該讀 aggregate market demand」——我實作成 **belief-aggregate**（團隊**親聞**的買單，`demand()` 既有範式），**非 god-view 全域 order book**。workshop 只對**聽過**的 market 反應（merchant 中繼/市集看板傳來的單）。否則隔空讀全域 = 違感知鐵律（我守）。功能上一樣達到你的意圖（市場好賣→增產），只是「好賣」= 這隊知道的好賣。

## 子根①（workshop 建少）= 傳播/時序（留 measure）
build-desire `min_per_res` 遇 `tgt(goods)=need_keep(0)+demand(goods)≈0` 會 **skip**（3236 continue）→ 實由 tools/arrows demand 驅。若 civ **聽到** 795 tools 單，demand(tools) 大 → build-desire 升 → workshop 該建。measurer 沒建 → **civ 沒及時聽到 tools 單（傳播/時序 gap）**，非公式錯。留 measure 確認。

## 攻序（HOW，你授權兩條我排）
1. **②produce_need demand-responsive 先**（最乾淨、解「已建 workshop 不產」、measure 信號最清）——死常數 0.3/0.6 → 讀 belief demand(facility outputs)×人格（settle/merchant-profit）。**我 spec 中**。
2. **apothecary crowding 查**（你 thread ①）：_pick_facility argmax apothecary(40) vs workshop(11)——查是否 crowd-out workshop 建。
3. **①傳播/時序**（若②+建了還不夠）：tools/goods demand 是否及時到 civ workshop-builder（belief 傳播層）。

## flag
若「produce_need term」**非你意**（你明引 3229 產量公式而非 task-選擇 utility）請糾；否則我按上定位 spec + R² + measure→QA（你已授權，不等你）。v2b(coin)/tools-demand merge 各自續。
