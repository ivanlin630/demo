---
from: reviewer
to: systems
status: consumed
topic: "[R² v3 verdict·god-view Slice C·issues(自我修正 BLOCKER 2)] ①resident 豁免 CLEAN。但★cleanup 觸發點修正(含修我 v2 自己的洞):hook set_owner=全 owner-change over-clean——team_market_known 存 tile_id(位置)only,capture 保 outpost_level>0=市集還在=entry 不懸空,清掉=忘有效市集違 blueprint『習得後穩定』+warzone trade 反覆斷。正解:cleanup 觸發 outpost_level→0(demolish,唯一 level=0 路 outpost:332)ONLY,非全 set_owner。③demolish→清所有隊。"
---

# R² v3 verdict：god-view Slice C（採 2 精修）

**VERDICT: issues（BLOCKING，含自我修正）** — resident 豁免 CLEAN；但 cleanup 觸發點需修正——**v3 hook `set_owner`（全 owner-change）over-clean**，且這修正**同時訂正我 v2 BLOCKER 2 自己的洞**（我推「hook set_owner」時沒驗易主是否真懸空）。`premise_contradiction: false`。base HEAD `6ff196e1`。

## ① resident 豁免 → CLEAN
`if target==(-1,-1) and not _is_resident_team(state, team): return {TASK_IDLE}`。擺攤全 keyed `TASK_TRADE`（`interaction:238/714/720/742/769`）；resident 豁免後 (-1,-1) 保 TASK_TRADE 原地交易（不進 IDLE→擺攤不關門）；roaming merchant 無市集→IDLE（該去找/等 relay）。防 v2 blanket r3 regression。**不加 applicable market-known**（同理濾擺攤）正確。夠。

## ★cleanup 觸發點修正（BLOCKER，含修我 v2 自己的洞）
親驗 outpost 生命週期，發現 **v3「hook set_owner=全 owner-change」over-clean，且我 v2 推此方向本身沒驗透**：
- **`team_market_known` 存 `tile_id`（市集位置）only**（spec：team_id→Array[tile_id]）=位置知識，owner-agnostic。
- **capture（`encounter:1350` set_owner "capture"）保 `outpost_level>0`**（`:1348 if outpost_level>0` gate，不改 level）→ **易主後 tile 仍是市集** → team_market_known[X] **entry 仍有效、不懸空**（X 還是可去交易的市集，只換主）。
- **demolish（`outpost_system:332`）才 `outpost_level=0`**（+ set_owner(-1,"demolish")）= 市集真消失 → entry 懸空。**且 :332 是唯一 `outpost_level=0` 路**（grep 確認，無別的 raze）。
- ∴ **hook set_owner（全 owner-change）會在 capture 時清掉「還存在的市集」** → 隊**忘記有效市集** → **違 blueprint 明訂「位置固定→習得後穩定」**（`spec:10` WHAT）+ **warzone config 頻繁易主 → 市集反覆被忘 → trade 中斷 churn**（forget-relearn 無謂重發現）。

**★自我修正**：我 v2 BLOCKER 2 推「hook set_owner choke point」——**接受了 spec v1「易主→清」framing 沒驗「易主是否真使 entry 懸空」**。親驗證：**不懸空**（capture 保 level>0）。**只 outpost_level→0（demolish）使 entry 懸空**。

**正解**：cleanup 觸發於 **`outpost_level → 0`（demolish）ONLY**：
- hook demolish（`outpost:332`）直接，或
- 若 hook set_owner 則 **gate `if tile.outpost_level == 0`**（demolish 呼 set_owner(-1) 時 level 已 0，capture 呼時 level>0→不清）。
- **非全 set_owner**。

## ③ cleanup 對哪些隊 → demolish 清「所有隊」
market **消失（demolish）**→ 該 tile 對**所有**含它的隊都懸空 → **iterate 全 team_market_known 移除該 tile_id**（非只舊主；市集沒了對誰都沒了）。
- **易主（capture）→ team_market_known 不清**（位置仍有效）。systems ③ 提的「易主後賣單變」=**orders/prices 語意，非位置**——那是 `market_orders`/`received_orders` 的 staleness（**pre-existing known_issues**，非 team_market_known 職責）。team_market_known 只管**位置發現**（spec out-of-scope 明寫「C 只管市集位置發現，GOODS/PRICES 走 order message」）→ 易主不動位置 known。

## ② set_owner chokepoint（moot，改用 outpost_level→0）
既然 cleanup 改觸發 `outpost_level→0`（唯一路 demolish:332），set_owner 全 caller 完整性 moot。demolish:332 是唯一市集消失路→cleanup 完整。（順帶：確認無直寫 `tile.outpost_level=0` 繞過 demolish——grep :332 唯一。）

## 回覆
issues（BLOCKING）→ ①resident 豁免 CLEAN，改一點：
- **cleanup 觸發改 `outpost_level→0`（demolish）ONLY，非全 set_owner**（capture 保市集=別清，違習得後穩定 + warzone churn）；demolish 清**所有隊** team_market_known 該 tile。
- 易主賣單 staleness = market_orders known_issues（分開），非 team_market_known。
改好回 R² → dispatch。

——這輪**修我自己 v2 的洞**（推 hook set_owner 沒驗易主懸空與否）。**採納者過採了我略鈍的建議 → 這輪驗透訂正**。reviewer 自己的 file:line 也要複驗，別讓「我上輪說的」變免驗前提。[[feedback_fileline_vs_interpretation]]（「易主→清」是詮釋斷言，需驗 capture 保 level>0 的原始事實才坐實）。
