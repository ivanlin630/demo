# ①規模經濟力 底查 measure-HOW（大vs小 淨值帳 + 運輸摩擦權重）

**status**: measure-spec（底查、非 build spec；量測員執行、code 零改純讀）
**用戶**: 核可 measure-first 底查（同復甦地型底查模式：先 dump 真淨值帳再定藥、禁靜態斷言禁 crank、乙教訓區）。
**blueprint**: 設床 WHAT 已交 systems；systems 定床設計+taps+派量測員 → 數字回 blueprint spec genuine lever。
**連**：[[project_size_matter_arc]] ①生產統一勞力池 MERGED **待 §8 真世界驗 = 此底查**；[[feedback_genuine_value_not_crank]] 乙教訓（genuine 真值非 crank）；[[feedback_measure_peroption_util_before_decision_claim]]（決策 fire 疑先 dump per-option util）。

---

## 底查問題（blueprint 定）
同總人口/資源，**集中（一大據點）vs 分散（多小據點）**，量兩側淨值 + 核心假設（運輸摩擦權重）。

### 場景（量測員建、同總量隔離變因）
- **CONCENTRATED**：1 大據點、全 pop（e.g. pop 24）、全資源集中。
- **DISPERSED**：N 小據點（e.g. 4×pop6）、同總 pop 24 + 同總資源、terrain-quality 對齊（避地型混淆——全 plains 或等質）。
- ★不變量：兩場景**總 pop / 總起始資源 / terrain 產能等質**，唯一變因=集中度。seeded（determinism）。可加中間點（2×pop12）取 gradient。

---

## 量什麼（淨值帳兩側 + 運輸權重 + per-option util）

### A. 好處側（集中省的）
1. **facility 產出（勞力池效應）**：`LaborSystem.pool_of(tile)` / `labor_mult(tile,"mfg:<lvl>")` / worker_rate（manufacturing:96）——集中 labor_share→高 worker_rate？dump 兩場景總 manufacture 產出 + `manufacture.noop_no_worker` tap（勞力荒）。**核心=[[project_size_matter_arc]] 勞力池 §8 驗：集中真的產更多？**
2. **供應鏈延遲/損耗**：convoy 趟省（集中內部零 convoy）——dump `convoy.dispatch/deliver_settled/deliver_bail_<reason>` count + 投遞 latency（OUTBOUND tick→deliver tick）。
3. **勞力池利用**：能 staff 多少 / 多高設施——facility level distribution 兩場景。
4. **貿易節點 throughput**：`convoy.deliver_settled`（真成交）+ 市場交易量。

### B. 運輸摩擦側（分散的代價）★★核心假設
5. **convoy 負擔**：分散 convoy.dispatch 趟數 + porter labor 佔用（porter-days=convoy 隊 OUTBOUND+RETURN 佔用 tick / pop）+ deliver_bail 失敗率。
6. ★★**運輸/距離摩擦在決策 util 的權重**（疑根：分散「太便宜」否）：per-option util dump（reuse peaceful_economy_bed `_dump_peroption_util`）——
   - `_evaluate_new_outpost_location` score：`dist×5` proximity 罰=擺放緊湊、**非營運運輸成本**（max_dist 5/8 內分散大致等價）→ dump 分散候選 score vs 集中 upgrade util。
   - 決策選 disperse（新據點）vs concentrate（升級既有/整併）時，util 裡運輸營運成本**佔多少**？（現疑=零：convoy 無 loss、只時間+labor，決策層可能沒秤持續補給距離）。
   - dump 領主/隊 expand-vs-upgrade-vs-consolidate 的 per-option util 明細。

### C. 成本側（集中的代價）
7. **維護/消耗/擁擠**：food 消耗/upkeep（MIGRANT_UPKEEP 族）。★**crowding/maintenance 現 under-modeled**（grep 零 facility upkeep/crowding）→ dump 現有成本；**若集中零額外成本=另一疑根**（集中無罰=分散無獎的對偶）。

### 淨值
- 集中 total wealth/output/survival vs 分散、**gradient 哪裡平或負**（大現在划算/打平/虧）。

---

## taps 狀態（觀測鐵律 §全量暫態可觀測性）
- **齊**：convoy.*（dispatch/deliver_settled/deliver_bail/return）、manufacture.noop_no_worker、LaborSystem.pool_of/labor_mult（bed 可讀）、per-option util（_dump_peroption_util）、marginal_economy._inflow_est。
- **可能缺（量測員回報若需）**：①convoy porter-days 佔用聚合（可由 OUTBOUND/RETURN tick 算、或需小 tap）②facility labor 利用率明確 tap（現靠 pool_of 讀+noop tap 間接）③運輸營運成本進 util 的 term（**現疑=不存在**=正是要測的疑根，非補 tap 而是測「有沒有」）。
- ★若量測員發現關鍵盲點（convoy 成本聚合測不到）→ 回報 systems 補純讀 tap（零 RNG、[[feedback_observer_no_global_rng]]），非硬湊。

---

## 床設計（reuse + 右尺寸 + Tier 分層）
- **基座**：`peaceful_economy_bed` 變體（WarringHarness.run + probe dump + 逐隊故事 + _dump_peroption_util 全 reuse）。新 config：concentrated / dispersed（同總量）。
- **Tier1（秒級迭代）**：短跑（~3 月）dump 淨值帳骨架 + per-option util（快看 gradient 方向 + 運輸權重）。
- **Tier2（確認）**：長跑（~6-12 月）3 seed dump 完整淨值帳 + convoy 負擔聚合 + facility 產出分化（determinism 硬斷）。
- **★純讀零 sim-code 改**（bed=runner 合法 seed()、非 @observe-pure；observability_gate ③ 只納嵌入 helper、bed seed() 正確豁免）。

---

## output（→ blueprint）
淨值帳（好處側/運輸摩擦/成本側/淨值 gradient）+ **運輸摩擦 util 權重數字**（決策秤不秤集中/運輸）→ blueprint spec genuine lever（讓分散**真實代價痛**、非發集中獎金；乙教訓 genuine 非 crank）。
- ★禁靜態斷言：疑根（運輸太便宜 / crowding 缺 / 勞力池夠不夠獎集中）**由數字定**、非先射箭。
- 序：底查 dump → blueprint 回數字裁 lever → spec① → R①/R² → build。地基 KEEP。
