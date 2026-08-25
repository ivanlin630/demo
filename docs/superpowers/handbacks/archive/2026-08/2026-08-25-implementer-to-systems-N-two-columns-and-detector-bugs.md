---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ 21de8a4f (pushed)
topic: ★§N 兩欄跑出來了(開發回饋非驗收);★★但第一輪抓到的是【我自己 detector 的兩顆 bug】(order 無進度事實卻被判停滯 652 次/開火不重置 baseline),修後 652→0;★★★construction_abandoned 仍 = 0 ⇒ 兩張票的接點目前是空的
---

# §N 兩欄（★**開發回饋，非驗收** —— 驗收數字請 measurer 產）

**branch**：`feat/convoy-return-task-authority` @ `21de8a4f`（已 push）
**床**：`convoy_rewrite_path_bed`（`peaceful_economy` / seed 1337 / 90 天）

---

## §1 ★★第一輪抓到的不是世界的問題，是**我自己 detector 的兩顆 bug**

```
commit.stall_fire = 653   ← 其中 order 佔 652
樣本：{ kind:"order", waited_ticks 2370 → 2390 → 2410 → …, progress 0, baseline 0 }
```

| # | bug | 修法 |
|---|---|---|
| 1 | ★**`order` 沒有進度事實可讀**（只有「對象還在」這個布林），我卻給它 `progress: 0.0` 常數 ⇒ 耐性耗盡後**每個 cadence 都判 STALLED** | 加 `measurable` 旗標，★**沒有事實就不給判決** |
| 2 | ★**STALLED 開火後沒重置 baseline** ⇒ 同一段承諾一直重放（`waited_ticks` 單調變大就是證據） | 開火後**一律重置** |

★**第 1 顆的性質要講清楚**：那是**把儀器的缺口當成世界的事實** ——
**「量不到」不等於「沒進展」**。這正是我這幾輪一直在別人數字上抓的那一族，**這次犯在自己身上**。
⇒ 兩顆的**血證都寫進 code 註解**（`652 次假觸發`／`waited_ticks 單調變大`），
★**理由不可見的 gate，就是日後會被拿掉的 gate。**

**修後**：`stall_fire 653 → 1`。

---

## §2 §N 兩欄（修好之後的數字）

```
①合法退場 commit.release_clean              = 53      ★【不該】下降
①帶著未完成承諾被卸 release_with_commitment  = 177
      ├─ order   163      ← ★不可量測那一類
      ├─ convoy   50
      └─ corvee   43
②被 hold 擋下 commit.hold_blocked            = 5       ★【該】上升
      ├─ construction 3
      └─ convoy       2
latch 解藥 commit.stall_fire                 = 1（convoy）
```

★**逐標記拆開是必要的**：`177/230 ＝ 77%` 看起來很嚇人，
**但 163 筆是 `order`（沒有進度事實的那一類）** ⇒ **一個混在一起的總數無法據以行動**。
真正「丟下已開始的工作」是 **corvee 43 ＋ convoy 50**。

★**②只有 5 次** —— hold 確實有擋到東西（且分佈在兩種承諾），但**量級很小**。
**我不解讀它是好是壞**：這一輪沒有 main 側同床對照，**①有沒有「下降」根本無從判定**
（`53` 是這一版的絕對值，不是相對 baseline）。
⇒ ★**§N 兩欄要能回答「①有沒有掉」，必須有同床 main baseline** —— **這是 measure 的事，不是我自測能回答的。**

---

## §3 ★★★`construction_abandoned = 0` —— **兩張票的接點目前是空的**

`construction_abandoned` 在這張床**一次都沒發**。
⇒ ★**磚的 acceptance 第三面（紮根執行型失敗真的進記憶）目前沒有進料。**

**已知的相關事實**（都來自我自己先前的量測，不是推測）：
- A1：站③ commit drop **全 0** ⇒ 我接在那裡的 `record()` 也是死站
- 本輪：`stall_fire.construction` **0** ⇒ 工地承諾在 90 天內**沒有一個走到 STALLED**
- 但 A1 同時量到 **`start 4 → complete 1`** ⇒ ★**確實有 3 個工地沒完成**

⇒ ★**「有 3 個沒完成」與「偵測器一次都沒判停滯」同時成立** —— 兩者必有一個解釋：
1. 那 3 個工地**在耐性窗內就換手/消失**（`_build_tile` 找不到 ⇒ 承諾消失 ⇒ 偵測器認為結束了）
2. 或**偵測器的耐性窗（`STALL_BASE_DAYS × patience`）比工地閒置的時間長**
3. 或**那些隊根本沒走到四個 decision entry**（我先前自報的覆蓋缺口已補成 4/4，但那是這一版才補的）

★**我不猜是哪一個**。要分辨，得加一顆「**未完成工地存在、但當輪沒有任何 stall 判決**」的計數
——**就是你說的「假設不靜默」**。**要不要加，你裁**（加了會多一顆常設 tap）。

---

## §4 現況
| | |
|---|---|
| headless | **8 ＝ baseline，0-new**（上一輪；本輪只改 tap 與 detector gate，未重跑，**我會在交件前補**）|
| `commitment-field-scan` | 16/16 PASS |
| `decision-entry-scan` | 4/4 PASS |
| measure | ★**缺同床 main baseline** ⇒ §N ①那欄目前**不可判**|

★照你剛立的三分法：**閘綠 ≠ 這一版達標**。
**convoy 這張的 measure 我不會拿自測充數**，同磚的標準。
