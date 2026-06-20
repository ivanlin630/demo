---
from: implementer
to: systems
status: open
date: 2026-06-20
feature: 經濟 WS-3 移動隊硬 carry cap + 救活馬車
branch: feat/economy-ws3-carry-cap
plan: docs/superpowers/plans/2026-06-20-economy-ws3-carry-cap.md
---

# Hand Back: 經濟 WS-3 carry cap 硬 + 馬車 load-bearing

## 實作摘要

- `scripts/simulation/movement_system.gd`
  - 新 `remaining_carry_space(team)` = `get_carry_capacity − calc_total_weight`，floor 0（防負/除零）。
  - 新 `carry_space_for_res(team, res)` = `remaining_carry_space / _resource_weight`；weight 0 的 res（mounts/wagons/coin）回大數（`1<<30`）→ 不誤限。
  - **`_resource_weight` 新增 `coin → 0.0`**（見「與 plan 偏離」）。
- `scripts/simulation/interaction_system.gd`
  - `_attempt_trade_direction` 函式頭加 `var ms := MovementSystem.new()`。
  - buyer 進貨兩處 intake 受 carry 空間限（與 `buyer_coin` 後再 `mini`）：inventory 買（`item["grade"]`）、surplus 買（`res`）。既有 `qty<=0` 守衛 → 買方滿載即不買。
- `scripts/simulation/resource_system.gd`
  - `_collect_from_tile` 的 **else 分支**（非 PUBLIC_RESOURCES、非 food 糧倉路徑的移動隊 res，如 material）：gain 前算 `carry_space_for_res` → `gain = minf(gain, space_qty)`；`gain<=0 → continue`（滿載不採，tile 不扣）。**未動 WS-1 food 糧倉路徑**（line 216 的 `if res in PUBLIC_RESOURCES or res == "food"` 分支原封不動）。
- `scripts/debug/headless_test.gd`
  - 三新測 + 註冊：`_test_carry_cap_trade`（helper 行為）、`_test_carry_cap_forage`（移動隊硬上限+超額留 tile）、`_test_trade_throughput_wagon`（確定性 throughput + 馬車對照 + coin_eq 守恆）。

## 守恆驗證（零 drop、零 coin 觸碰）

- **trade**：buyer 少買 → `_execute_transfer`/coin 對稱少動，seller 留貨。throughput 測試內 `coin_eq`（Σ qty×BASE_PRICE）成交前後 delta < 0.01，seller 出貨量 == buyer 進貨量。
- **forage**：超額不採 → 留 tile（測試斷言 tile material 99999 → 仍 >90000）。team 總重 ≤ carry cap。
- 全回歸 `coin_eq` 測試（投靠/屠村/extract_treasury/storage/trade conservation）全綠；world_sim `[CoinAudit] delta=0.00`。

## 四新測 + 回歸閘結果（全綠）

headless（`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`）：
- `=== DONE ===` ×1
- SCRIPT ERROR ×0、Assertion failed ×0
- `carry cap trade OK (空間 pop2=20.0 +馬車=60.0 裝貨後=45.0)`
- `carry cap forage OK (weight=20.0/cap=20.0)`（移動隊總重精確收斂到 carry cap，非無限囤；修前=92304）
- `trade throughput OK (無車進貨=50.0 有車進貨=130.0)` — 無車進貨 == carry cap 50（受 carry 限非 coin，coin=100000 充足）；2 馬車 → 50+80(WAGON_BONUS×2)=130，**馬車 load-bearing 確認**
- 既有覓食/絕境/飢荒全綠：`NPC forage viability OK`、`Forage release OK`、`desperation cascade OK`、Famine Task1a–3c OK（carry cap 未卡死維生覓食/絕境）
- 既有 trade 全綠：`trade conservation OK`、`trade chain end-to-end OK (fulfilled=1)`、`_resolve_market 雙向`、barter coin_eq OK
- `InvariantAudit population/faction 雙向/subteam 雙向 OK`

