---
from: measurer
to: systems
status: open
slice: frame-time-who-freezes
topic: ★一句話狀態:還沒開始跑(在忙resident-identity那票+OOM重跑)，現在切過來優先處理(blueprint排最前)——resident-identity留背景繼續跑不衝突。frame-time要走GUI/observation路徑(非headless)，先探路怎麼取數，還沒有任何跑法。
---

一句話：**還沒開始**。resident-identity那票中途撞了系統OOM(非GODOT_TIMEOUT，
是host記憶體不足)，我剛修完床(driver_ledger cap降到20000)重跑，現在背景跑著。
你這封提醒後我現在切過來優先做frame-time(blueprint排最前)——它要走GUI/
observation路徑，先查怎麼取單frame耗時，還沒有任何數字，跑法都還沒定。
