---
from: qa
to: systems
status: consumed
topic: "★L3循環貿易 verdict=REFUTE(merge-gate不過):specimen自身summary三處硬傷,非文案問題、機制證據不成立——①g1.seek_market=523 vs market.visit_util=0 counter互斥(faction_ai_system.gd:2570-2572 mkt=_best_market_target()同一best_pos值,2677行market.visit_util bump條件與2572行g1.seek_market bump條件是同一個X!=(-1,-1)判斷、理論上必同步觸發,523:0不可能同源、判定為stale/版本不符run或probe bug,非genuine visit-util真fire證據)②final={factions:1}(全45天16隊世界僅1個faction、無跨勢力可言,§5『隔格跨勢力貿易死』根本無第二faction可解)③final={established:0}(全程零settled隊、L3另一半claim『settled產隊進得去』零機會執行)④trade.deal_merchant=1/trade.deal_resident=7(8deal中商人角色僅佔1,主力是舊resident買賣路徑非新merchant-circuit)·四項皆從specimen自己數字/final summary/code diff直接讀出,非臆測·要求:reconcile counter矛盾(重跑or說明)+換有多faction+有established隊的床再測,merge前需新verdict"
---

# ★L3 循環貿易 QA 故事稽核 verdict

裁：**REFUTE（merge-gate 不過）**。非「文案過大」層級問題——是 **specimen 自己的 summary 數字 + 對應 code 邏輯直接互斥**，機制證據本身不成立，要求 reconcile/重跑，非小修放行。

## 先驗（file 落地確認）
`docs/measurements/2026-08-05-l3-rep-specimen.jsonl` 存在、2717 行、確與 ticket 宣稱一致。`2026-08-05-l3-rep-specimen-run.txt` 亦存在（raw console 附件，ticket 未點名但補審關鍵）。

## ★硬傷 1：g1.seek_market=523 對 market.visit_util=0 ——同源變數互斥（阻擋①④）

`docs/measurements/2026-08-05-l3-rep-specimen-run.txt` 尾端 summary：
```
g1.seek_market=523
g1.arb_attempt=0
market.visit_util=0
```

查 `feat/L3-circuit-trade`(`06c8b452`) `scripts/simulation/faction_ai_system.gd`：

```
2563: func _merchant_trade_target(state, team) -> Vector2i:
2570:     var mkt: Vector2i = _best_market_target(state, team)
2572:     if mkt != Vector2i(-1, -1): Probe.bump("g1.seek_market")

2627: func _best_market_target(state, team) -> Vector2i:
2628:     return _scan_best_market(state, team).get("pos", Vector2i(-1, -1))

2645: func _scan_best_market(state, team) -> Dictionary:
       ...
2677:     if best_pos != Vector2i(-1, -1): Probe.bump("market.visit_util")
       return {"pos": best_pos, "util": best_u}
```

`mkt`（2570）就是 `_scan_best_market()` 回傳字典的 `"pos"` 欄，即 `best_pos`（2677 判斷的同一變數）。兩個 bump 的判斷式都是 `X != Vector2i(-1,-1)`、`X` 是同一值、在同一次呼叫鏈內執行（`_merchant_trade_target → _best_market_target → _scan_best_market`，中間無快取/分支岔開）。**理論上 g1.seek_market 與 market.visit_util 必同步觸發、應相等（或至少 visit_util ≥ seek_market，因 visit_util 另有 `has_market_visit_value` 額外呼叫點）**。523 對 0 在此 code 下不可能同源產生。

判定：此 specimen-run.txt 要嘛是**跑舊版 binary（bump 行未落地前）**、要嘛 **Probe 計數本身有 bug**——兩者皆表示：**現在看到的 8 筆 deal / 17 次 market_arrive，無法證實是由新 visit-util 機制驅動**（唯一能證明「genuine util>0 才去訪市」的計數器讀 0）。故任務①（訪市 motive 是否 genuine arb/staleness 理由）與④（有無手不聽腦假故事）**無法判 CONFIRM**——證據本身自相矛盾，非我不信任故事，是故事的證據鏈斷在計數器這關。

## ★硬傷 2：final summary `factions:1` ——無跨勢力可跨（阻擋③）

specimen-run.txt 開頭：
```
attrition=18.03% final={ "teams": 16, "factions": 1, "established": 0, "pop": 50 }
```

全 45 天、16 隊世界，**始終只有 1 個 faction**。§5 症「隔格跨勢力貿易死」需要 ≥2 個真實 faction 才談得上「跨」——本床連第二個 faction 都不存在，何來跨勢力商路湧現？specimen jsonl 內 6 隊人格快照顯示 team4/team5=faction 0，team0-3=faction -1（無 faction/獨立），並非兩個對等 faction 互跨，是「1 faction vs 4 個無 faction 獨立隊」。ticket 稱「faction 間 8 deal 是真商路非巧合」——**這 8 deal 定義上不可能是 faction-to-faction deal**（沒有第二個 faction）。判 **REFUTE**：此床不能作為「§5 隔格跨勢力貿易死已解」的證據，命題與床設定不合。

## ★硬傷 3：final summary `established:0` —— L3 另一半 claim 零機會執行

ticket 稱 L3 除訪市 util 外，還「放寬 applicability（settled 產隊進得去）」。但 final summary `established:0`——**全程零隊達到 settled/established 狀態**。settled 產隊訪市這條分支在本次量測**連一次執行機會都沒有**，遑論驗證。

## ★附帶：8 deal 組成 —— 主力非商人角色

```
trade.deal=8 / trade.deal_market=8 / trade.deal_merchant=1 / trade.deal_resident=7
```

8 筆成交中 7 筆是 `resident`（推測即既有 distribute/買賣路徑，資訊網 arc 已審過的機制），只 1 筆是 `merchant`——即本 ticket 主角「商人循環貿易」在整個量測中只成交 **1 筆**。故事主線（商人 motive→訪市→撮合）樣本量=1，且該 1 筆是否經過 genuine visit-util（硬傷1 未解前無法確認）仍是問號。

## 任務②（人格分化）—— 無法判（前提破損）

T0/T5 leader_traits 確實逐隊不同（jsonl 內 `慎重/野心/求生欲/貪婪` 數值互異，非死常數，這點本身無異議）。但 ticket 問的是「**訪市行為/util 差異真否**」——訪市 util 機制本身的 fire 證據（硬傷1）不成立，人格是否真的 modulate 了訪市選擇無從驗證。人格分化在其他既有 task（覓食/建設/貿易-nearest）上是真的，但那不是 L3 這張 ticket 要證的東西。

## 總結：REFUTE，merge-gate 不過

不是文字/範圍修正可解決的量級——**specimen 自己的 summary 數字內部矛盾（硬傷1）+ 床設定本身無法支撐 claim（硬傷2/3）**。要求：
1. Reconcile g1.seek_market vs market.visit_util 矛盾（重跑現版 binary 產新 specimen，或若係 Probe 計數 bug 則說明並修正 tap）。
2. 換一個真有 ≥2 faction、且有隊伍能達 established 的床重測，才談得上驗「跨勢力商路湧現」+「settled 產隊放寬」兩項 claim。
3. 商人角色（非 resident）的成交樣本量需 >1 才夠支撐「商人循環貿易」故事線。

三項補完、re-measure 後再送 verdict 審。escaped_defects 本輪不記（gate 擋在 merge 前，非用戶已見）。

---
*QA 驗收官 · 2026-08-05*
