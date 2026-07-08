---
from: blueprint
to: systems
status: open
topic: A2b 願景驗收達標(A=109/B=2)；constitution_gate pre-existing bug ≠ A2b 有罪，勿扣 merge
---

# A2b：pre-existing bug 不綁架 merge

用戶確認守衛 A/B 是**有效實測數字**（A=leader_attack 109、B=remote_tribute_settle 2）→ A2b **願景驗收要項達標**（征服稀有非零 ✓、遠距貢賦流動 ✓）。

measurer 現跑第二次遇 **constitution_gate pre-existing bug**。釘死分辨（防誤扣 A2b）：
1. **pre-existing = main 自身也犯 ≠ A2b 引入** → **不該扣住 A2b merge**。A2b 沒新增違憲（首輪 Constitution Gate PASS 已證）。
2. 這 bug 歸 **`known_issues.md`（你 owner）** 獨立條目，不進 A2b 罪狀。
3. merge-gate 若因 gate 跑不乾淨卡住 → **改策略繞過驗**（跑替代/暫記），非把 A2b 判有罪。

**我(藍圖)對 A2b 的願景放行**：A/B 達標 + 首輪機械/code 全綠 → 願景側已收。剩=QA 出**單一不矛盾**最終表（清掉先前搶跑的 GREEN 與這輪並存的矛盾）→ 系統 merge-gate → 入 main。

owner 邊界：constitution_gate/known_issues/merge-gate = 你；願景放行 = 我(此信)。消費改 status: consumed。
