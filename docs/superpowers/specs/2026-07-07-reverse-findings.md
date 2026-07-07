# 逆向工程 — 斷點總表（累積，2026-07-07）

計畫見 `2026-07-07-reverse-engineering-program.md`。各 slice 的契約 diff 累積於此。severity：斷鏈/no-op/god-view/wrong-flag/守恆漏/dead-path/missing-emitter/否決層。

---

# ★ CHECKPOINT 總表（10/10 done，2026-07-07）

## 健康地圖（分化,非全爛）

| 系統 | 判 | 核心 |
|---|---|---|
| 戰鬥 | ✓健康 | 重量公式真算、capture 真落地 |
| 移動 | ✓核心健康 | 多因子速度真跑;唯互動與 arrival 解耦(V1) |
| 交易 | ✓核心健康 | 守恆、村攤營業;唯 edge 笨(套利/囤貨/coin回饋) |
| 資源食物 | ✓守恆 | 唯 flat 消耗+死區+ore斷鏈(R4) |
| 事件反應 | ✓健康 | consequence-only、panic 溶入成功 |
| 人口anon | ✓健康 | 守恆、無 runaway |
| **決策管線** | **✗脊椎病** | latch 丟 busy 輸出+leader/子隊 bypass+4層子集+凍結 |
| **faction** | **✗第二脊椎** | leader 零引擎+5平行權威+優先權倒置 |
| **訊息** | **✗半殘** | 上半(事件→新聞→決策)90%旁白+god-view |
| **視野威脅** | **✗半霧** | belief-gated 但空間全 truth+戰力欄零寫端 |
| **訓練/武裝** | **✗全斷** | train≠arm(C1)+ore拿不到(R4) |

**結論**：物理/狀態層(6 系統)**可信**;控制/決策/感知層**是病灶**。根不是「功能壞」,是控制層碎裂。

## 三個根主題（所有斷點歸這三類）

1. **控制/決策碎裂**（D1 latch+D13 subset+D6/D7 leader/子隊 bypass+FA1-10 五平行權威+D2 凍結）→ 手不聽腦是架構。
2. **感知半霧**（T7 單調 discovered 根+T8/9/10 空間 god-view+M5/T11 戰力欄零寫端）→ 霧只霧了 who,沒霧 where/how-strong。
3. **武裝路徑全斷**（C1 train≠arm+R4 ore斷+無製造驅動）→ 征服 bootstrap 的物理根。

## 修：分級 + 序（待用戶裁）

**A 結構 arc（大,~1-2 天/個）**
- A1 塌決策管線：一次秤→執行 rank[0];arbiter 只裁物理中斷;刪 subset 前置層。**根,先做**（其餘修不先做這會被 latch 丟）。
- A2 faction/leader 併入引擎：leader/外交/戰略停 bypass、走秤（或降為引擎輸入）。最大覆蓋缺口。

**B 護航（1 slice,配 A1）**
- 「手聽腦」runtime 不變量：每 cadence 斷言 task==rank[0]∨白名單物理鎖;進回歸鏈,病永不藏。

**M 收斂修（各~1 slice）**
- 凍結 bug D2（真害,contained）;感知 threat 側接 last-known belief+寫戰力欄;武裝鏈 R4+製造驅動+②a 適應消耗;訊息上半接消費 or 認旁白（設計裁）。

**Q 一行修（時級）**
- wrong-flag(interaction:848)、假探針、死常數、P1 anon刪、doc-drift、god-view 收尾點。

**C 鎖死（每修必配）**
- 行為句子 harness：修完的每斷點配「效果發生」斷言,防爛回去。

**建議序**：A1+B → A2 → M（感知/武裝/食物/訊息）→ Q 收尾。每步 C 鎖。
**估**：A1~2天/A2~2天/M~1-2天/Q時級 → 樂觀 3、實際 4-6 天連跑（修「類」不 whack-a-mole）。

---

## slice #2 訊息/belief（done）

