# Known Issues

> 最後更新：2026-07-04 | **本檔只列開放項**。已修項（✅）移 `docs/archive/resolved_issues.md`（保留根因/修法/教訓,可搜尋）。
> 來源：動態測試 + code review + QA harness 遍歷。
>
> ★★★**新條目必帶【狀態】＋【回訪條件】同一行**（回訪＝blueprint 立 2026-09-01；★狀態欄＝systems 裁 2026-09-02）：
> `**狀態：已知未修** ｜ **回訪：<三選一>**`／`**狀態：未確認** ｜ **回訪：量測窗 <哪一輪會確認它>**`
> ／★`**狀態：已知未實裝** ｜ **回訪：觸發事件 <什麼發生時做>**`（blueprint 立 2026-09-02；★★**刻意不做**、修法已知、觸發已定 —— **不是缺陷未修**）
> ★**為什麼是「一行兩格」而不是新增一欄**：新欄會 rot（沒人維護的欄位＝裝飾）；而**回訪條件本來就必填**，
> 把狀態黏在它前面 ⇒ **寫回訪的時候一定會看到狀態**，兩者一起腐爛或一起活。
> ★★**硬規則（可機械檢查）**：**`狀態：未確認` ⇒ 回訪只能是「量測窗」**；★**`狀態：已知未實裝` ⇒ 回訪只能是「觸發事件」**（刻意不做的東西，唯一該回來看它的時機就是那個觸發發生時）——
> 因為能把「未確認」變成別的東西的**只有量測**，寫「到期 token」等於把它擱到沒有人會去量它的地方。
> ★★★**為什麼要有這一欄**：清單的第三軸是「**被確認過嗎**」，而**把【未確認】寫成【已知未修】是在考卷上說謊的溫和版** ——
> 後人會拿它當前提去修一個可能不存在的病。血證：`founding 沉默` 掛了整輪沒人發現它從未被獨立確認過。
>
> ★★★**舊三選一（回訪條件本體）**（blueprint 立 2026-09-01；★三選一，缺則不算合格條目）：
> `回訪：到期 token <slice-id>` ／ `回訪：觸發事件 <某事發生時>` ／ `回訪：量測窗 <哪一輪量測會答它>`
> ★**為什麼**：本檔【沒有到期機制】—— 條目寫下來，而沒有東西在該回來看的時候叫人。
> ★★血證 `:728`：「製造 no-op 混三因」早就記在這裡，而 2026-09-01 有人花了一輪【重新量它】。
> ★★★**存量 132 條的回填 ＝ 排在「清單清零」階段的開場動作**（重錨收章後緊接）—— 不是現在，也不是丟掉。
> **仍有效真 backlog**：Bug2(salary floor 後果)、Bug5(休眠)、W4(NPC promote/train + leader 駐留)、W3(dist tune)。（P5 C-1~C-6 對稱缺口 ✅ 2026-06-16 reframe+實作,見下 P5 段。）
> **圖形 Main.tscn 項 moot**：`run/main_scene = TextUI.tscn` → S5/U5/U6/U7/U8/U9 等 graphical 項凍結,復活圖形 UI 才解。**部分復活（2026-07-04 observer GUI）**：`world_map_view.gd` 現雙用途（observer 分支 + dormant player 分支）,動 player 繪製須顧 observer;Main.tscn 本體仍 dormant。


### ⏳★★`stale-conclusion` 閘蓋好但【故意沒註冊】——真涵蓋率 9.0%（2026-09-03 systems 裁）

**狀態：已知未實裝** ｜ **回訪：觸發事件 — 當 verdict 開始帶 `touches`，且【指名得出 production 路徑】的比例 ≥ 50% 時，把它加進 `docs/process/merge-gates.tsv`（expect `\[STALE-CONCL\]`）**

`.claude/hooks/stale-conclusion.sh` 已完成並自帶 `--self-test`（陽性/陰性對照 PASS），但**不在註冊表裡**。
理由是量出來的：134 顆 verdict 裡 73 顆指名得出 `scripts/*.gd`，★**但 61 顆指名的是【床】，而床不會出現在 production diff 裡**
⇒ **真涵蓋率 12/134 ＝ 9.0%**（盲區 91%）。★★而 9.0% 與我當天拿來否定 `measured_at_commit`（8.2%）的是同一個數量級。
床→production 反查也試過並失敗：**130 張床平均直接引用 0 個 production 檔**（走 `class_name` 不走 `res://` 路徑）。
★**它每次執行都印當下涵蓋率** ⇒ 啟用門檻可觀察，不靠誰記得。詳 `docs/superpowers/specs/2026-09-03-stale-conclusion-expiry-HOW.md` §⑧。

### ⏳★★★4 張【docs 當守衛引用】的床是紅的，而沒有人判過（2026-09-03 systems 掃出，blueprint 裁判序）

**狀態：未確認（★4 張裡 3 張已收官，只剩 ③）** ｜ **回訪：量測窗 — `tracer_completeness_test` 那張「不確定」被判定時**

★★**收官對帳（2026-09-03）**：①`observability_path`＝**治本已 merged**（跨 run 靜態清除點；跨輪命中 **72→0**）／
②`seam1_registry`＝**修好 MERGED**（fixture 補 `threat_pos`／`flee_dest`）／④`unified_commerce`＝**修好 MERGED**（給買方真需求，**不是放寬斷言**）／
③`tracer_completeness`＝★**仍「不確定」，誠實掛著**。
★★★**而兩張修好的床都通過陽性對照，且【弄壞的是被守的機制不是 fixture】**
（`survival.applicable` 改 `return false` ⇒ seam1 2 FAIL；`_market_visitor_buy` 插 `return false` ⇒ unified_commerce 12 FAIL）
⇒ **那才是「床咬得住」的證據** —— blueprint「用時付費」制的第一批兌現。

★★**綠床規則已立法（blueprint「用時付費」）**：預設 **「綠＝未知」**；陽性對照**不做全掃**，綁兩個自然時點 ——
**(a) 床要註冊進閘時**（寫進 `docs/process/merge-gates.tsv` 表頭）／**(b) 床被引用為結案／驗收證據時**
（寫進 `docs/process/01_architect.md` 銷案表：★**沒對照過的綠床不配當證據**）。

★★**四張判定**：①`observability_path`＝**床有缺陷**（tracer 無罪；成因 `goal_resolver.gd:492` static 跨 run 不清）
★★★**①的降級處置已【解除】（2026-09-03 當日，量掉的）**：原本標「byte-identical 的證明力受【共享 `_path_cache`】折損」，
而 implementer 用**差額法**量掉了它 —— **不必記鍵：把第二輪跑兩次（一次不清快取、一次先清），差額就是跨輪命中**：
```
第一輪（全新快取）  hit=195 miss=127
第二輪（不清快取）  hit=267 miss= 55   ←★跨輪命中 = 72 ⇒ ★★母體【不是空的】
第二輪（先清快取）  hit=195 miss=127   ←★與第一輪逐數相同 ⇒ 決定性沒問題
★★★而【清了快取】world sig 仍然逐位元相同
```
⇒ **理由升級**：★**不是「快取沒作用所以看不出差別」，是「快取確實作用了 72 次，拿掉之後世界仍逐位元相同」。**
★**殘留一格（不是疑慮，是排定的補證）**：上述量在**等價的臨時床**上做，`observability_path_test` **本身**在 `_path_cache` 修完後會重跑一次。
★★**副產物**：**72 成為 `_path_cache` 修法驗收②的【修前基準】** —— 修完同床同 seed 重跑，該差額**應為 0**。
②`seam1_registry`＝**床過期**（fixture 從沒設 `threat_pos`，該閘 2026-07-20 就 in-main ⇒ 紅比 #10 早六週）
③`tracer_completeness`＝**不確定**（誠實第三態，卡點已寫清）④`unified_commerce`＝**床過期**（`trade.market_bail.buy_no_want=1`，fixture 從沒建立需求）
★★★**而更難的一格**：過期的床有兩種長相 —— **期望值不再成立 ⇒ 紅（看得到）／期望值不再【咬得住】 ⇒ 綠（沒有人會去查一張綠的床）**。
**4 紅裡 3 張過期 ⇒ 這批的 rot 率不低，而那 14 張綠【沒有任何證據】說它們仍有鑑別力。**

```
docs（known_issues/specs/invariants）引用為守衛的床 = 19 張；★在 merge-gates 註冊表裡的 = 1 張（headless_test）
⇒ 跑其餘 18 張：14 綠 / 4 紅，198s ——★這就是「紅床 12 天沒人讀」的機械原因
①observability_path_test   [FAIL] tracer on vs off → 世界+Probe aggregate byte-identical（re-query 包 suppress 不污染）
②seam1_registry_test       [FAIL] applicable 少了 "survival"（team 與 subteam 兩處）★#10 not_in_ranked 的熱 lead
③tracer_completeness_test  [FAIL] commit-fail/heartbeat entry 期望 1、實際 0
④unified_commerce_test     [FAIL] 交易整條沒發生（material 0→0／coin 0→0／庫存沒扣／order 沒被吃）
```
★**①插到最前面**（blueprint）：**儀器信任閘住一切** —— 真紅則今天所有數字都要重看；床過期則一判便知。
★★**判定前，新 verdict 一律加「儀器待驗」誠實限**（已通知 measurer／implementer；★判完由 systems 主動發信撤，不靠人記得）。
★★★**不註冊第 13 道閘**：+198s，且**現在註冊就得把 4 條未判的紅 baseline 掉＝重演同日早上那 7 條 assert 的錯**。
涵蓋率（誠實）：18/19 claimed-guard；★而 claimed-guard 只是「docs 有沒有提到」的代理 —— **另外 116 張 `*_test.gd` 在視野外。**

### ✅（裁為可接受的世界性質，存查）深帶找不到施主 —— **此線收，僅剩一個守衛**（2026-09-03 blueprint 裁）

**狀態：已知未修（★★★重開 2026-09-04：守衛條件【已觸發】）** ｜ **回訪：量測窗 — 那 2 筆交集的成因（哪一階都不 applicable、為什麼）**

★★★**重開理由（blueprint 自己設的條件）**：他裁「**交集非空才重開**」，而 **`peaceful_economy_regime` 90 日跑出【交集 ＝ 2】**
（warring 三 seed 30 日是 0／0／0）⇒ ★**條件成立，此線重開。**
★★**而它正是「舊世界結論清單」要防的那件事**：★★★**原結論量在【無政權 warring 30 日】，而它在【有政權 peaceful 90 日】上不成立。**

★★**守衛結果（2026-09-03，三 seed）**：「**無施主 ∧ 其他階一個都不 applicable**」的交集 ＝ **0／0／0**（分母 **75／68／79**）
⇒ **階梯沒斷：沒施主的時候，總有別的階可用** ⇒ 依 blueprint 裁定，**此線收**。

```
深帶「找到施主」：2.3% ／ 0.5% ／ ★52.0%（seed 1337/42/7）  同 code 同 30 日
不餓的帶(ge5)  ：36.5% ／ 37.9% ／ 39.5%                      ★三 seed 高度一致
⇒ 不餓時一致、越餓越發散 ⇒ 「深帶有沒有施主」是【世界長出來的樣子】不是機制常數
```
**裁定理由（三條既有法）**：①`genuine-depletion` 非 bug（深帶沒施主＝世界長出來的貧，不是機制欠他一個鄰居）；
②**絕境無死路由【階梯】保證，不由【每一階】保證**（乞食只是一階；#12 已量到深帶贏家＝買糧／併入／覓食＝其他階在接手）；
③補上保證施主＝**給世界裝補貼＝scripted**。
★**唯一守衛**：「**無施主 ∧ 無其他階**」交集必須是空的 —— **非空才重開**。
★★**施主可及率留作【世界薄溫度計】進長考卷面（報不修）**，見 `docs/process/09_exam_gate.md §5.4`。
★★★**副產物**：資訊層那條路確定關了（次數 vs 相異集合兩口徑相反，同一個「少數隊每 tick 重掃」）。

### ⏳★★`FORAGE_VIABLE_POP` 一個常數承載【兩個不同意圖】⇒ 不可分別調、也不可分別觀測（2026-09-04）

**狀態：已知未修** ｜ **回訪：觸發事件 — 有人要調 `FORAGE_VIABLE_POP`（或量到「pop 那一半在擋人」）時**

```
用處①`options.gd:57`（覓食 applicable）：pop ≤ 15 才 applicable —— ★意圖＝【划不划算】
用處②`faction_ai_system.gd:6312`（`_find_food_seek_target`）：pop ≤ 15 才掃 wild_game
   ★★而它的註解自己寫著另一個意圖：「pop>15 追不到野味死＝新型不連貫死」—— ★意圖＝【追不追得到】
⇒ ★★★同一個數 `15`（自稱 TEST VALUE／粗略 proxy／待 tune）同時扮演兩個角色
```
★**後果一（觀測）**：pop > 15 的隊【兩層都被同一個數擋】⇒ **`has_forage_tile` 那一半不可觀測**
（`6312` 先回 false，`applicable` 再擋一次）⇒ **量測只能給【三格＋一格明標不可觀測】。**
★★**後果二（修法）**：（訂正 2026-09-04：★**那兩處的理由【不是兩個】—— 第二個在 code 裡不存在**）
```
①L0 forage：`draw = minf(pool_food, pool_food * L0_FORAGE_MULT * day_fraction)` ⇒ ★與 `population` 無關
②`HuntSystem.hunt_small_game`：★★全函式【零處讀 `population`】——命中率＝`base + survival*0.4`、
   產出＝`FOOD_PER_GAME * (1 + survival*0.3)` ⇒ 只看【求生技能】
③★★★唯一真的看 pop 的是苟活封頂 `_forage_subsist_buffer = pop × FOOD_PER_PERSON_PER_DAY × FORAGE_FLOOR_DAYS`
   ⇒ **方向相反：pop 越大、可入帳上限越高**
```
⇒ ★**所以 `:6312` 註解那句「pop>15 追不到野味死」描述了一個【不存在的機制】** ——
★★**而這個常數正在把大隊【整個排除在覓食之外】（applicable 與 finder 兩層），理由是假的。**
⇒ ★★★**修法不是「拆成兩個」也不是「把 15 改大」，是【讓它由 income/burn 推導】** —— 而 `15` 應該消失。

### ✅（已修，存查）`_setup_explicit_teams` 的【順序相依】：leader 不在陣列第一個 ⇒ 該政權永遠不會建立（2026-09-04）

**狀態：已知未修（★已修 merged，存查）** ｜ **回訪：不需要（★修在機制不在資料）**

```
舊寫法：在【確認 leader 之前】就 `seen_factions[fid] = true`
⇒ ★該 faction 的第一個出現的隊【不是 leader】時，fid 被標成看過
⇒ ★★真正的 leader 後面出現時被 `continue` 掉 ⇒ ★★★**那個 faction 永遠不會被建立**（症狀：`0 factions` 而 config 明明寫了）
```
★**為什麼一直沒被發現**：**既有 config 剛好都把 leader 排在陣列前面** ⇒ **這條路從來沒有被走到**。
★★**修法＝只在【真的建立了】才標 seen**；★★★**不是把 config 的順序調成 leader 在前** ——
**後者是繞過，而下一份 config 會再踩一次。**
★**同族（同日）**：`TeamData.new()` 食物 0 的 349 個 fixture —— **兩者都是【沒有人需要說出來的假設】，被一份新資料照出來。**

### ⏳★★★53% 的測試隊【開局沒糧】—— 一個從來沒被交代過的預設值習慣（2026-09-04，★由 crisis 絕對餓判準照出來）

**狀態：已知未修** ｜ **回訪：觸發事件 — 下一條【讀糧的規則】讓 headless 變紅時（★屆時真因可能在四個月前的 fixture 裡）**

```
`headless_test.gd` 的 `TeamData.new()` ＝ 658 處；★【14 行內沒給 food 的 ＝ 349 處（53.0%）】
★★而 crisis 絕對餓那一刀只弄紅【4 個】—— 不是因為那 4 個特別錯，
   是因為【只有它們的斷言剛好碰到 crisis】⇒ ★★★其餘 345 個帶著同一個前提，而沒有任何東西會碰到它
```
★**所以這不是「4 個 fixture 的 bug」，是【`TeamData.new()` 出來的隊食物 0，而沒有人覺得那需要交代】。**
★★**危險在【下一條讀糧的規則】**：★★★**那時紅的會是【它】，而真因在四個月前的 fixture 裡。**
★**處置傾向**：不建閘（閘只擋新的，而危險來自舊的 345 個）⇒ **改讓它在每份輸出裡自己現形**
（`[BedSelfCheck] foodless_at_setup=M/N`）—— **把話放進讀者當下的產物，不是放進他應該去看的地方。**

### ⏳★★`minor_population` 有 4 個寫入點，而【戰鬥傷亡不扣它】（2026-09-04，★由一次假紅逼出來）

**狀態：已知未修** ｜ **回訪：觸發事件 — 若日後有人動戰鬥傷亡路徑（★那條路仍不扣 `minor_population`）**（訂正 2026-09-04：★三 seed 實測 `minor > pop` ＝ 0／0／0 ⇒ **銷的是「它現在有害」這個推論，不是那個機制事實**）

★★**量到了**：`minor_population > population` 的隊×tick ＝ **0／0／0**（三 seed，organic 30 日）
⇒ ★**「戰鬥傷亡不扣 minor」這個【機制事實】仍然成立**，★★**但它在這批世界裡【沒有造成】越界**
⇒ ★★★**所以銷的是「它現在有害」這個推論，不是「那條路不存在」這個事實。**

```
寫入點（全樹）：
  population_system.gd:21   −n   成年（minor → 成人）
  reaction_system.gd:323/332 +1  出生
  resource_system.gd:327    −md  ★饑荒 minor 死亡
★而戰鬥／一般傷亡路徑【沒有任何 minor_population 處理】（`npc_combat_system` 零命中）
⇒ ★★團在戰鬥中掉人口時，minor 數不會跟著掉 ⇒ ★★★`minor_population` 可能【超過】`population`
```
★**它不在單寫者白名單裡** ⇒ 單寫者閘不管它（那道閘只管白名單上的欄位）。
★★**而這顆是被一次【假紅】逼出來的**：implementer 想用 `AnonCohort` 加「孩童」湊 `minor_population`，
而它是 `TeamData` 上的**獨立 int 欄位**、根本不受 cohort 影響 ⇒ 陰性對照假紅 ⇒ **假紅逼他去查那欄位是誰寫的。**
★★★**同名不同物警告**：`health_system` 裡的 `"minor"` 是**輕微出血**，不是**未成年** ——
**用 grep 數「有沒有處理 minor」會把它算進去，然後負斷言變成假的。**

### ⏳★★★camp churn：重複紮營 **已歸零**（`has_home` 24/9/17 → 0/0/0，2026-09-03，★等價已證）

**狀態：未確認** ｜ **回訪：量測窗 — 下一輪 organic 量測時順手看 `no_home` 是否回落（★不派專輪）**

```
`camp.built.has_home`（有家還再紮）：24／9／17 → ★0／0／0（三 seed 全歸零）
`camp.built.no_home` （無家初次紮）：64→75／64→68／69→66 ⇒ ★★方向不一致 ⇒ 不歸類
★★★總量下降【完全由 has_home 解釋】：−24+11=−13／−9+4=−5／−17−3=−20（三顆逐數對得起來）
   ⇒ 這是加減法證據，不需要相信任何百分比
```
★**修前基準的合法性是【證出來的】不是假設的**：修前世界沒有索引 ⇒ 用掃描版量 ⇒
**而掃描版先在修後世界與索引版對帳**：`shadow_checks=12358`／`shadow_fails=0`／兩版分桶逐數相同（`mismatch=0`）；
★★**再加一條反向證據**：掃描版在修前世界產出 **24/9/17 ≠ 0** ⇒ **它不是「恆 false」的壞實作**。 ★**範圍限定（訂正 2026-09-04）**：兩版**共用同一個真值來源 `camp_team_id`** ⇒ 它證的是「兩種讀法一致」，**不證「該欄位本身正確」**；★★**跨世界比較仍成立**（系統性錯誤在差值上抵銷），**但不得拿它背書該欄位。**
★★★**而 implementer 自己標出證法碰不到的角**（修後 `has_home` 恆 0 ⇒ 分桶層只走過 `no_home` 那一支），
**再用「影子對帳比的是座標不是布林」補上** —— **不是宣稱已證。**

### ⏳★★#10 承諾 option 不在候選集：是【紮根】9/10，**條件本身不成立**（2026-09-03，第一步結案）

**狀態：未確認** ｜ **回訪：量測窗 — blueprint 對「結為【行為正確】」的裁定**（★證據鏈已齊，見下）

★★**最後一格已答（2026-09-04）**：`won_table`（補「只記輸不記贏」的盲點）⇒ **贏時紮根 util 0.2660／0.1851／0.2660／0.2660
vs 輸時 0.1129／0.0800／0.2245** ⇒ **贏是【它自己變強】不是【對手變弱】**；而那 4 次**備戰都在候選裡**（u 0.1872–0.2053）⇒ 排除「對手沒上場」。
★★★**證據鏈**：①機制修好（organic 紮根 0/0/0）②churn `has_home` 歸零③22 敗**無一邊緣輸**（差距全 ≥0.5）④**util 會動會贏**
⇒ **warring 的 0/22 是【對手在戰區真的強得多】，不是 util 壞掉。**
★**保留的誠實限**：控制床對手強度是**注入的**（威脅 0.22–1.24），**organic 的實際強度未標定**。
★★**順帶**：控制床上有一筆 **0.2245 vs 0.2253＝差 0.0008** 的邊緣輸 ⇒ **這張床分得出 0.001 級差距**，以後問「輸多少」比 organic 有解析度。

★★**野外複驗（三 seed，2026-09-03）**：**「不在候選集的是哪個 option」紮根 2/4/3 → ★0/0/0（三 seed 一致）**
⇒ **念頭在腦裡了，這一刀修的那件事確實 landed**（總量 `not_in_ranked` 降2升1 ⇒ 依先寫死判準**不歸類**，殘餘換成紮營，另有追問）。
★★★**而它現在 100% applicable 卻【贏 0／輸 22】**：輸給 **備戰 9／徵收 7／歸建 4**（威脅與派系義務）＋ maintain_* 2 ——
★**生存階 0 次、建設 0 次**（我先寫死的兩列都沒中）。
★★**限縮**：控制床腿A 的「30/30 贏」**沒有威脅也沒有派系** ⇒ 那句只證明「util 不是恆低」，不證明「在真實對手前夠高」。
★★★**下一步兩腿**：`peaceful_economy` 野外腿（最快分離器）＋ 22 敗 per-option util dump（**第一問＝輸得對不對**）。
★**若判定輸得對 ⇒ 本案結為【行為正確】而非【已知未修】**（戰亂延後定居＝世界在說故事）。
★★**窗長註記**：30 日可能**短於戰時自然定居節奏** ⇒ 長考 90 日會免費補答，**這輪不得因 0 勝下「壞掉」**。

★★**真根已坐實並修好（2026-09-03）**：**決策模型裡沒有「自己的營地」這個概念**（`camp_team_id` 決策路徑零讀取）——
**不是手不聽腦，是【腦裡沒有那個念頭】**（新病型，blueprint 立；判別法＝決策路徑零讀取的結構讀）。
★**控制場景床（每腿母體 30）**：腿A 30/30 applicable→贏→真 dispatch（**銜接本身無病**）；腿B **0/30 → 30/30 走回去**；
腿C 出發 30/30、解承諾 30/30、**卡住 0/30**。★★**而修法是三件不是兩件**：第三件是「第三支 applicable 進了候選集但
`util` 恆 0.0000」（選址素材只在舊兩支下計算）—— **修法是讓同一套真值對第三支也算得出來，不是 crank 分數**。
★★★**已註冊為第 14 道閘 `own-camp-link`**（回歸守衛，11s，含陽性對照）。

★**分支級 tap 已完成**：`can_settle_here` false **19/21＝90.5%**（三 seed 形狀一致）；六子條件**沒有單一主因**
（不站自家 L0 營地 52.4／88.9／69.2%、該格已有據點 42.9／77.8／53.8%，兩支常**同時**成立，其餘四支全 0）；
`applicable` 時 **won=0／lost=7**（母體 7 ⇒ 依預登記**不下判**）。
★★**可行動的結論只有一個**：**紮根極少 applicable** ⇒ 下一題是**紮營→紮根的銜接**，不是紮根的 util 權重。
★★★**而支配的兩個子條件同時為真，指向「承諾在而人不回家」**（blueprint 2026-09-03）—— 控制場景床的腿B 直接答它。
★★★**併帳提示（blueprint 2026-09-03）**：本條與「**紮根 applicable 時勝＝0**」（seed42 0/1 輸 survival、seed7 0/3 輸備戰，母體 4）
**住在同一區**（survival／applicable）⇒ **兩線資料可互餵，計數票回來時一起看**。
★**而界線要守**：**併看【資料】≠ 互為【證據】** —— 兩條線各自要有自己的母體與判準
（★★`seam1` 那次血證：兩件事碰巧都碰到 FLEE 的 applicable，而它的紅比 #10 早六週）。


`not_in_ranked` ＝ 10/25（40%）裡，**9 次是【紮根】**（seed 1337/42/7 各 2/4+覓食1/3）。
★**`stall cooldown` 排除三 seed 全 0** ⇒ **不是被 cooldown 排除，是條件本身不成立。**
★★母體 25（`not_in_ranked` 合計 10）—— **形狀可信、比例不可信**（implementer 自標，systems 同意）。
★★★下一步是分支級 tap，**禁猜**（blueprint 明令）：拿到分支名之前不提出「大概是因為…」。

### ✅（已證偽，存查）施主候選被「必須知道對方存糧」擋住 —— **假說死於當日量測**（2026-09-03）

**狀態：已知未修 → 撤銷** ｜ **回訪：不需要（已證偽，保留供對照）**

原假說：`_find_aid_target` 第三道 `bel.has("food_est")` 在擋人，理由是 `food_est` 只在互動時產生
（★**機制描述是對的**：production 產生點窮盡驗證後確為 `interaction_system.gd:1067` 單一處；
`distortion_engine.gd:85/98` 是 `*=` ＝改既有值不是產生；`village_estimate.gd` 的同名欄位是同名不同物）。
★★**而它推出的預測被打掉**：
```
              ②has_belief 通過   ③food_est 通過   ③/②
seed 1337/42/7     175/150/181      150/126/162    ★84~90%
```
⇒ **`food_est` 不稀有 ⇒ 「必須知道存糧＝認識論過嚴」不成立**，blueprint 預置的「外觀層富態信號」**未蓋**。
★★★**教訓（已入量測協議）**：③在**次數**上擋掉 57~60%，**與相異 target 集合說相反的話** ——
**一小撮沒有 `food_est` 的隊被每 tick 重掃**；★**只看次數會把修法推去資訊層，蓋一整層不需要的機制**。
★**來源稀有 ≠ 結果稀有。**

### ⏳★★★SpecimenTracer 對【戰鬥整段】盲（2026-09-02 A#14 收，★systems 親跑確認）

★**死亡那一刻已可見**（A#14 掛在 `WorldState.erase_teams`／mutation 之前，三把尺 on/off/off 逐位元同，且掛點真的 fire）。
★★**盲的是死亡【之前】的整段戰鬥**：傷亡／負傷／撤退／追擊補刀，`SpecimenTracer` 一筆都沒有。

**確認用的數字（`scripts/debug/specimen_combat_death_bed.gd`，systems 2026-09-02 親跑）**：
```
fixture：victim pop=3 無武器 ｜ killer pop=40 全武裝 ｜ 同格
4000 round 後：specimen 還在世界裡=true、pop=2      ←★★★pop 4 → 2 ＝【掉了兩個人】
交戰前後 tracer entries：1 → 1（Δ=0）              ←★★★而 tracer 記了 0 筆
erase 前後 tracer entries：1 → 2（Δ=1）            ←★死亡窄口本身是好的
```
★**「4→2」這一格是本條目從【未確認】變成【已知未修】的唯一理由** —— 在它之前，`Δ=0` 分不出
「tracer 盲」與「這段根本沒事發生」。★★而床**早就算了** `var _casual := Probe.counts.get("combat.casualty",0)`
**卻沒有印出來** ⇒ 已回信 implementer 補那一行（判準⑨：窗內那件事有沒有真的發生，要印在輸出上）。

★★★**訂正（2026-09-02，implementer 抓到，systems 認）**：本條目初版寫「起始 pop=3、掉 1 人」——
**那是我從 `_mk_team(..., pop=3, ...)` 讀 code 反推的，而床印出來是 `4 → 2`（掉 2 人）**。
⇒ ★**結論方向不變（0 vs 2），而那個數字錯了** ——★★**它正好是本條目要求「補印那一行」的理由本身**：
**讀 code 反推會錯，床自己說不會。**（★`_mk_team` 的 `pop` 參數 ≠ 最終 `population`，尚未查明，**不在本條目**。）

★★★**誠實限（寫死，別讓後人以為這是強證據）**：40 全武裝打 3 無武器、4000 round 只掉 2 人 ⇒
**這個窗裡的事件母體 ＝ 2**。⇒ 「tracer 對戰鬥盲」是**用兩個樣本**坐實的；方向可信（0 vs 2），
**強度不可信**（分不出「全盲」與「漏記率高」）。要分，得先有一張傷亡率不是 2/4000 的床。

**狀態：已知未修** ｜ **回訪：到期 token — 下一個「可見性／specimen」slice 開場時**（連同 A#27 faction-leave 四出口無 tap 一起排，兩者同族＝**引擎有事發生、儀器沒有窄口**）。

### ⏳★★`Probe.counts["death.combat_pop"]` 漏記追擊/撤退期間的減員（2026-09-02，A#14 副產）

★**同一張床上量到**：`specimen pop 4 → 2`（真的掉 2 人），而 `death.combat_pop = 0`。
★★**出處**：`npc_combat_system.gd:403` —— 該 counter **只在 `_end_combat` 記敗方陣亡**，
⇒ **追擊補刀／撤退期間的減員完全不進這一格**。

★★★**所以 A#14 那條盲不是只有 tracer**：**Probe 這一格也漏** ——
兩者一起漏的後果是：**「戰鬥造成多少人死」目前沒有任何一支儀器答得出來。**
（★implementer 只把數字印出來、沒動它；照 recamp 規矩不越界。）

**狀態：已知未修** ｜ **回訪：到期 token — 與 A#14「戰鬥段可見性」同一個 slice 一起做**
（★同一個窄口問題：**傷亡發生在 `_end_combat` 以外的路徑上**；補 tracer 而不補這一格＝只修一半。）

### ⏳`_mk_team(pop=N)` 造出來的 team `population` **不等於 N**（2026-09-02，blueprint 命上帳）

★**事實**：`specimen_combat_death_bed.gd` 以 `_mk_team(..., pop=3, ...)` 建隊
（`add_member(leader)` ＋ `AnonCohort.add(..., pop-1=2)` ⇒ **讀 code 會算出 3**），
★★**而床印出來的起始 `population` 是 4。**

★★★**為什麼要上帳而不是順手查**：這一格**同時是**一個測試 fixture 的語意問題**和**一次「讀 code 反推 vs 儀器實印」的血證
——systems 就是在這裡把 `4→2` 誤寫成 `3→2`。**差 1 不重要，「哪一種來源算數」才重要。**
★**可能是** `population` 另計 leader／anon cohort 有進位／`add_member` 有副作用 —— ★★**以上全是猜測，一個都沒驗。**

**狀態：未確認** ｜ **回訪：量測窗 — 下一次有人跑 `specimen_combat_death_bed` 或任何用 `_mk_team` 的床時，順手印 `population` 與傳入 `pop`**
（★不值得為它單開一輪；★★但它會讓**每一張用 `_mk_team` 的床**的母體數字都偏，所以不能不記。）

### ⏳★★族①god-view：**真剩餘母體 ＝ 憲法閘的 10 顆豁免標記**（2026-09-02 systems 定位）

★**血證**：blueprint 依清單把族①定序成「修 #7 `can_reach` / #17 `has_food_market`」，
★★**而這兩條連同第三站（jhost）在複驗時【全部已經修好了】** —— 清單描述的是 2026-07 的現場。

★**真母體在憲法閘的標記裡**（`scripts/debug/constitution_baseline_v2.txt`，11 顆，其中 `_find_own_outpost` 本輪已 de-patch ⇒ **現存 10**）：
```
gv_mapscan (9)：decision_context.gd::_home_granary_food ／ faction_ai::_check_ore_surplus ／
  _enemy_outpost_positions ／ _evaluate_infrastructure ／ _evaluate_new_outpost_location ／
  _evaluate_outpost_residency ／ _faction_has_workshop ／ need_oracle::_team_has_facility ／
  strategic_ai::_find_trade_partner
gv_teamstate (1)：faction_ai::consolidate_target_of
```
★★★**而「被標記」≠「違憲」**：標記＝**豁免**，逐顆要判「這個 mapscan 是不是決策在讀 god-view」——
**有些可能是合法的自有物查詢**。⇒ **族①的第一步是【逐顆分類】，不是【逐顆修】。**

★★★**2026-09-02 當日撤回**：本條目原本主張「除這 10 顆外沒有已知的 god-view 決策點」——
★**reviewer R① 抽查 76 個候選裡的【前 40 個】就翻掉它**（`premise_contradiction: TRUE`）。

## ★★★而漏掉的那顆有一個【名字】——detector 天生看不見的形狀
```
faction_ai_system.gd:246-250  ★belief 閘：if not BeliefSystem.has_belief(...): continue
faction_ai_system.gd:265      var border := 1.0 if _is_border_adjacent(team, prey) else 0.3   ← 乘進 score
faction_ai_system.gd:316-317  func _is_border_adjacent(attacker, prey):
                                  prey.tile_pos.x - attacker.tile_pos.x   ←★★★live 真位
⇒ ★belief 閘只管【要不要評估這個目標】，★★而【評估本身】讀 live 真值
⇒ ★★★「有情報」被當成「情報內容任我取用」——而 belief 只說了【知道它存在】
```
★**為什麼 detector 抓不到**：它的分類是 `gv_mapscan`（讀一整個集合）／`gv_teamstate`，
★★**而這顆是「讀一個【已經知道存在】的實體的 live 欄位」** —— **不掃集合，所以不長得像 god-view。**
★★★**這比原本記的「間接 local-var 存取」盲點更嚴重**：那條是**寫法**上的規避，這條是**類別**上的缺席。

★**母體現況（2026-09-02 掃完後更新）**：**兩顆真漏洞**（`_is_border_adjacent` 閘後／`_find_occupy_target` 閘前，見上方新條目）
＋ 10 顆既有標記。★**其餘抽查的 belief 函式確認乾淨**：`_find_weakest_prey`／`_find_absorb_target`／
`_find_strong_neighbor`／`_find_aid_target`／`_resolve_scout_target`／`_commit_conquest_attack`／`_conquest_viable`＋relocate/migrant 族。

★★★**殘留（reviewer 自述，我照收不美化）**：**非 100% 逐行覆蓋 76 處** ——
覆蓋了**全部 43 個 belief 呼叫點所在函式** ＋ relocate 族，★**未逐行查三個 tile-scan cluster：`4335-4400`／`4652-4699`／`5370-5382`**。
★★**我判這個殘留可接受，理由要寫出來**：那三個是 **tile-scan**，★★★**而 tile-scan 正是 detector 現有 `gv_mapscan` 桶【看得見】的類別**
——**漏掉的新形狀（讀已知實體的 live 欄位）不長在 tile-scan 裡**。⇒ **不是「懶得查」，是「那一段有另一道防線」。**

**狀態：已知未修** ｜ **回訪：到期 token — 族①god-view 批開工時（下一站）**

### ⏳★★`constitution_gate` 必須為「belief 閘後讀 live 欄位」新開一個桶（2026-09-02 藍圖裁，★等掃完 36 顆）

★**問題不是漏了一顆，是【閘沒有一個桶是給這類的】** ⇒ 這類永遠不會紅（現有桶：`gv_mapscan` 讀集合／`gv_teamstate`）。
★★**藍圖裁定**：「閘沒有桶 ＝ 永不紅」不能留。⇒ **36 顆候選掃完、分類定案後，detector 開新桶。**
★★★**為什麼要等掃完**：桶的判準要長成什麼樣，取決於那 36 顆裡真正的形狀有幾種——
**現在開桶 ＝ 用 1 個樣本設計分類器。**

**狀態：已知未修** ｜ **回訪：觸發事件 — reviewer 交回 36 顆逐顆分類的那一刻**

### ✅族①god-view 兩顆真漏洞 —— **已修 merged**（2026-09-02；★嚴重度不同，保留對照）

| # | 位置 | 形狀 | 嚴重度 |
|---|---|---|---|
| A | `faction_ai_system.gd:265` → `:316-317` `_is_border_adjacent` | **belief 閘【後】**，live `prey.tile_pos` 算 border **乘進 score** | ★**分數算錯** |
| B | `faction_ai_system.gd:6080` `_find_occupy_target` | **belief 閘【前】**，live `t.tile_pos` 查 tile 判 `outpost_level` ⇒ **決定這格算不算可據目標** | ★★★**live 真值決定「算不算候選」** |

★★**B 比 A 嚴重**：A 是評估算錯；★★★**B 是連「該不該把它納入考慮」都由真值決定** ——
`has_belief` 在 `:6084`，**而 `:6080` 已經先用真值把候選篩過一輪了**。
⇒ ★**因此 `invariants.md` 細則 1a 已補洞**：初版寫「閘**後**評估」，涵蓋不到 B。**現在寫的是「決策路徑上」。**

A＝型別防線（`_is_border_adjacent` 改吃兩個 `Vector2i`，函式再也拿不到 `TeamData`）；
B＝母體換成 `BeliefSystem.known_targets` ＋ 所有權查 `team_tile_known`。
★**證明 god-view 真被關掉的那一格不是差集**（舊/新母體差集 ＝ 0，同一張床上恰好重合），
★★**而是 `occupy.scan_kill_tile_unknown = 161`** —— **這 161 個候選在舊 code 直接讀全圖【會通過】。**
★★★**留這句話是因為：只看差集會得出「沒效果」這個錯結論。**

### ✅（撤回，存查）憲法閘「帳本身對不上」—— **不是缺陷，是我讀錯機制**（2026-09-02 當日自撤）

★**原主張**：`_village_est:2187` 有 inline `# gate-ok:` 而不在 `constitution_baseline_v2.txt` ⇒「官方清單連 legit 那邊都漏」。
★★**撤回理由（`constitution_gate.gd:6,8` 契約原文）**：
```
:6  指紋 = <relpath>::<func>::<type>。契約：current ⊆ baseline。added=FAIL。removed=PASS
:8  ★源碼行含 `# gate-ok` = 明允豁免，【不入 current】
⇒ ★★兩者是【不同機制】不是同一本帳的兩份：
   inline gate-ok ＝「這行根本不算一個站點」；baseline ＝「這個【被偵測到的】站點被凍結承認」
⇒ ★★★被 inline 豁免的東西【本來就不該出現在 baseline】—— _village_est 是【設計正確】
```
★**教訓（比這條目本身有用）**：我驗了**事實**（inline 有、baseline 沒有），**沒驗【詮釋】**（兩者本來就該一致嗎）——
★★**而這個詮釋不是我自己想的，是從 reviewer 那裡照收的。** ★★★**上游給的詮釋一樣要驗。**
（★我已據此撤回寄給 blueprint 的那一段，並砍掉為它寫到一半的 `gateok-reconcile` 閘 —— **錯前提上的守衛比沒有守衛更貴。**）

### ⏳★★★憲法閘 baseline 的【一行兩義】：「判過合法」與「已知漏、暫緩【★非裁定：此處是【引述】那個一行兩義的問題本身】」長得一樣（2026-09-02 reviewer 撿，★systems 讀原文複驗）

★**坐實（該行自述，不是詮釋）**：
```
constitution_baseline_v2.txt:76
scripts/simulation/strategic_ai_system.gd::_find_trade_partner::gv_mapscan
  # CANDIDATE-LEAK: partner discovered 但 outpost pos 讀 live(半漏,待 R²+follow-up)
```
⇒ ★★**這一行自己說它是【待修的漏】，而閘對它與「判過合法」的行【一視同仁地靜音】。**
★★★**所以「在 baseline 裡」不代表「判過」** —— 它可能是「看過、知道有問題、先放著」。

★**與 2026-09-02 稍早那條【已撤回】的主張要分清楚**（★避免後人以為這是同一件事）：
```
★撤回的那條：inline gate-ok ↔ baseline「對不上」⇒ 錯，兩者是【不同機制】
★★這一條：  baseline【內部】混了兩種語意 ⇒ 有原文支撐（該行自己寫著 CANDIDATE-LEAK）
⇒ ★★★前者是我把兩個機制當成一本帳；後者是一本帳裡混了兩種判決。不同的病。
```
★**母體**：目前**只有 1 行**帶自述漏的字樣；★★**而其餘 74 行【有沒有被判過】，清單本身不記錄** ——
**這才是真正的缺口**：不是「有幾行是漏」，是**「這份清單不保存判決」**。

**狀態：已知未修** ｜ **回訪：到期 token — 族①修法 slice（`_find_trade_partner` 已列入該 slice 的第 5 顆）**

### ⏳★★族①god-view：**5 顆「判不出來」誠實掛著**（2026-09-02，★沒有一顆被猜進 baseline）

★`_update_escort`（reviewer 缺 call-graph 證據）＋ implementer 退回的 4 顆
（reviewer 的函式級理由**涵蓋不到那一行的具體讀**，依裁定**不准延伸**）。
★★**它們既沒有 inline `gate-ok`、也沒有進 baseline** ⇒ **仍在 warn 桶裡每次跑都印出來** —— **這是刻意的。**
★★★**為什麼不猜**：猜出來的分類會被凍進 baseline 當成【判過的】，而那正是 baseline 第 76 行
（`_find_trade_partner # CANDIDATE-LEAK`）的形狀 —— **我們今天花了一輪把它挖出來。**

**狀態：未確認** ｜ **回訪：量測窗 — 兩條路擇一即可**
①**長考卷面讀數**（把該函式的 call-graph 讀完，判「那個 live 讀是否真的餵進決策」）；
②**warn 桶的 runtime 證據**（該站點在真實跑動中被走到幾次、讀到的值有沒有影響輸出）。

### ⏳★★★#33 五支決策支不可量測 —— **錨精確化**（2026-09-02 systems 先查）

★**條目原文成立，而錨可以更準**：
```
decision_tier.gd:162-163
  static func poll_measurable(k: String) -> bool:
      return k in ["GOAL", "LADDER", "STRATEGIC", "INTENT"]
⇒ ★★白名單【只有 4 支】；ALLIANCE／BETRAY／INFRA／FACTION_UPDATE／INDEP_INFRA 五支不在其中
⇒ ★★★與條目原文「9 支裡只涵蓋 4 支」完全吻合 —— ★這是【坐實】不是【重述】
```
★**維持不開票**（條目自述理由仍成立：要它們進分母＝讓選擇落到持久欄位＝**改行為**不是**加 tap**）。
★★**on-touch 義務不變**，而現在它有一個**單一改動點**：`poll_measurable` 的白名單。

**狀態：已知未修** ｜ **回訪：觸發事件 — 下次動那五支任一支時（★白名單那一行就是入口）**

### ⏳★★長跑輸出檔【讀太早會讀到 0】（Windows 寫入／MSYS 讀取可見性延遲；2026-09-02 ★根因訂正）

★★★**本條目的原始版本被 measurer 自己推翻，訂正記在最上面**：
```
★原版寫：「8mo 兩次 0-byte 瞬殺、連 header 都沒印 ⇒ 疑同機多 session Godot 資源競爭」
★★而 measurer 隔一段時間再開【同一個檔】：446 KB、跑到 tick=55000、
   尾端 `[GODOT TIMEOUT 2400s - process killed]` ⇒ ★自然 timeout，header/progress 全部正常
⇒ ★★★「資源競爭外部瞬殺」【沒有站得住的證據】，他收回，我照收
```
★**真正可複現的危害（他兩次都撞到）**：**background process 剛觸發「completed」的那一瞬間，
`wc -l` 可能讀到 0** —— Windows 側寫入與 bash(MSYS) 側讀取之間有**可見性延遲**。
⇒ ★★**規避**：長跑輸出**不要在完成通知的當下立刻讀**；先 `ls -l` 看大小，或隔一次操作再讀。

★★★**而它又是同一個形狀**（今天第三次）：**`wc -l = 0` 被讀成「沒產出」，而它是「還沒看得到」。**
⇒ ★**用今天立的判別法就抓得到**：問「**這個 0 是誰產生的**」——
**它是【讀取者】(wc) 產生的，不是【產生者】(godot) 產生的 ⇒ 先懷疑「還沒到」，不是「沒發生」。**

★**判別法保留、血證撤掉**：原條目寫的「0-byte 連 header 都沒有 ⇒ 先懷疑環境」**邏輯本身仍成立**，
★★**但促成它的那筆觀測是假讀** ⇒ **它現在是一條沒有實證的判別法**，★★★**不得當成「環境競爭」的案例引用。**

★**systems 自認**：我**沒有驗證那筆觀測就立了條目** —— 而我今天稍早才立過「上游給的詮釋一樣要驗」。
★★**這次比那次更差：我連【事實】都沒驗**（只要 `ls -l` 一下就會看到 446 KB）。

**狀態：未確認** ｜ **回訪：量測窗 — 下一次有人在完成通知當下讀長跑輸出時（★順手記錄「立刻讀」與「隔一次再讀」的差異）**

### ⏳★★★解承諾之後 `current_option` 不清 ⇒ **持守加成活過承諾**（2026-09-02，reviewer 問出來的、systems 查實）

★**兩個欄位，設在同一條路上，清在不同地方**：
```
派出（faction_ai_system.gd:2884）：team.current_option = opt   # 註解原文「承諾追蹤實際派出」
   ＋ 同路 _stamp_survival_commit 蓋 survival_committed_option
★解承諾（:5944／:5948）：survival_committed_option = ""    ←★★而 current_option 【沒被清】
★release()（task_arbiter.gd:161-181）：也【不清】current_option（grep 命中 0）
★★★rank_scored（decision_engine.gd:96）：`if opt == current_option: u += _persist`
⇒ ★被【明確解除承諾】的那個 option，仍然拿得到【持守加成】
```
★**當下影響有限**：`STALL_STALLED` 會把該 option 放進 `survival_stall_cooldown` 硬排除窗，
排除期間有沒有加成都不影響結果。★★**但排除窗過期後，它帶著一個【已被解除的承諾】的加成回來。**

★★★**要不要修是 WHAT 不是漏**：「**承諾被解除之後，持守加成該不該跟著消失**」——
★這與 blueprint 今天裁的「承諾＝決策層狀態」直接相關，★★**但我不替他答**，已呈報。

**狀態：已知未修** ｜ **回訪：到期 token — 承諾再派 funnel slice（同一刀會碰到這兩個欄位）**

### ⏳★★`FLEE` 的 applicable 問「有沒有座標」，`備戰` 問「怕不怕」——**兩道閘不同種類**（2026-09-02 reviewer 撿，systems 複驗）

```
options.gd:76-81  "逃跑"  applicable: ctx.threat_pos != Vector2i(-1,-1)        ←★只問【可行性】
options.gd:400-401 "備戰"  applicable: ctx.threat_react >= ctx.threat_threshold ←★★只問【意願/強度】
```
★★★**同一個「威脅」情境下，兩個反應選項用【不同種類的判準】決定 applicable** ——
★**FLEE 少了 threshold**：只要威脅有座標，FLEE 就是候選，**即使那個威脅弱到不足以引發反應**。
（★★它仍要在 rank 裡贏才會被選，所以這不是「一定會逃」，是「**它一直在候選名單上**」。）

★**由此產生一個既有的窄 band**（reviewer 命名，非 flee-to-safety 那刀新造）：
**`threat_pos != -1` 但 `threat_react < threshold`** ⇒ FLEE 現在 applicable、備戰不 applicable。
★★**flee-to-safety 給 FLEE 加上「要有 believed 目的地」之後，這 band 裡沒有目的地的隊 ⇒ 兩者皆不 applicable。**
★★★**我判它 benign**：**低於反應門檻 ＝ 沒怕到需要出口**，隊會去 rank 正常選項（覓食／建設…）。
⇒ **而「我判它 benign」要有數字撐**：flee-to-safety 那刀已要求為它加計數（落進該 band 幾次）。

**狀態：已知未修** ｜ **回訪：到期 token — flee-to-safety slice（該刀會在同一區動刀，屆時一併判要不要給 FLEE 補 threshold）**

### ⏳★★能派 FLEE 的站【4 個】、設 `flee_from_pos` 的【2 個】、註解說【3 個】（2026-09-02 implementer 全量掃）

```
faction_ai_system.gd:2950 _decide_unified     → ✅ 設（:2989）
faction_ai_system.gd:3373 _decide_subteam     → ★❌ 不設（★★而它走 ranked ⇒ 過 applicable 閘）
   ⇒ ★★★2026-09-02 實測訂正：**12 日窗 subteam ＝ 0、30 日窗 subteam ＝ 8**
      ⇒ ★「走不到」是【窗太小】不是【不存在】——★★正是「0 三讀法」第③讀（母體塌陷／儀器沒跑到）
      ⇒ ★★★而它們【沒有】造成續卡（backstop 仍 0）：**ADDENDUM 的構造解（`to_task` 帶 target ⇒ `try_set` 存）
         讓它們派發時就帶著目的地** —— **構造涵蓋在真實資料上被驗證了，不是只在推理上**
faction_ai_system.gd:3549 _evaluate_solo      → ✅ 設（:3562）
faction_ai_system.gd:5728 _trigger_survival   → ★❌ 不設（★implementer 讀 code 判 FLEE 走不到：
                                                 rank_survival 只收 sets 含 "survival"，而 FLEE 是 {"threat": true}
                                                 ⇒ ★★但「讀出來的走不到」不算證據，桶已放、恆 0 才是坦白）
★而 flee_from_pos 的 writer 全量三處：上面兩個 setter ＋ `task_arbiter.gd:179 release()` 清成 (-1,-1)
★★★faction_ai_system.gd:494 的註解寫「3 FLEE 派發站派 FLEE 後呼，設 flee_from_pos」
   ⇒ 站 4 個、設 2 個、註解說 3 個 —— **三個數字沒有一個對得起來**
```
★**後果**：`_decide_subteam` 派 FLEE 而不設方向 ⇒ 欄位維持 `release()` 清出來的 `(-1,-1)`
⇒ ★★**movement 看到 positionless ⇒ backstop ⇒ 同一個迴圈，只是換一站生出來。**
★★★**而這一格【推翻了 systems 先前的定位】**（原指 `:2973/:3539` 兩站零 guard；
實測 `_flee_threat_pos` 163 次呼叫【零次】回 (-1,-1)）。

**狀態：已知未修** ｜ **回訪：到期 token — flee-to-safety slice（該刀的通則「凡能派 FLEE 的站都必須存目的地」直接涵蓋它）**

### ⏳★★`tree-div` 升級成【WIP manifest 歸屬制】（blueprint 提 2026-09-02，systems 裁「採，但附防橡皮圖章條款」）

★**現況**：`tree-div` 是**儀表不是守衛**（只印不判；誠實限③自述「數字變大不會讓任何閘變紅，靠人看」）。
★★**升級形狀（blueprint）**：一次性樹對帳落地後 **baseline ＝ 0**；之後每個 divergent 檔**必須歸到一個具名 WIP**，
**歸不到的才紅** ⇒ WIP 合法性保住、無主漂移可判。

★★★**systems 裁：採，而【必須帶三條防橡皮圖章的設計】** —— 理由是今天一整天的同一個教訓：
**維護型清單會腐爛**（known_issues stale／baseline 一行兩義／註解說 3 站而實際 4 站）。
```
①★manifest 條目必須帶【owner ＋ 到期或觸發條件】—— ★★WIP 不能無限期
②★★★【過期的條目本身要紅】—— 不是「有條目就綠」
   ⇒ 沒有這條，manifest 會變成【加一行就綠】的橡皮圖章，
     ★而那比「只印不判」更糟：★★它【看起來像被管住了】
③★採用時點＝【樹對帳專段之後】—— ★★在那之前採，manifest 會以 18 個來歷不明的條目開張
   ⇒ ★★★【天生就是橡皮圖章】
```

**狀態：已知未實裝** ｜ **回訪：觸發事件 — 樹對帳專段完成、baseline 歸零的那一刻**

### ⏳★★`_begin_facility_construction` 缺【再入守衛】（2026-09-02 reviewer 撿，★systems 判：潛在非活）

★**不一致**：`start_build:540` 與 `start_demolish:651` **都有** `construction_team_id != -1` 的再入守衛，
★★**而 `_begin_facility_construction` 沒有**。
★**後果（若被繞過）**：★★不是「換目標」而是**真的把進行中的工程重置**（`ticks_left` 歸零）。
★★★**現況判定：潛在，不是活的**（systems 複驗）——兩個呼叫端
（`outpost_system.gd:592` 的 `start_upgrade_facility`／`:819`）**都在呼叫前檢查 `construction_team_id != -1`**。

## ★★而它與今天另一個【相反方向】的裁定不矛盾，寫清楚免得後人誤讀
```
★`own_granary_tile(state=Nil)`：systems 認可【修呼叫端】而不在被呼叫端加 null 檢查
   ⇒ 理由：被呼叫端擋 ＝ ★★【吞掉呼叫端的錯】（null 進來本身是 bug）
★★★而這一條相反：被呼叫端加再入守衛 ＝ 【守住一個不變量】（不得覆蓋進行中的工程）
   ⇒ ★差別在【那個檢查是在隱藏錯誤，還是在保護一個必須永遠成立的性質】
```

**狀態：已知未修** ｜ **回訪：觸發事件 — 下一次新增 `_begin_facility_construction` 呼叫端時（★屆時補守衛，不要靠新呼叫端記得檢查）**

### ⏳★★★跨 arc 訊號：**「備戰」是三個獨立漏斗的共同贏家/去向**（2026-09-02 systems 併看三份量測）

```
①#10 承諾再派 dump：★贏家【都是備戰】（util 0.8046／0.8742，而承諾那格 0.0967／0.1527）
②#5 flee 退化去向：★★怕過門檻但無目的地 → 備戰，★30 日【2108 次】
③#12 乞食輸家分析：★★★28 次【輸給備戰】（床裡刻意設的「贏家跟糧食無關」訊號）
⇒ 三份【獨立】量測、三個不同的病，而【同一個贏家】
```
★**兩個讀法，而我不下結論**：
```
(a)★備戰【真的】該贏：它便宜、幾乎總是 applicable（`threat_react >= threshold`，無其他前置）
   ⇒ 在 warring 世界裡多數隊過門檻 ⇒ ★★它一直在候選裡，而 util 0.8+ 高
(b)★★備戰的 util【被高估】或 applicable【太鬆】⇒ 它排擠掉真正該做的事
```
★★★**為什麼值得單獨查**：**若是 (b)，它一次解釋三個看起來無關的病** ——
**而我們現在正要為那三個病各開一張票。**

**狀態：未確認** ｜ **回訪：量測窗 — 下一輪任何跑決策的床，順手 dump 備戰的 util 組成（各項貢獻）與 applicable 命中率**

### ⏳★★★設施【升級】整條路不在秤上（2026-09-02，導回自救建田時撞出來）

★**建造新設施**走 `_pick_facility` 仲裁；★★**而升級既有設施**走 `start_upgrade_facility`，
**被以【寫死的設施名】呼叫**：`outpost_system.gd:595 "farming"`／`:598 "workshop"`（＋玩家指令 `player_command_system.gd:504`）
⇒ ★★★**`_pick_facility` 對這條路【零參照】—— 誰升級、升哪一個，不經過任何秤。**

★**而 `_pick_facility` 自己也不能表達升級**：`:5164` `if 現有等級 > 0: … continue`（註解原文「已有設施→升級 skip」）
⇒ ★★**秤的候選集合 ＝【未建設施】**，而「把既有的田 1→2」**不在它的語彙裡**。

★★★**這是我們今天剛修掉的那個病的【兄弟】**：
```
①自救建田繞過仲裁 ⇒ ★已導回（#35）
②★★升級整條路繞過仲裁 ⇒ ★★★【還在】，而且它是【寫死名字】的版本（比 ① 更硬）
```
★**血證（導回 #35 後的真世界床）**：自救路再也選不到 farming（`pick.farming = 0/3605`），選到的又幾乎全部付不起
⇒ **自救建田形同停擺** —— ★★**因為它要的是「升級既有田」，而秤說不出那句話。**

**狀態：已知未修** ｜ **回訪：觸發事件 — 【規模經濟 R① 開場】時**（blueprint 裁 2026-09-02）
★**為什麼綁那個觸發而不是「排後面」**：把 `:595/:598` 兩個寫死名字收進秤 ＝ **「升級」第一次有仲裁**，
★★**而那本質是【升級估值】問題** —— **「第二座田值多少」正是規模經濟的地盤**，
★★★**在那個 arc 開場前做，等於用一個沒有估值模型的秤去仲裁升級。**
★**而止血的那半（(i)：讓秤能說「升級」）另案先做** —— 見 `#35` 修秤 slice。

### ⏳★★★威脅評估的 power 維：**自己用真值、對方用手抄常數 0.3**（2026-09-02，備戰 root-check 釘死）

★**量測（implementer，兩個 config）**：
```
peaceful：pop_est 5.99 vs self_pop 6.00（★人口幾乎相等）；★★而 ratio 平均 2.997 ≈ 0.3 / 0.1
⇒ ★★★power 項【整個】來自常數落差 —— 不是 belief、不是情報
★self combat < 0.3 的比例 ＝ 【100.0%】（母體 51.5 萬／1.07 萬，兩 config 皆然）
★★而 power 項平均 3.6410(warring)／0.9882(peaceful)，approach −0.03／hostility 0.51 ⇒ power 主導 raw
```
★**code（`threat_assessment.gd::_power_ratio`）**：
```
other_power = pop_est * 0.3        ←★手抄常數（註解：「無 combat skill in intel → 用 0.3 baseline」）
self_power  = _team_power(self_team) ←★★真值（真實 combat skill）
```
★★★**而答案就在同一支函式裡**：`pop_est` 的 fallback 是 **`self_team.population`**
（註解原文「鏡射 diplomatic `_get_pop_est` fallback=self_pop 模式」）
⇒ ★**人口那一維【用自己當先驗】，而技能那一維【用手抄常數】** —— **同一函式內兩維不一致。**

★**修法方向（不是把 0.3 改成 0.1）**：memory `feedback_no_handcopied_physics` 明令
**估值必 (a) 物理同源推導 或 (b) 讀自身狀態；血統② 手抄常數全禁；修法形狀＝改接線非改數值**
⇒ ★★**讓技能維跟人口維走同一個 fallback（以自己為先驗）** ⇒ ratio ≈ 1（中性），
★★★**而那正是那行註解自己宣稱的意思（「視對方等強」）——它只等在人口那一維。**

**狀態：已知未修** ｜ **回訪：到期 token — 待 blueprint 裁（★它會改變【所有】威脅評估，不該夾在別的刀裡）**

### ✅★★★merge-gate 註冊表【漏了 headless_test】—— 已補（2026-09-03）

★**發現方式**：implementer 跑 `headless_test` 才看到**兩顆【已 merge】的 slice 各弄紅了 fixture，而 merge-gates 十支全綠**。
★★**原因**：`headless_test` **不在註冊表裡**；`bed-parse` **只解析不執行**。
★★★**而 `CLAUDE.md` 寫「merge 前跑【全部】merge-gate —— 清單見註冊表」**
⇒ **註冊表被當成【完整的】，而它不是** —— ★這是「檢查管道與失效管道不同軸」的又一次
（同族：`known_issues` 錨 stale、`gv_belief_*` 沒有桶、fence 只在 render 現形）。

★**已補**：第 12 支 `headless`，★★**而它比數量更進一步：逐條比對失敗【清單】**
（`docs/process/.headless-baseline-list.txt`）—— ★★★**因為「只比數量」會被【一紅一綠抵消】**。
★**代價誠實記**：merge-gates 總時 170s → **239s**。

**狀態：✅已補** ｜ ★**而留下的問題不是這一支**：**註冊表【還漏了什麼】沒有人知道** ——
★★**它自己不會說「我不完整」** ⇒ 見下方新條目。

### ⏳★★註冊表的完整性【無人負責】（2026-09-03，補 headless 時撞出來）

★**今天補了 `headless` 之後，沒有任何東西能回答「還漏了什麼」** ——
★★**閘表是一份【只會被加東西】的清單，而它從不宣稱自己完整。**
★★★**而 `CLAUDE.md` 那句「跑【全部】」讓讀者以為它完整** ⇒ **語氣與事實不符。**

★**候選解（未定）**：①`CLAUDE.md` 那句改成「跑註冊表上的全部（★而註冊表不保證涵蓋一切）」
②列一份「已知但【刻意不入閘】的檢查」清單（含理由）③定期用「哪些床/測試從沒被任何閘跑過」反查。
★★**而 ③ 是唯一能【主動】發現漏的** —— ①②只是誠實化。

**狀態：已知未修** ｜ **回訪：觸發事件 — 下一次有人發現「閘全綠而東西是壞的」時（★屆時不要只補那一支，先問【還漏什麼】）**

### ⏳★★`dcef1f63`「breed 讀真盈餘」在 branch 上**弄紅自己的 fixture**（2026-09-03 實測坐實）

★**量測**：`main` 跑 `headless_test` ＝ **7 條紅**；`feat/old-growth-forest` ＝ **12 條** ⇒ **差集正好那 5 條生育 assert**。
★★**根**：`dcef1f63`（2026-09-01「停下來報：breed 讀真盈餘…」）**只在 branch、NOT-IN-MAIN**。
★★★**而這給了樹對帳裡「Package B ＝ WIP 留 branch」一個【具體理由】** ——
先前的理由只是「commit 標題自己寫著停下來報」。

★**要分開寫的兩件（在「WIP」這個標籤下長得一樣）**：
```
①★「還沒做完」⇒ 缺功能、測試沒動
②★★「做了，而測試說它不對」⇒ ★★★本條是【②】
⇒ 而 ② 若被當成 ① 擱著，會在某天被人「順手 merge 一下」——因為 WIP 聽起來像未完成不像有問題
```
★**附帶（implementer 自揭的分類混淆，值得記）**：他先前答「那五條來歷是 6 月／8 月」——
★★**那是【assert 那幾行何時被寫下來】，不是【它們何時開始紅】** ⇒ ★★★**同一個東西的兩個時間軸，
而【前者查得到、後者要跑】** —— 他用前者答了後者的問題，然後自己翻掉。

★★★**2026-09-03 歸屬坐實（差集法，非推論）**：把 `dcef1f63` 的**六個 production 檔退回 main 版**之後，
`assert` 從 **12 → 7**（＝main 的數），★**五條生育 assert【全部消失】** —— 包含正規化之後才浮出來的那第 5 條。
⇒ ★★**五條全屬這一顆，不必單獨立項。**
★**而方法值得記**：★★**兩個狀態各跑一次比差集** —— **不是 `git log -S`（答錯問題）、也不是讀 code 推**。
★★★**這是同一條紀律今天第三次生效**（前兩次：定年那 7 條／`beg.` tap 的歸屬）。

**狀態：已知未修** ｜ **回訪：觸發事件 — breed 真盈餘那條 arc 重啟時（★屆時第一件事是讓那 5 條綠，不是繼續往上疊）**

### ⏳★★★main 上有 **7 條 assert 失敗** —— **6 條已登記為 `unjudged`、1 條未登記**（2026-09-03；★本條目原文寫錯，已訂正）

★★★**訂正（implementer 指出）**：原文寫「**沒有被任何清單登記**」——**錯的**。
```
`docs/test-baseline-failures.txt`：★7 條 `unjudged` ＋ 1 條 `real-regression`
⇒ 那 7 條 assert 裡【6 條已登記】（5 條 unjudged ＋ g1a real-regression）
⇒ ★★唯一沒登記的是 **fixture B**（★而那是 implementer 的、等 blueprint 裁「設施升級 vs 據點升級」）
★★★而我怎麼寫錯的：我 grep 了「生育／breed」得 0 就下結論 —— ★那個 grep 答的是【條目裡有沒有那兩個字】，
   不是【那些失敗有沒有被登記】。**負斷言用錯了鑰匙。**
```
★**而那個檔本來就有 `unjudged` 這個標記** —— ★★**專案早就有「未判」這一態，而我寫得像它沒有。**

★**它們一直都在**（`SCRIPT ERROR: Assertion failed: …`），★★**而沒有被任何清單登記**
（`docs/test-baseline-failures.txt` 只登記 `[FAIL]` 那條管道的兩條）。
★★★**它們今天才第一次被看見，是因為 merge-gate 的 `headless` 閘原本【只 grep `[FAIL]`】** ——
**而失敗有【兩條不重疊的管道】**：①`[FAIL]` 行 ②`SCRIPT ERROR: Assertion failed:`。
⇒ ★**資料本來就在輸出裡**（閘用了 `2>&1`）—— ★★**缺的不是抓取，是 grep 太窄。**
⇒ ★★★**這正是「缺陷躲在我們不走的管道」：檢查管道與失效管道【不同軸】** ——
**而它這次發生在【為了治這個病而建的閘】裡面。**

★**現況**：那 7 條已進 `headless` 閘的 baseline 清單 ——★★**目的是【擋住新的紅】，不是承認它們合理。**
★★★**每一條都欠一個判決**（自哪顆 commit 起紅／該修還是該登記）。

★★★**2026-09-03 已定年（implementer 用「跑舊 commit」那個方法，一次得到全部）**：
```
★在 357e7807（2026-08-25）就紅的 ＝【5 條】：FORCE／p2a join／rung 擴張／197 擋／紮營=1.0
★★這段期間【才變紅】的只有 2 條：g1a（已登記 real-regression）與 fixture B（等 blueprint）
⇒ ★★★那 5 條 `unjudged` 【確實是老的】—— 不是誰最近弄紅的，而【它們仍然沒有被判過】
```
★**而他第一次跑那個舊 commit 拿到【0 條】** —— ★★**因為新 worktree 沒有 class 快取 ⇒ parse error ⇒ 整支沒跑到**
⇒ ★★★**0 差一點被讀成「08-25 是乾淨的」** —— **今天第二次同族**（我早上把「快取沒建」讀成「床壞了」）。
★**而 `headless` 閘對這一種是有防線的**：抓不到 `HARD-FAILS` 那一行就 FAIL，並印
**「這是【儀器沒跑到】不是【沒有失敗】」** —— ★★**但那只保護閘自己的跑法，不保護手動在 worktree 裡跑的人。**

**狀態：已知未修**（★5 條老的、仍未判；2 條新的各有歸屬） ｜ **回訪：到期 token — 下一個碰 breed／絕境階梯的 slice（★屆時順手判掉相關的那幾條）**

### ⏳★★★`redispatch.not_in_ranked` **10/25（40%）** —— **母體加大後成為主要出口，而它推翻了我先前的結論**（2026-09-03）

★換尺後 re-measure：#10 承諾再派 母體 3 → 6、贏 0 → 1，★★**而冒出一格【新的】**：
`not_in_ranked` **0 → 2（33%）** ⇒ **承諾的那個 option 現在【有時連候選都不是】**。
★★★**不判**：**母體 6，2 不是趨勢**（implementer 自述「這個結論很脆」，systems 同意）。
★**而它值得追的理由**：★★先前那一格【一直是 0】——**「候選一直都在」正是我們用來推翻「缺 funnel」的證據**；
★★★**現在它不是 0 了 ⇒ 那個推翻的前提在新世界裡【可能不再成立】。**

★★★**2026-09-03 母體加大到 25 ⇒ `not_in_ranked` ＝ 10/25（40%）**：
```
★母體 3 → 6 → ★★25 ｜ not_in_ranked 0 → 2 → ★★★10（40%）
⇒ 承諾的那個 option 有【四成的時候連候選都不是】—— 它從「不存在的一格」變成【主要出口】
```
★★**而這推翻了我 2026-09-02 報給 blueprint 的結論**：
```
★當時：`not_in_ranked = 0` ⇒ 我據此說「再派 funnel【不缺】，病是【它每次都輸】」
   ⇒ ★★blueprint 因此撤回了他「病＝缺 funnel」的病位判斷
★★★而那個 0 是在【威脅膨脹 4.33 倍】的世界裡量的 —— 換尺之後它不是 0 了
⇒ ★所以：**不是我當時量錯，是【世界變了】** —— 而結論沒有跟著重驗，直到現在
```
★**下一個問題（唯一該問的）**：★★**它為什麼不在候選？** —— 是哪一個 `applicable` 條件擋的？
★★★**不要猜（今天已經有兩次「聽起來很合理」被數字打掉）** ⇒ **要逐次記下被擋的那個條件名。**

**狀態：已知未修**（★由「未確認」升格：母體 25、40% 不是雜訊） ｜ **回訪：到期 token — 下一輪 #10 開刀時，第一格就是「擋它的是哪個 applicable 條件」**

### ⏳★★★施主可及率**隨餓深崩塌**（37.5% → 4.0%，最深帶 0.0%）—— **世界薄，不是秤的問題**（2026-09-03）

★**量測（分帶 dump，兩個 seed）**：
```
施主可及率（該帶裡「有至少一個可乞對象」的隊 ÷ 該帶母體）：★37.5% → ★★4.0%
★★★而兩個 seed 的【階梯 deep 帶】都是 **0.0%** —— 最需要乞食的隊，一個施主都沒有
```
★★**而決策層是好的**：同一輪量到「最深帶且施主可及時，乞食【會贏】（41/84 ＝ 49%）」
⇒ ★★★**所以這不是「引擎不選乞食」，是【根本沒有對象可選】。**

★**兩個可能（我不判，這是 WHAT）**：
```
(a)★世界本來就該這麼薄（餓的時候鄰居也餓／關係本來就少）⇒ ★★那 `乞食` 這個選項的存在意義要重談
(b)★★關係密度／可及性的模型缺了什麼（例如：只認直接鄰居、不認同 faction、不認曾經的交易對象）
⇒ ★★★而 (b) 若成立，它會同時影響【所有需要「找一個對象」的選項】——不只乞食
```
★**同族線索**：階梯路舊值「沒有援助對象」擋掉 **199/209** —— ★★**那個數字先前被讀成「乞食的閘」，
而它其實是【世界薄】的溫度計。**

**狀態：未確認** ｜ **回訪：量測窗 — 下一輪任何跑 survival／社交的量測，順手量【可及對象數】的分佈（不只有無）**

## ★★★means-end/長程計畫全系統 = binding root（用戶定 2026-07-24，material arc 全 PARK 待它）

material 供給查出決策模型 **means-end 缺口完整三段**（①動機盲 `settle_fit` terms.gd:184-190 flat by option-type ②零 terrain/forest-seeking 移動決策 ③build 只腳下 `建設 to_task=team.tile_pos` options:45 / `start_build` 用當前格 outpost:368）→ 逐段補 = 3 條 bespoke 補丁 = 違憲 scripted + 無限打地鼠（同 軍閥天命/立王朝/發展維度/造謠/天災 全同缺口，2026-07-19 note line 52）。

> ★**狀態標記三態慣例（2026-08-21 立、blueprint 認可）**——**禁一律標「已修」**：
> - **✅ 真結案**：機制已修 **且** 影響面已清（可直接不再讀）。
> - **⚠ 機制已修、歷史資料仍污染**：修法已 merge，但**舊量測/舊結論仍受影響** → 必附**自查方法**（如 signature）。
> - **⚠ 部分修**：只修了其中一支 → 必寫**剩下哪一支、去哪追**。
> ★**「部分修」標成「已修」是最陰的坑**：之後沒有人會回頭看剩下那半。

### ⏳★★`_hex_dist` 全站【11 份拷貝】＋兩個改名變體（2026-09-02，godview-1a seam 副產）

★`faction_ai_system`／`game_setup`（★兩份：`_hex_dist` ＋ `_hex_dist_static`）／`movement_system`／`order_system`／
`outpost_system`／`path_system`(static)／`strategic_ai_system`／`threat_assessment`(static)／`vision_system`／`world_generator`
＋ `sim_runner::_hex_distance`（★**改名變體：grep `_hex_dist` 抓得到，而比對呼叫點時會漏**）。
★★**抽查三份（faction_ai／path_system／threat_assessment）公式逐字相同** ⇒ 目前**沒有行為分歧**。
★★★**同族**：memory 記過的「走一格要多久全站五套算法」——**今天沒分歧不代表明天沒有，而分歧會是靜默的。**
（★本輪實際代價：seam 差點因為「要用 `_hex_dist`」而讓 `belief_system` 依賴 `faction_ai_system`。）

**狀態：已知未修** ｜ **回訪：觸發事件 — 下一次有人要在新檔裡用 hex 距離時（★直接呼既有 static，不要抄第 12 份）**

### ✅`has_belief` 不蘊含「有位置」——**belief 有欄位粒度**（2026-09-02；★三態已落地：有值／`stale`／`never`）

★**systems 在 spec 裡寫**「過了 `has_belief` 閘 ⇒ 一定拿得到 `belief_pos`，開一個【必須恆 0】的桶」。
★★**錯的**：`has_belief` ＝ claims 非空；`belief_pos` ＝ 需該 claim **帶 `tile_pos` 欄位**且**未過期**。
⇒ **有 claim 不代表有位置。** 實測：`headless_test.gd:9510` 附近 `record_claim(..., {"population_est":…,"armed_est":…}, …)`
**沒帶 `tile_pos`** ⇒ 兩個既有測試在 belief 化之後轉紅。

★★★**處置（systems 裁）**：那個桶**不是違規桶，是【合法的第三種結果】** ⇒ 更名 `known_but_positionless`，
**當狀態處理（棄該 target），★不得退回 live**。已寫進 `invariants.md` 細則 1a。
★**未做**：**全站還有哪些 `belief_pos` 消費端假設了「過閘就有位置」，本輪沒查。**

★**已落地（2026-09-02 感知兩層 slice）**：讀取端回 `{activity: unknown, state: "never"|"stale"}` ⇒ **三態分得開**；
★★寫入端**沒有 unknown 這個答案**（`observed_activity` 落到最後回 `ACT_IDLE`），`write_unknown_BUG` 恆 0 桶已上床。
★★★**仍未做**：**全站還有哪些 `belief_pos` 消費端假設「過閘就有位置」** —— 本輪只修了 `_try_invite_nearby_exile` 這一條路徑。

### ⏳★★★建造：**兩條路，兩個不同的病**（2026-08-26 三度訂正；★舊讀法全部保留在下方，因為每一個都曾經看起來很有道理）

★★**我們一直把「建造」當成一件事在追，而它是【兩條獨立的路】**：
| 路 | 做什麼 | 實測（`peaceful_economy`／`seed 1337`／30 天） |
|---|---|---|
| ★**founding**（新建 outpost） | `_dispatch_builder` | **day 0 嘗試 39 次、全部卡在材料閘、之後 30 天零嘗試** |
| ★★**facility**（在自家 outpost 上蓋設施） | `_resolve_build_facility` | ★★★**30 天內【一次都沒有】產出過 build candidate —— 連 day 0 都沒有** |
⇒ ★**漏斗那欄 `cand.build` 量到的是 founding，不是 facility。** ★★**facility 這條【從來沒有 fire 過】。**

★**逐日分桶的漏斗（`main`，`peaceful_economy`／`seed 1337`／30 天）**：
```
day |  cand  build |  decide  win_cand |  deleg  br_build
  0 |    72    39  |     27       13   |    39       39
  1 |    49     0  |     16        9   |     0        0
 29 |    75     0  |     18        6   |     0        0
```
★★**候選總量越後面越多（49 → 75）、決策每天在跑、candidate 每天在贏 —— 只有 `build` 那一欄 day 1 起永遠 0。**
⇒ ★★★**斷點在 `frontier_candidates`（提案生成），不在 argmax、也不在 dispatch。**

**★已答一半（2026-08-26，窮盡 grep ＋ code read）**：
- ★**「在但被判 satisfied」＝【不可能】** —— `satisfied` 全 repo **只有一個賦值點**（`goal_resolver.gd:43`），
  **被 `MAINTAIN_GOAL_RES` gate 住**，而 `MAINTAIN_GOAL_RES`（5 個）與 `BUILD_FACILITY_GOALS`（8 個）**完全不相交**
  ⇒ ★★**`build_*` 永遠不可能是 `satisfied`；那 937 筆全是 maintain goal「這輪不缺」＝正常運作。**
  ⇒ ★★★**systems 曾寫「30 天零建成卻 937 次 satisfied」當矛盾 —— 那是【類別錯誤】，拿 build 的結果比 maintain 的狀態，已作廢。**
- ★**真正的消失路徑 ＝【被移除】**：`goal_resolver.gd:57-63` 四個 `continue` 條件任一成立
  （`otile == null`／`outpost_type` 不在 `allowed_outpost`／`current_level > 0`／`_facility_deficit < CONSTRUCTION_DESIRE_MIN`）
  **就把 goal 從 `goal_state` 整個拿掉**。★★**四個條件哪一個成立，尚未量。**

## ✅⚡效能 arc（事件比例計算）收束（2026-08-27，blueprint 點頭）
### ★出口用的是【重定義後】的那組，不是原本那組
★**原出口「零 LOD、50+ 隊可跑」在 slice 0 一量就已達成**（35~143 隊 baseline median 全在 16~31us）
⇒ ★★**blueprint 裁：已達成的目標不能當出口** —— **重定義為「A 攤平 ＋ B 處置定案 ＋ 長考 wall-clock 預算重估」。**

### ★★真正的病（五顆探針換來的）
```
spike ＝ 每小時一次（間距恰好 = TICKS_PER_HOUR）｜中位數 ~6.8 秒／次
★不 ∝teams（101→202 沒放大）｜★不 ∝tiles（radius 3.84× 不單調）｜★★★是【常數因子】問題不是複雜度問題
靶 A：loop3.orders_ambition cadence 對齊 burst（~8/45 個 spike tick，burst/non-burst ＝ 3.5×）
靶 B：整條決策路徑穩定地貴（單次 rank_scored 100~150ms、均攤，top-1 只佔 1.8%）
      └ gather.* 對 dt ≈ 35%（★跨頂層：rank_scored ＋ rank_survival 兩條路）
```

### ★★★落地
| 刀 | sha | 結果 |
|---|---|---|
| ★**④ 錯峰**（靶 A） | `0ff0dde3` | **「≥100 隊」的 tick 數 2 → 0**｜最大同批 104 → 19｜**最小間隔違規 0** |
| ★**② 髒旗快取**（靶 B） | `fb1a3d8d` ＋ `48aa98df` | **命中率 93.8%**（`rank_scored` 96.0%／`rank_survival` 87.1%）｜**零 stale**（807 配對）｜QA specimen 半 PASS |
| ★③⑤ | — | ★★**撤**（不 ∝teams／不 ∝tiles；⑤ 減隊數不會變快還犧牲世界內容） |
| ① T0 事件驅動 | — | **未做**（②的更徹底版，②之後沒有剩餘價值可圖） |
`fp` 新基線 `06580e7fbaaa4dedc184cb721ffe24f6`｜headless 7 vs 7｜憲法閘 PASS(74)

### ★★★★兩個【誠實的空手】—— ★這是收束帳的主體，不是附註
1. ★**效能收益不宣稱加速**：**全相位合計 −7.0%，落在既有紀錄的雜訊帶（±4~8%）內。**
   ★★**兩把刀都做對了它們該做的事，而總量沒有可宣稱的改善** —— **常數因子問題的正常結果。**
2. ★★**公平性行為面【未驗】**（非「已驗證公平」，也非「有問題」）：
   **`warring_states` 12 筆成交、碰撞 0/12，而 `0.9¹² ≈ 28%` ⇒ 連 10% 的碰撞率都排除不了。**
   ★**拒絕拉長窗湊樣本** —— **更穩健的事實是那條通道實質不活躍（見下一節 4 床證據）。**
   ★★**另兩條疑似通道（`outpost` 選址／`weakest-prey`）從未驗過。**
   ⇒ ★★★**再驗觸發條件：市場成交量到達可統計量級時。**

### ★出口第三項【未做，且刻意】
**長考 wall-clock 預算重估 ⇒ ★排在【時間重錨之後】【★defer token: exam-budget-recalc；★★而時間重錨已落地 ⇒ 本條已逾期一次，2026-09-06 重新裁定】**（blueprint 准）——
★★**重錨會改所有 tick 語意，現在估的是【作廢數字】，不留。**

## ⏳ g1a 舊根/新根差異＝【未歸因】，但帶著三條已排除的路徑（2026-08-27，S2 重錨）
**現象**：同 fixture、同 seed，**舊根 headless 蓋 `workshop`＋`mint`；新根蓋 `farming`×3**。
★**而「這是重錨造成的排序改變」這個因果解釋【已被撤回】** —— 逐決策 trace 打掉它。

### ★★已排除的三條（★寫下來是為了下一個人【不要重走】）
| # | 排除的路徑 | 證據 |
|---|---|---|
| ① | **「重錨改了決策排序」** | ★**舊根／新根【決策序列逐筆相同】（96 筆）**；`farming` **根本不在候選清單裡**；`mint` **每一次都贏（util 8.64）** ⇒ ★★**卡點是【贏了但買不起】，不是【選了別的】** |
| ② | **「孤立 fixture 能重現」** | ★**孤立床【重現不出】原觀測** ⇒ ★★**該 trace 只證明「在這條孤立路徑上重錨不動決策」，不涵蓋 headless 那個差異** |
| ③ | **「RNG 流位置被重錨位移」** | ★**兩根在 g1a 前都 `seed(1337)`，結果仍分歧**（舊根 `mint=1` ／ 新根 `mint=0`） |

### ⇒ ★★★狀態：**未歸因**，而它【不是空白】
★**差異真實存在（兩份 headless 結果不同），而三條最可信的解釋都被打掉了。**
★★**刻意不再往下追的理由**：**繼續加東西進孤立床去重現 ＝ 把 headless 的複雜度一點一點搬進來 ——
搬到重現為止的那一刻，手上就是另一個 headless，不是一個可解釋的 fixture。**
★★★**再開的觸發**：**若日後有【別的】症狀指到同一段（`mint` 買不起／設施選序），把這條翻出來一起看。**

## 🏪 市場撮合幾乎不發生（2026-08-27，效能 arc 公平性量測【順手】挖到，★歸經濟線非效能 arc）
量「先搶先贏是否給 offset 優勢」時窮盡試了 4 張床，挖到一件跟效能無關但經濟線該知道的事：
| config | buy 嘗試 | sell 嘗試 | ★成交 |
|---|---|---|---|
| `perf_scale` | — | — | **0** |
| ★**`merchant`**（★**專為貿易設計**：商隊 tag ＋ coin/goods） | 93 | 260 | ★★**0** |
| `econ_bed` | 0 | 0 | **0**（★連撮合都沒被走到） |
| `warring_states`（2000 tick） | 95 | 325 | ★**12** |
★**bail 原因（`peaceful_economy`）**：`sell_no_surplus 6`／`buy_no_stock 1`／`buy_no_want 1` —— **賣方沒餘糧。**
⇒ ★★**連「專為貿易設計」的床都是 0 成交** —— **這不是床沒調好，是【世界沒有可交易的剩餘】。**
★★★**與材料 arc 收束的「世界就是窮」（`lt_cost 182/257 ＝ 71% 連物理成本都不到）完全一致。**
★**歸屬**：**經濟線／規模經濟 arc**（blueprint roadmap）。**此處只記事實不開藥，效能 arc 未碰它。**
### ★★★重納觸發（blueprint 命 2026-08-27）—— ★掛在這裡，因為做重基線／量市場的人一定會打開這一條
```
★觸發條件：市場【成交量】活過來（到達可統計量級）時
★★要重納的兩件：
   ①S2 統計等價床的「交易成交/日」—— 現被排除在 <5% 判準之外（12 筆無解析度，照印不裁決）
   ②效能 arc 的公平性行為面（先搶先贏的爭奪頻率＋先評估方勝率）—— 現為【未驗】
★★★而「活過來」由誰宣告：★量到市場成交進入兩位數以上且跨床可複現的那個人，不是等有人想起來
```
★**共同形狀**（blueprint 已在 S6／公平性上裁過同一形狀）：**照印、不裁決、不假裝**。

★**連帶後果**：**效能 arc 的公平性行為面因此【現在測不了】** —— `warring_states` 那 12 筆碰撞 0/12，
**而 `0.9¹² ≈ 28%` ⇒ 連 10% 的碰撞率都排除不了** ⇒ **明記未驗，再驗觸發條件＝市場成交量到可統計量級。**

## ★arc 狀態（blueprint 裁 2026-08-26）
- ★**A（拉高 forest 初始庫存）／B（伐木場加速）＝ 停站** —— **世界堆滿材料也一樣沒人提要蓋。**
- **B ＝ 帶條件封存**（不拆出去）：**若「賽跑」框裡開採速率日後真的成為 binding，再回來。**
- **用戶深層 WHAT（開採／賽跑／地理張力）不動**；**意圖帳 material row 的補註，等 day 1 謎底一起寫、由 blueprint 呈用戶。**
- ★**D（`cost × 1.5` 閘人格化）已 merged** —— ★★**它從來就不是解鎖用的，驗的是形狀不是解鎖，這點在票裡先寫死過。**

### ★material-need bootstrap gap（code-provable，reviewer R² 2026-07-30 揭）
`NeedOracle.need_keep(material)` 對**無 outpost 隊結構性恆 0**：`_self_use(material)` material∈`PURE_INTERMEDIATE`(need_oracle:100,111)→0；`_supply_chain` 無設施→0；`_construction_facility_need` `_find_own_outpost==(-1,-1)`(need_oracle:38-40)→0。∴ `goal_resolver.gd::ensure_maintain_goals()` `holding>=need_keep(0)` 恆真→吐空、**founding 分支(:206-219「★A1 founding」)碰不到**。**⇒ 雞生蛋 bootstrap gap**：無 outpost 隊永不「想要」material（need_keep≡0）→永不因缺料立國拿料；material-founding 動機**只對已有 outpost + 缺料設施需求的隊**存在（established 隊建 secondary forest outpost 供設施）。**fresh 隊 settle-motive 走 settle_fit（上述三段①，已知 flat/broken）非 material。** 這是 A1「缺料→立國」假設的 code-provable 修正：該動機對 fresh 隊不存在（bootstrap gap）、對 established 隊 gated on need_keep>0。折入 means-end 全系統（need 沿依賴鏈上傳 chaining 該讓「想建設施→缺料→缺 outpost→想 found」串起來）。連 [[project_food_flow_runway]] measure-first Step0（①fixture 據此修＝established 隊測 live secondary-founding，非 fresh 隊死 fixture）。**用戶兩原則**（memory `feedback_whole_system_first`）：①健全系統才有價值模擬結果 ②整個系統做完當 whole 才 measure，非邊建邊 patch。**∴ material 全 PARK**（settle-motive/伐木場/regen/初始庫存/gate②/BUY 弱閥）until **means-end/長程計畫全系統**（2026-07-19-long-range-planning-brainstorm.md，scope=B 全四塊：慾望 registry × means-end 依賴圖 × applicability 湧現順序 × 折現/承諾）設計+建完當一個 whole。L1 大功能，brainstorm（用戶主導）→spec→plan→implement。★架構 orientation：機制大半已在（`option.applicable`=前置 gate、`rank_scored`=湧現順序、`NeedOracle`=need 傳播），缺口=(a)need 沿依賴鏈上傳 chaining (b)goal-as-chainable-option → 實作=擴非新引擎。

### order-noise（arb_kill_nostock 42k-84k）= hollow-economy 症狀（measurer 確診 2026-07-24，同根不獨立修）
kill_nostock 99.96-99.97% 集中在 tools/weapon_melee_low/weapon_ranged_low，這 3 種 **production=0**（cross-ref harvest_carry+manufacture_output 雙源）——沒隊在產（沒 weaponsmith/manufacturing 設施＝EXPAND 100% 失敗互證）→ 掛單找不到貨 → kill_nostock。material 本身有 production（362-556）且**零 kill＝非噪音源**。∴order-noise = **means-end/facility-scarcity 同一根的下游症狀**，非獨立 order-layer bug；root（means-end 全系統）修好自然消退，**不需另開 ungrounded-order-layer 修復工**。（(b) ungrounded 掛單分支 measure 排除。）

### ★★measure-first Step0 收斂結論（和平經濟床，2026-07-30，用戶核可 measure-first）
和平經濟床（`config/peaceful_economy.json`+`peaceful_economy_bed.gd`，merged 7fdb6439，好戰=0 12 隊 sharp 缺口）量 4 問（seed70730 6mo）：
- **Q2 develop fires**（`complete_upgrade_facility=6`，own-outpost 升級真完工）。**Q4 runway 感官活**（`foodflow.update=4594`）。**∴economy 動機真 fire、非「完全不發生」**（confound「warring 壓經濟」量掉了）。
- **★★兩根收斂＝GATE-B 買撮合（binding 根）**：①founding `complete_build=0` **非 bug**——`action=build=0`/`indep.found_*=0`＝founding-build 從不 dispatch，因 **buy-preempts-founding**（`goal_resolver:200-203` 買候選在 :206 founding 之前；①隊 coin+市場可達→買候選永遠先返回、founding 從不生成）。founding=正確 fallback（買不到才 found）、買=primary。②trade `order_fulfilled=0`/`trade.deal=0`（狂下單 1833 零成交）＝**GATE-B 買撮合 broken**（`_market_visitor_buy` interaction:781 只從抵達 tile granary 買、賣方 surplus 沒進市場 granary→`buy_no_stock`）。**①founding 被 ②trade preempt+失敗擋＝同一根**。fix GATE-B → material 經買滿足 → economy 真活。
- **★binding 根＝GATE-B 買撮合分配機制**（already-diagnosed known_issues 下方 GATE-B 段+:504 ruling 固定市集；**large economy-arc、大於 GATE-A**）。blueprint 判「續攻已知 execution-completion 家族根、不 pivot」＝GATE-B 是收斂點。**攻 GATE-B（economy 鑰匙）進行中**。
- **★vision Q 升用戶（blueprint 帶，不擋 GATE-B）**：買驅動經濟 vs 用戶伐木/賽跑願景（誰先砍 forest 優勢=founding 當 primary）可能 mismatch；**founding-attractiveness（讓立國獨立於買可達也值得選）等用戶回**，別為賽跑願景在 GATE-B 前塞 founding 補丁。
- **★active-construction persist floor＝現 BANKED（2026-07-31 blueprint 裁 bank+文件化，f84fdd22 merged）**：`persist_strength.gd CONSTRUCTION_ACTIVE_FLOOR=0.15`（施工中隊 TASK_BUILD+ticks_left>0→persist_eff=max(computed,FLOOR)保護免 routine argmax 搶班）。**曾 HOLD**（target founding complete_build>0 未達）——**現 bank 的 rationale（HELD 主因 moot）**：①verified-safe（R² 雙線非凍紅線清白 + merged gates 全綠、含觸 RELEASED persist 交互驗過）②**HELD 主因『founding 未達』moot**——measure 定案 founding 決策 fire 正常（買 preempt=正確 fallback、非決策壞）、且 **floor 本就保全 active-construction（含 upgrades 真完工 6→7）非只 founding**③re-pick 條件『economy work active』到（SLICE A convoy 在修 GATE-B delivery）④誠實測：條件變我會主動 re-pick（founding-target moot+驗 safe+construction-commitment measured-real 07-25）＝非 accident-convenience、是條件真變。★**共 worktree 誤帶入是 process slip（見 memory HELD 隔離），但 bank 本身經 blueprint 裁定+此 rationale=clean provenance 非默默 accident**。連 [[project_persistence_unification]]（RELEASED + construction floor 延伸）。

### ★資訊網 arc：核心機制 VALIDATED（fixture）但 whole-world distribute 未通（2026-08-05 QA CONFIRM-WITH-REVISIONS 誠實 flag）
資訊網 arc（求援 letter→領主聞→賑濟 side-dispatch→免費直注 convoy）**核心機制逐站 VALIDATED**（T1 fixture 全鏈真、糧真到、7+ 輪剝殼）。**★但 QA 對抗審揭誠實 scope 限制（鎖字前必標、非機制假）**：
- **whole-world distribute 未通**：全 49 隊 warring 床 `distribute.deliver=0`（main/branch 皆然）——relief 鏈只在專屬 T1/T3 fixture 走通、**一般 settled 經濟 distribute 仍 0**（warring solo-heavy 少 faction-resident relief 案例）＝踩自家 `jia honest_premature_victory_flag`（窄床 accepted≠general）。**禁 resolved/fixed 描述一般經濟紓困。**
- fixture 內 T1 day38-54 17 天 food=0、pop 9→2＝「間歇投糧撐命」非「穩定復甦」。
- seed-cascade（warring 1337 惡化/42 改善）=**plausible 非 confirmed**（量級 4.5x unrest 無逐 tick 因果鏈）。
- T2 scout util fixture 恆 -0.8=genuine no-target cost（T2 factionless）非 stub、但此 fixture 未 demo scout 人格（人格分化只 help-seeking 側證）。
- **→ whole-world distribute 通用 = economy-balance/L3 補完批**（[[project_information_network]] backlog）。連 [[feedback_verify_execution_end]]（premature victory 精化6：窄場景 accepted 當 general）。

### ★★§5 執行塌陷 root REFINE = 三層（2026-08-03，jia-distribute-zero-diagnostic.json 完整診斷）+ 後勤/商業 premature-victory
§5 整合揭執行全塌（`distribute.dispatch=0`+`order_placed=426/fulfilled=0`+`trade.deal=0`+`convoy.dispatch=0`，領主 food=3940 rich 卻居民 pop2 runway0 餓死不救）。完整診斷（4 角度+差分+surface）定 root **三層、非單一 GATE-B**：
- **L1＝propagation dead-end（★兩症收斂同一 root、非「直掃」修）**：`message_system.gd::propagate_on_arrival()` 傳播只在共位發生（`if other.tile_pos != arrived.tile_pos: continue`）→ settled 隊不共位 → 消息 **dead-end 永不傳**。**兩獨立症狀收斂此同一 root**（診斷坐實 `jia-distribute-zero-diagnostic.json` + `famine-flee-diagnostic.json`）：
  - **甲 distribute 敗**：居民買單沒傳達領主 team_known（`goal_resolver.gd`（★L2 錨：檔級） received_buy_orders 恆空）→ 領主坐擁餘糧不救自家餓死居民。
  - **居民餓死**：food 賣單沒傳達居民 team_known → `food_seek_target` 源②親聞 food 賣單恆空 → 居民**學不到哪有糧** → 遷移找糧 not-applicable → 餓死。**注**：非結構 pin bug（resident 給可達已知糧源即 relocate、與 mobile 同、(a) REFUTED）、非人格撐死（relocate 決策會生成、只是沒 target）＝**純資訊餓**。
  - **★＝架構信號**（同型缺口重複、[[feedback_structural_audit_complement]]）：修 propagation 無死角**一解多症**、非逐症 patch。
  - **★修法（用戶定 2026-08-03，否定原「直掃」；資訊網 arc）＝修 propagation 讓消息無死角傳達（延遲/decay 保 fog、非硬擋、非開領主直讀特例）**＋**「有意收集/傳播」=思考層決策**（餓村莊決定求援派信使 / 領主決定派信使查、**人格秤 util 非死常數門檻**）。見 invariants.md「資訊永遠傳播」段。原直掃 spec 已 SUPERSEDED。HOW spec 待 blueprint user-confirmed WHAT 框定。
- **L2 同格跨勢力貿易交易面窄**：`interaction:731-813` 只 owner public_storage、非 team.resources（用戶 WHAT=broaden 同格 willing→team.resources、bounded 非 O(N²)）。
- **L3 隔格跨勢力貿易**：`read_market_board`（order_system:194）須賣方物理抵買方市集、settled 不巡→從不讀外單。深、最大 remainder、需循環/carrier flow。
- **非 (ii) 決策層**：distribute 生成即 rank0 贏 util1.33、deliver 生成 candidate、convoy/argmax/throttle 全 fine（診斷 test_B/D）。binding=**上游買單物理傳達**（感知鐵律兩路徑 co-location carrier `order_system.gd::read_market_board()` + 市集看板 `order_system.gd::read_market_board()` 皆須物理在場，settled 隊不共位/不巡市集）。
- **★premature-victory CONFIRMED（不 paper over）**：「後勤 SLICE A convoy fulfilled 0→6 修好」= scenario-specific——0→6 在「買單已在賣方 team_known」近距 fixture fire；一般 settled 各據點不共位→買單不傳達→convoy.dispatch=0。SLICE A 修 candidate生成+convoy執行層、**未修買單傳達層**。「商業 market-as-place 修好」同款（deal~1-2、market 未大 revive、`sell_no_surplus 51.7%` known wall）。窄場景 accepted ≠ general working（[[feedback_verify_execution_end]] 精化6）。
- **序建議**：L1（de-patch、§5 impact 最高、cheap）→L2（用戶 WHAT surface）→L3（循環 remainder）。待 blueprint WHAT 裁序+L1 感知鐵律解讀。**上方「GATE-B 買撮合 binding 根」段＝此 refine 的粗粒版**（GATE-B 是 L2/L3 的一部分；L1 intra-faction 是新拆出的更根本層）。

### ★★constitution_gate god-view detector 盲點：間接 local-var 存取漏抓（2026-08-04 R² 揭、系統性追蹤）
`constitution_gate.gd:40 GV_TEAMSTATE_RE` 只認**字面 `state.teams[id].<動態欄>` 鏈式** pattern——**漏「先 `var X: TeamData = state.teams[...]` 存 local var、再隔行讀 `X.population`/`X.food` 等動態欄」的間接寫法**（比鏈式更常見自然）。血證：`goal_resolver:_distribute_candidates` `_resident_food_runway(resident)` 直讀 resident live pop/food=god-view，**活過本 session 多輪 review（SLICE B/L1/資訊網 R①R²）+ 人審多次直讀該區、皆沒抓到**（不在 baseline_v2 白名單=從沒被 gate 碰過），直到 measurer 實測+diagnostic 才浮出（distribute de-scan 已移除此違規）。
- **★意味 codebase 可能還有同款盲點殘留**（其他間接 god-view live-read 逃過 gate）。
- **追蹤（systems）**：①**兩階段 grep 掃 `scripts/simulation/decision/` + `faction_ai_system.gd`**（先找 `= state.teams[` 賦值、再對目標變數名找後續 `.population`/`.food`/`.coin` 等動態欄讀）看殘留同款；②**強化 detector**（GV_TEAMSTATE_RE 認間接 local-var 存取、或加 data-flow 粒度）。連 [[reference_constitution_gate_marking]]（機器證>人審 completeness、但機器本身有 pattern 盲點=需補）。

### ⏳資訊網名冊 ④分裂 frozen-snapshot 未實作（known gap、2026-08-04 R² 訂正）
bootstrap fix 名冊（faction 成員知自家固定據點位、`_faction_roster_pos`）**MVP 用 faction-gate 讀當下 `faction_id`**——分裂後對 ex-faction 回 -1（零資訊）。**★這 ≠ 用戶 ④ 硬界**（原文「分裂=名冊凍成 belief 快照帶走、對方後續新建/棄置不知會過時」＝帶走一份**會變舊的快照**）。MVP 是分裂瞬間零資訊、**連快照都沒**＝機制不同（R² 抓我原「達 ④ outcome」自我認證過頭）。**non-blocking**：現 Part2 消費者（help=自家領主/scout=自家子民）只鎖同勢力當下、**無人讀 ex-faction 位** → 現無害。**未來若有消費者需「分裂後仍知對方舊據點 stale」→ 另 slice 建 stored 名冊 snapshot + copy-on-split**。連 [[project_information_network]]。

### ⏳糧流 Slice4(b) 和平 economy measure — 首批驗收 tripwire（B1 merged c82a685e，2026-07-29）
糧流 runway arc：**Slice A（糧感官）+ B1（糧橋 go/no-go + 通用 food top-up）已 merged**（reviewer R² CLEAN + blueprint JUDGE merge=YES），機制正確、bank 起 infra。**但 A1 build=0 execution-verified 坐實=founding 從不 dispatch（warring 無動機、糧橋 bridge_nogo=0/topup=0 從不 fire）＝A1 folds material/經濟 arc（founding 動機=料驅 economy 非 runway 糧食軸）**。B2/B3/C **PAUSE**（blueprint 帶 roadmap fork 問用戶：pivot economy/motivation vs 續 runway 糧食軸）。
- **★首批必驗（reviewer R² 追蹤項，別靠 aggregate 矇混）**：economy 起、founding 真開始 fire 時，**礦山站子隊完工後撐不撐得到自足**必第一批驗（非只驗一般 plains 站）。疑慮：B1 通用 top-up `_need_food = pop×FOOD_PER_PERSON×(eta_travel+eta_build)×1.5` **只算建 outpost 本身 ETA、沒算「蓋完後還要蓋第一座設施才自足」那段**——舊礦山 bootstrap（`BOOTSTRAP_DAYS=50`，已被收編刪除）comment 自承涵蓋施工+設施全周期（礦山格種不了田、自給食物極低）。親算 civilian lv1 `eta_build≈16.7 天`×1.5 顯著短於原 50 天＝**公式概念性縮水**，非數字差一點。`food_bridge_test.gd` fixture 全 `terrain="plains"` 無 mountain/ore 案例＝這風險**完全沒被測到**，2mo warring aggregate 也因 founding 從不 fire 沒 exercise 到。潛伏非發作中 regression（對非礦山站是純改善），不擋 B1 merge，但 Slice4(b) 首批 spec 開頭必列驗。連 [[feedback_verify_execution_end]]（機制對 target 不 fire＝該驗場景從沒真跑過，team14/A1 同款）。

### ⛔A1 stall latch+resume = **凍化 seed1337 世界 REGRESSION**（乾淨 fresh 重現坐實 2026-07-26，別 merge/folds until 根治）
construction commitment latch+resume（branch 5b166eb1，已 revert 出 main 5292faec）**凍化 seed1337 世界**：乾淨 fresh 重現（worktree=純 5b166eb1 確認+cache 清+full re-import）seed1337 monthly `_snapshot`（真 `state.teams.size()`+pop）**71/438 逐月不變 attrition 1.4 = 凍**，vs fresh 現 main（means-end 無 latch）**71→63 churn 動**。∴ **凍源=latch+resume 本身**（非 per-action tap 37f2ce31、非 pre-existing means-end、非 curve artifact）。seed42 動（seed-specific）。**★翻用戶「latch valid 健康」前提——latch 不該 merge/folds 進手統一 until 凍化根治。**
- **✅矛盾解（measurer isolated A/B 2026-07-28）**：12.39%「動」是 **specimen tracing 假象**。同 5b166eb1+seed1337+worktree、唯一變因 specimen on/off → OFF 凍（1.35%，你我一致）/ ON 動（9.0%）。**latch 真凍確認**（specimen off）。★諷刺：observer bug 擾動反掩蓋 latch bug。

### specimen RNG leak（2026-07-28，★源訂正兩次收窄：非 tracer wrap、非既有 helper，是 measurer 一次性 ad-hoc pick_random 已刪）
- **源精確**（implementer bisect + reviewer 讀 code 兩次收窄）：leak **非 `_begin_observe` wrap 漏包**（tracer 實證中性，bisect A/B/C）、**非既有 `SpecimenDumpHelper`**（2026-07-19 untracked，`SPECIMEN_SAMPLE_N` 本來零 RNG strided）——真源=**measurer 那次 temp wiring 用 `pick_random` 選 specimen**（另一支獨立、已 revert 不在 repo 的 ad-hoc 腳本）。
- **結論影響（收窄）**：只 **measurer 那次 pick_random ad-hoc run 發散**（latch json 12.39% 假象源）。用既有 `SpecimenDumpHelper`（SPECIMEN_SAMPLE_N strided）或 tracer wrap 的量測=中性。latch 真凍（specimen-off 你我一致）、aggregate、質性故事都站。
- **修（選項 1，dispatch 中）**：commit 既有 untracked `SpecimenDumpHelper` 進 repo（保全 API：SPECIMEN_TEAM_ID+SPECIMEN_SAMPLE_N+dump 兩參數）+ regression 鎖 SPECIMEN_SAMPLE_N 中性（normal-LOD ON==OFF byte-identical）。丟 implementer 分支窄化版（撞既有、砍 SPECIMEN_TEAM_ID、dump 零參數炸 adhoc_demo）。
- **★★observability_gate followup（第 4 次同族 observer_no_global_rng，blueprint 多次點名，明列此處別靠人工記性）**：機器擋 observe/選取路徑碰 RNG。~~`constitution_gate` 現 `SCAN_DIR` 不掃 `scripts/debug/`、RNG regex 不含 `pick_random`/`shuffle`~~。**✅ 做中（2026-07-29，feat/observer-rng-freeze-gate f79bd8ac，R² 中）**：`observability_gate.gd` ③ RNG scan（observe-pure marker 檔禁 7 向量+negative-lookbehind 逃生口）+ constitution_gate RNG_RE 擴 4 新向量+3 核心檔 marker。連 memory `feedback_observer_no_global_rng`。
- **⏳observability_gate tryset_re 盲區（2026-07-29，regex-blind-spot 家族，非阻斷）**：`decision_tryset` counter `tryset_re=TaskArbiter\.try_set\(.*PRIO_(DISPATCH|SURVIVAL|THREAT)` 只認 **literal** `PRIO_*`。d5b5cb73 threat-oracle-S3 converge 後 `_decide_unified` 統一 commit 用 **`_prio` 變數**（`try_set(...,_prio,"unified")`）→ 逃 regex → **check②（新 commit 點無伴隨 tap→疑漏）對 unified 主決策路徑部分失明**（tryset count 10→3、baseline 已 ratify 到 3）。潛伏非發作（capture_decision tap 本身還在:1621，不是 coverage 真丟；只是 check② 的「新 tryset 無 tap」偵測對 unified path 不靈）。**未來 gate refine**：tryset_re 認 `_prio`/unified path（或改抓 `try_set(` 全形不綁 PRIO literal）使 check② 復全。連 reviewer R² §5（逐行 regex 天生盲區）+ `feedback_observer_no_global_rng` 家族。
- **機制詭異待深查**：latch 只 `_should_reeval TASK_BUILD→false`（施工隊）+ resume orig_recall（少，5）**卻凍全世界 teams/pop**（births/deaths/foundings 全停 day30後）= 機制不通，需逐 tick trace latch 下 seed1337 day25-35 怎麼卡。**code 定位（latch-root code trace 2026-07-28）**：`_try_resume_construction`（faction_ai:2756，呼叫點 :3166）在 `_evaluate_infrastructure`「(2) 擴建設施」`for tile_id in state.world.tiles` 迴圈內、每 `construction_team_id!=-1` tile 呼（先 `check_construction_timeout` 後 resume）→ resume 掃 all teams 找 orig（construction_team_id 隊）release+transition TASK_BUILD。但 orig_recall=5 少、不足以解「凍全世界」——**真機制（skip reeval 連鎖 / last_decision_tick 凍 / force_reeval 副作用 三假說）需 runtime 逐 tick trace 定**（blueprint 認可 compact/fresh 後做，重工別在快滿 context 跑）。
- **★systems 診斷教訓（memory `feedback_avoid_rabbithole` 已記）**：凍源我 3 次翻轉（non-tap→tap→latch），前兩次 code 論證/舊 json 對照猜錯，第 3 次 worktree cache-stale bug，**乾淨 fresh 重現（full re-import 排 cache）才坐實**。
- A1 核心（新 outpost founding `construct.complete_build`）兩 seed 皆 0（但在凍化 run 上=suspect，clean 重量待 latch 修）。

### ✅SurvivalMergeIn churn = (b)arrival-never（根修 MERGED `7877310a`，2026-08-19；缺口②③④待下游高壓輪覆蓋）
農業b popcap 長跑揪出：`[SurvivalMergeIn]` 全期 **698 行、同對隊反覆**（Team58→27 54×）、team 暴增 **49→242+**、per-tick avg 793ms/peak 20.2s=**40-70× perf degradation**。**probe-pin 定案 (b)arrival-never**：`join.resolve`（`_resolve_join` 真 fire）2mo 僅 7 次（3mo 外推 ~10-11）vs commit 698=**1.4%**；`accept.join_reject`=11 同量級（(c) host 拒非主因）；`mergein.dissolve`=1/`subteam`=6（resolve 後分流、非成因）。∴ joiner commit JOIN（`TaskArbiter.try_set` 成功）後**大多從沒真移動抵達 host**、每 cadence 重評又重 commit 同 target=**committed-but-never-resolves**（[[project_hand_obeys_brain_arc]] 家族、12mo 大考 #4 travel/arrival persist 前科、S2b corvee persist cousin）。**resolve 路本身沒壞**（`_resolve_join`/`_resolve_mergein` 走到時運作正常、reviewer 親讀確認）——根在**上游**：try_set 後 movement 是否真朝 host / cadence 重評頻率是否比移動到達時間短 / host 移動中追不上。**★attribution**：churn 機制**疑 pre-existing**（JOIN resolver/persist=main、非農業b 引入）、**農業b 弱隊 cap 放大現形**（cap<5 佔 5.3% 弱隊間接餵養）；未跑 main baseline 對照坐實。**★下游污染**：labor-v2 controlled starve 32 之中含「弱隊想逃生卻到不了」的 **churn 人質**→ blueprint 裁 churn-fix 先 merge、labor-v2 疊上 combined re-measure 才記真 accepted cost。**fix in flight**：investigation-slice（T1 runtime-trace pin i movement 不執行/ii cadence 重評 reset/iii mobile-host chase → T2 手不聽腦根修 persist-to-arrival、禁在 resolve 端疊繞過補丁）、spec `2026-08-19-mergein-churn-arrival-pin-HOW.md` R²-CLEAN。

**★根修 MERGED `7877310a`（2026-08-19）**：T1 控制床 6 場景 pin 出根=**(iii) 移動 host + belief lag/失聯**（場景 D=host 動+belief 只在委派當下→20 日零到達卡 ghost tile；A/B/C/E/F 真到達=排除 movement 不執行/重委派單獨致命）+**結構根=`TASK_JOIN` 無完成/放棄契約**（窮盡驗 release/timeout/clear 零命中；TRADE 有 `TRADE_TIMEOUT`、STATION 有 `STATION_TIMEOUT`、JOIN 皆無；crisis-override `:389` 是泛化安全網但只深餓才 fire=非普遍出路）。**修（三件、全走既有結構非新機制）**：①JOIN timeout 進**既有單源塊**（TRADE↔STATION 之間、`JOIN_TIMEOUT`=6日+殘距×12h/hex 鏡射 TRADE 款）②**撲空 abort**=committed JOIN+已站上/清 move_target+`BeliefSystem.belief_pos(self, social_target)==(-1,-1)`→release（**讀自己 belief=感知鐵律、非 god-view 查 host 真位**）③`_release_failed_join` 寫 `join_rejected` memory→走既有 finder cooldown=**防 release 後重選同 host 的 churn 換皮**（systems 加的必要件）；proximity 不加（場景 E 證 belief lag 追擊仍能 resolve）。**gate**：控制床決定性 **PROVEN**（abort/timeout 真 fire + task 釋放 + memory 寫入 + `social_target` 清=**同對隊換皮結構性不可能重演**；不誤傷=host 靜止可達正常 resolve、零 false abort、真 merge 發生）+ headless 0-new + constitution 77。**attribution 坐實=pre-existing**（★**citation 已訂正 2026-08-20、QA 稽核抓 defect**：原引「plain main partial 跑 signature ×3」**查無此文**——那 log 被 wrapper timeout-kill race 吃成空檔、且 headless fixture `Team700` 子字串誤撞；**真證據=`docs/measurements/2026-08-13-phase3-panel-raw.txt`**[2026-08-13、農業b 與 churn-fix **都還不存在**時的純 main 長跑]`SurvivalMergeIn team=Team70 → 併入 Team37` **重複 69 次**+Team70→Team11 → **結構上不可能是農業b 引入**、比 code-read+partial 猜測更硬；QA verdict=REVISE 非 refute、方向對且更強）。
**★缺口（誠實、非 blocker）**：②churn 消比例 ③team 不暴增 ④perf 回正 **未在農業b 同量級高壓（49→242 隊 / per-tick 793ms / 40-70×）復現**（organic plain main 天然 churn 量低、n 太小）→ **由下游 labor-v2 combined re-measure + 農業b re-measure 兩輪覆蓋**（那才是高壓場景）。

### ⏳JOIN 在途重申 CPU + ★pair-print 非有效 churn 指標（2026-08-19 農業b final round 揭、systems code-read 定性）
**①指標訂正（重要、防未來誤判）**：`[SurvivalMergeIn]` **log 行 (joiner,host) pair 次數 ≠ churn 次數**——print 在 `faction_ai_system.gd::_trigger_survival()`（survival 路 `_trigger_survival` 每次 rank 選「併入」都印），**committed JOIN 在途期間**（`JOIN_TIMEOUT` 6 天+殘距）每 cadence 會 **re-set 同 target 並再 print** → pair 數把「**在途重申**」與「**跨 episode 重演**」混算。`join_rejected` cooldown（`JOIN_REJECT_COOLDOWN_TICKS=480`=**2 天**、`decision_context.gd::gather()` gate `has_acceptable_join_host`）**只在 timeout/abort/拒收「事後」才寫**、擋不到在途重申（設計如此、非漏）。∴ **修前 698 行/54× vs 修後 1647 行/81× 的比較無效**（雙重不可比：同樣被混算污染 + 698 是 day65 partial vs 1647 是 day90 full；且原輪 full stdout 被 wrapper race 吃掉=無有效對照值）。**有效 churn 證據改用**：team 暴增（同 day90：242→**152**、-37%）+ 出路真 fire（abort_ghost 21 / timeout 1 / reject 33）+ 控制床構造斷根（`mergein_join_lifecycle_test` PROVEN）。
**②真 follow-up（cheap、非 blocker）**：在途重申**燒 CPU**（每 cadence re-rank + re-set 同 target + print，無狀態進展）→ 候選修=committed JOIN 在途時 survival 不重複 re-set 同 target（=hand-obeys-brain 家族的「**重申抑制**」、屬既有 persist/commitment 語意延伸非新機制）；順帶讓 pair-print 恢復成可信指標。排 §4 之後。

### ✅specimen 非中立性 —— **根修已 MERGED（2026-08-21 結案）**：掛 tracer 讓模擬軌跡真實分岔（2026-08-20 measurer 意外撞到、威脅所有 specimen-based QA）
**現象**：同 seed/config/branch，Pass1（無 specimen）`death.starve_anon=28`、Pass2（7 隊掛 tracer）=**26**，Team10 死亡型態亦改變 → **掛 specimen 本身改了世界**；specimen.jsonl **不能當精確重播**、只能當「同類型典型軌跡」。
**★systems code-read（既有三道防線都在、分岔源不在它們）**：①`is_specimen`(specimen_tracer:21) 純讀零 RNG ②capture 路徑(:56/86/107/148) **全包 `_begin/_end_observe`**（`Probe.enabled=false`+`suppress_observe_noise=true`）③**LOD-exempt 已移除**(`sim_runner:506-507/518`)。
**★假說（待 implementer investigation 查證/否證）**：**非 RNG 的狀態副作用**——tracer re-query 呼叫**帶 lazy cache 的系統**（`LaborSystem.ensure_fresh`、belief snapshot/`known_member_states` 寫入、market memo、PathSystem 快取）→ 提前暖化/更新 → 下游行為改變；`_begin_observe` 只擋 RNG+Probe、**擋不住 cache/state mutation**。
**★影響**：QA 故事稽核建立在 specimen 忠實重播上 → 判決可信度打折。**invariants §83 保證範圍要擴**（原測「全域 specimen 開/關 byte-identical」、未涵蓋「對特定 team 開」窄情境）。**修前**：specimen 只當典型軌跡；**非 specimen 的 deterministic 量測不受影響**。

### ⏳零產出卡死（2026-08-20 lag-quantify 副產、與 honest-under-fed 不同病型）
28 起 starve 死亡的 7 隊裡：**team9/4/5 全程 raw `daily_rate` 精確 0.000**=**生產完全停擺**（非慢性遞減）；**team4/5 全程 `task=return_home`**（返家途中餓死、趕不及=**非決策錯**）。→ 「零產出卡死」需獨立診斷（為何完全沒有任何 income：無 tile 可採？勞力全抽走？task 卡住不生產？）、**12mo 大考留意**。非阻塞。

### ⏳`food_flow_avg` 5 日 EMA 落後（★2026-08-20 降級重寫：不影響死亡判定、只影響決策輸入）
QA 稽核 labor-v2 死亡分類時揭：`food_flow_avg` 是 **5 日 EMA**（`resource_system:20 FLOW_WINDOW_DAYS=5.0`、`:241-242 alpha=day_fraction/FLOW_WINDOW_DAYS`）、**結構性落後瞬時 daily_rate**。死亡明細見多筆 EMA **單調爬向零卻仍為負**（team10 -0.016→-0.008、team9 -0.040→-0.005、team0 -0.114→-0.062）=「真實日流已回正、EMA 沒追上」簽名。
**★★訂正（measurer lag-quantify code-read 坐實）：famine 死亡與 EMA 無關**——`resource_system:157-188` famine_days 累積/死亡**只看每日 STOCK check**（`food_available<food_needed`、satisfaction<0.3）、**完全不讀 `food_flow_avg`**。∴「EMA lag 導致誤殺」**假說不成立**；EMA 的實際角色=診斷 + **AI 決策輸入**。用 EMA 正負號**分類死亡**的準確度=**85.7%**（28 起裡 4 起誤判、集中 Team10）。**剩餘風險（降級後）**：同一 `food_flow_avg` 餵**多處決策**（生育 gate `reaction_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）、野心 rung 積累、crisis/persist safe_factor 等）→ **EMA 落後可能讓決策讀到過時的食物態**：食物已回正但 EMA 仍負→團續留絕境模式（過度保守）；或食物已崩但 EMA 仍正→晚進求生（反應遲鈍）。**現況純假說**（QA 只證了量測分類面）→ 需一輪 measure（瞬時 daily_rate vs EMA 對照、看決策點誤判率）才能定是否要改（候選：決策讀短窗/雙軌 EMA+瞬時、或只在分類/量測面改）。**非阻塞**、排 perf 線索包與 §4 之後。

### ⏳★★perf 真兇=`near.faction_ai` 決策核心（2026-08-20 perf 線索包①② 決定性）+ ★loop1 全量雙掃（LOD 不生效、systems code-read 坐實）
**①phase profile（現 main、10 天窗）**：`near.faction_ai` **獨占 93.1% wall**（191.5s/205.8s）、其餘 near.* 全部加總 <7%。**★systems 先前點名的 4 個候選全部 <0.15%、不是真兇**（l0_settle 0.01% / farm_prodline 0.04% / construction_tick 0.05% / labor_rebalance 0.01%）——原本都缺獨立 phase marker（被吃進混桶），補 tap 驗完發現吃時間的根本不是它們。
**真兇在 `near.faction_ai` 內部**（相對占比前四）：`loop1.factions` 19.0% / `loop1.assign_tasks` 18.8% / `unified.rank` 17.5% / `assign.leader_unified` 12.8% / `gather.market` 6.7%。
**★★具體 finding（measurer 指出 + systems code-read 坐實）**：`_evaluate_all_body(state, _team_ids)`（`faction_ai_system.gd:712`）**參數 `_team_ids` 底線前綴=刻意未用**、迴圈 `for fid in state.factions`=**全量 factions 掃**；而 `sim_runner.gd:152` `faction_ai` entry 是 **`lod: LOD_BOTH`** → **faction 層決策（member_snap/update_goals/assign_tasks/infra/diplo）每 tick 全量跑兩次（near pass + far pass）、LOD 近遠分流對 loop1 完全不生效**。
- **★blueprint WHAT 簽字 (A)（2026-08-20）**：接受回設計值（`2p`=事故產物、`p`=設計原值；外交/背叛密度從未被當故事量 tune 過→「在 2p 下 tune」前提不成立）。**(B) 補償調 `p` 保留為後備**：若修後具名 gate/12mo 大考顯示**政治質地過死**（外交趨零/背叛絕跡）→ `p` 升格正式設計旋鈕走 tuning 流程（documented、非默默調）、**觸發權在 Story QA verdict**。
- **★★perf③ 實測（2026-08-20、決定性）：去重真實價值僅 `1.72%` of wall**（systems 原粗估「兩桶 37.8% 對半≈19%」**錯**）。30 天/7200tick、涵蓋 72 個完整 100-tick 週期、tick-averaged、call classification 驗過（nondup 720/dup 72 match 理論）。拆分：**一般重評 77.5%**（重複率僅 2.75%、呼叫頻率高）／**infra+diplo+betray 22.5%**（重複率 50.65%、絕對次數少）→ 只修 idb 僅 **0.39%**。
- **★★DEFER 到 12mo 大考後（blueprint 2026-08-20 確認、非待議）**：①1.72% 換「fp intended-change+全故事審+**外交/背叛觸發率腰斬**+可能回退」=收益風險比不成立 ②**★考前改政治頻率會污染大考政治維歸因**（大考正要看結盟/外交/背叛質地）③**blueprint 補的決定性理由：毀掉與第一次大考的可比性**。**correctness 面不變**（每 tick 跑兩次仍是事故、blueprint (A) 簽字**仍有效**）→ **correctness backlog、大考後單獨走**；★**具名頻率檢查（diplo/betray/infra 跨週期前後對比）+ 全故事審那套照量、不因 defer 而降**（blueprint 明示）。
- **★修=行為影響道（非安全道）**：去重會讓 faction 決策頻率 2×/tick→1×/tick=**行為變（fp）**；per perf 憲章需 intended-change 流程 + LOD 紅線檢查 + blueprint 裁。候選形狀：(a) loop1 真正吃 `_team_ids`（近遠各處理自己的）(b) 只在 near pass 跑 (c) **per-faction tick-stamp 去重**（最小 delta：每 faction 每 tick 處理一次、first pass wins）。**未裁前不動**。
- **★誠實缺口（未 root-cause）**：measurer 的 `fai_inner` 累加器總和 696.5s vs outer 桶 191.5s=**3.6× 對不上**（loop1 雙付只解釋 ~10%）→ **inner 相對占比方向性可信、絕對值不可信**、需 code-read 確認 instrumentation 語意（懷疑其他 `DecisionContext.gather` 路徑沒被 gate 在同一 zoom 窗）。

### ⏳~~per-team tick 成本 +34%~~ → ★推論已被 bisect 削弱（2026-08-20 訂正）
**②slice 歸因 bisect（同床同 seed 同窗 10 天、三 commit 嚴格序列跑）**：`94e2f826`(pre-L0) / `3d30b3ed`(post-S2b) / 現 main 在 **49→56-73 團**範圍 per-team 成本**幾乎重合**（2415 / 2463 / **2209** us per team——現 main 甚至略快）、end_teams 也幾乎一樣 → **此規模窗內沒有單一 slice 可歸因的加價**。
**★∴ systems 先前「+34%=三 slice 疊加真開銷」的推論削弱**：那 +34% 來自 **670.6ms/152 隊 vs 793ms/242 隊**，但兩點來自**不同 run/不同 config/不同 day-in-run**、**非同方法論控制**（measurer 標 confound 警訊）；且低 N 區間走勢與那兩點**方向相反**。→ **改判：規模驅動（superlinear）為主、slice 疊加未坐實**。若要鎖定高 N 的真實加價，需 **100-200 團區間同方法論 bisect**（systems 裁：**先不做**、已知非 slice 驅動、優先做 ③scaling 曲線正式版）。
**★★★★三次量測對帳（systems 2026-08-26，slice 0 後補）**：`k≈2.1`（2026-07-05，★**mean**）／`k=0.636` 誠實 NULL（2026-08-20，30 點）／**次線性**（2026-08-26 slice 0：隊數 4.09× ⇒ spike 成本僅 2.79×，**每隊邊際成本略降**）—— ★★**三次沒有一次真正支持 N²，其中兩次是我們自己做的。**
★★★**而「舊結論 50 隊崩」與「新曲線 16~31us」不矛盾**：**舊報 `mean`／`max`，新報 `median`，而 `median` 會把一顆【只出現 1 次】的 spike 完全濾掉**（spike 絕對值 43M~121M us，攤進 12~15 tick 的 mean 正好落回舊量級）。
⇒ ★**真正的結論不是「誰錯了」，是【這個系統的成本不是平均分佈的】** —— **用 median 說沒問題、用 mean 說崩了，兩者都是真的** ⇒ ★★**該問的不是「快不快」，是【那顆 spike 多久來一次】**（長窗待答）。
★**同一顆 spike 這是第三次遇到**：`:846②` 早記過 `near.faction_ai` spike「pre-existing、main 早有」。
⚠️★★**引用紀律**：`:176` 那條 `k≈2.1` **已標「（史）」，但仍被轉述成「真 N² 嫌」** —— ★★★**「標了（史）」擋不住它變成下一個人的規格。**

**★★k 值正式版=誠實 NULL（2026-08-20 perf③）**：30 點 log-log 回歸 **k=0.636/R²=0.567（弱擬合）**、分段劇烈擺動（1.58/0.47/0.71）、與兩高 N 觀測點交叉驗證**都對不上**（N=152 低估 23%、N=242 高估 40% **方向相反**）→ **現單 run 單 seed 方法論不足以定 O(N) vs O(N²)、不該外推 12mo**；measurer 誠實揭露本輪有跨 session **CPU contention**（比率型結論穩健、絕對 us 可能偏高）。**systems 判：不再為 k 單開一輪**（止損準則）、「撞不撞牆」**併 12mo 大考本身觀察**。
⛔**RETRACTED — 不得引用**（systems 2026-08-26 改寫；★原本只標「（史）」，而**它仍在 2026-08-26 被轉述成「真 N² 嫌」並差點決定一整條 arc 的刀法**）
> ~~低 N 冪次擬合 **k≈2.1**（各 commit 2.1/2.7/2.9、noise 大僅方向性）＝超線性、疑 O(N²) 量級 → 12mo 大考規模會更惡化。~~
> ★**推翻它的是**：**2026-08-20 perf③**（30 點回歸 `k=0.636`、弱擬合、交叉驗證方向相反 ⇒ **方法論不足以定 O(N) vs O(N²)**）
> ＋ **2026-08-26 slice 0**（隊數 4.09× ⇒ spike 成本僅 2.79×，**次線性**）。
> ★★**保留原文的理由**：**它曾經看起來很有道理，而知道我們錯在哪比刪掉它有用。**
> ★★★**但它不再是可引用的斷言** —— **要引用 N² 的人，請引上面那條對帳段，不要引這一行。**


day90 `avg=670.6ms / max=17.37s @152 隊`（農業b+labor-v2+churn-fix 疊加）vs 原輪 `793ms / 20.2s @242 隊`。**絕對值略優、但 per-team=4.41ms vs 3.28ms=重約 34%**。★**可疑點**：O(N²) 總成本下 per-team 應 ∝N、隊數**變少**(242→152)時 per-team 該**降**才對、卻升 34% → 指向三 slice 疊加**真的加了 per-team 開銷**（labor-v2 per-labor yield 計算 / 農業b `effective_pop_cap` per overflow check / churn-fix JOIN timeout 塊）。**但**本輪無 phase breakdown、世界組成/faction/encounter 未控制 → **粗量測非定罪**。perf arc 已依止損準則收官（blueprint re-open 條件=**長局跑出新明確熱點**）→ 此條為 **re-open candidate**、需先一輪 phase profile（Phase1 那套 6 階段）才算「明確熱點」。排 §4 之後 / 12mo 大考一併看。

### ⏳`tools/godot.ps1` wrapper timeout-kill race：長跑 stdout 憑空消失（2026-08-19 measurer 揪出、複現 2 次含 solo run）
`GODOT_TIMEOUT` 觸發 `Kill()` 後**立刻** `[System.IO.File]::ReadAllBytes($tempOut)`——被殺進程的 stdout redirect handle **還沒釋放** → 擲 `"being used by another process"` → **整段 stdout 憑空消失**（只剩 sidecar 側寫檔活著）。**複現 2 次**：一次併發 run（可疑併發）、一次 **solo run（排除併發=證實通用 timeout-kill race）**。**影響面**：所有「跑很久、可能撞 timeout」的量測都有**隨機性失憶風險**（本輪 churn-fix organic 大窗的 stdout 就是這樣被吃掉、只能靠 sidecar checkpoint）——非本次獨有、是共用 wrapper 的系統性 infra bug。**修向**：Kill() 後 `WaitForExit()` + handle 釋放重試讀（retry loop with small backoff），或改用 detach 版（`tools/godot-detach.ps1` WMI-parented 路徑）承接長跑。**非阻塞**（sidecar/detach 有 workaround）、排 critical path 後。

### ⏳record_driver 契約 bug：set-style 函式記絕對值非 delta（observability tap 完整性，2026-08-13 嚴格守恆帳追出）
`WorldState.record_driver(entity, field, delta, reason)` 收 **delta**，但 `TileBank.set_amt`(tile_bank:41)/`TileBank.pool_set`(:65) 及 `ResourceBank.set_amt` 傳**絕對值**當 delta（deposit/withdraw/pool_add 傳真 delta ✓；tile_bank:40 註自認「delta 記絕對值慣例」）。**不影響 gameplay**（`driver_ledger` 預設 off、record_driver 純觀測零副作用）**但污染守恆稽核**：measurer 嚴格食物守恆帳第一版 `Σfood_flow` 差 **5600 萬**即此（`regen_food` 每天每 tile pool_set 記整池絕對值疊加）。measurer 已 prototype 真-delta fix（`amt - 呼叫前值`）+ **revert**（temp diag，main 乾淨）。**修** = set_amt/pool_set 讀舊值算 delta（同 deposit/withdraw 範式）。= [[feedback_full_transient_observability]] tap 完整性領域（systems owner）。formal fix 候選、待 blueprint/用戶排序（低急、稽核工具用時才咬）。

### 📉 `food_flow_avg` 不是「庫存健康度」，它是**刻意保守的成長訊號**（2026-08-21，★我先喊 bug、後讀註解的訂正）
**現象**（QA 逐 tick 坐實）：`team10`／`team11` 崩潰剩 1 人後 **`effective_food` 從 0 漲到 368／448**
（持續 18–43 天、`task=貿易`），**而聚合面的 `food_flow_avg` 仍掛負** `@40ab0ab4 2026-08-21`。

★★ **但這不是 bug** —— `resource_system.gd:234-236` 的註解**寫得清清楚楚，是刻意設計**：
> 「離開自家糧倉 → `effective_food` 跌（糧倉不計）→ 一次負脈衝壓低 flow → **偏向不成長（安全方向，絕不假陽性成長）**；
> 重新定居後 EMA 於窗內回復。**移動隊本不是成長候選（生育須安定＋盈餘）**」

⇒ `team10/11` **持續執行 `貿易`（移動中）**，被壓成負 **正是設計意圖**：**移動的商隊不該生小孩。**

**★真正的教訓是「指標被誤用」，不是「指標說謊」**：
| 問題 | 該用什麼 |
|---|---|
| 「這隊**該不該成長／生育**？」 | **`food_flow_avg`**（刻意保守、寧可漏不可假陽性） |
| 「這隊**還在不在流血**？」 | ★**`effective_food`（真實庫存）** —— **`food_flow_avg` 回答不了這題** |

⇒ measurer 那句「四隊 `food_flow_avg` 全程負 ＝ 還在流血」**是誤用**（其中兩隊真實庫存已暴漲），
**但指標本身沒壞**，**生育也沒有被錯誤低估**。

★ **systems 自評**：我看到落差就先寫成「結構性鎖負／影響生育」的缺陷條目，**是先喊 bug、後讀註解**。
**今天第三次**同型（`handback-inbox.sh` perf 檔頭／`godot-detach.ps1` ASCII 檔頭／本條）——
**檔案自己寫了答案，我沒讀就先下結論。**

### 🤝 「投靠」決策正確但**執行沒接上**（2026-08-21 QA 坐實）
`team11` tick10700/10900/10910 三筆完整 candidates：**`併入`（投靠／求收容）util ＝ 2.90–2.91**，
**遠遠壓過第二名 `備戰`（0.76）**，且 **`result=committed`**（真的選了、不是算出來沒切換）。
**但投靠沒有成功脫險**——tick10900 起 task 掉回 `紮營`，`pop` 停在 1。
⇒ **util 算對、承諾也對，是執行完成度斷**（目標可能不存在／搆不到）。

★ **QA 的謹慎值得照抄**：它與 convoy 那類「**決策對、最後一步沒接上**」**症狀模式相似**，
但 **QA 明說「只能指出相似性、不能斷言同源」**——**沒有更深的軌跡可以確認根因是否相同**。
**未開票；併入「決策對、執行斷」家族觀察。**

### 🏕★★★「滿池餓死」的真 binding ＝ **紮營被拿「覓食能全額餬口」當基準線扣掉**（2026-08-21 診斷到底）
**三分流實測**（peaceful／seed 1337／90 天、母隊零採集 **1109 次**）：
| 分流 | 次數 | 佔比 |
|---|---|---|
| (i) 卡絕境門檻 | **517** | 46.6% |
| (ii) 找不到無主可耕地 | **0** | ★**這條假說死了** |
| (iii) applicable 但**秤輸** | **592** | 53.4% |
| `camp.applicable_but_idle`（R² 保險 tap） | **0** | 未命中（**tap 保留常設**）|

★ **(i) 與 (iii) 是同一個 catch-22**：
**不餓** → `food_days ≥ 門檻` ⇒ **紮營不 applicable**；**餓了** → applicable 了，**但必然輸給「立刻找吃的」**。
（`camp.lost_to`：**覓食 157**／遷移找糧 53／買糧 25／併入 18…；**`camp.won_argmax` 90 天只有 12 次**。）

★★★ **第三層零件證據（每次取樣一致）**：
```
inflow_est 8.76 ｜ forage_floor 4.80 ｜ marg 3.96 ｜ daily_need 4.80
camp_u = marg / daily_need × urgency = 0.825 × urgency  ⇒ ★天花板 0.826（即使 food_days = 0）
對手（覓食／買糧，帶 survival boost）：3.17 – 3.30
```
**`forage_floor 4.80 == daily_need 4.80`** ⇒ **`camp_marginal` 拿「覓食本來就能全額餬口」當基準線**，
**扣掉整整一份口糧之後**，才算紮營的邊際價值 ⇒ **紮營的 util 有 0.826 的天花板，永遠打不過 3.17+ 的求生選項。**

★ **而這條基準線與實測世界矛盾**：這些隊**零被動收入**、**runway 1–4 天**、`effective_food` **2.3–9.2**。

**已 de-patch（第一刀，`feat/camp-access` @`bdad0174`）**：拿掉 `紮營.applicable` 的**絕境門檻**（(i) 的閘）
—— **沒有抬分、沒有補償補丁**，價值仍由 `camp_drive` 的真值秤。
**效果（同床同 seed 90 天）**：零採集 **1133 → 978（−13.7%）**、`pop=1` 村 **12 → 10**、母隊人口合計 **35 → 43**；
★**但 `camp.won_argmax` 12 → 11 幾乎沒動** ⇒ **acceptance 未達成，(iii) 才是真 binding。**

**★★剩下的是設計裁定（已呈 blueprint）**：**`camp_marginal` 的基準線該不該計入「永遠覓食 ＝ 永遠停滯」的機會成本？**

### 🌾★★★真根因定案：**站在滿糧池上餓死** —— 沒 outpost 又沒紮營 ＝ 被動採集物理上為零（2026-08-21，四輪翻案後定案）

**因果鏈（measurer 量測 ＋ QA 逐 tick，四輪互相推翻後收斂）**：

1. ★**我的「地格 cap 決定論」死透**：萎縮隊 `terrain_tally = {plains: 9, forest: 2}`
   ⇒ **82% 在 plains** ⇒ **cap 大也照樣萎縮，瓶頸不在承載力。**
   （我當初只從 3 隊推論，**相關當因果**；用戶一句「池不是蠻多的嗎」直接戳破。）
2. ★★★ **決定性證據**：**8／11 萎縮隊站在滿／近滿食物池上**（**runway 61–364 天**）
   **卻 `effective_food` 只有 2.3–9.2** ⇒ **「池滿人餓」成立 ＝ 提取 funnel 斷，不是承載力。**
3. ★★ **確認鏈坐實物理機制**：**無 outpost ＋ `camp_level = 0` 的團隊，該 cadence 物理上零被動食物**
   —— `collect.no_outpost_no_camp_zero_food` **累計 984 次**。
   **正面對照組**：`camp_level = 1` 的 **team10／11** ⇒ `effective_food` **暴漲至 388／457**。
4. **corvée（工期抽走採集勞力）假說**：code 讀**未發現** `labor_pop`／`pool_of` 依 construction 狀態扣減的路徑
   ⇒ **目前不成立**（measurer 自標**信心中等、未做即時快照**）。

**⇒ 一句話**：**這些村不是「地養不起」，是「沒有把嘴接到池子上」。**
**錢買不到糧（`coin=705` 無用）、地夠肥（plains）、池子滿的（runway 364 天）——它們就是沒紮營、沒據點。**

★★ **兩根【不同根】已坐實**（2026-08-21）：
| 問 | 答 |
|---|---|
| 萎縮 11 隊裡 `parent_team_id == -1` 佔幾隊 | **11／11（100%）**，**子隊 ＝ 0** |
| 984 次零採集裡子隊佔幾次 | **parent 960（97.6%）／ subteam 24（2.4%）** |

⇒ **`subteam-survival-ladder` 能吃到的 scope 只有 2.4%** ⇒ **接入 arc 的真 scope 幾乎不縮水（97.6%）。**
★ **這推翻了「兩者同根、ladder 落地後再量殘餘」的排序前提** ——**它們是兩根獨立的病**。
★ **measurer 誠實邊界（照抄）**：**單 seed 單 config（`peaceful_economy`）**，
**「子隊 ＝ 0」這個極端比例可能受此 config 影響**，**多 seed／warring 可能不同**。

★ **這與既有 arc 對得上**（memory `project_size_matter_arc`）：
「**三接入動詞各斷：紮營分數輸／settle 從未 dispatch／建設 argmax 贏但 `try_set` noop**」
⇒ **本輪是那條 arc 的獨立再確認，而且證據強得多**（984 次零採集 cadence、8/11 村站在滿池上餓）。

**★★連帶改寫（第四次）**：
- **生育** `born 1→5` ＝ 修真生效，**但新生兒生在一個「嘴沒接上池子」的村** ⇒ 照樣餓死
- **承載力不是瓶頸** ⇒ **`FARM_UNIT_YIELD` 的 tuning 議程降級**（先修接入，再談產量）
- 「**帶頭銜的獨居者**」的成因也清楚了：**`pop=1` 需求小，涓滴採集剛好打平** ⇒ **個體活、村莊死**

### 👶 生育門檻：anon 與 named **不對稱**（2026-08-21 R² 認可為可接受，記錄供日後對齊）
`breed-anon-eligible` 落地後：
- **named 適齡者**通過**兩層**糧食門檻：團層 `f(rel_surplus)` **＋** 個人 `needs.food > 0.7`
- **anon 適齡者**只通過**團層那一層**（`f`）——因為 **anon 沒有個別 `needs`**

⇒ **同一個世界裡，named 比 anon 更難被算成生育者**。
**R2 判可接受、非阻塞**；**未對齊的理由**：把 named 那層拿掉會**動到現行行為**，不該塞進本刀。
★ **日後若要對齊**，正確方向是**拿掉 named 的個人 food 門檻**（讓兩者都只吃團層 `f`），
**而不是**替 anon 補一層假的個人 needs（那等於把 cohort 拆成個體，是另一個量級）。

### 💔★人死了，關係不會消失：`relations`／`relation_edges` **全樹零清理**（2026-08-21 窮盡搜尋，★獨立於 id 重用的既有洞）
**窮盡結果**（`--include=*.gd`、排除 test/bed、無 `head` 截斷）：
- `relation_edges`：**只有 `RelationGraph.add_edge` 寫入、只有讀取**，**全樹沒有任何 `erase`／`clear`**
- `p.relations`：**只有 `npc_ai_system.gd:122` 一處寫入**，**零清理**
- person 死亡收尾（`npc_combat_system.gd:739-750`）＝ `remove_member` ＋ `persons.erase`，**不碰關係**
- **讀取端不擋死人**：`RelationGraph.strongest`（`relation_graph.gd`）**只比 intensity，不檢查該 id 是否還活著**
`@aa9f3ad9 2026-08-21`

**⇒ 兩個獨立問題，別混在一起修**（R② 明確要求分開報）：
- **(A) 懸空關係（既有洞）**：仇人／恩人死了之後，`feud`／`gratitude` 邊**永遠留著**，
  而讀取端會**把已不存在的 id 當成有效目標** ⇒ **復仇 goal 可能鎖定一個死人**。
  ★ 這與**執行失敗反饋鐵律**直接相關：**目標不存在 ＝ 計畫失效**，應該升 T0 重想，
  而不是每輪安靜地重新選一個不存在的目標 —— **這是 A1 五族的候選**。
- **(B) id 重用交互**：新人撿到舊 id ⇒ **平白繼承一段跟自己毫無關係的恩怨情仇**
  （`monotonic-person-id` slice 處理）。

**★WHAT 成分（已呈 blueprint）**：「**仇人死了，仇恨該怎麼辦**」是設計問題——
消解？轉移給子嗣（血仇代代相傳很有戲）？留著但只影響對其團體的觀感？
**機制上現在是「留著且指向虛空」，那個是 bug；但「該怎麼辦」不是我能裁的。**

### 💾 全樹**沒有存檔／載入路徑**（2026-08-21 窮盡稽核副產物，記錄事實非缺陷）
`monotonic-team-id` 的 §3 稽核第 4 項要查「載入後 `next_team_id` 是否 > 檔內最大 id」，
窮盡搜索結果：**`ResourceSaver`／`store_var`／`save_game`／`load_game`／`to_dict`／`from_dict`
在非-debug code 命中 0**（唯一 `FileAccess.WRITE` 是 `observer_main.gd:224` 的文字 dump）`@aa9f3ad9 2026-08-21`。
⇒ **今天不可能載到 stale 計數器**；該 gate **無對象可驗 ＝ 空過，未宣稱通過**（照實記）。
★ **未來實作存檔時必須回頭補**：載入後 `next_team_id` **必須 > 檔內最大 id**，
否則新隊會撞舊號、id 重用那族的病全部復發（分配器已有 floor guard 兜底並 `Probe.bump("teamid.floor_bump")`，
但那是**自我修復、不是設計保證**）。

### 🧭★「走一格要多久」全站有**五套**算法（2026-08-21 R² 親查 + systems 窮盡確認）
`BASE_MOVE_TICKS` 的非-test 使用點窮盡（`grep -rn`，無 `head` 截斷）：

| # | 位置 | 用途 | 吃哪些因素 |
|---|---|---|---|
| 1 | `movement_system.gd:193` `_move_cost` | ★**真實移動**（唯一權威） | 隊速／地形／疲勞／**超載**／車輛 ＋ clamp `[BASE/3, BASE×3]` |
| 2 | `path_system.gd:160` `eta_ticks` | T3 convoy 預算 | **只有疲勞** ⇒ **系統性低估 3×**（`eta-single-model` 修這條） |
| 3 | `path_system.gd:236` | **pursuit-eta**（追擊估時） | `relative_speed` |
| 4 | `faction_ai.gd:5612` `_round_trip_ticks` | **失聯帳本** | `dist × BASE × 2 + 1 日` |
| 5 | `subteam_system.gd:12` | **founding_timeout** | `dist × BASE × MULT` |

**R² 判斷（採納）**：3／4／5 **不共享 convoy 那個「超載驅動的 3× 誤差」病根**
（它們的用途對誤差沒那麼敏感）⇒ **不塞進 `eta-single-model` 那一刀**。

★ **但它們是 `invariants`〈同一個物理量不得有兩套獨立模型〉的活樣本**：
**同一件事有五個公式，彼此不知道對方存在。**
**日後任何一個被下游常數乘起來（像 T3 的 `MULT(3.0)` 那樣），分歧就會被放大或抵消，而檔面上完全看不見。**
**方向**：逐步讓 2–5 **由 1 導出**（真實模型加參數／封裝），**不是各自校準**。

### 🚶★★「明明相鄰卻不走最後一步」：移動／抵達執行斷（2026-08-21 QA 逐 tick 稽核坐實，★獨立缺陷）
**三筆 convoy `stranded` 的 porter 全部撞出同一個訊號**（QA 讀 specimen 逐 tick 軌跡，非快照距離）：
| porter | 凍結位置 → 目標 | 凍結時長 | 備註 |
|---|---|---|---|
| 100 | `[17,18]` → `[16,19]` | **240 tick／4 個連續樣本** | 之前一路正常接近 |
| 118 | `[10,12]` → `[11,11]` | **200 tick／4 個連續樣本** | 之前一路正常接近 |
| 164 | `[10,15]` → `[10,14]` | **一進 RETURN 即刻凍結** | ★**最乾淨的樣本** |
`@f9ad46c3 2026-08-21`

★ **systems 已排除一個假設**：三筆的 `tile_pos → move_target` 差值分別是
`(-1,1)`／`(1,-1)`／`(0,-1)`，**全部都在 `PathSystem.HEX_DIRS` 裡 ⇒ 是真正的六角相鄰**，
**不是「Chebyshev 相鄰但六角不相鄰」的度量錯配**。**就是最後一步不走。**

**可疑方向（QA 建議，未驗）**：移動系統的「已到達判定」／convoy 的 `move_target` 更新
與移動判定 cadence 沒對齊／相鄰格被判成「已算到達」但 `tile_pos` 沒真的寫入最後一步。

**★連帶疑點（同一病灶？）**：`porter164` 在 `OUTBOUND→RETURN` 那一刻 **`material` 沒有從 30.00 掉下來**——
其他乾淨案例（porter 12/20/22/100/118）轉 RETURN 時 material 都會因交割掉一截。
**懷疑這趟連貨都沒真的交割成功**；若「到達判定沒觸發」是共同根因，**交割自然也不會觸發**。

**★★為什麼今天才發現**：**T3 逾時兜底一直正確地把這些 porter 收掉**（超時是真超時），
**於是這個缺陷被兜底的正確行為完全遮蔽**。見 `invariants`〈兜底會遮蔽它兜住的東西〉。

### 🚚★porter 餓到「投靠」非母隊：convoy 貨物隨人被第三方吸收（2026-08-21 QA 故事稽核挖出，★第四種結局）
QA 交叉 6 筆真實 merge log 與 specimen 逐筆核對發現：**`Team1 ← Team12`** —— **某支 porter（持有 id 12 的那一支）在該趟根本沒回到真母隊 `Team5`**，而是併進完全無關的 `Team1`。★**措辭已訂正**：原本寫「porter_12 **第二趟**」是錯的——**`team_id` 會被重用**（`_next_team_id = max(現存 id)+1`，見〈身分不是 id〉），**「同一個 id」不等於「同一支隊」**；這裡講的是**某一趟**，不是「同一隻的第二趟」。
`tick7700` `task→投靠`（求收留）、`food` 掉到 **1.17**（瀕死）、`tick8000` **`parent_team_id` 直接改寫成 `1`**、`task→覓食`
`@convoy-specimen-t3budget 2026-08-21`。
⇒ **porter 自己撐不住、被路過的隊收留，貨（剩餘 material/coin）跟人一起被吸收。**
**6 筆 merge 中 1 筆錯認 owner ＝ 17%。**

**這是第四種結局**，跟既有三分類（`merged_home` 真回家／母團滿員或部分合併＝合法獨立／`stranded` timeout）**都對不上**。

**★兩個層次的問題（已分派）**：
- **WHAT（blueprint）**：這是 **bug 還是 genuine 悲劇**？「瀕死投靠」壓過「送貨回家」的優先序該不該存在？
- **HOW（systems）**：**貨物所有權**——領主派出的貨在**未經交易／未經同意**下轉移給第三方。
  全域守恆不破，但這是**吸收式的所有權移轉**。

**連帶：量測儀器也錯了**——床把它算成 `merged_home`（以「隊伍消失」推論），
`measurer` 的「**3 隻 porter 全部乾淨 merged_home**」需訂正為「**6 次 merge 中 5 次回真 parent、1 次錯認 owner**」。

### 🚚 CONVOY porter 在運輸期間**完全沒有決策**（2026-08-21 診斷坐實，★交 blueprint 判是否 by design）
`faction_ai:761-762` 子隊一律走 `_evaluate_subteam`；`:2753-2756` 對 `TASK_CONVOY` **直接早退** ⇒
porter 整趟**不進任何決策路徑**。specimen 佐證（追逐窗 tick 3600–4600）：porter_12 共 20 筆 entry ＝
**reaction 10 ＋ heartbeat 10、decision 0** `@371d6e94 2026-08-21`。
**連帶**：`PROGRESSIVE_HOLD_TASKS` 對 CONVOY **結構上不可達**（沒人呼 `try_set` 就沒有 hold 可談），
「survival 仍可搶」在 live **也不成立**——**沒人嘗試就沒得搶**。
**reaction 層仍在跑**，所以 porter 不是完全無反應；但「**運輸中的隊伍該不該有決策能力**」
（遇襲改道？瀕餓就地覓食？）是**願景層問題**，非 systems 可裁 → **已呈報 blueprint**。

### 👶★★生育 merge 後世界層級幾乎沒生效：90 天 `breed.born = 1`（2026-08-21 D1 短跑；**根因在 systems 的設計，非實作**）
**實測** `breed.born=1 · reaction.breed=1 · n_persons 24→24 凍結（每 10 天取樣皆 24）` **@70a792b3 2026-08-21** · repro: `EXAM_CONFIG=peaceful EXAM_MONTHS=3 EXAM_SEED=1337 .\tools\godot.ps1 --headless --script scripts/debug/exam_12mo_bed.gd` （正本 `docs/process/verdicts/d1-pop-vs-cap.measure.json`）。specimen 側證：`breed.rate_sample` 顯示 `breed_progress` **有在累加**（0.001→0.084）＝**機制路徑是通的、只是極慢**。
  ★★★**2026-09-01 重錨 arc（S0~S7）之後複測 —— 更極端**：兩床（peaceful＋warring）、30 日窗、
  **3060 個 team-day（361＋2699）** ⇒ `minor_population` 佔比**逐位元 0.0000**。
  ★**不是母體空**：分母 `population + minor` 從未為 0；★★**不是死碼**：累積機制 `reaction_system.gd::_tick_breed` 實存。
  ⇒ ★★★**30 日窗內【全隊全程沒有任何一次 `breed_progress` 累積到 1.0】**。
  ★★★★**當日訂正（★這是我自己製造的假訊號）**：我原本寫「從 `born=1` 變成 `born=0`」並當【重錨後迴歸候選】呈報
  —— ★**而兩個數字的窗長不同**：原始 `docs/process/verdicts/breed-verify-and-deathcause.measure.json`
  ＝ seed 1337 ／ peaceful_economy ／ **90 天** ⇒ born = 1；今天 ＝ **30 天**。
  ★★**期望值 ＝ 1 × 30/90 ＝ 0.33 ⇒ 觀測到 0【完全在預期內】** ⇒ ★★★**「1→0 迴歸」不成立。**
  ★**真正還成立的是**：**90 天只生 1 個** ＝ 長期低速率，不是迴歸。
  ★**效力邊界（量測員自標）**：本結論**只覆蓋 30 日窗**；更長窗未量。
**★★根因（systems code-read + 算術，兩條疊乘）**：
1. **`BASE_RATE` 的推導假設在這個世界不成立**：我用「健康村 `f≈0.5` × **5 名適齡成人** → 1 名額/30 日」反推 `0.0133`；**實測 24 named / 17 隊 ≈ 1.4 名/隊** → **光此一項就慢 ~3.5×**；而多數隊 `rel_surplus ≤ 0` → **`f = 0` ＝ 完全不生**（p90 才 0.148、`f≈0.5` 只在最頂十分位）。頂級村配 1 名 named：`0.0133 × 0.5 × 1 ≈ 0.00665/日` → **~150 天/名額**（設計目標 30 天）。
2. **★named/anon 不對稱（merged code 實證）**：`breed_rel_surplus` 分母用 **`t.population`**（`team_data.gd:55` ＝ leader + named + **anon 全部**），但適齡迴圈只跑 **`state.persons`（named only）** → **anon 吃飯拉低 `rel_surplus`、卻不能生 ＝ 雙重懲罰**；anon 越多、越不可能生。
**★這不是「修了沒生效」，是「修對了一半」**：懸崖→連續、尺度依賴（絕對→比例）都成立；**沒解掉的是「誰能生」這一層**（生育掛 **named 名冊**、非人口）——正是 blueprint 早先指出的**意圖帳「生育兩層」問題**（用戶 2026-08-18 問「這種生育怎麼跟**王朝血脈**對齊」時討論的同一結構）。
**恢復後的三個選項（systems 初判，未經 R²）**：**(a) 讓 anon 也能生**（結構解、接王朝血脈那條）／**(b) 把 `BASE_RATE` 調大 ~25×**（★**crank**：用常數補結構問題）／**(c) 分母改只算 named**（★**不真實**：大 anon 村會顯得很富裕）→ **systems 與 blueprint 皆 lean (a)**。★**但 (a) 是 WHAT 級**（兩層人口模型動「誰能生」）→ **恢復後由 blueprint 帶用戶拍、R² 前不定案**（**裁定 2026-08-21（blueprint）**；**地基＝structural code-read（`reaction_system.gd` 分母 `t.population` vs 適齡迴圈 named-only、`team_data.gd:55`）＝結構級不過期**，＋ **D1 量測 @70a792b3**＝會過期）；**systems 不得逕自出 HOW spec**。
**★附帶訂正（measurer 抓到、我的判準太天真）**：D1 票裡我先寫死「`AT_CAP > 0` → 開 arc」——實測 `AT_CAP=41%` **@70a792b3 2026-08-21** **是碎片化 artifact**（`n_persons` 凍結 24、`n_teams` 12→17-19，同一批人被拆進更多隊 → 個別隊 pop/cap 比值**機械性上升**）→ **該判準在 pop 沒真成長前不可用**。
**其餘 D1 數字**：跨門檻 12 隊數 **全期 0**；統領成長機制本體 ＝ `SkillSystem.on_reaction`（`skill_system.gd:23-33`，`REACTION_SKILL_MAP["P4_expand"]`；**我 grep `_grow_leadership_tenure` 沒命中是對的，該函式不存在**），`reaction.P4_expand` **224 次/90 天＝在跑**，但 `cmd_dist.median` 恆 **0.6** 未動（皆 **@70a792b3 2026-08-21**，repro 同上）（單次成長量 `BASE_GROWTH=0.005×…` 太小）。

### 📈 N² 歸因：per-eval 掃描 ∝ |team_discovered|，穩態飽和於 N（2026-08-21、ramp vs 穩態的和解）
**量測**（warring seed1337 day1-40）：`|team_discovered|` median **2→76**（38×）、`scan_per_team_day` **165→8784**（53×）、`global_tile_share` **99.2%→74.3%**。
**★表面矛盾**：`scan/team` vs **N** 回歸 k≈**3.87** → 隱含總成本 k≈4.87，**與大考量到的 k≈2.004 對不上**。
**★和解（systems 用同一份資料算 `median/N`）**：比值 day5 **0.09** → day20 0.29 → day40 **0.58**（p90/N 0.18→0.69）＝ **discovered 正在填滿、趨向飽和**。
- **ramp 期**（|discovered| 與 N 同時長、比值上升）→ 對 N 的回歸**虛高**（`1.1/0.298≈3.7` ≈ 實測 3.87 ＝ **day↔N 共線假象**，measurer 自己抓到）。
- **穩態**（`|discovered| → N`）→ per-eval **∝ N** → 總成本 **∝ N²** ＝ **正好 k≈2.004**（12mo 大考遠在 day40 之後、量的是長期行為）。
∴ **兩份數字不互斥，是不同 regime**；**不需要**開對照式量測去切開 day vs N（穩態會合流）。
**★對主刀的意義**：「限制 per-eval 掃描範圍」仍是主刀，但**正當性理由改寫**——不是「discovered 隨 N 超線性成長」，而是**穩態下每隊要把認識的世界掃一遍**。
**★不受 confound 干擾的乾淨結論**：`_find_own_outpost` 全圖掃**持續佔 74–99%** → **優先索引**（已 dispatch、必須 byte-identical）。

### 📋 訂單簿健康度：成交率 0.7%、壽命是硬常數牆、churn 0%（2026-08-21 世界級數字、用戶追問的舊懸案）
**數字**（peaceful_economy seed1337、90 天完整）：`order.placed 1001` ／ `filled` **7** ／ `abandoned 945` ／ `replaced` **0** → **成交率 0.7%**、abandon **94.4%**。
**★★「壽命」不是分布、是硬常數牆**：`ORDER_LIFETIME = 5 * TICKS_PER_DAY`（`order_system.gd:3`）**寫死**、下單當下 `expire_tick` 即固定；16 筆 abandon 樣本 `age_ticks` **全部 = 1200、零變異** ＝ 每張被砍的單都**活滿整整 5 天**。∴ 原本想要的「平均壽命/年齡分布」**退化成單點常數**。
**★重掛 churn ＝ 0%**（硬證據）→ **systems 先前的「訂單重掛 churn」懷疑正式撤回**。
**★systems HOW 判斷（下一步該修哪）**：**不要先動 `ORDER_LIFETIME`**——0.7% 與已知 **GATE-B buy-fill 0.5%**（seek 1363→arrive 333→fill 4；`order_system.gd::ORDER_LIFETIME` 只從**抵達 tile** 的 granary 買 ＝ 空間錯配）**幾乎一致** → 真 binding 疑為**貨到不了**而非**窗太短**；先拉長壽命只會把「到不了貨」變成「更久才被砍」＝**在結構性斷點上調參**。**正確順序：修 GATE-B → 看成交率是否自然上來 → 仍低才檢討 5 天窗**。
**★證據矛盾已釐清（2026-08-21 measurer、窮盡搜索）**：`qty_remaining` 全 `scripts/simulation` **僅 3 處寫入**（`order_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） 新單設定／`:375` `want-filled`／`interaction:916,922` `maxi(qty-filled,0)`），**全部單調不增** → team8 的 17→21 **上升必然是不同 `order_id`**、**「就地調大」確定 FALSE**。
**真相＝序列式重掛**（舊單**已死**後隔一段再重新下單），而 `order.replaced` 抓的是**重疊式**（舊單**未清**就再掛）→ ∴ **「訂單簿無 churn」只對「重疊式」成立**；**「序列式重新下單」未經測量**。
★**systems 裁：現在不為它開量測輪**——在 fill 0.7%／abandon 94.4% 的世界裡，**單到期後重新下單是正確反應**（隊仍然需要糧），它是 **0.7% 的下游症狀、不是獨立病**；等 GATE-B／dispatch-drop 釐清後若仍要量，**tap 設計已備**：追蹤同隊同 `kind+res` **連續兩張單的 `created_tick` 間隔**（現有 counter 答不了）。
★**別把「churn=0」讀成「沒有反覆下單」**——這是 counter 的**定義範圍**，不是世界的性質。
（附：systems 原信誤標該筆為 warring，實為 **peaceful_economy**；measurer 更正。）

### 🩺 生育不給「醫療」技能 XP（既有、非新引入；2026-08-20 生育 slice merge-gate 時查清）
`skill_system.gd:14` 有 `"P5_breed" → {skill:"醫療", attr:"智力"}` 映射，但 **`SkillSystem.on_reaction` 只吃 `_evaluate_person` 回傳的「行動反應」**，而 `P5_breed` 一直走 **life-event 分支**、**從不經過 `on_reaction`**（`skill_system.gd::on_reaction`（★L1 錨：systems 判 2026-09-01 —— 原錨指床，而條目內文本身就給了 production 錨） 的 assert「行動反應不應含 P5_breed」正是這個事實的反面證據）。
∴ 該映射**在生育改連續速率之前就已經是死的** → 「接生/生育累積醫療經驗」這條**設計意圖從未生效**。
**非 regression**（生育 slice 沒打死它）、**非阻塞**。要修的話是 WHAT 級小問題：生育事件要不要回饋醫療技能成長（現況：`醫療` 只在別的反應路徑成長）。

### ⚠️★★回溯標注：以下 peaceful 卷結論**全部缺一個章節**——「**這張卷沒有勢力層**」（2026-08-21，用戶令）

★★★**第二次打戳（2026-09-04，政權注入 ＝ 根修級世界變更）**：`config/peaceful_economy_regime.json` **新增初始政權**
（A 北緣 6 隊／B 西南 4 隊／獨立 2；★**舊檔 `peaceful_economy.json` 凍結存檔、一字未動** ⇒ 兩個世界都能重建）。
⇒ ★**打戳範圍比「政權統計」寬**（reviewer 放寬）：**`徵收／歸建` 變成新的活候選 ⇒ 整個競爭池改變**
⇒ ★★**任何在【無政權 peaceful】上量到的「哪個 option 贏了 argmax」結論，被引用時要先重驗**（用時付費）。
★**已知會被戳到的三筆**：①`備戰過門檻 20.0%` ②`peaceful 無人承諾紮根 0／0` ③`power_ratio 對照腿`。
★★**而它們【不自動作廢】** —— **舊 config 還在，複現得了；戳的意思是「引用前先重驗」，不是「它錯了」。**

**已坐實**：`peaceful_economy` **無 `factions`**（`state.factions.size()` 恆 0，逐 tick 驗）
⇒ `faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） `for fid in state.factions:`（**loop1**）**零疊代**
⇒ **`_update_goals` / `_assign_tasks` / `_evaluate_infrastructure` 全程未執行。**

**但範圍要精確**（systems 自驗，避免過度作廢既有結論）：

| 在 peaceful 卷 | 狀態 |
|---|---|
| `_evaluate_infrastructure`（**faction 級**：升級 outpost／擴建設施／`_dispatch_builder` 蓋新 outpost） | ❌ **零疊代** |
| `_evaluate_independent_infrastructure`（**獨立隊自家 outpost 蓋設施**，`faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走），在 **loop2** `for tid in state.teams`） | ✅ **有跑**（每 `INFRA_INTERVAL`） |

⇒ ★**不能簡單說「設施建造的程式碼沒跑」** —— 獨立隊那條有跑。

### ★★★ 但由此浮出一條可能統一今天所有線的鏈（**假說，一個數字可定案**）

`_evaluate_independent_infrastructure` 的第一道門是 **`faction_ai_system.gd::_evaluate_all_body()` `_find_own_outpost` == -1 就 return**，
下一行還要 **`tile.outpost_level != 0`**。

```
outpost.l0_to_l1 = 0（實測）      ← 沒有隊靠紮根取得 outpost
  + peaceful 無 faction          ← 另一條蓋 outpost 的路(_dispatch_builder)零疊代
  ⇒ 獨立隊唯一設施入口每次卡在 :4394 空轉
  ⇒ 沒有 workshop ⇒ 沒有 tools
  ⇒ apothecary / smeltery / weaponsmith / armorsmith / mint 全斷
  ⇒ mint_level 全期 0%
```
★**若成立，「設施鏈斷」的真上游不是 `afford×1.5`，而是「沒有人有 outpost 可蓋設施」**
—— **而那正是 §7 #1 `outpost.l0_to_l1 = 0` 本身。**

★**一個數字可定案**：**peaceful 卷裡 `outpost_level > 0` 且 `outpost_owner != -1` 的 tile 有幾個？**
- **若 ＝ 0** ⇒ 鏈成立，**下方「afford×1.5 是閘①」的結論前提要重驗**（那個閘可能根本沒被走到）
- **若 > 0**（config 自帶 outpost）⇒ 鏈第 3 步不成立，下方結論不受影響

### ✅ 數字回來了 —— ★**我的假說【否證】，照我自己預寫的規則辦**

**普查（measurer，`outpost-census-and-C6-1.measure.json`）**：
**day0 ＝ 11（config 開局自帶）／day90 ＝ 9／中途新增 ＝ 0。**

**我預寫的判讀規則是**：`= 0` ⇒ 鏈成立／**`> 0` ⇒ 鏈第 3 步不成立**。
**答案是 11 > 0** ⇒ ★**鏈第 3 步（「獨立隊設施入口每次卡在 `:4394` 空轉」）不成立，假說否證。**
有主 outpost 存在 ⇒ `_find_own_outpost` 對那些隊**過得去** ⇒
`_pick_facility` / `_dispatch_facility_builder` **是被走到的**
⇒ ★**下方「閘① `afford×1.5`」的前提【沒有被推翻】，「前提待重驗」標記撤下。**

> ★**與 measurer 的判讀差異，記在此**：他寫「鏈成立」，指的是**另一個命題**
> ——「**沒有任何新 outpost 被建成**」（真）。我的命題是「**沒有隊擁有 outpost**」（假）。
> **兩個命題很容易混為一談，但推論後果相反。** 我照預寫規則判否證，不順著結論走。

### ★★但普查給了一個**更根本**的新事實（獨立於我的假說）

**`11 → 9`，中途新增 ＝ 0 ⇒ outpost 只減不增，90 天淨 −2。**
★**這個世界只會失去據點，不會產生據點。** 外推 ⇒ **據點數單調趨零**。
「整條從無到有蓋出一個 outpost 的鏈，90 天內連一次都沒成功過」——
這是 §7 #1 `outpost.l0_to_l1 = 0` 的**世界級意義**：不只是計數器是 0，是**文明化這個動作從未發生過**，
而**去文明化（棄置/衰減）正常運作**。

### ★併同 C6-#1（棄工抖動）
`construct.progress = 344` vs `construct.stall = **5871**（94.5% 停滯）`。
與 75%／89% 棄置率同源：**不管 L0 camp 還是 L1+ construction，共同模式是「標記了要蓋、實際執行時間極少」。**
★**誠實邊界（measurer 自標）**：`stall` 是**累計 tick**（每次 hourly cadence 都可能重複算同一個停滯工地），
**不是 N 個不同的棄工事件** ⇒ **未拆 distinct 工地數**。
⇒ **已准 measurer 再開一輪加 tap 追蹤 distinct 工地命運** —— A1 票的判讀規則正需要這個拆分。


### 🏭 沒有人蓋 workshop ＝ 設施鏈斷的真上游（2026-08-20、mint 0% 追根時發現）
**mint 全世界 0%** 的下游解釋是「付不起 `tools: 5`」（tools 全球 production=0）；但**再往上一格**：`FACILITY_DEF` 完整 cost 表顯示 **`workshop` 成本 `material 60 / tools 0`**，而 **workshop 正是 tools 的生產者**（`manufacturing_system.gd`（★L2 錨：檔級） `material 4.0 → tools`）→ **入口不需要工具、沒有雞生蛋**（systems 一度誤判為雞生蛋，已對 blueprint 撤回）。礦村 settle 另有 bootstrap 給 8 tools（`faction_ai:3714-3716`）。
∴ **真問題＝為什麼沒有人蓋 workshop**。候選（未驗）：①argmax 對上 farming 的 survival-crush、在多數隊食物淨流為負的世界恆輸 ②afford（`60×1.5=90` material）③slot/型別 ④`_facility_deficit`（workshop 走 `use_demand=true`）在需求鏈斷時算 0。
**便宜查法＝facility-score 快照**（已核准併下輪新基線考規格第五項）：一份就能答「workshop 有沒有被評分、輸給誰、差多少」。
**連鎖**：workshop → tools → apothecary(2)/smeltery(3)/weaponsmith(3)/armorsmith(3)/mint(5) **全部卡在同一個上游**；也連 「★★★means-end/長程計畫全系統 = binding root（用戶定 」 的 tools/weapon production=0 與 order kill_nostock 噪音。

### ⚠️舊 warring 長跑可能靜默凍結 —— **機制已修（觀察者永不凍結 MERGED）；★歷史資料仍受污染、舊結論仍須按 signature 自查**（`game_over` × headless；2026-08-20 measurer retro-audit CONFIRMED）
`warring_states.json` **有 `player` 區塊** → headless 仍指定 player team（**歷來都是 Team48**）；該隊 leader 死且 named 空 → `event_system.gd`（★L2 錨：檔級） `game_over=true` → `sim_runner:70-72` **整個 tick 不推進**。而多數長跑床的「day」是 **loop counter 非真 tick** → 凍結後**繼續寫出假天數**。
**★degenerate signature（任何人都能 30 秒自查）**：log 出現 `[GameOver] 玩家絕後（Team48 無繼承人）`；其後 progress marker **背靠背**跳出（如 `tick=7200 月=1`＋`tick=14400 月=2`）且 **teams 數完全相同**、中間無任何模擬內容。
**retro-audit 結果（4 檔命中）**：`2026-07-22-ms-divert-spec-1337`（★低風險：凍結點接近真實結尾）／`2026-07-23-materialhold-1337`（**★★高風險**：宣稱 months=3，但真 ticking 疑似只到 tick 3840–7199 之間）／`2026-07-24-materialsupply-1337`（**★★高風險**：同 signature）／`2026-07-24-ordernoise-1337`（證據不足、風險未知）。
**★measurer 誠實邊界**：只做 log 層證據比對，**未重跑、未讀那 4 個 bed 原始碼**確認是否同樣用 loop counter → 因果鏈是**合理推論、非坐實**。
**處置（systems 裁、比例原則）**：**不深挖考古**——對應 handback 多已 prune、文件承重面只剩本檔 `:199` 一句（已就地加 caveat）。**signature 已記於此**，將來若哪條舊結論**真的變成承重前提**，30 秒即可自查。修法見 spec `2026-08-20-observer-world-never-freezes-HOW.md`。
**★同族**：與〈LOD 紅線〉同根——**玩家中心假設在無玩家世界裡靜默停掉東西**（一個停個體反應、一個停整個世界）。本 session 兩次踩同一族。

### ✅無玩家 headless ＝個體反應層從不執行 —— **已 MERGED（LOD 紅線修；rate-equivalence far/near=1.00）**（LOD 紅線違憲；★範圍已於同日更正：原寫「四系統」是錯的）（2026-08-20 measurer 實證 + systems 親驗 code；**擋考級**）
**機制**：`sim_runner` SYSTEMS registry 中 **`reactions`／`cleanup`／`outpost_tick`／`regen` 標 `lod=LOD_NEAR`**；near 判定＝`sim_runner.gd::_get_near_teams()` `_hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS(3)`。headless 床慣傳 `player_pos=(-1,-1)` → **全隊恆 far** → `sim_runner.gd::_run_systems()` 直接 `continue` → 四系統整段跳過。
**各自 body（單一 call site、已窮盡 grep）**：
- `reactions` ＝ `ReactionSystem.evaluate_all`：**生育 `P5_breed`**／逃／暴動／叛／怠工／士氣／`goal_alignment`。
- `outpost_tick` ＝ `OutpostSystem.tick_all`：**`_tick_construction`（建設進度）+ `_tick_mint`（鑄幣）+ `produce_stable_day`**。
- `regen` ＝ `ResourceSystem.regenerate_tiles`（tile 資源再生）。
- `cleanup` ＝ npc goal cleanup。
**實證**（measurer、peaceful seed1337 25 天）：`breedgate.calls=0`（全期全隊零呼叫）、11/11 隊 `minor_population=0`、零 `[PopMgmt]`。
**★★大考中彈**：`exam_12mo_bed.gd:55/64` 用 `no_player=(-1,-1)` 且**未開 `force_full_hd`** → 照現況開考＝量一個**建設不動、不鑄幣、不再生、不生育**的世界。**已暫停開考**，WHAT 裁定（世界存在是否綁玩家位置）呈 blueprint（systems 建議：無玩家→全隊視為 near）。
**★★範圍更正（2026-08-20 同日、systems 自糾）**：near 區塊按 **tick cadence** 執行（`:239`）、**不以 `near_teams` 非空為條件**；`_run_systems` 依 **shape** 派發（`:178-185`）：`shape=state`／`shape=regen` **完全不碰 teams 陣列** → **`outpost_tick`（建設/鑄幣/馬廄）與 `regen`（tile 再生）照常執行**。**真正死掉的只有 shape=teams 的 `reactions` 與 `cleanup`**（與 `breedgate.calls=0` 實證吻合）。∴**撤回**兩條先前寫下的污染指控：①「`mint_level` 0% 有更平凡解釋」→ 撤回，鑄幣一直在跑、監看項照舊；②「founding `complete_build=0` 的 buy-preempt 歸因是 confound」→ 撤回，建設一直正常前進。
**★★污染 triage 清單（systems 2026-08-20、blueprint ⑤ 要的；分四級、逐項標可信度）**
- **A 級＝直接失效（結論本體建立在 person-reaction 事件上）**：①**人口成長/生育**——「村莊卡 6 不長」的真根就是 breed 從沒被評估（`breedgate.calls=0`）；`MATURE_RATE` 慢這個懷疑方向**撤回**。②任何「個體叛逃/怠工/暴動/敲詐**從不發生**」的觀察 ＝ **artifact**，不是世界性質。
- **B 級＝通道部分死（有其他來源、結論打折不歸零）**：`LoyaltyBank.adjust` 全站 **14 caller、其中 3 個在 reaction_system**（`goal_alignment` 通道死、其餘 11 條照常）→ 忠誠相關結論**部分受影響**；`cleanup_goals`（**單一 caller 在 LOD_NEAR 塊**）→ headless 中**個人 goal 從不清理**，舊 goal 殘留可能污染 means-end 觀察。
- **C 級＝系統性偏置、方向已知**：`work_morale` **只在 reactions 統計寫入**（`team_data.gd::pop_cap_from_leadership()`），headless 中**恆為預設 1.0**；而它被 `resource_system:303 gain *= team.work_morale` **直接乘進採集產出** → **所有 headless 產出量測都是「零士氣變異」的世界**。修好後產出會出現變異（升降皆可能）＝**大考前必須知道的基線位移來源**。
- **★C 級的重量級案例：labor-v2 accepted cost（28 起 chronic 死亡）**——飢餓/死亡機制本身走 `resource_system`（LOD_BOTH、不受影響），但那個世界**零出生**：人口只出不進 → **所有 starve/attrition 基線都是「不會補人的世界」量出來的**。這不推翻「接受代價」的決定，但**它的量級解讀要重新校準**（與 GATE-B 那條歸因連動一起看）。
- **D 級＝不受影響（明確標出、避免過度恐慌）**：團級決策/移動/貿易/戰鬥/建設/鑄幣/馬廄/tile 再生（`LOD_BOTH` 或 `shape=state`）；**QA 的 EWMA 故事稽核**（決策層 util 追蹤）；**GATE-B 診斷**（`interaction` 層）；perf 五路（`force_full_hd` 或 tick-time 層）。
**★回頭影響（縮至 person-reaction 層；需逐床 audit，未逐一驗證前不下結論）**：全 **243 個 debug 床僅 20 個**用 `force_full_hd`。已知受影響候選：本 session 的 §4b organic gate／popcap 快照／breed 分解；更早的 **founding `complete_build=0`「buy-preempts-founding」診斷**（若建設本就不前進，該歸因可能是 confound）。**`mint_level` 全世界 0%** 這個大考監看項現有更平凡的解釋。
**★注意反例**：`force_full_hd=true` 的床（如 perf①③ profiling）**不受影響**（`_get_near_teams:501-502` 直接回全隊）；且 `force_full_hd` **不是中性開關**——它同時拿掉 far 降頻＝移速/思考恢復全速（`sim_runner.gd::_record_tick_perf()` 自警「勿在正式跑開…需配 gen 重校」）。

### 🔧 bed 工具坑：`OS.set_environment` 同進程讀回不可靠（2026-08-20 measurer 實證）
量測 bed 若用 `OS.set_environment(...)` + 下游 `XXX.setup_from_env()` 的組合在**同一進程內**傳參 → 實測 **specimen 捕獲 0 決策**（Godot 對同進程 set 後立即讀回不保證可見）。
**改法**：直接指定目標欄位（該例＝`state.specimen_team_ids`），不要繞 env。**env 只用於「外部 launcher → 進程啟動時」傳參**，不要當進程內部的參數傳遞管道。

### ⚠️人口不成長 —— **機制已修（生育＝per-capita 連續速率 MERGED）；效果待量（AT_CAP 短跑）**（領導天花板假說已 REFUTED、現指向生育引擎結構性關閉）
**現象**：`peaceful_economy` day5→day90 population median/max **精確卡 6**；§4b 擴點門檻 pop≥12 **三個 run 零次滿足**。
**★假說一（領導天花板）＝REFUTED**（measurer 快照 seed1337 day20、11 隊）：統領實測**全部 0.600**、`effective_pop_cap` **76–99**、population **3–6**、**AT_CAP=0.0%** → **cap 根本沒在綁**。（systems 的錯誤＝把「統領 0.08→cap 6 恰好等於 median 6」的**算術巧合**當坐實；公式為真但「這條在綁」未驗＝file:line 坐實公式 ≠ 坐實主導。附帶事實：該 config 的 leader 統領**全體一致 0.600**＝fixture 特性、非隨機樣本。）
**假說二（待測、已派 measurer 用既有 `reaction.breed` tap 分解）＝生育引擎結構性關閉**：
1. ★生育迴圈 `reaction_system:21-36` 迭代 `state.persons` 過濾 team ⇒ **只有 named 會生、anon cohort 完全不生**，而村人口主體是 anon。
2. `_breed_balance`（`:185-188`）要求該隊 **named 兩性皆有**（`minf(m,f)<=0 → 0`）⇒ 小村 named 僅 1–3 人、**單性機率極高 → 直接不生**。
3. 另兩道門：`food_flow_avg > BREED_FLOW_MIN=1.2`（**持續**淨盈餘；labor-v2 輪量測顯示多數隊 chronic ≤0）、`minor < 25% pop`。
4. 下游 `MATURE_RATE=0.1`（月）——**若 breed 全期 fire=0 則此項完全不是瓶頸**。
**★arc 連結**（blueprint 2026-08-20）：named-only 生育正是用戶 2026-08-18 問「這種生育怎麼跟**王朝血脈**對齊」時討論的同一結構 → 若坐實，意圖帳的**「生育兩層」問題提前現形**，修法與 [[王朝 arc]]／領導成長管道（established④）**同族、該一起排**。
**對大考的意義**：若坐實，科目 A 的答案會是「**正循環斷在人口引擎、不在經濟**」——符合 blueprint 定的「大考是診斷器非及格考」。

### 📐 `_inflow_est` 的 `pop_mult` 在 pop≥20 飽和 ⇒「抽人不痛」（考後 backlog、blueprint 2026-08-20 確認）
`MarginalEconomy._inflow_est` 的 `pop_mult = clamp(sqrt(pop/5), 0.5, 2.0)` 於 **pop≥20 觸頂** → 從大村抽走 6 個 settler，家內產能估計**零損失**（大村剎車床實測**家內邊際恆 `0.00`**）。
∴ §4b 擴點的剎車**確實 bounded**（util `0.3635 → 0.1148`、`applicable` 仍 true＝非硬 gate），但**剎車語意是「同樣產出攤給更多人所以每人不划算」（per-capita 分母），不是「抽人很痛所以不擴」**。
**歸屬**：既有 `_inflow_est` 性質、**非 §4b 引入**；屬 [[有大有小 arc]] **CASE B 規模經濟 absent** 家族在**擴張決策面**的具體現形（「團越大、多一個人越不值錢」在 pop≥20 後完全消失）。
**裁定＝考後 backlog**（blueprint 確認 systems 三理由）：①標準場景 pop 卡 6、走不到 20 → 現在調＝**在沒有大村的世界裡調大村參數**＝「壓力鍋裡調藥」同型 ②12mo 大考產出第一批「到底有沒有大村」的證據 ③若世界確實長不出大村，此參數優先序**自動降**（它只在 pop≥20 才有意義）。

### ⚠️`DecisionContext.gather` 有寫副作用 —— **部分修**（`need_urgency`/`plan_phase` 已移出＝specimen 非中立根修；★**cache 群仍在**、另案） → 任何非決策路徑呼叫都擾動世界（specimen 非中立性的真根方向、2026-08-20 implementer 隔離）

**重現**（`specimen_neutrality_bed.gd` 兩段式 A/B 比 fp）：seed1337、**7 specimens**、1200 tick → 首次分岔 **tick 439**（1 specimen/300 tick 零分岔＝要夠多 specimen＋夠久才炸，與 measurer 觀察一致）。
**元凶隔離**：跳過 `capture_options` → **1200 tick 全同**。∴分岔源＝`options.gd::DecisionOptions` 對每個候選呼 `DecisionOptions.to_task`，而 `to_task` 的 closure 會呼 **`DecisionContext.gather`，gather 會寫 state**。
**寫入點清單（implementer 讀出、file:line）**：`decision_context.gd::gather()` `team.need_urgency = NeedHierarchy.ewma_update(...)`（**非冪等 EWMA**）／`:606` `plan_phase`／`:233` `LaborSystem.ensure_fresh`→`rebalance` 寫 `tile.labor_alloc`＋`labor_eval_next_tick`（**cadence 重排**）／`:243-247` `idle_employ_cached`/`idle_employ_next_tick`／`:546-549` `consolidate/absorb_target_cache`＋`consolidate_eval_next_tick`（§4b 另有 `expand_*` 同族）。
**已排除**：只還原 `need_urgency` 仍分岔；再加還原 team/tile cache 群**仍分岔** → 尚有別的寫入點（或多點合成）。**進行中**：`compute_domains` 前後比對指名域。
**★架構層意涵（比 specimen bug 大）**：`gather` 命名/語義是「取脈絡」但**實為 mutator**（EWMA 推進＋cache 寫＋**cadence 重排**）→ ①觀測器不可能「只看不碰」（[[feedback_observer_no_global_rng]] 同族第 4 例：LOD→RNG→specimen→gather-write）②任何未來的 what-if/預演/UI 預覽呼 `to_task` 都會改世界 ③cadence 重排使**呼叫次數本身**改變後續排程＝與呼叫者無關的耦合。修法方向（investigation 收斂後定）：gather 拆 pure-read vs commit 兩段，或給 observe-mode 抑制寫（**但抑制清單＝易漏的黑名單**，優先前者）。

### 👁 §4c 選址記憶可能被 `MEMORY_MAX` 擠掉（12mo 大考監看、非阻塞）
site 記憶（TTL **30 天**）與人際記憶**共用 `p.memory`**、FIFO cap `MEMORY_MAX=20`（`npc_ai_system.gd`（★L2 錨：檔級））→ 社交活躍 leader 的選址記憶恐**未到期先被擠掉**＝反饋迴路靜默失效。故 merge-gate 要求補 tap（`site_memory.write` vs `site_memory.applied`），**兩者落差＝eviction 吞掉的量**；大考時若 applied≈0 → 此 slice 名存實亡、需獨立儲存或抬 cap（抬 cap＝全域行為改動、需 fp intended-change）。

### ✅own_granary_tile(state=Nil) SCRIPT ERROR —— **已修且已驗**（2026-09-02 收案）

★**兩件先訂正**（原標題兩處都 stale）：
```
①「fix in feat/own-granary-pin」→ ★e8ad1cb8 已在 main（2026-08-15；`git log HEAD..origin/feat/own-granary-pin` ＝ 空）
②「pending measurer 12mo confirm」→ ★★確認已完成,而【不需要 12mo】——見下面的判準
```
★**修法位置**：`interaction_system.gd` 兩行 —— `TradeValuation.reserve(a, …)` → 補傳 `state`。
★★**修在【呼叫端】不是在 `own_granary_tile` 內加 null 守衛，而那是正確的**：
**修呼叫端＝不讓 null 進來；在被呼叫端擋＝把錯誤吞掉。**

★**證據（measurer 2026-09-02）**：
```
warring_states 30d ★完整跑完（自然 === DONE ===，非 timeout 砍）
  機會母體 proxy `trade.meet` ＝ 275 ｜ trade.barter_deal ＝ 88 ｜ ★SCRIPT ERROR(own_granary/Nil) ＝ 0
peaceful_economy 30d：`trade.meet` ＝ 1 ⇒ ★★systems 裁【不算證據】（母體 1 ＝ 幾乎沒母體）
`own_granary_null_caller_test.gd`：ALL PASS（★systems 親跑）
```
★★★**母體對得上被修的那條鏈**（systems 複核）：修的兩行在 `_attempt_barter` 內，
**而 `trade.meet` 正是該分支的計數** ⇒ **275 次機會走的就是被修的那條路，不是別條。**

★**誠實限（照 measurer 原文，不美化）**：`trade.meet` 是**上界 proxy 非精確呼叫計數**；
**275 次是抽樣不是窮舉，極低機率邊界 case 無法排除。**

### ✅（原文，存查）🔧own_granary_tile(state=Nil) SCRIPT ERROR（★根 pin 定案、fix in feat/own-granary-pin pending measurer 12mo confirm）
**★★2026-08-15 根 pin 定案（implementer runtime trace get_stack seed1337）**：呼叫鏈=`own_granary_tile←effective_holding←effective_food←_self_use(food)←need_keep←TradeValuation.reserve:91←interaction_system._attempt_barter:990`。**根=`TradeValuation.reserve(...)` 有 `state=null` DEFAULT 參數 + `_attempt_barter` 兩呼點漏傳 state** → reserve 內 state=null → 一路傳到 own_granary_tile(null) → `state.world.tiles` 崩。**onset 實際 day0.8（tick199 首 barter）非 day15**、mid-sim barter 常態（非 Probe-gated、plain warring baseline 亦崩已驗）→ **teardown/specimen/tail-end 假說全推翻**。**穷尽（reserve 全 caller）**：`_calc_reserve`（★★★真 stale 候選：2026-09-01 窮盡查 `scripts/**/*.gd`，**該符號已不存在** ⇒ 錨指不到現場；★不刪條目，標記待判）=死碼、`decision_context.gd::gather()`=武器非食安全路不達 own_granary、`player_trade_system.gd`（★L2 錨：檔級）=無玩家非 live → **barter 唯一 live 源**（12mo measurer 再驗此負斷言）。**fix=補傳型根修**（interaction:990/997 `reserve(...,state)` 補傳第 4 arg、**own_granary 零改=非盲 guard**）；post-fix 1000t byte-identical（窗內 barter 多非自家糧倉格→own_granary 兩側 null；12mo 若 bartering 隊在自家糧倉才分岔=正確行為修）。**MERGED e210c00a（2026-08-15）**。**★★誠實：barter live-sim 源修好但 own_granary null-crash 非 100% 關閉**——measurer 12mo(seed1337 full horizon)=**0 SCRIPT ERROR**（barter 唯一 live 源對該 seed/scenario 坐實、arc 12mo 量測解封=goal 達成）；**但 systems merge-gate 親跑 headless_test 見 `world Nil` `~18→7` 減少非清零** → **headless_test 自身另有一 null-state 路殘留**（12mo seed1337 sim 沒撞、非新 test 檔[獨立 SceneTree 未被 headless_test 呼]、非 diff 引入[本 merge 只移 barter 源+加 test/tap]）=**pre-existing 第二源、未 pin**。∴ 12mo 量測不受阻（goal 達成）但**此條保持 OPEN**（別標 resolved）；第二源 pin=follow-up（likely reserve null-default trap enables headless-fixture/rare 路、runtime get_stack 定位）。★教訓：measurer「0 error」是特定 seed sim、merge-gate 親跑 headless 才接住殘留、禁盲信單一維度 green 標全綠。★**latent trap 順記**：`reserve` 的 `state=null` DEFAULT 是這 bug 的溫床（讓 caller 靜默漏傳）→ 未來 hardening 候選=state 改必填參數（現 barter 修後無 live null-caller、暫無害、非阻塞）。
<!-- 原始 flag 紀錄（保留供溯源）: -->
### ⏳own_granary_tile(state=Nil) SCRIPT ERROR（原 flag、mid-sim onset、非 B4/B5）
measurer 跑 B4/B5 branch story-audit 尾端見 24 筆 `own_granary_tile state=Nil` SCRIPT ERROR（own_granary_tile:399 `state.world.tiles` on null state 崩）。**dump 已完整落地未受影響**、非 gate blocker。**systems code-trace 確認非 B5 引入**（所有 `need_keep`/`_self_use` caller 帶非空 state：labor rebalance←ensure_fresh←manufacturing/resource/B4 皆帶 state；beds 帶 state）→ B5 的 `_self_use`→`effective_food`→`own_granary_tile` 恆得非空 state。∴為**別的 own_granary_tile caller 在 tail-end 傳 null**（靜態掃不到 literal null caller、需 runtime trace 定位；疑 worktree 跑尾端 teardown/stale state ref）。**修方向**：own_granary_tile 頭加 `if state == null: return null` guard（防禦、cheap）or pin null-caller 修源。**★2026-08-14 12月長局 run 復發（大量 log-tail 噪音、非致命 sim 完成寫 json）**：確認**非** specimen 路徑（那輪 specimen tracer 未 enable）→ 別的 null-state caller of own_granary_tile 在 12mo sim 路（未 pin）。json 守恆**不污染**（`_pool_census` 逐 tile 直讀不經 own_granary）。**升優先級=值防禦 guard 修**（noise 大 + 差點誤診成 specimen blocker）。**★★2026-08-15 measurer ghosttown/founding run 新證據=推翻 tail-end 假說**：crash **onset day15 左右（非 day60+/teardown）**、6mo/2mo 兩窗兩度撞、error-storm 被外部 timeout 殺（需 `tools/godot-detach.ps1` WMI-parented 長跑才撐過）。∴**非** teardown/stale-ref，是 **mid-sim 正常運行期就有真 null-caller**。**★風險升級（非純 cosmetic）**：mid-sim null-state → own_granary_tile 返 null → team `effective_food` 靜默漏算自家糧倉 → **可能污染食物決策/量測**（[[feedback_full_transient_observability]] 憲法級：量測盲點不可接受）。∴ **修法改為 pin-root（runtime trace 定位 day15 null-caller）非盲 guard**——盲 `if state==null:return null` 會**遮掉** silent undercount（症狀補丁遮根、違 [[feedback_symptom_vs_root]]）；guard 若加須同時 log 呼叫者 stack 捕根。**blocks 12mo arc validation**（settlement/founding 深根在 12mo horizon 才顯、現連 day15 都撞）→ 需 blueprint/用戶排序（S1 merge 後 slot 一 investigation-slice vs 續 S2）。

### ⏸(舊)A1 stall latch+resume = 部分改善 HOLD（↑已升級為凍化 regression）（**A1 核心新 outpost founding 未坐實**，revert merge 待 per-action-count，blueprint 判 2026-07-26）
construction commitment latch + resume 治本（branch `feat/construction-commitment-latch` 5b166eb1，**已 revert 出 main** 5292faec，hold 不 merge）。**latch**（`_should_reeval` 施工中 skip 例行 cadence argmax，`force_reeval` 繞威脅 :401-423）+ **resume**（優先召回 `construction_team_id` 原隊繞 gate）。
- **★blueprint 6mo 雙 seed 判 = 部分改善非閉 A1**：①latch modest+seed 不一（stall seed1337 95.6→87.3、seed42 96→89.7 = 降 6-8pt 仍~90% 離格；complete seed1337 33→56 但 **seed42 12→10 反向**）②**★16/16 抽樣 completion 全 `action='upgrade_facility'`（既有 outpost 升設施），零筆 `'build'`（新 outpost founding）= A1 核心硬標準未坐實**（可能真 0、可能 8-cap 抽樣 missed）。
- **★我 merge 太快教訓**：我 1mo seed1337「完工率 86%」的 complete 上升**可能全是 upgrade_facility**（非 A1 要的 forest founding `action='build'`）。execution-verified 我驗 complete>0 但**沒分 completion action type**——A1 核心 = `'build'` completion 非任意 completion。連 [[feedback_verify_execution_end]]（驗對的效果非任意效果）。
- **★★手統一 signal（blueprint→用戶談序）**：latch 助 general 構造持守（upgrade 完工升=手統一一角）**但弱/不一/不閉 A1 核心 = patch 非 unification 的典型症狀**——正坐實用戶「手統一是矩陣維度、單 latch=patch」。可能轉**手統一 proper arc**（brainstorm→design→build 執行持守統一，別再 latch-patch）。
- **★下一步（blueprint 序）**：先加 cheap **per-action-type `outpost_built` 計數 tap**（分 `'build'` vs `'upgrade_facility'` completion）→ 100% 確認新 outpost `'build'` completion 真 0 還是抽樣 missed → 決定 A1 閉沒 → blueprint 帶結果+用戶序：(a) 轉手統一 proper arc / (b) 若 `'build'`>0 只抽樣 missed 則重估。latch branch hold。material PARK。

### ~~★★A1 仍 FAIL：construction pipeline stall~~（↑已根修，保留診斷史）（施工啟動後~完工前，systems code-trace 2026-07-25，QA 定位）
A1 forest founding **仍 FAIL**（outpost_built 兩 seed 0，dispatch 6080/1447 巨量但 completion 0）。QA 定位卡「施工啟動後~完工前」（Team49 抵達✓+start_build✓，tick43200 仍不完工、跑去 trade/賣 material）。**卡點從 decision 層（上輪 wrong-task TASK_BUILD 無 consumer，已修）搬到 execution 層後段**（同手不聽腦家族、卡點下移）。systems code-trace 因果鏈候選群：
- **#1 `_tick_construction`（outpost_system.gd:258-275）進度綁「施工隊持續在格 current_task==TASK_BUILD("建設")」**，非 tile 自倒數；`active_team==null` → 暫停。施工隊離格/改 task → 進度停。
- **#2（一階最強候選）start_build 尾 `transition("建設", PRIO_DISPATCH)`（:390）若被 arbiter guard 攔（task_arbiter.gd:116 `task_priority>=PRIO_THREAT and priority<task_priority`）→ current_task 留 TASK_CONSTRUCT("建造") → _tick_construction 認 TASK_BUILD 找不到 → 永不倒數**（工期 civ lv1=100tick，pop6 每 tick 減6 → ~17tick 該秒完，卻 tick43200 卡 = 倒數從沒跑）。
- **#3** current_task 非 TASK_BUILD → 子隊走 `_evaluate_subteam`:1721 CONSTRUCT 分支 → 抵達 10 天 timeout → release/merge → IDLE → 被 trade 分派挑 → 跑 trade（**符合 QA 見 Team49 trade**）。子隊 TASK_BUILD 有 1717 `return 不打斷`保護，∴ 跑 trade 反證 current_task 非 TASK_BUILD。
- **#4（確定 code 缺）召回 `_try_resume_construction`（faction_ai:2742）對 remote/founding 荒地失效**：`is_owner = t.team_id == tile.outpost_owner`，founding 荒地 `outpost_owner==-1`（owner 只在 _complete_construction set）→ is_owner 恆假 + resident 需 TAG_PRODUCE/同 faction + `days_left<3 不復工` → 施工隊離格召不回。**解釋既有 own-outpost facility 21/31（owner 在場當 resume worker）vs remote/荒地 0/N**。
- **診斷**：construction pipeline 原**全無 Probe tap** → 違可觀測性不變量 → 盲區。補 tap（merged 75bcf306，gate 74）→ measurer 6mo 定位。
- **★根定案（measurer 6mo tap 坐實 2026-07-25）**：三根連鎖**同一** = **construction commitment（TASK_BUILD）在 unified 決策層無 latch**。①transition 被蓋 63.8-67.7%②stall 95.6-96%（samples 全 `ct_reason='unified'`+`ct_task='外交'`）③resume 全失效 candidates=0。機制：外交/build 同 `PRIO_DISPATCH(50)`，guard（task_arbiter:116）只擋 `>=THREAT(70)` → 同級 raw 覆蓋；`_should_reeval` cadence 分支漏豁免 TASK_BUILD → 施工隊每 cadence 被 `_decide_unified` argmax 搶外交。**修**：`_should_reeval` 施工中 skip reeval（survival/威脅/命令例外保留）+ timeout release 對稱（spec `2026-07-25-construction-commitment-latch-A1-fix.md`，R² in-flight）。**HOW 決策層修（手不聽腦核心，統一決策框架缺 construction commitment 尊重），非升 WHAT**。★#4「荒地 owner==-1」候選被 measure **反駁**（owner 非-1，實際 team_id）＝我 code 詮釋錯（fileline 坐實 is_owner 邏輯≠坐實荒地情境）。material PARK。

### A1 remote-facility 分支 vs 既有 infra cadence 重疊（means-end re-measure watch，reviewer R² track 2026-07-25）
A1 修保留的「facility remote 分支」（owner 不在場→`_dispatch_facility_builder` 派子隊）跟既有 `_evaluate_infrastructure`/`_evaluate_independent_infrastructure`（faction_ai:3057-3075+，固定 cadence 對每有 outpost 隊[含 remote]跑 `_pick_facility` desire-based 選+就地/派 builder，早於 means-end）**目標完全重疊**（同 outpost 同 build slot 同 `_dispatch_facility_builder` consumer）。means-end 這分支有無真增量、還是被 infra cadence 搶先/重複＝**純讀 code 判不出，可測**（非本刀新造，S4 原設計就有，reviewer S4 審漏）。**re-measure watch**：量 means-end remote-facility candidate 實際贏 argmax 並成功派出次數 vs infra cadence 獨立完成次數。若高度重疊 → 下輪收斂目標（collapse 為一，同 same-tile defer 精神）。

### S7 cadence stale-satisfied 反向 staleness（means-end whole-measure watch，reviewer R² track 2026-07-25）
`ensure_maintain_goals` cadence-gate（每 GOAL_EVAL_CADENCE=3天）：maintain goal 標 `satisfied` 後，資源在 3天窗內轉短 → `frontier_candidates` 首關 `if status!=active: continue` 跳過 → **不走 `_resolve_resource_prereq` 重驗** → 該資源 means-end 取得候選靜默停擺，最長 3天才醒（下次 cadence tick）。**非 blocker**：既有靜態 REGISTRY option（買糧/覓食/貿易/返家補給，GATE-A/extraction/material-hold 三腿已密驗）**每 decide 即時不受影響**，真斷糧不會因此餓死；受影響的只是 means-end「順便去買/採一點」背景補給念頭反應慢。**whole-measure watch**：量 means-end maintain-goal「資源轉短→候選恢復延遲」實際窗口，3天在真實隊節奏下是否可觀察落後。若無影響（多半既有 option 早接手）純紀錄；若真問題 → S8 調 cadence 或「resource 型 goal status 判斷繞過 cadence，只 lifecycle 掛/退節流」的更精準設計。（★我 R² 論證漏 stale-satisfied 方向，reviewer 異質框外抓，good catch。）

### S5 _try_dispatch_or_invite residency 手評未退（means-end 委派 followup，2026-07-24）
S5 委派 peer option 把 build/settle 派子隊變體收進 rank 池（引擎化）+ gate② 根治，**但 `_try_dispatch_or_invite`（residency repopulate owned empty outpost 的手評 heuristic `ambition*0.5+military*0.3`，在 rank 池外）未退役**——語意不同（residency 填自己空 outpost ≠ 新 build/settle），退役需驗融合 residency 不退化。= 憲法債殘（means-end 委派已進引擎，residency 仍手派）。followup：residency 收進委派/rank 池 option = 後續 arc；whole 建完 measure 後或 means-end 收尾撿。

### S4 perf + facility-type-mismatch（means-end 設施型 followup，2026-07-24）
**(A) perf**：goal 生成（`GoalResolver.ensure_maintain_goals`）每 `rank_scored`（每隊每 decide cadence）呼，掃 5 maintain + 8 build_F × `_facility_deficit` → 較慢（headless exit 0 非 hang，非 blocker）。修 = **S7 goal 生成 cadence-gate**（非每 decide 呼）optimize。**(B) facility-type-mismatch**：隊有 civilian outpost 想建 mil-facility（allowed_outpost type 不符）→ 靜默無 candidate（改建/建新 military outpost 鏈 S4 不做）。whole-system-first 中間態；whole 建完 measure 若真需再補「建對 type outpost」子鏈。

### S3 unowned forest 優選（means-end 定位型 whole-measure 待撿，reviewer R² track 2026-07-24）
S3 material 缺口鏈 `find_nearest_terrain_tile` 純地形找最近 forest，**不排除已被別隊佔的 forest tile**。若最近 forest 被佔（`outpost_level>0`）：隊 migrate 過去 → 到達發現 occupied（build-closure `outpost_level==0` 不 fire）→ d=0 guard 壓移動 → **該 goal thread 靜默無 candidate，落回 static option（非 churn/crash，非退化，同 arc 前行為）**。∴ 非 blocker，但**次優**（該優選 unowned forest 而非最近）。真需 unowned 優選 = S4（設施 build owned/unowned 前置自然處理）或 whole 建完 measure 真值時撿。**別漏**。

### gate② settle attempt-gate 矛盾（flagged 不一致，DEFER 進 means-end 重寫）
`faction_ai_system.gd::_try_dispatch_or_invite()` attempt-gate `population>=8` 比 dispatch guard 鬆——`_dispatch_subteam_settle:574-575` 需 `pop − settler_count(clampi(pop/4,2,5)) ≥ MIN_PARENT_POP_AFTER_DISPATCH(=10,:142)` → **effective pop≥13**，pop 8-12 帶 **100% 浪費 attempt**（measurer 坐實 93-795 全 fail）。**非純 hygiene**（對齊 attempt-gate 會讓 pop8-12 落 `:569 else→_try_invite_nearby_exile`=多 invite=behavioral 改）+ settle/expand dispatch 整條 means-end 要重寫 → **現修=churn**。DEFER 進 means-end 全系統設計，不做零改版（無價值）。

## ★★★食糧地方安全 arc = session keystone：兩分配閘（2026-07-23，measure+QA+systems code 三方坐實）

24-37% 隊 end-state 絕境，**但 world food 34904 充裕**（surplus 79-82% posted）= **純分配 gap 非產量**。QA gate-vs-real-cost 判 + systems patch-gate-first code 確認 = **兩閘 + forest 真缺少數**：
**★end-state 分類（2026-07-23 measurer proper 跨-seed，double-reframe 定稿）——主體=GATE-A 非 no-outpost**：
- **★GATE-A settled-left-home = 56-61% = 主體**：擁 productive home outpost 卻離家（positional effective_food 低、疑離家超 PROVISION_DAYS=10 乾糧 buffer 耗盡）；positional harvest（`resource_system:53,71-76` 採站的 tile）→ 離家不採 home、home granary 空 → 困死。**修=返家補給認 home_food_productive**（spec `...-gateA-recognize-productive-home`，4 touch，R² CLEAN，**resume measure 中**）。
- **settled-on-productive 薄利 = 23-36%**：蹲自家 outpost 仍餓——`with-outpost collect 5.58-6.55/day < pop10 burn 8`（大隊自產打不平、需 trade 但 GATE-B 崩）。修=harvest rate / trade（GATE-A 後）。
- **no-outpost（harvest-infra）= 8-13% 少數**：`resource_system.gd`（★L2 錨：檔級） 無據點只狩獵（hunt 1.08-1.21/day≪burn）→ 蹲 tile_food_pool 上採不到（T48 transient）。blueprint 裁 **(a) forage subsistence 率**（∈(1.2,5.6)，無設施=低效存活非=0，憲法世界代價非腳本）——**降為第③序**（仍做、少數）。
- forest real-cost 0-3% 極少。
- **★教訓**：我一度據 measurer T48 **transient 單點** re-scope 成「no-outpost 主體」→ proper end-state 分類糾回 GATE-A 主體。**該先要分類分布再 halt，別憑單 specimen**（[[feedback_fileline_vs_interpretation]] transient≠end-state 主體）。
- **★re-prioritize（呈 blueprint）**：①GATE-A（56-61%）②薄利 harvest rate（23-36%）③no-outpost forage 裁(a)（8-13%）。②③繫 harvest rate/trade，可能 GATE-A+harvest rate 解大半。GATE-B（買糧空間錯配 arrive→attempt 崩）伺候剩餘 trade。
- **★★story-level 首證（QA 2026-08-20、EWMA trace 稽核順手獨立讀到）**：`peaceful_economy` team8 `tick2960→4860`（**約 8 天**）：`coin=1000` **整段不變**、`orders` 持續掛 `{kind:buy,res:food,qty_rem:17→21}`（**不減反增**）、`food_private` 卡 `0`，直到 tick4920 才一口氣跳 10。＝**「有錢、已下單、持續下單、就是進不了貨」**——比「有錢不買」重一型。**判定＝撮合卡死（GATE-B），非 genuine 斷供**。★意義：先前 GATE-B 的證據全是**聚合數字**，這是第一個**故事層**證據（QA 不看聚合、純讀逐 tick 也撞到同一堵牆＝診斷在兩個獨立層面互證）。
- **★★對 accepted cost 的歸因連動（待 A 項稽核查證）**：labor-v2 combined 那 **28 起 chronic 死亡**，若掛著買糧單而食物不動 → 部分死亡是**「買不到」（GATE-B）而非「honest 水位」** → **不改「接受代價」這個決定，但改它的意義**（代價的一部分可能是既有執行斷被高壓環境放大顯影）。**已要求 QA 做 A 項 specimen 稽核時一併查 `orders` 的 buy-food `qty_rem` 是否長期不動**。
- **★GATE-B = local-only 撮合（真空間分配，死法②）**：`_market_visitor_buy`（interaction:781）只從**抵達 tile 的 granary**買 → 遠方 surplus 搆不到 → 空間錯配（buy-fill 0.5%：seek 1363→arrive 333→fill 4；sell_no_surplus 主導）。同 material Gate B。修=分配機制（surplus 流向 demand），大於 GATE-A。
- **forest 真缺**（T7/T43/T47 regen<burn）=少數 + 被 GATE-B 堵死逃不掉，修 GATE-B 後自動有出路（買糧/遷移）。
- **★attack 序**：GATE-A 先（最大槓桿+survival-correct+洩 buy-fill 壓力）→ GATE-B（死法②分配機制，兼 goods）。**★session keystone**：兩閘=開頭 starvation 死隊 + 結尾 workshop-build 終閘同根。呈 blueprint sanity-check framing（`...-food-gates-confirmed-attack`）。連 [[project_economy_arc]] 死法②/[[project_desperation_economy]]。

## ★weaponsmith 真牆 = 兩 build 閘（非 trade，2026-07-23，material-buy arc 後 patch-gate-first）

material-buy arc（v1+v2a merged e6519f9f）修好 trade 側（mil 買 material，peak 117 vs baseline 98，QA coherent 0 餓死），**但 weaponsmith 仍 0 建=兩硬 build 閘**（血證：T26 material80+coin70 夠 base cost 仍不建=閘非供給/錢）：
- **閘① afford×1.5（`faction_ai_system.gd::_dispatch_goal_delegate()` `_dispatch_facility_builder`：`avail < cost×1.5`）**：weaponsmith material 80→需 **120** > 隊 carry-cap ~117（差 3 不可達）。**★系統性 margin 非 weaponsmith-specific**（連 civ site material 62→需 75 同卡；blueprint 撤回 facility-specific 框架，改系統性重審倍率影響範圍/計算方式）。★注意 [[feedback...]] 全域降 ×1.5 已 ABANDON（破 mint/G1a 空解窗）→ 系統性修須 mint-safe（如絕對-bounded buffer `min(cost×0.5, CAP)`，高 cost 設施可達、低 cost mint 不變）。
- **閘② tools=0 全域 = 生產端 demand-routing 缺口（QA reframe）**：workshop 已完工（Team6/30/3/19/45）產 tools（recipe `out:tools, in:material 4`）**但 `use_demand=true`**（需求驅動）；weaponsmith build-need（tools 3）**從沒發 tools-demand 信號** → demand-gated workshop 不產。★根：`order_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） buy-order res list **不含 tools**（只 weapon/material/ore）→ mil 隊無 tools 買單 → `demand(tools)=0` → workshop 不產 → tools 恆 0。= material「需求沒轉買單」的**生產端版本**（同 means-end 家族深一層）。★workshop civilian-only / weaponsmith military-only = cross-outpost-type，須經 trade（mil 買 tools ← civ workshop 產）。
- **修（blueprint 定 2 件）**：①**tools-demand 註冊**（means-end 擴 tools：weaponsmith build-need→tools need→tools 買單→demand→workshop 產→mil 買→afford）②**afford×1.5 系統性重審**（mint-safe 計算調整）。v2b coin **defer**（build 閘不解，coin 無用）。material 停止迭代（117 夠）。連 [[project_economy_arc]]。

## ★★★貧困陷阱 = reserve_factor urgency-suppression 兩鎖（2026-07-23 大設計洞，blueprint 命記·folds game-design）

**機制（架構自洽非 bug，但強故事）**：`reserve_factor = clampf(0.6 + (hoard-0.5)×0.5 - urgency×0.4, 0.1, 1.2)`（trade_valuation:97）；`urgency = max(food_urg, coin_urg)`（:108）。**常駐高 urgency → factor 壓穿（0.25-0.29）→ 隊把非活命品(material)賣到 reserve(cap×25-30%≈25-29)→ structurally 囤不到投資本(afford 門檻 105)→ 蓋不出原本能解壓的設施(farming 升級/weaponsmith 等)→ 永困高壓**。= **貧困陷阱**：越窮越守不住資產→越蓋不起翻身設施→越窮。
- **★兩把鎖（data 坐實，非臆測）**：`urgency=max(food_urg, coin_urg)`——
  - **food 鎖**：`food_urg=(DESPERATION-food_days)/DESPERATION`。**食安 keystone（GATE-A 等）解此把**。
  - **★coin 鎖**：`coin_urg=1-coin/(pop×URGENCY_COIN_COMFORT=10)`。3 trace 隊 coin_urg：T1(coin1.6)≈0.97、T35(12.3)≈0.80-0.88、T23(22.5)≈0.63-0.78——**光 coin_urg≈0.8→factor≈0.28=正中觀測**→**coin_urg 對 mil 隊很可能是 binding(max 那項)**。∴**食安修單獨不解 afford**（food_urg→0 但 urgency=max(0,coin_urg 0.8)仍 0.8）。coin 鎖 = 既有 coin poverty（mil loot→anon_treasury 不流 team.coin，v2b defer）**升格**：不只擋 material-buy，是 urgency 壓 reserve_factor 的第 2 把。
- **逃生閥 = 解兩鎖**：軍設施 afford 要 **food AND coin urgency 都降**。食安解一把；coin 鎖需另解（v2b coin 重框成「貧困陷阱第 2 把」）。
- **★★coin-cause 坐實=salary 主因 illiquidity（2026-07-23，你兩假說皆 refuted）**：measurer coin-split：net coin flow 兩族群結構性負、**salary=兩族群共同最大 drain（mil 50-67%/civ 51-55% 跨 seed）**。★blueprint 兩 coin-cause 假說 measure 皆非主因：①mil-loot→anon_treasury **假說原型不成立**（conquest-loot 零事件、mil trade net 正）②civ-dealflow/GATE-B **真但次要**（civ trade net -4~-31/3mo 比 salary 小一個數量級）→**GATE-B 非 coin 引擎，排後獨立**。★**root=illiquidity 非 shortage（守恆）**：salary→`AnonTreasuryBank.deposit`（隊自己 anon_treasury illiquid）+`_consider_extraction` gate `greed-prudence×0.5>0.4`（faction_ai:2365）→**中庸領袖（greed.5/prud.5=0.25<0.4）永不 extract→coin 鎖取不回 spendable**。∴coin 不是沒有是拿不回→湊不到 afford。**fix 偏 salary 機制（drain 太兇 or extract/recovery gate 太嚴）非加 coin**；salary WHAT blueprint 裁。R① 第4擋（兩假說 measure 前別 spec=對）。
- **★coin-scope full-pop 坐實（2026-07-23，keystone-level 但 not-binding）**：chronic coin_urg>0.5=**91%**（兩 seed 一致）、**mil+civ 皆廣布**（mil 100/94%、civ 89/90%，非窄 mil-loot 因）、結構性（transient 僅 1/64）、coin_urg×reserve_factor 反向確認（high-urg→0.25）→ **coin poverty=keystone-level 系統性經濟條件**（非窄 defer，折入 facility-build keystone）。★**但 facility_count 高/低 coin_urg 兩組皆近零**（0.03-0.07 vs 0.00）→**coin necessary-not-sufficient**，建造近零 regardless of coin=binding 在**別處（build-decision/survival-override 非 accumulation）**。∴**facility-build keystone=全 poverty-trap 逃生**。**★binding 坐實（2026-07-23 R① measure，refuted 我 survival-override 假設）**：既有據點加設施（keystone 主目標）**根本不經 decision.rank()**——走 `_evaluate_infrastructure`（faction_ai:3027 cadence-gated 50h）+建造掛 tile 非 team.task（與覓食不互斥）→∴**①決策端/survival-override 非 binding**。**binding=③afford**（dispatch_fail_afford 2523-2699 壓過所有 fail、success 0.7-1.1%、demand 健康 argmax fine→②means-end 也非 binding）=poverty-trap（reserve_factor 被食+coin urgency 壓）。**+queue-limit 次要**（_evaluate_infrastructure 每 call 1 outpost+INFRA_INTERVAL 50h 結構節流）。**survival-blood（建設 option 42-47% vs 7-14%）=真但另一族群**（bootstrap 立新據點,非既有據點加設施）。★**收斂**：facility-build binding=poverty-trap（食+coin）=食安 arc（GATE-A）+coin relief 正在做的匯流,**非新獨立 fix**；脫貧→reserve_factor 升→afford→建得起→發展。R① 第3驗（refuted 非 confirm，pre-spec 攔白修）。coin relief WHAT（coin 從哪來）blueprint 排。queue-limit/bootstrap-survival 另條。呈 blueprint（`...-facilitybuild-binding-converges-to-povertytrap-R1-refuted-my-hypothesis`）。
- 連 [[project_desperation_economy]]（絕境經濟根）+ [[project_economy_arc]] 食安 keystone + cost70-trace（下條，afford largely-ineffective 的真 root 就是此兩鎖）。

## ★cost70 診斷訂正 + construction cap 100 脫鉤 afford 門檻 = means-end 缺口鐵證（2026-07-23 blueprint factcheck）

**「material 天花板 117」= 診斷框架錯**（blueprint factcheck，systems 認錯=本場第 2 次 file:line≠詮釋）：117=`_calc_team_need`（faction_ai:2497，NPC 公庫領料進背包 target）**與建造無關**。**建造真機制**：afford=`avail(公庫+私 material) ≥ cost×1.5`（faction_ai:2801）；material holding 趨向 `reserve=need_keep(material)×reserve_factor`（trade_valuation:94，超 reserve 賣掉）；`need_keep(material)=self_use(0,PURE_INTERMEDIATE)+supply_chain(0 若無製造設施)+construction(cap 100,need_oracle:52)`。
- **★cost70 判定 = largely ineffective（trace 坐實，2026-07-23，此線第 3 次校正）**：measurer §④b 3 隊坐實 self_use=0/supply_chain=0/construction 撞 cap 100，但 **reserve_factor=0.256-0.292**（遠低 1.05，`urgency≈0.72-0.98` 常駐高壓，`trade_valuation.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） factor=0.6+(hoard-.5)×.5-urgency×.4）→ **reserve 25-29**（非「100×1.13」，我先前把瞬時 avail spike 113 誤當 factor=錯）→ avail 震盪 **19-60 罕達 105**，**3/3 隊 0 建**。∴cost70 對多數無效（降門檻 120→105 但隊根本囤不到 105）。**真 afford root = reserve_factor urgency-suppression**（隊常駐食/coin 高壓→賣掉 material→守不住），**非 cost/cap/117**——**連 align cap 也無效**（urgency 主導壓 reserve 到 cap 25-30%）。∴**afford 閘經食安 keystone 化解**（GATE-A 等食安修→urgency 降→reserve_factor 升→守得住 material→afford 自然過），非獨立 cost/cap slice。cost70=無害 balance 值（食安修後生效=銀行 pattern），keep（blueprint balance 桿裁 keep/revert）。code 註指向本條單源。**★此線=R① 觸發洞修的實戰第一驗**（trivial 80→70 扛未驗因果「117/cap gates 建造」）。
- **★★construction cap 100 脫鉤 afford 門檻（cost×1.5）= means-end 缺口 concrete 鐵證**（blueprint 頭號 exhibit）：`_construction_facility_need` 的 `CONSTRUCTION_MATERIAL_NEED_CAP=100` 是 **flat 常數**，**非從「我想蓋的 facility 實際要 cost×1.5」推導**——前瞻買料 target 拍死 100，不隨要蓋的東西動。∴cost70 門檻 105 > cap 100 對低-factor 隊搆不到=**target 沒對齊真需求**。**facility-build keystone 查證時 #1 exhibit**：若 **align cap ≥ cost×1.5**（讓前瞻買料 target = 真要蓋的量）證明是通用 clean fix → 直接坐實 [[project_economy_arc]] 記的 **means-end/長程計劃假說**（delayed-value discounting + means-end 依賴圖）。低優先（downstream throughput 先）但線索別丟。

## smeltery + armorsmith = weaponsmith afford-ceiling 同族洞（2026-07-23 generality audit，列意識非急）

用戶點破「武器坊的洞該影響所有設施」→ audit：afford×1.5 vs material 天花板 ~117 → **material≥78 設施撞洞**。**smeltery(material 80) + armorsmith(material 80) = ×1.5=120 > 117 = weaponsmith 降 70 前的同洞、這兩個沒跟著降**（mint 100→150 有 bootstrap 覆蓋；farming30/stable40/apothecary50/workshop60 ×1.5≤90 安全）。**非急**（還被上游 food-security→facility-build 稀少堵、military 隊沒到建這步，降了短期不建）。軍事鏈浮現時同款修（cheap：降 cost 如 weaponsmith）或 blueprint 順手降。今天 fix generality：①material need-gen ③produce_need demand-responsive ⑤workshop-build **confirmed-general**（機制自動全設施）；②買料 material-specific（tools 走 passive orders 已通）。

## crisis 門檻 flow-based 漏偵絕對餓（food=0×500tick 不 fire，2026-07-22，QA d26ae644 驗證撿，低優先）

**狀態：已知未修** ｜ **回訪：觸發事件 — blueprint 裁「要不要現在補絕對量判準」時（★修法明確，但它會讓 crisis 更常 fire＝平衡問題）**

★★**B 級 sweep 判定（2026-09-04）：真病，還活著。** `_decision_crisis`（`faction_ai_system.gd:3469-3479`）**只有三個判準**：
①pop 崩跌 %（`rung_pop_last`）②`food_flow_avg < RUNG_CRASH_FOOD_DEEP`③`food_flow_avg < GRADUAL_DECLINE_FLOW`
⇒ ★**沒有任何【絕對量】判準**（沒有 `food == 0`／`food_days == 0`）⇒ **「穩定的零」flow≈0 ⇒ 三條都不觸發**，與條目原始量測一致。

`_decision_crisis`（`faction_ai_system.gd:1858`）= **food_flow_avg 流-based**（`< RUNG_CRASH_FOOD_DEEP` / `< GRADUAL_DECLINE_FLOW`）+ pop-crash，**無絕對-food 條件**。`food_flow_avg`（`resource_system.gd::_update_food_flow()`）= daily_rate 的 EMA。∴ **food=0 stuck → daily_rate=0 → flow EMA→0 → 不 < 負門檻 → 不 fire crisis**。QA 坐實：seed1337 team54 food_days=0.0 連 500 tick（tick4800-5300）全程 `in_crisis=false`（11/11 food=0 DIVERT 事件皆非 crisis）→ crisis-escape 不 fire → 鎖空市場貿易 lingered（[SurvivalMergeIn] 併入 Team34 安全網接住沒釀死）。**根=crisis 只偵「流失中」不偵「已見底 stuck」**。**修向**：`_decision_crisis` 加絕對-food 條件（`team.famine_days > 0`=已進飢荒 / 或 `food_days < CRISIS_ABSOLUTE_DAYS` 硬底）→ 字面餓著必 crisis → crisis-escape fire → re-eval 求生。**低優先**（blueprint 裁 2026-07-22：merge 安全網接住、非釀死，記待查）。連 [[feedback_symptom_vs_root_retry]] + 下方 market-seeker 空市場 + DESPERATION cliff 同族（abandon-guard/絕境門檻連續化一批處理）。

## ✅（裁為行為正確，存查）market-seeker 卡空市場不放棄→餓死（2026-07-22 記；★2026-09-04 兩格量測結案）

**狀態：已知未修（★已結為【行為正確】）** ｜ **回訪：不需要（★兩格皆綠）**（訂正 2026-09-04）

★★★**最終兩格（blueprint 定判準，三 seed）**：
```
格一 餓深分帶：★`deep = 0／0／0`；輸掉的幾乎全在 `ge5`（13／11／6 ＝ 母體的 87%／85%／100%）
   ⇒ ★★淺帶輸給義務 ＝ **genuine 戰時紀律**
格二 實際後果：★`starved = 0／0／0` ⇒ **輸掉沒有造成餓損**（`ate 1／6／1`、`neither 6／1／1`、`gone 1／1／0`）
```
⇒ ★**依 blueprint 的表【任一格綠即結為行為正確】—— 而兩格都綠。**
★★**母體語意註記（implementer 標）**：格一數【次數】、格二數【episode】（每隊同時只掛一筆觀察）
⇒ ★★★**15→8 不是流失，是兩個不同的量** —— **不可相減。**（訂正 2026-09-04：★原症狀描述被推翻，★★而 systems 的第二個假說也被推翻，見下）

★★**量到了（三 seed）**：`applicable 15／13／6`｜`pop_block ★0／0／0`｜`land_block 2／7／13`
⇒ ★**systems 的假說（`FORAGE_VIABLE_POP` 用假理由把大隊排除在覓食外）在這個母體裡【一次都沒發生】** ——
**那批隊全是小隊（樣本 pop＝1／1／2／3）**。
⇒ ★★**主導的是 `applicable`（34／56 ＝ 61%）** ⇒ **覓食【進得了候選】而【一次都沒贏】**（第三格：覓食 ＝ 0／0／0）
⇒ ★★★**落在「util 相對量級」那一格，不是「缺一階」。**
★**而 per-seed 方向不一致**（applicable 佔比 88%／65%／32%；seed7 反而是 `land_block` 主導 68%）⇒ **混合，兩邊都報。**

★★**B 級量測結果（三 seed，2026-09-04）：症狀不是「卡在市場」。**
```
bail 之後：再去【同一格】15.0%／46.2%／53.7%｜換【另一格】0／1／0（≈0）
其餘（17／20／19 次）：外交 9／11／6、迎戰 4／8／9、逃跑 3／0／3、徵收 1／0／1、投靠 0／1／0
★★★而【覓食 ＝ 0／0／0】—— 三 seed 一次都沒有
```
⇒ ★**所以它【不是】卡在市場（它會離開），也【不是】放棄後去找吃的** ——
★★**是【被別的事叫走】**（外交／迎戰佔那一格的 76%／95%／79%）。
⇒ ★★★**條目原本的因果鏈（「卡空市場不放棄 → 餓死」）不成立；真問題是【餓著的隊離開市場後不去覓食】。**

★★**B 級 sweep 判定（2026-09-04）：一半有了，一半沒查。**
★**有的那半**：`interaction_system.gd:859` 已有具名 bail 桶 `trade.market_bail.buy_no_stock`（空貨會 bail）。
★★**沒查的那半**：條目的症狀是「**繼續 re-seek 同一市場**」——★★★**bail 之後會不會馬上再去，我沒有量**，
而那正是「治抖動＝治症」那條要求先問的（`feedback_symptom_vs_root_retry`：先問 X 能否曾成功）。

market-seeker（TASK_TRADE 去市場）食物低 + 市場空（Gate B under-production，無貨）→ **該放棄交易轉覓食卻繼續 re-seek 同市場** → 食物耗乾部分餓死。= 「該放棄不可行選項轉可行選項」手不聽腦類型，連 [[feedback_symptom_vs_root_retry]]（治重試 X 前問 X 能否成功）+ DESPERATION 連續化 / look-before-leap 同家族。**範圍小**（只 market-seek 卡空市場特定情境）。**排低優先 / 順手併 DESPERATION cliff known-issue 一起處理**（market-seek 應 look-before-leap：市場空/無我要的貨 → 不 applicable → 轉覓食）。★真根仍是 Gate B（市場有貨了此情境自消）。**注意**：原 market-seek stickiness fix（Gate A）已撤回（治症狀，建在 buggy divert metric 上）。

## workshop demand-deficit 封頂太粗→連續（follow-up，2026-07-21，reviewer R² 拆出）

`_facility_deficit` A 類 min_per_res：`tgt = need_keep + demand`（unbounded）→ 中度未滿足即 `worst→0` → deficit 恆封頂 1.0（cliff-ish）。workshop（goods demand 3573 巨）恆 1.0=score 恆高。**fix**：demand 貢獻 pop-relative 正規化（`demand cap pop×DEMAND_PER_POP_CAP`）→ deficit **連續反映 demand 量級**（同 team73 DESPERATION「連續非 cliff」紀律）。**blueprint 認可「兩個都做、①優先」**（weaponsmith demand fix=①先，此=②錦上添花公式品質）。reviewer R² 拆獨立 slice（綁 ① 會 conflate goods 行為 measure）。**排序**：weaponsmith fix merged 後獨立做。連 [[project_economy_arc]]。

## ★economy 補丁閘優先查 verdict（2026-07-21，re-baseline 後，blueprint 認可）

god-view arc 收官後 re-baseline（main 9c084d3a，乾淨 doom **21.2/22.5/0.6%**，舊 28% 作廢）。blueprint 序③補丁閘優先查（tune 前查假稀缺 vs 真 balance）：
- **① team73「缺糧仍貿易」= 非 patch-gate（非 urgent，設計問題）**：覓食=`PRIO_SURVIVAL` 本會 preempt 貿易=`PRIO_DISPATCH`（`options.gd:354`），無 task-priority override。真機制=**DESPERATION_DAYS(~3) applicability cliff**：survival opt gate 在 `food_days < DESPERATION`，team73 food=4.17 > 3 → 無 survival opt applicable → default 貿易。**= 門檻 cliff 非 bug，連 2026-07-16「連續急迫非硬 cliff」原則**（blueprint 標 known-issue 非 urgent）。修向（未來）：DESPERATION cliff → 連續急迫（食物越低越傾 survival，非硬 3 天開關）。
- **② 死法② = GOODS 供需失衡（res-split 坐實，2026-07-21 訂正）**：`goods reserve = need_keep(0)×factor ≈ 0`（code-read 對，死鎖早解）。**★但我原「one-sided FOOD 市場」verdict 被 measurer res-split 推翻**：`sell_no_surplus` **food 26 vs goods 276**（我稱的 302 實 91% goods）、buy **food 1093 vs goods 3573**（goods 3.3×）、**food_harvested 76k 豐產**。→ **真根 = GOODS 供需失衡**（goods 需求 3573 高、賣家 holding~0 → sell_no_surplus goods 276）。**教訓**：聚合 count（sell_no_surplus=302）沒拆 res 就下結論 = 誤讀（同 team16/75 坑）[[feedback_fileline_vs_interpretation]]。
- **③ economy 入口 = GOODS 流動性/供給（blueprint 裁 2026-07-21）**：food-結構 arc 取消（food 豐產，starve=分配非產量，另議）。**★market-liquidize branch（`feat/b0cdf624` 降 goods reserve）HOLD 解除、重啟**（一直對著正確的靶=goods 流動性）。
- **★決定性未決：goods「沒產夠 vs 產了瞬耗」**（measurer 拆分中）——定 fix 生產側（產出不足）vs 撮合/流動性側（產了賣不掉，market-liquidize 對）。**market-liquidize 全推進等此拆分**（blueprint「方向不明別走岔路」）。連 [[project_economy_arc]]/[[feedback-patch-gate-first]]。

## ✅null-belief-flee —— **已修並驗收（2026-09-02）＋ 退化去向已解一面倒（2026-09-03 收口）**

★★★**2026-09-03 收口**：換尺後 re-measure ⇒ **退化去向不再備戰一面倒**：
```
母體 2108 → 1977 ｜ 備戰佔比 74.4% → ★47.4% ｜ 其餘散進：建設 323／外交 184／覓食 118／貿易 92
```
⇒ ★**「怕了但沒地方去 ⇒ 一律去備戰」不再成立** —— ★★**而它同時是【威脅被系統性放大】那條根修對了的直接證據。**

★**收官數字**（`warring_states`／`seed 1337`／30 日；全文 `docs/measurements/2026-09-02-flee-to-safety-warring_states-seed1337-30d.txt`）：
```
`_flee_threat_pos` 呼叫 ＝ 351 ｜ ★桶 A ＝ 0、桶 B ＝ 0（★★從未回 (-1,-1)）｜ 設無效 ＝ 0
★★★backstop release ＝ 0   ⇒ 續卡【歸零】
退化（怕過門檻但無目的地 → 備戰）＝ 2108 ⇒ ★退化路【真的在用】（恆 0 才是可疑）
band（有座標、未過門檻、無目的地）＝ 163 次／27 隊 ⇒ ★★真滅團 0、被吸納或收編 1 ⇒ benign 未被推翻
```
★**驗收②那條防自欺的也過了**：**續卡歸零【而母體沒塌】**（351 次呼叫）——
★★**若 flee 路徑也一起靜下來，那會是「把恐懼擋掉」而不是「修好」。**
★★★**而第三站（`_decide_subteam`）30 日 fire 8 次卻沒造成續卡** ——
**構造解（`to_task` 帶 target ⇒ `try_set` 自己存）在真實資料上被驗證，不是只在推理上。**

## （原文）★null-belief-flee —— 2026-09-02 複驗：不是延遲，是【每 tick 重新製造】

★**量測（measurer，warring 30d 完整跑完）**：
```
flee 機會母體（曾進 TASK_FLEE）＝ 78 ｜ 續卡事件（FLEE+positionless 連續 2+ tick）＝ 1239
★續卡隊數去重 ＝ 15 ｜ ★★而 15 隊【最終全部脫離】—— 沒有原始 signature 那種「凍死」結局
```
★★**成因（systems 坐實，不是猜）**：
```
①tick 階段序：… strategic_move → move → … → ★faction_ai …
   ⇒ backstop 在 `move`，重新指派在 `faction_ai` ⇒ ★★同一 tick 內【先收尾、後重造】
②TaskArbiter.release() 是純欄位賦值、無排程 ⇒ ★成因「release 延遲生效」【機械上排除】
③faction_ai_system.gd:2973 與 :3539 兩處：`if task == FLEE: flee_from_pos = _flee_threat_pos(...)`
   ★★★而 `_flee_threat_pos` 有【兩條路】回 (-1,-1)：best_id == -1（找不到威脅）
      ／`BeliefSystem.belief_pos()` 回 (-1,-1)（positionless／過期）
   ⇒ ★兩處【零 guard，回什麼寫什麼】
```
★★★**所以修法沒壞、也不是延遲**：**下游每 tick 收尾，上游每 tick 重造** —— 「手不聽腦」同族形狀。
★**而它跟今天落地的 belief 三態直接相關**：`unknown` 現在是**合法的第三態**，
★★而 `invariants` 細則 1a 寫的是「**篩選時 unknown 一律不通過**」——★★★**這裡沒有篩，是直接寫進欄位。**

**狀態：已知未修** ｜ **回訪：到期 token — 待 blueprint 裁「怕、但不知道往哪逃」該做什麼**
（★那是 WHAT：不選 FLEE？原地戒備？隨機遠離？—— ★★HOW 這邊三種都做得出來，而它們是不同的世界。）

## （原文）★null-belief-flee 凍結（個體 FLEE 對空氣逃，2026-07-20，Slice E QA 抽查撿，★Slice D 前必修）

team75/4/13（seed1337）：`task=逃跑 + flee_from_pos=(-1,-1)` 全程 + 凍結 1 格 + food=0 餓死（team4/13 還逃跑↔建設 thrash）。**第 4 種 broken 家族（手不聽腦 finder-check classifier 看不到——不是「有 target 沒 dispatch」，是「dispatch 了但目標 null」）**。機制：個體 survival FLEE（`faction_ai:1595/1948` `flee_from_pos = _flee_threat_pos` = 威脅 **belief 位**）——belief 威脅**有存在感但無座標**（stale/positionless→`belief_pos` 回 `(-1,-1)`）→ `flee_from_pos=(-1,-1)` → 算不出逃離向量。`movement_system.gd`（★L2 錨：檔級） 說「(-1,-1) 不設 target 靠 release 收」**但 release 沒真發生** → 卡 task=逃跑 凍結不覓食餓死。**★PRE-EXISTING 確認（measurer baseline diff 2026-07-20：pre-E 8146c4a2 seed1337 此 signature 570 snapshots 跨 11 隊 16/38/56/57/58/63/64/66/68/92/93=凍結 pre-E 就大量在，非 E 引入）**——slice2 belief-化威脅位+缺 flee-release 引入，**每 belief-化 slice（E 已、D 更大）都暴露更多**。**★廣（11+ 隊）值得修。fix 已 build @28470932（applicability-gate：FLEE 威脅無座標 not applicable→轉覓食），measurer 量測中。****★Slice D 前必修**（否則 D doom-delta 被同款污染）。**修方向**（blueprint 認可，look-before-leap）：`flee_from_pos==(-1,-1)`（威脅無座標）→ **release FLEE → re-rank 轉覓食**，非凍結（FLEE 無座標=not applicable 不該卡死）。連 god-view arc（belief-化暴露）/[[feedback_fileline_vs_interpretation]]。

## market_orders capture/demolish 不清（★2026-09-02 systems 複驗：**斷言成立、錨錯**）

★★★**錨訂正**：原文寫 `outpost_system.gd::slot_cap()`(capture) —— ★**`slot_cap()` 是設施格數函式，不是 capture**，
而**整支 `outpost_system.gd` 對 `market_orders` 的參照數 ＝ 0**。★★真正的現場是：
```
outpost_system.gd:839  func capture(state, winner_id, tile, …)        ← ★零 market_orders 參照
outpost_system.gd:636  func start_demolish(state, team, …)            ← ★零
outpost_system.gd:825  func demolish_with_control(state, team, …)     ← ★零
（唯一會動 tile.market_orders 的是 order_system.gd:112/:256/:330 的到期/撮合裁剪）
⇒ ★★★易主與拆除【確實不清賣單看板】—— 斷言成立，只是先前指錯了門牌
```

## （原文，錨已於上方訂正）market_orders capture/demolish 不清（pre-existing 洩漏，2026-07-20，god-view Slice C v2 異質審撿）

`tile.market_orders`（賣單看板）在 outpost **capture/demolish 零清理**：`outpost_system.gd::slot_cap()`(capture) 只改 owner 不動 market_orders；`:327/332`(demolish) 清 type/level/owner/facilities 但**不清 market_orders**；`_sync_board`(order:61-84) 只 prune 自家 origin_team 單、失主後沒人清該 tile → 易主/拆除市集殘留舊賣單 ghost（`received_*_orders` 可能 route 到）。**pre-existing**（非 Slice C 引入；C 的 team_market_known 走 demolish-only cleanup=正解示範不繼承此病）。**非急**（economy 診斷用；C harvest 濾 `outpost_level>0` 已擋部分 ghost）。修=capture/demolish 順帶清/標 stale market_orders。連 [[經濟 arc]]。

## ⚠部分修 can_reach（2026-09-02 systems 逐行複驗：★god-view 那半【已關】，剩 `<999` vacuous）

★★★**2026-09-02 訂正（三處，全部是本條目自己寫錯）**：
```
①★god-view 已關：faction_ai_system.gd:1432 "can_reach" 現在讀
  `BeliefSystem.belief_pos(state, f.leader_team_id, target_id)`，無 belief 位 ⇒ return false
  ⇒ ★★【不讀 live 他隊位】。本條目原文「決策 precondition 讀 live 他隊位」★已不成立。
②★★錨錯：不在 :1115，在 :1432（可 grep `"can_reach":`）。
③★★★本條目原有的負斷言【是錯的】：它寫「force_ge_target 該符號已不存在 ⇒ 錨指不到現場」，
   而它存在於 :83（preconds 清單）／:1416／:1424（實作，讀 BeliefSystem.best_estimate）。
   ⇒ ★一個【錯的負斷言】在帳上掛了一天，而負斷言協議要求附窮盡搜索證據 —— 那次沒附。
```
★**仍然開著的是另一個病**：`_hex_dist(...) < 999` **near-vacuous**（hex 距遠小於 999 ⇒ 恆真）
⇒ ★★**以為任何 target 都可達即攻/追，`PathSystem` 真可達性從未查** ＝ **決策品質洞，不是 god-view**。
（★code 自己的註解已寫「`<999` near-vacuous(真可達語意)=另評」。）

**狀態：已知未修** ｜ **回訪：到期 token — 族①god-view 批的「逐顆分類」那一輪一併判**
（★判什麼：`can_reach` 該不該改成 `PathSystem` 真可達 + belief 位 —— **一次治 vacuous，god-view 那半已經不用治了**。）

## ✅（已關，存查）god-view 殘留 can_reach（faction_ai:1115，2026-07-20，Slice E measure 撿）

`_check_precondition` 的 `"can_reach"`（`faction_ai_system.gd:1115`）：`_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = **決策 precondition 讀 live 他隊位**（vs 同函式 `force_ge_target`（★★★真 stale 候選：2026-09-01 窮盡查 `scripts/**/*.gd`，**該符號已不存在** ⇒ 錨指不到現場；★不刪條目，標記待判） 用 `BeliefSystem.best_estimate` belief，**不一致**）= 真 god-view leak（違感知鐵律：決策憑 belief 非 live）。**但 `<999` 近-vacuous**（hex 距遠小於 999→恆真）→ god-view 效果近無害、**低優先**。**out god-view Slice E 4-site（E1/E2/E3/E5）**，歸下批 god-view cleanup（Slice E follow-up/D 批機械 belief_pos 化）。**★順帶疑（非 god-view，另類）**：若 `can_reach` 本該真 reachability gate，`<999` vacuous=**決策品質洞**（以為任 target 可達即攻/追，PathSystem 真可達性沒查）——可能 can_reach 該用 PathSystem 真可達 + belief 位一次治 god-view+vacuous。連 god-view audit（`docs/superpowers/handbacks/2026-07-19-systems-to-blueprint-godview-audit-scope.md`）。

## ★constitution_gate v3 god-view detector 揪 2 新候選殘留 leak（2026-07-20，god-view arc 收尾機器證撿）

`constitution_gate.gd` v3 加 god-view 偵測（gv_teamstate=indexed `state.teams[id].動態欄`；gv_mapscan=`for x in ...tiles` whole-map 掃）。enumerate 13 site，凍 baseline v2.txt（含分類註）。triage：7 legit（self/地理）+ 1119(_precond_met,修中)+ 1 gray(consolidate 同-faction own-member pop) + **3 候選 leak**：
- **★`_enemy_outpost_positions`（`faction_ai:2912-2921`）掃全圖敵據點回位置陣列 = 瞬知全敵基建**（違感知鐵律，隊應只知看過/聞得的敵據點）。未記過，detector 新撿。**行為敏感**（改 belief 影響防禦/攻擊規劃）→ 待 R²+measure follow-up slice。
- **✅（已關，2026-09-02 複驗）~~`decision_context.gd::gather`（`:373`）jhost live pos~~** ⇒ 現為 `scripts/simulation/decision/decision_context.gd:675` `BeliefSystem.belief_pos(state, team.team_id, _jhost)`，★**檔案路徑也變了**（`decision/` 子目錄）。原文：**`decision_context.gd::gather`（`:373`）jhost live pos 入 `PathSystem.find_path` 算 join 可達**（jhost=strong_neighbor cross-faction 時=god-view，同 1119 can_reach 類）。未記過，detector 新撿。待 R²+follow-up（可與 1119 同範式 belief_pos-gate）。
- `_find_trade_partner`（strategic_ai）partner discovered(belief) 但 outpost pos 讀 live = 半漏——**已知**（本檔「finder 濾鏈 C 類候選」+ invariants「team_discovered fallback 最終應刪」）。
- **detector 限制**：靜態 regex 分不出 loop var 自/他 → 不抓 `for t in teams: t.tile_pos`（DROP gv_teamscan 噪音），是回歸閘非證明；細粒度靠 review。
- **狀態 ✅ RESOLVED（2026-07-21）**：reviewer R² 判 2 新候選**皆真 leak**（半公共/需知位 REFUTED）→ **followup slice merged 63d93aab**（jhost=belief_pos 同 1119 / enemy_outpost=belief-about-owner store-free proxy，全圖 loop 保留只避已知敵）。baseline 訂正：jhost gv_teamstate 移除、enemy_outpost gv_mapscan re-classify gate-ok(belief-filtered)。gate PASS sites=75 **零 CANDIDATE-LEAK 剩=真 zero-untracked-god-view**。`_find_trade_partner`(strategic C 類候選)續掛 team_discovered fallback「最終應刪」（非 god-view 本 arc，另軌）。god-view belief-化 arc 全收官。

## ★野獸洩進 team 決策迴圈（beast-decision-loop leak，2026-07-19，crisis-immunity QA 故事稽核撿 team=-1000000）

**狀態：已知未修 → ★已修（結案存查）** ｜ **回訪：不需要（★守衛在迴圈入口，且有一道自承冗餘的第二道）**

★★**B 級 sweep 判定（2026-09-04）**：`faction_ai_system.gd:943`／`:1025` **兩個決策迴圈入口都 `if team.beast_kind != "": continue`**，
註解寫明「**野獸不進決策迴圈：非-agent 無「腦」不該經引擎的秤（憲法決策模型）**」；`:5740` `_evaluate_survival` 另有守衛；
`:4077-4078` 還有一道**自承冗餘**的（「防未來別條 extinct 路誤計」）。⇒ ★**條目描述的洩漏路徑已封。**

QA 讀 seed1337 trace 撿 `team=-1000000` 連 300 tick `task=建設 reason=ambition food=0 survival_would_succeed=true` 從不轉求生。**身分坐實=野獸**（`beast_system.gd:16` `_next_beast_id=-1000000` 負區段避 team id；TAG_BEAST/leader_id=-1/1 anon pleb/無 food 經濟=戰鬥標的 pseudo-team）。**根因＝beast 未 skip 出決策迴圈**：`faction_ai_system._evaluate_all_body` loop2(`:700` `elif team.faction_id==-1`，beast faction_id=-1 落此支)無 `beast_kind` guard → beast 跑 `_evaluate_independent_strategy`(建國/ambition)+`_evaluate_solo`+`_evaluate_independent_infrastructure`(建設)；loop3(`:759` leader_id=-1)→`on_leader_death` 晉升 anon 當領袖。∴ 一隻鹿/豬跑完整定居隊 AI（野心→建設→晉升領袖），荒謬且污染鄰隊 belief/經濟 + 污染 starve 分母計數。

**非 crisis-override 第 6 種 stuck-task 變體**（blueprint 疑「ambition@10 沒排進 preemption 鏈」= 症狀）。**根＝beast 是戰鬥 prop 非決策 agent，不該進決策迴圈**（補丁閘/root 通則：先查機械洩漏非猜 tuning；別加 ambition-preempt 補丁）。**★第二根（更深，blueprint 全 log 證據坐實 2026-07-19）＝beast id 碰撞**：`_next_beast_id` 是 **instance var 非 static**（`beast_system.gd:16`），但所有 spawn 走 `BeastSystem.new().build_beast_team()`（`faction_ai_system.gd::try_hunt_predator()`/`encounter_system.gd::_spawn_beast_units()`/`ambush_system.gd`（★L2 錨：檔級）/`player_command_system.gd`（★L2 錨：systems 判 2026-09-01 —— ★兩解排除法：舊行號 177 > `player_command_api.gd` 全長 159 ⇒ 只能是 system）=每次 fresh 實例）→ `_next_beast_id` 每次重置 -1000000、`-= 1` 對即棄實例無效 → **每隻 beast 都拿 team_id=-1000000**。`create_team`（`world_state.gd:256`）= `teams[id]=team` 靜默覆寫 → 後 beast 覆前 beast，前者從 dict 消失但 `combat_target`/belief 的 -1000000 ref 懸空指向新 beast。**這解釋 blueprint 全 log「-1000000 出現 20 次/8月,每次 Combat→晉升臨時領袖(統領0.03-0.28)→buy food」**＝20 隻不同 beast 全撞同 id、各自洩進決策迴圈跑 AI。blueprint 直覺「anon pool 聚合體」對其表象(臨時領袖無生活史)、根實=**id 碰撞 + 決策洩漏**。

**兩修（同票）**：①**id 碰撞**——`_next_beast_id` 改 `static var`（class 級持久跨 new()）或移到 WorldState 持久 counter，讓每 beast 拿唯一遞減 id。②**決策洩漏**——`_evaluate_all_body` loop2/loop3 skip `team.beast_kind != ""`（beast 只留 combat/cleanup 生命週期，在 npc_combat/encounter 非 evaluate_all）。①優先(懸空 ref hazard=更基礎,可能污染 belief/combat_target/其他量測)。behavior 變(beast 停建設/晉升+唯一 id)→非 byte-identical，measure 驗真隊無 regression。**排序**：獨立票，off crisis-override merge 後 main（避 faction_ai 衝突）→ spec-light+R²+dispatch。**與 crisis-immunity 無因果糾纏**（pre-existing）。**★狀態（2026-07-19）：fix 實作@7fb16350 gates/determinism 全綠但 seed1337 真隊 8mo REGRESSION（starve 0→5,attrition 3.15→20.27 ~6.4x,可重現）→ blueprint 裁 investigate,merge HOLD。systems code-read 看不出顯機制（決策-skip 後 beast 被動→「累積圍毆」講不通;beast 勝敗 _end_combat 都 _cleanup→accumulation 不明顯）→ measurer 跑 month3→8 specimen trace（4 信號:beast count/hunt-meat/死因/divergence-point 分機制vs混沌）。混沌→accept;真機制→systems 查根因（accumulation 真則補 beast 生命週期界非 revert id 修）。****provenance（measurer 回證 2026-07-19，closed）**：`extinct.starve` bump（`faction_ai:2299 _on_team_extinct`）**無** TAG_BEAST 守衛，**但** seed1337 baseline 6 starve 全真隊（tid 48/58/52/19/96/35，beast_kind 空，pop=0，famine~33d），**零野獸** → seed1337 真隊 starve 乾淨可引用。2299 加 TAG_BEAST 守衛 = defense-in-depth（beast fix loop3-skip 已關 beast 走 extinct 路，冗餘），已給 implementer 順手可選。**bed 盲點旁註**（blueprint 提）：現 specimen bed 無視野/belief/鄰近資源欄→答不了「窮死前視野多大」；`survival_would_succeed=true` 有海市蜃樓前科(2026-07-14 買糧 applicable)不照單全收→嚴查此類需補欄。連 [[project_desperation_economy]]/[[feedback_patch_gate_first]]/[[feedback_symptom_vs_root_retry]]。

## ★TaskArbiter.transition = 無條件 raw 覆寫後門（手不聽腦，2026-07-19，team16 QA 撿 → systems patch-gate 查坐實）

`TaskArbiter.transition`（`task_arbiter.gd:108-112`）直接賦值 `current_task/task_priority/task_start_tick`，**不檢查 priority、不檢查 crisis-免疫 guard（只在 try_set:45-47）、不檢查 combat lock**。13 caller（`faction_ai:2638/3876`、`interaction:1249/1264/1289`、`outpost:384/406/447/461/566/602`、`player_command_system.gd`（★L2 錨：systems 判 2026-09-01 —— ★兩解排除法：舊行號 1017 > `player_command_api.gd` 全長 159 ⇒ 只能是 system）、`sim_runner.gd::_advance_tick_body()`：defection「等待新領主」/建設/生產/BUILD/beggar-restore）**全繞過**三檢查。∴ transition 可 **clobber 引擎剛派的 survival@80**（手不聽腦：機械 override pre-empt 引擎決策=補丁閘家族）+ **重設 task_start_tick 使 `_famine_crisis`(faction_ai:3462 baseline)恆重置→crisis 永不 fire**。

**血證=team16**：defection path A（`faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走））transition「等待新領主」@AMBIENT → team16 famine `would_succeed=true` 凍死 300 tick（crisis 永不 fire + 免疫抓不到 transition 重鎖）。**PRE-EXISTING @35e9ee8f**（beast-fix 不碰此路）。

**修方向（HOW，待 spec）**：transition 至少守 combat lock + 不 clobber 更高 priority（survival/combat）+ 尊重 crisis-免疫。★13 caller 有正當用途（安頓→生產就地轉換）→ spec 需 measure 逐 caller 不破。排序=beast-fix 定性後（絕境經濟/手不聽腦 arc 真根之一）。連 [[project_desperation_economy]]/[[feedback_patch_gate_first]]/[[project_reverse_engineering_arc]]（控制層手不聽腦）。

## crisis-immunity 覆蓋不全（2026-07-19，team16 揭）

**狀態：已知未修 → ★已修（結案存查）** ｜ **回訪：不需要（★覆蓋面已從一個入口擴到兩個）**

★★**B 級 sweep 判定（2026-09-04）**：條目說「免疫 guard **只在 `try_set`**」⇒ ★**現在兩個入口都有**：
`task_arbiter.gd:79`（`try_set`）與 **`:202`（`transition`）** —— 同一組條件（`crisis_released_task` ＋ `crisis_released_until`）。
★★★而 `:197` 的註解正好記著當初為什麼要補第二站：「**呼叫（defection「等待新領主」@AMBIENT）clobber 引擎剛派的 survival@80 ＋ 繞免疫 → crisis 永不 fire**」。

crisis-immunity（35e9ee8f/b71647ab）免疫 guard **只在 `try_set`** → 只覆蓋「release 後走 **try_set** 重委派」的重鎖（team1/19 被接住）。**走 `transition` 的重鎖（team16「等待新領主」）未覆蓋**。∴ 原 release-pass（靶三隊 team1/19/13 剛好全走 try_set 路）= **樣本不完整**，免疫修對它瞄準的有效但覆蓋不全。**非推翻已 merge**（免疫對 try_set 路真有效），但誠實記「覆蓋範圍=try_set 重委派，transition 重鎖需上條 transition 修一併治」。blueprint owner 補 game-design 對應處。連上條 [[TaskArbiter.transition 後門]]。

## ★subteam-idle-latch = 第三種手不聽腦 —— **2026-09-02 runtime 複驗：★病還在（不是好了）**

★**證據**（`seed 1337`／3mo／`tick=60000`，同一 tick 同一母體）：
```
命中(手不聽腦) = 2 ｜ ★機會母體(near_death_tracked) = 161
其餘同批分類：famine = 0 ／ stuck-task = 92 ／ food-ok = 67
★判準（bed :33-46）：would_survival_dispatch_succeed ＋ survival_finder_hits ＋ task ∈ {idle, 等待新領主}
   ⇒ ★★【引擎派得出、finder 找得到食物，而隊坐著不動】—— 這正是 #10 的 signature
★★★命中在 tick=60000 才首次非 0（20000／40000 皆 0）⇒ 低頻但真實；3mo 起跳即可捕到
```
★**不與 2026-07-19 的「6 隊」直接比較**：窗長／進度不同（本輪只跑到 46% 就被 timeout 砍）
⇒ ★★**「6 → 2」不是改善的證據，只是兩次不同的量測。**

★★★**而同批的 `stuck-task = 92` 我要標一個【命名風險】**（★不是缺陷，是讀法陷阱）：
```
★該格的判準只有一條：`survival_committed_option != ""`（有 committed option）
★★而名字叫「stuck-task」—— ★★★名字宣稱【卡住】，判準只證明【有承諾】
⇒ 一隊「已承諾覓食、正在路上、目前仍近死」會被歸進去，而那可能完全正常
⇒ ★不要拿 92 這個數去說「92 隊卡住」。要說那句話，需要另一次量測（有沒有在推進）
```

★★★**2026-09-02 再訂正：病【移了位置】，而移它的是量測**
```
再派 funnel 上線後實測（systems 獨立複跑一致）：
  candidate_sent = 3 ／ ★not_in_ranked = 0 ／ won = 0 ／ ★★lost = 3
⇒ ★★★候選【一直都在候選集裡】—— 「缺再派 funnel」那一格是 0
⇒ 病不是【送不回去】，是【它每次都輸】
stall 三態：WAITING = 114 ／ RESOLVING = 0 ／ STALLED = 0
⇒ ★床自己說「這個窗還沒走到判定點」，★★不是「安全閥不動」——★★★兩者差很多，靠三態 tap 才分得開
```
★**所以 blueprint 2026-09-02 裁的「#10 的病＝缺再派 funnel」前提【不成立】**（已呈報，非我自行改裁）。
★★**下一步是 per-option util dump**（memory `feedback_measure_peroption_util_before_decision_claim`：
決策問題禁靜態斷言，先 dump 真實 per-option util 再開藥）—— ★★★**在那之前不得對「為什麼輸」下任何結論。**

**狀態：已知未修**（★2026-09-02 由「未確認」升格，runtime 證據見上） ｜ **回訪：到期 token — 修法 slice**
★★★**逐隊明細（2026-09-02，有界 dump 只 2 隊）＋ 一個【欄位不可信】的發現**：
```
team 213  tick 52798  task=idle  prio=0  reason=survival  food_days 2.88  pop 2  committed=紮根  finder_hits=true
team 219  tick 54118  task=idle  prio=0  reason=survival  food_days 1.88  pop 2  committed=紮營  finder_hits=true
```
★**`reason=survival` 這一欄【不可當證據】**（systems 2026-09-02 查出）：
```
task_arbiter.gd:161 release() 清 current_task／move_target／task_priority／flee_from_pos
   ★而 flee_from_pos 那行的註解就寫著「避 stale 殘留」⇒ ★★紀律存在，只是【漏了 task_reason】
⇒ ★★★所以 idle + prio 0 的隊身上那個 reason，是【上一個任務的殘留】，不是「引擎現在想求生」
⇒ 而 #10 的 signature【不依賴 reason】(判準是 would_dispatch + finder_hits + task==idle) ⇒ ★#10 不受影響
```
★★**而 `committed=紮根/紮營` 是另一回事，我【不下結論】**：`survival_committed_option` 只在
`faction_ai_system.gd:5944/5948`（解承諾／清蓋）被清，**`release()` 不碰它** ⇒
★**「承諾活過任務釋放」可能是【設計如此】（承諾 ≠ 任務）** ⇒ ★★★**已送 blueprint 裁**，
**而那個答案就是 #10 的核心**：若承諾活著而沒有任何東西重新派它，那就是 latch。

★**落地路徑**：`docs/process/verdicts/subteam-idle-latch-recheck-2026-09-02.measure.json`
／`docs/measurements/subteamidle-recheck-mainHEAD-seed1337-3mo-v2checkpoint.txt`

## （原文）★subteam-idle-latch = 第三種手不聽腦（6 隊，2026-07-19，QA 抓 measurer undercount，HIGH）

bed 3 分類 classifier 測出 **6 隊同款 broken**（team62/71/73/79/84/90），同 signature：`food_days 足(2.5-4.58) + committed=覓食/遷移找糧 卻 task=idle 不執行 + reason=subteam + survival_dispatch_would_succeed=true`。measurer 只回報 1 隊（team84）= undercount，QA 逐隊讀 classifier 抓齊 6。**starve metric 天然看不到**（food OK 不進 famine 分母）→ 別靠聚合判此 arc，需 QA 逐隊讀。

**獨立於 transition-bypass 的第三種手不聽腦機制**：transition 路（defection-stomp）已修（[[TaskArbiter.transition 後門]]），這 6 隊走 **subteam dispatch 路**（`reason=subteam`，疑 subteam 指揮/併隊後 dispatch 沒正確執行 committed 求生 task）。**patch-gate-first**（非 tuning）：查 subteam dispatch 為何在 `committed=覓食` 且 `would_succeed=true` 時仍卡 `task=idle` 不執行。優先序 HIGH（同 quality bar「沒有隊伍能坐著/掙扎落空地餓死」）。歸 [[手不聽腦 mini-arc]]。

## task-priority-preempt 缺口（team48 型，2026-07-18，QA ② ladder 稽核順帶抓，與 ② 無關）

**狀態：已知未實裝** ｜ **回訪：觸發事件 — 持守統一 arc 動到「硬表→人格化」那一步時**

★★**blueprint 裁（2026-09-04）：排除項【維持】，不改成可 preempt。**
```
★理由一：JOIN／BEG【本身就是求生階】⇒ ★★打斷求生去求生＝無意義
★理由二：`PREEMPTIBLE_TASKS` 這張【硬表】＝死常數，該走【人格化】那條路 ⇒ 歸【持守統一 arc】
★★★附守衛（blueprint）：**卡在不推進的排除任務**＝【執行失敗反饋】管轄，**不是 preempt 管轄**
   ⇒ 那條路已經有擁有者，不要在這裡開第二套機制
```

★★**B 級 sweep 判定（2026-09-04）：缺口【由構造而生】，而那個構造是刻意的。**
```
`PREEMPTIBLE_TASKS`（`faction_ai_system.gd:149`）＝ PRODUCE／MANUFACTURE／BUILD／TRADE／GOVERN／TRAIN／FORAGE／CAMP
★註解自己列了不含哪些：ATTACK/LOOT(戰鬥)、FLEE/DEFEND/PREPARE/HOLD(已 threat)、REVOLT、JOIN/BEG(social)、survival
⇒ ★★`:464` 忙且不在清單 ⇒ **直接 return** ⇒ 生存決策打不斷它
```
⇒ ★★★**所以這不是「漏了一行」，是【要不要把 social/REVOLT 也變成可打斷】的設計選擇** —— **交 blueprint。**

QA 讀 seed4201 specimen 時抓：**team48 死於另一個既有 task-priority-preempt 缺口**（survival 該 preempt 的 task 沒 preempt 到），**與 desperation-ladder ② branch 無關**（非 ② 引入，pre-existing）。① priority 單一源收了 5 dispatch 路的 survival 保序，但 team48 這型疑另一 preempt 路徑漏（待 code-locate）。**獨立票**：不擋 ②。修前先 grep locate team48 走哪條 dispatch + 為何 survival 沒 preempt（別假設=本 session 反覆 state-錯教訓）。連 [[project_desperation_economy]] ① single-source。

## ★★★乞食 —— **框架訂正（2026-09-02，30 日實測）：「引擎從不選它」是假的**

**狀態：已知未修** ｜ **回訪：觸發事件 — 若日後施主可及率（世界薄溫度計）出現劇變**（★B 級 sweep 補欄 2026-09-04）

★★**終態（blueprint 預填 ＋ 本 session 續判）**：**決策層結案** —— 而 2026-09-03 施主線再結兩條存查：
**深帶找不到施主＝可接受的世界性質**（守衛：「無施主 ∧ 無其他階」交集三 seed 全 0，分母 75／68／79）／
**「必須知道對方存糧」假說＝已證偽**（③通過的相異 target ＝ ②的 84–90%）。

★**實測**：30 日**全 pool 路【贏 6 次】** ⇒ ★★**條目原文「6 specimen 全程從沒選過」不成立**（那是 specimen 樣本的事實，不是引擎的事實）。
★★★**交叉驗證（今天最強的一格證據）**：這個 **6** 與 flee 那張表的 `top_乞食 = 6` **是兩支獨立的床、同一個數**。

★**而擋住它的閘，兩條路【完全不同】**：
```
全 pool 路（統一 rank）  → ★食物門檻擋掉    4341 / 4519
絕境階梯路（rank_survival）→ ★★沒有援助對象  199 / 209
⇒ ★★★所以「乞食不 fire」不是一個問題，是【兩個】：一個是【還不夠餓】，一個是【沒人可乞】
   —— 而它們的修法完全不同（前者動門檻／後者是「找得到對象嗎」）
```
★**輸的時候**：★★**28 次輸給【備戰】** —— 而那是床裡刻意設的「贏家跟糧食無關」訊號（見下方跨 arc 條目）。

★★★**2026-09-03 分帶量測 ⇒ 兩條路都結案，而【真 binding 轉到別的地方】**：
```
★判準（blueprint 定）：最深帶（food_days→0）且【施主可及】時，乞食贏不贏？
★★答案：★★★【會贏】—— 階梯路 seed7 deep 帶 applicable 84、贏 41（49%）
   而輸的那些是輸給【併入／買糧】＝ 更好的出路 ⇒ ★照判準：【不是決策病】
★★★而真正的 binding 是：★施主可及率【隨餓深崩塌】 37.5% → 4.0%
   ——★★兩個 seed 的階梯 deep 帶是 **0.0%**
⇒ 「乞食不 fire」的真因不是秤，是【世界裡沒有施主】—— ★★★修法在【關係密度】不在【秤】
```
★**所以這條的兩半都不是原本以為的病**：階梯路輸得 genuine、統一路的 util 差與備戰無關、
★★**而擋住它的是【世界薄】** ⇒ 已另立條目（關係密度）。

**狀態：✅結案（決策層）** ｜ ★**而真 binding 已轉出成新條目：施主可及率隨餓深崩塌**

## （原文，框架已於上方訂正）★乞食死 rung——引擎幾乎不選乞食（2026-07-15，desperation QA 複判抓，絕境階梯斷階）

desperation 複判 6 specimen **全程從沒選過乞食**、log 無 beg print → 不是「幻覺」（never-selected 不守幻覺），是**引擎幾乎不選它**。該乞食的謙卑窮隊從不乞食＝絕境階梯一個死 rung。**非 desperation A 刀 blocker**（A=不選幻覺；乞食沒被選無 A 問題）。**★根因坐實（2026-07-15 code-read，非 util 是 applicability 門檻太嚴）**：`_find_aid_target`（`faction_ai_system.gd:3448`）要求 belief 有 **`food_est` 具體糧估** + 信它有餘糧（`food_est > pop×14`）——這種私有針對性情報通常只在**先前交易過/派人打探過**該隊才形成。剛絕境的隊大機率對鄰居無此具體 belief → `has_aid_target` 常年 false → 乞食**連候選都進不去**（與 util 無關）。對比買糧只需「聽過市集廣播賣單」（公開）寬鬆得多。**乞食非幻覺**（`_resolve_aid_request` mercy floor 有完成路，code 雙證）。**★blueprint WHAT 裁定（2026-07-15）＝盲乞食**：乞討本質＝對**可見鄰居的絕望懇求**（非對已知富 patron 的針對性精算）→ 放寬門檻：絕境隊對可見鄰居**盲試乞食**（不需 `food_est`，`has_belief`/視野內有隊即可）→ 撲空 emergent（謙卑施主給、禽獸拒；mercy 路真能救命＝可選 rung）。**人格 gate**：高求生欲/謙卑/低野心→肯乞；驕傲→寧死不乞（接決策模型）。**backlog 非本刀 blocker**（乞食 dead≠coherence bug，隊有覓食/遷移/掠奪其他路不 limbo）→ 歸「絕境階梯完整性」arc（見 progress.md，與抱團+食物流通同做）。連 [[project_desperation_economy]]。

## ★★★威脅值 29 天不變 —— **框架訂正（2026-09-02 先查）：不是「實體沒 despawn」**

★**保留【當時觀察到的症狀】**（那部分仍然有效，不因框架錯而消失）：
> Team18 後半 `threat_id:10 / threat_pos:[13,5] / threat_react:8.7` **29 天一個小數點沒變**，而 food 卻爬 279→…
> ——「無事發生的假戲」族（2026-07-15 QA desperation 複判抓）。

★★**而原標題的框架【套不上】**（systems 2026-09-02 窮盡掃 `threat_id`，全站 12 處）：
```
decision_context.gd:159  var threat_id: int = -1        ←★它是 DecisionContext 的欄位
decision_context.gd:323  c.threat_id = _best_id         ←★★每次決策【現算】
team_data.gd             ⇒ ★★★【沒有】threat_id／threat_pos／threat_react
⇒ 威脅【不是持久實體】⇒ 「無 resolve/despawn」這個描述沒有對象
```
★★★**所以真正的問題要重問**：**為什麼【每次重算】都算出同一個值？** 兩個完全不同的解釋：
```
(a)★真的有一個穩定的鄰居威脅 ⇒ ★★合法，不是病
(b)★★belief 過期而一直回同一份 stale ⇒ ★★★那是【belief 衰減層】的問題，不是威脅層的
```
★**歸屬（blueprint 2026-09-02 裁）**：**症狀多半在 belief 衰減層**；若查證成立，**掛 threat-oracle arc**。
★★**查法**：dump `_best_id` 的來源與該 belief 的 `last_tick` 年齡 —— ★★★**不是加 despawn。**

**狀態：未確認** ｜ **回訪：量測窗 — 下一輪任何跑 threat 決策的床，順手 dump `_best_id` 來源 ＋ belief 年齡**

## （原文，框架已於上方訂正）★凍結威脅實體無 resolve/despawn（2026-07-15，QA desperation 複判抓，「無事發生的假戲

**狀態：已知未修** ｜ **回訪：觸發事件 — 動到 belief 衰減層時**（★B 級 sweep 補欄 2026-09-04）

★★**終態（blueprint 預填）**：**框架訂正，歸【belief 衰減層】** —— ★**不是「威脅實體沒被清掉」，是【belief 沒有衰減】**
⇒ 修法屬那一層，不在本條目自己的範圍。」族）

Team18 後半 `threat_id:10 / threat_pos:[13,5] / threat_react:8.7` **29 天一個小數點沒變**，food 卻爬 279→369＝**威脅實體掛著不動、無 resolve/despawn**，撐 survival 決策常勝（原地戒備恆合理）。QA 判「無事發生的假戲」家族（決策合理但底層世界靜止不動＝同 thrash/mirage 族——決策層對、世界層沒對應動作）。**修向**：威脅實體須有生命週期（接觸→交戰/嚇退/despawn），非永久靜掛。**可觀測性**：威脅 tap 已能抓（threat_id/react 凍結可見），故此 bug 現形＝觀測投資回報。優先序中（撐假 survival 常勝＝掩蓋真求生壓力）。

## ★SpecimenTracer combat-death 盲點（2026-07-15，違全量暫態觀測不變量）

Team14 真死於 combat（tick9599）但 `decision_count=0`、trace 空＝**combat 死接不到 SpecimenTracer**（tracer 只接決策路徑 capture_decision，combat 結算死亡不經決策 tap）。**違 `invariants.md §全量暫態可觀測性`**（combat 死也是決策依賴的暫態/結局，該可 trace）。**修向**：combat 死亡結算補 SpecimenTracer tap（死因+死前狀態），比照決策 tap。**歸屬**：全量暫態可觀測性補洞（同交易/威脅 tap 家族），非 desperation 刀 blocker。

## survival-latch: _evaluate_survival 每-tick 重觸 churn（2026-07-15，掠奪根 scrap 後 measurer 定位，non-fatal backlog）

**狀態：已知未修** ｜ **回訪：觸發事件 — 兩個重開條件之一成立時（churn【普遍】或 perf【貴】）**（訂正 2026-09-04：★條目自己寫著這兩個條件，而它們**都不成立**）

★★**B 級量測結果（三 seed，2026-09-04）**：
```
普遍度（當日切換 ≥2 次的隊 ÷ 該日有 survival 決策的隊）＝ ★6.2%／5.9%／7.1%（三 seed 一致低）
perf（`loop3.survival` 佔比，★`exclusive=yes` 獨佔跑）＝ ★★1.08%／1.50%／0.76%
```
★**perf 的方向是保守的**：`phase_timing` 自己會膨脹被計時段 ⇒ **開著計時都只佔 1% 上下，關掉只會更少** ⇒ **可以結論「不貴」**。
★★**而 implementer 自揭兩個標籤錯誤，兩者都不改變結論**：①分母其實是 `_fai_ph` **全部** key（含 loop1/loop2）——
★★★**而那反而是更該用的分母**（survival 佔【全部被計時工作】的比例）；②累積窗**比一 tick 長且未量**——
★**但比率不受影響：分子與分母共用同一個窗** ⇒ **不知道窗多長只影響【絕對值】，不影響【比率】。**
⇒ **兩個重開條件都不成立 ⇒ 依條目原裁定（噪音非 bug、停追）收。**

★★**B 級 sweep 判定（2026-09-04）：讀 code 判不出，需要量。**
```
★`_evaluate_survival(state, team)` 仍在 loop3 【每 tick】被呼叫（`faction_ai_system.gd:1100`，呼叫點無 cadence gate）
★★而 2026-09 之後有了緩解：`survival_committed_option` 承諾機制 ＋ stall 三態 ＋（2026-09-04）
   「不 applicable 就解承諾」——★★★但【緩解的效果沒有量過】
⇒ 條目原始數字是 Team26 day24-26 churn 88/56 ⇒ **要的是同口徑的新數字，不是新的推論**
```

真 thrash 殘留源＝`_evaluate_survival` 每-tick 重觸（legacy，非掠奪選擇）→ Team26 day24-26 churn 88/56 次。**但非致命**：Team26 挺過 churn、期間仍行動（有 loot）、死在 60 天後（day85），churn 非死因＝噪音非 bug。**修向**：survival-latch（`_evaluate_survival` 別同快照重觸，＝原執行鎖意圖但對的層——非 recognizer、是「同狀態別每 tick 重跑」）。**backlog 非 urgent**：future 若觀察到 churn 普遍 + perf 貴再做。連 [[feedback_avoid_rabbithole]]（blueprint 判 Team26 剩的是邊際噪音，停追）。

## 絕境掠奪搶糧優先 + 權重量級（2026-07-15，掠奪 fix inert scrap 後 observe-later）

掠奪 hunger-weighted prey fix **inert 已 scrap**（`FOOD_PULL=1.0` 太弱、遠小於 pop_est 量級 + Team26 危機期只一候選＝方法錯，byte-identical，不 merge）。絕境隊掠奪「搶到料沒糧」QA 已判**連貫死**（搶了個也沒糧的鄰居＝真實悲劇，非幻覺）。**observe-later**：絕境掠奪要不要優先搶糧 + 強化權重量級＝desperation-economy arc，若觀察到 raiders **系統性**搶不到糧才做。分支 `feat/loot-hunger-targeting` 棄（inert）。

## 求和 sue-for-peace 無 handler（2026-07-15，diplomacy grounded 揭，backlog）

`handle_diplomacy_message` 無「求和/息兵/tribute_offer」case（只 propose_alliance/propose_trade/demand_tribute/offer_surrender/invite_settle）→ 求和一直被 `_try_diplomacy` 硬寫成 propose_alliance（求盟）。**diplomacy-grounded 刀只讓求和 grounded**（fire→release+cooldown no-op，不 loop 不偽裝求盟）。**真息兵行為＝backlog（WHAT 待 blueprint）**：求和是否獨立行為（納貢息兵讓威脅 de-escalate 退兵）vs 該併外交；要做則建 `sue_for_peace` handler（威脅退兵機制）。

## ✅has_food_market god-view 既有債 —— **已關**（2026-09-02 systems 複驗）

★`_nearest_market_outpost`（`faction_ai_system.gd:3626`）**現在只掃 `state.team_market_known`**
（三源習得：創世／親見／relay），**不是 `state.world.tiles` 全圖** ⇒ ★★**belief-gate，非 god-view。**
★同函式群的 `_nearest_market_outpost_with`（`:3647`）同範式。
⇒ **本條目下方原文保留存查**（它描述的是 2026-07-15 的現場，已被 Slice C 修掉）。

## ✅（已關，存查）has_food_market god-view 既有債（2026-07-15，desperation-food-seeking R② advisory）

`decision_context.gd` 的 `has_food_market`（`faction_ai_system.gd:2024-2037 _nearest_market_outpost`）**掃全圖**找最近市集 outpost＝god-view 既有債（違感知鐵律，隊不該全知所有市集位置）。非 desperation-food-seeking 刀範圍（該刀新增的 has_buyable_food/food_seek 已守鐵律），但既有 has_food_market 未修。**修向**：改讀隊已知市集（探索過/傳播聞得）而非全圖掃。**優先序**：低（既有行為，非本刀 blocker），感知鐵律稽核 slice 一併掃。

## ★Team18 lone-survivor death-limbo + intent 誤標致富（2026-07-14，full-HD live 觀察首個獵物）

**狀態：未確認** ｜ **回訪：量測窗 — 對照 A#14「死亡可見」那批落地後的 specimen（★該批已把 `erase_teams` 窄口接上 tracer）**

★★**B 級 sweep 判定（2026-09-04）：機械上找不到 limbo 殘跡，但【不能據此結案】。**
★`grep limbo／lone_survivor` 全樹 **0 命中**；團滅路徑現為 `_on_team_extinct`（`:4067`）＋批次 `erase_teams`（`:4115`）。
★★**而「找不到符號」≠「症狀消失」** —— 條目的症狀是**行為**（獨活者卡住 ＋ intent 誤標致富），不是一個叫 limbo 的欄位。
⇒ ★★★**要用 specimen 對照，不是用 grep 結案**（★而 A#14 那批剛好把死亡窄口接上 tracer，成本很低）。

**來源**：execlock 全-HD story acceptance 找團滅 specimen 時意外揪出（`docs/measurements/2026-07-14-execlock-seed1337-Team18-annihilated.jsonl`，34 entries）。**非 thrash-fix 範圍**。這是「先有結果/full-HD live 觀察」方向提早見效——**真 coherence bug 從 specimen trace 浮出，靜態設計看不到**。

**現象**：孤隊 Team18(pop=1)——tick7110/7120 兩次「併入→投靠」(真掙扎找收留)→ tick7690 起轉「買糧」(貿易 task)→ **連 31+ 天(27+筆/日)coin=0 food=0 卡同一迴圈**，到 trace 尾(tick15130/day63)仍 pop=1。

**兩疑似 bug**：
1. **death-limbo（該死不死）**：孤隊零糧一個月+理論該餓死卻卡 limbo 不死不活。possible root=(a) 買糧-貿易 path **繞過 survival controller**（lone-survivor 子隊死亡/求生判定沒接回引擎）/(b) famine 死亡判定對 pop=1 子隊有洞。
2. **intent-reality 不符（coherence）**：零錢零糧孤隊 AI「想什麼」標**致富/貪婪驅動**非求生恐慌。= 決策模型該防的「慾望不配現實」（垂死該求生欲主導，不該追財）。連 `game-design.md §決策模型 v2`（現實 gate 慾望）。

**歸屬**：**full-HD live 觀察 slice 的獵物**（decision-model coherence，live 才現形）。observe slice 開時優先查此類。連 [[project_desperation_economy]] / 敗北出路家族。

★~~## ★reeval_attribution_bed 死亡偵測 false-positive~~　⇒ ★★**已銷案（2026-09-02）**：`a67e9682`（2026-07-15）改了 `reeval_attribution_bed.gd` —— ★而本條寫於 07-14 ⇒ **隔天就被修了，而條目活了七週**（★我自驗過該 commit）。原文：（2026-07-14，量測可靠性）

`reeval_attribution_bed.gd` 死亡偵測（`elif spec_death_tick==-1 and not spec_last.is_empty(): spec_death_tick=tick`，單次 `state.teams` dict 查無即判死）→ Team18 tick7239 **瞬間 remove-readd**（併入嘗試的 lifecycle）被**誤判永久死亡**。**影響**：measurer 找「團滅 specimen」時把沒死透的隊誤當死透。**修法（L3）**：改連續 N tick 查無才判死、或讀 `population==0` 事件而非 dict-membership 瞬態。**已 dispatch implementer 修**（execlock worktree，量測可靠性在關鍵路徑上）。

## ★小 pop int()/round() 截斷病=結構類（2026-07-10 sweep，blueprint 結構信號；第 3 次同型）

**狀態：已知未修** ｜ **回訪：觸發事件 — 有人動 `_score_breed` 或處理「小隊不生育」時（★三顆原始血證已全修，剩一顆是本次 sweep 撞出的同型）**

★★**B 級 sweep 判定（2026-09-04）**：**原始三顆血證【全部已修】** ——
①殲滅端 `_cas_carry` de-patch ✅（條目自記）／②pursuit `_pursuit_carry` ★**符號全樹已不存在**（已移除）／
③capture ✅ 現為 `interaction_system.gd:161 mini(maxi(1, int(round(...))), wounded)`（**已護欄**）。
★★★**而 sweep 撞出【第四顆同型、未修】**：`reaction_system.gd:229`
```gdscript
var minor_cap: int = int(t.population * 0.2)
var base: float = 0.4 if (safe and fed and t.minor_population < minor_cap) else 0.0
```
⇒ **pop ≤ 4 時 `minor_cap = 0`** ⇒ `minor_population < 0` 恆 false ⇒ ★**`_score_breed` 恆 0 ⇒ 小隊永遠不生育**。
★★**而它是【截斷造成的硬零】不是【設計出來的門檻】** —— 正是本條目描述的病型（機制在小尺度靜默啞）。 ★★★**（訂正 2026-09-04：此第四顆【已修並 merged】** —— `reaction_system.gd:229` 改為 **float 對 float 的連續比較**，**不是 `maxi(1, int(...))`**；blueprint 裁「pop≤4 恆 0 ＝硬懸崖，直接違用戶生育定案『無絕對懸崖』」**）**
`int(pop*rate)`/`round(pop*rate)` 在小 pop 尺度恆歸零 → 機制靜默啞（探針前砍光=cosmetic 假過關）。血證 3 次：①殲滅端傷亡 `int(round)`→0（§D4 `_cas_carry` de-patch ✅）②pursuit `int(pop*0.05)` pop<18→0（S1 rev2 `_pursuit_carry` de-patch 中）③capture `round(wounded*rate)` 小 wounded→0（部分，rev2 severity 半救）。
**sweep 揭未護欄站**（`grep int(...pop...*)`）：
| 站 | 型 | 建議修 |
|---|---|---|
| `npc_combat_system.gd`（★L2 錨：檔級） pursuit | per-event 反覆 | 累積器（S1 rev2 做中）|
| `anon_tier:277/282` capture wounded/healthy | one-shot | `maxi(1,)` floor 或機率化捨入（三端 capture 相關，優先）|
| `encounter:251/252/1080` armed spawn | one-shot | 驗 ARMED_RATIO_FLOOR 是否已護；否則 floor |
| `reaction_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） minor_cap | one-shot | 視語意 floor |
| `subteam_system.gd`（★L2 錨：檔級） anon_xfer | one-shot round | floor/累積 |
**已安全（有 `maxi(1,)`）**：`population_system.gd`（★L2 錨：檔級）、`reaction_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）、`interaction_system.gd`（★L2 錨：檔級）。**比較用非病**：`faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）/`player_command_system.gd`（★L2 錨。★★★2026-09-01 我的「內容待驗」標記【撤回】：我用 `grep "maxi(1,"` 去否證，而真實寫法是 `maxi(int(...), 1)` —— ★參數順序相反。★★自驗：`maxi(1,` 11 處 vs `maxi(…,1)` 66 處 ⇒ **我的搜尋式漏掉 86%**。★★★本條的「已安全」【成立】，是我判錯）/`player_query_api.gd`（★L2 錨：檔級）（`int(pop*1.5)` threshold）。
- **★TASK_MERGE 0/8333 真根=combat_target 早退（2026-07-11，S-A merge-blocker）**：`interaction_system.gd`（★L2 錨：檔級） `if combat_target != -1: return` 早退，先於 MERGE resolver(:261) → absorber 常戰鬥 → merger 到格早退 → `_try_merge` 從沒 call（實證 merge_accept=0 且 reject=0）→ 0/8333。**= 見「統一矩陣窮盡稽核揭項」§NPC-NPC 乞食(BEG)/投靠(JOIN) task 路徑死（★★2026-09-02 訂正：原寫 `known_issues:18`，而寫下它那天（db00ea39）第 18 行是 `subteam:130` 表格列 ⇒ **寫下來那天就指錯**；真身在當天第 38 行）**（code :216 自註）。修=:214 豁免 social/merge 到達（S-A 折入 `merge-seam-real-fix`）。**★systems 首判「order_target 漏接」=錯**（order_target 早已三路 wired via `faction_ai_system.gd::_wire_threat_task()`，首判是不完整讀漏 :1529 helper 呼叫；implementer 框外挑框+實證翻案）→ 教訓 [[feedback_structural_audit_complement]]（characterize dispatch/seam 要讀完整條路含 helper 呼叫，別停在第一塊）。
→ **清償 slice（另開，fix 異質不塞 S1）**：per-event=累積器、one-shot=floor/機率化（決定性）。掛 memory [[feedback_structural_audit_complement]]。
**★更廣結構債（blueprint 2026-07-10 擴，pursuit 3 次失敗揭）**：不只捨入——**`pop-% × 小效果` 在小隊世界普遍失效**（organic 全小隊 → 任何 `pop*小rate` 恆~0，累積器也救不了因每 entity 只觸一次）。sweep 同看**模型選擇**：該量是「敗方 pop 百分比」還是「絕對小數（軍閥砍尾型）」？pursuit=絕對正解（rev3）。與**殲滅不可見同根**（隊太小）=consolidation 腿另一症狀。各站標「pop-% vs 絕對」宜哪個。

## gossip 名聲傳播 backlog（2026-07-11，資訊維度 Phase D；磁鐵接口已留）
consolidation 磁鐵 ship 後現況：`protector_rep` 只從**直接事件**長（aided/looted），organic `rep.host_nonneutral=0`（曝光缺口）→ 現階段「中性 rep 無差別投靠」（可接受、mega-blob 受控）。**gossip loop-1（名聲傳播）**讓它→「擇良木而棲（仁君聚望/暴君遭棄）」=名聲靈魂。**接口已留**（`update_protector_rep(…, source)` source-agnostic + `message_system:182 _exchange_intel` 標 TODO seam）→ 屆時「擴 message 帶第三方 protector_rep 意見，複用信任 gate/distortion/decay」=中工非大 arc。歸資訊維度 Phase D。

## world-gen variety backlog（2026-07-11，blueprint 記，下個項目一起做非現在）
用戶 GUI 親驗發現，**per-seed determinism 必守**（否則回歸 diff 廢）：
1. **據點太規則**：`world_generator:180 pick_start_positions` 按 tile key 順序貪婪挑 → 掃描式規則布局、**每 seed 一樣**。傷世界質感（人工格狀）+ 量測效度（地理骨架固定，多 seed 沒測不同地緣）。→ 改 **seeded 散布**（min_spacing 內隨機撒）。
2. **seed 間變異太窄**：現固定=據點位置/數量/地圖 grid/領土形狀；只變類型/隊數/次要位置/資源/人格。→ 加變維度：據點數量（8-14）、勢力數（2-4）+領土 share、地形分布（山/林/平原格局隨 seed；先驗地形現 seeded 沒）。
- 序：名聲磁鐵 slice 跑完後開，走正常 characterize/spec/R②。

## combat-into-engine arc backlog（2026-07-10，spec `specs/2026-07-10-combat-into-engine`）
- **S4 斷糧求生路由（blueprint 裁 defer）**：`rank_combat` COMBAT_OPTION_SET{血戰/逃} 無「逃向補給/家」跨域路由=結構漏（現行 `_mortal_flee_check` 亦只戰場逃，S2 preserving 不使其更糟）。=淨新 feature，掛絕境經濟/consolidation arc。別丟。
- **S2 地板1 硬 gate（靶A）**：rank_combat argmax 須逐 seed **重現** rev2 三端（逃83%/俘中頻/殲滅稀），對不上=design reject 非 tune weight 湊近似。
- **S3 戰後受降 vs 屠殺**：殘忍 term 決屠殺/受降接 capture/subjugate（真新湧現，序末別砍）。

## 統一矩陣窮盡稽核揭項（2026-07-01，全貌 `specs/2026-07-01-unification-matrix-audit`）

- **憲法防閘掛點（序0 2026-07-05 立閘；藍圖 wave1-order-gate 裁定提前硬掛）**：**arc 期間硬閘已上**=本地 `.git/hooks/pre-commit`——staged 含 `scripts/simulation/*.gd` 時跑 `constitution_gate.gd`（純檔掃描，不需 import），輸出含 FAIL 拒 commit（繞過 `git commit --no-verify` 須系統認可）。worktree 共用 common hooks dir → 實作子 session commit 也觸發（正中「邊拆邊長新」怕點）。**限制**：hook 在 `.git`（本地非版控，單機 arc-temporary）；閘 coverage 只鎖 TaskArbiter mutation 面，不覆蓋 return-task-字串式違憲（如 `ambition_ladder.rung_task`），見 `invariants.md` 憲法段誠實聲明。**arc 尾**：轉常駐全掃鏈（framework_validation 內呼 or 獨立 gate step），撤此 pre-commit。手跑：`.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`（CLAUDE.md 常用指令）。
- **A2a follow-up（2026-07-08 merge `06e10a0` 後立）**：①**HOB/team_trace bed 對 360s wrapper timeout 太慢**——`hand_obeys_brain_bed` 跑 4× 一個月 warring sim ≈500s（main 亦 392s），ephemeral measurer 預設 360s wrapper 會殺 → **製造假 perf 迴歸/假 reject**（A2a 首例，藍圖 measure-first 翻案）。修：bed 升 documented timeout 或砍到 2 run（1 主 + 1 determinism，去 nonperturbation 或縮窗）。②**`near.faction_ai` O(N²) 60隊 warring**（spike 130-320k us/tick，**pre-existing，main 早有**，非 A2a）→ 歸時間統一 wave（空間分區+honor-LOD+cadence 攤，見 progress 時間 wave 段/[[project_time_scale_wave]]）。③**join-consent-consolidation**：投靠玩家 3 路（`_evaluate_solo:~1767` 無 guard + 既有 2 處 fallthrough auto-merge）待全遷 `_try_join_target` helper（A2a scope B 只走新子隊路，既有未碰）。
- **★B 落地債：行為常數人格化/世界接地（藍圖 twin-constitution + decision-model-B-reframe，2026-07-06）**：憲法孿生條+決策模型定案——**塑造行為的門檻歸宿只有世界代價（seed/接地）或人格/記憶/現況（逐 agent），無全域行為常數該活**（見 invariants「決策模型」節）。**第一示範=`PREEMPT_MARGIN=2.0`**（該由隊謹慎度算：膽小早逃/悍將晚動，非全域一刀切）。同類待收：`THREAT_CADENCE`、`FEUD_ATTACK_MIN(0.5)`、`VIABLE_ARMED_RATIO(0.3)`、`ATTACK_SCORE_THRESHOLD`、各 reaction 閾。**排序=系統 HOW+measure，arc 內順手 or 另開「常數人格化」軌**（不擋各溶序）。**溶入驗收隱性標準**：行為真穿過人格/記憶/現況的秤，非全域 margin/gate 直達（具名常數=照妖鏡響）。連 [[project_unification_matrix]]。
- **wave1 序3 世界變靜 watch（2026-07-05，QA/藍圖 wave 級判）**：序3 收窄 idle-filler 除 86 ambient-FLEE churn（結構正確）→ 副產物：seeded 隊間威脅遭遇↓（`threat.dispatch` seeded 3→0，世界變靜）。`_evaluate_threat` 機制未改、確定性 live-seam 證真威脅仍派——**0 是「seed 少真威脅遭遇」非「機制壞」**。但需 QA wave 級判世界是否過龜縮（game-design 反龜縮 bar[[project_playable_priority]]）：offensive 衝突仍在（軍隊 attack 22.5%/prosperity），defensive threat 反應在 seed 少觸發。若判過靜=張力不足 → 藍圖裁（非機制修）。**★measure 洞察**：序1 驗的「threat 率 18」部分是此 churn 虛胖（隨機逃跑製造遭遇）→ 湧現率斷言可被無關 churn 污染，確定性 seam 測才穩（threat 5b 已改）。
- **★wave1 序2 solo 揭框架債（2026-07-05，結構信號非 bug）**：①**`_tag_weight` 是隱形去衝突閘**——舊 solo 靠 `_tag_weight=0` 讓 FORCE/軍隊隊 attack 分歸零→留 idle→`_evaluate_prosperity_attack`(loop3, idle-gated) 接精算征服鏈。去 `_tag_weight` + 引擎「建設」option **恆 applicable**（`options.gd` 無 gate）→ solo 每 idle tick 必派 → **餓死所有 loop3-idle-gated 路**（prosperity/非-unified threat/vendetta 等）。序2 加 **yield 閘補**（FORCE 征服候選 cadence 到期 return 讓 loop3）=橋非結構修。②**真結構修 = 序5+序6 ✅ 完全結清**（序5 merged 16ab3bc 拆 prosperity cascade+刪 yield 閘；**序6 merged 2b4a427 成員走 `_decide_unified` 主 rank，掠奪 option 自然接回打草穀 raid，成員退 loop3-idle-gate 依賴，每 cadence 重評**。縫#3 idle-gate 餓死問題結清——但「建設」恆 applicable 本身[任何 idle 隊永不真閒]若仍為債，arc 尾評估）。③**待系統判**：「建設」恆 applicable 是否框架債（任何 idle 隊永不真閒）；是否升級 prosperity 前置到 loop2（對齊 `_evaluate_independent_strategy` pattern，更徹底但漂移大）。連 [[project_framework_seams]]。**measure：threat 率 18 守恆**（loop3 threat 實測未被餓死，yield 補住 prosperity 即夠）。TEST VALUE：`VIABLE_ARMED_RATIO=0.3`/`LOOT_DRIVE_BASE=1.0`/yield cadence 待 wave QA 校。
- **wave1 序2 solo 獨立隊 ambition-diplomacy 流失（repertoire watch，待藍圖判）**：舊 solo `DIPLOMACY=maxf(野心×0.4−好戰×0.2,0)×_tag_weight` 給獨立(fid=−1)商隊/宗教隊野心-外交 dispatch。engine「外交」applicable 需 `faction_stakes`→獨立隊無。獨立外交今走 `_evaluate_independent_strategy`(結盟/建國)+threat「求和」，但此具體「獨立野心-外交」行為已無。窄（限獨立商隊/宗教 tag），他路覆蓋大部。藍圖判要否保→加輕量 tag/intent context term（F-D5 另軌）。軍隊攻擊 occupancy 0%→22.5%（QA wave 判過度侵略否）。
- **wave1 序1 threat 溶入殘留 watch（2026-07-05，非 bug，未端到端驗）**：①**unified 隊 迎戰/求和 下游 resolver 未驗**：threat 溶入後 unified 隊經 `_decide_unified` 主 rank 可選 迎戰(DEFEND)/求和(tribute_offer)，`_wire_threat_task` 已接 prosperity_target/order_target/order_task，但 DEFEND prosperity_target 消費端 + 求和 tribute_offer 外交鏈**未跑完整多 tick end-to-end**（融合驗只證 target 接線 + option 浮現）。建議 unified threat 情境跑一次驗 resolution。②**survival option 雙語意**：主 rank survival 用 reputation-filtered `ctx.threat`（軟，merchant 不逃中立商伴）；rank_threat survival 特例用 raw `threat_react`（硬，鏡射舊 threat 反應）。刻意分離已註釋——日後若統一 survival scoring 需知此差異。③pacify 率表此 seed=0（稀有非退化，逐類可達性由融合驗 5a 證）。
- **★確認 bug：NPC-NPC 乞食(BEG)/投靠(JOIN) task 路徑死**：`interaction_system.gd:197` `if a.combat_target != -1 or b.combat_target != -1: return` **先於** BEG resolver(`:247`);BEG/JOIN dispatch 恆設 `combat_target`(options.gd:96/104、faction_ai:1377)→ 早退不可達;**TASK_JOIN 根本無 `_try_interact` handler**。NPC 絕境「乞食/投靠」(P2a option)walk 到目標被 197 殺、無 resolve;player 版直呼 `_resolve_aid_request` 繞過故沒露。**影響**：P2a 絕境 repertoire NPC 側可能空轉。**先 measure**(插探針量 NPC BEG/JOIN 實際 dispatch+resolve 率)再修,別直接當實([[feedback_avoid_rabbithole]])。修向：BEG/JOIN resolver 移到 197 早退前 or combat_target 語意拆(社交 target ≠ 戰鬥 target)。
- **★第3不變量單寫者大面積未實現（強制閘前提）**：`team.resources` 乾淨(全 ResourceBank,first-pass「53直寫」修正=錯)。真洞：**tile.public_storage(granary)+tile.resources 全無 bank**(22+直寫)、**coin 憑空鑄入 public_storage 無 treasury bank**(outpost:228/241)、**named_members roster 無 chokepoint**(59 site/17 檔)、**combat_target/tags/solo_intent/faction.leader_team_id/person.coin/fatigue/armed_anon_ratio 無主**、**Pattern B driver-ledger=全 5 bank stub(reason 丟棄)**。team-creation 無 chokepoint(vs erase_team 有)、succession 三重手寫、faction_id=-1 6 處直寫繞 set_team_faction。= 統一矩陣「單寫者」領域最空,撐強制閘的前提。
- **守恆盲區**：person.coin `+=` raw(salary:66)+ coin 憑空鑄 public_storage → coin_eq audit(對 team.resources 求和)看不到。
- **其餘 fork（全 30+ 條見 audit doc）**：思考決策 5 scorer/threat term 死 stub(DecisionContext.threat=0.0)/雙 faction-goal producer;互動 2 diplomacy resolver(god-view vs belief)/~~3 tribute 公式/3 deception 引擎/RelationGraph orphaned~~（✅ 2026-07-04 互動統一軌收:F-I2/I4/I5/I6/I7，見 handback）;人力雙 skill/injury/equipment 模型;player 48 handler 4 缺口(demand_tribute/recruit×2/betray 全平行)+ UI god-view 洩漏。**燒序見 audit doc**（首燒=獨立/faction 戰略合併）。
- **finder 濾鏈 C 類候選（2026-07-04 互動軌順盤，排軌候選）**：①`faction_ai.find_prosperity_prey` vs `_find_weakest_prey`＝同「belief 弱者掃描」骨架（has_belief 守衛+armed_est weakness+距離濾）雙處各自維護,差 richness 項/絕境語境。②`faction_ai._find_trade_target`（team_discovered god-view fallback,invariants 已標「最終應刪」）vs `strategic_ai._find_trade_partner` 雙貿易 finder。輕度：`_find_strong_neighbor`/`_find_aid_target`/`_find_occupy_target` 各自重寫「候選迭代+belief 守衛+距離濾+argmax」樣板,可待 DecisionEngine finder helper 收,非急。
- **★V3 提案 accept=0 診斷（2026-07-05 measure）**：兩因。①**直解結盟門檻恆 false**：`diplomatic_ai_system.gd`（★L2 錨：檔級） alliance accept 門檻 `ALLIANCE_ACCEPT_THRESHOLD=0.55`，但收方視角重算 `_calc_diplomacy_score:112-119` fresh-world 封頂 ~0.44（power_gap belief-fallback=0、relation/rep default 低）→ 結構性不可達。②**帶禮脫 0 槓桿連坐 V4**：`gift_term`(+0.4,足以抬過 0.55) **只隨信使走**（interaction:426），直解(:176)不帶禮 → 依賴 envoy 送達(=V4=0) → 帶禮結盟評估一次沒發生。tribute refuse=score 0.1 不>門檻 0.1(fear≈0)且此路幾乎不發。**修向**：V4 修好帶禮路自通(一修多解)；直解 alliance 0.55 是否「合理的0」(陌生隊無理由結盟,關係建立前)=判準題待 QA/藍圖。
- **★V4 envoy 送達=0 診斷（2026-07-05 measure，非 timeout 太短）**：主因=**far-zone 10× 移速稀釋**（movement:76 `+=TICKS_PER_HOUR` × sim_runner:237 far 每 100tick 才跑一次；自然世界全隊 far）。timeout floor 12 天很寬（`_founding_timeout` faction_ai:1253），但 budget 按 **near 速**校準、信使跑 **far 速(10×慢)** → 走 ~1/10 距離就 timeout。疊加 target 漂移需精確同格(interaction:283)。**=trade 物流同根(known_issues:55 一修雙解)** → far elapsed 積分(B slice)一修多解:V4 envoy + V1 trade + V3 帶禮結盟。
- **★V2-cmd commander 征服路 0 = 結構 shadow（2026-07-05 measure，非純死碼）**：`if "徵收"`(faction_ai:1476) **嚴格支配** `elif "攻擊"`(1486)——攻擊-eligible 成員(軍隊/統領/subteam,`_tag_weight` 831-850)是徵收-eligible 子集 → 有徵收 goal 時攻擊 elif 對這些成員恆死。征服 tick 多半 co-emit 徵收(war_chest 1016 + 補力 levy 1098)→ shadow 常咬。次因:≤2 established faction 樣本薄 + consolidation-merge(1465) 抽走攻擊成員。窄可達窗存在(非純死碼)。**待 2 runtime probe 坐實**:shadow 率(征服 tick 有無徵收)、攻擊-eligible idle 成員普查。修向:若要 member means-end 征服,拆 1476/1486 elif 序 or tag-weight 支配——待藍圖裁 means-end 意圖(獨立 prosperity 路已達征服,member directive 是否必要)。
- **★行軍後勤真帳（2026-07-05 measure，錨①×1 前置）**：×1(240tick/hex=1天/格)下一格糧耗=pop×0.8(pop8=6.4糧/格);乾糧 buffer=`PROVISION_DAYS`(10)天=**僅 10 格**(×5 下 50 格=從不餓死,遮蔽真相)。沿途補給弱(覓食地板僅 1.5 天封頂延後死非延長、路過自家村滿補但長征罕見)。臨界:≤10格安全/10-17格空糧靠 grace/>17格真餓死。**founding(下限12天/12+格)、trade(全圖)不受保護**;`AI_ETA_LIMIT`(1200 固定 tick)使 catch-up/occupy 自動縮 5 格(安全,但它是裸 tick 該進 wave 收編、該隨 BASE_MOVE 或語意天數)。→ 藍圖裁補給機制(升 PROVISION/沿途 raid·買糧/糧耗率/journey cap)。
- **TRIBUTE_* 統一公式權重 = TEST VALUE（2026-07-04 F-I2）**：threshold 0.1/power_r cap 3.0/feud -0.3×int/gratitude +0.2×int/fear/survival 項,保守推導自三舊公式未跑平衡 pass。**屈服率整體上移**（threat 正向項）→ LOOT extort:combat:noop 分佈變,`raid.*` probe 可追,平衡 pass 與 TRIBUTE_* 一起校。
- **merchant seeded 時間線分岔終局（watch,非 bug）**：互動統一後 game_sim_multi merchant config `GameOver 玩家絕後 @tick 849`（RNG 分岔正常終局,coin_eq 守恆）。現無 gate 斷言玩家存活;要追蹤需 seeded 玩家劇本 harness（backlog,要不要做待裁）。
- **RelationGraph dormant edge types（2026-07-04 F-I5 measure 揭）**：`killed` 零 writer/reader（僅 person_data 註解提及）；`protect` writer-dead——"master" memory 全 codebase 無人寫 → `npc_ai._write_relation_edge` "master" arm + `salary._has_master_memory` 讀 = dead chain（12k tick ×2 config 實測 0 條邊）。feud/gratitude 已接線（tribute_accept 權重項）。修向：master/收徒機制實作時復活，或刪 type + salary 讀（salary 在互動軌 scope 外未動）。

### 燒進度（2026-07-01 首三軌 merged）
- ✅ **首燒 戰略 intent 統一 done**（F-D1/D2/D3/D4/D6 收；致富錨接上、CONQUER 0→1）。**follow-up**：①**征服名vs實斷點**(unified 好戰獨立 想=征服但 winner=掠奪,`_decide_unified` 掠奪 option 搶在 prosperity attack 前 → 需讓征服 intent 真驅乾淨攻擊 or 掠奪納征服 affordance) ②**F-D5 unified-tag subteam 進不了 engine**(未收) ③擴張 scorer TEST VALUE(0.3+野心*0.3)待平衡校 ④solo driver 未進全隊持久 ledger(Pattern B 所有權域另軌)。
- ✅ **單寫者 slice1 coin 守恆 done**（F-S8/S1 coin 部分：全池 audit + person.coin 單寫者 + mint ledger；順修 mint-cap 燒 ore 舊項）。**follow-up**：`_route_extinct_assets` no-tile LEAK(`faction_ai_system.gd::cleanup_extinct_teams()`,radius 全無有效格 coin 憑空丟失,正常小地圖不觸發)納下 slice or 標永久豁免。
- **單寫者剩餘 slice（第3不變量 enforce 前提）**：~~tile.public_storage/tile.resources 一般資源 bank(granary/自然池)~~ **✅ done（2026-07-03 S1 tile-bank，TileBank chokepoint 收編 ~40 直寫站點 + mint 守恆 connect + off-map sink，pointwise CLEAN×3 seed）**、**Pattern B 全域 driver-ledger 落地**(現全 6 bank reason stub;TileBank 已帶 record_driver reason)、roster(named_members 59 site)/combat_target/tags/team-creation chokepoint、succession 統一。**剩餘另型欄位（非資源量,未納 TileBank）**：facility levels(outpost/mint/stable/farming_level)、stable_progress、construction_team_id、abandoned_coin(scalar,已 CoinAudit)、resource_cap(靜態)。
- **BEG/JOIN 修（follow-up，探針已證）**：JOIN=中(66/月空轉,需新 resolver + combat_target 社交語意拆)、BEG=低(被197擋)。**建議合併一次修**(combat_target「社交 target≠戰鬥 target」=共根)。BEG endgame-scarcity runtime 頻率未實測(機制已證死,頻率次要)。

### 第二批燒進度（2026-07-01 三軌 merged）
- ✅ **B 食物張力 done**（張力機制到:forest 苟活須交易/plains 繁榮/不 mass-starve）。**★下一閘=交易網未轉真因=建設 util 碾貿易**（specimen 商隊 想=致富但 winner=建設 0.79>貿易 0.26,決策權重域非食物）→ granary 爆倉閘拆後露出。**修向**：貿易 util 提權（有訂單/arb 時應勝建設）or 建設 gate。屬決策權重 slice。**其他 follow-up**：FOOD_PER_PERSON 0.8 + flow 常數 TEST VALUE 待平衡 pass;material harvest ÷24 但 mat_regen 未縮放（建造/製造吞吐未專測,掃一眼）;ambition rung 讀 flow=行為變（marginal 隊 flow=0 起步卡 SURVIVE、prosperity-attack 需盈餘=飢餓不主動開戰）。**★warring 全窗 24 月已驗（系統補跑,radius14 seed）**：**不 mass-starve ✓**（teams 穩~30、Famine 涓滴非潮、DONE、0 error）、**founding ✓**（found_ally=5/factions=7 穩/FOUND=1 全程）、RICH=13 主導（致富錨活）;**但 ⚠ CONQUER=0 全程、established 卡1、EXPAND=0=征服/擴張 emergence 全窗變平**。**根=雙重壓制**:①食物軌 ambition rung 讀 flow → prosperity-attack 需經濟盈餘（食物緊→少隊達 EXPAND rung→少開戰）②征服攻擊路徑分裂（見征服 measure,粗攻擊不轉化）。首燒 bounded-3 月曾見 CONQUER 0→1,加食物軌全窗回 0。**修向**:征服攻擊統一（本批 measure 修向）+ ~~可能 rung-gate flow 門檻放寬~~ **✅ 2026-07-02 R1 三帶裁定改「解綁」非「放寬」**（藍圖 c 路線:拔 rung-food 攻擊閘,食物盈餘只管立國/坐穩/擴編,已 merged;CONQUER 壓平根因收）。
- ✅ **單寫者 slice2 done**（driver-ledger 真記 + roster chokepoint + audit）。**★audit 揭 pre-existing leader/team_id desync**（merchant leader P0 team_id!=本隊,經 leader 指派非-named 路徑;roster chokepoint 已修 named-transfer desync tyrant 4→0,但 leader 指派路徑覆蓋不到）= **第3不變量首個可查對象,root fix 行為變待 triage**（動 leader 指派/team_id 寫路徑）。**其他 follow-up**：`driver_tick_hint` sim_runner 未接線（要真 tick 溯源再接）;反向 roster audit 未做（需先解 health famine「死亡留屍保 team_id」語意）;`beast_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）/`subteam clear()` 兩豁免暫緩【★defer token: single-writer-leftovers】。
- ✅ **征服名實 measure done（證偽首燒假設）**：真斷點**非**掠奪搶排序（掠奪僅 2.4% winner、0 capture=打錯靶）,是**攻擊實作分裂**——舊 solo 粗攻擊(`_nearest_independent` 無 scout/rung gate,@PRIO_DISPATCH 優先)vs `_evaluate_prosperity_attack` 細攻擊(weakest-prey/scout-gated/導 subjugate),粗淹細 → 243 攻擊→1 capture。**修向（follow-up spec，數據支持）=統一征服攻擊路徑**（非-unified 好戰隊 TASK_ATTACK 委派 prosperity/共用 gate+subjugate 導向）。**次診斷**：攻擊→capture 轉化崩在「打不贏」還是「贏了不吸收」需另一輪 measure（戰鬥結局分布）。**→ means-end 已收攻擊路徑統一（route 6.6×）,但 capture 完成 depth 仍低,見下。**

### 第三批燒進度（2026-07-02 means-end + slice3 merged）
- ✅ **means-end 接戰術層 done（intent_fit,願景進化第一深化）**：戰術層 intent-blind 修（intent 注入 ctx + intent_fit reshape option util）。**症狀 a（致富→貿易）全解**。**follow-up（移動標靶下一步）**：①**capture 完成 depth 低**（征服→攻擊 route 6.6×成、但吞併完成率未升 3→1=combat/subjugate 完成度,pre-existing;需 measure「打不贏 vs 贏了不吸收」→修 combat/subjugate depth）②~~conqueror 食物 survival-trap~~ **✅ R1 三帶收（2026-07-02 merged）**:絕境=survival 域拚死搶（保留,surv.loot_dispatch 140 仍 fire）、餬口帶狼走 prosperity raid（拔 rung 閘後開通,specimen 想=征服→做=raid 78/80 弧可見）③**over-war 4pp 落 unseeded 噪**（要硬證不 over-war 需 **seeded warring 回歸 harness**,現 conquest_measure 無 seed [[reference_multi_sanity_unseeded]]）④**防衛/守成/建國/擴張 intent uplift**（後增量,本增量只致富/征服/匱乏）⑤TEST VALUE（INTENT_FIT_DRIVE 1.5/SURPLUS_FOOD_DAYS 7/SCARCITY_RAID_MIN 0.55）待校。
- ✅ **單寫者 slice3 done（leader desync 根修）**：`set_leader` chokepoint + 反向 roster audit + ledger tick 接線。**F-S3 leader/team_id desync 結構性關閉**（chokepoint 強制同步 + 反向 audit 常駐;merchant desync unseeded 間歇未在此環境復現,結構保證非 case repro,seeded 復現=backlog）。**follow-up**：~~combat_target chokepoint + BEG/JOIN 社交語意拆~~ **✅ done（2026-07-02,social_target 拆 + JOIN resolver,join.resolve 0→4 死路消,F-S4+F-I3 收）**、tile-granary-bank/tile.resources bank（剩餘單寫者 slice）。
- ✅ **單寫者收齊 B — chokepoint 掃收 done（2026-07-03，S5/S6/S9/S11/S12）**：`world_state.gd` 立 5 新 chokepoint 全直寫點收編，pointwise CLEAN×3seed（純 refactor 位元不變）。
  - **S9 `create_team`**（erase_team 對稱）：teams 註冊+known/discovered init，10 直寫站收（beast/subteam/manpower/population/reaction/split/tutorial/gen×3）。**順修 recruit_tutorial 漏 init known/discovered 病例**（原只 `teams[tid]=` 無 registry row）。
  - **S5 `set_team_tags`/`add_tag`/`remove_tag`(reason)**：全 tags 直寫收（event_tag_shift/faction_ai/interaction/subteam/beast/manpower/population/reaction/split/gen）。append/erase 鏡射原無條件語意（不加 dedup，site-guard 保留）→ 位元不變。
  - **S6 `set_readiness`/`set_solo_intent`(reason)**：readiness（interaction recovery/subteam init）收；solo_intent 升格 world_state（`_set_solo` 呼此，原已單寫者無旁寫）。
  - **S11 faction_id**：6 construction 站改走 `set_team_faction(t,-1)`（fresh team no-op，單寫者一致）+ event_faction_defect:21。
  - **S12 reputation**：sim_runner:168 改走 `update_reputation`（等價 clampf）。
  - **★平行紀律殘量（conquest-yield-chain 在飛，禁碰 → 該波 merge 後補收）**：`outpost_system.gd` tags 5 站（342/343/369/372/375）、`npc_combat_system.gd` readiness drain 2 站（183/184）暫豁免。CI-scan pattern 已註記於各 chokepoint（強制閘地基）。
  - **★stale-spec 校正**：spec 標 `event_faction_defect.gd::execute()` 為「懸空 member_team_ids 行為修（pointwise DIRTY 預期）」= **過時**。現 code line 24 `clear_team_faction`（faction 存在健康路徑）已修懸空；line 21 僅 faction-missing 防禦路徑（known_issues 138/160 證 world_sim 0 violation）→ 改走 `clear_team_faction` = 純 refactor（faction 不存在時語意等同 `=-1`，無懸空可修），**非行為修、pointwise CLEAN**。既有「defect:21 待 systematic-debug」項可結（機制已明：非 bug）。
  - **未收殘欄（本波 scope 外，backlog）**：S6 其餘無主欄（fatigue/work_morale/current_option/strategic_assignments/ambition_*）；`faction_ai_system.gd::_find_strong_neighbor()` `known_reputations[str_key]=owner_leader` = **cache 濫用 known_reputations dict（string key 存 leader id，非 reputation）**，非 S12 對象，宜獨立改名/搬 cache 欄（呈報系統）。

## 觀測 GUI 揭項（2026-07-04 observer slice，純觀測揭露、sim 未動）

- **★beast pseudo-team 洩入人類系統**：獸隊（id -1000000 段）走 `order_system.tick_team_orders` 張貼收購武器訂單、message 系統對人宣戰帶隊名——兩處未排除 `beast_kind != ""`。另 beast leader_id=-1 → faction_ai 繼承安全網會不會給獸隊晉升人名 leader 待驗。UI 層已標「X(獸)」,sim 側修=order/message 入口加 beast 濾（小）＋安全網 beast 豁免驗證。
- **ticker 同 tick 雙 channel 排序**：global_messages 先於 observer_messages 穩定合併 → 同 tick「收服」顯示先於「俘獲」（code 時序相反）。同日戳可讀性無傷;要嚴格時序需 per-tick 序號（未做,minor）。
- **MAX 速 ticker 滅團標示**：事件主已滅團顯示「隊N(已滅)」=消費時 state,誠實但可讀性小傷（1×/4× 幾乎不見,minor）。
- **observer_messages 無 TTL**：cap 2000 裁尾,sim 零讀無行為風險,僅記憶體上界（by design,記錄備查）。

## 後期 scaling / late-game 卡死風險（2026-07-01 評估，全報告 `specs/2026-07-01-late-game-scaling-assessment`）

> LOD infra 存在且對 movement/economy 正確,但重認知系統 defeat LOD → O(N²)/hr。沙盒長跑須加固(否則大戲跑不到)。非重寫,P0 三項 targeted。
- **★compute top:`faction_ai_system.gd:625 evaluate_all` 忽略 LOD 參數 → O(N²)（2026-07-05 lod_perf_bed 量化坐實）**：`evaluate_all(state, _team_ids)` 的 subset 被 `_` 忽略、`faction_ai_system.gd::_evaluate_all_body()` 對**全 factions×全 member_team_ids** 跑（非 near subset）→ faction AI 成本隨總隊數長,LOD 沒 gate。**perf 曲線（seed1337,2月,mean 攤銷）**:21隊 LOD 2994us(334tps)/full-HD 9035us / 41隊 7295us(137tps)/23659us / 107隊 49260us(20tps,max 6.7s)/137747us(7tps,max 7.4s)。**指數~2.0=O(N²) 鐵證;LOD 僅 3× 常數因子（movement/vision LOD-gate 給的,O(N²) 大頭沒 gate）。41隊(warring 自然上限)LOD 已 137tps<240+1s hitch;107隊(強塞 config)兩 regime 全垮**。修=bound faction AI（honor-LOD / 空間分區 / cadence 攤）=獨立 perf arc,規模野心大才值(藍圖裁目標規模,報 `2026-07-05-systems-to-blueprint-lod-perf-data`)。~~`_has_hostile_within` 每隊掃全隊~~ **已修（用 `state.teams_within` 空間索引,此條 stale 劃除）**。
- **★LOD「疏非慢非笨」重定義（2026-07-05,與上 throughput 正交）**：far 移速10×慢/思考10×低頻=遠隊行為錯（物流癱=trade/envoy 一修雙解）。修=elapsed 積分（movement process 收 elapsed_ticks + faction cadence）。**與 O(N²) throughput 是兩回事**:此修行為對(遠隊正常活)但不改 throughput;throughput 修才決定 full-HD 拿不拿掉 LOD。B 修可先開軌(不卡規模裁定)。
- ~~★compute:`world_state.gd erase_team` O(N)/erase → die-off O(K·N)~~ **✅ 批次化 done（2026-07-02 merged,`erase_teams` 單趟 sweep O(N+K),pointwise CLEAN×3 seed=零行為變,scaling 2.1-3.0× 隨 N 放大）**。**cadence spike 接棒案 ✅ 已收（2026-07-02 merged `cadence-spike-fix`）**:量測鏈 PhaseSpike→FaiPhase→call 級定罪（DecisionContext.gather finders A\* fan-out ~65%+_find_weakest_prey ~30%+infra new_loc O(tiles²)）→ 修全行為不變（**SSSP Dijkstra 永續 cache**（terrain 靜態,以 world iid 分層;runtime 改地形須呼 `PathSystem.clear_sssp()`,已留 API）+trusted param 跳 O(n) has+infra 敵 outpost hoist）。**pointwise IDENTICAL×3 seed**。faction_ai hourly 1.2-1.6s→常態 50-70ms(~20×)、早晚曲線平、K 分桶無惡化。⚠ 實作正確擋掉 plan 兩修法:濾先行/memoize 會位移 `observe_velocity` randf 流→pointwise dirty（**教訓:濾鏈含 RNG 副作用,「純 AND 濾可重排」假設要先驗 RNG**）。**→ 殘餘 perf 案（quantified,per-tick 不變量現行違反者,queue）**:①`far.total` LOD far batch 0.45-0.83s/500tick=現 top violator（pre-existing,top-15 spike 全是它）②`loop3.orders_ambition` ~300-330ms（OrderSystem order-cadence 對齊 tick 集中爆）③⛔**RETRACTED — 不得引用**（systems 2026-08-27，blueprint 准）：~~`unified.rank` 殘餘 `gather.market`／`home_food` **O(tiles) 掃** <100ms 級~~
   ★**推翻它的是**：**2026-08-27 measurer 讀 production code file:line** —— `faction_ai_system.gd:3463-3475` 迭代的是 `VisionSystem.VISION_RADIUS`（**＝3，`vision_system.gd:3`**）的**固定窗**；`:3440-3458` 迭代的是 `team_market_known` **每隊自己的快取** ⇒ ★★**都不是 `state.world.tiles` 全圖，是 O(vision_radius²)＝O(3²) 有界掃描。**
   ＋ **radius 12/18/24（tiles 3.84×）spike 中位數不單調、tile 最多階反而最低**（若真是 O(tiles) 就該單調長）。
   ★**位置活**（`gather.*` 確實是大宗：**對 `dt` 佔比穩定 ~35%**）；★★**機制宣稱死**（不是 O(tiles)）；**數值死**（`<100ms 級` 是別的時候）。
   ⇒ ★★★**要引用 `gather` 成本的人，請引這一段，不要引上面那句。****裁定:不阻長窗**（spike 耗 wall-time 不污染 sim 數據=deterministic;長窗 GODOT_TIMEOUT 預算加大;量測期間勿並行重 bed 防機器爭用）。
- compute 其他 O(N²)/O(N·T)/hr：`faction_ai_system.gd::_evaluate_outpost_residency()`(全 tile/隊)、`vision_system.gd:22 tick_discovery`(inner 全 N)、`interaction_system.gd:74`(co-location 全掃,修 pattern 已存 `sim_runner.gd:247` pos_map)、`outpost_system.gd:168 tick_all`。
- **★memory top leak:`world_state.gd:17 team_intel` observer rows O(世界年齡無界)**：`erase_team` 從不 prune team_intel → 每個曾存在的隊留永久 observer dict + 死 target claim rows。per-obs 200 claim cap 有、observer row 無。修=erase_team 加 `team_intel.erase(tid)` + 掃 observer 清死 target（同 create_faction chokepoint）。
- memory 其他：`player_alerts` headless 無 poll leak(diplomatic 未 dedup)、`person_data.gd:54 memory` 繞過 `_trim_memory` 路徑(reaction:369/diplomacy/trade/command)可超 MEMORY_MAX=20。其餘結構全有 cap/TTL/erase-prune 界住。
- **nit**:`world_state.gd:157-158 team_known[obs].erase(tid)` no-op(array 存 MessageData 非 int)→ 意圖 cleanup 沒跑;無害(TTL 覆蓋)該修對。
- **加固排序建議**：granary(定世界規模)→ P0(faction AI honor LOD + tile→teams 共用空間索引 + team_intel erase-prune)配 #2/#3 探針/計時 + scaling bed 驗 → 長跑觀 emergence。
- **P0 加固進度（2026-07-01 merged）**：✅ **tile→teams 索引 done**(co-location O(N²)→O(N)、hostile-within/residency sparse tail 收) + ✅ **team_intel erase-prune done**(top leak 修) + ✅ tick 計時 instrument + scaling bed。**honor-LOD 未觸發**(量到 evaluate_all 誠實 O(N)、索引已足;行為變 measure-gated 沒量到不做)。✅ **die-off erase 批次化 done（2026-07-02 merged）**:`erase_teams` 批次 API,O(K·N)→O(N+K),pointwise CLEAN×3 seed。**🔴 接棒案=cadence tick spike**（見上 ★compute 條:erase 非現行主導,K=0 cadence tick 1.2-1.6s 才是 per-tick 不變量最大違反者;`dieoff_perf_bed` 常備床已入 tree,量測案待排）。scaling bed sparse+high-movement near-zone 場景待加。
- **★致富非 named intent（specimen tracer 揭，經濟真根，2026-07-01）**：獨立商隊決策全走 DecisionEngine per-tick utility 標「日常」,**零 named 致富 intent**(commander-v2 只給 faction intent、獨立隊無致富意圖節點)→ 交易純 emergent、被 survival/食物壓力碾成覓食/買糧(無複利)。**修向（待藍圖）**：致富要不要成 named 意圖=給獨立隊致富 intent 節點(統一決策 arc 延伸);且食物壓力(R1,緩)是掐致富直接手。**更新（首燒 merged）**：致富**已成 named intent**(select_strategic_intent 給獨立隊全菜單) → specimen 商隊現 想=致富262/263。
- **★致富→交易 下一閘＝建設 util 碾壓貿易（B 食物張力 branch 揭，2026-07-01，`feat/food-tension` 未 merge）**：granary爆倉真根**已修**(R1 供給 day_fraction 對齊 + far 冗餘 regen 移除 + R2 成長讀 flow 非 stock + FOOD_PER_PERSON 0.8 張力校準;forest 苟活/plains 繁榮/不 mass-starve 皆 bed 證)。但 specimen 商隊 想=致富262 → winner=**建設**263/263(建設0.79 > 貿易0.26)，**從不貿易** → 致富→交易→成長鏈仍不接。**新真閘 = 決策層 建設 util 高於貿易**（非食物/granary，屬決策權重域,本軌 scope 外）。修向：貿易 util 提權 or 建設 gate（有訂單/有 arb 時貿易應勝建設）＝決策層另軌。
- **★野心 rung 改讀食物 flow → 戰略層行為變（B 食物張力 branch，待主 session 裁）**：`ambition_ladder` 積累 rung 由 `effective_food`(stock) 改讀 `food_flow_avg`(持續淨盈餘) → 新隊/marginal 隊 flow=0 起步暫卡 RUNG_SURVIVE(需持續盈餘才升 rung/觸 prosperity-attack)。**founding 未受影響**(獨立建國用自身 stock gate `faction_ai_system.gd::calc_readiness()` 未動,framework S1 PASS);但**侵略性擴張(prosperity-attack)現需經濟盈餘**(飢餓隊不再主動開戰)＝合理但屬行為變,warring 全窗未驗(sim 太重 timeout,見 progress)。
- **specimen tracer scope 缺口（非 bug）**：`capture_decision` 只 tap unified+survival winner commit,**prosperity-attack(`_evaluate_prosperity_attack`)+faction-goal-dispatch(~faction_ai:1090) TASK_ATTACK commit 不捕** → 「征服 intent→攻擊 action」鏈那段 tracer 看不到。要完整 trace 需增這兩點 capture。

## 讀B/G3 Phase E backlog（2026-07-01 平行軌）

- **★次閘：定居隊 granary 自填 = trade loop 不 fire 真閘（讀B 覓食 cap 後 measure 揭）**：覓食 subsistence cap 正確封住覓食成長路徑（unit 測 + priv food 壓低證），但 econ_bed baseline 對照顯 **forest 定居隊（regen food=3）granary 月1 即填至 ~cap（gran≈1999）並維持**，pop 成長由 granary（eff_food≈2200）驅動非覓食（priv≈150-288）→ cap 對定居成長影響小 → **trade loop 沒需求驅動、不 fire**。「繁榮須交易」emergence 未到（覓食封了、granary 旁路未封）。屬 **granary/harvest 域**（食物統一 arc 下一 slice），非覓食 cap scope。**修向（待藍圖排序 + measure）**：查 forest regen 3 為何 granary 也填滿（harvest 產出 / storage cap / tile 食物池 init 來源）→ 定居隊 granary 亦須「特化受限」才逼交易。覓食 cap 是必要地板層（granary 修好後覓食不能 backfill 成長）。
- **`FORAGE_FLOOR_DAYS=1.5` = TEST VALUE**：econ_bed/warring 顯覓食隊苟活不死、不膨脹；正式平衡再校（太低=餓死潮、太高=仍自足）。覓食 cap 對玩家 active hunt 同樣生效（對稱），玩家面手感待真人玩測。
- **G3「自信地錯」emergence 需 Phase D + 專屬 probe 才量得到**：Phase E enforce 機制到位（決策真讀 belief、欺敵可有後果、回歸測綠），但**未加專屬「按假 belief 行動並被咬」計數器** → 短窗 seed 無法量化 emergence。需 Phase D（植假 primitive）+ probe。本 phase 只證「決策跟 belief 走」。
- **[列管·藍圖知會 2026-07-02 `ai-depth-roadmap`,非現在做] AI 深度兩項**（roadmap 落 game-design「AI 深度 roadmap」段,藍圖 owner）：
  - **深化二 blocker→子需求**：目標被 gate 擋 → AI 讀 gate-ladder 探針信號把 blocker 變子需求（想立國卡糧→攢糧）+選擇性遞迴一層。零新判斷器（AI 當既有探針 reader）。**觸發條件=長窗數據見「狼卡可解 gate 前乾等」**（長窗回報時順帶標此訊號）。守四關。
  - **經驗=自己的 claim**：被伏擊→「那山谷危險」=一條親見高信 claim,fold 進 belief 域零新學習系統。**G3 Phase D/belief 擴充時帶上**（一行 backlog）。劇烈經驗塑人格=Trait 縫照舊排隊。
- **headless baseline 既有 FAIL：`[FAIL] 弱目標未加入攻擊 goal`（pre-existing，非 G3/讀B 引入）**：已驗 main dd26f67 baseline 即此 1 FAIL（G3/foraging 兩 branch 皆 1 FAIL 同源）。locus = commander-v2 `_update_goals` 攻擊 goal 未對弱目標開（belief/goal-emit 相關，非本輪 5 leak）。待另案追（確認為 bug or 刻意行為）。
- **⚠【地基待重驗】★headless baseline 現況 FAIL 集** —— ★**2026-08-21 R6 標記**：此條的數字來自 **main `ec74d28` / 2026-07-12**，距今已 40 天、落後 main 數百個 commit，**不可再當作現行 baseline 引用**。今日實測 merged tree ＝ **14 行錯誤**（見下條）。要當 merge-gate 參照請先重跑。原文如下（保留供對照）：
  **★headless baseline 現況 FAIL 集（main `ec74d28`，2026-07-12 全量比對，merge-gate 參照）**：headless_test 現有 **5 個 pre-existing FAIL**（多為 in-flight slice 的 TDD-red，非 world-gen 引入）——① `弱目標未加入攻擊 goal`（見上）② `Team23 task=建設 order=-1`（建設 order dispatch）③ `[p2a] join weight 太低 0.41`（:15284，reputation-magnet/survival term p2a）④ `戰鬥中(combat_target≠-1)→197 擋→不 resolve`（:6918，BEG/JOIN social_target vs combat_target，見上 :64 合修案）⑤ `rung 擴張+武力 未選擴張 intent`（:13775，得防衛 target=-1）。**world-gen variety 分支（feat/worldgen-variety）headless FAIL 集與 main byte-identical=零新增** → world-gen 非 regression，merge 於 headless 維度清。融合閘（framework/constitution/coin/determinism）為真 merge 閘，headless 已知 pre-existing FAIL 不阻 merge。未來 merge-gate 以此 5-FAIL 為 baseline，新增才 halt。**★2026-08-15 更新（settlement S1 merge-gate 順手驗、baseline 已成長）**：baseline 自 2026-07-12 起隨 in-flight slice 成長，**另 2 個 pre-existing FAIL 確認**（非在上列 5）——⑥ `紮營=1.0`（`headless_test.gd`（★L2 錨：systems 判 2026-09-01 —— ★本條講的【就是 headless baseline 本身】⇒ 錨指床是【對的】，不是 NEED_HUMAN）、`DecisionTerms.eval("camp_drive",ctx,"紮營")==1.0`、camp_drive term eval）⑦ `FORCE(任rung)→ambient_train_drive 0.5`（:1963、train_drive term）。**驗法**：pre-S1 main（`a3d197df`、零 S1 code）headless 三 assert（⑤⑥⑦）皆 FAIL、與 branch/merged 完全一致 → S1 零新增（S1 diff 僅 erase_teams outpost_owner + `_find_unowned_farmable_tile` reclaim-scan、不碰 terms.gd/intent 選擇）。**★★2026-08-20 全量重刷（systems 於 §4c+繼承-lite merge-gate 實測、pre-merge commit `4d7239c8` 專用 worktree 對照）——現行 baseline＝下列 6 條、順序固定，merge-gate 以此為準**：`T1:覓食 base 恆 1.0(飢餓在 coeff)`（`headless_test.gd`（★L2 錨：systems 判 2026-09-01 —— ★本條講的【就是 headless baseline 本身】⇒ 錨指床是【對的】，不是 NEED_HUMAN） survival_pressure term）／`[p2a] join weight 太低 0.41`／`戰鬥中(combat_target≠-1) → 197 擋 → 不 resolve`／`紮營=1.0`／`FORCE(任rung)→ambient_train_drive 0.5`／`rung 擴張+武力 未選擴張 intent`（got 防衛/target=-1）。與舊 ①–⑦ 差異：**①弱目標未加入攻擊 goal、②Team23 task=建設 order=-1 已不再 FAIL**（期間某 slice 修掉、未逐一溯源）；**新增「覓食 base 恆 1.0」**＝舊集確實 stale、**非本輪引入**（pre-merge baseline 實測同樣 FAIL）。`world Nil` SCRIPT ERROR **=7**。★**方法論教訓**：merge-gate 濾 headless **禁用 `Group-Object … -First N`**——6 條 FAIL 全是 `count=1`，會被出現次數高的正常 sim print 擠掉（本輪第一跑就這樣險些放行），要直接 `Select-String "Assertion failed"` 全列。（史）current 已知 pre-existing = ①–⑦。另 headless 尾大量 `Invalid get index 'world' on Nil`=own_granary null-caller 既有 crash（見本檔上「own_granary_tile(state=Nil)」條、crash investigation-slice 待修）、非 merge regression。
- **headless_test 既有噪音：`own_granary_tile` 對 `state.world` 無 null 護欄**（`resource_system.gd:433`）—— 合成 state（`state.world == null`）呼叫時噴 `Invalid get index 'world' (on base: 'Nil')`，今日實測**單跑 7 次**。`@70a792b3` 起算的今日 main 上實測 `14 行錯誤 @<今日> 2026-08-21`；**pre-existing、非任何在飛 slice 引入**。production 路徑 `state.world` 不會是 null，所以這是**測試噪音不是 production bug**——但它讓 headless 的 0-new 判讀每次都要人工挑掉 7 行，**建議順手加 null 護欄**（L3，一行）。
- **world-gen §3 兩非阻擋觀察（merge `9156f6f` R² re-check，2026-07-12，供知悉非缺陷）**：①**§3①「可達」實作偏弱**：`_tile_reachable`/`_has_passable_neighbor` 只查 `state.world.tiles.has()` 靜態存在+鄰格存在,無 PathSystem 呼叫。本引擎無不可通行地形（山地=移動慢非阻擋）→ 此檢查對完整 hex grid 幾乎恒真,對「勢力被封死」保護力有限——但該風險在本引擎地形模型下本就近乎不存在,落差非缺陷,命名/描述與實作力度不完全對齊。**若未來加不可通行地形,此檢查須升真 PathSystem reachable**。②**fallback 觀測粒度**：fallback 挽救成功時 probe 記 `floor_pass`,不留痕「此輪靠 fallback 介入」（真失敗仍記 `floor_fail`,最終狀態誠實）→ 少「主路徑失敗率」中間信號。未來追 retry 有效性可加 `worldgen.floor_fallback_used` probe,非必須。
- **G3 1c 施援同 faction snapshot 豁免 = 可選增益（裁定：維持 belief-strict）**：`_find_aid_target` 對同 faction 成員現走 belief-strict（無本隊 team_intel belief→跳過），未讀 faction `known_member_states` snapshot（leader 共享 belief）。**不違 provenance 不變量**（snapshot 本身 = best_estimate 派生、非 god-view）→ 現行正確且保守。snapshot 豁免=增益非修正，列可選後續，不擴 scope。

- ✅ **anon_treasury 滅隊 off-map leak（已修 2026-07-03 S1 tile-bank Task3）**：`_route_extinct_assets` no-tile 分支改記顯性 sink `WorldState.offmap_extinct_coin`（reason=`extinct_no_tile` + record_driver），`CoinAudit.total` 全池納此池 → 守恆閉合、不再靜默丟失。測 `_test_extinct_offmap_coin_ledger`。（原：隊死於 off-map 且 `_nearest_valid_tile` radius-12 找不到 tile → coin 憑空丟失，degenerate only。）

- ✅ **mint coin-cap 燒 ore off-ledger（已修 + 固化 2026-07-03 S1 tile-bank Task2）**：`_tick_mint` 前置 room-cap（`if room<=0: return` + `convert` 由 `minf(rate,room)/RATIO` 限量）→ 滿 cap 不燒 ore、有餘裕按可鑄量部分耗 ore。coin/ore 寫入收編走 `TileBank.set_amt`（reason=mint/mint_consume_*）。測 `_test_mint_cap_no_ore_burn` 固化（滿 cap 不燒 + delta==minted）。

## affordance 真實性債（commander-unify v2 盤點，2026-06-28）

> 北極星「凡 named 意圖必有可解釋驅動」+ affordance 真實性 invariant：宣稱效果模擬不出=孤兒 affordance=假。commander v2 **只掛真 affordance**，下列孤兒=暫不掛、列債（撐起來才掛）。盤點 = action-effect 審計（7 action/47 真效果/29 孤兒）。

- **真 affordance（v2 可掛）**：攻擊=削軍力(`npc_combat`casualty)+掠奪得資源(30% loot)；徵收=籌資(resource transfer)+壓迫(stress/loyalty hit)；外交=真結盟(faction merge)+背叛(betrayal 65%)；貿易=致富(+coin/換貨)；建設=mint(ore→coin)/stable(練騎)/倉儲;結盟=faction merge。
- **孤兒 affordance（藍圖願景但 sim 不產出 → 債）**：
  - **欺敵外交/離間/緩兵**（外交只有真結盟+背叛，無假和/離間第三方/緩兵機制）→ 玩家錨 C「拋外交=真心還是欺敵」的欺敵層**需先建欺敵機制**。
  - **貿易戰=砸敵經濟**（貿易只 local +coin/換貨，無供應斷鏈/壟斷收購/傾銷崩價）→ 需建供應鏈缺貨傳導（撐在既有市集/order plumbing 上）。
  - **壓迫 cascade/削弱屬民**（徵收有 stress/loyalty hit，無「缺糧→餓→忠誠崩」spiral）。
  - **城防/威望/產能升級**（建設只 mint/stable/倉儲，無守備加成/招募吸引/製造佇列）。
  - **互防/離間**（結盟只 faction merge，無自動戰鬥支援）。**戰俘 ransom/勞役**（prisoner_population 欄存在未用）。
- **影響**：v2 means-end commander **真 affordance 可跑**（征服X→攻擊+結盟/徵收 補軍力，depth-1 回推）；欺敵/貿易戰 deception 層 = 下列承諾 arc。
- **★ 欺敵 sim arc = anchored-pre-player 承諾 arc（藍圖裁 A，2026-06-28，非一般債）**：欺敵=玩家錨 C 心臟（看 action 反推 driver 全靠它）。**硬綁「玩家面開工之前必落地」**。內容=假和/斷供-貿易戰/離間/緩兵 sim 機制 → 建好**插回 commander 既有 means-end 機器**（affordance 由孤兒轉真、自動進匹配）。時序：commander-v2 → **欺敵 arc(玩家面前)** → 其餘孤兒 richness pipeline（壓迫 cascade/城防-威望-產能/戰俘 ransom，按 player-visibility）→ 玩家面。**禁無限延**（承諾 arc 非 cosmetic）。

## 統一決策框架 / survival backlog（P2b-1 揭）

- **attacker 輕飢 churn（pre-existing，P2b-1 world_sim 量測揭）**：~927 次/2yr 攻擊隊輕飢→`_evaluate_survival`→survival 評估無可派 option→`release`→idle→再攻 → churn。**非 P2b-1 引入**（baseline 927→after 932 幾乎不變）= 既有獨立問題。spec measure-first 把 1037 `[Survival]` 誤解為 return_home 熱路徑，實為此 churn 主導。**修向**：survival entry 對「無可派 option 之輕飢攻擊隊」早退不進 survival 評估 / 或攻擊 task 對輕飢更黏。待排序。
- **restock_need 非距離感知（P2b-1 距離 nuance 丟失）**：舊 `_trigger_survival` home-path「遠 outpost(eta>5天)+殘忍/好戰→就近掠」隨委派移除（`返家補給` 一律返家）。loot 稀有(11/2yr)，影響小。**後補向**：`restock_need` 加距離衰減 → 遠家殘忍隊重獲就近掠傾向。
- **survival 掠奪 option 無 G3d-1 confident_enough gate**：`掠奪` option（P1 建，P2b-1 沿用）的 `_find_weakest_prey` 只 has_belief 守衛，**未過 `confident_enough`**（invariants §決策風險 gate 列 survival loot 應 gate）。= 與舊 homeless loot parity（舊亦無 gate）、與舊 remote-loot Path1（有 gate，已隨 P2b-1 刪）不一致。後果：慎重 leader 絕境掠奪可能中假弱誘殺（無 scout 保護）。非 P2b-1 引入（P1 既存）。**修向**：`掠奪` applicable 或 to_task 前過 confident_enough（慎重者不確定→不選/scout）。
- **`_evaluate_solo` survival 仍雙 owner（P2b-1 範圍外）**：solo AI 的 camp/join survival scoring（`faction_ai_system.gd:~1058-1099`）仍手寫，未統一進 `rank_survival`。P2b-1 只統一 `_trigger_survival`。並 P2b-2 或獨立塊清。
- **`返家補給` 站家上 edge（P2b-1 generalize 擴大觸及）**：隊站自家(空)outpost 上絕境 → `返家補給` target=當前格 → return_home 原地。舊 Path1 同行為，未新增 latch，但 generalize 擴大觸及面 → 留意 world_sim 是否現原地空轉。

## G1a 礦村（鑄幣脈絡）backlog

- **礦村稀有邊際**：非貪婪 leader 在無 in-range 平原勝 MIN_BUILD_SCORE 時，ore +35 仍可把含礦山推過建址下限 → 偶founds 礦村。可信（山是唯一選項）非守恆問題，稍寬「稀有」。量測註記。
- **dense map distance 免疫未測**：`_check_distance` 含礦山 civilian 免疫（同 tick 多寫/密圖）未驗。
- **default 自然 fire 4/5（unseeded）**：礦村魂 default.json 自然 fire 但非每 run（tail 行為）；world_sim(buffed) 1/1。看機制 fire 非絕對閾 [[reference_multi_sanity_unseeded]]。

## 🔴 高優先（影響基本可玩性）

### P4 玩測批（2026-06-16 玩測抓,主 session harness 驗修中）
- **U16 地圖視野不以玩家為中心** ✅ 真修(viewport,見下 U16)。
- **P4-1 demand_tribute forced event「未知提案類型」** ✅ 修(`_accept_diplomacy` 加 "demand_tribute" case + framing「要求納貢」)。
- **P4-2 打獵選項混在 team 互動選單中** ✅ 修:`_interact_action_split()` 分離 self/原地動作 vs team-target;self-actions 在目標選擇階段直接可選,team-focus 只顯 team-kind。ui_flow 驗。
- **P4-3 跟其他 team 互動缺乞討等生存選項(選項不全)** ⚠ 開→roadmap:玩家無「乞討/投靠」等主動生存動作(對稱性缺——NPC 會,玩家不能)。**非「已有功能 UI 落差」,是缺玩家 command(新 feature)** → 對稱性,需設計 spec。
- **P4-4 遭遇戰到邊界不會停** ✅ 修:encounter_view 移動 target + attack_select 游標加 `_is_in_map` clamp。GUI clamp 邏輯確,視覺待玩測。
- **動作 UI 覆蓋保證**:新增 `_test_action_ui_coverage`,47 registry actions 全驗有 UI 路徑(防未來新增漏接)。
- **「等很多」**:玩測尚有未列出問題,待用戶補。
- **狀態**:U16/P4-1/P4-2/P4-4 已修 + harness 驗;P4-3=對稱性 feature→roadmap;覆蓋測保證已有功能全可達。

### P6 玩測批（2026-06-17 玩家實機遭遇戰玩測抓）
- **E-1 弱隊殺不光 / 對攻擊免疫**（高，世界無法收斂）。`armed_anon_ratio=0` 隊 → encounter spawn 0 匿名只 1 named 接戰；normal 遭遇戰**不減隊 pop**（只擊退上場單位）→ 打贏隊 pop 原封不動 → 弱隊無限被刷但殺不死。根因：normal 遭遇戰無「敗方 pop 損耗」機制 + 未上場 unarmed pop 不受傷。修向需設計：敗方 pop 損耗 / 強制 subjugate-or-flee / 武裝率下限。
  - **退化修已實作（2026-06-19，spec `2026-06-19-e1-annihilation-degenerate`）**：A 敗方整隊 pop 損耗（encounter reserve 連坐 `_apply_reserve_casualty` + npc_combat `_end_combat` `LOSER_CASUALTY_RATE`，對稱）+ B tier 加權存活（`SURVIVAL_KILL_WEIGHT`，平民承重/菁英多生還）+ C 武裝下限（`ARMED_RATIO_FLOOR`，消費端套用不覆寫推導值）。完整意志/人海/戰俘模型仍待母 spec `2026-06-19-combat-unification-umbrella` 後續子 spec；「打到死」滅團整鏈需繼承統一 plan（`2026-06-19-leader-succession-single-source`）合入才完整。
  - **brainstorm 深挖（2026-06-19，#1 spec 前置）**：E-1 實為**兩個獨立病灶**疊加：
    1. **結構免疫**：encounter 只 spawn 上場 units = `named + mini(pop×armed_anon_ratio, ANON_UNIT_CAP)`（encounter:247-248）；死亡 `kill_random` 只記上場陣亡（:1186-1194）→ 未上場 anon mass 永不在 kill 池 → pop 殺不掉。
    2. **繼承分叉（違單一真值源）**：兩套繼承實作分叉。`event_system.on_leader_death`(:47) named 不足→**從 anon 晉升**（符合設計）；但 faction_ai 每 tick 偵測點(:502) gate `not named_members.is_empty()` + `_promote_successor`(:1066) **只從現存 named 拔、無 anon fallback** → 遭遇戰打到 named 全滅的隊「設計該晉升 anon 卻沒晉升」= 永久 leaderless anon blob（玩測觀察到 named 不再生）。`generate_for_team`(anon→named) 只被 `npc_combat_system.gd::_kill_named_npc()`+`subteam_system.gd`（★L2 錨：檔級） 呼，faction_ai 偵測沒接。
  - **關鍵推論**：單修繼承會回到「named 工廠」死循環（死→晉升 anon→又上場→又死），仍不收斂。**必須繼承統一 + 敗方 pop 損耗(模型 A) 兩件一起** → 一直打→anon 漸減→anon=0→無人晉升→`on_leader_death` 回 false→團崩潰滅團（event:54）= 真「打到死」。
  - **複用先例**：`force_occupy`(encounter:1424 `occ_dead = pop − pop×0.8`) 已有 20% pop 損耗機制，模型 A 可複用公式。
  - **分叉解剖（2026-06-19 #3，③ 已挖→證實）**：戰鬥**兩條路徑 explicit by design 分叉**（`ambush:60-66` 註明「Bug9：NPC 不走 encounter」）：
    - **encounter（戰術）**：觸發者 = `player_command_system` 全部 + `ambush` 玩家分支。spawn 上場 units、`kill_random` 只數上場（:1186-1194）。
    - **npc_combat（抽象）**：觸發者 = `interaction:248-260`（NPC 遭遇）、`faction_ai_system.gd::_evaluate_all_body()`、`npc_combat_system.gd::_apply_casualties()`（NPC 分支）。`_apply_casualties`(:404)→`wound_random` 打**全 anon pool（無 cap 免疫）**、`_kill_named_npc`(:451)→`on_leader_death`(:456) **有 anon 晉升 fallback**。
    - **結論：兩病灶全在 encounter 路徑，NPC-vs-NPC 結構無病** → 解釋為何 multi sanity NPC 世界不崩、只玩測玩家介入才見 leaderless blob。**E-1 範圍大幅縮，不需碰 npc_combat。**
    - **繼承分叉真因鎖定**：`encounter_system.gd::_check_prisoners()` 死 leader **只 `leader_id=-1`，從不叫 `on_leader_death`**；靠 `faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） 補但 gate `named 非空` → named 全滅時不觸發 + `_promote_successor`(:1066) 無 anon fallback。對照 `npc_combat_system.gd::tick_critical_npcs()` 死 leader 直接叫 `on_leader_death` ✓。同樣死 leader，encounter 走殘缺路徑 = 分叉本體。
  - **owner 分屬（2026-06-19 #3 裁）**：
    - **繼承統一 = 系統 HOW**（單一真值源 seam）：立 `on_leader_death` 為繼承**單一 owner**，三入口（encounter:1184 / faction_ai:502 / npc_combat:456）全 route 進來、補 invariant。⚠ 合併須吸收 `_promote_successor` 的 **player heir 分支**(`_handle_player_leader_death`:1069，`on_leader_death` 現無)否則玩家死亡選繼承壞掉。行為不變（anon 晉升早在 on_leader_death），故非擴大願景。3 檔 + invariant → L2，需 spec/plan→worktree。
      - **✅ 繼承分叉已修（2026-06-19，spec `2026-06-19-leader-succession-single-source-design.md` + plan + `feat/leader-succession`）**：`on_leader_death` 成單一 owner（named 掃 named_members、無統領門檻、anon fallback、晉升後 check_overflow、player 分支內聚 + 冪等）；`faction_ai` 偵測 gate 由 `leader_id==-1 and named非空` 改為純 `leader_id==-1`（唯一偵測點，捕捉 encounter 裸置/饑荒/任意 leaderless）；刪 `_promote_successor`/`_handle_player_leader_death`，外部 caller（encounter `_check_player_wiped`、player_command stale-heir）改呼 public `EventSystem.handle_player_succession`；`get_player_team_id` 抽到 WorldState 單一源；順修 player 絕後經安全網 game_over 的 latent gap。**encounter 不碰**（死者 person 未 erase → 安全網次 tick 補位）。**結構免疫（殲滅模型 A）仍待藍圖 WHAT**，未在此 plan。
    - **結構免疫→「打到死」殲滅模型(模型 A pop 損耗) = 藍圖 WHAT 待決**：呈報藍圖（handback `systems-to-blueprint`）。
  - **spec 前剩小挖點**：① encounter 觸發/spawn 端（誰發起、為何反覆刷弱隊、spawn 時未上場 pop 怎記）② `ANON_UNIT_CAP` 值 ④ retreat/draw 是否常態結局（接 E-2，則連現有 pop 損耗都不觸發）。
- **E-2 AI 死戰到死**（中）。`_should_retreat`(encounter:322) 存在(殘廢率>0.7/torso critical/求生欲高30%機率) 但小隊(1單位)只在該單位倒下 ratio 才>0.7 → 等於戰到殘才逃,觀感死戰。小隊撤退門檻需調(絕對 HP/敵我懸殊判定,非只 ratio)。
- ✅ **E-3 玩家走到戰場邊無逃離**（已修，sim 驗 / UI 待 run-verify）。`_decide_action` 玩家 move 分支偵測 off-map target → 轉 retreat（既有 apply 在 `hex_dist>MAP_RADIUS` 設 `has_exited`）；encounter_view idle 邊界往外方向鍵 → `_do_exit`。sim 端 `_test_e3_player_edge_exit` 驗證離場機制；UI 鍵入 headless 不可測 → **待真人玩測**「邊界按往外方向 → 玩家離場、結算返世界」。**範圍**：只最小玩家角色離場（復用 has_exited/retreat apply）；「退場有代價」（追擊落跑傷兵）/全隊撤退 留藍圖衝突統一傘，未做。
- **U16-b 遭遇戰相機固定 ✅ 修（2026-06-17，待 run-verify）**。確認=**遭遇戰 tactical view**（非世界地圖;world map render headless 證實正確）。根因：`encounter_view.show_encounter:45` 相機固定置中 axial(0,0) **設一次永不更新** → 玩家單位偏離 (0,0) 時看不到自己、半邊出畫面（「x=0可視 x≤-1切」）。**修**：`_refresh_ui` 每次重置相機跟玩家單位 pos（`_camera = vp*0.5 - _hex_center(player_unit.pos)*_zoom`）。parse 綠、ui_logic 0。**GUI 視覺待玩家 run-verify**。
- **俘虜處置缺**（→ roadmap 中期）。capture/store(`prisoner_population`)✅,處置(賣/屠/招降/釋放/勞役)❌ 全沒 → 俘虜只增不用的死數字。

### P5 QA批（2026-06-16 QA session harness 系統遍歷，stage2 驗收抓）
> ui_flow 31/31 全綠但漏抓——測試只驗「能呼叫/字串含關鍵字」，不驗端到端守恆與主場景路徑。
- **B-1 收留撞 pop_cap** ✅ 已修（驗證 2026-06-19，移 `archive/resolved_issues.md`）。merge 前驗容量拒收 + cost 改 merge 後量 delta，無蒸發/msg 誠實；`_test_join_request_cap_capped` 覆蓋。
- **A-1 記名招募在主場景 TextUI 死路**（高，stage2 核心迴路斷）。`recruit` 回 payload menu(has_willing_named/anon_available)，但 `text_ui_main.gd` team-target handler（916-977）不消費此 menu，只 `_log_event` 後清 target。`recruit_named` 唯一路徑 `execute_action_with_target`（member-kind）text UI 從不呼 → 記名招募完全不可達。功能寫在停用的圖形 `main.gd`（show_recruit_panel:115-142）。`recruit_named` 不在 registry → `_test_action_ui_coverage` 抓不到。修向：把 recruit menu 消費搬進 text_ui_main。
- **C-1~C-6 ✅ 2026-06-16 brainstorm 重frame + 實作（merged 81e245b）**。走查發現原框架混淆「NPC task(AI 抽象)」與「玩家能力(直接動作)」——玩家直接控,不需持續 auto-task,真對稱=動作 parity（見 spec `2026-06-16-player-action-parity-design.md`）：
  - **C-1 設自隊 task → 砍掉**（玩家不要 auto-task,reframe 非缺口）。
  - **C-4 訓練/升 tier ✅ 做**（`_action_train` 一次性 coin→add_exp+try_promote;玩家版比 NPC 完整,NPC 無 promote tick caller=W4）。
  - **C-2 紮營 ✅ 做**（`_action_camp` Y版:免材料/無即時糧/距離spacing/限時施工）。
  - **C-3 覓食 ⏸ 擱置**（冗餘 hunt/hunt_beast,YAGNI）/ **C-5 pacify ⏸** / **C-6 settle ⏸**（niche/階段3 過早）/ **主動投靠 ⏸**（邊緣）。
  - **副產**：玩家主隊被恐慌橋寫 task=逃跑（latent,未實際劫持移動）→ 加守衛 ✅;「任務:」label→「狀態:」✅。
- **NPC crude_camp 即時糧 ✅ 量測+移除（2026-06-16）**：A/B（種子糧 ON vs OFF）2yr×4config → died 兩者皆 0、pop 相當（±噪音）→ 即時糧**非 load-bearing**（NPC 不靠它免死）。移除即時糧（`faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） 刪,保留抬 cap）恢復絕境稀缺,與玩家紮營版一致。

### Q7 QA批（2026-06-18 QA session harness 遍歷 + forced/encounter 動態驅動抓）→ **全 6 項 ✅ 修（2026-06-18）**
> 既有 37 harness 斷言全綠但漏抓——`_test_action_ui_coverage` A-baseline 只驗「靜態覆蓋圖存在」非端到端可走。動態驅動 forced-event/encounter 才現形。
> **✅ 修復**：Q7-1+Q7-2（forced-event 三聯單一源化 + choose_heir/aid_request，spec `2026-06-18-forced-event-single-source-design.md`，致命 softlock 解、雙重端到端驗）；Q7-3（戰利品文字 UI take_loot/leave_loot）；Q7-4（promote_anon 拔擢 anon→named，復用 generate_for_team，全 anon 隊可派子隊）；Q7-5（子隊派遣開放任務選擇）；Q7-6（faction 設定鈕 gate leader）。全 headless+ui_flow+multi 綠、coin_eq=0、invariant 0。
> **待議**：promote_anon 無 coin 成本（純拔擢，treasury 走 generate_for_team 內建守恆）；如要對玩家收費另議。

### Q8 QA 自檢批（2026-06-18 Q7 修後重掃，驗證 Q7 關閉 + 新落差）→ **N-1/N-2/N-3 全 ✅ 修（2026-06-18）**
> Q7-1~6 **六項全端到端驗證關閉**（含邊界）。新發現 3 項殘留已修：
> **✅ 修復**：N-1（子隊面板無 candidate 但有 anon 時引導去 promote_anon，補 Q7-4 發現性）；N-2（choose_heir 重查活候選不吃 stale 快照,單一 stale→重選,全死→`_handle_player_leader_death` 終局,修永久 leaderless;N-2 用 `fe.team_id` 解隊因 player_id 指向死 leader）；N-3（camp/train available_actions 補真 gate:camp `_check_distance`、train coin>=TRAIN_COST_COIN,gate 通過仍可達）。全 headless+ui_flow+multi 綠、coin_eq=0、invariant 0。
- **N-1 全 anon 隊子隊面板死路不引導 promote_anon**（中，A/B）。`_build_subteam_str`(text_ui_main:1683) 顯「（無：需命名非 leader 成員）」但不交叉引導去互動選單「拔擢匿名→記名」(Q7-4 的 promote_anon)。功能可達但發現性差 → Q7-4 半殘。修向：subteam 面板死路時提示「先拔擢匿名成員」或直接內嵌入口。
- **N-2 choose_heir 候選 raise→select 窗內死亡 → 隊永久 leaderless**（低，B）。`respond_to_forced`(player_command:918) 對 stale heir 失敗仍無條件清 forced、不重 raise；`get_forced_response_options` 讀 `forced.candidates` 快照非重查活 named（responses 以 fallback 名列死者）。非 softlock（forced 有清）。修向：respond 對 stale heir 失敗時重查活 named 重 raise，或 game_over。
- **N-3 camp/train 恆列即使 command 會拒**（低，B 顯示）。`_build_available_actions`(player_query_api:445/454) 只查粗 gate(anon>0)，未查 coin/`_check_distance`；camp label 未標成本門檻。選後才 reject。屬 gate-display 類（部分已知 Q7-6 同類）。

### 🆕 vision-dist 測試 FAIL（pre-existing，Q7 work 期間確認）
- `ui_logic_test.gd` 有 2 個 `team0 看不到 team1/team2 (dist=1/2)` FAIL，**Q7 前 main 即存在**（非新引入）。屬視野/距離可見性測試與實作不符——待查 VisionSystem 門檻 vs 測試期望（或測試過時）。低優先（不影響主流程,headless/ui_flow/multi 全綠）。
- **Q7-1 `choose_heir` 無選繼承人 UI → forced_event 永不清 → 世界永凍**（🔴 致命 softlock）。玩家 leader 餓死/戰死（`faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）/`health_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） 真觸發）→ `_process` 進互動模式 → `forced_interaction.responses` 只有「拒絕」（候選人沒出現）→ 按下 `resolve_forced_response` 驗 `get_forced_response_options(choose_heir)` 回 `[]` → `invalid response_id` → forced_event 不清。且 `sim_runner:99-100` 明確把 choose_heir 排除超時自動清除（設計凍世界）→ **玩家永遠選不了繼承人,世界永凍**。根因：`PlayerApiMapper.map_forced_interaction()`(player_api_mapper.gd:266) `match action` 無 choose_heir 分支→落 `_` fallback 只給拒絕；`get_forced_response_options()`(player_command_system.gd:834)+`respond_to_forced()`(:849) 也無 choose_heir（它走獨立 `_action_choose_heir` 需 `player_state["heir_id"]`,但 UI 無路徑設 heir_id/列候選）。
- **Q7-2 NPC 乞食玩家(`aid_request`) 無「給予」UI → 玩家只能(超時)拒**（高,破對稱）。注入 `aid_request` forced(`interaction_system.gd::_resolve_aid_request()` NPC 對玩家乞食真觸發)→ responses 只「拒絕」→ 按下同 `invalid response_id`→`sim_runner.gd::_advance_tick_body()` 一 tick 後超時視同拒。`respond_aid_request` 是 registered action(含 give_amount/守恆/reputation 全套) 卻**無 UI 觸達**。根因同 Q7-1（三聯缺 aid_request 分支）。**Q7-1+Q7-2 同源,可一 plan 修。**
- **Q7-3 文字 UI 戰勝無 `take_loot` 路徑 → 戰利品憑空丟棄**（中高,A+B）。玩家贏遭遇戰→`encounter_view.gd::_post_combat_hint()` 算 loot_pool 存 last_encounter_result。戰後 `encounter_view._post_combat_hint:569` 只 `[J]收編`,無 take_loot/leave_loot（encounter_view grep 0 命中）。功能只圖形 `main.gd:184` 接線→文字 UI(主測 UI) 打贏拿不到戰利品。
- **Q7-4 玩家無「升 anon→named」command;全 anon 隊無法派子隊**（中,C 對稱）。NPC `person_generator.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）/`faction_ai_system.gd::_dispatch_subteam_settle()` 缺 named 時自動拔擢 1 anon 為 named leader(帶 treasury×3);玩家無對應。`_action_dispatch_subteam`(player_command:531) 硬要 `sub_leader_id ∈ persons`→全 anon 隊 `dispatch_candidates` 空→`「無可用隊長」`。
- **Q7-5 子隊派遣/下令 UI 寫死 `TASK_IDLE`**（低,A）。`dispatch_subteam` command 支援任意 sub_task,但 UI(text_ui_main:1534,1589) 只給 IDLE→玩家只能派「移動」子隊。
- **Q7-6 faction 面板對非 leader 顯示設定鈕但 command 拒**（低,B 誤導非 crash）。`_build_faction_str`(text_ui_main:1282) 對所有成員列 `[A]設定目標 [B]徵收率`,但 command 要 leader→非 leader 按了 reject。
- **OK 項（非落差）**：37 harness 斷言全過;hunt/train/camp/recruit_named/equip/trade/storage/outpost/extract happy-path 觸達+state 變正確;互動分頁索引一致;對稱已 OK:beg/camp/build_outpost/train/recruit。

### W4. Faction leader 行為性貧窮 — 建造解鎖極慢 ⚠ 部分修（2026-06-13 economy-bootstrap）
- **症狀**：2 年 multi 派建造子隊 = 0；失敗原因 log（本批新增）顯示全是 material < cost×1.5（leader material +0.2/day 涓滴，門檻 75 要爬數年）
- **根因**：leader team 常駐外面（迎戰/乞食/逃跑），不在 outpost tile → collect 收入 0；material 只靠稅/貿易涓滴
- **修（部分）**：faction leader 補「治理」回家路徑（公庫<75 + 不在家 + idle → 回家攢公庫）；自給階梯讓無 tools faction 先蓋民村→工坊→產 tools→後期軍鎮
- **驗證**：2 年設施完工 2→4（merchant 自然長出 workshop）；但限**常駐型 leader**（merchant）有效
- **遺留**：遊牧軍閥 leader（tyrant/warzone 好戰高）永遠在外迎戰，從不 idle 在家 → 治理觸發不到、建造仍 0。需 leader 駐留行為 spec（強制週期回防/或建造資金走 faction 共同出資）才能根治

### Bug2. salary 拖 coin 無下限
- **症狀**：integration test merchant min_coin=-49 / warzone min_coin=-42（90 天）
- **根因**：salary 系統發薪前不檢查 coin >= 0；新團 `[Split]` 出來特別易負
- **影響**：經濟守恆破，新生團體永久赤字
- **發現**：2026-06-09 integration test
- **驗證（2026-06-15）**：**floor 已修**——`salary_system:65/75` 已 `maxf(coin−paid, 0.0)` → coin 不再為負。
- **驗證（2026-06-16，原「欠薪後果未做」= stale）**：欠薪後果鏈**其實已有**——減薪→掉忠誠（`salary_system.gd`（★L2 錨：檔級） `loyalty -= (1-ratio) × SALARY_LOYALTY_PENALTY`）→ 低忠誠/高壓觸發 reaction `N3_defect`(`:259`)→`_anon_actually_left`(`:269`) 真離隊。**功能完整**。剩「anon 補充停」屬邊緣低優先（budget_ratio<1 時 anon 薪自然少，已部分反映）。
- **狀態**：負 coin ✅；欠薪後果鏈 ✅（已存在,非缺）；anon 補充停 = 低優先邊緣 tune

---

## 🟠 中優先（影響遊戲合理性）

### S4. 人口分裂太快
- **症狀**：main.gd 開局 3 team，tick 10 開始自動分裂，tick 30 已有 10+ team
- **根因**：PopMgmt 分裂條件觸發太容易；10 人就能分裂出子隊
- **位置**：`scripts/simulation/population_system.gd`
- **勘誤（2026-06-15）**：描述過時。現 population_system 無「pop10 分裂」,改 **overflow-based**(`check_overflow`/`_create_overflow_team`,超 cap 才溢出建團)。且症狀指 graphical `main.gd` 開局 = **moot**(TextUI 為 `main_scene`)。如仍嫌溢出太快屬另議 tune。

### S5. main.gd test setup 無 outpost → 12.5 天必定斷糧
- **症狀**：300 food / (10人×0.1/tick×24tick/天) = 12.5 天；斷糧後人口死亡，UI 失效
- **根因**：`collect_resources` 只採 outpost 格，test setup 沒建 outpost
- **位置**：`scripts/ui/main.gd`（test setup）
- **建議**：加初始 outpost，或大幅增加初始食物（如 10000）
- **勘誤（2026-06-13）**：症狀數字（0.1/tick×24）為 2026-05 舊 prototype 行為；現行 burn 為 `FOOD_PER_PERSON_PER_DAY=2.4`/人/天，斷糧後的人口死亡鏈已由 2026-06-13 famine-death spec 補實（團級 famine_days minor/anon 耗損 + named hunger→blood 餓死，grace 7 天）。

### U4. 地圖移動後有時消失
- **症狀**：移動幾次後地圖變黑、旗子消失
- **根因**：player person 因食物不足死亡 → `player_tid=-1` → `discovered=[]` → 地圖全黑
- **連動**：S5（食物）是主因；player 無死亡保護是次因
- **勘誤（2026-06-13）**：「player 無死亡保護」為 2026-05 舊 prototype 行為；現行 famine-death spec 下，玩家 leader 餓死（blood=0）走既有 `_handle_player_leader_death` → `choose_heir` forced event（凍結世界等選繼承人），非靜默 `player_tid=-1`。地圖全黑殘留問題如仍存在屬 UI 層獨立議題。

### U5. 右側欄資訊不完整
- **缺少**：玩家 HP（body_parts 狀態）、attributes/values、skills
- **缺少**：team 完整資源列表（只顯示部分 key）
- **缺少**：faction 狀態（隸屬、等級）
- **位置**：`scripts/ui/right_sidebar.gd`

### U6. 圖塊資訊只有地形
- **缺少**：tile.resources（food/material/ore 庫存量）
- **缺少**：地形速度減益係數（plains 1.0 / forest 0.7 / mountain 0.4）
- **缺少**：outpost 類型/等級/擁有者
- **缺少**：harvest_factor（農業效率）
- **位置**：`scripts/ui/bottom_bar.gd:show_tile_info`

### Bug8. _test_on_team_extinct_to_storage 失敗 = stale test（非碼 bug）
- **症狀**：headless `food 應進公庫` assert 失敗
- **驗證（2026-06-15）**：**非碼 bug,是測試過時**。W6 重構後 `_on_team_extinct` 只標記 `teams_pending_erase`,實際路由延到 `cleanup_extinct_teams → _route_extinct_assets`(邏輯正確,進公庫)。測試只呼 `_on_team_extinct` 沒呼 `cleanup_extinct_teams` → 路由沒跑 → assert 失敗。
- **修**：測試加呼 `fai.cleanup_extinct_teams(state)` 再斷言。assert 值(50 food/30 coin)正確,「勿動」誤解除——值對,只缺呼全路徑。無守恆風險。

### U19. 強制事件無選單 → 卡死（H, blocker, 2026-06-14 run-verify 新發現）
- **症狀**：強制事件（乞食/繼承/勒索回應等）觸發但畫面無選單，一直卡（choose_heir 還凍世界）
- **根因**：`text_ui_main._process`（154-160）pre_encounter/encounter_active 有自動進模式，**一般 `forced_interaction` 無對等自動進選單** → 只顯「⚠強制事件」hint，玩家無從回應
- **修向**：`_process` 偵測 `forced_interaction` 非空 → `cancel_advance` + 進 forced-response 模式（仿 pre_encounter）；新 `_forced_mode` + handler 列 `forced_interaction.responses` 供選

### U10b. 全 Team 死亡直接退出（edge，2026-06-14 run-verify）
- **症狀**：遭遇戰中玩家全隊死亡 → 直接退出（應走 game-over / choose_heir）
- **修向**：encounter 結算偵測玩家隊全滅 → 接 `_handle_player_leader_death`/game-over，非靜默退出。低頻 edge

### U11b. 戰報 label 未顯（U11 修了但 GUI 沒出，run-verify）
- **症狀**：`_lbl_log` 戰報已加+wire（query_encounter_log）但玩家戰鬥沒看到
- **疑因**：encounter_log 玩家戰鬥未填 / facade 回空 / label 被佈局擠出。需 GUI 查
### U12b. 交易仍跳無資源（U12 direct preview 修沒對症，run-verify）
- **症狀**：互動→交易仍誤判。direct preview 加了但 text_ui trade 流可能仍走舊 path
### U13b. 裝備穿脫僅玩家，NPC named 成員無入口（run-verify）
- **修向**：member 面板加成員 equip/unequip（equip_item slot 已支援,需 member-target UI）
### U14b. 主畫面看不到自 team 武裝數（U14 reframe + U18，run-verify）
- **症狀**：玩家想在平時 UI 看自隊武裝 anon 數,非進場後。併 U18（武裝 anon 指令）+ status 顯 armed 數

### U18. 玩家無法武裝 anon（UI/指令皆缺）
- **症狀**：找不到 UI 武裝匿名兵
- **根因**：`armed_anon_ratio`/`equip_order` 由 `faction_ai` 為 NPC 自動設，**玩家無指令**（grep `player_command_system` 空）→ UI 自然無入口。同 S9 調薪類缺口
- **修向**：補 `player_command_system` 設 armed_anon_ratio/equip_order 指令 → 再上 UI。屬 P3 全動作覆蓋前置（sim 側缺口）
- **優先**：M

### U9. 圖形 Main.tscn UI 仍 reach-through raw WorldState（邊界債）
- **症狀**：`main.gd`/`encounter_view.gd`/`popup_layer.gd`/`debug_bar.gd` 大量 `_bridge.get_state()` 直讀 raw `WorldState`（body_parts/units/world.current_tick）→ 違反「UI 只經 player API」invariant（2026-06-14 新增）
- **狀態**：text_ui 已清（P1）；圖形 UI 未清。text-UI-only 階段不影響
- **優先**：M — 若推圖形 UI 或全面套 UI 邊界 invariant 才需解耦（範圍大,涉 encounter tactical view）。另案

### W8. coin 鑄造實機罕見 — 鑄幣**機制 ✅ 已存在且守恆**，缺實機觸發（2026-06-19 G1a 更正）
- **機制 ✅（G1a 驗證）**：鑄幣鏈**完整且守恆**——world_gen 放金銀礦 → resource harvest 進 `public_storage` → `OutpostSystem._tick_mint` ore→coin（`GOLD_TO_COIN_RATIO=20`/`SILVER_TO_COIN_RATIO=5`）→ `tick_all` 已 wired。`_test_mint_conserving`（headless）證 coin_eq delta=0。**非機制 bug**。
- **先前誤判更正**：原「coin 鑄造Δ=0 = 產出鏈完全休眠」≈ **無觀測 log 致錯覺** + 實機建造罕見。`_tick_mint` 現已加 `[Mint] tile(x,y) ore→coin +N` log（觀測藍圖 §12「coin 被鑄 Δ>0」）。
- **殘留（屬經濟平衡, 非機制）**：實機 NPC 罕採金銀 ore / 罕蓋鑄幣廠 → coin 生成稀 → 經濟偏零和集中（贏家集中、窮團翻身路弱）。此為**建造/經濟平衡**問題，另案。
- **不破壞**：減薪=0、無死、世界穩（coin 對生存非必要,團跑 lean 仍活）。
- **修向**：實機鑄幣頻率 = 平衡 / **G1c 需求驅動生產**接上後再觀察（需求迴路驅動蓋鑄幣廠 + 採礦）。屬經濟深度玩法層。
- **優先**：M（機制已綠；頻率待 G1c 後量測）。

### W7. 覓食 vs 乞食 仲裁（forage-foundation 遺留）
- **症狀**：`_find_forage_tile` 周圍無食物時仍回本格 → 小隊（pop≤15）恆覓食、不到乞食 Path4。枯竭區小隊空覓而非乞食富鄰
- **狀態**：2 年 multi 實測世界穩定（died=no、未顯退化）→ **暫不動，留量測**。主 session 曾試加 `best_food` 門檻使無食物回 -1,-1，但會弄紅 3 個依賴「urgent→SURVIVAL_TASK」的 baseline 測試（那些測試 setup 無食物 tile）→ 還原。要修需同步重整那批測試語意
- **優先**：L — 量測顯問題再開

---

### Bug5. DiplomacyAI demand_tribute 恆負
- **症狀**：90 天 120 次 evaluation，分數恆 −0.15（power_r=0.40, caution=0.80, pride=0.50）
- **根因**：caution=0.80 權重壓制 score 恆 < 0；同一決策每次重算同值
- **影響**：強者不勒索，AI 過保守
- **發現**：2026-06-09 integration test
- **結案（2026-06-15 量測）：非缺陷,原症狀誤判。** 經 warzone 整場量測:
  - **NPC demand_tribute 發起 = 0 次**。收方公式(`:129` `d_score=(power_r−1)×0.4 + caution×0.3 − pride×0.3`)其實**正確**——拒絕弱者勒索合理。舊「score 恆 −0.15 過保守」= 把正確的收方行為當 bug(−0.15 正是 power_r=0.4 弱者來勒索的應拒值)。
  - 真實狀態:**NPC 勒索機制休眠**。唯一發起點 `diplomatic_ai_system.gd::try_proactive_diplomacy()` 被三重掐死:早 return(score>0.6 結盟/>0.4 貿易先返)、U20 同格 gate、**方向反**(`power_gap>0.5`=other 較大才發 → 弱勒強 → 必拒)。
  - **不破壞任何東西**(世界穩),屬休眠機制非 defect → **關閉**。要活化 NPC 勒索 = 設計題,見路線圖。

### W3. BREAKOUT_DIST / ENCIRCLE_DIST tune
- **症狀**：常數調為 2/1 適配 radius 4 測試地圖；正式地圖 radius 可能不同
- **發現**：2026-06-10 NPC wakeup
- **建議**：改 `min(N, map_radius)` 動態計算

### W4. NPC 不主動 promote / train ⚠ 部分修（2026-06-16）
- **症狀**：multi 90 天 tier promotion = 0；戰場升等 0（因 0 combat），訓練 task 0 派
- **根因（兩層）**：(1) **promote tick caller 缺**——`training_system` 只 `add_exp` 從不 `try_promote` → 即使 TASK_TRAIN 累積 exp 也永不升階;(2) NPC AI 鮮少選 TASK_TRAIN。
- **修（2026-06-16，層1）✅**：`training_system.process` 補 `try_promote`（count=1 迴圈升到不能升）。headless `W4 NPC 訓練升階 OK`、warzone sanity 世界穩。**機制活化:NPC 一旦訓練即會升階**。
- **遺留（層2）**：NPC AI 決策仍鮮少選 TASK_TRAIN（faction_ai 無 promote/train 評估邏輯）→ 實戰升階量仍低。要常態升階需 faction_ai 加 leader 個性 + 物資自動評估 train。低-中優先，接戰場 exp（W1）成熟後一起 tune。

## 🟡 低優先（體驗問題，不影響可玩性）

### U7. Camera 每 tick 強制回正
- **症狀**：每次推進 tick，鏡頭自動對齊玩家，無法保持手動視角
- **根因**：`refresh()` 每次呼叫 `_center_on_player()`
- **建議**：改為只在玩家移動時重置，或加 C 鍵手動回正

### U8. Members/History popup 待確認
- **症狀**：按成員按鈕可能不顯示 popup（已加 print debug，尚未確認）
- **位置**：`scripts/ui/popup_layer.gd`

### D1. SoloAI 保護條件脆弱 ⚠ 部分緩解（2026-06-15 驗證）
- **症狀**：`team.leader_id == state.player_id` 在子隊分裂後可能失效
- **根因**：subteam 分裂可能重新指定 leader_id
- **位置**：`scripts/simulation/faction_ai_system.gd:_evaluate_solo`
- **驗證（2026-06-15）**：部分點已加 `named_members` fallback(`:1049` `leader_id==player_id or player_id in named_members`)+ player_id≠−1 守衛(`:141`)。但 `_evaluate_solo`(`:907`) 仍只查 leader_id → 邊緣仍脆。低優先。

### A1. agent_repl stdin 模式 stdout 污染
- **症狀**：stdin 模式下模擬 `print()` 混入 JSON Lines stdout，污染協定
- **根因**：GDScript `print()` 寫入 stdout；stdin REPL 與模擬 print 共用同一 fd
- **影響範圍**：僅限 stdin 模式（Windows headless 走 TCP fallback，實際不受影響）
- **位置**：`scripts/debug/agent_repl.gd:_run_stdin_loop`
- **建議**：加 `--quiet` flag suppress 模擬 print，或在 stdin loop 前重導向 print 到 stderr

### S9. 玩家 team 名 NPC 薪資 UI
- **症狀**：玩家無法調整 named NPC 薪水，預設 0 → 自然扣 loyalty 直到叛逃
- **設計意圖**：玩家管理 loyalty 的關鍵手段（過薪換忠誠）
- **建議**：team panel 加每個 named NPC 薪資設定，顯示「目前 / 公平」比值

---

## Movement

- **★far 區移速稀釋 10×（世界模型級,2026-07-04 貿易漏斗定罪,裁權=藍圖+系統合裁：修法 HOW 我有,但世界節奏×10=平衡意圖 WHAT+gen 重校=藍圖題,已報 `systems-to-blueprint-lod-carrier`）**：`movement_system.process` `move_tick_acc += TICKS_PER_HOUR` 硬編,但 far 區每 `FAR_ZONE_INTERVAL`(100 tick) 才跑一次 → far 隊 1 hex≈3 天（10× 稀釋）。無玩家世界**全隊=far** → 跨格物流全癱：**envoy 馬鏈 6 月未貫通 + 貿易旅程永不到場同根**（藍圖「一修雙解」假說 ✅ 實測定罪）。姊妹系統（collect/consumption）皆傳 elapsed,唯 movement 不一致；違「大地圖與遭遇戰共用時間尺度」invariant。**修法已驗**：process 收 `elapsed_ticks` 參數（near=NEAR_CADENCE、far=FAR_ZONE_INTERVAL）→ seed1337 6 月成交 6→30、TRADE 到場 0→43(33.9%)——**但世界節奏×10 → pop 172→68(-60%) 塌房=gen 校準全失效** → revert,修須配套節奏重校準（FAR_ZONE_INTERVAL/移速常數/gen 參數一起裁）。diff 見 handback `2026-07-04-trade-loop-ignition`。
- **★default 世界無 carrier（TAG_MERCHANT=0 兩 seed 全程,2026-07-04 貿易軌揭,藍圖題）**：跑單主體只有商 archetype 流浪隊（6-17 隊,多數 survival rung 自顧不暇）→「商隊完整弧（接單→出發→到場→成交）」在 default 缺主體,商隊 funnel `deal_merchant=0`。貿易域內修已到頂（成交 16/5 全 resident 村攤互售,非跑單）。修=gen 產商隊隊 or 既有隊晉升 TAG_MERCHANT 的路=藍圖 WHAT。與 LOD 稀釋並列=貿易「數十+肉眼可見」兩塊域外缺口。已報藍圖。
- **市集成交不 emit 觀測事件（2026-07-04 ticker-dump 揭,觀測缺口）**：`_resolve_market` 成交無 emit_message/emit_ambient → ticker 流零 deal 事件（訂單洪流無成交回音）=「感覺沒在貿易」的機器可讀證據,但也遮蔽真實成交。修=成交點 +emit_ambient（小,觀測用,勿進 global_messages 擾 oid）。非本 scope 備查。
- **★★沙盒憲法違憲清單（2026-07-05 稽核,統一矩陣收斂主軸）**：引擎(DecisionEngine)存在正確但只 wire `uses_unified`(TAG_MERCHANT/PRODUCE)+全隊 survival;8 個歷史舊平行 subsystem/判斷器繞引擎(違憲)：①threat `_evaluate_threat`(faction_ai:358,引擎已有 threat_pressure term 純重複,先溶)②`_evaluate_solo`(1749,平行第二決策引擎)③`ambition_ladder.rung_task`(105,查表判斷器)④vendetta(771,feud_pull term 未掛)⑤prosperity_attack(244,gate cascade)⑥faction dispatch `_assign_tasks`/`_assign_member_tasks`(1392/1465,goal→task if/elif=V2-cmd 征服 shadow 那條)⑦ReactionSystem(112,完整平行行為引擎,最難拆行為 vs 情緒後果)⑧灰項 dispatch(select_strategic_intent/diplomatic/strategic trade_net)。核心=擴 uses_unified 全隊+併 option 入 REGISTRY。零例外驗 PASS(絕境引擎內支配/遠方疏非笨)。=多 slice arc(續 project_unified_decision_framework);V2-cmd shadow=序⑥副產品。報藍圖 `constitution-audit` 待裁修序。憲法閘 arc 尾立(現碼未溶前全 fail)。**★★2026-07-06 全溶完（序1-8 全 merged）**：①threat→rank_threat(804432e)②solo→rank_scored(f7ce320)③rung→ambient weight(50dc86f)④vendetta→feud_pull option(2506e6e)⑤prosperity→攻擊 option+scout scaffolding(16ab3bc)⑥dispatch→成員_decide_unified,V2-cmd 自消(2b4a427)⑦reaction→panic-flee 溶 survival+9反應保 consequence(2edf120)⑧灰項 trade_net 刪(57f7d39)。+序3.5 threat-preempt(4afbcaf)。憲法閘現鎖 30 sites 全保留 scaffolding。**arc 尾待撤 pre-commit 轉全掃常駐。**
- **commander 征服 directive→成員攻擊路 0 貢獻（2026-07-05 V2 measure 揭,🟡未知探針 follow-up；★併入憲法違憲序⑥）**：sufficiency V2「征服脊椎斷」measure 定為假陽性（率表舊探針 conq.intent=unified-only by construction 空;征服行為真 fire=獨立 prosperity 路 attack 2/捕俘 3/同化 2）。但修正列 feasible=0（新 `conq.member_atk_eligible`=0）：established faction commander 選征服 1529 次、`_emit_goal(攻擊)`,成員 faction_goal 攻擊路(faction_ai:1486)**實派 0**。待 probe 分辨：**死碼**（成員無 攻擊 tag-weight→1486 branch 永不取 or driver 檢查 miss）vs **只 2 established faction 太少沒觸發**。非阻塞（征服有獨立路）。修向待 measure。
- **非 order 類訊息無消費 chokepoint（2026-07-04 率表軌揭,結構性缺）**：率表「消費/送達」只有 order 類（board_read）有分母,其餘 msg 類決策讀取無 mark 點 → 消費率量不到。補=決策讀 message 時 mark（機制擴,後續軌）。
- **mounts/wagons 速度**：⚠ 部分修（2026-06-15 驗證）。`_compute_team_speed`(`movement_system.gd::_move_cost()`) 現已 `× _compute_mount_bonus(team) × _compute_wagon_penalty(team)` → mount 加速、wagon 拖速**已有**。
  - **遺留**：speed_class（步兵/騎兵/輜重分類）仍缺——同隊內騎/步未分速,只算隊級平均 bonus。完整 unit-level speed_class 待 spec。
  - **發現**：2026-06-10 combat-engagement；2026-06-15 驗證 mount/wagon bonus 已實作

## 待 spec（按優先排序）

| 優先 | spec | 解的問題 |
|---|---|---|
| **H** | NPC 會合/攔截 | W1 + W2（0 Combat / 0 Trade）|
| **M** | mount 公庫系統 | mounts 改為 outpost public_storage（採集 / stable 產出 → 公庫，team 出征前 withdraw）；同時加 outpost 鄰格 wild_horses 自動採集 |
| **M** | 設施改制 B 期（材料層）| herb / 野馬群 圖塊資源 + 戰馬/野馬分離（民用馬廄馴野馬、軍用馬廄練戰馬）+ wagons 合成（野馬+mat+tools）+ medicine 配方接 herb。依賴 A 期 spec：2026-06-12-facility-overhaul |
| **L** | 信用貨幣（勢力券）| 各勢力自行發行、互不承認；coin 維持硬通貨總量固定。等 slot 專業化讓貿易量起來（C 期驗證）後再做。敘事接點：金銀挖完 → coin 通縮 → 勢力發券的歷史動機 |
| **L** | 新礦發現事件 | 低頻事件：tile 探出新礦脈（每脈有限量）— 後期擴張動機 + 淘金熱戰爭誘因，不破壞稀缺性 |
| **L** | 裝備回收鏈 | 戰損裝備 → 廢鐵 → 折損重煉（80%）。只在未來引入「銷毀事件」時才需要（守恆審計後現無銷毀）|
| **L** | goods 消費 sink | goods 目前純財富品無功能消耗；後續可加奢侈品 → named loyalty/滿足加成 |
| **L** | 子隊居民團 leader 留/回個性評估 + 合併 | outpost-residency-ai (ii) → (iii) 升級：流民駐紮後子隊 leader 個性決定留下（合併或共處）或回母團 |
| **L** | Residency dispatch print spam | NPC AI 派子隊到 outpost 後 sub pathing 失敗 / 母團 mobile，子隊未 settle → outpost 仍 missing resident → cadence 重派；in-flight check 在 sub task 被改 idle 時失效。invariant 過，但 print 多 |
| **M** | 人口循環受窮困抑制 | minor 長大簡版已實作（每月 10% → 平民，2026-06-12）。但 multi 90 天 0 次長大：reaction 收斂後世界窮 → P5 生育的糧食盈餘條件（>7 天份）幾乎無人達標 → 無小孩可長大。需 harvest/初始糧 tune 讓富裕村能生。完整人口結構 spec（性別/生育年齡）仍待 |
| **M** | task 優先權仲裁（Spec A）| current_task 被 5+ 系統互蓋（reaction bridge / faction goals / strategic dispatch / threat / survival），白名單散落。設計已討論（優先表 100 戰鬥/80 存亡/70 威脅/60 玩家/50 派遣/30 勢力/10 閒置 + 每層釋放條件），待 reaction 收斂後實作 |
| **M** | trade 三層問題殘餘 | TASK_TRADE 加入 faction_ai:660 exclusion（1 行）；trade partner 改限「tile 上有居民團」；DiplomacyAI reject cooldown；Equip print diff check |
| **M** | unrest / 抗命 玩家可見性 | unrest 完全沒露出 player API/UI。自家 team → team_stats 加欄位；同 faction → intel unrest_est；外人 → 躁動傳聞 message。[抗命] 事件玩家通知。等 UI batch |
| **L** | NPC 對 NPC 抗命 | arbiter 抗命窗口只開「50 挑戰玩家 60」；NPC leader 對 NPC 上級命令的抗命（50 vs 50 個性判定）後續另議 |
| **M** | encounter-engagement 後續 | 攔截方反追（prey 預測 attacker）；戰報廣播；玩家版反應 UI |
| **H** | salary 欠薪後果 | Bug2 |
| **M** | NPC promote/train AI | W4 |
| **M** | DiplomacyAI 平衡 | Bug5 |
| **M** | multi runner schedule 注入 | Bug6 |
| **M** | 戰場 mount unit-level | encounter 騎兵 unit + 衝擊 + 機動 + 戰場死亡（mounts/wagons spec 後續）|
| **L** | mount 細分 | 戰馬/馱馬/拉車馬；輕車/重車；草地補糧；城市買飼料 |
| **M** | named 升階機制 | anon tier spec 列後續 |
| **L** | tag drift | leader / event 改 tag |
| **M** | 團 vs 團突襲優勢 | 對稱：野獸伏擊已實作（AmbushSystem，2b-2）；團對團伏擊待做 — reuse `vision_system` 偵測（潛行降 exposure / 偵查偵測）+ 攻擊方未被偵測 → 首擊/陣位優勢 + 激活 dormant `_check_night_raid`。屬階段2+ 劫掠/戰團。**注意：團伏擊用 vision 偵測，非 beast 專屬 AmbushSystem** |
| **M** | AI 目標錨（策略延續②深層） | SoloAI 承諾慣性（solo_intent 加成，spec soloai-proactive-home）止短期 flip-flop；更深的「持久 goal 錨」（隊有慢變長期目標如稱霸/安身/致富，task 選擇朝 goal-aligned 跨多 tick）= 接 dormant `npc_ai.get_goal_task_override`。**先量測承諾慣性夠不夠再做**。**極克制 — 一個慢變 goal 欄位+偏好加成，非多層規劃器**（防戰略引擎無底洞） |
| **M** | 山村採礦換糧特化經濟 | 山地 food regen 低（種田餵不飽），真實山村靠採礦/畜牧→交易換糧（進口糧）。現食物模型只「收本地糧」→ 山村必餓。需缺糧村自動 trade ore→food / 進口糧 AI。階段3+ 經濟深度。現階段 explicit 村用 `outpost.terrain` 釘可農地規避 |
| **L** | 戰俘處置 | 賣/屠/招降 |
| **L** | 外交招募 / 雇傭軍 | 直接買高 tier anon |
| **L** | anon tier UI | team panel / 升等進度 / 死亡分檔 |

---

## 🟡 代碼健康批（2026-06-18 研究 session 審計，非阻塞·維護性債）

> 不變量架構（cohort/faction/subteam/erase）已乾淨。以下為**重複值 / smells / 缺抽象**，改一處其他 drift 的風險。

### 重複值 / magic numbers
- **[高] `FOOD_PER_PERSON_PER_DAY = 2.4` 獨立定義 3 份**：`resource_system.gd:3`(權威) / `player_api_mapper.gd:156` / `faction_ai_system.gd:45`(`_SURVIVAL` 名同值)。部分點正確引用 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`,部分用本地副本 → silent drift 炸彈。修：留一份,其餘改引用,刪副本。
- **[高] tier 字串「平民/新兵/老兵/菁英」全專案硬編碼**,不引用 `AnonTierSystem.TIER_ORDER`：encounter:1250 / player_command:190,198 / training:22 / beast:32 / population:21 / recruit_tutorial:22 / game_setup:340。修：非迴圈處用 `TIER_ORDER[0]/[-1]` 具名索引或加 `TIER_PLEB/TIER_ELITE` const。
- **[高] `TIER_ORDER` 兩處各一份**：`anon_tier_system.gd:7` 與 `anon_cohort.gd:6` 內容相同。修：擇一為源(建議 AnonCohort 更底層),另引用。
- **[中] task 字串「安頓/安撫/乞食/投靠/return_home」無 TASK_* const**：team_data.gd:3-22 有 TASK_* 塊但缺這幾個;散落 interaction:264-290 / faction_ai 多處 / `SURVIVAL_TASKS`(faction_ai:30) 混用 const 與字面。85 處用常數 vs 33 處裸字串 → typo 即 silent false。修：補進 TASK_* 全改引用。
- **[中] `VISION_RADIUS = 3` 三處副本**：vision_system:3 / text_map_renderer:4(註解「與 X 一致」自承耦合) / encounter_view:501。修：UI 引用 sim const。

### smells
- **[高] dead const `TRAINING_CAP_THRESHOLDS`**(anon_tier_system:34-38) 零引用 + `_training_cap`(:232) 硬編碼同 0.4/0.7 門檻。修：刪 dead 或讓 `_training_cap` 讀它(二選一)。
- **[中] 超長函數**：encounter_system `resolve_encounter_end`(186行)/`_decide_action`(150) / interaction `_try_interact`(132) / faction_ai `_trigger_survival`(106)。按分支抽 helper。
- **[低] `resources.get(key,0)` 樣板 99 處(17 檔)**,預設值有的 `0` 有的 `0.0`(型別不一)。可加 `ResourceSystem.get_res(team,key)->float` 統一。

### 架構
- **[中] 資源鍵無單一權威清單**：team_data:52-59 default dict 是唯一全鍵源;weapon/armor 鍵(跨 21 檔 51 處) 無集中枚舉。新增資源得手動同步多處。修：建 `ResourceKeys` 常數模組(PUBLIC/WEAPON/ARMOR 子集)。
- **[中] UI↔Sim 常數靠註解耦合**(見 VISION_RADIUS)：靠「人記得改兩邊」。修：UI 引用 sim const。
- **[中] `_decide_unified` phantom current_option**(faction_ai_system.gd:1487)：`team.current_option = opt` 寫在 `_set_ok = try_set`(1496) 前 → rank winner **dispatch 失敗也記承諾**（違本行註解「追蹤實際派出」原意）。busy 隊被高 util option 贏 rank 但 arbiter 擋不進時，current_option 記成沒做的事 → 下 tick COMMITMENT_BONUS 誤導。A2c-1 高 util 整併 option 首個踩到（量證對征服 immaterial，520→520，故 A2c-1 revert 未修）。修：gate on `_set_ok`（獨立 micro-slice，自己 spec+驗證）。
- **[中] observer dump 月級不可用**(perf)：`--obs-ticker-dump` 實測 warring_states 41 隊 **<12 tick/s**，3 月(21600t) 撞 GODOT_TIMEOUT 1800s 跑不完（純 `seeded_warring_bed` 快得多）。observer per-tick overhead(render/ticker/inspect refresh) 壓垮月級敘事落檔 → **③戲感審計工具在 warring 尺度實質不可用**。修：headless 快路徑（跳 render/UI refresh，純 sim+event 落檔）。併觀測 arc 或另立。
- **[設計限制·未來 slice] merge/join food-blind = survival-inert（2026-07-09 A2c-1 揭）**：`SubteamSystem.merge_teams` 併=pop+資產(含食物)按比例搬進 absorber，**不生食物**；`_find_absorber` 選 absorber 只看 capacity/proximity **不看糧**。∴ 餓隊併入非餘糧 absorber = 多嘴+少糧一起挪，全隊仍餓 → **併對生存零因果**。A2c-1 survival-value 實驗鐵證：逼併回 320(vs fold 154) starve 紋風不動(19)、final 世界逐位元同(36/203/46.7%)。**歸未來「絕境經濟」設計**（藍圖+用戶談中：投靠/整併找**能養的**food-aware 強者 + 饑民→掠奪→職業搶匪湧現）。非 bug=機制誠實，但機制弱。join.resolve 降(fold≤baseline)是此症狀，harmless for shipping。

**前 3 優先**：① FOOD const 收斂 ② 補 TASK_* 全引用 ③ 刪 TRAINING_CAP dead + tier 字串具名化。

---

## 待討論（設計決策）

| 問題 | 選項 A | 選項 B |
|---|---|---|
| S1 視野門檻 | 降至 0.3（保留距離衰減） | 移除衰減，範圍內直接可見 |
| U7 Camera | 每次 tick 回正 | C 鍵手動回正 |
| D2 player 死亡 | Game Over 畫面 | 自動轉移到新角色 |
| S4 人口分裂 | 提高門檻 | demo 期間停用 |


## 決策引擎（non-unified 求生 override thrash → 致死，2026-07-13 蟑螂普查確診 Team10 seed1337）
- **現象**：非-unified 隊絕境(days_left=0)時 task 每 tick 在 `建設↔貿易↔idle` 三者 livelock，從未穩定執行滿週期 → famine 累加 → 滅團（Team10 day89）。血證 `docs/measurements/2026-07-13-roach-scan-team10-thrash-1337.log`。
- **根（補丁閘/dual-owner 類）**：非-unified 隊同 tick 跑**兩個決策生產者**——`_evaluate_solo`(rank_scored，idle 時挑 ambient 建設) + `_evaluate_survival`(:3029 legacy override，缺糧翻成 買糧→貿易)，二者不收斂。unified 隊在 :3046 `uses_unified→return` 跳過 override 故無此病 → **override 是 unification arc 未退役的 legacy 補丁**。
- **加劇缺陷**：`SURVIVAL_TASKS`(:80)=[RETURN_HOME,BEG,JOIN,FORAGE,CAMP] **不含 TASK_TRADE(貿易)**；買糧→貿易 但 survival-latch(:3076-3094 hold+cadence throttle)認不得 貿易＝survival → override **每 tick 無節流重觸發**。（不可 naive 加 貿易 進 SURVIVAL_TASKS＝會誤classify 商隊常態交易。）
- **修向**：de-patch＝非-unified 求生亦走引擎(退役 `_evaluate_survival` override，鏡射 unified :3046-3047)。**decision-core 結構 fix(L1/L2)，需 spec→reviewer→implementer**。定序待用戶(2026-07-13 交接中，見 handback `systems-to-blueprint-roach-team10-thrash`)。關 [[project_unified_decision_framework]]/[[project_reverse_engineering_arc]]。

## 決策引擎（貿易/訓練/囤貨 applicable-vs-target gap，2026-07-13 reviewer 稽核附帶）
- **同型 gap（非阻塞 backlog）**：`貿易`(applicable 用 `has_goods`/`has_arb`) 但 `_merchant_trade_target` 找不找得到市場無關 → applicable 過但 to_task 可能撲空 IDLE 重評。訓練/囤貨同理未深驗。**非求生層、非本次 3-fix 引入/惡化**，撲空後果=任務落空重評（非求生斷觸發等級），故 Fix4 未納。日後若某經濟 option 常態撲空 churn，比照覓食 Fix4 加 applicable 可達性 gate（gather-flag pattern）。關 `2026-07-13-survival-layer-unify-3fix.md §Fix4`。

## 求生/資源決策 backlog（2026-07-14 slice A 排之後，用戶定）
同源缺陷＝「只看瞬時、不看前瞻/償付力」，跟 slice A 求生門檻同族，獨立 slice 排 slice A 驗收後：
- **候選3 faction 不救成員求生**：faction 無反向補糧 directive，且徵收還從餓的窮成員抽血（餓上加餓）。
- **候選4 breed 正反饋**：「養不起還一直生」只看瞬時 `needs.food>0.7`、無人均存糧剎車 → Team7 pop 10→4 暴崩候選機制。
- **非食物 applicable gate 人格化 follow-up**：候選2 人格化門檻框架本輪只接食物簇（食物安全/軍備/發展）；佔村 `OCCUPY_MIN_POP=6`/血仇 `FEUD_ATTACK_MIN=0.5`/匱乏搶 `SCARCITY_RAID_MIN=0.55`/capability `VIABLE_ARMED_RATIO=0.3` 等死常數 gate 同框架逐 gate 遷入（非本輪，控 blast radius）。
- **層4 鋸齒獨立機制**：僅當 slice A 量測後殘餘鋸齒餓死（真赤貧除外）才補（判被層3+層5+候選2 吸收）。
關 `2026-07-14-survival-budget-personality-architecture.md`。

## 情緒系統（stress decay，death spiral 根層）
- **成員 stress 累積不釋放**：驅 `team_panic` → death spiral 根層，跨 reaction/morale。survival-path #2 已於決策層斷 FLEE 螺旋（threat=0→FLEE eval 0），但 stress 本身累積待 person 情緒系統獨立 arc（decay/釋放機制）。本 slice 不修。

## 觀測（SpecimenTracer 窗口非全生命 — 第三觀測洞,討論中 2026-07-15）
- **現象**：specimen jsonl ＝**成功-commit 窗口**非全生命（Team26 錄 day76-85、漏 day24-75 ~50 天）。從沒一份 specimen 涵蓋一隊完整一生。
- **根（code 定音,非 perf）**：capture_decision 4 個 call-site（`faction_ai:1480/1523/1876/3217`）**全 commit-gated**——`:3217` 在 `if _surv_ok:` 內（try_set 成功才 tap）。no-commit 期間（IDLE 空檔／survival relatch commit 反覆失敗＝non-unified thrash 那隻／子隊無獨立決策）＝**零 entry**＝時間洞。commit-fail 的 attempt（rank 跑了選了 option 但撲空/no-op-fail）+ `[Survival]` flip(`:3117`) **完全不 tap**＝路徑洞。**tap-placement 問題,非觀測改世界（前兩洞的族但不同機制）**。
- **修向（1 隻 specimen 便宜,無 perf 否決）**：①tap 挪決策-attempt 邊界（帶 commit-result 成功/撲空/no-op-fail）補路徑維；②specimen per-cadence heartbeat 輕 entry 補時間維（timeline 無洞）。全族群全生命＝貴但不需要。
- **升閘（規劃）**：觀測不變量第三次同族破 → invariants 顯規則「specimen=全生命+全路徑,新決策/commit-fail 路徑必接 tap」+ 觀測盲點閘（未接 tap→FAIL），與「全量暫態可觀測性」「觀測禁燒 RNG」併。
- **不擋 god-view**：Tier1 控制場景=短窗受控→無窗口洞→god-view 繞開,tracer-completeness 排獨立 arc（序待用戶）。詳 handback `2026-07-15-systems-to-blueprint-tracer-completeness-analysis`。關 [[feedback_full_transient_observability]]/[[feedback_observer_no_global_rng]]。

## 選敵 finder（_find_weakest_prey 同-faction 不濾 — R② Fix F advisory②,pre-existing）

**狀態：已知未修** ｜ **回訪：觸發事件 — 序6「loop3 全溶接回」時（★屆時成員征服 intent 會有 dispatch 路，後果就不再受限）**

★★**B 級 sweep 判定（2026-09-04）：真病，而後果目前受限 —— 而【受限本身是暫時狀態】。**
```
★`_find_weakest_prey` 現行過濾：自己／null／`has_belief`／`reachable`／`pop_est < 0.7×自己`
   ⇒ ★★【沒有 faction 過濾】——與條目描述一致
★★★而我原本以為它不可能 fire（函式名叫 `_evaluate_independent_strategy`）——【錯】：
   `faction_ai_system.gd:978` 那個 `else` 分支（＝**有 faction 的成員隊**，「入勢力不換腦」）
   **也呼叫它**（:987／:990）⇒ 行為者【可以】有 faction ⇒ 同-faction 選敵【可以】發生
```
★**後果目前受限**：成員路只【宣告】征服 intent，`loop3` cascade 已刪 ⇒ **現在不會真打**。
★★**而條目自己寫著「待 序6 loop3 全溶接回」** ⇒ ★★★**那一天到來時，這顆就從「宣告」變成「真打自己盟友」。**
★**教訓（今日同族）**：**函式名寫著 independent，而它的呼叫者包含非 independent —— 名字比判準強。**
- `_find_weakest_prey`(`faction_ai:3311-3332`)迭代 `team_discovered` **無 faction_id 過濾** → `prosperity_target_id` 理論可能曾是同-faction 隊。Fix F 用純 `BeliefSystem.best_estimate`（非 belief_pos 通道分流），同僚可能無 belief claim → 提早進態③放棄。**效果=提早放棄攻擊（保守退化）非危險行為**，pre-existing 非 Fix F 引入,不阻本刀。日後選敵 finder 補同-faction 濾一併處理。

## god-view 位置 belief 化 follow-up（2026-07-15 merge 6aa3ee18）
- **★撲空後 aftermath 未觀測**：Fix F 追兵斷視線→去 belief last-seen 撲空已驗（單 tick 靜態，QA 撲空核心連貫）。但**追兵到達空的 last-seen 之後做什麼**（搜索周邊/放棄 re-eval/凍結/thrash）**完全沒驗證過**——pursuit_hiding_bed 是單 tick 靜態驗證非 multi-tick trace。**修向**：延長 pursuit 床多跑幾 tick 判 aftermath 連貫（或 tracer-completeness arc 順帶，因它正是看 multi-tick 行為）。態③(stale→release)理論上接手放棄，但未 organic 驗。
- **門檻④ HOB/sanity=implementer 自報未獨立複驗**：Fix F+床 infra 小 code 面，systems 判 HOB 回歸風險可忽略（belief_pos 非 LOD-gated、行為只斷視線 rare case 岔開、determinism 兩跑 byte-identical）→ 接受自報 merge。若日後 HOB obey% 異常回溯此決定。
- **_find_weakest_prey 同-faction 不濾**（R² Fix F advisory②，pre-existing）：見上「選敵 finder」條。

## 俘虜處置擴選項 = ③內部政治 slice（用戶定 B，2026-07-15，backlog 非急）
- **現況**：`decide_treatment` 只 厚待(→同化)/苛待(→暴動逃)。**缺主動殺俘**——③內部政治我們假設過殺俘存在但 code 沒有。
- **擴為完整人格化道德選項集**（`game-design.md §俘虜處置` owner=blueprint）：**殺俘/處決**（殘忍高→屠/低→受降，★帶③凝聚成本:殺俘違背低殘忍成員→不滿→defect/激進化）、**贖金**（貪婪高→勒贖，俘虜原勢力付得起才成=belief-gated 鏡射 look-before-leap）、**釋放**（義氣/慈悲→放走→名聲升）。各選項人格驅動→同批俘虜不同領袖處置全異=道德戲。
- **邊界**：decide_treatment 本身已是合法域專 scorer（讀殘忍，穿人格，非 unification blocker——見 invariants 域專判斷器邊界原則）；本 slice=**擴選項集**（加殺俘/贖金/釋放 option + 各自人格驅動 + 殺俘的③成本），非重構成 rank。
- **排序**：backlog，非急、**不擋** god-view/tracer-completeness。**標記「③內部政治 slice 的一部分」**——殺俘的牙（領袖決策違背成員→凝聚成本）=③同根，開③內部政治 slice 時一起做。

## tracer-completeness finder_miss 未 live-demo（2026-07-15 merge 2a805d35，留觀）
- `capture_decision(...,"finder_miss")` tap（`faction_ai:3219-3223`，survival loop finder 撲空 `continue` 前）＝**code-verified + 同構於 live-verified try_set_noop**（緊鄰同 for 迴圈、同 pattern），但**時限內未構造 live 觸發**——罕見防禦分支：ctx 可行（option applicable）但 to_task 回 `tgt==(-1,-1)` 的 race，organic 也從未撞到。
- **留觀**：若未來 specimen trace 出現「該有 finder_miss 卻沒被捕」的洞→回頭查此 tap 是否真 fire（現為高信心 code-verify 非 live 證）。非 blocker（try_set_noop 同迴圈 live 活證已證 tap 機制真接 code path）。

## ★FLEE 從不移動（dead flee-movement，序1 dissolution 遺留，2026-07-15 full-HD 觀察揪出）
- **現象**：隊觸發 TASK_FLEE 後**永不移動**（Team1 128 天原地「逃」，threat_react 凍結 15 位相同，re-commit 3080 次=75% 人生 churn）。aggregate `N1_flee` 虛高大半來自此。
- **根（code-verified）**：`options.gd:188` FLEE `to_task`→target `(-1,-1)`；`movement:82-84` `move_target==(-1,-1)→continue`（跳過）；**全域無 flee 方向/away-vector 計算**（`_flee_target` 序1 wave-dissolution 刪除，`faction_ai:445-447` 註解**謊稱**「FLEE target 由 mover 算」，mover 不算）；`_wire_threat_task` 不設 flee target。∴ FLEE=no-op，隊不動→威脅位置凍→threat 每次 re-eval 都贏→無限 churn。
- **★治根 vs 治症**：blueprint 初判「缺執行鎖」＝表象；加 lock 只讓 churn 節流（隊仍卡原地永逃）＝治症（[[feedback_symptom_vs_root_retry]]）。**治根＝恢復 flee 位移**（FLEE 派出設 move_target=遠離 threat belief 位的可達 tile→逃遠→threat 距離衰減→out of vision→自然 release=「有終點」）。
- **附帶**：①`faction_ai_system.gd::_decide_unified()`/`faction_ai_system.gd::_evaluate_solo()` `capture_decision` 在 try_set **前**用預設 `"committed"`（self-replace/被擋也記 committed）→3080 部分虛高；tracer-completeness 只補 survival(3217)未補 unified/solo＝**tracer-completeness follow-up**。②`_evaluate_threat` FLEE_TIMEOUT reflee-loop 逃成功後 moot。
- **狀態**：reframe 報 blueprint 確認中（`2026-07-15-systems-to-blueprint-flee-root-reframe`）→ 認同則 spec「恢復 flee 位移」。感知鐵律：flee 反向讀 threat belief 非活值。

## state-transition specimen tap（下批候選，R² advisory 2026-07-15）
- **death/split/betray/found/capture** 等 state-transition 事件目前僅 `Probe.bump` aggregate、**無 specimen tap**（同 person-reaction 補前現狀）。observability-path-completion 本刀先收 person-reaction，這批**下批**（模式相同：capture 進 specimen 帶 who/why）。**記此防之後當新發現重走一輪 R²**（tap-gap 家族第 5+ 個，該一併走盲點閘掃出）。

## 掛單噪音 churn(blueprint+用戶抓 2026-07-15,經濟arc納入)
- **現象**:order_placed 539-850單/月、arb_call 數千/月、arb_kill_nostock 8372-20331/月。Team0 常駐6張單跨tick不變每cycle重掛→撮合狂空轉。churn家族(掛成不了的單還重掛,同flee每tick重commit/買糧幻覺精神)。
- **兩層**:①供給seam修後可能自消一部分(有貨可撮→成交清掉→spam減,像flee修N1_flee回落)②剩獨立churn(隊照掛不管有沒有貨/買不買得起)→掛單紀律治。
- **掛單紀律(order-discipline,scope待seam修後噪音量測定)**:grounded-order(掛單版look-before-leap:買不到/賣不掉/付不起別掛)+dedup(常駐單去重)+expiry(過期清)。訂單也是決策/行動該grounded(結構稽核grounded-ness家族)。
- **序**:供給seam第一刀驗收#7量噪音修前後→看供給下游自消vs獨立churn組成→blueprint定同刀or下刀。**別預修**。溯源handback `2026-07-15-blueprint-to-systems-order-noise-scope`。關 [[project_economy_arc]]。

## ★生產/發展arc greenlight(甲·統一框架,2026-07-16用戶定)
- **用戶裁甲+同商業那套**:不de-patch單一恆-hungry閘,拆光生產/設施子系統所有補丁閘融進框架(引擎+人格秤)無殘補釘再量。乙不成立(bug閘非設計稀缺,補丁閘通則=de-patch)。
- **願景(綜合發展模型)**:食安地基→多維發展人格化(工匠建製造/農夫續農/好戰建軍事)。設施建造=發展核心動作。
- **頭號補丁閘=恆-hungry**(_pick_facility:糧倉有糧仍effective_food判餓→farming硬override→製造設施never)。其餘閘blueprint靜態稽核列中(餵systems)。
- **架構方向(systems HOW,待靜態稽核全閘)**:facility/發展決策走DecisionEngine(人格加權needs:工匠→製造/農夫→農/好戰→軍事)取代硬gate(hungry→farming override/facility_score門檻/builder gate);同unified-commerce精神(整子系統進框架)。切幾slice待閘清單。
- **等靜態稽核餵全補丁閘列表**再spec(同商業異質稽核抓全縫)。溯源handback `2026-07-16-blueprint-to-systems-production-arc-greenlight-unify-all-gates`。關 [[project_unification_matrix]]/[[project_economy_arc]]。

## 生產框架 arc follow-up（2026-07-16,供給側成功後殘項）
- **deal 側成交牆（死法②同款,下一 arc）**:生產框架破供給牆(has_facility 10%→31.3%、成品池 26→480 18x),但 deal headline 仍低(deal=2、sell_no_surplus 最大 bail)。根=供給「量」有了但**流通到 visitor 隨身可交易貨**未打通(產出集中在有 facility 隊自家 outpost 公庫,非分散到 roam visitor 手上)。=死法②同款成交牆,另開 arc 治(非生產框架範圍)。
- **A3 utility 化(生產 S4.2 未做)**:`_evaluate_infrastructure` 固定 if 階梯(升級>擴建>蓋新 first-match)→ utility argmax。measurer 坐實**非 release block**(has_facility 正常漲,ladder 沒餓死建造)→低優先 de-patch follow-up slice。
- **`GOVERN_MATERIAL_TARGET` const 孤兒**(A4 govern de-patch 後 `faction_ai_system.gd::GOVERN_MATERIAL_TARGET` const 可能無 caller)——advisory 清,非閘。
- **人格分化 confirm**(弱證據 n=8):mechanism 在(leader_pref+_facility_personality)但乾淨相關性樣本不足→待 blueprint 裁是否 multi-seed 聚合 confirm。關 [[project_economy_arc]]。

## Arc1 need oracle S6 + 終端消耗品 known-deferred（2026-07-16）
- **S6 遷 `_facility_deficit` → oracle**（dispatched）:blueprint 裁甲——workshop/apothecary/weaponsmith 等 non-food 設施 deficit 引擎外走 TARGET_PER_POP 各算=單一源違規+打架種子→遷 NeedOracle need（goods 由 demand 驅因 need_keep=0;保 facility gating）。遷完 ① clean→measurer 乾淨全量→批。
- **終端消耗品(武器/tools/armor) self-use=known-deferred(非 blocker)**:NeedOracle 內 self-use 暫用 flat TARGET_PER_POP base（`need_oracle.gd`（★L2 錨：檔級）），**單一源已達成**(reader 都經 oracle),只是值待「戰耗/造耗/傷耗率」世界物理機制建了才真推導。判準見 invariants「單一源 oracle 判準」(源統一=硬/值推導=軟債)。順手 arc5 死常數人格化或戰鬥機制 arc 補推導。關 [[project_economy_arc]]。

## ★★框架「做好」= 3 流（用戶零殘留+真統一+可擴充,blueprint 裁 2026-07-16,defer behavior)
統一驗收=**真統一+零殘留閘+可擴充三位一體**,3 流全綠才 behavior:
- **① 零殘留閘流**:強化 constitution_gate 抓全閘型(值閘 RNG/override/硬門檻 + 控制流閘 手派路由/散落入口/近似重複)→ enumerate baseline → de-patch section-A 真閘 → baseline→零/全 legit-marked = 證零殘留。歧義 world-rule vs behavior-gate 由 de-patch 進度判(非 regex auto)。
- **② 真統一/擴充 3 seam(一舉兩得)**:seam#1 `applicable()`+`to_task()` 折 REGISTRY(消 4 switch→registry 1 entry+term,收益最大,也修 dispatch 手派路由真統一破口);seam#2 `_facility_deficit` 資料驅動(FACILITY_DEF→NeedOracle gap 泛型衍生,加設施自動有需求訊號);seam#3 `sim_runner` 系統 registry(SYSTEMS=[{sys,lod_policy}]+統一 tick loop,消 near+far 雙分支)。
- **③ 思考補完**:情緒接線(person.goals/memory dormant→決策輸入維度,像 need/threat oracle 供 term;結構接線=框架,情緒行為內容=behavior 後做)。
- **section-A de-patch 清單**(各判):_threat_recent(faction_ai:3125,caller 3087/3090)=behavior-gate/FEUD_ATTACK_MIN+VIABLE_ARMED_RATIO=人格化/GOVERN_MATERIAL_TARGET 孤兒=刪/_evaluate_threat 忙碌+門檻雙gate(388-401)=util/tribute FLEE override(diplomatic:40)=world-rule?待判/establish is_military(3285)+try_hunt(3254)=連續util/applicable DESPERATION天閾(options.gd:93/103/115/121/124/149)=可達性留-天閾de-patch/diplomatic RNG閘(124/137/140)=人格util/dispatch手派return-gate(_evaluate_survival:3187/_evaluate_threat:396 if uses_unified return)=真統一破口收斂。**+baseline偵測器窮盡補漏(別假設清單完整)**。
- **defer behavior**:俘虜feature(殺俘/贖金)/估值小冗餘/emotion內容/deal側死法②。每流照Arc1模式(byte-identical/乾淨全量/R②)。關 [[project_unification_matrix]]。

## 框架做好 stream① 進度2（2026-07-17，seam#1 R②翻案 + 軌2 fast-follow結案）
- **★seam#1 R②異質框外審翻案(v1 FLAWED→REVISED)**:異質Sonnet skeptic+systems逐code全驗——**threat收斂UNSOUND**(5 findings全file:line):threat util量級**故意壓小**(terms.gd:170-171靠applicable-gate選)全pool被貿易1.3/野心1.5壓過+無break-top boost(survival有)+PRIO 70→50塌層+preempt唯一call site=rank_threat+自有FLEE公式(decision_engine.gd:143 vs主rank)。**裁定:threat收斂剝離→歸threat-oracle arc(4前置:severity-scaling util↑/break-top boost/preempt明確+PRIO保/probe先接)**,本就路線圖序3-4在後。seam#1只留**S1 registry(byte-identical)** + survival/ambient逐路驗收斂。threat控制流閘=**legit-until-threat-oracle**(標非移除)。可複用:filtered subset可編碼真選擇語意≠scaffolding,收斂前逐路驗。關 [[feedback_frame_challenge]]。spec `2026-07-17-seam1-control-flow-convergence.md`(REVISED)。
- **軌2 fast-follow multi-seed結案(measurer 8-10seed)**:3項de-patch機制**全legit(源硬統一done,框架零殘留達)**,殘餘=值軟債/vision→defer(framework-first):
  - **① militancy n=0穩**=facility-thin(軍事設施幾乎不建),production域→facility backlog,不追量。
  - **② tribute 100% submit under FLEE**=機制已de-patch(diplomatic_ai:46純人格formula),但generator floor(慎重/求生欲≥0.35)+flat TRIBUTE_W_FLEE=0.25→**高義氣拒絕分支數學不可達**(honor=1.0仍submit 0.125>0.1閾)。=**值軟債**:平衡波降W_FLEE/rebalance讓拒絕可達。連 [[project_desperation_economy]] 敗北三端塌1端(submit壟斷)。
  - **③ try_proactive 慎重³**=公式legit(unit-proven陡,RNG案③),但**行為級分化撤回**:高端「0%」是127-樣本noise(569樣本0.70%不重現),低慎重<0.35 generator架構不可達(person_generator:17 NORMAL_LO=0.35無lo_v慎重archetype)→分化被opportunity稀缺+floor遮蔽。gate-ok立於公式非行為。殘:generator-diversity(低慎重原型)+藍圖陳述更正=vision backlog。
- **54-triage tracker**:`docs/superpowers/54-triage.md`(A1安全收斂/A2 threat legit-until-oracle/B逐code/C=2皆legit)。

### ⏳有大有小 領導軸 follow-up：spread gap + militarize（2026-08-03，B MVP 後）
B idle-labor→建設 MVP（建設-only、develop 路）修 §8 領導軸。**三路張力（develop/spread/defend）剩兩路 deferred**：
- **spread gap**：`紮營` gated `NOT has_own_outpost`＝**established 團（有 outpost）無法 found 第2據點**＝真集團機制 gap（大隊困單 outpost、產能上限=該 outpost 滿設施）。follow-up（可能 subteam/delegate 路 found 新據點）。
- **militarize（defend）**：ABSENT（無 pop→軍決策）→ **折進未來「军民混编/民兵動員」arc**（blueprint 與用戶 shaping：團型定軍民比[騎士純軍/屯兵半兵半農/居民民兵]、威脅動員抽民兵離勞力→產出掉＝guns-vs-butter）。非 standalone、待該 arc 定案。
- 序：MVP 先綠 + §8 領導軸 ratio 追平驗 → 再開军民混编 arc。

### ⏳need_oracle 前瞻/reserve need — buffer 儲備 completeness（2026-08-03，統一勞力池 follow-up，非本 slice blocker）
統一勞力池 → 生產 **need-gated full-stop**（need=0→產出 0、無 min-floor，blueprint §51 憲法確認）。∴ **buffer/戰略儲備（戰前囤武器、荒前囤糧）＝真 gameplay 需求，須走 genuine anticipatory need**（need_oracle 模 reserve target → need>0 → production 自然 fire），**非 trickle floor**（trickle=floor=§51 禁）。
- **∴ 任何「該囤沒囤」＝need_oracle completeness item**（新增 reserve/前瞻 need：戰前威脅→武器 reserve、季節/荒前→糧 reserve），非加 floor 遮。
- 本 slice dev-verify 先驗**多級 need 傳播不斷**（tools←iron←ore、供給鏈即時 need）；reserve/前瞻 need ＝**分開的 need_oracle 增強 follow-up**（若勞力池量測顯「該囤沒囤」缺口才觸發）。[[feedback_genuine_value_not_crank]]（reserve 走真 need 非 scripted floor）。

### ⏳convoy 協調 live-scan perf（2026-07-31，flow-fix follow-up，非 blocker）
SLICE A flow-fix（convoy 協調散未填單）用 **live-scan in-flight guard**（`_deliver_candidates` 每次現掃 `state.teams` active convoy porters 聚合 per-order 在途認領）——correctness 對（結構免疫 registry 漏清幽靈認領，reviewer 鎖）+ flow measured 45→153=80%，**但 perf 成本真**：warring 49+ 隊每 cadence 呼 → O(teams×convoys)/call → single-seed 6mo warring >133min（首輪 GODOT_TIMEOUT=8000s 被殺、加大 28000s）。**follow-up 優化**：cache in-flight 認領 **per-cadence 算一次**（非 per-candidate per-team 重掃）→ 攤平 O(teams²×convoys)。非本輪 blocker（correctness/非凍優先驗）。連 [[reference_hob_perf_protocol]]。

### ⏳warring O(N²) per-tick + 世界膨脹 130+ 超目標 50（2026-08-01 measurer 附帶發現，後-logistics backlog，設計 gated）
measurer 6mo warring 量到 **per-tick 成本 O(N²) 量級**：day1 65隊 46ms → day90 137隊 516ms（隊 2 倍、成本 11 倍）。★**非 convoy code**（convoy 是本輪 flow-fix、live-scan 另記上方 perf follow-up）——是**既有 decision/diplomacy/market 每 tick 掃全隊名冊**。世界**自然膨脹 130+ 隊、遠超 [[project_world_simulator]] memory 目標 ~50**。
- **★不擋 flow-fix merge**（既有架構特性、非本輪 code）。**非緊急、非 fork 現在。**
- **★reframe（blueprint=game-design owner 定）**：perf urgency **gated on 設計問題**——世界該 **~50 legible factions** 還是 **130+**？
  - 若 **~50 才對** → 膨脹 130+ 本身是**設計 issue**（缺 consolidation 壓力）→ 修那個**順帶解 perf**（隊少）+ legibility 升。blueprint 傾向此（避碎片化）但待 game-design 評估。
  - 若 **130+ 是 target** → O(N²) 是真 gameplay perf 問題、要**優化 architecture**（每 tick 全隊掃 → 空間 index/增量/cadence 攤平）。
- **分流序**：①logistics arc（flow-fix merge → SLICE B/C）優先不動 ②perf/team-count = 後-logistics backlog（blueprint 先定 50 vs 130+ 設計、systems 再評 O(N²) architecture 可修否/成本）。連 [[reference_hob_perf_protocol]]。

### ⏳勢力規模動態 arc — 整併觸發太晚（2026-08-01 measure REFRAME，乙 in-flight，串 perf 同根）
**世界塌全小**（133隊全~2.9人、無大團、rung≥2 僅 6隊）＝**「併小成大」沒運作**（blueprint QA 現成資料坐實）：
- **現跑的 merge（322）= 母隊自我回收臨時工子隊**（Team40 派 Team61→完工併回、pop 恢復原狀非變大）＝**錯的整併、對 cross-lineage power consolidation 零效**。
- **★2026-08-01 measure+結構讀 REFRAME（非 resolve 瓶頸、blueprint 自認「85% 蒸發」猜錯）**：JOIN「併入」trajectory 量（3seed×1mo）＝dispatch 33→arrive 1→resolve 1，**97% 蒸發在 dispatch→arrival（mid-travel）**、非 gate(0)/非 resolver reject(0)。**resolver 本身好（1/1）**。
  - **真根＝觸發太晚**：JOIN「併入」只在 distress 才可選（options.gd:137-141 `food_days<DESPERATION_DAYS OR 認慫strong+threat`）、**無理性整併觸發** → 絕境隊已 <3 天糧派 JOIN → **物理到不了多天外 host** → 半路死：belief-stale FREEZE（target >3天沒見→`move_target=(-1,-1)`→凍住 movement:93）/ 非 sticky churn（每天重評 faction_ai:1536 註稱 sticky 但只 `pass`）/ famine 死（grace 7d resource:26）。共同根＝**觸發太晚沒糧撐完旅程**。健康小隊永不理性併大。
  - **★另有 pull-side「吸納」**（options.gd:154-166、強隊主動吸弱鄰、TASK_MERGE、**無 food gate**→強隊有糧撐旅程）＝更健康整併槓桿。**blueprint lean 吸納-主 + 併入-補**（等吸納 trajectory measure 回來才 commit final 方向、不半套硬拍）。
  - **arc 方向**：de-patch＝**加理性整併觸發**（弱隊趁健康早併/強隊吸弱、util weigh 野心stay/求生join → 有大有小 ~50、非塌1）走既有 argmax+人格 weigh（統一非特判）。**串 perf 同根**（O(N²)/膨脹 130+）＝一根解 perf+規模+legibility。連 [[feedback_verify_execution_end]] + [[project_economy_decision_underfire_metaroot]]。

### ⚠️乙 整併 util boost ＝ REVERTED crank（2026-08-02、真根 case B）
**乙 boost（ce369dca）＝arbitrary crank、已完整 REVERT（08d10281 merge、main 回 pre-ce369dca genuine baseline）**。用戶戳破決策引擎命門（[[../../../memory 見 feedback_genuine_value_not_crank]]）：util 必＝真實價值、禁「因不 fire 就 crank 分數讓贏」。
- **我的錯**：per-option dump 見吸納 ownutil 0.104 從不贏 → 誤判「util-starvation 要修」→ 加 `ABSORB_DRIVE_BASE_V2=1.5`(flat crank) + `ambition_amp[0.5,2.0]`(tuned) + join `protection urgency`+cap 2.0 讓 absorb/join 贏。**crank、paper over 真 finding**。
- **★真根＝CASE B：規模經濟 absent（4 維坐實）**——軍力 linear(npc_combat:654)/生產 **SUBLINEAR** sqrt cap2.0(resource:63、大團 per-capita 更少)/抗風險 proportional attrition/領土 pop cap **50/團** overflow split。**model 不獎勵 size 甚至反獎勵 → 世界碎小團＝正確湧現、absorb 0.104 是引擎正確估算、integration 真值低是對的**。
- **∴「有大有小」無 genuine-value 基礎**：consolidation 真沒好處（甚至負）→ **需先讓 size MATTER（加真規模好處：軍力 concentration/生產效率/抗風險）＝WHAT/vision（blueprint 帶用戶拍板中）**。要→加進 combat/production/stability+absorb_yield 自然算進（util 自然升湧現非 crank）→自然 consolidation→有大有小+perf 一根解；不要→碎片化接受、arc drop、perf 另循 O(N²) 優化。
- **reframe：130+ 團非 consolidation bug、是「size 不 matter」正確結果**。修 join/absorb util＝治標甚至 crank。
- **survival-boost（絕境併入）＝genuine**（food-scaled 真 survival spike、原有非 crank、留）。

### ✅（已 REVERT，存查）乙 整併 util boost 曾 merged（2026-08-01，ce369dca→已 revert 08d10281）
**根定案（per-option util DUMP）＝整併 util 結構餓死**（吸納 ownutil 0.104 vs 贏 1.09~10× 弱、finder 找 4794 但 dispatch 0；併入 0.332 只絕境 spike）＝**死常數過度正規化**（terms.gd:224-230 base 1.0 [0,1]cap + 野心×0.3 被閹 + 三 factor 連乘）。de-patch＝`absorb_drive` 野心真放大（ambition_amp=0.5+1.5·gap）+ base 1.0→1.5 / `join_drive` 理性 protection urgency（near×求生欲×低野心 cap2.0）、拆死常數、走既有 argmax term pipeline 統一非特判。dev-verify 4/4 + merged main 驗（constitution 74 + consol_boost_test ALL PASS + headless baseline 0-new + determinism byte-identical）。**warring absorb.dispatch 0→10（starvation 治好）+ teams 84（保守未塌非 blob）**。R² 兩輪 CLEAN。
- **★§5 一次合量 must-check（乙）**：①**absorb 完成率**（dev-verify `dispatch 10→merge 1`＝pull-side 也 mid-travel 蒸發、同 JOIN 33→1 belief-stale freeze movement:93）——**§5 對比 absorb vs JOIN 蒸發比例、排除新 ambition-driven targeting 瞄更遠 prey 加重蒸發**（reviewer 要求）。②**規模分布 tune**（隊數/規模朝 ~50 有大有小、非塌1；不夠→調高 AMB_GAIN/base、過衝→調低、保守起步值 §5 定）。③mid-travel completion 是下層（util-starvation primary 根已治）＝follow-up（可能修 belief-stale freeze movement:93）。

### ✅甲 SLICE B 領主分配政策（統一光譜）merged（2026-08-01，4cc5da15）
**給免費(義氣0.33)/賣公道(1.0)/賣高價(貪3.0)/賣外拋棄子民**＝一 argmax 一 convoy+貿易脊椎、人格 weigh 位置、**零新市場**（`_distribute_candidates` + `override_ask` 注入現成 `_market_visitor_sell`）。dev-verify lord_distribution_bed 6/6（光譜連續非 gate + 免費/付費 coin 守恆）+ merged main 驗（constitution 74 + bed ALL PASS + headless=baseline 5-FAIL 0-new + determinism byte-identical）。R² 兩輪 CLEAN（seam + 訂正 bid<=0 override_ask + 融合驗真 code 四約束 grep）。
- **★§5 一次合量 must-check（execution-end、非假 done）**：warring `distribute.dispatch=0`（此窗 scarce 領主無餘糧）＝**organic firing 未證**（unrest 耦合活 add137/reduce5＝接口通）。**§5 整世界合量必查「分配真 fire?」**。
  - **★§5 量測條件（blueprint 定 2026-08-01）**：**必在「領主有餘糧」條件跑**（和平 economy/surplus 累積窗）才測得到分配 fire + 光譜三端分化，否則 warring 稀缺又測 0＝誤判「分配壞」（其實「沒糧可分」）。**tension**：warring 多隊利乙 join/吸納 vs surplus 利甲 distribute——§5 設計需兼顧（長窗經濟流動累 surplus / 混合場景 / 或分條件），設計時（乙 ready 後）解。
  - **tap 分帳**：分配 fire 率 + 光譜分化(義氣給/貪高價/棄外) + unrest 餵 + 乙小併大 + 經濟流動＝沙盤活了嗎。若仍 0→finding（threshold 調 / 經濟 lord-surplus 生成）。[[feedback_verify_execution_end]]。

### ★faction 成員資格 fragility＝結構 confound（2026-08-05，measurer 3 次重現、systems 親驗坐實）
資訊網補完批 (A) 代表性床揭：**member 自行脫 faction → 斷 relief（及所有 lord-member 經濟關係）＝結構性反覆 pattern、非單一 fixture 偶發**。多退出機制皆 `state.clear_team_faction`：
- **defect**：`event_faction_defect.gd:16` `honor < DEFECT_HONOR_THRESHOLD(0.35) or trust < 0.35` → `:24 clear`（T3-attribution 輪、義氣門檻）。
- **起義 uprising**：`faction_ai_system.gd::_evaluate_uprising()`(守城)/`4577`(流亡) `clear_team_faction`＝**無條件**（(A) 床 T5 ~day41 起義→脫、斷 relief）。
- **defection_evaluation**：`faction_ai:4640/4643`（owner-contact-loss/leader-change，`_evaluate_owner_contact` 路）。
- **founding never-establish**：`g2.faction_found=0`（(A) 床 envoy 派 4× 求婚但 never establish、faction 關係**建不起來**）＝同族「faction 關係不穩」另一端。
- **★意涵（systems 注意、連 arc）**：faction 成員資格**易碎**（多機制退出/建不起）→ lord-member 關係鮮少持久 → relief/規模經濟/生產池 等 lord-member 機制反覆被斷。**連 [[project_size_matter_arc]]（規模經濟 absent＝faction 不 cohere）+ 照妖鏡死常數（DEFECT_HONOR_THRESHOLD 硬門檻 + uprising 無條件 clear = faction-balance 批人格化候選）**。measurement confound：relief 難觀測（member 常在 relief 前/中離開）；但 sim 語意上 member 叛離/起義離 faction **可能是 genuine 湧現**（不忠者該走）——**是否「太易碎」= 未來 faction-cohesion/立國arc 判**（非本批修）。

### ★失聯帳本 subteam 記帳缺口＝WHAT-mandated completion（下批完成、非無限期 park）（2026-08-05、measurer confirmed + blueprint 加牙）
失聯帳本（`feat/missing-contact-ledger`）`_ledger_record` 只 3 caller（herald `faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） / scout `:1732` / convoy `:3372`），但 `SubteamSystem.dispatch`/`dispatch_anon_messenger` 另有 **7+ caller 沒記帳**：settle(`faction_ai_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）)/construct(`:3097`)/upgrade(`:3173`)/expand(`:3458`)/envoy 結盟提案(`:1343`)/population overflow(`population_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走）)/player 指令(`player_command_system:549,585`)——母隊派這些子隊**不受失聯帳本追蹤**。
- **★WHAT-mandated（非 optional polish）**：用戶通例原句「**所有信使與子隊都應有同個系統**」——「子隊」literally 在句中＝general subteam 記帳是 WHAT 要求的完成、**下批完成、非無限期 park**。
- **staging 合理**（本批只 wired 3 info-kind）：①3 info-kind（herald/scout/convoy）先 wire primitive=arc 本旨②settle/construct/expand 等**不返 lifecycle 語意真不同**（settle 不回來、不是「逾時=失聯」同義）＝正當分批、需各自 clear 語意設計。
- **下批**：general subteam-dispatch 7+ site 接 `_ledger_record`（+ per-kind 的 resolve/clear 語意：settle 成功→resolved、construct 完工→resolved 等）。連 [[project_information_network]] 補完批。

### anon-exhaustion=caring 成本真但 distressed 世界無回補（2026-08-05、care-loop cohesion①natural verdict、genuine 非 bug）
領主主動照護 loop（`feat/lord-care-loop` merged 401dae27）決策層 100% clean 分化（好領主 47/47 care/壞領主 47/47 ignore），但 cohesion①natural NATURAL 分化未展現＝**執行層 anon-exhaustion**：care-scout（`faction_ai_system.gd::_detach_one_anon()`）+ 既有 herald/scout/redispatch 消耗平民 anon 池；平民回補靠 breed（`reaction_system.gd::breed_rel_surplus()` `food_flow_avg>BREED_FLOW_MIN`→P5_breed→minor→`population_system.gd`（★L2 錨：檔級。原為行號錨，而行號跟著編輯走） 月 10% 熟成平民）——**distressed fixture 食物匱乏→無 flow surplus→無 breed→無平民回補**→T0（好領主 care-scout）anon 池枯竭封 14 vs T2（從不 care-scout）摸 15。
- **genuine 非 bug**：caring 成本真（relief 花糧+care-scout 花人力）、distressed 世界回補不了＝**戰亂慈善枯竭寫實**。care-loop 決策/機制對，只是 distressed 單床養不起。
- **★收斂**：cohesion①natural NATURAL 四執行 blocker（race-timing/target-resolution/mini-util need-gate/anon-exhaustion）**全同族＝村經濟不可持續**（food surplus→breed→回補+relief affordable）→ **recovery-path/村經濟可持續 arc**（下一 arc 頭號候選、blueprint 定）。連 [[project_economy_arc]]/[[project_information_network]] recovery-path 兩段論。

### recovery-path Slice R1 移民 follow-up（2026-08-06、merged 53907687、非阻塞）
復甦路徑 R1（`MarginalEconomy` 邊際經濟計算層 + 移民 marginal-util dispatch）merged。決策層三態 CONFIRMED、執行層 arrived 三根修。兩個非阻塞 follow-up：
- **migrant 無專屬 specimen tap**：migrant 走 anon 側派（`dispatch_anon_migrants`、leader_id=-1）無專屬 print、不進標準 specimen tap → 決策細節（marginal 算式）無法逐 tick 獨立追、只驗 outcome+code（同 side-action 家族限制）。有 Probe tap（`migrant.marginal`/`mini_util`/`dispatched`/`arrived`）。全量暫態可觀測性理想=補標準 specimen path。
- **`MIGRANT_RATION_DAYS=15` 遠村校準**：口糧供給窗 15 天（`subteam_system.gd`）；近村 OK，**遠村（journey>15 天）可能途中耗盡口糧→survival preempt 再現**。R1 近村驗證；遠村距離需 measurer 校準 RATION_DAYS vs journey ETA。

### recovery-r2 量測 perf + fixture-construction 教訓（2026-08-06、非 code bug）
- **R2 near-LOD 運算成本比 R1 重**：measurer 22天/15天窗口皆逾時、右尺寸縮到 8 天才過關。R2 加 facility_roi/material convoy/village build-as-survival 多 per-team 算 → near-LOD（cluster_pos anchor 全隊 near）成本疊。連 O(N²) faction AI perf 牆（project_time_scale_wave）。量 R2/R3 用小窗+cluster anchor。
- **fixture 置村 belief-formation**：manual 手置 target 村（vid=1）全程 `_village_est` belief est=null（cluster_pos anchor 仍未解），但**自然生成 resident 村（vid=7 forest）work**。根=`_village_est` 讀 lord `dispatch_ledger` holding 條目（own-faction 村）+belief best_estimate；manual 置村不在 lord holding ledger / 未被世界結構納入 → never 評估。**★量 invest/recovery 類需 target 村 = own-faction holding-ledger resident（自然生成路徑、如 vid=7），非 manual 孤立置**。連 reference_measurement_protocol no-player far-cadence vision。

## care-loop scout de-patch = correct but DORMANT（2026-08-11、blueprint 裁 merge banked）
`_dispatch_care_scout` vpos 三層 fallback（roster 補洞）已 merged（a575c4fa）修 vpos silent-return circular（領主查不了無 belief 子民）。**correct+necessary but DORMANT**：death-spiral 未破=下游 **anon-pool exhaustion** 結構擋——lord anon 池被 **population overflow spin-off**（`_create_overflow_team` pop>leadership cap→分新團、day1-4 各搬1 anon、小池 config 平民4 榨乾）耗盡→care-scout `dispatch_anon_messenger` 撞 `total_pop(lord)<1`→零 dispatch。ANON_TRACE=1 trace 定案（非 leak 非 named-競爭）。★anon overflow-vs-proactive-care 分配=[[project_anon_cohort_refactor]] 2c-2 深結構領域、blueprint 裁不 descend（whack-a-mole 6 層）→ care-loop **anon-cohort 2c-2 某天做時立即生效**。relief-death 6 層 gate-chain（scale→propagation→vpos→anon-pool→overflow-spinoff）→ iii-pivot（desperation→defection proportionate ladder）另立。

## 主動升匿名 = correct but DORMANT（2026-08-12、blueprint 裁 merge banked）
`_try_promote_advisor`（領主 deliberate 提拔 anon→named 補 bench、解 named-scarcity）已 merged 修 §4 第 3 路。**formula genuine+bounded 正確**（promote_util=demand×pmult×quality、spare≥desired→0 非逢缺必補、多疑 util→0、add_member 非 subteam、machine-demonstrate 21/21）**但結構性 DORMANT**：quality=tier_combat/0.7、新村 anon 全平民 tier（combat0.1→quality0.1429）→ util_max=0.171 < THRESHOLD 0.3 **數學證明從不 fire**（只新兵+ tier 才可能）。∴ named-scarcity 未紓解、promotion **待 anon tier-up 進程**（平民靠經驗/戰訓→新兵→promotion-worthy）某天做時自動 fire。結構 gap（平民該不該可提拔/nobody 怎麼變 officer）= WHAT-level 用戶裁 a/b/c（a 絕境-relative bar field-promote / b anon tier-up 進程 richest 大 arc 連 [[project_anon_cohort_refactor]] 2c-2 / c 接受 named-scarcity genuine 弱勢 park）。連統一派遣（anon-drain 真根已修 MERGED）。

## ★CONFIRMED tap-gap：faction-leave 4 出口無 Probe tap（2026-08-12、③長期故事驗證 first-pass 揭）
`clear_team_faction` 出口中 **4 個無 `Probe.bump`（只 print）**：`faction_ai_system.gd::_evaluate_uprising()`（起義自立脫離）/ `:5158`（起義流亡脫離）/ `:5259`（defection path B 投降強鄰 fail→clear）/ `:5262`（defection path C 獨立）。相對地 defect（`reaction_system` → `death.defect_leave`）+ betray（`diplomatic_ai_system.gd`（★L2 錨：檔級） → `g3.betrayal`）出口**有** tap。→ 起義/自立/defection 型 faction-leave **Probe 不可見** = 憲法級觀測盲點（全量暫態可觀測性不變量 [[feedback_full_transient_observability]]）、令 story-audit 見 faction_id→-1 卻無事件留痕（measurer #3 真根）。**cheap 修**（4 出口各加 tap，如 `uprising.secede`/`uprising.exile`/`defection.surrender_fail`/`defection.independent`）+ un-blind 未來 long-game audit。blueprint 排 fix 優先序中。

## 記檔：用戶眼球「思考時間長」= O(N²) wall-clock perf + print-overhead（2026-08-13、③story-audit GUI 觀察）
用戶 GUI 親跑 seed1337 看終端：決策輪 fire 時每 team 決策**逐隻慢慢印出**（預期瞬完）=**wall-clock 每輪決策 stall**=#1 perf O(N²)（~130 團互查、[[project_time_scale_wave]] LOD 真根 O(N²)/目標50隊）**活體確認**、**非 sim-clock 節奏**（時鐘比第三守恆軸是 sim-clock 生存 timing=獨立事、與此眼球無關）。疑疊加 **print-overhead**（Windows console print 慢 + 決策路徑 debug print 拖）=未來 perf arc **便宜候選**（砍 hot-path debug print）。★處理序（blueprint）：famine/碎裂先修→團數降→O(N²) 自動緩→不夠再 perf arc（perf 非現在解、記檔待）。連 [[reference_hob_perf_protocol]]。

## 記檔更新：per-team perf 固定成本（2026-08-13、用戶 GUI 單團就慢 refine）
用戶 GUI：**單一 team 決策就肉眼可見慢**（非只團多疊）→ **per-team 固定成本大**。∴上方「famine 修→團數降→O(N²) 自動緩」**降級為部分緩解假設待驗**（O(N²) 剩線性緩解；若 per-team 常數 dominated 則團數降也不解）。嫌疑：①per-candidate 尋路（`estimate_catch_up`/reachable per 目標×幾十候選×hex r14 圖=單團就重）②console print 同步阻塞（Windows+中文~10ms/行×每團多行=逐隻蹦直接解釋）③belief/known_reputations 掃。★cheap 驗證（systems 跑、dieoff_perf_bed DIEOFF_PHASE=1 phase_timing + print console-vs-null A/B）→ print 佔大頭=hot-path 砍 print 便宜大勝 / 尋路=perf arc 主菜。

## ★建造隊派遣的真閘 ＝ 建材，不是糧（2026-08-21 實測，lead 非結論）

**量測**：`docs/measurements/breed-deathcause/dispatch-fail-90d.txt`
（peaceful_economy, day 90, seed 1337, teams=19）@ `52f08fdf`

- `dispatch_fail.資源不足 = 28 (100.0%)` —— **28 次派遣失敗全部同一個原因**
- `dispatch_fail.糧橋不足 / pop不足 / advisor不可用 / subteam失敗` **全部 = 0**
- `bridge.no_go_food = 0` ⇒ food-bridge 檢查 **一次都沒執行過**（建材 gate 更早短路）

**意義**：`size_matter` arc 記的「settle 從未 dispatch」，
**先前把嫌疑指向糧橋（`faction_ai_system.gd::_dispatch_builder()` `_eta_build` 高估 24×）—— 實測否決。**
~~**真閘在建材 cost（`_can_afford` 1.5×）這一層。**~~

### ★★★★再訂正（2026-08-25）：**「誰會再呼叫 `_dispatch_builder`」＝ 兩半，其中一半是【床缺一條路】**

**measurer 重驗（現行 branch）**：結構性樣貌與 08-21 main **完全相同** ——
`28/28 缺 material`、**全部 `tick = 10`**、`vault` 恆 0、`home_mfg_level` 恆 0、
★**之後 89 天 `_dispatch_builder` 再未被呼叫過一次**。
★**他的判斷成立**：**真缺口在「誰會再呼叫 `_dispatch_builder`」，不是 material 數量。**

★**systems 用語意錨重查（行號會漂），把那句補完成【兩半】**：
`_dispatch_builder` 的呼叫點 **＝ 2 個**（窮盡）：
| 呼叫點 | 在 peaceful 床上 |
|---|---|
| `_evaluate_infrastructure` | ★**結構性死掉** —— 它在 `for fid in state.factions:` 迴圈內（`:725 → :739`），**而該床 `factions` 恆空 ⇒ 零疊代** |
| `_dispatch_goal_delegate` | ★**活著，但只在 `tick 10` 那批觸發過** |

⇒ ★★**「89 天零呼叫」＝ 一條路【不存在】＋ 另一條路【之後不再產生 build 委派】。**

> ## ⏳★★★時間戳記（用戶補令 2026-08-26：「經濟等時間弄完再議 應該會變很多」）
> ★**本節【所有經濟數字】屬於【時間重錨前】的尺度**（`lt_cost 182`／`cost_to_margin 75`／`258`／`71%`／收入 `12/11/7`／`vault_full` 各值…）。
> ★★**重錨會改動經濟數字的地基**（收成曲線／工期 4–8×／飢餓減半／T0–T4 頻率）
> ⇒ ★★★**重錨完成後一律以新尺度重量，舊尺度結論【不帶入】、不得直接引用。**
> ★**留著它們是為了保留【推理過程】與【機制結論】**（「裝不下」「沒有出口」「就是窮」這類**與時間尺度無關**的形狀），
> **不是為了保留那些數值。**

### ✅★★★★★★★ARC 收束（2026-08-26 夜）：**配管全部接完，剩下的是【真的窮】**

**十五張票，每一層都是【一條沒接的線】，而它們現在全接上了**：
```
材料不夠(163) → 富點看不見(→64) → slot 滿(180) → ★升級沒接線 → ★★零收入(裝不下) → ★★★倉庫裝不下自己的下一步
```
| 已落地 | 結果 |
|---|---|
| 獨立隊接上升級路徑 | `upg.eval_entry 0 → 258` |
| material 回家卸貨 | **載重 194~203 → 59/60、公庫 material 0 → 200、`gained` 0 → 12/11/7** |
| 倉容關係式 pin（`storage_fits`） | civilian `[200,500,1500] → [250,650,1500]`、`vault_full 9 → 3` |
| 階梯溶解（升級進 `_pick_facility` 第三出口） | ★**今日零差別（預告過）**、四 fixture 綠（含負向 D） |

## ⚠️仍掛著的兩件（★blueprint 2026-08-26 已各給處置與【觸發條件】）
| 項 | 處置 | ★觸發條件寫在哪 |
|---|---|---|
| ★**床 config 給 Team3/4/5/7 塞 `material 400`**（失真；**Team5 `vault_full` 仍 72/72**，私產 120、cap 250 仍裝不下） | **下次重建本床基線時一併除掉**（量測衛生） | ★★**已寫進 `config/peaceful_economy.json` 的 `_doc`** —— **打開那個檔的人就是該做它的人** |
| ★**`military` L1 `cap 300 == 全費 300`（0 餘裕）** | **併入未來平衡輪，不單獨動**（關係式 `≥` 成立；墊高是平衡判斷） | ★**日後 military 若出現「存得到但永遠差一點」，第一個看這格** |

★★★**為什麼要寫觸發條件而不是只列在這裡**：**「等某天再做」的項目會靜默失效** ——
**唯一能活下來的寫法是把它掛在【那天那個人一定會打開的檔】上。**（連 memory `feedback_nobody_owns_shrinking`。）

### ★★★★★★再收口（2026-08-26 晚）：**根再往下一層 —— 是【載重】，而閉環變成五層**

**接上升級路徑後，升級被提出 258 次、派出 0 次**（`reject_cannot_afford 257` ＋ `reject_pop 1`）。
逐日軌跡 ⇒ **Team3/4/7 連續 25 天存量一個數字都沒動、公庫全程 0**。追下去：
```
movement_system.gd:16  carry_cap = pop×10 + mounts×15 + wagons×40   ⇒ ★pop 6、無馬無車 = 60
                       _resource_weight("material") = 1.0            ⇒ ★material 每單位重是 food(0.1) 的 10 倍
resource_system.gd:323 if res in PUBLIC_RESOURCES or res == "food":  ← ★★material 不在白名單
```
⇒ ★**material 一律進私產 ⇒ 一律受載重限制**（★**「公庫 material 全程 0」的機制原因在此，不是隊窮**）
⇒ **實測四支隊 `carry_full = 72/72`、`pool_empty = 0`、`gained = 0`，載重 194~350 / 上限 60**
⇒ ★★★**不是沒料可採，是【裝不下】，而且它自我維持：裝不下 ⇒ 採不到 ⇒ 永遠零收入。**

## ⚠️ 床的失真設定（**這輪【刻意不改】**）
`config/peaceful_economy.json` **給 Team3/4/5/7 開局塞 `material 400`** ⇒ ★**第一 tick 就超載 6.7 倍。**
★**不改的理由**：**它現在是「超載鎖」最乾淨的陽性對照，而正確的修法（入庫＋卸貨）會自動解掉它。**
★★**記在這裡是為了日後不要有人把它當成正常設定。**

## ⚠️ 而我上面寫的「infra 路不存在 ＝ 床的結構限制」**只對一半**
我把它整個歸成**床的問題**（⇒「該量的床是預塞政權」）。★**blueprint 2026-08-26 裁定：另一半是【真的產品缺口】。**
```
_evaluate_infrastructure            (:4559) = (1)升級 + (2)設施
_evaluate_independent_infrastructure(:4508) = ★只有 (2)
```
⇒ ★★**獨立隊有「擴建設施」卻沒有「升級據點」，而【拿到第 3 格 slot 的唯一出口】就是升級。**
★**窮盡搜索坐實另外三條升級路徑都到不了**：`start_upgrade_level` ＝玩家路徑、`_subteam_upgrade_level` 只由 `_dispatch_upgrader` 派、而 `_dispatch_upgrader` 唯一 caller 就是那支死掉的 `_evaluate_infrastructure`
⇒ ★★★**NPC 獨立隊在任何床上都沒有 L1→L2 的路，不只是這張床。**

**裁定＝既有法延伸適用**（用戶 2026-07-16「獨立隊也發展生產＝YES」），**接統一秤非平行特例**。
**修票**：`docs/superpowers/specs/2026-08-26-outpost-development-unified-HOW.md`（R² CLEAN，已 dispatch）。
★**兩個不得省的驗收**：①**迭代順序逐格一致**（全地圖字典＋第一次成功就 `return` ⇒ 哪格先掃到決定哪格先升級，重構成收集再排序會假紅）②**faction 回歸防線必須跑 `warring_states`**（`peaceful_economy` 零 faction ⇒ 在那張床上驗不到有沒有把 faction 路徑改壞）。

### ⚠️ 連帶：**「冷啟動雞生蛋死結」這個命名要修正一半**
★**在無 faction 的床上，infra 路【不存在】** —— **那不是「雞生蛋」，是【床缺一條路】。**
⇒ **正確拆法**：
| 半 | 性質 | 歸屬 |
|---|---|---|
| ★**infra 路不存在** | **床的結構限制**（和平床長不出 faction —— 建國只掛在打贏／臣服） | ★**用戶已裁：新基線考 peaceful 卷【預塞初始政權】** ⇒ **那才是該量的床** |
| ★**`_dispatch_goal_delegate` 之後不再產生 build 委派** | **真的要查的東西** | ★**與 faction 無關，可以現在追** |

★**這也解釋了為什麼在這張床上追了那麼久**：
**我們一直在一個【結構上少一條路】的世界裡，找「那條路為什麼不走」。**

### 原訂正（留史）
### ★★★訂正（T3，2026-08-21）：**建材只是表象，真相是整個 faction 層在這張床上零疊代**

measurer T3：`state.factions.size()` **恆為 0**（逐 tick 取樣）。
`faction_ai:717 _evaluate_all_body` 的外層是 `for fid in state.factions:` ⇒ **零疊代**
⇒ **`_update_goals` / `_assign_tasks` / `_evaluate_infrastructure` 三者從未被呼叫過一次。**
⇒ T1 那 28 次必然全部來自另一個呼叫點 `_dispatch_goal_delegate`（per-team，不經 `state.factions`）。

**systems 自驗並擴大（窮盡 grep `create_faction` 全部呼叫點）**：

| 建國路徑 | 出處 | 和平床上會發生嗎 |
|---|---|---|
| **config 預塞** | `game_setup.gd:298 / :572` | 只有 **3/29** config 有 `factions`（`default` / `perf_scale` / `warring_states`） |
| **戰勝後建國** | `npc_combat_system.gd:784` | ❌ 和平床無戰鬥 |
| **外交臣服** | `diplomatic_ai_system.gd:251` | ❌ |
| **玩家命令** | `player_command_system.gd` ×4 | ❌ headless 無玩家 |

★★**結論（推論，已標明）：和平床上 faction 永遠不可能出現** ——
**「建國」這個動詞只掛在「打贏」和「臣服」上，沒有「經濟／聚落成長 → 立國」的和平路徑。**

### ⚠️★★★重大訂正（2026-08-25）：**「26/29 config 沒有 factions」是【我的讀法錯】**

★★★**而 2026-09-04 我【又犯了同一個錯】**：我再次用 top-level `factions` key 掃，報出「26/29」「27/36」，
★**而正解就寫在本條目裡**（`teams[].faction_id`＋`is_faction_leader`）—— ⇒ **reviewer 第二次把它抓出來。**
★★**真正 0 政權的是 4 個**：`econ_bed`／`infonet_scale_econ_concentrated`／`peaceful_economy`／`survival_start`。
★★★**教訓（本檔自己就是證據）**：**訂正寫在帳上，而下一個犯同樣錯的人可能是【寫下那條訂正的人】** ——
**⇒ 所以訂正要寫在【會被撞到的地方】，而不只是寫在【正確的地方】。**

★**我用 top-level `factions` key 掃 29 個 config** —— **但那不是 faction 的唯一表達方式。**
**正確讀法 ＝ `teams[].faction_id`**（`game_setup` 會據此 `create_faction`）。

**用正確讀法重掃**：
| 有 faction | `demo 3`／`f0_recovery 3`／`game_sim_test 2`／`infonet_* 1~4`／`merchant 3`／`world_sim 2`／`unified_dispatch_diverse_bed 4`／`warzone 3`… ★**多數 config 都有** |
|---|---|
| **真的沒有** | `econ_bed`／`infonet_f1_entry_threshold`／`infonet_scale_econ_concentrated`／★**`peaceful_economy`**／`survival_start` |
| **用 top-level 表達** | `default 1`／`perf_scale 3`／`warring_states 3` |

⇒ ★★**「26/29 沒有 factions ⇒ 這些床勢力層全程 dormant」【作廢】。**
★**成立的只有**：**`peaceful_economy` 沒有**（★**而那是 measurer【實測】`state.factions.size()` 恆 0，不是靠我讀 config**）。

### ★★★這次錯的形狀值得單獨記
**我掃了 29 個檔 —— 看起來很窮盡。**
★**但掃描的【判準】本身是錯的。**
⇒ ★★★**「窮盡」保證的是【覆蓋率】，不保證【判準正確】——
掃遍所有檔案、用錯判準，等於一個都沒掃。**

★**而且有一個現成的交叉檢查我沒做**：
**`peaceful_economy` 的「沒有 faction」有【實測】佐證（`state.factions.size()` 恆 0）；
其餘 28 個我【只有讀法】、沒有任何一個實測。**
⇒ ★**有實測的那一個對，沒實測的 28 個我卻一起宣告了。**

### 原文（留史）
★**影響面**：**26/29 個 config 沒有 `factions`**（含 `world_sim`、`econ_bed`、全部 `infonet_*`、
`unified_dispatch_diverse_bed`）⇒ **這些床上 faction 層全程 dormant**。
**過去在和平床上做的量測，量的都是一個「沒有勢力層」的世界** —— 結論的適用範圍比我們以為的窄。

**分流訂正**：先前記的「冷啟動雞生蛋（沒人有料→沒人蓋→永遠沒料）」**描述錯了**。
真相是**蓋 manufacturing 的那條迴圈根本沒跑**。
★但**第三類判別（「從未被填過」≠「被榨乾」）本身仍然成立**，只是這顆展品的成因要改述。


**未處置**（camp-access 在飛，不插隊）。要接的下一步是**查那 28 次缺的是哪種建材、以及是否 genuine-depletion**
（memory `resource_depletion_genuine_vs_blind`：池空 ≠ bug，先分 genuine vs 盲派）。

## `predator_density` 住在 `tile.resources` —— 資料模型混雜（2026-08-25，falsifier 抓出）
**症狀**：**生態狀態（捕食者密度）與真資源同住 `tile.resources` / `resource_cap`**，
走同一套 `TileBank.pool_set` + `regen_predator`（`harvest_system.gd:93-100`）。
⇒ ★**任何「掃資源桶」的機制都會把它當資源**（means-end falsifier 上線第一次跑就撞到）。
**現況處置**：**分類表一次性標為非資源，falsifier 看守**（不擋交付）。
★**真修法**：**把生態狀態搬出資源桶** —— **結構債，未排期。**

## ★★★`own_granary_tile` nil 崩 —— **修過一次沒修乾淨，而根不在呼叫點**（2026-08-25）
**★★★訂正（2026-08-25，同日）：歸因錯了，真來源是【測試自己】。**
**implementer 補了 `decision_context.gd`（★L2 錨：檔級） 之後，nil 仍是 7 行 ⇒ 止血修沒讓數字動 ⇒ 歸因不對。**
**真來源 ＝ `headless_test.gd` 自己有 7 個呼叫點沒傳 `state`（如 `:11618` `TradeValuation.reserve(t, "material")`）⇒ ★7:7 完全對上。**
⇒ ★**這是 `stale test`，不是 production bug。**（★**本節原本寫「production 呼叫點漏傳」—— 那是我引用了錯誤歸因，我 owner 這份檔，由我訂正。**）

**現況**：headless baseline 有 **7 行** `own_granary_tile` 在 nil `state` 上讀 `world`。
**既有裁決**（`scripts/debug/own_granary_null_caller_test.gd` 檔頭，T2 regression）：
> **「根修 ＝ 呼點補傳 `state`（★非 `own_granary` 頭加 guard）」**

★**implementer 窮舉出【還有兩個呼叫點沒補】。**

### ★★★但我查完認為「補那兩個呼叫點」是**第三次補丁**
**窮盡 grep `state: WorldState = null`**：★**`trade_valuation.gd` 有 7 個函式全都把 `state` 設成可選**
（`reserve` `:85`／`_reserve_factor` `:102`／`_reserve_factor_food_only` `:109`／`_food_urgency` `:115`／`_urgency` `:121`／`ask_price` `:127`／`local_value` `:136`）。
**而下游 `NeedOracle.need_keep(state, …)` `:13` 的 `state` 是【必填第一參數】。**

⇒ ★★**斷層在這一層：`trade_valuation` 把 `state` 當可選，下游把它當必要。**
**⇒ 只要 default 還在，第三個、第四個呼叫點還會漏傳，而且【一樣是靜默的】。**

### ⇒ ★真正的根修：**拔掉那 7 個 default**
★★**漏傳從 runtime 崩 ⇒ 變成 parse error。**
★★★**這是同一條法今天第四次用到**：`reason` default（零使用＝純負債）／`kind` 必填／`stock_utility` 兩入口／**本條**。
> ★**default 的收益 ＝ 有多少人真的用它；成本 ＝ 忘記填時會不會靜默。**
> ★★**這個 default 已經害了兩次，這就是成本的實測值。**

**工作量未知**（要先數 caller），**不擋當前 slice**。

### ★★★而「拔 default」的結論**不變，理由更強了**
★**如果 `state` 是必填，那 7 個測試呼叫點會是 parse error —— 測試作者當場就知道。**
⇒ ★★**這個 default 不只害 production，它【也害測試】：它讓人可以寫出一個【看起來對、其實沒建好世界】的測試。**

★★★**而它的使用者【全部都是錯的使用者】** —— 對照 `reason: String = ""`：
| default | 使用者 | 結論 |
|---|---|---|
| `reason = ""` | ★**208/208 沒人用** | **零使用 ⇒ 純負債** |
| ★`state = null` | ★★**只有【漏傳的人】在用** | ★★★**只有錯誤使用者 ⇒ 比零使用更糟** |

> ★★**一個 default 若只有【錯誤的使用者】，那它不是方便，是陷阱。**

## ~~★★★註解描述了一個【不存在】的事實 —— `_calc_reserve`~~　⇒ ★**已銷案（2026-09-02）**
> ★**銷案憑據**：`_calc_reserve` 連同那句說謊的註解，★★**已在 `03fdf03c`（2026-08-26）被整支刪掉** —— 我自驗過該 commit。
> ★★★**而本條寫於 2026-08-25 ⇒ 隔天就被修了，而條目在清單上又活了一週。**
—— `_calc_reserve`（2026-08-25，我當場被它騙到）
`interaction_system.gd:667-669`：
```
func _calc_reserve(team: TeamData, res: String, leader_values: Dictionary = {}) -> float:
	# 留底邏輯收進 TradeValuation.reserve（單一源），★NPC + 玩家路徑同用。
	return TradeValuation.reserve(team, res, leader_values)
```
★**窮盡 grep `_calc_reserve`（扣定義行）＝【零 caller】。它是死 code。**
⇒ ★★**那句「NPC + 玩家路徑同用」描述的是一個不存在的事實。**

★★★**而我當場被它騙到**：我看到「沒傳 `state`」＋「NPC 路徑同用」，
**準備裁定「NPC 側留底還沒修、所以 `fp` 該變」—— 查 caller 才發現那支根本沒人呼叫。**
⇒ ★**註解 drift 最危險的形態：它不是描述錯，是【讓讀者相信某條路徑存在】。**
★★**`dormant-module-scan` 掃 `class_name` 層級，抓不到【函式層級】的死 code —— 這是掃描的已知覆蓋缺口。**

## ★`local_value` 仍有 ~12 個 blind 呼叫點（2026-08-25，窮盡掃出，★不在當前票範圍）

**狀態：已知未修 → ★已修（結案存查）** ｜ **回訪：不需要（★由型別強制，不是靠人記得）**

★★**B 級 sweep 判定（2026-09-04）：blind 呼叫【在型別層不可能存在】。**
```
簽名：`TradeValuation.local_value(team: TeamData, res: String, state: WorldState) -> float`
   ★`state` 是【必填、無預設】⇒ ★★少傳一個參數【編不過】
現行呼叫點逐個查（10 處）：`interaction_system` :901／:990／:1011／:1034×2／:1040×2／:1042／:1043
                        `faction_ai_system` :2534／:3931 —— ★★★全部傳 `state`
```
★**所以這一條不是「有人記得去補」修好的，是【把參數變成必填】之後它自己不可能再發生。**
★★**而那正是本條目該有的結局** —— **「~12 個 blind 呼叫點」這種條目，靠列清單去追永遠追不完。**
**已傳 `state`（granary-aware）**：`interaction_system` 主撮合路徑 `:826/:866/:968/:993/:1000`、`order_system`、`goal_resolver`、`coin_treasury`。
★**仍 blind**：`faction_ai_system.gd`（★L2 錨：檔級）（商隊自評值）、`interaction_system:952/996/1002/1004/1005`（易貨估值）、`player_trade_system:46/85/88/137/139`、`player_api_mapper:864/866/876/879`。
⇒ ★★**同族 blind-view，但屬另一張票 —— 列管，不擴張當前 slice。**

## 情報操控接線現況（2026-07-06 盤點：捏造缺口，但框架放得下）

> **★段落狀態(2026-08-21)**:2026-07-06 盤點快照,現況欄過期(資訊網 arc 已 CLOSED/ACCEPTED,傳播/belief/失真已落地);本節留作「捏造/主動操控」未做維度的定義,現況以資訊網 arc 收官記錄+完工清單為準。

**現有**（`distortion_engine.gd` 單一 owner）＝兩種、都寄生真訊息：
- **竄改轉述**（malicious relay）：轉述真訊息時扭曲數值／位置／身分（嫁禍）。
- **被觀察時自我欺敵**：被刺探時偽裝平民／虛張聲勢／弱隊謊稱屬大勢力。人格驅動（計謀/信義），但只針對「自己被看時」。

**缺**：**主動捏造＋散播完全虛假訊息**（「偽造軍情」——編一個沒發生的事丟進謠言網操縱第三方）。缺兩塊：①決策引擎無「散布謠言」option ②`emit_message` 只綁真事件、無「發一則不綁真事件」的口。

**★但框架放得下（不必後面重構）**：四塊建三塊——
- 捏造的**決定** → 決策引擎加 option（計謀高＋有動機者穿過人格的秤決定造謠）＝合統一框架。
- 散播**管路** → 現成（emit＋propagation）。
- **後果反噬** → 現成：`reconcile_firsthand` 拿親見比對轉述、抓到說謊降來源名聲 → 造假一接上就吃這代價。
- 缺的僅：捏造 option ＋「訊息可不綁真事件」的口。

→ **路線圖項，非急**；等情報操控維度開建時做，現框架承接。


## ★採集 material 在 warring 塌掉 −97%（具名，2026-08-27 S2 終量抓到）

```
before 0ab34123 = 1.85/日 (n=240)  →  bcbfb6f3 = 0.09/日 (n=7)  →  b05750ef = 0 (key 不存在)
                                    ↑ ★★★-97% 在這一格
```
★**要解釋的事件是 `240 → 7`，不是 `7 → 0`**（後者是已塌量的尾巴，n=7 本來就在雜訊層）。
★★**嫌疑犯已鎖定在 `0ab34123 → bcbfb6f3` ＝【`MSG_TTL` 修復那個 commit】** ——
★★★**同一個 commit 上：訊息送達 +55.4%／採集 material −97%。★不宣稱因果，但它有同 commit 的鄰居。**
★**已排除**：`bcbfb6f3 → b05750ef` 的純觀測 tap commit（`fp` 逐位元相同 `4f1c0eda…`）。
★**peaceful 那床 material 採集健康**（34.35/日，+1.0%）⇒ **這是 warring-bed-specific 的塌陷。**
**下一步**：**先看 S3 終量**（決策/送達同源嫌疑）；★**別在沒有 S3 數字前開它。**
出處：`docs/process/verdicts/S2-purity-final.measure.json`、`docs/superpowers/specs/2026-08-27-S2-root-reanchor-HOW.md §S2 結案`

## ★★detail 檔的節【重複 4×】且副本已分歧（2026-08-27 發現，★早於今天、不是今天造成）

```
01_architect-cases.md   節 134 / 相異 43  ⇒ ★重複率 67%
invariants-cases.md     節  60 / 相異 39  ⇒ 重複率 35%
其餘四份 detail：0〜9%（乾淨）
★git 追溯：2c387154~1（今天所有動作之前）就已經是 4× ⇒ 早於今天
```
★**試過機械去重（保留內容最多的那一份）⇒ 失落行 62／58** ⇒ ★★**副本【已經分歧】，不是純複製** ——
**⇒ 沒有寫回，因為「保留最長的一份」會刪掉只存在於別份的內容。**（同「extreme ctx 別 rush 半破壞大重組」。）

### ★★★而它立刻污染了一個【我今天用過兩次的驗證法】
> ★**「壓縮主檔前，先驗節標題在 detail 逐字命中」** —— ★★**重複的副本會讓這個檢查【被滿足】，**
> ★★★**而我檢查的是哪一份、血證在不在那一份，它答不出來。**
⇒ ★**修正**：**驗證要問「內容在不在」而且要問「在【哪一份】」** ——
**單純的 `grep -c 標題` 在有重複副本的檔案上是【恆真式】。**

**下一步（未排期）**：**逐節 union 合併**（不是保留最長），**做之前要先有「合併後不得失落任何非空行」的機械驗證**（本次那個守衛就是它）。

## ★★★製造觸發 −7.5%（peaceful）—— **未歸因【但已刻畫】**（2026-08-27 結案掛 R①）

★**麵包屑（R① 重看時從這裡下刀，不必從零開始）**：
```
桶              before  after       Δ        （entry 加總 864 == 864，Δ 加總 0，對帳成立）
fired             215    199     -16
no_outpost         36     29      -7
no_worker          30     43     +13
★no_facility      318    382     +64   ←★★主戲
★no_material      265    211     -54   ←★★近乎【對調】
```
★**出口語意**（`manufacturing_system.gd:127-142`）：
`no_facility` ＝「**我想做的東西，一個都沒有對應設施**」；`no_material` ＝「**有設施，但料不夠**」。
★★**而設施普查兩邊【完全相同】**（`manufacturing_level=3 / apothecary_level=6 / smelter=weaponsmith=armorsmith=0`）
⇒ ★★★**設施沒變，而「想做什麼」變了 ⇒ 【需求側】位移，不是供給側** ⇒ 指向 `NeedOracle.need_keep / demand`（`:182`）。

### ★兩個【已死】的假說（★寫下來免得下一輪重走）
```
①★「blind-view（投入只讀私產）造成」⇒ 死：修完後公庫路徑 tried = 0 ⇒ 那機制從未綁
   ★★（而 blind-view 本身是真缺陷、已修、陽性對照 v3 證明接得上——只是與這個殘差無關）
②★★「arc 打開據點漏斗 ⇒ 稀釋」⇒ 死：|Δno_outpost| = 7 撐不起下游 39（差 5.6 倍）
```
★★★**兩次都有 file:line、有機制、方向也吻合，而兩次都錯** ⇒ **這個殘差抗拒顯而易見的解釋，第三個故事不要憑機制猜。**
出處：`docs/process/verdicts/S2-manufacture-arithmetic-falsify.measure.json`

## ★五支決策支的【選擇】沒有落在可比較的持久欄位 —— 可觀測性缺口（2026-08-28）
```
ALLIANCE / BETRAY / INFRA / FACTION_UPDATE / INDEP_INFRA
⇒ 量「這次重評有沒有【改變選擇】」時,★它們【量不到】(沒有可比較的前後值)
⇒ ★★輪詢獨特貢獻率因此只涵蓋 9 支裡的 4 支
```
★**不開票的理由**：**要它們進分母 ＝ 讓選擇落到持久欄位 ＝【改行為】不是【加 tap】** ——
★★**而輪詢不退場已由 `GOAL` 的 147 筆獨立定案，補不補都不改結論；為量測而改 production 語意，方向上是「讓儀器改變被觀測物」的鄰居。**
★★★**on-touch 義務**：**下次動那五支任一支時，順手把選擇落到可比較的持久欄位。**
★**而它不只影響輪詢**：**哪天要做決策品質稽核（例：「rung 變了而意圖不動」那條），那五支同樣量不到。**

## ★★分類建立在一個【正在被修的 bug】上 —— `LADDER` 的「②不退」待重判（2026-08-28）
★**三支退場判準把 `LADDER` 判成「②貢獻率 > 0（9.0%）⇒ 不退」。**
★★**而 ⑧ 顯示那 24 筆【全部】有更早的事件喚醒（中位間隔 3.1 日）** ⇒ **輪詢補的是【事件在間隔裡漏掉的】。**
★★★**而事件路徑整體落空 12.5%（28,385 次喚醒消失）正在被雙緩衝修** ——
⇒ ★**若 9% 的來源是 emit-loss，它是【bug 的產物】不是【機制的性質】** ⇒ **修完後 `LADDER` 可能變成「①真冗餘」。**
★**已登記預測（修完貢獻率應下降）＋證偽條件（沒降 ⇒ 是 emit 覆蓋問題不是順序問題）。**
★★**而總結論不變**：**輪詢不退場的理由是 `GOAL` 的 147 筆「之後再也沒醒」，與 `LADDER` 無關。**
> ★★★**通則：一個分類若建立在【正在被修的東西】上，修完必須重判 —— 而重判要在【預測登記之後】才有意義。**

## ★LADDER 是唯一「選擇真的會變」的那一支 —— 具名記錄（2026-08-28，不現在修）
```
★兩個【獨立】量測指向同一支:
   ①輪詢獨特貢獻率:LADDER 9.0%(其餘支 0.0%)
   ②丟失喚醒的「下一次走訪選擇改變率」:LADDER 9.81%(聚合 warring 4.59% / peaceful 1.69%)
```
★**不現在修的三個理由**：**①該量測只涵蓋 35% 的丟失母體 ②修法（per-actor 消費）是【全域機制】，為一支造它不成比例
③★而 LADDER 的正解可能不是「旗子活久一點」，是【它的消費者走訪太稀疏】—— 那是別的軸。**
★★**觸發**：**若 LADDER／野心階梯的【選擇品質】成為議題，這一格是現成的起點。**
★**而 `t0-emit-ordering` 這條線的結論是【不修，具名記錄】** ——
**雙緩衝已回滾（`fp` 回基線一字不差），旗子命運儀器保留、現在量的是真實現況。**

## ★`harvest_system` 還有三個【無名骰子】（2026-09-01 記；★2026-09-02 systems 複驗：**錨精準、數目相符**）

★複驗：`harvest_system.gd:84`／`:101`／`:120` 三顆 `randf()`（野馬／野味／掠食者 regen），**不多不少三顆** ⇒ 條目可直接開票，不必再查。

**狀態：已知未實裝** ｜ **回訪：觸發事件 — S5b 完成，或野地再生的隨機性成為議題時**
★**不是缺陷未修**：那三顆骰子現在【正常運作】，要換掉是 WHAT 偏好（噪音來自有名字的事件）。
★★**而條目自帶的警告 blueprint 追認要尊重**：**刪一顆 `randf()` ⇒ 之後每顆骰子都換人擲 ⇒ 世界大幅位移**
——★★★**它正是「觀測儀器禁耗 global RNG」那條不變量的立法理由**（同一個物理：動一顆骰子＝洗掉所有既有 seed 的世界）。

## （原文）★`harvest_system` 還有三個【無名骰子】（2026-09-01，S5a merge 時記，★不夾帶）
```
harvest_system.gd:84  randf() < WILD_HORSE_REGEN_CHANCE
                 :101 randf() < WILD_GAME_REGEN_CHANCE
                 :120 randf() < PREDATOR_REGEN_CHANCE
```
★**S5a 只移除了 `harvest_factor` 的 ±25% 亂擲（已驗：那顆確實沒了）** —— **這三個是別的機制。**
★★**而 WHAT 的原則是「噪音來自【有名字的事件】，不來自無名骰子」** ⇒ ★★★**它們是同族候選。**
★**不夾帶進 S5b（一次一類）** —— **觸發：S5b 完成後，或哪天野地再生的隨機性成為議題。**
★★**而要動它們的人要先知道**：**刪一個 `randf()` ＝ 之後每顆骰子都換人擲 ⇒ 世界大幅分岔**（S5a 血證）。

## ★★★g1a 礦村未鑄幣 —— **根：繞過仲裁的路獨佔施工格**（2026-09-02，★框架被量測連改三次）

**狀態：已知未修** ｜ **回訪：觸發事件 — 急症走廊那條被拆時**（★B 級 sweep 補欄 2026-09-04）

★★**終態（blueprint 預填）**：**修已 merged**；剩下的是**急症走廊拆**那一段 —— ★而它不在本條目，另有歸屬。

★**三次重定框架，每一次都是量測推翻上一個**：
```
①「復發」（修法失效）  ⇒ ★推翻：舊修法 `headless_test.gd:15658 統領=0.5` 【還在且仍有效】（pop 沒被拆走、隊真的在蓋）
②「建設優先序」        ⇒ ★★推翻：在【唯一一個 mint 與 farming 同秤】的地方，★★★mint ＝ 8.640 贏 farming ＝ 1.279（6.8 倍）
③★★★【真根】：三次開工【全部】來自「自救建田」那條路
```
★**結構（systems 複驗）**：
```
`_food_rescue_eval`（faction_ai_system.gd:5271）→ 它的 facility ★【對 `_pick_facility` 零參照】⇒ 繞過設施仲裁
`_evaluate_infrastructure:5067` → `if tile.construction_team_id != -1:` ⇒ ★★仲裁路【跳過該格】
⇒ ★★★一條【繞過仲裁】的路反覆佔用【唯一施工格】⇒ 仲裁路永遠看到「有人在蓋」⇒ mint 排不進去
```
★★**所以它不是「mint 分數低」也不是「優先序設錯」** —— **mint 根本沒有上秤的機會**（★而它上秤時贏 6.8 倍）。
★★★**同族**：`disband` 繞過 `set_team_faction`／`release()` 漏清欄位 —— **一條路繞過仲裁點，而仲裁點對它無感。**

**狀態：已知未修** ｜ **回訪：到期 token — 待 blueprint 裁「自救建田該不該享有繞過設施仲裁的特權」**
（★HOW 這邊兩個方向都做得出來：導回仲裁／讓仲裁能 preempt；★★而它們是不同的世界，我不替他選。）

## （原文，框架已於上方連改三次）★★★g1a 礦村未鑄幣 —— 框架訂正（2026-09-02 先查＋3 seed dump）：不是復發，是【建設優先序】

★**舊修法【還在而且仍有效】**（implementer 實測）：`headless_test.gd:15658` 的 `統領=0.5` 在位，
**pop 沒被拆走、隊真的在蓋** ⇒ ★★**「同一症狀復發、修法失效」這個框架【不成立】。**
★★★**3 seed 逐日 dump 顯示那 25 天【被 farming 佔滿】**：`farming×3／farming×3／farming×2+mint×1`，
**餘工期零停滯** ⇒ ★**不是「料斷了」，也不是純「mint 工期太長」——是【優先序】：mint 排不進去。**

⇒ ★★**真問題重問**：**為什麼建設選擇每次都選 farming？** —— ★★★**而這是【決策問題】**，
照既有紀律 **先 dump 建設選項的 per-option util（含贏家組成）再開藥**，**不是調 mint 工期或加料**。
★**第一問同 #12**：**farming 贏得對不對** —— 一個沒糧的村先蓋田**可能完全 genuine**。

**狀態：已知未修** ｜ **回訪：到期 token — 建設選擇 util dump（與 #12 同一批，兩者都是「引擎為什麼不選它」）**

## （原文，框架已於上方訂正）★g1a 礦村未鑄幣【復發】（2026-09-01 記，systems）
```
現象：headless_test 比 baseline 多紅一項 [g1a] 礦村未鑄幣（★HEAD 與改名後同樣紅 ⇒ 非 S6 造成）
★而 headless_test.gd:15657 的註解【自己就記著這個症狀與成因】：
   「殘隊跑不動 collect/mint（[g1a] 礦村未鑄幣）。main 沒露是因舊 PRODUCE 走 leader-independent」
   ⇒ ★★前一次的修法就在下一行 :15658 `ldr.skills["統領"] = 0.5`
⇒ ★★★所以這是【復發】：同一個症狀被修過一次，現在又紅了 —— 而修法還在原地
```
★**處置**：已帶三欄入 `test-baseline-failures.txt`（**不無標記洗綠**）。
★★**未做**：沒有 bisect 找復發起點（headless 每跑一次很慢，且會動到別人 branch 的判讀）。
★★★**而真正該問的不是「哪一顆 commit」，是【為什麼同一個症狀能復發而沒有人被通知】** ——
**知識寫在註解裡，而閘不讀註解。**

## ★★★★床的 setup 盲區 ⇒ **真盲 0 張**（2026-09-02 重定性；★原記「結構性盲區」）
```
★閘印：已遷移 5 ／ 未遷移 272 —— ★★而【272 不是盲區規模】（★★★閘那句話是錯的，已修）
★真實剩餘：272 → 9（靜態篩出「arm 在 setup 之後」）⇒ ★★而 9 張【逐張讀完 0 張真盲】
★★★成因：「arm 在 setup 之後」有【兩種相反的意思】，而它們在 code 上長得一模一樣
   ①床先 setup 世界、再 arm ⇒ 真盲　②床 arm 之後又呼叫 setup（重置／多世界）⇒ 不盲
★而 implementer 的第一版判準錯（把【註解裡】的 `GameSetup.setup()` 當成呼叫）—— ★★是【陽性對照】抓到的
```
★**所以本條的剩餘是【0】** —— ★★**而 helper／閘／runtime 自檢都已落地，防的是【未來】不是存量。**

（以下為原始記錄，保留供溯源）
## ★★★床的結構性盲區：`Probe.reset()` 在 `GameSetup.setup()` 之後（2026-09-01，measurer 自揭）
```
TERRAIN_WEIGHTS(world_generator.gd:215) 在 setup 階段套用
而床的 Probe.reset() + enabled=true 在 setup 【之後】才跑
⇒ ★兩根兩床皆 0 —— 而那是【結構性量不到】,不是「沒發生」
```
★**這不是那張床的 bug，是【所有床】共通的**：★★**setup 階段發生的一切，對 Probe 是不可見的。**
★★★**而 0 在報表上長得跟「沒發生」一模一樣** —— 這次是量測員自己抓到並明列排除，**沒有混進判讀**。
⇒ **修法已示範**：`scripts/debug/s7_rootdiff_bed.gd:14-20`（commit `f91c401c`）——
   `Probe.reset()` / `enabled = true` 移到 `GameSetup.setup()` 之前，sanity 驗過
   `TERRAIN_WEIGHTS`（setup 階段常數）現在量得到（383 總數）。

★★★**而其餘的床【全部沒改】** —— 且**逐床改不可行**（床有上百張）。
⇒ ★**真解是【共用起手式】**：床的 arm 動作要有一個共同入口，改一次全體跟。
⇒ ★★**在那之前，這一條的狀態是【一張床修好了，盲區還在】** ——
   ★★★**而「示範過修法」與「問題解決了」是兩件事，不要因為看得到修法就把它當已結案。**

## ★★★★settlement_s2b_test 紅 ＝ **床是對的，世界錯了**（2026-09-02 重定性；★原記「一張紅著沒人讀的床」）
> **回訪：觸發事件 —— blueprint 對「原地重複紮營」定性之後。**
```
★★★implementer 查證：★該床【不是 fixture 壞】，也【不是測一個不存在的行為】
   ⇒ 它在 2026-08-21 `bdad0174`（紮營 de-patch：拿掉瀕餓門檻）那天【變紅】
   ⇒ ★★而現在的世界行為是：★★★【站在自己 L0 營地上，「再紮一次營」贏過「把它升成 L1」】
★證據：逐 option util dump ＋ 該 commit 的 diff
```
★**所以它一直在對我們喊，而我們判它【壞了】** —— ★★**紅了 12 天，而沒有人讀。**
★★★**而我 2026-09-01 的裁定（「修 fixture 不拆」）也錯**：**沒有 fixture 可修。**
⇒ ★**這不是 D 級文件事** —— **是【行為病】，等 blueprint 定性與分級。**

（以下為 2026-09-01 的原始記錄，保留供溯源）
## ★settlement_s2b_test：**一張紅著、沒有人在讀的床**（2026-09-01）
```
整床 18 紅（HEAD 上同樣紅，非 S6 造成）；第一條「設 construction_target action=crude_camp」就失敗
⇒ 紮根在該 fixture 根本沒 fire ⇒ 後面全滅
⇒ ★而我原本要拿它當 S6 的 gate ——【一張本來就紅的床，改錨也紅，證明不了任何事】
```
★**處置**：S6 的「改錨必紅」改放進真的是綠的新床（`s6_phase2_single_source_bed.gd` 驗收⑦）。
★★**待做**：修 s2b 的 fixture（低優先，但**具名**）。

### ★★★而這裡有一個更大的問題我沒有答案
> **有多少張床是「紅著、沒有人在讀」的？**

★**紅著沒人讀的床 ＝ 假守衛**：★★它看起來是覆蓋，實際上什麼都沒守，
★★★**而它比沒有床更糟 —— 因為有人會以為那一塊被蓋住了。**
⇒ **這是可數的**（跑全部床、看 fail>0 且不在 baseline 者），**但我還沒數**（★而我今天已經因為憑印象給數字錯了三次）。

## ★★★44 處團級 burn 估算漏算 `minor_population`（2026-09-01，型③ 對帳所得）
> **回訪：量測窗 —— 世界平均 `minor_population / population` 佔比量出來的那一輪。**
```
★執行端 `resource_system.gd`：`total_pop = population + minor_population`（★另扣馬匹草料）
★★而估算端【44 處】只用 `population` ⇒ 低估 burn ⇒ `food_days` 高估
⇒ ★★★隊【以為自己撐得比實際久】
★而馬匹草料【沒有任何估算端算進去】⇒ 有馬的隊高估更多
分類（implementer 逐條分完，★非上界）：團級漏 minor 44 ／ 含 minor 4 ／ 每人份 7（總 55）
```
★**形狀 ＝【手不聽腦的鏡像】**：**執行端正確、估算端系統性樂觀** ——
★★**而它不會 crash、不會有測試紅，只會表現成「隊一直誤判自己撐得住」。**

### ★嚴重度：**中高，但先量再開票**（systems judge 2026-09-01）
```
★44 處逐處改是大工；★★而偏差幅度【取決於 minor 佔人口的比例】—— 而那個沒人量過
⇒ ★★★若 minor 佔比很小 ⇒ 偏差可忽略 ⇒ 44 處改法不划算
   若佔比可觀（例如 >15%）⇒ 所有糧食決策系統性樂觀 ⇒ 值得開票
⇒ ★所以回訪條件綁【量測窗】而不是「下次有空」
```
★★**而這一條【不准躺回「上界」裡】**（blueprint 明令）——★★★**它現在有分類數字、有形狀、有回訪條件。**

## ★44 處 burn 漏 minor —— **裁定不開票**（systems 2026-09-01）
> **回訪：觸發事件 —— 若日後量到 `minor_population` 佔比 > 5%（見上「30 日窗零出生」條）。**
```
★量測結果：30 日窗內 minor 佔比【逐位元 0.0000】⇒ ★★那 44 處的偏差在這個窗內【恰好為零】
⇒ ★★★裁定：不開票（44 處逐處改的成本，換不到任何當下的正確性）
★★而【效力邊界】必須跟裁定寫在一起：★★★這只說「30 日窗內沒差」，不說「那 44 處是對的」
   —— 它們仍然是【估算端與執行端不同母體】，而那個結構性錯誤還在
```
★**所以這條不是「已修」也不是「不是問題」** —— ★★**是【它的傷害目前為 0，而傷害為 0 的原因是另一個病】**（世界沒有新生兒）。
★★★**若繁殖那條被修好，這 44 處會【同時】變成真的錯** —— 而回訪條件正是綁在那裡。

## ★人口不成長：**90 天只生 1 個**（2026-09-01 正式記；★不是迴歸，是長期低速率）
> **回訪：觸發事件 —— blueprint 裁定「這個世界的人口該不該成長」之後。**
```
★實測 A：seed 1337 ／ peaceful_economy ／【90 天】⇒ `breed.born = 1`
   出處 `docs/process/verdicts/breed-verify-and-deathcause.measure.json`
★實測 B：兩床（peaceful＋warring）／【30 天】／3060 個 team-day ⇒ minor 佔比【逐位元 0.0000】
   ★★而 B 與 A【一致】：30 天的期望值 ＝ 1×30/90 ＝ 0.33 ⇒ 觀測 0 在預期內
★★★機制實存（`reaction_system.gd::_tick_breed` —— ★★2026-09-01 二度訂正：先前寫 `breed_progress`（欄位，定義在 team_data）再寫 `_evaluate_life_events`（★【退休空殼】`:253 return []`，同檔 :90 註解自述生育已移出）⇒ 真正累積在 `_tick_breed:302`）、分母從未為 0 ⇒ **不是死碼、不是母體空**
```
★**曾被我誤讀成【重錨後迴歸】並升成主案 —— 而那是【窗長沒對齊】造成的假訊號，已撤。**
★★**所以這一條【不是「誰弄壞了它」】，是【它本來就這麼慢】** ——
★★★**而「這麼慢算不算病」是願景問題**：一個 90 天生 1 個的世界，可能是設計，也可能是斷掉。
⇒ ★**在 blueprint 裁定之前，不派任何歸因票** —— **歸因的前提是「它應該是別的樣子」，而那還沒有人說過。**

## ★★★★【已結案】warring 90 日 **跑得完** —— 舊框架「量測能力的上限」**推翻**（2026-09-04）
★**狀態：已知未修**｜**回訪：觸發事件 —— 下一次要在 warring 上開長窗時（★問的是【成本】不是【能不能】）**
```
★[PilotRun] wall_clock_s=10159.7 ｜ completed=yes ｜ window_days=90 ｜ seed=1337
   ⇒ ★★169.3 分鐘、9 段心跳全在、★0 個 GODOT TIMEOUT
★★★三個候選【全部排除】:
   ①計時器 —— 對照探針兩支活滿 90 分 ＋ 本跑 169 分
   ②固定天數 —— day 53 那道早就越過
   ③記憶體 —— 71.5 → 254.8 MB 單調上升【而沒有崩】
```
★★**而記憶體那條是【預先寫下的預測】**：day 40 時外推「day 90 約 250 MB」，**實測 254.8 MB**
⇒ ★★★**那是預測不是事後對帳** —— **而它同時把「記憶體會撞牆」這個候選【量化地】排除掉。**

### ★成本（★這才是新的約束）
```
warring 90 日 = ★169.3 分鐘 ｜ peaceful_economy_regime 90 日 = 431 秒（7.2 分）
⇒ ★★約 23.6 倍 ⇒ ★★★所以判準⑨(窗 ≥ 被量機制的一個週期)在 warring 上【不是做不到,是貴】
⇒ 而「多 seed × warring × 90 日」＝【小時級 × seed 數】—— 排程時要先算這個
```
★**舊結論「兩次失敗原因未知」仍然成立**，★★**但它的地位變了**：
**不是「找不到兇手所以不能長跑」，是【長跑會偶爾中斷，而中斷已經不昂貴】**（逐段落地）。

## （原文，框架已於上方推翻）★★★warring 床的長窗（90 天）跑不完 —— **而它是量測能力的上限**（2026-09-01）
★**狀態：已知未修**｜**回訪：見上方結案段（★本段為原文留存，框架已被 2026-09-04 的 completed=yes 推翻）**

★★★**第三次確認（2026-09-04 pilot）**：warring 90 日 **死在 day 53／90**，`SCRIPT ERROR 0`／`Assertion 0`、
輸出停在正常日誌中間 ⇒ **又是外部被砍，不是引擎失敗** —— ★**而這次是 systems 派工時沒回查本條目，把 pilot 派進了已知的牆。**
★★**同輪副產物（比失敗本身有用）**：**免費補答三項一項都沒撈到** —— 它們全印在【跑完之後的報告區】
⇒ ★★★**一個被砍的跑【什麼結論都不留】，只留逐日 `TickPerf`** ⇒ **長跑的結論必須【逐段落地】，不能堆在結尾。**
> **回訪：觸發事件 —— 下一次有機制需要 warring 床的【長窗】才量得到時。**
```
★兩次 warring 90 天（GODOT_TIMEOUT=3600s／7200s）都在完成前【被外部殺掉】
★★而【不是】GODOT_TIMEOUT 自然到期（log 沒有 TIMEOUT 字樣）—— 是更外層的東西
★peaceful 90 天同一輪【跑成功過】（約 90 分鐘量級）
★★★**成本驅動訂正（2026-09-04 pilot 實測）**：`peaceful_economy_regime` 90 日 ＝ **431 秒**（不是 90 分鐘）
⇒ ★**「90 分鐘」那個前例是【另一個世界】**（warring 64 隊 vs peaceful 23 隊）
⇒ ★★**長跑成本由【隊數】決定，不由【天數】決定** —— **而我先前把它當成「天數的下界先驗」是錯的比法。**
```
★★★**而它的後果是結構性的**：**判準⑨（窗 ≥ 被量機制的一個週期）在 warring 床上【可能無法滿足】**
⇒ ★**也就是說：週期長於可跑窗的機制，在 warring 上【永遠量不到】** ——
★★**而「量不到」與「沒發生」長得一模一樣**（★★★今天已經數過這個形狀四次）。

### ★而兩次的失敗模式【不同】，不該併成一個原因（systems 2026-09-01）
```
第一次：跑了一陣才被殺 ⇒ ★與「長跑撞到外部中斷」相容
第二次：★★連 day10 checkpoint 都沒撐到、【0 字節】⇒ ★★★那不像「跑太久」，像【啟動階段就死】或【寫檔失敗】
```
★**量測員歸因成「warring 隊數長到 200+ 比較重 ⇒ 長跑更容易被殺」** ——
★★**那對第一次成立，對第二次【不成立】。**
⇒ ★★★**分辨已做（measurer，2026-09-01）**：**warring 10 天短窗【正常完成】**（84742 bytes、完整 DONE 輸出）
   ⇒ ★**「啟動階段就死／寫檔失敗」被證偽。**

### ★★★而它同時讓【長跑假說】更難解釋第二次（systems 2026-09-01）
```
★第二次是【連 day10 checkpoint 都沒到】就 0 字節
★★而跑到 day10 所需的計算量，90 天窗與 10 天窗【完全相同】
⇒ ★★★所以「跑得久所以被殺」解釋不了它 —— 在 day10 之前，兩者根本沒有差別
```
★**結論：兩次失敗的原因【仍然未知】** —— ★★**證偽了一個假說，而剩下那個對第二次解釋力不足。**
★★★**而這一格要留著**：**「支持長跑方向」不等於「已解釋」** —— 否則下次有人會拿它當已知原因。

### ★★★★第四次資料點（2026-09-04）：**wrapper 自己砍會【留痕】** ⇒ 而它重開了第二次的成因
```
★tools/godot.ps1:131  if ($timedOut) { "[GODOT TIMEOUT ${timeoutSec}s - process killed]" }
   ⇒ ★★【無條件】印 ⇒ 標記在 = wrapper 自己砍的
★血證:implementer 第一次派 detached warring,在啟動腳本設 $env:GODOT_TIMEOUT=14400
   ⇒ ★★【沒有傳進子行程】⇒ wrapper 用回預設 360s,day 11 砍掉,★而它印了標記
   ⇒ 所以他【沒有】把它誤記成第三次「被外部殺」
```
★**而他順著推「前兩次 log 沒有標記 ⇒ 外部殺更硬」—— 這一半要收窄（systems 2026-09-04 查證）**：
```
★第二次那份 = docs/measurements/s7surplusbirths-warring_states-90d.txt ⇒ ★★【0 bytes】
⇒ ★★★那裡的「沒有標記」不是證據,是【儀器什麼都沒產出】
   ⇒ 「marker 不在」與「檔案裡什麼都不在」不能算成同一件事
```
★★★**而這顆新資料反而給第二次一個【比舊假說好的解釋】——記成假說，不記成結論**：
```
★舊帳寫「連 day10 checkpoint 都沒到 ⇒ 不像跑太久」,而【0 bytes 也可能是輸出從沒落地】
★★同型血證(systems 自己踩過):跑閘時用 `| tail -18`,被砍時得到【0 bytes】—— 管線緩衝沒 flush
   ⇒ ★★★所以第二次可能是【儀器失效】(輸出被緩衝/截斷)而不是【世界失效】
⇒ ★而它有一個【免費檢定】:現在跑的那顆 warring 用的是【串流版 wrapper】+ 逐日 HEARTBEAT
   ⇒ ★★若它再被砍而【留下部分輸出】⇒ 緩衝說成立;若又是 0 bytes ⇒ 緩衝說被證偽
   ⇒ ★★★兩種結果都有意義,不必為它單開一跑
```
★**本條仍然【不結案】**：舊結論「兩次原因未知」不變 —— **本節只是把第二次的候選解釋換了一個更像的，並附上怎麼驗。**

### ★★★★第五資料點（2026-09-04）：**計時器那一支【否掉】，而「day 53 那道牆」仍未受測**
```
★兩條獨立證據否掉計時器:
   ①對照探針 TIMER-ATTACHED / TIMER-ORPHAN 【兩支都活滿 90 分】並自報 SURVIVED-90MIN
     ⇒ harness 任務層在 90 分內沒有計時器
   ②warring 本輪 61 分鐘仍在跑 ⇒ 越過前次的【59.5 分】
⇒ ★★「死在固定 wall-clock」與「工具鏈有計時器」都不成立
   ⇒ ★★★而 59.5 ≈ 60 那個「看起來有意義的巧合」被打掉了
```
★★**而 systems 訂正一句（2026-09-04）：前次是 `day 53／59.5 分`，那是【兩道牆】**
```
★本輪 day 47 @ 61 分 ⇒ 越過的是【wall-clock 那道】
★★【day 53 那道】仍未受測 —— 本輪還沒跑到 day 53
⇒ ★★★所以「死在固定天數」目前【既沒被證實也沒被否證】,不得寫成「已排除」
```
★**附一個會污染比較的因素**：本輪 day/分鐘速率比前次慢約 23%（day 47@61 分 vs day 53@59.5 分），
而**同機還有 30 日 `unit-overlap` 在跑**（`EXCLUSIVE=unknown` 是 implementer 自己降的）
⇒ ★★**時間類讀數在並跑下不可比** —— **這不推翻計時器否證（活得更久仍是有效證據），但它讓 day 53 的檢定點【延後到更晚的 wall-clock】。**

### ★★★★★第六資料點（2026-09-04）：**day 53 那道牆也過了 ⇒ 前兩次的死因【不是確定性的】**
```
★12:48 進 day 54,輸出 712 KB 持續長大 ⇒ ★★兩道牆都不成立:
   wall-clock 那道(61 分)過了 ／ 天數那道(day 54)過了
⇒ ★★★同一支 code、同一個世界、同一個窗,這次【走過了前兩次死掉的位置】
```
★★**而「不可重現」本身就是結論** —— **它不是「還沒找到原因」，它是【原因不是確定性的】。**
⇒ ★**處置跟著換**：**停止找確定性兇手，改成把長跑當【機率性易碎】處理**
```
★已做:逐段落地(串流 wrapper + 逐日 TickPerf + 每 10 日 HEARTBEAT)
   ⇒ ★★被砍時留得下已跑段落 ⇒ 【一次中斷不再等於一次白跑】
★★★而這才是這條 backlog 的真正出口:不是「查出兇手」,是「中斷不再昂貴」
```
★**剩下的活候選只有記憶體**：day 50 ＝ 189.1 MB，斜率仍在收斂 ⇒ **不像會在窗內撞牆。**

### ★★「0 bytes」那個形狀：**緩衝說站得住**（2026-09-04）
```
本輪輸出從 day 1 起持續落地(61 分時 482 KB,逐日 TickPerf + 每 10 日 HEARTBEAT 都在)
⇒ ★就算之後被砍也留得下已跑段落
⇒ ★★所以第二次那份 0 bytes【不是「跑太久被砍」的必然結果】,
   是【舊的非串流 wrapper + 被砍】的結果 —— ★★★儀器失效,不是世界失效
```
★**剩下的活候選只有記憶體**：`71.5 → 132.2 → 156.3 → 172.9 MB`（day 10/20/30/40），
**單調上升而斜率收斂**（+60.7 → +24.1 → +16.6／10 日），線性外推 day 90 約 250 MB
⇒ ★★**不像會在窗內撞牆** ⇒ ★★★**若它照樣跑完，那是【三個候選全被排除】—— 而那本身是乾淨的結果。**

## ★★★信箱的 `consume` 標記會【消失】—— 而成因未知（2026-09-01）
> **回訪：觸發事件 —— 下一次有信被【重送】或 watchdog 點名一件已處理的事時。**
```
★血證：`2026-09-01-blueprint-to-systems-unknowns-need-filing.md` 我 consume 過，而它【又回到 open】
★★查 git log：該檔只有【兩顆】commit —— blueprint 的原信 ＋ 我事後補標的那顆
⇒ ★★★我先前的 consume【從未進版本】
```
★★★★**成因已定案（implementer 2026-09-01，而它是候選④的【更兇版本】）**：
```
★consume 標記被【別 session 的 commit 掃入】（他親身被掃：`4b75a559` 帶走他的 consume）
★★而那顆 commit 後來被 `git revert` ⇒ ★★★標記【跟著回退】⇒ 幽靈喚醒
證據：`30e619dd`（revert）—— 兩封信 consumed → open
★★★★而【一封信被整檔刪掉】：`2026-09-01-systems-to-qa-i-broke-your-watcher.md`
   —— 它是我寫給 qa 的告知信（我測試時頂掉他的 watcher），被那次 revert 連帶刪除
   ⇒ ★已從 `168afeb5` 還原（2026-09-01）
```
★**所以「立刻 commit」是對的方向但【不保證】**：★★別人 `git add -A` 仍可能搶先掃走它，
★★★**而真正致命的是【revert 會把別人的東西一起帶走】** —— **revert 的粒度是 commit，不是意圖。**

---
（以下為定案前的候選清單，保留供溯源）
★**三個候選成因，我【不知道是哪一個】**：
```
①sed 當下沒有匹配（★而 sed 不匹配是【靜默】的，回傳碼仍是 0）
②`git add` 那一輪沒有帶到它
③★多終端共 main dir ⇒ 被別 session 的操作蓋掉（★★memory 有同型血證）
★★★④（blueprint 補，2026-09-01）：**共 main dir 下 consume【原地改而未即 commit】**，
   窗內他人的 git 操作（checkout／merge／sweep）覆蓋
   ⇒ ★**這是「WIP 掃入事故」家族的【鏡像】**：那次是【被掃走】，這次是【被蓋掉】
```
### ★★severity 升檔：**它在燒真 token**（blueprint 旁證 2026-09-01）
```
★他今天收到【同一封信】的重複 📬 喚醒【至少 5 次】
   （spike-periodic ／ closeout-repriced ／ RETRACT-regression …）
⇒ ★★與「consume 丟失 → watcher 再見 open → 再喚醒」完全一致
⇒ ★★★每一次幽靈喚醒 ＝ 一輪 —— **這不是衛生問題，是成本問題**
```
### ★★★修法（已立即施行）：**consume 之後【即刻 commit】，不累積到回合末**
```
★我原本的做法：consume 後改檔，累積到回合末一起 commit ⇒ ★★那個窗有數十分鐘
⇒ ★★★而候選④ 說的正是那個窗 —— 【我就是那個窗】
⇒ 改成：consume ⇒ 立刻 `git add <該檔> && git commit` ⇒ 窗縮到秒級
★成本：多幾顆小 commit；★★收益：消掉幽靈喚醒（每次一輪）
```
★★**機械防線（已開始做）**：★★★**consume 之後 `grep` 驗一次** ——
**跟「commit 之後驗內容不驗退出碼」是同一條：【做了】與【留下痕跡】是兩件事。**
★**而這次是 hook 把它抓回來的** ⇒ 系統運作正常，只是我以為做完的事沒有痕跡。

## ★★★信箱的 consume 標記會【消失】—— 而成因未知（2026-09-01）
> **回訪：觸發事件 —— 下一次有信被【重送】或 watchdog 點名一件已處理的事時。**
```
★血證：`2026-09-01-blueprint-to-systems-unknowns-need-filing.md` 我 consume 過，而它【又回到 open】
★★查 git log：該檔只有【兩顆】commit —— blueprint 的原信 ＋ 我事後補標的那顆
⇒ ★★★我先前的 consume【從未進版本】
```
★**三個候選成因，我【不知道是哪一個】**：
```
①sed 當下沒有匹配（★而 sed 不匹配是【靜默】的，回傳碼仍是 0）
②git add 那一輪沒有帶到它
③★多終端共 main dir ⇒ 被別 session 的操作蓋掉（★★memory 有同型血證）
```
★★**機械防線（已開始做）**：★★★**consume 之後 grep 驗一次** ——
**跟「commit 之後驗內容不驗退出碼」是同一條：【做了】與【留下痕跡】是兩件事。**
★**而這次是 hook 把它抓回來的** ⇒ 系統運作正常，只是我以為做完的事沒有痕跡。

## ★recamp 那個病，在兩張床的 30 天窗內【從未被觸發】（2026-09-02 觀察，★不是「所以不重要」）
> **回訪：觸發事件 —— 下一次有人問「recamp 這類 fixture-only 的病值不值得修」時。**
```
★founding-recheck A/B（`ce497d7a` → `afedb3c3`，相鄰兩顆）：
   ★★整條 trace【byte-identical】（扣掉 TickPerf wall-clock，0 行內容差異）
⇒ ★★★recamp 那一行在 peaceful／warring 的 30 天窗裡【根本沒有 fire】
```
★**兩個含意，而它們不同**：
```
①★founding 沉默與 recamp【不同根】⇒ 要另外查（本票不回答）
②★★而 recamp 修的情境，目前只有【s2b 那張床】會走到
   ⇒ ★★★而那【不推翻它的價值】：它修的是一個真的邏輯錯誤（用 owner 判 L0 有沒有主，天生無效）
   ⇒ ★而「30 天沒走到」可能是【窗太短】（判準⑨）或【情境稀有】—— 兩者我沒有分開
```

## ★★founding 沉默 —— **具名上帳**（2026-09-02；★blueprint 要求：不得只寫「等它出現在某個群裡」）
> **回訪：量測窗 —— 長考（驗收考）基線那一輪的 founding 讀數。**
```
★狀態：★★【與 recamp 不同根】已證（A/B `ce497d7a`→`afedb3c3` 整條 trace byte-identical）
★★★而【它本身是否真存在】—— 我們今天【從來沒有獨立確認過】
   ⇒ 它一直是以「近親嫌疑」「疑似」的形式出現在別人的信裡，而沒有一輪是專門量它的
⇒ ★所以本條的內容是【一個未確認的病】，不是【一個已知的病】
```
★**而我原本寫的「等它出現在某個群裡再處理」不是回訪條件** —— ★★**那是【希望】**（blueprint 指出）。
★★★**現在綁的是【長考基線那一輪】**：**那一輪本來就要量 founding，所以它是免費的觀測點。**
★**而屆時要先答的是：【它存在嗎】—— 而不是【它為什麼發生】。**

## ★★★45 個 option 裡有 19 個【一次都沒贏過】——**而這是入口，不是工單**（2026-09-04，implementer 讀既有兩份 90 日跑，零新 code）
★**狀態：已知未修**｜**回訪：觸發事件 —— payoff 導出 merge 後的第一次「誰在贏」讀數**（★本表是【入口】不是工單）
```
★零勝 option = 19 個｜它們合計進候選 5149 次｜母體 = optpool.mother 2912 次 rank_scored（兩份跑合計）
★最大一顆：迎戰 cand 898 / win 0
```
★★**而不能直接讀成「這幾條線沒接」—— 同一個 means-end 家族【自己就反證了】**：
```
maintain_weapons:resource  cand 779  win 178      ←★同一條管線、同一個 dispatch
maintain_tools:resource    cand 479  win  61
maintain_food:resource     cand 636  win  35
build_stable:resource      cand 685  win ★0
build_apothecary:resource  cand 643  win ★0
build_workshop:resource    cand 638  win ★0
maintain_material:resource cand 683  win ★0
```
⇒ ★★★**零是【逐個 option 的】，不是【整條線斷掉】** ⇒ 問題形狀從「線斷了嗎」變成「**這幾個 option 的 util 憑什麼永遠比不過**」。

### ★兩個誠實限（★寫在數字旁邊，不寫進結論）
```
①★兩份跑【都是 peaceful】⇒ 迎戰 0 勝【可能是 genuine】（和平世界不迎戰是對的）
   ⇒ ★★warring 那份跑完【免費】會反駁或坐實它 —— 不必為它單開一票
②★★「0 勝」與「不該贏」長得一模一樣 ⇒ ★★★所以本條是【入口】不是【工單】
   ⇒ 同 2026-09-02 那條量化：A 級 12 條全查完，需新開修法票 = 0 條
```

### ★systems 裁序（2026-09-04）：只開**那 4 個自相矛盾的**，不開 19 個
```
★開：build_stable / build_apothecary / build_workshop / maintain_material 的 :resource 版
   ⇒ 理由 = ★★它們與贏家【同家族同管線】,所以「線沒接」這個解釋【已經被同一張表排除】
   ⇒ 做法 = dump 它們【輸掉當下】的 per-option util（既有 lost_table 形狀），★禁靜態斷言、禁 crank
★不開：其餘 15 個（迎戰等 warring／:location:delegate 族 cand 小且與上面同因嫌疑）
```
★**一個尚未驗證的形狀，明標為假說**：贏家是 `food/tools/weapons`（**團自己消耗的**），
輸家是 `stable/apothecary/workshop/mint`（**資本財**）＋ `material`（**原料**）。
★★**這只是看表看出來的，util dump 沒回來之前不算數** —— **寫在這裡是為了讓 dump 回來時有東西可以被推翻。**

## ★★★4 個零勝 option 的差距**正好是 0.0000** —— **它們不是輸在分數，是輸在 tie-break 的 `i` 序**（2026-09-04，8 日 smoke，★假說未證）
★**狀態：已知未修**｜**回訪：觸發事件 —— payoff 導出 merge 後**（★根已定案＝registry flat 常數，已由導出取代）
```
build_stable / build_apothecary / build_workshop / maintain_weapons 的 `:resource`
   均 util = 1.2190 ｜ 均贏家 util = 1.2190 ｜ ★均差距 = 0.0000
```
★★**而這解釋了那個「5149 次候選、0 勝」為什麼那麼乾淨**：
**若 tie-break 是 registry 插入序，那麼輸的那幾個【每一次都輸】** ⇒ ★★★**0/5149 不是偏好，是【決定性的排序假象】。**

### ★★★【已推翻】懷疑點 —— clamp 不是來源（訂正 2026-09-04，推翻它的是 implementer 自己補的覆蓋率）
```
★訂正版探針(掛 `_candidate_util` 單一收斂點):30 日 母體 523｜clamped ★0｜unclamped 523
⇒ ★★上限【從來沒咬到】⇒ 落在判讀表第二列:平手另有來源 ⇒ 往上游
★★★而第一版探針【自己就是儀器沒開】:掛在兩個 clampf 上,母體僅 64,
   而那七個 option 光 30 日就【各出現 46 次】⇒ 母體對不上 ⇒ 沒蓋到產它們的那條路
   (`:resource` 走 `_mk_candidate` → `_candidate_util`,不經那兩個 clampf)
⇒ ★那個 `clamped=0` 不是證據,是【沒量到】—— 工具騙人第一形態
```
★★**真來源 ＝ `goal_registry.gd:40-51` 的 flat 死常數（都標著 `TEST VALUE`）**：
```
maintain_food/material/tools/weapons/coin        payoff = ★1.0（五個同值）
build_farming/workshop/apothecary/mint/stable/…  payoff = ★1.5（八個同值）
★實測值分布坐實(不是從假設推的):30 日 1.50×242｜1.00×217 = 87.8% 只有兩個值;8 日跑相異值就 2 個
★★算術:1.50 × devcoef 1.00 × discount 0.87 = 1.3043 ＝ 那五個逐位元相同的 util
   maintain_material:1.00 × 1.00 × 0.87 = 0.8696 ＝ 它實測的值
```
⇒ ★★★**平手不是「上限壓平」，是【一群 goal 共用同一個常數】** ⇒ 同 payoff ＋ 同 dev_coeff（同隊同 tick）
＋ 同 discount（同 delay）⇒ **util 逐位元相同** ⇒ **registry 插入序決定誰贏，而那一步是決定性的** ⇒ **0/5149 只能是 0。**

### ★★歸因陷阱（值得單獨記）：**兩個不同的常數剛好同值**
```
`GOAL_UTIL_CAP` = 1.5，而 `build_*` 的 registry payoff **也** = 1.5
⇒ ★「飽和」與「本來就等於那個數」在【單一數字】上長得一模一樣
⇒ ★★分辨它們的不是推理,是【值分布】那一欄 —— ★★★而 clamped 計數看不出來(兩種情況它都可以是 0)
```

### （原文，框架已於上方推翻）★懷疑點（★implementer 標明沒有下斷言，我照樣不升級）
```
goal_resolver.gd:285   clampf(best_util, 0, 1.5)
   ⇒ ★可能把多個 candidate 壓成同一個 payoff（數字對得上:1.3043 = 1.5 × 1/1.15）
★★證法【必須】同時印 clamp 前後兩個值 —— 只印一個分不出「本來就相等」與「被壓成相等」
★★★而那一刀等兩跑收工再套(那棵樹正在被讀,不在跑的時候改它)
```

### ★★判讀表訂正（systems 2026-09-04，★我原本那格是錯的）
```
★我原寫:`<0.1` = 邊緣輸  ← ★★把兩個【機制不同】的東西併成一格
⇒ 拆成兩格:
   ①差距 == 0.0000（`tie_exact`） ⇒ ★輸給 tie-break 規則,不是輸給 util
      ⇒ 修法在【排序/tie-break】或【壓平 util 的那個 clamp】,★不是調分數
   ②0 < 差距 < 0.1（邊緣輸）      ⇒ 真的比較過而略輸 ⇒ 修法才輪到 util/需求
   ③差距 >= 2（完全不是對手）      ⇒ 多半 genuine,先問是不是本來就該輸
```
★**而 `clampf` 若證實，它屬於「補丁閘 pre-empt 引擎」那一族**：**上限把可比性削掉，argmax 退化成註冊序偏好。**
★★**但在 clamp 前後兩個值印出來之前，這仍是假說** —— **不得據此開修法票。**

## ★★★施主階梯「一階都不 applicable」的成因 —— **不是政權注入、不是那顆 bug 修，是【世界 × 窗】**（2026-09-04，兩跑完成）
★**狀態：已知未修**｜**回訪：觸發事件 —— 下一次施主/乞食相關裁定**（★成因已答：世界×窗，非 config 非 bug 修）
```
同一顆 code、同 seed 1337、90 日 × 兩份 config
   舊 config peaceful_economy         entry=561  ★hit=6（1.07%）
   新 config peaceful_economy_regime  entry=448  ★hit=2（0.45%）
⇒ ★兩邊都 >0 而不相等 ⇒ 判讀表【第四列:沒有單一主因】⇒ 照原樣報,不歸類
★★交集對帳兩跑都 ✅（ladder.deep.intersect == donorladder.hit,6==6／2==2）
   ⇒ 那個「按定義成立」的等價,現在是【被印出來驗過的】而不是被假設的
```
### ★★★而它把【題目本身】推翻了（★systems 的票前提錯，記在這裡）
```
★票的前提:「跑1(舊 config) 若是 0 ⇒ 成因是政權注入」
★★而舊 config 不是 0,是 6 ⇒ ★★★那個「0」根本不是舊 config 給的
   —— 它是【warring 世界、30 日、三 seed】(分母 75／68／79)給的
⇒ ★真正的自變數是【世界 × 窗】:peaceful + 90 日 ⇒ 兩份 config【都】斷過
⇒ ★★這是「舊結論綁著它量測的那個世界」今天的第二次命中
```
★**六筆/兩筆命中都能被指認，而它們長得一樣**：舊 config 六筆全部 `team=2 / food_days=0 / has_aid_target=false`，
`tick 68880→74160` **連續六個決策點**，當下 `scored` 名單裡**一個 survival 階都沒有**
⇒ ★★**不是「有而輸了」，是【真的沒有】** ⇒ **不是統計現象，是一隊、連續數點、名單真空。**
★**原裁定三條未被碰到**（①genuine-depletion ②階梯保證非每階保證 ③保證施主＝scripted）——
**只把「成因」那一格從【待查】改成【已查：不是那兩個變因】。**

## ★★★零勝 option：**`lt0.1` 桶裡一筆真正的邊緣輸都沒有**（2026-09-04，兩個世界同形，★接上面那條 tie 假說）
★**狀態：已知未修**｜**回訪：觸發事件 —— payoff 導出 merge 後的 tie 讀數**
```
★lt0.1 桶與 tie_exact 【逐個相等】(157/157、128/128、132/132、99/99;新跑同樣)
⇒ ★★所以「邊緣輸」這個現象在這七個 option 上【不存在】
   ⇒ systems 把 <0.1 拆成兩格是對的,而★★★拆完之後【原本那格是空的】
★maintain_material 落在 0.1to0.5（159 筆）⇒ ★它是【另一個機制】:穩定地略低,不是平手
★★maintain_weapons 是關鍵對照:tie 99 次而【贏 63 次】⇒ ★★★平手【不必然】輸
   ⇒ 輸不輸看它在 registry 序裡的位置 ⇒ 機制指向 tie-break,不指向分數
```
### ★飽和的證據（★而它仍然不是修法依據）
```
tick=600 team=9  贏家 maintain_tools=1.3043
   maintain_weapons／build_workshop／build_apothecary／build_stable 皆 1.3043  ←★五個逐位元相同
   maintain_material=0.8696                                                   ←★★只有它不同
★1.3043 = 1.5 / 1.15 = GOAL_UTIL_CAP × discount ⇒ 那五個的 payoff 正好【卡在上限】
★★五個獨立算式同時算出剛好 1.5 的機率是零 ⇒ 【飽和,不是巧合】
★★★而現有數字證得出「卡在上限」,證不出「沒有上限的話會不一樣」—— 而後者才是修法依據
   ⇒ pre／post／超出量三值同印的探針跑中(30 日足夠:tick 600 就看得到,母體不缺)
```

## ★★★同一種飢餓、不同管道給不同緊急度 —— **payoff 導出【刻意】不含 `SURVIVAL_GOODS` ×6 放大**（2026-09-04 立案，★不是遺漏）
★**狀態：已知未實裝**｜**回訪：觸發事件 —— payoff 導出 merge 之後的第一次「誰在贏」讀數**
```
★trade_valuation.gd:160-161  if res in SURVIVAL_GOODS and shortage > 0.5:
                                 shortage = 1.0 + (shortage - 0.5) * 6.0
★payoff-derive-bridge 用【escalation 之前】那個值 ⇒ maintain_food 在 payoff 管道裡【沒有】這個待遇
★★而「飢餓該有放大待遇」在本 repo 是 established:SURVIVAL_CRUSH(facility_score)／famine_escalation(_self_use)
   ⇒ ★★★於是同一種飢餓,在【三個管道】裡有【兩種】緊急度
```
★**為什麼仍然這樣做（★理由只有一個，不要事後加別的）**：
**含 escalation 會讓 food 的 shortage 衝到 4.0，而其餘資源上限 1.0 ⇒ 立刻重開剛剛才解掉的跨家族量綱問題。**
> **回訪：觸發事件 —— payoff 導出橋接版 merge 之後的第一次「誰在贏」讀數。**
```
★屆時要先答的是:【maintain_food 有沒有因為少了這個待遇而系統性輸掉】
⇒ ★★若沒有 ⇒ 這個殘留無害,留著;若有 ⇒ 下一刀要把放大接進來,而【接法不能是再乘一個常數】
   ⇒ ★★★正解方向:讓三個管道【共用同一個放大函式】,而不是各自寫一份
```
★**而這條的價值不在 food** ——★★**它是一個【一致性缺口】的樣本**：**同一個世界事實，在不同管道被翻譯成不同的緊急度。**

## ★★★施主階梯斷 ＝ **餓到後期的徵狀，不是餓的起因**（2026-09-04，DonorAftermath 兩跑，★這一條 re-scope 整條施主線）
★**狀態：未確認**｜**回訪：量測窗 —— 下一次量「餓的上游」那一輪**（★階梯本身已判 genuine 收案）
```
cfg team first_hit_day  crisis_first_fire_day  差      pop 首次命中→結束  結局
舊   2    47.8           34                   ★13.8 天  5 → 1            存活
新   1    46.4           33                   ★13.4 天  5 → 1            存活
新  10    46.5           37                   ★ 9.5 天  5 → 1            存活
```
★**三筆同形：【絕對餓】先出現，十天上下【之後】才出現「一階都不可用」**
⇒ ★★**所以往「乞食那階要保證施主」修，是【修徵狀】** ——
★★★**真正的問題在前面那十幾天：那時候階梯是【通的】，而那幾隊仍然一路瘦到 pop 1。**
★**而「存活」這兩個字在這裡有誤導性**：**pop 5 → 1 ＝ 塌了 80%，卻記在「存活」欄。**

### ★判讀表第三列（命中隊全活 ⇒ genuine ⇒ 不開票）—— ★★而它的強度取決於下一條
```
舊 config:命中 1 支團滅 0 ｜ 對照組 18 支團滅 3（16.7%）
新 config:命中 2 支團滅 0 ｜ 對照組 30 支團滅 4（13.3%）
★對照組正是它值錢的地方:沒有它,「命中隊活著」讀起來像好消息
   ⇒ 有了它才知道【這個世界本來就會死 13–17%,而命中隊反而沒落在死的那群】
★★誠實限:命中母體 1 支／2 支 ⇒ 【個案】不是【樣本】
```

## ★★★「存活／團滅」裝不下第三種狀態：**`pop_end = 0` 而未 `extinct` 的空殼隊**（2026-09-04，新 config 6 支）
★**狀態：未確認**｜**回訪：量測窗 —— ★長考 90 日那一輪**（blueprint 裁 2026-09-04）
> ★屆時要答的兩題：**①空殼會【持續累積】還是【暫態】？ ②它會被【回收】嗎？**
> ★★（原回訪「下一次任何以存活率為判準的裁定」仍然有效，本行是把它綁到一個【具體的窗】上）
```
★team 7/12/20/22/23/28（★舊 config 0 支、新 config 6 支）
   隊還在名冊裡、一個人都沒有,而【沒有】進 extinct 桶
⇒ ★★它會被讀成【存活】
⇒ ★★★而上面那條第三列的裁定【正是建立在對照組死亡率上】,
   而這 6 支就坐在那個率的【存活】那一邊 ⇒ ★所以 13.3% 可能【低估】
```
★**未查（不猜）**：可能是待清除、可能是真的零人續存 —— **implementer 標出不歸類，我照樣不歸類。**

### ★★★三分類重算（2026-09-04）：**空殼比團滅還多，而先前那個比較是拿【不同定義】在比**
| cfg | 組 | n | 存活 | 團滅 | ★空殼 | 團滅＋空殼 |
|---|---|---|---|---|---|---|
| 舊 `peaceful_economy` | 對照組 | 18 | 15 | 3（16.7%） | **0** | **16.7%** |
| 新 `peaceful_economy_regime` | 對照組 | 30 | 20 | 4（13.3%） | ★**6（20.0%）** | ★★**33.3%** |
```
★空殼在新 config 裡【比團滅還多】(6 vs 4)
★★而先前「16.7% vs 13.3%」是拿【兩個不同定義】在比:
   舊的 16.7% 已涵蓋全部非存活(空殼 0),新的 13.3% 沒有
⇒ ★★★同定義重算 = 16.7% vs 33.3% —— 【方向反過來】:新 config 更慘,不是更好
```
★**而裁定沒被推翻，反而變硬**：命中隊三分類裡**三格都落在存活**（舊 1/1、新 2/2），對照 33.3% 不是存活狀態。
★★**誠實限也要跟著變硬**：**母體 2 的「0%」在統計上什麼都不是** ⇒ **只能講「這三隊沒死」，不能講「交集不致命」。**

### ★★★★而它對【長考新基線】有直接後果（systems 2026-09-04）
```
★新基線預定跑在 peaceful_economy_regime 上,而該 config 的非存活率是 33.3%(vs 舊 16.7%)
⇒ ★★這不是「政權注入把世界弄壞了」的結論 —— 兩份 config 的隊數本來就不同(18 vs 30)
⇒ ★★★但它是一個【具名的、必須在開考前答掉的問題】:
   那 6 支空殼隊,是不是【走 regime/faction 創世路徑生成的那批】?
   ⇒ 可從既有輸出對帳 team id(7/12/20/22/23/28) vs config 的 faction 成員名單,★零新跑
```
> **回訪：觸發事件 —— 開考前置件盤點（B 三件）那一輪，★連同「基線世界的質地」一起答。**

### ★★★★分層答案（2026-09-04）：**政權注入【沒有】讓創世隊變糟 —— 差異整個來自 runtime 那層**
| cfg | 層 | n | 非存活（團滅＋空殼） |
|---|---|---|---|
| 舊 `peaceful_economy` | config-born | 12 | **3（25.0%）** |
| 新 `peaceful_economy_regime` | config-born | 12 | ★**3（25.0%）—— 完全一樣** |
| 舊 | runtime-born | ★7 | 0 |
| 新 | runtime-born | 20 | **7（35%）** |
```
★★config 那一層【新舊完全相同】⇒ ★★★「政權注入本身讓世界變糟」【不成立】
   ⇒ 先前那個 16.7% vs 33.3% 的落差,【整個】來自「新世界多長出 13 支 runtime 隊」
★而舊 config 的 runtime 只有 n=7 ⇒ ★★那個 0 照原樣報,【不當率用】
   ⇒ ★★★所以「runtime 隊本身比較脆弱」目前【只有新 config 這一邊有數字】,不是已建立的比較
```
★★**而對長考基線真正重要的是這一格**：**連 config-born 的隊，90 日後也有 25% 不是「能動的隊」** ——
**兩個世界都一樣** ⇒ ★★★**那是【這個模擬的常態】，不是某個 config 的毛病** ⇒ **考卷的分母要照這個寫。**

> **回訪：觸發事件 —— 下一次任何以「隊存活率／團滅率」為判準的裁定。**
★★**而它被看見的唯一原因是 implementer 在 8 日 smoke 撞到並加了守衛** ——
★★★**否則這 6 支會安靜地被算進「存活」那一欄，而那一欄正在被拿來當證據。**

## ★★★平手往下移了一層：現在卡在 `GOAL_UTIL_CAP` 上（2026-09-04，payoff 導出之後）
★**狀態：已知未修**｜**回訪：觸發事件 —— cap 那一票（單調壓縮保序）開票時**
```
★機械證據:gu2.clamped 改前 = 0/523 ／ 改後 = ★167/333（50.2%）
   ⇒ 上限【先前從來沒咬到】,現在有一半的時候在咬
★tick=600 team=9:五個 option 全 = 1.5000 = 【GOAL_UTIL_CAP 本身】
   (而 maintain_weapons = 1.3043 ⇒ ★它不一樣了 —— 導出【確實】拆開了一部分)
★原因可推:payoff 從 ~1.0–1.5 變成【均 54.9】⇒ payoff × dev × discount 常超過 1.5 ⇒ 一起壓到上限
```
★★**同一個形狀往下一層重演**：**上限把可比性削掉，argmax 又退化成註冊序偏好。**
★★★**而上限本身是【真的護欄】**：`GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX`＝**發展慾望不蓋絕境求生** ⇒ **不能直接拿掉。**
```
★修法形狀（★未定案,要走 R②）:【單調壓縮】把 [0,∞) 映到 [0, CAP) —— 保序 ⇒ 保證仍成立,可比性不被削
⇒ ★★而它需要一個尺度參數,★★★那個參數【不能是手填的】—— 那就是下一票的題目
```
> **回訪：觸發事件 —— payoff 導出那一票 merge 之後（★而它現在 HOLD 在「候選母體塌 94% 未診斷」上）。**

## ★★★★【已訂正】候選母體塌 —— **真值是 −43% 不是 −94%，而 tie 那格其實【通過】**（訂正 2026-09-04）
★**狀態：已知未修**｜**回訪：觸發事件 —— 已答，見下方「庫存證據」段（★本條可結案）**

### ★★★庫存證據（2026-09-04）：**notAct 是【真的滿足】—— 秤說話之後世界真的不一樣**
```
★同窗同 seed:maintain_food 缺口中位數 83.7 → ★60.0（−23.7）｜maintain_material −84.0 → −96.0（有餘變多）
★★而【內部對照】讓「其實是 pop 掉了」這個競爭解釋站不住:
   maintain_weapons 的 n／min／med／max 【四個數字全部一模一樣】(573→578、34／170／408)
   ⇒ ★★★target ∝ pop ⇒ pop 若掉它會【跟著掉】,而它沒掉 ⇒ pop 沒掉
⇒ ★所以 food 缺口下降【只能】來自 stock 上升,不是 target 下降
```
★★**這是整個 payoff 導出最有價值的結果**：**不是「tie 降了」，是【隊真的把糧食拿到手了】。**
★★★**而它同時說明 `notAct`（判成 satisfied）與 `already_built` 是不同格子 —— 前者是【存量滿足】，後者是【設施蓋好】。**
```
★成因:implementer 拿【90 日的導出前】去比【30 日的導出後】—— ★★窗不同
⇒ ①母體:384 → 220 = ★【−43%】(同 30 日窗),不是 −94%
⇒ ②tie 率:★★★【從 97.8% 降到 74–85%】—— 方向【相反】⇒ 驗收②其實是【通過】的
⇒ ③optpool.mother 573 → 578(幾乎不變)⇒ ★決策次數沒變,變的是候選池
★不受影響:cap 那顆(gu2.clamped 0/523 → 167/333)兩邊【本來就都是 30 日】⇒ 該發現仍成立
```
★★**而我（systems）把它從「一格待查」升成「擋 merge 的那一格」，是建在那個錯數字上的**
⇒ ★**重裁**：**−43% ＋ 決策次數不變 ⇒ 最可能是【世界分岔】（`fp` 本來就會變）**
⇒ ★★**所以它降回【merge 前的一個便宜確認】，不再是主要 blocker** ——
**真正剩下的 blocker 是 #4 determinism（跑中）與 #5 perf（未做）。**
★★★**通則（已入 03b）**：**票規格第四格「產地」要用在【比較的兩側】，不是只用在被解釋的那一個數字上。**

## （原文，框架已於上方訂正）★★★候選母體塌了 94% —— **而它擋住 payoff 導出的 merge**（2026-09-04，★未診斷）
★**狀態：未確認**｜**回訪：量測窗 —— 見上方訂正段（★本段為原文留存，框架已被推翻）**
```
build_stable cand 278 → ★23（−92%）｜maintain_food 427 → ★91（−79%）
tie 那幾格的 n 從 407／378／382 → ★20–23
```
★**為什麼它擋 merge**：**「好幾個先前 0 勝的 option 開始贏」全部發生在這個小池子裡**
⇒ ★★**「秤說話了」與「池子小到只剩它們」在目前的數字上【分不開】。**
★★★**診斷入口＝既有 tap，不必加新的**：`goal.build_fate.removed_*`（no_otile／wrong_outpost_type／
already_built／desire_below_min）＋ resolver 那層的 `empty_*` 桶 —— **問「是哪一個歸宿吃掉的」。**
```
★desire_below_min 暴增 ⇒ 導出改動的副作用 ⇒ 【不能 merge】
★already_built 暴增   ⇒ 世界真的分岔(隊真的蓋起來了)⇒ 【可以 merge】
★no_otile 暴增        ⇒ 世界更糟 ⇒ 【不能 merge】
★都沒暴增而 cand 仍塌 ⇒ 【我問錯了】,改票
```

## ★★★★Godot 單次 `print()` 被截在 **16383 字元**（2^14−1）—— **而被截的輸出看起來完全正常**（2026-09-04，根因已定，三支床已修）
★**狀態：已知未修**｜**回訪：觸發事件 —— 下一次有人寫「把整張表 join 成一包再 print」時（★已加機械閘擋，見下）**
```
★重現:床把 20000 行 join 成一包、只 print 一次 ⇒ ★★只活 191 行、19809 行消失
   ⇒ ★★★而【下一個 print 黏在被切斷的那一行後面】⇒ 開頭、結尾、格式三個表面特徵全部正常
★而第一版探針【測錯了形狀】:它用 20000 次【獨立】print ⇒ 缺號 0 ⇒ 看起來沒事
   ⇒ ★★所以「探針沒事」不等於「沒事」—— ★★★探針要複製【出事那個東西的形狀】,不是它的規模
★★同時否掉一個先前的猜測:「並跑造成」—— 3×20000 行在並跑下【零缺號】
```
★★★**而它的危害是回溯的**：**任何用 join-then-print 的床，過去產出的表都可能【少了尾段而沒有人發現】。**

### ★★★★升級（2026-09-04，修前/修後同參數對照）：**不是「少了尾段」，是【整張表不存在】**
```
★修前:4 個 section（31/31/30/24 列）｜修後:★5 個 section（31/31/31/31/30 列）
⇒ ★★被吃掉的是【第四張的一半 ＋ 第五張的全部】
⇒ ★★★而消失的那張是【infra path 歸宿】表 —— 也就是「defer_infra 把候選交給誰、之後發生什麼」
   ＝ ★build 漏斗【最下游】那一段,而那正是我們一直在查的地方
```
★**所以它是「儀器沒開」的第一形態，只是粒度是【整張表】**：**0 被當成「沒發生」，而這裡連 0 都沒有 —— 是【那一段不存在】。**
★★**而它躲過了我們的對帳**：**我們做過的「Σ各歸宿 == 母體」都是【單張表內】的**
⇒ ★★★**單張表內的對帳，看不到「整張表不見了」** ⇒ **對帳必須【跨表】：stage N 的出口 == stage N+1 的入口。**
⇒ ★**已加機械閘 `print-join-guard`（第 17 支）**：**禁止 `print(...join(...))` 形狀，白名單需具名。**
⇒ ★★**而「哪些過去的結論建在被截的輸出上」＝【污染清查】** —— ★★★**已做完（2026-09-04）：**
```
★掃 docs/measurements 全部 1238 檔 ⇒ ★★命中 0（兩個疑似全是偽陽性:一個 BOM、一個 CP950 亂碼裡的 `==========`）
★★★真因是機制上的:那三支床【寫檔走 store_string】而【印螢幕走 print】
   ⇒ store_string 沒有 16383 上限 ⇒ ★【落地檔天生免疫】,被截的只有 stdout 擷取
★點名複驗:「defer_infra 是一面牆」(entry 336／in_place_failed 180／built_in_place 8)
   引用的是落地檔 `docs/measurements/2026-08-26-infra-path-fates-30d.txt`
   ⇒ 開檔驗過【五張表全在、無黏連】⇒ ★★該結論【不受影響】
```
★★★**而這給出一條可重用的紀律**：**下結論要引【落地檔】，不要引【從螢幕貼上來的片段】** ——
**因為兩者走不同管道，而只有其中一個有 16383 上限。**

## ★★★「`defer_infra` 是一面牆」的**現況待重判** —— `in_place_failed` **180 → 0**（2026-09-04）
★**狀態：未確認**｜**回訪：量測窗 —— implementer 的對齊版跑（`peaceful_economy`／30 日／seed 1337，與落地檔標頭一致）**
```
★歷史讀數仍然成立(它產自 2026-08-26 的落地檔,五張表全在、無黏連,已複驗)
⇒ ★★變的是【現況】:in_place_failed 180 → ★0;最大歸宿換成 guard_no_own_outpost（139/155 ＝ 90%）
★★★而【不歸因】:兩份差了三個變因 —— config／9 天的 code／母體 336→155
   ⇒ 對齊版先切掉 config 那一個,再看剩下的
```
### ★★★★而這件事本身是【截斷 bug 的直接後果】—— 值得單獨記
```
★那張表【存在了幾個月而我們一直看不到】(join-then-print ⇒ stdout 被截,而落地檔有)
⇒ ★★它一被印出來,第一件事就是【推翻一條掛在帳上的結論的現況】
⇒ ★★★所以「看不到的表」不是中性的空白:★它會讓一條【已經不成立的結論】繼續掛在帳上
```
★**衍生的追查（已請）**：**同一個 bug 修好後，【另外兩支床】有沒有也「多出來一張表」，而那張表推翻了別的帳？**

### ★★★對齊版回來了（2026-09-04）：**config 固定後牆仍然不見 ⇒ 不是 config**
```
★in_place_failed 180 → ★0（config 已固定，所以【不是 config 造成的】）
★★built_in_place 反而變多:8 → 11,而母體 336 → 128 ⇒ 成功率 2.4% → ★8.6%（3.6 倍）
   ⇒ ★分子與率【同向上升】⇒ 這個方向對母體變化【穩健】
★★★新的最大歸宿:`pick_empty` 69/128 ＝ 54% ⇒ 【卡點往上游移了一格】
   —— 從「進門後被拒絕」變成「選不出要建什麼」
★而仍【不歸因到任何單一改動】:9 天的 code 差不只那兩刀
```
★★**而 `pick_empty` 正好接回一條既有的帳**（2026-08-26）：**那一輪拆過它的六個歸宿**
`empty_no_eligible 0／empty_all_below_threshold 0／ok_slot_free 77／empty_slot_full_margin 180／
empty_slot_full_no_lowest 0／ok_demolish 1`（母體 258）⇒ **當時的答案是「slot 滿而拆建門檻 1.5× 擋住」。**
⇒ ★★★**所以下一問是【它是不是同一個機制】** —— **已請重跑那六格對照（同床、同六格、產地標清）。**

## ★★★★`_pick_facility` 的出口分類**對帳是紅的** —— **70/80（87.5%）落在沒有名字的出口**（2026-09-04）
★**狀態：已知未修**｜**回訪：觸發事件 —— 下一次要用 `pick.infra` 那張表下結論時（★在補齊命名之前，那張表不可用）**
```
★實測:「7 類合計 10 vs entry 80 ⇒ ❌不一致（有出口沒被分類）」
⇒ ★★所以 `pick_empty` 那張六格表【現在不能用來下結論】—— 87.5% 的出口沒有名字
★★★而這個 ❌ 【一直在印】,只是它落在 join-then-print 的截斷區裡 ⇒ 沒有人看得到
   ⇒ ★守衛有效、而守衛的輸出被截掉 —— 比「表消失」更諷刺的一種失效
```
★★**順帶推翻 2026-08-26 那個答案的【現況】**：**當時的 `empty_slot_full_margin 180`（slot 滿＋拆建門檻 1.5×）**
⇒ ★★★**現在那兩格【都是 0】** ⇒ **卡點不是 slot／門檻了** —— **而真正的答案在那 70 筆沒有名字的出口裡。**
★**歷史讀數仍然成立**（產自落地檔，已複驗）—— **變的是現況；這條記的是【現況】。**

## ✅★★★★★★【成因找到了】「外部砍」**根本不是外部** —— 是 **harness 管理的背景任務被終止**（2026-09-05 結案）
★**證據強度（2026-09-05 訂正，implementer 修正了問題的【軸】）**：
```
★偵測（有沒有被砍）＝【5/5 全部直接】—— 每次都收到 `status: killed` 任務通知
★★批次性（是不是同一個動作）＝【1/5 有證據】—— 僅一對 mtime 差 2 秒;其餘四次各自孤立
⇒ ★★★所以「成因是 harness 終止任務」【強】,而「一次砍掉全部」【只有一例】
⇒ ★而我原本把兩者寫成同一條強度光譜 —— 它們是【兩個不同的問題】
```
★**已收案**｜**修法＝改啟動方式（真 detach），不碰世界**
```
★今天六跑全部是【session 的背景任務】(harness 會追蹤、會通知 —— ★而它也殺得掉)
★★證據不是回憶:被砍時收到的是 harness 的 ★★★`status: killed` 任務通知
   ⇒ 那是【被管理的任務被終止】的形狀,不是【行程自己死】
★而對照組是現成的:★pilot 那一跑【真 detached(WMI)】⇒ ★★完整跑完 169.3 分、completed=yes
   ⇒ ★★★真 detach 六跑一成功 vs 真 detach 一跑一成功 —— 兩種啟動方式,兩種命運
```
★★**而這是一條【跨多日的敘事被訂正】**：
```
★我們曾寫過「兩次都被外部殺」「原因不是確定性的」「死在固定天數/wall-clock 都不成立」
⇒ ★★而那些觀察【都成立】,只是【歸因錯了】:不是世界或機器不穩,是【我們自己的啟動方式】
⇒ ★★★而讓它現形的是【2 秒內同死】那個結構簽名 —— 單一行為者,而那個行為者是 harness
★而 memory 裡那條老法(`detach ＋ --path 絕對路徑`)【本來就是為這件事存在的】—— 我們沒有一直用它
```

## （原文，成因已於上方找到）★★★★★【結構簽名找到了】外部砍是**批次級的** —— 一次砍掉【所有】背景跑（2026-09-05）
★**狀態：未確認**｜**回訪：量測窗 —— 下一次任何背景長跑（★而它現在有可測的簽名）**
```
★warring seed 42（第三跑）與 seed 7 【同時】被砍,兩者最後寫入時間差 ★★【2 秒】(16:23:57／16:23:59)
⇒ ★★★那【不是各自不穩】,是【有東西一次砍掉所有背景跑批】
```
★★**而它推翻了 systems 的裁定②**：**「並跑可以把曝險減半」** ——
⇒ ★★★**並跑不會減半：兩張【一起死】⇒ 曝險【一樣】而損失【加倍】。**
★**而它把整條 backlog 的搜索空間換掉**：
```
★舊結論:「原因不是確定性的」(因為它有時死有時不死)
⇒ ★★而新證據說:它是【單一外部行為者】—— 那與「不確定」相容,但【搜索空間完全不同】
   ⇒ ★★★不再是「這一跑為什麼死」,而是【什麼東西會一次終止一批背景任務】
★下一步(便宜、排終卷之後):把【每次被砍的時刻】與【當時發生了什麼】對照
   ⇒ 而我們今天已經累積了【七次以上】的時刻 —— ★★母體是現成的
```

## ★★★長跑被外部砍 —— **第三次，而這次砍在【長考第一段】上**（2026-09-04；★不再是 warring 專屬）
★**狀態：未確認**｜**回訪：量測窗 —— 每一次長跑（★它自己會出現，不必為它安排）**
```
★本次:seed 1337 完成｜seed 42 跑到 1.58 MB 被砍（無 `[PilotRun]`、specimen 未落地）｜seed 7 沒開始
★★而【迴圈這次也死了】(task status=killed)⇒ 沒有上一次「砍行程而迴圈續跑」那個擴散問題
★★★而它【不是長度相關】:warring 169 分鐘跑得完,而這次 7 分鐘級的卷被砍
   ⇒ 與先前的結論一致:【原因不是確定性的】
```
★**已生效的緩解（★而它這次真的省了事）**：
```
①★逐段落地 ⇒ 被砍的那張留下 1.58 MB 可讀,不是 0 bytes
②★★每個 seed 是【獨立一跑】⇒ 一次砍只損失【一張卷】,不是整段
③★★★而 seed 1337 【不重跑】:儀器與參數完全相同 ⇒ 產地同源成立,重跑只會多花 8 分鐘換到同一份資料
```
★★**新增紀律**：**每張卷跑完【立刻】做表頭四格對帳** —— **不要等三張都跑完才驗**
⇒ ★★★**否則「被砍的那張」會在交卷時才現形，而那時最自然的動作是【補跑一張】—— 而補跑那張的產地可能已經不同。**

## ★★★★「備戰」贏了但**從未 dispatch** —— 三張卷的**第一贏家是幻影**（2026-09-04，QA 讀 trace 撞見；★systems 窮盡驗過）
★**狀態：已知未修**｜**回訪：觸發事件 —— 下一次解凍時（★而它應在 warring 段【之前】修，理由見下）**
```
★QA 實證:seed42 specimen 裡【18/18 次】備戰 argmax 勝出,全部 result=finder_miss、target 恆 (-1,-1),從未真正 dispatch
★★code 坐實(systems 窮盡搜索,13 處全列):
   options.gd:434          備戰 to_task ⇒ target = Vector2i(-1,-1)（★註解明寫「原地整軍,無 target」＝ by design）
   faction_ai_system.gd    :3008 / :3500 / :3721 / :6020 四站共用 `tgt == (-1,-1) and task != TASK_FLEE` ⇒ 擋掉
   ★另有 :2347 一站【連 FLEE 豁免都沒有】
   ⇒ ★★★TASK_PREPARE【不在】任何一條豁免清單裡 —— FLEE 是唯一豁免
★而它在別處【有】被特別處理:movement_system.gd:73／sim_runner.gd:414 都把 PREPARE 排除在移動之外
   ⇒ ★所以「原地整軍」這個語意在【移動層】被實作了,而在【dispatch 層】沒有
```
★★**後果（★對長考直接相關）**：**備戰是三張卷的第一贏家（352／412／328）⇒ 「誰在贏」那一格被污染**
⇒ ★★★**而它是「手不聽腦」家族的又一例**：**argmax 贏了，而什麼都沒發生。**
★**順帶撞到一顆 stale 註解**：`faction_ai_system.gd:754` 寫「spec 原列 TASK_PREPARE，但 TeamData 無此 task」
⇒ ★★**而 `team_data.gd:20` 就有 `TASK_PREPARE := "備戰"`** ⇒ **那句註解是錯的，而它會讓下一個人以為這個 task 不存在。**

## ★★★specimen 抽樣**系統性漏掉故事最激烈的那一層**（2026-09-04，QA 揭）
★**狀態：已知未修**｜**回訪：觸發事件 —— seg1 重跑（★下一次跑 specimen 之前必須先解，否則同樣的偏差會再來一次）**
```
★helper 在【setup 當下】取樣 ⇒ ★★runtime 新生隊(seed42 佔 26/38 = 68%)【完全不在 specimen 裡】
⇒ ★★★而卷面自己說:runtime 層非存活率 46.2%,是 config 層(16.7%)的【近 3 倍】
⇒ ★所以任何從這份 specimen 讀出來的故事,天生偏向【比整個世界更平靜】的那一半
```
★★**方向明確：偏樂觀（偏穩定），不是隨機噪音** ⇒ ★★★**這不是抽樣方法錯，是【抽樣範圍先天排除了後來才出生的隊】。**

## ★★「有 coin 不買糧」 —— team10 的慢性流失（2026-09-04，QA 讀 trace，★只呈現象未查 code）
★**狀態：未確認**｜**回訪：量測窗 —— 長考第二段或下一次經濟線量測**
```
★team10:food=0 持續數千 tick(多日餓死線),而 ★★coin=156.94【全程凍結未動】
⇒ 只選 覓食／返家補給,★★★從未見【貿易】candidate 贏
⇒ population 靠反覆 N2_riot 一個一個扣:6→5→4→3→2→1
```
★**QA 明標「我沒有查那段 code，只呈現象」** ⇒ ★★**與「資源盲派／手不聽腦」家族接近，但這次是 coin→food 這一段**（不是 material catch-22）。

## ★seed42 少一個政權 ＝ **推論不是觀測**（2026-09-04）
★**狀態：未確認**｜**回訪：量測窗 —— 下一次有 faction 生滅 tap 的跑**
```
★faction1 已知 3 個成員:team7(tick2400 死)／team0(tick3600 退出)／team9(tick36960 退出)⇒ 三個都不在了
⇒ ★★方向與「2 政權 → 1 政權」吻合,而 ★★★【沒有一筆明確的「faction 解散」事件 log】
⇒ QA 自標:這是從成員 faction_id 轉移【推出來的】,不是直接觀測
```

## ✅★★★兩顆潛伏的 tracer 崩潰 —— **擴大覆蓋率才讓它們現形**（2026-09-04，已修結案）
★**狀態：已修結案**｜**回訪：不需要（★而它的教訓見下）**
```
★列印端直接索引 `w["candidates"]`／`s["food_granary"]` ⇒ ★★而【半途加進來的隊】沒有那些鍵
⇒ SCRIPT ERROR 中斷該筆
★★★而它先前【不可達】:specimen 只在 setup 當下取樣 ⇒ 從來沒有「半途加進來的隊」
⇒ ★所以【擴大覆蓋率會讓從沒跑過的 code 第一次跑到】—— 而那類 code 天生沒被驗過
```
★★**而 implementer 的處置值得記**：**兩處都【不填 0 蒙混】，改印「本筆無記錄」**
⇒ ★★★**因為 `pop=0 food=0.0` 與「沒有記錄」在畫面上長得一模一樣，而意思相反。**

## ★★★★「併入」**committed 了卻從未真的併成** —— 手不聽腦的【執行層】版本（2026-09-04，QA 讀 trace）
★**狀態：未確認**｜**回訪：量測窗 —— 下一次任何涉及併隊/投靠的量測（★或長考第二段）**
```
★team13(runtime,生來 pop=1):food 見底後【反覆選併入 10+ 次,result 全是 committed】
⇒ ★★而 pop 全程停在 1、task 卡在「投靠」、team_id 從未消失 ⇒ ★★★【從未真的併成】
⇒ 最後 tick73440 erase_teams:孤身餓死,被「委任了但沒發生」的併入卡住到最後
```
★★**而它與「備戰」那顆【不同層】**：**備戰是 dispatch【前】被 guard 擋掉；這顆是 `committed` 之後【執行層】沒發生。**
⇒ ★★★**所以「手不聽腦」至少有兩個獨立的斷點，而 `result=committed` 【不保證】那件事真的發生。**

## ★★★「存活」不是二分，是**落進不同的結構性均衡**（2026-09-04，QA 揭；★直接影響卷面指標）
★**狀態：已知未修**｜**回訪：觸發事件 —— warring 卷（★卷面已改成四分，而【卡在單一迴圈】那類本身還沒被修）**
```
同一輪 runtime 層四支「存活」隊,命運天差地遠:
★team15 瀕死 —— food 探底到 0,★最後一刻(tick129180)買糧 committed 撿回一命
★team17 食物 400+ 而【永久卡在迎戰迴圈】(同一個 threat_id=5 持續糾纏)
★team18 食物 380+、coin 62.5,而【建設 100% try_set_noop】—— 想蓋、有錢、從未蓋成
★team14 穩定小康(food 成長到 134)
```
★★**所以「非存活率」這個聚合數字掩蓋了結構差異** ⇒ ★★★**卷面要把「存活」拆成【穩定／瀕死／卡在單一迴圈】。**

## ★★紮根/建設 `try_set_noop` 的**跨 seed 反差**（2026-09-04，QA 交叉檢查）
★**狀態：未確認**｜**回訪：量測窗 —— 長考第二段或下一次建設線量測**
```
★seed42:team14 十二次跨 44+ 天【全部 try_set_noop】、team17 三次全 noop ⇒ 抽樣兩隊 0/15
★★seed1337:同一個「紮根」在 team13/15/18/19/20 身上【大量 committed】(team13 一支就成功 12 次,週期性)
⇒ ★★★同一個 action,42 幾乎全滅、1337 大量成功 ⇒ 【不是這個 action 普遍執行不了】,
   是 seed42 撞上某個 1337 沒撞上的【結構閘】—— 而 QA 明標沒查 code,只呈現反差
```

## ★`threat_id=5` **跨隊跨輪反覆出現**（2026-09-04，QA 意外發現）
★**狀態：未確認**｜**回訪：量測窗 —— 下一次威脅線量測**
```
★本輪 team15／team17 都撞到同一個 threat_id=5;★★上一輪 team10 的舊跑也出現過同 id 系列
⇒ ★★★若它是地圖上【長駐的敵對實體】而非每次隨機生成 ⇒ 它可能是整條
   「威脅→備戰/迎戰/求和」故事線背後【真正的常數角色】
⇒ ★而要查的是 threat_id 的【生命週期與位置穩定性】—— QA 明標沒查 code
```

## ★★★★共位（同格）**超過一半看不見對方** —— 而根在**距離項只跨 [0.5, 1.0]**（2026-09-04）
★**狀態：未確認**｜**回訪：量測窗 —— 90 日窗（JOIN 情報年齡那格 12 日窗母體 0，正在跑）**
```
★實測(implementer):同格 pair 1710,★★【沒偵測到 880 = 51.5%】
★同格 claim = 1293 > 0 ⇒ ★★★共位【會】產生 sighting —— 所以【不是】propagation dead-end
```
★★**而公式的形狀是根**（`vision_system.gd:43-45`）：
```
dist_f  = 1.0 - (dist / (vrange+1)) * 0.5      ←★dist=0 ⇒ 1.0（滿分）／dist=vrange ⇒ ★0.5
eff_exp = exposure * dist_f
if _can_detect(scout, eff_exp): …
⇒ ★★★所以【距離的全部影響只有 2 倍】:站在腳下 vs 站在視野邊緣,只差一倍
⇒ ★而 dist=0 已經是最好情況,剩下的【全看 exposure 與 scout】⇒ 站到腳下也補不上
```
★★★**後果（★而它比 JOIN 那條線大）**：**任何依賴「靠近就會知道」的機制，在這個公式下都沒有拿到它以為的保證。**
```
★具體受害者:JOIN —— 隊站在宿主身上,而 belief 說宿主在 14 格外(39/55),於是走開去找它已經抵達的東西
★★而這【不是】感知鐵律的問題:決策吃 belief 是對的;問題是【belief 該怎麼被更新】
```

## ★★★新鮮度洗白：**看見一次，會把【沒看到的欄位】一起蓋上新時戳**（2026-09-04，implementer #8 量出來、systems 判）
★**狀態：已知未修**｜**回訪：觸發事件 —— 下一次動 belief/感知鏈時（★共位必見那一票【不含】它）**
```
★vision_system.gd:111  snap = BeliefSystem.best_estimate(state, obs_id, tgt_id).duplicate()
   然後只覆寫【真的看到的那些】:population_est／tile_pos／last_tick／tags_seen／activity
⇒ ★★所以 best_estimate 裡【其他欄位】會被原樣帶著走,而 `last_tick` 卻被刷新
⇒ ★★★一個欄位的新鮮度,被【另一個欄位的觀察】背書 ⇒ BELIEF_STALE_TICKS 對那些欄位【失效】
```
★★**而它【不是】god-view 違憲**（systems 判）：**帶過來的是觀察者自己的舊信念，不是真值** ——
**沒有任何真實狀態被複製進去** ⇒ 感知鐵律沒有被破。
★★★**而它也【不是】JOIN 那顆的成因**：**JOIN 讀的是 `tile_pos`，而 `tile_pos` 是被真值覆寫的那一格。**
```
★修法形狀(未定案):【逐欄位時戳】或【只帶這次真的觀察到的欄位】
⇒ ★★而它是【另一票】—— 共位必見那一票的 scope 明寫「不動感知鐵律本體」,不要順手改
```

## ★★★★互動**只在移動時觸發** —— 靜止的兩隊【結構性不互動】（2026-09-05，implementer 控制床揭；★systems 窮盡驗過）
★**狀態：已知未修**｜**回訪：觸發事件 —— blueprint 裁「共位能不能互動」之後（★它是「共位必見」的孿生問題）**
```
★窮盡搜索(不 head):`_resolve_join` production 呼叫點只有 interaction_system:293／296
   而兩者都在 `_try_interact` 內,★★而 `_try_interact` 的 production 入口只有:97(arrived)／:125(moved)
   —— 都在 `process_on_move` 內,而它由 sim_runner:459 以 `moved_ids` 呼叫
⇒ ★★★雙方都沒動的 pair【對 resolver 是結構性隱形的】
★控制床實測:48 tick 裡 `moved` 名單【每一 tick 都是 0 筆】⇒ join.dispatch 0、resolve 0
```
★★**而它對「共位必見」那一刀是【逆風】**：
```
★共位必見把 belief 修對之後,同格 JOIN 隊的 move_target ＝【自己腳下】⇒ ★★它更不會動 ⇒ 更不會 resolve
⇒ ★★★所以【感知修對了,反而讓互動更不會發生】—— 兩個機制的假設互相矛盾:
   一個假設「知道了就會靠近」,另一個假設「靠近的動作才觸發互動」
```
★**影響範圍不只 JOIN**：**外交/徵收也對齊 `process_on_move` 同格外交**（`diplomatic_ai_system.gd:138`）
⇒ ★★**任何「兩隊都待在原地」的情境,互動都不會發生** —— 而那正是【貧窮、走不動】的隊最常見的狀態。

## ★★★★`徵收` 贏 137 次，**真正完成資源移轉的只驗到 1 例**（2026-09-05，QA 讀 trace）
★**狀態：已知未修**｜**回訪：觸發事件 —— blueprint 裁「徵收兩格」的第②格（間隔分布）回來時一起判**
```
★137 次 argmax 勝出 ⇒ ★★108 次（79%）`try_set_noop`【連 dispatch 都沒過】
★過關的 29 次裡 ⇒ ★★★24 次（83%）`tile_pos` 在後續窗口【完全凍結】
   —— 從未真的往 target 移動,而 task 在 1–3 個決策週期內【被靜默換掉】
★真正走到 target 並逐 tick 收到 coin 的：★★【只驗到 1 例】(team16,完整 travel→arrive→逐 tick 收稅)
```
★★★**而方法論上這比「備戰幻影贏」更隱蔽**：
```
★備戰:靠 `result=finder_miss` 字面就篩得出來
★★徵收:★★★【連 `result=committed` 都會騙人】—— committed 只代表 TaskArbiter 收下,
   而「有沒有真的走過去」要對【tile_pos 軌跡】才篩得出
⇒ ★所以驗證標準要再升一級:【贏 → dispatch → committed → ★★軌跡 → 資源真的移動】
   —— 五站,而我們今天已經證過【每一站都可能斷】
```

## ✅★JOIN 修法的**正面案例**（2026-09-05，QA 驗到端到端）
```
★team19:同 tick 前後兩筆快照
   merge 前 faction=-1／coin=0／food=0／material=0.08／pop=1
   merge 後 faction=1／coin=58.3／food=4.08／material=6.9／pop=2
⇒ ★★全部【同步跳動】⇒ ★★★真的救到一支瀕死隊 —— 共位必見＋共位互動的端到端證據
```

## ★★★徵收漏斗拆開：**最大的一格是 `try_set` noop，而舊 counter 看不到那一層**（2026-09-05）
★**狀態：已知未修**｜**回訪：觸發事件 —— 兩個漏口的逐條件名回來時**
```
★母體 99（徵收＝rank[0]）＝ 落跑 31（無目標）＋ 派出 68 —— ★對帳平
★★而派出的 68 裡：`try_set` noop ＝ 33（ok 僅 35）
⇒ ★★★【第四型手不聽腦】：派了,但【靜靜地沒發生】
★而舊 counter `tribute.dispatch.member` ＝ 68 ⇒ ★★它數的是【打算 dispatch】不是【dispatch 成功】
   ⇒ ★★★又一次「counter 的名字與它數的東西不同」—— 而名字讓人以為那 68 都發生了
```
★★**而 90 日 seed1337 的全鏈**：`win 233 → dispatch 85 → 到達 23 → ★真轉移 18`，**只涉及 3 對**、守恆 ±3017.9
⇒ ★★★**「徵收洪水」在世界層【沒有被支持】** —— **81.2% 的勝率背後是 3 對隊、18 次真轉移。**

## ★★★★政權對【自己成員】的位置，取決於**領袖有沒有親眼看到**（2026-09-05，徵收漏斗與 JOIN 收斂到同一條通道）
★**狀態：未確認**｜**回訪：量測窗 —— blueprint 裁「自家成員該不該回報位置」之後**
```
★徵收「無目標」31 次 ⇒ ★★【全部】是「belief 沒有位置」—— 沒有一次是「沒有可徵對象」或「最富的是自己」
★而它走 `belief_pos` 的【同 faction 分支】＝ `known_member_states`
   （`faction_ai_system.gd:863`：`f.known_member_states[mid] = BeliefSystem.best_estimate(leader, mid)`）
⇒ ★★★而共位必見驗收 #2 的「對不上 29/45/42」也【全落在同 faction】—— 【同一條通道】
```
★★**所以兩條線（徵收走不到 ／ JOIN 走錯地方）收斂成一個**：
```
★一個管道叫【已知成員狀態】,而它其實只裝得下【領袖親眼看到過的】
⇒ ★★自家成員【不會回報位置】—— 而那是一個 WHAT 級的世界模型問題,不是 bug
⇒ ★★★而它與感知鐵律【不衝突】:回報也是一種資訊傳遞,不是 god-view
```

## ★★★★孤隊（pop1 餓到歸零）**不是在投靠** —— 而我上呈的那個「不必修」說法【被證偽】（2026-09-05）
★**狀態：已知未修**｜**回訪：量測窗 —— 基線產出後的第一輪修法排隊（★收斂則③：本段只標不修）**
```
★母體 4470（pop1 餓到歸零的隊,當下在做什麼）
⇒ ★★【併入只有 99 ＝ 2.2%】
★前四名:返家補給 1341(30%)／買糧 913(20%)／乞食 692(15%)／覓食 663(15%)
```
★★**所以「孤身求援＝自己走過去＝投靠」這個故事【不成立】** ——
**孤隊不是在投靠，它們在【回家補給與買糧】。**
★★★**而這一筆是我的**：我把它當成「病溶解於既有機制」的收案形態上呈，**而 blueprint 據此批了「不必修」。**
```
★教訓:【病溶解於既有機制】是一種很漂亮的收案形態 —— ★★而正因為漂亮,它【同樣需要數據】
⇒ ★★★而 implementer 把判準寫在數據之前(上一封信),所以這【不是事後挑數字】
```
★**而依收斂則③（本段只標不修）**：**本條【具名上卷，不重開修法】** —— 基線產出後再排隊。

## ✅★★★★孤隊的求生選項【半工作】：**不死，但也不恢復** —— **而那正是「能苟不能興」法的實貌**（2026-09-05 收案）
★**已收案（blueprint 裁：符合既有法，不開票）**｜**讀數留著當基線的一部分**
```
★用戶 2026-08-14 定的質地原文:「L0 吊命、無積累；small ＝ 停滯；翻身 ＝ 歸隊 or 紮根」
⇒ ★★而實測正是它:苟【真的苟住了】(死只 3／2／3)、興【真的興不了】(卡 pop1 15／10／9)
⇒ ★★★翻身門【機械上是通的】(JOIN 2.2% 在 fire ＋ team19 端到端案例)——
   只是引擎秤它低 ＝ 人格/情境排序,不是管道不通
★卷面寫法:【卡在單一迴圈】的讀數留著 ＋ 故事寫「孤狼吊命等機會」
```
```
★曾餓到歸零的隊:21／23／18
⇒ ★★死 3／2／3 ｜ 空殼 0／8／5 ｜ 還活著 18／13／10
★★★而「還活著」【不等於恢復】:pop_end ＝ 1 人的有【15／10／9】,其餘只有零星 2–6 人
⇒ ★大多數只是【停在 1 個人沒死】
```
★★**所以 blueprint 的二分（選項在工作／選項空轉）漏了第三種**：**【半工作】—— 它們防住了死亡，沒有帶來恢復。**
★★★**而我們自己的分類已經有這個詞**：**存活四分裡的【卡在單一迴圈】** ——
**孤隊落在那一格：返家補給／買糧／乞食／覓食輪流做，活著，而永遠回不到 2 人。**
```
★而它接回一條既有的:「有 coin 不買糧」(team10)與「食物 400+ 而永久迎戰」(team17)是同一族
⇒ ★★共同形狀:【資源不是問題,而狀態出不去】
```

## ★★★★被併掉的隊**留在名冊裡**（合併屍體）—— 而它污染【所有以「隊」為母體的讀數】（2026-09-05，坐實 100%）
★**狀態：已知未修**｜**回訪：觸發事件 —— 基線產出後第一批（★收斂則③：本段不改世界，只改卷面）**
```
★空殼 ∩ 合併日誌【被吸收側】＝ 32/32、19/19、16/16 ＝ ★★【100%，三張皆是】
⇒ ★★★所以「空殼」不是一種【存活狀態】,是【合併之後留在名冊裡的屍體】
★而它也解釋了翻倍:JOIN 剛修通 ⇒ 合併變多 ⇒ 屍體變多（★20% → 43–53%）
★★★**跨世界確認（2026-09-05 warring 卷 1）**：**屍體 ∩ 合併 ＝ 112／112 ＝ 100%** ——
**與 peaceful 三張的 100% 一致** ⇒ ★**它是【結構性質】不是【那個世界的性質】** ——
**兩個世界、四張卷、母體從 16 到 112，全部 100%。**
```
★★**而危害【不只那一欄】**：**屍體留在 `state.teams` ⇒ 每一個 per-team 迴圈都會走到它們**
⇒ ★★★**任何以「隊」為母體的比率都被稀釋**（存活率、各種 per-team 分布、甚至 perf 的隊數）。
★**本段的處置（不改世界）**：**卷面把它們【從存活分類的母體移出】，另列一行「合併屍體（不計入存活分類）」。**
★★**而「該不該 erase」是世界層的問題** ⇒ **排基線之後第一批** —— ★★★**而它現在有 100% 的坐實，不必重新量。**

## ★★★★徵收在 warring：**意圖放大 12 倍，真轉移只放大 3.6 倍**（2026-09-05，五站全母體）
★**狀態：已知未修**｜**回訪：觸發事件 —— 終卷之後第一批（★收斂則③：本段只標不修）**
```
★warring 五站:贏 3803 → 派工 515 → committed 183 → 到達 80 → ★★真轉移 29（★守恆 ✅ ±315.9、UNBALANCED_BUG=0）
★peaceful（seed1337 90 日）:贏 233 → 派工 85 → 到達 23 → 真轉移 18
⇒ ★★★轉化率:peaceful 18/233 ＝ 7.7% ／ warring 29/3803 ＝ ★0.76% —— 【掉了一個量級】
```
★★**兩個漏口（★而第一個是舊識）**：
```
①★母體 3723 裡【3208（86%）落跑在「無目標」】,而那 3208 ★★【100% 是 belief 沒有位置】
   ⇒ ★★★成員回報【已經 merge 了】,而這個漏口在 warring 上仍是 86%
     —— 因為它只治【有人手且觸發位置級大事】的隊,而 warring 的母體大得多
②★★try_set noop 332 / ok 183 ⇒ 「派工 515」裡【只有 183 真的接上】,其餘 332 派了而靜靜地沒發生
```
★★★**所以「世界越大越亂 ⇒ 徵收越收不到」** —— **而那不是一個新機制，是【同一個漏斗在更大的母體上漏得更多】。**

## ★★★同一個機制，兩個世界卡在**不同的人力條件**（2026-09-05，成員回報 peaceful vs warring）
★**狀態：已知未修**｜**回訪：觸發事件 —— 終卷之後（★需要 `ptype` tap 才能歸因，而本段凍結中）**
```
★peaceful:嘗試 50 → 派出 2 ｜ 沒派成的主因＝【母隊只剩一人 46】
★★warring :嘗試 133 → 派出 16 ｜ 沒派成的主因＝【沒有可派的名人 501】(母隊只剩一人 60／不知道對方在哪 40)
⇒ ★★★peaceful 是【人太少】,warring 是【人都被派去做別的了】—— 同一個機制,兩種瓶頸
```
★★**而母體的誠實限（implementer 自標）**：**那三個 fail counter 的母體是【全站所有 envoy 用途】**
⇒ ★★★**所以【不能說】「回報因為沒名人而失敗 501 次」** —— **要歸給回報自己那一份，需要 `ptype` tap。**
★**而那張小票已開，排在終卷之後【★defer token: envoy-ptype-tap；★★而終卷已到 ⇒ 本條已逾期一次，2026-09-06 重新裁定】**（★`_dispatch_envoy` 在 `faction_ai_system.gd` ＝ 世界路徑，本段凍結中）。

## ★★★belief **沒有位置**的真根因【未知】—— 而「新鮮度洗白」這個假說**已被否證**（2026-09-05）
★**狀態：已知未修**｜**回訪：觸發事件 —— ②徵收 broad-thin 落地之後**（★②會改候選集合，現在切出來的分佈馬上過期）
```
★症狀兩格:徵收「無目標」86% ／ JOIN 的 true<belief 39/55
★★曾經的假說:vision_system.gd:111 `duplicate()` 後【只覆寫子集】⇒ 未觀察欄位頂著新的 last_tick
   ⇒ ★★★【已被否證】:三個 firsthand `record_claim` 寫入點【全部都寫 tile_pos】
      (vision_system.gd:113／interaction_system.gd:1219／faction_ai_system.gd:2015)
   ⇒ tile_pos_tick 恆等於 last_tick;實測 newly_expired=0／newly_fresh=0(母體 34039 次位置新鮮度判斷)
   ⇒ 第二個獨立證據:fp 逐位元相同 92f890ca
```
★**這條要留著的理由**：**假說被否證是資訊**，不寫下來的話**下一個人會重新走一遍同一條死路**。
★★**還沒切的三選一（互斥且窮盡）**：belief **從未建立** ／ 建立過但**真的過期**（`last_tick` 舊，＝正常行為不是 bug） ／ belief 在但 `tile_pos == (-1,-1)`。
★★★**而「程式碼形狀是真的」不等於「它是這個症狀的病因」** —— 這輪的錯就是把形狀當病因，**沒先查那個子集裡到底有沒有出事的那個欄位**。

## ★★★常設斷言【沒有被註冊成閘】＝ 它不存在，而它看起來像存在（2026-09-05，同型第三次）
★**狀態：已知未修**｜**回訪：觸發事件 —— 第一批全部落地之後**
```
★三次同型(全部是【寫了測試但沒進 docs/process/merge-gates.tsv】):
   ①headless_test.gd  2026-09-03 ——「本來不在註冊表」,而兩顆已 merge 的 slice
      弄紅 fixture 時【十支全綠】(註冊表自己的註解記著)
   ②belief_freshness_invariant_test.gd  2026-09-05 —— ③的反向斷言,補進去才會跑
   ③unified_commerce_test.gd            2026-09-05 —— ★【從來就不在表上】
      ⇒ 它既有的斷言(守恆/整合/probe funnel/member_tax)也【一直沒人跑】
```
★**規模**：`scripts/debug/*_test.gd` 共 **135** 支，註冊表直接點名的 script 只有 **6** 支（＋`headless` 那道跑 `headless_test.gd`）。
★★**而 135 vs 6 本身【不是醜聞】**：多數是一次性診斷床，用完就該安靜。
★★★**真正的洞是【沒有任何標記能分辨兩者】** —— **一支扛著常設不變量的測試，與一支用完即棄的診斷床，在檔名、位置、寫法上長得一模一樣。**
⇒ **所以「忘了註冊」不會被任何東西攔下來**，而漏掉的後果是**靜默的**（那支測試不會紅，因為它根本不會跑）。
★**已想到但未做的機械防線**（具名，不是遺漏）：diff 型守衛 —— 一顆 commit 若**新增 `scripts/debug/*_test.gd`** 或**往既有測試加 `push_error`**，卻**沒有動 `merge-gates.tsv`**，就出聲。

## ★★★★所有隊最終都變成【生產隊】—— 而那讓薪資／稅／匿名池三個系統一起死（2026-09-05，坐實）
★**狀態：已知未修**｜**回訪：觸發事件 —— B 議程（經濟）開場之後**
```
★config/peaceful_economy.json 手寫 12 隊:11 隊 ["統領","生產"] ＋ ★1 隊 ["商隊"](id=8)
   而 team8 是【全床唯一帶 coin 1000 的隊】
★★實測(measurer):team8 day90【仍活著】、team_id 沒變、★★★那 1000 coin 在 setup/day30/day90
   【三個時間點恆為 1000.00】—— 一分未花未收
⇒ 它 day30 的 tags 已是 ["商隊","生產"] —— ★被 settle 【追加】了生產 tag(保留原 tag,非取代)
⇒ ★★而 salary_system.gd:31 的 early-return 只看 `has(TAG_PRODUCE)`
   ⇒ 一支【定居過的商隊】從此不發薪
```
★**TAG_PRODUCE 的 production 寫入點有【三個】**（★我第一次負斷言說「唯一一個」是**錯的**）：
`interaction_system.gd:1509`（**settle**）／`:1536`（**convert_resident**）／`outpost_system.gd:525`（子隊完工安頓）。
### ★★★★【2026-09-05 當日訂正 —— 下面那條連鎖的因果宣稱是【錯的】】
```
★拔掉 PRODUCE early-return 之後,`_pay_salary` 的進入次數【還是 0】
   —— 而 entry tap 就在函式【最上面】⇒ 這個函式【根本沒被呼叫】
★★真根 = LOD 相位:無玩家床 ⇒ 全隊走 far ⇒ far pass 每 FAR_ZONE_INTERVAL(600) tick
   而 payday = 10080k,10080k % 600 = 480k % 600 ≠ 0 直到 k=5 ⇒ 30 日窗【一次都對不上】
⇒ ★★★所以下面的「settle → 薪資 early-return → …」這條鏈,【機制描述為真,因果宣稱為假】
   而三症之中【薪資 0】與【匿名池 0】是【相位造成的】,不是經濟造成的
   (★member_tax = 0.00 那一格【仍然成立】:它的 caller 走 TICKS_PER_MONTH=43200,%600=0,不受相位影響)
```
★**而這不只是量測盲點，是世界的 bug**：在**有玩家的真實遊戲**裡，**離玩家遠的隊真的只領到 1/5 的薪水**（見下一條 known_issue）。

★★**連鎖（★★★因果已於上方訂正，保留原文供對照）**：
```
settle 把隊變成 PRODUCE ⇒ 薪資系統 early-return ⇒ ①【薪資從未執行】(90 日 0 次)
                                              ⇒ 具名成員拿不到錢 ⇒ ②【member_tax 90 日 0.00】
                                              ⇒ anon 薪水不入公庫 ⇒ ③【匿名池水位全程 0.00】
```
★★★**而真正該問的設計問題**：**「定居」與「不再是雇主」是不是同一件事？**
`tags` 是**追加不是取代** ⇒ 一支隊可以同時是**商隊**與**生產** ——
**而 early-return 只看 PRODUCE 一個 tag，等於讓「定居」單方面決定了「不發薪」**。
⇒ **這是 WHAT 問題（歸藍圖），不是我可以自己改的門檻。**
★**誠實限（measurer 自標）**：只驗了 team8 一例；其餘 10 隊是 config 原生 PRODUCE 還是也經 settle 取得，**未逐一追**。

★★★★**【2026-09-05 二次撤回】本條引用的 `member_tax 90 日 = 0.00` 也【無效】**：
`WorldState.driver_ledger` 是 **cap=4096 的環形緩衝**（`world_state.gd:164`／`:186-187`，**靜默 `pop_front`**），
而量測的 drain 間隔是**每 2000 tick 一次** ⇒ 單窗 entry 數 > 4096 ⇒ **讀到的永遠是每窗最後 4096 筆**。
★**證據簽名**：每窗 `ledger_seen` 增量**精準等於 4096** —— **飽和值就是溢出的簽名，而它看起來像一個穩定的計數**。
⇒ ★★**所以本條的三個支撐數字裡，`member_tax = 0.00` 待重量**；
★★★**【同日再訂正：已重量，結論不變】** —— measurer 以 **drain 間隔 50 tick** 重跑，**`overflow_hits = 0`**（直接量證未溢出），`member_tax` 總額**仍為 0.00** ⇒ **這次是可信的真 0**。
★而值得記的是：`_ledger_seen` 從 **266240 → 1017343** ⇒ **舊版少看了約 75%，而它當時看起來完全正常**；
★★匿名池那票的母體 **1 → 18**（**舊版的 1 本身就是被吃掉的結果**）—— **所以撤回不是白做，即使結論沒變**。
★★★而 **team8 的 1000 coin 三時間點不變**那一格**不受影響**（它讀的是 `team.resources` 快照，**不是 ledger**）。

## ★★★`belief_pos` 把【從未有情報】與【情報過期】回成同一個值（2026-09-05，量測順手撞到）
★**狀態：已知未修**｜**回訪：觸發事件 —— 墓碑（①票）落地之後**
```
★belief_system.gd:135／:140 `belief_pos`:「從未有 claim」與「有 claim 但超過 BELIEF_STALE_TICKS」
   【兩者都回 (-1,-1)】⇒ ★★讀取端分不出「我不知道它在哪」與「我知道過但過期了」
★★★而它是【既有、全域的 belief 毛病】,不是墓碑機制引入的
   —— 是墓碑前置量測時撞到的:known_member_states 清 6 vs member_team_ids 清 7,
      差 1 ＝ 有死者【在名冊裡卻從來沒有情報條目】
```
★**為什麼不併進墓碑票**（R² 判，我同意）：鬼城情報的核心故事**不靠讀 stale belief 分辨** ——
它靠**有人新鮮地走到那個座標、用 vision 現場看到那裡沒人**（感知通道），**兩條不同通路**。
★★**修法形狀已有現成範本**：抄 `belief_system.gd:386-399` `appearance()` 的**三態**（`"fresh"`／`"stale"`／`"never"` 各一個桶），
★★★**不要另外發明一種表示法** —— 而它會 touch 全域 belief 讀取端，**是一張獨立的票**。

## ★★★★裸 `current_tick % INTERVAL` 在 LOD far pass 下會【週期性漏拍】—— 而它是距離依賴的世界扭曲（2026-09-05）
★**狀態：已知未修**｜**回訪：觸發事件 —— ⑦票（遷 `CadenceStagger`）落地**
```
★受害條件:【裸 modulo 閘】長在 shape:"teams" 且 LOD_BOTH 的 step 裡,
   而 INTERVAL 不是 FAR_ZONE_INTERVAL(600) 的倍數
★★命中清單(全掃 scripts/simulation,扣掉 whole-state 的):
   salary_system.gd:31         SALARY_INTERVAL 10080 → %600 = 480  ★中招
   faction_ai_system.gd:1170   TICKS_PER_MONTH 43200 → %600 = 0   安全
   faction_ai_system.gd:1499   定期徵收,動態 interval             ★同一類
★★★而策略層【免疫】:INFRA_INTERVAL 那一整排走 `CadenceStagger.next_tick()`
   —— 它比的是 `last_eval_tick` 【不是精確 modulo】⇒ 相位錯開不會漏(全 repo 23 個呼叫點)
```
★**後果不是「床看不見」，是【世界不公平】**：
```
sim_runner.gd:291 near pass = tick % NEAR_CADENCE(60) == 0   ⇒ payday 全中
sim_runner.gd:337 far  pass = tick % FAR_ZONE_INTERVAL(600) == 0 ⇒ payday 只有每 5 次中一次
⇒ ★★同一支隊,【離玩家近就月月領薪,離玩家遠就四個月領一次】
⇒ ★★★而【無玩家的 headless 世界裡「遠隊」＝全部】⇒ 薪資軸在任何預設床上都【不可觀測】
```
★**修法（已具名，不要另外發明）**：把 `salary_system.gd:31` 與 `faction_ai_system.gd:1499` 遷到 **`CadenceStagger`**，
與策略層同形、**零新機制零新常數**。★★**而不要去調 `SALARY_INTERVAL` 的數值** —— 那是把相位問題偽裝成調參問題。

## ★★★★憲法債：**玩家近遠分班「判死」於 2026-08-20，而它今天仍然活著**（2026-09-05 對帳）
★**狀態：已知未修**｜**回訪：觸發事件 —— 用戶對 LOD 對帳的裁示**
```
★2026-08-20 明文(commit 0a1e03a7):「模擬層零 LOD…玩家近遠分班【判死】」
★★而 docs/progress.md:99 同日我自己寫的:「systems 排序裁定:零 LOD(拆 near/far)【排最後】【★非裁定：此處是【引述】progress.md:99 的考古】
   —— 它是花預算不是賺預算,且 cadence 語意依賴時間包層級制」
⇒ ★★★【已裁定、未執行】,而 16 天後它以【薪資相位病】的形式咬人
   (遠隊四個月領一次薪水;而無玩家世界裡「遠隊」＝全部)
```
★**殘件（權威來源＝`SimRunner.SYSTEMS` 的 `lod` 欄，27 entry 逐條看）**：
```
①★分班本體:sim_runner.gd:583-589／:591-599 依 `_hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS` 分兩批
②★★兩批不同 cadence:':291' near ＝ %60 ／ ':337' far ＝ %600
   ⇒ ★★★遠隊的 vision／move／interactions／collect… 【有跑,但慢 10 倍】(它們是 LOD_BOTH)
③`outpost_tick`(:159)／`regen`(:163) 仍掛 LOD_NEAR ⇒ ★但兩者 shape 是 whole-state
   ⇒ 【不是按隊距離分班】,只是節奏跟著 near pass
④stale 註解 `movement_system.gd:30`(寫 10／100,真值 60／600)—— ★它今天已經騙過兩個人一次
```
★★**而 ⑦（排程事件玩家無關）只止住了最會流血的那一刀** —— **它讓「排程事件」不受分班影響，
但分班對其他一切的影響（頻率差 10 倍）仍未清。** ★★★**「模擬層零 LOD」今天還沒有做完。**

## ★★★盟可能**永遠處在「緊急徵收」override 裡** —— 而「守成」分支在本床是**死的**（2026-09-05，線索非結論）
★**狀態：未確認**｜**回訪：量測窗 —— ⑧ 落地後同 seed 重跑，印【盟實際選到的意圖分布】（implementer 已加 `intent.sel_*` tap）＋【守成分支進入次數】per-faction**
```
★⑦驗收③(逐盟徵收準時度)【答不了】——不是紅也不是綠:
   兩個盟在 43200 tick 內【一次都沒進過「守成」分支】⇒ 母體是空的
   (而徵收排程只長在 `_rebuild_goals` 的 `"守成"` 分支裡)
★★線索(★implementer 只報線索、未坐實):
   faction_ai_system.gd:1436  食物不足 ⇒ f.strategy = "緊急徵收";_emit_goal(...); ★return
                                                                                    ↑在 `match itype` 【之前】
   ⇒ ★★盟若長期缺糧,【整個意圖分派段根本到不了】⇒ 守成分支自然是死的
```
★**為什麼要記**：⑦ 對 `faction_ai_system.gd:1499` 的修法 **在這個世界無法驗證** ——
★★**不是沒修好，是那條 code path 在這個世界是死的** ⇒ **驗收③標【不可判】，不是 pass。**
★★★**而「兩個盟從未守成」若為真，它比徵收準時度重要得多**：那意味著**盟層的策略只有一個狀態**。
★**待補的一格**（implementer 已加 tap）：**盟實際選到的意圖分布** —— **母體是 0 的時候，卷面要說出「它們去哪了」**，
否則「不可判」只是另一個沒有內容的字。

## ★★★★「守成」意圖**永遠不會被選到**（12335 選 0）—— 而定期徵收整段是**死 code**（2026-09-05，坐實）
★**狀態：已知未修**｜**回訪：觸發事件 —— 「死常數人格化」那條 arc（統一路線圖序 5）動工時**
```
★ambition_ladder.gd:37  "守成": 0.25,  ← ★flat 死常數,而註解寫 `# default base`
   對手全部是人格導出:征服 ∈[-0.4,0.8]／致富 ∈[0,0.7]／防衛 ∈[0,0.6]
   人格多落 0.4~0.6 ⇒ 致富≈0.35、防衛≈0.30 【都 > 0.25】
★★實測(implementer):意圖選擇 12335 次 ⇒ 建國 10／征服 245／致富 7153／防衛 4927／★★★守成 0
```
★**後果①（機制）**：`faction_ai_system.gd:1499` 的**定期徵收只長在「守成」分支裡** ⇒ **那一段是死 code**
★★★**而【徵收機制整體不是死的】——這一格要講清楚，免得被讀寬**：`徵收` goal 的發射點有**六處**，
`:1481`（**致富**，實測選中 **7153** 次）／`:1493`（**防衛**，**4927** 次）／`:1469`／`:1489`／`:1559`／`:1418`（缺糧 override）
**都是活的** ⇒ **死的只有 `:1500`「定期維持 treasury」那一條（itype ＝ 守成）。**
⇒ ★★**⑦ 對它的量化失真修法【仍然正確】，但【結構上無法驗證】** ⇒ ⑦驗收③ 判**【不適用】**（非紅非綠）。
★**後果②（讀 code 的人）**：**一個自稱 `default` 的分支，實際上永遠不會被選到** —— **而它會被讀成常見情況。**
★★★**而先前那個「缺糧 override 擋住了意圖分派」的猜測【是錯的】**：override 會在 `intent.sel_*` 之前 return，
**擋掉的次數不會出現在分布裡；而分布顯示 12335 次真的跑到了** ⇒ **不是被擋，是【選了一萬兩千次，一次都沒選到它】。**

## ★★★「事件密度排程」尚未實裝 —— **省錢的合法路**（2026-09-05 立條目）
★**狀態：已知未實裝**｜**回訪：觸發事件 —— perf 需要時，或 B 議程之後**
```
★用戶原文(2026-08-20 立身宣言):「事件驅動／髒旗快取 ＝【安靜地區便宜是湧現非裁判】」
⇒ ★★所以「模擬層零 LOD」那句有兩半:
   前半【不跟隨觀察者】＝ ⑧(拆 near/far 分班)—— ★正在做
   後半【跟隨事件密度】＝ 本條 —— ★★尚未實裝
★★★形狀:per-team cadence 由【該隊自身的活動密度】決定
   ⇒ 睡覺的隊少輪【不是因為它離玩家遠】,是【因為它沒事】
   ⇒ ★而那是【湧現】不是【裁判】—— 前者由世界自己決定,後者由觀察者位置決定
```
★**為什麼現在不做**：⑧ 的代價（**投影 2.64×**）已由 blueprint 裁「買」——**憲法不打折**。
★★**而本條是【省錢的合法路】**：它不違憲（不看觀察者），所以**可以在需要時再做**。
★★★**而先做 ⑧ 的理由**：⑧ 讓本條有一個**乾淨的基準** —— **現在的基準被分班污染，近／遠是兩個世界。**
~~★限制（誠實記）：本條無法進 `docs/process/defers.tsv`……~~
★★★**【2026-09-06 訂正：我上面那句是錯的】** —— blueprint 裁：**「XX 需要時」＝某個數字越線，把那個數字寫出來**。
⇒ **本條已進 `defers.tsv`**（token `event-density-schedule`），`met_check` ＝
**任一量測檔出現 `wall_s > 28800`（＝8 小時）** —— ★**量測檔本來就帶 `wall_s`，機械可讀**
（現況最大 `wall_s` ＝ 1105.97 ⇒ 未觸發；**陽性對照**：門檻改 1 秒 ⇒ 立刻觸發）。
★★**而通則比這一條重要**：**寫不出數字的「需要」＝還沒想清楚需要什麼**；
真不可量化的極少數 ⇒ 退而求其次＝**定期複審日期**（也是 met_check）⇒ ★★★**表上不留裸 memory 行。**
