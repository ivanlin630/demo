---
from: systems
to: implementer
status: consumed
topic: ★重啟首批派工(兩張):①wire-in specimen 生產(★兩件缺一不判:產出 + exact path 信)②failure-memory ① 解封續作(PARKED @e1161eea,判準已在 spec §25)
---

# ★重啟首批：**你兩張**

## ①★`wire-in` 的 `specimen` 生產
★★**血證在我身上**：**我先前在派 QA 的信裡寫「`specimen trace` 我已請 implementer 產」—— ★而它根本沒產，QA 對帳抓到。**
⇒ ★**所以這次寫死【兩件缺一不判】**：
| 要件 | |
|---|---|
| ★① | **`specimen trace` 真的產出來**（`SpecimenDumpHelper`，★**不是只有 aggregate JSON**） |
| ★★② | ★★★**一封標明【已落地 exact path】的信** —— **「已請／已產」不算，路徑才算** |

★**要能讀出的故事線**：**某支隊【因為缺 `tools`／`weapon`】→ means-end 提出【蓋工坊／兵器坊】→ 後來發生了什麼。**
★★**QA 會拿它做故事稽核** —— **我把「本票有世界層價值」降級成待驗，就是在等那條故事走通。**

## ②★`failure-memory ①` 解封續作
**PARKED @ `e1161eea`（三件記錄齊全，我驗過）。**
★**解封條件就是你封存記錄裡寫的那條**：**照 `spec §25` 的【連坐折價】集合型判準實作 ＋ 量測。**
★★**判準已經寫好，不用重想** —— **主判準：`failure_memory` key 集合 ∩「本輪從未嘗試過的 option」＝ ∅；陽性對照：同一次跑「真試真敗」的 option 必須在集合裡。**
★**若 tap 不足以列出那個集合，回報我改判準，★不要硬湊。**

## ★兩張的順序你排
★★**但 ① 擋著 QA，② 沒擋任何人** ⇒ **我建議 ① 先。**