**一句判決**：「觀察→claim→best_estimate→finder 決策」半條活（含口碑閉環）；「世界事件→message→決策」半條除 order 貿易單外**全是旁白**（~90% message type 無決策消費者）。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| M1 | tier2 欺敵值寫親見 cred=1.0/distorted=false → 謊言成最高信 claim | interaction:848 | wrong-flag |
| M2 | detection 只咬 relay 失真；親見欺敵/誠實轉述謊言永不進識破 | message:221-235 | no-op |
| M3 | `_find_trade_target` 讀裸鍵 population/food/material，belief 只存 *_est → 恆 miss | faction_ai:1935 | 斷鏈（audit 舊項未修） |
| M4 | threat belief-miss fallback 讀 other.population 真值 | threat_assessment:42 | god-view |
| M5 | 敵戰力=pop_est×0.3；combat_skill_est/power_est 全 repo 零寫零讀 | threat_assessment:44 | missing-emitter |
| M6 | `_has_independent`/`_nearest_independent` 讀真 faction_id | faction_ai:1974/1984 | god-view |
| M7 | ★audit 漏：strategic_ai 自帶另一份 `_nearest_independent` 讀真 faction_id+真 pos | strategic_ai:101-102 | god-view（同型第二實例=架構信號） |
| M8 | 位置 god-view：ctx/options target-pos 全讀 live tile_pos（~17 點，含新增 JOIN/BEG） | decision_context:146…252 / options:145…187 | god-view（系統性） |
| M9 | faction_id 早濾/加分讀真值（scoring 已 belief、濾用真值） | faction_ai:188/3162/3218/3244 | god-view（灰） |
| M10 | 交換只在「換格 tick」觸發（傳 moved 非 arrived，參數誤稱）；同格靜止對永不交換 | sim_runner:196-197/243-244 | 斷鏈 |
| M11 | msg.id=size() + 每日 prune → id 回收；去重 by id → 撞 id 新訊息靜默不傳；order_id 借同空間 | message:33/94-97/194；order:214 | 斷鏈（機率） |
| M12 | assim/revolt/flee/captives 走 emit_ambient 永不進 team_known（卻佔 TTL 表） | manpower:135-181/npc_combat:303 | missing-emitter |
| M13 | NPC↔NPC 成交零 emit；trade_done 只玩家發 | interaction:782-810 | missing-emitter |
| M14 | 非 order 全部 message type 無決策消費者 | grep `.type==` 僅 order | no-op（flavor） |
| M15 | inquiry 回答不 record_claim → 玩家問到情報不落 belief | inquiry:38-82 | 斷鏈（player 小） |

**死路**：process_pending 空 stub（_step9 白跑）；4 ambient TTL 表項永不命中；is_suspicious 寫入無讀端；detection 三級只 relay 跑；strength 除丟棄門檻無消費者。

---

## slice #5 戰鬥/訓練（done）

**一句判決**：戰鬥**健康**(重量公式真算人均戰力×tier×武裝×意志,capture/subjugate/翻旗/loot 全落實可量,只 combat_decisive 是假探針)。**訓練=對戰力/武裝的空轉**——兩條獨立斷鏈。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| C1 ★根 | **train→self_armed 架構斷開**:self_armed 只由**武器池÷anon**決定;平民→菁英全程升 tier **零改** self_armed;而征服閘讀**武裝**非 tier → **訓練永遠開不了征服閘** | npc_combat:113-121 / equipment:72-73 / faction_ai:912/1031/3187 | 斷鏈(結構) |
| C2 ★ | promotion 八成永不觸:try_promote gated 在 coin/food/material/head,純練兵 FORCE 隊沒產不出 → exp 無上限累積、無 promotion → str 平(解釋 T23 訓練99.9% a=2 str1.6 數月) | anon_tier:398-401 | dead-path/斷鏈 |
| C3 | leader 戰術≤0 → 訓練**完全** no-op(零 exp 零 promote) | training_system:19 | no-op |
| C4 | TASK_TRAIN 無 release(=D1)→ 狂者永遠訓練 99.9% 產零,不自我修正去 MANUFACTURE(才真武裝) | training_system:13 | latch |
| C6 | 俘虜→captive_groups(隔離,非 population/strength),同化後只加技能非武裝(同 C1 武器斷開) | anon_tier:212/234 | missing-factor |

**★關鍵**：**武裝=武器(manufacture 需鐵匠+礦+駐村 / loot / 買);訓練=技能/tier;兩條 code 路永不相交,而征服閘鎖武裝。** → **我的 ③a「讓霸主練兵→武裝」瞄的是死路**。真militarization=MANUFACTURE/劫掠拿武器,非訓練。

**死路**：`_check_night_raid` TODO stub;純練兵隊 try_promote while 迴圈實質死。

---

## slice #4 移動（done）

