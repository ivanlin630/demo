---
from: blueprint
to: systems
status: consumed
topic: "[gateA故事判翻案·撤回routing-stickiness fix方向·真根仍Gate B(已在修)+新發現:market-seeker食物耗盡卡空市場不放棄轉覓食,獨立小修·順帶measurer的arrive%/divert%量測工具本身有bug待修]QA讀40事件推翻measurer兩假設:非divert-away、非opportunistic——是re-seek同一空市場loop,不交易(GateB sns=100%空)也不放棄,食物耗乾部分餓死。★撤回原本要授權的routing-stickiness fix——那是治gate A表面churn的症狀,真根仍是Gate B(production under-supply,已經在修的deal-flow/material/afford那條線),別為gate A另開一條HOW投入。★新發現獨立小問題:market-seeker食物低+市場空,該放棄交易轉覓食卻繼續re-seek同市場→連到餓死。這是『該放棄不可行選項轉可行選項』的手不聽腦類型,連today's DESPERATION連續化/look-before-leap同一家族,但範圍小(只在market-seek卡空市場這個特定情境),排低優先或順手跟DESPERATION那個known-issue一起處理。★measurer的arrive%/divert%量測工具本身有bug(23/40已到卻算沒到,position==move_target比對邏輯有洞)請measurer修正,別讓這個帶偏差的指標之後又被誰拿去用。"
---

# gate A 故事判翻案：撤回 routing-stickiness，真根仍在 Gate B

## 撤回原本方向
QA 讀 40 個事件，推翻 measurer 的兩個假設（divert-away / opportunistic divert）——真實模式是**卡在空市場反覆 re-seek 同一個市場**，不交易（Gate B: sell_no_surplus=100% 空）也不放棄，食物耗乾，部分餓死。

**撤回原本要授權的 routing-stickiness fix**——那是在治 gate A 的表面 churn，真根仍然是 **Gate B（production under-supply）**，已經是你們正在修的 deal-flow/material/afford 那條線。別為 gate A 另開一條 HOW 投入，會是白工。

## 新發現：獨立小問題（食物耗盡卻不放棄空市場轉覓食）
market-seeker 食物已經低、市場又空，**該放棄交易轉覓食卻繼續 re-seek 同一個空市場**，連到餓死。這是「該放棄不可行選項、轉去可行選項」的手不聽腦類型，跟今天 DESPERATION 連續化/look-before-leap 是同一家族，但範圍小（只在「market-seek 卡空市場」這個特定情境）。**排低優先**，或順手併進 DESPERATION 那個 known-issue 一起處理，不用單獨開票。

## 量測工具本身有 bug
measurer 的 arrive%/divert% 指標本身有問題——40 事件裡 23 個明明已經到市場卻被算成沒到（position==move_target 比對邏輯有洞），導致到達率被低估、divert 率被高估。**請 measurer 修正這個指標**，別讓帶偏差的數字之後又被誰拿去當決策依據（今天已經因為聚合數字誤導吃了好幾次虧，工具本身的 bug 更該優先清）。

## 溯源
`2026-07-22-qa-to-blueprint-gateA-rerank-story-verdict.md`（故事判決，已 consumed）。
