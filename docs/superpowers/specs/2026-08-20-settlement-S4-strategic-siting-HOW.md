# settlement §4：戰略蓋點決策（engine 化）+ de-scaffold（HOW / systems）

status: DRAFT→R²delta（2026-08-20）
owner: systems（HOW）← design `2026-08-14-settlement-lifecycle-agriculture-design.md` §3 + **§4 WHAT 補定五點**（blueprint 2026-08-20）
溯源：settlement arc 全 slice merged（S1/crash/S2a/S2b/農業a/農業b + churn-fix + labor-v2）→ §4=**建點成為第一個完整深思熟慮決策**（立國 bespoke 的泛化起點）+ **清 S2b scaffolding 債**。
★**不鎖在 pending-QA 因果**（labor-v2 accepted cost / churn attribution 兩條在 QA 稽核中）——本 spec 前提=結構事實（constitution 站、REGISTRY 面、既有 marginal/belief/memory 機制），不引用那兩條。

## §0 命門
- **★de-scaffold=本 arc 硬 gate**（blueprint 釘死）：拆 `_evaluate_l0_settle` 的 2 個 constitution 暫時站（`::taskarbiter` + `::threshold`）→ **constitution 77→75**、**§4a 內完成**（不留到 arc 後）。
- **★零新旋鈕**（WHAT 補定①③）：擴張訊號用**既有** MarginalEconomy/勞力飽和/farming state；可行性帳用**既有** food_runway/ETA（同 `persist_strength._safe_factor` 量）；人格只 **modulate 既有權重**、禁另加線。
- **★禁 crank / 禁硬門檻回潮**：viability 從 hard gate 改**收進 util**（湧現過濾非門檻）；applicable 只留**物理可行性**（站位/tile 狀態/玩家豁免）。
- **感知鐵律**：選址讀 **belief 分層**（自己住過=親見高信 vs 遠方傳聞低信、**既有機制自然湧現、禁新管道**）；反饋只寫/讀**自己 leader memory**（self-knowledge）。
- **替代比較同秤**：紮根 / 撿現成 / 投靠 / 續流浪 在**同一 rank_scored** 比、無寫死偏好。

## §1 現況（grounded）
- **S2b scaffolding**：`_evaluate_l0_settle`（faction_ai:4777、caller 唯一 :838 在 loop3 survival 後）=standalone lifecycle evaluator + `TaskArbiter.transition` + viability threshold（`food_days < L0_TO_L1_CORVEE_DAYS` 直接 return）→ constitution 兩站（baseline_v2:77-78）。
- **既有 option 面**（`decision/options.gd` REGISTRY）：`紮營`:192（L0、applicable=絕境+有可農地+**無自家據點**、to_task→TASK_CAMP）、`併入`:155、`建設`:42、覓食/乞食/投靠等 survival 族齊。**缺「紮根(L0→L1)」option**=本 slice 補。
- **撿現成**：S1b 已把 belief-known `owner=-1` outpost 納 `_find_unowned_farmable_tile` 目標池（camp/紮營 路），抵達後既有 `_evaluate_outpost_takeover` 3 天 timer 認領。
- **overflow 機械源**：`population_system.check_overflow_for_team`（pop>`effective_pop_cap` → advisor 帶走 or `_create_overflow_team`）=**碎裂機械源**（design §3 要決策化）。
- **memory 機制**：`NpcAiSystem.write_memory(leader, type, subject_id, tick, weight)` + `decision_context` 讀（`join_rejected` 款、cooldown 比對）=**反饋迴路可複用、零新管道**。

## §2 slice 拆分

### §4a 建點入引擎 + de-scaffold（★硬 gate 本 slice 完成）
1. **新 engine option `紮根`**（REGISTRY）：
   - `applicable`（**只物理可行性**）：站自己 L0（`camp_level==1` 腳下）+ `outpost_level==0` + `construction_team_id==-1` + 非玩家。
   - `terms`：**可行性帳**（工期 ETA=`level×K_FARM`-free：`L0_TO_L1_CORVEE_DAYS+殘距` vs `team.food_runway`；ETA≫runway→util→0=**瀕餓自然不開工**、取代原 hard threshold）+ **選址品質**（腳下 tile 地力/farm 潛力、**belief 分層**：親見住過>傳聞）+ 人格 **modulate 既有權重**（好戰/野心 影響 type 與權重、非另加線）。
   - `to_task`：設腳下 `construction_target{action:"crude_camp", type:(civ/mil by leader), level:1, owner:team_id}` + `construction_ticks_left` + **經引擎 dispatch 走 TaskArbiter 單源**（=不再自呼 transition）。
2. **刪 `_evaluate_l0_settle` + 其 caller :838**（功能全落 option）→ **2 constitution 站消失、baseline_v2 移除該 2 行 → 77→75**。
3. **替代比較同秤驗**：同 rank 下 紮根 vs 併入 vs 紮營(L0) vs 覓食 → 無寫死偏好（**1 人碎片=可行性帳讓紮根 util 低、併入相對高=「蓋不如投」湧現**、WHAT 補定③）。
- **TDD**：①紮根 option applicable 只吃物理條件 ②瀕餓團 util→0 不開工（無 hard gate 仍過濾）③健康團開工並完工（端到端 L1）④constitution **75**（2 站消失、baseline 同步）⑤既有 S2b 行為（工期/中斷/recovery/完工清 camp_level）不破。

