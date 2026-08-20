---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2輕量觀察] F0 state-fingerprint安全網HOW——★審點⑤(F0不擾世界禁耗global RNG)最仔細查:這條對應本session memory feedback_observer_no_global_rng『觀測儀器禁耗randf,LOD→RNG已犯過兩次』的第三度警戒線,spec的自驗設計(determinism 3-run byte-identical+coin_eq純讀不寫)是間接但有效的偵測手法——如果StateFingerprint計算過程真的消耗了global RNG,會偷走後續合法模擬邏輯要用的隨機數,導致同seed三跑的世界軌跡本身就分岔,這個3-run test抓得到,且這正是本session稍早obs-rng-gate那個arc已經驗證過有效的同款方法論非新發明的脆弱手法;輕量觀察(非阻塞)①:間接的3-run偵測法沒問題但可以再加一個更直接的測試——在StateFingerprint.compute()呼叫前後直接讀RNG call-count/state做斷言,比等軌跡分岔這種間接症狀更快失敗更好debug,非必要只是錦上添花;②scope覆蓋度:3床(warring/peaceful-economy/recovery-cohesion)聲稱覆蓋全8域,但envoy(建國提案/信使外交)這個域具體被哪一床exercise到不夠明確(warring的diplomacy或recovery-cohesion的side-dispatch兩邊都可能沾到但沒明講),建議build時順手確認envoy相關欄位在27筆fingerprint裡真的有變化非死值(如果envoy從沒被真exercise到,這個域的漂移偵測是假的覆蓋);full canonical dump優先於摘要這個spec自檢精化(hash本身collapse任意size成定長,摘要無助於省size反而漏偵測)技術推理正確;dict顯式sort(非信GDScript4插入序)在fingerprint這個specific用途上是正確且必要的保守選擇,不是跟codebase既有『dict插入序可信賴』的invariant矛盾——那個既有invariant保證的是同code同輸入下run-to-run可重現,非跨code版本的順序穩定性,fingerprint恰好需要後者這種更嚴格的性質;涵蓋範圍/排除項清單合理;CLEAN→build(StateFingerprint helper+state_fingerprint_bed harness+baseline 27 fingerprint)"
---

# R②判決：F0 state-fingerprint安全網 HOW — CLEAN + 2輕量觀察

## ★審點⑤（F0不擾世界，禁耗global RNG）——這輪查得最仔細的一點
這條對應本session memory記錄過的憲法級不變量`feedback_observer_no_global_rng`——「觀測儀器（tracer/probe/HOB）禁耗global randf，這是**第三次**同族LOD→RNG病灶」。F0本質上是又一個新的觀測/量測儀器（讀整個world state算hash），這條防線的重要性我認同要優先查。

spec的自驗設計：**determinism 3-run byte-identical**（世界軌跡不變）+**coin_eq純讀不寫**。這是**間接但有效**的偵測手法——如果`StateFingerprint`計算過程真的偷偷呼叫了`randf()`之類的函式，會從global RNG stream偷走一次本來要留給後續合法模擬邏輯用的隨機數，導致**即使是同一個seed，三次獨立跑測的世界軌跡本身就會產生分岔**（因為RNG被F0偷用過一次，後面所有依賴RNG的模擬邏輯都會拿到錯位的隨機序列）。這個3-run determinism測試抓得到這類問題——而且這正是本session稍早`obs-rng-gate`那個arc已經實測驗證過有效的同款方法論，不是這輪臨時發明的脆弱手法。

## 輕量觀察①（非阻塞）——可以加一個更直接的RNG測試
間接的3-run軌跡分岔偵測法沒問題，但如果想要更快失敗、更好debug，可以額外加一個直接測試：在`StateFingerprint.compute()`呼叫**前後**直接讀RNG call-count（或等效的RNG狀態快照）做斷言，比等到「軌跡分岔了」這種間接症狀更早抓到問題根源。這不是必要項，是錦上添花的建議，供implementer參考。

## 輕量觀察②（非阻塞）——envoy域的覆蓋度可以在build時順手確認
3床（warring/peaceful-economy/recovery-cohesion）聲稱合起來覆蓋全部~8個行為域，但`envoy`（建國提案/信使外交）這個域具體被哪一床真正exercise到，spec沒有明確點名——warring的「diplomacy」跟recovery-cohesion的「side-dispatch」兩邊都可能沾到一點，但沒講清楚。**建議**build完27筆fingerprint之後，implementer順手確認envoy相關欄位（例如`in_transit_letters`裡`kind="help"/"relocate"`以外、跟建國提案相關的信使活動）在這27筆之間真的有變化、非恆定死值——如果envoy這個域從沒被真正exercise到，這個域的漂移偵測能力就是假的覆蓋，不會在後續結構slice真的出問題時被發現。

## 涵蓋範圍/排除項——親驗設計思路合理
「full canonical dump優先於摘要」這個spec自檢精化的技術推理是對的——雜湊本身會把任意大小的輸入collapse成定長輸出，摘要對「省size」這個目的沒有幫助，反而會漏掉摘要沒抓到的細微漂移，全量canonical dump是正確選擇。排除清單（ephemeral快取/probe/observer/tracer/phase-timing/RNG state本身）都是「非決策結果本身的meta資訊」，排除合理，不影響漂移偵測能力。

**dict顯式sort（不信任GDScript4插入序）**——這個選擇在fingerprint這個specific用途上是正確且必要的保守作法，跟這個codebase既有的「dict插入序在同code同輸入下可重現」這條determinism慣例**不矛盾**——既有那條invariant保證的是「run-to-run」的可重現性（同一份code、同一組輸入，跑幾次都一樣），但fingerprint需要的是更嚴格的「跨code版本」順序穩定性（結構重構如果不小心改變了某些entry被建立/插入的順序，即使實際的team集合跟欄位值完全沒變，插入序仍可能被打亂，若fingerprint依賴插入序就會產生假陽性漂移警報）——顯式`sort()`by id避開了這個陷阱，這個判斷正確。

## 判決
**CLEAN → build（`StateFingerprint` helper + `state_fingerprint_bed` harness + baseline 27 fingerprint）→ F0綠=安全網就位 → F1（threshold死常數審）。** 這輪最重要的查核是RNG不消耗這條防線——spec的間接3-run偵測法有本session既有前例背書、技術上站得住，兩項輕量觀察（更直接的RNG call-count斷言/envoy域覆蓋度確認）供build階段參考，皆非阻塞。地基KEEP。
