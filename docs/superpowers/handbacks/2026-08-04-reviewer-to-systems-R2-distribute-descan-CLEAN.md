---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+★1嚴重追蹤(非阻塞這次fix)] distribute de-scan——①god-view live-read親驗坐實真存在且比claim更值得警惕:goal_resolver.gd:204-211 _resident_food_runway直讀resident.population/minor_population/ResourceSystem.effective_food(state,resident)三個live動態欄,跟同檔:122-123舊comment『intra-faction自有居民deficit=合法非god-view』的自我辯護矛盾,這個舊辯護正是用戶後來在資訊網arc明確否定的『領主直掃』;★親查constitution_gate.gd:40 GV_TEAMSTATE_RE正則只認字面state.teams[id].field這個pattern,這段違規是先state.teams[rid]存進區域變數resident再隔幾行读resident.population=完全不會命中正則+親查constitution_baseline_v2.txt全檔零_distribute_candidates/_resident_food_runway/goal_resolver相關entry=證實這不是『先前審過標legit』而是『從沒被抓到過』的detector盲點,非這次修法牽連範圍但值得系統性追一輪同款pattern；②死常數DISTRIB_DEFICIT_DAYS門檻閘親讀:169確認真是硬continue閘非連續weigh；③is_resident_static(faction_ai_system.gd:503-513)親驗只讀tags/outpost_owner/outpost_level結構性欄位零live動態態,belief-sourced relief換源後applicability仍乾淨；④calibration DISTRIB_RELIEF_NORM同款錨真值紀律追蹤(非阻塞)；CLEAN→build續feat/info-network-whole→re-measure症1端到端"
---

# R②判決：distribute de-scan（arc最後一哩）— CLEAN + ★1嚴重追蹤（非阻塞這次修法）

## ①god-view live-read——親驗坐實，且比claim描述的更值得警惕
親讀worktree `goal_resolver.gd:204-211`：

```
static func _resident_food_runway(state: WorldState, resident: TeamData) -> float:
	var pop: int = resident.population + resident.minor_population
	...
	return ResourceSystem.effective_food(state, resident) / burn
```

這確實直讀`resident`(另一個team)的**live population**（`population`/`minor_population`）跟**live food庫存**（`ResourceSystem.effective_food`）——不是belief/message，是決策當下即時查詢對方team的動態即時狀態。這個claim坐實。

**更值得警惕的是**：同檔`:122-123`有一段**舊comment**寫「★感知鐵律:讀本勢力自有居民deficit=合法(intra-faction自有後勤態非god-view)」——這是原作者當初自己給自己的正當性理由。這次spec的定性剛好相反：「正是用戶否定的『領主直掃』」。這不是我在挑spec的字面矛盾——是這codebase裡對「同一段code」**先後兩種互斥的官方定性**（舊：intra-faction讀自家居民=合法／新：這正是god-view該死角）。這次de-scan要修正的不只是code，也是把這段舊comment的錯誤自我辯護一起拿掉，否則以後有人重讀那段comment又會覺得「這是既有合法模式」再犯一次——**要求**：implementer動這段時順手把:122-123這段舊comment也改掉，非只刪:168/:169兩行留下矛盾的說明文字。

## ★detector盲點——親驗到這個違規從沒被gate抓過，非「先前審過現在翻案」
親讀`constitution_gate.gd:40`：`GV_TEAMSTATE_RE := "state\.teams\[[^\]]+\]\.(tile_pos|armed|food|coin|population|morale|troops|current_task)"`——這個正則**只認字面上`state.teams[id].field`這個緊鄰pattern**。但這段違規的實際寫法是：`goal_resolver.gd:164 var resident: TeamData = state.teams[rid]`先把索引結果存進區域變數，**隔了幾行之後**在`_resident_food_runway`裡才讀`resident.population`——`resident.population`這個字面字串跟`state.teams[...].population`完全不符合正則的緊鄰要求，**規則語法上不可能命中**。

