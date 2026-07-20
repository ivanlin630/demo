# Invariants

## ★★★ 沙盒憲法（governing invariant，凌駕級，藍圖 2026-07-05，專案定義級）

> 靈魂層 owner=`game-design.md`；本節=架構 enforcement。**凌駕所有其他不變量**：與此衝突者無效。

**凡 NPC 行為必經統一決策引擎（means-end 子需求 + utility weigh，人格調製）。禁繞過引擎的行為規則/判斷器/行為 subsystem。行為是引擎輸出，永不是輸入。**

- **作者寫世界，不寫決策**：給世界（狀態/手段/代價/感知）+ 引擎。**不給行為規則。**
- **分辨線**：
  - ✅ **世界規則（物理，該有）**：食物耗盡/山難走/遠征累/被打傷/資訊霧 = 手段空間 + 代價。描述「世界怎麼運作」。
  - ❌ **行為規則（腳本，禁）**：`if 食物<X then 塞糧`、判斷器（prescribe 而非 weigh）、替 NPC 決定的行為 subsystem = 違憲。描述「NPC 該怎麼選」。
- **強制閘**：掃「替 NPC 決定的碼」——引擎外硬編 action selection / 判斷器 prescribe / 行為 subsystem = fail。
  - **機械實體（序0 立，2026-07-05）= site-freeze 防閘**：`scripts/debug/constitution_gate.gd` 掃 `scripts/simulation/` 的 `TaskArbiter.transition/try_set` 呼叫面（= 引擎外 task 指派落點），指紋 `<relpath>::<enclosing_func>` 比對 `constitution_baseline.txt`（32 指紋凍結，8 known 違憲以 `# 序N` 標 arc 溶入序）。**契約**：current ⊆ baseline，新增=FAIL、移除(arc 溶解)=PASS（印 `removed` 作 arc 進度信號）。
  - **arc 溶入進度**：**序1 threat done ✅**（merged 804432e，`_dispatch_threat_response`→`rank_threat`；seeded 46/8/1/380→48/8/1/382）。**序2 solo done ✅**（merged f7ce320，`_evaluate_solo` argmax→`rank_scored`+去 `_tag_weight` 硬鎖+capability-grounded attack；融合+反向驗綠；seeded 48→**52/8/1/380**；★揭框架債：`_tag_weight` 隱形去衝突閘 + 「建設」恆 applicable→loop3 idle-gate 餓死風險，yield 橋補，真修在序6）。**序3 rung_task done ✅**（merged 50dc86f，查表撕除→archetype/rung 當 weight+訓練 option；idle-filler 走 `rank_ambient`[收窄排 survival/threat，FLEE churn 86→0]；★揭序1 率18 部分 churn 假象→threat 5b 改確定性 live-seam；seeded 52→**48/8/1/380**）。**序4 vendetta done ✅**（merged 2506e6e，hand dispatch→`feud_pull` 掛攻擊 option；優先序→權重序[血仇>致富=weight、威脅>血仇=PRIO_THREAT]；融合驗 4 錨綠+S2b 不 DORMANT；seeded 零漂移）。**序3.5 threat-preempt done ✅**（merged 4afbcaf，忙碌目標 idle-gate seam 修；PREEMPT_MARGIN=2.0；TASK_PRODUCE 納入；反龜縮 flee 0→12；seeded 48→52/9/1/381）。**序5 prosperity done ✅**（merged 16ab3bc，arc 最大；cascade 決策→攻擊 option[readiness→intent_fit×readiness factor、富 prey]；scout-verify 保 scaffolding `_commit_conquest_attack`[S3/S4 誘殺保]；刪 cascade+yield 閘+reroute；融合驗 6 錨綠；seeded 52/8/1/380 非凍死；★unready 征服隊改掠奪=capability grounding，成員 raid 暫失待序6）。**序6 faction 成員 dispatch done ✅**（merged 2b4a427，最高收斂動主幹；`_assign_member_tasks` if/elif→成員走 `_decide_unified`；V2-cmd 自消+成員 raid 接回+縫#3 結清；★只改成員 gate 非全域 uses_unified=序3.5 preempt 保；seeded 52→49/8/1/381）。**序7 ReactionSystem done ✅**（merged 2edf120，★reframe=其實小：唯一行為=聚合 panic-flee bridge→`ctx.team_panic`→引擎 survival FLEE；保 9 反應=consequence scaffolding；FLEE 三源序保；team_panic=決策模型情緒腳首接線；gate 32→31）。**序8 灰項 done ✅**（merged 57f7d39，`strategic_ai::_dispatch_trade_net` 死路撕除→引擎貿易/買糧/囤貨承接；gate 31→30 全為保留 scaffolding；seeded 零漂移）。**★★憲法 8 違憲全溶完（序1-8）——決策不統一 arc 完成。** gate 30 sites 全為 world-mechanic dispatch 落點/scaffolding（非違憲）。**arc 尾待：撤 pre-commit site-freeze 閘 → 轉全掃常駐鏈**（另 slice）。**arc 後平行軌**：gen readiness recalibrate（先 probe slice 補死因/winner→重跑 baseline→才調，待藍圖）+ 決策模型接線脊椎（感知腳 audit done：位置god-view→戰力欄→記憶腳；情緒腳序7起步）+ 全 pipeline 工作流切換（決策模型脊椎開軌時）。融合非刪守則：每張驗 repertoire 沒少 + 該出現還出現，seeded 漂移允許但 QA 判合理非退化。
  - **coverage 誠實限制**：閘只鎖 TaskArbiter mutation 面，**不**覆蓋「return task 字串供他處消費」式違憲（如 `ambition_ladder.rung_task`）——那類靠 arc 逐張溶解 + review，非機械閘。閘目標=「無新增引擎外 task 指派」，非完備語意偵測。
  - **arc 期間硬掛（藍圖 wave1-order-gate 裁定提前）**：本地 `.git/hooks/pre-commit`——staged 含 `scripts/simulation/*.gd` 時跑閘，FAIL 拒 commit（worktree 共用 → 實作 commit 也擋）。**arc 尾**轉常駐全掃鏈並撤此 hook。hook 在 `.git`（本地非版控，arc-temporary）。
- **零例外**：絕境=survival utility 在引擎內支配（非 override 繞過）；遠方=疏非慢非笨（引擎決策，非變笨）。此二處驗沒偷寫行為腳本。
- **稽核收斂主軸**：既有行為 subsystem/判斷器 → 溶進引擎（非特例）。連 [[project_unified_decision_framework]] / [[project_unification_matrix]] / 「架構已定別打補丁」。
- **應用例（藍圖 tick60 裁3）**：後勤=引擎 domain 非 subsystem——「食物不足-on-journey 登記成引擎子需求？塞乾糧/買/搶/覓食 被當 affordance 匹配？」缺→接進引擎;禁建「沿途補給 subsystem」。

### ★北極星：遭遇=統一反應（arc 收斂點，藍圖 encounter-north-star 2026-07-05，WHAT owner=game-design.md「★遭遇=統一反應」節）

憲法旗艦案例。**arc 各序溶 threat/solo/vendetta/prosperity… 的終點 = 五結局收斂進「一次遭遇的統一反應」**（非溶成五孤島）。遭遇 = 感知 → 引擎秤 → 挑一結局；threat/trade/diplomacy/vendetta/loot = **同一 encounter 評估的不同 option 輸出**（餵不同關係+軍力自然輸出，非寫死岔路）。剩下的溶朝此架，別各溶各成孤島。**序6-8 收斂主軸。**

**兩鐵律（納設計，約束所有溶）：**
1. **★感知鐵律**：威脅/身分感知**只吃可見表象（數量/逼近/可見武裝）+ 已知關係（盟友/宿敵）**；**禁吃對方 tag（商隊/軍隊/山賊）或真實意圖**（遠看分不出）。分不出照最壞繃緊（但「繃緊」可是「派斥候探底」非「恐慌」）。生湧現戲：虛驚/誤判釀仇。**enforce 點**：任何 threat/encounter 評估禁讀對方 `tags`/意圖做打折或岔路；只讀 belief 表象 + `known_reputations`。**repertoire 該有一格**：「陌生+不緊迫→派斥候/使者探底」（探而後戰，虛驚良性版），排入時機系統定。
2. **★深度靠感知非規則**：加深度=**讓世界更多狀態可被感知**，同引擎自算反應；**禁為每種社交組合寫新規則**（組合爆炸=墳場）。N 方（A看B、C交戰）**不建三方處理器**——把「交戰中/被打殘/威脅落盟友」變**可感知世界事實**，背刺殘敵/馳援盟友自己長出。**順序**：先做完兩方遭遇統一反應；N 方=湧現延伸，加可感知事實非加規則，過四關一次一個。成本：背刺殘敵≈免費（capability-grounding 已備讀當下戰力）；馳援盟友=要新感知（威脅落盟友，現只算對我）=有成本，等觀察缺戲再建。

### ★憲法孿生條：引擎=通用機制，好戲活 seed/param（藍圖 twin-constitution 2026-07-05，WHAT=game-design.md「★孿生條」）

憲法禁「替 NPC 寫行為」；**孿生條禁「把 scenario／平衡寫進引擎」**。引擎=零 scenario 假設的通用機制；所有「調得出好戲」的旋鈕活在 seed／環境參數層。believability 尺只判參數/seed 選得好不好，不改引擎。**三推論（約束 invariant/參數設計）**：
1. **規模/結局=seed 參數非模擬器不變量**：同引擎跑 5 隊/500 隊、一統/分裂、雪球/並立全成立。引擎不假設也不強求規模或結局。「~50 隊」「多強並立」=scenario 設定，**禁漏進引擎當寫死假設**。gen 重校=調 scenario 參，非修模擬器。
2. **行為常數參數化/人格化=落地債 B**（見下決策模型 B 重框）。
3. **believability 尺不越線變硬限制**：世界不對→改 seed/param 或補缺機制，永不硬塞行為規則。

