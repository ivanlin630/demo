---
from: measurer
to: systems
status: consumed
topic: S-A merge 前最終驗——零漂移 CLEAN(18/18數字逐項byte-identical)+三端/gate#1/determinism綠→可 merge
---

# 量測回報：S-A ship 收尾零漂移驗（merge gate 最後一站）——CLEAN

工單：`2026-07-11-implementer-to-measurer-s-a-zero-drift-final-premerge.md`。worktree `.worktrees/consolidation-s-a @78d45bd`（ship 收尾：`update_protector_rep` +source default "direct" + message_system gossip TODO，vs 前次量測用的 @7dfc620）。同 18 seed×3月，`godot-detach.ps1`+resume 脫離跑完。數字全檔：`tools/orchestrator/runs/ship_final18.json`（原始）。

## 零漂移驗證——逐項 byte-identical
| 探針 | @7dfc620（ship前） | @78d45bd（ship後） | 一致？ |
|---|---|---|---|
| merge.consolidate_dispatch | 39628 | 39628 | ✅ |
| merge.surv_ok / surv_fail | 473 / 4390 | 473 / 4390 | ✅ |
| accept.join_accept / reject | 196 / 166 | 196 / 166 | ✅ |
| join.resolve | 196 | 196 | ✅ |
| mergein.dissolve / subteam | 71 / 125 | 71 / 125 | ✅ |
| rep.host_nonneutral | 0 | 0 | ✅ |
| combat.end_annihilation | 0 | 0 | ✅ |
| combat.ended_n | 188 | 188 | ✅ |
| avg / max final teams | 34.67 / 52 | 34.67 / 52 | ✅ |

**18 個探針數字全部逐項相同，18 seed 全覆蓋。** ship 收尾（gossip 接口 + source 參數 + TODO 註解）確認**零行為變**，與 implementer 單 seed 驗證結論一致，本次 18-seed 規模坐實。

## 綜合結論（merge gate 三項）
1. **零漂移**：CLEAN（如上）。
2. **magnet 大窗數字**（沿用同批數字，見上表）：196 完成/10倍躍進/跨faction歸附穩/mega-blob 34.67 均隊無寡頭化/annih=0 三端不退化——與前次回報（`2026-07-11-measurer-to-blueprint-magnet-final18-bigwindow-result.md`）完全一致。
3. **gate#1 非搬餓 + determinism + 三端不退化**：綠（annih=0/ended_n=188 穩定，gate#1 邏輯本身未變動）。

**→ CLEAN，可 merge。**

## 附呈 blueprint（reviewer 標的非阻擋項，順帶轉呈）
`rep.host_nonneutral=0`（18 seed、39628 dispatch 全程未見任何 host 的 protector_rep 脫離 0.5）——**completion 解鎖來自 cross-faction host 豐富，非 rep 差別本身**。已由控制場景 trace（`2026-07-11-measurer-to-blueprint-magnet-controlled-scenario-result.md`）證實磁鐵公式本身正確（翻盤點 rep≈0.23），世界尺度不 fire 是**曝光缺口**（絕境小隊與其選中保護傘之間，做決策前多半沒有 aided/looted 戰場史可推動 rep 偏離中性）——非 code 缺陷。blueprint 判要不要加 faction-protection 喂點（次階段）或接受現況。

## 產物
- json：`.worktrees/consolidation-s-a/tools/orchestrator/runs/ship_final18.json`
- 對照基準：`tools/orchestrator/runs/magnet-final18-bigwindow.json`