親查`constitution_baseline_v2.txt`全檔（已標legit的既有god-view讀取白名單）——**完全沒有`goal_resolver`/`_distribute_candidates`/`_resident_food_runway`任何entry**。這證實這不是「這段code之前被gate抓到、審過、標了gate-ok」，是**從頭到尾沒被gate抓到過**——這段god-view live-read活在codebase裡，經過本session這麼多輪(SLICE B分配政策/L1 distribute de-patch/資訊網R①R②多輪)review，包括我自己前幾輪對這個檔案這個區域的多次直接閱讀，都沒抓到，直到這次measurer實測+diagnostic才浮出來。

**這是一個真實的detector盲點**：「先索引存local var、再隔行讀動態欄位」是**很自然、很常見**的寫法（比直接`state.teams[id].field`鏈式寫法更常見），意味著這個codebase裡**可能還有其他地方**用同樣手法逃過gate偵測。**非阻塞這次distribute de-scan**（這次fix正確地把這段違規拿掉，不需要等gate補強才能merge）——但**要求**systems記一筆tracking：找時間對`decision/`跟`faction_ai_system.gd`裡「`var X: TeamData = state.teams[...]`後續讀`X.<動態欄位>`」這個pattern掃一輪（可以是簡單的兩階段grep：先找所有`= state.teams[`賦值，再對賦值目標變數名找後續`.population`/`.food`/`.coin`等動態欄讀取），看還有沒有殘留同款盲點。這不是這次spec的責任範圍，但值得系統性看一次。

## ②死常數真移——親驗坐實
`:169 if runway >= DISTRIB_DEFICIT_DAYS: continue`親讀確認是**硬continue閘**（非連續weigh的一部分，是二元篩選）——`runway`來自剛剛確認的god-view read，兩個問題（god-view+死常數）綁在同一行輸入上，一次de-scan兩個都解掉，非各自獨立的兩處修法碰巧同批處理。

## ③is_resident_static——親驗結構性、belief-sourced relief換源後applicability仍乾淨
親讀`faction_ai_system.gd:503-513`：`is_resident_static`只讀`team.tags.has(TAG_PRODUCE)`/`tile.outpost_level`/`tile.outpost_owner`——三個都是結構性/位置性欄位（tag歸屬、outpost等級、outpost擁有者），零動態live欄位（population/food/coin都沒碰）。這個函式繼續留在applicability裡沒有問題，跟god-view live-read是完全不同性質的讀取——這個區分（結構性 vs 動態即時）正是本session一路以來反覆驗證的界線，這裡守住了。

## ④genuine/calibration——延續同款紀律追蹤(非阻塞)
`need_signal = clampf(eff_rem / DISTRIB_RELIEF_NORM, 0, 1)`用buy-order剩餘量(belief已送達的need訊)取代live runway，方向正確——這是「領主憑聽到的信+人格決定要不要救」而非「領主自己去查對方家底」，跟資訊網arc一路建立的belief-only原則一致。`DISTRIB_RELIEF_NORM`是新常數，延續idle-labor/mfg-hub/bootstrap系列已經要求過多輪的calibration錨真值紀律——要求implementer訂值時交代錨定依據（典型food買單量級），非反推「調到剛好讓distribute fire」。

## determinism/economy
零新RNG；`food_surplus`計算(`:137-140`)沒被這次改動碰，reserve守恆不變。

## 判決
**CLEAN + 1嚴重但非阻塞的追蹤項（detector盲點系統性掃一輪；:122-123舊comment順手訂正）→ 回systems → build（續`feat/info-network-whole`）→ re-measure症1端到端（症1真正閉環：letter抵seat→領主聞→distribute憑belief+人格fire→糧真到resident runway回升）→ QA故事稽核。** 這輪最重要的產出是把「這個god-view違規為什麼活到現在都沒被抓到」查清楚——不是先前審查失職放過，是gate正則本身有一種常見寫法會漏抓，這個發現比單純核准這次fix更有價值，值得systems正式記錄追蹤。
