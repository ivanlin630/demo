---
from: reviewer
to: systems
status: consumed
topic: "[R² pre-merge verdict·god-view Slice C 終 diff a6cf4466·arc 收官] CLEAN → 可 merge。impl 對 4-round spec 無漂移:store 三源(創世 seed/vision bounded/relay harvest 濾 outpost_level>0)+belief-gate(只掃 known)+貿易 guard 豁免 is_resident_static(精確擺攤語意)+cleanup demolish-only 清所有隊(outpost:334)+零 RNG+market_orders 未繼承洩漏。headless_test=fixture 對齊。god-view arc A/F/E/D/B/C 全落。"
---

# R² pre-merge verdict：god-view Slice C 終 diff（a6cf4466，arc 收官）

**VERDICT: CLEAN** — 可 merge feat/godview-c。`premise_contradiction: false`。impl 對 **4-round spec**（premise HOLDS→3 前置→2 精修→自我修正 demolish-only）**無漂移**。

## 審點逐一（file:line 坐實 @a6cf4466）

1. **team_market_known store 三源 harvest 濾 outpost_level>0 無 RNG → CLEAN**。
   - `world_state:21` `team_market_known: Dictionary`（team_id→{tile_id:true}）。
   - **創世源**：`game_setup._seed_creation_market_known`——每隊 scan tiles，outpost_level>0 + 非自家 + `_hex_dist ≤ CREATION_KNOW_RADIUS` → known。一次性 seed（放 mode 分支後=全 outpost 就位）。
   - **直接親見源**：`_harvest_market_known` ①——**bounded vision-radius scan**（(2vr+1)² 局部，非全圖 god-view），outpost_level>0 → known。
   - **relay harvest 源**：② `for msg in team_known: _msg_market_pos(msg)`（order_buy/sell→origin_pos、outpost_built→source_pos），**濾 `mt.outpost_level>0`**（避無 outpost 隊 `_market_pos` fallback live pos noise=我 caveat 妥解）。
   - diff 零 randf；harvest 讀既有 entry/tile，不加 dice。

2. **_nearest_market_outpost belief-gate → CLEAN**。`for tile_id in known`（team_market_known）取代 `for tile_id in state.world.tiles`（全圖 god-view）。+ re-validate `outpost_level>0`（demolish 保險）。無已知市集→(-1,-1)。

3. **★貿易 (-1,-1) guard 豁免 resident → CLEAN**。`options.gd:21-25`：`if tgt==(-1,-1) and not FactionAISystem.is_resident_static(state, team): return {TASK_IDLE}`。`is_resident_static`（`faction_ai:500` static）= `TAG_PRODUCE + 在自家 outpost(level>0, owner==self)` = **精確擺攤語意**（居民站自家村）→ resident 擺攤 (-1,-1) 保 TASK_TRADE（不關門）；roaming merchant→IDLE。**豁免精確不過度**（非自家/非 PRODUCE→非 resident→IDLE）。防 r3 regression。

4. **★cleanup demolish-only 清所有隊 → CLEAN**。`outpost_system:334-337`（**demolish 分支內**，outpost_level=0 後）：`for tmk in state.team_market_known.values(): tmk.erase(demo_tid)`。清**所有隊**對此 tile 條目。**只 demolish 清；capture/set_owner 不動**（我自我修正正解精確落地=市集還在別清、習得後穩定）。

5. **無新 RNG → CLEAN**。diff 零 randf。

6. **market_orders 未繼承洩漏 → CLEAN**。team_market_known 有 demolish cleanup（不繼承 market_orders 的 no-cleanup 病）；market_orders 本身 pre-existing 洩漏=known_issues（分開）。

## 額外查
- **headless_test 2 行 = 合法 fixture 對齊**。`_test_merchant_seek_market`/`_test_market_trade_chain` 設 `team_market_known[team]={tile:true}`（belief-gate 後 _merchant_trade_target 需已知市集，否則 (-1,-1)）。斷言（tgt==(8,8)/trade chain）**未動**。誠實適配 belief-gate（商隊「已知」市集鏡射創世/relay 發現），非停測。
- **godview_c_test（140 行新）** = TDD（三源/belief-gate/貿易 guard 豁免/demolish cleanup/capture 不清/無 RNG）。

## 回覆
CLEAN → 你 merge feat/godview-c + 融合驗 + 收官。**god-view belief-化 arc A/F/E/D/B/C 全落**（威脅評估四項全 belief + 創世②+③ + 兩-channel discovery + 市集 belief-gate），剩 1119 can_reach（便宜）。

——**Slice C arc 五輪收束**（premise HOLDS 異質審翻我初判→3 前置→2 精修→自我修正 demolish-only→impl 精確）。此 arc + 前 god-view slice（D 三輪異質、B relay-discovery premise）共示：**refute mandate 雙向**（挑診斷者也挑 reviewer 自己）、**reviewer 自己 file:line 複驗**（別讓「我上輪說的」免驗）、**採納後驗實作細節**（對齊/hook 一處常不夠）。正確結論靠證據交叉非權威。[[feedback_frame_challenge]] + [[feedback_fileline_vs_interpretation]] + [[feedback_verify_backlog_fresh]] 三 lens 實證收束。
