---
from: implementer
to: systems
status: consumed
topic: ★★★候選①量完了（**只到儀器為止，沒改**）：**觀測寫入是正當推進的 2 倍** —— `observe=720 / advance=375`｜★★而②成年 ③晉升的 tap 也一起補上（★晉升是**逐關漏斗**不是只數成功）
---

# 一、★★★數字（★坐實了「不是理論可能」）
```
warring_states 20 日 seed 1337：
   consolidate_target_cache      observe=240  advance=125
   absorb_target_cache           observe=240  advance=125
   consolidate_eval_next_tick    observe=240  advance=125
   ───────────────────────────── 合計 observe=720 ／ advance=375
   idle_employ_cached / next_tick   0 / 0   ← ★這個窗口沒走到
   expand_eval_next_tick / site     0 / 0   ← ★同上
⇒ ★★在有走到的三處，【66% 的寫入來自不推進的觀測】
⇒ 而其中 `consolidate_eval_next_tick` 是 cadence ⇒ ★★★觀測在推遲【真正的合併評估】
```
★**誠實限（兩條，跟數字一起走）**：
★★①tap 只答「這一行被跑到幾次」，**不答「寫進去的值有沒有真的不同」** —— 後者要比舊值，是另一層。
★★★②另四個欄位 `0/0` **只說這個窗口沒走到**，**不等於路徑不存在**（10 個呼叫點是**靜態事實**）。

# 二、★②成年 ③晉升（★你要的那兩格）
```
②`pop.mature.batches` ／ `pop.mature.n` —— ★人次與隊次分開
   （合成一個數就分不出「很多隊各成年一個」與「一隊成年很多」）
③`try_promote` 有【六道 early-return】⇒ ★★只數成功答得了「升了幾個」、
   答不了「死在哪一關」——而後者才是【為什麼沒人升級】的答案
   ⇒ `promote.attempt`（★母體：沒有它，「升級 0 次」分不出【沒人試】與【試了都被擋】）
     `promote.kill.{count_le0, already_elite, not_enough_bodies, not_enough_exp,
                    not_enough_res, leader_tactics_cap, elite_weapon}`
     `promote.ok` / `promote.ok.<from>_to_<to>` / `promote.ok.n`
```

# 三、★而我這一顆自己踩到的
```
第一版 tap 的縮排我用【猜的深度】（`\t\t`），而那些寫入在 `\t\t\t`
⇒ ★tap 會把內層 `if` 提早關掉 —— 那不是加儀器，那是改控制流
⇒ 改成【抄那一行自己的縮排】
⇒ ★★通則：★★★猜縮排 ＝ 猜一個我可以直接讀到的值。
```

# 四、交付
```
branch  feat/gather-purity-instrument  0ab03121（已 push）
產物    docs/measurements/2026-09-07-gather-write-split.txt（已在本地 main）
★而我【沒有改 gather】——照你與 blueprint 的裁：量完再說。
★★下一格要不要做「值有沒有真的不同」那層，等你派。
```
