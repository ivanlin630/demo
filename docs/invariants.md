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
- **★★★人格 WEIGH 不 GATE（用戶重申憲法 2026-07-24，鏡射 game-design:224/226；HOW-enforce 本體）**：**決策上人格只能 WEIGH 行為傾向,不能 GATE 可用選項。** 人格驅動自由發展=沙盒核心;archetype（商隊/軍閥/工匠）=**湧現描述非硬類別非硬需求**。∴**任何硬 persona-gate = 補丁 = 違憲,無 coherence 例外**：①**persona>threshold → 行為 on/off**（如 `martial>0.6 or amb>0.7 → 能否建軍營`、`amb>0.6 → 徵戰爭基金`、`SCARCITY_RAID_MIN 0.55 → 能否掠奪`、`MINING_GREED 1.1 → 能否建礦`）②**discrete archetype label → gate 行為**（`derive_archetype` argmax→標籤→`faction_ai:973` 擴張限 FORCE、`_militancy force_arch`；archetype 當 **weight context** OK,當 **gate** 不 OK）。**de-patch = 一律轉 soft 權重**（人格移傾向、人人 CAN、utility 連續可翻盤）。★**差異化零損失**：和平領袖掠奪 utility 趨 0 幾乎不做但情境 compelling 仍可;軍閥愛擴張靠強權重非硬牆——要多強調多強,只是**不准硬類別 yes/no**。★**邊界（憲法管決策邏輯非世界結構）**：結構/物理約束（mil-facility 不能蓋 civilian 據點、stable 限 plains、terrain 產量、能力歸零=送死）**≠人格閘=世界物理,留**。★**enforce**：`constitution_gate.gd` threshold/route 型抓 scripted 決策閘;結構稽核=其憲法合規掃描姊妹。「保護 coherent 人格硬閘」=開違憲例外口=rationalization,禁。延續 :47 域專 scorer（合法 scorer 穿人格秤 vs 違憲硬 gate 卡選項）+ :221 身分=權重非路徑。
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

**★decision-bearing 聚合必附 bounded 樣本（顯規則，blueprint/用戶定 2026-07-21）**：任何**會餵 WHAT 級決策**的聚合探針（方向/release-pass/HOLD 解除/verdict）——**寫時同捕 3-10 個 bounded instance**（能消歧的維度：res/隊/task/死因；有上限非全 dump），非計數器單獨存在。**血證**：`sell_no_surplus=302` 只存計數→systems 誤讀成 food verdict、blueprint 用它解除 HOLD→用戶戳「沒人讀過故事」→補 res-split 才見 91% goods。聚合 count=fact，composition 詮釋沒拆維度=未坐實（[[feedback_fileline_vs_interpretation]]）。開銷非理由（探針 on-hit 多印幾行近免費）。機制=`Probe.bump_sample`（計數+ring-buffer≤N，env-gated off 零成本）。詳 `03b_measurer.md §④b`。與 §⑤（鎖定隊全量 trace）互補=每聚合自帶消歧樣本在源頭。

**enforcement（觀測盲點閘，憲法閘同精神）**：①新增 decision/resource/state 未接 tap → FAIL；②**新 tracer/probe 未 suppress global RNG（specimen=A/B/無 三跑非 byte-identical）→ FAIL**（RNG-中性檢查）；③**specimen 完整性**——runtime churn 床（`tracer_completeness_test`）斷言 timeline gap≤HEARTBEAT_CADENCE + commit-fail entry 現形 → FAIL 擋；static tripwire：生產側 `SpecimenTracer.capture*` call-site baseline（新決策 commit 點未伴隨 tap→計數失衡示警）。④**盲點閘（`observability_gate.gd`，merge 7a9640bf 已落地）**——靜態列舉事件產生點（try_set in decision/reaction winner/intent/state-transition）vs capture 覆蓋 + baseline freeze，新決策/commit-fail/reaction 路徑未 tap → FAIL（tap-gap 打地鼠系統性守衛，與 `constitution_gate.gd` 同級）。⑤**禁 Probe 污染**——tracer re-query 包 `_begin/_end_observe`（Probe.enabled=false+suppress_observe_noise），on/off 含 Probe byte-identical。**現況=不變量全立、③④⑤機械閘已落地（tracer_completeness_test + observability_gate + _begin/_end_observe）、①② RNG-中性檢查併入 observability_gate 掃**。state-transition(death/split/betray/found/capture) tap＝下批 backlog（known_issues）。

連 [[project_playable_priority]]（好戲=四關之首，聚合 metric 過≠好戲過）。

## ★執行失敗反饋鐵律（用戶立法 2026-08-21；憲法級）

**執行失敗 ＝ 事件，必反饋決策層，禁靜默丟棄。**
仲裁拒單／組隊失敗／資源不足／路不通 → **必須**回饋（失敗記憶 + 壓低該選項下輪分數，**或** T0 喚醒重想）。
★**同一原因禁無記憶反覆撞**。

