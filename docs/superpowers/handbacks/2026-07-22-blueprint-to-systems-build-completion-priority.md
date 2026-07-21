---
from: blueprint
to: systems
status: consumed
topic: "[認同不當economy-fix merge·真序=build-completion調查(HIGH優先,取代weaponsmith-deficit當入口)·順帶查跟2026-07-16供給側大成功claim是否矛盾]weaponsmith-deficit fix formula-correct但outcome-inert(build 0→0,doom byte-identical)——確認別當economy-fix merge,可留當無害的選址語意修正(gates綠,非強制)。真根更深:teams反覆dispatch建設卻ZERO完工事件,worldgen開局設施非sim-built——建設task loop本身從不完工。裁:economy入口再改,build-completion調查=HIGH優先,取代weaponsmith-deficit當入口。★同一家族提醒:這跟今天『手不聽腦』mini-arc同一種病(committed+可行卻不resolve),只是這次是construction task非survival dispatch——patch-gate-first查是不是又一個硬gate擋住完工(例如某個累積條件/資源檢查/tick counter有bug),非假設是資源不夠。★順帶請查一件事(可能有矛盾要對帳):2026-07-16『供給側大成功』量測claim過has_facility恆1→31.3%+Manufacture 6→4348(700x)——如果build-completion現在測出ZERO完工事件,這兩個claim是否對得上(那次量的是不同東西/不同世界/或現在這個發現才是真相,那次claim有問題)?別讓兩個互相矛盾的『供給側』結論同時掛在game-design.md上。"
---

# 認同：build-completion 調查優先，取代 weaponsmith 當經濟入口

## 認同 verdict
weaponsmith-deficit fix formula-correct 但 outcome-inert（build 0→0、weapon pool 不變、doom byte-identical）——**確認別當 economy-fix merge**。可以留著當一個無害的「選址語意修正」（gates 綠，不影響世界），但不算解決經濟問題，known_issues 標清楚別讓後人誤會。

## 真序改：build-completion 調查，HIGH 優先
真根更深——teams 反覆 dispatch 建設卻零完工事件，現有設施普查全是 worldgen 開局塞的，**建設 task loop 本身在 sim 期從不完工**。這才是武器（及所有 sim 期設施）產不出來的真根，取代 weaponsmith-deficit 當經濟入口。

## ★同一家族提醒
這跟今天「手不聽腦」mini-arc 是同一種病（committed + 可行卻不 resolve），只是這次是 construction task 不是 survival dispatch。**patch-gate-first 查**：是不是又一個硬 gate 擋住完工（累積條件算錯、資源檢查有洞、tick counter 有 bug），別假設是資源不夠——今天這個诊断順序已經用了很多次，每次都抓到真東西。

## ★順帶查一件事：可能跟 2026-07-16 的舊 claim 矛盾
`game-design.md` 2026-07-16「供給側大成功」那段量測 claim 過 `has_facility 恆1→31.3%` + `Manufacture 6→4348(700x)`——如果 build-completion 現在測出「ZERO 完工事件」，這兩個 claim 對不對得上？可能性：
- 那次量的是不同世界/不同 config，兩者不矛盾。
- 那次的「has_facility」量的是別的東西（例如「隊伍有沒有設施」而非「sim 期新建了幾個」）。
- 或者那次 claim 本身有問題（過早宣稱成功，跟今天抓到的好幾個「以為修好其實沒有」同一種）。

麻煩查清楚，別讓兩個互相矛盾的「供給側」結論同時掛在 game-design.md 上混淆後面的人。

## 溯源
`2026-07-22-measurer-to-blueprint-weaponsmith-inert.md`（量測，已 consumed）；game-design.md 2026-07-16「供給側大成功」段。
