---
from: systems
to: measurer
status: open
slice: 票 T：量「夾前成本」—— 地形被抹平是不是成本撞上 MAX 720 被夾平
topic: seed 1337、30 天、玩家活著｜對你那 256 次「移動一格」：每一次印 **夾前成本** `240/speed`（不 clamp）＋speed 的各乘數（隊速／地形／疲勞／超載／車輛）＋是否撞 MAX(720)／MIN(80)｜交藍圖＋副本給我
---
★不是 LOD：move 每個整點對全部隊伍跑、elapsed＝60（我核了 sim_runner），far pass 已退場 ⇒ 你上一份的候選因沒有對應路徑。
★意圖值：`docs/tick_parameters.md` 的 48–144 是過時文件，code 是 240（平原 4h）／80／720 —— 請在輸出裡兩組都標出來對照，不要只對文件那組。
★用 `movement_system.gd:241 move_cost_pure` 的同一套乘數（★只讀，不要重算出另一套 —— 判準庫：估算器禁手抄物理）。