### §4b 三動機 + overflow 決策化（fp intended-change 大）
1. **①求生建家**=既有（無家 applicable、已在 §4a）。
2. **★②擴張建點=純邊際帳**（WHAT 補定①、零新旋鈕）：`applicable`=**有家** + 有可建候選；`util`=「**開分點期望邊際產出 − 建置成本**」vs「**家內再投一單位勞力的邊際產出**」——讀既有 `MarginalEconomy._inflow_est`（分點 est）/`ctx.idle_labor`（家內閒勞力=邊際產出低的訊號）/farming 頂格/倉飽和。**兩邊都用既有量、禁新常數**。
3. **★overflow_split 決策化**（碎裂機械源除）：擴張 option 在**接近 cap/idle_labor 高**時 util 自然升 → 團**主動**開分點（=有計畫的擴張、非機械爆裂）。**★機械 split 保底不刪**（`check_overflow_for_team`）但**降為 last-resort**（延遲/放寬：決策有機會先動作；★R² 議具體：延遲 N 天 or 只在 pop>cap×margin 才 fire）——**完全移除風險=pop 卡 cap 無出口**。量測目標=design §4「`overflow_split` 機械觸發→0（決策化）」。
4. **③軍事要地=佔位不建**（WHAT 補定②、本 arc 不做 military-siting）。
- **TDD**：①倉/勞力飽和團擴張 fire、無家團不 fire（動機分化）②機械 split 在決策先動作時不 fire ③邊際帳零新常數（引用既有）④pop 不卡 cap 無出口（保底仍在）。

### §4c 結果反饋迴路（第一條反饋邊、思考層四缺件之一）
- 建點/認領後**結局寫回自己 leader memory**（既有 `write_memory`、type 如 `site_failed`/`site_thrived`、subject=tile_id、weight 依結局）：**棄置/團滅/長期糧負** → 負面；**存活/積累** → 正面。
- **選址估值讀該 memory**（既有 `decision_context` memory-scan 款）→ 同團第二次選址**避開失敗地**（design §4 量測項：specimen 可見）。
- ★**self-knowledge**（只自己的記憶、非全域黑名單）、**零新管道**、**禁永久黑名單**（同 `join_rejected` cooldown 精神：weight 隨時間衰減或有效期）。
- **TDD**：①建點失敗→memory 寫入 ②同團下次選址該地 util 降 ③非同團不受影響（非全域）④衰減/有效期（非永久）。

## §3 gate（measurer bounded、綠才 merge）
- **§4a**：★constitution **75**（硬 gate、de-scaffold 完成）+ 紮根 option 端到端（開工→完工 L1）+ 瀕餓不開工（util 過濾非門檻）+ 替代同秤（1 人碎片選投靠>紮根）+ 既有 S2b/S1 行為不破 + determinism + headless 0-new。
- **§4b**：三動機分化 fire + bounded（倉滿才擴張、無家才建家）+ **`overflow_split` 機械觸發→0**（決策化生效、保底未被觸發）+ pop 不卡 cap + 邊際帳零新常數（code-read 驗）+ fp intended-change 標。
- **§4c**：反饋真作用（同團第二次選址避開失敗地、specimen 可見）+ 非全域 + 有效期。

## §4 界外
- 軍事選址本體 / 長程計劃脊椎全套（承諾/前瞻/means-end）=next arc。
- 12mo 大考（含 **perf phase profile**、blueprint 裁併大考跑）+ 經濟 4 科目=arc 後。
- (a) JOIN 在途重申抑制 / (b) per-team +34% = known_issues follow-up、§4 後。

序：**R² delta 審**（非全審、blueprint 明示）→ CLEAN → §4a dispatch → gate → merge → §4b → §4c。地基 KEEP。

## §5 R²delta 訂正（2026-08-20、CLEAN+1 必查項 + 5 議定套用）

