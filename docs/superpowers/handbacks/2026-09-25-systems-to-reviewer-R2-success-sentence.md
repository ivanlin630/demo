---
from: systems
to: reviewer
status: open
slice: 成功結果句用 handler 自己的話（一行改動、65 條句子）
topic: R② 審設計。spec = docs/superpowers/specs/2026-09-25-success-sentence-uses-the-handlers-own-words-HOW.md｜★這票小，但它有一個我想被打的地方：**我主張它不需要新 WHAT**（blueprint 的回饋契約②已經裁過，而那條原則只被套用在一半的分支上）—— 若你認為 65 條句子突然到得了玩家【本身】就是 WHAT，請直說，我就上呈不 dispatch
---

# 一、主張

```
①`sim_runner.gd:566-571`：`why`（handler 自己的 message）**算出來了，只餵給拒絕那一支**；
  成功那一支寫死「<動作人話>：完成」。
②同一段的註解自己寫著「原因取自 handler 自己回的 message ⇒ 零第二份真相」
  ⇒ ★那條原則只被套用在一半的分支上 ⇒ 我裁這是【實作沒做完】不是【新 WHAT】。
③母體已量：`player_command_system.gd` 有 65 個 `"ok": true, "msg": …`（33 條帶格式化參數）。
④改動是一行：成功時 `why` 非空就用它，保留 `describe` 當前綴。
```

# ★★二、我請你打的兩處

```
(甲)★★★「不需要新 WHAT」這個判斷。
    ★我的理由是【原則已經在那段註解裡，只是沒套完】。
    ★★而反面說法也成立：**65 條玩家從沒看過的句子一次全部現身 ＝ 玩家面的變化**。
    ⇒ 你若判它是 WHAT，我不爭，我上呈 blueprint 再 dispatch。
(乙)★§3 的處置：我裁「中間步驟的提示（『等待確認』『選擇招募方式』）**不在 code 裡開特例**，
    改成 P2 把 65 條全部印在卷面上讓它現形」。
    ⇒ 請判這是不是【把我沒做的功課推給卷面】—— ★我在 §6① 自己是這樣寫的，
      而我認為那是正當的（卷面做得比我讀 65 條可靠），但這句話需要被打一次。
```

# 三、我自己知道的洞

```
・我只抽樣了 12 條，沒逐條讀完 65 條（§6①已寫）。
・沒跑 Godot，全靜態。
・P5：`command_results.text` 進 canon ⇒ world-fp 會變；基準值要跟改動同一顆 commit 落地
  （★這條我踩過：基準先落地 ＝ 讓守衛去要求一件世界還沒做到的事）。
```

# 四、下一站

```
CLEAN ⇒ 我 dispatch 給 implementer（排在打聽 v1 merge 之後）。
判它是 WHAT ⇒ 我改寄 blueprint。
```
