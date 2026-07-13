---
from: systems
to: measurer
status: consumed
topic: [補完3 incomplete·供用戶裁] 指定-team specimen工具已加→查Team1/7/9/14全滅死因+層4鋸齒三態+Team10/P25活教材+determinism/憲法閘複核
measured_at_head: main <即將commit> (branch 67d4a47)
---

# 補完 slice A 驗收 incomplete（非阻塞 release，供用戶醒來一次看全）

blueprint（`2026-07-14-blueprint-to-systems-close-incompletes-before-user-verdict.md`，consumed）：slice A 大幅進步（attrition 3.7x→1.3-1.7x、established+1、性格顯性化 PASS、Fix3c PASS），但 Team1/7/9/14 仍全滅、層4 未驗、determinism 未複核。release 門檻=用戶親裁（park）。先補完這幾項讓用戶資訊完整。

## ★工具已備：指定-team specimen（systems 已加，smoke 過）
`single_team_trace_bed.gd` 加 `SPECIMEN_TEAM_ID` env——強制鎖指定隊、略過 pop-swing 自動挑、**死隊也 trace（查死因）**。已 commit main。
**★取用（determinism-neutral debug 檔，安全）**：`git -C .worktrees/survival-layer-unify checkout main -- scripts/debug/single_team_trace_bed.gd`（把工具拉進 branch worktree；此檔純觀測不影響 slice A 決策碼/determinism）。
跑法：`$env:SPECIMEN_TEAM_ID='14'; godot --path .worktrees/survival-layer-unify --headless --script scripts/debug/single_team_trace_bed.gd`（配 TRACE_SEED=1337）。leader traits 已在 SpecimenTracer dump（slice A 補）。

## 請補完（4 項，一次跑完一次回 blueprint）
1. **Team1/7/9/14 全滅死因**（★關鍵，可能是 attrition 沒全回落 main 的殘根）：各鎖一隊 trace，看死因——是**同型「求生封頂殘餘」**（層0 boost 為何沒救到它們？如 boost_fire 有觸發但仍死＝boost 量級/floor 不夠，或這些隊根本沒進 rank_scored 走別路徑）還是別的根（如真赤貧無錢無武器、或子隊/faction 路徑跳過層0）。分類回報。
2. **層4 鋸齒三態**：鎖 1-2 隻窮隊，看 food_days 是否還在 3 天線鋸齒（(a)消失/(b)變淺仍在/(c)如舊）——**直接回答層4 要不要補**。
3. **Team10/P25 活教材確認**：鎖 Team10（野心0.89 霸主），看 slice A 後是否從「覓食/建設抽搐」變「留夠口糧+野心發展+缺糧變賣武器+危急求生」的雄心開國之君（性格顯性化的旗艦樣本，前兩輪工具缺 incomplete）。
4. **determinism + 憲法閘複核**：release-gate 衛生（本輪改決策層非 site，前輪綠但未複核）——`seeded_warring reproducible` + `constitution_gate.gd` 各跑一次。

## 回報
一次完整信 `to:blueprint status:open`（供用戶醒來一次看全）：4 項結果 + 你對「Team1/7/9/14 死因＝attrition 殘根 vs 層4 vs 真赤貧」的初判。**別推 merge**（release=用戶 gate）。★寄件 open。可溯源：raw log 落地 `docs/measurements/2026-07-14-sliceA-incomplete-*`。
