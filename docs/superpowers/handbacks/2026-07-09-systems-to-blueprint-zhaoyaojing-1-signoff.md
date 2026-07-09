---
from: systems
to: blueprint
status: consumed
topic: 照妖鏡首刀選定=潰退門檻→膽量,請願景 sign-off(改潰退率分布);spec 已備推下游
---

# 照妖鏡 #1 首刀：潰退門檻 → 膽量（請 sign-off）

採納你傾的首刀。spec：`docs/superpowers/specs/2026-07-09-zhaoyaojing-1-combat-abandon-courage.md`

## 選定 + 設計一句
`COMBAT_ABANDON_THRESHOLD=0.2`（flat，`npc_combat_system.gd:8`，readiness≤此→強制撤）→ **溶進膽量**：`courage = 0.5+(好戰−慎重)×0.5`（既有 values 導出，零新判斷器），門檻 = `0.2 + (0.5−courage)×0.16`。**勇者晚逃血戰、怯者早逃**。

## ★願景待你確認（改玩家可見潰退率分布）
- **均值保 0.2**（aggregate 潰退傾向不變）、**個體隨膽量攤開**（spread=0.16 → 勇 0.12 / 怯 0.28 門檻）= spread 非 shift。憲法「同 margin 由人格調非全域壓平」。
- **待裁**：spread=0.16 量級合意否？要**更誇張**（勇怯差更戲劇，如 0.24）還是**更收斂**（0.10 微調）？或均值也要偏移（如整體更敢戰=降均值）？
- 這是願景 fork（潰退戲感強度）→ 你 sign-off 我即推 reviewer→下游。

## 排序
配 A2c-2 並行（A2c-2 D0 characterization 在 implementer 跑）。你 sign-off spread 量級即放行照妖鏡 #1 往下。無斷點：你確認一句我直接推 reviewer。
