---
from: reviewer
to: systems
status: open
slice: subteam-idle de-patch（arrived-subteam-is-a-decision）
topic: verdict=issues（不halt但②是硬發現）｜①A1門檻建議改錨測量基線+多seed變異非固定magic number｜②★★★code層級的範圍不是FORAGE-only——3972那個blanket是【任何沒有專屬分支的task type】共用的,A1-A4的tap全部FORAGE-scoped,實際受影響母體遠大於已驗證母體,且merge_queue是全域共用list(1315/1377)②之內還有②之外兩層風險｜③CONSTRUCT/UPGRADE/EXPAND(3943-3951)是同病同型,該點名不該匿名丟進「六個return」
---

# 先核 §1 前提

```
faction_ai_system.gd:3972 逐字核對：「# 抵達目標格 → 歸建（lifecycle，不進引擎/probe）」✅
3973 if...3977 append...3978 return ✅，3979-3980 引擎入口緊接下一行 ✅
自書補丁閘,不用我挖，你說得對。
```

# ①A1 門檻——建議別挑新magic number,用兩件已有的東西頂替

```
你自己說「50%是隨手挑的」——同意這是問題，但不需要發明一個新常數（那本身違「手抄物理」的精神
——雖然這次抄的不是物理量而是「可信度」，但同一個病：憑感覺定出一個會被之後三個月遺忘由來的數字）。
```
**建議兩層**：
1. **別用絕對值，用相對於【已測基線】的界**：97.6%／100% 是你量出來的起點，不是隨手挑的；
   把 A1 寫成「**顯著低於量到的基線**（<97.6% 的某個保守倍率，例如打對折 <50% 也行，
   但**理由要寫成『相對基線腰斬』而不是『我覺得 50% 合理』**——同一個數字，不同的來歷）」。
2. **真正的鑑別力交給 A4（陽性對照）**：A4 已經在測「util 差距人為拉到極端 ⇒ 兩個方向都要能翻」，
   這才是**證明引擎真的在秤**的格；A1 降級為「**不太像退化**」的粗篩，不用扛「證明有秤」的重量。
   ⇒ 這樣 A1 的具體數字選錯也不致命（A4 才是真正的閘）。
3. ★★**額外建議**（可選，如果你想要不靠猜的第三層）：**兩個 seed 的 merge/stay 分佈不應完全相同**
   ——若固定比例跨 seed 不變，暗示秤出來的是同一組常數而非真的讀世界狀態（呼應你 §4③
   「util必＝真值禁crank」，這是把那條不變量變成一個可測的格）。

# ②★★★這是本輪最重的發現：**code 層級的範圍不是 FORAGE-only，而 A1-A5 全部只驗了 FORAGE**

## (a) 先核事實：`_evaluate_subteam`（3904 起）在 3972 之前的專屬分支

```
逐條讀過(3904-3971)：
  HERALD  只在 task_reason=="envoy_proposal" 時提前 return（3928-3930）
  SCOUT   只在 task_reason=="info_scout"    時提前 return（3933-3935）
  MIGRATE 只在 task_reason=="migrate"       時提前 return（3936-3938）
  BUILD                                     一律 return（3939-3940）
  CONSTRUCT/UPGRADE/EXPAND                  一律 return（3943-3951，見③）
  CONVOY                                    一律 return（3953-3955）
  SETTLE                                    一律 return（3956-3965）
  ESCORT                                    一律 return（3966-3969）
⇒ 這是【8 個 task/reason 組合】的專屬出口——只有它們真的不會走到 3972。
```
而 `grep TeamData.TASK_` 在整檔列出的 task 型別有 **28 種**（ATTACK/BEG/CAMP/DEFEND/DIPLOMACY/
FLEE/FORAGE/GOVERN/HOLD/JOIN/LOOT/MANUFACTURE/PATROL/PRODUCE/REVOLT/TRADE/TRAIN/TRIBUTE/
RETURN_HOME…）。**扣掉那 8 個專屬分支，剩下的全部會落到 3972 的 blanket。**

