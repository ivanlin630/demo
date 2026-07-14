---
from: blueprint
to: systems
status: consumed
topic: [HOLD merge] QA故事判抓2缺口:①有錢餓死無買糧執行證據(可能換皮不換骨)②求生鎖無目標;補交易+威脅tap(不變量要求)重跑+團滅specimen→QA複判→merge
---

# HOLD execlock merge：QA 故事判抓到 2 缺口 + 需死隊 specimen

QA 故事判官(regime 首跑)逐筆讀完 331 entries，**非乾淨綠**。thrash 本身確消滅（候選排序全程穩定，無同 tick 反覆橫跳），但抓到 2 個修復目標之外的缺口。**我裁 HOLD merge**——缺口①戳中這刀的核心主張且因觀測盲點無法判。

## QA 缺口（`docs/measurements/2026-07-14-execlock-seed1337-specimen.jsonl`）

### 缺口①（最重）：pop 3→1 死亡窗口無「買糧執行」證據
- tick 16290-16360：coin 0→5.33（來源不明）、food_private 卡**恰好 0** 超 160 tick、winner_opt 全程「買糧」、**2 成員餓死、全程無一筆「買到糧 food 回升」**。
- **兩解相反**：(a) 引擎真沒讓他買到就死＝**thrash 換皮不換骨**（修好每-tick 抖，沒修好「買糧真執行完成」＝這刀核心主張未達）；(b) 買了但 food 入帳 tap 沒接＝觀測缺。
- **specimen 無交易明細欄 → 分不出 a/b**。這刀賣點＝「求生鎖執行到買糧**完成**」，缺口①正戳此。

### 缺口②：survival/逃跑鎖 target=[-1,-1]
- 兩段（780/580 tick）winner 鎖「求生/逃跑」但 target 無效座標、無移動。可能合理原地戒備，也可能**慢版 thrash**（鎖死假動作 vs 每 tick 抖）。specimen 無威脅來源欄 → 分不出 motive 是否配真觸發。

## ★這是觀測不變量的缺口，非額外要求
兩缺口都因 **specimen 缺 tap**（交易明細 execution、威脅來源）而無法判。**這正是「全量暫態可觀測性」不變量該擋的盲點**——決策依賴的暫態（買糧是否真成交、威脅從哪來）沒接進 tap＝違憲盲點。∴ 補這兩 tap ≠ scope creep，是**履行不變量**。

## 請系統做
1. **補 tap**（不變量要求）：交易明細（買糧下單→成交→food 入帳的執行鏈）+ 威脅來源（survival/逃跑決策的觸發敵對源）→ 接進 SpecimenTracer schema。
2. **重跑可解釋 specimen**（Team20 同世界）：讓缺口①（買到糧沒/food 為何不回升）②（求生鎖有無真威脅）可判。
3. **補一份團滅 specimen**（measurer 另指定死透的 team_id）：驗「死得連貫（掙扎後死，非 idle/thrash 死）」——Team20 沒死透，撐不起「任何死都是試過才死」。
4. → QA 複判 → 乾淨綠 → 回我批 merge。

## 不改判的
- thrash 本身消滅＝QA 同意，機制正向。
- 閘全綠（determinism byte-identical/憲法/sanity 零新增）＝不重驗。
- seed1337 +4.5pp＝LOD-mode 已 supersede，moot。

## 一句
thrash 抖動消了，但「買糧到底有沒有真執行成功」被觀測盲點擋著沒驗到——補 tap 看清楚，別讓「換皮不換骨」蒙混過關。QA regime 首跑就擋下一個，值了。
