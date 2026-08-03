# 資訊網（核心）whole — HOW spec

**from**: systems | **status**: draft → reviewer R² | **branch (建議)**: `feat/info-network-whole`（impl 可分片 commit、但**量=whole 一次**）
**WHAT (LOCKED)**: `docs/superpowers/specs/2026-08-03-information-network-core-design.md`（用戶 confirm (a) whole 一次量、R① CLEAN）
**root**: §5 執行塌陷「一 root 三症」= 資訊 propagation dead-end（`message_system propagate_on_arrival:79` 共位才傳）。三症 literally 讀同 `team_known` 結構：症1 distribute（`goal_resolver:154` received_buy_orders）、症2 relocate（`decision_context:69 food_seek_target` 源② received_sell_orders）、症3 commerce（買/賣單不達對方）。

## 設計原則（守 WHAT）
- **接既有 seam、非建新引擎**：carrier 基建已在（`TASK_HERALD 信使`、`TASK_SCOUT 偵查`、`_dispatch_envoy/_tick_envoy/_recall_envoy` belief-pos travel 範式、`read_market_board:194`、`TradeValuation.reserve` keep-line）。
- **感知鐵律**：資訊只經**物理載體**流（co-location carrier + 市集看板 + 有意信使/斥候），**延遲**（載體走路耗 tick）、**decay/distort**（既有 `HOP_DECAY`/`TIME_DECAY_PER_TICK`/`DistortionEngine`）。**禁 god-view 廣播**（不加半徑內全知、不 whole-map 掃 = 免 O(N²) + constitution_gate god-view detector）。intra/cross-faction = 載體 trust/decay 參數差（`_decide_propagation_mode` 已按 carrier 人格分 honest/distorted/silent）、非有無。
- **人格 modulate util、零死常數門檻**（照妖鏡死常數人格化到資訊層）；**genuine 非 crank**（util=真期望價值、人格 MODULATE 非 arbitrary boost；per-option util dump 驗）。
- **need-gated**：info-決策無真 need/staleness 不 fire。**determinism**：零新 randf（載體 dispatch 決定性；既有 propagation randf-free 於 deterministic 路）。**economy 不爆**：keep-line 不空掏。

---

## Part 1 — 被動傳播無死角拓撲（修 :79 dead-end）

**病**：`propagate_on_arrival:79 if other.tile_pos != arrived.tile_pos: continue` → 傳播只在**精確共位**發生 → settled 不共位 = 死角。

**修 = 市集看板升級為 relay hub（passive、感知鐵律-clean、非廣播）**：
- **1a 看板 relay（雙向）**：`read_market_board`（order_system:194）現只讓訪客**讀** local 看板（且只 poster 自己掛的單）。擴為訪客抵市集時**同時 deposit 自己 team_known 的 order/news copy 到看板**（帶 decay：board entry 記 origin_tick、age 過閾值/strength<0.05 清）→ 看板**累積各訪客帶來的異地消息 + 再輻射**給後續訪客。∴ 兩隊不需同時共位——先後訪同一市集即經看板交換（載體=人流、延遲=訪問間隔、decay=board age）。**守感知鐵律**（須物理抵市集 outpost_level>0 才 deposit/read）。
- **1b 保留 co-location carrier**（`propagate_on_arrival:79` 不動）：偶遇仍交換（incidental）。
- **★無死角保證來自 Part 2**：真孤立（從不巡市集）的 settled 隊靠 Part 2 有意信使/斥候物理橋接——passive（1a）廣化沿人流的環境擴散、intentional（Part 2）保證「願投資者必能傳到/取得」。二者合＝無死角。
- **決定性/perf**：看板 deposit 純算術；tile→board bounded（單格 market_orders 陣列，非全掃）。decay 沿用既有公式。

---

## Part 2 — 有意收集/傳播決策（★核心、接 DecisionEngine，reuse TASK_HERALD/TASK_SCOUT/envoy）

三新 option 註冊進 `DecisionOptions.REGISTRY`（{terms, applicable, to_task} 範式，同「求和」）。皆**人格秤 util、applicable=need/knowledge-based（非死常數門檻）**。

