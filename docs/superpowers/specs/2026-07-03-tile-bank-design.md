# 單寫者 A 波：S1 tile-bank（第 3 不變量最後大塊）— Design

> 管線序（用戶裁）。freshness 已驗（2026-07-03 investigator）:30 直寫 `public_storage[` 站點、無 TileBank、coin 憑空鑄 outpost:259。
> **判斷器盤點（checklist）**:banker pattern 既有五例（ResourceBank/LoyaltyBank/UnrestBank/OutpostOwnerBank/CoinAudit）——本波=**收編進同 pattern**（mirror,非新裁決者）。判斷器淨數 0。

## 範圍
1. **TileBank chokepoint**（world_state 或獨立 static class,mirror ResourceBank 簽名）:
   - `deposit/withdraw/set_amt(tile, res, amt, reason)` 管 `tile.public_storage`;`tile.resources`（自然池）同傘（`regen/harvest/hunt` reason）。
   - cap 語意保留（現 `_get_storage_cap` clamp 移入 bank=單點）。
   - 30 直寫站點（resource/outpost/manufacturing/interaction/faction_ai/harvest/ambush…）收編。
   - 每站 reason=driver-ledger（Pattern B）;CI-scan pattern 附註解（強制閘地基,同 B 波慣例）。
2. **coin 憑空鑄收編**（守恆 connect）:
   - mint（outpost:259）產 coin 走 TileBank+`CoinAudit` mint ledger（slice1 既有 `minted` 軌——tile vault 已在 audit 全池,鑄入記 minted=守恆閉合）。
   - **順收兩舊 known_issues**（同域,行為修段單獨 commit）:
     a. **mint-cap 燒 ore**（outpost `_tick_mint` coin 滿 cap 仍耗 ore=off-ledger 損失）→ 滿 cap 跳過/部分消耗。
     b. **anon_treasury off-map leak**（`_nearest_valid_tile` 全無 → coin 靜默丟）→ 擴半徑 or 記 ledger sink（`extinct_no_tile` reason 顯性化,不再靜默）。
3. **不做**:facility levels/stable_progress/occupied_by（非資源量,另型欄位,列殘量）;player 路徑（F-P 傘）。

## 紀律
- **純 refactor 段 pointwise CLEAN×3 seed 必須**;行為修段（2a/2b）單獨 commit 單獨驗（CoinAudit 前後+月線 sanity）。
- 與在飛軌無衝突（收益鏈/B 波已 merge,outpost 檔已釋出）。
- 守恆:coin 全池 delta 語意升級——鑄入走 minted 軌,audit 等式 `after = before + minted` 全綠。

## 驗收
1. 直寫殘量 grep=0（`public_storage\[` / `tile.resources\[` 賦值,bank 檔自身+殘量清單除外）。
2. pointwise CLEAN（refactor commits）;2a/2b 行為修:mint 滿 cap 不燒 ore（測）、off-map 滅團 coin 有 ledger 軌（測）。
3. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7（S5 mint 魂含）、**CoinAudit delta=0 且 minted 軌正確**、InvariantAudit 0。

## 檔案 scope
`world_state.gd` 或新 `tile_bank.gd`（class_name→跑 --import）、直寫站點檔（resource/outpost/manufacturing/interaction/faction_ai/harvest/ambush/encounter）、`headless_test.gd`。
