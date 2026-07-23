# Known Issues

> 最後更新：2026-07-04 | **本檔只列開放項**。已修項（✅）移 `docs/archive/resolved_issues.md`（保留根因/修法/教訓,可搜尋）。
> 來源：動態測試 + code review + QA harness 遍歷。
> **仍有效真 backlog**：Bug2(salary floor 後果)、Bug5(休眠)、W4(NPC promote/train + leader 駐留)、W3(dist tune)。（P5 C-1~C-6 對稱缺口 ✅ 2026-06-16 reframe+實作,見下 P5 段。）
> **圖形 Main.tscn 項 moot**：`run/main_scene = TextUI.tscn` → S5/U5/U6/U7/U8/U9 等 graphical 項凍結,復活圖形 UI 才解。**部分復活（2026-07-04 observer GUI）**：`world_map_view.gd` 現雙用途（observer 分支 + dormant player 分支）,動 player 繪製須顧 observer;Main.tscn 本體仍 dormant。


## ★★★武器經濟 arc 正式收斂完畢 → 併入食物安全 arc（2026-07-23 blueprint 收官裁定）

food→goods→weapons→material→tools→workshop-build 整條鏈**正式收斂**。誠實記：**每一層都是真 bug 且已修**——material-buy v1/v2a（chicken-egg trade 側）、tools-demand（生產端 demand-routing）、weaponsmith cost70（afford margin）、produce_need demand-responsive（死常數→市場反應，子根②）全部 merged/授權 merge、無迴歸。**但終閘不在本輪範圍**：
- **workshop-build 終閘根 = farming 求生優先 override 碾壓（QA 終驗，正確機制非 bug）**：`_facility_score`（faction_ai:3132）farming `×(1+SURVIVAL_CRUSH×urgency²)`，食壓下 farming 壓過一切發展設施 → 隊永遠卡 subsistence farming、升不到 specialization（workshop/apothecary）→ 無 workshop → 無 tools → 無 weapon。= **食物經濟下游症狀**，連回 session 最早 starvation/desperation-economy 根。
- **★★禁 force-workshop 補丁（blueprint 明裁，違憲）**：不准繞合法求生優先權強蓋 workshop / 動 `SURVIVAL_CRUSH`/argmax。求生優先是正確憲法行為，武器 gap 的解在**上游食物安全**非強塞下游。
- implementer refine（採信）：workshop deficit ≠ goods-starve（goods target=0→min_per_res SKIP 非 binding，workshop deficit 由 tools/arrows self_use 驅≈1 高）→ 「apothecary 40× 勝」非 goods-demand 缺、亦非 argmax 因子問題，是 farming survival-crush 碾壓整個 specialization 層。
- **真下一步 = 食物地方分配/穩定性**（新 arc，meta-pattern「world-level 夠、local/team-level 不夠」第 N 次；material/goods/tools/food 同款）。詳 [[project_economy_arc]] + systems 盤點。

## arc 收斂中間態（保留脈絡）：weaponsmith 0→0 供給側（2026-07-23，已併入上方收官）

cost70+tools-demand **兩修 confirmed 有效**（measurer：afford 達 105≤天花板113、tools-demand 接 795 筆買單）但 weaponsmith 仍 0→0 → 唯一剩因 = **tools 供給全域 0**（workshop 幾乎沒蓋 + 蓋出來也產 0）= 製造業產能本身（非需求/貿易/門檻）。blueprint 授權查兩子閘，fix 範圍**等 QA §④b build-sample 判故事後**定。結構圖（systems patch-gate-first 查，file:line）：
- **子閘 A：workshop 0→1 稀少（build 側）**：workshop=civilian-only A-class；build-completion 家族（同日 civ 設施 **20-44% 完工率**調查）——construction 起手不完工（subteam abandon/timeout/資源）+ facility-argmax 選擇。連 [[project_hand_obeys_brain_arc]]。此 seed 尤糟（只 1 workshop + 晚建）。
- **子閘 B：蓋出來產 0（生產側，manufacturing_system:62-102）**。候選（QA build-sample 待判哪個主導）：
  1. **★silent MANUFACTURE-assign gate**（`:67` `if current_task != TASK_MANUFACTURE: continue` **無 tap**）：workshop tile 的 owner 沒被指派 MANUFACTURE → 產 0 **零可觀測**（決策沒選生產任務；tap-gap，違全量暫態可觀測性）。
  2. **no-material**（`:102` `noop_no_material`）：material=**tile-harvest**（forest 12/day 富、mountain 2、**plains 0.5 貧**；resource_system:35-37），**無 facility 產 material**（只 harvest+beast-hide+loot+anon）→ workshop 在 material-貧 tile（plains）或沒 harvest → 產 0。
  3. **no-demand**：recipe target≤0（need+demand 皆 0）。
- **★★兩 tap-gap（觀測盲點，會讓 QA build-sample 捏假故事）**：(1) `:67` silent MANUFACTURE gate 無 tap (2) `:102` `noop_no_material` **混淆** no-material/no-demand/already-satisfied 三因（`_run_recipe_group` 回 "" 三種都落此 tap）。→ 若 QA specimen 無法 tile-level 拆這三，需補 tap 再 measure（觀測=判決前置，憲法）。
- fix **未定**（等 build-sample）。連下方兩 build 閘（afford/tools 已解，供給側是新終閘）。

## ★weaponsmith 真牆 = 兩 build 閘（非 trade，2026-07-23，material-buy arc 後 patch-gate-first）

material-buy arc（v1+v2a merged e6519f9f）修好 trade 側（mil 買 material，peak 117 vs baseline 98，QA coherent 0 餓死），**但 weaponsmith 仍 0 建=兩硬 build 閘**（血證：T26 material80+coin70 夠 base cost 仍不建=閘非供給/錢）：
- **閘① afford×1.5（`faction_ai:2801` `_dispatch_facility_builder`：`avail < cost×1.5`）**：weaponsmith material 80→需 **120** > 隊 carry-cap ~117（差 3 不可達）。**★系統性 margin 非 weaponsmith-specific**（連 civ site material 62→需 75 同卡；blueprint 撤回 facility-specific 框架，改系統性重審倍率影響範圍/計算方式）。★注意 [[feedback...]] 全域降 ×1.5 已 ABANDON（破 mint/G1a 空解窗）→ 系統性修須 mint-safe（如絕對-bounded buffer `min(cost×0.5, CAP)`，高 cost 設施可達、低 cost mint 不變）。
- **閘② tools=0 全域 = 生產端 demand-routing 缺口（QA reframe）**：workshop 已完工（Team6/30/3/19/45）產 tools（recipe `out:tools, in:material 4`）**但 `use_demand=true`**（需求驅動）；weaponsmith build-need（tools 3）**從沒發 tools-demand 信號** → demand-gated workshop 不產。★根：`order_system:121` buy-order res list **不含 tools**（只 weapon/material/ore）→ mil 隊無 tools 買單 → `demand(tools)=0` → workshop 不產 → tools 恆 0。= material「需求沒轉買單」的**生產端版本**（同 means-end 家族深一層）。★workshop civilian-only / weaponsmith military-only = cross-outpost-type，須經 trade（mil 買 tools ← civ workshop 產）。
- **修（blueprint 定 2 件）**：①**tools-demand 註冊**（means-end 擴 tools：weaponsmith build-need→tools need→tools 買單→demand→workshop 產→mil 買→afford）②**afford×1.5 系統性重審**（mint-safe 計算調整）。v2b coin **defer**（build 閘不解，coin 無用）。material 停止迭代（117 夠）。連 [[project_economy_arc]]。

## dispatch afford buffer ×1.5 承重（G1a mint 依賴，不能為 weaponsmith 降，2026-07-22 ABANDON）

`_dispatch_facility_builder:2780` / `_dispatch_upgrader:2637`（3 站含 2551）dispatch-afford `avail < cost×1.5`——嘗試降解 weaponsmith 卡建（mil 隊 material 54-80、cost 80×1.5=120），**但 buffer 承重**：降到 1.1 → owner 撥完料 depletion → **G1a 礦村→鑄幣鏈斷（headless 1 new）**。★**空解窗**：幫 80-料隊需 buffer≤1.0，但 1.1 已破 G1a（1.4 才安全）→ 無值能幫 weaponsmith 又不破 G1a。∴ **buffer 不是 weaponsmith lever**，ABANDON（revert 1.5）。weaponsmith 真解=material 貿易（mil 買料達標，Gate B trade-primary 主線）。**若日後要**：depletion-guard（降 buffer 但守 owner critical needs 如 mint 資源）拆 weaponsmith afford=另案 slice（非 cheap，需 guard 設計）。reviewer 預警「查承重」+ implementer TDD 具現（1.4 過/1.1 破）雙證。

## crisis 門檻 flow-based 漏偵絕對餓（food=0×500tick 不 fire，2026-07-22，QA d26ae644 驗證撿，低優先）

`_decision_crisis`（`faction_ai_system.gd:1858`）= **food_flow_avg 流-based**（`< RUNG_CRASH_FOOD_DEEP` / `< GRADUAL_DECLINE_FLOW`）+ pop-crash，**無絕對-food 條件**。`food_flow_avg`（`resource_system:208`）= daily_rate 的 EMA。∴ **food=0 stuck → daily_rate=0 → flow EMA→0 → 不 < 負門檻 → 不 fire crisis**。QA 坐實：seed1337 team54 food_days=0.0 連 500 tick（tick4800-5300）全程 `in_crisis=false`（11/11 food=0 DIVERT 事件皆非 crisis）→ crisis-escape 不 fire → 鎖空市場貿易 lingered（[SurvivalMergeIn] 併入 Team34 安全網接住沒釀死）。**根=crisis 只偵「流失中」不偵「已見底 stuck」**。**修向**：`_decision_crisis` 加絕對-food 條件（`team.famine_days > 0`=已進飢荒 / 或 `food_days < CRISIS_ABSOLUTE_DAYS` 硬底）→ 字面餓著必 crisis → crisis-escape fire → re-eval 求生。**低優先**（blueprint 裁 2026-07-22：merge 安全網接住、非釀死，記待查）。連 [[feedback_symptom_vs_root_retry]] + 下方 market-seeker 空市場 + DESPERATION cliff 同族（abandon-guard/絕境門檻連續化一批處理）。

## market-seeker 卡空市場不放棄→餓死（2026-07-22，QA 40-event 撿，DESPERATION 同族小範圍）

market-seeker（TASK_TRADE 去市場）食物低 + 市場空（Gate B under-production，無貨）→ **該放棄交易轉覓食卻繼續 re-seek 同市場** → 食物耗乾部分餓死。= 「該放棄不可行選項轉可行選項」手不聽腦類型，連 [[feedback_symptom_vs_root_retry]]（治重試 X 前問 X 能否成功）+ DESPERATION 連續化 / look-before-leap 同家族。**範圍小**（只 market-seek 卡空市場特定情境）。**排低優先 / 順手併 DESPERATION cliff known-issue 一起處理**（market-seek 應 look-before-leap：市場空/無我要的貨 → 不 applicable → 轉覓食）。★真根仍是 Gate B（市場有貨了此情境自消）。**注意**：原 market-seek stickiness fix（Gate A）已撤回（治症狀，建在 buggy divert metric 上）。

## workshop demand-deficit 封頂太粗→連續（follow-up，2026-07-21，reviewer R² 拆出）

`_facility_deficit` A 類 min_per_res：`tgt = need_keep + demand`（unbounded）→ 中度未滿足即 `worst→0` → deficit 恆封頂 1.0（cliff-ish）。workshop（goods demand 3573 巨）恆 1.0=score 恆高。**fix**：demand 貢獻 pop-relative 正規化（`demand cap pop×DEMAND_PER_POP_CAP`）→ deficit **連續反映 demand 量級**（同 team73 DESPERATION「連續非 cliff」紀律）。**blueprint 認可「兩個都做、①優先」**（weaponsmith demand fix=①先，此=②錦上添花公式品質）。reviewer R² 拆獨立 slice（綁 ① 會 conflate goods 行為 measure）。**排序**：weaponsmith fix merged 後獨立做。連 [[project_economy_arc]]。

## ★economy 補丁閘優先查 verdict（2026-07-21，re-baseline 後，blueprint 認可）

god-view arc 收官後 re-baseline（main 9c084d3a，乾淨 doom **21.2/22.5/0.6%**，舊 28% 作廢）。blueprint 序③補丁閘優先查（tune 前查假稀缺 vs 真 balance）：
- **① team73「缺糧仍貿易」= 非 patch-gate（非 urgent，設計問題）**：覓食=`PRIO_SURVIVAL` 本會 preempt 貿易=`PRIO_DISPATCH`（`options.gd:354`），無 task-priority override。真機制=**DESPERATION_DAYS(~3) applicability cliff**：survival opt gate 在 `food_days < DESPERATION`，team73 food=4.17 > 3 → 無 survival opt applicable → default 貿易。**= 門檻 cliff 非 bug，連 2026-07-16「連續急迫非硬 cliff」原則**（blueprint 標 known-issue 非 urgent）。修向（未來）：DESPERATION cliff → 連續急迫（食物越低越傾 survival，非硬 3 天開關）。
- **② 死法② = GOODS 供需失衡（res-split 坐實，2026-07-21 訂正）**：`goods reserve = need_keep(0)×factor ≈ 0`（code-read 對，死鎖早解）。**★但我原「one-sided FOOD 市場」verdict 被 measurer res-split 推翻**：`sell_no_surplus` **food 26 vs goods 276**（我稱的 302 實 91% goods）、buy **food 1093 vs goods 3573**（goods 3.3×）、**food_harvested 76k 豐產**。→ **真根 = GOODS 供需失衡**（goods 需求 3573 高、賣家 holding~0 → sell_no_surplus goods 276）。**教訓**：聚合 count（sell_no_surplus=302）沒拆 res 就下結論 = 誤讀（同 team16/75 坑）[[feedback_fileline_vs_interpretation]]。
- **③ economy 入口 = GOODS 流動性/供給（blueprint 裁 2026-07-21）**：food-結構 arc 取消（food 豐產，starve=分配非產量，另議）。**★market-liquidize branch（`feat/b0cdf624` 降 goods reserve）HOLD 解除、重啟**（一直對著正確的靶=goods 流動性）。
- **★決定性未決：goods「沒產夠 vs 產了瞬耗」**（measurer 拆分中）——定 fix 生產側（產出不足）vs 撮合/流動性側（產了賣不掉，market-liquidize 對）。**market-liquidize 全推進等此拆分**（blueprint「方向不明別走岔路」）。連 [[project_economy_arc]]/[[feedback-patch-gate-first]]。

## ★null-belief-flee 凍結（個體 FLEE 對空氣逃，2026-07-20，Slice E QA 抽查撿，★Slice D 前必修）

team75/4/13（seed1337）：`task=逃跑 + flee_from_pos=(-1,-1)` 全程 + 凍結 1 格 + food=0 餓死（team4/13 還逃跑↔建設 thrash）。**第 4 種 broken 家族（手不聽腦 finder-check classifier 看不到——不是「有 target 沒 dispatch」，是「dispatch 了但目標 null」）**。機制：個體 survival FLEE（`faction_ai:1595/1948` `flee_from_pos = _flee_threat_pos` = 威脅 **belief 位**）——belief 威脅**有存在感但無座標**（stale/positionless→`belief_pos` 回 `(-1,-1)`）→ `flee_from_pos=(-1,-1)` → 算不出逃離向量。`movement:81` 說「(-1,-1) 不設 target 靠 release 收」**但 release 沒真發生** → 卡 task=逃跑 凍結不覓食餓死。**★PRE-EXISTING 確認（measurer baseline diff 2026-07-20：pre-E 8146c4a2 seed1337 此 signature 570 snapshots 跨 11 隊 16/38/56/57/58/63/64/66/68/92/93=凍結 pre-E 就大量在，非 E 引入）**——slice2 belief-化威脅位+缺 flee-release 引入，**每 belief-化 slice（E 已、D 更大）都暴露更多**。**★廣（11+ 隊）值得修。fix 已 build @28470932（applicability-gate：FLEE 威脅無座標 not applicable→轉覓食），measurer 量測中。****★Slice D 前必修**（否則 D doom-delta 被同款污染）。**修方向**（blueprint 認可，look-before-leap）：`flee_from_pos==(-1,-1)`（威脅無座標）→ **release FLEE → re-rank 轉覓食**，非凍結（FLEE 無座標=not applicable 不該卡死）。連 god-view arc（belief-化暴露）/[[feedback_fileline_vs_interpretation]]。

## market_orders capture/demolish 不清（pre-existing 洩漏，2026-07-20，god-view Slice C v2 異質審撿）

`tile.market_orders`（賣單看板）在 outpost **capture/demolish 零清理**：`outpost_system:606`(capture) 只改 owner 不動 market_orders；`:327/332`(demolish) 清 type/level/owner/facilities 但**不清 market_orders**；`_sync_board`(order:61-84) 只 prune 自家 origin_team 單、失主後沒人清該 tile → 易主/拆除市集殘留舊賣單 ghost（`received_*_orders` 可能 route 到）。**pre-existing**（非 Slice C 引入；C 的 team_market_known 走 demolish-only cleanup=正解示範不繼承此病）。**非急**（economy 診斷用；C harvest 濾 `outpost_level>0` 已擋部分 ghost）。修=capture/demolish 順帶清/標 stale market_orders。連 [[經濟 arc]]。

## god-view 殘留 can_reach（faction_ai:1115，2026-07-20，Slice E measure 撿，下批 cleanup）

`_check_precondition` 的 `"can_reach"`（`faction_ai_system.gd:1115`）：`_hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999` = **決策 precondition 讀 live 他隊位**（vs 同函式 `force_ge_target:1109` 用 `BeliefSystem.best_estimate` belief，**不一致**）= 真 god-view leak（違感知鐵律：決策憑 belief 非 live）。**但 `<999` 近-vacuous**（hex 距遠小於 999→恆真）→ god-view 效果近無害、**低優先**。**out god-view Slice E 4-site（E1/E2/E3/E5）**，歸下批 god-view cleanup（Slice E follow-up/D 批機械 belief_pos 化）。**★順帶疑（非 god-view，另類）**：若 `can_reach` 本該真 reachability gate，`<999` vacuous=**決策品質洞**（以為任 target 可達即攻/追，PathSystem 真可達性沒查）——可能 can_reach 該用 PathSystem 真可達 + belief 位一次治 god-view+vacuous。連 god-view audit（`docs/superpowers/handbacks/2026-07-19-systems-to-blueprint-godview-audit-scope.md`）。

## ★constitution_gate v3 god-view detector 揪 2 新候選殘留 leak（2026-07-20，god-view arc 收尾機器證撿）

