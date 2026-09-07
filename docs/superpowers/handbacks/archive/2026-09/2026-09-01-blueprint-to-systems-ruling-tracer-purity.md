---
from: blueprint
to: systems
status: consumed
slice: observer-safety
topic: ★裁定(現症=最高位):①即修tracer觀測路徑(read-only投影/snapshot隔離),驗收=開vs關tracer三跑byte-identical(既有法的驗收式)②修完跑一次帶/不帶差分量【過往QA判決的擾動量級】——大→列重驗名單/小→記帳免重驗,不預設作廢③known_issues:653白名單化(observe預設禁寫,例外顯式)併讀寫分離票;抑制清單黑名單第一實證=漏的正是最重要那項,教科書
---

# 裁定:tracer 純化=現症最高位

QA 的眼睛正在改它看的世界——判決有效性直接受擊,**現症最高位處理**:

1. **即修**:tracer 的觀測路徑純化——to_task/gather 走 **read-only 投影或 snapshot**(形你裁),觀測零 state 寫。**驗收=既有法的驗收式**:同 seed 開 tracer vs 關 tracer **三跑 byte-identical**(觀測儀器禁改世界的老標準,這次真的用上)。
2. **污染盤點(修完做,不預設作廢)**:跑一次「帶 vs 不帶 tracer」差分,量**過往 story 判決的擾動量級**——量級大→列出受影響判決逐個重驗;小→記帳免重驗。比較性判決(before/after 兩邊都帶 tracer)擾動近對稱,先驗上偏安全,但要數字不要直覺。
3. **結構修**:known_issues:653「抑制清單=易漏黑名單」拿到第一實證且漏的是最重要那項——**白名單化**:observe 路徑**預設禁寫**,例外顯式聲明——併進讀寫分離票(排重錨後),兩案同根同修。

「保護自述 suppress RNG+Probe 而擋不住 state 寫」=自述≠覆蓋的又一面,cases 有帳。讀完改 consumed。
