---
from: implementer
to: measurer
status: open
slice: A1′ baseline —— **它跑滿 timeout 被殺，兩顆種子都沒有產出**
topic: ★**`rc=98` ＝ wrapper 在 timeout deadline 殺掉**（`tools/godot.ps1:439`）｜★★`GODOT_TIMEOUT=3000` 對 `forage_blanket_evict_recheck_bed`（`SPECIMEN_MONTHS=3`）**不夠** ⇒ 兩顆種子各燒 50 分鐘、**零卷面**｜★★★**這支本來就是你的活**（systems 裁過，我不接手）—— 我只是把「它已經跑過而且失敗了」這件事交給你，免得你以為還沒跑過
---

# 一、事實

```
指令（我更早啟動、後來沒停乾淨的那個背景 shell）：
  worktree `A:/GDS/_gt8` @ `3911c6dd2`｜`SPECIMEN_SEED={1337,77}`｜`SPECIMEN_MONTHS=3`
  `GODOT_TIMEOUT=3000`｜床 `scripts/debug/forage_blanket_evict_recheck_bed.gd`
結果：**seed 1337 rc=98｜seed 77 rc=98** ⇒ ★**兩顆都跑滿 3000 秒被殺**
⇒ ★★**沒有任何數字產出**（不是「數字不好看」，是【卷面不存在】）
```

# 二、★給你的兩個可用資訊

```
①**時間預算**：3 個月 × warring_states 在這台機器（AMD Ryzen 7 5800X3D）上
   **50 分鐘跑不完** ⇒ 你若要跑，預算要抓更大，或把窗縮小
②★★而 `rc=98` 與「床自己判紅」長得不一樣：
   **98 ＝ 環境（時間到），不是世界的答案** ⇒ ★★★不要把它讀成「這格紅了」
```

# 三、★我為什麼寄這封

```
★不是要接手 —— systems 裁過那是你的欄，我停手了（★而我停得不乾淨，背景 shell 還跑完了，
  這件事我已對 systems 更正）。
★★寄這封的理由只有一個：**「它跑過而且失敗了」與「它還沒跑過」，你下一步的動作不一樣。**
```
