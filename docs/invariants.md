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
  - **arc 溶入進度（序1–序N 的 merged sha／seeded 數）／coverage 誠實限制／arc 期間 `pre-commit` 硬掛／後勤應用例** → `process/detail/invariants-cases.md` 同標題節。★搬走的是進度與細則，上面那條**契約**（current ⊆ baseline）就是規則本體。
- **零例外**：絕境=survival utility 在引擎內支配（非 override 繞過）；遠方=疏非慢非笨（引擎決策，非變笨）。此二處驗沒偷寫行為腳本。
- **稽核收斂主軸**：既有行為 subsystem/判斷器 → 溶進引擎（非特例）。連 [[project_unified_decision_framework]] / [[project_unification_matrix]] / 「架構已定別打補丁」。

### ★北極星：遭遇=統一反應（arc 收斂點，藍圖 encounter-north-star 2026-07-05，WHAT owner=game-design.md「★遭遇=統一反應」節）

憲法旗艦案例。**arc 各序溶 threat/solo/vendetta/prosperity… 的終點 = 五結局收斂進「一次遭遇的統一反應」**（非溶成五孤島）。遭遇 = 感知 → 引擎秤 → 挑一結局；threat/trade/diplomacy/vendetta/loot = **同一 encounter 評估的不同 option 輸出**（餵不同關係+軍力自然輸出，非寫死岔路）。剩下的溶朝此架，別各溶各成孤島。**序6-8 收斂主軸。**

**兩鐵律（納設計，約束所有溶）：**
1. **★感知鐵律**：威脅/身分感知**只吃可見表象（數量/逼近/可見武裝）+ 已知關係（盟友/宿敵）**；**禁吃對方 tag（商隊/軍隊/山賊）或真實意圖**（遠看分不出）。分不出照最壞繃緊（但「繃緊」可是「派斥候探底」非「恐慌」）。生湧現戲：虛驚/誤判釀仇。**enforce 點**：任何 threat/encounter 評估禁讀對方 `tags`/意圖做打折或岔路；只讀 belief 表象 + `known_reputations`。**repertoire 該有一格**：「陌生+不緊迫→派斥候/使者探底」（探而後戰，虛驚良性版），排入時機系統定。
> ★★★**細則 1a：belief 通過 ≠ 內容任取**（藍圖立 2026-09-02；★★systems 2026-09-02 補洞：**不限「閘後」**）——
> **belief 閘只授權「要不要評估這個對象」，不授權讀它的 live 值。**
> ⇒ **決策路徑上用到的【每一個他隊欄位】都必須是 belief 欄位**（位置走 `belief_pos`、強度走 `best_estimate`），**不是 `other.tile_pos` / `.population` 直讀**。★★**而 belief 有【欄位粒度】**：`has_belief`（有 claim ＝ 知道它存在）**不蘊含**有位置（`belief_pos` 另需 `tile_pos` 欄位且未過期）⇒ **「知道它存在但不知道它在哪」是合法的第三種結果，必須當狀態處理（棄該 target），★★★不得因此退回 live。** ★★**通則化（藍圖 2026-09-02「感知兩層」）**：**任一 belief 欄位都有三態——有值／過期／從未觀察到**；★**`unknown` 是誠實的第三態**，篩選時 **`unknown` 一律【不通過】**（★★**禁 default-pass、禁 fallback 到 live**）。★★★**而「未知」只屬於【讀取端】**：在**觀察發生的當下**（寫入端）你正看著它 ⇒ **`unknown` 不是合法輸出** —— 分類表沒有一格給它，叫做**分類表不完整**，不叫做未知（★血證：靜止的流亡團被投影成 `ACT_UNKNOWN`，使「unknown 不通過」照字面套會讓 invite 結構性死掉；★★真正的修法是補一格「觀察到、靜止」，不是放寬規則）。★★★**而哪些欄位【能】進 belief 由 WHAT 定**：外觀層（親見可得）可以；**組織/內心層（如隸屬母隊、打算做什麼）只能靠情報，不得因為「決策需要」就把它變成可見**。
> ★★★**「閘前」比「閘後」更嚴重，而初版規則漏了它**：閘後直讀是**分數算錯**；★**閘前直讀是【live 真值決定這個對象算不算候選】** ——
> **連「該不該知道它」都被真值決定了**（血證 `_find_occupy_target:6080`：live `tile_pos` 查 tile 判 `outpost_level`，發生在 `has_belief` 之前）。
> ★**最會漏的地方是被呼叫出去的小函式**：呼叫端那一行看起來乾淨，live 讀藏在裡面。血證與掃法 → `process/detail/invariants-cases.md`。

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