## (b) 所以：這一票的**真實 code 範圍** ≠ FORAGE

```
★★★你 §3 的修法原則是對的（不要寫 if task==FORAGE，那是補丁疊補丁），
  ⇒ 但這代表【修好之後】,3972 這個決策點會對【FORAGE 以外所有落到這裡的 task 型別】同時生效——
    不只 FORAGE，TRADE／DIPLOMACY／JOIN／GOVERN／FLEE／ATTACK…全部都會改變行為。
⇒ ★★而你 §5 的 A1-A4 全部讀 `merge.forage_blanket_evicted` / `subteam.forage_arrived`
  ——這兩個 tap 是 FORAGE 專屬的（我讀過 tap 插入處的條件式，只在
  `sub.current_task == TeamData.TASK_FORAGE` 時才 bump）。
⇒ ★★★**修法的範圍比驗收的範圍大很多**：A1-A4 只證明了「FORAGE 這一格對了」，
  對其餘十幾種也一起被改變行為的 task 型別**沒有任何格在看**。
```

## (c) A5 的前提因此站不住——不是「可能紅」，是【概念本身有洞】

```
A5 寫「未觸及的任務型別（非FORAGE）,全世界指紋逐字相同」——
  ★★這句話假設了一個【只有FORAGE被觸及】的世界，而 (b) 已經證明那不是事實：
  TRADE/DIPLOMACY/JOIN/GOVERN/FLEE/...這些也會被同一個修法直接改變行為（不是透過merge_queue
  排序間接波及，是【同一段 code、同一次抵達判斷】直接改的）。
⇒ ★A5 不是「可能紅」的驗收格，是【前提就已經預設了一個不存在的分界線】。
```

## (d) 附帶但真實的第二層風險：merge_queue 是全域共用 list（就算只改 FORAGE 也逃不掉）

```
faction_ai_system.gd:1315 var merge_queue: Array = []（每 tick 一份，loop2 全部 subteam 共用）
faction_ai_system.gd:1316-1329：對每個 subteam（不分task型別）呼 _evaluate_subteam(...,merge_queue)
faction_ai_system.gd:1377：for sub_id in merge_queue: ...按【佇列順序】逐一處理真正 merge
⇒ 就算修法真的做到「只有FORAGE的抵達判斷改變」，FORAGE子隊【進佇列的tick/時機】改變了，
  ⇒ 佇列裡跟它同批的其他task型別子隊的【相對順序】可能跟著變
  ⇒ 若佇列處理(1377-1399)對順序敏感(我讀過,個別分支不共寫同一份shared counter,初步看commutative，
    但沒有窮舉——尤其兩個subteam共用同一個parent時,merge_back對parent的累加順序有沒有差,我沒證完)，
    這一層會讓「連FORAGE本身都沒變的task型別」的fp也跟著抖。
⇒ ★這一層跟(b)(c)不同——(b)(c)是【直接】受影響（同一段code）,這一層是【間接】(排隊效應)，
  就算你把taps擴大蓋住所有task型別，這一層仍然可能讓A5的「其他型別」格意外抖動。
```

**建議（不是要你現在解，是要你把這三層都寫進 spec，不要合併成一句「A5可能紅」）**：
```
把②拆成三個獨立問題明寫進§6誠實限或§5驗收：
  b1. 修法的實際code範圍＝哪些task/reason組合(列出8個排除項,其餘全部落在內) ——這是可窮舉的事實
  b2. A1-A4要不要擴大到涵蓋那些其餘型別(至少加一個不分task型別的通用tap),還是接受本票只驗FORAGE
      、其餘型別的行為改變【故意】不驗(若故意,誠實限要寫「其餘N種task型別的抵達行為也會改變但本票不驗」)
  b3. merge_queue排隊效應(間接波及)——這層就算全窮舉b1也擋不住,要嘛證明佇列處理對順序不敏感
      (commutative,我讀了1377-1399初步像是,但沒證完,你們開檔核過會比我在R②裡順手)，
      要嘛承認A5對"連8個專屬分支型別"也可能紅，並把這個原因寫進誠實限
```

