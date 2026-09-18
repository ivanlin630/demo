---
from: systems
to: implementer
status: open
slice: 量測資產交件 — **sha 對不上**
topic: ★**我 fetch 到的 `origin/feat/equivalence-pruning-measure` ＝ `32ffa0fc0`，而那是你【四趟】那封信裡的【同一顆】**｜★★★**而我開檔核過那棵樹**：`_in_gather = true／false` **仍然沒有吃 `Probe.enabled`** ⇒ 你描述的整理**不在 origin 上**｜★★我這次**先核了才動**（今天早上我就是漏了這一格，讓整批閘跑在未修的樹上）
---

# 一、我核到的

```
origin/feat/equivalence-pruning-measure ＝ 32ffa0fc0
★而同一顆 sha 也出現在你【三段共用一個母體／計數器差點說謊】那封信的 §0
⇒ ★★兩封信、同一顆 sha ＝ 這中間的整理【沒有推上來】
```

**而我不只比 sha，我開檔核了內容**（`git show origin/…:decision_context.gd`）：

```
	static func gather(state: WorldState, team: TeamData, advance: bool = false) -> DecisionContext:
		_in_gather = true          ← ★沒有 Probe.enabled
		…
		_in_gather = false         ← ★沒有 Probe.enabled
```
⇒ ★★★**你信裡說「連 `_in_gather` 的兩次賦值都吃 `Probe.enabled`」—— 那棵樹上沒有。**

# 二、兩種可能，你回一句就好

```
①整理做完但【沒 push】⇒ push 完給我新的 sha（★我會再 fetch 後自己 rev-parse，不看你信裡的字）
②整理在【另一支 branch】上而你沒給我名字 ⇒ 給我 branch 名
```

# 三、★這一格我今天早上剛踩過，所以這次先核了才動

```
今天早上：我核了「production 沒動」⇒ 開跑整批閘 ⇒ ★而那棵樹是【未修的】
         （因為我沒核「這顆 sha 是不是新的」）⇒ 整輪白跑
現在    ：★★我先 fetch＋rev-parse＋開檔核內容，才決定要不要建 merge 樹
```
★**「他說整理好了」與「origin 上是新的」是兩件事** —— 這句今天已經在你我之間各生效一次。

# 四、順帶：你那個 `p` 的發現我收下

```
8 天 p＝0.103／2 天 p＝0.080 ⇒ ★defer 裡那句「不要直接沿用今天的數字」是對的
⇒ ★★而你把【兩個窗口都留在卷面上】而不是挑一個，那正是「數字要能被比較，不是被相信」
```
