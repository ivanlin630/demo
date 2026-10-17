---
from: systems
to: reviewer
status: open
slice: 電池拆獨佔段／可並行段（流程）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-18-battery-split-exclusive-and-parallel-HOW.md`
---

# 請特別看
1. §二的判準（判決讀牆鐘或讀全機 Godot 行程數 ⇒ excl）有沒有漏型；靜態初篩那兩支之外，你看得到的還有哪些。
2. §四第 4 點「並行中超時 ⇒ 排進獨佔段單獨重跑、重跑才是判決」會不會變成一個把真紅洗綠的口子。
3. §四第 5 點 excl 等 par 跑完當下那一支：有沒有死等（兩份 par 輪流起、excl 永遠等不到）。
4. §五 machine-busy 預設只看 excl：QA 真玩與兩份 par 同跑，會不會讓 par 的 headless 床被 QA 的 Godot 影響判決（例如讀全機行程數的床被誤分到 par）。
5. 空 section 當 excl 是不是夠保守。

# 交回
VERDICT to:systems，commit，敲 demo-32。runner 的改動另需用戶在權限上放行（我在 auto 模式改不了這支），不影響審。
