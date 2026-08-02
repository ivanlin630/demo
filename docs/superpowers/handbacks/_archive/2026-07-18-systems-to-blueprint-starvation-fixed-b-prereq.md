---
from: systems
to: blueprint
status: consumed
topic: "[解·傻站死 bug 修好·B 第一關過(sampled)] survival PRIO fix merged(31f9833c)。你判準的 bug(傻站死絕境出路沒 fire)根治:seed42 8mo extinct.starve 15→0(質變回自限),pop 持平,attrition 自限 2.78%(甚至低於 pre-threat-oracle ~9%=survival 保序在統一路更 robust)。threat 黏性未損(迎戰/備戰/求和 更活躍)。★根=S3 threat @70 但 survival 落 @50 無法 preempt;fix=survival @PRIO_SURVIVAL 80 restore 階層。attrition 現=自限型(餓→逃/覓食 fire→隊縮回)你原判準的 acceptable 型。B 第一關(世界 sustain N 隊)sampled 世界過。"
---

# 解：傻站死 bug 修好，B 第一關過（sampled）

你重判準的 bug（傻站著餓死、絕境出路沒 fire）**根治**：

## 修好了
- **根**：S3 threat-oracle 收斂把 threat 抬 @PRIO_THREAT 70，但 survival 選項落 @PRIO_DISPATCH 50 → 卡 threat task 的瀕死隊 survival 無法 preempt（50<70）→ 傻站死 no_forage。
- **fix**：survival-class @PRIO_SURVIVAL 80，restore SURVIVAL 80 > THREAT 70 > DISPATCH 50 階層（+ self-replace 擴 PRIO_SURVIVAL，R² 抓的一致性）。
- **measurer 決定性**（seed42 8mo 同診斷 seed/窗）：**extinct.starve 15→0**（傻站死質變回自限）、pop 持平（423→420）、**attrition 自限 2.78%**（甚至低於 pre-threat-oracle 原生 ~9%=survival 保序在統一路比舊非統一路更 robust）、threat 黏性未損（迎戰 4.61%/備戰 4.63%/求和 13.74% 更活躍）。

## 對你判準
- attrition 現 = **你原判準的「自限代價 acceptable」型**（餓→絕境階梯 fire→隊縮回，非傻站死）。
- **B 第一關（世界能否 sustain N 隊）= sampled 世界過**（0 餓死滅團、pop 穩）。B 放大規模的地基（不會餓死隊）就位（此 seed）。

## 意義（你原話「未阻塞就更正才是對的」）
threat-oracle arc 誠實 attrition 查 → 揪出比 threat-oracle 大的根（絕境階梯 PRIO regression）→ 修好且改善（attrition 低於原生）。measure-first 值:若信我原「attrition=combat 好戲」就漏了這 B-blocker bug。

## 續
- multi-seed 確認（seed42 決定性，但擴 1-2 seed 確認普適=順手，非阻塞）。
- 真統一收斂 program 主體完成（threat done、survival-churn defer-as-legit）；零殘留收尾/stream③ 情緒續。

## 溯源
survival PRIO fix merged（`2026-07-18-systems-to-implementer-survival-prio-fix.md`）;measurer 決定性複核;你 re-judge 判準（自限 vs 傻站死）;[[project_desperation_economy]] B 前置。
