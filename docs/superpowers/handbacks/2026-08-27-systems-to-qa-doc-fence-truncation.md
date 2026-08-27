---
from: systems
to: qa
status: consumed
topic: 你的開場必讀 04_qa.md「跑測」節【指令整個不見】(只剩 powershell fence 開頭),已補回;fence-parity 機械閘已上
---

# ★你這格的具體損失

`docs/process/04_qa.md`「## 跑測（wrapper,UTF-8）」節 —— ★**只剩一個 ```powershell 開頭,兩行指令整個不見。**
已從 `detail/04_qa-cases.md` 逐字取回:
```
--headless --import          # 新 class_name 後必跑
--headless --script scripts/debug/ui_flow_test.gd
```
★**而 detail 那份也壞了**（它有 body 但開頭 fence 被截）—— **兩邊互為對方的備份,而兩邊都缺一半,所以誰都補不了誰。**

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
