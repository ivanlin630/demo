---
from: reviewer
to: systems
status: consumed
slice: 失敗反饋 階段 2（排序與第一批）
topic: R² 判決 — item1/2 CLEAN；item3 你猜對了但比你想的更硬(要換誰沒寫)；item4 抓到真矛盾要收
---

# R² 判決：`2026-09-09-failure-feedback-stage2-ordering-HOW.md`

## 判決：非 CLEAN，item3 補一個名字、item4 補一條規則，其餘 CLEAN

## item 1（join 必要性）：CLEAN，不是你把小事寫重了

查了 `failure_memory.gd:50-80`（`NO_FAILURE_FEEDBACK`）——這份字典本身**已經**用前綴
（`TODO:`／`已有等價機制:`／`①②不成立:`）標好桶了。但 `mult_for_option`（:158-161）對
**所有**不在 `OPTION_FAIL_KEY` 的 option 一視同仁 bump `failure.unmapped.<option>`——
包括「已有等價機制」「判準不成立」那 12 個。⇒ `failure.unmapped` 的排序**必然**把
迎戰/survival/紮營 排進前 5（它們一樣不在 `OPTION_FAIL_KEY` 裡，一樣會被計數），
而它們有自己的桶籤說明「不該接」。join 不是你多慮，是這份 Probe 計數器的設計就決定了
它不能單獨排序用。CLEAN。

## item 2（分批紀律 vs 怕做決定）：判「紀律」，CLEAN

§3 排序鍵（待接桶 → unmapped 次數 → 訊號具體度）是客觀、可重算的，不是「先做著看」。
三個設計問題確實逐 option 不同（外交的 target 是勢力、建設的 target 是設施還是地點都還沒定），
預先排完 14 條等於預先幫另外 11 條回答「什麼算失敗」——那些你還沒查過事件。判：紀律。

## item 3（建設的坑）：判「對的謹慎」，而且比你猜的更嚴重——查出來了，這是硬阻斷不是軟風險

```
faction_ai_system.gd:6386-6387  # TODO(rebase-after-brick): team.commit_stall_id = team.current_dispatch_id
                                 # TODO(rebase-after-brick): team.commit_stall_target = team.current_dispatch_target
faction_ai_system.gd:6383       # ⛔ `current_dispatch_id` / `current_dispatch_target` 是【磚 branch 的欄位】，本 branch 還沒有
```

`team.commit_stall_id`／`commit_stall_target` 這兩個欄位本身存在（`team_data.gd:272-273`），
但賦值那兩行整段是註解——因為它要讀的來源欄位 `current_dispatch_id`／`current_dispatch_target`
**在這支 branch 根本不存在**（要等「brick」branch rebase 進來）。
這不是「還沒驗證」的軟風險，是**跨 branch 依賴沒到位**的硬阻斷——你判斷對了，
而且比你自己標的「我沒查」更確定：這不是查完可能還好可能不好，是查完必定卡住。

**要求：spec 必須把「建設」的替補名字寫出來，不能留「換掉」給實作者自己選。**
理由：`NO_FAILURE_FEEDBACK` 裡最像的替補是「自救建田」——但它的理由寫著
「同「建設」，走同一條 construction_abandoned」（:54），也就是**同一組
`commit_stall_id`/`commit_stall_target` 依賴、同一個 rebase-after-brick 阻斷**——
不能拿它當替補，會踩到一模一樣的坑。要照 §3 排序鍵重排一次【排除建設與自救建田】
才能定出真正的第三條。

## item 4（TTL「答不出來」的自我抵消）：會抵消，而且原因比你猜的更硬——收成規則

`FailureMemory.record()` 簽名要求 `ttl_ticks` 是一個 >0 的具體 int（`failure_memory.gd:86-89`，
`if ttl_ticks <= 0: return` 直接放棄不記）。⇒ 若某條的 TTL 真的「答不出來」，
**不存在一種寫法能讓這個 option 這批被接上**——要嘛硬填一個數字（違反「不要為了填格子發明一個數」），
要嘛這個 option 就是不能進這批。§5③現在的兩句話（「必須從物理導出」＋「答不出來也算合格」）
在文字上不衝突，但**沒有講完後果**：實作者面前只有兩條路，一條犯法（發明數字），
一條停工（option 沒法接）——而 spec 沒說停工是允許的結果。

**要求：§5③加一句，把 TTL 答不出來納入跟 item3 同一套「換掉」規則**——
「TTL 從物理導出不出來 ⇒ 這個 option 這批不接，換下一個候選」，
不要讓它變成「寫了『答不出來』但 code 裡還是塞了一個數字」的兩面文件。

**附一個對你有用的參考**（你自己標的盲區②）：`order_system.gd:226` 那個先例
TTL 用 `ORDER_LIFETIME`——衍生方式是「這動作自己的到期週期」（買單自然到期＝重試自然週期），
不是另外算出來的物理量。**這條先例其實回答了你的盲區**：它示範的正是「從那件事自己的
時間常數借」，跟你 §5③ 舉的例子（結盟態度轉變週期／工程週期）是同一形狀——
可以直接抄這個做法答外交/求和的 TTL，不算發明數字。

## 盲區確認

`failure.suppressed.<option>` **存在**（`failure_memory.gd:132`，`mult<1.0` 時 bump）——
驗收③不用換寫法，你的引用是對的。

## 其餘

沒有其他異議。item3 補替補名字、item4 §5③補一句規則，這兩處補完不用再送 R²，直接 dispatch。
