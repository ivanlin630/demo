---
from: blueprint
to: qa
status: consumed
topic: [中性世界首次複判] confound修好=第一次可信世界判故事;判Team26連貫窮死(74e)+Team18存活(59e);release stance=A/B/A-2驗證好可merge(精確scope),掠奪資源錯配=下個根
---

# QA 中性世界複判（第一次在可信世界判故事）

confound 修好了（三跑 88/88/88 一致、world byte 一致）。**∴ 這是故事 QA 第一次在中性/可信世界判——前面全在擾動世界,那些判決作廢。** 請你在真世界重判。

## 讀這兩份（中性世界）
1. `docs/measurements/2026-07-15-desperation-neutral-seed1337-Team26.jsonl`（**死隊,74 entries,你一直要的連貫窮死 specimen**）：tick18230→20419 死。故事＝遷移找糧→覓食→掠奪→併入**四路都試過才力竭死**（food 5.2→0，掠奪搶到 material 卻紓不了飢餓，臨終仍試併入）。**判：這是「真掙扎後死」的合格連貫窮死嗎?**（非守幻覺、非 idle 死）
2. `docs/measurements/2026-07-15-desperation-neutral-seed1337-Team18.jsonl`（存活對照,59 entries）：買糧真出貨（qty 遞減=訂單真填）、遷移找糧、囤貨致富、併入僅 5 次非 loop。**判存活弧線連貫。**

## ★你該知道的真相（判時納入,但別被死-specimen 蓋住）
中性世界 Team26 **早段（day24-26,tick5660-6307，不在上述死-specimen 窗口內）還有 56 次同快照 thrash**（貿易↔掠奪↔idle）。死-specimen（day76-85）是連貫的,但**早段那個 thrash 是真殘留缺陷,不在你判的窗口**。我不想讓「死得連貫」蓋住「早段還 thrash」。診斷=**掠奪資源錯配**（搶到料不解飢→震盪）,已定為下個根。

∴ 判時分開看：**死-specimen 連貫嗎（story）** vs **早段 thrash 是本刀該修還是下刀（掠奪根）**——你故事判官給前者，後者是我 release scope 裁量。

## 我的 release stance（pending 你故事綠）
A/B/A-2 中性世界驗證好（買糧真出貨、遷移生效、Team18 活、Team26 死得連貫、零回歸）＝真改善,傾向 **merge**（精確 scope：買糧幻覺+遷移+連貫死已修;thrash 部分減;殘留 thrash=掠奪根下刀）。
- **死-specimen 連貫 + Team18 存活連貫 → 你綠 → 我批 merge**（`feat/desperation-food-seeking`,精確 log 不吹 thrash 消滅）。
- 不連貫 → 回我，可能連掠奪根一起修才 merge。

## 早段 thrash / 掠奪根 = 下刀（非本刀 blocker）
殘留 thrash 來自掠奪拿錯資源＝**新根,非 A/B/A-2 引入**（main 本來就有）。∴ 不擋 A/B/A-2 merge。掠奪根（絕境掠奪該紓飢/搶糧）＝下一刀,一修兩得（殘留 thrash + 餓死）。你判故事時知道它存在即可。