**一句判決**：移動核心真的動(多因子速度模型 terrain/load/fatigue/mounts/wagons/wounded 全活、到達真觸發 occupy/coin/storage/construction)。但「到達效果=交易/戰鬥/訊息」與到達**解耦**——跑 `moved`(換格後同格掃)非 `arrived`。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| V1 | 交易/戰鬥/訊息 fire on `moved`(換格即掃同格)非 arrival → 過路格觸發戰鬥 + **靜止同格對永不互動**(=M10) | sim_runner:196-200 / interaction:64-86 | 斷鏈/arch |
| V2 | combat_target≠-1 → 移動全凍(在 advance 前);preset 未同格 → 永久凍+擋開打(=D2 的移動實害,probe atk.blocked_ct_197) | movement:62 / faction_ai:1517 | 凍結 |
| V3 | strategic_assignments 直寫 move_target 繞過 arbiter+task(=D11) | movement:64-72 | bypass |
| V6/V7 | 非 ATTACK/LOOT 卡住無 release;sa 隊追不可達目標 livelock 狂印 stuck | faction_ai:84-87 / movement:71 | dead-path/livelock |
| V8 | MOVE_TICKS_PER_HEX=**48**(×5 mult 還在,A2 未做);註解寫 240 doc-drift | movement:3 | doc-drift |

---

## slice #6 faction AI（done）★第二脊椎

**一句判決**：沿 leader/member 線裂開。**成員**契約成立(序6 溶 V2-cmd,faction_duty term 真在 rank_scored 競 loyalty-gated)=唯一乾淨縫。**Leader 端到端失敗:根本不碰統一引擎**——intent=另一個 argmax scorer、intent→task=手寫門檻、征服 dispatch@**30(低於自己經濟@50)=優先權倒置**。外加外交/背叛/結盟/戰略包圍全是 off-engine 平行子系統。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| FA1 | Leader 隊**從不進 rank_scored**,手寫 cascade(=D6) | faction_ai:1351-1392 | bypass-engine |
| FA2 | Leader intent=獨立 argmax(select_strategic_intent/AmbitionLadder),非統一引擎=第二 scorer | faction_ai:849-906 | parallel-path |
| FA3 | Leader 攻擊/掠奪@30 < 自己徵收/外交@50 = 優先權倒置,征服是它最低優先的事 | faction_ai:1377/1382 | 否決層 |
| FA5 | MERGE consolidate 在 weigh 前 hard-set pre-empt | faction_ai:1403/1421 | hard-set |
| FA6 | strategic_ai→strategic_assignments→movement 直設 move_target 繞 arbiter(=D11/V3) | strategic_ai:152 / movement:65 | parallel/bypass |
| FA7 | strategic_ai 自帶 `_nearest_independent` 讀真 faction_id+真 pos(=M7) | strategic_ai:96-104 | god-view |
| FA8 | diplomatic_ai 背叛/結盟/徵貢=門檻驅動的結構性 faction 變更,全 off-engine | diplomatic:137/299/231 | parallel-path |
| FA10 | 征服 commit=手寫 leader ATTACK,target god-view `_nearest_independent` | faction_ai:1374-1378/1978 | 手寫+god-view |

**★平行決策權數**：faction **member** = 引擎@50 + 3 條真平行(MERGE pre-gate/strategic_ai bypass/diplomatic 背叛)+ subset 層。faction **leader** = **≥4 條 off-engine,引擎零**。

---

## slice #10 事件/反應（done）✓健康

**一句判決**：事件從真狀態觸發(確定性門檻)、效果守恆;反應正確停在 consequence(loyalty/unrest/pop 效果,**零 current_task 寫**);panic-flee 正確溶進秤(序7 橋已拆,team_panic→threat_pressure→survival)。只邊緣破。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| E2 | leader flee/defect **不移除 leader**,改殺一個 proxy anon(pop sink 非 transfer,誤標 death.defect_leave) | reaction:261-264/297 | conservation |
| E3/E4 | 反應+team_panic 只讀 named/leader 的 PersonData → anon-heavy 隊幾乎零反應、大軍永不升 panic(反應 unobservable 根因) | reaction:21-23 / decision_context:123 | unobservable |
| E1/E5/E6 | _score_breed 死 scorer;solo leader 高壓不 vent;shirk 棄糧 sink | reaction:163/254/281 | dead/by-design |

**無 task-usurpation、無核心斷鏈。** 反應層乾淨。

---

## slice #9 視野/威脅（done）

