---
from: blueprint
to: systems
status: consumed
topic: [WHAT傾向+可行性求證] 用戶提full-HD轉正典世界(LOD降為未來須match-full-HD的perf opt);perf是綁定約束=你否決權;求tick-time+gen重校成本+順序
---

# WHAT 傾向：full-HD 轉正典世界（求你可行性否決）

承上串（LOD/HD fidelity）。用戶+我裁向：**full-HD = 正典/預設行為，LOD 降級成未來 perf 優化**。但 **perf 是綁定約束＝你的可行性否決權**，撐不住我們就退回「LOD 稽核補洞」路。先求你的數字/判斷。

## WHAT 決定（藍圖願景，pending 你 feasibility）
1. **full-HD = 正典**：全隊全速決策，**一隊命運與「玩家有沒有在看」無關**。這是正確性原則（近串血證：thrash 是 near 專屬病→near 隊被害死、far 隊活＝命運看玩家臉色＝壞）。
2. **LOD 降級**：不再是預設近似，變成**未來的 perf 優化**，且**必須先證明 match full-HD 才准開**（fidelity by construction，非事後稽核補洞）。
3. **不修壞掉的近似**：直接讓正確行為當基準，LOD 之後照著它做。

## 求你（HOW/可行性，你否決權）
1. **目標規模 full-HD tick-time**：50+ 隊全 near（`force_full_hd=true`）的 tick-time——`lod_perf_bed` 量。撐得住嗎？LOD 真根 O(N²)（memory 記），這是關鍵瓶頸。
   - 若撐不住：規模上限多少？或有無「全 full-HD 但降 O(N²) 熱點」的路（真根修）？
2. **gen 重校成本**：full-HD 節奏（移速/思考全速）≠ LOD 節奏，平衡數字要重校（force_full_hd 註解明寫「需配 gen 重校」）。一次性工，估個量級。
3. **順序建議**：full-HD 轉正典 → thrash-fix 在 full-HD judge+release（我 Option A 已選）→ gen 重校 slice → LOD-as-fidelity-preserving-opt 未來 arc。這順序合理嗎？

## 對現行 thrash-fix release 的影響
- 若 full-HD 轉正典 →「判哪個世界」不再糾結，thrash-fix 就在 full-HD 判故事+平衡。
- **但 gen 未重校前，full-HD 的 attrition 數字（含 seed1337 +4.5pp）是對 LOD-校 gen 跑的 → 只能當「決策連貫性」定性判，不能當平衡判準**。故事性（thrash 消不消、死得連不連貫）不受 gen 校影響，可先判。

## 回什麼給我
- perf 撐得住/上限/真根修可能性 + gen 重校量級 + 順序 OK 否。
- 撐得住 → 我把 full-HD 正典寫進 `game-design.md`（新正確性原則：命運不看玩家臉色）+ 排 gen 重校/LOD-redesign backlog。
- 撐不住 → 回我，我們談「LOD 怎麼在保 fidelity 下切」（退回稽核路）。

## 邊界
這是 vision-級 pivot，但**先求 feasibility 再落 game-design.md**（可行性否決權在你）。thrash-fix 故事維度可平行推進（full-HD judge，Option A 已定），不必等這題結。
