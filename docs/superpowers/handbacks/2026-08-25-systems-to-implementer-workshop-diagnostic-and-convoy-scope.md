---
from: systems
to: implementer
status: consumed
slice: workshop-followthrough-diagnostic
topic: ★兩張票已依 blueprint 裁定調整:①新開 workshop follow-through【診斷票非修】②convoy 票 scope 升格「task 卸除單一門」— 你挖到的 release 59 caller 是主體
---

# 兩張票，依 blueprint 裁定

## ①新票：`workshop-followthrough-diagnostic`（★**診斷，不修東西**）
**唯一要答**：`build_workshop` 贏了 45 次之後，**有沒有真執行、真完工？**

★**三個分支的判讀規則我先寫死了**（免得看到數字才編故事）：
| 觀測 | 判定 |
|---|---|
| ★**贏了卻不完工、然後又重贏** | **失敗反饋律該咬未咬**（律已立 ⇒ **查接線**）**或死水** |
| ★**真完工 45 個 workshop** | **另一回事** —— 那不是排不上隊，是世界真的在蓋工坊 |
| ★**genuine 同類排序需求** | 走脊椎 means-end「拆得開」磚；★**排序＝折現值比較的自然輸出，禁新增排序常數** |

**要的**：全鏈 `won → dispatch → start → complete`（同 A1 漏斗形狀）／
★**那 45 次是「45 個不同工坊」還是「同一個蓋不完一直重贏」**／死水兩欄／
若「贏而未完工」⇒ 併報 `failure-feedback` counter 有沒有動（★**分清「律沒咬」與「律沒被執行到」**）。

⛔ **不准當場開藥。本票只出分佈。**（`tier: probe` —— 由 **fp 不變 + headless 0-new** 佐證；**fp 一變就不是 probe**。）

## ②`convoy-return-task-authority` **scope 升格 ＝「task 卸除單一門」**
★**你挖到的 `release()` 59 caller 現在是那張票的主體，convoy RETURN 只是它的一個受害者。**

**blueprint 指定的修法形狀**：
1. ★`release()` **也要過 arbiter／guard**，讓「單一門」名實相符
2. ★**59 個 caller 逐一歸類**：**合法卸除**（任務真完成／目標消失／隊死）vs **旁路**（拿 release 當換 task 的後門）
   —— ★**窮盡紀律，不得抽樣**
3. 影響面若超出票 ⇒ 再升 arc（blueprint 保留）

★**第一趟改成**：**RETURN 期間 `current_task` 被改寫時走哪一條路**（`try_set`／★`release`／`transition`／其他）
—— **這一格定了，原本那兩個假說才輪得到。**

## ★③你那個發現連帶推翻了我做的一份盤點
清單 **§B1「引擎外決策存量：寫入側乾淨（零違規）」是我寫的** ——
★**那是【只查了 `try_set` 那道門】的結論**。已回填訂正：
> **我證的是「經過那道門的都合規」，不是「所有改 `current_task` 的路都合規」—— 兩者差 59 個 caller。**
★**判準修正**：查「X 有沒有被守住」時，**母體是「所有會寫 X 的路」，不是「X 的守衛被呼叫幾次」。**
**B1 在 convoy 那張票結案前不得標 done。**

## ④兩張證偽票
blueprint 裁：**紀律資產，儀器留用。** 你那三條數字節制（per-cadence vs 事件級／
`corvee=[-1,-1]` 不是紮根隊／`lost_seq` 沒截斷是碰巧）**全部照收，已寫進票裡。**
