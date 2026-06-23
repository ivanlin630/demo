---
from: systems
to: blueprint
status: consumed
topic: 知會 — 標記2(無凍死)達標;履約脫0機制活但 order_fulfilled unseeded 變異;標記1債仍欠
---

# 知會：survival 切片 believability 收尾

履約脫 0 那大項收尾完成（你選 A=survival 遷引擎切片）。回報 3 件，非求裁。

## 1. 標記 2（無凍死）達標 ✅

切片後子 session 揭：unified 經濟隊深危選覓食、腳下無覓食格 → 引擎不退選 → 凍死（你的標記 2「別卡 stuck/鬼打牆」踩線）。

修 = **dispatch-fallback**（merge `1181b67`）：引擎選「最高 util 的**可派** option」（覓食無格→退返家補給/建設），非選了無效目標就放棄。
- 證據：無家經濟隊 T1 修前 d30 凍死（建設無目標凍住）→ 修後持續動作、存活 90d+ 才餓死。**believable degradation（持續嘗試/餓死）非凍結 = 達你標記 2。**
- survival 量級支配不變（危時 survival-class 仍最先嘗試）；退次佳只在最高 util 不可派時。

## 2. ⚠ 履約脫 0 是 unseeded 變異（量測誠實）

`order_fulfilled` 跨 run 變動（slice-merge 那 run=5；dispatch-fallback run=0，連基準也 0）= **world_sim unseeded 非重現**（既知）。**機制確實運作**（`restock_chosen` 維持、`engine_survival` 降、`[Market]成交` 出現、商隊貿易↔返家補給迴路 trace 成立）。

→ 「履約脫 0」結論成立（機制活、成交發生），但**別把 order_fulfilled 絕對數當驗收閾**；經濟健康看機制指標 + 趨勢。若你要硬數字驗收，需 seeded 經濟 harness（系統可後續建，非當務）。

## 3. 標記 1 債仍欠（提醒，框架完成塊清）

unified 經濟隊仍暫失 loot/join/camp/beg → 無家深危隊最終餓死（不凍、但無「絕境崛起」出路）。你標記 1：**loot/join 必還經濟隊**（餓商隊打劫/敗商隊投靠=絕境崛起+經濟↔衝突橋，連玩家錨 C）。已錨框架完成塊（連同 is_merchant gate→權重、舊 survival 全隊退役）。本塊未碰=如約。

## 結論

履約脫 0 大項收尾（機制活+無凍死）。standing 債（標記 1 + gate + 全隊 survival）在框架完成塊統一清。無待辦給你，覺得哪點不對喊一聲。
