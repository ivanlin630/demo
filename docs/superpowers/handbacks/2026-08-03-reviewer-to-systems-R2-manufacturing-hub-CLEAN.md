---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2追蹤項] 製造樞紐HOW——①genuine非crank：goods消耗結構性不同於乙(補經濟模型真缺口非調util乘數，need_oracle:109-110 comment本就自承goods零消費是簡化非設計終局)，但要求GOODS_UPKEEP_RATE校準錨定既有真消耗率參照非反推「多少能保證emerge」；②要求emergence量測看「異質結果」(有的隊選hub有的不選)非「加了需求demand自然升」這種trivial response當證據；B/C復用_dispatch_convoy/_market_visitor_buy確認乾淨"
---

# R②判決：製造樞紐 HOW — CLEAN + 2 追蹤項

## ★①genuine非crank——結構上是，但校準常數需要錨點
這是我這輪花最多力氣想清楚的地方。先比較跟乙那次crank的**性質差異**：

乙的問題是**直接調一個已存在的util乘數**(`ambition_amp=0.5+AMB_GAIN×gap`)，這個乘數除了「讓吸納這個選項分數變大」以外沒有任何獨立經濟意義——它不代表世界裡任何真實發生的事，純粹是決策層的分數操縱。

這次的(A)不一樣：它不碰任何util公式，是在**世界模型**裡新增一個真實的資源消耗事實——「人口會用掉製造出來的東西」。這不是決策層操縱，是補一個**經濟模型的缺口**。而且我在R①那輪親讀`need_oracle.gd:109-110`時，`_self_use`對`goods`回傳`0.0`的comment原文是「goods純貿易品，無自用消費sink」——這句話讀起來本來就像一個**早期簡化的暫定狀態**(承認沒有sink)，不是「goods本質上不該被消費」的設計終局。補上這個消費，比較像是**填補一個一直存在的模型缺口**，不是為了樞紐特別發明一個消費者。

**但**——結構上是genuine不代表`GOODS_UPKEEP_RATE`這個具體數字自動誠實。跟我在idle-labor那輪對`PER_HAND_OUTPUT`的要求同一個邏輯：

**要求**：`GOODS_UPKEEP_RATE`訂值時要錨定某個**跟樞紐要不要emerge無關**的真實參照——比如類比既有`FOOD_PER_PERSON_PER_DAY`(resource_system.gd既有真消耗率常數)的量級抓一個「每人每天消耗多少tools/weapon等值」的合理數字，或者從軍隊/民生的既有buffer常數(`TradeValuation.TARGET_PER_POP`)反推一個消費速率，而不是先跑幾次「樞紐有沒有長出來」再回頭調這個常數調到剛好長出來為止。如果校準方法是後者，那就是披著genuine外皮的crank——這件事spec本身無法從文字判斷，是實作/校準紀律問題，要求implementer在校準時明確交代錨點來源。

## ★②emergence量測要求——加碼一條，避免「有需求就有反應」被誤讀成「湧現」
§4現在的驗收邏輯是「有出口需求+進得到料→引擎自選import→manufacture→export」——這句話本身沒錯，但我想指出一個容易被誤讀的地方：**如果新增的goods消耗需求量級夠大，任何有idle勞力的隊都會自動被demand()拉去生產**，這種情況下"有反應"只是供給需求的基本恆等式，跟"引擎在多個選項裡秤出樞紐是最優解"是兩件不同的事——前者哪怕拿掉整個決策引擎、用最笨的if-else硬寫都會發生，不能拿來當「湧現非script」的證據。

**要求**：measurer在§4量測emergence時，除了「有沒有反應」，要看**跨隊異質性**——條件相似的多支隊伍裡，是不是只有某些隊（那些真的有idle勞力+位置卡在原料/需求路徑上的）選擇了import→manufacture→export，另一些隊選了別的選項(繼續採掘/貿易/純建設)——這種"不是人人都變工廠、變工廠的是有道理的那些"的分化，才是真正能區分"util競爭出來的選擇"跟"只要有demand就會發生的機械反應"的證據。這條要求明確寫進§4的驗收敘述，非只有我這輪口頭提。

## ②③④⑤⑥——其餘審點確認乾淨
- **湧現非script**：spec全程沒有寫死"某隊變hub"，(A)只加消耗需求、(B)(C)只加convoy的新kind/phase分支，決策本身仍走既有argmax競秤，方向對。
- **unify非patch**：(B)明確「鏡射`_dispatch_convoy`、複用porter/subteam spine、非另建convoy系統」，(C)明確「convoy物理橋接」直接用已存在的`_market_visitor_buy`(我本session已反覆讀過的函式，position-gated、讀tile.market_orders)——沒有重新發明一套平行的貿易邏輯。
- **感知鐵律**：(C)的buy-side de-local靠的是porter**物理**travel到對方tile(convoy移動需要真實時間跨tick)，不是隔空判定"聽說對方有貨就直接成交"——親讀`_market_visitor_buy`的運作前提本來就是"視覺上visitor真的站在那個tile"，convoy只是提供了一個**移動手段**去滿足這個既有的position-gate，不是繞過它。
- **need-gated**：(A)新增的消耗只是讓`effective_holding`降低觸發既有的shortfall買單路(`order_system:114`)，不是新開一條不受need管束的路，§51 no-floor不受影響。
- **B import phase**：`_tick_convoy`加`import`分支(OUTBOUND→FETCH/BUY→RETURN→home deposit)跟既有`export`分支(OUTBOUND→DELIVER→RETURN)結構對稱，是同一個狀態機加一個新分支非另起爐灶，符合我在SLICE A convoy審查時要求的「各階段專屬分支」精神。

## 判決
**CLEAN + 2追蹤項（GOODS_UPKEEP_RATE校準錨點/emergence量測看異質性非機械反應）→ dispatch隔離(可分A→B→C)。** 核心機制設計方向誠實、genuine論證站得住，兩個追蹤項是implementer/measurer階段要顧到的紀律，非blocking design flaw。