### ★決策模型：感知→腦→行為（藍圖 decision-model 2026-07-06，方向硬機制軟，WHAT=game-design.md「★決策模型」）
```
客觀世界 →①技能過濾(理解力,低技能看糊/誤判,接迷霧)→ 我的感知
        →②人格(權衡)+記憶(經驗染價值)+現況能力(做得到/代價) 三腳秤
        → 這人眼中 utility → argmax → 行為
```
- **引擎=唯一的秤，感知→反應必經「這隻的腦」，絕不容全域規則/常數/gate/margin 繞過。** 同一感知不同腦→不同行為（懶+謹慎隊放掉送嘴邊弱敵=性格非 bug）=模擬器 vs 腳本分界。
- 現況能力腳=[[project_combat_unification]] 序2 capability-grounding（已在做，此並列講清非新工）；技能雙重=現況資源+感知品質。
- **★B 重框（取代「常數參數化」）= 落地債**：**行為門檻的歸宿只有兩處——世界代價（seed/世界接地）或人格/記憶/現況（逐 agent）；無塑造行為的門檻該以全域常數活下來。** `PREEMPT_MARGIN=2.0` 病=該由這隊謹慎度算出（膽小早逃/悍將晚動），非全域一刀切=第一示範。同類：THREAT_CADENCE/FEUD_ATTACK_MIN/VIABLE_ARMED_RATIO/各 reaction 閾。**方向硬機制軟**：怎麼算/何時溶/溶多深=系統 HOW+measure 按 arc 節奏逐步收（arc 內順手 or 另軌「常數人格化」）。
- **★溶入驗收多一條隱性標準**（所有後續溶）：**該行為是否真穿過人格/記憶/現況的秤，非某全域規則/常數直達。冒出具名 margin/gate/threshold 常數=照妖鏡響。**
- **★★域專判斷器邊界原則（用戶定 2026-07-15）**：獨立 domain scorer（`decide_treatment` 讀殘忍→苛待、`ReactionSystem` named 9-scorer 等）**不必強塞 DecisionEngine `rank`** 才算「統一」。合法域專 scorer 判準兩條：①**真穿人格/記憶/現況**（非硬寫繞過引擎的死路）；②**讀跟主引擎同一組人格值**（角色一致，不分裂人格）。**統一 arc 的敵人＝硬寫/繞過 dispatch 的死常數 gate（C 類 judge 退役針對這種），非人格化 scorer。** ∴ 滿足兩條的域專 scorer＝**矩陣可標「收斂」非「待併 rank」**（decide_treatment/reaction-9 皆是，非 unification blocker/殘項）。未來同類 scorer 照此判，別再逐個當「未統一殘項」列 backlog。**反例仍違規**：讀跟主引擎不同的人格值（人格分裂）、或硬寫常數 gate 繞過（照妖鏡響）。
- **★★★兩條框架健全不變量（用戶問 2026-07-16，納入框架驗收機器證——3 流全綠=兩問有機器證）**：
  - **① 下游零決策**：思考層（DecisionEngine+人格 oracle）做決策，下游系統**純執行**。下游偷做決策（section-A 焊決策的行為閘：`_threat_recent`/硬門檻 override/RNG 開閘）=違規 → de-patch → `constitution_gate` v2 值閘+控制流閘 detector **綠 = 下游零決策證**。**caveat：下游供狀態給思考層讀 = OK（輸入非決策）**——分界=「算給思考參考」合法 vs 「替思考決定 task/行為」違規。
    - **★手不聽腦不變量（task 執行，2026-07-19 transition-arbiter merge 980e0b1c）**：引擎決策的求生 task **必被手執行**。任何**繞過 arbiter 的 raw task 覆寫**（`TaskArbiter.transition` 曾無 guard 直接賦值 current_task/priority）= 下游 stomp 引擎的 emergency 決策 = 違規。**enforce**：**所有 current_task 寫入路（try_set + transition）都守 arbiter 絕對鎖**——combat lock + crisis-免疫 + **emergency-respect（in-place 轉換不得 stomp active emergency task ≥PRIO_THREAT）**。**★配套句**（否則不變量反噬合法退場）：**emergency task 自身的 resolution 退場走 `release`（→re-rank）非靠 transition 降級**；被 guard 擋的只有「外部 in-place stomp」，非「emergency 正當退場」（release=引擎認可的 emergency 退場出口，同 crisis-override/② release→re-rank 正典）。血證=team16 defection transition「等待新領主」clobber survival 凍死。同族殘留待清 = [[手不聽腦 mini-arc]]（subteam-idle-latch 等 committed+would_succeed=true 卻不 dispatch 的 drop 點，starve metric 看不到需 QA 逐隊讀）。
  - **② 下游零干擾**：下游系統互不干擾，三面：**(寫)** Pattern B 單寫者（一狀態一 owner，CI-scan 強制閘證，需驗覆蓋完整）；**(算)** 零各算——同概念多處各算=干擾，**單一源 oracle 殺之**（need/threat oracle + `constitution_gate` 近似重複 detector 抓手刻版）；**(tick 順序)** `sim_runner` 系統 registry（`SYSTEMS=[{sys,lod_policy}]` 統一 tick loop，消 near+far 雙分支手接=順序確定不亂,seam#3）。
  - **★機器證組合**：`constitution_gate` v2（零決策+近似重複）+ CI-scan（單寫者）+ oracle 單一源（零各算）+ sim_runner registry（tick 序）**全綠 = 用戶兩問「下游不影響決策 + 互不干擾」有機器證**。別讓下游偷決策 or 跨系統亂寫/各算。
  - **★RNG 判準 3 案（用戶精修 2026-07-17）**：`constitution_gate` rng detector 抓的逐個照此判：
    - **① 純骰無人格替決策 = 行為閘 → de-patch**（personality-blind randf 選行為）。
    - **② 世界不確定 outcome = 合法留**（訊息有沒有送到/事件/event-ID 生成/遭遇/外交成敗/戰鬥擲骰=世界怎麼回應，非替 NPC 決策）。
    - **③ 人格加權機率決策 = 合法-IF 陡 + framework-routed + seeded**：性格把**清楚案例推兩端**（忠 2%/奸 95%），骰**只斷真難分的中間**→結果掙來（不太運氣）+ 有機戲（天人交戰不可測）。**曲線平（如 0.2~0.7 範圍）= 太運氣 → 陡化（非 de-patch）**；曲線陡（清楚案例 deterministic、margin-only stochastic，如 `consider_betrayal` driver≥HARD→100%）= gate-ok。
    - **systems 驗**：③ 類逐個驗曲線陡度——陡則 gate-ok、平則陡化（把人格影響放大到兩端），非拆掉 RNG。血證：`consider_betrayal` 陡(ok)、`try_proactive_diplomacy` 0.2~0.7 平(陡化)、`_check_discipline` fail-under-stress=②outcome(ok)。
- **★★單一源 oracle 判準（用戶/blueprint 定 2026-07-16，統一路線圖通則）**：收概念成單一 oracle（need/threat/估值…）時，兩種「不完整」判準不同：**①違規=oracle 外各算**（同概念在引擎外另有一套計算，如 `_facility_deficit` 引擎外走 TARGET_PER_POP 算 need）→**必遷 oracle**（是打架種子，各算會不一致）。**②可接受 deferred=oracle 內值暫 flat**（單一源已達成、所有 reader 都經 oracle，只是某分量的值還是常數未推導，如 NeedOracle 終端消耗品 self-use 暫用 TARGET_PER_POP 待戰耗率機制）→**記 known-deferred 非 blocker**（值的精化可後補，源已統一）。**分界=「源」統一（reader 都經 oracle）是硬標準；「值」推導完整度是可分期的軟債。** 驗收乾淨證據時 grep「oracle 外同概念各算」=硬 gate，「oracle 內 flat 值」=documented。

## ★★ 全量暫態可觀測性（governing invariant，憲法同級，用戶定 2026-07-14）

> WHAT owner=`game-design.md`「好戲關」；本節=架構 enforcement。**與憲法閘同級**（新增盲點=違規，該被閘擋）。

**code 不管怎麼改，所有暫態都要量得出。任何改動不准製造量測盲點。**

「暫態」= **故事判斷可能依賴的一切瞬時狀態**，三類：
- **想法**：decision trace（候選 option / winner / 理由）、控制流轉換（如 `idle↔貿易` thrash、`[Survival]` fire 轉換）。
- **狀態**：pop / food_days / 威脅 / 意圖 / 子隊關係 / 狀態機轉移。
- **資源**：coin / food / weapons / 庫存時序。

**規則**：新增任何決策層／資源／狀態機 → **必須同步接進量測 tap**。**新增盲點 = 違規**（憲法閘同精神，可行性系統評下方閘）。

**為何是不變量非 nice-to-have（血證，2026-07-14）**：盲點會**捏造假故事 + 誤導判決**——
- **tap-gap 假象**：SpecimenTracer tap 沒接 order 系統 → `decision_count=0` 假象 → **差點誤判「架構絕症」**（第一次量測結論，第二次同世界 reeval 才推翻）。
- **thrash 只因 `[Survival]` 轉換有 log 才抓得到**（Team14 subteam `貿易↔idle` 抖 122 次餓死）；沒 log = 永久盲點，故事崩在哪永遠看不出。

