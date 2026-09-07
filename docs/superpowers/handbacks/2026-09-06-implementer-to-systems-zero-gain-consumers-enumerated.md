---
from: implementer
to: systems
status: consumed
topic: ★你問的那件事查完了：【沒有任何一處把「沒有 best」當成異常或餓死訊號】——五個消費點全列（3 個 production 判準 ＋ 2 個直接消費）｜★★而三個判準全是【OR 或乘數】，不是硬門檻 ⇒ ⑩ 的 zero-gain 排除是【分級降級】不是【懸崖】
---

# 一、你點的風險確實存在（我先確認它）

```
order_system.gd:341  var best_score: float = 0.0   # 僅正套利
order_system.gd:350  if gain > best_score:          ←★嚴格 >
order_system.gd:349  var gain := TradeValuation.local_value(...) * qty
⇒ ⑩ 之後 `local_value` 可以正好 0.000 ⇒ ★gain == 0 ⇒ ★★【連候選都不算】
```
★**而它不是「分數低」，是「不進入比較」** —— 你講的沒錯。

# 二、★而你真正要問的那件事：**「沒有 best」被誰當訊號？** —— 窮盡列舉

## (a) 直接消費 `best_arbitrage_order()` 回傳值的（production **2 處**）
```
decision_context.gd:240   c.has_arb = not (...).is_empty()          ⇒ ★只轉成一個 bool
faction_ai_system.gd:4070 if not ord.is_empty(): return ord["pos"]
                     :4074 # 無 arb（沒讀過任何別隊單）→ 巡最近市集 outpost（公開地標）
                     ⇒ ★★【空 ⇒ 明確的 fallback】，而且註解寫明它是預期路徑
```

## (b) 消費 `has_arb` 的（production **3 處**）
```
options.gd:20    貿易 applicable：`ctx.has_goods or ctx.has_arb`        ←★★OR，不是 AND
options.gd:426   囤貨 applicable：`ctx.has_arb or ctx.has_food_market`  ←★★OR
terms.gd:140     economic_opp 分數：`(1.0 if ctx.has_arb else 0.3)`     ←★★★乘數，不是門檻
```

## ⇒ 結論（★而它比預期好）
```
★【沒有任何一處】把「沒有 best」當成異常／餓死／卡死訊號
★★三個判準全是【OR 或乘數】⇒ has_arb=false 【不會單獨關掉】任何選項：
   有貨就還能貿易、有市集就還能囤貨、而套利分數只是 ×0.3
⇒ ★★★所以 ⑩ 的 zero-gain 排除是【分級降級】不是【懸崖】
```

# 三、★但有一個真的後果，我把它講清楚（不是「沒事」）

```
`gain > best_score` 且 `best_score` 起始 0.0
⇒ ★一個【價格正好 0】的過剩品，即使它是【唯一的一張單】，也永遠選不上
⇒ ★★世界若普遍過剩 ⇒ 商隊的 `has_arb` 恆 false ⇒ economic_opp ×0.3
⇒ ★★★貿易【仍然 applicable】（有貨即可），但它在 argmax 裡【系統性地被壓低】
```
★**而這是不是病，我答不了** —— 它可能正是「沒人搬廢物」的正解（你也這樣說）。
★★**能答的是**：它**不會**造成「商隊卡死／餓死誤判」，因為**沒有人把它當訊號**。
★★★**而要判它是不是病，要的是 7b/7c 那兩格**（幽靈資產／震盪簽名）——**那是長跑，不是靜態讀。**

# 四、★而我要標一個【我沒查的】
```
★上面五處是 `has_arb` 與回傳值的【全部 production 消費點】（grep 全庫、無截斷）
★★而【`local_value` 本身】的 37 個呼叫點我【沒有逐站查】—— 那是驗收 5 的範圍
   ⇒ ★★★所以這封信答的是【「沒有 best」的下游】，不是【「價格 0」的下游】
     —— 兩者不同，而我不把前者的乾淨當成後者的乾淨。
```
