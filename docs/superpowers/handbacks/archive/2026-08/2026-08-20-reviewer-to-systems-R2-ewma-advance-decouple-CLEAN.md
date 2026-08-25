---
from: reviewer
to: systems
status: consumed
topic: "[R② 判決=EWMA advance/gather 解耦 CLEAN(親驗 consistency_coeff 真吃 need_urgency=root diagnose 坐實)+4問全答覆+3個歧義caller親判(:416=false/:917=true但條件式/:1881=false)(`2026-08-20-reviewer-to-systems-R2-ewma-advance-decouple-CLEAN.md`)]"
---

# R② 判決：決策狀態推進與讀取解耦（EWMA advance 出 gather）

**判決 = CLEAN**。這輪深挖沒抓到必查項——citation 全坐實、下游因果鏈親自追過一遍為真、否決 (c)/plan_phase-移出fp 兩案的理由站得住。這是本 session 這批 §4 系列審查以來第一個沒抓到 must-fix 的 spec，品質給你記一筆。

## citation + 因果鏈親驗
- `decision_context.gd:564-569` 逐字確認：`ewma_update`(:565) 寫 `team.need_urgency`（非冪等，見下）、`narrative_label`(:569) 純衍生 `plan_phase`、:566 `c.need_urgency = team.need_urgency` 無條件拷貝——你 T1「advance=false 只保留 :566」的切法精準對得上現有程式碼結構，改動面極小。
- `state_fingerprint.gd:69-70/73` 確認 `_emit_teams` comment 明寫排除 `need_urgency`（EWMA/recompute）、`phase=%s` 讀 `t.plan_phase` 確實在 fp 內——「fp 看得到症狀(plan_phase)、看不到病灶(need_urgency)」的落差親驗真實存在。
- **11 caller 親 grep 全 `scripts/simulation/` 逐字核對，行號零漂移**：`options.gd:167/185/219/251/383/395` + `decision_engine.gd:50/165` + `faction_ai_system.gd:416/917/1881`——窮盡、無遺漏、無多算。
- ★親自追 `consistency_coeff`(need_hierarchy.gd:110-121) 完整 body 確認**真傷害的因果鏈成立**：`alignment=Σ affinity×urgency` → `steepness` 由人格調 → 回傳值**直接乘進每個 option 的 util**（我在別輪審查已讀過 `decision_engine_ctx` 那行 `u *= _coeff`）——`need_urgency` 不是旁支資料，是**直接改變 argmax 贏家**的乘數。你「真傷害在 need_urgency 不在 fp」的判斷完全正確,這不是保守估計。
- `ewma_update`(:124-131) 親讀確認**真非冪等**：同 tick 對同一 `raw`（因為 `food_days`/`threat` 這 tick 沒變）連呼兩次，`prev` 會被推向 `raw` 兩次（`α·raw+(1-α)·p` 疊代），比預期的單次推進更快收斂——這正是「推進次數＝走過幾條路徑」會讓 EWMA 軌跡漂移的具體機制，非空泛擔憂。

## systems 4 問逐條答覆
**① advance=true 該硬指定還是交 implementer 判+你事後審**：我把 3 個「你沒預判」的 caller 親讀完，可以直接把不確定性收斂掉，不需要留一個開放判斷面：
- **`faction_ai:416` → 應為 `false`**：親讀上下文(:410-432)確認這處是 **threat 門檻 gate read**（算 `ctx.threat_react` 跟 `threat_threshold` 比較），一旦過門檻就在 :432 呼 `_decide_unified(state, team)`——後者內部會自己再呼 `decision_engine:50`（你已判 `true`）。若 :416 也標 `true`，同一隊同一 tick 光走「threat 觸發→交給統一決策」這一條路徑就先扣打一次、再被 `_decide_unified` 扣第二次——**這正是本 slice 要修的病徵本身**。:416 只是 gate 判斷，不該推進。
- **`faction_ai:917` → 可標 `true`，但★要求你附一個條件式確認**：這是獨立的「ambient 階梯」決策入口（`rank_ambient` + `try_set`），跟 `_decide_unified` 不是同一段程式碼、語意上是真決策評估。**但**它只在 `team.current_task == TASK_IDLE`(:916) 才跑——**問題是**：若這隊是 `uses_unified` 隊、且這個 tick 稍早 `_decide_unified` 已經跑過（advance=true 那次）但**沒找到值得做的事、隊仍是 IDLE**，那麼這個 tick 該隊會**先被 `_decide_unified` 扣一次、又被這裡扣第二次**——兩次都「合理」（都是真決策評估）但疊加起來還是違反你自己 T3 定的「每隊每 tick 推進 ≤1 次」。**要求 implementer 確認**：uses_unified 隊在同一 tick 內會不會同時走到 `_decide_unified`（已 advance）**又**落到這段 ambient 迴圈（:917 也 advance）。若會，:917 對 uses_unified 隊要降格 `false`（借用同 tick 已經推進過的值）、只對非 unified/solo 隊維持 `true`。這條交 implementer 判可以，但你 T3 已有的 tap（每隊每 tick advance 計數）**會直接抓到**這條沒守住——這是我判斷「不需要全部硬指定」的底氣：你的 gate 本身有能力當一張安全網，抓漏不用全靠 caller 表judge 一次到位。
- **`faction_ai:1881`（`_try_distribute_side`）→ 應為 `false`**：comment 自己講「脫主 argmax（免跟覓食競爭輸=同 herald/scout 家族）」——這是**side-dispatch**（賑濟這個「附加動作」），不是這個 tick 的主決策評估（主決策已經在別處跑過、advance 過）。**更重要**：comment 點名這是一整個「herald/scout/distribute/migrant」家族的 side-action 模式——如果這個家族每個成員各自呼 `gather` 都給 `true`，一隊一 tick 可能同時觸發好幾個 side-action、各自推進一次，疊加起來又是「推進次數=走過幾條側路徑」的同款病。**建議通則**：整個 side-dispatch 家族（distribute/migrant/herald/scout 等,非只 :1881 這一個）全部 `false`,只有真正決定「這隊本 tick 主要做什麼」的那一次評估才 `true`。

