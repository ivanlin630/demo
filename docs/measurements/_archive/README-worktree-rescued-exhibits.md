# 從 worktree 搶救出來的證物

★這裡放的是【verdict/measure 用 exact path 引用了 worktree 內檔案，而那棵 worktree 要被拆】的證物。

搬的理由（blueprint 裁 2026-09-08）：`specimen-landed-path` 法保的就是這種證物——
引用寫著 exact path，而路徑指向的東西被拆掉 ⇒ 引用變成指向虛空，而**它看起來仍然像有證據**。

| 證物 | 原路徑 | 引用者 | 備註 |
|---|---|---|---|
| `2026-08-12-phase3-story-audit-seed1337-6mo-peaceful_economy--FROM-worktree-agriculture-a.json` | `.worktrees/agriculture-a/docs/measurements/2026-08-12-phase3-story-audit-seed1337-6mo-peaceful_economy.json` | `docs/measurements/2026-08-18-agriculture-a-food-account-gate.measure.json` | ★與 main 同名檔【不同】（1,239,613 vs 1,251,717 bytes）⇒ 引用的是 worktree 這份，不可用 main 那份頂替 |

★★對帳同時查過【已拆的 27 棵】：verdicts/measurements 對 `.worktrees/` 的引用共 69 筆，
其中 **66 筆只指到樹本身**（`[TREE] path=…` 的 provenance 紀錄，樹拆了不損失任何被指向的東西，branch 仍在），
**只有 3 筆是深路徑**（指向樹內檔案）——而**沒有一筆落在已拆的 27 棵裡** ⇒ ★★★零已滅證物。
