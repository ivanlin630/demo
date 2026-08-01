---
from: implementer
to: measurer
status: consumed
topic: "[量測·per-action-type completion tap done·6mo 確認 A1 閉沒·base=feat/construction-commitment-latch 37f2ce31] construct.complete_<action> aggregate 計數(非抽樣)done。1mo seed1337 已 100% 確認 build=0(新 outpost founding 真 0,非抽樣 missed);complete=6 全 upgrade_facility。請 6mo(seed1337,42)確認雙 seed→construct.complete_build aggregate 真 0 否→數字 to:blueprint(帶用戶序 a 轉手統一 arc / b 重估)。閘全綠(headless 0-new+gate 74+determinism 3跑 5cf06fda)。"
branch: feat/construction-commitment-latch
commit: 37f2ce31
---

# 量測請求：per-action-type completion 6mo 確認 A1 閉沒

per-action-type completion 計數 tap **done**（cheap，純觀測）。1mo seed1337 已 100% 確認 `build=0`（非抽樣 artifact）。請 6mo 雙 seed 坐實。

## 跑法
```powershell
$env:GODOT_TIMEOUT="600"; $env:WARRING_SEEDS="1337,42"; $env:WARRING_MONTHS="6"
$env:WARRING_OUT="A:\GDS\demo\docs\measurements\2026-07-26-per-action-completion-6mo.json"
.\tools\godot.ps1 --path .worktrees\construction-latch --headless --script scripts/debug/seeded_warring_bed.gd
```

## 讀（每 seed `.probe`，aggregate 非抽樣）
- **`construct.complete_build`** ← ★決定 A1 閉沒：新 outpost founding completion 數（0 = A1 核心真未閉 / >0 = 前 16/16 抽樣 missed）。
- `construct.complete_upgrade_facility` / `_upgrade_level` / `_demolish`（既有 outpost 升設施/升級/拆）。
- `construct.complete`（總）= 各 action 和。

## 1mo seed1337 sanity（已確認）
`complete=6 / complete_build=0 / complete_upgrade_facility=6 / upgrade_level=0 / demolish=0`
→ **build 真 0**（非抽樣 missed）。latch+resume 閉 facility 建，但**新 outpost founding（A1 核心 forest founding）仍 0 完工**。

## 交付
`construct.complete_build` 6mo 雙 seed aggregate → `to:blueprint`（帶用戶序）：
- **(a)** build 確 0 → A1 核心新 outpost founding 未閉 → 轉手統一 arc / 深挖 founding 為何不完工（remote founding 子隊 _evaluate_subteam 保護但仍 0=另一層）。
- **(b)** build >0（1mo 巧 0，6mo 有）→ 前抽樣 missed，重估 A1 部分閉。
