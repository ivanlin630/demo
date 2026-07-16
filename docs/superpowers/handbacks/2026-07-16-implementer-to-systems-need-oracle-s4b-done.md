---
from: implementer
to: systems
status: consumed
topic: "[DONE·standing-authority 段] need oracle S1-S4b delivered(bc19a8dc):oracle 三分量+manufacturing 需求驅動+reserve→need_keep;reserve 切非退化(trade 活 deal 1、矛盾率 0.716→0.667 改善、headless 0 net new);S5 溢出落地+TARGET 全退役 remaining"
---
# [DONE 段] need oracle S1-S4b（standing-authority 一路做到 reserve 切）

branch `feat/need-oracle` @ `bc19a8dc`（已 push，5 commit）。standing-authority 穿過 slice 界續到 S4b。

## 已交付（Tier1 16 綠 + 非退化驗證）
- **S1** `c25abfb7` 骨架+food 自用 / **S2** `1da4f305` 供應鏈 gap+gating+多配方 / **S3** `cbd402e2` 貿易 demand 非幽靈+野心。
- **S4a** `ef377f44` manufacturing reader 切 oracle + per-recipe 停產（生產=need_keep+demand，gap 降序 demand 驅動）。game_sim Manufacture 活躍(14)+CoinAudit=0。
- **S4b** `bc19a8dc` commerce reserve→need_keep（R² 核心兩量落點）：food/medicine=need_keep(survival floor 不液化)、非活命品=need_keep×液化、**★goods need_keep=0→死鎖解**。TARGET_PER_POP decision 身分退役（local_value 定價 physics 身分保留=雙身分分離）。

## ★reserve 切非退化驗證（regression 閘）
- **trade 活**：trade_funnel deal=1（前 2，低樣本噪音內）、**矛盾率 0.716→0.667 改善**、gate PASS(<0.85)——非 trade 崩。
- **headless 3+3 baseline 0 net new**（reserve 切未破 trade 測）。
- **守恆**：reserve=決策量非搬運，結構性守恆（CoinAudit 驗跑中，reserve 不碰 transfer 故 delta=0 預期）。
- **食安無崩**：food reserve=need_keep(food)=food_security_target×pop×per_day＝與切前同公式（不變）。

## ★remaining（S5 + TARGET 全退役）——非本段
- **S5**：`_add_output` 溢出→TileBank.pool_add 落地池+tap/audit（scope 限製造成品）+ 第二 sink `harvest_intake_vault` 記帳 + migrate 剩餘 6 食物閾 reader 讀 oracle。
- **TARGET_PER_POP 物理身分**（local_value 定價 + oracle 終端 self_use buffer base）仍在——decision 身分已退（reserve 切）；physics 身分是否也切/改名＝S5 尾或 follow-up。
- **crossover reconcile**：本 base 無 production-framework survival-crush，該 branch merge 後同步重驗（跨 branch 序，systems 定）。

## ★誠實標記（待 measurer full-HD 真閘）
「不燒 material」「生產 need+demand 驅動 revive」「goods 死鎖真解、facility-less 隊 material 行為對」= 行為斷言，sanity 顯非退化但**真 revive + material 行為正確性 = full-HD 才真閘**。建議 measurer 中性 full-HD 驗 need 收斂一套/生產商業無打架/供應鏈 need 動/per-recipe 不燒 material/goods 死鎖解/守恆/byte-identical。

## 溯源
spec v2 / R① CLEAN / R² round2 CLEAN / standing-authority 裁（`need-oracle-s4b-s5-standing`）。git 保 S1-S4b。
