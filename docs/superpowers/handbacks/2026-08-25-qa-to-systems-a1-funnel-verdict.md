---
from: qa
to: systems
slice: a1-construction-dispatch-drop
status: consumed
topic: "[QA故事稽核:A1紮根funnel]★root.commit_drop.no_camp=0坐實部分confirmed:15隊抽樣裡真出現紮根winner的只有team8/team15兩隻,兩筆result皆committed乾淨(無commit-hook層drop訊號)——team8完整全程(前輪camp-access已讀過,紮根→build_workshop持續、正是唯一complete_crude_camp那筆);team15只有7筆entry、紮根委任後3個tick內specimen就斷,看不到後續有沒有進start/complete(第4種同款覆蓋窗有限案例,非specimen壞掉是這隊很快掉出抽樣可見範圍);start=4裡另外2筆不在15隊抽樣名單內,無法交叉"
---

# QA 故事稽核：A1 紮根 funnel — 正式判決

15 隊抽樣裡，真正出現「紮根」贏 argmax 的只有 **team8**、**team15** 兩隻（跟聚合數字 `settlement.l0_to_l1_start=4` 對不上——另外 2 筆不在這 15 隊抽樣名單內，這輪判不到，誠實列出缺口）。

## team8 ＝ **CONFIRMED 乾淨完整（我前輪 camp-access 稽核已讀過全程）**

tick7610 `建設/紮根 result=committed`（tile `[13,6]`），承接前面 `覓食→紮營`（多個候選 tile 試探後落定）——**這就是聚合數字裡唯一的 `complete_crude_camp=1` + `outpost.l0_to_l1=1`**，全程沒有任何「commit-hook 層蓋了就丟」的訊號：紮根 commit 之後直接接上 `貿易/build_workshop:resource`，`effective_food` 從 2.50 一路衝到 66（詳見我上一封 team8 verdict）。**這一筆對 `no_camp=0` 是硬證據，非聚合猜測。**

## team15 ＝ **委任乾淨，但故事看不到後續（specimen 覆蓋窗又斷了）**

```
tick7400  task=紮根 result=try_set_noop  （task 已是紮根，noop 正常，同 winner 重複判定的機械副作用）
tick7400  task=紮營 result=committed
tick7410  task=紮根 result=committed     ← 真正委任這一刻
tick7420  task=紮根 result=try_set_noop
tick7420  task=紮營 result=committed
（specimen 到此為止，team15 全部只有 7 筆 entry）
```

**委任本身乾淨**——`result=committed`、沒有任何 drop/reject 訊號，跟 team8 同款「commit 沒被 commit-hook 層擋下」——**這部分支持 `no_camp=0` 的判讀**。**但 team15 的故事只到 tick7420 就沒了**，我看不到它有沒有真的推進到 `settlement.l0_to_l1_start`（聚合數字裡的 `start=4`）、更看不到它是不是 `start=4` 裡沒 `complete` 的那 3 筆之一。這不是 specimen 壞掉——是這隊很快從抽樣可見範圍掉出去（同一種「覆蓋窗只夠看一小段」的限制，我這輪起碼還能確認「委任那一刻本身乾淨」，比完全看不到強）。

## 結論

**`root.commit_drop.no_camp=0` 這條聚合數字，我能拿到的兩個真實案例（team8/team15）都支持它**——**committed 那一刻本身沒有被 commit-hook 層擋下的訊號**。但 `start=4` 裡有 2 筆不在抽樣名單，team15 也只驗到「委任乾淨」驗不到「後續有沒有真的 start/complete」——**這是部分confirmed，不是全量4筆都驗證過**。

**建議**：若要把 `no_camp=0` 完全坐實成「commit-hook層絕對沒有蓋了就丟」，需要另外 2 筆 start 事件所屬的隊也在下次 specimen 抽樣名單內（或全隊抽樣，這批世界似乎隊數不多，成本應該可控）。目前的證據支持方向、不到「窮盡驗證」的程度。

地基 KEEP。
