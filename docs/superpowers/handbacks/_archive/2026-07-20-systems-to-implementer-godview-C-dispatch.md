---
from: systems
to: implementer
status: consumed
topic: "[dispatch·god-view Slice C 市場 belief-gate·R² v4 CLEAN(4輪異質審)·★off LOCAL main f7390b1e·economy measure 敏感] spec=2026-07-20-godview-slice-C-market-discovery.md。root:_nearest_market_outpost(faction_ai:2112 行號驗過非 audit stale 2065)全掃 tiles=god-view。修 4 部:①新 WorldState.team_market_known(team_id→Set[tile_id])三源:創世-nearby(proximity≤CREATION_KNOW_RADIUS)+直接親見 outpost+★relay HARVEST(從 team_known 的 order/outpost_built 訊息收 origin_pos/source_pos 進 known,★濾 tile.outpost_level>0 避無 outpost 隊 live pos noise,★無新 RNG harvest 既有 entry)②_nearest_market_outpost:2112 belief-gate(只掃 team_market_known 非全 tiles)③★貿易 to_task(options:22)補 `if target==(-1,-1) and not _is_resident_team(state,team): return {TASK_IDLE}`(只 roaming→IDLE;★resident 擺攤 (-1,-1) 保 TASK_TRADE 原地交易,防 r3 村攤關門;別加 applicable market-known 同理濾擺攤)④★cleanup 只 hook demolish(outpost:332 outpost_level→0 唯一路)→清所有隊此 tile known;★capture/set_owner 不清(市集還在習得後穩定)。market_orders pre-existing 洩漏已記 known_issues 別繼承。★★off LOCAL main f7390b1e 禁 origin,pre-push hook 已裝。TDD 7型(spec §驗收)。gate/headless 0new/determinism 無新 RNG/★measure=economy 對照(trade volume/coin_eq/市集發現曲線)+冷啟動 throughput+doom-delta seed1337/42/4201+8 config sanity。task=systems+reviewer。"
---

# dispatch：god-view Slice C（市場 belief-gate，R² v4 CLEAN 4 輪異質審）

spec：`docs/superpowers/specs/2026-07-20-godview-slice-C-market-discovery.md`（4 輪異質審磨：v1 premise 驗 HOLDS→v2 3 前置→v3 2 精修→v4 自我修正 demolish-only）。★economy measure 敏感→非盲改。

## ★★ branch base
- **off LOCAL main `f7390b1e`**（禁 origin 落後）。pre-push hook 已裝。

## 修 4 部
1. **新 `WorldState.team_market_known`**（`team_id → Set[tile_id]` 已知市集）三源：創世-nearby（proximity≤`CREATION_KNOW_RADIUS`）+ 直接親見 outpost（vision）+ **★relay HARVEST**（從 `team_known` 的 order/outpost_built 訊息收 `origin_pos`/`source_pos` 進 known；★**濾 `tile.outpost_level>0`**避無 outpost 隊 `_market_pos` fallback live pos noise；★**無新 RNG**——harvest 既有 entry 不加「注意到市集」dice）。
2. **`_nearest_market_outpost:2112` belief-gate**：只掃 `state.team_market_known[team_id]`（已知），非全 tiles。無已知→(-1,-1)。
3. **★貿易 to_task guard 豁免 resident**（`options.gd:22`）：`if target==(-1,-1) and not _is_resident_team(state, team): return {TASK_IDLE}`。只 roaming→IDLE；**★resident 擺攤 (-1,-1) 保 TASK_TRADE 原地交易**（防 r3 村攤關門）。**別加 applicable market-known 檢查**（同理濾擺攤）。
4. **★cleanup 只 hook demolish**（`outpost:332` `outpost_level→0` 唯一路）→ 清**所有隊** team_market_known 對此 tile；**★capture/set_owner 不清**（市集還在=known 位置仍有效，習得後穩定；warzone 頻繁易主不忘市集）。market_orders pre-existing 洩漏已記 known_issues 別繼承。

## 驗收（spec §驗收 7 型）
①創世-nearby ②直接親見 ③relay harvest（濾 outpost_level>0）④belief-gate 只回 known ⑤demolish→清所有隊(capture 不清) ⑥貿易 (-1,-1) 非-resident→IDLE、resident 保 TASK_TRADE ⑦harvest 無新 RNG。gate PASS / headless 0 new / determinism 2 跑 byte-identical。
- **★measure（→measurer，economy 敏感非盲改）**：economy 對照（trade volume/coin_eq/市集發現曲線 vision+relay）+ 冷啟動 throughput（無 outpost 隊靠 relay 補市集，貿易起得來）+ doom-delta（seed1337/42/4201）+ 8 config sanity。

## 完成判定 = systems + reviewer/QA。做完 → to:measurer。