`constitution_gate.gd` v3 加 god-view 偵測（gv_teamstate=indexed `state.teams[id].動態欄`；gv_mapscan=`for x in ...tiles` whole-map 掃）。enumerate 13 site，凍 baseline v2.txt（含分類註）。triage：7 legit（self/地理）+ 1119(_precond_met,修中)+ 1 gray(consolidate 同-faction own-member pop) + **3 候選 leak**：
- **★`_enemy_outpost_positions`（`faction_ai:2912-2921`）掃全圖敵據點回位置陣列 = 瞬知全敵基建**（違感知鐵律，隊應只知看過/聞得的敵據點）。未記過，detector 新撿。**行為敏感**（改 belief 影響防禦/攻擊規劃）→ 待 R²+measure follow-up slice。
- **★`decision_context.gd::gather`（`:373`）jhost live pos 入 `PathSystem.find_path` 算 join 可達**（jhost=strong_neighbor cross-faction 時=god-view，同 1119 can_reach 類）。未記過，detector 新撿。待 R²+follow-up（可與 1119 同範式 belief_pos-gate）。
- `_find_trade_partner`（strategic_ai）partner discovered(belief) 但 outpost pos 讀 live = 半漏——**已知**（本檔「finder 濾鏈 C 類候選」+ invariants「team_discovered fallback 最終應刪」）。
- **detector 限制**：靜態 regex 分不出 loop var 自/他 → 不抓 `for t in teams: t.tile_pos`（DROP gv_teamscan 噪音），是回歸閘非證明；細粒度靠 review。
- **狀態 ✅ RESOLVED（2026-07-21）**：reviewer R² 判 2 新候選**皆真 leak**（半公共/需知位 REFUTED）→ **followup slice merged 63d93aab**（jhost=belief_pos 同 1119 / enemy_outpost=belief-about-owner store-free proxy，全圖 loop 保留只避已知敵）。baseline 訂正：jhost gv_teamstate 移除、enemy_outpost gv_mapscan re-classify gate-ok(belief-filtered)。gate PASS sites=75 **零 CANDIDATE-LEAK 剩=真 zero-untracked-god-view**。`_find_trade_partner`(strategic C 類候選)續掛 team_discovered fallback「最終應刪」（非 god-view 本 arc，另軌）。god-view belief-化 arc 全收官。

## ★野獸洩進 team 決策迴圈（beast-decision-loop leak，2026-07-19，crisis-immunity QA 故事稽核撿 team=-1000000）

QA 讀 seed1337 trace 撿 `team=-1000000` 連 300 tick `task=建設 reason=ambition food=0 survival_would_succeed=true` 從不轉求生。**身分坐實=野獸**（`beast_system.gd:16` `_next_beast_id=-1000000` 負區段避 team id；TAG_BEAST/leader_id=-1/1 anon pleb/無 food 經濟=戰鬥標的 pseudo-team）。**根因＝beast 未 skip 出決策迴圈**：`faction_ai_system._evaluate_all_body` loop2(`:700` `elif team.faction_id==-1`，beast faction_id=-1 落此支)無 `beast_kind` guard → beast 跑 `_evaluate_independent_strategy`(建國/ambition)+`_evaluate_solo`+`_evaluate_independent_infrastructure`(建設)；loop3(`:759` leader_id=-1)→`on_leader_death` 晉升 anon 當領袖。∴ 一隻鹿/豬跑完整定居隊 AI（野心→建設→晉升領袖），荒謬且污染鄰隊 belief/經濟 + 污染 starve 分母計數。

**非 crisis-override 第 6 種 stuck-task 變體**（blueprint 疑「ambition@10 沒排進 preemption 鏈」= 症狀）。**根＝beast 是戰鬥 prop 非決策 agent，不該進決策迴圈**（補丁閘/root 通則：先查機械洩漏非猜 tuning；別加 ambition-preempt 補丁）。**★第二根（更深，blueprint 全 log 證據坐實 2026-07-19）＝beast id 碰撞**：`_next_beast_id` 是 **instance var 非 static**（`beast_system.gd:16`），但所有 spawn 走 `BeastSystem.new().build_beast_team()`（`faction_ai:3314`/`encounter:1232`/`ambush:57`/`player_command:177`=每次 fresh 實例）→ `_next_beast_id` 每次重置 -1000000、`-= 1` 對即棄實例無效 → **每隻 beast 都拿 team_id=-1000000**。`create_team`（`world_state.gd:256`）= `teams[id]=team` 靜默覆寫 → 後 beast 覆前 beast，前者從 dict 消失但 `combat_target`/belief 的 -1000000 ref 懸空指向新 beast。**這解釋 blueprint 全 log「-1000000 出現 20 次/8月,每次 Combat→晉升臨時領袖(統領0.03-0.28)→buy food」**＝20 隻不同 beast 全撞同 id、各自洩進決策迴圈跑 AI。blueprint 直覺「anon pool 聚合體」對其表象(臨時領袖無生活史)、根實=**id 碰撞 + 決策洩漏**。

**兩修（同票）**：①**id 碰撞**——`_next_beast_id` 改 `static var`（class 級持久跨 new()）或移到 WorldState 持久 counter，讓每 beast 拿唯一遞減 id。②**決策洩漏**——`_evaluate_all_body` loop2/loop3 skip `team.beast_kind != ""`（beast 只留 combat/cleanup 生命週期，在 npc_combat/encounter 非 evaluate_all）。①優先(懸空 ref hazard=更基礎,可能污染 belief/combat_target/其他量測)。behavior 變(beast 停建設/晉升+唯一 id)→非 byte-identical，measure 驗真隊無 regression。**排序**：獨立票，off crisis-override merge 後 main（避 faction_ai 衝突）→ spec-light+R²+dispatch。**與 crisis-immunity 無因果糾纏**（pre-existing）。**★狀態（2026-07-19）：fix 實作@7fb16350 gates/determinism 全綠但 seed1337 真隊 8mo REGRESSION（starve 0→5,attrition 3.15→20.27 ~6.4x,可重現）→ blueprint 裁 investigate,merge HOLD。systems code-read 看不出顯機制（決策-skip 後 beast 被動→「累積圍毆」講不通;beast 勝敗 _end_combat 都 _cleanup→accumulation 不明顯）→ measurer 跑 month3→8 specimen trace（4 信號:beast count/hunt-meat/死因/divergence-point 分機制vs混沌）。混沌→accept;真機制→systems 查根因（accumulation 真則補 beast 生命週期界非 revert id 修）。****provenance（measurer 回證 2026-07-19，closed）**：`extinct.starve` bump（`faction_ai:2299 _on_team_extinct`）**無** TAG_BEAST 守衛，**但** seed1337 baseline 6 starve 全真隊（tid 48/58/52/19/96/35，beast_kind 空，pop=0，famine~33d），**零野獸** → seed1337 真隊 starve 乾淨可引用。2299 加 TAG_BEAST 守衛 = defense-in-depth（beast fix loop3-skip 已關 beast 走 extinct 路，冗餘），已給 implementer 順手可選。**bed 盲點旁註**（blueprint 提）：現 specimen bed 無視野/belief/鄰近資源欄→答不了「窮死前視野多大」；`survival_would_succeed=true` 有海市蜃樓前科(2026-07-14 買糧 applicable)不照單全收→嚴查此類需補欄。連 [[project_desperation_economy]]/[[feedback_patch_gate_first]]/[[feedback_symptom_vs_root_retry]]。

## ★TaskArbiter.transition = 無條件 raw 覆寫後門（手不聽腦，2026-07-19，team16 QA 撿 → systems patch-gate 查坐實）

`TaskArbiter.transition`（`task_arbiter.gd:108-112`）直接賦值 `current_task/task_priority/task_start_tick`，**不檢查 priority、不檢查 crisis-免疫 guard（只在 try_set:45-47）、不檢查 combat lock**。13 caller（`faction_ai:2638/3876`、`interaction:1249/1264/1289`、`outpost:384/406/447/461/566/602`、`player_command:1017`、`sim_runner:259`：defection「等待新領主」/建設/生產/BUILD/beggar-restore）**全繞過**三檢查。∴ transition 可 **clobber 引擎剛派的 survival@80**（手不聽腦：機械 override pre-empt 引擎決策=補丁閘家族）+ **重設 task_start_tick 使 `_famine_crisis`(faction_ai:3462 baseline)恆重置→crisis 永不 fire**。

**血證=team16**：defection path A（`faction_ai:3876`）transition「等待新領主」@AMBIENT → team16 famine `would_succeed=true` 凍死 300 tick（crisis 永不 fire + 免疫抓不到 transition 重鎖）。**PRE-EXISTING @35e9ee8f**（beast-fix 不碰此路）。

**修方向（HOW，待 spec）**：transition 至少守 combat lock + 不 clobber 更高 priority（survival/combat）+ 尊重 crisis-免疫。★13 caller 有正當用途（安頓→生產就地轉換）→ spec 需 measure 逐 caller 不破。排序=beast-fix 定性後（絕境經濟/手不聽腦 arc 真根之一）。連 [[project_desperation_economy]]/[[feedback_patch_gate_first]]/[[project_reverse_engineering_arc]]（控制層手不聽腦）。

## crisis-immunity 覆蓋不全（2026-07-19，team16 揭）

crisis-immunity（35e9ee8f/b71647ab）免疫 guard **只在 `try_set`** → 只覆蓋「release 後走 **try_set** 重委派」的重鎖（team1/19 被接住）。**走 `transition` 的重鎖（team16「等待新領主」）未覆蓋**。∴ 原 release-pass（靶三隊 team1/19/13 剛好全走 try_set 路）= **樣本不完整**，免疫修對它瞄準的有效但覆蓋不全。**非推翻已 merge**（免疫對 try_set 路真有效），但誠實記「覆蓋範圍=try_set 重委派，transition 重鎖需上條 transition 修一併治」。blueprint owner 補 game-design 對應處。連上條 [[TaskArbiter.transition 後門]]。

## ★subteam-idle-latch = 第三種手不聽腦（6 隊，2026-07-19，QA 抓 measurer undercount，HIGH）

bed 3 分類 classifier 測出 **6 隊同款 broken**（team62/71/73/79/84/90），同 signature：`food_days 足(2.5-4.58) + committed=覓食/遷移找糧 卻 task=idle 不執行 + reason=subteam + survival_dispatch_would_succeed=true`。measurer 只回報 1 隊（team84）= undercount，QA 逐隊讀 classifier 抓齊 6。**starve metric 天然看不到**（food OK 不進 famine 分母）→ 別靠聚合判此 arc，需 QA 逐隊讀。

**獨立於 transition-bypass 的第三種手不聽腦機制**：transition 路（defection-stomp）已修（[[TaskArbiter.transition 後門]]），這 6 隊走 **subteam dispatch 路**（`reason=subteam`，疑 subteam 指揮/併隊後 dispatch 沒正確執行 committed 求生 task）。**patch-gate-first**（非 tuning）：查 subteam dispatch 為何在 `committed=覓食` 且 `would_succeed=true` 時仍卡 `task=idle` 不執行。優先序 HIGH（同 quality bar「沒有隊伍能坐著/掙扎落空地餓死」）。歸 [[手不聽腦 mini-arc]]。

## team68 手不聽腦-STUCK + team64 RESOLVED（food-ok idle 坐死，2026-07-19，measurer 死因校準）
> 更新（transition-arbiter QA 稽核 2026-07-19）：team64 branch 93966d15 **SURVIVES**（transition fix 生效）；team68 resolved 成 food-ok-vanish。**team64/68 = transition-bypass 家族已解**（非 subteam-idle-latch 那 6 隊的獨立機制）。

measurer 校準 seed1337 14 消失真隊（`beastfix-lockpoint-deaths-7fb16350-1337.txt`）：9 TRUE-FAMINE（coherent 窮死）+ 手不聽腦-STUCK + 3 food-ok vanish。
- **team68 = 手不聽腦-STUCK（solid）**：food 4.58 **>CRISIS_FLOOR 1.5=不缺糧** + `dispatch_would_succeed=true` 卻 task idle 坐死＝控制層不執行（非餓）。
- **team64 = broken idle-latch（QA v2 讓步 2026-07-19）**：QA 前判 coherent-flee 是**抽樣偏誤**，v2 讓步 = 實為 idle-latch 坐死（food 4.17）。與 team68 同 idle-latch 型。

**★★pivot 到結構 sweep（blueprint 裁 2026-07-20）→ 再定向（finder-check 反轉 2026-07-20）**：subteam-idle v1→v2→v3 三輪 gate-tuning 治標 → 結構 sweep（15 drop 點地圖 `docs/process/hand_obeys_brain_sweep_map.md`）→ slice1 spec（D6+D1/D2 faction 成員 survival 命脈）→ **異質 R² BLOCKING**：would_succeed 只驗優先權零 finder → 真 famine 誤標手不聽腦，slice1 前提未坐實。→ **measurer 補 finder-check（d12ef6fb，RNG-free）重分類反轉圖像**：加 finder 後當前 seed1337 world **idle-freeze 手不聽腦 ≈0、finder-miss-famine ≈0**——finder 幾乎總 hit，「手不聽腦遍地」大半是 finder-blind bed 假象。**arc 真案例（crisis 5-stuck/transition team16/64）已修+merged=真救；slice1 靶 team21/65 岔出當前世界不存在。當前死隊只 team62/73=finder-hit+task=貿易+food 低=task-priority/merge 非 idle-freeze。** **★★手不聽腦 mini-arc 收工（blueprint 裁 2026-07-20）——誠實邊界**：
- **真成果（收工=真案例修好+驗證清楚，非填平所有結構洞）**：crisis-override 5-stuck 家族（`35e9ee8f`）+ transition-arbiter team16/64（`980e0b1c`），兩批經 QA 故事稽核確認真救活、已 merge。
- **slice1 DROP**（faction 成員 survival 命脈 D1/D2/D6）：當前世界 idle-freeze≈0，靶 team21/65 岔走不存在，不建大結構修。
- **未做（靶岔走，除非再冒真實例）**：slice2 D3/D4/D5（等待新領主 preemptible）+ subteam-idle D10/D11（branch `feat/subteam-idle@c53c8cbb` v3 **PARK 不 merge**，target 已 reclassify economy）。**★別讓後人以為「手不聽腦已徹底填平」——是「真案例修好」收工，D1-D15 sweep map 存 `docs/process/hand_obeys_brain_sweep_map.md` 供後續（若真實例冒出）。**
- **team62/73**（finder-hit+缺糧仍貿易/merge）→ **併入 [[經濟 arc]] scope**（食物供給/task-priority 決策品質，樣本僅 2 非急，economy arc 開工一起看）。
- **standing 工具**：finder-check bed（`d12ef6fb`）+ **per-team raw > 聚合 bucket count 判讀原則**（finder-blind bucket 假象教訓）= 本 arc 最實在副產出。
連 [[feedback_frame_challenge]]（異質審攔假象）/[[project_hand_obeys_brain_arc]]。

**★收斂（blueprint broken-count 2026-07-19）＝broken 3 隊可能兩種 DISTINCT 機制，開票別預設同根**：
- **team16 = leaderless-limbo**（已 root-cause 到 [[TaskArbiter.transition 後門]]：defection path A transition「等待新領主」→ crisis 永不 fire + 免疫繞過）。
- **team64/68 = idle-latch**（`would_succeed=true` ×300 能救沒救，task idle）——**機制未定，別預設同 transition-bypass 根**。可能 release-無-redispatch / arbiter latch / 另條 transition。**分開查根因**（QA 提醒）。

`famine_days=0 → 不在 extinct.starve metric`（∴ 不污染 cascade verdict：淨 8 coherent 窮死 + 3 broken stuck + 3 merge/combat + 2 combat）。**pre-existing 控制層 latch**（beast-fix skip 只碰 `beast_kind!=""`，真隊照跑→非 beast-fix；被 seed1337 較苦 basin 暴露）。**開票拆兩查**：team16→[[TaskArbiter.transition 後門]] HIGH 票（root 已定）；team64/68 idle-latch→獨立查根因（別綁 transition 假設）。**bed 死因標籤已批 3 分類修**（famine/stuck-task/手不聽腦，measurer 出 determinism-safe patch）——消觀測盲點（全量暫態可觀測性不變量）。連 [[project_reverse_engineering_arc]]（手不聽腦 arc 未竟殘留）。

## ② stall 對併入-rejection loop 不 fire（retry 不 re-stamp，2026-07-19，crisis-override R² 抓，crisis 已覆）

② `_detect_survival_stall` 判 `survival_committed_option` + relief（`_stamp_survival_commit` **只在 try_set 成功時 re-stamp baseline**）。**併入被 host 拒→retry loop** 不成功 try_set → 不 re-stamp → ② stall 不 fire（team 卡 pending-join 食不回升餓死）。**crisis-override（2026-07-19）已涵蓋**（OUTCOME=famine 未緩，不管 dispatch 成敗）→ 非急。**② 那 gap（retry 該不該 re-stamp baseline）**留 backlog：realistic 應維持首次 baseline（仍卡=stall 累積）而非每 retry 重置窗。crisis 覆後低優先。連 [[project_desperation_economy]]。

## task-priority-preempt 缺口（team48 型，2026-07-18，QA ② ladder 稽核順帶抓，與 ② 無關）

QA 讀 seed4201 specimen 時抓：**team48 死於另一個既有 task-priority-preempt 缺口**（survival 該 preempt 的 task 沒 preempt 到），**與 desperation-ladder ② branch 無關**（非 ② 引入，pre-existing）。① priority 單一源收了 5 dispatch 路的 survival 保序，但 team48 這型疑另一 preempt 路徑漏（待 code-locate）。**獨立票**：不擋 ②。修前先 grep locate team48 走哪條 dispatch + 為何 survival 沒 preempt（別假設=本 session 反覆 state-錯教訓）。連 [[project_desperation_economy]] ① single-source。

## ★乞食死 rung——引擎幾乎不選乞食（2026-07-15，desperation QA 複判抓，絕境階梯斷階）

desperation 複判 6 specimen **全程從沒選過乞食**、log 無 beg print → 不是「幻覺」（never-selected 不守幻覺），是**引擎幾乎不選它**。該乞食的謙卑窮隊從不乞食＝絕境階梯一個死 rung。**非 desperation A 刀 blocker**（A=不選幻覺；乞食沒被選無 A 問題）。**★根因坐實（2026-07-15 code-read，非 util 是 applicability 門檻太嚴）**：`_find_aid_target`（`faction_ai_system.gd:3448`）要求 belief 有 **`food_est` 具體糧估** + 信它有餘糧（`food_est > pop×14`）——這種私有針對性情報通常只在**先前交易過/派人打探過**該隊才形成。剛絕境的隊大機率對鄰居無此具體 belief → `has_aid_target` 常年 false → 乞食**連候選都進不去**（與 util 無關）。對比買糧只需「聽過市集廣播賣單」（公開）寬鬆得多。**乞食非幻覺**（`_resolve_aid_request` mercy floor 有完成路，code 雙證）。**★blueprint WHAT 裁定（2026-07-15）＝盲乞食**：乞討本質＝對**可見鄰居的絕望懇求**（非對已知富 patron 的針對性精算）→ 放寬門檻：絕境隊對可見鄰居**盲試乞食**（不需 `food_est`，`has_belief`/視野內有隊即可）→ 撲空 emergent（謙卑施主給、禽獸拒；mercy 路真能救命＝可選 rung）。**人格 gate**：高求生欲/謙卑/低野心→肯乞；驕傲→寧死不乞（接決策模型）。**backlog 非本刀 blocker**（乞食 dead≠coherence bug，隊有覓食/遷移/掠奪其他路不 limbo）→ 歸「絕境階梯完整性」arc（見 progress.md，與抱團+食物流通同做）。連 [[project_desperation_economy]]。

