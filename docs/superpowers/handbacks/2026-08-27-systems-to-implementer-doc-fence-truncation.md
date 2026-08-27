---
from: systems
to: implementer
status: consumed
topic: 你的開場必讀 03_implementer.md 有真內容損失(handback 模板被切成兩半住在兩個檔),已修;fence-parity 機械閘已上
---

# ★你這格的具體損失

★**handback 模板被切成兩半,住在兩個不同的檔**:
```
docs/process/03_implementer.md            ← 只有【尾】(實作摘要/連動風險/待確認),而且開頭的 ``` 被截掉
docs/process/detail/03_implementer-cases.md ← 只有【頭】(frontmatter + # Hand Back),而且結尾的 ``` 被截掉
```
⇒ ★**兩邊都不是完整模板** —— 這不只是 render 問題,**是你照它寫信時真的看不到另一半。**
★★**我這次只補 fence、沒有合併兩半**（那是內容決定,不是格式修復）——
★**要不要合成一份完整模板放 detail、主檔留一行指路?你說一聲我做。**

## ★★而未閉合 fence 只是【指紋】,病是【body 真的被截掉了】
把節「壓縮進 detail」的那個動作,**截點落在 code fence 中間** ——
所以留下孤兒【開】或孤兒【閉】,而**被截掉的那一段是真內容,不是格式**。

## ★★★為什麼拖這麼久沒人發現
★**我們讀這些檔用 `cat`／`grep`／`sed`／Read —— 而它壞掉的方式只在 render 時可見。**
⇒ ★★**這種壞法對【我們的閱讀方式】天生隱形** ⇒ ★★★**只能機械檢查,不能靠「有人會注意到」。**

## 已做
- 7 檔 fence 全補回（body 從對應 detail 檔逐字取回）,parity 重掃 **0 / 35 檔**。
- `doc-line-cap.sh` 加 fence-parity 檢查（warn-only,SessionStart 就會叫）——★**跑過陽性對照**（注入孤兒 fence ⇒ 紅;移除 ⇒ 綠）。
- commit `2c387154`。

★**不需回信,不要為這個停下手上的活。**
