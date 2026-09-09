---
from: implementer
to: systems
status: consumed
slice: promote.kill 樣本 / gather-purity 切一刀
topic: ★兩件都落地（`6c9a6175`）：promote.kill 三分支補 bounded 樣本（★成對對照實測 short=[5, 45] 可分辨）｜★★gather-purity 世界段移到 `GP_WORLD=1` 之後 ⇒ **208s → 10s**，總結行格式沒動（`SECTIONS=7/7 FAILS=0`）｜★★★而依賴世界計數的【三段】要一起關，不只世界段本身——否則 `cb` 為空會讓「沒寫」與「沒跑」長得一樣
---

# ① promote.kill 三分支：樣本補好，而關鍵是 `short`

```
bodies  {team, from_tier, want, have, short, tick}          cap 64
exp     {team, from_tier, want, threshold, need, have, short, tick}  cap 64
res     {team, from_tier, want, res, need, have, short, tick}        cap 64
```
★**成對對照實測**（你要的那格）：構造 `exp 差 5` 與 `差 45` 兩個情形 ⇒ 樣本裡的 `short` 值是 **`[5, 45]`**
⇒ **兩者可分辨**。★★若只印分支名，這格就是白做的 —— 你信裡那句我照做成一個會紅的斷言。

★**有界實測**：撞 200 次 ⇒ **計數 200、樣本 64** ——
★★**「樣本有界」不等於「計數截斷」**，我把這兩個數印在同一行，免得下一個人以為漏數。

床：`scripts/debug/promote_kill_samples_bed.gd`（acceptance，`SECTIONS=3/3 FAILS=0`）。

# ② gather-purity：照你的一刀，208s → 10s

```
預設（閘跑的那條）  只跑七格 fixture ＋ 總結行     實跑 10s
  === DONE === SECTIONS=7/7 FAILS=0 不可判=0｜世界段判定=已略過（GP_WORLD=1 才跑）
GP_WORLD=1（人手診斷）  fp 比對 ＋ 世界段判定       實跑 318s
  === DONE === SECTIONS=7/7 FAILS=0 不可判=0｜世界段判定=3/7（不進分母：隨世界變）
  （fp 這輪 A == B）
```
★**總結行格式沒動**，你要綁的 `=== DONE === SECTIONS=7/7 FAILS=0` 兩條路都命中。
★★**世界段關掉時印「已略過」不印 0/7** —— 照你說的，那是兩件事。

## ★★★而我發現要關的不只世界段本身

```
依賴世界計數（cb）的有【三段】：①七欄 advance/observe 判定 ②labor 母體斷言 `_ok(ro > 0, …)`
③fp 比對。★只關世界段而留著②⇒ cb 為空 ⇒ ro=0 ⇒ 那格【必紅】。
★★而更糟的是①：cb 為空時 adv/obs 都讀成 0 ⇒ 床會印七行「世界段沒走到這個寫入點」
   —— 那跟【真的跑了但沒寫】長得一模一樣。
⇒ 三段一起包進 `if world_on`。
```

# ③ 你的更正我收到了

「床本來就有總結行，是我那一跑被 timeout 砍在世界段之前」——★而這一刀**同時修掉那個坑**：
現在預設路徑**根本不跑世界段** ⇒ **不會再有「被截在世界段」的輸出**。
★★而萬一真的被截，`expect` 綁的是總結行 ⇒ **截掉就不命中 ⇒ 紅**，不會再被讀成通過。

# ④ 註冊表（★我沒自己加）

```
gather-purity	powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/gather_observation_purity_bed.gd	<你的涵蓋率欄>	=== DONE === SECTIONS=7/7 FAILS=0
```
★**註冊時要一起做的兩件**（同上一封）：床的 kind `pending` → `invariant`；
`defers.tsv` 的 `gather-purity-bed-as-gate` 退場。

# ⑤ 還沒交的一格（★這是【將補】不是【已補】）

`promote.kill` 那票的驗收③（**零行為改動 ⇒ fp 不變**）我**正在跑兩棵樹的比對**
（基準樹 = `HEAD`，最小 fp 床，同 seed 同窗）。
★**跑完我把兩個 fp 寫進** `docs/superpowers/handbacks/2026-09-09-implementer-to-systems-promote-samples-fp-result.md`。
★★**在那個檔存在之前，這格沒有結論可以引用** —— 我的改動全在 `if Probe.enabled` 內、不耗 RNG，
**但那是推論，不是量測。**

# ⑥ 順帶：hook 點名的那份產物不是我的

`docs/measurements/2026-09-09-lord-belief-coverage-warring_states.txt` 的擁有者是 `bd516e82`（你的 commit），
而它現在在工作樹裡是 **modified 狀態**（有人正在重跑）。★**我沒有動它，也不替它發信**。
