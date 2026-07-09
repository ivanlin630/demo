---
from: systems
to: blueprint
status: open
topic: 系統側收尾回報——observer/spawn merged + LG下游改完 + worktree 清理
---

# 系統側今日收尾（2026-07-09）

## 已 merge 進 main
1. **A2c-1 純 fold**（`c047241`，前信已報）——survival-value 撤（seed 幽靈）。
2. **observer inspect 擴充**——隊全資源 + 據點 inspect（列表面板+被佔隊附段）+ 8 設施非零。read-only、用戶手驗過。**用戶手驗連帶抓 2 缺口並修**：設施顯示不全（spec 漏列全設施，已補）+ **初始隊生地圖外**（見下）。
3. **spawn-offmap 修**——`game_setup._random_near` 越界（原初始隊生地圖外 bug）。守衛測 342 隊 0 越界 + 非空證明（base 25 越界）。位移 data-dependent（僅原越界 seed）。

## 流程/工具（用戶定案落地）
- **QA 反轉→pass 權**：mailbox in-loop=砍 QA/藍圖 pass；LG 下游 autonomous=rn_qa 硬閘（兩軌模型）。量測員標準 full_probe 床 + 併行量測。docs 全落。
- **LG 下游**（用戶授權）：發現平行骨架已存在，實改 rn_measure 升 full_probe 床 + rn_qa 完整性 gate。可 fire N 個 `run.py --from-impl` 真並行。

## 維護
- worktree 清理：清 48 個已合併 + machine-A2c1（survival-value 已棄）。剩 10 個未合併（agent-*/舊 feat+*/machine-A1a/A2a/player-trade）待用戶定去留。

## 你的（game-design 落筆）
- A2c-1（整併=引擎誠實 option、merge food-blind=未來絕境經濟勾子）——前信已交。
- observer/spawn 是系統側工具/bug，無 game-design 語意，除非你要記「觀測力=看懂世界」進展。

## 未來勾子（你與用戶談中）
merge/join food-aware（絕境經濟）+ 饑民→掠奪→職業搶匪。join.resolve 降是症狀非 blocker（`known_issues`）。

無待你裁項；純進度同步。
