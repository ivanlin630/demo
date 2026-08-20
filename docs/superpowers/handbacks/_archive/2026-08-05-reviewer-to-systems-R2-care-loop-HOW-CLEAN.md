---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2必查項] 領主主動照護loop HOW——★必查項①holding『refresh-not-resolve』語意跟_step_contact_ledger既有迴圈結構衝突:親讀feat/missing-contact-ledger branch尖端_step_contact_ledger(faction_ai_system.gd:4697-4719)確認現有邏輯是『未逾時→append進kept續留/逾時→fire reaction+entry[resolved]=true+★不進kept』,最後team.dispatch_ledger=kept——這代表任何一筆一旦逾時觸發反應就會被永久丟棄,對herald/scout/convoy(一次性派出)是對的行為,但holding要求的是『查完後繼續監看、刷新非丟棄』,若不特別處理,領主check完一次自家村後這筆holding監看記錄就從ledger消失,除非有別的機制每次都重新補建——spec提到的『or lazy:_step_contact_ledger對自家faction holding補建』如果真的每tick對『目前沒有entry的holding』重新造一筆,邏輯上能繞過這個問題但這是我從字裡行間推出來的,spec沒有明講到底靠這個機制解決還是要改_step_contact_ledger本身讓holding kind特殊處理(查完refresh dispatched_tick放回kept非丟棄);要求implementer/systems在動工前把這個機制講清楚,兩條路都可以但要選一條寫清楚非留給implementer自己猜;★必查項②(這輪最高風險項)新firsthand觀察write函式的呼叫位置必須鎖在_tick_info_scout既有的if scout.tile_pos==target.tile_pos co-location分支『裡面』,不能變成一個外部/獨立可呼叫的函式——這是避免重蹈distribute-descan那輪抓到的_resident_food_runway直接讀resident.population/food的god-view覆轍的唯一防線,兩者讀的資料類型幾乎一樣(食物/人口),差別只在有沒有物理co-location gate,若這條防線沒守住這個新機制在本質上就是換個包裝復刻剛修好的違規,要求merge-gate那輪逐行核對呼叫點位置;care/ignore competing argmax結構跟已驗證過的react_util四類同款模式,結構上信任;distribute reuse/holding逾時偵測沿用共享_contact_elapsed_days/零死常數程度界線皆親驗合理;CLEAN+2必查項→dispatch implementer"
---

# R②判決：領主主動照護loop HOW — CLEAN + 2必查項

## Seam——親驗坐實
四塊reuse的既有件（`dispatch_ledger`/`_ledger_record`/`_pick_contact_reaction`/`_try_scout_side`/`_try_distribute_side`/`_distribute_candidates`/benefactor write）皆是本session這個大arc（失聯帳本/勢力凝聚力）前幾輪已經逐行審過、親驗坐實的機制，這輪不重複驗證這些底層件本身，聚焦在這次「新拼法」有沒有問題。

## ★必查項①——holding「refresh-not-resolve」語意跟`_step_contact_ledger`既有迴圈結構有真衝突，需要明確機制交代
這是這輪我花最多力氣查的地方。親讀`feat/missing-contact-ledger`branch尖端`_step_contact_ledger`（`faction_ai_system.gd:4697-4719`）：

```
for entry in team.dispatch_ledger:
	if resolved: continue   # 已清帳 → 丟棄（不進 kept）
	...
	if overdue_ratio <= 1.0:
		kept.append(entry)   # 未逾時 → 續留
		continue
	# 逾時 → fire reaction
	_apply_contact_reaction(state, team, entry, react)
	entry["resolved"] = true   # ★逾時觸發反應後直接標resolved，不會進kept
team.dispatch_ledger = kept
```

**這個迴圈的結構是：一筆entry一旦逾時觸發反應，就會被永久丟出`dispatch_ledger`**（因為只有「未逾時」跟「resolved前」兩種情況會進`kept`，觸發反應的entry兩者都不是）。對herald/scout/convoy這種「派出去一次、事情辦完就算了」的性質完全正確——逾時了、反應完（再派/防禦/救援/註銷），這筆帳自然結案丟棄。

但holding要求的是**相反的語意**：領主對自家村的監看是**持久的**，查完一次（`check`反應派scout去看）不代表監看關係結束，理論上下次還要繼續倒數計時。**如果holding kind直接套用現有迴圈**，領主check完一次自家村之後，那筆holding監看記錄就從`dispatch_ledger`裡永久消失了——除非有別的機制每個tick重新幫這個村補一筆新的holding entry。

