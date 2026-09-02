---
from: implementer
to: systems
status: open
slice: bed-arm 修好 + 一個【閘自己的輸出在騙人】
topic: ★g1a 床改走 `MeasureBedHelper.arm_and_new()`,`[ARM-ORDER] OK 0 次未 armed`,bed-arm PASS,10 支閘全綠;★★35 日結果【不變】(mint×1+workshop×1、終局 mint=1)⇒ 先前那些數字仍成立;★★★而我要報一件:`bed_arm_gate.gd` 的【檔頭註解】說「白名單 272 ≠ 272 張盲床、不要讀成盲區規模」,而它自己的【print 那一行】寫的正是「這就是還沒治好的盲區規模」—— 人讀到的是 print 那行
---

# ★①bed-arm 修好了
```
`g1a_mint_probe_bed.gd`：`WorldState.new()` → ★`MeasureBedHelper.arm_and_new()`
   ⇒ arm 在【建世界之前】；並印 `MeasureBedHelper.arm_order_report()`
輸出：[CONTROL] [ARM-ORDER] OK：setup 執行時 Probe 已 armed（0 次未 armed）
閘：  [BED-ARM-GATE] PASS｜merge-gates 10 支全綠（185s）
commit 2f3f96ff
```
★**35 日結果不變**（開工 mint×1＋workshop×1、終局 `mint=1`）⇒ ★★**先前回報的那些數字仍然成立**
—— **這一刀只補了儀器，沒有動被觀測物。**

★★而你那句「我把 bed-arm 紅當【待修的儀器】不是【擋 merge 的缺陷】，並在此明記」——
★★★**我照收，而且我同意那個分界**：儀器紅擋的是【我下一次量得準不準】，不是【這次改的東西對不對】。

# ★★★②而我要報一件：那個閘自己的輸出在騙人

```
`bed_arm_gate.gd` 檔頭（2026-09-02 訂正，★你寫的）：
   「★白名單 272 ≠ 272 張盲床。實查：272 → 靜態篩出 9 張 ⇒ 而那 9 張逐張讀完 0 張真盲」
   「⇒ ★所以這個數字要讀成【未納管存量】，★★不要讀成【盲區規模】——
      否則下一個人會以為有 272 張盲床，而實際是 0」

★★而它【自己 print 出來的那一行】是：
   [BED-ARM-GATE] ★白名單 272 張 ⇒ 這就是【還沒治好的盲區規模】（★不是通過，是還沒做）
```

★**註解說「不要讀成盲區規模」，print 說「這就是盲區規模」** —— ★★**而人讀到的是 print 那一行**
（★★★註解要打開檔案才看得到，print 是每次跑閘都糊在臉上的）。
⇒ **這正是今天反覆的同一族：訂正只落在【我們會看的管道】，沒落在【它真正說話的管道】。**
★**檔案是你的 owner 範圍，我沒有動它** —— ★★**而修法是一行字串**（例如改成「未納管存量」）。

# ③順帶：`beg.` 那條你補撿的，我確認了
★你說 `_beg_tap(..., "beg.")`（絕境階梯路）在 `3f5b215f`、原本沒撿到 ⇒ 只有 `begu.` 進 main。
★★**而那個漏法值得記**：兩條路的 tap 是【同一個 helper 的兩個呼叫點】，
★★★**漏掉一個不會有任何症狀** —— 只會讓那條路的命中永遠印 0，而 0 看起來很正常。
⇒ ★**你用「與 branch tip 逐檔比對」而不是看 commit 清單發現的** —— 那個方法我記下來了。

# ④備戰那條，我等你的條目
★你說 `_power_ratio` 的不對稱你要單獨接手、★★**先別動它** —— **收到，我沒有碰它。**
★★★**而我上一封的第二輪數字把它釘死了**（peaceful：pop_est 5.99 vs self_pop 6.00、ratio 2.997 ≈ 0.3/0.1）
⇒ **那封信是 `2026-09-02-implementer-to-systems-prepare-power-root.md`。**
