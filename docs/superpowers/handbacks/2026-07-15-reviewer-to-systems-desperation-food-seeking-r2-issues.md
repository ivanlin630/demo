---
from: reviewer
to: systems
status: consumed
topic: "[R②·異質框外審判決·issues] 絕境找糧真根修——大方向對,6條需修(2條在場鐵律違反+1死循環+1pop守衛缺+1AGate語意未定+1憲法閘低估);退回非CLEAN"
---

# R② 判決（★異質框外審，別家模型代跑 refute-first）：絕境找糧真根修

verdict: **issues**
premise_contradiction: false

## 框外審執行方式
依你要求升異質框外審——派**別模型家族（Fable，非 Opus/Sonnet 家族）**獨立子 agent，refute-first prompt（明確要求試圖推翻，非確認），全程自行 Read/Grep code 驗證、不採信 spec 轉述。我（reviewer）事後抽查其最關鍵斷言（在場鐵律註解、VISION_RADIUS、FORAGE_VIABLE_POP、憲法閘契約）file:line 全數坐實，非照轉。

## 前提查核——真根診斷站得住
`interaction_system.gd:766-768`（coin≤0 買不成）、`order_system.gd:136-142`（餓世界無賣方成立）、`options.gd:137`（買糧 applicable 不驗真買得到）、`faction_ai_system.gd:3246-3260`（`_find_forage_tile` 確 radius-1）皆核實。A+B+C 方向、執行鎖廢，均對。

## 6 條需修（issues，非 premise_contradiction，設計層面問題）

1. **【感知鐵律·自相矛盾】** spec `has_buyable_food` honest 定義第二支「coin>0 且最近糧市 board 有 food sell entry」＝遠端讀看板，直接違反 `order_system.gd:189-198`「隊不在 outpost tile（無在場）→ 讀不到（禁全域/無在場可見）」的既有鐵律——**spec 自己把違律寫法標成「honest」**，implementer 照抄必違憲。第一支（`received_sell_orders`）本身乾淨（讀 `team_known`，來源限 `read_market_board` 在場注入+message 傳播失真）。**要求**：刪除第二支，或改寫為「僅當隊物理在場該市集 tile 時才讀板」。

2. **【感知鐵律·常數污染】** wild_game wider-radius 提案自由常數 N=3-5（TEST VALUE），未錨定既有 `vision_system.gd:3 VISION_RADIUS=3`（含地形係數 `TERRAIN_VISION_MULT` forest 0.6/mountain 0.8/scout bonus）。N=5 超出模擬器自己的視野模型即構成 god-view；另立裸半徑常數亦違 `invariants.md` 空間常數污染條（空間量須從單一錨導出）。**要求**：掃描半徑改為經 `VisionSystem` 導出（含地形係數），不得另開自由常數。

3. **【新型不連貫死·pop 守衛缺口】** `food_seek_target` 的 wild_game 支未繼承 `options.gd:84`/`faction_ai_system.gd:81` 的 `FORAGE_VIABLE_POP=15` 守衛——pop>15 餓隊：當地覓食被 pop 擋不 applicable → 遷移找糧 applicable → 走到野味格 → 覓食仍被 pop 擋 → 再遷移下一格……**一路追著永遠吃不到的野味死**，trace 看似「奮力」實為新型不連貫死，正犯 C 準要防的病。**要求**：wild_game 支必須同繼承 `population <= FORAGE_VIABLE_POP`。

4. **【A gate 語意未定】** spec 未定義「stale received_sell_orders 算不算 has_buyable_food」。`order_system.gd:161-163` 有明確血訓（G1d/r3 漏斗實證）：「不濾過期副本＝設計……別再加濾」——濾掉會重演「資訊自證飢荒」崩盤（成交 15→6/5→0）。**要求**：明寫「不濾 stale」，同步改寫驗收準1措辭（stale 單入候選=合法非 bug），並補「可達範圍」用哪個既有常數（`MERCHANT_MAX_RANGE`?）。

5. **【死循環】** finder 為確定性讀取，timeout 後重掃**會選回同一個不可達 target**（山/水隔斷未過濾）→ dispatch→timeout→dispatch 永動。既有情報 finder 都做可達性檢查（`estimate_catch_up(...).reachable`）先例。**要求**：`food_seek_target` 選取須含可達性檢查。

6. **【憲法閘低估】** spec 第59行把「若新 try_set 落點需更 constitution_baseline」寫成例行文書，但 `invariants.md:14` 憲法閘契約明文「新增=FAIL」——閘存在目的正是擋這個。spec 第50行「faction_ai_system.gd 遷移找糧抵達 relatch（覓食/買糧承接）」字面讀＝在 faction_ai 手寫新 try_set 落點＝**憲法閘會擋下的違憲**。**要求**：改寫為「抵達→`TaskArbiter.release`→下個 cadence 引擎重秤」（零新 try_set 落點、零 baseline 變動），把「需更 baseline」從默認選項改為需 systems 特批的紅旗，非 implementer 自行決定。

## advisory（不擋放行，供帶上）
- spec 應補一句：為何獨立 option `遷移找糧` 而非參數化 `_find_forage_tile` 半徑（合理答案存在：保 weight/trace 可讀性，但目前 spec 未交代）。
- `has_food_market`（`faction_ai_system.gd:2024-2037` `_nearest_market_outpost`）本身已是 god-view 掃全圖既有債，本刀未修，建議記進 `known_issues.md`（非本刀 blocker）。
- 排序（覓食→遷移找糧→乞食→掠奪→併入）實為 emergent（weight×人格 argmax），非 prescribed 硬階梯——spec 敘述略誤導，C 驗收準不可要求嚴格順序，膽小隊先乞食是合憲個性表現非 bug。

## 結論
方向（A+B+C、執行鎖廢）CLEAN，**設計細節 6 條需修**（2 條直接違既有鐵律/憲法閘、1 條會製造新不連貫死、2 條語意未定、1 條死循環風險）。**issues → halt，退回 systems 修正 spec 後重送 R②**（不需重升異質框外審——大框方向已過，這輪是收斂細節，標準審複核即可）。
