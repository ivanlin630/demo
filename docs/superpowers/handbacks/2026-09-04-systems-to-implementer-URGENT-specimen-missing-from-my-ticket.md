---
from: systems
to: implementer
status: consumed
slice: ★★★我的 SEG1 派工單漏了 specimen —— 現在講，不要等交卷
tier: slice
topic: ★★★我派工單的產出物五項【沒有 specimen】,而卷面判定【全是 behavior 結論】⇒ 依用戶 2026-07-22 硬規則(綁 hook),長跑下 behavior 結論【必附 specimen trace → 送 QA 故事稽核】—— 這是我的漏,不是你的;★而好消息:`exam_12mo_bed.gd` 已經內建掛好(`:60 setup_from_env`／`:208 dump`)⇒ 若你跑的是它,只要【設 env 重跑】;★★而若已跑的三張沒設 env ⇒ ★★★三張【一起重跑】,不要只補後面兩張(產地要同源);22 分鐘,現在付比交卷後付便宜
---

# ①我的漏（★先說清楚是誰的）
```
★我在 SEG1 派工單寫的產出物五項:判定／報不修讀數／免費補答／§7-D 三行／產地標記
⇒ ★★【沒有 specimen】—— 而卷面判定(誰在贏／founding 沉默存在嗎／空殼隊…)全是 behavior 結論
⇒ ★★★用戶 2026-07-22 硬規則(綁 hook 非記憶):長跑下 behavior 因果結論
   【必附 specimen trace（SpecimenDumpHelper）→ 送 QA 故事稽核】,禁跳 QA 自讀 metric 自判
★而我自己在 pilot 那封還特地寫過「長考正考那一輪最容易忘」—— ★★然後我就忘了
```

# ②★好消息：床已經內建掛好（★不必改 code）
```
scripts/debug/exam_12mo_bed.gd:60   SpecimenDumpHelper.setup_from_env(state)
scripts/debug/exam_12mo_bed.gd:208  SpecimenDumpHelper.dump(state, _env("SPECIMEN_OUT", ...))
⇒ ★env 開關:SPECIMEN_SAMPLE_N（均勻抽 N 隊,sorted id 等距,零 RNG 消耗）／SPECIMEN_TEAM_ID
★★而 helper 是 RNG-neutral 已被 regression 鎖住(normal-LOD 2000 tick byte-identical)
   ⇒ ★★★所以【開了它不會改世界軌跡】—— 這點很重要,否則三張卷就不是同一個世界了
```

# ③★★★所以要你做的（★兩種情況）
```
①你跑的若【就是 exam_12mo_bed】而 env 沒設 ⇒ ★三張【一起重跑】,設:
     SPECIMEN_SAMPLE_N=<你判斷的數,建議涵蓋大中小隊>
     SPECIMEN_OUT=docs/measurements/exam-seg1-<seed>.specimen.jsonl
   ⇒ ★★不要只補後面兩張:【產地要同源】,三張必須同一個儀器設定
②你跑的若【是別的床】⇒ 回報我那支床有沒有掛 helper;沒掛的話那是【儀器改動】,
   ⇒ ★★★而依我自己的明令,儀器改動要在【段與段之間】—— 但這一段【還沒有任何一張卷被接受】,
     所以「改儀器 + 三張全部重跑」不破壞段內一致性 ⇒ ★我核可這個例外,理由寫在這裡
★而 SPECIMEN_TEAM_ID 若要指定:★★記得「含死隊死因才是故事關鍵」(helper 檔頭寫的)
```

# ④★而 22 分鐘現在付比交卷後付便宜
```
★現在付:重跑三張,22 分鐘
★★交卷後才發現:三張卷已交、QA 履不了職 ⇒ 要嘛重跑(同樣 22 分鐘)+ 已經浪費一輪讀卷,
   ★★★要嘛有人會說「這次先不送 QA」—— 而那正是用戶當初立這條規則要防的東西
```
