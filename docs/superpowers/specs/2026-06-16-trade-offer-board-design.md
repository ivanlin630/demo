# 貿易 offer-board（行情傳播 + 線索跑商）— Design

> 日期：2026-06-16
> 議題：貿易模型深入（基底 `docs/trade-economy-review.md`）。現況商隊 `_find_trade_target` 套利視野窄（只 food/material 估價差,問題 4）、需求靜態 target 飽和（問題 5）。建 offer-board：據點發 buy/sell offer → 既有訊息系統傳播 → 商隊（+玩家）憑情報跑商 → 到場按實價結算。樞紐：offer = **線索**（非合約）。

## 概念：市鎮行情 + 行商傳價
據點是市集節點（有貨/有需求）,旅人把行情傳開,商隊憑可能過時/失真的情報跑單,到場按當下實價成交。**資訊不完美 → 跑商有風險 = 激情時刻**。自發形成區域貿易圈（近鮮情報可靠、遠舊情報是賭）。

## 設計核心（各系統歸位,不散亂）

| 塊 | 歸屬 | 狀態 |
|---|---|---|
| offer message type + 傳播 | **訊息系統**（既有 `propagate_on_arrival`/`team_known`/confidence/origin_tick）| type 新增,傳播既有 |
| 發布觸發（surplus/shortage→emit） | interaction 層（surplus/reserve 已知處）| 新 |
| 評分/消費（商隊選 offer 跑單） | **faction_ai**（取代 `_find_trade_target`）| 新 |
| 線索結算（到場重議） | **interaction**（既有 `_resolve_market`）| reuse |
| 統一 `_local_value`（問題 3 前置）| **interaction**（單一 home,player_trade 委派）| 重構 |
| 玩家行情板 DTO（raw） | player_query | 新（措辭顯示→訊息系統,見下）|
| 謠言 diegetic 措辭顯示 | **訊息系統（後續做,本 spec 不碰）** | 延後 |

## 不變量
- **offer = 情報,不轉移資產**。真結算走既有守恆轉移（coin/貨）。offer message 只攜帶 hint。
- **統一估值**：發布/評分/結算同一 `_local_value`,消問題 3 漂移。
- **同格 gate**：實際成交需同格（既有 `_resolve_market` 前提）。offer 只引導商隊「去那格」。
- **對稱性**：玩家與商隊讀同一批傳播 offer、同風險。NPC 用數值評分;玩家看 raw DTO（措辭層後做）。
- **呈現歸訊息系統**：交易碼不塞謠言顯示邏輯。

## 0. 前置：統一 `_local_value`（問題 3）

現有兩份 copy 漂移：`interaction_system._local_value`（生存品非對稱 food 5×）vs `player_trade_system._local_value`（無,food cap 2×）→ DTO 天平與 evaluate_offer 對 food/medicine 用不同公式（單一真相已破）。
- **單一 home = `interaction_system._local_value`**（含生存品非對稱 + BASE_PRICE/TARGET_PER_POP/SURVIVAL_GOODS）。
- `player_trade_system._local_value` 改**委派**（呼 interaction 版）或刪除 copy 改引用。BASE_PRICE/TARGET_PER_POP 去重複（單一常數來源）。
- 驗：DTO 天平 give/want_value 與 npc_would_accept（evaluate_offer）對 food 用同值。

## 1. 發布（據點隊）

- **發布者** = 據點上的 team（`tile.outpost_owner == team` 或居民團 `_is_resident_team`）。roving 隊不發。
- **常駐 offer 狀態**：每據點隊算當前買賣意向——`surplus = stock − _calc_reserve(res) > 門檻` → sell；`stock < target` → buy。
- **觸發**：閾值跨越時（surplus/shortage 狀態變化）注入一則 offer message,非每 tick spam。
- **payload**：`MessageData` type=`"trade_offer"`,params=`{res, side("buy"/"sell"), qty_hint, price_hint, pos}`;`origin_team_id`/`origin_tick`/`strength`（=急迫度,缺/剩越多越遠）既有欄位。
- **price_hint** = 發布時的 `_local_value(team, res)`（餌,線索;到場另議）。

## 2. 傳播（既有訊息系統,碰面才跑）

