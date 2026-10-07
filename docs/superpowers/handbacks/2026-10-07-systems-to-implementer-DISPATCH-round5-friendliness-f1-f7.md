---
from: systems
to: implementer
status: open
slice: 第五輪友善度 F1–F7（R² 全 CLEAN：F1–F6 448398660 前後輪、F7 三輪至 05fc19e82）
topic: spec docs/superpowers/specs/2026-10-07-round5-friendliness-convergence-HOW.md 全文｜序＝你手上排在前面的票做完之後｜★F7 裡「據點間距 2／11」那條不做（等藍圖再裁），其餘照做
---

# 範圍
```
F1 開場三行｜F2 能做的排前、不可的折疊（鍵號不漂移，不變量 #10）｜F3 原因盤點（disabled_reason＋precheck_*＋inquiry 三種收成一欄）
F4 各模式鍵處理表同一份（_mode_binds_key）｜F5 play.py 單鍵即時輸入（Ctrl+C 走既有 QUIT_TOKEN）｜F6 資料／排版拆刀
F7 游標處明細一行：只讀附身者知識；紮營被擋原因句走 _distance_blockers（一支來源，_check_distance 改成它 is_empty()）＋逐筆比 known_outposts 的 tile_pos，擁有者用 belief 那筆
```
# 不做
```
✘ 據點間距規則（L0／L1、2／11）——前提對不上，已回藍圖（c49ddd504）；precheck_camp 的間距條件照今天
✘ 紮營被擋寫弱 belief（併進糧源情報 kind 那張）
```
# 交件
```
P5d 兩個終端人工實按結果貼信裡（R² 明說讀碼答不出）
P7／P7b（純重構 fp 不變＋bool 與 is_empty 逐格一致）／易主那格
world-fp：F1–F6 純 UI 預期不變、F7 重構預期不變 ⇒ 先量，變了才換，沒變就不要動並寫為何
全電池 BATTERY_RC=0、已知紅排除: 0；遠端 tip sha
```

# ★追加（2026-10-07，R² 全 CLEAN 至 9440615ac）：F7b 與 F8 併入本批
```
F7b 選中區塊同游標處規則（視野內真值／記得的格只印地形＋「糧量：未記錄」／沒去過）＋P7c
F8 玩家紮營＝L0（呼 establish_crude_camp）、紮根＝新動作（共用 NPC 紮根落地段、施工中不可重按）、四寫入點同呼 _distance_blockers(tier)、營地欄（家欄不動）＋P8a–g
⇒ 上面「不做：據點間距規則」那條作廢；F8 照 spec 做
```

# ★追加二（2026-10-07，R² CLEAN ed7b0c0be）：F8 換成第三版
```
用戶裁：據點間距（2／11，含 NPC 選址 faction_ai:5960 min_dist）與山地禁紮整條退場，只留「同格已有」
⇒ F8 照 spec 現行全文做（整節改寫過）；F7 的 _distance_blockers／known_outposts 比對作廢；「追加」那段裡「四寫入點同呼 _distance_blockers(tier)」作廢
P8g 報告逐字印 mountain_camp_survived_days: <最大天數>（defer 讀它）
```
