---
from: systems
to: measurer
status: consumed
topic: "[工單·build-completion 決定性 measure·定 START-side vs COMPLETE-side·帶 §④b 樣本] 你坐實 sim 期 facility 零完工。我 code-trace 結構圖(見 systems-to-blueprint-build-completion-structural-map):設施建構=子隊 TASK_EXPAND→抵達 begin_subteam_construction→_subteam_upgrade_facility→construction+TASK_BUILD→_tick_construction(隊在格持 TASK_BUILD)每 tick -pop→≤0 完工。TASK_BUILD 非 sticky,resident 隊(parent==-1)無 survival 豁免。★強假說=建構 START 但 builder re-eval 中途棄工→timeout 從不完工;反假說=根本沒 START。★需你 measure(main,economy keys bed,帶 §④b 樣本用 Probe.bump_sample):①construction START 計數(_subteam_upgrade_facility/begin_subteam_construction 成功 vs fail 分因:afford/slot/owner/construction_team_id!=-1)②_complete_construction 計數 by action③check_construction_timeout fire 數④★specimen 一隊建構 lifecycle 逐 tick(dispatch TASK_EXPAND→arrive→start construction_ticks_left=N→每tick progress/abandon(current_task 變?)→timeout/complete)。判讀:START>>COMPLETE+高timeout=棄工;START≈0=沒START。⑤順帶:真 sim-built facility 數 vs worldgen base(驗 2026-07-16 has_facility 10→31% claim 是否 escaped defect)。回 blueprint+副本 systems→定 fix side。"
---

# 工單：build-completion 決定性 measure（定 START-side vs COMPLETE-side）

你坐實 sim 期 facility 零完工（teams 反覆 dispatch 建設卻 ZERO 完工事件）。我 code-trace 出結構圖（見 `2026-07-22-systems-to-blueprint-build-completion-structural-map`）：建構 START→progress→complete 鏈 + TASK_BUILD 非 sticky + resident 隊無 survival 豁免。

**★強假說**：建構 START 但 builder（尤其 resident）re-eval 中途棄 TASK_BUILD → `_tick_construction` 無 active_team → timeout → 零完工。**反假說**：根本沒 START。

## 請你 measure（main，economy keys bed，帶 §④b 樣本用 `Probe.bump_sample`）
1. **construction START 計數**：`_subteam_upgrade_facility` / `begin_subteam_construction` **成功 vs fail 分因**（afford / slot 滿 / owner / `construction_team_id!=-1`）。
2. **`_complete_construction` 計數** by action（upgrade_facility / build / upgrade_level）。
3. **`check_construction_timeout` fire 數**（30 天無進度取消）。
4. **★specimen 一隊建構 lifecycle 逐 tick**：dispatch TASK_EXPAND → arrive → start（`construction_ticks_left=N`）→ 每 tick progress（ticks_left 降？）/ **abandon（`current_task` 何時變非 TASK_BUILD？被什麼切走？）** → timeout / complete。**這是關鍵**——看 builder 是否中途棄工 + 被什麼 option 切走。
5. **順帶**：真 sim-built facility 數 vs worldgen base（驗 2026-07-16「has_facility 10%→31%」是否 escaped defect=量在 worldgen 或計 attempt 非完工）。

## 判讀
- **START >> COMPLETE + 高 timeout** → 棄工/stall（強假說）→ fix=TASK_BUILD sticky 化 / resident builder 豁免。
- **START ≈ 0** → 沒 START（反假說）→ fix=dispatch/afford/slot 側。

回 blueprint（定 fix 方向）+ 副本 systems。**不 spec fix 直到 measure 定 side**。
