# 統一勞力池 HOW spec（2026-08-03）

**WHAT owner**：blueprint（`2026-08-03-unified-labor-production-scale-design.md`、R①-CORRECTED CLEAN）。**HOW**：systems。
**目標**：讓 size 在生產 genuinely matter（治 CASE B 規模經濟 absent、genuine-value 非 crank [[feedback_genuine_value_not_crank]]）——勞力變**有限稀缺資源**，大隊/集團→多勞力→餵多工位→真產得多。

## §0 grounding（file:line 坐實、G1–G5）
- **P1 製造**：`manufacturing_system.gd:82` `pop_mult=clampf(sqrt(pop/5),0.5,2.0)`；`:92` `worker_rate=level×pop_mult×(0.5+avg_skill×0.5)`；`:150-159` `q=worker_rate×rate`；RECIPE_GROUPS 每設施免費吃同 pop_mult（不競爭）、per-tick。
- **P2 採集**：`resource_system.gd:63` 同式 pop_mult；`:265-266` `gain=productivity×current×COLLECT_RATE(0.05)×day_fraction×outpost_mult×pop_mult×work_morale`。**承載＝`current`(庫存遞減)/COLLECT_RATE/regen 獨立、勞力池不碰**。
- **need_oracle**：`need_oracle.gd:13-15` `need_keep(res)=self_use+supply_chain+construction`、`demand(res)=trade`（per-resource）。
- **共址**：iterate `state.teams` filter `tile_pos==tile` && `TAG_PRODUCE in tags`（`outpost_system:166` 型）。
- **cadence 型**：`faction_ai_system:106` `const CADENCE=TICK_PER_DAY×N; if current_tick>=team.x_eval_next_tick: recompute; 設 next`。

---

## §1 seam：`LaborSystem`（新、單一共享 allocator）
新 `scripts/simulation/labor_system.gd`（class_name `LaborSystem`）。**採集端 + 製造端共讀同一 allocator**（統一非平行）。
- **儲存＝per-tile**（勞力池 tile-local＝co-located PRODUCE pop）：`HexTileData` 加
  - `var labor_alloc: Dictionary = {}`（workstation_key → `{demand:float, share:float, fill:float}`、fill=share/demand ∈[0,1]）。
  - `var labor_eval_next_tick: int = 0`（per-tile cadence gate）。
- **workstation_key 規範**（deterministic sorted）：`"gather:<res>"`（食/材/原料，tile 有該資源且有 PRODUCE 隊採）+ `"mfg:<level_key>"`（RECIPE_GROUPS 每 active facility）。
- **rebalance 觸發＝lazy-on-cadence（頻率解耦命門）**：生產 sweep（`resource_system.collect_resources` / `manufacturing_system.tick_all`）處理 tile **開頭**呼 `LaborSystem.ensure_fresh(state, tile)`——**僅當 `current_tick>=tile.labor_eval_next_tick` 才真重算**（否則直讀既存 alloc）→ **重算走慢 cadence、生產每 tick 只讀 share、零雙算**。

## §2 allocator 演算法（`LaborSystem.rebalance(state, tile)`、deterministic）
1. **池** `pool = Σ pop`（共址 `TAG_PRODUCE` 隊；軍隊無 tag 不算）。
2. **列 workstations**（sorted key）：tile active 採集資源 + active 製造設施。
3. **demand（工位規模×K）**：
   - `"mfg:Lk"` → `demand = facility_level × K_MFG`。
   - `"gather:res"` → `demand = K_GATHER`（每資源線一份、可按 outpost_level 微調）。
4. **need 權重**（`need_oracle`、per-workstation output res、Σ 共址隊）：
   - `w = Σ_teams (need_keep(res)+demand(res))`（survival 階層天然拉高食權重＝糧不被餓、**無 scripted min-floor**憲法）。`w=0`（不需要）→ 該工位不參與分配。
5. **需求加權比例 + demand-cap + 溢出串聯**（blueprint §分配法）：
   - `share_i = pool × w_i / Σw`；
   - clamp `share_i ≤ demand_i`；削下總量按剩餘 w 再分未封頂者、**iterate 到穩**（固定上限 e.g. 8 迭代防無限、deterministic）。
