# 貿易環點火（漏斗 measure→fix + QA 反轉試點）— Design

> 用戶玩測 GUI 直接回饋：「感覺沒有在貿易」。數字坐實：exam2 default 6 月成交 `[Market]` 僅 6 筆(1337)/2 筆(2674)，對比訂單張貼數百條=**成交率 ≈1-2%、每村 ~14 個月才交易一次**（率不是計數——這除法早該做）。
> 前情：「建設 util 碾貿易」已由 means-end intent_fit 收（症狀 a 全解，2026-07-02）；成交仍 ~0 → **斷點在下游，位置未定=先量**。
> 相關舊帳：商隊履約卡 survival latch（經濟 arc B 首序）、定居隊 granary 自填=需求側旁路（讀B）、envoy 馬鏈 6 月未貫通（同型物流疑問）。
> **藍圖兩裁（2026-07-04 rulings）**：①准插隊（default=沙盒本體，經濟維度真產品世界未收）②granary 需求側原則預定（見 Task 2）。
> **★QA 反轉試點（blueprint qa-inversion，事故級）**：本軌 done ≠ 修好——**done = 修好 + 三層常駐機器存在並綠**（①充足性閾值 ②常駐漏斗 ③戲感審計素材輸出）。用戶眼球=願景輸入，永遠不是驗收工具。沒機器不准宣告。

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
**★輸出格式強制（R3 率不是計數）**：每站一律 `分子/分母=率`（收到/張貼、選中/收到、dispatch/選中、到場/dispatch、成交/到場;另出 成交/月/村對）。裸計數不收——harness print 直接帶率。

## Task 2 — 修主斷（按數據，候選方向預載）

- 若斷在 **4 dispatch/latch**：商隊 survival latch 校（釋放條件/timeout 按距離估——「凡 latch 必 timeout」invariant 既有）；survival 碾貿易的 util 差距量化後校 term 權重（連續秤，零新判斷器）。
- 若斷在 **3 選單**：價差公式/失真撲空/`SHORTAGE_QTY` 需求端稀疏 → 校常數或需求真源。**需求側方向已由藍圖預裁（rulings 裁②）**：「生存自給、繁榮須貿易」——非糧地形自給上限=苟活，繁榮/成長必須進口；**缺口咬成長不咬生存**（別造餓死潮，1.2× 承載+緩坡保留）；**別 nerf regen**（改「自給撐到哪」的閘，非抹平地形）；度=TEST VALUE，漏斗數據後 seeded 校（帶數據回藍圖裁度）。
- 若斷在 **5 到場**：距離/馬/路徑（與 envoy 馬鏈同型物流問題，一起診）。
- 若斷在 **2 傳播**：order message TTL/傳播半徑。
- **禁**：加「貿易 bonus」補丁 hack；身分切路徑；新 judge。統一秤內調權重/修機制斷。
- **★修理協議（audit-explainability-bar）**：治矛盾不追配額——修=接通斷鏈，禁灌 util 讓數字達標；**修一環全環對照**：fix 後全率表前後對照（率表 harness 軌先 merge 供此用），貿易通了但掠奪率/人格分流/知足者行為變形=fail。

## 硬約束

- measure 探針零行為變（純 print/counter，不動 RNG 流——濾鏈含 randf 勿重排）。
- fix 行為變=預期（貿易活了 hash 必變），seeded finals 附前後量級。
- 凡新/校 latch 必 timeout；身分=權重。

## Task 3 — 常駐機器（QA 反轉三層，done 的一部分非附加）

1. **①矛盾偵測 assert（判準修正 audit-explainability-bar：可解釋性非量級，廢量配額）**：seeded bed assert=**矛盾率**——「有效想要（訂單存在+供給在+對象可達）而長期未成交」比率 ≤ `TRADE_CONTRADICTION_MAX`（TEST VALUE）。**非** `成交/月≥X` 量地板（世界真無稀缺時貿易 0=健康，不逼表演）。
2. **②常駐漏斗**：六站漏斗計數+率進 seeded bed 常駐輸出（非一次性探針拆掉）——之後任何軌動到經濟，漏斗率變化回歸可見。
3. **③戲感審計素材**：observer harness 加 `--obs-ticker-dump=<file>`（跑完把 ticker 全量事件流落檔,機器可讀）——供系統 session 跑 default 讀流做「世界句子審計」（統計唸成句子問怪不怪），**審計綠了才輪到用戶**。

## 驗收（三層全綠才 done）

1. 漏斗表（六站率）進 handback，主斷點有數據定罪。
2. fix 後 default 兩 seed 6 月：**成交率量級起跳**（成交/月、成交/月/村對 皆報;目標=ticker 上「X 以 Y 換 Z」持續發生）；商隊 specimen 可追一條「接單→出發→到場→成交」完整弧。
3. 不塌房：不 mass-starve、狼弧仍在（立國/raid 鏈照 fire）、緩坡照舊。
4. 回歸：headless+framework+coin_eq 綠。
5. **Task 3 三件機器存在並綠**（閾值 assert 過+常駐漏斗輸出+ticker dump 可用）。宣告權=**QA 驗收官判決**（qa-role-revival 後生效;系統備機器不自判）。

## 檔案 scope

`order_system.gd`、`interaction_system.gd`（trade resolve 段,勿碰 tribute_accept/DistortionEngine 剛統一區）、`faction_ai_system.gd`（商隊 option/dispatch）、`decision/options.gd`、beds（漏斗探針+閾值 assert）、`scripts/ui/observer_main.gd`（僅 +ticker-dump flag,勿動其他 UI）。
