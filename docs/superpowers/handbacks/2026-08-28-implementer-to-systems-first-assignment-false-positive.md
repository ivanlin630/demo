---
from: implementer
to: systems
status: consumed
slice: poll-retire-precondition
tier: measure
topic: ★★★30 日 warring 跑出來了，而裡面有一顆【會翻轉你裁決】的假陽性：INTENT 貢獻率 10.3% 是假的（8 筆「改變」全是 ""→X ＝ f.intent 初值空的首次賦值），真值 0%;★★而 10.3% 正好落在你判準的「分子>0 ⇒ 不退場」上;★已修+兩床重跑中，磁碟上那份舊檔請先別引
---

# ★★★①先講會誤導你的那件（第二次了，同一種形狀）

```
docs/measurements/2026-08-28-poll-unique-value-warring_states.txt   ← 磁碟上這份是【第一輪】
   它寫著：INTENT|78|8|70|10.3%
★★而那 8 筆「改變」是【假的】。
```

**成因池逐筆看得到**（這正是我堅持印 `before→after` 原文而不是只印聚合率的原因）：
```
cause|6|INTENT｜ → 防衛:-1
cause|2|INTENT｜ → 守成:-1
        ↑ before 是【空字串】
```
`f.intent` 初值是空字典 ⇒ `_intent_sig()` 回 `""` ⇒ **第一次填上被記成「選擇變了」**。
★**而 8 == 這張床的勢力數（faction=8）** —— 每個勢力剛好一次首次賦值，數字自己說明了它是什麼。

⇒ **INTENT 的真值是 0%，不是 10.3%。**

## ★★為什麼這顆非講不可

★**10.3% 正好落在你判準的分界上**：
> **③分子 > 0 ⇒ 不退，③那欄的清單交我**

⇒ **若我沒抓到，你會對著一個「首次賦值」開出「不退場 + 待補 T0 kind 候選」的裁決。**
★★**這不是報表好不好看的問題，是【假陽性直接改變裁決】。**

已修 `3582fd0d`：`poll.first` 獨立成第四桶，貢獻率分母 = 改變 + 維持（**排除首次賦值**）。
★**兩床都在重跑**（走 `.claude/hooks/longrun.sh`，beacon 自動掛撤）。
⇒ **在覆寫之前，磁碟上那份的 INTENT 那一列請別引。**

# ★②第一輪的其他數字（★那幾欄不受這顆 bug 影響，但仍等重跑確認）

## 貢獻率（分子/分母）
```
GOAL       779 次純 cadence ｜改變 0 ｜維持 779 ｜★0.0%
STRATEGIC   67 次           ｜改變 0 ｜維持 67  ｜★0.0%
LADDER     266 次           ｜改變 24｜維持 242 ｜★9.0%  ←★真的（成因是 rung 升降）
INTENT      78 次           ｜★真值 0.0%（上面那顆修掉之後）
五支量不到（ALLIANCE/BETRAY/INFRA/FACTION_UPDATE/INDEP_INFRA）
```

## ★★★④延遲欄 —— 它把 GOAL 推進你的【第四種結論】
```
支別        樣本   中位    平均     最大      ★之後再也沒醒
GOAL        632   2400   4408.9   28200    147
LADDER      200   3000   5040.6   24300     42
STRATEGIC    66    360    536.4    3900      1
INTENT       69    420    813.9   12840      1
（1440 tick = 1 日）
```
⇒ **GOAL：貢獻率 0%，但中位延遲 1.7 日、最大 19.6 日、★147 筆之後【再也沒有】事件喚醒。**
★**這正好是你寫的第四種**：
> **④分子 ≈ 0 但延遲量【大】 ⇒ 輪詢沒在改變決策，但它是【兜底的時效保證】**

★★**而 STRATEGIC 是另一種**：貢獻率 0%、延遲中位僅 360 tick（0.25 日）、只有 1 筆從此沒醒
⇒ **它比較像「真的冗餘」。★但那一格是你裁，我只把數字分開。**

## ⑦ 落空率（30 日，★不是 2 日那個 51%）
```
GOAL 24.1% ｜ LADDER 12.0% ｜ STRATEGIC 0.0% ｜ ALLIANCE 0.0%
BETRAY/INFRA/FACTION_UPDATE 5.3% ｜ INDEP_INFRA 48.6% ｜ INTENT 7.3%
```
★**我先前寄你的 51% 是 2 日母體，作廢** —— 30 日這組才是。
★★**INDEP_INFRA 48.6% 是最高的那個**，而它的 `no_consumer` 有 21565（獨立隊才有這一支）
⇒ **分母已經排除 no_consumer，所以 48.6% 是真的落空不是分類問題。**

## ⑥ rung_changed → INTENT（#3 驗收②）
```
同 tick 醒 = 44 ／ 之後才醒 = 3 ／ ★從此沒醒過 = 0 ／ 獨立隊無勢力 = 89 ／ 樣本 136
```
★**「從此沒醒 = 0」是這條的重點**；★★**而有 3 筆是【之後才醒】不是同 tick，我沒有把它們併進同 tick**。

# ★③兩件我不做的事

1. **不替你選修法**（(a)/(b)/(c)）—— 逐 kind 落空率與 unseen/no_consumer 已分開，那格是你的。
2. **不替那五支「量不到」造代理指標** —— 照你 ⑤ 那條。
   ★若要讓它們進分母，那是**改 code 讓選擇落到可比較的地方**，不是加 tap，另一票。

# ④exact path
```
docs/measurements/2026-08-28-poll-unique-value-warring_states.txt    （★第一輪，INTENT 那列作廢，重跑中）
docs/measurements/2026-08-28-poll-unique-value-peaceful_economy.txt  （★跑中，還沒有內容）
docs/measurements/2026-08-28-s4b-wake-coverage-warring_states.txt    （★判決句待重跑覆寫，逐格資料是對的）
scripts/debug/s5_poll_unique_value.gd                                （床本體）
```
★**fp 也在同一批跑**，跑完一起寄。
