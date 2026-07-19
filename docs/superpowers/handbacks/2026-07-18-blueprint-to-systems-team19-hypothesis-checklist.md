---
from: blueprint
to: systems
status: consumed
topic: "[trace checklist·team19 decision≠task 別鎖latch] 原始事實只有『決策=survival/任務=安頓/不在戰鬥』。5類機制各fix不同,trace要定位是哪個非確認眼熟的:A選項落不了地(無目標/路不通→skip→維持舊task) B優先序/latch擋(舊settle優先太高 or settle承諾型永不完成鎖死) C控制流早return(dispatch前return) D多頭desync(survival latch/主rank/threat不同權威,QA讀的欄非驅動task的欄) E★probe誤讀(count剛被證灌水=同probe,先驗這條讀數真不真)。★E優先:probe剛誤分類4隊,別在假數據診斷。別預設逆向arc回歸=latch,那只是5選1。"
---

# trace checklist：team19「決策≠任務」別一頭栽進 latch

## 原始事實（只有這些，其餘都是詮釋）
team19：**決策欄=survival、任務欄=安頓、combat_target=-1（不在戰鬥）**，持續 4+ tick。QA 標「手不聽腦」= 症狀標籤，非坐實機制。

## 5 類機制，各 fix 完全不同——trace 要「定位哪個」非「確認眼熟的」
- **A 選項落不了地**：survival 選項（覓食/買糧/投靠）算出無可執行目標（belief 位置未知/附近無糧/target=(-1,-1)）or 路徑走不到 → skip → 維持舊 task。**fix=補目標解析/絕境 fallback，非動 arbiter。**
- **B 優先序/latch 擋切換**：舊「安頓」優先序太高 → survival try_set 被拒；or 安頓是承諾型/不可中斷任務且**永不完成** → 鎖死。**fix=arbiter/task-completion，這才是真「手不聽腦」。**
- **C 控制流早 return**：`_decide_unified` 在 survival dispatch 前 early-return（歷史有 faction_ai:1485 算完不執行前科）。**fix=控制流。**
- **D 多頭 desync**：survival latch / 主 rank / threat 不同權威並跑，**QA 讀的「決策」欄可能是諮詢性、非驅動 task 的權威欄** → 兩者脫節。**fix=釐清權威單一性。**
- **E ★probe 誤讀**：count 剛被證灌水（4 隊誤標餓死）= **同一 probe**。「決策=survival / 任務=安頓」這讀數**本身可能誤/過期**。

## ★執行序：E 先
**先驗 probe 這條讀數真不真**（決策欄與任務欄是不是即時、正確配對讀的）——**別在假數據上診斷機制**。probe 剛剛才把 4 隊誤分類，這條讀數同源，可信度未證。probe 過關，才往 A-D 逐一排除。

## 別預設
**別假設「手不聽腦 = latch = 逆向工程 arc 回歸」**——那只是 B，5 選 1。逆向 arc 修的是已知路徑，team19 可能是 A/C/D/E 任一。trace 定位到哪個欄在哪個 tick 是什麼值，再說。

## 溯源
QA seed1337 story-verdict（team19 決策≠任務原始 trace）；[[feedback_symptom_vs_root_retry]] 症狀vs根；[[feedback_fileline_vs_interpretation]] 事實vs詮釋；[[project_reverse_engineering_arc]]（別預設回歸）；probe 灌水（QA 同封）。
