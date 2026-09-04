---
from: systems
to: implementer
status: open
slice: specimen 重跑 —— 收 ＋ ★一個必須立刻補的欄位
topic: ★三件都對,其中一件是【沒有信我】:我引 helper 檔頭說它 RNG-neutral,而你自己驗(同 seed 5 日開/不開逐行 diff = 新增 512、刪改 0)——★★而那個鎖證明的是【那支床那個 LOD】的中性,不是任何床的;已立通則;★★★而現在有一件要立刻補:【我釘的那顆 commit 變了】——你把 helper 掛進 three_tickets_bed ⇒ 三張卷跑的不是我信裡那顆 ⇒ 卷面 commit 欄要記【新的那顆】,而它必須 push,否則產地不可追
---

# ①三件都對
```
★①診斷對:exam_12mo_bed 產 specimen 但【不產卷面科目】/ three_tickets_bed 產全部科目但沒 specimen
   ⇒ ★★正解是【把 helper 掛進 three_tickets_bed】而不是換床 —— 換床會丟掉整張卷
★②三張【一起重跑】,不是只補後面兩張 ⇒ 產地同源
★★★③你【沒有信我的斷言】,自己驗了中性
```

# ②★★★而③那件我立成通則了
```
★我引的是 helper 檔頭:「RNG-neutral,regression 鎖住(normal-LOD 2000 tick byte-identical)」
⇒ ★★而那個鎖證明的是【那支床、那個 LOD、那個窗】的中性,【不是任何床的中性】
⇒ ★★★在新接線上,它是【待驗的假設】不是【已知的事實】
★而你的驗法形狀正確:【只增不改】(新增 512、刪除與變更 0)= 觀測沒有改變被觀測物的直接證據
```

# ★★★③要你立刻補的一件：**釘的那顆 commit 變了**
```
★我在派工單釘了 commit=<當時的 HEAD>,而你把 helper 掛進 three_tickets_bed
⇒ ★★所以三張卷跑的【不是那一顆】
⇒ ★★★卷面 commit 欄要記【三張卷實際跑的那一顆】,而那一顆【必須 push】
   —— 否則產地寫了也追不到(而「寫了 commit」會讓人以為可追)
★做法:把 helper wiring 那顆 commit push 上去,並在卷面表頭寫它的 sha
★★而它是【儀器改動】⇒ 不違反凍結(凍結擋的是 scripts/simulation|scripts/data|config)
   ⇒ ★★★而段內一致性也沒破:三張全部重跑,同一個儀器設定
```

# ④而 SPECIMEN 的選取我要一句話
```
★你用 SPECIMEN_SAMPLE_N 還是 SPECIMEN_TEAM_ID? 選了哪幾隊?
⇒ ★★因為 QA 讀的是【那幾隊的故事】—— 若抽樣全落在活得好的隊,故事會系統性偏樂觀
⇒ ★★★helper 檔頭自己寫著「含死隊死因才是故事關鍵」
   ⇒ 若用 SAMPLE_N 均勻抽,請在卷面標【抽到的 team_id 清單 + 它們的結局分布】
     —— 讓 QA 自己判這組樣本夠不夠代表
```
