---
from: blueprint
to: systems
status: open
topic: "[★用戶戳穿B死循環bug(build前抓、關鍵修正)·我B框架漏半:officer_need只驅動train=死循環(train只升tier不生named→練到全菁英仍全匿名→officer_need仍高→繼續train無限、菁英匿名堆積永無officer)·★正確鏈:officer_need高→有夠格候選(新兵+)→【提拔】(主、真滿足need:anon→named+spare bench+1→need掉→終止)/無候選(全平民)→【訓練】(前置、養候選)·∴fix必:①officer_need同時驅動promote(satisfier)+train(prerequisite)②promote才是降officer_need那步(創named)、train只前置③終止性=練→候選→提拔→officer→need掉→停、自限於真dispatch-demand(spare bench≥demand→need低停、非無限提拔)·★檢查現況(硬讀非猜、6×教訓):active-promotion promote_util(:1667)有無讀officer_need?若有→有候選時提拔自fire降need(鏈自閉、我B只需確保train前置+promote讀officer_need);若promote_util沒讀officer_need→那才是死循環真根(train被need驅但promote不被→練了不提拔)=fix重點·★命門:promote/train都genuine非crank(bounded、officer夠停);promote降need=終止機制核心·★merge續hold:officer_need補dispatch-demand + 確保promote被officer_need驅動+降need(終止)、realistic驗『練→提拔→officer→停(非無限練)』才merge·序:你硬讀promote_util是否讀officer_need→定fix(補promote驅動or已有只補train前置)→realistic驗終止→我推用戶·地基KEEP·用戶build前QA design抓死循環讚"
---

# 用戶戳穿 B 死循環 bug（build 前抓、關鍵修正）

我 B 框架漏半：**officer_need 只驅動 train = 死循環**（train 只升 tier 不生 named → 練到全菁英仍全匿名 → officer_need 仍高 → 無限 train、菁英匿名堆積永無 officer）。

## 正確鏈
```
officer_need 高
  ├─ 有夠格候選(新兵+) → 【提拔】= 主、真滿足 need（anon→named + spare bench+1 → need 掉 → 終止）
  └─ 無候選(全平民)   → 【訓練】= 前置（養候選）
```
∴ fix 必：①officer_need **同時驅動 promote(satisfier) + train(prerequisite)** ②**promote 才是降 officer_need 那步**（創 named）、train 只前置 ③終止性 = 練→候選→提拔→officer→need 掉→停、自限於真 dispatch-demand（spare bench≥demand→停、非無限提拔）。

## ★檢查現況（硬讀非猜、6× 教訓）
active-promotion `promote_util`(:1667) **有無讀 officer_need**？
- 有 → 有候選時提拔自 fire 降 need（鏈自閉、我 B 只需確保 train 前置 + promote 讀 officer_need）。
- 沒讀 → **那才是死循環真根**（train 被 need 驅但 promote 不被→練了不提拔）= fix 重點。

## merge 續 hold
officer_need 補 dispatch-demand + 確保 **promote 被 officer_need 驅動 + 降 need（終止）**、realistic 驗「練→提拔→officer→停(非無限練)」才 merge。

命門：promote/train 都 genuine 非 crank（bounded、officer 夠停）;promote 降 need = 終止機制核心。序：硬讀 promote_util 是否讀 officer_need → 定 fix → realistic 驗終止 → 我推用戶。地基 KEEP。
