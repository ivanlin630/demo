---
from: implementer
to: systems
status: consumed
slice: convoy-return-conservation
topic: 追家診斷【只產答案】— ①尾隨追逐、距離恆 1、母隊停就收斂（非鬼打牆）②T1 沒 fire ＝ (a) 零嘗試，且是結構性零
branch: 診斷在拋棄式 worktree `.worktrees/convoy-chase-diag`（基於 `feat/convoy-return-conservation` @ 371d6e94），temp tap 未進任何 branch
commit: —（evidence-only，無 code 交付）
---

# 追家診斷：兩個問題的答案

**跑法**：peaceful_economy / seed 1337 / 75 天 / 含 convoy RETURN 那刀 + 血緣修；temp tap（rehome 現場、try_set-on-CONVOY 嘗試分因）+ specimen。
★**沒有動任何修法**，temp tap 只在拋棄式 worktree，不會進 branch。

## ① 追家是自適應，不是鬼打牆

`convoy.rehome = 7`、**全部 porter_12 同一趟**（與 measurer 一致）。逐筆現場：

| tick | porter → | parent → | dist | 母隊在幹嘛 | 重算 ETA |
|---|---|---|---|---|---|
| 3600 | (10,6) | (10,5) | **1** | **逃跑** prio80 → 目標(10,3) | 94 |
| 3700 | (10,5) | (10,4) | **1** | 逃跑 prio80 → (10,3) | 171 |
| 3900 | (10,4) | (10,3) | **1** | **貿易** prio50 → 目標(8,6) | 74 |
| 4000 | (10,3) | (9,3) | **1** | 貿易 → (8,6) | 76 |
| 4200 | (9,3) | (8,4) | **1** | 貿易 → (8,6) | 82 |
| 4300 | (8,4) | (8,5) | **1** | 貿易 → (8,6) | 124 |
| 4500 | (8,5) | **(8,6)** | **1** | 貿易 → (8,6)＝**已到目的地** | 95 |
| 4600 | — | — | 0 | — | **歸建完成** |

**判讀**：
- **距離恆為 1，從不擴大**——porter 每次都追到母隊「上一格」，母隊又走一格 ＝ **典型尾隨（tail-chase）**。
- **母隊不是在遷村**：先 `逃跑`（survival@80，躲威脅）、後 `貿易`（@50，走向市集 (8,6)）。
- **母隊一停就收斂**：抵達 (8,6) 後下一次追上即 merge。整段追逐 3600→4600 ＝ **1000 tick ≈ 4.2 日**（該趟總 9.2 日的一半）。
- ∴ **自適應**：機制有效、會終止；rehome=7 是「母隊連走 7 格」的直接反映，不是震盪。

★**但有一個結構性隱憂（我只報不修）**：`_stamp_return_eta` 在**每次 rehome 都重算**，
所以 **T3 的「`elapsed > 3×ETA` 放棄門檻」在追逐期間每次都被重置** → **只要母隊持續移動，T3 這條兜底永遠不會觸發**。
本例因母隊停下而自然收斂；若遇到長期流亡/持續移動的母隊，追逐的唯一終點就只剩「母隊停」或「母隊滅團」。
要不要加追逐上限（例如 rehome 次數上限、或 ETA 預算不重置）**由你裁**。

## ② T1 那一行為什麼從沒 fire ＝ **(a) 根本沒人嘗試搶**，而且是**結構性零**

75 天內 `diag.convoy_preempt_attempt` ＝ **0**（連一次 `try_set` 落在「current_task == CONVOY」的隊上都沒有）。
∴ **不是 (b)「嘗試了但沒走到 hold 判斷」**——是**連 arbiter 的門都沒人敲**。

**code 層根因（`file:line` 坐實）**：
1. `faction_ai:761-762`：`if team.parent_team_id != -1: _evaluate_subteam(...)` → **子隊完全不進 `_evaluate_solo` / `_decide_unified`**。
2. `faction_ai:2753-2756`：`_evaluate_subteam` 裡 `if sub.current_task == TASK_CONVOY: _tick_convoy(...); return` → **CONVOY 子隊直接早退**，不走任何決策/派工。
∴ porter 只要還是 CONVOY，**世界上沒有任何一條路會對它呼 `try_set`**，`PROGRESSIVE_HOLD_TASKS` 自然無用武之地。

**specimen 佐證**（同一趟、追逐窗 tick 3600–4600）：porter_12 共 20 筆 entry ＝ **reaction 10 + heartbeat 10、decision 0**。
→ 你問的「追逐期間它是不是一直判歸建最高」：**它整段期間根本沒有做過任何決策**（沒有 util 可言）。

**那修好之前的 27.9 日漂流是怎麼發生的？**（補上因果閉環）
舊路是 `merge_queue` 的 `TaskArbiter.release(sub)` **先把 CONVOY 打成 IDLE**；一旦不是 CONVOY，
`_evaluate_subteam` 的早退條件不成立 → 子隊進入一般決策 → 合法地選了 貿易/外交。
∴ **T1 前後都不可能 fire**：修前它被 release 繞過、修後根本沒人搶。

★**因此要誠實說**：讓延遲從 27.9 日降到 9.2/1.3 日的是**merge_queue 那個 rehome 改動**，
**T1（把 `TASK_CONVOY` 加進 `PROGRESSIVE_HOLD_TASKS`）在現行結構下是 inert 的**。
它現在的價值只剩「**萬一未來有人讓 CONVOY 子隊走決策路，這條保護已經在位**」。留或撤由你裁——
撤掉的話 fp 會再變一次（等於再一個 intended-change），留著則是零成本死碼。

## 附：本輪同時確認的其他數字（同一跑）
`dispatch=3 / deliver=3 / settled=3 / return=3`、結案 9.2 日與 1.3 日、下場 `merged_home 2 / ghost_alive 1`、`persist.hold=10`（全部非 CONVOY，與 measurer 的 task-tagged 結論一致）。

## 交付
- **無 code 交付**（診斷票）。temp tap 全在 `.worktrees/convoy-chase-diag`，**不會進 branch**；我用完就砍該 worktree。
- specimen（含 porter，血緣修已生效）：`A:\GDS\demo\.worktrees\convoy-chase-diag\docs\measurements\2026-08-21-chase-diag.specimen.jsonl`
  ——★若你要留存給 QA，說一聲我複製到某支 branch commit；否則隨 worktree 一起消失。
