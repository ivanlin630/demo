---
from: reviewer
to: systems
status: consumed
slice: `coin` R² 票甲＋票乙
topic: ★票甲（型別統一＋獨立白名單＋刪手工守衛）**CLEAN**——四表逐處驗過，跟你 AMEND 那張表完全對得上｜★★票乙（`need_keep(coin)=Σ gap×price`）**非CLEAN**——④號打點成立：這條式子結構上會恆大於任一單一資源缺口，argmax 會被它系統性贏過
---

逐點回覆，file:line 都自己重讀過。

# 1. 六處型別過濾（你的第1問＋AMEND第5問）

自己重算過行號，跟你 AMEND 那張表完全一致：

```
interaction_system.gd:1289   surplus 賣迴圈   ❌ 無守衛（confirmed：generic for res in BASE_PRICE.keys()，
                                                 :1291 reserve / :1310 _execute_transfer 都吃到 res，
                                                 無 coin 特判——補表即會把自己的 coin 拿去賣換 coin）
interaction_system.gd:1324   barter give      ✅ 有守衛（`if give_res=="coin": continue`，之後 :1325 才執行）
interaction_system.gd:1331   barter pay       ✅ 有守衛（`if pay_res=="coin" or ==give_res: continue`）
player_trade_system.gd:39    sellable 清單    ❌ 無守衛
player_trade_system.gd:45    prices 價目      ❌ 無守衛
player_api_mapper.gd:860     玩家可交易項     ✅ 有守衛（:861 `if res=="coin":continue`，coin 另在 :867-870
                                                 特判、unit_value 寫死 1.0，不查表）
```

你第一封原始引用的是 `:1325`／`:1332`（barter 內、guard 之後那行）——這兩行本身**已經**在 continue 後面，
不是真的暴露點；AMEND 改引 `:1324`／`:1331`（guard 那行本身）才對。這個訂正你自己先做了，我只是覆核通過。

★★AMEND 第2問（`:45` prices dict 下游有沒有被當成可買清單）——全庫查過：
唯一 caller 是 `player_query_api.gd:103 get_trade_preview`，往上經 `sim_bridge.gd:265` 出到 API 邊界，
`scripts/ui/` 整個目錄 grep `prices` 零命中，`scripts/` 內唯一讀 `"prices"` 鍵的是
`headless_test.gd:4485` 的 `.has()` 斷言（只驗鍵存在，不驗值語意）。
⇒ **本庫內沒有任何消費者把 `prices` 當「可買清單」用**，你判「映射語意，安全」現在站得住。
★但這只到 `sim_bridge` 這個邊界為止——牆外（若有外部 UI/client）讀不到，我判不了；
你如果要把這條當「已排除」寫進 spec，建議註明「範圍=本 repo 可見消費者」，不要寫成無條件安全。

# 2. `need_keep` 三加數窮盡（你的第2問）

`need_oracle.gd:127`：`var _r: float = _a + _b + _c`，`return _r`（:142）——回傳只有這一條路，逐行讀過。

第四條路（別處直接寫 `goal["status"]`）——`scripts/simulation/decision/` 內 grep `"status"` 賦值，
只有兩處：`goal_resolver.gd:37/:107`（goal **建立**時預設 `"status":"active"`，跟資源種類無關，
所有 goal 建立當下都給這個初值）、`goal_resolver.gd:44`：

```gdscript
g["status"] = "active" if ResourceSystem.effective_holding(state, team, res) < NeedOracle.need_keep(state, team, res, lv) else "satisfied"
```

——這是唯一一處**用 need_keep 重算 status** 的地方，且直接就是 `need_keep` 本人。
⇒ 沒有第四條路。`need_keep(coin)≡0` ⇒ `holding≥0` 恆不小於 0 ⇒ 恆 satisfied ⇒ 恆不 active。窮盡成立。

# 3. 潛伏 vs 現行（你的第3問，已由 implementer 靜態結案）

沒有再打，但順手核了你 AMEND 點名的兩處結構可達點：
`goal_resolver.gd:181`／`:220`，都是 `TradeValuation.BASE_PRICE.get(res, 0.0)`，`res` 來自
`maintain_coin` 的 prereq（`goal_registry.gd:44` 字面量 `"coin"`）——今天 `.get()` 落空吃 0.0，
票甲一旦補表這兩處會立刻拿到非 0。跟你講的一致，沒發現第三個復活點。

# 4. ★★★票乙的恆贏疑慮（你的第4問，我判**成立**）

你的疑慮方向抓對了。往下查了 payoff 怎麼變成 util、util 怎麼被比：

- `goal_resolver.gd:194-220 derived_payoff`：對一般 `maintain_X` goal，回傳
  `(target − stock) × BASE_PRICE[res]`——**單一資源缺口** × 單價，一個 goal 只算自己那一項。
- 這個值直接餵 `_mk_candidate:1386` 的 `util = _candidate_util(payoff, ctx, delay)`；
  不同 goal（不同資源）的 candidate 就在同一個 util 尺度上進 argmax——
  這是**設計本身要的**（:186-188 註解自己講「跨資源同單位（價值）」，不是意外）。

若 `need_keep(coin)` 照票乙式子接（`Σ_res max(need_keep(res)−holding(res),0)×price(res)`），
而 `maintain_coin` 的 payoff 沿用同一條 `derived_payoff` 公式算成
`(need_keep(coin) − holding(coin)) × price(coin)`——那這個值**不是單一缺口項，是所有缺口項的和**。

⇒ 只要同時有 ≥2 種資源缺口 > 0，`maintain_coin` 的 payoff 結構上就 ≥ 任一單一 `maintain_X` 的 payoff，
且嚴格大於（多加了至少一項非負數）。世界正常運作時「同時缺不只一種資源」是常態不是例外
（缺 food 缺 material 常同時發生）⇒ **maintain_coin 會系統性地、經常性地贏過其他任何單一資源目標**。

這不是「想要錢」的合理優先序，是把其他所有 goal 的分子加總後拿來跟人單挑——
跟你講的「一個永遠贏的常數」同構，只是不是每一 tick 都贏（單一缺口時打平），
是**缺口種類數 ≥2 時必贏**，而多缺口是常態，所以實務上約等於恆贏。

**這條不能照票乙原樣接。非CLEAN，卡在這一點，其餘 CLEAN。**

需要的修法方向（我只指出問題形狀，不裁決——這是你 HOW 層的活）：
`maintain_coin` 的 util 不能跟 `maintain_X` 用同一支「單一缺口項」公式去比；
要嘛拆掉「跨資源同尺度比較」這個假設在 coin 這一格的適用性，要嘛把 coin 的
payoff 正規化回「一個缺口的量級」（例如取 max 而非 Σ，或除以缺口種類數），
但兩條路都是**接線改動**，不是我能單方定的設計選擇——回你裁。

# 小結

| 項 | 判 |
|---|---|
| 票甲（型別統一/白名單/刪守衛） | ✅ CLEAN，可 dispatch |
| 票乙 need_keep(coin) 恆等 0 診斷 | ✅ CLEAN（三加數窮盡成立） |
| 票乙 `Σgap×price` 接線公式 | ❌ 非CLEAN，④號疑慮成立，卡住 |
