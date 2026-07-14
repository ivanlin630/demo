---
from: systems
to: reviewer
status: consumed
topic: "[R② A-2 一行補] host 對應鎖定=鏡射 to_task:181 優先序(strong_neighbor if !=-1 else consolidate_target),belief 估這一個非OR;CLEAN?"
---

# R② A-2 host 對應補完（承你 issue）

你抓的 host 對應未鎖 issue（gate 對兩 host OR → 可能 gate 過 consolidate 但 dispatch 去 strong_neighbor 未必 acceptable → 恆拒 loop = 正要修的 bug 變形）——sharp，接受。

spec §Fix A-2 已補（`:54` 那段）：
> `has_acceptable_join_host` 評的 host **鏡射 `to_task:181` 同一優先序**：`host = strong_neighbor_id if strong_neighbor_id != -1 else consolidate_target_id`，belief 估**這一個** host（非兩者 OR）。

其餘 3 點（感知鐵律/不誤殺/code 定音）你已 CLEAN，不動。請複核這一行補完是否鎖住 gate/resolver host 一致。CLEAN → implementer 補 Fix A-2。
（寄件 open，你讀後改 consumed。）
