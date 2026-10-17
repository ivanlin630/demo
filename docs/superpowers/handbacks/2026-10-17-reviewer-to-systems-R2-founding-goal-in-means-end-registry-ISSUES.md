---
from: reviewer
to: systems
status: consumed
slice: 開點登進既有長程目標表
topic: R² VERDICT＝ISSUES（must-fix 7 條；六個請看的點逐一答在 §二）。不 dispatch。
---

# 一、判定
**ISSUES。** 方向（目標表一列、四條路收斂、秤同呼）我沒有異議；擋住派發的是下面 7 條，其中 M1、M2 是「照現在寫會讀到相反結果」的結構問題，不是措辭。靜態讀 code，沒跑測試。

# 二、六個請看的點

## 點 1：§四的靜態推論 — ✓（但有一個漏洞）
- `_dispatch_builder` 呼叫者：產品碼只有 `faction_ai_system.gd:5889`、`:6559`（全庫 grep；其餘都在 `scripts/debug/`）。
- `:5889` 只在 `td.has("build_type")` 時進（`:5885`）。`"build_type"` 當 to_task 鍵的產生處只有兩個：`options.gd:379-380`（擴點）、`goal_resolver.gd:1174-1175`（③）。`_delegate_variant` 包的是 TASK_BUILD／SETTLE 自候選，擴點本身已是 delegate ⇒ `goal_resolver.gd:560` 早退；紮根與「建設／自救建田」的 to_task 沒有 build_type ⇒ 它們的變體走 generic 分支（`:5902-5911`），不進 `_dispatch_builder`。
- 擴點 applicable＝`can_expand`，要 `team.population >= 12`（`decision_context.gd:901-903`），與派遣端門同值（`:5585`）⇒ 擴點本身擋不到人數門。④ `_evaluate_infrastructure`（`:6466-6482`）只擋 null／戰鬥／玩家，沒有人數檢查。⇒ pop ≤ 3 的人數門嘗試只能來自 ③ 或 ④：**成立**。
- ★漏洞：④ 的 `leader_team` 是**勢力領隊那支隊**（`faction.leader_team_id`），不是「各隊自己」。pop ≤ 3 的 13 支隊裡有多少是「小勢力的領隊隊」，量測沒拆，我也讀不出。這影響 §五：④ 刪掉後，勢力層「由領隊隊替全勢力選一格」變成「每支隊各自選」——見 M5。

## 點 2：`FoundingCrew.plan` 對 n 取最大 — 部分 ✓
- `baseline_daily(n)` 能取代「剩 10 人」這個**經濟**意義，取代不了**非經濟**的部分：`_inflow_est` 只算產糧（`decision_context.gd:909-911`），不含守備、孩童（`minor_population`）、派走者的糧（見 M2 食物閘）。你在 §四寫「秤自己會停」只在經濟項對 n 凸時成立；我讀不出它對 n 是凸還是近線性（`VillageEstimate.make` 的人口上限在別檔），**這一點請 F8 用「母隊 pop 20/40/80 各一支、印 argmax n」直接答，不要只印分布**。
- 1–3 人被推去派 1–2 人：你已誠實限，不另判。但注意 `crew ∈ [1, pop−1]` 讓 pop=2 的隊派 1 人、母隊只剩 1 人（沒有任何人可當下次的帶隊人）——下一輪它回到 `no_crew`，不會死循環，OK。

## 點 3：退掉「紮根」兩支 — ✗，見 M1（這不是量出來才知道的）

## 點 4：感知 — ✗，見 M6

## 點 5：F9／m8 — 部分，見 M7

## 點 6：§一對 HOW §9 的改寫 — 成立，附兩條件
- 成立的部分：慾望可以有對象；`target` 欄今天就在（`goal_resolver.gd:36`、`:106`），沒有讀者假設恆 null（R① P8）。
- 條件①：`value`（以及 `type`、`level`）是**算出來的評估**，不是慾望。`commitment_fields.gd:28` 的 `expand_site_cached` 就被分類成「cadence 快取（評估結果），不是已開始的工作」。⇒ 要嘛只存 `target`＋`type`，`value` 每次重算（`replaced` 用「新最佳格 vs 重算後的舊格」兩個當下值比，不需要存舊值）；要嘛 `value` 欄在註解與 `commitment_fields` 裡明寫為快取。照現在寫成 goal 元素的一個欄位，會把「慾望層」註解（`commitment_fields.gd:34`）改成一句同時涵蓋慾望與快取的話——這正是 §9 要擋的混層。
- 條件②：`state_fingerprint.gd:398` 用 `_arr_canon(t.goal_state)`；元素裡塞 `float value` 和 `Vector2i` 時，fp 是否量化要看 `_arr_canon` 對 float 的處理。我沒追進去；請實作端在 F1 加一條「同 seed 兩跑 fp 相同」（world-fp 本來就要印新舊，這條是它的前置）。

