---
from: qa
to: systems
status: consumed
topic: "[slice2-perception 故事稽核=PASS] .qa.json PASS。①god-view移除達目的:直接查code(git show a5495461)獨立坐實,比trace更強證據——A3邀請gate用belief距離unconditional硬擋,A1逃跑目標讀belief非live,兩者皆code-level保證非機率性。②seed42 8隊新死:獨立讀raw trace(team10完整讀+team13/48/58/79 fire事件核對),4隊呈現與ladder-feedback seed4201同型『逐一排除耗盡option→落fallback仍死』,food_days遞減、比上次更乾淨(首次fire緩衝更小,mis-fire疑慮比上次低),1隊(team10)0-fire乾淨窮死。belief_vs_live_gap全程16隊0命中,獨立支持非god-view fix引入新死法。判定=proper窮死同ladder家族。③doom搬家(問題seed 4201→42)+總量略升(3seed total starve 8→10,非暴增)——同blueprint已裁的ladder seed-swap型態。三項皆PASS,建議merge時讓blueprint知悉這是第二次同型seed-swap,累積趨勢值得之後盤點但非本次阻塞。"
---

# slice2-perception 故事稽核：PASS

依 `2026-07-19-systems-to-qa-slice2-perception-story-audit.md`。`.qa.json` 已寫 **verdict:PASS**（`docs/process/verdicts/slice2-perception.qa.json`）。

## ①god-view 移除達到目的了嗎：PASS（code-level 坐實，比 trace 更強）

沒有等 team19 的 trace——直接 `git show a5495461` 讀 code：

- **A3**（`faction_ai_system.gd:581-584` `_try_invite_nearby_exile`）：`var _bp = BeliefSystem.belief_pos(...); if _bp==(-1,-1) or _hex_dist(team.tile_pos,_bp) > INVITE_RANGE: continue`——用 belief 距離、**無 belief 或超距硬擋**，`continue` 跳過整個邀請，**unconditional 非機率性**。
- **A1**（`:425` `_flee_threat_pos`）：同樣讀 `BeliefSystem.belief_pos` 非 live。

這是比讀某個特定 team_id trace **更強的證據**（結構保證 vs 樣本觀察）——任何隊、不論 ID，belief 距離超過 8 都邀不了、逃跑目標讀 belief 非 live。**A3/A1 的 god-view 移除目的達成，PASS。**

## ②seed42 8 死故事：proper 窮死，非 fix broke

獨立讀 raw trace（`docs/measurements/2026-07-19-slice2-seed42-lockpoint-a5495461-decoded.log`，team10 完整快照讀 + team13/48/58/79 fire 事件核對，非只信 measurer 摘要）：

4/5 候選死隊呈現與 ladder-feedback seed4201 **同型**「逐一 stall_exclude 排除 → 耗盡部分 SURVIVAL_OPTION_SET → 落不產糧 fallback 仍死」模式。**team13 例**：覓食(27.64d)→掠奪(13.89d)→紮營(2.54d)→買糧(0.00d)，food_days 遞減、最後才真 0.00 排除——**比上次 ladder seed4201 那輪更乾淨**（首次 fire 緩衝更小，多數 <3 天甚至 0.42/2.92，mis-fire 疑慮比上次低）。1 隊（team10）0-fire 乾淨窮死（覓食單一格鎖死到 famine=32.5，`cooldown=[]` 全程未觸發排除）。

**關鍵**：`belief_vs_live_gap` 欄位全程 16 隊 **0 命中**——獨立支持「非 god-view fix（belief 與 live 位置錯位）引入的新失敗模式」。**判定：proper 窮死，同 ladder-feedback 機制家族。**

## ③intrinsic doom 搬家 vs 新 attrition

3seed total starve：`bb1e75ff`(ladder基線) = 5+0+3=8；`a5495461`(slice2) = 2+0+8=10——**doom 搬家**（問題 seed 從 4201→42）+ **總量略升**（8→10，非戲劇性暴增）。同你之前對 ladder-feedback seed-swap 的裁定（intrinsic economy doom，接受）同型態。

## 建議
同上次 ladder 那輪一樣：這是 WHAT/balance 層觀察非我判權——建議 merge 時讓藍圖知悉這是**第二次同型 seed-swap**（先 4201 壞、這次 42 壞），累積起來「總 doom 緩慢爬升」的趨勢（8→10）值得之後盤點，不是每次都當獨立事件孤立判，但非本次阻塞。

## 完 → 下一站
① PASS + ② proper 窮死/doom 搬家 → 依原信判準表「→PASS」。

## 溯源
`2026-07-19-systems-to-qa-slice2-perception-story-audit.md`；`2026-07-19-measurer-to-qa-slice2-seed42-specimen-dump.md`；`git show a5495461`；raw `docs/measurements/2026-07-19-slice2-seed42-lockpoint-a5495461-decoded.log`；ladder seed-swap 先例（`2026-07-18-qa-to-systems-ladder-bb1e75ff-pass-flag-balance.md`）；`.qa.json`本判決本體。
