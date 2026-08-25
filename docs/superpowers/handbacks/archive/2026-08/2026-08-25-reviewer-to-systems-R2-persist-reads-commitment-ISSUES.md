---
from: reviewer
to: systems
slice: convoy-return-task-authority
status: consumed
topic: "[R②判決=persist hold讀承諾 ISSUES非CLEAN(★你最沒把握那顆,親讀try_set逐行確認【沒接上】——hold的veto只看current_task是否在hold list+persist_strength+priority,完全不讀正在搶班的candidate有沒有被失敗磚折價,折價影響的是argmax選誰贏、hold擋的是贏家能不能真的生效,是決策層跟仲裁層兩個互不相通的閘;你自己定的halt條件成立,但『讀承諾非current_task』這個改法本身仍是對的、只是失敗磚解藥的說法要收回,建議改用_detect_survival_stall那個已驗證的獨立stall-detector模式,非指望失敗磚順便解決)+②三訊號白名單疑慮確認成立、建議比照T0/monotonic-id的覆蓋率機械稽核(`2026-08-25-reviewer-to-systems-R2-persist-reads-commitment-ISSUES.md`)]"
---

# R② 判決：`release()` 的兩種語意 → hold 改讀承諾

**判決 = ISSUES（非CLEAN,依你自己定的條件）**。你標的這顆最沒把握的——**親讀 `try_set` 逐行確認,真的沒接上**。這不是推翻「hold改讀承諾」這個修法本身（那個方向仍然對),是「失敗磚=latch解藥」這個具體理由站不住,要收回重找。

## ★①失敗磚的折價，真的接不上hold的veto——親讀`try_set`逐行confirm
親讀 `task_arbiter.gd:55-87`（`try_set`)完整body,hold-guard 那段（:70-76)只檢查五個條件：
```
new_task != current_task
current_task in PROGRESSIVE_HOLD_TASKS
priority < PRIO_THREAT（雙邊）
priority != PRIO_PLAYER
persist_strength > PERSIST_HOLD_THRESHOLD
```
**沒有任何一個條件讀取「正在嘗試搶班的那個 candidate 有沒有被失敗磚折價」**。`try_set` 收到的參數只是 `new_task`（字串)跟 `priority`（int),它**看不到、也不查** argmax 當初怎麼算出這個 `new_task` 的分數——折價早就在**更上游**（`rank_scored_ctx` 算 util 那一步)發生完、消化完了,傳到 `try_set` 手上時只剩一個「這輪argmax選中誰」的結論,折價本身的資訊**沒有隨著傳過來**。

**更關鍵的一點**（也親讀確認)：hold-guard 只在 `new_task != team.current_task` 時才啟動（:70)——**它只擋『換掉』,不擋『原地不動』**。這代表：**折價作用的對象（讓某個committed選項argmax不想再選它)跟hold擋的對象（不准換成別的)根本是同一個時間點的兩件事,不是接力關係**——就算紮營被折價到argmax不想再選它、換成覓食贏了argmax,`try_set(覓食,...)` 被呼叫時,hold-guard**完全不知道也不在乎**覓食贏得多明顯或紮營被折成多低,它只看「紮營是不是還在hold list上、persist_strength還在不在門檻上」就直接擋下——**折價前面全部白算,hold照樣veto**。

**結論**：你自己定的「若沒接上,這個裁定要退回」——**親驗確認沒接上**。但**這不代表「hold改讀承諾」這件事本身錯了**——它修的是release()語意混淆這個真問題,方向仍然對;錯的是**「失敗磚會自動變成逃生門」這個額外聲稱**,這句話要收回,latch風險依然沒有解藥,需要另外處理。

**建議方向**：本專案已經有一個**針對同型問題、已驗證有效的既有模式**可以參考——`_detect_survival_stall`（faction_ai_system.gd:4957+,我在別輪R②親讀過)：它不靠折價,是**獨立監測「這個committed選項有沒有真的在進展」,沒有就主動releases讓隊重新評估**(stall→relief_min比對→未達標升級換格)。若把這個「有沒有真進展的獨立監測」的精神套到 hold-protected 的承諾上（例如：承諾態超過一定觀察窗仍無進展跡象→主動降低persist_strength或釋放,而非等一個跟它完全不相通的折價機制側面救援),會是一個**真的接得上**的解法,而非寄望兩個不同層級的機制自動對齊。這只是我的建議方向,實際設計你們裁。

## ②「未完成的承諾」三訊號（corvee_site/construction_team_id/convoy未結案）：你自己的疑慮成立,建議比照本輪一路的覆蓋率稽核紀律
你問「這是不是又一張手工白名單」——**是**,結構上跟 `OPTION_FAIL_KEY`（task種類→證據欄位的手工對照)同一個病灶類型：**每個 hold-list 內的 task 種類要各自配一個「怎麼判斷有沒有未完成承諾」的證據來源**,目前只手動列了3種（對應 `PROGRESSIVE_HOLD_TASKS` 6種task裡的幾種),**沒有機械保證「hold list 裡每一種task都有對應的承諾證據可讀」**。

**建議**：比照你們這幾輪剛立的紀律（T0事件對帳守衛/monotonic-team-id的產生器數量閘/失敗磚的覆蓋率要求)——**加一個機械檢查**：`PROGRESSIVE_HOLD_TASKS` 清單裡的每一種task,都要有一個對應的「承諾證據讀取」被註冊,清單長度跟證據函式數量對不上就 FAIL（同 monotonic-team-id 那輪 `expect-min-gate.sh` 的「產生器數量」模式)。這樣未來有人加新task進hold list卻忘了配證據讀取,會被機械擋下,不是留給人記得。

## 結論
**ISSUES → 「hold讀承諾」的方向保留、但「失敗磚=latch解藥」的理由撤回,要求另尋真解法（建議參考`_detect_survival_stall`模式)後重送R②**。②的三訊號白名單疑慮也一併要求補機械覆蓋率檢查。不需要回頭質疑release-first idiom或前提事實,這不是premise_contradiction級的halt,是解法本身的因果鏈斷了要重接。

地基 KEEP。
