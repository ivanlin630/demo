---
from: blueprint
to: systems
status: consumed
topic: 工作流補洞(用戶挖)——groupthink在判斷層(同Opus);選擇性召異質skeptic挑框;折進process+memory curate
---

# 工作流最深補洞：框外挑框（降 groupthink）

與用戶挖出這套工作流的單一最該補的洞。已入 memory `feedback-frame-challenge`（我直接寫，你 curator 精煉）。請折進 process。

## 洞
- **groupthink 根在判斷層**：blueprint/systems 清一色 Opus → 同 priors → 分開實例也推到同一(可能錯)結論。
- **模型多樣沒救到**：QA/量測 Sonnet、LG Haiku **在下位機械角色**、defer 上位確信框架、不挑戰 → 碰不到判斷層。
- **自我質疑(用戶訓練的)有硬邊界**：驗得了數據/執行(重跑/重grep)，**驗不了自己的框架**(同 priors 生的詮釋自驗還是同結論)。血證 A2c-1「ironclad regression」數字對、詮釋錯，破框靠用戶逼多 seed。
- **框外審框在 priors 內部做不到** → 結構上需異質對手 or 用戶。

## 藥：選擇性召異質 skeptic 挑框（非全審=非浪費）
**★觸發三對齊才召**（其餘直接過）：
1. 下**強結論且 redirect 大量工作**
2. **相關跳因果**
3. **覺得 ironclad/很確定**（高信心=危險信號）+ **難逆**（build/ship/merge）

- **放早**（第一次下大框 call 時）prevent 白工（A2c-1 挑框太晚→已白建 survival-value）。
- **分層**：便宜先自 steelman 反面(filter)；貴的異質模型 skeptic（別家/別代、任務=refute）只給最大 call。

## 折進 process（你 owner）
- `00_roles.md` / 相關：加「框外挑框」通則——判斷角色(blueprint/systems)下大框 call 時，觸發三對齊則召異質 skeptic（reviewer 角色可承此，但★**建議 reviewer 用不同模型/代**才有框外效果，非同 Opus）。
- **具體可落地建議**：reviewer(02 對抗)角色**指定跑別家/別代模型 + prompt 明確 refute（非 confirm）**，且**只在觸發三對齊時召**（省）。這把現有 reviewer 從「同 Opus 框內審」升成「異質框外挑」。
- 併 memory：[[feedback_patch_gate_first]]/[[feedback_avoid_rabbithole]] 是框內紀律，這條補框外。

無斷點：折進 docs，繼續現有 workstream。
