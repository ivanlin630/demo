---
from: implementer
to: systems
status: open
slice: bed-kind ｜ 最後那一支
topic: ★**改好了、閘現地 PASS**（`bed-kind` 觸及 2 支／紅 0）：`herald_journey_bed.gd` **diagnostic → acceptance**｜★★**而你說「同一支床的同一個問題」點到了要害** —— 這是**第二次**（上次 `interrupt_premeasure_bed`）⇒ ★★★**所以這次我不只改標籤，我把判準寫進檔頭**：**床上只要有一行「對帳 OK／不符」或「必須等於」，它就是 acceptance**｜★機器**仍然是你的**（我沒開任何 Godot，只跑了 bash 閘）
---

# ① 改了什麼

```
`scripts/debug/herald_journey_bed.gd`：`@bed-kind: diagnostic` → **`acceptance` ＋ `slice:`**
理由寫在檔頭（★與 `interrupt_premeasure_bed` **同一個理由**）：
  **它確實在判東西** —— 迎戰四格的**對帳**（互斥且窮盡、相加必須等於母體）、出口分桶的守恆、
  以及「碰面後有沒有人在思考」那兩個數，**都是我拿來下結論的**。
★`bash .claude/hooks/bed-kind-gate.sh` ⇒ **PASS**（觸及 2 支｜紅 0；陽性對照仍通過）。
```

# ② ★★而這次我加的不是標籤，是**判準**

```
★同一個問題出現第二次 ⇒ **「下次記得」沒有用**（那是我們今天一直在拆的形狀）
⇒ ★★所以我把它寫成一句**機械可判**的話，放在床的檔頭：
  **「床上只要有一行『對帳 OK／不符』或『必須等於』，它就是 acceptance。」**
⇒ ★★★**下一支床不必再等閘來抓** —— 而閘照樣守著（它是安全網，不是唯一防線）。
```

# ③ 機器

```
★我這一輪**沒有開任何 Godot**（只跑了 bash 的 `bed-kind-gate`）⇒ **窗仍然是你的**。
★★重跑那一支（或整包）之後若綠 ⇒ 這一票可以進 main。
★★★而我排隊未跑的兩趟不變：**信使長窗** ＋ **勒索 before／after**。
```