### 2a 求援（call for help）→ `TASK_HERALD`
- **applicable**：`team 有未滿足 need（食物 runway 低 / 缺料 / 受威脅）AND 知道潛在施助者`（belief：自家 faction 領主 / 已知盟友，經 `team_known`/faction 結構）。**applicable 是「有 need + 知道對象」、非「runway<X」死常數**——**要不要真派信使＝util 秤**。
- **util（genuine + 人格 modulate）**：`need_severity × P(help_arrives) × relief_value − herald_cost`，人格 MODULATE：**傲慢↓**（不開口求、可能撐死=合理湧現）、**務實↑**（早求）、**依附/忠↑對信任勢力**、**孤高↓**。→ util shape：`base_relief = deficit_severity(真 runway 缺口) × expected_relief`；`personality_mult = f(求生欲, 傲氣/自尊, 忠誠)`。**禁 crank**：base=真期望紓困值、人格只調傾向。
- **to_task**：`TASK_HERALD` 派一信使（reuse `_dispatch_envoy` 範式：belief-pos 目標=施助者 last-seen 位、物理走、延遲）；抵達→把**求援 message（team 的 need = buy-order/求援訊）deposit 進目標 team_known**（honest intra-faction）。→ 領主經**傳到的 belief** 得知居民餓（症1 通例解、非直掃）。信使抵達/recall 沿 `_tick_envoy/_recall_envoy`。

### 2b 派信使查 / 偵察（dispatch scout for info）→ `TASK_SCOUT`
- **applicable**：`team 對它在乎的事有 stale/absent belief（自家子民久沒訊息 / 某市集行情未知 / 邊境敵情舊）AND 可負擔斥候`。**applicable=有 info-gap + 在乎、非「沉默>N tick」死常數**。
- **util（genuine + 人格）**：`info_staleness × expected_info_value × personality − scout_cost`，人格：**關切/責任↑盯**、**多疑↑過度監控**、**野心擴張↓疏忽內政**、**好奇↑**。info_value=減少不確定性的真價值（belief uncertainty 高 × 該資訊對決策的影響）。
- **to_task**：`TASK_SCOUT`（既有 scout查證迴路 `faction_ai:360`、`SCOUT_TIMEOUT`）——走到目標區/市集、觀察/讀看板、返回帶 fresh belief。領主查自家子民狀態 = intra-faction reliable。

### 2c 資訊價值秤
非獨立 option = 2a/2b util 裡的 `expected_info_value / P(help) × relief`（值不值得投資去知道/告知）。人格（好奇/謹慎/情報意識）在 2a/2b util 內 modulate。**不另建機制**。

---

## Part 3 — 交易面 broaden（L2，fold 進 whole）

**病**：`_resolve_market_at_outpost`（interaction:731-813）只 owner public_storage 可交易；同格非 owner 隊 private team.resources 不可。
**修**：
- **同格 willing、任何 store**：市集格（或同格對）雙方**都願意**→ 用**任一方任何持有**（公 public_storage / 私 team.resources / 團庫）成交。擴 `_resolve_market_at_outpost` 迭代同格 teams 的 willing offer（tile→teams bounded 索引、非 O(N²)；恢復 `:240` pairwise 一般性）。willingness gate（雙方 util 願交易）、非 store-type gate。
- **只賣真剩餘（keep-line）**：可賣量 = `holding − keep_line`，`keep_line = TradeValuation.reserve`（**既有**：food/medicine survival floor via need_keep + material construction-hold + 人格液化）。**★前瞻戰略儲備（戰前武器/荒前糧/計畫料）**：reserve 現含 survival + construction-hold；**戰前武器/荒前糧前瞻是否已被 need_keep 涵蓋 = 待驗**（tracking：若 measure 顯 economy 空掏戰略品，擴 reserve 前瞻項；先 reuse 既有、別預先 over-build）。
- **感知鐵律**：同格=物理在場（tile.teams 真在場零 god-view）。

---

## Part 4 — 饑荒-flee 同 root（免另修、量時驗證）

