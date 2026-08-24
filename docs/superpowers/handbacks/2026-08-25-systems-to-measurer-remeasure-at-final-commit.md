---
from: systems
to: measurer
status: consumed
slice: camp-access
topic: ★重量令:你量的 b968f492 早於 e927be2f(遷移找糧 delay=行為改動);併三件小事(join tap dump/標籤更正/你的床沒 commit)
---

# 重量令：`camp-access` 世界層三條，改在 `e927be2f`

implementer 自己抓到的對帳問題，我判**必須重量**：
你的答卷標 `b968f492`，但 **`遷移找糧` 的 delay（我准的行為改動）落在 `e927be2f`**。

★**不要用 `det fp` 相同來推「行為沒變」** —— implementer 已坐實：
fp 在兩個 commit 都是 `880d3adf…`，**但 a4 那 1000 tick 床根本沒跑到遷移找糧**。
⇒ **fp 只覆蓋「那張床實際跑到的路徑」**。已立成 `03b §④g`。

**要的**：**同床同 seed（peaceful 1337 / 90d）在 `e927be2f` 重跑**，報 §7 三條：
1. ★`outpost.l0_to_l1`（**二值**；`b968f492` 上 implementer 量到 **1**，需你獨立確認）
2. `camp.abandoned` vs `camp.built`
3. `collect.no_outpost_no_camp_zero_food` vs 同床 main baseline

★**併報 outpost 普查**（day0 / day90 / 中途新增）—— 上次是 `11 → 9、新增 0`；
**若這次「中途新增 ≥ 1」，那就是「這個世界第一次做出文明化動作」的獨立佐證。**

## 併入同一輪的三件小事
1. ★**`join.accept_check` dump**（QA 指路，`interaction_system.gd:1256-1259`，cap 40）
   —— **8 次 reject ≪ 40 ⇒ 完整母體**，請照 `03b §④e` 明寫母體＝樣本。
2. ★**標籤更正**：`discount.camp_raw_u` / `horizon_eff` / `flow_food` 用的是 `Probe.note` ＝ **peak**，
   你們床報表標成「**最後一次**」⇒ **誤導**。請改標「**本輪最大值**」。已立 `03b §④f`：
   每個量都要標明 **本輪最大值／最後一次／平均**。
3. **你在 `.worktrees/camp-access/scripts/debug/camp_access_diag_bed.gd` 的未 commit 編輯**
   （`SpecimenDumpHelper` ＋ 四 tap 報表段）——**implementer 逐檔 add、沒掃到它**（做得對）。
   **要不要 commit 請你自己決定。**

## 其餘續辦不變
C6-#1 distinct 拆分 ／ T2 先報分母 ／ C-5 抽驗 ／ `eta-single-model` gate4/gate6 長跑票。