## ★凍結威脅實體無 resolve/despawn（2026-07-15，QA desperation 複判抓，「無事發生的假戲」族）

Team18 後半 `threat_id:10 / threat_pos:[13,5] / threat_react:8.7` **29 天一個小數點沒變**，food 卻爬 279→369＝**威脅實體掛著不動、無 resolve/despawn**，撐 survival 決策常勝（原地戒備恆合理）。QA 判「無事發生的假戲」家族（決策合理但底層世界靜止不動＝同 thrash/mirage 族——決策層對、世界層沒對應動作）。**修向**：威脅實體須有生命週期（接觸→交戰/嚇退/despawn），非永久靜掛。**可觀測性**：威脅 tap 已能抓（threat_id/react 凍結可見），故此 bug 現形＝觀測投資回報。優先序中（撐假 survival 常勝＝掩蓋真求生壓力）。

## ★SpecimenTracer combat-death 盲點（2026-07-15，違全量暫態觀測不變量）

Team14 真死於 combat（tick9599）但 `decision_count=0`、trace 空＝**combat 死接不到 SpecimenTracer**（tracer 只接決策路徑 capture_decision，combat 結算死亡不經決策 tap）。**違 `invariants.md §全量暫態可觀測性`**（combat 死也是決策依賴的暫態/結局，該可 trace）。**修向**：combat 死亡結算補 SpecimenTracer tap（死因+死前狀態），比照決策 tap。**歸屬**：全量暫態可觀測性補洞（同交易/威脅 tap 家族），非 desperation 刀 blocker。

## survival-latch: _evaluate_survival 每-tick 重觸 churn（2026-07-15，掠奪根 scrap 後 measurer 定位，non-fatal backlog）

真 thrash 殘留源＝`_evaluate_survival` 每-tick 重觸（legacy，非掠奪選擇）→ Team26 day24-26 churn 88/56 次。**但非致命**：Team26 挺過 churn、期間仍行動（有 loot）、死在 60 天後（day85），churn 非死因＝噪音非 bug。**修向**：survival-latch（`_evaluate_survival` 別同快照重觸，＝原執行鎖意圖但對的層——非 recognizer、是「同狀態別每 tick 重跑」）。**backlog 非 urgent**：future 若觀察到 churn 普遍 + perf 貴再做。連 [[feedback_avoid_rabbithole]]（blueprint 判 Team26 剩的是邊際噪音，停追）。

## 絕境掠奪搶糧優先 + 權重量級（2026-07-15，掠奪 fix inert scrap 後 observe-later）

掠奪 hunger-weighted prey fix **inert 已 scrap**（`FOOD_PULL=1.0` 太弱、遠小於 pop_est 量級 + Team26 危機期只一候選＝方法錯，byte-identical，不 merge）。絕境隊掠奪「搶到料沒糧」QA 已判**連貫死**（搶了個也沒糧的鄰居＝真實悲劇，非幻覺）。**observe-later**：絕境掠奪要不要優先搶糧 + 強化權重量級＝desperation-economy arc，若觀察到 raiders **系統性**搶不到糧才做。分支 `feat/loot-hunger-targeting` 棄（inert）。

## 求和 sue-for-peace 無 handler（2026-07-15，diplomacy grounded 揭，backlog）

`handle_diplomacy_message` 無「求和/息兵/tribute_offer」case（只 propose_alliance/propose_trade/demand_tribute/offer_surrender/invite_settle）→ 求和一直被 `_try_diplomacy` 硬寫成 propose_alliance（求盟）。**diplomacy-grounded 刀只讓求和 grounded**（fire→release+cooldown no-op，不 loop 不偽裝求盟）。**真息兵行為＝backlog（WHAT 待 blueprint）**：求和是否獨立行為（納貢息兵讓威脅 de-escalate 退兵）vs 該併外交；要做則建 `sue_for_peace` handler（威脅退兵機制）。

## has_food_market god-view 既有債（2026-07-15，desperation-food-seeking R② advisory）

`decision_context.gd` 的 `has_food_market`（`faction_ai_system.gd:2024-2037 _nearest_market_outpost`）**掃全圖**找最近市集 outpost＝god-view 既有債（違感知鐵律，隊不該全知所有市集位置）。非 desperation-food-seeking 刀範圍（該刀新增的 has_buyable_food/food_seek 已守鐵律），但既有 has_food_market 未修。**修向**：改讀隊已知市集（探索過/傳播聞得）而非全圖掃。**優先序**：低（既有行為，非本刀 blocker），感知鐵律稽核 slice 一併掃。

## ★Team18 lone-survivor death-limbo + intent 誤標致富（2026-07-14，full-HD live 觀察首個獵物）

**來源**：execlock 全-HD story acceptance 找團滅 specimen 時意外揪出（`docs/measurements/2026-07-14-execlock-seed1337-Team18-annihilated.jsonl`，34 entries）。**非 thrash-fix 範圍**。這是「先有結果/full-HD live 觀察」方向提早見效——**真 coherence bug 從 specimen trace 浮出，靜態設計看不到**。

**現象**：孤隊 Team18(pop=1)——tick7110/7120 兩次「併入→投靠」(真掙扎找收留)→ tick7690 起轉「買糧」(貿易 task)→ **連 31+ 天(27+筆/日)coin=0 food=0 卡同一迴圈**，到 trace 尾(tick15130/day63)仍 pop=1。

**兩疑似 bug**：
1. **death-limbo（該死不死）**：孤隊零糧一個月+理論該餓死卻卡 limbo 不死不活。possible root=(a) 買糧-貿易 path **繞過 survival controller**（lone-survivor 子隊死亡/求生判定沒接回引擎）/(b) famine 死亡判定對 pop=1 子隊有洞。
2. **intent-reality 不符（coherence）**：零錢零糧孤隊 AI「想什麼」標**致富/貪婪驅動**非求生恐慌。= 決策模型該防的「慾望不配現實」（垂死該求生欲主導，不該追財）。連 `game-design.md §決策模型 v2`（現實 gate 慾望）。

**歸屬**：**full-HD live 觀察 slice 的獵物**（decision-model coherence，live 才現形）。observe slice 開時優先查此類。連 [[project_desperation_economy]] / 敗北出路家族。

## ★reeval_attribution_bed 死亡偵測 false-positive（2026-07-14，量測可靠性）

`reeval_attribution_bed.gd` 死亡偵測（`elif spec_death_tick==-1 and not spec_last.is_empty(): spec_death_tick=tick`，單次 `state.teams` dict 查無即判死）→ Team18 tick7239 **瞬間 remove-readd**（併入嘗試的 lifecycle）被**誤判永久死亡**。**影響**：measurer 找「團滅 specimen」時把沒死透的隊誤當死透。**修法（L3）**：改連續 N tick 查無才判死、或讀 `population==0` 事件而非 dict-membership 瞬態。**已 dispatch implementer 修**（execlock worktree，量測可靠性在關鍵路徑上）。

## ★小 pop int()/round() 截斷病=結構類（2026-07-10 sweep，blueprint 結構信號；第 3 次同型）
`int(pop*rate)`/`round(pop*rate)` 在小 pop 尺度恆歸零 → 機制靜默啞（探針前砍光=cosmetic 假過關）。血證 3 次：①殲滅端傷亡 `int(round)`→0（§D4 `_cas_carry` de-patch ✅）②pursuit `int(pop*0.05)` pop<18→0（S1 rev2 `_pursuit_carry` de-patch 中）③capture `round(wounded*rate)` 小 wounded→0（部分，rev2 severity 半救）。
**sweep 揭未護欄站**（`grep int(...pop...*)`）：
| 站 | 型 | 建議修 |
|---|---|---|
| `npc_combat:551` pursuit | per-event 反覆 | 累積器（S1 rev2 做中）|
| `anon_tier:277/282` capture wounded/healthy | one-shot | `maxi(1,)` floor 或機率化捨入（三端 capture 相關，優先）|
| `encounter:251/252/1080` armed spawn | one-shot | 驗 ARMED_RATIO_FLOOR 是否已護；否則 floor |
| `reaction:166` minor_cap | one-shot | 視語意 floor |
| `subteam:130` anon_xfer | one-shot round | floor/累積 |
**已安全（有 `maxi(1,)`）**：`population:18`、`reaction:194`、`interaction:126`。**比較用非病**：`faction_ai:3252`/`player_command:48`/`player_query:232`（`int(pop*1.5)` threshold）。
- **★TASK_MERGE 0/8333 真根=combat_target 早退（2026-07-11，S-A merge-blocker）**：`interaction_system:214` `if combat_target != -1: return` 早退，先於 MERGE resolver(:261) → absorber 常戰鬥 → merger 到格早退 → `_try_merge` 從沒 call（實證 merge_accept=0 且 reject=0）→ 0/8333。**= known_issues:18 BEG/JOIN 早退死路同案**（code :216 自註）。修=:214 豁免 social/merge 到達（S-A 折入 `merge-seam-real-fix`）。**★systems 首判「order_target 漏接」=錯**（order_target 早已三路 wired via `_wire_threat_task:401`，首判是不完整讀漏 :1529 helper 呼叫；implementer 框外挑框+實證翻案）→ 教訓 [[feedback_structural_audit_complement]]（characterize dispatch/seam 要讀完整條路含 helper 呼叫，別停在第一塊）。
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
- **★V3 提案 accept=0 診斷（2026-07-05 measure）**：兩因。①**直解結盟門檻恆 false**：`diplomatic_ai:198` alliance accept 門檻 `ALLIANCE_ACCEPT_THRESHOLD=0.55`，但收方視角重算 `_calc_diplomacy_score:112-119` fresh-world 封頂 ~0.44（power_gap belief-fallback=0、relation/rep default 低）→ 結構性不可達。②**帶禮脫 0 槓桿連坐 V4**：`gift_term`(+0.4,足以抬過 0.55) **只隨信使走**（interaction:426），直解(:176)不帶禮 → 依賴 envoy 送達(=V4=0) → 帶禮結盟評估一次沒發生。tribute refuse=score 0.1 不>門檻 0.1(fear≈0)且此路幾乎不發。**修向**：V4 修好帶禮路自通(一修多解)；直解 alliance 0.55 是否「合理的0」(陌生隊無理由結盟,關係建立前)=判準題待 QA/藍圖。
- **★V4 envoy 送達=0 診斷（2026-07-05 measure，非 timeout 太短）**：主因=**far-zone 10× 移速稀釋**（movement:76 `+=TICKS_PER_HOUR` × sim_runner:237 far 每 100tick 才跑一次；自然世界全隊 far）。timeout floor 12 天很寬（`_founding_timeout` faction_ai:1253），但 budget 按 **near 速**校準、信使跑 **far 速(10×慢)** → 走 ~1/10 距離就 timeout。疊加 target 漂移需精確同格(interaction:283)。**=trade 物流同根(known_issues:55 一修雙解)** → far elapsed 積分(B slice)一修多解:V4 envoy + V1 trade + V3 帶禮結盟。
- **★V2-cmd commander 征服路 0 = 結構 shadow（2026-07-05 measure，非純死碼）**：`if "徵收"`(faction_ai:1476) **嚴格支配** `elif "攻擊"`(1486)——攻擊-eligible 成員(軍隊/統領/subteam,`_tag_weight` 831-850)是徵收-eligible 子集 → 有徵收 goal 時攻擊 elif 對這些成員恆死。征服 tick 多半 co-emit 徵收(war_chest 1016 + 補力 levy 1098)→ shadow 常咬。次因:≤2 established faction 樣本薄 + consolidation-merge(1465) 抽走攻擊成員。窄可達窗存在(非純死碼)。**待 2 runtime probe 坐實**:shadow 率(征服 tick 有無徵收)、攻擊-eligible idle 成員普查。修向:若要 member means-end 征服,拆 1476/1486 elif 序 or tag-weight 支配——待藍圖裁 means-end 意圖(獨立 prosperity 路已達征服,member directive 是否必要)。
- **★行軍後勤真帳（2026-07-05 measure，錨①×1 前置）**：×1(240tick/hex=1天/格)下一格糧耗=pop×0.8(pop8=6.4糧/格);乾糧 buffer=`PROVISION_DAYS`(10)天=**僅 10 格**(×5 下 50 格=從不餓死,遮蔽真相)。沿途補給弱(覓食地板僅 1.5 天封頂延後死非延長、路過自家村滿補但長征罕見)。臨界:≤10格安全/10-17格空糧靠 grace/>17格真餓死。**founding(下限12天/12+格)、trade(全圖)不受保護**;`AI_ETA_LIMIT`(1200 固定 tick)使 catch-up/occupy 自動縮 5 格(安全,但它是裸 tick 該進 wave 收編、該隨 BASE_MOVE 或語意天數)。→ 藍圖裁補給機制(升 PROVISION/沿途 raid·買糧/糧耗率/journey cap)。
- **TRIBUTE_* 統一公式權重 = TEST VALUE（2026-07-04 F-I2）**：threshold 0.1/power_r cap 3.0/feud -0.3×int/gratitude +0.2×int/fear/survival 項,保守推導自三舊公式未跑平衡 pass。**屈服率整體上移**（threat 正向項）→ LOOT extort:combat:noop 分佈變,`raid.*` probe 可追,平衡 pass 與 TRIBUTE_* 一起校。
- **merchant seeded 時間線分岔終局（watch,非 bug）**：互動統一後 game_sim_multi merchant config `GameOver 玩家絕後 @tick 849`（RNG 分岔正常終局,coin_eq 守恆）。現無 gate 斷言玩家存活;要追蹤需 seeded 玩家劇本 harness（backlog,要不要做待裁）。
- **RelationGraph dormant edge types（2026-07-04 F-I5 measure 揭）**：`killed` 零 writer/reader（僅 person_data 註解提及）；`protect` writer-dead——"master" memory 全 codebase 無人寫 → `npc_ai._write_relation_edge` "master" arm + `salary._has_master_memory` 讀 = dead chain（12k tick ×2 config 實測 0 條邊）。feud/gratitude 已接線（tribute_accept 權重項）。修向：master/收徒機制實作時復活，或刪 type + salary 讀（salary 在互動軌 scope 外未動）。

### 燒進度（2026-07-01 首三軌 merged）
- ✅ **首燒 戰略 intent 統一 done**（F-D1/D2/D3/D4/D6 收；致富錨接上、CONQUER 0→1）。**follow-up**：①**征服名vs實斷點**(unified 好戰獨立 想=征服但 winner=掠奪,`_decide_unified` 掠奪 option 搶在 prosperity attack 前 → 需讓征服 intent 真驅乾淨攻擊 or 掠奪納征服 affordance) ②**F-D5 unified-tag subteam 進不了 engine**(未收) ③擴張 scorer TEST VALUE(0.3+野心*0.3)待平衡校 ④solo driver 未進全隊持久 ledger(Pattern B 所有權域另軌)。
- ✅ **單寫者 slice1 coin 守恆 done**（F-S8/S1 coin 部分：全池 audit + person.coin 單寫者 + mint ledger；順修 mint-cap 燒 ore 舊項）。**follow-up**：`_route_extinct_assets` no-tile LEAK(`faction_ai:1753`,radius 全無有效格 coin 憑空丟失,正常小地圖不觸發)納下 slice or 標永久豁免。
- **單寫者剩餘 slice（第3不變量 enforce 前提）**：~~tile.public_storage/tile.resources 一般資源 bank(granary/自然池)~~ **✅ done（2026-07-03 S1 tile-bank，TileBank chokepoint 收編 ~40 直寫站點 + mint 守恆 connect + off-map sink，pointwise CLEAN×3 seed）**、**Pattern B 全域 driver-ledger 落地**(現全 6 bank reason stub;TileBank 已帶 record_driver reason)、roster(named_members 59 site)/combat_target/tags/team-creation chokepoint、succession 統一。**剩餘另型欄位（非資源量,未納 TileBank）**：facility levels(outpost/mint/stable/farming_level)、stable_progress、construction_team_id、abandoned_coin(scalar,已 CoinAudit)、resource_cap(靜態)。
- **BEG/JOIN 修（follow-up，探針已證）**：JOIN=中(66/月空轉,需新 resolver + combat_target 社交語意拆)、BEG=低(被197擋)。**建議合併一次修**(combat_target「社交 target≠戰鬥 target」=共根)。BEG endgame-scarcity runtime 頻率未實測(機制已證死,頻率次要)。

### 第二批燒進度（2026-07-01 三軌 merged）
- ✅ **B 食物張力 done**（張力機制到:forest 苟活須交易/plains 繁榮/不 mass-starve）。**★下一閘=交易網未轉真因=建設 util 碾貿易**（specimen 商隊 想=致富但 winner=建設 0.79>貿易 0.26,決策權重域非食物）→ granary 爆倉閘拆後露出。**修向**：貿易 util 提權（有訂單/arb 時應勝建設）or 建設 gate。屬決策權重 slice。**其他 follow-up**：FOOD_PER_PERSON 0.8 + flow 常數 TEST VALUE 待平衡 pass;material harvest ÷24 但 mat_regen 未縮放（建造/製造吞吐未專測,掃一眼）;ambition rung 讀 flow=行為變（marginal 隊 flow=0 起步卡 SURVIVE、prosperity-attack 需盈餘=飢餓不主動開戰）。**★warring 全窗 24 月已驗（系統補跑,radius14 seed）**：**不 mass-starve ✓**（teams 穩~30、Famine 涓滴非潮、DONE、0 error）、**founding ✓**（found_ally=5/factions=7 穩/FOUND=1 全程）、RICH=13 主導（致富錨活）;**但 ⚠ CONQUER=0 全程、established 卡1、EXPAND=0=征服/擴張 emergence 全窗變平**。**根=雙重壓制**:①食物軌 ambition rung 讀 flow → prosperity-attack 需經濟盈餘（食物緊→少隊達 EXPAND rung→少開戰）②征服攻擊路徑分裂（見征服 measure,粗攻擊不轉化）。首燒 bounded-3 月曾見 CONQUER 0→1,加食物軌全窗回 0。**修向**:征服攻擊統一（本批 measure 修向）+ ~~可能 rung-gate flow 門檻放寬~~ **✅ 2026-07-02 R1 三帶裁定改「解綁」非「放寬」**（藍圖 c 路線:拔 rung-food 攻擊閘,食物盈餘只管立國/坐穩/擴編,已 merged;CONQUER 壓平根因收）。
- ✅ **單寫者 slice2 done**（driver-ledger 真記 + roster chokepoint + audit）。**★audit 揭 pre-existing leader/team_id desync**（merchant leader P0 team_id!=本隊,經 leader 指派非-named 路徑;roster chokepoint 已修 named-transfer desync tyrant 4→0,但 leader 指派路徑覆蓋不到）= **第3不變量首個可查對象,root fix 行為變待 triage**（動 leader 指派/team_id 寫路徑）。**其他 follow-up**：`driver_tick_hint` sim_runner 未接線（要真 tick 溯源再接）;反向 roster audit 未做（需先解 health famine「死亡留屍保 team_id」語意）;`beast:30`/`subteam clear()` 兩豁免暫緩。
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
  - **★stale-spec 校正**：spec 標 `event_faction_defect:21` 為「懸空 member_team_ids 行為修（pointwise DIRTY 預期）」= **過時**。現 code line 24 `clear_team_faction`（faction 存在健康路徑）已修懸空；line 21 僅 faction-missing 防禦路徑（known_issues 138/160 證 world_sim 0 violation）→ 改走 `clear_team_faction` = 純 refactor（faction 不存在時語意等同 `=-1`，無懸空可修），**非行為修、pointwise CLEAN**。既有「defect:21 待 systematic-debug」項可結（機制已明：非 bug）。
  - **未收殘欄（本波 scope 外，backlog）**：S6 其餘無主欄（fatigue/work_morale/current_option/strategic_assignments/ambition_*）；`faction_ai:3479` `known_reputations[str_key]=owner_leader` = **cache 濫用 known_reputations dict（string key 存 leader id，非 reputation）**，非 S12 對象，宜獨立改名/搬 cache 欄（呈報系統）。