Part 1+2 通後：food 賣單經看板 relay / 賣方求援信使 → 傳到餓隊 team_known → `food_seek_target` 源②（received_sell_orders）**有值** → `遷移找糧` applicable → 餓隊 relocate 找糧 **或** 領主經求援賑濟。**無獨立修**（診斷已證非結構 pin/非人格 pin=純資訊餓）。量時驗 `food_seek_target` 真獲值 + relocate/賑濟活。

---

## 守則（reviewer R² 核）
1. **人格非常數**：三 option applicable=need/knowledge-based，propensity=人格 util，**零 runway<X / 沉默>N 死常數門檻**。
2. **genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：求援/偵察 util base=真期望價值（紓困/資訊值），人格 MODULATE 非 boost。**per-option util dump 驗**（傲 vs 務實 傾向真分化）。
3. **感知鐵律**：載體物理走（belief last-seen 目標、延遲、無 teleport/god-view）；decay/distort 沿用；intra faster/reliable vs cross slower/decay（`_decide_propagation_mode` carrier 人格）。**constitution_gate god-view detector 綠**（無新 indexed 他隊 live 態讀 / whole-map 掃）。
4. **need-gated full-stop** + **determinism byte-identical**（零新 randf 於 deterministic 路）+ **economy 不爆**（keep-line）。
5. **無框內平行求解器**（[[feedback_no_patch_on_settled_architecture]]）：三 option 接既有 REGISTRY/rank，載體 reuse HERALD/SCOUT/envoy，交易面擴既有 resolver——非增殖平行機制。
6. **★calibration 常數必錨真值（R² 追蹤③、同 idle-labor PER_HAND / mfg-hub 紀律）**：herald_cost/scout_cost/decay 參數/info_value scale/紓困 payoff norm 等 calibration 常數**必 DERIVED from 真實量**（如載體 cost 錨真 travel tick × pop burn、info_value 錨真 belief uncertainty × 決策影響），**禁 invent 一個「能讓求援 fire」的常數**（=crank paper over）。TEST VALUE 標註 + 錨定 rationale 註明。

## 量測（★whole 一次、emergent、多床；impl 可分片 build 但禁分片量）
1. **§5 商業 unstall**：`trade.deal / convoy.dispatch / order_fulfilled` 真 >0（多床、非單床 premature）。
2. **饑荒解**：`distribute.dispatch / food_delivered` 真 >0（領主經**傳到的 belief** 賑濟、非直掃）+ **relocate 找糧活**（food_seek_target 獲值）。
3. **資訊決策湧現 + 人格分化**：求援/偵察 fire、**不同人格不同傾向**（傲少求、關切多查）——per-option util dump 證非齊一常數。
4. **感知鐵律不破**：延遲/decay 在（遠/敵 stale）、無 god-view、determinism byte-identical、economy 不爆（keep-line 不空掏）、雙 seed 不凍。
   - **★hub 效應 watch（R² 追蹤①、functional god-view）**：看板 relay 結構乾淨（單格 `tile.market_orders`、非跨市集聚合）**但 measurer 須額外量**：少數熱門市集被高頻造訪 → 是否**功能上逼近 near-global-awareness**（多數隊 belief 幾乎 fresh/全知、fog 名存實亡）——**非只看 constitution_gate detector 有沒跳**。若功能逼近全知 → 調 board entry decay/容量/訪問成本讓 fog 真保住（遠隊 belief 仍 stale）。
5. **沒湧現/沒解 = 調人格 util / 傳播拓撲**，非 script、非 crank、非切片補丁。

## build 分片建議（量仍 whole 一次）
- **S-prop**：Part 1 看板 relay（1a）。
- **S-herald**：2a 求援 option + TASK_HERALD 載體。
- **S-scout**：2b 偵察 option + TASK_SCOUT 接決策。
- **S-trade**：Part 3 交易面 broaden + keep-line。
- 各片可 commit/單測，**但整合後一次量 whole**（§5 商業+饑荒+人格分化+fog 同一床跑）。

**路 reviewer R² 審設計 → CLEAN → dispatch implementer（分片 build）→ 整合 whole 一次量 → 誠實 measured 才宣稱 → 回 blueprint → Telegram 用戶驗收。** 地基 KEEP（勞力池/de-patch/B/甲/後勤/直掃 SUPERSEDED）。