- 過路隊碰據點 → `propagate_on_arrival` 撿當前 offer message → 存進自己 `state.team_known[tid]` → 帶往他處再傳。
- 每 hop `confidence ×(1−HOP_DECAY)` 衰、`origin_tick` 老化、可能 `is_distorted`、`prune_old_messages` 過期清。
- **不新增傳播機制**,只新增 offer type。

## 3. 消費/評分（商隊 + 玩家,v1）

- **商隊**（TASK_TRADE 既限商隊）：讀 `state.team_known[merchant_id]` 篩 `type=="trade_offer"` 的 → 評分：
  ```
  分數 = 預期利潤 × 新鮮度(origin_tick 老化因子) × confidence / (eta + 風險)
  預期利潤 = 該 offer 對商隊的套利價差估計（sell offer:對方 price_hint vs 商隊/他處 _local_value）
  eta = PathSystem.estimate_catch_up 到 offer.pos
  ```
  挑最高分 → `TaskArbiter.try_set(TASK_TRADE, offer.pos)`。**取代 `_find_trade_target`**（解問題 4：offer 涵蓋所有貨,非只 food/material 估）。一次一單,撲空/成交後重評。
- **玩家**：`player_query` 出「行情板」DTO（raw offer 列表 + 各自 age/confidence/distorted **數值**）。措辭顯示交訊息系統（後做）;v1 UI 可極簡列 raw。

## 4. 線索結算（到場重議）

- offer **不保證價/量**。商隊到 offer.pos 同格對方 → 走既有 `_resolve_market`（用當下實際 `_local_value` 雙向議）。
- 途中對方賣光/價變/offer 失真 → 撲空或賺更少 = 自然風險。
- 玩家到場 → 既有玩家交易流程（offer-builder / `_resolve_market`）。

## 自我調節（問題 5 飽和）
offer 在失衡時湧現（有人缺/剩才發）、平衡時消失（都到 target 沒人發）→ offer 板疏密 = 真實需求訊號。不假裝永久需求,把真實失衡浮給商隊跑。

## 風險
- **評分公式 TEST VALUE**：新鮮度老化曲線、風險項、利潤估計權重 → 量測 trade 量是否回升（接問題 4/5）。
- **offer 量爆**：每據點每資源都發 → team_known 膨脹。對策：限「跨閾值才發」+ TTL + 每隊 offer 上限/去重（同 res 覆蓋舊）。
- **預期利潤估計**：商隊憑 offer price_hint + 自身 `_local_value` 估價差,可能與到場實價差 → 正是線索風險（接受）。
- **統一 _local_value 連動**：改動 evaluate_offer/DTO/NPC market 共用估值,須全測（既有交易/守恆測 + DTO 天平一致）。
- **placement**：發布觸發勿散落;集中一個 offer publisher 入口（interaction 層或專用 `market_offer` 函數），message type 常數放訊息系統側。
- **效能**：商隊每次評分掃 team_known — offer 數受 TTL/上限控,可接受;必要時快取。

## 測試
- 前置：統一 `_local_value` 後,DTO 天平與 evaluate_offer 對 food 同值（headless）;既有交易/守恆測仍綠。
- 發布：據點隊 surplus → 注入 sell offer message（type/params 正確）;roving 隊不發;閾值跨越才發（不每 tick）。
- 傳播：offer message 經 propagate 進過路隊 team_known（reuse,確認 offer type 不被既有邏輯漏接）。
- 消費：商隊讀 team_known offer → 評分挑最高 → TASK_TRADE 朝 offer.pos;多 offer 取最高。
- 玩家：行情板 DTO 出 raw offer 列。
- 整合：survival_start/warzone 跑,`[TaskHist]` 貿易佔比 + trade 成交量 vs 現況（驗問題 4/5 改善方向）;coin_eq 守恆。

## 範圍
- **v1（本 spec）**：前置統一 _local_value + 據點發 buy/sell offer（message type）+ carrier 傳（既有）+ 商隊評分跑單（替 _find_trade_target）+ 玩家行情板 raw DTO + 線索結算（既有 _resolve_market）。
- **v2（後）**：謠言 diegetic 措辭顯示（隨訊息系統）、失真當陷阱玩法、缺貨團追供給 offer（提流量,接 survival）、多腿套利路線（buy+sell 配對）、barter-offer（buy offer 指定付貨,順帶解問題 2）。
- **本 spec 外（獨立另議）**：問題 1（玩家刷光留底）、問題 2（NPC barter）、問題 6（coin 通縮/流動性）。