## 觀測 GUI 揭項（2026-07-04 observer slice，純觀測揭露、sim 未動）

- **★beast pseudo-team 洩入人類系統**：獸隊（id -1000000 段）走 `order_system.tick_team_orders` 張貼收購武器訂單、message 系統對人宣戰帶隊名——兩處未排除 `beast_kind != ""`。另 beast leader_id=-1 → faction_ai 繼承安全網會不會給獸隊晉升人名 leader 待驗。UI 層已標「X(獸)」,sim 側修=order/message 入口加 beast 濾（小）＋安全網 beast 豁免驗證。
- **ticker 同 tick 雙 channel 排序**：global_messages 先於 observer_messages 穩定合併 → 同 tick「收服」顯示先於「俘獲」（code 時序相反）。同日戳可讀性無傷;要嚴格時序需 per-tick 序號（未做,minor）。
- **MAX 速 ticker 滅團標示**：事件主已滅團顯示「隊N(已滅)」=消費時 state,誠實但可讀性小傷（1×/4× 幾乎不見,minor）。
- **observer_messages 無 TTL**：cap 2000 裁尾,sim 零讀無行為風險,僅記憶體上界（by design,記錄備查）。

## 後期 scaling / late-game 卡死風險（2026-07-01 評估，全報告 `specs/2026-07-01-late-game-scaling-assessment`）

> LOD infra 存在且對 movement/economy 正確,但重認知系統 defeat LOD → O(N²)/hr。沙盒長跑須加固(否則大戲跑不到)。非重寫,P0 三項 targeted。
- **★compute top:`faction_ai_system.gd:625 evaluate_all` 忽略 LOD 參數 → O(N²)（2026-07-05 lod_perf_bed 量化坐實）**：`evaluate_all(state, _team_ids)` 的 subset 被 `_` 忽略、`_evaluate_all_body:644` 對**全 factions×全 member_team_ids** 跑（非 near subset）→ faction AI 成本隨總隊數長,LOD 沒 gate。**perf 曲線（seed1337,2月,mean 攤銷）**:21隊 LOD 2994us(334tps)/full-HD 9035us / 41隊 7295us(137tps)/23659us / 107隊 49260us(20tps,max 6.7s)/137747us(7tps,max 7.4s)。**指數~2.0=O(N²) 鐵證;LOD 僅 3× 常數因子（movement/vision LOD-gate 給的,O(N²) 大頭沒 gate）。41隊(warring 自然上限)LOD 已 137tps<240+1s hitch;107隊(強塞 config)兩 regime 全垮**。修=bound faction AI（honor-LOD / 空間分區 / cadence 攤）=獨立 perf arc,規模野心大才值(藍圖裁目標規模,報 `2026-07-05-systems-to-blueprint-lod-perf-data`)。~~`_has_hostile_within` 每隊掃全隊~~ **已修（用 `state.teams_within` 空間索引,此條 stale 劃除）**。
- **★LOD「疏非慢非笨」重定義（2026-07-05,與上 throughput 正交）**：far 移速10×慢/思考10×低頻=遠隊行為錯（物流癱=trade/envoy 一修雙解）。修=elapsed 積分（movement process 收 elapsed_ticks + faction cadence）。**與 O(N²) throughput 是兩回事**:此修行為對(遠隊正常活)但不改 throughput;throughput 修才決定 full-HD 拿不拿掉 LOD。B 修可先開軌(不卡規模裁定)。
- ~~★compute:`world_state.gd erase_team` O(N)/erase → die-off O(K·N)~~ **✅ 批次化 done（2026-07-02 merged,`erase_teams` 單趟 sweep O(N+K),pointwise CLEAN×3 seed=零行為變,scaling 2.1-3.0× 隨 N 放大）**。**cadence spike 接棒案 ✅ 已收（2026-07-02 merged `cadence-spike-fix`）**:量測鏈 PhaseSpike→FaiPhase→call 級定罪（DecisionContext.gather finders A\* fan-out ~65%+_find_weakest_prey ~30%+infra new_loc O(tiles²)）→ 修全行為不變（**SSSP Dijkstra 永續 cache**（terrain 靜態,以 world iid 分層;runtime 改地形須呼 `PathSystem.clear_sssp()`,已留 API）+trusted param 跳 O(n) has+infra 敵 outpost hoist）。**pointwise IDENTICAL×3 seed**。faction_ai hourly 1.2-1.6s→常態 50-70ms(~20×)、早晚曲線平、K 分桶無惡化。⚠ 實作正確擋掉 plan 兩修法:濾先行/memoize 會位移 `observe_velocity` randf 流→pointwise dirty（**教訓:濾鏈含 RNG 副作用,「純 AND 濾可重排」假設要先驗 RNG**）。**→ 殘餘 perf 案（quantified,per-tick 不變量現行違反者,queue）**:①`far.total` LOD far batch 0.45-0.83s/500tick=現 top violator（pre-existing,top-15 spike 全是它）②`loop3.orders_ambition` ~300-330ms（OrderSystem order-cadence 對齊 tick 集中爆）③`unified.rank` 殘餘 gather.market/home_food O(tiles) 掃 <100ms 級。**裁定:不阻長窗**（spike 耗 wall-time 不污染 sim 數據=deterministic;長窗 GODOT_TIMEOUT 預算加大;量測期間勿並行重 bed 防機器爭用）。
- compute 其他 O(N²)/O(N·T)/hr：`_evaluate_outpost_residency:419`(全 tile/隊)、`vision_system.gd:22 tick_discovery`(inner 全 N)、`interaction_system.gd:74`(co-location 全掃,修 pattern 已存 `sim_runner.gd:247` pos_map)、`outpost_system.gd:168 tick_all`。
- **★memory top leak:`world_state.gd:17 team_intel` observer rows O(世界年齡無界)**：`erase_team` 從不 prune team_intel → 每個曾存在的隊留永久 observer dict + 死 target claim rows。per-obs 200 claim cap 有、observer row 無。修=erase_team 加 `team_intel.erase(tid)` + 掃 observer 清死 target（同 create_faction chokepoint）。
- memory 其他：`player_alerts` headless 無 poll leak(diplomatic 未 dedup)、`person_data.gd:54 memory` 繞過 `_trim_memory` 路徑(reaction:369/diplomacy/trade/command)可超 MEMORY_MAX=20。其餘結構全有 cap/TTL/erase-prune 界住。
- **nit**:`world_state.gd:157-158 team_known[obs].erase(tid)` no-op(array 存 MessageData 非 int)→ 意圖 cleanup 沒跑;無害(TTL 覆蓋)該修對。
- **加固排序建議**：granary(定世界規模)→ P0(faction AI honor LOD + tile→teams 共用空間索引 + team_intel erase-prune)配 #2/#3 探針/計時 + scaling bed 驗 → 長跑觀 emergence。
- **P0 加固進度（2026-07-01 merged）**：✅ **tile→teams 索引 done**(co-location O(N²)→O(N)、hostile-within/residency sparse tail 收) + ✅ **team_intel erase-prune done**(top leak 修) + ✅ tick 計時 instrument + scaling bed。**honor-LOD 未觸發**(量到 evaluate_all 誠實 O(N)、索引已足;行為變 measure-gated 沒量到不做)。✅ **die-off erase 批次化 done（2026-07-02 merged）**:`erase_teams` 批次 API,O(K·N)→O(N+K),pointwise CLEAN×3 seed。**🔴 接棒案=cadence tick spike**（見上 ★compute 條:erase 非現行主導,K=0 cadence tick 1.2-1.6s 才是 per-tick 不變量最大違反者;`dieoff_perf_bed` 常備床已入 tree,量測案待排）。scaling bed sparse+high-movement near-zone 場景待加。
- **★致富非 named intent（specimen tracer 揭，經濟真根，2026-07-01）**：獨立商隊決策全走 DecisionEngine per-tick utility 標「日常」,**零 named 致富 intent**(commander-v2 只給 faction intent、獨立隊無致富意圖節點)→ 交易純 emergent、被 survival/食物壓力碾成覓食/買糧(無複利)。**修向（待藍圖）**：致富要不要成 named 意圖=給獨立隊致富 intent 節點(統一決策 arc 延伸);且食物壓力(R1,緩)是掐致富直接手。**更新（首燒 merged）**：致富**已成 named intent**(select_strategic_intent 給獨立隊全菜單) → specimen 商隊現 想=致富262/263。
- **★致富→交易 下一閘＝建設 util 碾壓貿易（B 食物張力 branch 揭，2026-07-01，`feat/food-tension` 未 merge）**：granary爆倉真根**已修**(R1 供給 day_fraction 對齊 + far 冗餘 regen 移除 + R2 成長讀 flow 非 stock + FOOD_PER_PERSON 0.8 張力校準;forest 苟活/plains 繁榮/不 mass-starve 皆 bed 證)。但 specimen 商隊 想=致富262 → winner=**建設**263/263(建設0.79 > 貿易0.26)，**從不貿易** → 致富→交易→成長鏈仍不接。**新真閘 = 決策層 建設 util 高於貿易**（非食物/granary，屬決策權重域,本軌 scope 外）。修向：貿易 util 提權 or 建設 gate（有訂單/有 arb 時貿易應勝建設）＝決策層另軌。
- **★野心 rung 改讀食物 flow → 戰略層行為變（B 食物張力 branch，待主 session 裁）**：`ambition_ladder` 積累 rung 由 `effective_food`(stock) 改讀 `food_flow_avg`(持續淨盈餘) → 新隊/marginal 隊 flow=0 起步暫卡 RUNG_SURVIVE(需持續盈餘才升 rung/觸 prosperity-attack)。**founding 未受影響**(獨立建國用自身 stock gate `faction_ai:994` 未動,framework S1 PASS);但**侵略性擴張(prosperity-attack)現需經濟盈餘**(飢餓隊不再主動開戰)＝合理但屬行為變,warring 全窗未驗(sim 太重 timeout,見 progress)。
- **specimen tracer scope 缺口（非 bug）**：`capture_decision` 只 tap unified+survival winner commit,**prosperity-attack(`_evaluate_prosperity_attack`)+faction-goal-dispatch(~faction_ai:1090) TASK_ATTACK commit 不捕** → 「征服 intent→攻擊 action」鏈那段 tracer 看不到。要完整 trace 需增這兩點 capture。

## 讀B/G3 Phase E backlog（2026-07-01 平行軌）

- **★次閘：定居隊 granary 自填 = trade loop 不 fire 真閘（讀B 覓食 cap 後 measure 揭）**：覓食 subsistence cap 正確封住覓食成長路徑（unit 測 + priv food 壓低證），但 econ_bed baseline 對照顯 **forest 定居隊（regen food=3）granary 月1 即填至 ~cap（gran≈1999）並維持**，pop 成長由 granary（eff_food≈2200）驅動非覓食（priv≈150-288）→ cap 對定居成長影響小 → **trade loop 沒需求驅動、不 fire**。「繁榮須交易」emergence 未到（覓食封了、granary 旁路未封）。屬 **granary/harvest 域**（食物統一 arc 下一 slice），非覓食 cap scope。**修向（待藍圖排序 + measure）**：查 forest regen 3 為何 granary 也填滿（harvest 產出 / storage cap / tile 食物池 init 來源）→ 定居隊 granary 亦須「特化受限」才逼交易。覓食 cap 是必要地板層（granary 修好後覓食不能 backfill 成長）。
- **`FORAGE_FLOOR_DAYS=1.5` = TEST VALUE**：econ_bed/warring 顯覓食隊苟活不死、不膨脹；正式平衡再校（太低=餓死潮、太高=仍自足）。覓食 cap 對玩家 active hunt 同樣生效（對稱），玩家面手感待真人玩測。
- **G3「自信地錯」emergence 需 Phase D + 專屬 probe 才量得到**：Phase E enforce 機制到位（決策真讀 belief、欺敵可有後果、回歸測綠），但**未加專屬「按假 belief 行動並被咬」計數器** → 短窗 seed 無法量化 emergence。需 Phase D（植假 primitive）+ probe。本 phase 只證「決策跟 belief 走」。
- **[列管·藍圖知會 2026-07-02 `ai-depth-roadmap`,非現在做] AI 深度兩項**（roadmap 落 game-design「AI 深度 roadmap」段,藍圖 owner）：
  - **深化二 blocker→子需求**：目標被 gate 擋 → AI 讀 gate-ladder 探針信號把 blocker 變子需求（想立國卡糧→攢糧）+選擇性遞迴一層。零新判斷器（AI 當既有探針 reader）。**觸發條件=長窗數據見「狼卡可解 gate 前乾等」**（長窗回報時順帶標此訊號）。守四關。
  - **經驗=自己的 claim**：被伏擊→「那山谷危險」=一條親見高信 claim,fold 進 belief 域零新學習系統。**G3 Phase D/belief 擴充時帶上**（一行 backlog）。劇烈經驗塑人格=Trait 縫照舊排隊。
- **headless baseline 既有 FAIL：`[FAIL] 弱目標未加入攻擊 goal`（pre-existing，非 G3/讀B 引入）**：已驗 main dd26f67 baseline 即此 1 FAIL（G3/foraging 兩 branch 皆 1 FAIL 同源）。locus = commander-v2 `_update_goals` 攻擊 goal 未對弱目標開（belief/goal-emit 相關，非本輪 5 leak）。待另案追（確認為 bug or 刻意行為）。
- **★headless baseline 現況 FAIL 集（main `ec74d28`，2026-07-12 全量比對，merge-gate 參照）**：headless_test 現有 **5 個 pre-existing FAIL**（多為 in-flight slice 的 TDD-red，非 world-gen 引入）——① `弱目標未加入攻擊 goal`（見上）② `Team23 task=建設 order=-1`（建設 order dispatch）③ `[p2a] join weight 太低 0.41`（:15284，reputation-magnet/survival term p2a）④ `戰鬥中(combat_target≠-1)→197 擋→不 resolve`（:6918，BEG/JOIN social_target vs combat_target，見上 :64 合修案）⑤ `rung 擴張+武力 未選擴張 intent`（:13775，得防衛 target=-1）。**world-gen variety 分支（feat/worldgen-variety）headless FAIL 集與 main byte-identical=零新增** → world-gen 非 regression，merge 於 headless 維度清。融合閘（framework/constitution/coin/determinism）為真 merge 閘，headless 已知 pre-existing FAIL 不阻 merge。未來 merge-gate 以此 5-FAIL 為 baseline，新增才 halt。
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

## G2 目標錨點進度

- **G2a（關係圖 typed-edge）✅** + **G2b（野心階梯狀態 + strategic 衍生）✅**：`TeamData.ambition_rung/archetype/cap` 由 `AmbitionLadder` 從 leader values + 隊安全 derive（faction_ai cadence update）；`strategic_ai._update_faction_goals` 改讀階梯衍生 expand/trade（真 reader，非 dormant）。階梯門檻/權重全 TEST VALUE（待藍圖平衡 pass，handback `systems-to-blueprint-g2b-feel`）。
- **G2c（rung×archetype→task 映射）✅**：`AmbitionLadder.rung_task(archetype×rung)→既有 TASK_*`（零新 task）；faction_ai ambient caller 以 `PRIO_AMBIENT`(最低,只填 idle) 指派；prosperity attack 對齊（僅武力 archetype 才主動征服；**R1 2026-07-02 拔 rung>=擴張 條件**——rung 職權收窄=立國/坐穩/擴編，餬口帶狼由 `find_prosperity_prey` logistics 因子[②路程糧×③belief 歸屬]連續壓權管住，非閘）。rung1-2 三 archetype（武力 TRAIN/→prosperity、商業 TRADE、定居 PRODUCE/BUILD）。立國/稱霸細節、商業遠程商隊(依 G1)、外交/徵收深做 = 後續 refinement。
- **G2d（私人脫軌 / 血仇）✅**：`NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate；`faction_ai` 以 `PRIO_VENDETTA`(55) 脫軌設 TASK_ATTACK（生存/威脅擋得住、prosperity 擋不住）。= G2a `relation_edges` 真行為 consumer（消 dormant）。框架債：pre-existing dormant `get_goal_task_override` 已刪（接 `project_framework_seams` dormant 清理）。
  - **OUT（後續）**：弱仇「偏置」（擴張優先挑仇人邊）= refinement；`killed` 型別深用。
- **A 類 feud 放寬 ✅（2026-06-20 merge）**：feud 由「被侵害」本身形成（劫掠/吞併/屠/背叛，非只倖存被搶）+ **滅族 faction 餘部繼承**（`spread_feud`，事件當下傳同 faction member team，**非血親**）+ severity×個性 gate（`form_feud` 唯一形成點，`FEUD_MIN=0.30` 擋噪音）。把 G2 §5 血仇傳播做實。**血親(parent/kin)傳播仍 OUT** = 待 ④Trait/家族樹（G2 無血緣邊）；獨立團(faction_id=-1)無餘部=仇隨滅消（可接受）。**emergent 量未驗**（world_sim seed77 該 run 零戰鬥；非確定性）→ 遞延 #1 經濟壓力 + scout/ambush 場景。TEST VALUE（FEUD_MIN/severity 階梯/SPREAD 0.6）待有戰鬥重量 run 校。
- **G2 主體（a/b/c/d）全完成 ✅**。後續 = 上述各 refinement + 商業遠程依 G1d + feud 血親傳播(待家族樹)。

## G3 殘缺情報進度

- **G3a（belief accessor seam）✅**：`BeliefSystem.best_estimate/has_belief/uncertainty` 包 `team_intel` 單一讀 accessor；決策單 entry 讀者（diplomatic/strategic/threat/faction_ai/player_api_mapper/inquiry）全遷走它，**行為完全保留**（accessor 回現單 entry 語義，回歸零變）。de-risk G3b：屆時換 multi-claim 只改 accessor 內部，讀者零動。inquiry key 迭代（讀「對所有 tgt」）保留，僅取 entry 改 accessor。
- **G3b（multi-claim 儲存）✅**：`team_intel[obs][tgt]` 由單 dict → Array of claim（值/源/時效/可信度/失真）。寫端三處遷 `record_claim`（vision/interaction 親見 cred=1.0 同源 merge；message 傳播停 confidence-max 覆蓋 → 跨源 append 不覆蓋、同 giver 更新）。`best_estimate` 聚合最高 credibility claim、`uncertainty` 換 claim 分歧（≥2 用 population_est `(max-min)/max`）、caps 剪枝。讀端收尾 sim_bridge/inquiry（`known_targets` accessor）。讀容錯舊 Dict（test/transitional coerce 單親見 claim）。回歸：headless 全綠、coin_eq=0、InvariantAudit 0、1000 tick；行為非保留（多源/分歧為真 WHAT 變化）。
  - **TEST VALUE**：`MAX_CLAIMS_PER_TARGET=4`、`MAX_CLAIMS_PER_OBSERVER=200`、uncertainty 分歧欄選 `population_est`、relay credibility interim `(1-HOP_DECAY)*entry.confidence`（G3c 換 類型×trust×跳數×時效）。
- **G3c-1（可信度公式 + 身份信任 + 類型基準）✅**：claim 可信度從 G3b interim flat → 真公式 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數) × 時效衰減`。寫時 cred 存進 claim、讀時乘 time_decay → best_estimate 改排 effective（新鮮勝陳舊）。source_type 正名真來源類別（親見/隊友/商旅/流民，relay 依 giver 分類；distort 另存 `distorted` flag 兩維度）。**身份信任 = `TeamData.known_reputations`（team→team，覆寫 HOW spec §4 trust 邊，不開 RelationGraph person 邊）**；親見比對 relayed claim pop_est → `update_reputation(source, ±)`（準升騙降，被動查證，record_claim 內單一 choke）。修 G3b relay 雙重 HOP（hop 只算一次）。回歸：headless 全綠、coin_eq=0、InvariantAudit 0。行為非保留（best 排序變 = WHAT 可信度真公式）。
  - **TEST VALUE**：`CRED_BASE`{親見 1.0/隊友 0.8/商旅 0.6/流民 0.3}、`TRUST_FLOOR=0.5`、`BELIEF_HOP_DECAY=0.15`、`CRED_AGE_FULL_DECAY=TICKS_PER_DAY*30`、`CRED_TIME_FLOOR=0.2`、`TRUST_DELTA=0.05`、reconcile 比值門檻 [0.7,1.3] 升 / <0.4 或 >2.5 降。
  - **coupling（interim）**：known_reputations 兼外交/施捨/勒索口碑 → belief 查證 ±它 =「騙我者我也少分享」emergent-coherent（非 bug）。量測顯衝突再拆專用 trust。
  - **OUT（待）**：決策改讀 uncertainty + scout 主動查證迴路（G3d）；team_known 事件謠言 claim 化（G3d/專案）。本 plan 決策仍讀 best_estimate（多源時值改變、接口不變）；查證為被動（親見偶遇既有 relayed 才比對，無 scout dispatch）。