# 三、must-fix

## M1（結構）紮根兩支退場＝絕境隊結構性失去紮根，且「停下回報」那道不是守衛是必然事件
- 事實鏈：
  - 候選 util＝`GOAL_UTIL_CAP × x/(1+x) × dev_coeff × discount`（`goal_resolver.gd:1633`），`dev_coeff = food_days / DESPERATION_DAYS`（`:1611`，`DESPERATION_DAYS = 3.0`，`terms.gd:37`）。food_days 趨 0 ⇒ 目標候選 util 趨 0（這是 `:1610` 註解寫明的設計：「絕境→0 讓 survival 奪 argmax」）。
  - 紮根在 survival 集（`options.gd:337`），絕境時吃 `SURVIVAL_BOOST_MAX × (FLOOR−food_days)/FLOOR`（`decision_engine.gd:381`，最多 +2.5）。
  - `options.gd:338-339` 已經寫了：拿掉它「＝絕境隊結構性沒紮根選項＝隱含硬門檻」。
  - ⇒ §五把「站在營地上、走回營地」兩支搬進目標候選後，**food_days < 3 的隊在營地上的開點 util 必然被壓向 0**。這是讀 `:1611` 就推得出的方向，不需要量。
- §五「若明顯變少，停下回報」＝把一個**已知必然發生**的事件當成待觀察的守衛；而且「明顯」沒有判準。依我的守衛清單：expected-red 的守衛不是守衛（它紅了你也只會說「預期內」）。
- 要的修法（我不裁 WHAT）：派發前由你或藍圖在三條裡選一條寫進 HOW——(a) 兩支紮根保留在 survival 集（只退決策端的重複、不退絕境路）；(b) 營地目標的 `found_outpost` 執行候選走 survival 集而不是目標迴圈（util 來源就不是 `_candidate_util`）；(c) 明寫接受絕境隊不再紮根，並要藍圖裁。三條各自的 F8 數字不同，所以要在 HOW 裡選，不是交件後選。

## M2（結構）秤只涵蓋兩道閘；其餘四道仍只在派遣端，且食物閘是 n 的函數
- `_dispatch_builder` 的閘序（`faction_ai_system.gd`）：busy_subteam（`:5544-5551`）→ tile_occupied（`:5553-5556`）→ site_barren（`:5569-5578`）→ no_advisor（`:5579`）→ pop（`:5584-5598`）→ food_bridge（`:5602-5616`）→ dispatch。`plan` 只吸收 no_advisor／pop 兩道。
- 食物閘：`_need_food = pop × FOOD_PER_PERSON_PER_DAY × (_eta_travel + _eta_build) × MARGIN`，`pop`＝派出人數（`:5606-5608`）。n 是秤選的，所以**可行性依賴 n**：秤選 n=8 而食物只夠 n=3 時，候選端說行、派遣端 `funnel.build_gate.food_bridge` 擋——正是你要消滅的「兩端各一份規則」，只是換成食物。⇒ 食物閘必須在 `plan` 的 n 迴圈**裡面**（不可行的 n 直接排除），不能留在派遣端。
- 其餘三道（busy_subteam／tile_occupied／site_barren）不依賴 n，但同樣只在派遣端。後果：目標掛著、子隊在路上的那幾天，每個 decide 週期執行候選照樣被產出、贏、`busy_subteam` 擋、`continue`（`faction_ai_system.gd:4741-4746`）。
- ⇒ 要求：(a) `plan` 或與它同呼的候選端謂詞涵蓋全部六道；(b) 自己已有 CONSTRUCT 子隊在途時不產執行候選（`subteam_ids` 掃描，O(子隊數)）；(c) F9 的「連續失敗最長串 ≤ 1」改成**依 reason 分列**，否則 busy_subteam／tile_occupied 會讓它紅在跟 `plan` 無關的地方，或被你改鬆而失去意義。

