# SLICE B — 領主分配政策 HOW spec（2026-08-01）

**arc**：後勤統一 §②分配政策（[[project_logistics_unification]]）。WHAT 定案（blueprint）：領主拿到供給後怎麼分給居民＝**人格 WEIGH 非腳本福利**（義氣→發、貪婪→囤/賣外賺、忽視→不管），餵現有 unrest/defection 管線。

**★約束1（用戶硬定，統一搬運脊椎）**：分配走**同一 convoy 原件**（`_tick_convoy` FETCH→OUTBOUND→DELIVER→RETURN），DELIVER 終點＝居民隊（≠market_order）。禁另刻平行搬運。

---

## §0 現況（premise 坐實 file:line）

| 事實 | file:line |
|---|---|
| 居民現況＝**純機械水管**：每日 auto-consume `team+own_granary_tile.public_storage["food"]` merged pool、**無領主政策層** | resource_system:126-141 |
| UnrestBank `add(team,n,reason)`/`reduce`/`reset`→`team.unrest_turns`；`unrest_turns≥20`→defection fire | unrest_bank:5-16 / event_faction_defect:9 |
| persona：`greed=leader.values.get("貪婪",0.5)`、`honor=leader_p.values.get("義氣",0.5)`（[0,1]、義氣＝anti-greed、無獨立慷慨欄） | faction_ai:196/1026/1141 |
| convoy DELIVER 現終點：`_tick_convoy`(faction_ai:1774)→`_resolve_market_at_outpost`(interaction:731)→`_market_visitor_sell(deliver_cargo)`(interaction:815)；`deliver_cargo>=0` bypass reserve。**現只 貨主 outpost `tile.market_orders`**（interaction:758） | — |

**病**：占領村居民（獨立隊、自產可能 < 消耗＝deficit）跨距靠自己 local granary、領主 capital vault 的 surplus 不會流過去。無政策＝無戲（領主人格不影響居民死活）。

---

## §1 核心 seam（統一光譜：給/賣內人格定價/賣外，零新市場）

**★blueprint 裁定（2026-08-01、用戶定）：非 A-xor-B、做統一光譜**。剝削≠新市場——**復用現成貿易市場**（`TradeValuation` 定價 + coin 結算，premise 全 PROVEN 見 §0b）。領主 surplus 一條連續光譜、同一 argmax、一條 convoy+貿易脊椎、**人格 weigh 出光譜位置**：

```
給免費(義氣max) ← 賣居民公道(neutral) → 賣居民高價(貪,剝一筆) → 賣外拋棄子民(貪max,餓死)
        price=0            price=local_value        price=local_value×markup      不發、賣外部
```

**兩個人格導出連續旋鈕（皆非硬 gate）**：
1. **價格 factor**（約束③）：領主賣居民的 ask ＝ `local_value × price_factor(honor,greed)`，連續：honor max→`price_factor→0`（免費）、neutral→1（公道）、greed→`markup>1`（高價）。**modulation 現成 `local_value` settle（interaction:827/838），非新定價機制**。
2. **util weigh**（約束②）：feed-residents candidate util ＝ `relief_term(honor 放大) + coin_term(price×可負擔量)`，競 argmax 對 sell-external（`_deliver_candidates`）。honor 放大 relief（救子民）、greed 壓 relief 但價高抽 coin。

**三種湧現（同一機制 seed 出，非三 branch）**：
- **仁君**：honor 高→relief util 大 + price→0→居民免費 fed→`UnrestBank.reduce`。
- **苛捐雜稅**：greed 中→feed util 仍贏但 price 高→居民買不夠→部分 deficit→unrest↑、領主抽 coin（富而不仁）。
- **拋棄子民**：greed max→feed util < sell-external util→surplus 全賣外→居民餓→unrest↑↑→defection。

∴ **A（賣居民高價）與 B（機會成本扣留賣外）是同一光譜兩端**，價格旋鈕 + util weigh 皆連續人格導出。零新市場、零硬 gate。

**感知鐵律 note**：分配決策讀**本勢力自己**居民 deficit（intra-faction 自有後勤狀態＝合法知情、非 god-view 讀敵隱藏態）。不涉隔空/敵情 belief。✅

