---
from: systems
to: implementer
status: open
topic: "[dispatch 補 officer_need dispatch-demand(blueprint 裁、genuine 完成 spec 非 crank、held branch feat/named-scarcity-ab 8afaa64a 上疊小修)·★真根:officer_need(faction_ai:1684)現只 villages-oversight((desired∝管轄村數−spare)/desired)、漏 spec 明訂的『想派任務沒人可派』dispatch-demand=arc 本旨的真 named-scarcity(T12 唯一 named 派 scout 後無 bench 想派更多派不出=統一派遣 arc 原症)→realistic 村數-satisfied 領主 officer_need~0.04→train util 0.05<<build 0.98 dormant(measurer 硬數據)·★★§HOW-binding:officer_need 加 dispatch-demand 分量——領主有 pending/wanted dispatch(scout info-staleness / care overdue / relief help-severity 任一 demand>0=想派)× spare named bench 短缺(post-unified-dispatch 派遣借 spare named via _pick_dispatch_runner、bench=可借 named 數≈named_members−自用)→想派但無 bench=高 need·officer_need=max 或加權合(villages-oversight 現有 + dispatch-demand 新)、取真反映『缺 officer』最大壓力·★★genuine 非 crank(乙命門、blueprint 定):是讓 officer_need 真反映真壓力(想派沒人真缺)、★禁 bump TRAIN_OFFICER_MAG 逼 train 贏(治標 crank);補全後 train util genuine 高 WHEN 真缺(T12 想派無 bench)→贏 argmax genuine·★★bounded 守(命門):村夠+能派(有 bench 或無 dispatch-demand)→officer_need 低不練(非 always-train、machine-demonstrate 保 dispatch-demand=0 或 bench 足→need 趨零)·★★驗收(硬數據、6×gap 教訓禁預設、realistic 床非只 unit):①★realistic 床(4+16 隊、T12 型 1-named named-scarce 領主)officer_need now 真高否(想派 scout/care 但無 bench)→train util 贏 argmax→tier-up→promote 真 fire(前 dormant now fire)②bounded machine-demonstrate(bench 足/無 dispatch-demand→officer_need 趨零不練、非 flat)③unit test 更新+新 realistic-scarce 案③determinism+無 regression+constitution·★★行為變 slice=fp 分化 intended·完成 handback to:systems R²(★這次特別核 officer_need dispatch-demand 真反映壓力否非只 bounded=第6 gap 教訓+realistic 床驗真 fire)→measurer realistic 前後對照(T12 型真解+bounded+人格分化+vs 玩壞)→QA→merge→推用戶·地基 KEEP"
---

# dispatch 補 officer_need dispatch-demand（held branch 上疊、genuine 非 crank）

blueprint 裁。held branch `feat/named-scarcity-ab` `8afaa64a` 上疊小修。

## ★真根
`officer_need`（faction_ai:1684）現只 **villages-oversight**（`(desired∝管轄村數−spare)/desired`）、漏 spec 明訂的「想派任務沒人可派」**dispatch-demand** = arc 本旨的真 named-scarcity（T12 唯一 named 派 scout 後無 bench 想派更多派不出=統一派遣 arc 原症）→ realistic 村數-satisfied 領主 officer_need~0.04 → train util 0.05<<build 0.98 dormant（measurer 硬數據）。

## ★★§HOW-binding
officer_need 加 **dispatch-demand 分量**——領主有 pending/wanted dispatch（scout info-staleness / care overdue / relief help-severity 任一 demand>0=想派）× **spare named bench 短缺**（post-unified-dispatch 派遣借 spare named via `_pick_dispatch_runner`、bench=可借 named 數）→ 想派但無 bench = 高 need。officer_need = max 或加權合（villages-oversight 現有 + dispatch-demand 新）、取真反映「缺 officer」最大壓力。
- ★★**genuine 非 crank**（乙命門、blueprint 定）：讓 officer_need 真反映真壓力（想派沒人真缺）、★**禁 bump TRAIN_OFFICER_MAG 逼 train 贏**（治標 crank）；補全後 train util genuine 高 WHEN 真缺 → 贏 argmax genuine。
- ★★**bounded 守**：村夠+能派（有 bench 或無 dispatch-demand）→ officer_need 低不練（非 always-train、machine-demonstrate 保 dispatch-demand=0/bench 足→need 趨零）。

## ★★驗收（硬數據、6×gap 教訓禁預設、★realistic 床非只 unit）
①★**realistic 床**（4+16 隊、T12 型 1-named named-scarce 領主）officer_need now 真高否（想派 scout/care 但無 bench）→ train 贏 argmax → tier-up → promote **真 fire**（前 dormant now fire）②bounded machine-demonstrate（bench 足/無 dispatch-demand→need 趨零不練）③unit test 更新+新 realistic-scarce 案 + determinism + 無 regression + constitution。★★行為變 slice=fp 分化 intended。

## 序
handback `to:systems`（R²：★這次特別核 **officer_need dispatch-demand 真反映壓力否**非只 bounded=第 6 gap 教訓 + realistic 床驗真 fire）→ measurer realistic 前後對照（T12 型真解+bounded+人格分化+vs 玩壞）→ QA → merge → 推用戶。地基 KEEP。
