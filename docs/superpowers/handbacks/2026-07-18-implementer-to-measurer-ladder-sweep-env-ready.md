---
from: implementer
to: measurer
status: consumed
topic: "[② calibration-sweep env override ready·branch 17fd4fc4] blueprint 裁 B sweep 工具備:3 env 注入掃 STALL 值,無改 scripts。LADDER_STALL_BASE→STALL_BASE_DAYS(def 8.0)、LADDER_RELIEF_MIN→STALL_RELIEF_MIN(def 1.0)、LADDER_STALL_WINDOW→STALL_EXCLUDE_WINDOW(def 4800=TICKS_PER_DAY 240×20)。無 env=byte-identical 現行為(no-env determinism==bb1e75ff 16a7f17e 驗)。用法 powershell:$env:LADDER_STALL_BASE='X'; godot --path .worktrees/desperation-ladder ...。sweep 協議 systems 另寄你。branch@17fd4fc4。"
---

# ② calibration-sweep env override ready（branch 17fd4fc4）

## 工具（blueprint 裁 B：先 sweep 找 STALL_DAYS 修 seed1337 latch 又不 10x seed4201）
3 個 env 注入掃值，**無需改 scripts**：

| env var | → const | default（無 env） |
|---|---|---|
| `LADDER_STALL_BASE` | `STALL_BASE_DAYS` | 8.0 |
| `LADDER_RELIEF_MIN` | `STALL_RELIEF_MIN` | 1.0 |
| `LADDER_STALL_WINDOW` | `STALL_EXCLUDE_WINDOW` | 4800（= TICKS_PER_DAY 240 × 20） |

- `STALL_DAYS = STALL_BASE_DAYS × patience(慎重+(1-求生欲))`。掃 STALL_BASE↑ = 更耐心（晚換格）；↓ = 早換格。
- `RELIEF_MIN↓` = 更容易判 resolving（少換格）；↑ = 嚴（多換格）。

## 用法（powershell，對 branch worktree 跑，禁原地 checkout）
```powershell
$env:LADDER_STALL_BASE='4.0'; $env:LADDER_RELIEF_MIN='0.5'
.\tools\godot.ps1 --headless --path .worktrees/desperation-ladder --script <your bed>
Remove-Item Env:LADDER_STALL_BASE, Env:LADDER_RELIEF_MIN   # 掃完清，避殘留污染
```

## 保證
- **無 env → byte-identical 現行為**（no-env determinism `game_sim_multi` == bb1e75ff `16a7f17e`；純掃機非改邏輯）。
- gate PASS(64)；stall bed ALL PASS；env 注入讀通（3.5/0.5 驗）。

## sweep 協議
systems 另寄你（掃 STALL_BASE↑/RELIEF_MIN↓ 找 seed1337 latch 保 + seed4201 回 baseline 的值）。

## 溯源
dispatch `2026-07-18-systems-to-implementer-ladder-sweep-env-override.md`；blueprint (B) sweep 裁。
