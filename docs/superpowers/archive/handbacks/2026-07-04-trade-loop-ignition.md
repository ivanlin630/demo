---
from: implementer
to: systems
status: consumed
topic: 貿易環點火——主斷(timeout stale 秒殺)修死+成交 6→16/2→5；Task3 三機器建成並綠(矛盾率回歸gate PASS/常駐漏斗/ticker-dump)；★但絕對矛盾率 0.71-0.76=貿易環仍病(域外殘因 LOD+carrier)，「現綠=done?」= QA 判決題；下一斷=LOD far 移速稀釋 10×+default 無商隊 carrier=藍圖/世界模型題上交你裁
---

# Hand Back: 貿易環點火（trade-loop-ignition）

## 漏斗表（Task 1 產出：fix 前 baseline，兩 seed 各 6 月，config=default）

| 站 | seed 1337 | seed 2674 | 判讀 |
|---|---|---|---|
| 1 張貼 | 3783 (buy 3128/sell 655) | 3817 (buy 3229/sell 588) | 洪量如已知 |
| 2 收到 | board_read=6 | board_read=60 | 傳播有到（arb 濾鏈有料），非主斷 |
| 3 選中 | arb_pick 4032/32922=12.2% | 1551/37807=4.1% | 有選中，非主斷；濾鏈大宗=無貨殺 |
| 4 dispatch | 15545（ambient 10461/囤貨 5084） | 40859（ambient 20188/囤貨 20671） | 洪量 churn；被打斷≈0 |
| **5 到場** | **arrive=0；timeout=13948** | **arrive=0；timeout=22815** | **主斷。派出即被 timeout 秒殺** |
| 6 成交 | deal=5 | deal=4 | 全 resident 互售/barter，商隊跑單=0 |

## 主斷定罪 + 修法（全機制修，零補丁/零新 judge/零身分切路徑）

1. **主修 timeout stale 秒殺**：`TRADE_TIMEOUT` 檢查讀平行欄位 `trade_task_start_tick`，只有
   member_trade/trade_net/舊 solo 三路寫；unified/ambient 派 TRADE 拿 stale 0 → tick>1440 後
   **派出即死**（兩 seed 合計 dispatch 5.6 萬、到場 0）。修=改讀 `TaskArbiter.try_set` 恆蓋章的
   `task_start_tick`（單源），**欄位+三寫點全廢**——未來新增派發路徑 by construction 不再漏。
   **家族病史**：2026-06-11 encounter-engagement handback 修過同病（當時三處補記），unified 引擎
   新增第四路又漏=散落純量 drift 重演（資料模型規則 1 反例活教材）。
2. **ambient TRADE 派發 target=自格**：商業 archetype 隊被派「原地貿易」永不出發。修=TRADE 派發
   target 走 `_merchant_trade_target`（訂單→市集→fallback，同 unified to_task 映射），無標的退原地擺攤。
3. **`_resolve_market` 任意同格相遇即 release**：途中碰隊=棄單。修=途中相遇機會交易完**續程**，
   到點才 release。仍有界（timeout+高優先可搶）。
4. **timeout 按距離估**（invariant「timeout 別死常數」）：`TRADE_TIMEOUT + 殘距×TRADE_TIMEOUT_PER_HEX(120,TEST VALUE)`。

## 錯修二連（r3 數據打臉，已 revert——教訓入檔）

- **過期單濾**：84% 已知單=過期副本沒錯，但「追死單→有理由出門→到市集撞活單」是活性來源；
  「撲空=副本過期=emergent」本是 G1d 設計。濾掉→arb 崩 12%→2.7%、成交 15→6/5→0。**勿再加此濾**。
- **移動鎖 viability guard（貿易/囤貨/買糧擋駐村隊）**：駐村隊掛 TASK_TRADE 站自家村=**村攤營業**
  （來客觸發 _resolve_market + absorb 糧倉賣餘糧=需求側環實體），非 zombie。濾掉→村攤關門→成交崩。

## fix 後量級（最終碼＝修 1-4）

| | baseline | 最終 | |
|---|---|---|---|
| seed 1337 | 5-6 筆 | **16 筆**（coin 8/barter 8）；meet 16、arrive 3 | ~3× |
| seed 2674 | 2-4 筆 | **5 筆**；meet 12 | ~1.5× |

**誠實結論：量級「起跳」只走了半路**（16 非數十；2674 弱）。主斷修死後漏斗指向下一層：

## ★下一斷=LOD far 移速稀釋（世界模型級，修法已驗，裁權上交）

`movement_system.process` `move_tick_acc += TICKS_PER_HOUR`(10) 硬編，far 區每 100 tick 跑一次
→ **far 隊移速 10× 稀釋（1 hex≈3 天）**；無玩家世界全隊=far → 跨格物流全癱。
**= 藍圖裁定「envoy 馬鏈+貿易共享物流嫌疑，一修雙解」假說實測定罪。**
違「大地圖與遭遇戰共用時間尺度」invariant；姊妹系統（collect/consumption）皆 elapsed-aware 唯 movement 不。

