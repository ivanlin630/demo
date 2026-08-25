---
from: systems
to: implementer
status: open
slice: convoy-return-task-authority
topic: ★判決:測試面 ACCEPT(我親讀 99a0e2c1 逐條對裁定);★★★你多做了兩件我沒交代的,其中一件是「防修回頭」的成對判準,你自己從 failure-memory 遷移過來;★票仍未落地=缺 porcelain 空 + merge
---

# 判決：**測試面 ACCEPT** —— ★**我親讀 `99a0e2c1`，逐條對過我的裁定**

| 我裁的 | 你做的 |
|---|---|
| fixture ＝ convoy 在 `RETURN` ＋ 有競爭 task | ✓ |
| 斷言 `task` 仍是運輸 | ✓ |
| ★`n` 由你決定，**列舉**競爭 task 種類 | ✓ **4 種逐一列舉（非抽樣）＋ 覆蓋斷言 `held == size and control == size`** |
| ★★★**陽性對照：關掉 hold 必須真的被 preempt** | ✓ **每一例都配** |

## ★★★你多做的兩件，我要點名
### ①**成對判準 —— 我只交代了第一條**
`_test_convoy_return_yields_to_crisis`（**危機／玩家仍搶得走 ⇒ hold 不是硬鎖**），你寫的理由是：
> **「這條是防修回頭：若有人為了讓上面那個測試更綠而把 hold 改成無條件，這裡會紅。」**

★★**那正是 `failure-memory §11` 那組「兩面成對」的思路** —— ★★★**你自己遷移過來的，我沒交代。**
★**而它擋的正是我今天在別處反覆擋的那件事：把一面弄綠、代價是另一面全塌。**

### ②★**真實搶班路徑的機制理解**
你寫明：**真正的搶班是 `priority == task_priority` 且兩側 source 都在 `ENGINE_SOURCES` 的 self-replace 支**，
**而不是 `priority > task_priority`（routine 不會帶更高優先序）。**
★★**並把第一版 fixture 的血證留在註解裡**（`PRIO_FACTION(30)` vs convoy `50` ⇒ **被優先序擋住、根本輪不到 hold** ⇒ **那個 PASS 是因為錯的理由**）。
⇒ ★**那不是猜出來的，是查出來的** —— **而且你把「怎麼查錯的」也留給下一個人。**

## ★★但票【仍未落地】—— 三件齊只過一件
| 條件 | 狀態 |
|---|---|
| ★**判決信 consumed** | ★**本信即判決（測試面）** |
| ★**`porcelain` 空** | ✗ **2 個檔懸著，含 `scripts/simulation/faction_ai_system.gd`（production）** |
| **branch merged 進 main** | ✗ **領先 7 個 commit** |

⇒ ★★**HOLD 的排空清單定稿三張，`convoy` 是其中一張** —— **它卡在【那兩個未 commit 檔】。**
★**warring 跑完後，這張只差把那兩個檔處理掉 ＋ merge。**

## ★我還沒判的
★★**production 那條（`feat/detector`／`feat/arbiter` 那幾顆 commit）我沒讀** ——
**測試面 ACCEPT ≠ 整票 ACCEPT。** ★**merge 前我會讀 diff，或走 reviewer。**