## §0b premise 驗（統一光譜三 premise 全 PROVEN，2026-08-01 grep 坐實、非信 blueprint 斷言）

| premise | 結論 | file:line |
|---|---|---|
| 貿易市場有價格+coin 結算、price 於 settle 算 | ✅ `TradeValuation.ask_price/local_value`=BASE_PRICE+shortage mult；coin 轉 interaction:806-807(buy)/838-839(sell) | trade_valuation:127-148 |
| 居民持 coin（購買力） | ✅ team.resources["coin"](TeamData:101)←member_tax(faction_ai:2521)←salary(salary_system:65)；居民付貢含 coin(interaction:527) | — |
| intra-faction 貿易允許（無 faction gate） | ✅ 只擋 self-trade `owner==visitor`(interaction:731-736)、貿易跨/同勢力皆可(interaction:238)；領主掛賣、同勢力居民可買 | — |

---

## §2 元件（新增/擴充，implementer 做）

### A. deficit 偵測（trigger）
- 領主（faction 有 capital vault surplus）掃**自有 resident-teams**，投影 food runway＝`(team_food + local_granary_food) / (pop × FOOD_PER_PERSON_PER_DAY)`（複用 resource_system:126 算式）。
- runway < `DISTRIB_DEFICIT_DAYS`（新常數、初值 e.g. 4 天）＝deficit 候選。

### B. `_distribute_candidates`（新，goal_resolver.gd，仿 `_deliver_candidates`:125）
- 對每個 deficit resident-team，生成 **feed-residents candidate**（既有 argmax 候選、非特判 branch＝約束①）：
  `{task:TASK_CONVOY, target:resident_team_tile, cargo:"food", qty:補到 runway 目標量, kind:"distribute", terminus_team_id:resident.id, price_factor:_price_factor(honor,greed)}`。
- **price_factor（連續人格導出＝約束③）**：`_price_factor(honor,greed)` 連續映射——honor max→→0（免費）、neutral→1、greed→markup>1。e.g. `clamp( (0.5+greed) / (0.5+honor), 0, PRICE_MARKUP_CAP )`（honor 拉低、greed 拉高、無 if-gate）。
- **util（連續 weigh＝約束②）**：`relief_term + coin_term`——`relief_term = deficit_severity × (0.3+honor)`（義氣放大救子民）、`coin_term = price_factor × local_value × affordable_qty × (0.3+greed)`（貪婪放大抽 coin）。競 argmax 對 sell-external（`_deliver_candidates`）+ 其他。**GOAL_UTIL_CAP=1.5 沿用**（reviewer 核乘數真推過 cap、非 economy-headroom 死 lever）。**無 `if greed>X` 硬 gate**。
- source vault＝領主 capital granary surplus（FETCH 既有 `_load_convoy_cargo` faction_ai:2964）。

### C. DELIVER 終點擴充（interaction_system.gd，復用貿易市場＝約束④）
- `_resolve_market_at_outpost`(731)：加 **resident-DELIVER 分支**——`task_extra_data.kind=="distribute"` 且抵達 tile 有 `terminus_team_id` 對應 resident-team → **賣入居民**（復用現成 sell-settle + coin 轉 interaction:838-839），**但 ask 用 `local_value × price_factor`**（modulation 現成定價、非新機制）：
  - `price_factor==0`（仁君免費）→ ask=0 → 居民 0 coin 取食（現成路、qty 由 deliver_cargo）。
  - `price_factor>0` → 居民按 ask 買可負擔量（`min(需求, resident.coin / ask)`）→ 買不夠則 deficit 殘留。**coin：resident.coin -= q×ask、領主(owner) coin += q×ask**（現成 806-807/838-839 路）。
- 沿用 `deliver_cargo>=0` bypass-reserve（interaction:815）。**無新 market/order class**（grep 驗）。
- convoy RETURN 照舊（faction_ai:1774 尾）歸建釋 pop；未售 cargo 隨 RETURN 歸領主 vault（守恆、非憑空銷毀）。

### D. unrest 耦合（新回饋，resource_system 或 faction_ai per-tick）
- resident-team per-tick（或 per-cadence）：
  - 持續 deficit（runway < `UNREST_STARVE_DAYS` e.g. 2、且本 cadence 未受 distribution 補）→ `UnrestBank.add(resident, 1, "領主斷糧/剝削")`。
  - 受補 fed（runway 回升 > 安全線）→ `UnrestBank.reduce(resident, 1, "領主施捨")`。
