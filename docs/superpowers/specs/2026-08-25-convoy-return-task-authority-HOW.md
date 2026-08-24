---
slice: convoy-return-task-authority
tier: full
qa: required
from: systems
topic: ★scope 已升格(blueprint 2026-08-25)=「task 卸除單一門」—— release() 59 caller 旁路所有 guard;convoy RETURN 只是其中一個受害者
---

# convoy RETURN：**task 主導權沒鎖住**

**來源**：QA 故事稽核（`eta-single-model` 那輪）。
**`stranded 3→0` 是 margin 稀釋，不是修好**（見 `05_acceptance` 的 margin 稀釋條）。

## §1 QA 的觀測（故事層，counter 看不到）
逐隻掃 14 個 porter 的 RETURN 期間移動訊號：
**team123（及 86／162 較輕微）連續 20+ 個樣本 `convoy_phase = RETURN` 但 `task ≠ 運輸`、
`move_target` 與 home 完全無關** —— 被**掠奪／紮營／覓食**反覆劫走。
★**與 gate9 那輪抓到的「相鄰不動」不是同一件事**，這個更根本。

## §2 code-read（systems，**file:line 已坐實**，機制假說標待驗）
`task_arbiter.gd:70-75` 的 progressive hold 條件：
```
new_task != team.current_task
  and team.current_task in PROGRESSIVE_HOLD_TASKS     ← ★只看 current_task
  and priority < PRIO_THREAT and team.task_priority < PRIO_THREAT
  and priority != PRIO_PLAYER
  and team.persist_strength > PERSIST_HOLD_THRESHOLD
```
而 `convoy_phase` 存在 **extra-data**（`faction_ai_system.gd:2819/2846` `xd["convoy_phase"]="RETURN"`）
⇒ ★**arbiter 完全不看它。**

### ★★2026-08-25 更新：**先驗 `release()` 路徑，(a)(b) 都往後排**
`camp-construction-duration` 第一趟窮盡列舉 `current_task = ` **＝ 9 處**，發現：
| 路 | 過哪些 guard |
|---|---|
| `try_set` ×4 | combat／crisis／**persist hold**／優先序 |
| ★**`release()` ×1** | ★**一道都不過**（`TaskArbiter.release(` **59 個 caller**） |
| `transition()` ×1 | combat／crisis／emergency，**不過 persist hold** |

★**「持守 floor 守的是 `try_set` 那道門，而離開的隊是從旁邊那扇沒鎖的門走的。」**
⇒ **本票假說 (b)「一次被搶就永久解鎖」建立在「被 `try_set` 搶」的前提上 ——
若 porter 是被 `release()` 放掉的，(b) 根本還沒輪到。**
⇒ ★**第一趟改成：RETURN 期間 `current_task` 被改寫時，是走哪一條路？**
（`try_set` ／ ★`release` ／ `transition` ／ 其他）**這一格分佈定了才談 (a)(b)。**

### 兩個候選機制（**都待驗，且排在 release 路徑分佈之後**）
| # | 假說 | 性質 |
|---|---|---|
| **(a)** | **第一次被搶的原因**：porter 的 `persist_strength` ≤ 門檻 ⇒ **hold 從未生效** | 需量 `persist.hold` 對 porter 的觸發率 |
| **(b)** | **被搶之後為什麼一直被搶**：`current_task` 已非 `TASK_CONVOY` ⇒ **後續永遠不受 hold 保護** | ★**結構上必然**（條件讀 `current_task`）—— **一次成功搶班 ＝ 永久解鎖** |

★★**這是「同一件事有兩份真相」的又一例**：**「我正在送貨回家」** 這個事實
同時存在於 `convoy_phase`（extra-data）與 `current_task`（arbiter 唯一看的），
**兩者會脫鉤** —— 與〈估算器禁手抄物理〉、〈跨代縫〉**同族**（第二份拷貝必 drift）。

## §3 量測（★**開票就指定兩趟法**，見 `04_qa`）
1. **第一趟**：tap 記 **RETURN 期間 `task = 運輸` 的佔比**（★**margin 影響不到的量**）
   ＋ `persist.hold` 對 porter 的觸發率 ＋ **被搶走時的 new_task 分佈**
   ＋ dump **命中「RETURN 期間被搶」的 team id**
2. **第二趟**：同 seed ＋ `SPECIMEN_TEAM_ID=<那幾隊>` ⇒ QA 讀得到被搶當下那幾隊在想什麼

## §4 修法方向（**待分佈，先不定案**）
⛔ **不准**再放寬 margin／調 `RETURN_ABANDON_ETA_MULT`（那正是製造這個假象的東西）。
可能形狀（**不自選**）：讓 arbiter 看得到「convoy 未結案」這個事實（單一真相源），
而不是靠 `current_task` 這個**會被覆寫**的欄位當代理。

## §5 acceptance
★**主指標 ＝ RETURN 期間 `task = 運輸` 的佔比**（margin 轉不動它）。
`stranded` 計數**只當輔助**，★**不得單獨當通過依據**。

---

## §I ★★scope 升格：**「task 卸除單一門」**（blueprint 裁 2026-08-25）

本票原本只管 convoy RETURN。**升格後管的是整個「誰可以把一支隊從它的 task 上卸下來」。**

### 為什麼升格
`camp-construction-duration` 第一趟窮盡列舉 `current_task = ` **＝ 9 處**：
★**`release()` 一道 guard 都不過**，**59 個 caller**。
⇒ ★**convoy RETURN 被劫走只是這個結構的一個受害者，不是獨立的 bug。**
⇒ 且**清單 §B1 的「寫入側乾淨」是只查了 `try_set` 那道門的結論** —— 已回填訂正。

### 修法形狀（blueprint 指定）
1. ★**`release()` 也要過 arbiter／guard —— 讓「單一門」名實相符**
2. ★**59 個 caller 逐一歸類**：**合法卸除**（任務真的完成／目標消失／隊死）
   vs ★**旁路**（拿 release 當「我就是要換 task」的後門）
   —— **窮盡紀律，不得抽樣**
3. **若診斷顯示影響面超出本票 ⇒ 再升 arc**（blueprint 保留）

### ★量測順序（改寫本票第一趟）
**先報「RETURN 期間 `current_task` 被改寫時走哪一條路」的分佈**
（`try_set` ／ ★`release` ／ `transition` ／ 其他）——
**這一格定了，(a)(b) 兩個舊假說才輪得到。**