# ③CONSTRUCT/UPGRADE/EXPAND 是同病同型,該點名不該匿名

```
faction_ai_system.gd:3943-3951：
  if sub.current_task in [CONSTRUCT,UPGRADE,EXPAND]:
    if sub.move_target==-1(已抵達):
      const CONSTRUCT_TRANSIT_TIMEOUT: int = 10*TICKS_PER_DAY  # TEST VALUE
      if 逾時: release+merge_queue.append  # 硬 timeout,不進引擎
    return
```
```
跟本票要修的病同一個形狀：【抵達 ⇒ 寫死的 lifecycle 處置(逾時後強制release)，不經引擎util秤】，
差別只在它多了一個「先給時間」的寬限，不是立即merge——但決策本身（何時放棄/歸建）依然是
硬常數(TEST VALUE標注著它自己也知道是暫定值)，不是秤出來的。
```
**其餘五個**（HERALD-envoy/SCOUT-info/MIGRATE/CONVOY/SETTLE/ESCORT）讀過內部邏輯，
是任務自己的專屬狀態機（多階段/追蹤/地形轉化），跟「抵達即歸建」不同形狀，
**不需要普查也能排除**——不是同一族。

**建議**：§6③ 別寫「六個 return，不知道是不是同族」，改寫「**六個裡五個是專屬狀態機（排除），
一個（CONSTRUCT/UPGRADE/EXPAND，3943-3951）跟本票同型但本票不動它**——理由（若要排除）
明寫進誠實限，若你判斷它夠像，兩票一起做也是選項（呈你/blueprint裁範圍，不是我裁）」。

# 其餘（§3/§4）——沒有異議

```
排除舊branch(手抄常數+god-view)判斷對，god-view那條（_parent_needs_food讀母團真值）我沒有
逐行核（你已經核過file:line），先信任你這條，若後續要接回舊branch我會另外驗。
§4四條不變量逐條核過對應A1-A5，扣掉②的洞之外沒有引用了沒套用的情況。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim": "A5：未觸及的任務型別(非FORAGE)全世界指紋逐字相同",
     "file_line": "faction_ai_system.gd:3904-3980（_evaluate_subteam 分支列舉）、spec §5 A5",
     "truth": "8個task/reason組合(HERALD-envoy/SCOUT-info/MIGRATE/BUILD/CONSTRUCT族/CONVOY/SETTLE/ESCORT)才是真正未觸及；其餘20種task型別(TRADE/DIPLOMACY/JOIN/GOVERN/FLEE/ATTACK等)全部落在3972那個blanket裡，修法會直接改變它們的行為，不是FORAGE專屬。A5的『非FORAGE=未觸及』前提是錯的"},
    {"claim": "A1-A4驗收範圍等於修法的實際範圍",
     "file_line": "spec §5 A1-A4（tap均為merge.forage_blanket_evicted/subteam.forage_arrived，FORAGE專屬）",
     "truth": "修法code範圍是『任何落到3972的task型別』(至少20種)，驗收tap只蓋FORAGE一種，未驗證覆蓋率遠小於實際影響面"}
  ],
  "note": "①的magic number建議錨定測量基線+靠A4扛真正鑑別力，不必再挖。③CONSTRUCT/UPGRADE/EXPAND是同型同病，該具名列出不該匿名列六個return。②是這輪主要issue：範圍聲稱(FORAGE)跟code實際範圍(20+種task型別共用同一個blanket)不一致，加上merge_queue全域共用list的間接波及層(1315/1377)，兩層一起讓A5前提站不住。建議把②拆成b1(窮舉真實受影響task型別清單)/b2(裁決A1-A4驗收要不要跟著擴大或誠實限寫明不驗)/b3(merge_queue排序敏感性——commutative與否)三個獨立問題明寫進spec，不是合併成一句『A5可能紅』帶過。這個裁範圍的活是WHAT/HOW的,我只負責把洞挖出來、把file:line釘住，不代裁。" }
```
