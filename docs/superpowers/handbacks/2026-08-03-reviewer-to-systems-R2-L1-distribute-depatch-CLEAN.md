---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] L1 intra-faction distribute de-patch——親讀goal_resolver.gd:154(現況received_buy_orders確認)+:220-232(_deliver_candidates用同函式但完全獨立function body)確認②cross-faction隔離是結構性保證非承諾——新helper只給_distribute_candidates呼叫，_deliver_candidates/demand()一行都沒被碰到，架構上不可能漏；①util formula(relief+coin)確認完全不在改動範圍內，genuine不變非crank；is_resident_static既有真function非新造；CLEAN→implementer"
---

# R②判決：L1 intra-faction distribute de-patch — CLEAN

## ★②cross-faction隔離——親驗是結構保證，非承諾
親讀`goal_resolver.gd`現況：`_distribute_candidates:154`跟`_deliver_candidates:232`**都**呼叫`OrderSystem.new().received_buy_orders(state,team)`——但這兩個是**完全獨立的function body**(:126起跟:220起，中間沒有共用helper)。這次de-patch的方案是新增一個只給`_distribute_candidates`呼叫的新函式`_intra_faction_food_buy_orders`，`_distribute_candidates:154`那一行換成呼新函式，`_deliver_candidates:232`那一行**原封不動**——因為兩個function之間本來就沒有任何共享的中間層可以被這次改動波及，cross-faction隔離不是「這次改動小心翼翼避開了」，是**架構上這兩條路徑從頭到尾就是分開的兩條線，其中一條被換源，另一條連摸都沒被摸到**。這是我這輪驗證最仔細的一點，結論：隔離是結構性保證。

## ★①genuine非crank——util formula確認完全在改動範圍外
親讀`_distribute_candidates`現況(:126-175+)——util計算(`relief_term`/`coin_term`，我在SLICE B那兩輪已經逐行驗證過的公式)完全不在這次改動的範圍內；這次唯一改的是「怎麼找到buy_orders這個陣列」，陣列裡每個元素的shape、下游怎麼用這些元素算util、怎麼算deficit/runway/claimed去重——全部維持原樣。這不是「調整一個看起來像事實查核的東西去讓util變好看」，是換一個**取得資料的管道**，跟util分數的計算邏輯完全正交，不可能是披著皮的crank。

## 感知鐵律scope邊界——非新發明，既有precedent
`is_resident_static`(親讀`faction_ai_system.gd:503-513`)是既有真實函式(檢查PRODUCE tag+在自家outpost tile上)，非為這次修法新造。「同勢力成員身份是行政記帳、非需要belief傳播才能知道」這個區分，跟我在SLICE B分配政策最初那輪就已經核可過的推理一致(領主知道自己勢力有哪些居民隊是faction membership記帳，不是猜測敵情)——這次只是把這個既有原則正確套用到「領主知道自己居民的buy-order」這個具體案例，不是開創新先例。

## 其餘（determinism/no平行solver）——確認到位
新helper用`for tid in state.teams`(Dictionary插入序，跟既有`:145`claimed-scan pattern同構)+純算術，零RNG。買單本身的產生管道(居民post shortage_buy)完全不變，這次只換領主"聽到"買單的**感知來源**，不是新增一條平行的分配決策路徑。

## 邊界（spec已列，認可延後）
「居民餓但還沒post buy-order」的timing gap——spec選擇不synthesize假訂單、寧可等下個cadence補齊，這個選擇誠實(不製造沒有order_id的假分配)，若真的需要更即時的反應是另一個議題，不該塞進這次minimal de-patch，認可延後處理。

## 判決
**CLEAN → 回systems dispatch implementer build。** ①②(systems自己標最需戳的兩點)皆親驗確認站得住。measurer驗收時的「cross-faction數字不因本改動而變」這條，給定我已經確認架構上不可能被波及，這條驗證結果應該會很乾淨，不用特別緊張。