**現實校準（藍圖給，免落地做歪）**：「所有暫態每 tick 全 dump」爆 perf（fullprobe 已重）。可實作版＝
- **tap 必須存在、零盲點**（可觀測性=不變量，不打折）。
- **dump 可 scope**：specimen 鎖隊全量 / probe 抽樣，不必全世界每 tick 全記。
- **原則不稀釋**（不准有量不到的暫態），**perf 平衡=系統 HOW**。

**★觀測者禁耗 global RNG + 禁污染 Probe（顯規則，用戶+blueprint 2026-07-15；RNG 第 3 次、Probe 第 4 次同族咬人後升）**：任何觀測儀器（SpecimenTracer/HOB/probe/tracer）**禁消耗 global RNG**（`randf`/`randi`）**且禁 bump 共享 Probe counter**。**Probe 版血證（2026-07-15 observability-path-completion HALT）**：SpecimenTracer `capture_decision` re-query `best_estimate` → `Probe.bump("bel.best_call")`；新 attempt-tap 使 specimen 隊多呼 → **Probe aggregate 污染**（bel 694059 vs 693715，on/off 非 byte-identical）。**雖非 world-state 破（sim 不讀 Probe counter，teams/pop 仍 byte-identical）但污染 measurer 的 aggregate 測量**＝觀測儀器觸發另一觀測儀器＝同 RNG confound 家族。**修＝tracer 所有 re-query（純觀測用途）包 `_begin_observe/_end_observe`（save/restore `Probe.enabled=false` + `suppress_observe_noise=true`）**。**驗收含 Probe**：specimen on/off/A/B 跑除 tracer entries 外**世界 + Probe aggregate 全 byte-identical**（前輪只驗 world 漏 Probe→小場景不顯 full-HD 才爆）。觀測若多跑決策/估算路徑（gather→estimate_catch_up→observe_velocity、rank→to_task→finder…）而耗 RNG → 偏移全域 RNG 流 → **觀測改變被觀測物**（換 specimen/開 probe=換世界）。**必包 `PathSystem.suppress_observe_noise=true`（save/restore，scope 只包觀測額外呼叫）或等價 observe/dry-run 旗標。** 血證：①LOD-exemption（specimen 升 near→換世界）②RNG（SpecimenTracer observe_velocity 耗 randf→同世界 Team26 flip 0/71/88，desperation 全驗證在擾動世界=不可信）。**驗收操作定義**：同 seed，specimen=A/=B/無 三跑→除 tracer entries 外世界 byte-identical。**release 綠只認中性（無-specimen）世界**，擾動世界綠作廢；determinism/憲法綠不救此。memory [[feedback_observer_no_global_rng]]。

**★specimen 完整性：全生命 + 全路徑（顯規則，用戶+blueprint 2026-07-15，第 3 次同族咬人後升）**：指標 specimen 的 trace **必須涵蓋完整一生（無時間窗口洞）+ 全決策路徑（含 commit-fail attempt，非只成功 commit）**。血證：Team26 死-specimen 只錄 day76-85、漏 day24-75（~50 天），根＝capture 全 commit-gated（`capture_decision` 只在 try_set 成功點 tap）→ no-commit 期（IDLE/survival relatch commit 反覆失敗/子隊）零 entry，commit-fail churn（想求生但 commit 不成＝致死主因之一）全隱形。**兩機制（merge `b21794b7` 落地）**：①**attempt-tap**——`capture_decision(...,result)` 記 `committed`/`finder_miss`/`try_set_noop`，churn/fallthrough 全成 timeline entry（路徑維無漏）；②**heartbeat sweep**——`evaluate_all` 末尾對 specimen 無決策期補輕 entry（`HEARTBEAT_CADENCE`=6h），timeline 無 >6h 洞（時間維無漏）。**新決策/commit-fail 路徑必接 specimen tap**（否則盲點閘 FAIL）。此規則使 story-QA 判的是完整一生非窗口切片。

**enforcement（觀測盲點閘，憲法閘同精神）**：①新增 decision/resource/state 未接 tap → FAIL；②**新 tracer/probe 未 suppress global RNG（specimen=A/B/無 三跑非 byte-identical）→ FAIL**（RNG-中性檢查）；③**specimen 完整性**——runtime churn 床（`tracer_completeness_test`）斷言 timeline gap≤HEARTBEAT_CADENCE + commit-fail entry 現形 → FAIL 擋；static tripwire：生產側 `SpecimenTracer.capture*` call-site baseline（新決策 commit 點未伴隨 tap→計數失衡示警）。④**盲點閘（`observability_gate.gd`，merge 7a9640bf 已落地）**——靜態列舉事件產生點（try_set in decision/reaction winner/intent/state-transition）vs capture 覆蓋 + baseline freeze，新決策/commit-fail/reaction 路徑未 tap → FAIL（tap-gap 打地鼠系統性守衛，與 `constitution_gate.gd` 同級）。⑤**禁 Probe 污染**——tracer re-query 包 `_begin/_end_observe`（Probe.enabled=false+suppress_observe_noise），on/off 含 Probe byte-identical。**現況=不變量全立、③④⑤機械閘已落地（tracer_completeness_test + observability_gate + _begin/_end_observe）、①② RNG-中性檢查併入 observability_gate 掃**。state-transition(death/split/betray/found/capture) tap＝下批 backlog（known_issues）。

連 [[project_playable_priority]]（好戲=四關之首，聚合 metric 過≠好戲過）。

## World

- 世界獨立運作
- 玩家不是世界中心

## Map

- Hex Grid Only
- 禁止 Square Grid 假設

## Time

- 大地圖與遭遇戰共用時間尺度

### ★ TimeScale 骨架三不變量（time-scale wave slice A，2026-07-05，enforce 起步）
```
凡時間量              必從 TimeScale 骨架導出（禁裸硬編 tick）
凡移動                大地圖格 = 遭遇戰動作 × 遭遇戰地圖尺度（連動,不准倍率打破）  ← 錨①②
凡延遲/timeout/cadence  以語意單位（TimeScale.days(N)/hours(N)，非裸 720）
```
- **單一權威源 = `TimeScale`**（`scripts/simulation/time_scale.gd`）。承既有根：`TICK_PER_DAY`←WorldState、`BASE_ACTION_TICKS`/`ENCOUNTER_MAP_SCALE`←EncounterSystem。**單向依賴 TimeScale→{WorldState,EncounterSystem}，反向禁**（循環）。新碼一律 `TimeScale.*`。
- **錨①（移動連動,釘死）**：`MOVE_TICKS_PER_HEX = BASE_ACTION_TICKS × ENCOUNTER_MAP_SCALE / WORLD_SPEED_MULT`。`MovementSystem.BASE_MOVE_TICKS` 唯一讀站走此連動式。**★A1/A2 拆片（藍圖 timewave-five-rulings）**：**A1（現行）= ×5 先留 → MOVE=240/5=48（零行為變,骨架 refactor 即 merge）**；**A2 = 拿掉 `WORLD_SPEED_MULT`(×5→1)→ MOVE=240=1天/hex**，綁 ④沿途補給+FOOD 消耗重校+gen 承載力重校 **四件一個 landing**（缺補給裸切 ×1=餓死潮,已 measure 證 10 格斷糧）。A2 落地後此錨終值=240、mult 刪、禁再塞倍率。
- **錨②**：`ENCOUNTER_MAP_SCALE = EncounterSystem.MAP_DIAMETER = 24`（遭遇戰地圖尺度,不變）。
- **錨⑤（觀看組不碰物理）**：倍速靠 GUI（TICKS_PER_SECOND/TURN/DUMP 橋），非改時間尺度。
- **enforce 進度**：**A1 立骨架單源（×5 留,零行為;headless time-invariant assert 守 MOVE=48）**；A2=×5→1+補給+FOOD+gen 四件；B=far elapsed ✅（一修 V1 trade+V4 envoy+V3 帶禮結盟,merged）；**③序0 done ✅（10 裸 cadence/timeout const 導出 `TimeScale.TICK_PER_DAY*N`＋FLEE 硬編240修＋eta/240→/TICKS_PER_DAY＋near/far hoist 進 gate,全零行為變 seeded 46/8/1/380 守恆）**;CI 掃裸 tick/倍率=後段。**FOOD/FATIGUE per-day 率=A2 重校對象（×5 手校痕）**；跨格旅途糧耗（×1 下 5× 增）=④完整食物收支 measure。
- **解析度旋鈕（藍圖 tick-resolution-60）**：`TICKS_PER_HOUR`（現 10）= 時間解析度旋鈕（動根字面 `TICKS_PER_DAY 240→1440`），`BASE_ACTION_TICKS=10` 遭遇戰動作粒度守速度鑑別度**釘死**。60 下運算安全（掃證：唯 `_get_near/far_teams` O(N) 需 cadence 化,餘 O(1)）;**序0 已修 ✅**（near/far hoist 進 gate＋10 常數導出＋eta/FLEE，全就位；根值仍 240 待 A2 切）。**`PRISONER_CHECK_INTERVAL=5` 非違規**（活凍結遭遇戰 time-frame,measure 證藍圖定性有誤）。

