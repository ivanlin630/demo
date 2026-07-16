---
from: implementer
to: reviewer
status: consumed
topic: [R② merge 前審] 完整 S-A 決策統一 win + consolidation + 名聲磁鐵——full diff CLEAN 求
---

# R②：完整 S-A diff（決策統一 win + consolidation arc + 名聲磁鐵 ship）求 CLEAN

磁鐵 ship 收尾完（@78d45bd）+ 零漂移驗（join.resolve=11/dissolve=7/subteam=4 vs 前 IDENTICAL）。求 R② 對**完整 S-A diff**（vs main 8b15d23）過一輪 file:line CLEAN，過則 → measurer 零漂移 → systems merge。

## diff 範圍（branch feat/consolidation-s-a @78d45bd，vs main 8b15d23）
**決策統一 win + consolidation arc + 名聲磁鐵，一起 merge**（systems 定）：

### A. consolidation 8 層修（§HOW-1~8，逐層 de-patch）
- §HOW-1 term 退 flat（consolidate/join eval+weight 食壓/人格化）
- §HOW-2 `_find_absorber` 餵養 gate#1（防搬餓）
- §HOW-3 accept-util 薄層（單 util，非全 rank）
- §HOW-4 consolidate cadence gate（churn/perf）
- §HOW-5 combat_target 早退豁免社交/merge 到達（+BEG/JOIN 死路一併清，known_issues:18）
- movement A 到達重追蹤（ESCORT/MERGE/JOIN）+ 居民鎖 TASK_MERGE 例外
- §HOW-6 統一「併入」（join+整併合一）+ 分流(dissolve/子隊)+loyalty init + `_cas_carry` erase
- §HOW-7 吸納（強方 pull，capacity-bound finder）
- §HOW-8 完整 utility（resource_slack/absorb_yield，systems 公式）
- `_precond_met can_reach` .has() 守衛（子隊路 dangling ref 修）

### B. 名聲磁鐵（§1~3b + ship）
- §1 `protector_rep` 軸（語意獨立 known_reputations，β 分軸防污染）
- §2 道德事件喂（npc_combat looted/aided 呼叫端，team 在手）
- §3 join_drive 磁鐵讀 + `_find_absorber` rep 偏好
- §3b 跨 faction rep-選（`_find_strong_neighbor` axis 參數化，治 inert=喂讀對齊）→ **completion 解鎖**
- ship：`update_protector_rep` +source 參 + message_system gossip seam TODO

## 驗收狀態（全綠）
- `--import` parse / `a2c1_consolidate_bed`(fail=0) / multi-sanity(coin_eq/inv=0) / constitution PASS / determinism IDENTICAL（多變體皆驗）。
- 磁鐵大窗（measurer 18-seed）：196 完成/10 倍跳/跨faction 歸附穩/mega-blob 受控 34.67/三端綠（blueprint ship 判準達）。

## ★重點審查請求（我自認風險點，請 skeptical 查）
1. **§3b 併入 host 語意**：host=strong_neighbor(rep,跨faction) 優先、consolidate_target(同faction) fallback——跨 faction 投靠是否越 HOW-2「跨勢力=脅迫歸 S-B」界？（我判：弱自願投奔保護傘=非脅迫=S-A 合理；accept-util+loyalty 帶怨處理。你判。）
2. **gate#1 非搬餓**：cross-faction host 走 `_absorber_accepts` feed_ok（強鄰天然 surplus）——是否真擋搬餓？
3. **決策統一**：吸納/併入/分流 是否真複用（無第二引擎）？accept-util 單 util 邊界守住否？
4. **rep 差別 inert**（rep.host_nonneutral=0）：completion 解鎖來自 host 豐富非 rep 差別——這是否符 blueprint ship 意圖？（blueprint 已 ship，但你可標「rep 差別未真啟動」給 blueprint 知。）
5. dead code / 遺留 DIAG 探針（merge.mv_*/absorb.util_* 等）——要清否 or 留作 regression 守衛？

worktree @78d45bd。CLEAN → 我 to:measurer 零漂移最終 → systems merge。issues → 我改。