- **systems HOW 裁定（連續折價非硬 cooldown／失敗記憶放哪／哪些升 T0／反射弧三段）＋落地順序（convoy dispatch-drop 7 個靜默 `return false` 起）** → `process/detail/invariants-cases.md` 同標題節。★★WHAT 只釘上面那兩句（禁靜默 ＋ 禁無記憶重撞），**那兩句就是規則本體**。

## ★★★感知鐵律的**鏡像**：決策也不得【讀不到自己的狀態】（2026-08-25）

**既有鐵律**：★**決策只能吃 belief，不得 god-view 讀世界真值。** ★★**本條是它的另一端。**
| ★**god-view**（既有） | ★**blind-view**（本條） |
|---|---|
| **讀了不該讀的**（別人的真值） ⇒ 神目決策 | ★★**讀不到該讀的**（自己的糧倉） ⇒ ★**腦沒有眼睛** |
★**判準**：**同一支流程裡，「產出／檢查」與「投入／扣款」若讀【不同的池集】，那就是它。**
★★★**第三端（systems 裁 2026-10-01，implementer 把終端畫面印出來才看到）：【顯示】不受這條鐵律管，而它需要自己的執法點。** 玩家畫面上有一區逐字自稱「真值·debug（**非附身者所知**）」而它印 `tile_id`／格上真實資源／格上隊伍數 ⇒ ★**它自己說它不該被玩家看到，而玩家正在看它**。⇒ 感知鐵律管**決策**不管**顯示** ⇒ 它**不違憲**；★★而「玩家知道什麼」的邊界在畫面層**從來沒有執法點** —— 因為舊 GUI 把它藏在 `visible=false` 的 Label 與一個沒人截圖的視窗裡。⇒ ★★★而終端介面讓它**第一次可被機械檢查**：裁①**玩家走法不印那一區** ②它只活在一個**明確的 debug 走法**下（不是一個會悄悄預設錯的旗標）③自驗母體加一條「**玩家走法的輸出裡零 debug 識別字**」＋**負對照：debug 走法下它必須出現**（否則那個走法是死的）⇒ 細節在 `specs/2026-10-01-player-ui-is-a-terminal-repl-HOW.md`。
> ★血證兩例（`TradeValuation.reserve` 讀不到自家糧倉／製造投入只讀私產而產出讀兩池）→ `process/detail/invariants-cases.md`（同標題節）

## ★★可慢不可卡（用戶立法 2026-09-10，親測原話；憲法級）

> **「我能接受 5fps 甚至 1fps 的遊戲，但我不能接受用 60fps 跑到思考層後卡住 5～10 秒。」**

**判準（★兩個軸的優先序被【反轉】了，這是本條的全部內容）**：
```
★【畫面節奏均勻】＝ 硬要求   —— 凍 frame【不行】
★★【吞吐】       ＝ 軟要求   —— 掉 tick 率【可以】
```
⇒ ★★★**任何「一次做完一大批」的設計都要先問：它會不會凍住一個 frame。**
**而正確的形狀是【跨 frame 分攤】，不是【做得更快】** ——
★把一批 1000 隊的思考壓到 2 秒仍然是**凍 2 秒**；把它切成每 frame 50 隊**才是解**。

