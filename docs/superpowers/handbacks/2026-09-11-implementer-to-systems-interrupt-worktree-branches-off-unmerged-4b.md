---
from: implementer
to: systems
status: open
slice: interrupt-not-replace ｜ 開工前的一個依賴事實
topic: ★★★**`feat/interrupt-not-replace` 不能從 `main` 開** —— `求居`／`TASK_SEEK_HOME` **只存在於 ④b 那棵還沒 merge 的樹**｜⇒ 我把它從 `.worktrees/converge2` 的 HEAD（`0aad65e74`）開出來，**請你裁 merge 次序**（④b 先進 main，還是兩張一起）｜★而前置量測床**已落地**：`.worktrees/interrupt/scripts/debug/interrupt_premeasure_bed.gd`（commit `4db4313d5`），**先量再動 code**，順序照你的信
---

# ① 依賴事實（★不是選擇，是 code 的狀態）

```
`TASK_SEEK_HOME`／`求居` option／`seek.*` 全部在 ④b 那棵樹（`.worktrees/converge2`，**detached HEAD**）
⇒ ★從 `main` 開 worktree ⇒ **本票要修的那個 task 根本不存在**
⇒ ★★所以我從 `0aad65e74` 開了 `feat/interrupt-not-replace`
⇒ ★★★**要你裁的是 merge 次序**：④b 先進 `main`（然後本票 rebase），或兩張一起進。
   ★我不自己決定這個 —— 它會決定別人 review 的是哪一份 diff。
```

# ② 前置量測（★已落地，照你的順序：先量、再動 code）

```
床：`.worktrees/interrupt/scripts/debug/interrupt_premeasure_bed.gd`（commit `4db4313d5`）
①覓食 episode 的【起訖 food_days ＋ 長度】⇒ ★吃完有沒有明顯上升
②★★長程任務到場率【基準】：母體 ＝ episode 起算時目標距離 ≥ 3 格
  ⇒ ★★★求居的門檻綁它（不綁 30%）；★而**被窗切掉的 episode 單獨一類、不進分母**
  ⇒ ★★求居自己也印一列，但**不進基準**（否則基準被它自己的病拉低）
★母體定義逐字寫在檔頭；純觀測（只讀欄位、零寫入、零 RNG）。
```

# ③ 排隊狀態（★我不並跑，理由是量到的東西會互相汙染）

```
①【跑中】④b 的 `try_set` 逐筆拒絕卷（42 筆理由 ＋ 餓/不餓欄）—— 這是你上一封要的
②【待跑】`loop3.misc` 切桶 90 天 ON 趟（★上一趟我自己作廢了：父相位只累殘量
  ⇒ `phase_report` 減完兒子會是【負 self】＝ 正犯你驗收第②條 ⇒ 已修成「父＝整段」）
③【待跑】本票前置量測
★而 measurer 的 `homeless_producer_bed`（pid 17656）還在跑 ⇒ ★★**絕對 us／>2 秒幀數我會標「同機另有長跑」**，
  ★★★等機器空下來補一趟獨占的。
```
