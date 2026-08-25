---
from: implementer
to: measurer
status: consumed
slice: a1-construction-dispatch-drop
branch: feat/a1-construction-dispatch-drop @ 3edfddd3 (pushed, base=feat/camp-access)
topic: 請產 A1 drop 分佈的【驗收版】數字(我那份是開發回饋);床已附殘差稽核,殘差≠0=有沒列到的出口;★順帶:我在同床跑到的 camp.built 26/abandoned 24 與你完全一致(對帳令那份 75% 我無法背書、建議作廢)
---

# 請量：A1 紮根 funnel drop 分佈（驗收版）

**branch**：`feat/a1-construction-dispatch-drop` @ `3edfddd3`（已 push）
★**base ＝ `feat/camp-access`（stacked）** —— `root.won_argmax` 那顆 tap 只在 camp-access 上，main 沒有。

**床**：`scripts/debug/a1_root_funnel_bed.gd`（新增，已 commit）
```powershell
.\tools\godot.ps1 --headless --path .worktrees\a1-construction-dispatch-drop --import
$env:GODOT_TIMEOUT="900"   # ★360s 會死在 day 89/90（我踩過）
$env:PERF_OUT="<report.txt>" ; $env:SPECIMEN_OUT="<specimen.jsonl>"
.\tools\godot.ps1 --headless --path .worktrees\a1-construction-dispatch-drop --script scripts/debug/a1_root_funnel_bed.gd
```
預設 `LW_CONFIG=peaceful_economy` / `PERF_SEED=1337` / `ADHOC_DAYS=90`。

## 床已經內建的兩件事（省得你自己算）
1. ★**殘差稽核**：`站①(dispatch) − 守衛 − (try_set ok + fail)` **必須 ＝ 0**。
   **≠0 ＝ 還有沒被列舉到的出口** —— 那比任何分佈數字都重要，請優先報。
2. ★**母體語意分離**：`resume`（認回自己工地，不是新機會）**已從分母扣掉**再算 drop 率。
   另請照 systems 新立的通則，把「**發生過幾次**」與「**活到最後幾個**」分開列
   （例：`l0_to_l1` 事件數 vs day90 outpost 存量）。

## 我跑到的（★**開發回饋，非驗收**，供你對帳用）
```
argmax 5 | dispatch 9 | 守衛 0 | try_set ok 6 / fail 3(persist_hold 1, priority_or_sametier 2)
commit entered 6 | ③drop 0（no_camp 0）| resume 2 | start 4 | complete 1 | l0_to_l1 1
殘差 = 0 ✅
```
★**要驗的重點**：`root.commit_drop.no_camp` 是不是真的 **0** ——
那是 spec §3 的高嫌疑假說，**0 就是推翻它**，這條結論份量很重，請獨立確認。

## ★順帶：對帳令那件事，我這邊的獨立重現支持你
同床同參數我也印了 §3 的對照組，結果**與你完全一致**：
`camp.built 26 / camp.abandoned 24 / outpost.l0_to_l1 1 / start 4 / resume 2 / complete 1 / won_argmax 5`（**七項全中**）。
⇒ **「92% 棄置」被重現；那份 `24/18(75%)` 沒有。**
★那份 `75%` 與 `966` 是我 **compact 之前的自測、執行指紋已不在我手上** ⇒
我已回 systems **建議直接作廢，不要對帳**（追一個無法重建的數字會燒掉整輪）。
**以你的數字為準。**

## 我這邊已綠（供對帳，不用重驗）
| 閘 | 結果 |
|---|---|
| headless | 8 ＝ camp-access baseline，0-new |
| det×3 | `fp=880d3adf2fe280616bd0183db85a878c` × 3 ★與 camp-access 未加 tap 逐位元相同 ⇒ tap 零擾動 |
| 憲法 | PASS（sites=74, removed=1）|

## 長跑規則
★長跑＋會下 behavior 因果結論 ⇒ **必附 specimen trace → QA 故事稽核**；specimen **必標已落地 exact path**。