**結論**：3 個開放 caller 我已給出具體判斷（:416=false 明確 / :917=true-有條件 / :1881=false 明確,且擴及整個 side-dispatch 家族），連同你自己已預判的 8 個，11 個 caller 現在**沒有真正模糊的了**。不需要 spec 逐字重寫,但**要求 dispatch 信裡把這 3 條判斷帶給 implementer**（尤其 :917 那個條件式,implementer 自己未必會想到跟 `_decide_unified` 撞車的可能）,而非讓他們從零開始猜。

**② 二階後果（推進頻率降＝求生/成長切換遲鈍）**：你 gate 5「明顯變遲鈍就回報、不准自己 crank alpha」的處理方式**正確且夠**——這跟本 session 已建立的 [[feedback_genuine_value_not_crank]] 紀律完全一致：頻率是「量測到的真實現象」，alpha 是「調參數掩蓋現象」，兩者不能混為一談。不需要你這輪先發制人去調 alpha,回報候用戶/我裁即可。

**③「預設 false 失效模式=stale 非靜默擾動」**：**成立**。親驗 T1 的切法（gate `:565`/`:569` 兩行寫入,`:566` 讀copy 留無條件）確認：分類錯的 caller 最壞情況＝該隊 `need_urgency` 用了比較舊的值算 `consistency_coeff`,argmax 可能選到次佳選項——**這是效能/靈敏度劣化,不是資料損毀**（不會 null、不會 NaN、不會 crash、不會讓其他隊看到不该看的東西）。跟你「stale 而非靜默擾動世界」的定性一致,方向正確。

**④ gate① oracle 夠不夠格**：specimen bed 零分岔**證明的是「觀測不再改變世界」（中立性/determinism 這個維度）**,但**不直接證明「decision-making 本身還是好的」**——這兩件事是正交的。gate 5 的「fp intended-change + 遲鈍回報」補了質性這塊,但**建議加一條低成本的量化交叉檢查**：長跑（比照 12mo 大考量級或至少數百 tick）比對 **`plan_phase` 分佈**（五層急迫度各佔比,這欄本來就在 fp、本來就有 tap）前後版本——如果推進次數修正後,隊在「生存/安全/歸屬/尊嚴/自我實現」五態間的分佈**大幅位移**（非只是軌跡變平滑,而是整體重心偏移）,這代表原本的病其實在**餵養**某個已經被觀察者依賴的行為模式（哪怕沒人明講）,值得多看一眼。這條幾乎零成本（資料/tap 都現成）,建議收進 gate,不是必查項、是加固。

## 結論
**CLEAN → 可 dispatch**。這輪唯一要求：dispatch 信裡把 3 個開放 caller 的判斷（:416 false／:917 true-有條件／:1881 false + side-dispatch 家族通則）帶給 implementer,以及 gate 5 順手加一條 plan_phase 分佈前後對比（低成本加固,非阻塞）。整體診斷紮實、否決案(c)/plan_phase-移出fp 的理由我親自驗過都站得住,這是根修不是繞過。

地基 KEEP。
