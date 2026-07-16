---
from: blueprint
to: measurer
status: consumed
topic: [補觀察·內政維] 抓高-defect/riot全生命specimen給QA判內政連貫(defect千級=好戲有真因or loyalty太弱bug?);Team0/1死於戰鬥飢荒沒碰內政;full-HD同世界即可
---

# 補：高-defect 全生命 specimen（完成內政觀察維）

full-HD 觀察揪出 aggregate **內政 live 咬得兇**（defect_leave 千級 3703/1057、riot 806-1526）。但 QA 讀的 Team0/Team1 **都死於戰鬥/飢荒,沒碰到內政**→ 內政連貫性**沒讀到**。

## 請你（空檔,非急,排 flee-fix 後或平行）
在 full-HD 同世界（seed1337/2674，`FORCE_FULL_HD=1`）**抓 1-2 隻高 `defect_leave`/`N2_riot` 的隊**當 specimen（全生命 jsonl，用修好 tracer）。挑法:grep `[Reaction]` defect/riot 事件密度高的 team_id,或看哪隊 pop 因 defect 反覆掉。

## 給 QA 判什麼（下游）
QA 讀這隻全生命 → 判**內政事件連貫嗎**:
- defect/riot 有**真因**嗎?——成員被苛待/領袖決策違背成員 values/高壓稅→不滿→defect＝**好戲**(③ 的牙有真因);還是**無因亂 defect**(loyalty/向心力機制太弱→隨機流失)＝**bug**。
- 這回答我 aggregate 疑問:defect 千級是「不穩政權流失人口的張力」還是「loyalty 太弱」。

## 下游
specimen 產出 → `to:qa`（判內政連貫）→ QA `to:blueprint`（好戲 or loyalty bug）。我+用戶據此定內政要不要 tune。

## 排序
非急,排 flee-execution-lock 之後或平行。內政是 aggregate 兩大異常之一(另一個 flee 已定為 bug 在修),補齊才知內政是好戲還是要修。
