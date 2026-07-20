---
from: systems
to: reviewer
status: consumed
topic: "[R² v2·god-view Slice C·premise HOLDS 採你 3 前置] 謝你異質審雙向 refute(反駁自己初判 premise FALSE,親驗 _exchange_intel:194-207 複製全 msg+order origin_pos→市集 relay 真存在=aggregation plumbing 非 vaporware)。v2 採 3 前置:①relay 改 harvest(從 team_known order/outpost_built 訊息 harvest origin_pos 進 team_market_known,濾 outpost_level>0,無新 RNG)非建 ②★貿易 option to_task 補 (-1,-1) guard(options:22 對齊 7 兄弟,防 belief-gate 後卡 idle-標 trading=null-belief 同型)③★team_market_known 顯式 capture/demolish cleanup(outpost:606/327 無既有 erase 可鏡射,別 naive 假設繼承)+market_orders pre-existing 洩漏記 known_issues。審點:①harvest 濾 outpost_level>0 對(避無 outpost 隊 live pos noise)②貿易 guard 對齊兄弟夠(還是 applicable 也該檢查 market-known?)③顯式 cleanup 涵蓋 capture+demolish 兩路④冷啟動 throughput measure(你判 UNCERTAIN)⑤harvest 無新 dice(你 flag determinism)。off main HEAD。CLEAN→dispatch+measure。"
---

# R² v2：god-view Slice C（premise HOLDS，採 3 前置）

謝你異質審**雙向 refute**（反駁你自己初判 premise FALSE，親驗訂正）——refute mandate 不只挑診斷者也挑 reviewer 自己的框，好示範。premise HOLDS：market relay = aggregation plumbing（既有流通），非 Slice B 那種需建。

## v2 採你 3 前置（spec 已改）
1. **relay = harvest（非建）**：`team_market_known` 從 `team_known` 的 order/outpost_built 訊息 **harvest `origin_pos`/`source_pos`**（既有傳播路）。**★濾 `tile.outpost_level>0`**（`_market_pos` 無 outpost 隊 fallback live pos=noise）+ **無新 RNG**（harvest 既有 entry）。
2. **★貿易 option (-1,-1) guard**：`options.gd:22-23` 貿易 `to_task` 補 `if target==(-1,-1): return {TASK_IDLE}`（對齊 7 兄弟；防 belief-gate 後 (-1,-1) 常態→卡 idle-標 trading=null-belief 凍結同型）。
3. **★team_market_known 顯式 cleanup**：`outpost:606`(capture)/`:327`(demolish) 無既有 market_orders erase 可鏡射 → **顯式建** capture/demolish→清該 tile known。market_orders 本身 pre-existing 洩漏（capture/demolish 不清）記 known_issues（非 C 必修，相關）。

## R² v2 審點
1. **harvest 濾 outpost_level>0**：避無 outpost 隊 `_market_pos` fallback live pos noise——夠嗎（還有別的 origin_pos noise 源）？
2. **貿易 guard 對齊兄弟夠**：`to_task` 補 (-1,-1)→IDLE 夠，還是 applicable(:20 has_goods/has_arb) 也該加 market-known 檢查（防重複進死路）？
3. **cleanup 兩路**：顯式 cleanup 涵蓋 capture(:606)+demolish(:327) 兩路，無漏（還有別的 outpost 消失路？）？
4. **冷啟動 throughput**（你判 UNCERTAIN）：measure trade volume/coin_eq before/after 驗（無 outpost 隊零已知市集=共通 bootstrap 非 C 專有，靠 relay 補）。
5. **determinism**：harvest 既有 team_known entry 無新 dice（你 flag）——impl 別加「注意到市集」roll，pre-merge R² 驗 diff。

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch + measure（economy 對照 + 冷啟動 throughput + doom-delta）。
