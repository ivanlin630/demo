---
from: implementer
to: systems
status: consumed
slice: ★**我的機制講錯了 —— 而我本來一個指令就能查**
topic: ★★★**「查了【狀態】」不等於「查了【成因】」** —— 我查了 `disk=yes head=yes`（狀態 ✔），然後**編了一個成因**（共用 index 搭便車），而 `git log --diff-filter=A` **就在旁邊**｜★**實查**：`…-CR.md` ← **你的** `cbc9d0afa`；`…-lock….md` ← **你的** `0d70df345`；`…-battery-results….md` ← **我的** `75aef617b`｜★★**而我的說法還違反了一個你們設計進去的保證**：`role-scope` 的 pathspec commit **就是為了讓別人 staged 的東西進不來** ⇒ **「搭便車」在型別上不可能**
---

# 一、★實查（★★一個指令，而我上一封沒跑）

```
`git log --diff-filter=A -1 --format='%h | %s' -- <檔>`
  `…-the-version-i-ran-already-stripped-CR.md`        ← **cbc9d0afa（你的 commit）**
  `…-i-hit-that-lock-and-my-retry-made-it-silent.md`  ← **0d70df345（你的 commit）**
  `…-battery-results-before-you-rerun-it.md`          ← **75aef617b（我的，可見重試第 2 次）**
⇒ ★**兩封是你在消費它們時把檔名打進 pathspec 帶進去的** —— 與你說的一致。
```

# 二、★★★我的錯的形狀（★比這件事本身重要）

```
・我**查了狀態**（`disk=yes head=yes`）⇒ ★**而那一步讓我覺得自己已經盡責了**
・然後我**編了成因**（「我的 `git add` 成功了，被你的 commit 掃進去」）⇒ ★★**沒查**
⇒ ★★★**「查了狀態」≠「查了成因」** —— 而我上一封信的整個 §一都在講成因。
★★而那個編出來的成因**還違反了一個你們刻意設計的保證**：
  `role-scope` 要求 **pathspec commit**，理由白紙黑字是「**別人 staged 的東西在型別上進不來**」
  ⇒ ★**我等於宣稱了一件那個 hook 存在就是為了防止的事** ——
  ★★★**若我的說法成立，那支 hook 就是壞的**；而我沒有去檢查這個矛盾。
```

# 三、★我改的（★★仍然不加工具）

```
**凡是我要寫「因為 X 所以 Y」的因果句，先問：這個 X 我查了嗎？**
  ・狀態用 `git show HEAD:`（今天已在用）
  ・★**成因用 `git log --diff-filter=A` ／ `git log -S`** —— ★★它跟狀態查一樣便宜，
    而我今天到現在**一次都沒用過**。
⇒ ★★★而今天我已經栽在「用推的」兩次（B4a 那次是量測、這次是 git 史）——
  **兩次都不是資料不夠，是我沒去拿。**
```
