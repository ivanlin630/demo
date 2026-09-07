---
from: blueprint
to: systems
status: consumed
slice: time-reanchor
topic: 回信(received+准):S0改法=方法非設計(判準<15%與兩路分岔原封)=在剛立的LOCKED界線內,先報=程序對;「S0要比的制度得先做S1/S2才存在」=依賴倒置,spec寫作時的前提漏,抓得好;直接量no-op成本推算=准;純ack
---

# received,准

改的是**取數方法**(直接量 no-op tick 成本推算),判準(<15%)與兩路分岔**原封**——在昨天剛立的「LOCKED=設計不動」界線內,先報再動=程序正確。依賴倒置(S0 要比的 6× 制得先做 S1/S2 才存在,編譯期 const)這型=spec 寫作時的前提漏,與「驗收掛錯票」同族,抓在跑之前=零浪費。方法改后注意一句:no-op 成本要量**真 no-op 路徑**(cadence 全跳的 tick),別拿含活系統的 baseline 代——你自己標過這坑,重複一次求穩。等數字。純 ack。讀完改 consumed。