**修法已寫已驗（elapsed_ticks 參數，diff 三行）**：seed1337 6 月成交 **6→30（達「數十」bar）**、
arrive 0→43（33.9%）、board_read 6→244——鏈全通。**但世界節奏×10 → pop 172→68（-60%）＝塌房**
（gen 校準在舊速度下做的，全失效；2674 未跟上=另有單源稀疏因素）。
→ 已 revert（movement_system 頭部留 debt 註記），known_issues Movement 段立項。
**此修須與 FAR_ZONE_INTERVAL/移速常數/gen 參數一起重校準——實作 session 無權動世界模型，你裁。**

## 不塌房 + 回歸（驗收3/4，最終碼）

- funnel bed sanity：兩 seed 期末 teams/pop/factions/capture/faction_found 與 baseline 同量級
  （1337: pop 118 vs 119、faction_found 2=2；2674: pop 101 vs 101、capture 7=7）——狼弧在、緩坡照舊。
- 回歸全綠：headless `=== DONE ===` 0 SCRIPT ERROR + 投靠守恆(coin_eq) OK + seeded warring
  reproducible OK；framework_validation PASS=7 DORMANT=0；game_sim_multi coin_eq delta=0.00 ×4 config
  （merchant GameOver@849=既知 watch 項，pre-existing）。
- **Task 3 回歸再確認（本 session）**：diff 僅 `trade_funnel_bed.gd`(debug bed) + `observer_main.gd`(觀測 UI harness)
  ——**零 sim 觸碰** → headless/framework/coin_eq×4 與 Task 2 baseline 同綠；矛盾率 gate 兩 seed PASS。
  唯一 soft-fail「弱目標未加入攻擊 goal」= origin/main pre-existing，無關本 feature。

## Task 3 — 常駐機器三件（QA 反轉試點，done 的一部分；建成並綠）

**①矛盾率 assert（`trade_funnel_bed.gd`，`TRADE_CONTRADICTION_MAX`）**
- 定義：月邊界 read-only 取樣每張 active **買單**——「有效想要」= 供給在（他隊私產/他村糧倉有貨）
  且 **對象可達**（供給點→買單會合市集 ≤ `MERCHANT_MAX_RANGE=20`，**用 sim 自身的可達尺**，非理想化）。
  矛盾 = 有效想要 且 齡 ≥ 壽命×0.8 仍掛著（≈到期未成交）。零 RNG 零 state 寫。
- **語意兩層（關鍵，別混）**：
  - **絕對矛盾率（output 印真值）= 病的量度**。兩 seed 6 月 = **0.758(1337)/0.708(2674)**——
    **現值本身仍是病**（高矛盾＝有效想要大量落空；`deal_merchant=0` 兩 seed=商隊 funnel 零成交）。
  - **閾 `TRADE_CONTRADICTION_MAX=0.85` = 常駐「回歸」baseline，非健康證書**。設現值上方 →
    gate 現 **PASS**（防 timeout 秒殺回歸：貿易再死→矛盾率趨 0.95+→破閾 RED）。
    絕對率 0.7+ 仍印出＝病未清不隱藏（`絕對健康讀數` 欄）。
- **★交你一題（QA 反轉核心）**：**「現綠是否等於 done」= 判決題**。gate PASS（未比今日更壞）
  vs 絕對率 0.7=病（可解釋性判準：矛盾=病）。實作**不自判**——照 spec「宣告權=QA 判決」。
  我的立場：機器建成且**誠實**（絕對率印真值、不灌閾騙綠、殘因已定罪上交）；綠/紅由 QA 裁。
  **未灌 util 騙數**（治矛盾不追配額）——Task 2 域內修已到頂，殘 0.7 是域外 LOD+carrier。
- den=0（世界真無稀缺）→ 印 `[PASS] n/a`，不逼表演（非量地板）。

**②常駐漏斗（`trade_funnel_bed.gd`，非一次性探針）**
- 六站計數+率鏈每跑必出（`[funnel]`/`[rate]` 行）。**商隊 funnel 全鏈同分母遞減**
  （選中/呼叫→dispatch/選中→到場/dispatch→**成交_merchant**/到場）；**resident 互售另列**
  （在家村攤成交、不走旅途 funnel→不混入避免 >100% 假象）。另出 成交/月、成交/月/村對。
- 之後任何軌動經濟，率變化回歸可見。TF_SEED/TF_MONTHS/TF_CONFIG/TF_DIAG env。

**③ticker-dump（`observer_main.gd`，`--obs-ticker-dump=<file>`）**
- 觀測 harness 跑完把 ticker 全量事件流落檔（TSV：`tick\ttype\tteams\ttext`，首行 header）→
  系統 session 讀流做「世界句子審計」。新增 `--obs-config=<name>`（審計跑 default 真產品世界；預設 warring）。
