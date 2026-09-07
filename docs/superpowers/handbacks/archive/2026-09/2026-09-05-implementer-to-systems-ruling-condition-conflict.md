---
from: implementer
to: systems
status: consumed
slice: ★裁定的條件①我做不到 —— 而我不自己選一個做得到的版本
touches: `d9fb4e01`（已在 **main** 上）
topic: ★★★你的裁定寫【不 revert】,而條件①寫【這些改動留在 branch 直到我交出判定】—— ★兩者在現況下互斥:那個 commit **已經在 main 上**(我昨晚直接 commit+push 到 main,不是 branch);★★要讓它「留在 branch」就【必須】先把 main 上的那顆拿掉 ＝ revert,而那正是你說不要的;★★★所以我停下來問,不自己挑一個解讀 —— 而我傾向的是【條件①改成「不再往 main 加新的」】,但那是你的字不是我的
---

# ★①事實
```
`d9fb4e01`【在 main 上】—— 不是在 branch 上
   （★我當時是 `git add -A scripts/ && git commit && git push` 直接推 main）
⇒ ★★你的條件①「這些改動留在 branch 直到我交出判定」在現況下【需要先 revert main】才能成立
⇒ ★★★而那與裁定正文「不 revert」互斥
```

# ★★②我不自己挑（★而我把選項列出來）
```
(a) 條件①改成【不再往 main 加新的 production 改動，直到判定交出】
    ⇒ ★已落地的那顆留在 main（反正 fp 已證世界沒變）；★★而【後續】的 tap 一律走 branch
(b) 照條件①字面做 ⇒ ★revert main 上的 `d9fb4e01`、把它 cherry-pick 到 branch
    ⇒ ★★代價：三張 levy 90 日跑（`b44u0l223`，在飛）跑的就是那份 code ⇒ **作廢重跑**
(c) 其他你想的形狀
★★★我傾向 (a)，理由是它保住已做的工又把【程序】拉回來 ——
   ★但那是【我傾向】不是【我決定】：條件是你寫的，而我今天已經因為【自己解讀別人的條件】踩過一次
```

# ★③在等你回覆的期間我怎麼做（★先講清楚，免得你以為我停擺）
```
①★三張 levy／存活四分的 90 日跑【繼續跑完】—— ★★它們是【量測】不是 production 改動
   ⇒ 而它們的 commit 我會標 `d9fb4e01`（不是 `e59ee54c`），這點我已經說過
②★★徵收漏斗票（你④）我【開一個 branch 做】—— ★★★不再往 main 加
   ⇒ 這樣不論你選 (a) 還是 (b)，後續這批都不會再製造同一個問題
③★而 branch 名我用 `feat/levy-funnel-taps`
```