- **G3c-2（技能識破 + 觀察吃技能）✅**：識破 = 收 distorted claim 折 cred（信假/生疑/裁決，best_estimate 排序消費）；觀察吃技能 = 親見值噪吃觀察者偵查/戰術（cred 仍 1.0）。is_suspicious 由 G3b dormant → 分級寫（降 UI/G3d flag，非唯一效果）。TEST VALUE：DETECT_SCHEME_GAIN/SUSPECT_T/ADJUDICATE_T/SUSPECT_MULT/ADJUDICATE_MULT/OBS_SKILL_NOISE_GAIN。
  - **⚠ watch（觀察吃技能 × reconcile 交互）**：觀察吃技能 → 親見 truth 本身可能錯 → G3c-1 `reconcile_firsthand` 拿錯 truth 比對 relayed → 可能誤罰對的 source。主題 coherent（看錯怪線人），balance watch；若量測顯線人信用噪過大 → reconcile gate by observer 偵查 或降 gain（後續）。
  - **OUT（待）**：決策讀 uncertainty + scout 主動查證（G3d；裁決級「觸發查證」在此接，本層裁決 = 強折 cred + flag）；team_known 謠言 claim 化（G3d/專案）；戰術識破伏兵/佯動（戰鬥域 OUT）。
- **G3d-1（決策讀 uncertainty + 風險 gate）✅**：攻擊性 commit 讀 (best 值 + uncertainty)，`BeliefSystem.confident_enough(觀察者,目標,慎重)` gate（confidence=1-uncertainty、threshold=lerp(LOW,HIGH,慎重)）。插 faction_ai prosperity attack + survival loot、diplomatic demand_tribute。不確定+慎重→被動按兵（下次 cadence 重評）；莽者→照衝→假情報誘殺。不 gate 威脅(防禦極性反)/vendetta/結盟求和。survival loot gate 失敗 fall-through 不凍結。回歸：headless 全綠、coin_eq=0、InvariantAudit 0、200 Tick sim 仍有攻擊（不凍結）。行為非保留。
  - **TEST VALUE**：`GATE_CONF_LOW=0.0`、`GATE_CONF_HIGH=0.6`（莽者門檻 0 恆過，慎重者需 confidence≥0.6 即 uncertainty≤0.4）。
  - **OUT → G3d-2**：①scout 主動查證迴路 ✅（見下）②威脅(防禦)uncertainty-gate（延 post-measure）③team_known 謠言 claim 化（延 post-measure）。
- **G3d-2（scout 主動查證 + uncertainty cred-weighted）✅**：①**uncertainty 重定義 = credibility-weighted**：`clamp((1−top_eff_cred)+cred 加權值分歧,0,1)`（top=最強源 eff_cred；分歧=`Σwᵢ·|vᵢ−best|/(Σwᵢ·best)`）。取代舊 raw `(max-min)/max`——親見高 cred 主導壓謊→查證可收斂（舊式親見壓不掉舊假 claim → scout 永不收斂，故為 scout 前提）。既有 G3b/c uncertainty 測試核對後**仍對齊**（accessor 0.2 / multiclaim >0.5 / confidence gate / diplomacy 皆同號）。②**scout dispatch**：`_evaluate_prosperity_attack` gate-fail → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位，PRIO_DISPATCH，reason "scout")、記 prosperity_target_id=prey、**不設 combat_target**；confident 後 release scout（同 PRIO_DISPATCH 擋不住自身）→ try_set ATTACK。莽者跳過誘殺不變。回歸：headless 全綠（cred-weighted/scout verification/attack gate OK）、coin_eq=0、InvariantAudit 0、1000 Tick、`[Scout]`+`[ProsperityAttack]` 並見（不凍結、收斂）。行為非保留。
  - **TEST VALUE**：`SCOUT_TIMEOUT=TICKS_PER_DAY*3`、uncertainty top/spread 權重。
  - **⚠ watch（收斂依賴時效/值接近）**：cred-weighted spread 由 best_val 正規化——假 claim 值離 best 越遠、cred 越未衰，uncertainty 越壓不下（真打架→持續 scout 直到 SCOUT_TIMEOUT release）。設計符合（矛盾大本該查不停）；若 sim 顯 scout 過頻/卡 timeout → 調 SCOUT_TIMEOUT 或 GATE_CONF_HIGH。
  - **scout 追擊精度**：`_refresh_attack_pursuit` 僅處理 TASK_ATTACK/LOOT，scout 追擊靠每 cadence 重評刷新 move_target=最新 best_estimate（prey 移出視野→走陳舊位→timeout release）。可接受（timeout 防卡），未做攔截預測（OUT）。
  - **OUT（待 post-measure）**：威脅(防禦)uncertainty-gate（§8 極性反）、team_known 謠言 claim 化（§3 獨立 arc，**告知藍圖呈報**）、斥候被抓/餵假（C 情報戰）。
- **G3-targeting（攻擊目標選擇讀 belief）✅**：G3d-2 揭的 `find_prosperity_prey`/`_find_weakest_prey` 直讀 prey 真 population/resources（god-view）缺口**已補**——選擇層 richness/weakness/pop 一律經 `BeliefSystem.best_estimate`，`has_belief` 守衛無情報不評估（禁 fallback 回真值）。weakness 吃 `armed_est`(偽裝載體,退 pop_est)、richness 經 `_belief_richness`(tier2 sum/100 → resource_scale 粗估 → 0)。自身真值照讀、位置 reachability 讀真位(物理 OUT)。**誘殺脊椎閉環**：選擇讀假 belief(本) + gate 把握(G3d-1) + scout 查證(G3d-2) + 戰鬥按真實力結算。回歸 headless 全綠、coin_eq=0、InvariantAudit 0、`[ProsperityAttack]`+`[SurvivalLoot]`+`[Scout]` 並見(不凍結)。
  - **TEST VALUE**：`_belief_richness` 粗細混排(tier2 sum/100 vs resource_scale 0-3 同尺度排序)、survival `_find_weakest_prey` food 門檻（belief 無 food_est 時不擋,以 pop 弱點為主）。
  - **OUT（延 post-measure）**：威脅(防禦)uncertainty、team_known claim 化、情報戰 C（同 G3d-2 OUT,本 plan 只攻擊選擇真值→belief 遷移）。
- **⚠ [高·measure-first·藍圖裁定中] 征服者 emergence 卡 ambition-ladder EXPAND gate — 非 targeting/reachability（2026-07-02 attack→combat measure）**：藍圖裁「measure 90% 攻擊為何不進戰鬥→修 targeting/reachability」**被 measure 證偽**。seeded warring 14400 tick 漏斗探針（`conquest_measure` funnel census + `prosp.gate_*` ladder）：**追擊距離 0.48 hex(貼身)、reached→combat ≈100%+ → 追不到/接觸轉化都不是問題**；征服者 **14400 tick 只真派出 1 次攻擊**（`conq.prosperity_reached=1`），卡在 `_evaluate_prosperity_attack` 第一關 archetype/rung gate（faction_ai:200）。**雙等根**：**R1 rung(50%)** = 主動征服需 `ambition_rung>=EXPAND`，爬 EXPAND 需持續糧盈餘 `food_flow_avg>=0.5/日`+pop>=8（ambition_ladder:54-58），但 **86.5% FORCE 隊 food_flow<0.5 卡 SURVIVE**（rung 狂 yo-yo 0→2→0）——苟活戰爭經濟無糧盈餘→爬不上征服階（= #10「食物 rung-flow-gate 壓平征服」釘成主瓶頸）；**R2 archetype(48%)** = 隊有 `征服` solo_intent 但 `ambition_archetype≠FORCE`——`select_strategic_intent` 與 `AmbitionLadder.derive_archetype` 兩判斷器讀同 leader values 48% 分類矛盾（決策域不變量違反,統一矩陣型缺口）。**狀態：✅ R1+R2 merged（2026-07-02,handback `2026-07-02-r1-threeband-r2-retire`）**——R2 disposition 共源+derive_archetype 委派（判斷器−1,desync 結構歸零）;R1a 拔 rung-food 攻擊閘;R1b logistics 因子（②路程糧×③歸屬,belief claim+deceive faction_id 誤報 channel+未知→0.5 保守 fallback）。**驗收**:③管住（believed-owned 攻擊=0）、不 over-war（隊數 75→78/attrition 降）、絕境仍搏（surv.loot 140/201）、貿易不歸零（[Market] 3→9）、specimen 狼弧可見（想=征服→做=raid 78/80）、回歸全綠。**⚠ 殘項**:①`prosperity_reached` 1→4 **未達門檻 10**（方向對量級不足;三因:R2 分布位移 FORCE 16%（義氣負項,好戰 boost 腳本半數狼落 TRADE）/91% FORCE 隊 food_flow<0.5 在 survival 域佔用/drift）→ **呈藍圖裁**（收貨 or disposition 權重平衡 pass）②assimilate 如預測=0（win_absorbed=0/P1Absorb=0,manpower cadence=下一瓶頸候選）③~~「intent=征服且被 archetype 擋」交叉探針~~ ✅已加（`prosp.desync_conq_blocked`,長窗 6 月=0 ✓）④seed42 post 對照因機器爭用未取得（assets JSON 已入庫,獨占時補跑）。
- **長窗斷鏈修進度（2026-07-03,長窗 6 月+zoom 拆根,藍圖四裁 `chain-rulings-envoy`）**：
  - ✅ **②a found_ally 凍結修 merged（`envoy-diplomacy-fi1`）**：founding timeout（距離估非死常數,MULT=6.0/floor 12 天=**步行信使追移動 target 實測收斂裕度**,TEST VALUE）+ **信使實體**（herald+子隊+撥馬+冗餘騎+自身 timeout,零新系統）+ 送達走 `handle_diplomacy_message`（belief）+ **F-I1 退役 god-view `team_strength` 接受公式（judge −1）**。驗收:T32/T34 解凍（不再跨月卡 found_ally,結構必然——母隊派信使即 release）、T32 raid 曲線恢復、S1 PASS、envoy 分佈 dispatched=5 delivered=2 accept=1 reject=1 timeout=1、回歸全綠。**行為變（pointwise 預期 DIRTY）,月線 sanity 過**。
  - **⚠ 同型缺口列管（新 invariant「凡 latch 必 timeout」CI-scan 候選）**：faction 外交 goal 路徑（`_assign_tasks`/`_assign_member_tasks` 外交→TASK_DIPLOMACY 直追）**仍無 timeout**——本波只修獨立建國路。同型,待掃全 dispatch-guard 補齊。
  - **⚠ 無馬經濟 → ★升 vision 標記（藍圖 2026-07-03 `envoy-acks-horse-vision`,經濟深化 pass 做,非現在）**：seeded 世界 mounts=0=信使/騎兵/機動 movement 模型全 dormant。vision:**馬=亂世戰略資源**（中原缺馬 vs 北方產馬=戰略不對稱）+**地形特化貿易品**（產馬區→賣馬→騎兵/信使加速,接地形特化-交易網,貿易 stakes 新維度:馬貴/軍事價值/禁運=外交武器）。連鎖:信使 timeout 縮回、E-2 騎兵、機動戰;stable 設施已在=半地基。**時機:經濟深化 pass（複利弧優先）**。暫收 (c) 步行信使慢=believable。
  - ✅ **第二波 merged（2026-07-03 `asm-deepen-hunger-raid`）**:**②b/②c 達標**——T36 餬口狼 raid 0→37-54/月（hunger_relief 只降 prosperity 搶糧路,T32 食足不誤放/T29 知足仍蹲/不 over-war attrition 47.1% vs 47.9%）;food<20 濾殺=0 窮村可俘;score 0.30→0.25。**★③ asm 誠實呈報:completion 1→0 反向（同 seed）——spec「flee-always=主斷因」假設證偽**:main 唯一 completion 靠「厚待免費餵養」（假 affordance）撐出;真掏糧後食貧狼付不起 25 天餵養（feed_quality 崩→厚待失效）+ FORCE 狼高殘忍選苛待。**=以戰養戰經濟真相:raid 搶的糧<養俘成本（目標全窮村）**。機制無 bug（headless 決定性:厚待+糧足→必同化;guard/cap/守恆全過）。**值旋鈕升藍圖裁**（INIT_MORALE 0.25/FOOD_RATE 0.5/ASSIM 窗 25 天/treatment util,handback `asm-wave-falsified`,我傾向 INIT→0.35+FOOD_RATE→0.3+壯兵 intent 厚待加權,消化期不縮）。**guard_ratio 機會成本未實體化**（調變比例非真抽 anon 出生產,後續 task）。treatment_history String→Dict（消費端型別檢過）。
  - ✅ **asm 旋鈕落地（2026-07-03 藍圖 `asm-knobs-slavery-dial` 裁,L3×3）**:FOOD_RATE 0.3/INIT_MORALE 0.35/壯兵 intent→厚待加權 0.3（means-end 接回）;ASSIM 窗不動。asm 三測過。**驗收框改三帶**（糧正狼同化成/純餬口敗=believable/殘忍照炸）,長窗二跑驗。
  - **[列管] 奴役=合法終態（用戶裁,Phase 2/3 照舊）**:處置 means-end 按意圖（要兵→同化買斷/要勞力→奴役租/要錢→贖賣/要威懾→屠）。**build gate=勞動產出 hook 要真**（俘虜幹活→採集建設真加速,否則假 affordance）。**觸發=長窗二跑見「狼卡 養不起同化↔白放 之間,中間選項缺」→提前 build**。spec §4b 已補（看守=買暴動的 dial:同化=買斷壓力遞減/奴役=租恆壓;戰時守衛抽走=暴動窗;named 剛烈寧死不為奴+頭目效應煽動,零新判斷器）。
  - ✅ **斷① merged（2026-07-03 `raid-continuity-identity-weight`）**:打草穀（候選放行成員）+ ③own 減免只給能拍板者（leader/獨立;成員 day-op 對屬村恆基準罰,`member_atk_believed_owned=0` 哨證）+ 不換腦 enforce 第一處（拆 fid 早退,成員跑戰略 intent 層;`_evaluate_solo` 全域=後續 F-D 矩陣格）。**asm 三帶框首驗過:completed=2>0（糧正狼同化達標,新旋鈕生效）**,interrupted 5 仍主導（隊死/散/逃=另鏈）。**⚠ 實作抓出 spec PRIO 誤述**:實碼 `PRIO_DISPATCH=50>PRIO_FACTION=30`,真 enforce=prosperity idle-guard+急件層（80/70/100）;殘留反向 race（成員 raid@50 先設→directive@30 搶不動至 release）**系統裁可接受**（短 op+cadence 重發+急件壓;三軌若見抗令再調）——spec 已補正註。sampling gap:該 seed 代表狼全程 fid=-1,member raid 由 unit test 直證。
  - ✅ **長窗二跑三軌 done（2026-07-03,`longwindow2-results`+assets）**:軌1 斷鏈修全過（T36 raid 活法閉環/asm 暴動歸零/T32 糧正不誤放）;軌2 泛化 ✓（seed7 by_attack=3 首 fire）;軌3 default 半死寂（過擬合 warring 密度部分成立）。藍圖裁（`dual-engine-horses`）:**雙引擎複利**（人力×糧,咬合點=佔村）。
  - ✅ **三平行軌 merged（佔村/誘因結盟/馬 slice,2026-07-03）**:
    - **佔村**:measure——「戰不落村格」否決（100% 落村格,翻旗 13 真發生）;**主斷=收益鏈**（(a) 翻旗村不為新 owner 產出:`_team_works_tile` 擋原住民 (b) 小狼贏不了圍城:pop8 圍 pop15-25 必敗=循環依賴 (c) asm scatter/escape）。option=safe foundation（means-end 佔/走並列+緊 gate,dispatch 13 翻旗 0）。**→ 收益鏈修=下一燒**（村民→受控人力歸新 owner/圍城勝算/同化鏈三段）。
    - **誘因結盟**:accept 脫 0、白嘴仍難、禮沉沒=押鏢、聯姻槽 payload 鋪好。
    - **馬 slice**:產馬帶（seeded 集中=戰略不對稱地基）、stable breed、mounts 入訂單鏈、envoy 配馬 ×2.96 速;breed 湧現 world_sim 印證,warring 因 stable 建造率低餓死=config 投資偏好非源缺陷;`horse_slice_proof.gd` 留作源回歸閘。
  - ✅ **征服收益鏈 merged（2026-07-03 `conquest-yield-chain`）**:A 翻旗接治權（capture∧subjugate 合一,三 case 含以戰立國授統領;`flip_with_rule=2`+`works_tile_pass=93`=**村產出真歸 owner,主斷閉合**）;B margin gate（真 armed≥believed pop×0.1×1.3,`kill_margin=2310` 弱狼不自殺=序列成長階梯）;C 收取鏈驗**無洞**（effective_food 現格制=既有設計+home_food 決策層 restock 閉環,**系統確認不動全域 accessor**）。Team32 糧引擎正循環（flow +3~4.7/pop 7→9）。asm (c) 殘留順記。全弧 specimen 串接=軌3 二考驗。
  - ✅ **單寫者 B 波 merged（2026-07-03 `singlewriter-chokepoints`）**:5 chokepoint（create_team S9/tags S5/readiness+solo_intent S6/faction_id S11/reputation S12）,pointwise CLEAN×3、直寫殘量 grep=0、**CI-scan pattern 每 chokepoint 附=強制閘地基**。**defect:21 stale-spec 證偽**（防禦路徑健康,純 refactor;舊「待 systematic-debug」backlog 結案）。create_team 剪 scope 保 pointwise（tile index/intel row lazy init 各歸其主）。順修 recruit_tutorial 漏 init。S6 殘量（fatigue/work_morale/current_option/strategic_assignments）列殘;**S10 stale 劃掉**（slice3 set_leader 順收）。
  - ✅ **S1 tile-bank merged（2026-07-03 `tile-bank`）**:TileBank chokepoint（banker pattern mirror,判斷器淨 0）、~40 站點收編（豁免明示:bootstrap+player F-P）、pointwise CLEAN×3、mint 走 bank+minted 軌、兩舊項結案（mint-cap 燒 ore/off-map coin 顯性 sink 入全池）、S5 mint 魂活、CI-scan 附。另型欄殘量:facility levels/stable_progress/construction_team_id/resource_cap。**→ 第 3 不變量單寫者大塊全齊,強制閘可全立**。
  - **★管線序（現位置→）**:①~~收益鏈~~✅~~單寫者B~~✅~~S1 tile-bank~~✅ → **default 組成/健康 measure（FORCE 狼=0 根因+和平隊餓崩）→ 藍圖裁生成參數 → 軌3 二考** + 強制閘全立（CI-scan 已鋪,收攏成閘）+ cadence spike 殘餘（far.total/orders_ambition）+ 矩陣剩餘（互動 F-I2/I4/I5/I7[順盤 finder 濾鏈 C 類 watch]/人力 F-M1-7/belief F-B1/B4/S6 殘量;F-P 留玩家面）②**觀測 GUI 輕 slice**（bar=看著狼崛起）③願景凍結照舊。G3 Phase D 照排。
