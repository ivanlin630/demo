# L1 intra-faction distribute de-patch — HOW spec

> **★★SUPERSEDED（2026-08-03，用戶否定「直掃」做法）**：本 spec 的「領主直掃自家居民 active_orders」＝**開特例後門繞過 propagation＝用戶明否**。用戶原則：**資訊永遠傳播、無 dead-end、fog 靠延遲/decay 非硬擋**（invariants.md「資訊永遠傳播」段）。**L1 修法改＝修 propagation 讓饑荒消息經 belief 傳達領主（延遲不 dead-end）→領主依 belief 賑濟**，非直掃。**reviewer R² CLEAN 於本做法＝moot、別 dispatch build。** 執行端分析（convoy 送糧 plumbing、util genuine、驗收 execution-end）**可複用**於新 propagation-fix spec。新 spec 待 blueprint user-confirmed reframe。下方原內容存檔備查。

---

**from**: systems | **status**: ~~draft → reviewer R²~~ **SUPERSEDED** | **branch (建議)**: `feat/L1-intra-faction-distribute`
**序**: L1（blueprint ratify L1→L2→L3，2026-08-03）| **root**: §5 執行塌陷 root 三層之 L1（known_issues「§5 執行塌陷 root REFINE」段）

## 動機 / root（measure 坐實、非猜）
§5：領主 food=3940（rich）+ 自家居民 pop2 runway=0 餓死 → `distribute.dispatch=0`。診斷（`jia-distribute-zero-diagnostic.json` test_B/D）：distribute 機制/util/argmax **全 fine**（生成即 rank0 贏 util1.33）；**唯一 binding = 居民買單沒物理傳達到領主 team_known**（`_distribute_candidates:154` 讀 `received_buy_orders`＝team_known、co-location/board 閘）。settled 領主+居民不共位 → 領主永不「知道」自家居民餓 → 不救。

**＝過度把感知鐵律套到內政的補丁閘**（[[feedback_patch_gate_first]]、本 session 核心病）。blueprint ratify：**intra-faction 內部 telemetry＝合法 perceive、非 god-view**（感知鐵律治 cross-faction/rival fog-of-war；invariants.md「intra-faction 內部 telemetry carve-out」段，2026-08-03）。

## 修法（de-patch = 換感知源、非加補償補丁）
**只改 `_distribute_candidates`（intra-faction 領主→自家居民）的感知源**：從 `received_buy_orders(team)`（team_known co-location 閘）→ **直掃自家 faction static 居民的 `active_orders`**（內部 telemetry、firsthand honest）。**下游 for-loop / order_id / pos / qty / util 全不變（byte-identical plumbing）。**

### 新 helper（`goal_resolver.gd`，static）
```
static func _intra_faction_food_buy_orders(state: WorldState, team: TeamData) -> Array:
    # intra-faction 內部 telemetry：領主直讀自家勢力 static 居民的 food 買單（感知鐵律合法，
    # invariants.md intra-faction carve-out）。回傳 shape 鏡射 received_buy_orders（下游不改）。
    var out: Array = []
    for tid in state.teams:                       # 決定性：Dictionary 插入序（同 :145 claimed 掃）
        var resident: TeamData = state.teams[tid]
        if resident.team_id == team.team_id:
            continue
        if resident.faction_id != team.faction_id \
                or not FactionAISystem.is_resident_static(state, resident):
            continue                              # ★SCOPE 硬界：僅自勢力 static 居民；cross-faction 不碰
        for o in resident.active_orders:
            if String(o.get("kind","")) != "buy" or String(o.get("res","")) != "food":
                continue
            out.append({
                "res": "food",
                "qty": int(o.get("qty_remaining", 0)),
                "origin_team": resident.team_id,
                "pos": _resident_deliver_pos(state, resident),   # 見下
                "order_id": int(o.get("order_id", -1)),
                "distorted": false,               # 內部 telemetry = honest
            })
    return out
```
`_resident_deliver_pos`：交貨終點＝居民實體所在（領主 intra-faction 知其位、合法）。用 `OrderSystem.new()._market_pos(state, resident)`（鏡射買單 origin_pos 語意：居民自家 outpost，無則回 `resident.tile_pos`）。**與現行買單 origin_pos 同值**（`order_system:32` origin_pos=_market_pos(resident)）→ 下游 convoy target 不變。

