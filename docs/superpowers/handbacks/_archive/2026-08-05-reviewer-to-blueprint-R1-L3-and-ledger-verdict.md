---
from: reviewer
to: blueprint
status: consumed
topic: "[R①×2判決] (1)L3循環貿易=CLEAN+必訂正P2/P3(非halt,缺口本體仍真在但描述過頭):親讀_merchant_trade_target(faction_ai_system.gd:2563-2573)+_nearest_market_outpost(2578-2593)+『貿易』option applicable(options.gd:18『has_goods or has_arb』)發現一條既有『去已知市集逛逛順便讀板』的fallback路(無arb時巡最近known市集),P2『商人只對已聽聞單反應、無主動去讀板決策』字面上不成立——真缺口是這條既有路太naive(永遠揀最近、零staleness/util秤、零人格分化)+applicability被has_goods/has_arb擋住settled產隊進不去+只能去team_market_known(vision半徑/relay聽過)範圍內的市集永遠發現不了全新未知遠方市集;要求P2/P3改寫成精確描述這個更窄的真缺口,HOW設計方向應是『升級_nearest_market_outpost的naive揀法成genuine util秤』非『從零蓋新option』,否則走偏建平行機制;(2)失聯帳本=CLEAN+1提醒:P1親驗坐實且證據比claim更豐富——grep到10+個獨立timeout常數(FOUNDING/TRADE/STATION/SCOUT/FLEE/CONTACT/CONSTRUCT_TRANSIT/letter/envoy/scout)全是子單位側自我到期非母隊側帳本,散落程度比『3旋鈕』還嚴重支持P1;但意外挖到_evaluate_owner_contact+_trigger_defection_evaluation(faction_ai_system.gd:4651-4664)——這是一個方向相反(村發現領主久無音訊,非領主發現遠村久無音訊)但用同一套底層原語(BeliefSystem.best_estimate().last_tick+_DAYS門檻)的既有『失聯偵測→反應』機制,P1沒提到這個,要求R②/HOW階段必須明確處理跟這個既有機制的關係(整併/reuse同款原語 vs 刻意保持獨立),否則新帳本系統本身就會變成第4個散落知識點,正撞上這spec自己想解的3旋鈕病"
---

# R①×2判決：L3循環貿易 CLEAN+必訂正 / 失聯帳本 CLEAN+1提醒

## (1) L3循環貿易——CLEAN + 必訂正P2/P3（非halt，缺口本體仍真在，但描述過頭）

### P1/P4——親驗坐實
`read_market_board`(order_system.gd:194-219，本session多輪已驗)=到場firsthand讀板，P1對。P4：`_market_peer_trade`(interaction_system.gd:789-812)+keep-line(`TradeValuation.reserve`)本session早幾輪(S-trade Part3)已經審過確認merged活，P4對。

### ★P2——字面上不成立，但缺口本體仍真在，要求改寫成精確版本
親讀`faction_ai_system.gd:2563-2573`(`_merchant_trade_target`)+`:2578-2593`(`_nearest_market_outpost`)：**確實有一條既有的「去逛市集順便讀板」路徑**——商人無已知arb時，`_merchant_trade_target`會呼叫`_nearest_market_outpost`巡「最近已知市集outpost」，抵達後既有`read_market_board`(S-prop)機制會firsthand讀板。這代表「商人只對已聽聞單反應、無主動去讀板決策」這句話**字面上不成立**——已經有一條主動去讀板的路，非零。

但這條既有路徑**確實非常naive**，這才是真正的缺口：
1. `_nearest_market_outpost`永遠只挑**最近**的已知市集（`:2589-2592`純距離排序），**零staleness/預期套利值的util秤**——不會因為某市集資訊特別舊而優先去，純粹每次都去同一個最近的。
2. `貿易`option的`applicable`(`options.gd:18`)是`has_goods or has_arb`——**沒有貨也沒有已知arb的隊，這個option根本不是候選**，這部分P3是對的（詳下）。
3. `team_market_known`（`_harvest_market_known`,`:2619-2639`）只透過**vision半徑內直接看到**或**relay聽過的訊息**累積——一個隊永遠不會主動走向一個「完全沒聽過、不在視野範圍內」的市集，L3想要的「遠距循環貿易」如果目標市集從沒被看過/聽過，這條既有路徑一樣到不了。

