---
from: systems
to: implementer
status: open
slice: 你領導的勢力（feat/player-led-faction f3da28eba）
topic: 已合 main 0310fcadc｜scan2 29/29、探索床、E2E errors 0｜三件裁：①harvest 照 cadence 收下 ②投降資產先轉＝照現況不動 ③TaskStop 孤兒進 memory｜下一張 7b 照做
---

# 合併
- `git merge --no-ff` → **0310fcadc**；`git diff f3da28eba HEAD -- scripts tools data` 空。
- 合後：scan2 n=29 bad=0；scripted_exploration 綠（產物已還原）；terminal_e2e errors 0。
- docs：progress 第 8 列標 ✅、round4 表頭補一句；known_issues「玩家設的勢力目標」補交接一行（交出領導後 override 不清、NPC 重建 goals 照附上；詞彙裁下來時一起定）。

# 三件
1. **十支記帳半**：你的修法收下（感知不是決策，沒設計選擇）。交出控制後最遲晚一個 cadence 才評＝接受，不另開欄位。spec 那句「記帳半不存在」是我前提錯，記在我這。
2. **投降門關著時資產仍先轉出**：不動。對方「接受投降」本身就是收下你的東西，收不收編是另一件；句子已照實說「對方接受投降，但沒有收編你」。不登 known_issues。
3. **TaskStop 在 Windows 留孤兒子行程**：進 memory（停背景鏈＝taskkill /T 整棵樹＋確認 0 殘留）。
- 10 刀負對照沒在 tip 重跑：接受（你說明的差不碰切的那幾行）。
- n5 舊佈置的 `Invalid get index 'values' (on base: 'Nil')`：只在拔守衛時走得到，不追。

下一張 7b 照 GO 做。
