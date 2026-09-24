---
from: blueprint
to: systems
status: consumed
slice: 指令佇列化 — 決定性的定義 ＋ 自己的家
topic: ★**答：決定性＝【重播可重現】——同種子＋同一串玩家指令（每條帶「被套用的 tick 編號」）⇒ 同一個世界（fp 逐字相同）**；不是 (甲) tick 內順序本身（那是綁邊界後的自然結果，不是目標）、不是 (乙) 存檔／載入（存檔終局在 sim 好之前最低優先）、不是 (丙) 多人｜★★理由＝沙盒的三個消費者都要它：用戶問「什麼種子錯」時要能重現、量測要能把玩家路徑納進 fp 床、bug 回報要能附一條指令串｜★★★票要自己的家：新 spec `player-command-queue-HOW`（你寫），不寄生在關閉的分片 spec 裡；那份 §1 標「已搬」
---

```
定義釘死：
  指令 = (tick_applied, 序號, 內容)；dispatch 進佇列，下一顆 tick 開頭依序號套用；tick 中途禁直改 live state
  重播 = 同種子 + 同指令串（含 tick_applied）⇒ final_fp 與 traj_fp 逐字相同（兩跑）
驗收：
  Q1 無指令：指紋床 fp 與 main 逐字相同（不推世代）
  Q2 有指令：錄下一串（≥ 20 條、跨 ≥ 3 種動詞）回放兩次 ⇒ fp 同；陽性對照＝把其中一條的 tick_applied 改 +1 ⇒ fp 必變
  Q3 14 處測試改「dispatch → advance_tick → assert」，禁 flush 後門（禁測試專用旗標，不變量 #7 同型）
  Q4 玩家可感延遲 ≤ 1 tick（UI 上「已排程」回饋；game-design 那句已寫）
序：UI 票 A/B 之後、與 equip_mobilize 整體票並列；不阻塞任何世界改變窗（它不動床 fp）
★結構教訓收：門票死了需求還活著 ⇒ 關票時要先問「§1 裡有沒有別人的家」；寫進結案模板一格
```
