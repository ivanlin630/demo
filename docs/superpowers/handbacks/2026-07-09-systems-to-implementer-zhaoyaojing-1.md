---
from: systems
to: implementer
status: open
topic: 實作 照妖鏡#1（潰退門檻→膽量）——spec 鎖(blueprint sign-off+reviewer CLEAN)
---

# 實作工單：照妖鏡 #1 潰退門檻→膽量

spec（已鎖）：`docs/superpowers/specs/2026-07-09-zhaoyaojing-1-combat-abandon-courage.md`

## 在哪做
**新 worktree** `feat/zhaoyaojing-1`（base origin/main；獨立，與 A2c-2 不同 branch）。可 LG `--from-impl` 或 mailbox。

## 做什麼（照 spec，1 檔改 + 探針）
1. `npc_combat_system.gd`：flat `COMBAT_ABANDON_THRESHOLD=0.2` → `ABANDON_THRESHOLD_BASE=0.2` + `ABANDON_COURAGE_SPREAD=0.16` + `_abandon_threshold(state,team)`（`courage=clampf(0.5+(好戰−慎重)×0.5,0,1)`，門檻=`BASE+(0.5−courage)×SPREAD`，null leader→BASE）。`:197/200` 改各隊自算 `_abandon_threshold(state,a)`/`(state,b)`。
2. 探針（`warring_harness.gd` PROBE_KEYS + npc_combat bump）：`rout.total`/平均回合數 + **`rout.readiness_at_retreat_by_courage_bucket`**（`_force_retreat` 命中瞬間記該隊 readiness，courage 分高/中/低三桶）。

## 驗（spec §驗收法）
- `--headless --import` 綠、sanity 無崩、constitution 綠。
- **★acceptance full_probe 3 seed(1337/42/7)**：驗①勇者桶退時 readiness < 怯者桶（人格差異現）②**aggregate 潰退率 vs baseline 對照**（reviewer：均值守恆是待驗假設，好戰/慎重 archetype 分布不對稱可能 shift；若顯著 shift 報 systems→blueprint）。
- TDD 逐步 commit。

## 完後
handback to:systems（acceptance 場合數字 to:blueprint 判，spec §驗收=blueprint pass）。**若 aggregate 潰退率顯著偏移 baseline** → 標明報 systems，我判 median-center 或回 blueprint 接受。