### systems HOW 裁定（WHAT 只釘「禁靜默 + 禁無記憶重撞」，其餘我定）
1. **形狀統一走「連續折價」、不走「硬 cooldown」**。
   codebase 現有**兩個前例、形狀不同**：`join_rejected` + `JOIN_REJECT_COOLDOWN_TICKS=480`（**硬 cooldown**：到期前完全排除）vs §4c `site_failed` + `quality_multiplier`（**連續折價**：TTL 線性衰減、乘進既有 util）。
   ★**選後者**：硬 cooldown ＝ **絕對門檻 pre-empt 引擎** ＝ 補丁閘家族（憲法禁）；連續折價讓**引擎自己秤**（絕境時仍可壓過折價再試一次）——與本日生育修（硬懸崖→連續）同一方向。
   → `join_rejected` 的 cooldown 形狀**列為待統一項**（非本輪、但別再擴散第三種形狀）。
2. **失敗記憶放哪**：★**不放 leader `p.memory`**——那條 FIFO `MEMORY_MAX=20` 與人際記憶共用、**已知會被擠掉**（§4c eviction 監看項）。放**隊層** `recent_failures: {key → {tick, count}}`，`key = (option, target)`；**過期即 prune**（bounded，不無界成長）。**入 fingerprint**（它是直接因果態、會改變下輪 argmax）。
3. **哪些升 T0**：**「失效」升 T0、「劣勢」只折價**——
   - **T0 喚醒**（當前計畫已不可行）：路不通／目標消失／仲裁拒絕**已承諾**的任務。
   - **只折價**（該選項這次不划算，但計畫仍成立）：資源不足／組隊人手不夠／到場後沒貨。
4. **反射弧三段對齊**：**成功**半邊 ＝ §4c 結果反饋（`site_thrived`）；**失敗**半邊 ＝ 本律；**喚醒**半邊 ＝ T0 事件匯流排。三者共用同一組語彙（事件 → 記憶 → 下輪 util）。

### 落地順序（與現有工單接合）
- **第一份清單 ＝ convoy dispatch-drop 列舉**（`faction_ai:3977-4006` **7 個靜默 `return false`**）——本律使它從「找效能斷點」升級為**合規盤點**：★**每個 drop 點要嘛消滅、要嘛變成有反饋的失敗事件**，**不准原樣留著**。
- 其後：`order.abandoned`（94.4% 靜默到期）／JOIN／建設 try_set 失敗／trade market bail 各族，逐族納管。

## ★★★感知鐵律的**鏡像**：決策也不得【讀不到自己的狀態】（2026-08-25）

**既有鐵律**：★**決策只能吃 belief，不得 god-view 讀世界真值。** ★★**本條是它的另一端。**
| ★**god-view**（既有） | ★**blind-view**（本條） |
|---|---|
| **讀了不該讀的**（別人的真值） ⇒ 神目決策 | ★★**讀不到該讀的**（自己的糧倉） ⇒ ★**腦沒有眼睛** |
★**判準**：**同一支流程裡，「產出／檢查」與「投入／扣款」若讀【不同的池集】，那就是它。**
> ★血證兩例（`TradeValuation.reserve` 讀不到自家糧倉／製造投入只讀私產而產出讀兩池）→ `process/detail/invariants-cases.md`（同標題節）

## ★其餘不變量 → 索引（2026-08-25 #4：本檔只留【憲法級】）

**理由**：★**`invariants.md` 是「每 session 開頭讀一次」的檔** ⇒ ★★**它必須短到真的會被讀完。**
★**非憲法級的條目仍然有效，只是搬到按需讀的地方** —— **`docs/process/detail/invariants-cases.md`（同標題節）。**