spec文字寫「記帳點：...**or lazy**：`_step_contact_ledger`對自家faction holding補建」——這句話讀起來像是想靠「每tick檢查『這個faction自己的holding有沒有entry、沒有就補一筆』」這個機制去繞過上面的問題（等於每次查完，下一tick被重新造一筆全新的、重新起算的holding entry，效果上約等於refresh）。這個做法邏輯上說得通，但**spec沒有明講到底是靠這條lazy補建機制解決、還是要另外改`_step_contact_ledger`本身讓holding kind特殊處理**（查完後refresh `dispatched_tick`塞回`kept`而非丟棄，兩種kind分流處理）。

**要求**：implementer動工前，systems要把這個機制講清楚並寫進spec或commit——兩條路都可以（(a)lazy補建全靠每tick重新造entry、確保「查完消失了但下tick又補回來」在邏輯上等價於refresh；(b)`_step_contact_ledger`對holding kind特殊處理，查完reaction後refresh `dispatched_tick`塞回`kept`而非設resolved丟棄），但不能沒講清楚就讓implementer自己猜——這種「一筆帳該不該丟」的細節如果猜錯，會造成「領主第一次check完自家村之後，就再也不會被提醒去查這個村」這種靜默失效，非常難在一般跑測時被發現（因為第一次check的行為表面上完全正常）。

## ★必查項②（這輪風險最高項）——firsthand觀察write函式的呼叫位置必須鎖死在既有co-location分支內部
這是我認為這輪**唯一真正有god-view風險**的地方，必須在merge-gate那輪逐行核對，這裡先把要求寫清楚。

這次要新建的「scout抵村firsthand讀food/pop/困頓」機制，讀的資料類型（村的食物存量、人口）**幾乎跟`distribute-descan`那輪(本arc更早幾輪)我抓到、後來被修掉的`_resident_food_runway`直接讀`resident.population`/`ResourceSystem.effective_food(state, resident)`的god-view違規一模一樣**——差別只在一個關鍵點：**有沒有物理co-location gate**。`_resident_food_runway`的違規是「領主的決策函式，無視物理距離，直接伸手讀任何一個居民的即時狀態」；這次新設計的合法性完全建立在「scout必須真的物理走到那個村（`scout.tile_pos == target.tile_pos`）才能讀」這個前提上——spec自己也這樣寫（「＝現行S-scout tick的firsthand read**擴**」，暗示是在既有co-location分支裡加邏輯，非另開一個函式）。

**要求**：這個新的觀察write函式，實作時**必須**寫在`_tick_info_scout`既有的`if scout.tile_pos == target.tile_pos:`分支**裡面**，不能變成一個外部可以獨立呼叫、不受co-location約束的函式（哪怕現在只有這一個呼叫點，未來如果被其他地方也拿去呼叫，防線就破了）。這條防線沒守住，這個新機制在本質上就是換個包裝、復刻一次剛剛才修好的違規——merge-gate那輪我會逐行核對呼叫點位置跟有沒有任何`state.teams[id].food`/`state.teams[id].population`這種鏈式直讀殘留，非只看有沒有god-view detector跳。

## care/ignore competing argmax——結構信任
`care_util`/`ignore_util`兩類competing argmax，跟本arc已經審過兩輪（失聯帳本原始4類react_util、以及defensive/rescue真consumer那輪）的結構完全同款——這個pattern（dict存各候選util、迴圈找max、禁if/elif）已經被我反覆驗證過是這codebase這個family的正確寫法，這輪不需要重新質疑結構本身，只需要build完之後confirm沒有退化成分支判斷（同上輪的必查慣例）。

## distribute reuse/零死常數/程度界線——親驗合理
`_try_distribute_side`/`_distribute_candidates`零改動、只多一個belief來源——這個「不新建賑濟機制」的claim跟spec文字一致，不需要新的util公式。零死常數（無「逾時X必派」，理不理走care/ignore util秤）跟「非保姆國家」的程度界線（無天眼、無自動補滿、結果分化）在spec文字裡守住，跟WHAT的`★程度界線`要求對得上。

## 判決
**CLEAN + 2必查項（holding refresh機制需明講；firsthand觀察write呼叫位置鎖死co-location分支，merge-gate逐行核對）→ dispatch implementer（`feat/lord-care-loop`）→ 量cohesion①natural真考 → QA → merge。** 這輪最大的價值是抓到「refresh-not-resolve」這個新語意跟既有`_step_contact_ledger`迴圈結構的潛在衝突（spec文字沒完全講清楚靠哪個機制解決），以及重申firsthand觀察write絕對不能鬆動co-location這道防線（這正是P4缺口被填補的合法性根基）。兩項都非阻塞spec鎖定/dispatch build，但必須在build階段被正面回答，merge-gate那輪我會針對這兩點重點複查。
