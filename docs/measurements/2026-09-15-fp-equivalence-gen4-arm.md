# fp 等價驗證：gen4 那一臂的兩棵樹（2026-09-15 落地）

★**結論：fp 逐字相同 ⇒ 那次 commit 對世界無影響 ⇒ gen4 三趟可合為一臂。**

## 為什麼要驗

多 seed 六趟跑到一半，implementer **往被量的那棵樹（`.worktrees/herald`）commit 了 sim code**
（`c3696b0d3` 09:58，食慾輸入稽核的 Probe tap）。結果：

- `gen4/1337` 09:13 起跑 ⇒ 樹 `9b4e40fd8`
- `gen4/4242`、`gen4/7` 09:58 之後起跑 ⇒ 樹 `e15c5227b`

★**同一臂三趟不是同一份 code** ⇒ systems 裁：**不可合為一臂，除非用 fp 證明那次變動對世界無影響**。
★★而「那些 tap 只是 Probe、應該無害」**不是證據** —— 靜態讀 code 讀不出「會不會改世界」。

## 跑法（★事先寫死判準，不是看到數字才定）

```
新 worktree `.worktrees/fpcheck` @ 9b4e40fd8（乾淨）★不在 herald 原地 checkout
前置：先驗床在兩個 commit 之間沒變（git diff 9b4e40fd8 e15c5227b -- combat_multiseed_bed.gd ＝ 空）
     ⇒ ★否則比到的是床的差，不是 code 的差
CM_SEED=1337｜CM_TICKS=2880（2 天）｜一次一趟｜old → new
判準：fp 逐字相同 ⇒ 可合；不同 ⇒ gen4/1337 作廢重跑（其餘五趟不重跑）
```

## 實得

```
old  [TREE] path=.worktrees/fpcheck commit=9b4e40fd8 clean=yes codehash=clean
     ★fp = e78693dff291755db5749f038f8987db
new  [TREE] path=.worktrees/herald  commit=e15c5227b clean=yes codehash=clean
     ★fp = e78693dff291755db5749f038f8987db
⇒ ★★**逐字相同** ⇒ 判定：那次 commit **對世界無影響**。
```

原始 log：`docs/measurements/2026-09-15-fpeq-old-9b4e40fd8.txt` / `...-fpeq-new-e15c5227b.txt`

## ★★★這份驗證證明的與**不**證明的

```
★證明：**那一次 commit（該 seed、該窗）不改變世界狀態** ⇒ 三趟可合為一臂。
★★不證明：**所有 Probe tap 都無害** —— 這是一次具體比對，不是一條通則。
★★★也不證明：**更長的窗不會分岔** —— 而 fp 是逐 tick 狀態指紋，
   行為若有差，2 天窗內就該分岔；這是本驗證的假設，寫出來讓它可被質疑。
```

## 附：這趟為什麼晚了三天

```
★這兩趟 **09-12 12:44 就跑完了**，而輸出寫在 **scratchpad** ——
★★scratchpad 對別人是不存在的 ⇒ **從外面看，它與「從來沒跑」完全一樣**。
⇒ ★★★「活著 ≠ 前進 ≠ 送達」的第三格：**跑完不等於送達** ——
  **送達的唯一證明是【repo 裡有檔案 ＋ 有人被通知】**，而我兩件都沒做。
```
