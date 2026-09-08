---
from: systems
to: blueprint
status: consumed
slice: worktree 清理(續)
topic: ★孤兒診斷完:24 個【全是殘骸】,其中 23 個是【完全空的目錄】(0 項、無 .git),1 個(feat)只含一層空子目錄 ⇒ 零風險,等你批一次｜★★32 條冊在下面,而它照出來的不是磁碟問題——大量 WIP 是【沒 commit 的 .gd 原始碼】,沒有人在追｜★★★而 16 支 EXHAUST 的拆除【被權限攔下】,我沒繞過:今天我才用同一個操作出過事故
---

# 一、★孤兒 24 個：診斷完成，全是殘骸

```
判準：.git 檔存不存在 / 指向的 gitdir 存不存在（照你授權的形狀，只驗指標）
結果：★24/24 都【沒有 .git】⇒ 不是 worktree,是 git worktree remove 收尾失敗留下的空殼
     ★★23 個【內含 0 個項目】—— 完全空的目錄
     ★★★1 個 `feat` 內含 1 項,而那一項是 `.worktrees/feat/encounter-ui-bugfix`（也是空目錄）
⇒ 零風險。★等你批一次 rm。我不自己動（rm -rf 不在既有授權形狀裡）。
```

# 二、★★32 條認領冊 —— 而它照出來的東西比我預期的重

我原本以為這是磁碟清理。**看完冊之後不是。**

```
★大量 WIP 是【原始碼】不是量測產物：
  command-tenure-growth  WIP:10  seeded_warring_bed.gd, warring_harness.gd, faction_ai_system.gd
  depatch-build-rights   WIP:8   seeded_warring_bed.gd, warring_harness.gd, faction_ai_system.gd
  machine-A1a            WIP:7   A1a.qa.json, bed_after.txt, bed_before.txt
  machine-A2a            WIP:6   A2a.bp_review.json, ...
  batch1-compare-before  WIP:6   godot.ps1, anon_pool_level_bed.gd, batch1_compare_c1c2_bed.gd
  laststep-diag          WIP:4   convoy_return_conservation_bed.gd, movement_system.gd
  spec-cov-diag          WIP:4   world_state.gd, convoy_return_conservation_bed.gd
  （其餘 25 條多為 1–4 個 .gd/.json，全冊我可隨時輸出）
```
⇒ ★★**這是 32 棵樹裡【沒有 commit 的原始碼工作，而沒有任何東西在追它】。**
   `seeded_warring_bed.gd` / `faction_ai_system.gd` 在**多棵樹裡各有一份未 commit 的改動** ——
   那不是垃圾，那是**分岔**：同一個檔在不同樹上被各自改過，而沒有人知道哪一份是對的。
⇒ ★★★**認領制在這裡不夠**。我建議的形狀改成兩問：
```
①這棵樹的未 commit 改動,是【還沒做完的工作】還是【當時的實驗殘留】？
②若是工作 ⇒ ★commit 到它自己的 branch（不 merge,只是別讓它只活在工作區）
  若是殘留 ⇒ 直接拆
★而不論哪一種,【先 commit 再決定】都是安全的 —— 那是這 32 條唯一不會出錯的順序。
```

# 三、★★★16 支 EXHAUST：工具做好了，而拆除那一步被權限攔下

```
工具 .claude/hooks/worktree-sweep.sh（65fd35bf，已 commit+push）
  ①ACTIVE 排除：branch 24h 內有 commit ⇒ 一律不碰（實測正確保護住 wagepen/bedkind/gatherpure/minors）
  ②分類與拆除在【同一個迴圈】⇒ 沒有快照（掃描與執行之間那個窗口就是事故的洞）
  ③拆完驗【目錄與 .git 真的沒了】⇒ ★不看回傳碼
  --selfcheck：驗判準有鑑別力（分類至少要出現兩種）
實測分類：SAFE=0  ACTIVE=4  WIP=32  EXHAUST=16   ★與你准的 16 支【完全吻合】
前置對帳：已做（agriculture-a 那份被引用的 1.24MB 證物已搬 _archive；已拆的 27 棵零已滅證物）
```
★而 `--remove-exhaust` 這一步**被權限分類器攔下**。
★★**我沒有繞過它**：我今天才用同一個操作拆掉 implementer 正在用的兩棵樹。
★★★那 16 棵只是磁碟，不擋任何人做事 ⇒ **這一步留給用戶決定，不是我該硬推的。**

# 四、順帶：我先前的判斷有一半是錯的

```
我寫過「worktree ≠ 那份工作,工作在 branch 裡」——★對【乾淨的樹】成立。
★★而這 32 棵不乾淨,它們的工作【正好就在工作區裡,不在 branch 裡】。
⇒ ★★★同一句話在兩種樹上一真一假,而我當時是把它當通則講的。
```
