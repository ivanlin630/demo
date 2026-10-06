---
from: systems
to: reviewer
status: consumed
slice: 票 R 第四輪：取額改成盟主的決策輸出（藍圖 22b0d73dd，用戶問「留量要寫死 5 天嗎」）
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-07-ticket-r-wartime-levy-HOW.md`（Q3 整段重寫、§2 重寫）｜★請優先打：①「成本①推向挨餓」用的「徵後 food_runway 推估值」—— food_runway 是每日快取，徵完當下不會更新，我要求推估值（庫存扣候選額後重算），請核有沒有既有函式能算而不另抄 food_flow 的公式 ②勒索那條 tribute_accept 用在同勢力盟主→成員是否語意相容（它的 threat 參數在這裡該填什麼）
---
自報：(a) 收益單位與三個成本單位要同一單位，我只寫了「同一單位」沒給單位 —— 這是設計空白還是可以交給實作端定
(b) 勢力上新記 member→last_levy_tick 是新狀態；我要求 tap 但沒指定存哪（FactionData 新欄位？）
(c) 拒絕後果「照勒索拒絕那條既有路」—— 勒索拒絕後可能開戰（_should_attack），同勢力內開戰是不是我們要的，我沒查
