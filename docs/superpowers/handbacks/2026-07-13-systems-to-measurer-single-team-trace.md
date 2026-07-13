---
from: systems
to: measurer
status: open
topic: [量測·用戶請求] 單一代表隊3mo逐次task/option時間軸——用既有SpecimenTracer,無需implementer
---

# 量測：單隊 3mo 決策時間軸（用戶要看行為故事，非聚合）

用戶要親眼看**一支具體隊伍** 3 個月逐次 task/option 選擇時間軸（驗 §驗收① 行為連貫性——聚合數字驗不了搖擺）。**能力已在，無需 implementer 加 code**。

## 工具（既有 SpecimenTracer，純觀測零改決策）
- `state.specimen_team_ids = [<代表隊 id>]` + `SpecimenTracer.enabled = true` + `SpecimenTracer.reset()`（開場）。
- sim_runner 日邊界自動 `SpecimenTracer.flush()` → 印可讀 timeline（每決策一條：tick/想什麼 intent+candidates(opt,util)/做什麼 winner_opt+task+target）。
- 收尾 `SpecimenTracer.summary()`（想 vs 做 聚合）。
- 範本 `scripts/debug/specimen_bed.gd`（設 specimen + advance_tick 迴圈 + flush）；改跑 default.json warring/organic 3mo window（非 econ_bed 10 天）。

## 跑法
- **branch**：normalize branch **當前 committed HEAD**（T1-T4，**T5 在 implementer 手上未 committed → 跑 committed 態避 worktree 並發衝突**）。**明標「T1-T4 normalize 態,pre-T5」**（T5 會 lift 備戰/駐守/買糧/訓練→post-T5 可再撈一版對比）。
- **選隊**：seed1337，挑一支**非 owner、持續存活、有經歷波折**的代表隊（存活到 3mo 尾、經歷過缺糧/威脅/成長轉折佳）。列 team_id + 為何選它。
- **window**：3mo（≈90 日）。單隊 entries 量可控（每 cadence 一決策）。

## 出什麼（人類可讀 → 用戶）
逐日/逐次列表，格式如 blueprint 信範例：
```
day 1: 覓食 (intent=日常, util: 覓食0.9/生產0.4/...)
day 3: 建設
day 45: 攻擊 (intent=征服)
...
```
- 至少含 winner_opt 時間軸；能附 intent 轉折 + 關鍵 tick 的 candidates util 更佳。
- 標轉折點（缺糧→覓食期 / 成長→建設期 / 威脅→備戰逃期），佐證「有無計畫感/連貫 vs 搖擺」。

## 回報 → blueprint
可讀 timeline + 選隊理由 + pre-T5 標註 → handback to:blueprint（他轉用戶）。determinism 不涉（純觀測）。