★**這條與既有的效能討論【不是同一件事】**：過去所有量測量的都是**總時**，
★★**而一個總時更短但有一次 5 秒尖峰的方案，在這條下【更差】。**
（★現況＝**未診斷**，嫌疑清單與診斷票 → `detail/invariants-cases.md` 同標題節）

## ★其餘不變量 → 索引（2026-08-25 #4：本檔只留【憲法級】）

**理由**：★**本檔是「每 session 開頭讀一次」的檔 ⇒ 它必須短到真的會被讀完**；★★非憲法級的條目**仍然有效**，只是搬到按需讀的 **`docs/process/detail/invariants-cases.md`（同標題節）**。

| 條目 |
|---|
| **域**（純標題，逐條全文在 detail 同標題節）：World ／ Map ／ Time ／ Information ／ Simulation ／ 關鍵設計規則 ／ 對稱性 ／ 玩法節奏 ／ UI 邊界 ／ NPC ／ Interaction ／ Anon ／ Task ／ 財產 / 守恆 ／ 飢餓 / 人口 ／ team reference 契約 ／ Leader 繼承單一 owner ／ 訂單系統 ／ 隊目標單一 owner = leader 野心階梯 |
| ★★ 三條對稱不變量（統一架構骨架，believability 北極星，藍圖 2026-06-29） |
| ★ 意圖驅動完備（決策域，藍圖 2026-06-28） |
| ★ 統一搬運脊椎（後勤，用戶定 2026-08-01，enforce 起步） |
| ★ 統一勞力池（生產規模、用戶定 size-matter 2026-08-03，enforce 起步） |
| 資料模型不變量規則（防散落純量 drift） |
| 關係圖（typed-edge） |
| 私人脫軌（血仇） |
| 混合協調（faction stakes vs team 日常） |
| perf 優化 arc（用戶+blueprint 憲章 2026-08-18） |
| resource 分類學（農業a merge 落定、守恆稽核依此） |
| 決策 option 的「競爭範圍」與「承諾優先級」解耦（§4a、2026-08-20 systems 裁 + R² 護欄） |
| 死亡窗口（走屍隊）決策紀律（2026-08-20 systems 立、R² 繼承-lite 抓到具體 race 後升格） |
| LOD 降頻補償紀律（2026-08-20 立、LOD 紅線修實戰產出） |
| 長跑量測床的三條硬規（2026-08-20 立、大考實戰產出） |
| 承諾態只能經仲裁移轉：直接寫欄位 ＝ 承諾靜默消失（2026-08-21 立，convoy RETURN 實戰產出） |
| specimen 選樣必須「血緣封閉」：執行期生成的實體不得落在觀測範圍外（2026-08-21 立，convoy RETURN QA 判不了產出） |
| ★★★觀測器**禁任何副作用**（不只禁耗 RNG）——2026-08-25 擴充；★**2026-09-10 再擴：查詢面不得交出【本體】**（回傳引用的 Dictionary/Array ⇒ 觀測者可以改被觀測物；血證 `get_decision_snapshot` 交出 `ctx_snapshot` 本體，而症狀是【對照變成跟自己比】）；★★★**2026-09-23 三擴：一支【被當成查詢用】的指令，它原本的副作用要在查詢版裡【走不到】**——血證：招募的「開選單」改走查詢面時，失敗路徑會 `erase(pending_targets)`（`player_command_system` 招募支）⇒ 查詢竟會清掉世界狀態；**修法是讓查詢版先擋掉那條路（檢查目標存在），不是把 erase 刪掉**（那個清理沒消失：隊伍死亡時 `world_state.gd:878` 本來就會做）。★**通則：把一支函式從【指令】重新分類成【查詢】時，要逐條路徑問「這條路上有沒有寫」，而不是只看成功路徑**——★★成功路徑純讀、失敗路徑寫，是這一族最常見的長相） |
| ★means-end / 前提解析的「無手段終止」不得靜默（2026-08-25） |

