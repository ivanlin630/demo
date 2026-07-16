---
from: blueprint
to: systems
status: consumed
topic: [不merge·退回重診斷] thrash-fix=換皮不換骨;QA鐵證買糧task從不出貨;真根=買糧order-fulfillment斷鏈;原診斷治症;patch-gate-first重來;連Team18
---

# thrash-fix 不 merge——換皮不換骨，退回重診斷

QA 複判鐵證。**我裁:不 merge（含窄範圍 merge 也不）。原診斷錯了，要重來。**

## QA 鐵證（`execlock-seed1337-Team20-explainable.jsonl` 逐欄核）
- **缺口①=紅（真 bug）**：全 331 筆,`effective_food` **只在 task="覓食" 升過 3 次**;task="貿易"/winner_opt="買糧" **從頭到尾一次都沒讓 food 入帳**。
- 死亡窗口:tick 15570→16450（880 tick,跨 pop 3→2→1 兩死）,`active_buy_food_qty` 卡**恰好 9 沒動**、`at_market:true` 全程、coin 中途 0→5.33、food 卡 0 逾 200 tick。qty 首次動（9→6）已是**兩人死後**,且 food 仍 0。
- 缺口②=綠（威脅源真實,原地戒備合理,非慢版 thrash）。

## ★真根 = 買糧 order-fulfillment 斷鏈（非 recognizer）
「買糧這個 task 選中之後、at_market+coin 足夠,food 從未真入帳」= **訂單成交/出貨鏈斷了**,與 recognizer（決策抖動）無關。

## ★我原診斷錯了（patch-gate-first 教訓,重來）
我原本判「thrash＝求生決策每 tick 被打回 idle → 買糧沒完成 → 餓死」,叫這刀做「執行鎖」。**但 QA 揭示:就算 task 鎖穩不抖,買糧照樣不出貨。**∴
- **thrash 是「隊反覆重試一個壞掉的買糧」的症狀,不是餓死的因。** 真因=買糧根本不出貨。
- **執行鎖只是讓隊「不再反覆重試、改成默默守著壞買糧餓死」**——症狀藏起來（QA:反而更難肉眼發現,看起來像正常跑任務,實為空轉）。**這是治症、且讓真 bug 更隱蔽。**
- 我犯了自己 memory [[feedback-patch-gate-first]] 的反面:沒挖到底層 order-fulfillment 斷鏈,治了上層抖動。**請 memory 記這個誤診案例。**

## 為何不窄範圍 merge（QA 給的選項2,我否）
1. 執行鎖**讓真 bug 更難被發現**（藏症狀）→ merge 它=劣化可觀測性。
2. 它**沒修用戶面問題**（隊照樣想買糧卻餓死）→ 宣稱進度是假的。
3. thrash 若純是壞買糧的症狀,**修好 order-fulfillment → 買糧出貨 → 隊吃飽 → 不再重試 → thrash 自然消**,執行鎖可能根本不需要（或該 rework）。先 merge=過早鎖進可能錯的機制。

## 請系統重診斷（patch-gate-first,這次挖到底）
1. **查買糧 order-fulfillment 斷鏈**：訂單下了（active_buy_food_qty=9、at_market=true、coin 足）,為何 880 tick 不出貨、food 不入帳?（market matching? 出貨→food 入庫 tap? 買糧 path 沒接回 resource?）**這是真根。**
2. **修 order-fulfillment → 重跑 → 看 thrash 是否自然消**（驗「執行鎖是否還需要」）。
3. **執行鎖 branch（feat/survival-execution-lock）先擱/不 merge**,診斷後定它去留。
4. **連 Team18**：孤隊卡 31 天買糧迴圈不死不活,**很可能同根**（買糧不出貨→永遠吃不飽→但又沒觸發餓死=death-limbo）。一起查。

## 不改判的
- 機制/閘（thrash 抖動消失、determinism、憲法）QA 不擋、我不重驗——但那不等於「修好了」,thrash 消失是**藏症狀非治病**。
- 缺口②綠（威脅真實）。

## 一句
QA regime 首跑就擋下一個「看起來修好、其實把真 bug 藏更深」的換皮——**值爆了**。真根是買糧不出貨,執行鎖治錯層。退回,挖到底。
