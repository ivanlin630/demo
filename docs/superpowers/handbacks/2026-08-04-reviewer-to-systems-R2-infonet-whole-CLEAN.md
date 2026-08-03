---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2追蹤項] 資訊網whole HOW——①god-view機制層乾淨(看板relay仍是tile.market_orders單格結構，非跨市集聚合，親讀order_system:194確認)，但要求measurer額外看「hub效應」(少數熱門市集被高頻造訪，會不會功能上逼近near-global-awareness即使結構不違憲)非只看detector有沒有跳；④reuse確認為真(_dispatch_envoy/TASK_SCOUT本就是通用belief-based派遣機制非單一用途寫死)；util genuine結構同idle-labor/mfg-hub兩輪已驗證的模式，要求calibration常數錨定同款紀律"
---

# R②判決：資訊網 whole HOW — CLEAN + 2 追蹤項

給定這是whole-build一次量、難逆的大範圍scope，這輪針對systems自己標「最需戳」的①②(god-view+reuse)做最仔細的驗證，其餘沿用本session已建立的直接認識。

## ★①感知鐵律god-view——機制層乾淨，但要求追加「hub效應」量測
親讀既有`read_market_board`(order_system.gd:194-219，我本session已直接讀過)確認運作對象是**單一tile的`market_orders`陣列**，非跨市集索引/whole-map掃。這次擴充(訪客deposit自己team_known副本到board、board累積+輻射)沒有改變這個「單tile結構」的邊界——只是同一個結構現在**寫入**的東西變多(不只賣單，也含轉手的異地news)，讀取範圍依然是「這個市集」，不是「所有市集」。結構上，沒有引入任何新的跨tile聚合或索引，`constitution_gate`的god-view detector(親讀過的`GV_MAPSCAN_RE`/`GV_TEAMSTATE_RE`)不會被觸發，這條機制本身是乾淨的。

**但**——我想指出一個design text本身驗證不到、需要whole-build自己的量測階段去看的風險：如果少數幾個「熱門」市集(交通樞紐、大隊常去的地方)被**非常高頻**造訪，這個relay機制實際上可能讓資訊傳播速度/廣度遠超「純靠零星共位巧遇」的原始設計意圖——變成一種**功能上**接近「大家很快都知道」的效果，即使**結構上**完全沒有違反「必須物理在場」這條硬規則。這不是god-view違憲(沒有任何一步跳過物理限制)，是一種**emergent湧現的資訊過快擴散**，會讓原本想保留的fog-of-war/decay設計意圖在實際遊玩中被稀釋掉。

**要求**：§5的「感知鐵律不破」驗收，不能只看「god-view detector沒跳」，要額外量「資訊實際擴散速度/廣度」——尤其熱門市集節點附近的隊，資訊新鮮度是不是明顯高於零星移動的隊(這才是預期中的「hub地點消息比較靈通」)，還是整個世界的資訊新鮮度被拉得普遍很高(這就代表hub效應把fog-of-war意圖架空了)。這條要求寫進§5驗收，非只是我這輪口頭提醒。

## ★④無框內平行求解器——確認reuse為真
親讀`_dispatch_envoy`(faction_ai_system.gd:1323-1348)：函式簽名`(mother,target_id,ptype)`——`ptype`本身就是一個通用的「這次派信使是為了什麼目的」參數，目標位置讀`BeliefSystem.best_estimate`(belief-based，缺belief回傳sentinel(-1,-1)而非默認活人位置——這正是既有的「禁god-view、缺情報不派」保護，這次新增的「求援」用途直接繼承這個保護，不用重新設計)，派遣走既有`SubteamSystem`+冗餘機制。這是一個**通用的belief-based信使派遣框架**，目前被用在建國提案上，這次加一個新`ptype`(求援)是自然的參數化延伸，不是另起一個平行系統。`TASK_SCOUT`同理，親grep確認這是既有task、有自己的`task_reason`區分機制(`=="scout"`)，這次的「查自家子民」用途只需要一個新的`task_reason`值來跟既有敵情偵查區分，底層travel/observe/return機制完全共用。確認reuse claim為真，非包裝過的新引擎。

## genuine非crank——結構同前兩輪已驗證的模式，要求相同紀律
求援/偵察的util公式(`base_relief×人格modulate`/`info_staleness×info_value×人格`)結構上跟我在idle-labor(`PER_HAND_OUTPUT`)、製造樞紐(`GOODS_UPKEEP_RATE`)兩輪已經驗證過的「structure genuine、但calibration常數需要錨點」模式完全一致——base項有真實的期望值意義(缺口嚴重度×真實紓困量/資訊不確定性×資訊對決策的真實影響)，人格只modulate傾向不是憑空boost分數。**要求同款紀律**：`herald_cost`/`scout_cost`/`expected_info_value`裡任何implementer要訂的新常數，calibration時要交代錨定依據(比照既有cost/value常數的量級)，非反推「調到剛好讓求援/偵察fire」。

## Part3/Part4——範圍拿捏誠實
keep-line前瞻戰略儲備「待驗證是否需擴」——沒有預先over-build，先reuse既有reserve、留給measurement決定要不要擴，這個節制我認可。Part4(饑荒-flee免另修)的邏輯鏈(看板relay/求援信使→food賣單傳到餓隊→food_seek_target源②有值→relocate或賑濟)跟我在R①那輪親自追過的機制鏈完全對得上，不是新斷言。

## 判決
**CLEAN + 2追蹤項（hub效應量測寫進§5/calibration常數錨定紀律）→ 回systems dispatch implementer分片build。** ①②(systems自己標最需戳的兩點)皆親驗確認站得住，兩個追蹤項是whole-build量測階段要顧到的紀律，不是設計缺陷。這輪review我認為方向紮實，可以往下走。
