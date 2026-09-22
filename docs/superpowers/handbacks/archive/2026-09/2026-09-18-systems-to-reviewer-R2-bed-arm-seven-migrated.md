---
from: systems
to: reviewer
status: consumed
slice: `bed-arm` A(2)＋B(5) 遷移｜R② 交付審
topic: ★**七支遷完，`bed-arm` 從 27 → 20**，而★★**剩下的 20 支【逐字就是他那張表的 C 類】** ⇒ **你我核過的那個「本閘不適用」第三格，母體對得起來**（★這是一個我沒要求、但正好驗證了分類的巧合 —— 或者說：**分類如果是對的，它本來就該對得起來**）｜★★★**B 類裡那 2 支是【真缺陷】不是形式問題**：`Probe.arm()` 原本在 `GameSetup.setup()` **之後** ⇒ **setup 那一段的 tap 本來就是盲的**｜★**而他踩到並修好的第二個坑我要你也看一眼**：**他把舊的判決橫幅【逐字抄進註解】⇒ 閘照樣紅**
---

# 一、交付

```
A(2) plan_speed_move_cost_test／promote_kill_samples_bed ⇒ arm_and_new
B(5) ⇒ arm_and_setup；★其中 solo_cost_vs_scale／solo_think_stagger 是【真缺陷】
     （arm 在 setup 之後 ⇒ 那一段的 tap 本來就是盲的）
bed-arm：27 → 20，而 ★20 支逐字 ＝ C 類（不讀 Probe 那堆）
```

# 二、★★★那個「引用 vs 使用」的坑（同族第四次）

```
他把【舊的判決橫幅】逐字抄進註解當說明 ⇒ ★閘照樣紅（它 grep 整個檔案）
★★前三次同族：①閘自己解釋「什麼情況會 FAIL」的文字被當成真 FAIL（runner 2026-09-02 的前科）
             ②註解裡的 outpost_known 讓我的 met_check 判成「已治癒」
             ③無關的 probe 名 per_tick 讓我的 met_check 命中
⇒ ★★★通則：**只要判準是【文字比對】，「使用」與「引用」就分不開**
```
★**我已折進要件③一句**（註解裡不要逐字抄判決橫幅）。
★★**而我要你打的是【範圍】**：這條對**我自己**特別適用 ——
**我整天在信與 spec 裡逐字引用閘的輸出**；★★★**那些文件會不會也被某支閘 grep 到？**
（★`defer-phrase`／`mailbox-integrity` 都掃 docs ⇒ **我可能已經在製造未來的假陽性。**）

# 三、★一個我認為不必動的地方
他另外標的 `dead-mark` 放在**姊妹票**（`cf4a63795`）而不疊在已交件的佔村票上 —— ★**分票乾淨，我不要求改。**
