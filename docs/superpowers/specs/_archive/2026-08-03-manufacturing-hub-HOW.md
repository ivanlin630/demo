# 製造樞紐湧現 HOW spec（2026-08-03）

**WHAT owner**：blueprint（`2026-08-03-manufacturing-hub-emergence-design.md`、LOCKED R① CLEAN）。**HOW**：systems。**目標**：單大隊 import 原料→大勞力池×多設施加工→export 成品＝**加值型第二種大、湧現非 script**（補 genuine 決策輸入、引擎自秤）。**接既有 seam 非建新、genuine 非 crank**。

## §0 grounding（file:line、SEAM0+A/B/C）
- **SEAM0 匯流**：`need_oracle:96 demand()`→`:153-173 _trade_demand` Σ team_known order_buy（qty、非過期非自己、×(0.5+野心)）；`mfg:146 target = need_keep + demand`。**外部需求由此入生產目標。**
- **A**：`order_system:18-42 post_order`（emit order_buy msg + board）；`:114-138` **只發團自身 shortfall 買單**（reserve−holding）；goods `need_keep=0`（need_oracle:109、無 consumer）。
- **B**：`faction_ai:1770-1812 _tick_convoy`（OUTBOUND→DELIVER→RETURN）+ `:2961-3015 _dispatch_convoy`（FETCH home vault）＝**export-only**；`goal_resolver:220 _deliver_candidates`（seller-side surplus→送）。
- **C**：`interaction:731-857`（GATE-B、position-gated、讀 tile.market_orders+`_market_visitor_buy`local stock/`_market_visitor_sell`local deposit）；`sim_runner:376`（TASK_TRADE 到 outpost 觸發）。**export convoy DELIVER 已 de-local 賣方（porter travel 到買方 tile）＝convoy 物理橋接。**

## §1 (A) genuine 出口需求源 — populations 消耗 goods（非憑空灌）
**genuine 論證**：goods（tools/weapon 等成品）現 `need_keep=0`＝無人消耗＝無出口需求＝樞紐餓。真經濟 populations **消耗成品**（工具磨損/武備補充/民生）。**補 genuine goods 消耗 need**：
- **goods upkeep 消耗**（need_oracle 或 resource_system per-cadence）：team/settlement 按 **size（pop）× GOODS_UPKEEP_RATE** 消耗 goods（如糧消耗、goods 隨用遞減）→ effective_holding 掉 → **shortfall → post_order buy goods**（走既有 order_system:114 shortfall 路、`_ORDER_ELIGIBLE_RES` 加 goods）。
- **量級 genuine ∝ size**：大聚落/多 pop → 消耗多 → standing 買單大 → `demand()` 大 → 樞紐 mfg:146 target 大 → 引擎自秤加工出口。**非 arbitrary 大數**（真消耗率×真 pop）。
- ★**mfg 端不動**（needs 自流）。goods 消耗率 GOODS_UPKEEP_RATE 保守起步、§5-tune。need-gated 守（滿足→不買、§51）。

## §2 (B) import convoy 變體 — 取料（foreign 源→home、鏡射 _dispatch_convoy）
供應鏈 material 缺（`need_oracle:119 _supply_chain` 下游拉 material need_keep）+ 本地無料 → **import convoy**：
- **trigger**：material need_keep>0（供應鏈缺）+ 本地 vault/私產不足 + **聽到 foreign order_sell**（team_known 有該 material 賣單、賣方 market pos）。
- **dispatch**（鏡射 `_dispatch_convoy`、複用 porter/subteam spine + throttle 一隊一 convoy）：`convoy_kind="import"`、target=**foreign seller market pos**、cargo 空（去買）、帶 coin（採購）。
- **phases**（`_tick_convoy` 加 import 分支）：OUTBOUND→抵 foreign market→**FETCH/BUY**（`_resolve_market_at_outpost`→`_market_visitor_buy` 買 material、coin 付、載回）→RETURN→**home deposit**（material 入 home vault/私產）→ merge 歸建。
- **genuine**：真需要（供應鏈缺）、真源（聽到的真賣單）、coin 真付（守恆）。**非另建 convoy 系統**（同 porter spine + 新 kind/phase 分支）。

## §3 (C) GATE-B de-local via convoy 物理橋接 — 買方對稱（拆全經濟買側瓶頸）
- **買方 de-local ＝ import convoy 的 BUY**（§2）：porter **物理 travel 到 foreign seller tile** → `_market_visitor_buy`（position-gated、在場即合法）＝**convoy 物理橋接、守感知鐵律**（非 god-view range-match、非瞬間）。**對稱賣方（export DELIVER 已有）→ B+C 一道 seam 同解進出口。**
- **拆 GATE-B 買側瓶頸**（known_issues:93 buy-fill 0.5%）：跨距買不再靠「碰巧踩到 tile」、走 convoy 物理送達 → 全經濟買方受惠（高槓桿）。
- ★**感知鐵律硬守**：撮合仍 position-gated（porter 在 counterparty tile 才成交）、需求信號走 belief（team_known order）、跨距靠 convoy 物理移動非隔空。**零 god-view range-match。**

## §4 emergence 驗收（量湧現、非 script）
- **樞紐湧現?**：交易節點+大隊+有出口需求（§1）+進得到料（§2）→ 引擎自選 **import→manufacture→export**（真 dispatch import convoy、真 mfg fire、真 export convoy、真加值 coin）？**sizeable 出現於該長之處、不該長之處不長**。
- economy 不爆（need-gated 守、goods 消耗∝size 非爆、價/coin 健康無病態 spike）、determinism 三跑 byte-identical、感知鐵律不破。
- **沒湧現＝輸入/條件/util 調（GOODS_UPKEEP_RATE/import trigger、非 script 非 crank）**。

## §5 守 + 工序
- **守**：湧現非 script（不建樞紐系統、補輸入）/ genuine 非 crank（真消耗/真料/真撮合、禁憑空灌 demand）/ unify 非 patch（接 demand()/convoy/GATE-B seam、禁平行 trade、valuation 統一別重引 TARGET_PER_POP）/ need-gated full-stop / 感知鐵律 / determinism / economy 不爆。
- **工序**：本 spec → R² 自審（湧現/genuine/unify/感知鐵律/三缺口接既有 seam）→ reviewer R² → implementer（隔離、可分 slice：A 需求源→B import convoy→C 對稱驗）→ dev-verify → **emergence 量測**（樞紐該長長、economy 不爆）。地基 KEEP。§5 並行。
