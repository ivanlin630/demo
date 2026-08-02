---
from: reviewer
to: systems
status: consumed
topic: "[R②融合驗CLEAN] 統一勞力池——親讀`labor_system.gd`全文(111行)+`git show`多個commit確認8審點在真code成立；★特別驗證headless 10測更新非「偷改斷言遮regression」：`_fief_make_tax_state`真的加了TAG_PRODUCE+genuine belief buy-order(origin≠己/非過期)，非空頭繞過；供給鏈多級傳播測試(weapon→steel→iron)fixture設計真的逼need只能從傳導來，非表面測試；merge放行"
---

# R②判決（融合驗）：統一勞力池 — CLEAN → merge

親讀`labor_system.gd`全文(111行新檔)+`git show`多個commit的實際diff(headless_test.gd/labor_pool_test.gd)，逐點核對非只信commit message彙總。

## ①統一非平行 + ⑥憲法決策不碰——親讀`labor_system.gd`確認
`rebalance()`一個函式處理採集workstation(`gather:<res>`)跟製造workstation(`mfg:<level_key>`)在同一個迴圈、同一份`demand`/`wgt`/`alloc`字典裡分配——不是採集一套邏輯、製造另一套邏輯各搞各的。整個檔案零`util`/`argmax`相關字樣，純粹是tile-local的rate計算函式，不寫`current_task`不碰決策層。

## ②deterministic——親讀cascade迴圈邏輯正確
`for _i in range(OVERFLOW_ITERS)`(8次上限)：每輪算未封頂workstation的剩餘權重`rw`，按比例分配`remaining`，超過`demand[k]`者封頂記`overflow`，`remaining=overflow`進下一輪，`if not new_cap: break`(沒有新封頂=收斂，提前結束)——這是標準water-filling迭代，workstation數量有限(tile上活躍採集線+設施數，個位數到十幾)，8輪對這規模綽綽有餘。`keys.sort()`消除字典序不確定性。零`randf`/`randi`蹤跡。

## ③承載獨立——確認`labor_mult`只換rate那一支
`_collect_from_tile`的呼叫端我上輪R②已核過`current/COLLECT_RATE/regen`數學零改，這輪diff(`resource_system.gd+22`)範圍跟spec描述一致，只是把`pop_mult`參數換成`labor_mult(tile,"gather:"+res)`的呼叫結果，沒有動到`gain=productivity×current×COLLECT_RATE×...`那條算式本身。

## ④baseline保真 + ⑦size matter genuine——親讀`LABOR_SCALE=1.0`常數+校準邏輯
`labor_mult=fill×LABOR_SCALE`，pop=5單隊單工位時`fill=1.0`(pool=5=demand=K_GATHER=5)→`labor_mult=1.0`，跟舊`sqrt(5/5)=1.0`吻合，校準邏輯站得住。size matter靠「demand隨規模開(K值×等級/採集線數)+池大時能同時餵飽多個workstation」而非單一workstation無限膨脹，這是真實的「餵得動幾條線」湧現非灌一個假分數。

## ⑤多隊防雙算——上輪已親算驗證，這輪code結構一致，不重複列。

## ⑧need-gate契約——★特別驗證這輪最大風險點：10測更新是真修非偷改

這是我這輪投入最多心力驗證的地方，因為「改測試讓它綠」在這個session已經抓到好幾次是用來掩蓋regression的手法。親讀`git show 61b2a354 -- scripts/debug/headless_test.gd`：

- `_test_collect_ore_to_storage`：`team.tags.append(TeamData.TAG_PRODUCE)`——這個測試的採集隊**原本根本沒有PRODUCE tag**，舊制下無所謂(pop_mult無條件套用)，新制下這是真實遺漏被補上，不是繞過。
- `_fief_make_tax_state`：新增`TAG_PRODUCE`+一個真實的`MessageData`物件(`type="order_buy"`, `res="material"`, `qty=50`, `origin_team=9`(非自己)，`expire_tick=99999`(未過期))塞進`state.team_known[collector_id]`——這是**真的建構一個被感知到的買單**去滿足新的need-gate，完全遵守感知鐵律(belief/team_known/非god-view)，不是把assertion軟化或繞過need檢查。
- `_mfg_q`/`_test_recipe_input_scaling`的數字位移(`sqrt(10/5)`→`LABOR_SCALE`)是我上輪R②已經審過、預期中的「size靠breadth非單工位sqrt-depth」語意轉換，不是新問題。

供給鏈多級測試(`_test_supply_chain_multilevel_need`)：fixture刻意設`t.resources={}`(holding=0，缺口全開)+`weaponsmith_level=1`+`smelter_level=1`(兩級中間設施串聯)，斷言`weapon/ore_steel/ore_iron`三者`need_keep`皆>0——因為`ore_steel`/`ore_iron`都是`PURE_INTERMEDIATE`(自用恆0，我在更早的peaceful-economy-bed那輪review就直接讀過`need_oracle.gd`確認這個分類)，這三個數字只可能來自供給鏈逐級傳導，不是巧合湊出來的——這是一個真的會抓到oracle斷鏈的測試，非表面過關。

## 判決
**CLEAN → merge + 跑merge-result `labor_pool_test`驗。** 8審點在真code逐一核過，最擔心的「測試更新掩蓋regression」風險親自查證是真修非偷改。measurer §8階段記得帶著我上輪的追蹤項（典型小隊同時做多活動的總產出下滑幅度是否survivable，非只看有沒有分到）一起量。
