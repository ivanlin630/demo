---
from: systems
to: qa
status: consumed
slice: ★長考 C 方案第一段 —— 故事稽核（★三張卷＋specimen 已落地）
topic: ★依用戶 2026-07-22 硬規則:長跑下 behavior 結論【必附 specimen → QA 故事稽核】⇒ 卷面與三份 specimen 的 exact path 在內,我【還沒有】下任何 behavior 結論,也還沒交 blueprint;★★而我點名【seed 42 先讀】:它在四個軸上同時是離群(政權剩 1、空殼 13、runtime 隊 26、非存活 36.8%)—— 離群那張最可能有故事;★★★四個要你判的具體問題在 §3,而其中一個是「和平世界裡【備戰】是三張卷的第一贏家」
---

# ①交付物（★exact path，逐檔驗過存在＋大小）
```
卷面   docs/measurements/2026-09-04-exam-seg1-e863873c-paper.md
specimen  docs/measurements/exam-seg1-e863873c-1337.specimen.jsonl   6,722,701 B
          docs/measurements/exam-seg1-e863873c-42.specimen.jsonl     7,190,999 B
          docs/measurements/exam-seg1-e863873c-7.specimen.jsonl      6,815,302 B
考程 commit  e863873c（origin/exam/seg1-specimen，已 push）｜EXCLUSIVE=yes｜三張 completed=yes
四格對帳  ①[INTERIM] 9/9/9 ②[CP]/[TickPerf] 90/90 ③section 21/21/21（三張互比一致）④黏連行 0/0/0
```

# ★★②先讀 seed 42（★理由：它同時在四個軸上離群）
```
factions(day90)=★1（另兩張是 2）｜空殼隊 ★13（另兩張 5／4）
runtime 新生隊 26（17／20）｜對照組非存活 ★36.8%（27.6%／19.4%）
⇒ ★離群那張最可能有【故事】—— 而聚合數字看不出那個故事是什麼
```

# ★★★③四個要你判的問題（★我只給讀數，不給因果）
```
①和平世界裡【備戰】是三張卷的第一贏家（352／412／328）
   ⇒ ★這是 genuine（真的有威脅）還是【util 形狀造成的偏好】? ★★請從 motive→action→outcome 讀
②施主可及率 hit/entry ＝ 0/574、0/347、★3/605
   ⇒ ★★幾乎不可及 —— 而先前已知「階梯斷是餓的【徵狀】不是起因」
   ⇒ 請看:那些餓的隊在【階梯還通的那十幾天】做了什麼
③空殼隊（pop_end=0 而未 extinct）5／13／4
   ⇒ ★★★它們是【怎麼變空的】? 一次團滅? 慢慢流失? 被併? —— 聚合分不出來,故事分得出來
④seed 42 少了一個政權（2 → 1）
   ⇒ ★那是【被消滅】、【自行解體】還是【從未成形】?
```

# ④★誠實限（★我先寫，不要等你問）
```
①★兩項【答不了】:recamp 觸發（本床無 counter）／人口成長率（無出生 log、無 pop 總量）
   ⇒ ★★而 implementer【拒絕用近似量頂替】:camp.built(27)/abandoned(22) 不是 recamp;隊數不是人口
   ⇒ 隊數 day1→day90 ＝ 14→21／14→24／14→26【只是替代讀數】,不是答案
②★★卷面的 argmax 讀數產自 payoff 導出＋cap 壓縮【之後】⇒ 與更早的讀數【不同源】,對照必看 commit
③★★★「這 13 個 goal 的歷史 argmax 讀數是【插入序 artifact】」⇒ 不要拿它們當對照
④分層規則:一切率【分 config 隊 / runtime 新生隊兩層讀】—— 混讀會把組成差異讀成世界變糟
   （本段自身就是證據:config 層 16.7–25.0% 集中,runtime 層 20–46% 散布大）
```

# ⑤★而我要的產出
```
★①上面四題的【故事判讀】:motive→action→outcome,而不是重新算一次聚合
★★②你認為【卷面哪一條結論不能下】—— 那比「哪一條可以下」有用
★★★③抽樣代表性:specimen 抽到的隊【結局分布】夠不夠代表(★若全是活得好的隊,故事會系統性偏樂觀)
⇒ 你判完我才交 blueprint —— ★在那之前我不下 behavior 結論
```
