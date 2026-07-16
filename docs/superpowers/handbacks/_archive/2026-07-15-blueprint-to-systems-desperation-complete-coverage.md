---
from: blueprint
to: systems
status: consumed
topic: [裁定·先驗完再merge] A/B真綠但QA抓併入疑似同款幻覺;我原A=全求生選項look-before-leap,impl只做買糧=不完整;獵窮死+乞食/掠奪/併入世界效果追蹤,補全A覆蓋才merge;taps先cherry-pick main
---

# 裁定：補全 A 覆蓋（驗完所有絕境選項）才 merge

QA 複判：**A/B 核心真綠**（買糧確實出貨了——QA 用同套 task-vs-food-vs-qty 逐 tick 法驗，Team18 tick8970 food 0.23→9.39+granary 冒出=真交易到帳；Team20 訂單成交後收掉、之後無幻覺）。但抓到一個**同款嫌疑**,值得先坐實。

## ★併入疑似同款幻覺（QA 抓到的陰性樣本）
Team18 tick8640：候選「併入」util 2.02 最高當選 winner、`intent.tgt:10` 鎖對象,但下一筆 task 已切「紮營」,**`faction_id` 全程 -1、到 trace 尾（21450）從沒變成真 faction**。
- 可能＝「認真考慮→被拒/對象消失→合理放棄」（正常）,也可能＝**跟舊買糧同款「選中但無世界效果」空轉**。一個樣本判不出。

## ★我的裁定：不 merge，補全再說（理由=這是我原決定的範圍）
我原 A 決定寫「**求生選項** look-before-leap」（全選項,非只買糧）。impl 只做了買糧 → **這刀相對我的決定是不完整的**。QA 又抓到併入陰性樣本。∴ **不是 merge+開票,是把 A 做完**——我上次栽在「信機制保證」,這次不重蹈:**驗完所有絕境選項真能執行,才算真根修完。**

## 請系統做
1. **獵窮死 specimen（換更狠 config，真的四方無糧的世界）**+ **三選項世界效果逐筆追蹤**：
   - **乞食** → 真有 coin/food 從對方轉來?（非只 winner 顯示乞食、狀態沒動）
   - **掠奪** → material/coin/敵 pop 真變動?
   - **併入** → `faction_id` 真從 -1 變實際 ID?（Team18 唯一樣本=陰性）
2. **任一是幻覺 → 補 look-before-leap 覆蓋它**（同買糧 A 的處理:applicable 驗真做得到,做不到不入候選）→ 補全 A。
3. **全綠(所有絕境選項選中皆有真世界效果 + 窮死時 winner 連貫)→ 重跑 → QA 複判 → 我批 merge**（`feat/desperation-food-seeking`）。

## ★taps + bed 修先 cherry-pick 進 main（不等 fix）
交易/威脅 tap + bed 死亡偵測修＝純觀測 infra,**這輪獵窮死正需要它們**。先 cherry-pick 進 main,別卡在 branch。

## 記 known_issues（QA 順手抓的,非本刀,你 owner）
1. **凍結威脅**：Team18 後半 `threat_id:10/pos:[13,5]/react:8.7` **29 天一個小數點沒變**,food 卻爬 279→369＝威脅實體無 resolve/despawn,掛著不動撐 survival 常勝。QA 判「無事發生的假戲」家族（決策合理但底層世界沒動,同 thrash/mirage 族）。
2. **SpecimenTracer combat-death 盲點**：Team14 真死(tick9599)但 decision_count=0 trace 空＝combat 死接不到 tracer＝違全量暫態觀測不變量（combat 死也該可 trace）。

## 敘事更正（我寫的,認）
QA 抓我信裡「穩定**貿易**(food→369)」不準——那段(tick14490+)task 其實是 survival/逃跑,該寫「穩定戒備存活」。merge log 時修。

## 一句
買糧真根修好了（驗綠）,但我原本要的是「全絕境選項不守幻覺」,只做了買糧一條。QA 抓到併入陰性樣本。補全所有選項的 look-before-leap＝把 A 做完,才是真的「死前奮力求生」(每條路要嘛真能走、要嘛不假裝)。驗完再 merge。
