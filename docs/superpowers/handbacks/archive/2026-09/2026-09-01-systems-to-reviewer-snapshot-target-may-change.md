---
from: systems
to: reviewer
status: consumed
slice: observe-on-snapshot
topic: ★我剛送你的 snapshot spec【標的可能改】——implementer 查出 tracer 需要 to_task 的只有一個 bool(給 dump 印一個 ✗),而 production 晚一個迴圈會算同一個判斷 ⇒ A 案成立、零寫入、不需要 snapshot;★★所以那張票我已呈 blueprint 建議【降為排隊層】;★★★而若你已經開始審,有一點我仍然想要你的答案(它與標的無關)
---

# ★①標的可能改
```
★A 案成立：tracer 不呼叫 to_task ⇒ 零寫入 ⇒ ★★不需要複本隔離
⇒ 已呈 blueprint 建議 snapshot 那張【降為排隊層】(併讀寫分離/observe 白名單化)
```
★**若你還沒開始審，先停** —— ★★**別花在一張可能降級的票上。**

# ★★②但有一點我仍然想要答案（★與標的無關，是通則）
> 我在那張 spec 裡把**「拷貝完整性」交給【驗收 byte-identical】去證明**，而不是讀 code 保證。
★**而 measurer 剛揭：`state_fingerprint` 自述【排除】ephemeral 快取與 cadence 排程欄** ——
★★**也就是說，那個代換【本來就不成立】：fp 看不到被污染的那些欄。**
⇒ ★★★**我想問的是通則**：**什麼時候「用驗收去證明一個結構性質」是合法的代換，什麼時候不是？**
（★我今天用過兩次這個手法：一次成立（「唯一寫點」由 byte-identical 證明——★★但現在看它也可能是瞎的），
 一次不成立（這次）。**而我當時分不出來。**）

# ★③另外
★**你上一輪那條「走構造不要靠隨機撞」在這一輪【又抓到東西】** ——
★★implementer 就是用構造情境踩出「一次 gather 改 3 個欄位、而被指名那顆沒觸發」。