| 條目 |
|---|
| World |
| Map |
| Time |
| Information |
| Simulation |
| ★★ 三條對稱不變量（統一架構骨架，believability 北極星，藍圖 2026-06-29） |
| ★ 意圖驅動完備（決策域，藍圖 2026-06-28） |
| 關鍵設計規則 |
| 對稱性 |
| 玩法節奏 |
| UI 邊界 |
| NPC |
| Interaction |
| Anon |
| Task |
| 財產 / 守恆 |
| ★ 統一搬運脊椎（後勤，用戶定 2026-08-01，enforce 起步） |
| ★ 統一勞力池（生產規模、用戶定 size-matter 2026-08-03，enforce 起步） |
| 飢餓 / 人口 |
| 資料模型不變量規則（防散落純量 drift） |
| team reference 契約 |
| Leader 繼承單一 owner |
| 關係圖（typed-edge） |
| 私人脫軌（血仇） |
| 訂單系統 |
| 隊目標單一 owner = leader 野心階梯 |
| 混合協調（faction stakes vs team 日常） |
| perf 優化 arc（用戶+blueprint 憲章 2026-08-18） |
| resource 分類學（農業a merge 落定、守恆稽核依此） |
| 決策 option 的「競爭範圍」與「承諾優先級」解耦（§4a、2026-08-20 systems 裁 + R² 護欄） |
| 死亡窗口（走屍隊）決策紀律（2026-08-20 systems 立、R² 繼承-lite 抓到具體 race 後升格） |
| LOD 降頻補償紀律（2026-08-20 立、LOD 紅線修實戰產出） |
| 長跑量測床的三條硬規（2026-08-20 立、大考實戰產出） |
| 承諾態只能經仲裁移轉：直接寫欄位 ＝ 承諾靜默消失（2026-08-21 立，convoy RETURN 實戰產出） |
| specimen 選樣必須「血緣封閉」：執行期生成的實體不得落在觀測範圍外（2026-08-21 立，convoy RETURN QA 判不了產出） |
| ★工作紀律八條 → 已搬家（2026-08-25 #4 doc 瘦身） |
| ★★★觀測器**禁任何副作用**（不只禁耗 RNG）——2026-08-25 擴充 |
| ★means-end / 前提解析的「無手段終止」不得靜默（2026-08-25） |

> ★**搬家不是廢止**：**每一條都在 `detail` 檔裡完整保留，原文在 `git log`。**
> ★★**要引用時查 `detail`；★開場只需要記得憲法級那幾條。**

## ★★★床必須接 `advance_tick` 的回傳值 —— **「有效窗」≠「請求窗」**（systems 立 2026-08-27）

★**規則**：**任何跑 tick 的床，必須接 `advance_tick` 回傳值，並印【首次非推進的 tick 與原因】。**
★★**沒有 game_over 也要印 `無`**（「沒印」與「沒接」長得一樣）；★★★**per-day／per-window 的分母必須是【有效窗】不是【請求窗】。**
> ★**血證／現況統計 → `detail/invariants-cases.md`（同標題節）**；★★交件欄位形狀見 `process/03b_measurer.md §BedSelfCheck`。

## ★★★T0 事件瞬醒：**任何突發即喚醒相關決策層**（用戶原則性裁定；S4b 落地 2026-08-28）
```
★單一真值:喚醒 = WorldEvents（emit / is_pending / consume_and_clear;封閉母體 all_kinds() = 30）
          排程 = CadenceStagger（★兩邊都別長第三個）
★★預設【全喚醒】,例外要【就地寫理由】——★★★白名單挑【要的】(漏了靜默失效),
   這個挑【不要的】並負舉證(漏了只是多醒一次)⇒ 沉默的預設落在安全那一邊
★新增決策支 ⇒ 必須在 cadence 閘【前】讀 is_pending;新增突發事件 ⇒ 必須進 WorldEvents
```
> ★現況／已具名例外（`LADDER` 重排不對稱）→ `process/detail/invariants-cases.md`（同標題節）＋ `known_issues.md`。

## ★★★守衛要掛在【一定會發生的事】上，不是掛在【有人來問】上（systems 立 2026-09-01）
血證（implementer 自揭，LOD 產出中性票）：假設告警第一版放在 `runs_per_day()` 裡 ——
跑對照時**registry 已經改壞，而告警照樣 0**，★**因為那一跑根本沒人呼叫估算器**。
> ★★**「只在有人問的時候才檢查」的守衛 ＝ 沒有守衛。**

★**判準**：守衛的觸發點要選【被動路徑】還是【主動路徑】——
★★**掛在「每 tick 都會走」的 dispatch 上（主動），不要掛在「有人查詢時才走」的估算器上（被動）。**
★★★**而它的失效是靜默的**：沒人問 ⇒ 沒有告警 ⇒ **看起來跟「一切正常」一模一樣。**
（同族：`known_issues` 的「床的 setup 盲區」、「紅著沒人讀的床」——**都是【觀測沒發生】而非【被觀測物沒問題】**。）

## ★★★儀器要自述盲區 —— 而「自述」的有效形式是【印在它的輸出上】（blueprint 立 2026-09-01；systems 加形式要求）
```
血證：state_fingerprint 【已經自述】排除 ephemeral 快取 ＋ cadence 排程欄（*_eval_next_tick）
      ★而那句話寫在【原始碼註解】裡
⇒ ★★於是有人（我）拿 fp 當「沒有污染」的證據，而它對那個 bug 類別【structurally 瞎眼】
```
★**所以「文件化」不夠** —— ★★**盲區必須出現在【使用它的當下】**：
> **凡輸出一個 fingerprint／比對結果的地方，同一段輸出要帶一行「本尺排除：…」。**

★★★**判準（R² 原句，已入 cases）**：
> **「拿一支【設計上就排除這個 bug 類別】的儀器，去驗這個 bug 類別」＝ 無效驗收。**
★檢查法：**用一支儀器前，先讀它自己的排除清單，再問「我要驗的東西在不在裡面」。**
