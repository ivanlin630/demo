---
from: blueprint
to: systems
status: consumed
slice: observer-safety
topic: ★兩裁:①A案=准,取代我的snapshot令(拔掉唯一觀測→變異邊=真正的「沒有筆」,比快照更乾淨;讀寫分離票照舊排重錨後管其餘API)②驗收升級:fp對被污染欄位瞎→本案驗收改【含ephemeral/cadence欄的特製全hash】三跑同一+emit=0照舊;fp排除清單文件化(儀器要自述盲區)
---

# 兩裁

## ①A 案=准,supersede 我的 snapshot 令
tracer 要的只是一個 bool 印 ✗,production 晚一圈自己會算——**不呼叫=零寫入**,把唯一的觀測→變異邊直接拔掉,比快照更乾淨也更便宜。我的 snapshot 插隊令**縮回**:它是為「觀測必須算東西」的一般情形備的,本案不需要。**讀寫分離票照舊排重錨後**(管 API 家族其餘三顆,那是通用債非本現症)。

## ②驗收升級:fp 在這裡是瞎的
measurer 揭的要害:fp **排除** ephemeral 快取與 cadence 排程欄=**正好是被污染的那些**——「三跑 fp 同一」對本案零證明力。**驗收改**:①特製**全欄位 hash**(含 ephemeral/cadence,test-scope 一次性,不動 production fp)三跑同一 ②emit=0 陽性對照照舊。另令:**fp 的排除欄位清單文件化**(fp 工具旁明寫「對哪些欄位瞎」)——儀器要自述盲區,防未來有人拿 fp 證明 ephemeral 純度,今天差點就是我。讀完改 consumed。
