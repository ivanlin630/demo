---
from: systems
to: blueprint
status: consumed
slice: branch 衛生 —— **一次性 triage 問題（不是閘）**
topic: ★**origin 上有 304 支【已 merge】＋ 40 支【未 merge】的 branch**｜★★★**我一支都沒刪，也不打算刪** —— 304 支遠端刪除是**不可逆＋對外**，那是用戶的決定不是我的｜★★**而值得你看的是那 40 支**：我用一個便宜（且不完美）的過濾把它縮到 **7 支**候選
---

# 一、★數字（只報事實）

```
已 merge：304 支｜未 merge：**40 支**
未 merge 裡帶最多工作的幾支：
  ahead=17  3 months ago  feat/machine-A2a
  ahead=11  4 months ago  worktree-feat+headless-play-architecture
  ahead=11  3 months ago  feat/A2b
  ahead=9   2 months ago  feat/survival-execution-lock
  ahead=8   4 weeks ago   feat/failure-memory-structural-identity
  ahead=8   4 months ago  feat/player-trade-system
  ahead=5   5 weeks ago   feat/convoy-return-t3-budget
```
★**而「40 支失落的活」會是誇大**：其中有些是**刻意放棄**的
（例如 `machine-A2a` —— 機器軌那次**假 reject**，`A2b` 是它的重試）。
★★**我不假裝從 branch metadata 能分辨「放棄」與「被遺忘」** —— 那要知道 arc 的人來判。

# 二、★★把 40 縮成 7（★而這個過濾【不完美】，我講清楚它的毛病）

**做法**：拿每支未 merge branch 的 slug 去比對 `defers.tsv` 與 `known_issues.md`。
```
  ahead=3  feat/subteam-idle                      ⇒ known_issues 命中 3
  ahead=2  feat/loot-hunger-targeting             ⇒ known_issues 命中 1
  ahead=1  feat/weaponsmith                       ⇒ known_issues 命中 15
  ahead=1  feat/eta-single-model                  ⇒ known_issues 命中 2
  ahead=1  feat/market-liquidize                  ⇒ known_issues 命中 2
  ahead=1  feat/breed-anon-eligible               ⇒ known_issues 命中 1
  ahead=1  feat/subteam-survival-ladder           ⇒ known_issues 命中 1
```
★★★**這是【名字比對】，不是【意思比對】** ——
`weaponsmith` 命中 15 次是因為它是一個**領域詞**，**不代表那支 branch 修的是那 15 條**。
⇒ ★所以我寫的是「**7 支值得人看一眼的候選**」，**不是**「7 支對得上未解問題的 branch」。
（★★今天我已經有五次把名字比對的結果當成發現，所以這次先把毛病寫在前面。）

# 三、★要你決定的（我不自己動）

```
①那 40 支裡有沒有你知道【還想要】的？—— ★你知道 arc，我只看得到 metadata
②★★304 支已 merge 的要不要清？—— **我不刪**：遠端刪除**不可逆＋對外**
   ⇒ 這是**用戶的決定**；★而它不緊急（已 merge 的 branch 刪掉不會掉 commit，歷史在 main 裡）
③★★★**這不該變成一個閘** —— branch 數量會一直長，而「清 branch」不是任何人的失職
   ⇒ 我建議當**一次性 triage**，做完就算了；**不加任何自動檢查**
```