### 改點（唯一一行）
`_distribute_candidates`（`goal_resolver.gd:154`）：
```
-   var buy_orders: Array = OrderSystem.new().received_buy_orders(state, team)
+   var buy_orders: Array = _intra_faction_food_buy_orders(state, team)
```
下游 loop（:157-）**完全不動**——含 faction_id/is_resident_static 複查（現冗餘但防禦保留）、runway<DISTRIB_DEFICIT_DAYS deficit 閘、`mpos==team.tile_pos continue`（同格直給免 convoy）、claimed 在途去重、util（relief+coin）、to_task 組裝。

## 不變量 / 守則（reviewer R² 核）
- **genuine 不變**：util＝現行 `relief_term(deficit×義氣) + coin_term(price×food_val×qty×貪婪)`，**一字不改**（非 crank、[[feedback_genuine_value_not_crank]]）。relief 避 unrest 動機保留。
- **★SCOPE 硬界 cross-faction 不破**：新 helper 只掃 `faction_id==team.faction_id && is_resident_static`。**`_deliver_candidates`（cross-faction 賣、`:220`）不動**——仍讀 `received_buy_orders`（belief/board/co-location gated）＝cross-faction 感知鐵律完整保留。`demand()`（need_oracle 讀 received_buy_orders，:232）不動。
- **determinism**：純算術 + Dictionary 插入序迭代（零 RNG），鏡射既有 `:145` claimed 掃 pattern。三跑 byte-identical 該綠。
- **感知鐵律**：intra-faction 直讀＝invariants.md carve-out 合法；helper 註明 scope；cross-faction 對稱仍 gated。**constitution_gate god-view detector**：新 helper 迭代 `state.teams[tid]` 讀 resident 態＝需標 gate-ok（legit intra-faction 註，同 `consolidate_target_of` 範式）。
- **無新平行求解器**（[[feedback_no_patch_on_settled_architecture]] 框內補丁）：de-patch＝換單一感知源，非增殖 option/solver。買單 pipeline（resident post shortage_buy）不變，只領主感知它的**來源**從 co-location team_known → intra-faction 直讀。

## 邊界 / 待 reviewer 戳點
- **edge：居民餓但尚未 post buy-order**（timing）→ helper 該 tick 漏它（active_orders 空）。判斷：居民斷糧必 post shortage_buy（§5 `shortage_buy=340` 證在 post）→ 下 cadence 補；**不 synthesize 無 order_id 的分配**（保 fulfillment plumbing 完整）。若 reviewer 認 timing gap 需補，另議（別在此 slice 塞）。
- **perf**：每有餘糧領主 O(teams) 掃（cheap 前閘 :129-140 限少數領主到此）。is_resident_static O(1)。warring 49 隊可接受（同量級 claimed 掃）。

## 驗收（execution-end 硬驗、[[feedback_verify_execution_end]]）
1. **§5 bed 重跑**：`distribute.dispatch>0` + `distribute.food_delivered>0` + 居民 runway 回升不餓死（**執行端真效果**、非只 candidate 生成）。
2. determinism 三跑 byte-identical。
3. constitution_gate 綠（新 helper site 標 legit gate-ok）。
4. cross-faction 不變：warring/economy bed convoy/deliver 對外貿易數字**不因本改動**（scope 隔離證明）。
5. genuine：util 分數與現行一致（相同 input → 相同 util、只感知源變）。

**路 reviewer R²（每 slice 必過）→ CLEAN → dispatch implementer → build → measurer 獨立驗 execution-end → blueprint JUDGE → merge。**