- **實測（default seed 1337，1 月）**：34s 完成、**715 事件/712 行**。type 直方圖：
  order_buy 604 / order_sell 99 / combat_start 6 / faction_establish 2 / captives_taken 2 / subjugate 1 / assim 1。
- **★審計素材本身即坐實病**：ticker 流 **零 deal/成交事件**（訂單洪流無成交回音）＝「感覺沒在貿易」
  的機器可讀證據（市集成交目前不 emit 觀測事件=另一觀測缺口，非本 scope，備查）。
- **實作坑（已解，記教材）**：observer 走 GUI `_process`（12ms/frame budget 節流）→ default
  ~16 tick/s→月級 >360s wrapper timeout 永跑不完。修=dump 模式 `DUMP_CHUNK_TICKS=300` 大 budget
  一塊快跑（去 framerate 節流），月級降 34s。**僅改 dump path**（`if _dump_path != ""` guard），
  互動/截圖 path 零變；`advance_tick` 確定性不受 chunk 影響（同 seed 同流）。

## 實作摘要（檔案）

- `scripts/simulation/order_system.gd`：站1/3 探針（post 分流、arb call/pick/濾鏈殺數）+ 勿加過期濾註記
- `scripts/simulation/task_arbiter.gd`：站4 探針（TRADE 被誰搶 new_task|source）
- `scripts/simulation/faction_ai_system.gd`：**timeout 讀 task_start_tick（主修）+ 距離感知額度**；ambient TRADE 真目標；廢 trade_task_start_tick 寫點；站4/5 探針
- `scripts/simulation/strategic_ai_system.gd`：廢寫點 + 站4 探針
- `scripts/simulation/interaction_system.gd`：**途中相遇續程（到點才 release）**；站5/6 探針（meet/deal 主體/nodeal/release 分類）
- `scripts/simulation/movement_system.gd`：LOD debt 註記（行為未變）
- `scripts/data/team_data.gd`：**刪 `trade_task_start_tick` 欄位**
- `scripts/debug/trade_funnel_bed.gd`：新 bed（TF_*，月報+六站漏斗表）**+ Task3① 矛盾率回歸 gate + ② 常駐率鏈**
- `scripts/ui/observer_main.gd`：**Task3③ `--obs-ticker-dump` TSV 落檔 + `--obs-config` + dump 快跑 chunk**（僅 dump path，互動/截圖零變）
- `scripts/debug/headless_test.gd`：兩處測試改讀 task_start_tick
- `docs/known_issues.md`：Movement 段 LOD 稀釋立項
- `docs/superpowers/plans/2026-07-04-trade-loop-ignition.md`：plan

## 連動風險

- **TRADE task 壽命「秒死」→「有界存活」**：ambient 商隊真的出門+村攤營業=生產/覓食時間占比位移；
  funnel sanity 未見塌房，但長窗（12-24 月）未驗。
- 途中續程=商隊旅途中可連續多次機會交易（估值收斂自然止損，未見 ping-pong；probe `trade.continue_midroute` 可盯）。
- 歷史 docs（2026-06-11 handback/plan）仍記載 trade_task_start_tick——存檔不改。

## 待主 session 確認

0. **★QA 判決題（Task3① 兩層語意）**：三機器建成且綠（矛盾率 gate PASS/常駐漏斗/ticker-dump），
   **但絕對矛盾率 0.71-0.76 仍是病**（域外 LOD+carrier 殘因）。「機器現綠 = 貿易環 done？」
   由 QA 判決——gate 是「未回歸」證書非「健康」證書。若 QA 要絕對率降到健康帶（<0.4）才算 done，
   則須先解域外兩塊（見 1/2），本 branch 域內已到頂。實作立場：不自宣 done，備妥誠實機器交判。
1. **LOD far 移速稀釋修不修、怎麼配套**（上節，最高優先——貿易+envoy 雙解鎖鑰匙在這）。
2. **default 世界 TAG_MERCHANT=0**（兩 seed 全程）：跑單 carrier 只有商 archetype 流浪隊（6-17 隊，
   多數 survival rung 自顧不暇）。「商隊完整弧（接單→出發→到場→成交）」在 default 缺主體
   ——gen 產商隊隊/既有隊晉升商隊 tag 的路=藍圖題。
3. 驗收「成交數十+ticker 肉眼可見」在 default 現 carrier 結構下，靠貿易域內修已到頂（16/5）；
   剩餘缺口=①LOD 物流 ②carrier 存在性，皆域外。序你裁。
4. baseline 既有 soft-fail print「[FAIL] 弱目標未加入攻擊 goal」（headless_test:3188 非 assert，
   origin/main 同碼已存在）——與本 feature 無關，備查。