**一句判決**：belief-**gated** 但 truth-**valued**。發現閘=真霧(要見過才 threat)、hostility(名聲)+pop_est=真 belief;但**所有空間輸入讀 live 真值**。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| T7 ★根 | `team_discovered` **永不衰減/遺忘**(單調,只死亡才清)→ 見過一次=永久可追 live 位置。所有位置洩漏的根 | vision:75-79 / world_state:317 | god-view(系統根) |
| T9 ★ | approach/velocity 讀 live tile_pos+last_tile_pos,「是否衝我」整項純真值(最大單點洩漏) | threat_assessment:27→path:170 | god-view |
| T8 | 距離衰減讀 live tile_pos 非 belief | threat_assessment:20 | god-view |
| T10 | threat_pos=live → DEFEND/求和 target=敵當前格(完美追蹤未見敵) | decision_context:146 / options:207 | god-view |
| M5/T11 | combat_skill_est/armed_est **零寫端**(vision 只 tier0/1,tier2 從不產)→ 敵戰力永遠 pop×0.3 flat,50菁英=50農民 | vision:85-115 / threat:44 | missing-belief-field |
| T12 | reveal_encounter 標 discovered 但不寫 belief claim → best_estimate={} → 落 live fallback | vision:40-42 | 斷鏈 |

**★last-known 位置機制已存且 pursuit 側有用**(scout/envoy/strategic 讀 best_estimate.tile_pos ~9 點),**唯 threat/flee 側無視它**——~4 點 god-view 洞。

---

## slice #8 人口/anon（done）✓健康

**一句判決**：人口**守恆**(getter 結構上不可漂)、所有 transfer 走 AnonTierSystem、promotion **5 站全 gated 無饑荒/不滿驅動=無 runaway**、split 搬既有 named 不從 anon 鑄。**runaway 擔心徹底排除。**

| # | Divergence | file:line | Severity |
|---|---|---|---|
| P1 | anon leader-defect = kill_random **刪** 1 anon(非遷徙 exile),與 named 保人不對稱;誤標 death.defect_leave | reaction:263/298 | by-design sink(守恆OK) |
| P2/P4 | `_score_breed` 用 stock、`_evaluate_life_events` 用 flow;只後者真 +minor;兩套 cap(0.2/0.25) | reaction:163 vs 187 | dead/cosmetic |

**無守恆漏、無 runaway-promotion、無 god-view。** 乾淨。

---

## slice #7 資源/食物（done）

**一句判決**：守恆(single-writer bank 無漏)。named 餓死漸進;但**消耗 flat 無配給**(R1)、**0.3-1.0 滿足度死區**(慢性半飢零後果 R2)、grace-cliff step(R3)。且揪出武裝斷鏈上游。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| R4 ★ | **ore→vault 但 smelter/weaponsmith 讀 team.resources,ore 自動提取 need=0 → 永不出庫** → 鋼/武器/甲生產斷料 = **slice#5 C1 武裝斷鏈的上游根** | resource:266 / manufacturing:55-65 / faction_ai:2186 | 斷鏈 |
| R1 | 消耗 flat 0.8 永不配給(短缺只靠 grace timer+attrition) | resource:116 | step-not-gradual(=②a 待改) |
| R2 | 滿足度 0.3-1.0 死區:慢性半飢**零人口後果**(死鏈全在 0.3 崖下) | resource:142/369 | step |
| R5 | vault→team 只在 arrival re-sync;久駐隊不出門則庫存擱死;need=0 也困住 goods/herb | movement:262 / faction_ai:2186 | dead-path |
| R6 | coin 餵 has_specie(買糧)但不餵貿易利潤打分(=T5) | decision_context:188 | blind-input |

**★武裝路徑全斷(合 C1)**：訓練給技能非武器(C1)+ 製造拿不到 ore(R4)+ 無製造驅動 → **軍閥除劫掠/買,無任何路徑升 self_armed**。這是征服 bootstrap 不起來的物理根。

---

## slice #1 決策管線（done）★脊椎

