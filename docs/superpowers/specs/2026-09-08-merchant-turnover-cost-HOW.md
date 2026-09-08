# HOW spec：商人的【持貨機會成本】接上當下可得的最佳套利 gain

owner: systems ｜ 2026-09-08 ｜ player_reachable: no ｜ 狀態：★R² CLEAN（issues 中，兩點已補）
上游：用戶裁「一般人賣貨 ≠ 商人賣貨」；blueprint 核可「當下 gain」版（非歷史版）

## §1 病

```
商人囤貨【零成本】：貨不腐、escrow 免費放 ⇒ 舒服的商人沒有折價動機
而真實的成本存在：貨壓手上 ＝ 資本停轉 ＝ ★放棄【此刻可得的】最佳套利差價
```
★ 而那個「此刻可得的最佳套利差價」**引擎每次都算，然後丟掉**：
```
order_system.gd:447   var best_score: float = 0.0
order_system.gd:505/527  best_score = gain; best = {kind,res,qty,pos,origin_team,order_id}
order_system.gd:530   return best          ⇒ ★best_score 不在回傳裡
decision_context.gd:259  c.has_arb = not ....is_empty()   ⇒ ★★只留布林,量級扔了
全庫 arb history / turnover（production）⇒ 0 處
```

## §2 修法（三步，零新常數、零新持久狀態）

```
①`best_arbitrage_order` 的回傳 dict 加一個 key：`"gain": best_score`（順手修 plumbing，一行）
②`DecisionContext` 存【量級】而非只有布林：`c.arb_gain = best.get("gain", 0.0)`
   ★`c.has_arb` 保留不動（別的地方在用），只是旁邊多一個量級。
③賣方急迫度加第三項（商人限定，見 §3）：
     turnover_urg = clamp(arb_gain / holding_value, 0.0, 1.0)
     _urgency = max(food_urg, coin_urg, turnover_urg)
```

## §3 ★★★母體鐵則：用 `ARCHETYPE_TRADE`，**不得**用 `TAG_MERCHANT`

```
decision_context.gd:325  c.is_merchant = team.tags.has(TeamData.TAG_MERCHANT)
★★★R² 加碼驗證（比我自己標的硬）：config/*.json 的 mode 分布 ＝ 28 explicit / 9 random，而 **warring_states.json（目前經濟量測正在用的世界）是 random 模式且商隊字面搜尋 ＝ 0 處**。
⇒ ★鐵則不是「理論上該用 ARCHETYPE_TRADE」，是【現在用 TAG_MERCHANT 在正在量的那個世界裡就是啦的】。
★而 defers.tsv 的 `genesis-merchant-weight-empty-population` 仍掛著：
  **random-mode 世界裡 TAG_MERCHANT ＝ 0 隊**（真正驅動的是 ambition_archetype）
★★interaction_system.gd:852 的註解也記著：「R²#7：ARCHETYPE_TRADE 分流，TAG_MERCHANT …」
⇒ ★★★若本票用 `c.is_merchant` 當閘，它在 random-mode 世界裡【一個商人都匹配不到】
   —— 而那是【靜默的 no-op】：閘綠、床綠、世界毫無變化。
⇒ 判定一律用 `team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE`。
★而 `c.is_merchant` 本身有同一個潛在缺陷 —— **本票不修它**（會動到別的行為），
  但要在卷面標明：它是同族，已有 token。
```

## §4 ★常數自由的正規化（★★R² 訂正：分子分母必須同母體）

```
問題：`gain` 是絕對 coin 額，`_urgency` 要 [0,1]。
      ★而引一個 TURNOVER_K 就是手抄常數，blueprint 已禁。
```

### ★★★R² 抳掉我的第一版（而他是對的）

```
我原本寫：turnover_urg = arb_gain / (local_value(seller,res) * qty)   ← ★分母是【特定 res】
而 `best_arbitrage_order` 回傳的 `gain` 是【全庫掃描出的單一最佳值】，不分 res。
⇒ ★★分子是【全域】、分母是【逐 res】 ⇒ **母體對不齊**。
⇒ ★★★後果：貨物種類愉多的商人，同一個 arb_gain 被切成愉小份
   ⇒ turnover_urg 系統性偏低，而那不是因為他真的比較不缺流動性。
（★這是 memory「比率的分子分母不同時刻同母體＝沒有意義」的【空間版】。）
```

### ★修正：兩邊都用【全域】

```gdscript
total_holding_value = Σ_{res ≠ "coin"} local_value(seller, res, state) * qty_held(res)
turnover_urg        = clamp(arb_gain / total_holding_value, 0.0, 1.0)
```
```
★語意：**我放棄的那一個最佳套利，相對於我卸不掉的全部資本，值多少？**
  ⇒ 分子：全域的【單一最佳替代】（商人一次只能做一筆套利）
  ⇒ 分母：全域的【被壓住的資本】
  ⇒ ★★比值 ＝ 【每單位被鎖住的資本所放棄的報酬】—— 這才是周轉率。
★★★coin 必須排除：`local_value(coin)` 恆為 1.0 face value，
  而 coin 是【已經流動的資本】—— 把它放進分母正好把語意弄反。
total_holding_value <= 0 ⇒ turnover_urg = 0（不得用 maxf 墊成非零）。
```

## §5 ★★鐵則

```
①★`c.arb_gain` 是【只讀】的。任何讀取端【不得寫回】DecisionContext 或 team。
   —— 本專案 2026-09-08 剛修完 gather 觀測純度（讀路徑寫世界）；多一個讀取點就多一個風險。
②★★不動 discount 的四個常數（COMMERCE/URGENCY/GREED/DISCOUNT_MAX）。
③★★★不新增任何歷史/累加狀態 —— blueprint 核可的是【當下】版本，
   而「近期收益率」需要不存在的歷史（前提已查，見 premise-correction 那封）。
```

## §6 驗收（四格，★成對）

```
①【會動】商人 ∧ 當下有肥單（arb_gain 大）⇒ turnover_urg 顯著 > 0 ⇒ 折扣變深
②【不亂動】商人 ∧ 市場死寂（arb_gain = 0）⇒ turnover_urg = 0 ⇒ 折扣不變
   ★②是【正確行為】不是缺陷：沒有機會可放棄,就沒有機會成本。
③【分岔可見】同一世界、同一 tick：商隊 vs 農隊的折價行為【可分辨】
   —— 這是用戶裁「兩型」的直接驗收。
④★★★【母體非空】ARCHETYPE_TRADE 的隊數 > 0（★若為 0,本票一切皆綠而世界沒變）
   —— 這一格擋的正是 §3 那個靜默 no-op。
```
★★次要觀察（**嚴禁當判準**）：成交量、板厚。理由同 payroll 票 §4。

## §7 誠實限

```
①★「當下 gain」是【瞬時】的：商人在市場死寂時不折價 —— 那是對的，但它意味著
   本票【不會】讓一個長期囤貨的商人自己鬆手，除非市場出現機會。
②★★`holding_value` 用賣方自己的估值 ⇒ 高估自己貨的商人，turnover_urg 天然偏低。
   那是【一致的】（同一把尺量分子分母），而不是中立。
③★★★本票只治【商人】那一半；一般隊那半是 payroll 票。兩票都動賣出秤 ⇒
   **量測必須分開歸因**（blueprint 已裁：payroll 先，本票後）。
```