## M3（量綱）§二「值同時是 payoff」＋§五「util＝flow_utility 再過護欄」＝雙重正規化與雙重折現
- `flow_utility` 回的是 `value / pv(daily_need)`（`discounted_flow.gd:112`、`:122`）——已除過一次該隊的日需；且 `delay_days` 已進 `wait_mult = d^delay`（`:110`、`:120`）。
- `_candidate_util(payoff, ctx, delay)` 收的是**食物單位的 payoff**，內部再除一次 `_unit = pop × 每人日糧 × 單價`（`goal_resolver.gd:1630-1632`），再乘 `discount = 1/(1+rate×delay)`（`:1613`）。
- ⇒ 把 `flow_utility` 當 payoff 餵進去：正規化兩次（量綱錯，隨 pop 偏移）、delay 折兩次（d^delay 與 1/(1+rate·delay) 疊乘）。這跟 `_row`／`derived_payoff` 的單位也對不上。
- 要求：HOW 寫明走哪一條——(a) 餵 `_candidate_util` ⇒ payoff 取未正規化的 `pv(gain)−pv(base)`（食物單位）、delay 只在 `_candidate_util` 折一次；或 (b) 直接用 `flow_utility` 的值且**不經** `_candidate_util`，但那樣 `GOAL_UTIL_CAP` 的單調壓縮與 `dev_coeff` 都要另接。我傾向 (a)（`_candidate_util` 是 `gu2.*` 探針的單一收斂點，`:1618`）。
- 同源問題：`replaced` 的 `value ≥ 舊 value × (1 + PERSIST_CAP)`：`PERSIST_CAP = 0.3`（`persist_strength.gd:15`）是「持守的 **util 加成** 上限」，不是相對倍率。拿它當 ×1.3 的遲滯＝同名常數、不同量綱，且實際上是新立的一個門檻。要嘛標成 TEST VALUE 新常數並說明來歷，要嘛改成用 `PersistStrength` 既有的函式給偏置。「不另立門檻」這句不成立。

## M4（生命週期）`site_taken`／`built` 會把自己的子隊誤判成別人
- `begin_subteam_construction` → `start_build(state, team=子隊, …)`（`outpost_system.gd:1052`），`tile.construction_team_id = team.team_id`（`:811`）＝**子隊 id**，不是母隊。註解 `:1041` 寫明「子隊自身成為 owner」；`_dispatch_builder` 給的 `task_extra_data` 沒有 `owner` 鍵（`faction_ai_system.gd:5626-5628`）。
- ⇒ §二重驗：`site_taken`（「別隊在施工」）在自己的子隊抵達開工那一刻成立 ⇒ 目標被當成被搶而退；`built`（「目標格成了自己的據點」）在落成時 `outpost_owner` 是子隊，不是母隊 ⇒ 不成立。五事件的對帳式仍然加得起來（所以 F5 不會紅），但**事件是錯的**——本質是「對帳式只證明沒漏算，不證明歸類正確」。
- 要求：「自己的」＝`team_id` 或 `team.subteam_ids` 內（含在途與施工中）；`built` 的判準寫成母隊親緣的謂詞（已有的單跳謂詞，`outpost_system.gd:1061-1064` 那段註解在講同一件事：不得再手寫 owner == parent_team_id）。F5 的 `site_taken` 與 `built` 各加一個「自己的子隊在施工」的反例格（該走 `kept`）。

## M5（範圍／成本）掛的母體未限定；選址是 O(tiles)，今天它被節流到勢力層
- `ensure_maintain_goals` 對每支隊都跑（`decision_engine.gd:102`，無 subteam／玩家過濾）。§二「每隊最多一筆」未說哪些隊。含：建造／運補子隊（`parent_team_id != -1`）、玩家領隊的隊。擴點明確排除玩家（`decision_context.gd:886`）；`found_outpost` 若不排除，玩家隊會被掛目標、產執行候選。
- 成本：`_evaluate_new_outpost_location` 全圖掃 tiles，內層再掃 centers（`faction_ai_system.gd:6167-6209`）。今天 ④ 每勢力每 INFRA_INTERVAL 一次；② 每隊但被 `has_own_outpost ∧ idle_labor>0 ∧ advance` 擋並快取（`decision_context.gd:886-897`，註解 `:887-891` 記了它是為了壓 500-tick infra 尖峰）。§二每隊每 3 天一次、無那三道前置 ⇒ 次數放大。HOW 沒有 perf 驗收。
- 另：④ 的選址以勢力為單位（領隊隊替全勢力選一格，`centers` 含全勢力據點），收斂後每支隊各選、各掛、可能同選一格；`tile_occupied` 只在子隊**抵達**才有值（`:5553-5556`、`outpost_system.gd:811`），在途期間同一格會有多支子隊。
- 要求：(a) HOW 寫明掛的母體（建議至少排除 `parent_team_id != -1`、玩家領隊、無領隊人；我不裁，請你定）；(b) 選址結果走既有的快取形狀（`expand_site_cached` 的 cadence＋advance 閘，`commitment_fields.gd:28` 已分類），不在 `ensure_maintain_goals` 裡每隊重掃；(c) 驗收加 HOB perf 比對（`reference_hob_perf_protocol`）與「同目標格並行派出數」（F8）。

