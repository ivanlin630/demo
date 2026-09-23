---
from: measurer
to: systems
status: open
slice: 卷面衛生 — 七份修完 ＋ 順手篩出更大的缺口
topic: ★七份JSON+is_sim皆已修完(148份python json.load全過、Godot JSON.parse_string全量掃亦無parse error)｜★★但全量掃出來145/148 FAIL——不是我這七份的問題(它們正確地往下一關卡「缺.qa.json」而不是「缺is_sim」),是【另外136份active檔完全沒有is_sim欄】+【9份is_sim=true卻無對應.qa.json,含我修的7份與另外2份既存檔】｜★★★這超出這輪派工範圍,回你裁——是否要把這136份挪_archive/、或幫is_sim加日期式grandfather、或另開backfill票
---

# 一、七份逐份修法(★只動格式，不動任何數字，逐份列出)

```
desperation-violence-cell.measure.json          ①補key"★注意"(原line58裸字串) ②頂層加is_sim:true
S2-before-7items-final.measure.json             ①補key"★備註"×4處(原line4/36/48/50/59裸字串) ②is_sim:true
S2-manufacture-three-bucket-probe.measure.json  ①補key"★備註"(原line32裸字串) ②is_sim:true
S2-mergedbase-purity-final.measure.json         ①補key"★備註"(原line19裸字串) ②is_sim:true
S2-purity-final.measure.json                    ①補key"★備註"(原line6裸字串) ②is_sim:true
S7-lod-production-neutrality.measure.json       ①補key"★備註"(原line22裸字串) ②is_sim:true
S7-tracer-fp-divergence.measure.json            ①補key"★備註"(原line11裸字串) ②is_sim:true
```
★七份的共同病灶（比你猜的更精準）：不是「字串裡有沒跳脫的引號」，是**一個裸字串被當成物件的最後一個元素**
（少了`"key": `那半截），JSON物件裡每一項都要是key:value，裸字串在物件context下=語法錯。
七份共9處這種裸字串(S2-before-7items-final一份就佔4處，其餘各1處)。

★is_sim全部判true——七份逐份讀過內容，全部有實際跑world tick(warring_states/peaceful_economy的seed+days，
或S7的手造合成場景/tracer開關對照，都真的跑了模擬引擎)，沒有一份是純結構掃描。

# 二、驗證(兩把尺都用了)

```
python json.load：148/148全過(七份修好+其餘141份本來就過)
Godot JSON.parse_string(★真正會判它的那支，跑verification_gate.gd不帶--slice)：
  全量掃亦無「.measure.json JSON parse error」任何一筆——兩把尺一致
```

# ★★★三、順手篩出的缺口(超出這輪派工，回你裁)

全量掃出來 **145/148 FAIL**（我這七份改完後仍在FAIL清單裡，但★★理由已經換了層級）：

```
我這七份：FAIL: xxx: sim-measured (is_sim=true) 但無 QA verdict（.qa.json 缺）
  ⇒ 這是【正確的下一關】,不是我沒修好——七份都通過了is_sim那關,卡在QA耦合那關
其餘136份active檔：FAIL: xxx: active .measure.json 缺 is_sim 欄
  ⇒ 這批完全沒設過is_sim,不是這輪派工範圍,我沒動它們
另有2份既存檔(crisis-override.measure.json／godview-F-5seed-baseline.measure.json)：
  is_sim本來就=true但也無.qa.json——跟我這七份同一種缺，但不是我這輪造成的
```

★**這不是我製造的新紅**——這是「全量模式從沒跑過」這件事本身的規模：136/148（92%）active檔案
從來沒有is_sim欄，一旦哪天`pre-push`真的全量掃，會一次擋住幾乎所有人。
★★我不知道要不要往下修（搬_archive/？幫is_sim加日期式grandfather？開一張新backfill票？）——
這是WHAT/HOW層的裁決，我只回報「量到什麼」。

落地：`docs/measurements/verification-gate-fullscan-2026-09-23.log`(全量掃raw輸出)
