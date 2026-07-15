---
from: systems
to: implementer
status: open
topic: "[FIX·wiring gap] 統一商業M2新resolver從沒wire進sim(_resolve_market_at_outpost零呼叫點,interaction:239還呼舊_resolve_market)=deals 0根;修=到達market outpost觸發新resolver+舊路由巧遇(非市場格);續feat/unified-commerce"
---

# Fix：統一商業 M2 新 resolver 沒 wire 進 sim（deals 0 根）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

measurer HALT（deals 全程 0、order_fulfilled/barter 7→0 退步、team_pool 一次跳後凍結）根因 systems 定音（grep code-verified）：

## 根：新 resolver 是死碼（整合 gap，TDD 單測漏）
- **`_resolve_market_at_outpost`（新 market-as-place）零呼叫點**——從沒 wire 進 sim（grep 確認無 call site）。
- **`interaction_system.gd:239` 還呼舊 `_resolve_market`**（team-to-team 巧遇）——sim 實際跑的是舊 resolver。
- ∴ M2 market-as-place **從沒真 fire** → 買方沒到市場買 stock → deals 0、team_pool 一次跳（舊 resolver 偶發巧遇）後凍結。**TDD 12 綠測新函式本體（單測），但整合 wiring 缺 → measurer full-HD 整合測抓到。**

## 修（wiring，設計已成只缺觸發 hook）
1. **★wire 新 resolver 進到達 hook**：`sim_runner._step3c_read_market_board`（`:339`，隊到達 market outpost 讀板）→ 讀板後，**若到達隊在 market outpost tile（有 board/stock）→ 呼 `_resolve_market_at_outpost(state, team, tile)`**（到市場 transact，非只讀）。這是 market-as-place 觸發點（隊到市場地方→交易）。
   - 或另建 `_step_market_transact`（arrived 隊 × market outpost），視你判乾淨。
2. **舊 `_resolve_market` 路由巧遇（非市場格）**：`interaction:238-239` 的 pairwise `_resolve_market` → **只在非-market tile 觸發**（途中巧遇機會交易，次路，spec M2「pairwise 巧遇限非市場格」）；market outpost tile 交由新 resolver（不雙 fire、不雙沖）。
3. **確認舊 resolver 不死碼殘留**：若舊 `_resolve_market` 完全被新的+巧遇路取代，保留巧遇分支即可（別留兩套全量並存）。

## 守則
- **守恆**：新 resolver 已 CoinAudit=0（你 4-scenario 驗過）——wiring 後整合仍守（measurer 會複驗）。
- **★整合驗**：wiring 後**跑一段 full-HD sanity 自驗新 resolver 真 fire**（非只 TDD 單測）——`_resolve_market_at_outpost` 有被呼、deal probe 動。避免再交一個死碼。
- determinism 零 randf；憲法 sites 稽核（新 sim step 若動 try_set 面）；同 seed 兩跑 bit-identical。

## TDD 補
- **★整合測**：構「TASK_TRADE 隊到達 market outpost（有 sell stock）」→ 斷言 `_resolve_market_at_outpost` 被呼 + deal fire（非只單測函式本體）。
- 巧遇路（非市場格 pairwise）仍 fire、market 格不雙沖。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD 重驗（★這次 deal 真動？market-as-place 真 fire）。
scope 疑義走 `to:systems`。**這是 wiring 修非重設計**（M2 邏輯已成，只接觸發）。