## M6（感知）「不讀遠端真值」這句事實錯誤
- §二寫「選址秤與 `site_prior` 讀的是隊自己知道的格與地形先驗，不讀遠端真值」。
- `_site_resource_bonus` 對候選格及六鄰直接讀 `ntile.resources`（現存量）與 `ntile.resource_cap`（礦）（`faction_ai_system.gd:6235-6243`）——遠端格的**當下存量**，不是先驗。整個 tiles 迴圈有 `# gate-ok: legit-geo` 標記（`:6167`、`:6188`），標的是「掃 tiles 讀地形」，不涵蓋 `:6240` 對 `resources` 的讀。`site_gather_days` 那條才走 `site_prior`（`:6204`，結構輪已驗）。
- 這不是要你現在修選址秤（它是既有 code），但：(a) spec 這句要改成事實（列出 `resources`／`resource_cap` 兩讀，各標是否屬 legit-geo 由藍圖／憲法閘判）；(b) 這一列把該讀值的使用範圍從「勢力領隊每 INFRA_INTERVAL 一次」放大到「每支掛目標的隊」，上了遠端存量資訊的外流面；交件信的「讀到的遠端量各標來源」（你已列）要先寫出這兩項。

## M7（守衛）F9／m8 會恆綠，且 m8 在電池上不保證紅
- F9「`crew.*` 加總 = 0」：沒有任何建點嘗試時也是 0 ⇒ 空洞綠。要加進場計數器（`dispatch_builder.attempt` > 0 ∧ `plan` 呼叫次數 > 0，兩端各一顆）。
- m8（候選端不呼 `plan`）要紅在 `crew.* > 0`，前提是電池世界裡真有 pop=1 的隊走到建點。量測顯示戰國有（257 次，pop 全 1），但那是修前的路徑；§五把 ③／④ 退場後，pop=1 的隊是否還會被目標迴圈產出執行候選取決於 M5 的母體——母體若排除了小隊，m8 在電池上根本沒有人觸發。⇒ F9 另造**單隊構造床**：一支 pop=1、一支 pop=3、一支 pop=40；斷言「候選端有／無候選」與「`plan.ok`」逐支一致，且注射 m8 時 pop=1 那支紅在 `crew.no_crew`。電池版 F9 留作補充。
- 連續失敗串 ≤ 1 見 M2(c)。

# 四、小項（不擋，但請併進同一輪）
- S1 F6 的「全庫 grep 擴點 option 0 處」會撞既有床：`expand_bigvillage_bed.gd`、`settlement_s4b_test.gd`、`means_end_a1/s3/s4_test.gd`、`headless_test.gd` 都在讀或呼 `can_expand`／`expand_*`／`_dispatch_builder`（本審 grep 結果）。HOW 要列「這些床遷到哪」，否則 merge-gate 會先紅在舊床而不是 F6。`failure_memory.gd:100` 的 `"擴點"` 鍵也要處理。
- S2 §三 `new_outpost_commitment` 第三種「goal」：goal 掛著但**尚未選定**（`target` 尚無、或 `wait_material`）的隊，`need_keep(material)` 多出整筆成本，這就是設計。但同一隊在「goal 掛著＋子隊在途」時，母隊的 `goal` 與子隊自己的 `walk` 會各自對同一座點算一次（母隊走 goal 分支、子隊走 walk 分支）。兩者是不同隊的帳，不是同隊重複；但**母隊料已撥給子隊後**（`_fund_subteam_from_vault`）母隊仍把整筆成本算進 `need_keep`，會去買第二份。⇒ 母隊有在途 CONSTRUCT 子隊時，`goal` 這一種應回空（與 M2(b) 同一個謂詞，抽成一支共用）。
- S3 `goal.found.*` 五事件互斥性：`replaced` 與 `site_taken` 同時成立時的優先序要寫出來（對帳式在重複計數時會多一個，在優先序未定時會少一個歸屬）。
- S4 §五 `target` 是自己營地時走 `TASK_BUILD`＋`settle_site`（紮根的身體）；其 `try_set` 會把 move_target 設成目標（`task_arbiter.gd:98-99`），站在營地上等於自己；這條路徑照舊，我沒有疑慮，列出來是因為 F1 只驗掛上，沒有驗「營地上的隊真的開工」——F2 是有據點版，營地版缺一格。

# 五、我確認過的（不需動）
- `new_outpost_commitment` 加第三種的位置與下游不改（R① P6 已驗；`_new_outpost_need` 與 `new_outpost_urgency` 仍是唯二呼叫者，`need_oracle.gd:238`、`:269`）。
- 「沒據點的隊照跑目標迴圈」成立（R① P2）；`found_outpost` 不讀 `otile` 即可。F1 要求的進場計數是對的。
- 升人移到最後（F7）方向正確：`_pick_or_promote_advisor` 的世界寫入確實在 pop／食物閘之前（`faction_ai_system.gd:5579` vs `:5584`、`:5602`）。

# 六、下一站
M1 需要藍圖或你選一條（我不裁 WHAT）。M2–M7 是 HOW 內的修正。修完回 R²（只審 diff：§二 重驗、§四 plan 的閘集、§五 候選條件、驗收 F1/F5/F9）。
