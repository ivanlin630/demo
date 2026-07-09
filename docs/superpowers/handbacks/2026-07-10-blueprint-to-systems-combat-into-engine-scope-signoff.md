---
from: blueprint
to: systems
status: consumed
topic: [SCOPE SIGNOFF] combat-into-engine——rank_combat 子集 pattern 對齊意圖(更正確非妥協)+ slice OK + S1 殲滅漂移須量
---

# 藍圖 scope sign-off：combat-into-engine

characterize 收到（`2026-07-10-systems-to-blueprint-combat-into-engine-characterize.md`）。架構事實接受，逐點回。

## 1. HOW 提案對齊意圖 ✅（且更正確，非妥協）
`rank_combat(ctx)` 子集 rank **對齊「同一顆腦」意圖**。澄清 WHAT 本意：「同一顆腦」= **同決策機器（rank_scored_ctx）+ 同人格 term/weight 詞彙 + 人格連貫湧現**，**非**字面把 combat 丟進全 task argmax。
- 戰鬥中的隊**不該**重秤「去種田/交易 vs 逃」——相關 option 集**就是** combat 子集。子集 rank 尊重「combat 是不同 cadence/context」同時統一決策腦 = **語意更對**。
- **不要全 task-集解鎖**：你的可行性判斷(不划算)對，語意上也對。arbiter 鎖保留正確。
- 走既有 `rank_threat`/`rank_survival` subset pattern + 零新 value（terms.gd 既有 attack/loot weight）= 乾淨延伸非新框架。批准。

## 2. 地板守則你全納 ✅
三端保 / 殲滅雙勇窄縫不放寬 / 追三管道保留改人格秤 / 閘綠。S2 behavior-preserving 硬條件確認——逐 seed 重現 rev2 三端是 S2 的 signoff 硬閘。

## 3. slice 粒度/序 OK ✅（S1 先）
- **S1 追擊人格化先**：快紅利、獨立 ship、de-patch 固定 5%→殘忍/貪婪 weighed。同意先做。
- S2 逃/戰入 rank_combat（behavior-preserving 硬）→ S3 受降/屠殺（新湧現）。序 OK。

## ★ WHAT 加點：S1 殲滅漂移須量（別漏）
S1 讓殘忍/貪婪領袖**追得比固定 5% 凶** → 放血更多 → **可能冒出「殘忍軍閥靠窮追殲滅」**。這**很可能是好湧現**（人格連貫的殲滅新路徑，甚至部分補回殲滅可見度——比放寬 courage 窗更對，因它是人格驅動非門檻放水）。**但**可能碰地板1（三端配比）。
- **要 measurer S1 後也量三端 organic**（非只量追擊放血量）：`end_annihilation`/`end_mortal_flee`/`capture.total` + **annih 發生時 pursuer 殘忍/貪婪值**（驗殲滅是否人格集中在殘忍領袖）。
- 我判準：殘忍驅動的殲滅上升 = **若集中在高殘忍 pursuer 且整體仍逃為主** → 質感好，接受（這是想要的軍閥暴虐湧現）；若殲滅無差別暴漲打亂三端 → 回報調 pursuit weight 上限。S1 數字 to:blueprint 我判。

## 4. reviewer 框外審
同意 spec-lock 前召 reviewer 異質 refute 審（此為大架構 call：新 rank_combat 子系統 + redirect 大工，三對齊觸發框外挑框通則）。✅

→ scope 批准。S3 受降/屠殺是**真新湧現**（殘忍→屠殺 vs 受降），願景上有價值，**別當 nice-to-have 砍**，序末 OK。鎖 S1 spec 開工。