### ★ 空間尺度骨架（矩陣新維度，時間的空間孿生，藍圖 space-dim-freq-gate，2026-07-05，enforce 起步）
```
凡空間量  必從遭遇戰動作粒度錨導出（一格真實距離 → 據點密度/min_spacing/地圖 radius 連動）,不各自硬編
```
- 病：「一格多大」散三處（遭遇戰 `MAP_DIAMETER=24` / 據點 `min_spacing`/`total_count` / 移動 `MOVE_TICKS_PER_HEX`）= 空間版時間常數污染。
- **矩陣加第二跨切維度「空間尺度」**（配「時間尺度」，非綁單一實體，與意圖/belief/state/人力/互動同級）。單一來源=遭遇戰動作粒度錨。
- **強制閘**：掃裸硬編地圖大小/據點間距/移動成本（繞骨架）=fail。
- **enforce 起步**：本 arc（TICKS_PER_HOUR 調 + 據點反推）=首次落地,非結束；散落點=`game_setup.gd:66/73/74`(config radius/count/spacing)、`encounter:174/175`(MAP_RADIUS/DIAMETER)。**時間-空間橋**：一格真實時長 = `MOVE_TICKS_PER_HEX / TICKS_PER_HOUR`（60 下 240/60=4h/格=據點密度合理化,「1天/hex」語意隨解析度變=預期）。
- **運算頻率 = 非維度**（藍圖釘清）：= per-tick 有界 + 時間量必導出 兩既有不變量的閘檢查,非新格。裸 tick 常數導出=時間閘直接應用;每 tick 無條件 O(N) 迴圈=per-tick 有界守門對象。

## Information

- 認知不等於真實
- NPC 可說謊
- 訊息可能失真
- 任何資訊命令都需傳遞 ,永不跨距離傳播,也不全知

### belief 單一 accessor + multi-claim（G3b）
- 決策/UI 讀 `team_intel` 一律經 `BeliefSystem`（best_estimate/uncertainty/claims/has_belief/known_targets），**禁直讀 state.team_intel**（含 UI/inquiry）。
- storage = `team_intel[obs][tgt]` Array of claim（值/源/時效/可信度/失真）。寫端一律 `record_claim`。
- **多源不覆蓋**：claim 按 source_id 保留，同源更新、跨源 append，**禁 confidence-max 跨源覆蓋**（否則矛盾無從察）。
- **真值不隨行**：傳播失真寫 copy（`_distort_intel_entry` 回新 dict），原 claim 不被改。
- best_estimate = 最高 **effective_credibility** claim 的 value（G3c-1 真公式，含時效）。uncertainty = **credibility-weighted**（G3d-2 重定義，見 belief 段 G3d-2 條；取代舊 raw `(max-min)/max`）。
- caps：每 (r,t)≤MAX_CLAIMS_PER_TARGET、每 observer≤MAX_CLAIMS_PER_OBSERVER（TEST VALUE，剪低可信/最老）。
- 讀容錯（transitional）：accessor 遇舊式 Dict（test 直設/漏遷）coerce 成單親見 claim。canonical 仍 Array，生產寫端強制 Array。G3c 可收緊。

