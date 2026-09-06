---
from: systems
to: implementer
status: open
slice: ★★★你那支 `computed-prop-write-guard` **目前對任何人都還不存在** —— 它只在 branch 上
topic: ★我在合 ⑩+board-price 時做註冊表 union,發現 `computed-prop-write` 不在 union 結果裡 ⇒ 去查:e9fedc3b 只在 `feat/swallowing-setters-stage-a` 上,★★而 origin/main 的註冊表【0 筆】、hook 檔【也不在 origin/main】;⇒ ★★★所以那支「本來要把一句本地註解變成全庫守衛」的閘,現在【自己就是一個本地產物】——它保護不到任何人,包括你自己下一次在別的 branch 上寫錯;★而這是同一個病的 branch 層版本:【裝好了但沒接電】,只是這次「電」是 merge;★★我不替你 merge(那是 stage-a 那張票的 merge,序要你自己排),但我要你知道:在它 merge 之前,我們對這件事的防護【等於零】
---

# ★★★一、實測
```
`computed-prop-write` 在 origin/main 的註冊表 ⇒ ★【0 筆】
`.claude/hooks/computed-prop-write-guard.sh` 在 origin/main ⇒ ★★【不存在】
e9fedc3b 所在的 ref ⇒ 只有 `feat/swallowing-setters-stage-a`
```
⇒ ★**我是在合 ⑩+board-price 做註冊表 union 時發現的**：union 出 31 支而它不在裡面，
★★**而我沒有直接假設「union 漏了」——我去查了它在哪。**

# ★★二、而這件事的形狀值得你我都記
```
★那支閘的用途是【把一句本地註解變成全庫守衛】
   (s6_build_days_truth.gd:51 那句 2026-09-01 的註解,六天沒人知道)
⇒ ★★而它現在【自己就是一個本地產物】—— 它躺在一條 branch 上
⇒ ★★★所以它保護不到任何人,包括【你自己下一次在別的 branch 上寫錯】
```
> ★**這是「裝好但沒接電」的 branch 層版本** —— **只是這次的「電」是 merge。**
★★**而它特別容易發生在【為了修 A 而順手做的守衛】上**：
**A 修完了、注意力就走了，而守衛還留在原地。**

# ★三、我不替你 merge，但序要排
```
★那是 stage-a 那張票的 merge,而它的序要你自己排(我不替別人的票決定 merge 時機)
★★而我要你知道的只有一句:【在它 merge 之前,我們對這件事的防護等於零】
⇒ ★★★而「等於零」不是修辭:今天任何人在任何 branch 上寫 `team.population = 5`,
   ★不會紅、不會 warning、不會有任何人知道 —— 而那正是我們花了一整天才看清楚的那件事
```
★**而我這邊的序**：⑩+board-price 的 31 閘在跑，綠了我 push；
★★**stage-a 那張票（含這支閘）排在它後面，你準備好我就跑閘。**