- 餵**現成** `unrest_turns≥20→event_faction_defect`（零新 defection 機制）。

**★全量暫態可觀測性（憲法）**：新 decision（distribute util per-option）、新 resource move（distribute DELIVER 量）、新 state（resident deficit runway、unrest 增減源）**必接 tap**（telemetry），否則 QA 故事性判官盲。distribute candidate 的 util 分項（deficit×persona）入 per-option dump。

---

## §3 dev-time 便宜驗（★約束3，非跳過）

`scripts/debug/` 新 bed（仿 `peaceful_economy_bed`）：
- fixture：1 領主（capital vault food surplus）+ N resident-teams（deficit：pop×burn > local food、居民持 coin），**三型領主 persona**（仁君 honor max / 苛捐 greed 中 / 拋棄 greed max）各一 run。
- **硬斷（三種湧現同一機制 seed 出）**：
  1. **仁君 fire**：honor max → distribute convoy dispatch>0、price_factor→0、居民免費 fed、runway 回升、`unrest_turns` reduce。
  2. **苛捐雜稅**：greed 中 → distribute 仍 fire 但 price 高 → 居民買不夠（coin 見底）→ 部分 deficit 殘留、`unrest_turns`↑、**領主 coin 增**（抽 coin 證據）。
  3. **拋棄子民**：greed max → feed util < sell-external util → surplus 全賣外、distribute dispatch≈0 → 居民餓 → `unrest_turns`↑↑ → 逼近/觸 defection≥20。
  4. **連續非 gate**：同 fixture 掃 greed 0→1（honor 反向）→ price_factor + distribute-share **連續變**（無階梯跳）＝WEIGH 非 GATE 證據。
  5. determinism（seeded、3 跑 byte-identical）、observe 路徑零 RNG（[[feedback_observer_no_global_rng]]）、coin 守恆（居民付=領主收）、gates 綠。

## §4 隔離（★約束2）
- branch `feat/logistics-sliceB-distribution`（獨立、防 floor 式誤 merge、[[feedback_held_work_isolate_worktree]]）。

## §5 一次合量（★約束4）
- 甲乙各 dev-verify 綠後，**一次**整世界 warring 合量 + tap 分帳（分配 fire? unrest 餵? + 乙 join.resolve↑? + 全貌活/大小/政治）。非多跑昂貴 run。

---

## §6 ★統一光譜約束（blueprint 裁定 2026-08-01、用戶定、鎖統一非補丁、R² grep 硬檢）

甲禁自造新補丁（本 session 一路 de-patch）。四約束＝驗收 grep 硬檢：

| # | 約束 | grep 硬檢（R² + dev-verify） |
|---|---|---|
| ① | 選項＝**既有 argmax 候選**非特判 branch | `_distribute_candidates` 產候選入同一 `_candidate_util`/argmax；grep 無 `if kind=="distribute"` 在 dispatch/決策層特判繞過 argmax |
| ② | 人格＝**連續 weigh** 出光譜非 `if greed>X` 硬 gate | grep util/price 路無 `if greed >`/`if honor >` 階梯 gate；只連續乘除 |
| ③ | 價格＝**人格導出連續值**（貪→高）非新剝削定價機制 | `_price_factor` 連續映射、乘現成 `local_value`；grep 無新 price 常數表/定價 class |
| ④ | **復用現成 convoy+貿易市場**非另建內部市場 | DELIVER 走現成 `_market_visitor_sell`+`TradeValuation`+coin 轉(806-807/838-839)；grep 無新 market/order class |

## §7 工序（更新）
甲 HOW spec 定稿（此檔、統一光譜、premise §0b 全 PROVEN）→ **R²**（★硬檢：無 persona-hard-gate②、無新市場④、無特判①、價格 modulation③）→ CLEAN → dispatch implementer（隔離 branch `feat/logistics-sliceB-distribution`）→ dev-verify（三人格湧現+連續非 gate）→ 乙合量。blueprint WHAT 已裁（統一光譜）。