**一句判決**：as-built 不是「每 cadence 執行 rank[0]」,是**「idle 邊緣觸發的填空器」**。rank[0] 只在隊 idle(或更高優先層出手)時裝得上;busy@50 時每小時引擎輸出被 arbiter 靜默丟(TRAIN/生產/駐守無 release=永久 latch);且 faction leader 與子隊兩類**根本不過秤**。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| D1 ★根 | 引擎 dispatch 一律@50 + arbiter 嚴格大於 + TRAIN/MANUFACTURE/GOVERN **無 release** → 裝上後每小時 rank[0] 全被丟,僅 70/80/戰鬥能換 | task_arbiter:24 / training_system:13 / options:136,140,215 | **latch(結構根,train-latch 的「類」)** |
| D2 ★害 | try_set **失敗仍執行副作用**(combat/social_target/wire_threat)→ movement:62 凍結、interaction:205 早退擋開打(probe atk.blocked_ct_197 坐實);每 cadence 重設→busy 隊持續凍結 | faction_ai:1511-1523 | **silent-failure+凍結(違 arbiter 自家契約)** |
| D3 | current_option=opt 在 try_set **前**寫 → 被否決的選項仍拿承諾慣性 | faction_ai:1502 | silent-failure |
| D5 | 「備戰」target=(-1,-1)非FLEE → 被 target 檢查永遠 skip → 引擎主 rank 選備戰=靜默落次佳;只 non-unified threat 路派得出 | options:201 / faction_ai:1494,1745 | dead-path+否決層 |
| D6 | **faction leader 從不進 rank_scored**:手寫 goal cascade,攻擊/掠奪只@30(<50 被壓死) | faction_ai:1351-1383 | 否決層/覆蓋缺口 |
| D7 | **子隊從不進引擎**:手寫 argmax(掠奪/攻擊/回歸)+randf | faction_ai:1669-1700 | 覆蓋缺口 |
| D8 | leader null/戰鬥中 → 全成員該輪跳過 _decide_unified | faction_ai:1326-1328 | 否決層(間接) |
| D11 | strategic_assignments 直改 move_target,繞過 arbiter+task 全層 | movement_system:64-72 | 否決層(行動級) |
| D13 ★架構 | 契約「一次秤所有」實為**四層子集引擎**:主@50(idle-edge)/threat@70/survival@80/ambient@10,同隊同 tick 最多 4 次不同子集秤,優先層決定誰的 rank[0] 算數 | decision_engine:44,70,95 | 架構 diff |

**死路**：備戰不可派(D5);`DecisionEngine.decide()` sim 零呼叫;PRIO_VENDETTA 死常數;成員征服 scout-gate 永不觸;吞併 fallback 自註不觸。

**★根因收斂**:手不聽腦 = ①arbiter 嚴格大於 latch + 無 release task(D1) ②leader/子隊 bypass 引擎(D6/D7) ③四層子集非一秤(D13) ④try_set 失敗仍落副作用凍結(D2)。veto/train 都是 D1 的個案。

---
## slice #3 交易經濟（done）

**一句判決**：交易鏈本體真的活——意圖→移動→同格結算→四筆對稱轉帳、**全路徑守恆無憑空生滅**、村攤真營業。斷的是兩端「聰明」層（比訊息/決策健康：core 好、edge 笨）。

| # | Divergence | file:line | Severity |
|---|---|---|---|
| T1 | `_find_trade_target` 查裸鍵恆 miss（=M3 同點確位），但**已退居近死 fallback**（僅零外家 outpost 世界可達） | faction_ai:1930-1946 | blind-input（低,近死） |
| T2 | `best_arbitrage_order` gain=自估值×廣告量 proxy，不讀對方真價差、不檢自己有無 coin | order_system:243/256 | blind-input（利潤仍真,到場 ask<bid 硬閘擋） |
| T3 | has_arb 對所有 unified 隊抬 economic_opp ×1.0,但只 TRADE-archetype 真去追單 | decision_context:103 vs faction_ai:1888 | 秤/派微裂 |
| T4 | 囤貨=換 target 的貿易別名;買低賣高 gated TAG_MERCHANT,非商隊囤貨主要是**賣** surplus;「蓋倉」無 code | options:193-199 | no-op（語意退化,非死路） |
| T5 | coin 變富**完全不改變**貿易/囤貨打分（只 goods/has_arb 半邊回饋） | decision_context:102-103/188-191 | 斷鏈（回饋半殘） |
| T6 | 零交換 resolve 合法（撲空仍到點 release）;MAX_COIN_PER_TRADE 死常數;_nearest_market 排自家致買糧繞路 | interaction:708-724/7 | by-design/dead（記錄勿再濾） |

**核心結論**：守恆安全、成交真實;斷點=套利不讀真價(T2)、貿易估價器盲(T1近死)、囤貨沒囤(T4)、coin 致富不回饋決策(T5)。**「不夠聰明」非「壞掉」。**

---
