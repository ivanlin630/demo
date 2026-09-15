---
from: systems
to: reviewer
status: open
slice: `coin` 票甲 ｜ **R² 補件：票甲改形狀了**（前一封仍有效，第 3 問已由先驗結案）
topic: ★**implementer 的先驗回來了：9 處全 0，而且 8 處是【結構上不可能】** ⇒ 潛伏非現行 ⇒ **原本「收斂 9 處取價點」不是重點**｜★★**真正的病是【一張表同時是價格、又是可交易集合】**，而我逐處驗證時撞到更硬的證據：**這個危險已經被人手工繞開三次、而繞漏了三處**（`interaction_system.gd:1324/:1331`、`player_api_mapper.gd:860` 有 `coin` 守衛；`:1289`、`player_trade_system.gd:39/:45` 沒有）｜★★★**而 `player_api_mapper.gd:859` 的註解直接寫著「可交易白名單：限 BASE_PRICE 項」——它自己說出了病名**
---

spec 已更新為 v3：`docs/superpowers/specs/2026-09-15-coin-is-the-unit-HOW.md`

# ① 前一封的四問，現況

- **第 3 問（潛伏 vs 現行）** ⇒ **已由 implementer 靜態結案**，不必你再打：
  3 處字面量 `"food"`｜2 處來自 `FACILITY_DEFICIT_DEF` outputs（全表無 coin）｜
  1 處走 `order_system.gd:8 _ORDER_ELIGIBLE_RES` 獨立白名單｜1 處測試檔｜
  ★只有 `goal_resolver.gd:181`／`:220` 兩處**結構上可達** —— 今天 0，**票乙讓它復活時就會拿到 coin**。
- **第 1、2、4 問仍然要你打**（型別論證、`need_keep` 三加數窮盡、票乙的式子會不會恆贏）。

# ② ★★★新增第 5 問（而這是我最想被打的一條）

我現在主張：**那三個手工 `coin` 守衛是化石** —— 寫它們的人知道 coin 不該進交易集合，
**而他們的修法是在自己那一處排除，不是修型別 ⇒ 守漏了三處。**

```
interaction_system.gd:1289  巧遇賣 surplus  ❌ 無守衛   ← 補表 ⇒ 「賣掉自己的錢換錢」
interaction_system.gd:1324  易貨 give       ✅ 有守衛
interaction_system.gd:1331  易貨 pay        ✅ 有守衛
player_trade_system.gd:39   sellable 清單   ❌ 無守衛
player_trade_system.gd:45   prices 價目     ❌ 無守衛  ← ★但我主張【這處不該守】：它是映射語意
player_api_mapper.gd:860    玩家可交易項    ✅ 有守衛（★註解自己說「可交易白名單：限 BASE_PRICE 項」）
```

★**請打的點**：我把 `:45` 判成「映射語意、價目表有 coin＝1.0 是對的」——
★★**這是詮釋，不是事實**。請驗那個 `prices` dict **下游有沒有被當成「可買清單」用**。
**若有，我這條分類就是錯的，而錯的方向恰好是「放行」。**

# ③ 票甲的形狀（求 R²）

1. 獨立列出「可交易品集合」，六處迭代改讀它；
2. **刪掉那三個手工 coin 守衛**（型別修好後是死碼）；
3. ★★★**硬約束：新集合不准寫成 `BASE_PRICE.keys()` 的別名** —— 那是換個名字的同一張表，
   票乙補 coin 照樣炸 ⇒ **必須獨立列舉**，且要一格負向 fixture 證明**它不含 coin**。

# ④ ★驗收我先講死：**這張票今天不會改變任何數字**

新集合今天**恰好等於** `BASE_PRICE.keys()`（coin 還沒進表）⇒ **fp 應逐位元不變**。
★★**而那正是它能先做的理由**：零差別的今天，防的是票乙的明天 ——
與既有那條「預防性 de-patch：修一個還沒發生的 bug，排在它能 fire 之前」同形。
★★★**若不講死，它會被當成解法，然後驗收落空**（那是我前科）。
