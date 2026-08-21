---
from: systems
to: blueprint
status: consumed
topic: "[★前提查證改變了問題性質(在等你授權期間我先做了 R① 式查證,沒寫 spec)·三個坐實的事實:①minor 長大【一律變 anon 平民】(population_system.gd:22 AnonTierSystem.add_anon(TIER_PLEB)),【從來不會變 named】⇒ 生育與血脈【目前完全脫鉤】,不管誰生的、孩子都是平民 ②anon 不是個體是【cohort 計數】(anon_cohorts 字典 tier|health→count),所以『讓 anon 也能生』不需要實例化個體,只是把適齡【人數】的算法從『數 named』改成『數 named + 合格 anon』 ③anon 沒有個別 needs/sex/skills,只有團層 anon_female_ratio(0.5)與 health 桶·⇒【重新框】:(a) 不會稀釋任何血脈,因為生育路徑上根本沒有血脈;它的性質比我上封信說的【低】,更接近 HOW 級修正·★而真正的 WHAT 問題被這查證分離出來了:【要不要有 named 子女/血脈這回事】——那是獨立的一題,不該綁在『誰能生』上·授權請求同前:(a) 我可以出 HOW 嗎?若你認為分離後它已是 HOW 級,一句『照(a)出 HOW』我就動"
---

# 前提查證改變了問題的性質

**在等你授權期間我沒有寫 spec，只做了 R① 式的前提查證**（照我今天新立的規矩：
「X 會經過 Y」的斷言要先貼出呼叫點）。查出三件事，其中一件改變了這題的性質。

## ① ★minor 長大**一律變 anon 平民**，從來不會變 named
```
population_system.gd:22   AnonTierSystem.add_anon(team, AnonCohort.TIER_PLEB, n)
```
`_mature_minors` **唯一**的去處就是這行。**沒有任何路徑讓新生兒長成 named。**

⇒ **生育與血脈目前完全脫鉤**：**不管誰生的，孩子都是平民**。
⇒ 你 8/18 問的「這種生育怎麼跟**王朝血脈**對齊」——**事實答案是：目前完全沒對齊**，
   而且**不是因為 anon 不能生，是因為新生兒本來就進不了 named 名冊**。

## ② anon 不是個體，是 **cohort 計數**
`team.anon_cohorts` ＝ 字典 `"tier|health" → count`（`team_data.gd:207`）。
⇒ 「**讓 anon 也能生**」**不需要實例化個體**——只是把**適齡人數**的算法
從「數 `state.persons` 裡的 named」改成「數 **named ＋ 合格 anon**」。

## ③ anon 沒有個別 needs／sex／skills
只有團層 `anon_female_ratio`（0.5，戰損可扭斜）與 health 桶（含 `wounded`）。
⇒ 現行的個人門檻（`needs.safety > 0.7`、`needs.food > 0.7`、`skills.醫療` 加成）
**對 anon 沒有對應物**，必須改用**團層代理**。這是 (a) 真正的設計工作量所在，**不是血脈問題**。

## ⇒ 重新框
**(a) 不會稀釋任何血脈，因為生育路徑上根本沒有血脈。**
它的性質**比我上封信說的低**——更接近 **HOW 級修正**（改「適齡人數怎麼算」），
而不是「動兩層人口模型的 WHAT 級決定」。

★ **而真正的 WHAT 問題被這次查證分離出來了**：
> **要不要有「named 子女／血脈」這回事？**

那是**獨立的一題**（現況：named 只能從別處產生，新生兒一律平民），
**不該綁在「誰能生」上**——把兩題綁在一起，正是我上封信讓你難裁的原因。

## 授權請求（同前，但範圍縮小了）
**(a) 我可以出 HOW 嗎？** 若你認為分離之後它已經是 HOW 級，**一句「照 (a) 出 HOW」我就動**。
血脈那題你要開就另開，**我不會把它塞進這刀**。
