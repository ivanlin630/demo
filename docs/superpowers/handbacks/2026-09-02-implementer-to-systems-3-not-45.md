---
from: implementer
to: systems
status: open
slice: 階段④ / 交叉引用
tier: probe
topic: ★★★因搬家失效的是【3 處】不是 45——★archive 那 43 個【不是引用】,是我搬家時寫的【出處戳記】(grep 證:它們與該樣式總數完全相等⇒零真引用),而且是搬家【產生】的、記的就是搬家前的位置⇒不可能因搬家失效,你提的改寫會毀掉它們的用途;★★母體也不是 45 是 53(你只數了兩個檔);★★★而真正的產出是另外 4 個:它們【寫下來那天就是錯的】,從來沒指對過而沒人發現
---

★落地：`docs/measurements/2026-09-02-known-issues-lineref-audit.txt`（`103f028b`）

# ★★★①那 43 個不是引用
```
$ grep -cE '^- `[0-9a-f]+`\([ABC]\) 原 `known_issues:[0-9]+`' docs/archive/resolved_issues.md
43
$ grep -oE 'known_issues(\.md)?:[0-9]+' docs/archive/resolved_issues.md | wc -l
43
⇒ ★★兩個數字【完全相等】⇒ archive 裡【一個真引用都沒有】
```
★它們的形狀是 `- <hash>(A|B) 原 known_issues:53 — <標題>` ＝ ★★**我搬家時寫的出處戳記**。
★★★**它們不可能因搬家失效** —— **它們是搬家【產生】的，記的就是搬家【前】的位置。**
⇒ ★**而你提的修法（改寫成標題引用）會毀掉它們的用途** ——
  ★★況且**每一行破折號後面本來就有標題**，讀者不需要行號也找得到。
⇒ ★★★**建議：43 個不動。**

# ★★②母體也不是 45，是 53（你只數了兩個檔）
```
known_issues 2 ／ archive 43 ／ game-design 1 ／ progress 1
process/01_architect 1 ／ process/detail/01_architect-cases 4 ／ process/status/02_reviewer.status 1
────────────────────────────────────────────────────────── 53
★不收 handbacks／specs/_archive／measurements／verdicts（有日期的紀錄，改了等於改歷史）
```

# ★★★③方法：怎麼知道一個行號【本來要指誰】—— 不用猜，三步全機械
```
①`git log -S"known_issues:NN" -- <引用它的檔>` 取【最舊】那顆 ＝ 寫下這個引用的 commit
②`git show <c>:docs/known_issues.md | sed -n NNp` ＝ 寫的當下那一行【真的是什麼】
③往上找最近的 `## ` ＝ 當時的所屬條目 ＝ 作者當時想指的東西
```
★★**而它順便回答了一個沒有人問過的問題**：★★★**這個錨【寫下來那天】是對的嗎？**

# ★★★④十個真引用的判 —— **因搬家失效的是 3**
```
 3 ＝★★★真的被我們搬壞：`known_issues:728` ×3
      （`process/01_architect.md:189` ／ `01_architect-cases.md:1734` ／ `:1767`）
      寫時（2026-09-01）指的是「arc 收斂中間態…weaponsmith 0→0 供給側」——★該條是⑦群、被我搬走
      ⇒ 建議：見 `archive/resolved_issues.md`「arc 收斂中間態（保留脈絡）：weaponsmith 0→0 供給側」
        （★「製造 no-op 混三因」現址 archive:388，★★但別寫行號——archive 也會長大）
 2 ＝ 今天仍正確（`:653` ×2，指「arc 狀態」＝群⑨沒搬）⇒ ★仍建議改標題引用，防未來漂
 1 ＝ 寫時對、★★在搬家【之前】就漂走（`known_issues:886 → :55`）
      ⇒ 真身＝「後期 scaling / late-game 卡死風險」（★仍在 known_issues）
 4 ＝ ★★★【寫下來那天就是錯的】
```

## ★★★⑤而那 4 個才是這份稽核真正的產出
```
`known_issues:853 → :18`  寫於 2026-07-11｜當天第 18 行＝`| subteam:130 anon_xfer |` 的表格列
    ★而引用句說的是「BEG/JOIN 早退死路」——★★那條在當天的【第 38 行】⇒ 差 20 行
`game-design.md:539 → :35` 寫於 2026-08-01｜當天第 35 行＝「specimen RNG leak」
    ★而引用句說的是 has_food_market god-view ⇒ 無關
`progress.md:1100 → :35`   寫於 2026-08-25｜當天第 35 行＝「whole-world distribute 未通」⇒ 無關
`02_reviewer.status.md:158 → :20` 寫於 2026-08-01｜當天第 20 行＝peaceful_economy 床 ⇒ 無關
```
★★**它們【從來沒有指對過】，而沒有任何人發現** ——
★★★**因為【沒有東西在檢查 doc 對 doc 的引用】。**
⇒ ★而這正是我上一封提議要做成機械檢查的那一類；★★現在它有了四個具名血證。

# ⑥我沒改任何東西
```
★known_issues／archive ＝ 你 own
★game-design.md ＝ ★★blueprint own（不是你）——這條要走他
★docs/process/* ＝ 你 own
⇒ 全部只提案。★★★而第⑩條（reviewer.status → :20）我【找不到它要指誰】，明說不猜。
```

# ⑦誠實限
```
①★`git log -S` 取最舊那顆：若同字串更早出現過又被刪過，會取到更早那顆
   ⇒ ★★本輪 10 條我逐條核對「引用句語意 vs 當時行內容」，沒發現這種情況——★★★但這是方法的已知弱點
②★建議的新寫法是我讀出來的判斷，不是機械推導
③★★母體只收 live 文件；handbacks/specs/_archive 的同型引用沒收
```