- **⚠ [量測基建] world_sim 非確定性 — ProbeSummary 不可作回歸/歸因閘（#0b 實證）**：handoff #5「seed 77 可重現」**不成立**。同一 branch 跑兩次 ProbeSummary 大幅分歧（promote 35↔71、trust_up 14735↔3690、feud 1↔0、末月存活 8↔7），run-to-run 噪聲**遠大於** pre/post 差 → 無法對任何改動做 emergent 因果歸因。擴展既有 [[reference_multi_sanity_unseeded]]（multi drift 不可重現）至 world_sim。**系統裁定**：world_sim = **不可重現煙霧台**（驗「不崩 + ProbeSummary 仍印 + faction_found≥1」），**非平衡/回歸證據**；emergent 因果一律走**確定性 headless 場景 + 定向探針斷言**（如 #0/#0b 重量證 root 走的是 headless 階梯差，非 world_sim drift）。**含 feud plan Task3**：其 world_sim `feud_formed 對照前次` 同屬煙霧，真驗收 = gate/spread 單測（確定）。**選用後續（不阻塞）**：若要 world_sim 可作閘 → 補種子化（全 `randf()`/`randi()` 走 seeded rng）= 大改（散落多系統），post-#1 評估。
- **✅ 懸空 known_reputations 死隊已修（`2933563`，systematic-debug）**：root = `belief_system.reconcile_firsthand`(165-176) 迭代 claims 對每個 `sid`(來源隊) 呼 `update_reputation(sid)` **無 liveness 檢查**；claim 存活過來源隊（隊死後其轉述仍留別隊 team_intel）→ reconcile 跑到死隊 claim → `update_reputation(dead_sid)`(team_data:174 建 key) → 重注入死 id。`erase_team:147` 死時清了但 reconcile 死後重注入。**修 = `reconcile_firsthand` 加 `if not state.teams.has(sid): continue`**（死 source 不更新口碑）。world_sim InvariantViolation **556→0**。先前「補 erase_team 清 team_intel」猜錯方向（症狀非根）。**教訓**：藍圖 `state-fight-scope` 指 event_faction_defect:21 是另一回事（faction bidir，world_sim 0 violation，防禦清理非 bug）——reproduce 校正 pointer，[[feedback_verify_backlog_fresh]]。

## 框架驗證套件（2026-06-22 framework-validation 子 session）

- **Part 2 魂觸發 harness（`scripts/debug/framework_validation.gd`）✅**：每魂最小場景 setup→觸發→斷言 probe>0。**全 7 魂 PASS**（S1 立國/S2a feud/S2b vendetta/S3 scout/S4 ambush/S5 mint/S6 order_fulfilled）= 6 子系統魂的 plumbing 全可觸發，**無 code-level dormancy**。
- **dormant-in-default backlog（魂在預設 2yr world_sim 不觸發，非壞 = 場景稀有 / TEST VALUE 門檻高）**：定向 harness 證可 fire，但預設世界 run 計數為 0 —— 觸發鏈正確但**自然發生條件罕見**。各魂初判：
  - **`g2.vendetta_trigger`（world_sim=0，harness PASS）**：vendetta@55 被 threat@70 系統性擋住（設計優先序）。自然只在「強隊 leader 對**已不構成現役威脅的弱小舊仇**」才觸發（仇敵須被發現但 ThreatAssessment score < 門檻）。預設世界血仇多伴隨現役敵對 → threat 先佔 → vendetta 罕見。**非 bug**（符合「威脅優先於私仇」invariant）；若藍圖要 vendetta 更常見 → 調 VENDETTA_* 門檻或弱仇偏置（G2d OUT 已列）。
  - **`g3.scout_dispatch/converge/timeout`（world_sim=0，harness PASS）**：需 FORCE archetype + rung≥擴張 + attack_score≥.3 + readiness 過 + **prey belief 不確定 + leader 慎重**全同時成立。預設世界多為親見高 cred（uncertainty 低→直接攻不 scout）或莽者（低慎重恆過 gate 不 scout）。場景稀有，鏈正確。
  - **`g1.mint`（world_sim=0，harness PASS）**：需 tile `mint_level>0` + 居民 PRODUCE 隊 + `ore_gold/ore_silver>0` 同時。預設 config 無金/銀礦 tile 或無鑄幣廠設施 → 鏈空轉。**初判 = 場景/config 缺供給端**（金銀礦生成 + 鑄幣廠建造路徑未在預設世界出現）；接 G1a 鑄幣 arc，待 config 補金礦 + AI 蓋鑄幣廠評估。
  - **`g3.ambush`（world_sim=0，harness PASS）**：`Probe.ambush_check`（觀測點）僅在 encounter 敗方=攻方時呼（attacker 誤判弱敵踢鐵板）。預設 2yr 該 run 無「攻方低估 belief 且戰敗」事件 → 0。純觀測探針（不 gate AI），誘殺脊椎成立才會自然累計。
  - **fire-in-default（對照）**：`g2.faction_found=1`、`g2.feud_formed=3`、`g1.order_fulfilled=4`（+ g1/g3 經濟/belief 大量活動）在預設 2yr 自然觸發。
  - **量測注意**：world_sim 非確定性（見 §「量測基建」），上述 0/非0 為單 run 快照，run-to-run 會抖；harness 為確定性證據（魂可 fire），world_sim 計數僅佐證自然頻率粗略級別。

## G1 供應鏈進度

- **G1a（鑄幣觀測：W8 機制已存 + log/驗）**、**G1b（訂單 infra + 餘→賣盤 + 需求驅動生產）✅**：訂單走 message（權威存發起隊 `active_orders`，emit 為可失真傳播副本）；`OrderSystem.tick_team_orders` faction_ai cadence 發賣盤 + 過期清；`manufacturing._run_recipe_group` 讀 `received_buy_orders` 偏向需求 recipe（訂單真 reader，非 dormant）。
- **G1d（商隊訂單驅動 + 短缺買單）✅**：商業 archetype 隊 targeting 改讀 `team_known` 訂單（`best_arbitrage_order`，殘缺情報），取代 `_find_trade_target` 的 `team_discovered` 上帝視角（後者降 fallback/標 deprecated，最終應刪）；`tick_team_orders` 短缺發買單（料/武器 < `SHORTAGE_QTY`）→ G1b infra 閉環（賣盤有 reader、生產買單有來源）。到場履約走既有 interaction 同格 trade（守恆）。撲空 = 訂單 stale → `local_value` glut，emergent 無新機制。
- **#1 訂單履約 ✅（2026-06-20 merge `186e433`）**：`OrderSystem.settle_orders`（`_resolve_market` 後按 res 淨變沖 `active_orders`、填滿移除 + 點亮 `g1.order_fulfilled`/`g1.arb_hit`）。純記帳、守恆無關。settle 機制單測證正確（履約/部分/撲空/sell 對稱）。
- **⚠ [中][measure-first] order/trade 迴路 runtime 半 inert — 商隊 runtime 不交易（履約 merge 後揭）**：履約 code 正確但 world_sim 該 run **`g1.arb_attempt=0` + `[Market]成交=0`**（整 run 零交易）→ 履約率仍 0%。**非結算 bug，根因上游**：商隊 `_merchant_trade_target`(faction_ai:1180) 的 `best_arbitrage_order` 從未回非空單 → 沒商隊被 dispatch TASK_TRADE。懷疑（**未驗，別猜** [[feedback_avoid_rabbithole]]）：①商隊沒成形/沒掛 `TAG_MERCHANT`(archetype 派生) ②`received_buy/sell_orders`(team_known order message) 空 — message 沒傳到商隊 or `MERCHANT_MAX_RANGE`(20) 外。
  - **WS-1 食物糧倉已 merge（`cde372c`）= 殺幽靈囤 + 滿了賣決策**：food→capped 糧倉、消耗合併池、food sell 單 fire。囤糧崩（4-5萬→cap≤18000）、無過餓。**剩待後續**：①**UI/面板讀 team food 誤判**——定居隊 team.resources food 現=0（全在糧倉 public_storage），面板/FoodLedger 若讀 team food 顯示「沒糧」（消耗合併池已正確不誤餓，純顯示層）→ 需改讀「team+自家糧倉」合併。②**food 買單側未做**——糧倉滿發 sell，但飢荒隊買 food 的 buy 單未補（`tick_team_orders` shortage_buy 不含 food）→ 食物經濟只半邊（賣有、買無）→ 待補 + WS-2 市集完成交易。③**食物稅語意變更**（systems ack `cde372c`）：food 進糧倉不走一般稅 split（=自存自村，語意一致），稅 split 機制測覆蓋已移 material。
  - **⚠⚠⚠ [FOUNDATIONAL ARC·藍圖裁定 2026-06-21] 經濟真根 = AI 決策框架不統一 → 做「統一決策框架」大 arc**：完整 trace 證實——商隊 T1 掛商隊 tag 但 leader 人格 derive archetype=定居 → 目標錨驅動建設/生產，跟 WS-2/2b tag-based 商隊 hoist 互搏，貿易每 ~2 天被搶走 → 震盪永不完成一趟（d8 鐵證：人在別人市集、有 arb、卻在生產）。藍圖+用戶定論：**真根更深，非經濟局部**——目標錨/faction AI/solo AI/subteam/商隊 hoist/survival **各自 latch task、用 ad-hoc TaskArbiter 優先序互搏**，無「一隊一個連貫決策」。= `[[project_framework_seams]]` 框架債現形。**決定做統一決策框架 foundational arc**（比經濟大，惠及全 NPC 行為），(a)/(b) tag-vs-人格 patch **全不做、fold 進框架輸入**。believability bar：①一隊一連貫決策（survival/野心/archetype/tag/faction/feud/經濟 全是 weigh 的輸入）②加行為=加 term 非加吵架子系統 ③服務全行為類型 ④**連貫≠同質（人格必須分歧權重，嚴禁抹平戲劇尾巴）** ⑤任一隊在幹嘛都講得出「所有驅力綜合此刻最該做這」。HOW（我）：utility 形狀 / 從 N 子系統遷移路徑（de-risk seam-first 如 G3 accessor）/ term 權重 TEST VALUE / 保人格分歧機制。**經濟=第一個驗證案例**（框架對→商隊不被搶→走完貿易→6 層 plumbing 被 exercise→履約脫 0）；arc 須含重量經濟驗證當驗收。WS-2/1/3/2b/2c/2d 六層 plumbing **不浪費**=貿易執行層，只是被破碎決策擋門外。ruling `2026-06-21-blueprint-to-systems-unified-decision-framework`。**待開 brainstorm/spec**。
    - **scope map（藍圖徹查 `state-fight-scope`）**：**Pattern A 決策吵架** = 6 平行意圖槽（current_task/task_priority/move_target[無 arbiter,22 寫點]/strategic_assignments[第二套決策槽]/combat_target[全域 mutex,一沒清=整隊凍結]/prosperity_target_id/order_target_id+order_task[一槽三義]）+ 3 生產者（faction_ai→strategic_ai 順序耦合）+ 5 cadence 時鐘自閘 + IDLE-only 重評（結構性餓死=stuck 主因）+ 雙重意圖表徵 4×（goals/strategy/strategic_goals/player_goal_override）→ **收成 1 生產者/1 意圖表徵/1 weigh 非 latch/去 IDLE-only**。**Pattern B 所有權吵架** = 6 池 delta-vs-絕對 set 互洗無銀行（loyalty ~26 寫/resources ~110 寫/anon_treasury 24 寫[貨幣守恆風險]/unrest_turns[歸零壓掉該爆叛亂]/outpost_owner 16 寫/stress·fear）→ **各設 banker 收 delta 禁外部絕對 set**。現成乾淨 owner 藍本：ambition_ladder.update / AnonCohort / RelationGraph / world_state bidir。對上 `[[project_framework_seams]]`（pipeline 縫+所有權圖縫）。
  - ~~**[可即修·藍圖定位] `event_faction_defect.gd:21` faction_id 繞 bidir helper**~~ **✅ 收（2026-07-03 單寫者收齊 B）**：機制已明——line 21 僅 faction-missing 防禦路徑，faction 不存在時無 member_team_ids 可懸空（健康路徑 line 24 `clear_team_faction` 早已處理懸空）。改走 `clear_team_faction` = 純 refactor（語意等同 `=-1`），非行為修，pointwise CLEAN。「懸空單向鏈」屬 stale-spec 誤標。
  - **⚠ [下一層·measure-first] 履約仍 0% — market_arrive 高但 board_read≈0（WS-2c 後）**：WS-2c 破 survival 鎖後 `market_arrive` 0→100-250（商隊終於到市集）、`merchant_survival` 18837→~0，**但履約仍 0%**——商隊站上市集 tile 卻 `board_read≈0`（讀不到別隊單）。下一層 root 待查：可能 ①商隊巡到的 outpost 看板無別隊單（residents 沒 post 到該板 / `_sync_board` 清掉 / `_market_pos` 登錄到別處）②時序（到達 tick vs 看板登錄）③`_nearest_market_outpost` 巡到無單的板。measure-first：market_arrive 當下印 `tile.market_orders` 總數 vs 非己單數。**別硬調**。
  - **✅ 商隊 survival 二階死鎖已破（WS-2c merge `bb63f18`）**：`effective_food` accessor 單源（team food+自家糧倉），10 決策讀者路由（survival/trade/ambition gate）。根因 = WS-1 food 搬糧倉只改消耗、漏改決策讀者（[[project_framework_seams]] 搬資源位置=所有讀者跟著走）。merchant_survival 18837→~0、market_arrive 0→100-250。世界無過餓（2 年穩 6 隊）。保留 2 讀者（`_calc_team_need` 需求常數、`_find_aid_target` 讀他隊私產）。剩履約 0 = 下一層（見上）。
  - **~~商隊 chronic survival 阻斷~~（✅ 已破 WS-2c，見上）**：WS-2b 市集可見性機制**確定性測通**（fulfilled=1，看板登錄+親讀+巡市集全鏈），但 world_sim 3 跑仍 0%。探針定位：`g1.board_register=4831`(看板運作)、`g1.seek_market=113`(商隊想巡市集)、但 `g1.market_arrive=0`(2 年僅 1 次抵達)、`g1.merchant_survival=18837`(商隊永卡 return_home/forage)。= **商隊被 chronic survival 鎖死永不出門到市集** → 機制無從 exercise。疑**二階死鎖**：商隊無自有糧源、靠貿易進食，但貿易又被 survival 鎖（要出門貿易才有糧、但沒糧只能 survival 不能出門）。**下一個 measure-first WS** = 診斷+破商隊 survival 鎖（修後 `g1.market_arrive` 0→正、履約脫 0 = 成功信號，WS-2b 碼無需再改）。留 4 永久探針（board_register/seek_market/market_arrive/merchant_survival）作驗收。**別硬調 survival 參數，先 measure-first 查二階死鎖結構**。
  - **WS-2b 市集可見性 ✅ merge（`2ee85bb`）= 解 ③訂單可見性死鎖（機制層）**：看板登錄 outpost tile + 抵達親讀(firsthand honest,守 G3)+ 商隊巡市集 fallback。確定性整鏈測通。world_sim 待商隊 survival 解（見上）。
  - **~~經濟在 world_sim 仍 0 交易~~（已定位+WS-2b 機制修，剩 survival 阻斷見上）— 訂單可見性死鎖**：本 session 探針定位——商隊收到的訂單 **100% 是自己的**（`origin==self`）→ `best_arbitrage_order` 濾掉 → arb 永空 → 無 dispatch → 0 交易。`message_system`：`emit_message` 只放發起隊自己 team_known；跨隊**只**靠 `propagate_on_arrival`（同格碰面交換+carrier 失真）。**死鎖**：交易需知別隊單 → 單只碰面傳 → 商隊只在有 arb 才出門 → 永不碰面 → 永不知 → 永不出門。**WS-2 漏修**：只做 order pos routing，沒做 order **可見性**（藍圖 B 市集本意含「市集訂單可見」）。**教訓**：WS-2 的「[Market]5→8/履約 0→1.5%」是 `game_sim_test/multi` 量的——那台隊密集碰面遮蔽此 bug → **經濟驗收必走 world_sim（散開隊），別信密集 harness**。修：WS-2b 市集看板（訂單登錄 outpost tile + 抵達親讀 firsthand honest + 商隊巡市集破死鎖，守 G3 傳播原則）plan `2026-06-21-economy-ws2b-market-visibility`。**次旗標**：全隊卡 `return_home[survival]`（有糧仍 survival）疑壓制出門，WS-2b 量測仍 0 才查。
  - **WS-2 主角已 merge（`81bd56b`）= 解 ①dispatch 角色卡死 + ②order pos routing（但 ③可見性漏，見上）**：商隊 member hoist + solo bonus（真被派貿易）+ order pos route 到固定 outpost 市集。throughput 限 → WS-3 carry cap+馬車（已 merge）。
  - **數據定論（world_sim 診斷，臨時探針已還原）+ 藍圖架構裁定**：先前「零 TRADE archetype」**猜錯**（商業穩定 2-3 隊、arb 常非空、隊真進 task=貿易）。真因 = **多因結構縫**：①是 TRADE 的隊都卡在永不呼 `_merchant_trade_target` 的角色（faction leader 跑勢力 AI / 獨立隊覓食分數蓋過 / 子團 / member 被 SETTLE+faction goal 攔截）②漫遊商隊追舊位置 → co-location 幾不可能（`[Market]成交` 2 年僅 5 次）③那 5 次沒對上單 res → fulfill 0。④食物幽靈囤真因 = `resource_system:213` food 不在 PUBLIC_RESOURCES → else **uncapped**。**架構裁定**（ruling `economy-direction`）：選 **B 固定市集**（co-location 解）+ 硬上限給「滿」信號 + 糧倉 + **解角色卡死讓 NPC 決策 fire**（主角）；**腐壞砍**（上限封頂取代）。arc spec `2026-06-20-economy-marketplace-caps-design`（WS-1 食物糧倉 route/WS-2 市集+角色卡死[主角]/WS-3 carry cap+馬車/WS-4 糧倉設施）。**主從鐵則**：僕人不改 NPC 局部決策 = 砍。**caveat：單一 world_sim run（非確定 [[reference_multi_sanity_unseeded]]），他 run 可能有交易；確認「真never trade」需確定性貿易場景**。後果：#1 經濟閉環 runtime 沒真正活（腐壞/儲限即使造短缺→買單，若商隊仍不履約則經濟照空轉）→ **腐壞 plan-2 dispatch 前宜先釐清此上游**。修需 measure-first：建確定性貿易場景（兩隊互補供需 + 商隊）看 arb_attempt/成交在 code 路徑哪段斷，非長跑猜。
