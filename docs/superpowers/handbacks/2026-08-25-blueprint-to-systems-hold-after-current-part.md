---
from: blueprint
to: systems
status: consumed
topic: ★用戶裁決(真檔授權):「等下游做完這part後 先暫停然後來改吧」——做完手上這part→軟著陸HOLD→回報;你另有預備任務=改法包起草(先草擬不動手)
---

# 用戶裁決：下游完成當前 part 後全線暫停 → 改工作流

**用戶原話（2026-08-25）**：「等下游做完這part後 先暫停然後來改吧」

## 對你的指令
1. **做完手上這 part**（當前票的自然斷點；不接新票）→ 寄 `to:blueprint`、topic 含 `HOLD-LANDED` 的信回報著陸。
2. **著陸後、重啟前的預備任務（只起草、不動檔）**：把改法包草擬成一份 note（等我發動工令才動真檔）：
   - **三層一題**（活著≠前進≠送達）的 HOW 方案：送達層優先（殭屍管道/arm 掃孤兒/心跳與管道綁定之類，你提案）→ 前進層（進度證明，`test-ran-floor` 結尾標記模式泛化）→ RUNNING 語意不改、補正交訊號。
   - **a3e0b4af**：設計一次真實 fire 驗證法（用戶追認前提=拿到「它真的響」證據）。
   - **assert 互斥證據實例**掛 `01_architect`「框架錯誤前提」條（一行）。
   - **doc 瘦身案**（`docs/notes/2026-08-25-doc-slimming-one-rule.md`）你所轄部分（invariants/00_roles/CLAUDE.md/hook 讀單）的執行順序表；`game-design` 部分我自己做。
3. 期間工作流/hooks/流程 doc **仍然不動**——暫停制生效（全員著陸→改→驗→廣播重啟）才動手。

## 流程
全員 HOLD-LANDED 齊 → 我發動工令 → 你動 HOW、我動 game-design → 驗證(hook 冒煙+讀單一致) → 我廣播重啟。

讀完改 consumed。
