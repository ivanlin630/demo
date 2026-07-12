---
from: blueprint
to: systems
status: consumed
topic: [merge請求+補probe] plan-layer S2驗收基本盤過,請merge；但補plan_phase分布probe(比照rung_dist)在S3前先跑organic驗證,防「湧現誠實化」章節的同質化風險在S4才被發現
---

# plan-layer S2 —— merge請求 + 補organic phase分布probe

## S2驗收結論
determinism CLEAN，0新增SCRIPT ERROR，單元測試（`_test_plan_phase_derive`/`_test_plan_phase_bias`）PASS，TC7 divergence確認（霸主/商人/隱士三distinct選項）。**請merge S2。**

## ★補probe請求（S3 dispatch前）
measurer回報：`warring_harness.gd`目前沒有`plan_phase`/`plan_phase_drive`相關probe key，organic多隊3mo跑看不到「哪些隊實際落在哪個phase」的統計，目前只有implementer的孤立單元測試覆蓋。

**這正好碰到用戶原本的顧慮**（「目標錨直接做行動，會產生很多誤導我們的數據」）——spec裡「湧現誠實化」章節明確要求organic驗證「至少2種以上明顯不同phase序列模式」，且已誠實預告野心分布窄可能導致同質化風險。這個驗證**不能只靠單元測試**，需要organic真實跑出來看分布，才知道野心分布窄的風險是否真的發生。

**請implementer補一個`plan_phase`分布probe**（比照`rung_dist`模式，`2026-07-12-measurer-to-blueprint-plan-layer-s1-result.md`裡的`rung_dist`欄位同款）——記錄organic多隊3mo跑裡各隊落在哪個phase、選了哪個偏置option的分布。measurer再補跑一次organic快照確認：
1. 是否真的出現≥2種明顯不同phase模式（湧現誠實化驗收標準）。
2. 若高度同質化——這是已知風險（誠實標記過），不算S2失敗，但要記錄下來給S4 GUI設計參考、以及最終「established>0整包驗收」時一併考量。

## 序
merge S2 → 補plan_phase分布probe → measurer organic驗證 → 回報 → 續S3（survival-bypass）。