## world_sim 煙霧（非閘，game_sim_multi.gd）

- 0 SCRIPT ERROR，四 config 跑完整 ticks（game_sim_test/warzone 各 21600 tick）。
- **無凍結**：`[Move] 抵達` ×97、stuck ×0；`[Barter]` ×2、`[SurvivalForage]` ×12（貿易/覓食仍發生）。
- **移動隊不再無限囤**：MaterialStats 各 config material 均無 4+ 位數堆積（幽靈囤已殺）；無 `weight=####`/`囤` 異常。
- `[CoinAudit] coin_eq delta=0.00`（四 config 守恆）。
- **履約/[Market]成交對照 WS-2**：本次 multi-sim run `[Market]成交`=0（unseeded smoke，這幾個 config 的隊少有市集 co-locate 成交，與 WS-2 後同屬偶發；CLAUDE.md 載明 multi drift 不可重現、僅煙霧）。**throughput 的權威證據 = Task3 確定性測試**（無車 50→有車 130），非 multi drift。
- tyrant config `game_over: 玩家絕後` = 該 config 正常玩家絕嗣終局（非崩潰）。

## 與 plan 偏離（1 項，需 systems ack）

- **`coin` 改 weightless（`_resource_weight: coin → 0.0`）**：plan 未列此改。原因：`coin` 原走 `_resource_weight` default 1.0，買方囤大量 coin → `calc_total_weight` 暴漲 → `remaining_carry_space=0` → 買方一個都買不到（throughput 測 got=0，且回歸 trade 測「A 應收到 coin」「trader 應買到 food」全紅）。錢幣無物理載重理由，且這是 carry cap **凍結貿易**的根因（守則「carry cap 不可卡死貿易」）。判定為回歸必需的修正，非平衡調參。
  - **連帶語意變更**：`calc_total_weight` 同被 `_move_cost` 的既有超載速度懲罰使用 → coin weightless 後，富隊不再因囤 coin 觸發速度懲罰（修前其實會，疑似 pre-existing 非預期 artifact）。回歸全綠、world_sim 移動正常（stuck=0），但這是**既有軟懲罰行為的微改**，呈報 systems 確認是否接受（我判定接受：錢幣不該壓垮商隊速度）。

## 連動風險

- `MovementSystem._resource_weight` / `get_carry_capacity` / `calc_total_weight`：現多三處 consumer（trade buy / forage cap / 既有速度懲罰）。carry 常數（BASE_CARRY=10/MOUNT_BONUS=15/WAGON_BONUS=40）與 res weight 皆 TEST VALUE → 平衡 pass 調整時，trade throughput 與 forage 上限會一起動（單一源，符合預期 coupling）。
- 定居 vs 移動分流維持：定居隊 food 走糧倉 cap（WS-1，未碰）；移動無 outpost 隊 material 等走本 WS carry cap；food 對無 outpost 小隊仍走 else-fallback 但 food **不在本 WS else 分支**（food 在上面 `or res == "food"` 分支，carry cap 不咬 food → 小隊維生覓食不被卡，絕境測試守住）。
  - 註：無 outpost 小隊的 food fallback（line 226-229）**不受 carry cap**，故 food 對移動小隊仍可無限囤（plan 範圍只限 trade+非糧 forage）。若後續要對移動隊 food 也設 carry 上限 = 另 WS（本 WS 不碰，守「別動 food 糧倉路徑」）。

## 待主 session 確認

1. **coin weightless**（上「與 plan 偏離」）—— 接受 / 改採其他方案（如 carry_space 計算時排除 coin 但保留速度懲罰的 coin 重量）？我建議接受（最簡、conservation-neutral、語意正確）。
2. **loot 不在本 WS**（plan Self-Review 載明，屠城搬不完 = 另議）—— 確認後續 task。
3. 移動小隊 food fallback 無 carry 上限（見連動風險）—— 是否後續補（本 WS 範圍外）。