### ★必查項（zombie construction race）：**systems 裁 (b) 根治、非 (a) 降機率**
**race**（reviewer 親讀鏈）：`_decide_unified` 於 **:2520 呼 `to_task`**（spec 原案在此寫 `construction_target/ticks_left/construction_team_id/corvee_site`）、**:2575 才呼 `try_set`**；`try_set`(task_arbiter:49-79) **真的會 false**（combat_target 鎖 :51-52 / crisis-released 免疫窗 :56-58 / `PROGRESSIVE_HOLD_TASKS`+persist≥`PERSIST_HOLD_THRESHOLD` :64-70 / 一般搶班失敗）→ **副作用已落地但隊沒進 TASK_BUILD** → `_tick_construction`(outpost_system:272-297) 只在 `construction_team_id` 對應隊**已死**才清 orphan、隊活著只落「無施工隊、暫停」→ 且 `紮根` applicable 要求 `construction_team_id==-1` → **這格對所有人永久卡=zombie 工地**。
- **★裁定=(b) 兩段式 commit-after-success**：`to_task` **只回 `{task, target}`（零世界寫入）**；`construction_target`/`construction_ticks_left`/`construction_team_id`/`corvee_site` 寫入**移到 `_set_ok==true` 之後**的 commit-hook（**比照既有 pattern**：`td.has("combat_target")`/`td.has("social_target")` 在 try_set 成功後才處理、`_decide_unified:2586-2589` 先例）。
- **★為何不取 (a)**（applicable 加 `current_task==IDLE`）：①(a) 只把踩雷機率壓回舊碼等級、**沒移除雷**——未來任何 option 只要在 `to_task` 寫世界狀態就再炸同一坑（=治症非治根）②(a) 等於「committed 隊永不改選紮根」=**行為限制**、與 §4 engine 化「替代比較同秤/公平競爭」的目的相牴（S2b 舊碼正是 IDLE-only）③本 arc 命門「禁硬門檻回潮」。★**(b) 是結構修正、且有既有先例**。
- **TDD 補（R² 要求）**：非 idle 隊（正做別的 progressive task、persist 高）+ 站自己 L0 空地 + `紮根` 進 ranked → **try_set 失敗 → tile `construction_target` 仍空、`construction_team_id` 仍 -1（零 zombie 殘留）**。

### ②util 非硬 gate=維持（reviewer 支持）、但 gate 要**真測**且含邊界
不加 applicable 物理下限（硬線=走回頭路、違 §0）。**但這是 empirical claim 非 by-construction** → §3 gate「瀕餓不開工」必須**真跑量測**、且**須含 isolated 邊界情境**：附近**無 join host、無 forage tile**（紮根事實上是唯一非零選項）的瀕餓隊，**是否仍低 util 選中它然後餓死在工地**。

### ④overflow 保底=**margin-based 優於純 delay**（採納 reviewer 方向）
機械 split 降 last-resort 用 **margin**（`population > cap × POP_OVERFLOW_MARGIN`）**取代純時間延遲**：純 delay 與溢出量級無關（小超額與難民潮式暴增同一延遲、大超額傷害更大）；margin 讓小溢出留給決策層（擴張 option）慢慢解、**只有滾到顯著超額（=決策層明顯沒接住）才機械介入**，且 margin 隨 population 成長**最終必觸發**（不需額外時間備援=無「決策永遠沒接住」死角）。**`POP_OVERFLOW_MARGIN` = TEST VALUE（建議起 1.15）、待量測校準**。

### ⑤§4c 衰減公式**寫進 spec 本體**（非留 implementer 猜、R² 要求）
- 建點/認領結局寫 `write_memory(leader, type, tile_id, tick, weight)`：`site_failed`（棄置/團滅/長期糧負）weight **0.5**、`site_thrived`（存活+積累）weight **0.5**（沿用 `join_rejected` 既有 weight 慣例）。
- **有效期/衰減**：`SITE_MEMORY_TTL_DAYS`=**TEST VALUE 30 天（一季）**（★比 `JOIN_REJECT_COOLDOWN_TICKS`=480tick=2 日長：選址是低頻高成本決策、記憶該跨季節）；**選址 util 調整量 = weight × max(0, 1 − 已過天數/TTL)**（線性衰減、**過期歸零非永久黑名單**）。
- **self-knowledge**：只讀自己 leader memory（非全域）；★TDD 驗「非同團不受影響」+「過期後該地 util 回復」。

### ③⑥（無需改）
③零新旋鈕：`MarginalEconomy._inflow_est`/`ctx.idle_labor`/`persist_strength._safe_factor`/`L0_TO_L1_CORVEE_DAYS` 皆既有、reviewer 親驗。⑥「1 人碎片蓋不如投」湧現：ETA∝人力反比 + `join_drive` 獨立高權重=兩條獨立算出、結構支持湧現、§3 gate 已列驗收項。

### ★R² 快查回覆套用（2026-08-20、priority 解耦支持 + 3 要求）
- **護欄①值域鎖死**：`priority` 欄只准 `TaskArbiter` 具名常數、**禁裸 int**。**護欄②必附 why-comment**。→ **已入 `invariants.md`（權威落點）+ 要求 REGISTRY entry 留理由行**。
- **★§3 gate 補（empirical、非只信推理）**：「**壓境頻繁區域的紮根隊，中斷-續建循環次數 / 平均完工時長是否顯著劣化**（vs 無威脅區同款隊）」——驗 `corvee_site` recovery 在真實 threat 密度下夠不夠、不變成「開工又中斷」新 churn。（reviewer 親讀確認結構上足夠：`_tick_construction` 找不到 active_team 時**純暫停不歸零**、`settle_resume_site` 憑自己 `corvee_site` 回頭=self-knowledge；threat 側 `PRIO_THREAT self-replace` 既有黏性壓低反覆短打斷——但那是 code 推理、需量測坐實。）
- reviewer 附帶確認：**zombie race 已在 worktree 修好**（`_commit_settle_site` 四呼點 :2586/:2894/:3038/:4828 皆 `_set_ok`/`_surv_ok` 後才 commit、`to_task` 零世界寫入）=該條收斂。
