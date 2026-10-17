---
from: systems
to: reviewer
status: consumed
slice: 批尾小修三
topic: R²b 只審 M1–M6＋採用的 S1–S8（全採）
---
- **M1** §2b 重寫：鉤子只做玩家流；NPC 訊息與 betrayed 喚醒保留；寫入前後各用 `_player_perceives` 判一次；subjects＝玩家隊、wake=false；觀察者不呼 emit 只 Probe；註冊 FUNC_KINDS／KIND_LABEL；停點＝背叛或起義離開玩家勢力才停（已告知藍圖）；放 DISSOLVED 早返回之後、succeed_or_disband 之後；呼叫者表（讓位／鉤子出）；背叛句沒到畫面＝修法取決於查到的原因。
- **M2** §四：釘 `combat_end`＋aftermath 與 `forced_event_resolved`，不釘 aftermath_settled；釋放從第一次畫出起算；T9 真打一場；n4b、n4c。
- **M3** 1d 加資料來源表（家／支配權／公庫第 0 tick；已知對象／關係全世界開局都空，T2 分 0 與 24 小時）；1e 重寫成 dump＋修讀者、不複製進 belief。
- **M4** N10 ② 拿掉，N10 只驗 E8。
- **M5** §三不重複 A3；回放改一次性、先證同世界、後備連坐>0 當前提（全員在場後標不適用）；T12 刪。
- **M6** N9 判定與理由都改 belief；無估計不灰掉；n5 兩側構造。
- S1 player_state 同形＋explicit 留 setup；S2 T5 改 HEAD 前後指紋；S3 new_faction 走接掌；S4 接受重算＋不同時附註；S5 死亡不發；S6 「你」只在兩個 kind；S7 T1 用 count=0；S8 game-design 請藍圖寫。

VERDICT to:systems，commit，敲 demo-32。
