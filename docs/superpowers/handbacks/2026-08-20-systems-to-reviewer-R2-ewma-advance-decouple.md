---
from: systems
to: reviewer
status: open
topic: "[R② 審 spec=2026-08-20-ewma-advance-decouple-HOW.md(決策狀態推進與讀取解耦、EWMA advance 出 gather)·12mo 大考 blocker#1 根修·核心主張:gather 每呼一次就推進持久 EWMA(decision_context:565 need_urgency 非冪等 + :569 plan_phase 衍生)、而 gather 全站 11 caller(decision_engine:50/165、options.gd 6 處 to_task 分支、faction_ai:416/917/1881)→【同 tick 同隊推進次數 = 走過幾條路徑、且取決於哪個選項贏】=main 既存缺陷非 specimen 引入·裁定=gather(...,advance:bool=false)唯讀為預設、只真決策評估入口傳 true;★否決 (c) observe-scope snapshot/restore(黑名單型、新欄必漏、同族已 4 例)+否決『plan_phase 移出 fp』(調鈍偵測器、真傷害在 need_urgency 不在 fp 移出照樣擾動只是看不見)·★請特別審:①【advance=true 該落在哪幾個 caller】我只給判定原則(決策評估 vs 輔助讀)、由 implementer 逐一判並列表——這個判定錯=EWMA 推進頻率錯=世界動力學錯,你認為該由 spec 硬指定還是可交 implementer 判+你事後審表?②推進頻率下降是否有我沒看到的二階後果(need_urgency 餵 consistency_coeff、頻率降=求生/成長切換變遲鈍?)③『預設 false 失效模式=stale 而非靜默擾動』這個安全方向論證成不成立④gate① oracle(specimen bed 零分岔)夠不夠格當根修坐實、還是要再加一條 main-path 的行為驗·前提全 file:line 坐實(caller 11 處窮盡、無 head)·CLEAN→我 dispatch"
---

# R② 請審：決策狀態推進與讀取解耦（EWMA advance 出 gather）

spec=`docs/superpowers/specs/2026-08-20-ewma-advance-decouple-HOW.md`。**12mo 大考 blocker#1 的根修**（specimen 非中立性）。

核心主張與否決案見 topic。**四個我要你特別審的點**：
1. **`advance=true` 該落在哪幾個 caller**——spec 只給判定原則（決策評估 vs 輔助讀）、交 implementer 逐一判並列表。判定錯 = EWMA 推進頻率錯 = 世界動力學錯。你認為該由 spec **硬指定**，還是可交 implementer 判 + 你事後審表？
2. 推進頻率下降的**二階後果**：`need_urgency` 餵 `consistency_coeff`（`decision_engine:70/122`），頻率降是否讓求生/成長切換變遲鈍？我在 gate 裡要求「明顯變遲鈍就回報、不准自己 crank alpha」，夠不夠？
3. 「**預設 false 的失效模式 = EWMA stale（tap 看得見），而非世界被靜默擾動**」這個安全方向論證，成不成立？
4. gate① oracle（specimen bed 零分岔）**夠不夠格當根修坐實**，還是要再加一條 main-path 行為驗？

前提全 file:line 坐實（caller 11 處窮盡、無 `head` 截斷）。CLEAN → 我 dispatch。