> ★**搬家不是廢止**：每一條都在 `detail` 檔裡完整保留、原文在 `git log`；★★**要引用時查 `detail`，開場只需要記得憲法級那幾條。**

## ★★★近期立的不變量（一條一行；★血證／為什麼一律在 `process/detail/invariants-cases.md` 同標題節）

> ★**一張表而不是 N 個標題**：N 個標題＝N 個入口＝開場讀不完 ⇒ 規則存在但不會被用到；★★**搬走的只有【為什麼】那一半，規則本文一行都沒少**——判事情讀這裡，要說服人去讀 cases。（★★★而新增一行就要**同檔省回一行** —— 2026-09-22 加第 7 條時 doc-cap 當場 601>600，這一行就是那時併的）

| # | 不變量（★這一行就是規則本體） | 立 |
|---|---|---|
| **1** | ★**任何跑 tick 的床，必須接 `advance_tick` 回傳值，並印【首次非推進的 tick 與原因】**；★★沒有 game_over 也要印 `無`（「沒印」與「沒接」長得一樣）；★★★**per-day／per-window 的分母必須是【有效窗】不是【請求窗】**。交件欄位形狀見 `process/03b_measurer.md §BedSelfCheck`。 | systems 2026-08-27 |
| **2** | ★**T0 事件瞬醒**：喚醒的單一真值＝`WorldEvents`（`emit`/`is_pending`/`consume_and_clear`，封閉母體 `all_kinds()`＝30），排程＝`CadenceStagger`（★兩邊都別長第三個）。★★**預設【全喚醒】，例外要就地寫理由**——★★★白名單挑【要的】漏了會靜默失效，這個挑【不要的】並負舉證，漏了只是多醒一次 ⇒ **沉默的預設落在安全那一邊**。★新增決策支 ⇒ 必須在 cadence 閘【前】讀 `is_pending`；新增突發事件 ⇒ 必須進 `WorldEvents`。（已具名例外：`LADDER` 重排不對稱，見 `known_issues.md`） | 用戶裁定；S4b 2026-08-28 |
| **3** | ★**守衛要掛在【一定會發生的事】上，不是掛在【有人來問】上** ——「只在有人問的時候才檢查」的守衛＝沒有守衛。★★掛在「每 tick 都會走」的 dispatch（主動），不要掛在「有人查詢時才走」的估算器（被動）。★★★**它的失效是靜默的**：沒人問 ⇒ 沒告警 ⇒ 跟「一切正常」一模一樣。 | systems 2026-09-01 |
| **4** | ★**儀器要自述盲區，而「自述」的有效形式是【印在它的輸出上】** ——文件化不夠，盲區必須出現在【使用它的當下】：**凡輸出 fingerprint／比對結果的地方，同一段輸出要帶一行「本尺排除：…」**。★★判準：**拿一支【設計上就排除這個 bug 類別】的儀器去驗這個 bug 類別＝無效驗收**；用一支儀器前先讀它自己的排除清單。 | blueprint＋systems 2026-09-01 |
| **6** | ★**回傳【決定】的介面，必須能同時回傳【依據】（同一次計算的孿生視圖），不得讓下游事後重算** —— ★★重算不只是貴：它常常**會寫 state**（`gather`）⇒ **觀測改變被觀測物**；★★★而**依據在算決定的那一刻本來就在手上**，丟掉它的是 **`return` 那一行**。★血證三件（同日）：`rank_survival` 算過 `u` 而 return 只留 `opt`／`task_reason` 存了【誰設的】沒存【值多少】／deny 那一刻想重算現任 util。★★**修法形狀＝孿生視圖**（同一次計算兩種回傳，舊 caller 形狀不變），**不是新增一條計算路徑**。 | systems 2026-09-16 |
| **5** | ★**文件引用 tick 常數時寫【時長】不寫【tick 數】**：寫「＝2 天，值見 code」，★**不寫 tick 字面數**。★★理由與「估算器禁手抄物理」同源——**改接線不是改數值**；把 480 更新成 2880，下一次換根它會再爛一次。 | systems 2026-09-01 |
| **7** | ★**記帳可以閘，語意不可以** —— 量測旗標（`Probe.enabled`，**預設 false**）後面只能掛 tap；**任何 production 語意（快取清空／代號遞增／狀態轉移）一行都不得依附它**。★★而危險不在「有人故意」，在**照樣造句**：`decision_context.gd:503／1444` 的 `if Probe.enabled: _in_gather = …` 就站在 `gather()` 的 entry／exit 旁邊，複製貼上抄錯一個字就是同一種病。★★★**而它會被整張驗收表一起掩護**：要讀 tap 的驗收格結構上只能跑在 Probe 開之下 ⇒ 語意在測試時發生、在 production 不發生 ⇒ **全綠，而 bug 只在玩家跑法發作**。⇒ **修法不是再寫一句規矩，是讓【至少一格驗收跑在 `Probe.enabled = false`】**（指紋床零 Probe 參照 ⇒ 天生可以）。★這一條是既有「觀測者禁耗 global RNG／禁污染 Probe」的**鏡像**：那條管【觀測者不得影響被觀測物】，這條管【被觀測物不得依賴觀測開關】。 | systems 2026-09-22（R² 兩輪找到，血證見 `progress.md` 同日） |
| **8** | ★**「只動相位、不動頻率」不等於行為中立** —— 兩個機制競爭同一批目標時，**改變先後順序就改變結果**。★★★而**「頻率」這個詞必須拆成兩欄**：**計數**（每週期恰好一次，構造保證，after/before ＝ **1.0000**）與**間距**（**最長間隔 ≈ 2×cadence**，而純加法恆為 c）——**只守計數會全綠，而尾巴已翻倍**。★★所以**任何宣稱「零新旋鈕、只換賦值方式」的 slice，驗收不得只守【頻率】，必須守【母體與結果】**（存活數、生滅計數）。★★★血證 2026-09-22（★**純函式床，無世界、無母體污染**）：10 處 cadence 改走錯開後，每週期評估次數 min=max=1（不變），而兩次之間的距離 c=4320 時 **max=8596 ≈ 1.99c**（純加法恆為 c），>c 佔 64.9%。★★**撤回早先引用的「存活隊數同向掉 11–21」**——那個欄位是 `state.teams.size()`，**把野獸 pseudo-team 算進來**（`team_data.gd:179 beast_kind`）⇒ 它不是【隊】的數字。★配套讀法：**多種子方向相反 ＝ 洗牌；方向相同 ＝ 訊號** （★★別拿「世界重新洗牌」當整份卷面的解釋）。 | systems 2026-09-22（implementer 逐日軌跡坐實） |　★★★**推論（2026-09-23 血證）：錯開的【單位】必須等於系統的【粒度】** ——`faction_ai` 是勢力粒度，而按【隊】錯開讓它在「批次裡有任一成員」時就把**整個勢力**的活做一遍（`faction_ai_system.gd:1218 _faction_due` 任一成員即 true ／ `:1267-1275` 整個勢力的成員快照＋goals＋tasks）⇒ 一個 M 人勢力每小時被做 ~M 次 ⇒ **那不是「慢」，是同一件事被做了 M 次＝行為改變**。★判準句（reviewer 2026-09-23 精確化）：**看【寫到哪裡】不是看【讀了什麼】** ——這次呼叫的**寫入目標**是呼叫者自己（安全，誰觸發都一樣）還是**被迭代到的那一群共用的狀態**（危險，觸發時機決定那群被驅動幾次）；★掃描群體資料當【輸入】是安全的（`_best_relocate_target` 掃全世界格子但只寫回自己那一隊）。★★而抓到它的是一支**今天恆真、專為將來某個改動而留的回歸柵欄**（`faction-drive-once`，expect `per_hour_max=1`）⇒ **回歸柵欄與陽性對照的區分，在這裡第一次真的兌現**。
| **9** | ★**`state.teams` 裡住著三種東西，任何對它的量測必須聲明它指哪一種** —— **真隊**｜**野獸 pseudo-team**（`team_data.gd:179 beast_kind != ""`）｜**在外子隊**（`:404 parent_team_id != -1`）。★★**它們在 `state.teams.size()` 裡長得一模一樣** ⇒ 「存活隊數」這個詞沒有主詞就是錯的。★★★血證 2026-09-22 **同一天三次**：①用 `teams.size()` 當存活隊數 ⇒ 消失端 92.9% 其實是野獸；②「新生／死亡兩端同時變多」——**方向對、主詞錯**，真身是子隊派出／歸建；③零殘差分解後：末隊數 −21 而 **真滅團 2→0（死得更少）**。★**所以「世界有沒有變糟」要看 `extinct`／`starve`／`combat`，不是看 `teams.size()`。** | systems 2026-09-22（implementer 零殘差分解坐實） |
| **10** | ★**一個按鍵的意義，不得由一個【會在同一顆 tick 內改變的計數】決定** —— 索引式選單（`num < fe_count` 後接 self-actions）在計數歸零的那一瞬間改了全部數字鍵的意義，而**玩家的手指還在同一個鍵上**。★★因此【強制事件回應】與【自家隊動作】**不得共用同一段數字區間**；★★★而「吃掉那一次按鍵」是 debounce 補丁（下一次索引改變還會撞），「回應完離開互動模式」只修這一條路。★血証 2026-09-30：面板消失後再按同一個 `KEY_1` 實測執行了 `establish_faction`（建國）＋`train`（扣 30 coin）。★★而它很可能就是用戶第二輪「能一直按 1 產很多待辦」的另一面：那些「待辦」不是重複的回應，是一串不相干的動作。 ★★★【推論，systems 2026-10-01 裁，血證重放】**判別子必須是【玩家自己改變的狀態】，不能是【世界改變的狀態】** —— 目標聚焦是玩家按的（可當判別子）；強制事件面板的出現／消失是世界決定的（**不可**：鍵會在玩家手指下換意思而他什麼都沒做）⇒ **強制回應的鍵空間必須被它獨佔**（現況＝字母 A..Z）⇒ ★動作鍵不得用字母。★而「一個鍵永遠是同一個動作」這個真正要的性質**與字母無關** ⇒ 用靜態綁 id 的數字表拿到。★★拒絕「字母在聚焦時＝動作鍵」的算式：玩家在面板上按 A 回應 → 面板消失 → 再按一次 A ⇒ 變成動作⇒ **同一個病、同一個手勢，只是鍵換了一種**。★★★★【位置偏移版，systems 2026-10-01 裁，implementer 實測坐實】**兩個母體不得靠「位置偏移」共用同一段數字鍵**（血證：`text_ui_main.gd:1814` `pending_idx = num − self_acts.size()`）—— ★自家隊動作從「只列可做的」改成「常駐全列 11 列」之後，那個偏移**從『會漂』變成『擠爆』**（`num − 11` 對 `num=0..8` 全為負 ⇒ 目標清單用數字鍵按不到）⇒ ★★**同一個算式的兩種病**：不是新壞掉，是舊違反換了形狀 ⇒ 所以修法是**刪掉偏移**不是調偏移。⇒ ★★★三條推論：①兩個母體**各自獨佔** 1..9 **且各自獨佔頁計數**（今天 `_interact_page` 一個計數被兩張清單共用，:1858／:1911）②切換兩者的**必須是玩家按的鍵**（本條推論逐字授權：目標聚焦是玩家按的 ⇒ 可當判別子）③鍵不夠用時用**翻頁**（`,` `.` 已是交易／倉庫／互動三處的既有語彙，:1870／:1917 已經在印「第 N/M 頁」）**不得用字母**（字母被強制回應獨佔）。★而「11 選 9 的短缺」在獨佔鍵空間＋翻頁之下**不需要存在**。 | systems 2026-09-30（implementer 實測坐實） |
