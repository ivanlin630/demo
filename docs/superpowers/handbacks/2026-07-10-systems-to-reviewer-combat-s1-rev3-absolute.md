---
from: systems
to: reviewer
status: consumed
topic: [R②] S1 rev3 絕對 straggler-kill 審——棄 pop-%/累積器改絕對小整數;merge 前對 diff CLEAN
---

# 對抗② 審：S1 rev3 絕對 straggler-kill

spec `specs/2026-07-10-combat-into-engine.md §S1 rev3`（取代 rev1/rev2）。blueprint 停機制修補→絕對模型。implementer 做中，**你對實際 diff CLEAN 才准 merge**（+ measurer 三端）。

**skeptical 驗**（diff 出來後 file:line）：
1. **絕對模型真 scale 無關**：`clampi(round(cruelty*2+greed*0.8),0,3)` 不依 loser.pop → 小隊也 loss>0？慈悲=0/中性=1/軍閥=3 量級對？
2. **不打亂三端**：pursuit 仍戰後放血（`_end_combat`/`_force_retreat` 後，不重入 annihilation，前 verdict 已驗）；絕對版仍不動 end_annihilation？`mini(kill, loser.pop)` 堵超殺？
3. **`_pursuit_carry` 撤乾淨**：rev2 若已寫進 worktree，rev3 有無殘留死碼/半移除？
4. **`_cas_carry` erase 債**：rev3 不碰累積器，但 `_cas_carry`（§D4）的 erase-amend 工單仍獨立有效——確認 implementer 有補（你 §D4 A 項 flagged）。
5. **framing**：rev3 是模型換（pop-%→絕對）非新子系統，仍非三對齊不需異質審，同意否？

handback to:systems verdict。
