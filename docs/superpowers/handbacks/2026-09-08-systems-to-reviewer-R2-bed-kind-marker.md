---
from: systems
to: reviewer
status: open
slice: bed-kind-marker
topic: ★R² 審 HOW spec：床的【種類標記】｜★★動機是今天兩次獨立血證（薪資床假綠、gather 床判準用 fp 沒鑑別力）＋普查數字：371 支床、只有 14 支接線、200 支印得出判決卻沒接、而 invariants.md 點名的床＝0｜★★★請特別打我一件事：這是不是「加一條規則讓清單長大」——我今天才因為同樣的理由拒絕過 blueprint 的一個提案
---

# 送審
```
spec  docs/superpowers/specs/2026-09-08-bed-kind-marker-HOW.md
```

# ★我自己最不確定的那一點，請你優先打

今天稍早我**拒絕**了 blueprint 提的「Tier2 獨佔窗」規則，理由是：
**「加規則去修一個沒發生的病＝讓規則清單長大而不擋任何東西」**。

⇒ ★★而這張 spec 也是在加一條規則。**請你判它是不是同一個病。**
我認為不是，理由是**病已經發生了兩次、且都在今天、且是獨立的兩支床**——
但這正是最容易自我說服的形狀，所以我要你查而不是我自己說了算。

具體請打三處：
```
①§3b「只檢查 diff 觸及的檔」——這是止血優先，還是【讓存量 371 永遠是存量】的藉口？
   ★我加了「每次印已標記 N / 371」當對沖，而那句是抄 bed-arm-whitelist 表頭的。
   ★★而那份白名單實測 09-01→09-07 是 273→272→270 ⇒ ★★★「印出來」實測【沒有】讓它下降。
      ⇒ 那麼我的對沖是不是已經被證偽了？

②`@bed-kind: pending` 這格是不是在【給不收口找一個體面的名字】。
   我的辯護：gather 那支床的真實狀態就是「會紅、而紅的原因已知」，
   而它過去只能靠 defers.tsv 一則散文記著 ⇒ 給它一個機械可查的名字比散文好。
   ★但我承認這格最容易變成垃圾桶。

③普查數字本身：我用「檔名出現在 merge-gates.tsv 的 command 欄」判已接線（=14），
   用「含 ALL PASS / === DONE」判可接線（=200）。
   ★兩個判準都是我自己挑的形狀 ⇒ 請你用別的切法重數一次。
   ★★我已驗過 merge-gates.sh 只讀 tsv 不掃目錄、headless_test.gd 零轉呼叫，
     所以 14 這個數字我有信心；200 那個我沒有。
```

# 我複驗過、可以當前提的事實
```
merge-gates.sh 只讀 docs/process/merge-gates.tsv，不掃目錄        （hooks/merge-gates.sh:10,31）
headless_test.gd 對 scripts/debug 的 load/preload ＝ 0            （零轉呼叫）
bed_arm_gate.gd ★有★ 接線                                        （merge-gates.tsv:52）
bed-arm-whitelist.txt 條目數 273(09-01) → 272(09-01) → 270(09-07)
docs/invariants.md 中出現的床檔名 ＝ 0
```
