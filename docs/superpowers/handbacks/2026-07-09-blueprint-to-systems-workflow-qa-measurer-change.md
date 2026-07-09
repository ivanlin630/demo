---
from: blueprint
to: systems
status: consumed
topic: 流程改(用戶定案)——砍正式QA段/藍圖持pass權 + 量測員標準full_probe床;寫進 04_qa/03b_measurer/roles/08
---

# 流程改：驗收模型 + 量測員（用戶定案 2026-07-09）

用戶親定兩改，互鎖。請寫進 process docs（`04_qa.md`/`05_acceptance.md`/`03b_measurer.md`/`00_roles.md`/`08_machine_workflow_v2.md`）+ 提煉 memory（你單寫者）。

## 動機（A2c-1 現場證據）
- **正式 QA stage 沒出力**：A2c-1 抓到 regression 的是量測員+藍圖+**用戶**（餓死洞察），不是 QA stage。QA 全程「判不 ok 就丟回 00 再量」= 沒行使獨立判決、只 bounce。
- **bounce 根因 = 量不了**：acceptance bed（seeded_warring_bed）跑 quiet（無 per-event print）+ 缺維度（merge count / option 去向）→ 量測員產不出數 → 反應式補探針重跑 → QA 無完整數據判 → bounce。
- 用戶深度在線 = 事實驗收權威；正式 QA 角色是為「用戶不在迴圈」設計 → 現模式下是 overhead。

## A. 驗收模型改
- **砍下游 per-slice 正式 QA release-gate stage。**
- **release-pass 權 → 藍圖**：**沒問題就過；有問題才升用戶**。用戶 = 問題 backstop，非每次交付閘。
- **藍圖持真 bar，非橡皮章**：用完整數據審，主動升真問題（A2c-1 = 模型：藍圖主動升餓死 regression）。若藍圖淪為鬥橡皮章 → 違此改精神。
- **每 slice 保留**：reviewer（對抗審 correctness/獨立性軸）+ 量測員（獨立完整數字）。這兩個是真正 localize regression 的。
- **escaped_defects ledger 續記**：砍 QA 後若漏 bug，帳上可見、隨時翻案。

## B. 量測員改：標準 full_probe 床
- **acceptance/診斷跑標準 full_probe 床**：所有維度**一次抓齊**——
  - 衝突面（征服/攻擊/交戰/掠奪/血仇/背叛/外交）
  - 生存面（餓死/餓滅/pop/food_flow 分布/team-size 直方圖）
  - **決策面（option 選擇分布 / merge-applicable 隊實際去向）** ← 上次缺這個卡死
  - 結構面（teams/faction 消長/established）
- **結構化 JSON、不靠 print 刮、無 quiet 死路、無缺維度**。baseline/slice 並排。
- **∴ 量測員永遠量得出完整數字** → 藍圖判得動 → 不再 bounce、不再「量不了」。
- full_probe merge 探針你已起頭（PROBE_KEYS + faction_ai bump）→ 續補齊上述全維度成標準模式。

## 互鎖（閉環）
完整量測（B）→ 藍圖判得動 → release-pass（A）→ 不再 bounce。兩個缺一不閉：只砍 QA 不修量測 = 藍圖也可能「量不了」；只修量測不砍 QA = QA 仍多餘 bounce。

## Caveat（寫進 doc 別漏）
- **full_probe 只在 acceptance/診斷床**（本就跑對照的場合，慢可接受），**非每個 sim/live GUI/每 headless**（perf）。
- **綁「用戶在迴圈」**：哪天轉自動交付（用戶不看）→ **正式 QA 硬閘回來**。此改是 user-in-loop 模式的優化，非永久廢 QA。

## 落地
- 你寫 process docs + memory 提煉（[[feedback_qa_inversion]]/[[feedback_session_roles]]/[[feedback_avoid_rabbithole]] 系族——反應式逐維量測→全探針一次抓全 + QA-in-loop 收斂藍圖）。
- 與 A2c-1 升級並行不擋：A2c-1 fold+survival-value 的 full_probe 三方驗收正是新量測模型首個實例。

用戶已 ok。寫 doc。
