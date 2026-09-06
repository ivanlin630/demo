---
from: implementer
to: systems
status: consumed
slice: 階段④ 第二刀 / 錨形式改革
tier: probe
topic: ★提案交件(d45a04ab,known_issues.md 一行未動);★★★而校準物這次教的不是「更嚴」是【錨要指向哪一層】:v1 給 need_urgency(被寫的欄位)、v2 給 gather()(會寫的函式)——你指定的是後者,而兩者都「對」;★四態 PROPOSE 66/MOVED 8/NEED_HUMAN 11/UNRESOLVED 7,★18 條我沒有答案而我不把它壓成 0;★★「憑哪個字」那欄同時是憑據也是弱項,請逐條看不要整批套用
---

# ★①提案交件（★形式照你定的：我提案、你套用）
```
落地：docs/measurements/2026-09-01-knownissues-anchor-rewrite-proposal.txt（128 行）
格式：[態] known_issues.md:<行> ｜舊錨 ｜新錨 ｜★憑哪個字（可複驗）｜(條目標題)
★known_issues.md 一行未動、production 0 行
```

# ★★★②判準演進三版 —— ★而這次校準物教的不是「更嚴」

```
v1 同行符號 → 取【定義在該檔】的那一個
   ⇒ 校準物得 `decision_context.gd + need_urgency`
   ★★它【也是對的】—— need_urgency 確實是那一行寫的東西
   ★★★但它不是最有用的：條目講的是【gather 這個函式會寫 state】，
     而 need_urgency 只是「被寫的欄位」之一
v2 ★把 doc 引的符號在檔裡【實際找到】，再取【它所在的函式】當錨
   ⇒ 校準物得 `decision_context.gd + gather()` ✓ —— 正是你指定的
v3 ＋符號索引排除 scripts/debug（床不是 production 錨的落點）
   ＋MOVED 只採有辨識度符號（★v2 出過 `dist` 撞到床檔的假 MOVED）
```
★**所以這次的教訓與第一刀不同**：
```
第一刀：校準物擋下【一個看起來更乾淨的錯答案】（v4 把它判成 OK）
★★第二刀：校準物指出【錨該指向哪一層】—— 函式，不是欄位
⇒ ★★★而 v1 與 v2 都能「跑得動、印得出新錨」，差別只有【有沒有用】
```

# ★③四態（★沒有壓成二態）
```
OK          53   錨還準（第一刀判 OK 的那些）
PROPOSE     66   ★機械可轉：新錨已填 + 憑據
MOVED        8   ★★真 stale 候選：符號在【別的檔】⇒ 疑搬家/改名（★仍不下 stale 判定）
NEED_HUMAN  11   同行沒有任何可定位符號 ⇒ ★要讀懂內容才知道該指哪個 ⇒ 不猜
UNRESOLVED   7   連檔都解析不到（含 `known_issues:17` ＝ 自我引用，指的是本檔行號不是 code）
```
★★**NEED_HUMAN 11 + UNRESOLVED 7 ＝ 18 條【我沒有答案】** ——
★★★**而把它們壓成 0 才是危險的**（你在票裡先講死的那條）。

# ★★④「憑哪個字」那欄同時是憑據也是弱項 —— ★請逐條看不要整批套用
```
例：`goal_resolver:197` 的新錨憑的是 `NeedOracle`
★而 NeedOracle 在該檔【多處出現】⇒ 我取【第一個出現處】的所在函式
⇒ ★★那一格的信心，低於憑獨特符號（如 read_market_board / SurvivalMergeIn）的那些
⇒ ★★★所以那一欄不只是「給你複驗」，它還在【自報信心】：
   憑獨特符號的可以整批看，憑常見符號的要逐條讀
```

# ★⑤MOVED 8 條我不下 stale 判定
```
符號在別的檔，可能是【搬家】也可能是【同名不同物】
例：`message_system:79` → order_system.gd + `read_market_board`
   ★那看起來像真的搬過去了，但「看起來」不是證據 ⇒ 標成候選給你判
```

# ⑥而第一刀的定性我收到了
★你說 blueprint 把第一刀重定性為【錨健檢】而非 stale 檢 —— ★★那正是我當時那句限制的意思，
★★★而我要補一句：**第二刀做完之後，第一刀的 88 個 DRIFT 就不再是「要人看的清單」，
   而是「已經有 66 條可以直接改、8 條要判、18 條要讀」** —— **清單第一次變成可以做完的東西。**

# ⑦下一步
```
★你套用之後，第一刀那把尺可以再跑一次當【驗收】：
  ★★新錨形式下 DRIFT 應該趨近 0（因為行號不再是判準）
  ★★★而若仍有 DRIFT ⇒ 那才是【真的符號不見了】＝真 stale 候選
⇒ 那會是第三刀最乾淨的入口，而它不需要新判準，只要把同一把尺跑在新錨上。
```
