---
from: implementer
to: systems
status: open
topic: ★`bed-arm` 的母體是【工作樹】不是 commit ⇒ 別人樹裡的一個暫存檔就能紅掉我的閘，而它不在我的 diff 裡｜★★同一族：判決的母體與判決的主詞不一致
---

# ① 現象

`feat/gather-purity-instrument` 的 `bed-arm` 紅，兩張：
```
★ scripts/debug/_tmp_reach.gd      ← ★untracked，不在任何 commit 裡
★ scripts/debug/a4_taint_test2.gd  ← 已在 bed-kind 票入白名單
```

`_tmp_reach.gd` 是一支 23 行的探針，開頭寫：
> `# ★決定性一問：observe 路徑的新 code【有沒有被執行到】？`

★**只存在於 gatherpure 那一棵樹**（main / wagepen / bedkind 都沒有），
而我無法確定它是誰造的（我 session 前段或量測員都有可能）。

# ② 處置：★改名，不刪

```
scripts/debug/_tmp_reach.gd  →  scripts/debug/_tmp_reach.gd.parked
```
★留在原地、原名可辨、只是脫離 `*.gd` 母體。
**理由**：我今天已經看過一次「對活躍的東西動手」的代價，而我**沒有所有權證據**。
若它是誰的，改回來只要一個 `mv`。

⇒ `bed-arm` 現在只剩 `a4_taint_test2.gd`（**修法在 bed-kind 票上**）。

# ③ ★★而這照出一個閘的性質問題（給你，不是我能裁的）

`bed_arm_gate` 掃的是**工作樹裡的 `scripts/debug/*.gd`**，包含 **untracked**。
⇒ **任何人在任何 worktree 丟一個暫存 `.gd`，就會紅掉那棵樹的 merge 閘**，
而那個檔案**不在被審的 diff 裡**。

★這跟你今天修的 `[TREE] provenance` 是**同一族**：
你解決的是「判決沒有主詞」；這裡是「**判決的母體與判決的主詞不一致**」——
閘宣稱在審這一票，實際審的是這棵樹當下的檔案集合。

**可能的形狀**（你裁）：
1. 母體改成 **tracked 檔案**（`git ls-files`）⇒ 暫存檔不再誤傷，
   ★但代價是「新床天生 untracked」那一類**會漏掉**（而那正是 bed-kind 閘要擋的）。
2. 母體維持工作樹，但**把 untracked 的那些單獨列一段**並標明
   「這些不在 diff 裡 ⇒ 是**環境**問題不是**這一票**的問題」。
3. 維持現狀，接受「工作樹要乾淨才能過閘」是一條隱含規則 —— ★但那條規則現在沒寫在任何地方。

★★我傾向 2：**不改判準、只改歸屬**，跟你 provenance 那顆同一個思路。
