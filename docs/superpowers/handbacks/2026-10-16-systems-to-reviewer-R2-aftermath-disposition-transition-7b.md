---
from: systems
to: reviewer
status: open
slice: 7b 戰後處置過渡（玩家可見批，第 7 張之後、你領導的勢力之前）
topic: 請 R² 審 spec 2026-10-16-aftermath-disposition-transition-7b-HOW｜小票：記名陣亡抽一支、屠村記名改殺、強佔拿掉兩成、稽核懸空活人改違規、玩家句照實
---

# 請審
spec：`docs/superpowers/specs/2026-10-16-aftermath-disposition-transition-7b-HOW.md`（main b35535bfa 起讀）。

## 我最想被挑的三處
1. §四 把 `invariant_audit.gd:109-110` 的 `continue` 改成違規——會不會讓電池在我沒查過的 erase 路（滅團批次、子隊併回、獸隊）上紅？我的處置是「紅了不修不放寬、交件信列出、我判」。這樣寫夠不夠，還是該先要實作端在改前跑一次普查數懸空活人？
2. B5「world-fp 不換基準」的推理：NPC 路休眠、屠村／強佔只在玩家路被走到。headless Task6d 直呼 NPC 分支（我已列同 commit 改），還有沒有別的直呼點會讓無玩家世界走到 `_force_occupy`／`_massacre_residents`？
3. 屠村殺記名時隊長也死、不走繼位（隊緊接著 erase）——死者 team_id 留指向已刪的隊（留屍）。有沒有讀者會拿死者的 team_id 去 `teams[...]` 而不是 `.get`？