- **G1d 剩 refinement**：~~部分履約精細記帳~~（✅ 上述 settle_orders）、distort 是否動 order params（現假設只動 description/strength，撲空主靠過期）、信用幣/異地折價（移出 ③G3）、`_find_trade_target` 完全刪除、arbitrage 分數公式（現 proxy TEST VALUE）。
- ORDER_LIFETIME/cadence/SURPLUS 門檻/eligible res/SHORTAGE_QTY/MERCHANT_MAX_RANGE 全 TEST VALUE，待平衡。

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
    2. **繼承分叉（違單一真值源）**：兩套繼承實作分叉。`event_system.on_leader_death`(:47) named 不足→**從 anon 晉升**（符合設計）；但 faction_ai 每 tick 偵測點(:502) gate `not named_members.is_empty()` + `_promote_successor`(:1066) **只從現存 named 拔、無 anon fallback** → 遭遇戰打到 named 全滅的隊「設計該晉升 anon 卻沒晉升」= 永久 leaderless anon blob（玩測觀察到 named 不再生）。`generate_for_team`(anon→named) 只被 `npc_combat:456`+`subteam:161` 呼，faction_ai 偵測沒接。
  - **關鍵推論**：單修繼承會回到「named 工廠」死循環（死→晉升 anon→又上場→又死），仍不收斂。**必須繼承統一 + 敗方 pop 損耗(模型 A) 兩件一起** → 一直打→anon 漸減→anon=0→無人晉升→`on_leader_death` 回 false→團崩潰滅團（event:54）= 真「打到死」。
  - **複用先例**：`force_occupy`(encounter:1424 `occ_dead = pop − pop×0.8`) 已有 20% pop 損耗機制，模型 A 可複用公式。
  - **分叉解剖（2026-06-19 #3，③ 已挖→證實）**：戰鬥**兩條路徑 explicit by design 分叉**（`ambush:60-66` 註明「Bug9：NPC 不走 encounter」）：
    - **encounter（戰術）**：觸發者 = `player_command_system` 全部 + `ambush` 玩家分支。spawn 上場 units、`kill_random` 只數上場（:1186-1194）。
    - **npc_combat（抽象）**：觸發者 = `interaction:248-260`（NPC 遭遇）、`faction_ai:2050`、`ambush:66`（NPC 分支）。`_apply_casualties`(:404)→`wound_random` 打**全 anon pool（無 cap 免疫）**、`_kill_named_npc`(:451)→`on_leader_death`(:456) **有 anon 晉升 fallback**。
    - **結論：兩病灶全在 encounter 路徑，NPC-vs-NPC 結構無病** → 解釋為何 multi sanity NPC 世界不崩、只玩測玩家介入才見 leaderless blob。**E-1 範圍大幅縮，不需碰 npc_combat。**
    - **繼承分叉真因鎖定**：`encounter_system:1184` 死 leader **只 `leader_id=-1`，從不叫 `on_leader_death`**；靠 `faction_ai:502` 補但 gate `named 非空` → named 全滅時不觸發 + `_promote_successor`(:1066) 無 anon fallback。對照 `npc_combat:456` 死 leader 直接叫 `on_leader_death` ✓。同樣死 leader，encounter 走殘缺路徑 = 分叉本體。
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
- **NPC crude_camp 即時糧 ✅ 量測+移除（2026-06-16）**：A/B（種子糧 ON vs OFF）2yr×4config → died 兩者皆 0、pop 相當（±噪音）→ 即時糧**非 load-bearing**（NPC 不靠它免死）。移除即時糧（`faction_ai:2105` 刪,保留抬 cap）恢復絕境稀缺,與玩家紮營版一致。

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
- **Q7-1 `choose_heir` 無選繼承人 UI → forced_event 永不清 → 世界永凍**（🔴 致命 softlock）。玩家 leader 餓死/戰死（`faction_ai:1058`/`health_system:221` 真觸發）→ `_process` 進互動模式 → `forced_interaction.responses` 只有「拒絕」（候選人沒出現）→ 按下 `resolve_forced_response` 驗 `get_forced_response_options(choose_heir)` 回 `[]` → `invalid response_id` → forced_event 不清。且 `sim_runner:99-100` 明確把 choose_heir 排除超時自動清除（設計凍世界）→ **玩家永遠選不了繼承人,世界永凍**。根因：`PlayerApiMapper.map_forced_interaction()`(player_api_mapper.gd:266) `match action` 無 choose_heir 分支→落 `_` fallback 只給拒絕；`get_forced_response_options()`(player_command_system.gd:834)+`respond_to_forced()`(:849) 也無 choose_heir（它走獨立 `_action_choose_heir` 需 `player_state["heir_id"]`,但 UI 無路徑設 heir_id/列候選）。
- **Q7-2 NPC 乞食玩家(`aid_request`) 無「給予」UI → 玩家只能(超時)拒**（高,破對稱）。注入 `aid_request` forced(`interaction_system:836` NPC 對玩家乞食真觸發)→ responses 只「拒絕」→ 按下同 `invalid response_id`→`sim_runner:102` 一 tick 後超時視同拒。`respond_aid_request` 是 registered action(含 give_amount/守恆/reputation 全套) 卻**無 UI 觸達**。根因同 Q7-1（三聯缺 aid_request 分支）。**Q7-1+Q7-2 同源,可一 plan 修。**
- **Q7-3 文字 UI 戰勝無 `take_loot` 路徑 → 戰利品憑空丟棄**（中高,A+B）。玩家贏遭遇戰→`encounter_system:1301` 算 loot_pool 存 last_encounter_result。戰後 `encounter_view._post_combat_hint:569` 只 `[J]收編`,無 take_loot/leave_loot（encounter_view grep 0 命中）。功能只圖形 `main.gd:184` 接線→文字 UI(主測 UI) 打贏拿不到戰利品。
- **Q7-4 玩家無「升 anon→named」command;全 anon 隊無法派子隊**（中,C 對稱）。NPC `person_generator:46`/`faction_ai:389` 缺 named 時自動拔擢 1 anon 為 named leader(帶 treasury×3);玩家無對應。`_action_dispatch_subteam`(player_command:531) 硬要 `sub_leader_id ∈ persons`→全 anon 隊 `dispatch_candidates` 空→`「無可用隊長」`。
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
- **驗證（2026-06-16，原「欠薪後果未做」= stale）**：欠薪後果鏈**其實已有**——減薪→掉忠誠（`salary_system:73` `loyalty -= (1-ratio) × SALARY_LOYALTY_PENALTY`）→ 低忠誠/高壓觸發 reaction `N3_defect`(`:259`)→`_anon_actually_left`(`:269`) 真離隊。**功能完整**。剩「anon 補充停」屬邊緣低優先（budget_ratio<1 時 anon 薪自然少，已部分反映）。
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
  - 真實狀態:**NPC 勒索機制休眠**。唯一發起點 `try_proactive_diplomacy:68` 被三重掐死:早 return(score>0.6 結盟/>0.4 貿易先返)、U20 同格 gate、**方向反**(`power_gap>0.5`=other 較大才發 → 弱勒強 → 必拒)。
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
- **mounts/wagons 速度**：⚠ 部分修（2026-06-15 驗證）。`_compute_team_speed`(`movement:138`) 現已 `× _compute_mount_bonus(team) × _compute_wagon_penalty(team)` → mount 加速、wagon 拖速**已有**。
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


## 決策引擎（term-normalize T5）
- **乞食 chosen≈0**：非缺陷。BEG_FLOOR_FACTOR 故意低（乞食=最後手段低品質）+ applicable 稀有（需 has_aid_target，appl_n 8-180）。合理現象，不改 code（measure 觀察佐證）。

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
- **附帶**：①`_decide_unified:1537`/`_evaluate_solo:1876` `capture_decision` 在 try_set **前**用預設 `"committed"`（self-replace/被擋也記 committed）→3080 部分虛高；tracer-completeness 只補 survival(3217)未補 unified/solo＝**tracer-completeness follow-up**。②`_evaluate_threat` FLEE_TIMEOUT reflee-loop 逃成功後 moot。
- **狀態**：reframe 報 blueprint 確認中（`2026-07-15-systems-to-blueprint-flee-root-reframe`）→ 認同則 spec「恢復 flee 位移」。感知鐵律：flee 反向讀 threat belief 非活值。

## state-transition specimen tap（下批候選，R² advisory 2026-07-15）
- **death/split/betray/found/capture** 等 state-transition 事件目前僅 `Probe.bump` aggregate、**無 specimen tap**（同 person-reaction 補前現狀）。observability-path-completion 本刀先收 person-reaction，這批**下批**（模式相同：capture 進 specimen 帶 who/why）。**記此防之後當新發現重走一輪 R²**（tap-gap 家族第 5+ 個，該一併走盲點閘掃出）。

## ★經濟供給鏈斷點:非糧賣單查錯 storage(framework seam,2026-07-15 full-HD 觀察揪出)
- **現象**:order_placed 539-850/月(需求穩)但 order_fulfilled≈0(6月共1筆),arb_kill_nostock 數千/月(無貨撮)。市場撮合引擎在跑非壞,供給端拿不出貨。
- **根(code-verified,framework seam)**:manufacture 產出(`manufacturing_system._add_output:117-118`)outpost 隊→`tile.public_storage`(非 team.resources);但非糧賣單(`order_system:110`)`qty=team.resources.get(res); if qty<20: continue`只讀 team.resources→定居隊製造的 goods/weapon/ore_steel 在糧倉、賣單查私產=0→**永不掛非糧賣單**→市場無貨。**同 WS-2c food accessor 家族**(資源搬位置讀者沒跟)。food 賣單已修(`_tick_food_granary_sell:138` 讀 granary,227筆/年);非糧漏同款修。
- **修向**:非糧賣單讀 effective 持有(team.resources+自家 public_storage,鏡射 effective_food 單源 accessor)+ 成交從正確 storage 扣。**下一層**(seam 修後若供給仍薄):material 產能 vs 消耗(measure-first 別預修)。
- **=經濟/發展 arc 經濟維核心**(生產→surplus→貿易→財富鏈接通)。blueprint 出願景→systems spec。溯源 handback `2026-07-15-systems-to-blueprint-economy-supply-root-found`。關 [[project_framework_seams]]/[[project_economy_arc]]。

## 掛單噪音 churn(blueprint+用戶抓 2026-07-15,經濟arc納入)
- **現象**:order_placed 539-850單/月、arb_call 數千/月、arb_kill_nostock 8372-20331/月。Team0 常駐6張單跨tick不變每cycle重掛→撮合狂空轉。churn家族(掛成不了的單還重掛,同flee每tick重commit/買糧幻覺精神)。
- **兩層**:①供給seam修後可能自消一部分(有貨可撮→成交清掉→spam減,像flee修N1_flee回落)②剩獨立churn(隊照掛不管有沒有貨/買不買得起)→掛單紀律治。
- **掛單紀律(order-discipline,scope待seam修後噪音量測定)**:grounded-order(掛單版look-before-leap:買不到/賣不掉/付不起別掛)+dedup(常駐單去重)+expiry(過期清)。訂單也是決策/行動該grounded(結構稽核grounded-ness家族)。
- **序**:供給seam第一刀驗收#7量噪音修前後→看供給下游自消vs獨立churn組成→blueprint定同刀or下刀。**別預修**。溯源handback `2026-07-15-blueprint-to-systems-order-noise-scope`。關 [[project_economy_arc]]。

## 經濟供給seam修正確但非binding(2026-07-15,多層調查中)
- **seam修(effective_holding)驗證**:kill_nostock月1-3降(-22/-47/-59%=賣單看見糧倉貨,供給可見性真改善)但deals仍~0(order_fulfilled 1→2),coin三池凍,守恆PASS。**seam是真bug但非市場死的binding約束**(同絕境五層鏈,修一層露下一層)。
- **binding層候選(待漏斗證,別猜)**:①賣單貼了merchant看不到(board_read≈0 known_issue)②太遠arb_kill_range③追了到不了點(travel/co-location)④會合不成交(transfer)。deal路徑要買方/merchant到producer outpost co-locate,非只「賣單看見貨」。
- **best_arbitrage_order:252讀merchant.resources**(carried stock,同seam家族但不同path=merchant carried非producer granary)——待漏斗定是否binding。
- **處置**:seam分支`feat/supply-seam-effective-holding`(4c2f85cb)hold不單獨merge(inert避換皮),等binding層挖出bundle。measurer跑完整trade漏斗breakdown(post_sell/arb_sell_seen/arb_pick/meet_nodeal/deal)定binding站。溯源handback `2026-07-15-systems-to-blueprint-seam-not-binding`。關 [[project_economy_arc]]/[[project_established_chain]](多層調查同精神)。

