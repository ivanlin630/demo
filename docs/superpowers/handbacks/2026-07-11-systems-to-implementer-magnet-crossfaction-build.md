---
from: systems
to: implementer
status: consumed
topic: [磁鐵修 開工] 跨faction rep-選(治inert)——finder參數化axis,兩JOIN點傳rep;R②三輪CLEAN
---

# 實作工單：跨 faction rep-磁鐵修（R② 三輪終 CLEAN）

spec `specs/2026-07-11-reputation-magnet-slice.md §3b`（R② 三輪過：根因修正 + 共用衝突參數化 + 呼叫點盤點）。**疊 worktree**（磁鐵 §1~3 已上、inert）。治 inert=喂-讀 pair 對齊（投奔護過我的保護傘）。

## 改（參數化 finder，非引新 finder/不碰 _find_absorber）
1. **`_find_strong_neighbor(state, team, axis: String = "pop")`**（`faction_ai:3238`）：
   - select（`:3253`）：`axis=="rep"` → argmax `protector_rep[tid]`（tie-break pop）；`axis=="pop"` → 原 best_pop（不變）。
   - 共用 filter/scan/reachability 全不動（跨 faction :3246 / 可達 / belief / 強度 / known_reputations>0.3 sanity）。
2. **★兩 JOIN 呼叫點都傳 `"rep"`**（reviewer 盤點，缺一則 gate/target 脫鉤）：
   - `decision_context.gd:170`（餵 has_strong_neighbor/strong_neighbor_id）→ 傳 `"rep"`。
   - `options.gd:174`（JOIN target 取值）→ 傳 `"rep"`。
3. **`_trigger_defection_evaluation`（`:3422`）維持 `"pop"`**（投降找強者，行為零變）。
4. context `best_protector_rep`（選中 host 的 protector_rep）供 §3.1 join_drive 磁鐵讀（喂-讀現同 pair）。

## 驗（measurer 磁鐵測，這次喂-讀對齊該活）
- **`rep.host_nonneutral>0`**（選中 host 的 protector_rep 脫 0.5）→ 磁鐵有差別。
- **弱隊投奔高 protector_rep 保護傘 dispatch/complete>0、聯邦成形**（核心假設）。
- 對照：defection(:3422) 行為零變（best_pop 不動）。
- 附：高名聲仁君 vs 低名聲暴君分化「自願聯邦 vs 征服帝國」。mega-blob 併隊數觀察。gate#1 非搬餓 + determinism + 三端不退化。
- 大窗 `godot-detach.ps1`+`WARRING_RESUME`；worktree rebase 最新 main。

## 決策樹（blueprint）
- 磁鐵動（聯邦成形）→ 回 blueprint → **S-B 完整政治值得建**。
- 不動（rep 高仍投靠輸逃）→ 回 blueprint 重估 weight 量級/卡點。

卡點 → to:systems（別猜別問 user）。merge 閘=reviewer diff CLEAN + measurer 磁鐵 to:blueprint。
