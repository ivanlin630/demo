---
from: systems
to: reviewer
status: open
topic: "[R²·重送round2] 統一商業框架補齊——3結構缺口(賣方變現半環/belief基底=公開地標豁免誠實入invariants/履約權威側直記)+6補完項全補;大框寧可多轉,你複核補齊是否CLEAN"
---

# R² round2：統一商業框架（3 缺口 + 6 項補齊）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-unified-commerce-framework.md`（已補）。感謝異質框外審抓 3 結構缺口——都是真「只寫一半/假裝合規/拆了沒接手」，補如下：

## 3 結構缺口（補齊）
1. **賣方變現半環（M2）**：補 **owner-mediated 市場雙側** —— 訪客**買**（向 sell 單/stock，coin→owner）+ **★訪客賣**（向 owner buy 單，貨入 public_storage，owner.coin→visitor）→ 商隊「高賣」端有 resolver、套利閉合、coin 雙向非單向泵。producer=owner 自然變現；resident 產進 owner 公庫 coin 歸 owner（faction 經濟，coin 循環後磨）。
2. **belief 基底（M1）**：**不假裝 belief**——選市場**保留 `_nearest_market_outpost` 掃全 tile 的「市集=公開地標」豁免**（WS-2b 死鎖破除器，冷啟動靠它），**誠實寫進 `invariants.md` 感知鐵律豁免清單**（路線 b）。belief-based market store=backlog 非本刀。
3. **履約記帳（M2）**：新 resolver 成交**按 order_id 直接沖 active_orders+board**（權威側直記，不靠 delta），`settle_orders` 降級只服務巧遇路 → 不掛幽靈單（WS-2b 死鎖不復活）。

## 6 補完項（補齊）
4. 無主 outpost coin→`public_storage.coin`/abandoned_coin（CoinAudit 池內）。
5. 賣超語意→`TileBank.withdraw` 實際取出量計價（禁信 board 鏡像）。
6. 「+」鎖→可購量=min(board 單餘量,現貨)、無單不賣、SURVIVAL_GOODS 強制有單（防買穿）。
7. deal_merchant/merchant_inventory probe 改按 `ARCHETYPE_TRADE`（TAG_MERCHANT 全 0）+ merchant_inventory 死路處理。
8. 巧遇/市場路交界→outpost tile(有 board)=market resolver 專屬 / pairwise 巧遇限非市場格（明文分工,不雙 fire）。
9. 死常數 kill-list 補全（+FOOD_BUY_TARGET_DAYS/SHORTAGE_QTY/×0.5/20.0/TRADE_MIN_STOCK/arb×0.1/`_can_trade` 殭屍公式=第6 accessor 縫/MERCHANT_MAX_RANGE 兩處重複收單一源）。

## + coin 單向泵風險（納驗收觀測）
驗收加：長窗 deals 不得單調衰減到 0（脈衝 vs 穩態）+ coin 分佈逐月記錄 → 量到脈衝則 coin 循環（backlog）提前。

## 你複核
補齊是否 CLEAN（尤其 owner-mediated 賣方半環守恆、公開地標豁免入 invariants 合理、履約權威側直記無雙沖）→ CLEAN 則 dispatch implementer（feat/unified-commerce，大檔面 worktree）。
仍有結構洞 → to:systems 再轉（大框寧可多轉）。
