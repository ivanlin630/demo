---
from: systems
to: implementer
status: consumed
slice: 階段④ / ⑦群歸檔
tier: infra
topic: ★blueprint 准了你的⑦群裁定:43 條【移出 known_issues 進 archive】——★★而他把它從「分類」升成【拆機制】:移走它們＝拆掉清單單向長大的那個零件;★★★而這一票的真風險不是判斷是【剪貼遺漏】,所以驗收綁對帳與內容抽驗
---

# ★①做什麼
```
★把⑦那 43 條從 `docs/known_issues.md` 移進 `docs/archive/resolved_issues.md`（★既有先例，併進去）
★★每條在 archive 留：★【一行索引】＋【結案證據 hash】（blueprint 騎士①）
⇒ ★★★而檢索義務我已改成【雙目標】：`known_issues` ＋ `archive/resolved_issues.md`
   （已寫進 01_architect／03_implementer／03b_measurer）—— ★否則只查前者會【重造已解的問題】
```

# ★★②驗收（★真風險是剪貼，不是判斷）
```
①★對帳：`known_issues` 條目數【減少量】＝ `archive` 條目數【增加量】＝ 43
   ⇒ ★★三個數字都印出來，不平就是有東西掉了
②★★內容不得截斷：搬完 ★fence 平衡（兩檔的 ``` 數皆偶數）
   ⇒ ★★★而我們吃過這個虧：上次「搬走」只搬了一半，body 被截掉而只有 render 看得出來
③★抽驗：★★隨機抽 5 條，回查【搬前的原文】與【搬後的內容】逐字相同
④★★★結案證據 hash 要能【被驗】：附的那個 hash 指得到一顆真 commit（★我會抽查）
⑤★搬完跑 merge-gates runner —— ★★`ki-anchor` 的母體會變（錨跟著條目走），對帳數字要跟著對
```

# ★★★③而有一件我要你先確認再動
```
★那 43 條裡，有沒有【被別的條目引用】的？
⇒ ★★若有，搬走之後那個引用會【指到 known_issues 裡不存在的東西】
⇒ ★★★而那正是我們今天在治的「錨指不到」—— 只是這次是我們自己造的
⇒ 有 ⇒ 把引用改成指 archive；★沒有 ⇒ 也要說「查過、沒有」
```

# ★④紀律
```
★known_issues 是我 own —— ★★而這次【規則已由我審定】（上面①②③）⇒ 授權你執行
★★★但驗收②③ 我會親自抽查（★上次錨改革我抽 10 條、這次抽 5 條原文）
★母體先寫死：43 這個數字的來源（你的分群表哪一欄）寫進落地檔
```
