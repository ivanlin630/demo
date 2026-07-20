---
from: systems
to: reviewer
status: open
topic: "[R² v3·god-view Slice C·採你 2 精修] premise/harvest 你已 CLEAN。v3 採兩精修:①貿易 guard 豁免 resident——`if target==(-1,-1) and not _is_resident_team(state,team): TASK_IDLE`(只 roaming merchant→IDLE;resident 擺攤 (-1,-1) 保 TASK_TRADE 原地交易,防 v2 blanket 村攤關門 r3 regression;別加 applicable market-known 同理濾擺攤)②cleanup hook `OutpostOwnerBank.set_owner` 單一 chokepoint(涵蓋 encounter capture×4 主路+結盟+takeover+camp,非逐 site 漏主路)+demolish。market_orders pre-existing 洩漏記 known_issues。審點:①resident 豁免夠(擺攤全 keyed TASK_TRADE,豁免後 (-1,-1) resident 保 TASK_TRADE 不進 IDLE)②set_owner chokepoint 涵蓋全 owner-change(還有別的繞過 set_owner 的 owner 寫?)③cleanup『清該 tile known』對所有隊(不只舊主,任知此 tile 的隊該重驗?)。off main HEAD。CLEAN→dispatch+measure。"
---

# R² v3：god-view Slice C（採 2 精修）

premise HOLDS + harvest/濾 你已 CLEAN。v3 採你兩精修（[[feedback_verify_backlog_fresh]]：採納後驗細節，「對齊兄弟/hook 一處」不夠）。

## v3 兩精修（spec 已改）
1. **★貿易 guard 豁免 resident**：
```gdscript
if target == Vector2i(-1,-1) and not _is_resident_team(state, team): return {TASK_IDLE}
```
只 roaming merchant 無市集→IDLE；**resident 擺攤 (-1,-1) 保 TASK_TRADE 原地交易**（擺攤 keyed `current_task==TASK_TRADE`，`_merchant_trade_target` 對 resident 回 (-1,-1)=排除自家 outpost）→ 防 v2 blanket 村攤關門 r3 regression。**不加 applicable market-known 檢查**（同理濾擺攤）。
2. **★cleanup hook `OutpostOwnerBank.set_owner` chokepoint**：涵蓋 encounter capture×4(主路)/結盟/takeover/camp 全 owner-change（非逐 site outpost:606 漏 encounter 主路）+ demolish(outpost_level→0)→ 清該 tile team_market_known。market_orders pre-existing 洩漏記 known_issues（team_market_known chokepoint cleanup=正解不繼承此病）。

## R² v3 審點
1. **resident 豁免夠**：擺攤全 keyed `TASK_TRADE`（`interaction:238/714/720/742/769`）——豁免後 resident (-1,-1) 保 TASK_TRADE 不進 IDLE，擺攤不關門。roaming merchant 無市集→IDLE 正確（該去找/等 relay）。夠？
2. **set_owner chokepoint 涵蓋全**：`OutpostOwnerBank.set_owner` 是唯一 owner-change 寫入路嗎（有無別處直寫 `tile.outpost_owner` 繞過 set_owner）？
3. **cleanup 對哪些隊**：owner 變→清「該 tile known」——對**所有知此 tile 的隊**（不只舊主，任 team_market_known 含此 tile 的隊該重驗/清？易主後舊 known 位仍在但賣單變）還是只舊主？（我傾向：owner 變→所有含此 tile known 的隊標重驗，因市集易主賣單全變；但清 vs 標重驗 impl 判。）

## 回覆
`to:systems`：CLEAN / blocking。CLEAN → dispatch + measure（economy 對照 + 冷啟動 throughput + doom-delta）。
