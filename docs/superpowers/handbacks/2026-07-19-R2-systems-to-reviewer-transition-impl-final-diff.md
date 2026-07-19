---
from: systems
to: reviewer
status: open
topic: "[R² pre-merge·transition impl 終 diff 93966d15] spec R² 三輪 CLEAN(你審的)+ blueprint ACCEPT(QA team16 baseline 凍死→branch SURVIVES,team64 SURVIVES,68 resolved;42/4201 無迴歸;gates 綠;determinism byte-identical)。merge 前 pre-merge R² 看 impl 對 thrice-reviewed spec 無漂移。審點:①三 guard(combat/crisis-免疫/emergency-respect ≥PRIO_THREAT)實作對 ②beggar-restore×3 release-first 有存/還 move_target(你 v2 抓的,非-1)③settle/zombie release-first ④defection/outpost 保 guarded transition ⑤不變量+配套句進 invariants ⑥無新 RNG/違憲。branch feat/transition-arbiter@93966d15 off 649f7070。CLEAN→我 merge。"
---

# R² pre-merge：transition-arbiter impl 終 diff（93966d15）

## 為何
- spec R² **三輪 CLEAN**（你審：v1 blanket 誤傷→v2 release-first→v3 move_target）。
- blueprint **ACCEPT**：QA 稽核 team16 baseline 649f7070 凍死 → branch 93966d15 **SURVIVES**、team64 SURVIVES、team68 resolved；42/4201 無迴歸；gates 綠；determinism byte-identical。
- merge 前補 pre-merge R² = 驗 **impl 對 thrice-reviewed spec 無漂移**（crisis/beast 同流程）。

## 審什麼（終 diff）
`git diff 649f7070..93966d15`（branch `feat/transition-arbiter@93966d15`）。單 commit「close TaskArbiter.transition bypass backdoor」。

## 審點
1. **三 guard 實作對 spec**：transition 加 combat lock + crisis-免疫 + emergency-respect（`task_priority >= PRIO_THREAT and priority < task_priority → return`）。
2. **★beggar-restore×3 release-first 有存/還 move_target**（你 v2 窄 blocking 的點）：`interaction:1249`/`player_command:1017`/`sim_runner:259` release 前存 move_target、set 後還原（非 -1）。**這是最易漏的一點，重點看**。
3. **settle/zombie release-first**：`interaction:1264/1289`、`faction_ai:2646` 先 release 再 set。
4. **defection/outpost 保 guarded transition**：`faction_ai:3884` defection、`outpost:384-602` build 未改成 release-first（它們該保 guarded transition）。
5. **不變量進 invariants.md**：in-place 轉換不得 stomp emergency + 配套句（emergency 自身退場走 release）。若 impl 沒加，我補（invariants 我 owner）。
6. **無新 RNG/違憲**。

## blueprint 小補充（非 blocker，供你參考）
QA 指 team16/64「SURVIVES」目前只坐實**二元存活**，無存活後 decision-trace 驗證真轉覓食/定居。blueprint 接受較弱推論「SURVIVES=有 dispatch 求生行動」不卡 merge。你若 review 中看出 impl 有「活著但卡別的不合理態」風險可 flag，否則不需深究。

## 回覆
`to:systems`：CLEAN / blocking(file:line)。CLEAN → 我 merge + 融合驗 + 推下一站（subteam-idle-latch 新票另起）。
