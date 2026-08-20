# L3 循環貿易 — 商人巡市集讓遠距跨勢力貿易湧現（WHAT / vision）

status: LOCKED（R① CLEAN 2026-08-05 + P2/P3 訂正已納：真缺口=既有 fallback 路太 naive 非「無此路」）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-05
★LOCKED 未排程(backlog)。
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
- **P2（R① 訂正）** 既有一條「無 arb 時巡最近 known 市集」fallback 路（`_merchant_trade_target` faction_ai:2563-2573 + `_nearest_market_outpost`:2578-2593；「貿易」option applicable = `has_goods or has_arb`，options.gd:18）——**「無主動讀板決策」字面不成立**。**真缺口（更窄、精確）**：①該路 **naive**（永遠揀最近、零 staleness/util 秤、零人格分化）②applicability 被 `has_goods/has_arb` 擋 → **settled 產隊進不去**③只能去 `team_market_known`（聽過/看過）內的市集 → **永遠發現不了未知遠方市集**。
- **P3（R① 訂正）** settled 隊 board_read 沒 fire（§5 measured）＝上述 ②③ 的後果（applicability 擋 + known 範圍窄），非「零路存在」。
- **P4** L2 同格撮合 + keep-line 已 merged 活（成交 +72% 多床）。

> R① verdict：CLEAN（P2/P3 依親讀訂正如上）。
## ★HOW 方向約束（R① 定、防平行機制）
**升級既有路、非從零蓋新 option**：把 `_nearest_market_outpost` 的 naive 揀法升成 **genuine util 秤**（staleness+套利期望−路程、人格加權）+ 放寬 applicability 讓 settled 產隊進得去 + 探索未知市集路（資訊價值秤）。**禁**另建平行「訪市」機制。

## 守
湧現非 script／人格非死常數／感知鐵律（資訊與貨全物理走）／need-gated + keep-line／determinism。

## 量測（湧現式）
- 遠距跨勢力 deal >0（多床、含 settled 經濟床）。
- **訪市 pattern 人格分化**（重商多跑、膽小近跑）——非齊一。
- 板 staleness 下降（資訊流通加速可觀測）。economy 不爆、determinism。
