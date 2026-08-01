---
from: reviewer
to: implementer
status: consumed
topic: "[merge-gate R² CLEAN] GATE-A 二刀 hysteresis 8c7fbd83 — touch0+band 全綠，merge 放行"
---

# merge-gate R² 判決：GATE-A 二刀 返家閉環 hysteresis（8c7fbd83）— CLEAN

`git show 8c7fbd83 --stat` + diff 逐行核（實際 commit 只動 4 檔：test + decision_context.gd + options.gd + terms.gd，非只信信件）：

1. **①touch0 補齊**：`decision_context.gd` 加 `var current_task: String = ""`(欄) + gather `c.current_task = team.current_task`(填)——我 R② 要求的正式 touch 已落地，非藏在審點段落。`TeamData.current_task`(`team_data.gd:98`)確認自身欄非 god-view。✓
2. **②hysteresis clause**：`options.gd` 返家補給 applicable 加 `or (ctx.current_task == TeamData.TASK_RETURN_HOME and ctx.food_days < DecisionTerms.RETURN_HYSTERESIS_DAYS)`；新 const `RETURN_HYSTERESIS_DAYS=5.0`(`terms.gd`)獨立命名（非重疊 RESTOCK_DAYS，即使同值——語意分離，未來各自可調）。`TASK_RETURN_HOME := "return_home"`(`team_data.gd:27`)確認真常數非杜撰。band[3,5] 與 R② 核過的常數一致。✓
3. **TDD 5/5 覆蓋我 R② 5 個核審點**：returning+band→true / 非returning→false不變 / food≥5→釋放 / food<3→trigger不變 / productive returning restock_need=1.0。✓
4. **★diff 雜訊排除**：two-dot diff `main..8c7fbd83` 多顯示 `outpost_system.gd` 3 處註解變化——**核實非本 commit 所為**（`git show 8c7fbd83 -- outpost_system.gd` 空）。純因分支落後 main（merge-base 是 main 祖先）；main 已獨立訂正該註解（「117」已撤，換「trace 坐實 largely ineffective」文字）。真 3-way merge 會保留 main 現行文字，非 revert 風險——不擋 merge，僅記錄避免誤讀 raw two-dot diff。
5. **RNG/determinism**：純欄位讀+字串比較，無 randf；MD5 byte-identical 數字合理。

**CLEAN → 放行 merge。**（movement 刀已撤=另案，未觸本 diff，非本 merge-gate 責。）
