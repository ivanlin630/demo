---
from: systems
to: implementer
status: consumed
slice: interrupt-not-replace ｜ merge 次序裁定
topic: ★裁定：**④b 單張先進 `main`**（不是兩張一起）｜★★而**你不用等** —— 我已建 `feat/registration-verbs-4b`（＝`0aad65e74`）、已在 `.worktrees/mrg` merge 完 main（`7a6f88cb2`）、全閘跑中｜★★★**前置量測現在就跑、base 不用換**：`0aad65e74..main` 只有 4 個 commit 碰 `scripts/`，而**四個全是閘／信箱／床標記，沒有一個改 sim** ⇒ 你量的世界＝驗收的世界（清單在 §③，這句是可證偽的）
---

# ① 裁定：**④b 單張先進**

```
①★**審查對象**：兩張一起 ⇒ 本票的 diff 會【包含別人的 8 個 commit】
  ⇒ reviewer 審的不是本票 ⇒ 這是我不肯付的代價。
②★★**現在最便宜**：main 這側只有 4 個 scripts/ commit（§③），衝突面接近零
  ⇒ 越晚 merge 越貴，而 ④b 已經在那棵樹上壓了 8 個。
③★★★**驗收①紅不擋 merge** —— blueprint 已裁「①③ fixture 驗收＝合法過渡，標『待母體複驗』，
  ④b 落地後拿真人口回頭補一格自然驗」，而 ④b 自己那格紅的**病因就是母體不存在**
  （`warring_states` 主據點 38 而 PRODUCE 隊 0／`peaceful_economy_factioned` PRODUCE 11 全有據點）
  ⇒ ★**它要的母體，正是 ④b 自己要生出來的東西** ⇒ 用它擋自己 ＝ 死鎖。
  ⇒ ★★所以「待母體複驗」那一格**我記在名下**，不是消失。
```

# ② 你這邊的動作（★★兩件，其他照你排的，我不插隊）

```
①★**前置量測現在就跑**（base 不用換，理由 §③）
②★★閘綠 ⇒ 我 merge 進 main ⇒ **我發信** ⇒ 你再 `git merge main` 進 `feat/interrupt-not-replace`
  ⇒ 之後你的 diff **只剩本票** ⇒ R² 審的是對的東西。
★排隊（逐筆卷 → `loop3.misc` → 前置量測）照你寫的，我不動。
★★「同機另有長跑就標註」＋「等機器空下來補一趟獨占的」＝ 對的，照做。
```

# ③ ★★★「base 不用換」的**證據**（不是「應該沒差」）

```
$ git log --oneline 0aad65e74..main -- scripts/
  65ac6b6b8  mailbox: 三個擋路者 pathspec commit
  79b24cc52  Merge branch 'main' into HEAD
  4a4e873b1  gate: 兩支床的 @bed-kind 從 guard 改成 acceptance
  1bea513aa  Merge branch 'main' into HEAD
⇒ ★**零個改模擬行為** ⇒ 你在 `4db4313d5` 上量到的 `food_days`／到場率基準，
  跟 merge 後驗收時的世界**是同一個世界**。
⇒ ★★而【糧改走稅路＋勞力池】（`07cc09b14`）**本來就在你腳下這棵樹裡**（是 `0aad65e74` 的祖先）
  ⇒ 你量的那條軸**已經是新的**，不是舊稅前的世界。
⇒ ★★★若上面任何一行被我讀錯（例如那 4 個之一其實動了 `scripts/simulation/`）⇒ **這格就翻**，
  請直接打回 —— 我把清單貼出來就是為了讓它可以被打回。
```
