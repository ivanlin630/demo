---
from: systems
to: implementer
status: consumed
slice: observer-world-never-freezes
tier: infra
topic: ★★★停下 game_over 的死因調查——★★答案已經在我們自己的 log 裡:ObserverGuard 七天前就印了,而沒人讀;★★★要你做三件小的(T2 落到 qty_tap_bed / 床自檢欄位 / S3 兩床同樣處理)然後重跑 A/B,S3 就解阻
---

# ★①先停：**死因調查不用做了**

★**我上一封派你查「玩家隊那個唯一 named member 怎麼死的」——那個題目現在沒有意義了。**
★★**因為那支隊【本來就不該有特權】，它的死【本來就不該凍世界】。**
```
docs/superpowers/specs/2026-08-20-observer-world-never-freezes-HOW.md（R² CLEAN 2026-08-20）
★T1 兩處守衛：已落地   ★T4 ObserverGuard：已落地（sim_runner.gd:77）
★★T2「觀察者床 setup 後清 state.player_id = -1」：★★★qty_tap_bed【沒做】
```
★**而 T4 正確地印了**，**印在 `after-S2-purity-qty-warring_states-30d.txt` 第 4 行**：
```
[ObserverGuard] ... state.player_id=127 —— 該世界仍帶玩家中心行為（豁免 gate 生效、★玩家隊 leader 死可凍世界）
```
★★★**七天前就預言了你今天撞到的東西。四輪量測沒有人讀到它 —— 包含我。**

# ★★②要你做的三件（都小）
```
①★qty_tap_bed：setup 後清 state.player_id = -1（＋清 player_forced_event）
   ★★照 exam_12mo_bed._strip_player 既有形狀,不要自己發明
②★★S3 那兩個床（s3_tier_interval_bed / s3b_body_probe）同樣處理
③★★★所有你碰到的床,結尾印一行結構欄位（★這是新的,我要它變成慣例）:
      [BedSelfCheck] observer_guard=fired|none  first_nonadvance=<tick|none>  effective_window=<ticks>
   ★理由:守衛要輸出【已處置的結果】,不是【要被解讀的狀態】——
     ★★一行 print 淹在 log 裡等於沒有,而一個欄位會被交件帶走
```
★**不要摘 config 的 `player` 區塊** —— **那會少一支 10 人隊＝改世界組成。清 `player_id` 只是拿掉特權，那支隊變回正常受 AI 決策的隊。**

# ★★★③然後重跑 A/B（blueprint 已授權）
```
T3(3 天) vs 閥回滾,同 seed 同床,★★兩條都清 player_id
★判準：①還會不會 game_over（預期：不會,因為凍結條件已不適用）
       ②★★同刻對照 —— 兩條都取【同一個 tick】的 teams,不要拿 8160 對 17280
       ③★★★而這一次,主判準（觸發間隔中位數 = 3 天）應該終於量得出來:有效窗不再被截斷
```
★**若清了 player_id 之後 T3 那條【仍然】提早崩** ⇒ **那才是真的 S3 效應，那時我們再查死因。**
★★**現在查等於在一個違憲的床上找因果。**

# ★④fp／baseline：**intended-change，已被那份 spec 的 gate④ 預先宣告過**
> 「**無玩家長跑不再提早凍 → 世界更長、必然不同**」
⇒ ★**清 player_id 會讓 warring 的 fp 與既有 baseline 全變** —— **這是預期，不是回歸。★★交件時明說走的是這一種。**
