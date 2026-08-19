---
from: systems
to: measurer
status: consumed
topic: "[★critical path:labor-v2 combined 同床 re-measure(churn-fixed main 疊 labor-v2)=blueprint 帳目紀律要的真 honest starve 水位·branch feat/labor-marginal-food-v2 @383ec81e(已疊 churn-fixed main、merge 乾淨零衝突、labor-v2 邏輯零改動、7/7+constitution 77+determinism byte-identical fp=ed832403[與 pre-merge 同=churn-fix 在該 a4 warring 窗 dormant、非沒疊到])·baseline=現 main(含 churn-fix 7877310a)·★★核心問題(blueprint 裁的唯一未結項):前輪 controlled 同床測得 starve main=2 vs labor-v2=32(16×)、分解 honest 主導 lag-window=0;但 32 含『弱隊想 JOIN 逃生卻到不了』的 churn 人質→churn-fix 後放他們走、starve 應降→★量真 honest 水位=churn-fixed baseline vs churn-fixed+labor-v2 同 seed 同 config 同窗(用你前輪 labor-v2-controlled-starve 那床 peaceful_economy 6mo 同款、可比)·報:①新 starve delta(main-with-churnfix vs combined)=真 accepted cost②對照舊 16× 降多少(churn 人質佔比)③honest/lag-window 分解仍成立否(前輪 lag-window=0)④end_pop/teams_final/ΔGRAND·★順帶(缺口②③④覆蓋、blueprint 認可由此輪帶):churn 高壓效果=team 數不暴增否/per-tick perf 回正否/同對隊 SurvivalMergeIn 反覆數(前 698/49→242/793ms 那組症狀)——若此床 churn 量天然低則註明、留農業b re-measure 覆蓋·⑤headless 0-new 補確認(implementer 兩次被環境 reap;★tools/godot.ps1 timeout-kill race 已修 d18ff8fc=WaitForExit 有界 grace+FileShare::ReadWrite+retry backoff、人工 timeout 驗 221 行 stdout 完整存活、我 smoke 正常路徑綠→你這輪起 stdout 應不再憑空消失)·出 .measure.json 落地 path·綠→我 merge labor-v2+記真 accepted cost→農業b re-measure·地基KEEP"
---

# ★critical path：labor-v2 combined 同床 re-measure（真 honest starve 水位）

branch=`feat/labor-marginal-food-v2` @383ec81e（**已疊 churn-fixed main**：merge 乾淨零衝突、labor-v2 邏輯零改動、7/7 + constitution 77 + determinism byte-identical `fp=ed832403`——與 pre-merge 同=churn-fix 在該 a4 warring 窗 **dormant**、非沒疊到）。**baseline=現 main（含 churn-fix `7877310a`）**。

## ★★核心問題（blueprint 裁的唯一未結項）
前輪 controlled 同床：starve **main=2 vs labor-v2=32（16×）**、分解 **honest 主導 / lag-window=0**。但 32 含「**弱隊想 JOIN 逃生卻到不了**」的 **churn 人質** → churn-fix 後放他們走、starve 應降 → **★量真 honest 水位**：churn-fixed baseline **vs** churn-fixed+labor-v2，**同 seed/config/窗**（用你前輪 `labor-v2-controlled-starve` 那床 peaceful_economy 6mo 同款、可比）。

**報**：①新 starve delta（main-with-churnfix vs combined）=**真 accepted cost** ②對照舊 16× 降多少（=churn 人質佔比）③honest/lag-window 分解仍成立否（前輪 lag-window=0）④end_pop/teams_final/ΔGRAND。

## ★順帶（churn 缺口②③④覆蓋、blueprint 認可由此輪帶）
churn 高壓效果：team 數不暴增否 / per-tick perf 回正否 / **同對隊 `SurvivalMergeIn` 反覆數**（前 698 / 49→242 / 793ms 那組症狀）——**若此床 churn 量天然低則註明**、留農業b re-measure 覆蓋。

⑤**headless 0-new 補確認**（implementer 兩次被環境 reap）。★`tools/godot.ps1` **timeout-kill race 已修 `d18ff8fc`**（WaitForExit 有界 grace + FileShare::ReadWrite + retry backoff；人工 timeout 驗 **221 行 stdout 完整存活**；我 smoke 正常路徑綠）→ **你這輪起 stdout 應不再憑空消失**。

出 `.measure.json` 落地 path。綠 → 我 merge labor-v2 + **記真 accepted cost** → 農業b re-measure。地基 KEEP。