6. `fill_i = share_i / demand_i`（∈[0,1]）；存 `tile.labor_alloc`。
7. 設 `tile.labor_eval_next_tick = current_tick + LABOR_CADENCE`。
- **兩規模自動對**（blueprint）：人手少（Σdemand>>pool）→ 無封頂 → 純比例（全線都產、按 need）；人手多（pool>>Σdemand）→ 全封頂 fill=1 + 餘力外溢（surplus/閒）。

## §2b 多隊共址細節（R② 自審補、防雙算）
- **多隊 gather 防雙算**：gather workstation 的 share 是**聚合**勞力。每共址隊 `collect_resources` 時 `labor_mult × (team_pop / pool)`＝該隊佔池比例的份 → **Σ 各隊 = tile gather 分配、無雙算**。單隊常態＝pool=team_pop→比例=1（退化回單隊）。
- **output ownership 不變**：製造 facility 產出仍歸 acting/owner 隊（`_add_output` 既有）、gather 歸採集隊。**勞力池只改 rate（labor_mult）、不改 ownership**（最小 seam、非重寫生產歸屬）。
- **perf**：rebalance sweep **先建 `tile_pos → [PRODUCE teams]` index 一次**（非 per-tile 掃 state.teams＝O(tiles×teams)）→ O(teams) 建 index + O(active_tiles×workstations) 分配。cadence-gated（3 天）攤平。記 known_issues perf follow-up 若量測顯著。

## §3 採集/製造共讀（取代兩套 pop_mult）
**產出 ∝ 分到的手數（linear-in-labor 到 demand-cap）＝size matter；再 min 承載/原料上限**（blueprint §分配法 5）。
- **labor_mult 取代 pop_mult**：`labor_mult(tile, wkey) = fill × LABOR_SCALE`，其中 `LABOR_SCALE` 校準使**baseline 小隊 ≈ 現況**（見 §4）。fill∈[0,1]、乘 LABOR_SCALE 還原量級。
  - ★**size matter 靠 demand 隨規模開大 + 池大 fill 高**：大隊/集團 pool 大 → 多工位同時 fill≈1（小隊只夠餵幾條）→ 總產出規模化。**單工位 fill≤1 不爆量**（demand-cap）、規模來自「餵得動多工位 + 大 demand 設施」。
- **manufacturing:92**：`worker_rate = level × labor_mult(tile,"mfg:Lk") × (0.5+avg_skill×0.5)`（pop_mult→labor_mult）。
- **resource:265-266**：`gain = productivity × current × COLLECT_RATE × day_fraction × outpost_mult × labor_mult(tile,"gather:res") × work_morale`（pop_mult→labor_mult）。**current 承載數學不動**（大隊採快→current 掉快→yield 降＝人均遞減，憲法意圖真承載）。

## §4 K 值 + demand 曲線 + LABOR_SCALE 校準（誠實旋鈕、measurement-tune）
起始值（**baseline-preserving + linear-scale**、§7 dev-verify 校）：
- `K_MFG = 3.0`（每設施 level 要 3 手；L2 workshop demand=6）。
- `K_GATHER = 5.0`（每採集線 5 手飽和）。
- `LABOR_SCALE`：校準使「pop=5 單隊、單工位」`labor_mult ≈ 1.0`（＝現 pop_mult at pop5=sqrt(1)=1.0）。pop=5 全投一工位 share=min(5,demand)、fill=min(5,demand)/demand。取 gather demand=5→fill=1→`LABOR_SCALE=1.0`。**校準原則寫死於 dev-verify：baseline 單隊產出 ±5% 現況**（防偷改量級）。
- **demand 曲線**：線性 `level×K`（誠實、無隱藏非線性）。高 need 工位分多、低 need 少（§2.4 權重）。

