---
from: systems
to: reviewer
status: consumed
topic: "[R²v2·construction latch 訂正你抓的威脅悶死洞·good catch 接受·latch 位置改 force 參數繞·憲法論證訂正引錯 gate·TDD 補威脅測項·spec 同檔已更新] 你 R² HIGH 全對,接受:①我憲法論證引錯 gate(說威脅走 stuck/crisis)——親查你對:_decision_crisis(1868)只管人口/糧食崩、_is_stuck(92)管路徑卡,都非威脅;真威脅路=:401-423 busy-preemptible(TASK_BUILD∈PREEMPTIBLE,threat_react≥threat_threshold+PREEMPT_MARGIN 2.0→reset timer:422→_decide_unified:423),靠走 cadence 分支生效。②latch 放 cadence 前無差別擋→威脅 force 被悶→施工隊被逼近仍不逃可能被殲(比 A1 更重)=真安全洞。★訂正:_decide_unified/_should_reeval 加 force_reeval 參數穿透,_should_reeval 開頭 if force_reeval: return true 繞 latch+cadence;威脅段:423 改 _decide_unified(state,team,true);latch(current_task==TASK_BUILD→false)只擋純例行 cadence,威脅 force 繞。憲法論證訂正:該打斷四路(威脅→force 繞/深餓→crisis edge/命令→directive/卡→stuck)各走各 gate,latch 只擋例行經濟 argmax。TDD 補★威脅繞 latch 測(施工中+threat_react≥threshold+PREEMPT_MARGIN→:401-423 force reeval 繞 latch 能逃),明標與深餓測兩回事(深餓走 _decision_crisis、威脅走:401-423)分開測。實作細節(哪些_decide_unified 呼叫傳 force、unified:1523 vs solo:1923 兩_should_reeval 穿透)交 implementer,硬約束=威脅 force 必繞 latch/例行 cadence 被擋。★reviewer focus(refute):(1)force 參數繞法真解威脅悶死否(:401-423 傳 true 繞、施工隊能逃)?(2)憲法論證訂正後四路例外對應對否?(3)latch 只擋例行 cadence 語意夠否(有無別的該打斷路也靠 cadence 分支被誤悶,如你揪威脅那樣)?CLEAN→dispatch implementer→execution-verified(outpost_built>0)才收。"
---

# R²v2：construction latch 訂正（接受你抓的威脅悶死洞）

你 R² HIGH **全對，good catch 接受**（審憲抓真安全洞非吹毛）。訂正如下（spec 同檔 `2026-07-25-construction-commitment-latch-A1-fix.md` 已更新）。

## 接受①：憲法論證引錯 gate（親查確認你對）
我原寫「威脅走 stuck/crisis」**錯**：`_decision_crisis`(1868) 只管人口崩潰/糧食流崩、`_is_stuck`(92) 管路徑卡，**都非威脅 gate**。真威脅路 = `:401-423` busy-preemptible（`TASK_BUILD∈PREEMPTIBLE`，`threat_react≥threat_threshold+PREEMPT_MARGIN(2.0)` → reset timer:422 → `_decide_unified`:423），**靠走 cadence 分支生效**。

## 接受②：latch 悶死威脅 = 真安全洞
latch 放 cadence 前無差別擋 → 威脅 force reeval 被悶 → 施工隊被逼近仍不逃、可能被殲（比 A1 更重）。

## 訂正：force 參數繞
- `_decide_unified(state, team, force_reeval:=false)` + `_should_reeval(state, team, force_reeval:=false)`；`_should_reeval` 開頭 `if force_reeval: return true`（繞 latch+cadence）。
- **威脅段 `:423` → `_decide_unified(state, team, true)`**（force 繞，施工隊能逃）。其他呼叫（1463/1485/1488/1920）預設 false → latch 對例行生效。
- latch（`current_task==TASK_BUILD → return false`）**只擋純例行 cadence**。
- 憲法論證訂正：該打斷四路各走各 gate（**威脅→force 繞** / 深餓→crisis edge / 命令→directive / 卡→stuck），latch 只擋例行經濟 argmax。
- ★實作細節（哪些 `_decide_unified` 傳 force、unified:1523 vs solo:1923 穿透）交 implementer；**硬約束：威脅 force 路徑必繞 latch，純例行 cadence 被擋**。

## TDD 補（你要求）
- **★威脅繞 latch 測**：施工中 + `threat_react≥threat_threshold+PREEMPT_MARGIN` → `:401-423` force reeval → 繞 latch 能逃（非悶住）。
- 明標**與深餓測兩回事**（深餓走 `_decision_crisis`、威脅走 `:401-423`）→ 分開測，測深餓不替代測威脅。

## ★reviewer focus（refute）
1. force 參數繞法真解威脅悶死否（:423 傳 true 繞、施工隊能逃）？
2. 憲法論證訂正後四路例外對應對否？
3. latch 只擋例行 cadence 語意夠否——**有無別的「該打斷但靠 cadence 分支生效」路也被誤悶**（如你揪威脅那樣，還有沒有第二個同型洞）？

**CLEAN → dispatch implementer → execution-verified（outpost_built>0）才收。** 有洞 → 回 `to:systems`。
