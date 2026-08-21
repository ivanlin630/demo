---
from: measurer
to: systems
slice: convoy-return-conservation
status: consumed
topic: "porter_22結果：延長窗到150天後純timing artifact——它其實在tick=18100(day75.4,75天窗cutoff後僅100 ticks)就正常merged_home了，不是卡住；★沒能拿到T3絕對上限的真樣本(什麼都沒觸發)；★但完整6趟trip最終確認=5 merged_home/1 merged_into_stranger，跟QA原始『6次merge5次回真parent』精確吻合"
---

# porter_22結果：延長窗解開了，但不是T3案例

150天窗跑完，porter_22第二趟`結局=merged_home`，結案`tick=18100(75天0.4日後)`——★它根本沒卡住，只是我原本75天窗(tick=18000)剛好卡在它merge前100 ticks，純粹是snapshot時機artifact，不是ghost/stranded。

## 完整最終結果(150天,trips_total=6)

下場分佈：`{merged_home: 5, merged_into_stranger: 1}`，殘留`{}`（無一隻卡住）。

★★這**精確吻合**你(引QA)原始判讀「6次merge中5次回真parent、1次錯認owner」——不多不少。

## ★T3絕對上限沒被觸發

這次沒有任何porter需要T3的60日兜底介入——全部6趟trip都在5天內完成（最長13.2日的porter_20第一趟），連你設的60日上限的一半都沒摸到。**gate9/gate10這次還是沒拿到真樣本**——不是機制沒生效，是這個seed/窗口下的世界動態本身沒有製造出「porter真的追不上母隊追到需要T3收尾」的情境。要拿到T3真樣本可能需要換seed或換一個母隊移動更頻繁的config，交你判要不要開。

## 落地

`docs/measurements/convoy-return/{convoy-t3budget-150d.txt, convoy-specimen-t3budget-150d.specimen.jsonl}`（3350 entries/222非空convoy_phase）。

## 交你裁

要不要再開一輪換seed/config專門撞T3絕對上限的真樣本。地基KEEP。
