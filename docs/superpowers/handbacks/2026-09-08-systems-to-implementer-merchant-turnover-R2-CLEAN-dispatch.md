---
from: systems
to: implementer
status: open
slice: merchant-turnover-cost
topic: ★R² CLEAN 可動工——商人持貨機會成本 ＝【當下可得的最佳套利 gain】｜★★而 R² 抓到我一個真的語意缺陷:分子是【全域最佳】而我的分母寫成【逐 res】⇒ 母體對不齊,已改成兩邊都全域｜★★★母體鐵則的證據被 R² 加硬了:不是「理論上該用 ARCHETYPE_TRADE」,是【現在用 TAG_MERCHANT 在正在量的那個世界裡就是啞的】
---

# 一、送件
```
spec  docs/superpowers/specs/2026-09-08-merchant-turnover-cost-HOW.md（R² CLEAN）
序    ★payroll 票【先】,本票後 —— 兩票都動賣出秤,量測要分開歸因（blueprint 裁）
```

# 二、★做什麼（三步，零新常數、零新持久狀態）

```
①`best_arbitrage_order` 回傳 dict 加 `"gain": best_score`（順手修 plumbing,一行）
   —— 現在它算了就丟（:447/:505/:527 算,:530 回傳的 dict 裡沒有它）
②`DecisionContext` 存量級：`c.arb_gain`（★`c.has_arb` 保留不動,別的地方在用）
③賣方急迫度加第三項（★★商人限定,見 §3 鐵則）：
     total_holding_value = Σ_{res ≠ "coin"} local_value(seller,res,state) * qty_held(res)
     turnover_urg        = clamp(arb_gain / total_holding_value, 0, 1)
     _urgency            = max(food_urg, coin_urg, turnover_urg)
```

# 三、★★R² 抓到的那個缺陷，我要你知道它為什麼重要

```
我第一版寫：turnover_urg = arb_gain / (local_value(seller,res) * qty)   ← ★分母是【特定 res】
而 `best_score` 是【全庫掃描出的單一最佳值】,不分 res。
⇒ ★★分子全域、分母逐 res ⇒ **母體對不齊**
⇒ 貨物種類愈多的商人,同一個 gain 被切成愈小份 ⇒ turnover_urg 系統性偏低,
   ★★★而那不是因為他真的比較不缺流動性,是因為他手上東西種類多。
⇒ 修正：兩邊都全域。分子＝我放棄的【單一最佳替代】,分母＝我卸不掉的【全部資本】,
   比值 ＝【每單位被鎖住的資本所放棄的報酬】—— 這才是周轉率。
★coin 必須排除：local_value(coin) 恆 1.0,而 coin 是【已經流動的資本】,
  放進分母正好把語意弄反。
```

# 四、★★★母體鐵則（違反 ＝ 整票靜默無效）

```
判定一律用 `team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE`
★【禁用】`c.is_merchant` / `team.tags.has(TAG_MERCHANT)`。
證據（R² 親自量的，比我原本標的硬）：
  config/*.json  mode 分布 ＝ 28 explicit / 9 random
  ★★warring_states.json（★正在跑經濟量測的那個世界）＝ random 模式,商隊字面搜尋 ＝ 0 處
  ⇒ ★★★用 TAG_MERCHANT 當閘,在【我們現在正在量的世界裡】就是啞的 ——
     閘綠、床綠、世界毫無變化。
⇒ 驗收第④格【母體非空】(ARCHETYPE_TRADE 隊數 > 0) 就是專門擋這個,不得省略。
```

# 五、驗收四格（成對）
```
①【會動】商人 ∧ 當下有肥單 ⇒ turnover_urg 顯著 > 0
②【不亂動】商人 ∧ 市場死寂（arb_gain = 0）⇒ turnover_urg = 0 ★這是正確行為不是缺陷
③【分岔可見】同世界同 tick,商隊 vs 農隊折價行為可分辨（用戶裁「兩型」的直接驗收）
④★★★【母體非空】ARCHETYPE_TRADE 隊數 > 0
★★次要觀察（嚴禁當判準）：成交量、板厚。
```

# 六、鐵則
```
①`c.arb_gain` 只讀,★任何讀取端不得寫回 DecisionContext 或 team
   —— 今天剛修完 gather 觀測純度（讀路徑寫世界）,多一個讀取點就多一個風險。
②不動 discount 四常數；③不新增任何歷史/累加狀態。
```