**要求**：P2改寫成——「既有`_merchant_trade_target`/`_nearest_market_outpost`的訪市fallback是naive nearest-pick、零staleness-util秤、零人格分化，且受限於`team_market_known`範圍——這才是真缺口，非『完全沒有訪市機制』」。這個訂正影響HOW設計方向：**正確路線是升級`_nearest_market_outpost`的揀法（naive nearest→genuine util(staleness×value−cost)秤+人格modulate），reuse既有`貿易`option/`_merchant_trade_target`這個seam**，非從零開一個新的「訪市決策」option——後者會是跟既有機制平行的重複建設，撞`feedback_no_patch_on_settled_architecture`。

### P3——CLEAN但需搭配P2一起訂正
「settled隊無訪外市集候選生成路」對**沒有貨也沒有已知arb**的settled隊成立（`貿易`option applicable擋在門口）。但**有貨的settled隊**（`has_goods=true`）其實貿易option是candidate、也會透過naive nearest-pick去逛市集——這部分P3過度概括了。跟P2一起訂正成「零貨零arb的settled隊完全無路；有貨的settled隊雖有路但naive」，讓HOW設計者知道要處理的是「兩種隊都升級到genuine util秤」而非只補「完全沒路」那一種。

## (2) 失聯帳本——CLEAN + 1個R②必查提醒

### P1——親驗坐實，且證據比claim描述更豐富
親grep`faction_ai_system.gd`全檔`timeout`關鍵字，找到**10個以上獨立的timeout常數**：`FOUNDING_TIMEOUT_MULT`/`TRADE_TIMEOUT`/`STATION_TIMEOUT`/`SCOUT_TIMEOUT`/`FLEE_TIMEOUT`/`CONTACT_TIMEOUT_DAYS`/`CONSTRUCT_TRANSIT_TIMEOUT`/letter timeout/envoy timeout——**每一個都是子單位自己配一個timeout、自己到期自己recall/dissolve**，沒有一個把「逾時」這件事回報給母隊側形成一筆帳。這個散落程度**比spec自己講的「3旋鈕」還誇張**（是10+旋鈕），P1「無統一tracking」這句話不只成立，證據比claim原本引用的還扎實。

### ★意外發現——`_evaluate_owner_contact`，R②/HOW階段必須處理
親讀`faction_ai_system.gd:4651-4664`：這是**已存在**的機制——resident村莊自己偵測「我的owner（領主）多久沒消息了」（`BeliefSystem.best_estimate(state,team.team_id,owner_id).last_tick`+`CONTACT_TIMEOUT_DAYS`門檻），逾時觸發`_trigger_defection_evaluation(state,team,"no_contact")`。

這個機制**方向剛好相反**於spec描述的案例（spec講「領主對久沒消息的村」=領主查子民；這個既有機制是「村對久沒消息的領主」=子民查領主），P1沒有提到這個既有機制。但兩者用的是**同一套底層原語**（belief staleness via`best_estimate().last_tick`+一個`_DAYS`門檻常數+觸發某個反應）——這代表：
1. 這個既有機制是**技術可行性的強力佐證**（同款pattern已經在codebase裡跑，非spec憑空發明）。
2. **但**如果新的「失聯帳本」系統不明確跟這個既有機制對齊/整合，很可能變成第**4個獨立的**「staleness偵測→反應」小系統——**正好撞上這個spec自己要解的3旋鈕病**。

**要求**：R②/HOW階段必須明確處理這個關係——是把`_evaluate_owner_contact`折進新的統一帳本（用新帳本的「失聯」belief flag取代這個獨立`no_contact`判斷、觸發走新帳本的人格反應而非現有硬編`_trigger_defection_evaluation`），還是刻意保留獨立（如果保留需要講清楚為什麼resident-對-owner這個特定關係不該併入通例）。這不是spec premise本身有錯，是R②必須交代的整合設計問題。

### P2/P3——親驗坐實
P2：scout side-dispatch本session前幾輪已確認35/40 fire，反應端既有為真。P3：`team_known`/`MessageData`結構本session反覆驗證支援加`type`欄位不用新store，belief store可承載失聯flag為真。

## 判決
**L3：CLEAN + 必訂正P2/P3（缺口本體真實，描述需改精確，HOW方向=升級既有naive選點非新建平行option）。失聯帳本：CLEAN + 1個R②必查提醒（`_evaluate_owner_contact`整合關係要交代）。** 兩spec核心guardrail（湧現非waypoint/人格非死常數）我沒有意見，這輪判準只在code前提；兩處我都往下多挖了一層spec自己沒提到的既有code證據，非只驗spec引用的行號本身。
