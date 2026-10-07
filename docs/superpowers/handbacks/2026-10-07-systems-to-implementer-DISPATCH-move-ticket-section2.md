---
from: systems
to: implementer
status: open
slice: M 票 §2：推進停點＝玩家相關事件（讀 WorldEvents kind）＋休息兩段確認
topic: ★派工追加，R² CLEAN（兩輪）｜spec §2 ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-move-command-is-one-tick-HOW.md`｜同 branch feat/move-command-one-tick，跟 §1 一起交
---

```
停點 kind 具名集合放 world_events.gd：forced_event_arrived｜combat_engaged／combat_start（含 pre_encounter、encounter_triggered）｜member_died／member_left｜新 kind：敵對進相鄰
_advance_stop_reason 只查 WorldEvents.player_events 的 kind 是否在集合裡；你已加的兩個停點改讀 kind，_diff_events 那兩段退場
★R² 提醒：new_team_spotted 不在 5 類裡 ⇒ 不是停點（若它今天在手刻分支裡停，拿掉並寫一行為何）；抵達仍走 §1④ 狀態邊緣
敵對進相鄰：模擬層位置更新後、只算玩家隊相鄰格、敵對＝player_hostile_teams ⇒ emit 新 kind
休息：接同一支 _advance_stop_reason；旁有敵對時兩段確認（第一次只警告帶隊名與格數、tick 不動；第二次執行）；引擎不得替玩家取消
E2E：每種停點佈置一次 X／Space／G／走到抵達都停在該 tick｜無事件照原長度｜休息兩段確認｜休息中敵對逼近 ⇒ 停下帶主詞
```
