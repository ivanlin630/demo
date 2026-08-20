# 07_orchestrator_machine.md — langgraph 編排機器（**設計背景**；操作看 08）

> **定位**：本 doc ＝ **為什麼是這台機器**的設計理由與**自主邊界裁定**。
> **操作/現行流程 → `08_machine_workflow_v2.md`**；**實作權威 → `tools/orchestrator/`（`run.py` / `real_nodes.py` / `graph.py`）**——節點圖、每節點契約、state 物件、durability、落地步驟**以 code 為準**（doc 重述會 drift，已於 2026-08-21 瘦身移除；歷史全文見 git log）。
> **現況**：軌**可用但少用**（`CLAUDE.md:72`：只大/並行活才上）。

## 為何是這台（三約束同時滿足）
| 約束 | 怎麼滿足 |
|---|---|
| **durable**（停不死，非 subagent-death） | state 全在 **git**（handback+commit）；langgraph **checkpoint** 存位置；node 撞上限 → 從 checkpoint resume |
| **乾淨 context**（角色不互污） | 每 node ＝ 全新 headless `claude -p`，只載自己 role + 相關 handback |
| **無人肉 relay** | edge 自動觸發下一 node；用戶只在 interrupt 點回來 |

★**核心原則：流程 ＝ graph 強制節點，不是 doc 建議**（doc 會腐、graph 不會——05/06 腐爛教訓）。
★**subagent 穩定性碰不到專案**：node 只讀/寫**已 commit 的 git 狀態**，死了 ＝ 無害重跑。

## 自主邊界（B→C 漸進；用戶定案 2026-07-07）
**終態 ＝ C（每 arc 全自動），但漸進掙來**：第一個 arc 用 **B**（merge 前煞車）→ 機器證明會抓東西後才升 C。
★**C 從設計就是「可觀測 + 隨時可插手」，不是黑箱丟出去**。**三道防瞎跑**：
1. **02 逼 reframe 到前面**——設計不健全（含閉迴路）在 arc 開頭審就現形，不拖到中途。
2. **surprise-interrupt 節點**——任何**前提矛盾**（fact-check 打臉／QA red 暗示方向錯／審查者報違反原則）→ **自動暫停回用戶**，不硬闖。
3. **可觀測 + 隨時 interrupt**——串流每節點 verdict/metrics；用戶可隨時 interrupt → checkpoint 暫停 → 塞新 brief → resume。
★**自動 ≠ 瞎；省的是 relay 雜務，非知情權。**
★**誠實殘餘**：需要人直覺、但**不觸發矛盾偵測器**的 reframe，只有用戶在看時才浮 → **可觀測性 ＝ 安全網，非自動化能取代**。

## 流程自量表（解「某節點值不值」）
每 node 落 `docs/process/metrics.jsonl`：`{slice, node, verdict, found_issue, wall_clock}`。
★**累積命中率 → 用數據裁該不該留該節點，不猜**（對抗①近免費常開；對抗②掛 log，~10 slice 空手 → 砍）。
