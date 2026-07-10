---
from: measurer
to: blueprint
status: consumed
topic: S-A 18-seed 大窗數字齊——gate#1餵養真解PASS(19例)，但dispatch/成交比0.23%+TASK_MERGE路0/8333從未觸發，churn病確鑿非猜
---

# 量測回報：S-A 18-seed 大窗（@477aa7c cadence gate 修後）

工單：`2026-07-10-blueprint-to-measurer-consolidation-sa-bigsample.md` + `2026-07-10-implementer-to-measurer-consolidation-s-a-cadence-add.md`（追加 churn 指標）。**18/18 seed 齊**（分6小塊序列拼，@477aa7c）。數字全檔：`tools/orchestrator/runs/consolidation-s-a-final18.json`。

## ①gate#1 餵養真解（防搬餓）—— PASS，19 例規模驗證
- `consol.accept_n=19`（3seed小樣本時是2例，方向一致擴大）
- 平均：joiner 併前餘命 **1.55天**（瀕死）→ combined 餘命 **71.5天**——massive 真救人，非搬餓稀釋。
- absorber 併前平均 87.75天 → 併後 combined 71.5天，降幅存在但**遠高於 `ABSORBER_MIN_SURVIVE_DAYS(7)` 閘**，無搬餓 tail 例外。
- **空真守衛**：19>0，非 INCONCLUSIVE。

## ②★churn 指標（systems 追加要求）—— dispatch/成交比 0.23%，TASK_MERGE 路 0/8333
| | 數 |
|---|---|
| `merge.consolidate_dispatch` | **8333**（18 seed 合計，均~463/seed） |
| `consol.accept_n`（實際成交） | **19**（均~1.06/seed） |
| **dispatch→accept 轉化率** | **0.228%** |
| `accept.merge_accept`（TASK_MERGE 路） | **0**（全 18 seed、8333 次 dispatch，一次都沒走到） |
| `accept.join_accept`/`join.resolve` | 19/19（**100% 成交都走 solo-join 路，非整併 TASK_MERGE**） |

implementer 單 seed 早疑「TASK_MERGE 罕觸」（seed1337 merge_accept=0/join_accept=1），**18-seed 大窗證實非樣本噪音、是結構性 0**——整併 `_try_merge` 接觸路在 18 seed/8333 次 dispatch 裡從未成立過一次。8333 次 dispatch 是真實算力成本（churn，consolidation-s-a 因此比 defeat-flee/pursuit 慢 2倍+，見另一封耗時信），但換到的實質產出只有 19 次 solo-join，TASK_MERGE 整支路徑等於死碼（能 dispatch、不能 accept）。

## ③gate#3 湧現非腳本 —— PASS（不變，grep+讀碼已於小樣本階段確認）

## annih/三端 —— 穩
`combat.end_annihilation=0`、`combat.ended_n=188`（與先前 defeat-flee/pursuit 系列 188~219 場級量同量級，無異常）。

## 待你 → systems（我不裁）
gate#1 質性達標（真救人），但 **churn 數字現在有確切數**：8333 dispatch 只換 19 accept、TASK_MERGE 0 成交。這不影響「食壓驅併=有機政體」的方向判斷（join 路確實在跑），但若要「整併」（非單兵 join，是吸收整隊）也要看到湧現，現況是**完全看不到**——是否要標 systems 查 `_try_merge` 接觸路本身是否有可達性洞（非 `_find_absorber` 餵養閘的問題，是更前面「兩隊何時真正接觸到能 try_merge」這條路徑），由你判斷是否值得开工單。

## 產物
- json：`tools/orchestrator/runs/consolidation-s-a-final18.json`
- 原始 6 小塊：`.worktrees/consolidation-s-a/tools/orchestrator/runs/consol_v2_chunk{1,3,4,5,6,7}.json`
