# 貿易環點火（漏斗 measure→fix）— Design

> 用戶玩測 GUI 直接回饋：「感覺沒有在貿易」。數字坐實：exam2 default 6 月成交 `[Market]` 僅 6 筆(1337)/2 筆(2674)，對比訂單張貼數百條=名存實亡。
> 前情：「建設 util 碾貿易」已由 means-end intent_fit 收（症狀 a 全解，2026-07-02）；成交仍 ~0 → **斷點在下游，位置未定=先量**。
> 相關舊帳：商隊履約卡 survival latch（經濟 arc B 首序）、定居隊 granary 自填=需求側旁路（讀B）、envoy 馬鏈 6 月未貫通（同型物流疑問）。

## Task 1 — 漏斗 measure（探針，先斷主因）

default seed 1337+2674 各 6 月（gen 校準後世界），量六站漏斗 per-月 counts：

1. **張貼**：`tick_team_orders` post buy/sell 數（已知洪量，記基準）。
2. **收到**：商業隊 `team_known` 內 order message 數（傳播是否到商隊手上）。
3. **選中**：`best_arbitrage_order` 回非空次數 vs 呼叫次數（有單但不選？價差全負？失真撲空率）。
4. **dispatch**：TASK_TRADE（或等價）真派出次數；**被誰打斷**——survival/threat/其他 latch 搶走的次數與 reason（release/priority 覆蓋計數）。
5. **到場**：走到目標同格次數；途中放棄（timeout/改志）次數與原因。
6. **成交**：`[Market]` / interaction trade 完成；撲空（到場但訂單過期/庫存變）次數。

加碼切面：成交的 6+2 筆是誰（resident 互售 vs 商隊跑單）；商業 archetype 隊數與其 util 排名前三（貿易 option 排第幾、輸給誰）。

**產出=漏斗表**：每站轉化率，主斷點=掉最兇那站。進 handback。

## Task 2 — 修主斷（按數據，候選方向預載）

- 若斷在 **4 dispatch/latch**：商隊 survival latch 校（釋放條件/timeout 按距離估——「凡 latch 必 timeout」invariant 既有）；survival 碾貿易的 util 差距量化後校 term 權重（連續秤，零新判斷器）。
- 若斷在 **3 選單**：價差公式/失真撲空/`SHORTAGE_QTY` 需求端稀疏 → 校常數或需求真源（granary 自填旁路=讀B 舊帳，若數據指這裡，修=定居隊 granary 收取限制，屬藍圖已標方向）。
- 若斷在 **5 到場**：距離/馬/路徑（與 envoy 馬鏈同型物流問題，一起診）。
- 若斷在 **2 傳播**：order message TTL/傳播半徑。
- **禁**：加「貿易 bonus」補丁 hack；身分切路徑；新 judge。統一秤內調權重/修機制斷。

## 硬約束

- measure 探針零行為變（純 print/counter，不動 RNG 流——濾鏈含 randf 勿重排）。
- fix 行為變=預期（貿易活了 hash 必變），seeded finals 附前後量級。
- 凡新/校 latch 必 timeout；身分=權重。

## 驗收

1. 漏斗表（六站 per-月轉化率）進 handback，主斷點有數據定罪。
2. fix 後 default 兩 seed 6 月：**成交筆數量級起跳**（6→數十;目標=ticker 上「X 以 Y 換 Z」肉眼可見持續發生，觀測 GUI 勾掉「隱藏訂單」能看到活的經濟流）；商隊 specimen 可追一條「接單→出發→到場→成交」完整弧。
3. 不塌房：不 mass-starve、狼弧仍在（立國/raid 鏈照 fire）、緩坡照舊。
4. 回歸：headless+framework+coin_eq 綠。

## 檔案 scope

`order_system.gd`、`interaction_system.gd`（trade resolve 段,勿碰 tribute_accept/DistortionEngine 剛統一區）、`faction_ai_system.gd`（商隊 option/dispatch）、`decision/options.gd`、beds（漏斗探針）。UI 不碰。
