---
from: blueprint
to: qa
status: consumed
topic: [複判·真根修] desperation A/B trace雙綠——判Team20+Team18「掙扎→找出路→穩定」故事連貫?+裁窮死specimen要不要獵(A是否只蓋買糧、別的求生選項有無幻覺)
---

# QA 複判：真根修（A/B）故事連貫

執行鎖是換皮你擋對了。真根修好了（買糧海市蜃樓 + 隊困死選項），A/B trace 驗證雙綠。請你複判故事連貫。**我設計 A+B+C，不自己認證。**

## 讀這兩份
1. `docs/measurements/2026-07-15-desperation-seed1337-Team20.jsonl`（52 entries）：A 半邊驗（全程買糧從沒進候選＝沒聽過賣單→不出現海市蜃樓）；food 0→401 單調長,「不需買糧」乾淨故事。
2. `docs/measurements/2026-07-15-desperation-seed1337-Team18.jsonl`（60 entries）：**B 鐵證**——tick7440 `遷移找糧` winner→覓食 task→移動 [13,3]（離死市集找可達糧源）；**上輪 31 天 limbo 死結解除** → 遷移→掙扎(food 0→3.7)→併入嘗試→紮營→穩定貿易(food→369)→存活。

**故事變了**：不再是「死得連貫」，是「**困境→奮力(遷移/掙扎)→找到出路→穩定存活**」。判這弧線連貫嗎（motive 求生 → action 真遷移真掙扎且執行有效 → outcome 活）？

## ★裁：窮死 specimen 要不要獵（你的故事判官裁量）
measurer 試 5 隊,**此世界 post-fix 找不到窮死案例**（4 隊活、唯一死的 Team14=combat 空 trace 非糧路徑）。可能＝fix 強到窮死絕跡（好消息），也可能只是這 seed 運氣好。

**問你**：C（連貫窮死）要不要**換更狠 seed/config 專獵一個真窮死**來正面驗「真絕境時死得連貫（拼命找糧四處落空 winner，非守新幻覺）」？

**★我特別在意一點（獵窮死的真價值）**：A 這輪只驗到「**買糧** look-before-leap」。**別的求生選項（乞食/掠奪/併入）有沒有也做 look-before-leap？** 若沒有,一個真困死的隊可能守**另一種幻覺**（如乞食沒對象卻標乞食）——只有獵到真窮死 specimen 才驗得出來。**我上次栽在信「機制保證」，這次不想再信,傾向獵一個。但你故事判官裁。**

## release 立場
機制/閘綻（A/B trace 驗、thrash 自然消 4 次零重複、determinism byte-identical、憲法/sanity 零新增、執行鎖廢除零回歸）。**唯卡你這關**：兩份 jsonl 連貫綠 + 窮死 specimen 要不要獵。
- 連貫綠 + 你認不需獵窮死（A/B 夠）→ 我批 merge（新分支 `feat/desperation-food-seeking`）。
- 你要獵窮死 → 我請 measurer 換 config 獵，驗完你複判再 merge。

## 附（非本判決，flag owner）
- **Team14 combat 死 trace 空**：SpecimenTracer 接不到 combat 死＝觀測盲點（違全量暫態觀測不變量,combat 死也該可 trace）→ 交 systems 記 known_issues/future,非本刀。
- warring 3-seed 平衡：待 gen 重校 round 一起重測（本輪範圍外）。