## §5 cadence + 危機觸發
- `const LABOR_CADENCE = TimeScale.TICK_PER_DAY × 3`（**常駐站位、慢**、非每 tick 抖；接用戶「隨時算太頻繁」）。
- **危機觸發即時重算**（skip cadence gate）：共址任一隊 `food_days < LABOR_CRISIS_FOOD_DAYS(2.0)` → `tile.labor_eval_next_tick = current_tick`（下次 sweep 立即 rebalance、survival need 拉高食權重自動搶回勞力）。**憲法：危機是 need_oracle 權重 spike 驅動、非 scripted floor**。

## §6 守憲（P5 訂正版）
- **deterministic**：workstation sorted key iterate + 純算術 + 溢出 cascade 固定迭代上限、**零 RNG** → 三跑 byte-identical。
- **tile 生態承載獨立不碰**：`_collect_from_tile` 的 `current/COLLECT_RATE/regen`（resource:254-284）**只改 pop_mult→labor_mult 那一支、庫存數學零改**。
- **「大隊一格採食人均遞減」= 真意圖、雙機制承載**：①採食 demand-cap（大隊無法對單格無限灌勞、超 cap 溢走）②`current` 庫存遞減（過採→yield 降）。→ **游牧大隊仍餓死、大隊須定居設施據點+糧供給才產得動**（blueprint §自洽）。
- **無 explicit toggle**（玩家 on/off 另循 player_command_system、本 arc 不做）。
- **憲法決策不碰**：勞力池是生產執行層 rate、非決策；util/argmax 不動。

## §7 dev-verify（交付前自跑）+ §8 量測（交 measurer）
**dev-verify bed**（`scripts/debug/`）硬斷：
1. **baseline 保真（單工位）**：pop=5 單隊單工位產出 ±5% 現況（LABOR_SCALE 校準證、非偷改量級）。
1b. **★小隊多活動下滑 survivable（R² 追蹤項、reviewer 2026-08-03）**：小隊（pop 5–10）**同時做多活動**（採食+採材+製造）＝**常見情況非 edge**。labor 稀缺 → pool 分裂 → 每工位 fill<1 → 每活動比現況慢（**intended：稀缺逼排序**）。**硬驗此下滑 bounded + survivable**：need_oracle survival 權重把糧優先拉滿（不餓死）、總產仍撐得住早期經濟、**非全面崩**（世界不因小隊產崩而塌）。measure 下滑幅度；若崩→tune（LABOR_SCALE↑ per-hand 產高 / K↓ demand 小=少分裂），**非加 scripted floor**（憲法）。
2. **size matter**：大隊（pop 40）/大集團（多隊共址）**真產得多於等總量小團**（餵得動多工位）——非只搬數字、比總產出。
3. **人手少全線比例**：小池多需求 → 每需要工位都 fill>0 分一份（無單工位獨吞、無 winner-take-all）。
4. **人手多飽和外溢**：大池 → 全工位 fill=1 + 餘力（surplus）。
5. **大隊一格採食人均遞減**：大隊單格採食 total 升但 per-capita 降（demand-cap+current 承載）、鋪多格/供給才規模化。
6. **頻率解耦**：labor rebalance 走 LABOR_CADENCE（非每 tick）、生產每 tick 讀 share、危機觸發即時重算 verify。
7. determinism 三跑 byte-identical + 不凍（雙 seed）+ gates 綠 + constitution + headless baseline。
**量測（measurer）**：現況 baseline vs 改後大隊/集團真產多；世界沒凍雙 seed；承載機制未破壞（大隊一格仍餓）；人手少全線比例。

## §9 工序（R② 自審 → dispatch）
本 spec → **R② 自審**（統一非平行 patch/deterministic/承載不碰/baseline 保真/憲法決策不碰/size matter genuine 非 crank）→ reviewer R²（可升，新 seam）→ implementer（隔離 branch `feat/unified-labor-pool`）→ dev-verify → measurer 量測 → merge → §5 合量（納入）。
**血脈**：非 crank（勞力真經濟投入、閒置設施真損失、util 因真 yield 升）；unified 接既有 team/tag/need_oracle/物流無新 resident subsystem；[[feedback_genuine_value_not_crank]] + CASE B 溯源。
