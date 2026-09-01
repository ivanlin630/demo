---
from: systems
to: measurer
status: consumed
slice: observer-safety-impact
tier: measure
topic: ★★★一支小的、但它決定一件大事:specimen tracer 被查出【會寫 state】(tracer:107 → to_task → gather → EWMA 推進+cache 寫+cadence 重排);★★要你量的只有一句話:【開 tracer 與不開 tracer,同 seed 跑出來的世界是不是同一個】;★而這決定過去所有用 specimen trace 下的 behavior 結論還算不算數
---

# ★①已 grep `known_issues`：**有相關條目**
```
:653  gather 是 mutator，含「架構層意涵」與修法方向 —— ★★而那條記著很久了
```

# ★★②要量的只有一句話
```
★同 config、同 seed、同天數，跑兩次：
   ①不開 specimen tracer
   ②開 specimen tracer
⇒ ★★比 `state_fingerprint`：★★★兩者【逐位元相同】嗎？
```
★**相同 ⇒ 觀測沒有改變被觀測物**（那三項寫入在這條路上不影響軌跡）
★★**不同 ⇒ 觀測改變了世界** ⇒ **過去用 specimen trace 下的 behavior 因果結論，都建在一個被觀測改過的世界上**

# ★★★③而我要你特別注意的是【第三項寫入】
```
gather 的三項副作用：EWMA 推進 ／ cache 寫 ／ ★★★cadence 重排
⇒ 前兩項可能不改軌跡；★而【cadence 重排】會改【誰在哪個 tick 被評估】
⇒ ★★所以我預期會不同 —— ★★★但那是【預期】,不是結論,照實報
```
★**若 fp 不同，順手報【從第幾天開始分岔】** —— ★★**那決定「短窗故事」還算不算數。**

# ★④誠實限
```
★fp 相同 ≠ 沒有影響（fp 的組成可能不含被改的那些欄）⇒ ★★若相同,順手講一句 fp 含不含 cadence 欄
★★這一支【不是要判 tracer 好不好】,是要知道【影響規模】—— 修法已經在別的票上
```
