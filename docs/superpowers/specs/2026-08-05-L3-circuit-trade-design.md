# L3 循環貿易 — 商人巡市集讓遠距跨勢力貿易湧現（WHAT / vision）

status: DRAFT（pending R① factcheck 前提 → CLEAN 才鎖）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-05
溯源：§5 三層 root 之 L3（隔格跨勢力貿易死:賣方從不讀外市集板）；資訊網補完批。

## 動機
L1（勢力內賑濟）/L2（同格交易）已修活；**L3 = 隔格 + 跨勢力**仍死：掛單板要**物理到場才讀得到**（對、守迷霧），但 settled 隊**從不出門逛外市集** → 遠距買單永遠沒人看到 → 遠距跨勢力交易恆 0。**修法 = 讓「去外市集看看」成為 genuine 決策 → 商路湧現。**

## ★核心 guardrail（用戶定 2026-08-05）：禁寫死巡邏路線
**路線是結果、不是輸入。** 不建 waypoint 清單、不 script 巡邏 loop：
- 「去市集 X 看看」= **一個決策**：**去的價值**（該板資訊多舊 + 預期套利/已聽聞買單）vs **路程成本** → 引擎秤。
- **板資訊會過時** → 越久沒去某市集、去看的價值越高 → 「巡迴」自然浮現成 pattern。
- **人格加權**：重商勤跑遠路 / 膽小只跑近的 / 懶的不跑——零死常數門檻。
- 同 scout「資訊值不值得收集」**思考層家族**（對商人 = 市場情報收集）。

## 設計（WHAT）
1. **主動訪市決策**：商人型（及任何有貿易動機的隊）可把「訪市集 X」當候選——util = 資訊價值（板 staleness、預期缺口/套利）+ 已聽聞單的兌現價值 − 旅程成本/風險。走**主 argmax**（訪市是 body 移動 = 主任務，非 side-action）。
- **到場效果（既有機制）**：`read_market_board` firsthand 讀板 + 順手撮合（L2 同格規則）+ 帶著的貨賣/該補的買。
- **資訊帶回**：讀到的板況入 belief、隨身傳播（既有 carrier 機制）——商人自然成為資訊網的血管（貿易與資訊互饋）。
- **貨物物理走**：買賣皆須人貨到場（不改撮合鐵律）。keep-line 戰略儲備照守（只賣真剩餘）。

## 湧現 payoff
- 遠距跨勢力貿易活（§5 L3 症解）。
- 商路 = pattern 湧現（誰常跑哪條線）。
- 製造樞紐的出口血管（樞紐 GAP A/B 之後接這個）。
- 資訊流通加速（商人=最大 carrier 族群）。

## 現況前提（★pending R①）
- **P1** `read_market_board`（order_system:194）= 到場 firsthand 讀板（既有、對）。
- **P2** `best_arbitrage_order` + `MERCHANT_MAX_RANGE=20`（order_system:233/240）= 商人**只對「已聽聞」的單反應**——**無「主動去讀板」決策**（= L3 缺口本體）。
- **P3** settled 隊無任何「訪外市集」候選生成路（§5 measured：board_read 沒 fire）。
- **P4** L2 同格撮合 + keep-line 已 merged 活（成交 +72% 多床）。

> R① 判準：P1–P4 成立否？尤其 P2「無主動訪市決策」= 缺口本體。

## 守
湧現非 script／人格非死常數／感知鐵律（資訊與貨全物理走）／need-gated + keep-line／determinism。

## 量測（湧現式）
- 遠距跨勢力 deal >0（多床、含 settled 經濟床）。
- **訪市 pattern 人格分化**（重商多跑、膽小近跑）——非齊一。
- 板 staleness 下降（資訊流通加速可觀測）。economy 不爆、determinism。
