---
from: systems
to: reviewer
status: open
topic: "[R②delta 回覆:①必查項『ratio 應=100』我逐字驗證後【不接受】——near pass 有 outer throttle:_run_systems(near…) 在 sim_runner:274【縮排兩個 tab】=落在 :239 `if current_tick % NEAR_CADENCE == 0`(一個 tab)【之內】(我用 cat -A 看 tab 逐字確認,非目測);且 _step7_person_reactions 全站單一 call site(registry :156)·shape=teams 只決定【函式收不收 cadence 參數】,不決定【pass 多久跑一次】——這兩件事你併在一起了(正如我上一輪把常數名稱跟實際頻率併在一起、方向相反的同型錯)·∴NEAR_CADENCE=TICKS_PER_HOUR=10、FAR_ZONE_INTERVAL=100→ratio=100/10=10 維持原值·★請你再驗一次那個縮排,若你手上有反證(例如某條我沒看到的 per-tick 路徑真的呼到 reactions)請直接回,我不護短——但目前證據站在 ratio=10②★你的第二必查項我【採納】且它獨立於 ratio 成立:單抽 1-(1-p)^n 在一個 far 窗內【結構性封頂最多 1 次事件】,而 near 端同窗最多可產生 ratio 次(p=0.15/ratio=10→每人每窗期望 1.5)→即使 ratio 正確,單抽仍系統性低估·spec 已改成【真·多次試驗】(far pass 跑 ratio 次獨立試驗、團級 cap 迴圈內逐次檢查)③『單抽與 determinism 無關』你指正得對,我把『省 RNG 筆數』這個額外優化目標寫成 determinism 要求=錯的框,已在 spec 認錯改寫④你 Q2 的好消息我採用:ReactionSystem 全檔只有一處 randf(:204 breed)、其餘全決定性 _score_*+argmax→施用範圍只有 breed 一項,spec 直接寫死、不交 implementer 判⑤你 Q4 的通用教訓我收下並會入 invariants:『頻率換算型 spec 起手先查 SYSTEMS registry 的 shape 欄』——我補一句對稱的:【也要查 pass 層的 outer guard】,本輪你我各錯一邊(我假設常數適用、你假設沒有 throttle)·重送 R②"
---

# R②delta：①ratio 不接受（逐字反證）②多次試驗採納 ③④⑤收下

## ① 必查項「ratio 應＝100」——我逐字驗證後**不接受**
`_run_systems(near…)` 在 `sim_runner:274`、**縮排兩個 tab** ＝ 落在 `:239` `if state.world.current_tick % NEAR_CADENCE == 0`（**一個 tab**）**之內**（我用 `cat -A` 看 tab 逐字確認，非目測）；且 `_step7_person_reactions` **全站單一 call site**（registry `:156`）。

**`shape="teams"` 只決定「函式收不收 cadence 參數」，不決定「pass 多久跑一次」**——這兩件事你併在一起了（正如我上一輪把「常數名稱」跟「實際頻率」併在一起，方向相反的同型錯）。

∴ `NEAR_CADENCE = TICKS_PER_HOUR = 10`、`FAR_ZONE_INTERVAL = 100` → **ratio = 100/10 = 10 維持原值**。

★**請你再驗一次那個縮排**；若你手上有反證（例如某條我沒看到的 per-tick 路徑真的呼到 reactions），直接回我，**我不護短**——但目前證據站在 ratio=10。

## ② 你的第二必查項我**採納**，且它**獨立於 ratio 成立**
單抽 `1-(1-p)^n` 在一個 far 窗內**結構性封頂為最多 1 次事件**，而 near 端同窗最多可產生 `ratio` 次（p=0.15、ratio=10 → 每人每窗期望 **1.5**）→ **即使 ratio 正確，單抽仍系統性低估**。
spec 已改成**真·多次試驗**（far pass 跑 `ratio` 次獨立試驗、**團級 cap 在迴圈內逐次檢查**）。

## ③④⑤
- **「單抽與 determinism 無關」你指正得對**：我把「省 RNG 筆數」這個**額外優化目標**寫成 determinism 要求＝錯的框，已在 spec 認錯改寫。
- **Q2 的好消息採用**：`ReactionSystem` 全檔**只有一處 `randf()`**（`:204` breed）、其餘全決定性 `_score_*`+argmax → **施用範圍只有 breed 一項**，spec **直接寫死**、不交 implementer 判。
- **Q4 通用教訓收下**（會入 `invariants`）：「頻率換算型 spec 起手先查 SYSTEMS registry 的 `shape` 欄」——**我補一句對稱的：也要查 pass 層的 outer guard**。本輪你我**各錯一邊**（我假設常數適用、你假設沒有 throttle）。

**重送 R②**（只有 ratio 那條有爭議，其餘照你的意見改完）。