## ★經濟binding修正:非churn,是threat-preempt+meet_nodeal(2026-07-15 trace推翻churn假設)
- **trace判定**(measurer T5商隊specimen逐tick):非A churn(target 28000tick僅切6次穩定)、非B(抵達print命中29次有到)、落C變體(到點co-location落空);native bed:**dispatch404→arrive僅17(4.2%),96%被逃跑/threat preempt腰斬**;到場17裡meet_nodeal12/14。
- **真binding兩層**:①**主根=96% trade被threat/flee preempt到不了**(TASK_TRADE PRIO_DISPATCH50被threat PRIO_THREAT70 override;full-HD warring威脅常在+flee剛修好加劇)=survival vs commerce張力(WHAT:貿易該對threat有韌性or危險世界殺貿易對?)②次根=到場meet_nodeal(order pos=_market_pos固定outpost,疑對方移走/供需窗變/price)。
- **line 252 accessor**(best_arbitrage_order讀merchant.resources,kill_nostock 49970)=同seam第3讀點,code確定valid,正交收全(併held seam分支)。
- **★systems churn overclaim第2次被trace/HALT救**(seam非binding→churn非binding):**先證再修紀律價值再證**。churn假設trace推翻,沒白spec。merchant移出churn家族(progress backlog#5訂正)。
- **待blueprint定主根WHAT**(threat-vs-trade韌性方向)→systems spec。溯源handback `2026-07-15-systems-to-blueprint-trade-binding-corrected`。關 [[project_economy_arc]]。

## ★★經濟修向定案:結構統一重構(非調threat,blueprint靜態稽核+用戶核准 2026-07-15)
- **靜態稽核破死法二**:主根=結構沒統一,三層裸。accessor seam **5讀點**(非3):order_system:110/118/252 + ★trade_valuation:86 local_value(讀team.resources→糧倉貨誤估短缺→ask高/拒賣=meet_nodeal根) + decision_context:138 has_goods。我supply-seam只收3漏:86/:138/:252。**結構視圖抓measure-first撞不到的縫**([[feedback_structural_audit_complement]])。
- **主刀(結構統一,用戶核准)**:①effective_holding(state,team,res)收斂5讀點+廢absorb/spill dance ②order_system掛單層讀它+讀人格(食物留底統一走food_security_target,廢FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS死常數,清孤兒SURPLUS_RESERVE_MULT) ③雙resolver收斂(訂單看板vs到場ask/bid對齊,_find_trade_target+best_arbitrage_order收單一路徑) ④補accessor縫tap(躲public_storage的貨可觀測,守全量暫態可觀測性)。**大框→R²**。
- **第二刀(死法一,附帶,待量)**:387半路跑threat-preempt動態坐實掉因→定B threat韌性該修多少(商隊threat門檻人格化,PRIO_THREAT vs TASK_TRADE別flat)。
- **紀律**:先量再spec不變(死法二local_value hypothesis動態抽驗+死法一掉因坐實才spec)。line252併主刀收全。supply-seam分支(held)併入或廢重做。
- **兩刀分明**:死法二結構根(主刀)、死法一threat願景B(第二刀)。溯源handback `2026-07-15-blueprint-to-systems-economy-structural-unification`。關 [[project_economy_arc]]/[[project_unification_matrix]]/[[project_framework_seams]]。

## ★★經濟真根定音:私囊鎖coin循環斷(no_coin 91%,非accessor/threat,2026-07-15 measure第4次救)
- **死法二主根=no_coin 91%(24600/27020)**:買方team.resources.coin空。**code root=私囊鎖**:salary(salary_system:65-66)team.resources.coin→person.coin單向抽,person.coin唯一outflow=死亡(npc_combat:745),living named成員永不花回流;anon_treasury有extraction回收但named person.coin沒有→team.resources.coin單調枯竭→買不了→市場死。
- **★四假設全被measure/trace推翻(非binding)**:supply seam(可見性,deals~0)/merchant-target churn(target穩定trace推翻)/threat-preempt(真~6起,80.6% normal rotation,FLEE缺糧非threat)/accessor local_value(absorb+114%但<3%)。**真binding第5層=私囊鎖**。measure-first第4次擋非-binding大重構(accessor當主刀<3%=白做)。
- **真修向=coin循環(WHAT待blueprint)**:named成員person.coin該花回經濟(消費/週期回收/salary別單向枯竭)。**成員守財奴=私囊鎖病**。
- **accessor統一降級**:主刀→小follow-up(line 252/86/138/absorb真債,material +114%真小改善,非binding)。併框架債or coin修後順手。
- **Team6 execlock thrash**(死法一24筆survival↔trade)=churn家族→併backlog#5。**threat韌性B降優先**(非threat殺貿易是沒錢買)。溯源handback `2026-07-15-systems-to-blueprint-economy-real-root-siku`。關 [[project_economy_arc]]/[[feedback_symptom_vs_root_retry]]。

## ★★經濟真binding=merchant不co-locate+deal條件牆(coin紅鯡魚,2026-07-15 measure第5次擋)
- **coin紅鯡魚證實**:reconcile coin新解禁370筆全落coin_ok_other_bail、WOULD_TRADE恆零(有錢照樣不成交)→coin非binding。census:person.coin(named)61-63%最大池(B對準對池但floor/rate太弱補不動team_pool才3.6%)。**coin B治標,棄(非held),coin循環願景A+B降框架債backlog**(日後市場活了才有意義)。
- **2真結構binding**:①**merchant從不co-locate**(100% co-loc買方resident,0 merchant!arb_hit=0直因=merchant travel到order pos但從不與賣方成pair;churn trace證到達但落空)=blueprint預授WHAT「merchant完成trade」。候選根:move_target(order pos=_market_pos賣方outpost)vs賣方實位不符/normal-rotation preempt。②**price/surplus/qty牆**:deals=3 vs WOULD_TRADE 560(WOULD_TRADE該→deal卻沒),成交條件本身此世界幾乎不滿足。
- **measure-first第5次**擋非-binding(seam/churn/threat/accessor/coin全非市場死主根)。市場死=多結構疊(絕境五層鏈同精神)。**待blueprint定序(merchant co-locate vs deal牆)→systems patch-gate-first→spec**。溯源handback `2026-07-15-systems-to-blueprint-coin-red-herring-real-bindings`。關 [[project_economy_arc]]/[[project_established_chain]]。

## ★經濟arb_hit=0根確認+fix fork(2026-07-15,重排序②merchant先)
- **根(75到達,measurer)**:65.3%賣方漫遊離outpost(_market_pos固定outpost≠賣方實位,owner_settled_here=false)=dominant;24% owner在家仍零deal(②成交條件牆);preempt僅21.6%非主因。
- **★方法論修正**:TAG_MERCHANT本世界全程0隊!真閘=ambition_archetype==ARCHETYPE_TRADE(faction_ai:2045)。fix對象ARCHETYPE_TRADE非TAG_MERCHANT。
- **fix WHAT-fork(待blueprint)**:A追賣方belief_pos(鏡射pursuit,漫遊難追fragile,team-to-team)vs B outpost-market(貨在public_storage買方到outpost買stock免賣方在場,WS-2b infra現成,穩+像真市場,systems建議B)。市場模型WHAT:追人vs place-based。
- **序**:②merchant完成trade(通co-location)→①成交條件液化(held)→coin combo重驗。液化+coin B held不merge(下游)。溯源handback `2026-07-15-systems-to-blueprint-arb-root-fix-fork`。關 [[project_economy_arc]]。

## 經濟深multi-wall stack:coin大勝但供給側牆(2026-07-15,~10層measured剝殼)
- **coin combo大勝**:buy_no_coin 30421→27(-99.9%),coin雙向流動,私囊鎖root治對。但deal仍~1-2(未revive)。
- **層序(每層measured,修一露一)**:①供給可見性(seam)②撮合③移動④co-location(65%漫遊→market-as-place解)⑤成交條件(液化)⑥coin(私囊鎖,大勝)⑦**sell_no_surplus 51.7%(訪客到市場沒貨賣)=供給存在性最深牆**。
- **供給最深根候選**:producer產不出surplus(自用即耗/產能低)or TRADE隊無inventory累積(買低賣高需先買=chicken-egg)。=回到blueprint最初「誰生產可賣surplus」。
- **策略點(blueprint+用戶定)**:①續剝供給②重估市場模型/目標(稀缺世界本就少貿易?=設計特徵)③止血merge coin+foundation(unified-commerce巨大正確refactor+coin流+守恆,非inert,誠實標供給待續)。systems傾向3+1。
- **branch feat/unified-commerce(160301d9)**:market-as-place+液化+coin,守恆PASS,機制真fire(deal_market非零),但deals低=供給頂上。溯源handback `2026-07-15-systems-to-blueprint-coin-won-supply-wall-strategy`。關 [[project_economy_arc]]/[[project_established_chain]](深stack同精神)。

## 供給牆=生產arc(統一商業merged後,2026-07-15→16 patch-gate-first中)
- **市場未大revive因sell_no_surplus 51.7%**(訪客到市場沒貨賣)——掛單碼確認`surplus=effective_holding−reserve>ORDER_POST_MIN才掛`(seam已修含public_storage)→∴根=producer累積不出goods surplus。
- **根候選(systems measure中)**:①manufacture產能低(material稀/facility rare/生產鮮少選)②reserve太高(surplus never>reserve)③TRADE隊無inventory累積(買低賣高chicken-egg)。=回blueprint最初「誰產可賣surplus」。
- **決定甲/乙(measure後)**:甲=建surplus經濟(生產鏈產tradeable餘)/乙=接受薄貿易(稀缺世界本少貿易=設計特徵)。
- **孤兒函式advisory**(reviewer merge-gate標,de-patch殘留,非阻擋):生產arc順手清。溯源handback `2026-07-16-systems-to-implementer-unified-commerce-merged-done`。關 [[project_economy_arc]]。

## ★供給根precise=製造設施幾乎不建(生產arc甲,2026-07-16 measurer坐實)
- **根(measurer)**:has_facility隊恆=1(僅1隊有製造設施6月不變),8隊goods holding恒=0(從未產一單位),[Manufacture]全程6次。非material稀(surplus 417→破千)非reserve高非task-selection(TASK_MANUFACTURE dispatch 1→11隊想製造但has_facility=1每tick空轉no-op)。
- **precise=facility建造鏈存在但幾乎不產製造設施**(_evaluate_infrastructure→_pick_facility→_dispatch_facility_builder)。候選gate:①恆-hungry永建農(_pick_facility hungry→farming優先,WS-2c註定居隊food在糧倉恆hungry)②_facility_score製造太低(<門檻0.05)③builder gate(cost×1.5/advisor/pop≥6/subteam)。
- **生產arc(甲,待blueprint+用戶greenlight)**:讓製造設施蓋起→goods產出→surplus→市場供給→貿易活。接發展模型(生產/軍事/建設維度)。乙=接受薄貿易(稀缺特徵)。→greenlight則systems patch-gate-first定哪gate(可能measure一輪)→spec。溯源handback `2026-07-16-systems-to-blueprint-supply-root-facility-chain-production-arc`。關 [[project_economy_arc]]/[[project_established_chain]]。

## ★生產/發展arc greenlight(甲·統一框架,2026-07-16用戶定)
- **用戶裁甲+同商業那套**:不de-patch單一恆-hungry閘,拆光生產/設施子系統所有補丁閘融進框架(引擎+人格秤)無殘補釘再量。乙不成立(bug閘非設計稀缺,補丁閘通則=de-patch)。
- **願景(綜合發展模型)**:食安地基→多維發展人格化(工匠建製造/農夫續農/好戰建軍事)。設施建造=發展核心動作。
- **頭號補丁閘=恆-hungry**(_pick_facility:糧倉有糧仍effective_food判餓→farming硬override→製造設施never)。其餘閘blueprint靜態稽核列中(餵systems)。
- **架構方向(systems HOW,待靜態稽核全閘)**:facility/發展決策走DecisionEngine(人格加權needs:工匠→製造/農夫→農/好戰→軍事)取代硬gate(hungry→farming override/facility_score門檻/builder gate);同unified-commerce精神(整子系統進框架)。切幾slice待閘清單。
- **等靜態稽核餵全補丁閘列表**再spec(同商業異質稽核抓全縫)。溯源handback `2026-07-16-blueprint-to-systems-production-arc-greenlight-unify-all-gates`。關 [[project_unification_matrix]]/[[project_economy_arc]]。

## 生產框架 arc follow-up（2026-07-16,供給側成功後殘項）
- **deal 側成交牆（死法②同款,下一 arc）**:生產框架破供給牆(has_facility 10%→31.3%、成品池 26→480 18x),但 deal headline 仍低(deal=2、sell_no_surplus 最大 bail)。根=供給「量」有了但**流通到 visitor 隨身可交易貨**未打通(產出集中在有 facility 隊自家 outpost 公庫,非分散到 roam visitor 手上)。=死法②同款成交牆,另開 arc 治(非生產框架範圍)。
- **A3 utility 化(生產 S4.2 未做)**:`_evaluate_infrastructure` 固定 if 階梯(升級>擴建>蓋新 first-match)→ utility argmax。measurer 坐實**非 release block**(has_facility 正常漲,ladder 沒餓死建造)→低優先 de-patch follow-up slice。
- **`GOVERN_MATERIAL_TARGET` const 孤兒**(A4 govern de-patch 後 `faction_ai:18` const 可能無 caller)——advisory 清,非閘。
- **人格分化 confirm**(弱證據 n=8):mechanism 在(leader_pref+_facility_personality)但乾淨相關性樣本不足→待 blueprint 裁是否 multi-seed 聚合 confirm。關 [[project_economy_arc]]。

## Arc1 need oracle 進行中（統一路線首塊，2026-07-16）
- **S1 done**（branch feat/need-oracle @ c25abfb7，Tier1 5 綠，零產線影響=fallback 防中間態設計生效）。**S2-S5 remaining**（fresh session 續，ctx 衛生）。
- **核心架構**：NeedOracle 獨立新 module（NeedHierarchy 零改），出兩量 `need_keep`(自用+供應鏈,保留向)+`demand`(貿易,流出向);reader 組合 生產=keep+demand·可賣餘量=holding−keep·賣=min(餘量,demand)（R² 異質框外審抓單標量混反向缺陷後修）。
- **next=S2** 供應鏈 gap+gating+多配方→S3 貿易 demand 非幽靈→S4 共讀兩量+per-recipe 停產+TARGET_PER_POP 退役+SURVIVAL_CRUSH reconcile→S5 溢出落地雙 sink+migrate。spec v2=唯一真相。關 [[project_economy_arc]]。

## Arc1 need oracle done + urgency-閾順延 arc5（2026-07-16）
- **Arc1 need-quantity oracle S1-S5 core done**（branch feat/need-oracle @ 71280560,measurer full-HD 驗中）：NeedOracle 兩量(need_keep 自用+供應鏈/demand 貿易)、manufacturing 需求驅動、per-recipe 停產、reserve→need_keep、溢出雙 sink 落地守恆、TARGET_PER_POP 退役。早訊號:矛盾率 0.716→0.667、goods 死鎖解、trade 活、CoinAudit=0×多輪、生產框架 crossover reconcile。
- **★scope 釐清(implementer 抓)**:「散 need」混兩軸——**need-quantity**(該留多少:farming×14/reserve/TARGET)本 arc 收斂✓;**urgency-天閾**(DESPERATION/WARNING/RECOVER/SLACK/URGENCY days-常數,離餓幾天驅 survival 排序)=獨立 urgency 軸,量≠急,留 NeedHierarchy 零改動→**順延 arc5 死常數人格化**(它們是決策門檻常數該人格化)。migrate 進 NeedOracle=category error。
- deal 側成交牆(死法②)可能仍需專 arc(貿易 need 綁 deal 是供給側誠實,成交起否待 measurer)。關 [[project_economy_arc]]/[[project_unification_matrix]] arc5。

## Arc1 need oracle S6 + 終端消耗品 known-deferred（2026-07-16）
- **S6 遷 `_facility_deficit` → oracle**（dispatched）:blueprint 裁甲——workshop/apothecary/weaponsmith 等 non-food 設施 deficit 引擎外走 TARGET_PER_POP 各算=單一源違規+打架種子→遷 NeedOracle need（goods 由 demand 驅因 need_keep=0;保 facility gating）。遷完 ① clean→measurer 乾淨全量→批。
- **終端消耗品(武器/tools/armor) self-use=known-deferred(非 blocker)**:NeedOracle 內 self-use 暫用 flat TARGET_PER_POP base（`need_oracle:35`），**單一源已達成**(reader 都經 oracle),只是值待「戰耗/造耗/傷耗率」世界物理機制建了才真推導。判準見 invariants「單一源 oracle 判準」(源統一=硬/值推導=軟債)。順手 arc5 死常數人格化或戰鬥機制 arc 補推導。關 [[project_economy_arc]]。

## ★★框架「做好」= 3 流（用戶零殘留+真統一+可擴充,blueprint 裁 2026-07-16,defer behavior)
統一驗收=**真統一+零殘留閘+可擴充三位一體**,3 流全綠才 behavior:
- **① 零殘留閘流**:強化 constitution_gate 抓全閘型(值閘 RNG/override/硬門檻 + 控制流閘 手派路由/散落入口/近似重複)→ enumerate baseline → de-patch section-A 真閘 → baseline→零/全 legit-marked = 證零殘留。歧義 world-rule vs behavior-gate 由 de-patch 進度判(非 regex auto)。
- **② 真統一/擴充 3 seam(一舉兩得)**:seam#1 `applicable()`+`to_task()` 折 REGISTRY(消 4 switch→registry 1 entry+term,收益最大,也修 dispatch 手派路由真統一破口);seam#2 `_facility_deficit` 資料驅動(FACILITY_DEF→NeedOracle gap 泛型衍生,加設施自動有需求訊號);seam#3 `sim_runner` 系統 registry(SYSTEMS=[{sys,lod_policy}]+統一 tick loop,消 near+far 雙分支)。
- **③ 思考補完**:情緒接線(person.goals/memory dormant→決策輸入維度,像 need/threat oracle 供 term;結構接線=框架,情緒行為內容=behavior 後做)。
- **section-A de-patch 清單**(各判):_threat_recent(faction_ai:3125,caller 3087/3090)=behavior-gate/FEUD_ATTACK_MIN+VIABLE_ARMED_RATIO=人格化/GOVERN_MATERIAL_TARGET 孤兒=刪/_evaluate_threat 忙碌+門檻雙gate(388-401)=util/tribute FLEE override(diplomatic:40)=world-rule?待判/establish is_military(3285)+try_hunt(3254)=連續util/applicable DESPERATION天閾(options.gd:93/103/115/121/124/149)=可達性留-天閾de-patch/diplomatic RNG閘(124/137/140)=人格util/dispatch手派return-gate(_evaluate_survival:3187/_evaluate_threat:396 if uses_unified return)=真統一破口收斂。**+baseline偵測器窮盡補漏(別假設清單完整)**。
- **defer behavior**:俘虜feature(殺俘/贖金)/估值小冗餘/emotion內容/deal側死法②。每流照Arc1模式(byte-identical/乾淨全量/R②)。關 [[project_unification_matrix]]。

## 框架做好 stream① 進度（2026-07-17，constitution_gate v2 + 軌2 merged 08d3a39d）
- **constitution_gate v2 merged**:抓全閘型(值閘 RNG/override/硬門檻 + 控制流閘 手派route/散落入口/近似重複),baseline-freeze enumerate 93閘,綠=baseline全gate-ok=零殘留可證。baseline 現 91(37 gate-ok + 54 待軌1/triage)。
- **de-patch 軌2 值閘 merged**:閘1 _threat_recent→intent軍備/閘5 tribute FLEE→膽識絕望秤/閘7 calc_attack_score孤兒刪/try_proactive陡化。結構正確+無回歸,gate grep證消失。
- **★fast-follow(非blocker)**:①軌2分化 multi-seed confirm(militancy/低慎重 try_proactive/tribute修測法)——militancy綁**軍事設施thinness**(軍事設施幾乎不建,同生產框架facility-thin,production域separate)②守measure前不宣victory,分化待confirm。
- **剩零殘留工**:**軌1 seam#1 控制流收斂**(route×10+dispatch_entry收斂成一encounter eval+registry=真統一+擴充,大slice)+ 其餘54閘triage/de-patch → gate baseline續縮向零。stream② seam#2/#3(facility_deficit資料驅動/sim_runner registry)+ stream③情緒接線。關 [[project_unification_matrix]]。

## 框架做好 stream① 進度2（2026-07-17，seam#1 R②翻案 + 軌2 fast-follow結案）
- **★seam#1 R②異質框外審翻案(v1 FLAWED→REVISED)**:異質Sonnet skeptic+systems逐code全驗——**threat收斂UNSOUND**(5 findings全file:line):threat util量級**故意壓小**(terms.gd:170-171靠applicable-gate選)全pool被貿易1.3/野心1.5壓過+無break-top boost(survival有)+PRIO 70→50塌層+preempt唯一call site=rank_threat+自有FLEE公式(decision_engine.gd:143 vs主rank)。**裁定:threat收斂剝離→歸threat-oracle arc(4前置:severity-scaling util↑/break-top boost/preempt明確+PRIO保/probe先接)**,本就路線圖序3-4在後。seam#1只留**S1 registry(byte-identical)** + survival/ambient逐路驗收斂。threat控制流閘=**legit-until-threat-oracle**(標非移除)。可複用:filtered subset可編碼真選擇語意≠scaffolding,收斂前逐路驗。關 [[feedback_frame_challenge]]。spec `2026-07-17-seam1-control-flow-convergence.md`(REVISED)。
- **軌2 fast-follow multi-seed結案(measurer 8-10seed)**:3項de-patch機制**全legit(源硬統一done,框架零殘留達)**,殘餘=值軟債/vision→defer(framework-first):
  - **① militancy n=0穩**=facility-thin(軍事設施幾乎不建),production域→facility backlog,不追量。
  - **② tribute 100% submit under FLEE**=機制已de-patch(diplomatic_ai:46純人格formula),但generator floor(慎重/求生欲≥0.35)+flat TRIBUTE_W_FLEE=0.25→**高義氣拒絕分支數學不可達**(honor=1.0仍submit 0.125>0.1閾)。=**值軟債**:平衡波降W_FLEE/rebalance讓拒絕可達。連 [[project_desperation_economy]] 敗北三端塌1端(submit壟斷)。
  - **③ try_proactive 慎重³**=公式legit(unit-proven陡,RNG案③),但**行為級分化撤回**:高端「0%」是127-樣本noise(569樣本0.70%不重現),低慎重<0.35 generator架構不可達(person_generator:17 NORMAL_LO=0.35無lo_v慎重archetype)→分化被opportunity稀缺+floor遮蔽。gate-ok立於公式非行為。殘:generator-diversity(低慎重原型)+藍圖陳述更正=vision backlog。
- **54-triage tracker**:`docs/superpowers/54-triage.md`(A1安全收斂/A2 threat legit-until-oracle/B逐code/C=2皆legit)。
