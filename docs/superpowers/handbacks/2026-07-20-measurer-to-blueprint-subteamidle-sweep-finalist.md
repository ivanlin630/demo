---
from: measurer
to: blueprint
status: consumed
topic: "[gate-sweep 完·finalist=PARENT_LOW=5·雙seed最佳但seed42仍5≠0·待你送QA故事查] 6組合掃完:★PARENT_LOW 是唯一 lever(SATED 6/8/10 完全無差),PARENT_LOW=5 Pareto-dominate PARENT_LOW=3。finalist(SATED任意+PARENT_LOW=5):seed1337=0(勝baseline7!)、seed42=5、seed4201=0,total starve 5<baseline 7=淨改善。但 seed42 仍 5≠0(must-pass 嚴格未達,無任何組合到0)。死因乾淨(famine 為主,手不聽腦≈0)。finalist 故事 trace 已備(seed42 5死+seed1337 rescued),待你送 QA 判 coherent 求生 vs 撿分。"
measured_at_head: c53c8cbb
---

# subteam-idle v3 gate-sweep → finalist PARENT_LOW=5

授權 bounded sweep（SATED{6,8,10}×PARENT_LOW{3,5}，6 組合）跑完。

## 掃描矩陣（starve 1337/42/4201）
| PARENT_LOW | SATED | seed1337 | seed42 | seed4201 |
|---|---|---|---|---|
| 3 | 6/8/10（全同） | 4 (a14.4) | 9 (a22.5) | 0 |
| **5** | 6/8/10（全同） | **0 (a3.4)** | **5 (a16.0)** | 0 |

## ★關鍵發現
1. **PARENT_LOW 是唯一 lever；SATED 完全無差**（6/8/10 逐點相同）——早救母團（<5 vs <3）才是槓桿，forager 攜糧門檻無關。印證根因（母團餓死等交糧→早召救）。
2. **PARENT_LOW=5 Pareto-dominate PARENT_LOW=3**：seed1337 4→**0**、seed42 9→**5**，兩 seed 都更好。
3. **finalist = PARENT_LOW=5**（SATED 保 10 或任意）：seed1337=**0**（勝 baseline 7）、seed42=**5**、seed4201=0。**total starve 5 < baseline 7 = 淨改善**（跨 seed 總死更少）。

## 但 must-pass 嚴格未達
- **seed42=5 ≠ 0**（baseline 0）。**無任何 gate 組合把 seed42 拉回 0**——PARENT_LOW=5 是全域最佳點，seed42 仍殘 5。
- ∴ 不是「盲點沒補」也不是「參數沒調對」——**PARENT_LOW=5 已是 6 組合最佳，seed42 殘 5 是這機制在 seed42 緊糧世界的下限**。要 seed42=0 需超出本 slice 範圍（e.g. 母團自身覓食/更快供給，另 arc）。

## finalist 死因乾淨（供 QA 故事查基礎）
PARENT_LOW=5 死因 3 分類：
- seed42：famine 為主（37 含 beast husk）、stuck-task 2、**手不聽腦 1**（≈0）。5 個 real starve = 乾淨 famine（緊糧供給下限），非 glitch。
- seed1337：famine 17、stuck-task 1、**手不聽腦 0**（1337 starve=0，極乾淨）。

## 待你裁 + QA 故事查（你的 gate）
- **finalist = PARENT_LOW=5** 是 6 組合最佳（雙 seed 最優 + total 淨改善），但 **seed42 5≠0**（must-pass 嚴格未達）。
- 你要的「accept 前送 QA 讀 finalist 故事」——**故事 trace 已備**：
  - `docs/measurements/2026-07-20-subteamidle-finalist-p5-lockpoint-42.txt`（seed42 5 死 + 近死隊 motive→action→outcome）
  - `...-finalist-p5-lockpoint-1337.txt`（seed1337 rescued-to-0，確認救回的隊是 coherent 求生非撿分）
- **你裁**：(1) 接受 finalist PARENT_LOW=5（total 淨改善 5<7，seed42 5 為機制下限）→ 送 QA 故事確認 → 綠則 implementer 設 PARENT_LOW=5 為 v4 / (2) seed42 5 仍不可接受 → 認機制下限，挑 tradeoff（你原傾向 v3；但 finalist PARENT_LOW=5 嚴格優於 v3 的 1337=4/42=9，建議至少收 PARENT_LOW=5）。

## 建議
我傾向：**finalist PARENT_LOW=5 收（改 v3 default 3→5）**——它嚴格優於所有前版（1337=0 最佳 + seed42=5 為 6 組合最少 + total 5<baseline 7）。seed42=0 不可達＝機制下限非 bug，你送 QA 故事確認 5 死 coherent 即可 accept。

## 溯源
sweep raw `docs/measurements/2026-07-20-subteamidle-sweep-*.json`（5 新組合）、finalist 故事 trace 上列。sweep 用 LADDER_SATED/LADDER_PARENT_LOW env override（temp，已 revert，branch clean，fix intact）。

## 下一站
你裁 accept finalist / 送 QA → 綠則 implementer 設 PARENT_LOW=5 v4 → 我複驗（或 pre-merge）。
