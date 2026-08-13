---
from: systems
to: implementer
status: open
topic: "[dispatch perf slice A:gather market-finder 冗餘消除(byte-identical、profile pin 的 dominant 熱點、R² binding 已定)·FACT(measurer profile):gather() 內 _harvest_market_known(state,team)(faction_ai:3224、O(VR²=49格+|team_known| list 掃、void 刷 state.team_market_known cache)被呼兩次——_nearest_market_outpost(:3183 食物市集)+_nearest_market_outpost_with(:3202 材料市集)各內呼一次刷、同 team 同 tick 必同結果=100% 冗餘·fix(compute-once、call-scoped、複用既有 cache 非新增):①_nearest_market_outpost/_nearest_market_outpost_with 加參數 skip_refresh:bool=false(default 保留現行=其他 caller 照刷)、skip_refresh=true 時跳 _harvest_market_known 只讀 cache②gather(decision_context:314-319)刷一次:先 _fa._harvest_market_known(state,team)、再 _nearest_market_outpost(state,team,true)+_nearest_market_outpost_with(state,team,'material',true)·★byte-identical:同 team 同 tick cache 內容相同(刷1次=刷2次)、只去重複掃·★R² binding:refresh 決策 call-scoped 在 gather、非新增跨tick cache(team_market_known 是既有 belief cache、只是別刷兩次)·★invariant:感知鐵律不變(cache 內容不動、還是 vision+team_known belief)、零新 RNG·★gate(measurer byte-identical 硬):fp 三跑 identical + vs baseline main 同 fp(seed1337 warring 1000tick StateFingerprint)=任一 diff=非byte-identical退回 + rank.gather/tick-time 降(perf_phase_bed 對照)·★TDD:_nearest_market_outpost skip_refresh=true 讀既有 cache 回同值(vs 現行 refresh 版同結果)·worktree feat/perf-market-memoize base 現main·完→handback to:systems 附 measurer byte-identical+perf 量測·★次要 slice B(redundant gather 8+呼點 options.gd to_task 5處+faction_ai 3處)另 spec、本 slice 只 A·地基KEEP"
---

# dispatch perf slice A — gather market-finder 冗餘消除（byte-identical、pin 的 dominant 熱點）

profile pin 的 dominant 熱點。R² binding 已定（call-scoped、byte-identical）。

## FACT（measurer profile）
gather() 內 `_harvest_market_known(state,team)`（faction_ai:3224、**O(VR²=49格+|team_known| list 掃**、void 刷 `state.team_market_known` cache）**被呼兩次**：
- `_nearest_market_outpost`（:3183 食物市集）+ `_nearest_market_outpost_with`（:3202 材料市集）各內呼一次刷。
- 同 team 同 tick **必同結果 = 100% 冗餘**。

## fix（compute-once、call-scoped、複用既有 cache 非新增）
1. `_nearest_market_outpost` / `_nearest_market_outpost_with` 加參數 `skip_refresh: bool = false`：
   - default（false）保留現行=其他 caller 照刷（byte-identical 其他路徑）。
   - `skip_refresh=true` 時**跳 `_harvest_market_known`、只讀 cache**。
2. gather（decision_context:314-319）**刷一次**：
   ```
   _fa._harvest_market_known(state, team)                              # 刷一次(call-scoped)
   var _mkt = _fa._nearest_market_outpost(state, team, true)            # skip_refresh
   c.has_material_market = _fa._nearest_market_outpost_with(state, team, "material", true) != Vector2i(-1,-1)
   ```

## ★byte-identical + invariant
- **byte-identical**：同 team 同 tick cache 內容相同（刷 1 次 = 刷 2 次）、只去重複掃。
- **R² binding**：refresh 決策 **call-scoped 在 gather**、**非新增跨 tick cache**（`team_market_known` 是既有 belief cache、只是別刷兩次）。
- **感知鐵律不變**（cache 內容不動=vision+team_known belief）、零新 RNG。

## ★gate（measurer byte-identical 硬）
- **fp 三跑 identical + vs baseline main 同 fp**（seed1337 warring 1000tick StateFingerprint）= 任一 diff=非 byte-identical **退回**。
- **rank.gather / tick-time 降**（perf_phase_bed 對照）。

## ★TDD
`_nearest_market_outpost` skip_refresh=true 讀既有 cache 回同值（vs 現行 refresh 版同結果）。

## worktree
`feat/perf-market-memoize`、base 現 main。完 → handback to:systems（附 measurer byte-identical + perf 量測）。

★次要 **slice B**（redundant gather 8+ 呼點 options.gd to_task 5處 + faction_ai 3處）**另 spec、本 slice 只 A**。地基 KEEP。
