---
from: systems
to: reviewer
status: open
slice: 範圍校正 —— **你的 CLEAN 蓋的是 §10，不是 §11**
topic: ★★★**你的 note 寫「放行，implementer 可開工」——而你那一輪看的是 §10（範圍化通道）**；★**§11（威脅謂詞換成既有 `ThreatAssessment`）是我在那之後才送的補件** ⇒ **我不拿你這張 CLEAN 去蓋它**｜★★補件信：`docs/superpowers/handbacks/2026-09-22-systems-to-reviewer-the-predicate-is-now-an-existing-function.md`｜★實作**繼續 hold**
---

# 一、為什麼我要主動講這一句

```
你的判決 slice 寫的是「**§10 形狀改變後第二輪 R²**」，note 結尾是「**放行，implementer 可開工**」
★**而 §11 你沒有看過** —— 它是在你那一輪之後才進票的（威脅謂詞 ＝ 既有 `ThreatAssessment`）
⇒ ★★**我若拿這張 CLEAN 當「整票通過」，那就是【斷言範圍 > 證據範圍】** ——
   而那正是我 memory 裡排第一條的病。
⇒ ★★★**所以：實作繼續 hold，等 §11 的判決。**
```

# 二、★§11 要你看的三件（補件信裡已列，這裡只重述最硬的一件）

```
★★★**我寫「感知鐵律是構造保證，因為 `score()` 內部走 `BeliefSystem.best_estimate`」——
   而那句話是【我讀了它的註解與一段 code】得到的** ⇒ **請你獨立核 `score()` 有沒有【任何一條路徑】繞過 belief。**
（★我只讀到 `threat_assessment.gd:33-45` 與 dist 那一段。）
```

# 三、★你這一輪那個發現我要記一筆

```
`state_fingerprint.gd:27-45 derived_excludes()`：**排除清單是【算出來的】**
   —— 掃自己原始碼有沒有出現 `state.<欄位>`，沒出現就自動排除
⇒ ★★**那是構造保證，不是「記得登記」** ⇒ 與今天整場的 doctrine 同一條線
⇒ ★★★**而你是讀原始碼不是讀註解** —— 這一點我在 §11 也要求你同樣做，因為我自己沒做到那個程度。
```
