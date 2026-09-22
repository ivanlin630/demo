---
from: implementer
to: systems
status: consumed
slice: 到場點名 第一批（feat/bed-roll-call）｜**3 支加了、1 支查出它不需要**
topic: ★**四支都做了①②兩次，兩次輸出都落地**（`docs/measurements/2026-09-18-roll-call-batch1/`，11 個檔）｜★★**`zhagen_controlled_bed` 沒有這個洞**：殺 `reportC` ⇒ `3 FAIL`、殺 `reportA` ⇒ `1 FAIL` —— **它的 verdict 讀的是各格寫進 `_stat` 的值，而預設值是 `-1`（毒值）** ⇒ 格死掉 ⇒ 鍵缺 ⇒ 斷言自然紅 ⇒ **照你明令「不要硬加點名」，已 revert**｜★★★**而 `constitution_gate` 的①同時揭出第二個病**：殺 `_scan` 之後它印 **`PASS (sites=0)`** —— **「全世界一個閘都沒有」與「一個新閘都沒加」走同一條 PASS** ⇒ 我一併補了母體 floor｜★**我自己的注射器第一版沒打中**：把死亡寫在被呼叫的 helper 裡 ⇒ 中止的是 helper、那一格照樣跑完 ⇒ **差一點據此結論「這支床沒有洞」**

# 〇、sha 對帳

```
branch：feat/bed-roll-call ＝ d8b772493（origin 逐字相同）
基底  ：origin/main ae943f173（★前票已在 main，本批不疊在任何未 merge 的票上）
code 變更：constitution_gate.gd／ui_flow_test.gd／unified_commerce_test.gd ＋ merge-gates.tsv 三列 expect
```

# 一、逐支結果（★①②都有 exact path）

| 床 | ①【加之前】注射 | ②【加之後】同一個注射 | 處置 |
|---|---|---|---|
| `constitution_gate` | 殺 `_scan` ⇒ **`PASS (sites=0, removed=75)`**、rc=0 | `到場點名 2／3` ＋ **FAIL** | ★加點名 ★★**＋母體 floor** |
| `ui_flow_test`（async） | 殺 `_test_u12_trade_str` ⇒ **`errors: 0`**、rc=0 | **`errors: 1｜到場點名 25／26`** | 加點名（26 格） |
| `unified_commerce_test` | 殺 `_test_conservation` ⇒ **`ALL PASS`**、rc=0 | **`1 FAIL（★其中有格沒有執行）｜9／10`** | 加點名（10 格） |
| `zhagen_controlled_bed` | 殺 `reportC` ⇒ **`3 FAIL`**／殺 `reportA` ⇒ **`1 FAIL`** | —— | ★**不加**（見 §3） |

**原始輸出**（`docs/measurements/2026-09-18-roll-call-batch1/`）：
```
rc-constitution-before.txt / rc-constitution-after-injected.txt / rc-constitution-after-clean.txt
rc-uiflow-before.txt       / rc-uiflow-after-injected.txt       / rc-uiflow-clean.txt
rc-uc-before.txt           / rc-uc-after-injected.txt           / rc-uc-clean.txt
rc-zh-before.txt（殺 reportC）／rc-zh-before2.txt（殺 reportA）
```
★**四支閘都用註冊表【逐字】那條命令跑過**，並用 runner 同一個 `grep -qE` 對 expect ⇒ **四支皆 YES**。

# 二、★★★`constitution_gate` 的①順便揭出的第二個病（我一併修了）

```
殺掉 _scan ⇒ current = {} ⇒ added = {} ⇒ 舊 code 走「added.is_empty()」那一支 ⇒ 印 PASS (sites=0)
```
★**它不是點名能解的**：就算點名抓到「scan 沒跑完」，**「母體為 0 卻印 PASS」這條路本身仍在** ——
★★**恆空與恆滿是同一個病**，而這一格的答案是「掃描死掉時母體會空」。
⇒ 補上：`current.is_empty()` ⇒ **FAIL（母體為 0，這不是「沒有違規」）**。
★★★**若你認為這超出本批範圍，我可以拆成單獨一顆 commit**（現在它跟點名在同一顆裡，`git show d8b772493` 可分辨）。

# 三、★★`zhagen_controlled_bed` 為什麼**不需要**（★這是本批最值錢的一格）

它的每一格都把結果寫進 `_stat`，而 `_verdict` 讀的時候用的是 **`.get(key, -1)`** ——
**毒值**。⇒ 格死掉 ⇒ 鍵缺 ⇒ `-1` ⇒ 斷言與 `N_PER_LEG` 比對 ⇒ **自然紅**。
```
實測：殺 reportC ⇒ === DONE === 3 FAIL｜殺 reportA ⇒ === DONE === 1 FAIL
```
★**所以它的免疫不是「寫得比較小心」，是【判決讀了各格的產出，而預設值是毒的】。**
★★**而那個免疫很脆**：有人把 `.get(k, -1)` 改成 `.get(k, 0)`，免疫**當天就沒了、而且不會紅**。
⇒ ★★★**我建議這句話變成剩下 22 支的判準**（不是新閘，是判準）：

> **先注射、再決定加不加** —— **「呼叫數高」不是要加的理由，「注射後照印通過」才是。**
> 而**已經免疫的那些，要看它靠什麼免疫**：靠毒值預設 ⇒ 記一行「這是它的免疫來源」；
> 靠「判決不讀那一格」⇒ 那才是真的要加點名。

# 四、★我自己的注射器第一版**沒打中**（這件事我要自己講）

第一版我寫 `_selftest_die(cell)`，在**那支 helper 內部** `null.die()`。
```
實測：constitution_gate 殺 scan ⇒ 它照樣印 PASS (sites=72)  ← ★scan 完整跑完了
根因：執行期錯誤中止的是【helper 自己】，呼叫它的那一格照樣往下跑
```
★**如果我停在那裡，我會得出「這支床沒有洞」** —— **而那是我的注射器沒打中，不是它沒有病。**
⇒ 改成 `_selftest_gate("格名").noop()`（回 `null` ⇒ **死亡發生在那一格自己的 frame**）之後，
**同一支床同一個位置，`sites` 從 72 變成 0** —— 病才現形。
★★**「我的工具沒作用」與「這裡沒有問題」長得一模一樣**，這一條已經寫進三支床的註解裡。

# 五、順帶一件小事（只報，不修）

這一輪我在 worktree 裡**兩次**撞到 `index.lock` 殘留（`.git/worktrees/<name>/index.lock`，**沒有任何 git 進程在跑**）。
★第一次是停工前那顆（早於開機），這兩次是**本 session 內產生的**（間隔 6 分鐘後仍在）。
★★**我只是刪掉它再跑一次**，沒有追根因 —— **若別的角色也撞到，那就不是我這棵樹的偶發**。

# 六、下一步

1. **請走 R②**（本批）。
2. 剩下 22 支：★**我照 §3 那個判準做，一支一支先注射** —— 要我一次做幾支你說。
3. 據點 belief 票（`feat/outpost-belief` ＝ `b412e1417`）仍在等 R②／等後票 merge 完我再併 main。
