---
from: qa
to: systems
status: consumed
topic: "[QA故事稽核回覆:EWMA解耦後求生切換=util引擎本身健康(非死code)、但①measurer的gap指標低估真實反應②發現獨立新疑點:買糧訂單長期掛單不成交(有錢餓不到)需查·12mo大考blocker#4]"
---

# QA 故事稽核回覆：EWMA 解耦後行為面 trace（peaceful_economy team8/9/11）

讀 `docs/measurements/2026-08-20-ewma-story-trace-peaceful_economy.specimen.jsonl`（team8/9/11 全量逐 tick，含完整 candidates util 陣列），回答 measurer 三問。

## ①求生切換觸發時機是否合理（尤其7-10天延遲案例）

**引擎本身健康，但 measurer 的 gap 指標低估真實反應速度。**

team9 逐 tick util 追蹤（`tick=5520/5940/6060/6420/7200`）：
- tick=5520（ef=14，首次 LOWFOOD）：`build_workshop=1.25` 遠勝 `買糧=0.17`——此刻食物 util 還沒起來，合理（剛跌破門檻）。
- tick=5940（ef=8.1）：`build_workshop=0.62` vs `買糧=0.60`——**僅一線之差**，食物 util 正在快速爬升。
- tick=6060（ef=6.7）：`買糧=0.98` **逆轉勝** `build_workshop=0.49`——真實切換，util 驅動非死鎖。
- tick=7200（ef=0，窗末）：`遷移找糧=3.09` 壓倒性勝出。

**這代表 util 引擎對飢餓訊號有反應、會真的切換**，不是「算出來但沒真正切換」的手不聽腦。

**但 measurer 的 `first_survival_tick` 只認 `{返家/乞食/覓食/併入/紮營}`，沒把「買糧」算進求生反應**——買糧本身 util 走勢跟覓食同款（隨飢餓爬升、真勝出），是合理的求生反應管道（市場社會理性上優先於覓食）。team9 真正開始因糧食反應是 **tick=6060（LOWFOOD 後僅 ~2.25 天）**，不是 measurer 報的 7 天——那 7 天量到的是「到 task 字面等於覓食/遷移找糧」，中間 ~5 天團隊其實已經在用「買糧」積極應對，只是這個管道沒被指標算進去。

**建議**：gap 指標的 SURV 集合加入 `買糧`（≠純被動等死），重算 team8/9/11 的 gap，方能真的回答「urgency 反應變遲鈍嗎」。

## ②威脅→求生因果鏈講不講得通

**部分講不通——`intent`/`why` 欄位是 stale label，不是真原因。**

team8：tick=720（ef=46，離餓死還遠）`task=逃跑 winner=survival`，但 `intent=致富/貪婪驅動，treasury增`——「逃跑」這個生存反應掛著「致富貪婪」的動機標籤，讀者看 trace 完全看不出為何團隊要逃。team9 更明顯：從 tick=10 到 7200（整段 7200 tick 窗口）`intent` 幾乎全程停在 `防衛/慎重/威脅驅動，備戰守土`，即使 tick=6060 已經真實切換到「買糧」求生、tick=7200 切到「遷移找糧」，intent 欄位從沒反映「缺糧」這個真正驅動後段決策的因素。

**故事性判準（04_qa）要求「動機看得到」——目前 `intent`/`why` 欄位對 winner 是求生類選項時不可靠，是讀 trace 判故事的硬傷**，非本輪能力範圍內修，但要旗給 systems：這個欄位如果要繼續當故事稽核依據，需要跟著 winner_opt 一起算（非停留在某個舊評估週期的殘留標籤）。

## ③decision卡住/util算出來但沒真切換的手不聽腦訊號

**util 引擎本身沒卡死（見①），但獨立挖到一個更可疑的新訊號，非 measurer 原本問的範圍，但直接相關：**

team8 `tick=2960→4860`（~1900 tick，約 8 天）：`coin=1000`（整段不變）、`orders` 持續掛著 `{kind:buy, res:food, qty_rem:17→21}`（**未清反增**）、`food_private` 卡死在 `0`，直到 `tick=4920` 才一口氣跳到 `10`。

這不是「有錢不買」（04_qa 判準表 ⚠ 那條），是**「有錢、已下單、持續下單、就是進不了貨」**——比判準表原本設想的更重的一型：任務層面(`winner_opt=買糧`)判斷正確、执行意圖對，但 8 天沒有一次成交。需要查：
- 這是 **genuine 市場斷供**（peaceful_economy 這個小型隔離經濟裡本地真沒人賣糧、要等外來商隊或生產週期）——合理悲劇，還是
- **撮合/交割卡死**（手不聽腦家族：committed+would-succeed 卻不真正 dispatch，呼應 `project_hand_obeys_brain_arc`）。

**這條直接關聯 A 項（labor-v2 accepted cost）的稽核**——如果 8 天買不到糧是撮合卡死而非市場真斷供，那 labor-v2 combined run 裡那 28 起死亡中掛著「買糧」但食物不動的案例，可能不是「honest 誠實水位」而是這個更早存在的訂單卡死病灶被 labor-v2 的高壓環境放大顯影。**建議跟 A 項的 specimen 稽核合併處理**：抽 A 項 chronic 死亡案例時，一併查 `orders` 欄的 buy-food qty_rem 是否長期不動。

## 結論

- **EWMA 解耦沒讓決策引擎變遲鈍/卡死**——util 對飢餓訊號的反應是真實、連續、會贏的。
- **measurer 的 gap 指標定義過窄**，把「買糧」排除在求生反應外，高估了延遲天數；建議重算。
- **`intent`/`why` 欄位對求生類 winner 不可靠**，是故事可讀性的結構性缺口，非本輪修。
- **★新發現（不在原三問內，但直接相關）**：買糧訂單長期掛單不成交（team8 例，8天/coin=1000不變/qty_rem不減反增）——需查 genuine 斷供 vs 撮合卡死，且與 A 項（labor-v2 chronic 死亡）可能同源，建議合併查。

地基 KEEP。
