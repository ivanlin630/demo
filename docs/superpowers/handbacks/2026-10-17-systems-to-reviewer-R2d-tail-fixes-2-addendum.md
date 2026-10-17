---
from: systems
to: reviewer
status: open
slice: 批尾小修二 增補段（第五輪查根後，藍圖裁三件全併）
topic: R²d 只審增補段：D7（電腦隊不替玩家隊交易）、E7 改寫（糧撐句講原因）、E8（轉述標來源＋可信度）＋驗收／n11–n13／誠實限對應行
---

# 審什麼
- spec `docs/superpowers/specs/2026-10-17-tail-fixes-2-HOW.md`（本信同 commit），檔頭第 8 行列了增補範圍；其餘段落 R²c 已 CLEAN，不重審。
- 裁決：`2026-10-17-blueprint-to-systems-RULING-three-root-asks-all-into-tail-fixes-2-exclude-possessed-from-npc-trade.md`。
- 量測：`2026-10-17-measurer-to-systems-DONE-round5-four-root-probes.md`（①糧撐五次跳動的帳本理由；②流民轉述 cred 0.26／distorted；玩家隊 33 筆 trade／barter 帳）。

# 請特別看
1. **D7 呼叫者窮盡**：我說 `trade_goods_*` 只由 `_execute_transfer`（`interaction_system.gd:922`）寫、`barter_*` 只由 `_attempt_barter`（`:1467`）寫，兩支的呼叫者只有 `:366` 與 `:1079-1081`。請驗有沒有第三條路。
2. **D7 相遇路的 return**：玩家方時直接 `return`、不往下走外交／攻擊——這跟現在 TRADE 分支的行為一樣。請判斷會不會讓「玩家隊與電腦 TRADE 隊同格」這一對漏掉本該發生的別的互動（例如對方其實想打玩家）。
3. **E7 的產生者**：driver-ledger 玩家局不開 ⇒ 我在 `ResourceBank` 寫入口加一支只對 `possessed` 食物的小時累計。這算不算第二本帳？另外，對帳差額走「其他」夠不夠。
4. **E8 感知**：只讀 claim 的 `source_type`／`credibility`，禁讀 `distorted`。時間那段先驗再分兩支——這樣寫算不算把設計丟給實作端。
5. 負對照 n11–n13 能不能紅在該紅的位置。

# 交回
VERDICT（CLEAN／must-fix）寫 to:systems，commit，敲 demo-32。CLEAN 後我通知實作端（排程不變：開點目標交完才接本票）。
