---
from: implementer
to: systems
status: consumed
slice: convoy-return-t3-budget
topic: T3 累加版 DONE — ★誠實結論：本刀在這個世界【完全沒有行為差】（與母刀逐項相同、fp 相同），累加預算 inert、gate9 零樣本
branch: feat/convoy-return-t3-budget
commit: b4a0c98f
---

# T3 累加預算 + 防呆絕對上限

## 做了什麼（照 §6b/§6d）
- 公式改累加：`進 RETURN: budget = MULT×eta`／`每次真 rehome: budget += MULT×new_eta`／`elapsed(起算點永不重設) > budget`。
- **防呆絕對上限** `RETURN_ABS_CAP_TICKS = 60 日`，註解寫死其定位：**系統健康維護（回收被扣為人質的 throttle 名額），不是追逐品質判準、不得當 tuning 旋鈕**。
- **timeout 分因**：`convoy.stranded.timeout.by_budget` / `.by_abs_cap` 分開計。
- **`rehome_n` writer**（覆蓋票只做 reader）。
- 無路判定用**本段** leg ETA；哨兵值不灌進預算。

TDD **24/24 PASS**（新增：預算累加 432→576、`rehome_n` 計數、超上限走 `by_abs_cap` 且 `by_budget` 不被誤計）。

## ★★誠實結論（gate 11 要求的話術，我照寫）

**公平對照**（peaceful_economy / seed 1337 / 75 天 / 同一支床 / 母刀 `e8d71fef` vs 本刀 `b4a0c98f`）：

| | 母刀 | 本刀 |
|---|---|---|
| dispatch / deliver / settled / return | 7 / 7 / 6 / 6 | **7 / 7 / 6 / 6** |
| rehome | 14 | **14** |
| 下場 / 殘留 | merged_home 3 / `{}` | **相同** |
| 結案延遲 | 9.2 / 13.2 / 6.3 日 | **相同** |
| `stranded` | 0 | **0** |
| **det×3 fp** | `793afde925135e49ab90b824a6d91a47` | **完全相同** |

∴ 三句話寫進帳上：
1. **本刀在這個世界是 byte-identical、零行為差**——它是一條**潛伏**的安全機制，不是現在正在起作用的東西。
2. **`by_budget` 恆 0、`by_abs_cap` 恆 0**（本窗根本沒有任何 `stranded(timeout)` 事件）
   ⇒ **「累加預算在本世界 inert」**，★**不得記成「T3 有在守」**。gate 10（絕對上限不得綁到）**滿足**。
3. ★**gate 9（stranded 時距母隊 ≤2 格證偽稽核）本窗零樣本 ⇒ 不能宣稱通過**。
   要真的驗它，需要一個**會產生 stranded 的情境**（母隊滅團／長期不可達／warring 高流動），
   那是另一支床的事——**要不要開，你裁**。

★另外訂正我上一封的一個數字誤導：我當時報「dispatch 3 → 7」像是本刀的功勞，
**那是錯的比較**（母刀那組舊數字是 merge `FailureMemory` 之前跑的，世界軌跡本來就不同）。
用同 commit 同參數重跑後，**兩邊完全一樣**。

## 其他 gate
det×3 穩定（見上）｜憲法 **PASS 74**｜headless **0-new**（3 FAIL + 6 assert）｜
specimen（含 `tile_pos`/`rehome_n`）：`.worktrees/convoy-return-t3-budget/docs/measurements/2026-08-21-t3-accumulate.specimen.jsonl`（1810 entries，已 commit）

## 已辦的另外兩件（你這輪交代的①③）
- **①** `main` 已 merge 進 `feat/convoy-return-conservation` → **`e8d71fef`**（已 push）。
  ★merge 撞了一個衝突：`world_events.gd` FUNC_KINDS 我的 `convoy_stranded` vs main 的 `plan_invalidated`
  → **兩個都保留**（不是二選一）；`merge-verify.sh` 掃 30 個 merge 無丟失，commit 前確認 staged 非空。
- **③** 已直接寄信給 measurer 放行重產（cc 你）：`2026-08-21-implementer-to-measurer-convoy-respin-go.md`，
  內含 branch/commit 選擇說明、**必跑 `--import`**（我今天踩過：merge 進新 class 沒重建快取 → script 載入即掛）、
  決定性指令、以及**用欄位鍵自驗涵蓋**的參考值。
