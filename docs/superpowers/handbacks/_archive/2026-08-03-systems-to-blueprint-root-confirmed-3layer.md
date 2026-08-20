---
from: systems
to: blueprint
status: consumed
topic: "[★§5執行塌陷 root CONFIRMED(measure完整,診斷已產jia-distribute-zero-diagnostic.json+§5 probe dump)=三層非單一GATE-B/surface·L1甲intra-faction distribute:領主→自家居民distribute都讀received_buy_orders(team_known co-location/board閘)即使goal_resolver:166註『intra-faction感知鐵律合法』+:168已算resident runway→領主坐擁3940食居民pop2餓死runway0卻因買單沒物理傳達領主team_known而distribute.dispatch=0=過度套感知鐵律補丁閘(de-patch:領主直掃自家居民runway,勢力內部回報≠god-view我invariant-owner判合法)·L1最乾淨§5 impact最高是de-patch·L2同格跨勢力貿易(用戶WHAT)=broaden surface team.resources confirmed-safe,量已dispatch·L3隔格=board-read須賣方物理抵買方市集settled不巡=循環carrier flow深最大remainder·非(ii):distribute生成即rank0贏util1.33/convoy/argmax全fine·premature-victory CONFIRMED:SLICE A convoy0→6在買單已達team_known近距fixture fire,一般settled不共位→買單不傳達→convoy.dispatch=0=scenario-specific·我已記known_issues+memory·★序建議L1(de-patch高impact cheap)→L2(用戶WHAT surface)→L3(循環remainder)·待你WHAT:①序ratify②L1感知鐵律解讀ratify(勢力內部回報直接perceive自家居民=合法否)·root確認→我設計L1 HOW spec→R²→build·地基KEEP"
---

# ★§5 執行塌陷 root — CONFIRMED（measure 完整）= 三層、非單一 GATE-B/surface

診斷已產（`docs/measurements/2026-08-03-jia-distribute-zero-diagnostic.json` 4 角度+差分+surface；`s5-integration-seed1337` probe dump）。**root 三層**：

## 三層 root（file:line 坐實）
| 層 | binding | 性質 | 修法方向 |
|---|---|---|---|
| **L1 甲 intra-faction distribute** | 領主→自家居民 distribute 讀 `received_buy_orders`（`goal_resolver:154`=team_known、co-location/board 傳播閘），即使 :166 註「intra-faction 感知鐵律合法」+:168 已算 `_resident_food_runway` | **過度套感知鐵律的補丁閘** | **de-patch**：領主**直接掃自家居民 runway**（勢力內部回報≠god-view）非等居民買單物理傳達 |
| **L2 同格跨勢力貿易（你/用戶 WHAT）** | 交易面窄（`interaction:731-813` 只 owner public_storage、非 team.resources） | broaden surface | 同格 willing→team.resources 成交（confirmed-safe、tile→teams bounded 非 O(N²)） |
| **L3 隔格跨勢力貿易** | `read_market_board`（order_system:194）須**賣方物理抵買方市集**（outpost_level>0）、settled 賣方不巡外市集→從不讀外單 | 循環/carrier flow | 深、最大 remainder |

## §5 血證（`s5-integration-seed1337-run1`）
- 領主 food=3940（rich）+ 居民 pop 10→2、food=0、runway=0（**餓死**）→ `distribute.dispatch=0`（領主坐擁餘糧不救自家居民）。
- `order_placed=426 / order_fulfilled=0 / trade.deal=0 / convoy.dispatch=0`。board_read 沒 fire（賣方不抵外市集）。

## 判定（非猜、measure 坐實）
- **非 (ii) 決策層**：distribute 生成即 rank 0 贏 util 1.33、deliver 生成 candidate、convoy/argmax/throttle 全 fine（診斷 test_B/D）。
- **binding = 上游訊息物理傳達 + intra-faction 過度閘**。感知鐵律**兩路徑（co-location carrier `message_system:79` + 市集看板 `read_market_board:194`）皆須物理在場**——settled 隊不共位/不巡市集 → 買單不達 → received_buy_orders 空 → 全下游 0。
- **★premature-victory CONFIRMED**：SLICE A convoy fulfilled 0→6 在「買單已在賣方 team_known」近距 fixture fire；一般 settled 各據點不共位 → 買單不傳達 → convoy.dispatch=0 = **scenario-specific victory**（SLICE A 修 candidate生成+convoy執行層、未修買單傳達層）。**我已記 known_issues + memory（不 paper over）。**

## ★序建議（measure-first、de-patch 優先）
1. **L1 intra-faction distribute de-patch**（最乾淨、§5 impact 最高、cheap、de-patch）→ 領主直掃自家居民救糧。
2. **L2 同格跨勢力 surface**（你/用戶 WHAT、confirmed-safe；量同格 unstall 已 dispatch implementer）。
3. **L3 隔格循環**（carrier flow / 賣方巡市集；深、最大 remainder）。

## ★待你 WHAT 裁（2 點、才 lock L1 spec）
1. **序 ratify**：L1→L2→L3 對否（或你要 L2 用戶 WHAT 先）。
2. **L1 感知鐵律解讀 ratify**：**勢力內部回報 → 領主直接 perceive 自家居民 runway = 感知鐵律合法否**（我 invariant-owner 傾向：faction 內部 telemetry ≠ god-view 全世界，如領主本就知自隊 resources；但此擴 belief 來源、你 WHAT 對齊）。

root 確認 → 你裁序+L1 解讀 → 我設計 L1 HOW spec → R² → build → 驗 distribute.dispatch/food_delivered 真>0。地基 KEEP。
