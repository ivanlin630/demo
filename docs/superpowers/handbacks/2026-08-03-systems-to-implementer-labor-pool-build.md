---
from: systems
to: implementer
status: open
topic: "[統一勞力池開工(讓size在生產matter,治CASE B genuine-value非crank用戶裁定)·spec docs/superpowers/specs/2026-08-03-unified-labor-pool-HOW.md(R²CLEAN+1追蹤項)·做:新LaborSystem(scripts/simulation/labor_system.gd class_name LaborSystem)單一共享allocator採集+製造共讀·per-tile勞力池=共址PRODUCE pop總和(HexTileData加labor_alloc:Dictionary workstation→{demand,share,fill}+labor_eval_next_tick)·workstation_key=gather:<res>+mfg:<level_key> sorted·rebalance演算法:pool=Σ共址PRODUCE pop→demand(mfg:level×K_MFG 3.0/gather:K_GATHER 5.0)→need權重(need_oracle need_keep+demand per output res Σ共址隊,w=0不參與)→需求加權比例share=pool×w/Σw→clamp≤demand+削下按剩w再分未封頂iterate到穩(固定8迭代上限)→fill=share/demand·頻率解耦lazy-on-cadence:生產sweep處理tile開頭呼LaborSystem.ensure_fresh僅current_tick>=labor_eval_next_tick才真重算(LABOR_CADENCE=TICK_PER_DAY×3)+危機共址food_days<2即時重算·labor_mult取代pop_mult:manufacturing:92 worker_rate=level×labor_mult(tile,mfg:Lk)×(0.5+skill)/resource:265-266 gain=...×labor_mult(tile,gather:res)(labor_mult=fill×LABOR_SCALE校準pop5單工位≈1.0)·多隊防雙算:gather每隊×team_pop/pool·output ownership不變·perf tile→teams index一次·★守憲硬約束(違=reject):deterministic sorted+算術+零RNG三跑byte-identical/current承載COLLECT_RATE/regen零改只換pop_mult支/憲法決策util不碰·★baseline保真±5%單工位(LABOR_SCALE校準防偷改量級)·★R²追蹤:小隊多活動下滑survivable硬驗(pool分裂每fill<1 intended但非崩早期經濟,need_oracle糧優先)·隔離branch feat/unified-labor-pool"
branch: feat/unified-labor-pool
---

# 統一勞力池 — 開工（讓 size 在生產 matter、genuine-value 非 crank）

**spec**：`docs/superpowers/specs/2026-08-03-unified-labor-pool-HOW.md`（R² CLEAN + 1 追蹤項）。用戶裁定 size-matter（治 CASE B 規模經濟 absent）。

## 做（詳 spec §1-§5）
1. **新 `LaborSystem`**（`scripts/simulation/labor_system.gd`、class_name）＝單一共享 allocator（採集+製造共讀、統一非平行）。
2. **per-tile 勞力池儲存**：`HexTileData` 加 `labor_alloc: Dictionary`（workstation_key→`{demand,share,fill}`）+ `labor_eval_next_tick: int`。
3. **rebalance 演算法**（deterministic）：pool=Σ共址 PRODUCE pop → workstation demand（`mfg:Lk`=level×`K_MFG(3.0)` / `gather:res`=`K_GATHER(5.0)`）→ need 權重（`need_oracle.need_keep+demand` per output res、Σ共址隊、w=0 不參與）→ share=pool×w/Σw → clamp≤demand + 削下按剩 w 再分未封頂 iterate（固定 8 迭代上限）→ fill=share/demand。**sorted key iterate、零 RNG**。
4. **頻率解耦 lazy-on-cadence**：生產 sweep 處理 tile 開頭呼 `LaborSystem.ensure_fresh(state,tile)`——僅 `current_tick>=tile.labor_eval_next_tick` 才真 rebalance（`LABOR_CADENCE=TimeScale.TICK_PER_DAY×3`），否則直讀。**危機**：共址任一隊 `food_days<2` → 設 `labor_eval_next_tick=current_tick`（下 sweep 立即重算）。
5. **labor_mult 取代 pop_mult**（`labor_mult=fill×LABOR_SCALE`）：
   - `manufacturing_system:92`：`worker_rate=level×labor_mult(tile,"mfg:Lk")×(0.5+avg_skill×0.5)`。
   - `resource_system:265-266`：`gain=...×labor_mult(tile,"gather:res")×work_morale`。
   - **多隊 gather 防雙算**：每共址隊 `×(team_pop/pool)`（Σ回 tile 分配）。**output ownership 不變**。
   - **perf**：rebalance 先建 `tile_pos→[PRODUCE teams]` index 一次。

## ★守憲硬約束（違＝reject、R² 8 審點）
- **deterministic**：sorted + 算術 + cascade 固定迭代 + **零 RNG** → 三跑 byte-identical。
- **承載獨立**：`_collect_from_tile` 的 `current/COLLECT_RATE/regen`（resource:254-284）**只換 pop_mult→labor_mult 那一支、庫存數學零改**。大隊採快→current 掉快→yield 降（人均遞減意圖）。
- **憲法決策不碰**：勞力池＝執行層 rate、util/argmax 零動。
- **無 explicit toggle**。

## ★校準 + 兩硬驗（dev-verify、交付前自跑）
- **baseline 保真（單工位）**：pop=5 單隊單工位 ±5% 現況（`LABOR_SCALE` 校準證、防偷改量級）。
- **★R² 追蹤：小隊多活動下滑 survivable**：小隊（pop 5–10）同時採食+採材+製造 → pool 分裂每工位 fill<1（**intended 稀缺逼排序**）→ **硬驗下滑 bounded + survivable**（need_oracle survival 拉滿糧優先不餓死、早期經濟不全面崩）。崩→tune LABOR_SCALE↑/K↓、**非 scripted floor**（憲法）。
- **size matter**：大隊(pop40)/集團(多隊共址)真產多於等總量小團（餵得動多工位）。
- **人手少全線比例**（無獨吞）+ **人手多飽和外溢** + **大隊一格採食人均遞減**（demand-cap+current）+ **頻率解耦**（rebalance 走 cadence 非每 tick）。
- determinism 三跑 byte-identical + 不凍雙 seed + constitution + headless baseline + 全量 tap（labor pool/fill/dispatch）。

## 交付
- code 寫 worktree `feat/unified-labor-pool`（隔離）、handback `to:systems`（帶 bed 數字：baseline 保真/小隊多活動下滑幅度/大隊真產多/determinism）→ 我 R² 融合驗 → measurer 量測 → merge。
- 卡住/scope 變/K 校準難 → 報 `to:systems`（禁 inline 越界、禁問用戶）。
