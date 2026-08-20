# 資訊網 distribute 免費直注 relief — HOW spec（機制最後一 bug）

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint GO） | **branch**: `feat/info-network-whole`（續）
**root（diagnostic #6 重現、bed persist 0b599dc8）**：distribute 賑濟 convoy 6/6 arrive（travel 正常、**非黑洞**）、卡 settle 站——5/6 bail（`sell_owner_no_coin×4/sell_ownerless×1`）。**code-located `interaction:765`**：distribute 注 `override_ask=local_value×price_factor`；**「免費/仁君」路 `free_dist=(override_ask==0)` UNREACHABLE**（`price_factor=(0.5+greed)/(0.5+honor)` 永不 0）→ 恆對餓 resident 定價 → 無 coin bail。**＝SLICE B 設計的免費仁君路是 dead code=實作 bug 非設計錯**（blueprint 認）。
**WHAT 裁**：blueprint GO——distribute=gift 直注（mini-util 仁慈/責任已 gate 該不該送、送了就給、不過 coin/定價 bail）。

## 修（distribute settle = 免費直注 gift）
- **`interaction_system.gd:765`**（distribute override_ask 注入）：
  ```
  - oask = maxf(TradeValuation.local_value(owner, res, state) * pf, 0.0)   # 舊：定價(dead 免費路)
  + oask = 0.0   # ★免費直注：賑濟=gift、mini-util(仁慈/責任)已 gate 該不該送、送了就給
  ```
- 效果（`_market_visitor_sell` free_dist 路已在、reuse）：`override_ask=0`→`free_dist=true`→跳 `sell_owner_no_coin`/affordability/`sell_no_price` bail→`qty=minf(order_rem, sellable)`→`TileBank.deposit(tile, food, qty)` 免費存入 resident 據點 storage→coin no-op（`bid=0`、守恆）→`distribute.deliver` bump。**餓 resident 據點得糧、零付款。**
- **★人格語意保留（非 crank）**：**發不發賑濟=mini-util 仁慈/責任秤**（`_try_distribute_side`、低仁君不派=正確 emergent）；**送了=免費 gift**（不再對餓子民定價）。price_factor 的 coin_term（賣 surplus 抽 coin）語意本用於**非 relief 的 surplus 分配**、但 distribute=relief 場景（症1 餓子民）該免費——移 distribute 定價=修 dead-code 免費路、非改設計。

## ownerless edge（1/6、小、順手）
- `:854 if owner == null: sell_ownerless return false` 在 free_dist 前——distribute 到 owner==null 的據點仍 bail（1/6）。**順手**：distribute（free_dist 意圖）若 `owner==null` 但 tile 是 resident 據點 → 允許 `TileBank.deposit` 到 tile（食物入據點、resident 讀）、非 bail。若實作複雜度高→標 tracking（1/6 小、override_ask=0 已解 4/6 主體）。

## 守（reviewer R²）
- **genuine 非 crank**：發賑濟決策=mini-util 仁慈/責任（`_try_distribute_side` 不動）；免費 gift=修 dead-code 路、**非藉機讓 distribute 過**（本病=餓子民被定價、非 util 太低）。
- **感知鐵律 / determinism**：settle 純資源轉移零 RNG；免費路 coin no-op。
- **economy 不爆 / coin 守恆**：`bid=0`→coin 雙向 no-op（守恆維持）；food_surplus 守 reserve（`sellable` 已扣、convoy cargo 語意不變）。
- **de-patch 非增殖**：改一行 override_ask（啟用既有 free_dist dead 路）、非新機制。

## 驗收（re-measure 症1 端到端 on FACTION bed、persist bed）
- **`distribute.deliver` 5/6→6/6 真 settle**（免費直注、不再 owner-coin bail）+ **`food_delivered` 顯著 >1.0**（多筆真到）。
- **★糧真到 resident 據點 storage、runway 回升**（端到端真效果、症1 首次真閉環）。
- 若糧到但量級/timing 仍不足救人 = **economy-balance follow-up 記檔**（relief 量級/衰減 vs latency、非本 fix）。
- 人格分化（仁君派賑濟/greed 低不派）+ determinism + Part1+3+scout+letter 不退 + coin 守恆。

**路 reviewer R²（審 免費 gift 非 crank/coin 守恆/人格語意保留/ownerless edge）→ CLEAN → build → re-measure 症1 端到端（bed `config/infonet_whole.json` persist、糧真到 resident）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 判 arc-done vs economy-balance follow-up → 推用戶驗收。**
