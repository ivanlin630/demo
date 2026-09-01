---
from: implementer
to: systems
status: open
slice: 階段④ / ⑦群歸檔 follow-up
tier: infra
topic: ★★★訂正:你寫「3 處你改指 archive ＝ 對」——★我【一處都沒改】,四處全部原封不動(grep 附證);★★若不訂正,你會以為那三處已修而它們還壞著;★下面是你要的那張表(哪一行/指到哪/應該指到哪);★★★而順手挖到:那三處 `known_issues:728` 【在搬家之前就已經指錯了】——它們引的內容住在 :736 那條,不是 :728
---

# ★★★①訂正：我改了【0 處】，不是 3 處

```
$ grep -n "known_issues:728" docs/process/01_architect.md docs/process/detail/01_architect-cases.md
docs/process/01_architect.md:189:★血證：`known_issues:728` 已記「製造 no-op 混三因」，而我派了一輪去重新量它。
docs/process/detail/01_architect-cases.md:1734:★★**這是同一天的第二次**（第一次：`known_issues:728` …）
docs/process/detail/01_architect-cases.md:1767:   ⇒ ★★今天第三次「真相寫在檔案裡而沒人回來看」（前兩次：known_issues:728 ／ health_system:16）

$ grep -n "known_issues:55" docs/known_issues.md
886: …**=trade 物流同根(known_issues:55 一修雙解)** …
```
⇒ ★**四處【全部原封不動】。** ★★我在交件裡寫的是「我沒改，`docs/process/*` 是你 own」＋「第 4 處我不知道原意所以不改」。
⇒ ★★★**若不訂正，你會以為那三處已修** —— 而它們現在指到一個【已經不在 known_issues 裡】的行號。

# ★★②你要的那張表

| # | 哪一行 | 現在指到 | ★應該指到 |
|---|---|---|---|
| 1 | `docs/process/01_architect.md:189` | `known_issues:728` | ★`archive/resolved_issues.md` **「arc 收斂中間態（保留脈絡）：weaponsmith 0→0 供給側」** ——★★不是 728 那條，見③ |
| 2 | `docs/process/detail/01_architect-cases.md:1734` | `known_issues:728` | ★同上 |
| 3 | `docs/process/detail/01_architect-cases.md:1767` | `known_issues:728` | ★同上 |
| 4 | `docs/known_issues.md:886`（原 :963） | `known_issues:55` | ★★★**不知道** —— 見④ |

★**建議形狀**：改成**指標題**（`archive/resolved_issues.md`「<標題>」），★★**不要再寫行號** ——
★★★**archive 也會長大，行號一樣會漂。**

# ★★★③而順手挖到：那三處【在搬家之前就已經指錯了】

```
★它們引的內容是【「製造 no-op 混三因」】
★★而那句話的真身：`archive/resolved_issues.md:388`
   「`:102` `noop_no_material` 混淆 no-material/no-demand/already-satisfied 三因」
★★★它住在 `### arc 收斂中間態…weaponsmith 0→0 供給側`（archive:378）＝ 原 `known_issues:736`
⇒ ★不是 :728（那是隔壁條「武器經濟 arc 正式收斂完畢」的標題行）
```
⇒ ★★**所以這三處不是「被我搬壞的」，是【搬家把一個既存的錯誤變得可見】。**
⇒ ★★★**而它的形狀又是同一個**：**錨指到隔壁那條看起來很合理的條目**
   —— 今天已經第三次（`breed_progress` 欄位 vs `_tick_breed`／`_evaluate_life_events` 空殼／這次）。

# ★④第 4 處：我不知道它原本要指誰，而我要說清楚為什麼不猜
```
`known_issues:886` 的句子是【2026-07-05 的 V4 envoy 診斷】：「=trade 物流同根(known_issues:55 一修雙解)」
★而今天（搬家前）的 :55 落在一條【2026-08 才寫的】條目裡（[53] facility 出口分布）
⇒ ★★那個錨在【我搬家之前】就已經漂到一條不相干的條目上
⇒ ★★★我不改：改了等於【憑空發明一個引用】—— 而發明的引用比壞掉的引用更難發現
★可查的線索（給你判）：那句話講的是「far elapsed 積分一修多解：V4 envoy + V1 trade + V3 帶禮結盟」
   ⇒ 它要指的應該是【trade 物流 / far 移速稀釋】那一族，而不是 facility 出口分布
```

# ★★⑤我可以順手把這一類做成機械檢查（★等你點頭，不自己動）
```
★現況：`known_issues_anchor_gate` 只查【known_issues 內部指 code 的錨】
★★而【外部檔案指 known_issues 行號】這一類，★★★沒有任何東西在看
   —— 而它正是這次現形的那一類（3 處 process doc ＋ 1 處檔內）
★做法：閘掃 `docs/**.md`（排 handbacks／_archive／measurements）找 `known_issues(\.md)?:\d+`
   ⇒ 每一顆都印出來，並標「它現在落在哪一條目」⇒ ★人一眼看得出指錯
   ⇒ ★★不 FAIL（它們是文件慣例不是壞掉的 code），★★★但【印出來】就不再是隱形的
★而這與你入 cases 那條同一個道理：★★母體要看得見，不是要它綠。
```

# ⑥另：你報的「抽驗腳本錯了兩次」我收下
★**而我想指出一件對稱的**：★★你那三個錯（key 太脆／母版取錯／行號當標題行）
★★★**全都是「驗證工具答了另一個問題」** —— 而它和我今天犯的
（`/^func /` 看不見 static func、比對面只查 handbacks 噴 200 假陽性）**是同一族**。
⇒ ★**共同解不是更小心，是【先跑陽性對照】**：★★工具先在一個【已知答案】上跑一次，對了才信它的紅。
