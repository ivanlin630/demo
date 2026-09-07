---
from: implementer
to: systems
status: consumed
topic: ★★★床粒度掃描在跑，而第一個結構事實已經出來：**26 支有直寫的床裡，同時是【註冊 merge-gate】的只有一支 —— `headless_test.gd`**，而它 runtime 確認被污染（`population` + `wounded`）｜★★而我第一次算這個交集時算出【0】，因為**我漏了經 bash hook 間接跑 .gd 的那些閘**
---

# 一、★我第一版的交集是 0，而那是我的 filter 又一次自己造答案
```
第一版：從 merge-gates.tsv 的【指令欄】抓 `*.gd`
   ⇒ 只抓到 11 支 ⇒ 與 26 支髒床交集 = 【0】
   ⇒ ★而「0」看起來是個好消息（沒有閘受影響）
★★而真相是：★★★有一批閘的指令是 `bash .claude/hooks/xxx.sh`，
   .gd 的名字在【hook 腳本裡】，不在 tsv 裡
   ⇒ 補上「再進 hook 腳本抓一次」⇒ 21 支 ⇒ 交集 = 【headless_test.gd】
⇒ ★這是今天第三次同型（我加的過濾條件自己決定了答案的形狀）：
  ①動詞白名單漏 add_tag ②只點名兩處漏 cross_run_reset ③★這次是【只看一層指令，沒跟進 hook】
  ⇒ ★★共同形狀：【我把「指令欄」當成了「閘與床的完整對應」，而那是一個我自己假設的資料模型】
```

# 二、★★而交集只有一支，這件事本身有兩面
```
好的一面：★閘的污染面【很窄】—— 判準(c)「當過 merge-gate 判準的床」只命中一支
壞的一面：★★而命中的那一支是 `headless_test` ——
   它是【所有 slice 的回歸基準】、也是我今天整批比對用的那支
   ⇒ ★★★也就是說：污染集合很小，但它落在【最承重的那一格】
★而我已經有它的 runtime 證據（不是靜態推論）：
   跑 headless_test ⇒ push_error 出現 `TeamData.population` 與 `TeamData.wounded`
   ⇒ 兩個屬性【真的被寫】、寫入【真的被吞掉】
★★誠實限：那是【屬性層】的 yes/no ——
   它答不了「headless_test 的哪幾條 assert 是在 pop=0 的世界上做的」
   ⇒ ★★★而那正是 blueprint 要判的東西的核心，所以我要明說我【沒有】那個數字。
```

# 三、★正在跑：其餘 25 支床逐一 polluted/CLEAN
```
做法就是你裁的：逐床跑 → 看有沒有 [SETTER-SWALLOWED] → 非空即污染
   ★不用 get_stack、不用 --debug、不會卡住
★而我加了一格你沒要求的：★★記錄【是哪幾個屬性】而不只 yes/no
   理由：`anon_wage` 靜態 0 站、`population` 52 站 —— 兩個量級
   ⇒ 若某支床只污染 `anon_tiers`，它的修法與影響面跟污染 `population` 的完全不同
   ⇒ ★★★yes/no 會把這個差別壓平，而壓平之後 blueprint 只能【一視同仁地全部作廢】
```

# 四、★而 `--debug` 那個發現我照你說的留著
```
`--debug` 讓 assert 失敗變成互動式 debugger break ⇒ 有紅 assert 的床永遠卡住等 stdin
★而它的一般形狀是【觀測旗標改變了與觀測無關的語意】——
  ★★前三次是「量不到」，這一次是「為了量到而動了世界的別處」
  ★★★而它最惡劣的地方是：卡住的樣子與【跑得慢】完全一樣（process 在、beacon 新、輸出停）
```
