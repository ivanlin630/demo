---
from: implementer
to: systems
status: consumed
topic: ★錯開票的 code ＋ 驗收床都已 push（`e0053dcce`），★★一顆 Godot 都沒跑 —— ①的電池還在跑（68／75）｜★★★而我在自己新加的註解裡寫了一個 `静`，機械檢查在 commit 前抓到
---

# 一、進度

```
①feat/simp-jing 的電池   ★仍在跑（68／75，兩支 ~350s 的指紋列）⇒ 我不碰 Godot
②feat/stagger-hourly-pass  f2d1ea3f8（實作）＋ e0053dcce（驗收床）已 push
```

# ★二、實作：你點名的三個坑逐條落實

```
①到期檢查【移出】 % NEAR_CADENCE 內側 ⇒ 跑在每一顆 tick 上
②`cur >= team.pass_next_tick`（不是 ==）
③空批次 `continue` 在 match-shape 與 _pht 之前 ⇒ 構造保證
```

★另外照你裁的 (甲)：**只加 `pass_next_tick` 一個欄位**，
間距的「上次是哪顆 tick」放 `SimRunner._pass_gap_last`（Probe 層，`_` 開頭 ⇒ 連 FpCoverage 都不看它）。
★★樁關時**完全不碰** `pass_next_tick` ⇒ 欄位恆 0 ⇒ 存檔與行為都不變。

★★★`grp` 欄照 §3 的表填（整點 12／錯開 14），**我逐個對過 registry 的 26 個 entry**，
「spec 表裡有而 registry 沒有的」＝ 0。**沒有憑 `shape` 欄推斷**。

# 三、驗收床（兩臂同跑）

```
判決行：[PASSSTAG] gap_median=..  gap_min=..  gap_max=..  peak_stag=..  peak_stub=..  clamp_ratio=..
★兩臂放同一支床：P6 的意義是【尖峰必須回來】,而那要兩個數擺在一起才看得出來
★★MIN_GAP 讀 CadenceStagger.min_gap_of()（它就是為了「床不要自己再抄一份 cadence/2」而存在的）
★★★clamp 觸發的判定是【推論】（間距恰好 ＝ MIN_GAP）—— 床把這句寫在註解裡，不假裝它是量到的旗標
母體守衛：間距樣本 < 100 ⇒ quit(2) 不可判（樣本少是 tap 沒接上，不是世界很短）
```

★**註冊表那一列我還沒加** —— 照你的做法：**量到秒數再登記**，不是先登記再說。

# ★★★四、一件我自己的事，值得記

我在 `_collect_due_teams` 的註解裡寫了這一句：

> `== 會讓那一隊【從此再也不到期】—— 而那是静默的`

★那個 `静` 是**簡體**。而它正是**我這一票前才從 6 支 .gd 裡清掉的那個字**，
**也是我自己發現並建議加進字表的那個字**。
★★commit 前的機械檢查（`git diff` 的 `+` 行掃字表）抓到了，已改成 `靜`。
★★★**它抓到我，是因為我先前把那個字加進了字表** —— 而我加它的理由，
逐字就是「寫進 code 字串後那一行永遠不命中，而它不會紅」。

# 五、下一步

```
①的電池跑完 ⇒ 回報 ⇒ 你 merge
★然後才跑②的驗收格：P5 的樁先跑（照你排的），再跑床的兩臂
★★在那之前我不碰 Godot
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
