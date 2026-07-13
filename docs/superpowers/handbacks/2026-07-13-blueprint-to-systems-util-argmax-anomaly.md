---
from: blueprint
to: systems
status: consumed
topic: [★優先於①②·疑似argmax不一致] Team7連續67天買糧鎖死,但同筆candidates印出覓食util更高卻從未被選中
---

# 疑點：印出的util跟實際排序依據疑似不同步

## 背景
71/22/7% winner分布數字確認為真（measurer重跑同seed/同bed/main HEAD一字不差重現，見`2026-07-13-measurer-to-blueprint-winner-dist-resolved.md`，原main_story_trace_v7.txt矛盾是比錯log，非數字有誤）。

但measurer意外挖到一個現象：
```
tick=21240 winner=買糧 task=貿易 tgt=(12,3) | candidates: 覓食=0.87 買糧=0.58 生產=0.29 ...
```
理論上argmax該選util最高的「覓食」，但**連續67天(271筆)都選買糧，覓食始終印得比買糧高卻從未被選中**——非單次噪音，可重現、穩定現象。4隊90天日記見`docs/process/verdicts/winner-dist-contradiction-resolved.measure.json` `team_diaries`：Team7 day23-90整段買糧鎖死，配合這個util倒掛一起看。

## 請查（照補丁閘優先查走）
1. candidates印出的util，跟`_decide_unified`/`rank_scored`實際排序依據的util，是不是同一份數值——會不會candidates是印出「pre-coeff」原始util，但排序用的是「post-coeff/post-fallthrough」調整過的值，兩邊print時機不同步（純顯示問題，非邏輯bug）
2. 若印出跟排序確實同源，那就是**dispatch fallthrough或coeff層有邏輯錯置**，讓覓食本該贏卻沒被選中——查`decision_engine.gd:23-38`(加總)+`reorder_same_need_first`(:73-84)+dispatch fallthrough(:1470-1556)這幾處有沒有把「同need類別優先」的邏輯誤套到不該套的地方，導致買糧被錯誤地一路保送贏
3. Team7這67天買糧鎖死是否符合`COMMITMENT_BONUS`防抖動機制的預期範圍，還是超出正常防抖、變相另一種鎖死模式

## 為何優先於①②
如果這是真bug，Team7 71%買糧本身是bug產物，「行為健康多樣」的驗收結論、乃至①(established跨seed)②(重評頻率381)的裁定基礎都要重新看待。**用戶已裁示①②先擱置，等這個疑點查清楚**。

## 邊界
純HOW診斷，你owner。查完回報：真bug（走de-patch）還是顯示時機問題（無需修code，只是log印早了）。查完再回頭談①②要不要復活。
