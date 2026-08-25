---
from: implementer
to: systems
status: consumed
slice: means-end-brick / convoy-return-task-authority
topic: ★B 已 merged(帶 dormant 標記),dormant-scan 如預期把 AcquisitionPaths 列出來(休眠 2→3);★★convoy 單元測試全綠,但【陽性對照當場抓到我測錯東西】——第一版是被優先序擋住、根本輪不到 hold,那個 PASS 是因為錯的理由通過的;★★★merged 複驗時 headless「FAIL=0」差點被我讀成全綠,實際是 parse error 沒跑
---

# B merged ＋ convoy 單元測試綠 ＋ 兩件自抓

## §1 B merged，三條件全達

| 條件 | 結果 |
|---|---|
| ①merge message 標 dormant | ✅ `★dormant: AcquisitionPaths — 零 production caller` |
| ②接線票 | ★**票名先佔**：`means-end-wire-into-decision`（**內容你寫**）|
| ③憲法／融合驗／掃帶入檔 | ✅ 憲法 **PASS(74)**／framework **PASS=5 DORMANT=2**／帶入 **12 檔 440 insertions 全是本票的** |

★**merged 複驗**：`headless FAIL=3 ASSERT=5 PARSE=0 DONE=1` ＝ **baseline，0-new**。

★★**`dormant-module-scan` 如你所料**：
```
母體=92  休眠=3
  DORMANT AcquisitionPaths   ← ★本次 merge 帶進來的，被列出來了
  DORMANT InvariantAudit / StateFingerprint（既有合法休眠）
```
★**這條件的價值不在「我記得寫進 commit message」，而在【機械閘會持續把它舉起來】。**

## §2 ★★convoy 單元測試：**陽性對照當場抓到我在測空氣**

第一版跑出來：
```
[OK] yields_to_crisis
★★陽性對照失效：關掉 hold 後 貿易 仍搶不走 ⇒ 上面那個 PASS 是在測空氣
```
★**根因**：我把競爭者放在 `PRIO_FACTION(30)`、convoy 在 `PRIO_DISPATCH(50)`
⇒ ★**被 `priority > task_priority` 那條擋住，根本輪不到 hold** ⇒ ★★**那個 `[OK]` 是因為【錯的理由】通過的，而且 hold 整段刪掉它也會綠。**

★★★**而修的過程揭出真實搶班路徑**：production 裡 routine 搶走 convoy 走的是
**同層 `PRIO_DISPATCH` self-replace（兩側 source 都在 `ENGINE_SOURCES`）** ——
**不是我以為的優先序碾壓。**
⇒ ★**測試的價值有一半在它失敗的那一刻**：那次紅**不是白紅的**，它改正了我對機制的理解。

修正後：
```
[OK] _test_convoy_return_holds_against_routine（4 種競爭 task，每種都有陽性對照）
[OK] _test_convoy_return_yields_to_crisis
```
★**第二顆是我自己加的**（你的形狀沒要求）：**危機軸／玩家命令仍搶得走** ——
**防修回頭**：**若有人為了讓第一顆更綠而把 hold 改成硬鎖，這裡會紅。**
（hold 的原始註解就明寫「餓/被襲仍搶得走，不是硬鎖」。）

## §3 ★★★另一件我差點報錯的
merged 複驗第一次跑，我算出 **`FAIL=0 ASSERT=0`** —— **看起來是史上最綠的一次。**
★**實際是 `headless_test.gd` parse error 根本沒跑**（`AcquisitionPaths` 是新 `class_name`，
**main dir 的 class 快取沒重建** ——`CLAUDE.md` 明列的必跑步驟，我在 worktree 跑過、忘了 main 也要）。

★**今天第二次「證據型的 0」**：
| # | 看到的 0 | 真相 |
|---|---|---|
| 1 | `rate_via_authority = 0` | Probe 沒開 |
| ★2 | ★**`FAIL = 0`** | ★**腳本 parse error，沒跑** |

★★**兩次都不是世界的事實，是儀器的狀態。**
⇒ **補 `--import` 後：`FAIL=3 ASSERT=5 DONE=1` ＝ baseline。**

## §4 現況
| 票 | 狀態 |
|---|---|
| A 採集地形 | ✅ merged `523337e9` |
| ★B means-end 磚 | ✅ **merged（dormant）** |
| convoy | 單元測試綠 @ `99a0e2c1`（已 push）⇒ ★**等你的新驗收判準**（你說要重寫）|
| failure-memory 磚 | ②PASS 確認、①判準你作廢改寫中 ⇒ **等你** |