### 可信度公式 + 身份信任（G3c-1）
- **可信度公式**：claim 排序用 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數衰減) × 時效衰減`。寫時 cred 存進 claim（時不變部分），讀時乘 time_decay → 新鮮勝陳舊。**禁在 BeliefSystem 外算 claim 可信度**。
- **身份信任 = `TeamData.known_reputations[source]`**（team→team 動態，0..1 default 0.5，`update_reputation` clamp）。claim source = giver team → 複用既有 team→team 信任，**不開 RelationGraph person 邊**（team-keyed 不需 per-信使邊）。known_reputations 兼外交/施捨/勒索口碑 = 預期 coupling（量測顯衝突再拆專用 trust）。
- **source_type = 真來源類別**（親見/隊友/商旅/流民，非 distort mode）；失真另存 `distorted` flag（兩維度分離）。relay 分類：同 faction→隊友、商隊 tag→商旅、else→流民。
- **身份信任迴路（被動）**：record_claim 寫入親見後，比對同 tgt relayed claim 的 pop_est → `update_reputation(source, ±TRUST_DELTA)`（比值近 1 升、離譜/失真降）。被動偶遇既有 relayed 才跑，scout 主動查證 = G3d。
- **relay hop 只算一次**：message 傳播 cred 走 `source_credibility(...,hop=1)`，不再 `(1-HOP_DECAY)*confidence` 疊（修 G3b 雙重 HOP debt）。

### 技能識破 + 觀察吃技能（G3c-2）
- **技能識破**：收 distorted claim 時 `detection_discount(我 max(偵查,計謀), 對方計謀)` 折 claim credibility（信假1.0/生疑0.5/裁決0.2）。**非 un-distort**（值不動，只壓信）。效果經 best_estimate cred 排序（謊低於誠實/親見）。`is_suspicious` 由分級寫（降為 UI/G3d 提示 flag，非唯一效果，不再 dormant）。
- **觀察吃技能**：親見值噪 = `observation_noise(距離噪, 觀察者技能)`，低技能殘留噪 → 高 conf 親見可錯值（cred 仍 1.0）。源頭 claim 正確性 = 觀察者技能函數（vision pop_est 吃偵查、interaction armed_est 吃戰術）。

### 決策風險 gate（G3d-1）
- **攻擊性 commit 讀 uncertainty**：攻擊性決策（faction_ai 掠食/攻擊鎖定 prey、外交求貢）commit 前經 `BeliefSystem.confident_enough(state, 觀察者, 目標, 慎重)`——`confidence=1-uncertainty`，`threshold=lerp(GATE_CONF_LOW,GATE_CONF_HIGH,慎重)`。不確定且慎重 → 本 tick 不 commit（**被動按兵**，下次 cadence 重評，靠後續親見壓低 uncertainty）。莽者門檻低→照衝→假情報誘殺。
- **只 gate 攻擊性主動選擇**（belief-弱→主動攻/敵對）：prosperity attack + survival loot（`_find_weakest_prey`）+ 外交 demand_tribute。**不 gate**：威脅(防禦,極性相反 → G3d-2)、vendetta(私仇確定性脫軌 G2d)、結盟/求和。survival loot gate 失敗 → 落回其他絕境路徑（回家/覓食），不凍結。
- **不凍結**：親見單源 uncertainty≈0 → confidence≈1 → 恆過 → 正常掠食/攻擊不受影響；gate 只咬矛盾多源高 uncertainty。
- scout 主動查證（不確定→派斥候→親見壓謊→才動）= **G3d-2 ✅**（見下）；威脅(防禦)uncertainty-gate 仍延 post-measure。

### scout 主動查證 + cred-weighted uncertainty（G3d-2）
- **uncertainty = credibility-weighted**：`clamp((1−top_eff_cred) + cred 加權值分歧, 0, 1)`，`top`=最強源 effective_credibility，分歧 = `Σ wᵢ·|vᵢ−best| / (Σwᵢ·best)`（wᵢ=eff_cred，vᵢ=claim pop_est，best=best_estimate pop）。親見高 cred 主導→top→1 + 假源時效衰權重低→分歧小→壓低不確定（查證可收斂）；純未驗 relay→(1−cred) 高；雙新鮮高 cred 矛盾→分歧高。無 claim→1.0。取代 G3b/c raw 分歧公式。**禁在 BeliefSystem 外算 uncertainty**。
- **scout 查證迴路**：攻擊性 commit gate-fail（慎重者不確定）→ 不再被動按兵，改 dispatch `TASK_SCOUT`(move_target=prey best_estimate 位，`PRIO_DISPATCH`，reason `"scout"`)，記 `prosperity_target_id`=prey，**不設 combat_target**（純觀察）。斥候移入視野→親見壓謊→下 cadence uncertainty 降→confident→`release` scout 後 try_set `TASK_ATTACK`（同 PRIO_DISPATCH 須先 release 換手）。莽者(低慎重)恆過 gate→不 scout→攻假 belief→誘殺。
- **收斂保證**（序5 後：scout 機制在 `_commit_conquest_attack`/`_tick_conquest_scout` scaffolding，非已刪的 `_evaluate_prosperity_attack`）：scout 中允許重評；逾 `SCOUT_TIMEOUT`(TEST VALUE) 未收斂→`release` 回常規（防永 scout 卡死）。prey 親見後顯示強→find_prosperity_prey 不選→自然放棄（避誘殺）。scout 同 PRIO_DISPATCH 可被生存/威脅高層覆蓋（不凍結）。

### 攻擊目標選擇讀 belief（G3-targeting）
- **選擇層讀 belief**：`find_prosperity_prey`/`_find_weakest_prey` 的 prey 價值(richness)/弱點(weakness/pop)一律經 `BeliefSystem.best_estimate`，**禁直讀 prey 真 population/resources/armed**（god-view）。自身真值(`team.population`)照讀（自己不靠情報）。
- **無 belief 不評估**：候選經 `has_belief` 守衛，無情報→`continue`（**禁 fallback 回真值**，否則 god-view 回潮，違「team_discovered 僅可見性不作真值」）。
- **weakness 吃 armed_est**：`clamp(1 − armed_est/max(team.pop,1), 0,1)`，`armed_est = bel.get("armed_est", pop_est)`（tier2 偽裝低報在此咬；tier0/1 無 armed→退 pop_est）。richness 經 `_belief_richness`：tier2 資源估 sum/100 → 無 tier2 但有 `resource_scale` 粗估 → 皆無 0（TEST VALUE）。
- **誘殺載體**：偽裝(低報 armed_est)/失真 relay → 假弱 belief → 選假弱目標 → 戰鬥按**真**實力結算 → 莽者踢鐵板、慎重者 scout(G3d-2)看穿真強後不選。選擇層(價值)+gate(把握 G3d-1)兩層齊 = 誘殺脊椎閉環。
- **★位置語義澄清（2026-07-18，感知鐵律空間延伸）**：原「位置/reachability 屬可見性物理讀真位」**僅指地形**——拆兩事：①**地形/pathfinding cost/reachability = 物理真值**（PathSystem 讀真 tiles、A* 走真地形，合憲）;②**他隊「當前位置」= belief last-seen 非 live 真 `tile_pos`**（決策移動目標讀 `BeliefSystem.belief_pos`，範式=攻擊 to_task `options.gd:194`「攻擊 target 走 belief last-seen」）。**讀他隊 live `tile_pos` 作決策移動目標 = god-view（跟蹤已脫離視野的隊）= 違憲**。已知殘留(slice2 修)：threat DEFEND/求和 `decision_context.gd:192`→`options.gd:294/305` 讀 live threat_pos（與攻擊 belief 不一致）。
- **★threat evasion = intended 深度（blueprint 裁 2026-07-18，勿當 regression 修回）**：threat DEFEND/求和走 belief last-seen ⟹ 敵脫離視野可甩掉你的威脅反應（你朝最後見到位追，非瞬鎖真位）=**伏擊/脫接觸/佯動湧現玩法**，非 bug。belief staleness 自限（不永追鬼影）。**未來勿以「威脅反應追丟了」為由改回 live-track**（=違憲換皮）。威脅反應憑啥獨全知——同攻擊/FLEE。

### 決策讀 belief 非真值（G3 Phase E — provenance enforce）
- **信息域不變量**：凡決策評估**他隊**的 pop/food/armed/實力**或當前位置(tile_pos，作移動目標)**，一律經 belief（`BeliefSystem.best_estimate` / **`belief_pos`**，追得回 provenance），**禁直讀 `other.population`/`.resources`/`.armed`/`.tile_pos`（god-view 真值）**。比照決策域「無因令=0」硬約束：決策直讀真值 = 違規（=「自信地錯」的地基，欺敵才有後果）。已知殘留(slice2)：`absorb_yield`(decision_context.gd:369-372 讀 target 真 food+pop)、threat-move(讀 live threat_pos)。
- **★nearby-scan/LOD landmine（2026-07-18，連 [[時間統一 wave]] O(N²)）**：未來「只掃附近隊」的空間優化（LOD / reachability / intercept 預測）若**餵決策**，鄰隊位置一律 **belief last-seen 非 live `tile_pos`**。**★★訂正（2026-07-19 god-view audit，systems 前述「死碼」誤=grep glob bug 漏頂層檔）**：`path_system.gd` `observe_velocity`/`estimate_catch_up`/`predict_intercept`/**`_is_moving_away_observed`(226)** 讀 live `target.tile_pos` = god-view，**非死碼——production caller 以 `trusted=true` 跳 discovery 讀 live 位置**。stats(pop/food/armed) 已 belief-gate，**唯 position/velocity leak**。= **live god-view 違憲待修（god-view 殲滅 arc Slice D，最大塊）**。**★★caller inventory 訂正（reviewer 異質審 file:line 親驗 2026-07-20，前列行號 stale 勿信）＝10 caller**：`faction_ai:205/293/1403/2134/3607/3636/3666/3715/3747` + `threat_assessment:27`；~~3596~~ 非 caller。**★修法差異化（velocity≠position，異質 R² BLOCKER）**：velocity func（observe_velocity/predict_intercept/_is_moving_away_observed）斷視線→**invisible**（belief 無 velocity time-series analog，不可 last-seen）；position func（estimate_catch_up catch_cost）斷視線→belief last-seen 合法。freshness=`belief last_tick==current_tick`（鏡射 `_refresh_attack_pursuit:269` 但**分 velocity/position 語意**）。predict_intercept sentinel+envoy caller(1403) lockstep。詳 spec `2026-07-20-godview-slice-D-pathsystem-freshness-gate.md`。
- **★★掃近隊兩-channel（blueprint/用戶定 2026-07-18，遠方危險不得隱形）**：perf 靠「掃近隊」bound 的是**直接感知成本**，**禁把掃近隊當唯一 belief 填充源**。awareness 經 belief，belief **兩源填**：①**直接掃近隊**（近隊進 belief）②**情報網**（message/relay/known_reputations 把**遠方**高危險傳進 belief，獨立於直接掃）。∴ scan-nearby 優化**不得**讓遠方強敵隱形（=戰略盲）；遠隊「從沒掃過」仍須能經情報網進 awareness。scan-nearby spec 前 R① 必坐实既有 message/belief relay 真傳得到遠威脅（率/延遲），別假設。
- **無估 fallback = 保守/不行動，非偷讀真值**：無 belief → 攻擊性決策(掠食/求貢/背叛)最保守（skip 或視對方等強/強 → 不主動敵對）；選擇層(prey/aid/strong)無 belief→`continue` 不列 candidate。
- **已補 leak（6 處）**：
  - `diplomatic_ai_system.gd` `try_proactive_diplomacy` demand_tribute power_gap（1a）
  - `diplomatic_ai_system.gd` `handle_diplomacy_message` demand_tribute 回應讀 sender 實力（1d）
  - `diplomatic_ai_system.gd` `consider_betrayal`/`betrayal_assessment` 盟友實力（1e，優先 faction snapshot 次 belief）
  - `faction_ai_system.gd` `_find_strong_neighbor` 強鄰 pop（1b）
  - `faction_ai_system.gd` `_find_aid_target` 施援目標 pop+food（1c）
  - `threat_assessment.gd` `_power_ratio` 無 belief fallback→self_pop 視等強（1f，2026-07-17 threat-oracle S1.5;原 fallback `other.population`=首接觸讀真 pop 破虛張）
- **背叛 belief 驅動化（Task3）**：`betrayal_assessment` 純函數＝人格 + belief power advantage（盟弱我利→動機↑）+ confidence gate（1−uncertainty，不憑不確定情報背叛）。`consider_betrayal` driver 為主驅、僅門檻邊界保留小 stochastic tie-break（去純 `randf()<0.1`）。driver 可解釋。
- **刻意豁免（同 faction 內部協調，讀真值合法）**：merge/consolidate、faction/global tally（`faction_ai_system.gd` :1060/:1072/:1145/:1630/:1650/:1991 一帶）＝同勢力共享情報 believable；背叛的 faction `known_member_states` snapshot 亦屬此類。**★~~位置/reachability = 可見性物理(PathSystem 讀真位)不在此限~~ 否決（2026-07-19 god-view audit）**：他隊當前位置=belief last-seen（見上位置語義段）;PathSystem `estimate_catch_up/observe_velocity/predict_intercept` 讀 live 他隊位=**god-view 違憲待修（Slice D）非豁免**（terrain/自身位=物理真合法，他隊位≠）。
- **★★市集＝零豁免、必經 belief（用戶定 2026-07-19，否決舊「公開地標豁免」；god-view 殲滅 arc Slice C）**：~~市集 outpost 公開地標豁免~~ **否決**——**市場資訊永遠要傳播（憑聽過/belief，非全圖 god-view 掃）**。`_nearest_market_outpost`（`faction_ai_system.gd:2065-2078`）現全 `state.world.tiles` 掃無 discovery gate = **god-view 後門**（汙染 economy 診斷=改序先修 god-view 的硬理由）。**修（Slice C）**：貿易/買糧選市場**憑 belief（聽過該市集/其賣單，經 message/relay 傳播）**非全圖掃。**★前置**：BeliefSystem 現 team-keyed **無 tile/market 級知識庫** → Slice C 需**建 market-discovery belief store**（tile/market-level）+ 市集資訊經傳播進入。冷啟動出門憑「聽過附近有市集」的傳播 belief（非全知）。敵情/社交/市場位置**全走 belief，零 god-view 豁免**。
- **審計手段 = 回歸測**（非 runtime probe，成本裁）：`headless_test.gd` `_test_leak_*`（真值≠belief 兩向斷言決策跟 belief）+ `_test_betrayal_belief_driven`。新增決策讀他隊 stat 須走 belief 並補對應「真值≠belief」測。

### 屈服/失真/戰意單一 owner（F-I2/I4/I7，2026-07-04 互動統一）
- **屈服判斷單一 owner = `DiplomaticAI.tribute_accept`（static）**：勒索/求貢/兵臨「要不要屈服」一律委派此公式——belief-gated（aggressor 實力讀 believed pop_est，無估 fallback=視等強保守）、fear/求生欲在公式內（防衛方心理恆在）、兵臨壓力=caller `threat` 輸入權重、feud/gratitude 邊入權重（血仇不屈/恩義軟化）。**禁新開屈服公式**（三舊公式已退役：`_should_pay_tribute` ✂/`resolve_extortion_direct` 內嵌 ✂/`demand_tribute` 內嵌 ✂）。
- **失真單一 owner = `DistortionEngine`**：訊息內容（`distort_message`）/intel 估值（`distort_intel_entry`）/親見欺敵（`apply_observation_deception`）三 call site 傳 context，**禁在 engine 外寫失真邏輯**（舊三引擎+dormant 第 4 已退役）。寫點（`_write_tier2_intel`/`record_claim`）不變。
- **combat verb belief-gated**：`_should_attack` 讀 believed `armed_est`（退 pop_est）vs 自身真 armed；**無 belief → 保守不攻**（G3-E「無估 fallback=不行動」）。新 caller 契約：呼前須確保 belief 已寫（`_try_interact` 開頭雙向 `_write_tier2_intel` 即此保證），否則恆 false。

## Simulation

- Event = Consequence
- 禁止 Scripted Outcome
- **遍歷 id 快照前必驗存在**：team/person id 陣列是 tick 開頭的快照，元素可能在本 tick 內滅團/死亡被移除；存取 dict 前先驗 `.has(id)`，否則 Invalid get index

## ★★ 三條對稱不變量（統一架構骨架，believability 北極星，藍圖 2026-06-29）

同一隻病（憑空 / latch / 無可解釋來源）跨三域，三條對稱不變量 = 統一架構全骨架：
```
凡 named 意圖  必有可解釋驅動        ← 決策域  ✓ done（commander-v2 無因令=0 enforce）
凡 belief     必有 provenance(來源)  ← 信息域  G3 待 enforce（provenance 即識破機制：能追來源才能疑）
凡 state 變化  必有可解釋來源/單寫者   ← 所有權域 Pattern B driver-ledger 起步（slice2:5 bank reason 真記+roster chokepoint;tile-bank/combat_target 後 slice）
凡位置        必有可解釋上位路徑      ← 選擇/階級域 (a) 攀爬動力待修（起始劇本擺放豁免=authored premise）
凡 tick       早晚期成本無延遲差      ← 效能域  硬不變量（藍圖 2026-07-02,perf 倒推 1-2 代尺度,玩家直感）
凡 in-flight latch 必有 timeout/release ← 決策域  硬規則（藍圖 2026-07-03,②a found_ally 揭家族病）
凡身分        只能是權重不能是路徑切換  ← 決策域  原則（藍圖 2026-07-03,「入勢力不換腦」）
```
- **★效能域（per-tick 有界,藍圖 2026-07-02 升硬不變量）**：per-tick 成本早晚期**無延遲差**（玩家直接感受;perf 倒推出 1-2 代尺度）。推論：**世界大小全程有界**（1-2 代內累積也 bound）。**die-off erase O(N) spike 從「另案 backlog」升為必收**（滅團潮=大戲時刻最會爆、直接違反此不變量;長跑滅團潮量到 freeze 前該修，見 known_issues scaling）。scaling 加固（P0 索引+leak done、die-off spike 待）服務此不變量。
- **選擇/階級域（藍圖 2026-06-29）**：位置持有者（faction leader / established ruler / named commander）的 traits 必須**靠真選擇掙來、可解釋**（從其出身階級池帶真 rolled traits 爬上來），**非生成 fiat 欽定**（當了領袖就塞強數值=作弊）。**例外：起始劇本擺放 = authored premise 明示豁免**（設計者佈局種子，非憑空）。**(a) 主體 = 攀爬動力**（能人從底層真能升到立國/征服的鏈每段要通：累積>損耗 / 每階有可走轉換 / 跑途中能 founder 新派系 / 活得夠久爬完）；稀有度=屬性分佈旋鈕（攀爬通後才微調）。
- **決策域 ✓**：見下「意圖驅動完備」（commander-v2 落實）。
- **★latch-timeout 規則（藍圖 2026-07-03 升格,②a 揭）**：凡 in-flight latch（dispatch 後「不重評」guard）**必有 timeout/release**。scout 有 SCOUT_TIMEOUT、FLEE 有 FLEE_TIMEOUT、TRADE 有 TRADE_TIMEOUT、**found_ally 漏了=狼凍 4-6 月**＝家族病。timeout 別死常數——按「距離/移速」估合理往返時間。CI 可掃（有 dispatch-guard 無對應 timeout 常數=fail,強制閘 program ②候選）。
- **★身分=權重非路徑切換（藍圖 2026-07-03 升格,斷① 揭,用戶裁）**：**個人戰略層對每個 leader 永遠在跑**（統一架構本義）;faction 身分=一個 context/term（faction_duty）,大事壓上來、日常人格照驅動、低忠高野仍能叛。**任何「按身分切換決策路徑」（如 `fid≠-1 → 關掉個人層`）=違規**——入夥即人格蒸發。身分只能加權重。
- **信息域（G3，next keystone）**：凡 belief 必有 provenance（來源/credibility/時效）。= 欺敵地基 + 玩家錨 C 核心（玩家=霧裡 belief 消費者）+ 因果脊椎③。G3a-d 已建 multi-claim/credibility/detection/uncertainty/scout，待 provenance-complete enforce。
- **所有權域（Pattern B，slice2 起步）**：凡 state 變化必有單寫者 + driver-ledger（非僅 banker 集中寫，還要可追「為何變」）。解鎖可信內政（忠誠/民怨/壓力→叛亂崩潰有因）。**slice2 落地**：driver-ledger 真記（5 bank reason）+ roster chokepoint（見資料模型規則 2/4）。**首個可查對象揭 pre-existing leader/team_id desync → slice3 根修**（`set_leader` chokepoint force-sync + 反向 roster audit 常駐守 + driver_tick_hint 接線[ledger tick 溯源真]）。**combat_target/social_target chokepoint 落地**（`set_combat_target`/`set_social_target`,語意拆戰鬥≠社交,dangling audit;順修 BEG/JOIN 死路 F-I3）。剩餘：tile-granary-bank / tile.resources bank（後 slice）。完整未實現面見 `known_issues` 統一矩陣。

## ★ 意圖驅動完備（決策域，藍圖 2026-06-28）

- **凡 named 意圖必有可解釋驅動**：每個 named 意圖（派系令 / 隊 task / 人物 action / 野心階）**必追得回根驅動**——need / value / belief / **父意圖**。**追不出驅動 = bug**（閾值/tag/latch 憑空跳出=該病）。
- **連貫來自共享父意圖，非收斂單一**：多重命令 OK 甚至嚮往——只要可解釋。統領先 utility 選**戰略意圖**（征服敵X / 防衛 / 致富 / 擴張），意圖**生成協同子命令**（征服X → 攻擊X[手段] + 對X盟友外交[欺敵拖住] + 徵收[籌軍費]＝多令服務同一意圖）。**每令帶「為什麼」（連回父意圖）**。欺敵 = driver 真實（服務征服X）+ action 不真心（戰術外交）。
- **= 因果脊椎 + 統一決策合一**（[[project_causal_spine]] / [[project_unified_decision_framework]]）：驅動鏈 = 因果脊椎顯化 + 強制。直接定義玩家錨 C——世界 driver-complete → 玩家情報遊戲 = 從看得到的 action 反推看不到的 driver（外交=真結盟還是欺敵？囤糧=遠征還是投機？）。亦是 believability 審計鏡（走任一意圖問 driver，答不出=洞）。
- **範圍紀律**：北極星 + 不變量，**非現在停下給所有 action 塞 driver 欄重寫**。**統領層現在落實**（commander-unify 第一處）；其餘 = 審計鏡頭，按 player-visibility 排序逐步補——新工作須滿足，舊工作照洞補。**禁鑽牛角尖**（[[feedback_avoid_rabbithole]]）。

## 關鍵設計規則

- **不直接 script 結果**：所有行為從 NPC values/skills/stress/loyalty 計算產生
- **新功能前定義**：影響的世界狀態、資訊流動、時間消耗、受影響群體、二次後果

## 對稱性

- **無玩家專屬機制**：任一交互 / 生存系統（戰鬥 / 貿易 / 外交 / 覓食 / 狩獵 / 任務 / 賞金…）NPC 必須同樣能用
- 玩家與 NPC 走同一套底層數學；差別只在玩家可手動接管、NPC 自動解算

### 敗方損耗對稱
- encounter 與 npc_combat 敗方結算皆對敗方整隊 anon pop（**含未上場 reserve**）施 tier 加權陣亡（`AnonTierSystem.kill_random` + `SURVIVAL_KILL_WEIGHT`），無玩家專屬豁免（game-design §對稱性）。
- pop 變動只經 cohort API。武裝下限 `ARMED_RATIO_FLOOR` 在消費端（encounter spawn / npc 戰力）套用，不覆寫 `armed_anon_ratio` 推導值。
- **每 round 傷亡走分數累積器**（`_resolve_combat_round`+`_accum_casualty`，2026-07-10 §D4 de-patch）：real-valued 傷亡跨 round carry 於 `_combat_track[id].cas_carry`、floor 取整。**禁 `int(round())` 直接量化**——對小 pop（eff≤3，積 <0.5）恆捨入 0=絕境隊零流血=殲滅結構不可能（補丁閘型病）。累積器**零新增 randf**（傷亡量化不引入 RNG），seeded warring determinism 保。

## 玩法節奏

- **decisions-not-chores**：玩家做決策，模擬跑雜活；壓力存在是為製造決策岔路，不是逼玩家重複操作
- 可跳時間；事件只在 juncture 介入
- **激情時刻全手動 + 真風險**，且主要由玩家冒險決策觸發（非隨機 spam）

## UI 邊界

- **UI 只經 player API**：UI 層（`scripts/ui/*`）禁止直讀/直寫 `WorldState`；一切經 `SimBridge` → `PlayerQueryApi`/`PlayerCommandApi` 的 DTO
- **DTO 是 UI 契約**：玩家 UI 需要的任何 sim 資訊，必須 map 進 DTO（非讓 UI 繞道取）→ 換 UI（文字↔圖形）只需接同一 API
- **觀測 UI（ObserverMain）= 平行契約**：god-view 合法（觀測非玩家），但**全 read-only**——經 `ObserverBridge` → `ObserverQueryApi` DTO，禁寫任何 sim state（唯一 sim 側接點=`emit_ambient` append，見訂單系統節）。玩家 UI 禁用 ObserverQueryApi（god-view 洩漏）。`world_map_view.gd` 雙用途（`_observer` guard 分流），動 player 繪製須顧 observer 分支。

## NPC

決策來源：

- Values
- Skills
- Needs
- Memories

禁止硬編碼結果

## Interaction

- **嚴禁非同格互動**：戰鬥 / 貿易 / 外交 / 投靠 / 徵收 / 信使 / 安頓 / 安撫 全部需 `team.tile_pos == other.tile_pos`
- 觸發點：`interaction_system.process_on_move`（mover 對全 team 掃同格 → try_interact）

## Anon

- anon 是 team-level 抽象集體，**無個體 entity**
- 統一儲存於 `team.anon_cohorts`（稀疏 dict，鍵 `"tier|health"`→count；tier ∈ 平民/新兵/老兵/菁英，health ∈ healthy/wounded）
- 變動只透過 `AnonCohort`（add/move/remove）或 `AnonTierSystem`（add_anon/remove_anon/kill_random/wound_random/heal_random/kill_wounded/transfer_proportional/try_promote）
- `population` / `wounded` / `anon_combat_skill` / `anon_wage` 為 computed getter（投影自 cohort，**不可直接寫**，舊 set no-op）
- 入團時保留來源 tier（戰俘 / 投靠 帶原 tier 進入）；受傷 = move healthy→wounded；晉升 named/leader 從 anon 桶移除 1

## Task

- `current_task` 是團體狀態（不是個體）
- `combat_target` 是「正在戰鬥」flag（戰鬥中設、結束清）
- `prosperity_target_id` 是「想攻擊誰」意圖（攻擊 AI 評估時設）
- 兩者語意分離，不可混用
- **每個高優先 task 必須有釋放條件**：進得去必須出得來，否則凍結世界（高優先 task 蓋住一切）

## 財產 / 守恆

- **居民私產與統治者公庫永不混淆**：私產（採集稅後）vs 公庫（owner 稅金）兩錢包分明
- **建造資源嚴格本地**：建材來自施工團自身 + 腳下據點公庫（兩源皆可），不可動用他處據點的資產（非隔空遠端取物）
- **有限資源守恆**：建造永不消耗有限資源；任何死亡 / 滅團，資產走守恆路由，永不憑空銷毀
- coin 只能由鑄幣產生，無其他來源

## 飢餓 / 人口

- 飢餓判定唯一來源 = 團糧（個人不另算飢餓）
- 死亡順序：弱者先死（minor → anon → named）
- 生育是生命事件（可與行動並行），不與行動反應競爭單一名額

## 資料模型不變量規則（防散落純量 drift）

1. **可衍生聚合 → computed getter，不存可變欄位**。任何 `= f(權威來源)` 的值用唯讀 getter（範本 `team_data.population` / `wounded` / `anon_combat_skill`）。物理上不可 drift；加人必須動真來源（named_members / anon_cohorts），不能偷改數字。
2. **來源/雙向關係走單一入口**。anon 改動走 `AnonCohort`/`AnonTierSystem` 入口；勿直接 `anon_cohorts[k] = ...`。team↔faction 走 `set_team_faction`、child↔parent 走 `set_subteam_parent`、**named 成員↔person.team_id 走 `add_member`/`remove_member`**（勿直接 `named_members.append/erase`；`remove_member(...,clear_team_id:=false)` 給晉升 leader/死亡留屍/轉隊已先設目標隊三類）。**leader_id 賦值走 `set_leader(team, pid, old_leader_action)` chokepoint**（設 leader_id + **強制 person.team_id 回指本隊**[根修 slice2 揭的 leader/team_id desync] + role="leader" + 出 named_members;`old_leader_action="member"` 舊 leader 降 named）。建隊構造（`beast:30` 全新欄位初始化）+ bulk 清空（`subteam _merge_into` 尾 per-member add 後）= 明示豁免。**新增轉隊/晉升/死亡路徑須：入 roster（add_member/set_leader）或標 `person.is_dead`**（否則反向 audit 抓）。**combat_target 走 `set_combat_target`/`clear`（純戰鬥語意）、投靠/乞食社交目標走 `set_social_target`/`clear`（≠戰鬥,別塞 combat_target 否則被 `_try_interact:197` 戰鬥早退吃掉=BEG/JOIN 死路）。**
3. **不可衍生的真存量 / 不變量 → 註冊進 `InvariantAudit.check`**。真存守恆量（coin_eq **全池=team.resources+anon_treasury+person.coin+tile.public_storage.coin+abandoned_coin,見 `CoinAudit`；coin_eq 剔 ore=採集產出非守恆、mint 唯一 coin 源走 ledger 認增發**）、cohort 自洽、faction/subteam/**roster（named/leader↔team_id **雙向**:forward=roster→team_id、reverse=活人 team_id→roster,`p.is_dead`/team 不存在跳；`_check_roster_bidir`）**等靠 audit 守。加新不變量 = 加一個 `_check_*` 並在 `check()` 呼叫。
4. **改資料模型前讀本節。**

**所有權域 Pattern B driver-ledger（slice2 落地，第3不變量 enforce 起步）**：`WorldState.driver_ledger`（off-by-default ring-buffer）+ `record_driver(entity,field,delta,reason)`。5 bank（Resource/AnonTreasury/OutpostOwner/Loyalty/Unrest）的 `reason` 真 append（非丟棄）→ 強制閘/審計可查「這筆 state change 為何」。**新 bank 操作須帶 reason 並經 `record_driver`。** 剩餘（tile-granary-bank / tile.resources bank / combat_target chokepoint）= 後 slice。

## team reference 契約

移除 team 一律走 `state.erase_team(tid)`（唯一 chokepoint，清光所有指向它的 ref）。但解析時分兩類 —— **實證後的區分**（2026-06-18 batch1 子 session 證偽「全部納管 ref 永遠活」）：

### A. 維護集合元素 → 保證活 → `require_team`
`faction.member_team_ids` / `subteam_ids` / `team_known[obs]` / `team_discovered[obs]` 內的元素由 erase_team + 雙向 audit 持續維護，迭代時**每個元素必活**：
```
for tid in faction.member_team_ids:
    var t := state.require_team(tid)   # 保證活，不檢 null
```
這類**不可**寫 `if t == null`（dangling 不可能；寫了=死碼）。

### B. 單一可變 target 欄位 → 可瞬時懸空 → 保留容忍/自癒
`combat_target` / `order_target_id` / `parent_team_id` / `faction.leader_team_id` 是單欄位 target。**tick 內有瞬時懸空窗**：setter 可能從快照塞入「本 tick 稍早被 erase」的 id（setter 未驗存在）；erase_team 清得乾淨，但下個 setter 又塞 stale。月 audit 抓不到（自癒/cleanup 在取樣前清掉）。
→ 這類**保留** `teams.get()` + null 容忍/自癒（`if t == null: 自癒清 -1`）。**那些 guard 是 load-bearing 處理真瞬時態，非壞味道，勿改 require_team**（會在瞬時態崩）。

### 不納管（照舊 `teams.get()` + null）
玩家輸入 tid、`teams.keys()` 快照迭代期間可能已 erase、persons/tiles/factions 等非 team-ref lookup。

> `require_team` 對不存在 assert（debug 抓持久懸空 bug、release 剝離保韌性）。只用於 A 類。要讓 B 類也成立 = 修所有 setter 驗存在（大、收益邊際，因 guard 已正確處理瞬時態）→ 不建議。

## Leader 繼承單一 owner

- **繼承邏輯單一 owner = `EventSystem.on_leader_death(state, team) -> bool`。** 偵測單一點 = `faction_ai` 每-tick 安全網（`leader_id==-1` → 呼 owner）；`npc_combat._kill_named_npc` 戰中即時呼為效能捷徑（非另一 owner）。
- 禁止在 `on_leader_death` 外自行決定繼承人 / promote。裸置 `leader_id = -1` 僅允許作 transient（須由安全網次 tick 補位）。
- 分派：player → forced `choose_heir`（named 空則 `game_over`）；NPC → best named 無門檻晉升 → 無 named 則 anon 晉升 → 皆無回 `false` 滅團。晉升成功後呼 `PopulationSystem.check_overflow_for_team`（弱 leader → pop_cap 溢出回饋）。
- player 分支偵測靠 `WorldState.get_player_team_id()`（單一源）。但**死者 person 已 erase 時偵測查不到**（leader_id=-1 且不在 named）→ 已知是 player team 的 external caller（encounter `_check_player_wiped`、player_command stale-heir 終局）**直呼 public `EventSystem.handle_player_succession(state, team)`** 繞過自動偵測。所有真實路徑呼 `on_leader_death` 時死者 person 尚在 `persons`（combat 在 erase 前呼、famine/encounter/安全網從不 erase）→ 自動偵測對它們成立。
- 冪等：`on_leader_death` 的 player 偵測分支對已 pending 同隊 `choose_heir` 直接回 `true` 不重設（安全網每 tick 重呼）；`handle_player_succession` 本身不帶冪等（external caller 要即時重評）。

## 關係圖（typed-edge）

- typed 關係事實只經 `RelationGraph`（add_edge/edges_of_type/edges_to/strongest）寫讀 `PersonData.relation_edges`。
- 圖核心**型別無關**：只按 `type`/`target` filter；加新型別 = 加 reader，**禁改 RelationGraph 核心**（WHAT spec §4 硬約束）。
- 扁平 `relations`（純量泛好感）與 typed 圖**語義分職**並存：前者連續情感（loyalty/反應），後者事件型關係邊（feud/protect/gratitude/killed）。
- G2 用型別：`feud`/`gratitude`/`protect`（write_memory 填）/`killed`（G2d 死亡鏈）。未來 `kin`/`spouse`/`master` 等同型塞入。
- **consumer 現況（2026-07-04 F-I5 接線）**：feud → `vendetta_target` + `tribute_accept` 權重；gratitude → `tribute_accept` 權重。killed/protect = dormant（zero writer 或 writer-dead chain，見 known_issues，收徒/擊殺鏈機制時裁復活或刪）。
- 回傳：`true`=已處理（含 player pending）；`false`=無繼承人 → caller 滅團/faction 解散。

## 私人脫軌（血仇）

- feud 邊由戰鬥（looted/betrayal/extorted 記憶 → G2a `write_memory` 映射）populate（敗方含 leader 對勝方獲 feud）；本層只加 reader，不重做血仇 populate。
- `NpcAiSystem.vendetta_target` 讀 leader 最強 feud 邊 + 衝動 gate（好戰 ≥ `VENDETTA_BELLIGERENCE`、慎重 < `VENDETTA_PRUDENCE`、intensity ≥ `VENDETTA_INTENSITY`，全 TEST VALUE）→ 回仇人 team_id（存在且非自隊）否則 -1。冷靜 leader 隱忍不脫軌。
- 脫軌 = `faction_ai.evaluate_all` 在 `_evaluate_threat` 後以 `TaskArbiter.PRIO_VENDETTA`(55) try_set TASK_ATTACK：生存(80)/威脅(70) 擋得住、prosperity(50) 擋不住。置於 threat 後因 `_evaluate_threat` 只在 idle 動作 → threat 先佔 task 則 vendetta@55 搶不動（威脅優先）。
- `relation_edges` 的行為 consumer = `vendetta_target`（G2a 圖不再 dormant）。pre-existing dormant `NpcAiSystem.get_goal_task_override` 已刪（revenge 意圖由本路徑經 G2a 圖取代）。

## 訂單系統

- 訂單權威存發起隊 `active_orders`；`emit_message("order_buy"/"order_sell")` 為**可失真傳播副本**（殘缺市場知識湧現，復用 message propagate/distort）。
- **★`global_messages` 禁外部 append**：`order_system` 借 `global_messages.size()` 當 order_id 空間 → 任何非 `emit_message` 傳播路徑的 append 位移 oid 流=訂單去重/履約行為真變（2026-07-04 observer 軌 seeded 逐點 diff 實證）。**觀測型事件走 `emit_ambient` → `state.observer_messages`**（獨立 append-only channel，cap 裁尾）：不進 global_messages/team_known、**sim 禁讀**、無 RNG 消耗——觀測零擾 by construction。
- 履約/讀取依 message 副本，須回發起隊 active_orders 核對（撲空 = 副本過期/失真，G1d）。
- 生產需求偏好讀 `OrderSystem.received_buy_orders`，不另建需求表。同格本地交易沿用既有 interaction trade；跨格商隊 = G1d。
- 商隊（商業 archetype）目標**讀收到的訂單**（`team_known` order message = 殘缺/可失真，`OrderSystem.best_arbitrage_order`），**禁讀 `team_discovered` 上帝視角**挑貿易對象（接「目標決策讀殘缺情報」總則）。`_find_trade_target`（team_discovered）降為無訂單時 fallback，最終應刪。到場履約走既有 interaction 同格 trade。
- 短缺發買單：`tick_team_orders` 對 `_ORDER_ELIGIBLE_RES` 中低於 `SHORTAGE_QTY` 的料/武器 res post buy order（生產買單來源，閉 G1b 半 inert）。
- 撲空 = 訂單過期/失真 → 到場供需已變 → 既有 `local_value` glut 給壞 deal（**無新機制**）。準情報值錢，為 ③G3 鋪路。

## 隊目標單一 owner = leader 野心階梯

- 隊無獨立目標。`TeamData.ambition_rung/archetype/cap` 由 leader values + 隊安全經 `AmbitionLadder` derive，**單一真值源**。換 leader → 重 derive（方向劇變）。
- faction strategic_goals **衍生**自 faction-leader 階梯（`strategic_ai._update_faction_goals` 讀 rung/archetype），禁他處獨立定隊/勢力戰略目標。
- 階梯門檻/權重全 TEST VALUE（正式平衡 pass 調）。rung→每階 task/tag 全表 = G2c ✅；個人脫軌（血仇）= G2d ✅（見「私人脫軌」）。
- 隊常態行為由 `AmbitionLadder.rung_task(archetype×rung)` 驅動（既有 TASK_*，零新 task），`PRIO_AMBIENT` 只填 idle。生存 rung→`_trigger_survival`；武力擴張→prosperity；立國/稱霸→faction strategic(G2b)。極絕境/威脅/脫軌(vendetta)優先序皆高於 ambient ladder。
- **統領 `_update_goals` = means-end 意圖驅動（commander-v2，北極星第一處落實）**：非並行多閾值 append、非收斂單一姿態。流程＝意圖 predicate（小集 `{征服X,致富,防衛,守成}`，`_select_intent` 人格×belief×viability×hysteresis argmax）→ 子需求現算（深度1，主行動未滿足前提 vs live 世界，`_decompose_needs`，**不遞迴**）→ 真 affordance 匹配補肢（`_match_fillers` util=affordance∩need×人格適性×viable，從人格餘裕抽，非硬塞）→ `_emit_goal`（**每令 `f.goal_drivers[goal]={intent,why,mode}` 連回意圖＝可解釋驅動，無無因令**）。意圖 hysteresis（`f.intent` 承諾，`COMMANDER_COMMITMENT_BONUS`）；resource-aware viability（征服湊不出實打力→退更小意圖，不發打不贏攻擊令）。只掛真 affordance（攻擊combat/徵收levy·fund_war/外交ally）；**欺敵孤兒（擋敵盟子需求）無真 filler→不開該 need=anchored-pre-player**。掠奪=team option（非統領令）；緊急徵收=survival override（意圖前 return）；立國=既有分離 gate（非意圖集）。
- **獨立戰略層 = 野心普世驅力，戰略意圖非 faction-only（統一決策 arc 第三塊）**：戰略意圖層**下放到野心獨立隊**（`faction_ai._evaluate_independent_strategy`，fid=-1 + 野心≥`AMBITION_FOUND_MIN` + 累積夠[pop≥EXPAND_MIN_POP + 食盈餘] + founding 路徑可達 才觸發），mirror commander-v2 `_select_intent`（輕量）。意圖集只 `{建國, 守成}`（征服/徵收等 = 成 faction 後 commander-v2 給，獨立層不重做）。**建國 = means-end 秤的 option（driver=野心，driver-complete），非「野心+夠 pop→自動 create_faction」fiat**；means-end 子行動 **結盟（primary，義氣染）/吞併（機會，殘忍·好戰染）** argmax+hysteresis → **複用既有 `create_faction`**（結盟 `interaction:333` 兩獨立 / 吞併 `npc_combat:524` subjugate，**不新 founding 機制**）。守成=不 dispatch（繼續既有個體決策 SoloAI/survival/ambient）。**稀有 by construction**（三閘）→ 多數獨立隊守成（非建國潮）。**宣告（solo declare）defer**：無獨立鄰+無弱鄰的孤立野心隊暫無路（守成累積，backlog）。接點 = `evaluate_all` per-team 迴圈（survival 後 prosperity 前，fid=-1 cadence gate），不雙寫 `_evaluate_solo`（後者 idle-gated，被 PRIO_DISPATCH 建國令覆蓋）。

## 混合協調（faction stakes vs team 日常）
- **stakes-to-faction → 頂層協同；team 日常 op → 個體**（ruling §1）。stakes 集合 = **攻擊/徵收/外交**（`DecisionContext.STAKES_SET`）由霸主 `_update_goals` **means-end** 設 `f.goals`（單意圖→主令+補肢，每令帶 driver；viability gate=稀有蓄意）；unified 隊經 `faction_duty` term 響應。日常（貿易/掠奪/scout/survival）無 faction_duty=各隊個體決。**立國 = leader-level（`_declare_established`，非 member option，不在 stakes 集合）；掠奪 = 日常個體（非 stakes）；結盟 ⊂ 外交。** **war-priority（`FACTION_DUTY_DRIVE_LESSER`）已 revert**：單意圖後成員一次服務一意圖的子命令（主令+補肢）無同級矛盾，徵收/外交 drive 回 `FACTION_DUTY_DRIVE`(1.5) 與攻擊同級。
- **頂層決 WHETHER，人格染 HOW**：派系 directive 決定「要不要做」；member 經對應 option 的個人 drive×weight 染色執行強度。染色映射：攻擊=`attack_drive×attack`(好戰/殘忍)、徵收=`levy_drive×levy`(貪婪/好戰)、外交=`diplo_drive×diplo`(義氣/計謀)。協同≠同質。
- **stakes target finder**：攻擊/外交→`_nearest_independent`（最近獨立隊）；徵收→`_richest_member`（同 faction 最富 member，**雙重排除自身** `== team.team_id`，因 `_richest_member` 未排自身）。徵收/外交=非戰（不設 combat_target）。
- **脫軌逃閥**：`faction_duty` weight **與** 個人 drive（`attack_drive`/`levy_drive`/`diplo_drive`）共用脫軌因子 `_duty_factor = clampf(loy − max(0,野心−0.5)×DEFECT_K, 0,1)` → 低忠誠+高野心 member 的 duty 與個人驅力齊壓 0 → 個人驅力（survival/野心/貿易）蓋過 → 不參與/自走=破framework脫軌。faction_duty 是**加權 term 非 hard override**（非 100% 服從，by construction）。
- **危時不為派系做事**：survival-class term 危時量級碾壓 faction_duty（食物優先；攻擊/徵收/外交皆然）。
