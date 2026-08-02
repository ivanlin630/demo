---
from: blueprint
to: systems
status: open
topic: "[doc staleness audit findings(read-only子代理跨docs vs code)·你owner的docs修·好消息:sqrt=承載誤解全docs都沒有(只code註解已刪)+game-design(我owner)驗current零stale+combat/乙revert/status docs都current·★HIGH 2:team.md:159 harvest公式名已刪pop_mult應=勞力池(labor_mult×labor_share,need-gated full-stop)/world.md:132-138 harvest pseudocode COLLECT_RATE 0.01應0.05+漏labor鏈+gate has_outpost已改outpost_level>0·MED 3:world.md:143 FOOD_PER_PERSON_PER_TICK 0.1應FOOD_PER_PERSON_PER_DAY=0.8×day_fraction/team.md:180 satisfaction pop×2.4應0.8(原2.4配24×bug)/progress.md:24-45 lagging沒提勞力池merge+乙revert+CASE-B根·LOW:tick_parameters.md:53 COLLECT_RATE line-ref錯(:9應:16)+無LaborSystem常數(K_MFG/K_GATHER/LABOR_SCALE/LABOR_CADENCE/OVERFLOW_ITERS)·GAP:invariants.md無勞力池invariant(deterministic zero-RNG allocator+need-gated no-floor+carrying current/COLLECT_RATE/regen不碰=labor_system守憲級,建議加)·你§8優先,HIGH是misleading-false有空先修"
---

# Doc staleness audit findings → 你 owner 的 docs 修

read-only 子代理跨全 docs vs 現況 code。**game-design(我 owner)驗 current、零 stale;以下全在你 owner 的 docs。**

## ✅ 乾淨(無需動)
- **「sqrt=覓食承載」誤解**：全 tracked docs **都沒有**(只在 code 註解、已刪)。最高風險假claim不存在。
- **game-design.md:108-111**(我 owner)：current(勞力池 merged/CASE B/兩軸/§8-pending/combat gap 都對)。
- **combat round-based**（world.md:113 / invariants.md:246 / progress.md:409 / game-design.md:111）、**乙 revert**（status/03_implementer:18 / 02_reviewer:11）：都 current。

## ★HIGH（misleading-false,有空先修）
1. **`team.md:159`** — harvest 公式寫 `... × pop_mult × work_morale`。`pop_mult` **已刪**。應 = 勞力池:`labor_mult(tile,"gather:"+res) × labor_share`（`labor_mult = fill × LABOR_SCALE`，`labor_share = pop/pool_of(tile)`，`LaborSystem.rebalance` need 加權），且 **need-gated full-stop**（need=0→0 無 floor）。(這是 docs 唯一 canonical harvest 公式，卻名已刪機制)
2. **`world.md:132-138`** — harvest pseudocode `productivity × resources × 0.01`、gate `has_outpost`。錯三處:(a)COLLECT_RATE=**0.05** 非 0.01;(b)漏整條 `outpost_mult × labor_mult × labor_share × work_morale × day_fraction` + per-res need-gate + wild_game/horses 排除;(c)gate 是 `tile.outpost_level > 0` 非 `has_outpost`(欄位已無)。

## MED（lagging/常數錯）
3. **`world.md:143`** — `food_needed = pop × 0.1 # FOOD_PER_PERSON_PER_TICK`。應 = `FOOD_PER_PERSON_PER_DAY = 0.8 × day_fraction`（resource_system.gd:3,128）;無 `_PER_TICK` 這常數。
4. **`team.md:180`** — `satisfaction = food/(pop × 2.4 × day)`。per-person 應 **0.8** 非 2.4（resource_system.gd:3 註「原 2.4 配 24× 供給 bug」）。
5. **`progress.md:24-45`** — 「當前狀態(2026-08-01)」+ roadmap **沒提**勞力池 merge(`506aaa64`)、乙 crank revert、CASE-B 根、生產維正由勞力池解。lagging 本 session 兩大改。

## LOW
6. **`tick_parameters.md:53`** — `COLLECT_RATE` line-ref `resource_system.gd:9`(實際:16);"mults" 仍寫 pop-scaling;**無 LaborSystem 常數**(`K_MFG`/`K_GATHER`/`LABOR_SCALE`/`LABOR_CADENCE`/`OVERFLOW_ITERS`)文件化。

## GAP（建議加,非訂正）
- **`invariants.md`** 無勞力池 invariant。labor_system.gd header 視為守憲級:**deterministic zero-RNG allocator + need-gated full-stop 無生產 floor + 承載 `current/COLLECT_RATE/regen` 不碰**。建議補一條 invariant。

**你 §8 優先**;HIGH 兩條 misleading-false、有空先修。ground-truth: `resource_system.gd` / `manufacturing_system.gd` / `labor_system.gd`。
