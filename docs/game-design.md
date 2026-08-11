# 核心概念

## 相關文件
- [README](../README.md)
- [人物](person.md)
- [團體](team.md)
- [世界](world.md)
- [事件](event.md)
- [訊息](message.md)


本作是一款以：

- 資訊傳播
- 社會互動
- 生存壓力
- 不完整認知
- 勢力演化

為核心的 Roguelike / RPG / 社會模擬遊戲。

遊戲不是傳統「玩家探索世界」的設計。

而是：

> 「玩家作為世界中的一個人，在混亂社會中理解世界、獲取資訊、建立關係並生存。」

靈感來源：

- Dwarf Fortress
- Unreal World
- Cataclysm: Dark Days Ahead
- Mount & Blade
- Kenshi

但核心差異在於：

> 「資訊並不透明。」

## 規則分類索引

- [人物](person.md)：實體 NPC、需求、情緒、忠誠、記憶
- [訊息](message.md)：訊息如何產生、傳播、失真、被接收
- [事件](event.md)：事件如何從狀態與人物反應生成
- [世界](world.md)：資源、消耗、時間、勢力演化

---

# 世界觀

# 世界狀態

世界處於：

- 長期戰亂
- 地方割據
- 聚落間缺乏穩定聯繫
- 傳播與交通困難

因此：

- 地方文化差異巨大
- 資訊極度碎裂
- 謠言影響力很高
- 人們對外界認知有限

玩家不是救世主。

玩家只是：

- 流民
- 冒險者
- 士兵
- 商人
- 村民
- 幫派成員

中的一人。

---

# 世界不以玩家為中心

即使玩家死亡：

- 世界仍會繼續
- 聚落仍會發展
- 戰爭仍會進行
- NPC 仍會記得過去事件
- 勢力仍會興衰

玩家死後可選擇其他 NPC 繼續遊玩。

因此：

> 遊戲真正的主角是世界本身。

## 沙盒品質 bar（「夠好門檻」）

世界**沒有玩家也要好玩**。當個純沙盒跑，它必須**自己會說故事**：勢力興衰、野心者崛起、背叛、欺敵、結盟、征服與覆滅——觀者看得下去。

這是所有 believability 工作的**尺**：判任一機制/平衡是否「夠好」=
> **「沙盒自己跑（無玩家），故事生不生得出來、看不看得下去？」**

推論：
- 龜縮世界（全員防衛、無野心征服者、野心階梯頂端從不上演）= **fail this bar**（不可信 + 無聊），即使技術無 bug。
- **反面校正（2026-07-05）**：**雪球／一統 ≠ fail**。單一勢力吞全圖是「容易的一章」非結局，合「軍事易得，正統難守，傳承更難」——後續動盪由**正統／繼承爭位／叛亂／過度擴張崩解／天命失**製造（4/5/6/7 維度），**不靠壓征服率防壟斷**。**唯一真 fail 是「凍死」（啥都不發生、無起落）**，非「某方贏太多」。健康 bar = **有動有起落**，不論收斂到幾個勢力。
- **★規模分布校正（2026-08-01，用戶定）：活的世界要「有大有小」——健康的權力規模分布（少數大勢力＋一些中的＋很多小的）且會流動（小長成大、大衰落分裂、弱被強吞）。** 這是「有動有起落」的規模維度。**反面 fail-mode（實測 2026-08-01 發現）：世界退化成「全塌均一小團」**（6mo warring 實測 avg 4.88→2.9 人/隊、133 隊全 ~3 人、無大團浮現）＝**碎片化 fail**——只出不進（子隊派遣/紮營高頻生小團）、只碎不併（整併機制在但湧現無效、長不出大的）。**「有大有小的活分布」是 bar，「全均一小」跟「凍死」一樣是 fail。**（勢力規模動態/兼併有效性 = backlog arc；先量真因再開藥，見 handback 2026-08-01。）
  - **真根定案（CASE B，2026-08-02 量測）**：world model **不獎勵 size、甚至反獎勵**（軍力 linear、生產 sublinear+capped、抗風險 proportional、領土 pop-cap+split）→ 碎片化是「正確」湧現、整併低 util 是引擎**正確**估算。「有大有小」**無 genuine-value 基礎** → 要有大有小**須先讓 size 真 matter**（加真規模好處、非 crank）。用戶選定分**兩軸**：**大隊＝領導表現**（個人）、**大勢力＝集團表現**（組織）。
  - **★製造樞紐湧現（active arc，2026-08-03，spec LOCKED R① CLEAN）**：§8 定案「單大隊採掘非強權（大隊=軍事/集團=採掘）」→ 但單大隊可當**製造/貿易樞紐**=第二種生產強權（進口原料→大量加工→出口）。**核心=湧現非 script**：補齊 genuine 決策輸入 → 引擎自秤「進料→加工→出口」→ 樞紐在該長處自動長。audit 揭機器大半已在（製造已讀 demand / 出口運貨鏈 / 買料路 / coin 自籌）→ **三缺口**：(A) 大出口需求源（genuine 真需求非憑空灌）/(B) 取料商隊（遠方買料運回）/(3) 拆 GATE-B local-only 撮合牆（全經濟老瓶頸、拆它全域受惠）。地基（勞力池/de-patch/B/甲）KEEP。dispatch systems 做 HOW，驗 = **量樞紐有沒有湧現**（沒湧現=調輸入非 script）。spec `2026-08-03-manufacturing-hub-emergence`。
  - **維度一·生產（mechanism MERGED `506aaa64`，size 真 matter 待 §8 真世界驗，2026-08-03）**：**統一勞力池**——勞力變有限稀缺資源，採集+製造共吃一池，need 加權比例分配。size 從此 = **蓋更多/更高階設施的資本投入**（非堆人頭）；大隊靠領導 pop-cap、集團靠共址+多據點+物流。spec `2026-08-03-unified-labor-production-scale`。**mechanism 落地 + unit 7/7 綠**（含 size-matter Σfill 3.0>1.15 + 供給鏈多級傳播 + determinism + R² anti-crank CLEAN）。**★但「size 真 matter」= goal，未達成前不宣稱**——待 measurer §8 **真世界驗**（live sim 大隊 vs 等總人數碎小團誰總產多，同 SLICE A「measured 才宣稱」精神）；§8 綠才對用戶驗收此維。**經濟同時是軍事集中的反制錨**（集中大軍餵不飽）。契約:need-gated full-stop（need=0→0 無 floor）+ size 靠 facility breadth。
  - **維度二·軍力（backlog，排生產落地量完後）**：真根＝**combat 是唯一漏掉 time-scale wave 的系統**（戰鬥 5–10 tick vs 行軍 48 tick/格 → 反應式增援必遲到）。arc＝①combat 上 wave（round cadence 吃 elapsed、**NPC 結算戰與玩家遭遇戰 world-tick 一致**、拉長 → 反應式互援復活；本身亦獨立 coherence 修）②**互援**（共址/相鄰同 faction 隊開戰即併戰 → defeat-in-detail 湧現、集中＝bloc、分散被各個擊破）。`leadership_mult`/`tactics_mult` 已在（大隊領導 edge 部分已實現）。**守**：集中不得壓垮既有絕境逃膽量秤（否則集中＝團滅加速、反彈殲滅-heavy 老病）。序在生產後（避免兩大 arc 同撞 systems、且經濟錨先立）。
  - **候選 arc·軍民混编 / 民兵動員（2026-08-03 用戶定，待 B MVP 後、待 audit-first）**：軍民比**由團型分級**（非齊一混、非二元）——**專業軍團**（騎士團/貴族兵）=純軍拒屯兵、不算勞力；**後備/開墾團**=屯兵·半兵半農=部分勞力；**居民團**=**民兵制**（主力勞力 + 小武裝比，防禦才召）。機制=**團型設 `armed` 能力**（取代 faction_ai 自由設 `armed_anon_ratio`）；**平時民兵算勞力（農夫種田）**；**威脅→民兵動員抽離勞力池去打仗→產出掉（guns-vs-butter 真戰爭成本）**；和平解甲回田。涵蓋 systems 查出的三缺口（militarize/pop→軍 ABSENT、established 團 spread gated、recruit 非決策）。**★統一非補丁鐵律**：動手前**先 audit 現有散落機制**（`armed_anon_ratio`/`TAG_MILITARY`/`TAG_PRODUCE`/`TASK_TRAIN`/`equip_order`/belief→「全動員」/紮營 gate）→ **統一它們進一個模型**，禁再加平行補丁（同 [[統一矩陣]] / 整系統優先）。
    - **★audit 結論（2026-08-03，用戶怕點坐實）**：現況**三個各自為政的 pop-fraction 旋鈕**——`armed_anon_ratio`（武裝比，**由武器庫存**推 `equipment_system:62-73`）、`guard_ratio`（守衛比，威脅+tag 設 `faction_ai:2168-2180`，只影響夜哨/休息）、`captive_guard_ratio`（俘虜守衛比，自有決策 fn）——**三個不同 owner、不同規則、互不通**；加上**勞力池 `pool_of` 是二元 by-tag**（PRODUCE 全算/軍隊全不算，**無法表達民兵分數抽離**）。**arc 的真面目 = 把這些收斂成「一個團型驅動的 mobilizable 分數,威脅時把人力在勞力池↔戰力間搬」。** 約 **30% 統一現有 + 70% 新做**。建於 primitives（`armed_anon_ratio` 數值+戰鬥消費端 / `pool_of` / `AnonCohort` 守恆容器 / `TAG_*` 但需二元→光譜）；**折入** scattered（`equipment_system` 庫存推比、`equip_order`、`guard_ratio`、`captive_guard_ratio`、4 處分歧 tag-assign）；**新做**（mobilization 決策 pop→軍、team_type→ratio 表、belief→全動員、勞力池分數化 membership）。

> **★★統一派遣模型 arc（B、用戶拍 2026-08-11）：dispatch=記名領隊+匿名跟班+return-cycle 歸隊、一套統一模型套所有派遣（信使/斥候/賑濟/建造/移民）。給領隊→succession 安全網不誤觸→機械升格 bug 結構性消除；匿名→named 湧現保留（領隊死→接班/跟班不爽→脫隊=genuine）。序：measure-first 摸現況（列全 dispatch 點+anon 處理+哪些機械升格，硬數據非 inference、anon 錯 4 次教訓）→spec→R①/R²→build（F0 fingerprint 驗）→★re-measure 下游（此漏光疑為 relief/care/builder 派不出真根之一、修後 re-measure 不預設）。連 [[project_anon_cohort_refactor]] 2c-2。**
## 📍 當前路線圖總覽（2026-08-03，blueprint owner）
> **★scale-econ 量測線 CLOSED（2026-08-11、measure-first 教科書:5+層 artifact 逐層剝、每層 premature 前接住）：①survival 層 size 不 matter（iii 鎖、確定：confound 清後核心村兩擺法都活、attrition 差全是 overflow-spinoff 邊緣噪）②production 層『集中有無 genuine 生產優勢』答不了 = broken production pipeline（設施建不出→製造不 fire、demand 注入不解、更深斷在 facility-builder dispatch）= size-matter arc production 本體 territory、非乾淨 scale-lever ③**anon drain 真源 = 領主 deliberate scout + MECHANICAL succession-promotion（2026-08-11 QA+measurer 一致定案、Probe key scout.dispatched 4 筆 100% 對上，硬數據 supersede 前 3 版 inference-based 錯歸因）**：Team0 為唯一 faction leader 反覆 deliberate 派 scout 偵察（`_try_scout_side:2067`→`dispatch_anon_messenger`、genuine 主動偵察、state-aware 非盲派 day4 池空即停）；★但 scout messenger=leaderless anon→succession 安全網（`faction_ai:784` if leader_id==-1）**無 subteam/phantom guard**→機械升 named（`person_generator:103`）→永不歸隊 anon 池=**monotonic drain MECHANICAL bug**（非湧現、非兵變、非 overflow）。★★用戶 target model 正中：dispatch 該=名帶匿+歸隊循環；code 兩 gap=①leaderless anon-alone ②succession 機械升 named。用戶「派匿名→升記名」假設**命中**、emergent-vs-mechanical 判準把此歸為 bug。修候選：succession 加 phantom-messenger guard+recall 歸隊 anon / dispatch 改名帶匿 crew（用戶 target）。連 [[project_anon_cohort_refactor]] 2c-2。**★serial over-claim ×4（overflow→succession→unrest-split→scout+mechanical、用戶 measure-first 仲裁連續抓對）**。原 ③**anon drain 真源 FINAL = genuine unrest-split 兵變**：Team0 unrest≥30+低忠誠異見 named 幹部目標衝突→帶 anon 追隨者自立門戶（`event_unrest_split:102`、QA 9-caller 唯一匹配、非 overflow 非 succession 非 dispatch-promotion=我+用戶假設皆非）=Team4/5/6。**有動機的世界故事、非 bug**。下游 relief/care/builder dispatch 綁 anon-specific 池（`AnonTierSystem.total_pop` code-read 坐實）→池空派不出。★★systems『anon-overflow central bug 根』整條 framing 錯（第 3 次 over-claim、用戶 measure-first 仲裁連續抓對=[[feedback_resource_depletion_genuine_vs_blind]] 血證）。★待用戶裁平衡（非 bug）：(1)兵變太快？（day0-4 unrest 為何已≥30）(2)兵變後 41 天派不出=想要的難度 vs 太狠。★另 gap（獨立於此 drain）：用戶 target model『dispatch=名帶匿+歸隊循環』vs code『dispatch_anon_messenger leader_id=-1 anon-alone』=真 gap、可另修。原 ③**anon narrative REFUTED 二次**：measurer 加 check_overflow tap 重跑坐實 Team0 pop 全程 max 6 << cap 20、**從未 overflow**→「自動分村抽 anon」歸因整個錯、`_create_overflow_team` 從沒對 Team0 觸發、Team4/5/6 真起源未查出。∴「anon-overflow central 根擋 relief/manufacturing/builder」整條 narrative 建在未 double-check 因果上、**suspect**。真源 measurer 重查 caller 函式:line 中。★★用戶邏輯 catch（「都是分村→總人口該在 cap→池空矛盾」）二次戳破 over-claim=measure-first 仲裁。原 ③**anon-tightness=設計/平衡**（待真源定）：指標團 trace 決定性——領主 blind-dispatch=0（全程 state-aware）、drain 全 automatic（村壯大送殖民 + anon→named 晉升、非亂派）、2 spinoff 事後 merge 回（named workforce 回流、「不回補」部分誤導）。∴ 池空 = genuine 弱勢後果（小領主/小村人手本就緊、同時做不了照護+建設）非機械 bug；可能反支持「size 該 matter」（大領主才有餘裕建製造）。**用戶懷疑對、我+systems『central 根 bug』over-claim 已訂正**。是否調 = 待用戶 vision。scale-econ 不是獨立 arc、是 size-matter 命題的入口。**
> **★★① scale-economy 挖成 relief-death gate-chain（6層 whack-a-mole:scale→propagation→vpos→anon-pool→overflow-spinoff深結構）→ iii-pivot（用戶拍 A 2026-08-11）：絕境排序 arc——餓死隊現況『餓→直接叛離→factionless→救援不可達→死』；修=讓求援(低成本可逆)與叛離(劇烈不可逆)util反映真實期望值(可逆性/後果)、順序自然湧現(非腳本階梯)；餓叛≠野心叛由隊狀態湧現、不刪絕境-defection(雙向反crank)、factionless不可救保留。一根解(通info-net①natural+cohesion①natural+scale乾淨量)+服務③故事合理。scale lever 待 relief-death 解後 re-measure。care-loop de-patch 89af4837=merge banked-correct dormant待anon-cohort 2c-2。**
> **★下階段序（用戶定 2026-08-07）：① 規模經濟力（讓樞紐/集中自然湧現、genuine 非 crank）→ ② 军民混编/民兵動員 → ③ 驗證長期故事邏輯合理（活世界長跑敘事 coherence、非單機制測、連 believability 種子床）。** 框架收尾 C 路線結構批已收（②operational），Track②A（決策核抽引擎）= incremental backlog。
> `docs/roadmap.md` 已 stale（2026-06-15 UI 時代、未回填整個 economy/統一/size-matter 程序）→ 本節為 live 前瞻視圖；細節 arc 記憶見 memory `project_*`。
- **傘：統一決策框架 / 統一矩陣**——NPC 行為全走 genuine utility DecisionEngine（憲法溶解 done）。禁 scripted gate / crank。
- **★復甦路徑 arc = CLOSED/MERGED（2026-08-06）**：三動詞全收——R1 移民 `53907687`＋R2 投資 `71415ea6`＋R3 遷村令 `73b2a943`，共讀 `MarginalEconomy`、**terrain 三態湧現零查表**（禁地型腳本命門守住）。R3 領主令用領主自己視角（清一個 god-view 後門=不讀村戀土）+ 村自願遷（讀自己戀土）+ 兩層從抗人格秤（傲村抗命/忠村從帶怨）。= cohesion ①natural 深根（村經濟可持續）解、charity→自己站起來三動詞全備。誠實限（記著、非阻塞）：三 slice 一致 measurement-tooling fixture gap → clean organic 敘事 demo = narrative-polish follow-up（fixture-fix 已診斷 = holding-ledger resident/is_resident_static radius）。連 [[project_recovery_path_arc]]。
- **★框架收尾兩硬綠 = C 路線結構批收（2026-08-07）**：①硬綠 **F1 死常數人格化 done**（DESPERATION entry + MINING_GREED soft weight）+ ②硬綠 **F2 treasury/F3 subteam-messenger/F4 統一註冊表**（三刀、全 F0 fp byte-identical、`1cd5cfbf`）= **擴充性 operational**（加東西=動一「註冊」處 machine-verified f4_test）。★誠實非 premature：**full no-god-object 未達**（faction_ai 決策核 ~5248 行、新行為與決策核互動仍碰 faction_ai）= **Track②A（26 決策 func 抽引擎、fp 變 intended、per-slice blueprint 裁）= incremental backlog**（用戶 C 路線=收結構→回玩法→Track②A 漸進、不宣稱 done）。F0 安全網 program 全程雙用途生效（①intended 分化 / ②byte-identical）。連 [[project_unification_matrix]]（Track②A=統一決策框架 arc 延續）。
- **★★玩家鏡頭/可讀性 = 全專案最弱環（用戶 2026-08-07 戳、未來 arc 候選）**：功能=世界自主行為、玩家=situated 參與者/鏡頭（非 65 系統操作員、錨=世界本活著）。玩家碰=一角色/隊 scoped 動作（player_*_api 已框:移動/行動/交易/談判/回應/裝備/派子隊）、深系統當劇情+後果體驗。★未做兩塊：①可讀性（玩家看懂 NPC 為何/發生啥、史書/敘事可見 parked note）②動作呈現;UI stale（2026-06 UI 時代未維護）。刻意「先有好沙盒」但功能越堆缺口越顯 → 候選未來 arc「玩家鏡頭/可讀性」。——用戶問架構耦合（faction_ai 5018 行/引用 35 系統/62 系統共讀 WorldState）引出，裁「行為統一 + 結構模組化 兩個都要完成」。★完成標準=用戶早定的**兩硬綠**（本 doc §大戰略校準 l.358）：**①零殘留非框架閘**（殲滅 god-view 後門/死常數/隱藏硬閘 §殲滅清單 A + **強化 `constitution_gate.gd` 抓全閘型跑綠＝機器證非人肉**）**②可擴充**（加新系統乾淨、擴充性稽核證）。★兩線撞同一象＝`faction_ai_system`（5018 行）：**序＝先行為（抽該進引擎的邏輯出來→自然瘦一大圈）再結構（剩下切有邊界模組＋定乾淨對接介面）**，反序＝兩次白工。誠實：大工程/動核心有風險/過程零新玩法→**故必在 arc 邊界整段做、不與半成品 arc 對撞**（用戶拍 A＝復甦先收）。結構模組化同時服務「對接別人程式」（API 層 `player_*_api`/`observer_query_api` 已鋪 Dictionary DTO 半座橋，缺序列化+進程邊界）。連 [[project_unification_matrix]]（行為線）+ [[project_framework_seams]]（結構線/所有權圖）。spec/brainstorm 待復甦收後於 arc 邊界啟。
- **★活躍前線：有大有小 / size-matter arc**（真根 CASE B：model 不獎勵 size → 加真規模好處、兩軸 大隊=領導 / 大勢力=集團）：
  - **維度① 生產（統一勞力池）**：mechanism MERGED `506aaa64` ✓、組織軸 works（ratio~1）✓；**領導軸 → B MVP（idle-labor→建設 genuine）在飛 systems** → §8 重量領導軸 ratio 追平（誠實 measured 才宣稱）。
  - **維度② 軍力**：backlog——combat 上 time-scale wave（NPC 結算戰 / 玩家遭遇戰 tick 一致）+ 反應式互援；排生產驗收後。
  - **军民混编 / 民兵動員**：candidate——統一 3 個散落 pop-fraction 旋鈕 + 團型軍民比 + 威脅動員（guns-vs-butter）；audit done；排 B MVP 後。
- **支援 / 已完**：後勤 SLICE A（供給移動 flow）merged+用戶 accepted；持守統一 released；時間統一 wave slice A merged。
- **★遷移找糧 affinity semantic gap（F4 eval 揭、2026-08-07、future behavior slice）**：`遷移找糧` ∈ SURVIVAL_OPTION_SET 卻 affinity=uniform（疑該 survival-heavy 如覓食 0.9）= 語意 gap;F4 統一註冊**保 uniform（byte-identical）**、proper affinity = 另 behavior slice（fp 變 intended、候選併入漸進 Track②A 或玩法 arc 順修）。同類:AFFINITY 現漏列 24 中 2 REGISTRY-only opt 亦 uniform（F4 保序、proper 值另 slice）。
- **遞延 backlog**：material/伐木供給側、established chain、遭遇戰收斂（舊 P6）、perf O(N²) scaling、**L3 隔格循環貿易**（商人巡市集讀外板+跑商路；**★guardrail 用戶定 2026-08-05：禁寫死巡邏路線——「去某市集看看」=資訊價值(板子多舊+套利期望) vs 路程成本的引擎決策，人格加權（重商勤跑/膽小近跑），巡迴=湧現 pattern 非 waypoint 清單**；同 scout「資訊值不值得收集」家族）、economy-balance（救濟量級/timing、系統性餓死底線）。
  - **信使損耗模型（已定，資訊網 arc）**：信使死**不通知**寄件方（死訊瞬回=god-view）——寄件方只知「派了、沒回音」，**沉默本身是資訊**；再派=湧現（需求仍在→mini-util 續 fire→人格秤再派，實測 T1 連派 8 信使）；每信使=真抽 1 人力（信使一直死=村失血=真悲劇螺旋）；進階候選：預期回程逾時→belief 推斷凶多吉少（非 god-view）。
  - **★失聯感知＝通例（用戶定 2026-08-05，資訊網 follow-up、排現 arc 收完後）**：**所有派出單位共用一個系統**（信使/斥候/商隊/賑濟隊/子隊/開墾隊…）——母隊記**預期回報時間**（依距離/任務估）；逾時→belief 標「失聯」→**進思考層人格反應**（務實再派·派查/多疑防備/重情派救/冷酷註銷；領主對遠方村莊久無音訊=同系統）。零 god-view（全建於「自己派過誰+過了多久」的自我記憶推理）。「派信使查」決策=此系統反應端、信使逾時推斷=其一 case——統一成**一張預期聯絡帳本**、非各處特例。
- **infra**：Telegram 雙向 bridge（遠端驅動 blueprint）done（`reference_telegram_bridge`）。
- **★資訊網核心 arc = CLOSED/ACCEPTED（2026-08-05，用戶裁 A、QA CONFIRM-with-revisions）**：**bank（機制全真）**＝letter-carrier 物理信使／side-action 家族（herald·scout·distribute，人格 mini-util）／act-on-belief（de-scan×2 移 god-view 殘留）／賑濟＝免費 gift／同格交易＋看板 relay（商業 +72% 多床）／人格分化真湧現（務實 8 vs 傲 0）／T1 fixture 全鏈救活／T3 真故事（defect 叛離孤死）。**誠實限制（QA 強制）**＝relief 鏈僅 fixture 證、一般 49 隊經濟 distribute 仍 0（禁 resolved 字樣）；T1 回升＝間歇投糧非穩定復甦；cascade=PLAUSIBLE；anomaly 因果未 story-audited。**→ 資訊網補完批（下一批）**：①relief 通用化（settled faction bed 診斷 general distribute=0 根）＋economy-balance（救濟量級/timing/餓死底線）②L3 循環貿易（guardrail 已定：路線＝湧現非 waypoint）③失聯帳本（預期聯絡通例）④小項（seed-cascade 因果補／DEFECT_HONOR_THRESHOLD 死常數人格化照妖鏡／scout 人格 demo／anomaly story-audit 補檔）。
- **★doc 待辦**：`roadmap.md`（死化石）待 systems reconcile/archive（指向本節 + memory `project_*` 為 living 來源）。

## 🗂️ 未來願景 brainstorm 索引（parked，findability 用，2026-08-03 補）
> `docs/notes/2026-07-19-*` = 10 篇**刻意 parked 的未來 arc 停車筆記**（「不碰 canonical」的有意設計：腦力激盪→停車→成熟才升 canonical）。本索引**只解 findability**（原本只 1 篇被 link、其餘孤兒=同 roadmap 失聯病），**非**強行 canonize。七維度/五底線的 placeholder 詳設計在對應 note：
- **身份/王朝/正統/聯姻/繼承/性別**（七維度 #4/#5/#6）→ `notes/2026-07-19-identity-dynasty-legitimacy-brainstorm.md`（血脈→聯姻→繼承→正統→宗教 同一串 + 天命 belief 侵蝕 + 單一繼位爭）。
- **天災（物質×信念雙打）**（七維度 #7）→ `notes/2026-07-19-natural-disaster-brainstorm.md`（毀糧 + 蝕天命雙效）。
- **敘事可見/史書**（五底線 敘事可見）→ `notes/2026-07-19-narrative-legibility-chronicle-brainstorm.md`（A 觀者真史 essential-first / B 世界內偏史）。
- **情報操控·造謠 + 資訊戰四動詞**（情報系統）→ `notes/2026-07-19-active-rumor-fabrication-brainstorm.md` + `notes/2026-07-19-info-warfare-verbs-brainstorm.md`（憑空捏造 + NPC 主動 偵察/反情報/販賣情報，資訊=可爭奪資源非只被動傳播/扭曲）。
- **決策模型 v2 深化 + 長程計畫**（§決策模型 v2）→ `notes/2026-07-19-decision-model-v2-deepening-brainstorm.md`（③內政/慾望泛化/④情緒）+ `notes/2026-07-19-long-range-planning-brainstorm.md`（means-end 承諾深化）。
- **正面羈絆 + 人物成長弧**（★新維度、七維度未含）→ `notes/2026-07-19-bonds-and-character-arcs-brainstorm.md`（正面羈絆=背叛的賭注重量 / 人會變成長弧 / 個人效忠 vs 忠於位·派系——**與現「人格固定 by design」有張力，升 canonical 前須調和**）。
- **經濟階級**（★新視角、game-design 未名）→ `notes/2026-07-19-economic-class-brainstorm.md`（相對剝奪於財富兩鉤，窮 member 怨囤財頭人→叛，大半湧現）。
- **技術/知識（技術≠技能 + 知識即資訊）**（§未來加技術 placeholder l.241 深化）→ `notes/2026-07-19-technology-knowledge-brainstorm.md`（技術=能做啥·配方上限·可傳可失 / 技能=做多好 / 知識=不均分佈的資訊，接核心「資訊不透明」命題）。
- **memory-only vision 項**（非 note、但屬願景）：NPC 個別傷亡追蹤（[[project_future_improvements]]，team-pop 粒度→記名個體）；未成年長大/coming-of-age（[[project_population_fixes]]，生命週期 #6 機制）；PersonGenerator（匿名升格記名/天賦人物）。
- 玩家錨 C（資訊不對稱崛起）= 進入「本就活著的世界」的**鏡頭/參與者**，**非世界存在的理由**。先有好沙盒，玩家才是好鏡頭。
- 量測導向：believability 不靠單元測達標，靠「活世界自己跑出該有的戲」（戰國 seed 類驗證床）。

## ★ 沙盒憲法：作者寫世界，不寫決策（不得限制 NPC 行為邏輯）

這是**模擬沙盒**——NPC 行為是**湧現的，不是腳本的**。這是專案定義級約束，凌駕所有系統。

> **我們給：世界（狀態／手段／代價／感知）+ 統一決策引擎（utility weigh，人格調製）。
> 我們不給：行為規則。NPC 行為 = 引擎的輸出，永遠不是輸入。**

**分辨線（別誤砍世界規則）**：
- ✅ **世界規則**（該有，是物理）：食物會耗盡、山難走、遠征累、被打會傷、遠方情報不確定。= 定義「手段空間＋代價」，是 NPC 決策的**素材**。
- ❌ **行為規則**（禁，是腳本）：`if 食物<X then 塞乾糧`、`if 被威脅 then 撤退`、判斷器、行為 subsystem。= **替 NPC 決定**，剝奪湧現。
- 判準：你在描述「**世界怎麼運作**」還是「**NPC 該怎麼選**」？前者=作者的活，後者=引擎的活。

**推論**：
- 遇到「X 不足／受威脅怎麼辦」→ **先問「這是引擎的子需求＋手段嗎」，別建 X-subsystem**。後勤=感知糧況＋手段（塞乾糧／買／搶／覓食）＋引擎權衡，AI 自理；不是「補給機制」。
- 這是所有反覆痛點的**同一條根**：「為何還有沒統一的東西」「又多個判斷器」「別打補丁」= 全是「有人寫了替 NPC 決定的行為規則」的個案。根講死 → 未來個案自動判違規。
- **零例外**：絕境求生=survival utility 量級支配（引擎內），非硬 override；遠方 NPC=算得疏（**疏非慢非笨**），照樣引擎決策，非變笨。全走引擎，無行為腳本例外。
- 讓「距離／匱乏／威脅」有戲，靠**世界代價**（時間暴露、疲勞、資訊霧）+ AI 自己權衡，非替它寫反應。

## ★ 決策模型：感知 → 腦 → 行為（統一的秤，定 2026-07-06）

引擎 = **唯一的秤**：每個 agent、每 tick（照 LOD cadence）把當下所有選項秤 utility → argmax。**無特殊中斷／gate／margin／模式切換。**

**★核心：感知 → 反應必經「這隻的腦」，絕不容全域規則或常數繞過。**

```
客觀世界
   │ ① 技能過濾（理解力；低技能→看糊/誤判，接資訊迷霧系統）
   ▼
我的感知（可能是錯的）
   │ ② 進「腦」的秤——三腳一起：
   │     人格 = 怎麼權衡（懶/貪/謹慎/勇 → 抬壓各選項權重）
   │     記憶 = 經驗染色價值（那隊仇/那谷險/那人不可信）
   │     現況能力 = 做不做得到、代價多重（人力/戰力/資源/健康；capability-grounding 即此腳）
   ▼
這個人眼中的 utility → argmax
   ▼
行為（主觀）
```

- **同一感知、不同腦 → 不同行為**：懶+謹慎的隊放掉送到嘴邊的弱敵（繼續生產）＝性格，非 bug。這是**模擬器 vs 腳本遊戲的分界**。
- **技能雙重身份**：既是現況資源（軍略高→打得好），也是感知品質（軍略低→連形勢都看錯）。
- **行為門檻的歸宿**：只有兩處——**世界代價**（seed／世界接地）或**人格／記憶／現況**（逐 agent）。**沒有一個塑造行為的門檻該是全域常數活下來。**
- **★altitude**：此為**模型／方向**定義，**非機制 spec**。各腳怎麼算、哪些常數何時溶＝系統＋實測，逐步收（方向硬、機制軟，分開定）。

### ★ 決策模型 v2：慾望生成 → 現實調和 → 承諾 → 內部政治（與用戶成形 2026-07-14）

> v1（上）定「感知→腦→行為、引擎=唯一的秤」的**骨架**，但把「慾望」當人格驅動的既有物。v2 **深化「慾望」與「現實」到底是什麼**，並補上**承諾（長期）**與**內部政治（③）**。同 altitude：**模型／方向，非機制 spec**；各項怎麼算＝系統＋實測。血證見本次 session（Team14 thrash 餓死）。**驗收尺＝故事性判官**（QA 第五職，`04_qa.md`；motive→action→outcome 鏈完整）。

**一句話**：懂價值 = **動態看清現實、守得住慾望、跨線才重估、等現實開窗才動**。Team14 缺整條 → 抖死。

#### ★ RNG 判準 3 案 + 有機世界性格（與用戶成形 2026-07-17）
決策路徑上的 RNG 分三案（constitution_gate triage 用）：
1. **純骰替決策（無人格）** → **de-patch**（骰替思考＝壞;交人格/情境 util）。
2. **世界不確定 outcome RNG** → **legit**（訊息到不到、隨機事件、event-ID、遭遇誰＝非決策,世界的隨機）。
3. **人格加權機率決策** → **legit-IF-陡 + framework-routed + seeded**：性格/情境主宰**清楚案例**（推兩端，真忠 2% 背叛/真奸 95%），**骰只斷真難分的中間**。平骰（性格不影響機率）＝太運氣 → **陡化（tuning）非 de-patch**。
- **★世界性格定調（用戶定 2026-07-17）：有機非鐘錶。** 性格是**傾向（機率）**、擲骰實現,但**曲線陡**→清楚案例註定（結果掙來的,不太運氣）、天人交戰的才不可測（有機戲）。同性格隊多數一致、只有卡界線的才分歧＝變化不靠銅板靠性格+處境+真兩難。roguelike 本色（DF/Kenshi/M&B）。seeded → determinism/byte-identical 測試不破。

**1. 慾望不是人格，是「感知 × 比較」比出來的落差**
- 人格**不是**慾望本身，是**比較用的尺**（我在意哪種落差）。慾望是關係性的：**看見+比較才生慾望**。看不到富鄰居（感知，走 belief）→ 再貪也不生「要那筆財」的慾望。
- `慾望 = 人格尺 ×（感知到的 possible ── 自身現狀）的落差`。
- **參照錨＝復合**（人格定各項權重）：`錨 = w1·內在抱負(人格線) + w2·鄰比(感知鄰居有什麼＝相對剝奪) + w3·過去自己(曾達峰值＝失落/復仇)`。高野心→w1 重（對著夢比，永不滿足）；高貪婪→w2 重（要別人有的）；創傷/高義氣→w3 重（復原失去的）。
- **已有雛形＝層5 食物安全**（`DecisionTerms.food_security_target` 讀人格定目標、`SECURITY_STOCK_DRIVE` gap→drive）。v2 = **把「人格定錨、感知現狀、gap 驅動」從食物泛化到所有慾望（財富/權力/地盤/安全）**，且錨從純內在改吃外部感知（鄰比）。**非新架構，是層5 模式泛化。** 去風險：先做 內在+鄰比（最戲），過四關再加 過去自己。

**2. 現實動態 gate 慾望，決策 = 慾望穿過動態現實濾鏡**
- **現實值是動態的**：依 belief 的資源+威脅**每次重估**。同一慾望（征服），此刻是自殺 or 良機隨狀態變。引擎已有影子（`迎戰.ownutil` 負＝打仗自虧、`winutil` 高＝能贏才值）。
- 決策 = 慾望 × 現實可行性。**現實破地板（餓/危）→ pre-empt 慾望**（Maslow 式：承諾/野心活在求生地板之上）。

**3. 換道 = 跨線觸發（抗抖）+ 人格黏性（悲劇英雄）**
- **動態現實正是 thrash 的成因**：若每 tick 微抖就重算 winner → 抖死（Team14：想買糧抖 122 次餓死）。解 = **換道只在「跨線」觸發**（求生線 飽/餓/垂死、威脅線 安全/被盯/被攻、機會線 可打/不可打、資源線 買得起/不起），**不為雜訊改道**。
- **換道阻力＝人格黏性**：固執/高野心 撐著不換（跨了求生線也不放征服＝**悲劇英雄**）、善變 一有風吹草動就改。→ 同機制自動長出 理性求生者／悲劇英雄／（消滅）thrash。
- thrash = **慾望與現實結構上沒分層**（同池 per-tick argmax）的病；修 = 結構拆開 + 跨線才中斷。

**4. 承諾（長期投資）= 慾望層的多-tick 目標**
- 長期工作（蓋據點：長時間、大延遲回報）現在**幾乎不估**（計畫層 S2 已退役→五層急迫度 per-tick argmax，無時間折現、無累積投資記憶）→ 跟 thrash 同結構：蓋一半被急迫打斷、永遠蓋不完。
- 補兩塊：**延遲價值折現**（看得到據點未來收益流，折現率人格化：慎重/野心耐性↔貪婪短視）決定「值不值開工」；**承諾**（開工後抗打斷、sunk-cost 墊高放棄門檻）決定「守得住」。
- **承諾擋雜訊、不擋危機**：糧掉 0.3（沒跨線）→ 守著蓋；刀子砍來/餓垂死（跨線）→ 求生 pre-empt 承諾，放下鏟子。「別棄坑」不會變「拿鏟子被砍死」，因跨線危機本就 pre-empt 一切承諾。守多少＝人格黏性（狂熱隊撐過線＝另一版悲劇英雄）。

**5. ③ 內部政治：單一決策者 + 人格閘納諫 + 對稱牙**
- **團慾望 = 老大一人拍板**（非議會、非成員 values 平均——平均會殺死老大人格）。但**老大人格決定「要不要納諫」**：
  - **納諫 ≠ 混合價值**，是**決策層加「異議成本」項**：違背成員 values 的選項加一筆凝聚成本 = Σ成員在這件事的價值落差；`選項效用 = 老大原始慾望 − 異議成本 × 納諫傾向`。老大**價值不變**（高殘忍還是想殺俘），只是**選擇性壓抑**。納諫傾向 derive 自 義氣（高→聽）/野心（高→獨斷）。**只掛價值決策**（殺/放俘、背盟、屠民、險戰），不掛雜活。
- **對稱牙（兩邊都有代價，沒有免費午餐）**：
  - **成員憋（老大無視）** → 不滿累積 → **exile（出走另立）/ split（分團）/ coup（活人政變，老大降 member 不死）**。統領/魅力/忠誠分流哪種。**強挑戰者→coup 下台救團；無挑戰者→帶忠誠核心衝到團滅（船長同沉）**。
  - **老大憋（過度納諫）** → `leader.stress` 累積（**現在是死路變數：累積但無後果，已 code 確認**）→ v2 給第一個出口：**snap**（stress 壓垮納諫傾向 → 爆發做被壓抑的慾望，表面隨人格＝好戰→開戰/殘忍→屠殺/貪婪→劫掠，「轉嫁外侵」＝好戰老大 snap 的長相非獨立機制）。snap **成功→stress 洩掉（宣洩）**；**失敗→再加 stress→魯莽螺旋→終結於團滅 or coup**（非無限循環）。**砍掉自我退位/解散**（太極端；終局從外面來）。
- **★de-patch 註記**：現有 `event_unrest_replace`（coup）/`event_unrest_split`/exile **是早期 scripted-event 補釘**（死常數觸發 `unrest_turns>=20`、argmax 統領挑人、跟引擎脫節），**違背「引擎=唯一的秤、決策必經這隻的腦」**。③ 正解 = **內部政治做成 member 層引擎決策**（野心成員：慾望[奪權] × 現實[老大弱?我有班底?打得贏?] → 決定政變，走同一套引擎），**crude events 退役**（併決策不統一 arc 撕除清單），非重觸發舊事件。前老大降 member 活著 = 額外故事種子（反撲/清算/釋懷，下台不掌權→stress 或洩或不甘，人格定）。

**6. 附加維度（長在①感知上，較省）**
- **④ 瞬時情緒**：fear/stress/panic（`person_data` + `PANIC_WEIGHT`，序7 起步）= 慾望與現實間的**瞬時調節器**（區別穩定人格 求生欲 vs 瞬時 fear）。高恐懼→放大威脅感知（現實看更兇）+ 壓縮慾望，冷靜後衰減回基線。戲：突襲驚慌、血勇上頭、創傷殘留。
- **⑤ 淺預判**：大不可逆決策（攻擊）估價時加**一層淺預判**對方反應（用①感知算「他反擊/搬救兵嗎」）折進 winutil。**不做深博弈樹**（perf+防遞迴）。多數湧現（別隊也跑同模型）。

**建構順序（增量，每步過四關，設計磨與實作並行）**：①感知（大致在，補位置 god-view + 新模型現實輸入全走 belief）為地基 → thrash-fix（承諾/執行鎖，最爛最獨立，第一刀）→ 慾望生成泛化（層5→全域）→ ③ 內部政治（含 de-patch）→ ②慢漂 / ④⑤ 後疊。**不用「整個模型磨完才動」——一刀一刀過四關+故事QA。**

**★觀察先於設計（用戶定 2026-07-14）**：reactions/breeding 在 all-far 從沒跑過（`reaction.*` 全 0）→ **live 世界真樣未知，靜態設計看不出湧現問題（如 thrash：紙上合理、跑 trace 才現形）**。∴ **thrash-fix merge 後，下一刀＝開 full-HD live 世界（gen 重校，反應/生育首次活）+ 觀察湧現**，非繼續紙上磨 ②③④。**觀察到的真問題才是 ②③④ 的設計輸入**——「跑起來、看結果、對真問題開藥」（[[feedback_avoid_rabbithole]]）。②③④ 設計降級成「觀察後才做」。

**★慾望配現實＝求生選項必須 look-before-leap（血證 2026-07-14，thrash-fix 誤診挖出）**：原「thrash-fix」誤診＝治症（決策抖動 recognizer）。QA 交易 tap 挖出真根：**買糧被選中但從不出貨**（coin=0＋餓世界無食物賣方＋資產不流通＋隊空間受困），`買糧` applicable 只驗 `has_food_market+has_specie`（有貨≠換得到糧）＝**選了海市蜃樓**。垂死隊 winner 標「買糧」死守無糧市集＝**慾望不配現實的系統級版**（連 Team18 孤隊 31 天買糧 death-limbo 同根）。**修＝A+B+C（決策模型 v2 §現實 gate 慾望 的求生層落地）**：
- **A 求生選項 look-before-leap**：applicable 驗「真做得到」（買糧＝有 coin+可達賣方 或 可達 barter 對象要我的貨；鏡射 Fix4 給覓食的 gate）→ 做不到就別當慾望目標，fall through 到可 fulfill 選項。
- **B 絕境遷移找糧**：當地求生選項全不可 fulfill → **移動去找糧**（最近野味/糧市/賣方）。**這是「奮力求生」核心**——困死選項＝坐著等死（否決）；奮力＝離開死市集找活路。絕境階梯：覓食→**遷移找糧**→乞食→掠奪→併入。
- **C 連貫窮死**：真四方無糧才餓死（合法悲劇），但 **winner 必連貫**（拼命找糧四處落空 trace，非死守海市蜃樓）。
- **D（defer 經濟 arc）**：餓世界食物不流通（無賣方）＝買糧本就該罕見；「要不要做食物市場供給」併 full-HD live 觀察 slice（先看糧怎麼流再決定），本修不解。
- **★★餓世界大 pattern：「靠別人給」的求生路全是幻覺（血證 2026-07-15 逐一驗，中性世界坐實）**：買糧（無賣方）、乞食（無施捨者，但有 mercy 完成路＝非幻覺、只是情報門檻嚴到從不選＝死 rung）、投靠併入（無收留者，`_absorber_accepts` feed_ok≈0 恆拒、full-or-nothing 無漸進；中性世界 3 trace 累計 0 成功）——**根同：餓世界資源不流通，別人給不出**。相對「自己弄」的（覓食/遷移/掠奪）真能「動作生效」，**但掠奪有資源錯配陷阱**：掠奪成功搶到的是 material 不是 food（`material 13.6→20.2` 而 `food→0`）→ 對餓死的隊「動作成功卻救不了命」＝**掠奪該紓飢/搶糧（下個真根，一修解殘留 thrash＋餓死）**。∴ 餓世界真正可靠的自助只有覓食/遷移找糧。∴ coherence 修＝全「靠別人給」選項加 look-before-leap（不守幻覺→改自助）。但這揭示**餓世界絕境本質是孤立的**（各自互拒、孤獨餓死）。
  - **★抱團模型（用戶願景，經濟 arc 設計項，personality-gated 可選非強制）**：現行併入＝**收留模型**（承平邏輯 host 餵得起才收養）→ 餓世界全互拒＝難民孤立。用戶要**抱團模型**：兩絕境隊**共赴生死、湊資源**（湊人覓食/共享糧/湊人數佔村建據點），不問誰養誰。是絕境階梯一個**可選 rung，人格 gate 兩端**（求生欲/謙卑→求投靠；義氣/communal→願收；高野心/驕傲→獨撐或稱王）＝同絕境不同選擇＝性格。「難民真的會聚」的正面答案，讓絕境不只孤立。與 D（食物流通）同根，一起在 observe/經濟 arc 設計。**本 coherence 修先止血（收留 look-before-leap），抱團＝後續 arc。**
- **執行鎖（原 thrash-fix 機制）廢**：治錯層（真根修好→買糧不選海市蜃樓→thrash 自然消）。觀測 infra（交易/威脅 tap）cherry-pick 進 main。

**★俘虜處置＝完整人格化道德選擇（用戶定 2026-07-15，連 ③ 殺俘）**：`decide_treatment`（`manpower_system`）現只 厚待(→同化/收編)/苛待(→暴動逃)，人格驅動（殘忍高→苛待）＝已滿足願景（穿人格秤非硬寫）。**擴為完整道德選項集**（各人格驅動）：
- **殺俘/處決**：殘忍高→屠；殘忍低→受降。**帶 ③ 凝聚成本**（殺俘違背低殘忍成員 values→不滿→③ 內部政治的牙；殘忍領袖照殺→道德成員 defect→團激進化）＝這才讓「③ 殺俘那齣戲」真成立（現行只有「苛待→跑掉」無「主動殺」）。
- **贖金**：貪婪高→勒贖換錢（俘虜原勢力付得起才成，走 belief）。**釋放**：義氣/慈悲（低殘忍+低貪婪）→放走→名聲升。**厚待→同化 / 苛待→暴動逃**：現有保留。
- ＝同一批俘虜，殘忍/貪婪/義氣不同領袖處置全然不同＝性格湧現的道德戲。**slice 排 backlog（非急）**。
- **★域專判斷器邊界原則（用戶定通則）**：獨立 scorer（decide_treatment、reaction named 9-scorer 等）**不必強塞 DecisionEngine rank**，只要 ①穿人格/記憶/現況（非硬寫繞過）②讀跟主引擎同組人格值（角色一致）。統一 arc 敵人＝硬寫/繞過 dispatch，非人格化 scorer；C 類 judge 退役針對硬寫 judge。（invariants owner=systems 收此條。）

### ★ 綜合發展模型：糧食地基 + 人格化多維發展（與用戶成形 2026-07-15）

**「富足」不能只看糧食（太薄）——糧食是生存地基（門檻），之上看綜合發展。** 現行 rung 階梯（`ambition_ladder`）只讀 糧盈餘+人口+勢力規模＝薄；我曾判「吃得飽=富」更薄。修為多維。

- **發展維度（目前 3 條＝現有系統只做這三個）**：**經濟 / 軍事 / 建設**（≈現有 商業/武力/定居 archetype）。**★不硬寫 3——接口留擴充**（未來加 技術/領土… = 加一項，非重寫）。
- **★★用統一框架式做（用戶定 2026-07-15，接同一 arc 哲學）**：發展維度該像**決策一樣統一**——**一個統一「維度 registry」，每維由人格秤**（野心/貪婪→經濟、好戰→軍事、慎重→建設），隊追人格加權最高維。**加新維度＝registry 加 entry + 人格映射，不是各寫死一個系統。** 同 DecisionEngine option 一套、同 [[域專判斷器邊界原則]] 精神（穿人格秤非硬寫）。
- **量測欄位（怎麼合成）**：**資源 / 錢 / 據點 / 人力**（4 個 measurables）——糧食＝門檻（沒糧免談），之上這 4 維體現發展度。
- **★人格化多路（核心）**：**隊按人格走不同發展路**——**商隊追財（經濟：資源/錢）、軍閥追武（軍事：人力/戰力）、工匠追建設（據點/基建）**。同樣「食安之後」，不同人格追不同維度＝**多元文明類型的戲**（非單一「爬同一階梯」）。
- **★★archetype = 湧現描述非硬類別（用戶重申 2026-07-23，憲法執行）**：商隊/軍閥/工匠**不是硬需求、不是被分到的盒子**——核心是**依人格自由發展、不設限**。archetype 是「一個人格驅動的隊最後長成什麼樣」的**事後描述**，非「你屬這類只能做這類」的規定。**∴ 人格 WEIGH 行為傾向、不 GATE 可用選項**——和平領袖掠奪 utility 趨近 0（幾乎不做，但情境夠 compelling 仍可、可被 utility 翻盤），非一道硬牆。差異化強度隨你調權重，但**不准變硬類別**。**★決策上任何硬 persona-gate（如 `AmbitionLadder` 擴張限 FORCE archetype、militancy 硬門檻、`persona>常數` OR-閘）= 補丁 = 違憲**（沙盒憲法「utility 餵 utility 非 scripted」的反面），一律 de-patch 成 soft 權重，**無 coherence 例外**（「這閘 personality-appropriate」是 rationalization，硬閘就是硬閘）。**邊界**：結構約束（outpost-type/terrain 限制）≠ 人格閘——那是**世界物理**（決策上物理能不能），留；憲法管的是**決策邏輯**（隊怎麼選），那裡不准 scripted 硬閘。結構稽核 = 憲法合規掃描（抓 scripted 決策閘，`constitution_gate.gd` 抓 scripted task 指派的姊妹）。
- **發展度驅動**：rung 爬升 / prosperity-prey 判（誰值得征服＝誰發展高）/ AI 食安後追什麼（人格定）。
- **★連經濟通縮**：財富（錢）是發展一維，但發現 **coin 通縮排乾**（薪水 sink>賣貨 source，交易池乾涸）→ 經濟這維目前是**壞的**。∴ **經濟通縮修 + 發展模型多維化＝同一「經濟/發展 arc」**（coin census 找錢在哪＝第一塊實據）。世界現況＝「吃得飽的求生部落爬薄階梯」，目標＝「人格化發展的多元文明」。

#### 貿易死因診斷：真根＝兩結構牆（成交條件 + merchant 不成對），修向＝流動偏摩擦市場（與用戶成形 2026-07-15）
市場 deals≈0 挖到底,商隊「想做生意 404 次 → 成交 ~2 筆」。歷五層假設,measure/trace 逐一坐實**皆非 binding**,真根＝兩道結構牆:

| 假設 | measure/trace | 判 |
|---|---|---|
| supply seam（可見性）| deals~0 | 非 binding |
| merchant-target churn | target 穩定（28000tick 僅切6次）| 推翻 |
| threat-preempt（半路跑）| 真 preempt 僅 ~6 起,FLEE 是缺糧非 threat | 推翻 |
| accessor 結構（local_value）| absorb 修 +114% 但 <3% | 真債但非 binding |
| coin 私囊鎖（no_coin 91%）| **解禁 coin→全落 other_bail,WOULD_TRADE 恆零** | **紅鯡魚**（no_coin 是 co-loc bail 表面標記,非真兇）|

- **★★真根＝兩道結構牆（reconcile 坐實）**：
  1. **成交條件牆（最刺眼）**：雙方都想交易（WOULD_TRADE）**560 次卻只成 3 筆**（0.5%）。price/surplus/qty 三門檻疊乘,willing 夥伴幾乎永遠過不了。**是普世閘**（擋 resident + merchant 所有路）。
  2. **merchant 從不 co-locate**：100% 成交買方是 resident,**0 個 merchant**——商隊 travel 到訂單位卻從不跟賣方成對（arb 路死）。
- **★★修向＝流動偏摩擦市場（用戶定 2026-07-15）**：
  - **底線＝流動**：雙方都想交易 → **多數該成**。現 0.5% 不是「真實摩擦」,是**死常數幾乎不對齊＝壞**（照妖鏡）。
  - **質感＝摩擦**：交易不免費——價差談判 / 餘量謹慎 / 運力成本 讓**一部分** willing 夥伴談不攏,且**真實有意義**（真的價不對/運不划算），非全體卡死。
  - **摩擦掛人格**：急著交易/絕境的鬆手（接受薄利）、貪婪/謹慎的收緊（守價、留餘量）→ 談不成＝**性格與情境的戲**,非一道誰都過不了的死門檻。
  - 一句：**willing 夥伴大多能成交,談不攏是少數且有理由（人格/情境）,非常態。** 成交率/門檻數字系統 tune（HOW）。
#### ★★方法翻轉：整個商業模型一次進框架，再量測（用戶定 2026-07-15）
**放棄 hole-by-hole（coin→co-loc→成交牆→A/B 逐洞補）。** 用戶裁：**先把整個商業框架做好、所有補釘融入,再跑量測。**
- **理由（用戶）**：只融一點 → 後面又在抓「哪個補丁擋住」＝一路在打的地鼠。**補釘互相 confound 量測——全拆光才量得到乾淨模型。**
- **與 measure-first 相容（非重蹈 accessor <3% 白工）**：那些是**還沒找到根就猜的大重構**;此處是**已知模型是補釘拼湊（靜態稽核坐實 file:line）,拆光補釘讓量測乾淨** → 量統一模型出不出 deals → 再磨。量測仍 gate 結果（統一模型 revive 市場否）,只是工作單位＝整個模型非單洞。
- **商業框架覆蓋圖（靜態稽核，該全收進框架）**：
  | 環節 | 現況 | 目標 |
  |---|---|---|
  | 要不要貿易 | ✅ DecisionEngine 秤、人格化 | 保持 |
  | 去哪/跟誰(target) | ❌ `_merchant_trade_target` if/else 引擎外（`_market_pos` 撲空 bug 住這）| 進框架 |
  | 成交執行 | ❌ `_attempt_trade_direction`/`best_arbitrage_order` 硬碼 | 進框架 |
  | 掛單層 | ❌ `order_system` 人格全盲、~13 死常數、引擎外 | 進框架 + 人格化 |
  | 撮合 | ❌ 雙 resolver 沒收斂 | 收斂單一 |
  | 庫存讀取 | ❌ 5 散讀縫、無統一 accessor | 統一 accessor |
- **商業模型骨幹＝B 市場即地方（用戶定，非 A 追人）**：貨在 outpost/市場 `public_storage`,買方來買 stock（免賣方在場）＝真實市場、穩、可規模化、複用 WS-2b infra。A（追漫遊賣方）＝補釘思維且脆,棄。
  - **保留「遭遇＝統一反應」旗艦**：遭遇貿易（兩隊荒野撞見機會性以物易物）留作**風味**（罕見）;**市場貿易（B）＝經濟骨幹**（可規模化）。經濟撐不起 7-10 次隨機遭遇,要市場才有商業。兩者並存。
  - 未來可長：市場/貿易樞紐當地理特徵、樞紐間貿易路線（合 [[綜合發展模型]]、接口留）。
- **「磨」（統一模型跑出 deals 後）**：流動偏摩擦成交條件（willing 夥伴大多成交,摩擦＝價差/餘量/運力少數且有理由,掛人格）、掛單層人格化細節、coin 循環 A+B（私囊鎖 named person.coin 61-63% 大池 + 稅回收）、threat 韌性（真 preempt ~6 起＝非急）。**皆先有（統一模型 revive）後磨。**
- **HOW 全交系統**：統一商業框架怎麼架（target/execution/order 層怎麼進引擎、resolver 怎麼收斂、accessor 怎麼統一、B market resolver）＝系統 HOW;藍圖只定「整個模型進框架 + B 市場即地方 + 全程人格化 + 無殘留補釘」。

#### ★★進度 + 牆移子系統：貿易機制通,市場死在供給（2026-07-16）
統一商業框架 build 後量測:**貿易機制證明對（`deal_merchant` 史上首次非零 + 守恆 + de-patch cleanup 對）+ coin 大勝（`buy_no_coin -99.9%`,雙向流）。**
- **coin 從「磨」升「先有」（確認）**：coin 是 deals 前提非事後精修（no_coin -99.9% 才讓機制真跑）。
- **★但市場仍未 revive,牆移子系統**：deals 仍 ~1-2。新主牆＝`sell_no_surplus 51.7%`（訪客到市場**沒貨賣**）。**貿易水管全通了,但沒水可灌——producer 產不出可賣 surplus。** binding 從「貿易子系統」（已解）移到「生產/經濟實質子系統」（sell_no_surplus）。這正是最初的問題「誰生產可賣 surplus」＝整條經濟最深牆。
- **merge 決定（用戶定 2026-07-16）**：merge 貿易 foundation+coin（機制+coin 通,誠實標供給待）——**revise「revive 才 merge」,理由 blocker 移到不同子系統,避正確大 refactor 爛 branch drift**。過 reviewer R② + probe 語意核（新 order_id 路可觀測）才 merge。
- **供給牆 patch-gate-first（決定 2 前置）**：先查 `sell_no_surplus` 是 **gate 擋賣單**（`SURVIVAL 無單不賣` / 餘量門檻太高 → 有貨不掛賣單 → de-patch）**還是真沒 surplus**（生產求生型無餘糧）。
- **★決定 2＝甲（用戶定 2026-07-16，patch-gate-first 解疑）**：供給根 precise＝**製造設施幾乎不建**（`has_facility` 恆 1）。隊**想**製造（TASK_MANUFACTURE 1→11）、**有材料**（surplus 破千）,純被 **補丁閘擋**（頭號＝`恆-hungry→永建農`:定居隊糧在糧倉卻恆判餓→永優先農田→製造 never）。**∴ 非天生稀缺是 bug 閘 → 乙不成立（補丁閘通則＝de-patch,不把 bug 當設計）→ 甲。**
- **★★生產 arc＝拆光補丁閘融入框架（用戶定 2026-07-16，同商業那套）**：不 de-patch 單一閘,**拆光生產/設施子系統所有補丁閘、全融進框架（引擎 + 人格秤）、無殘補釘再量**（否則又抓下個閘＝打地鼠）。
  - **願景＝[[綜合發展模型]] 落地**：食安地基後多維發展人格化——工匠型建工坊/冶煉、農夫型續農、好戰型建軍事。食安→製造→餘貨→貿易,人格+情境定速。
  - **這是「吃得飽的窮部落爬薄階梯」突破口**：從求生升發展。
  - HOW 全交系統（哪些閘、怎麼進引擎、切幾 slice）;藍圖只定「食安後多維人格化發展 + 拆光補丁閘 + 全程人格化」。靜態稽核列全補丁閘餵系統。
  - **★★premise 訂正（R① 2026-07-16 手算推翻天真 de-patch）**：原以為「拆 `恆-hungry` override → 人格自然選農田」＝**假**。reviewer 手算 `_facility_score=地利×(1+deficit)×人格`:普通~良好地力,餓隊會選 workshop（4.40）> farming（除非地力近 max）,因 **deficit clamp[0,1] 使「快餓死」與「略缺」都=1.0 無量級**。**∴ override 其實承重（補償壞公式防餓死），天真拆掉會餓死＝比現狀更糟。**
    - **修正 WHAT**：不是拆 override,是**讓食安地基「真實在秤裡」**——deficit/急迫度要有**量級**（快餓死須輾壓 workshop/軍事 → 自然選農田;食安後急迫降 → 才輪人格選發展）。food-floor 從秤裡湧現,override 才能安全退役。**序：score 修好（地基進秤）才准拆 override。**
    - **means-end 斷鏈**：「建設 option 接手蓋工坊」全 codebase 不存在;facility 建造只由 `_evaluate_infrastructure`（僅 `state.factions`）發起 → faction_id=-1 獨立定居隊永無建設施路。**修：所有隊都要有「想 goods→需設施→能發起建」的真 means-end 路。**
    - **常數訂正**：`FOOD_PER_PERSON_PER_DAY=0.8`＝代謝物理**絕不人格化**;只「7」安全天數視野該人格化。世界物理常數留 flat,只人格化決策常數。
    - **修材引擎裡本就有（systems 親驗）**：`need_hierarchy L_SURVIVAL`（連續急迫度隨餓程度縮放）+ `food_security_target`（已人格調變 buffer）＝reviewer 說 flat deficit 缺的量級 + 願景要的人格 buffer。修＝facility-choice 接上這套（非新造 flat deficit 平行系統）。
    - **WHAT 定（2026-07-16）**：①**獨立隊（faction_id=-1）也發展生產＝YES**（綜合發展涵蓋所有據點主,非 faction 特權,排除＝任意豁免;means-end 統一發起涵蓋）。②**食安壓倒＝軟連續急迫曲線非硬 cliff**（cliff＝另一種死 gate）,但急性瀕死須真壓倒（農田輾壓,別讓餓隊蓋工坊死）;人格 textures 轉折（慎重 buffer 大→餓更晚仍發展、大膽→發展進更薄邊際＝戲）。
    - **序/閘**：score 修好（地基進秤）才准拆 override;v2 須再過 R①（可能 measure 坐實「急迫度真讓飢隊 farming 主導」）才 spec。
  - **★★供給側大成功（measurer full-HD 坐實 2026-07-16）**：`has_facility 恆1→31.3%`（含獨立隊 27.3%）、世界成品池 `26→480（18x）`、`Manufacture 6→4348（700x）`、`no-op=0`、**餓隊沒餓死（食安地基靠軟急迫守住,非 override）**、守恆 PASS、無殘補釘。**R① 訂正後的設計成功落地**（urgency 真 fire、獨立隊真發展兩項坐實）。**供給牆破。**
    - **merge 裁（2026-07-16）**：觀測閘綠即 merge（框架 correct+safe+主目標達成＝強證,不卡 emergence）,誠實標「供給破+surplus,人格分化 mechanism-present 待 multi-seed」。
    - **emergence 定案（multi-seed 2026-07-16）**：**好戰→軍事真 emergence 強坐實（Δ+0.36）**;貪婪→工坊/慎重→農**不顯＝need-first 設計的正確後果非 bug**（farming/workshop 由求生+deficit 主導,人格是 texture;食安不因人格打折）。**接受 by-design,不 tune 人格權重**（盲 tune 打架 need-correctness 傷供給側成功）。**願景訂正:人格化多路＝人格→archetype→目標→discretionary,非平坦 trait→設施映射;「工坊=貪婪」是錯映射該除。** 商業/定居的濃差異＝deal 側 arc 長出（為賣而產）。
  - **★deal 側牆＝死法②（下個 arc）**：供給「量」有了（18x goods）但**流通到 visitor 隨身可交易貨未打通**（sell_no_surplus 仍最大 bail）＝成交牆同款。經濟全景:**水管通（商業）+ 水有了（供給）→ 但水流到買家（deal-flow）仍塞**。下個 arc。
  - **★★貧困陷阱＝兩把鎖（food + coin urgency）鎖住建設層（measurer §④b 3 隊坐實 2026-07-23）**：追武器坊建造不成，一路挖到 afford 根＝**常駐求生高壓的隊會賣光非求生資產換食/coin，structurally 湊不到投資本**。機制:`reserve_factor=0.6+(hoard-0.5)×0.5-urgency×0.4`，`urgency=max(food_urg, coin_urg)` 常駐 0.72-0.98 → factor 壓到 0.25-0.29 → material 賣到 reserve 25-29 → 永遠囤不到建造門檻（105）→ 蓋不出**原本能解它壓的設施** → 永困。**設計自洽的『貧困陷阱』非 bug**。**★關鍵訂正（data 坐實，非單一逃生閥）：這是兩把鎖**——`urgency=max(food_urg, coin_urg)`，食安修只解 food 那把；**coin_urg 常駐 0.8-0.97（3 隊 coin 全極低）＝很可能是 binding 那把**，光 coin_urg≈0.8 就把 factor 壓到 0.28（正中觀測）→ **食安修單獨後 urgency 仍=coin_urg 0.8 → afford 仍鎖**。∴**軍設施 afford 要 food AND coin 兩鎖都解**；coin 鎖＝既有 coin poverty（掠奪 coin→anon_treasury 不流 team.coin，v2b defer）從「buy 錢包」升格成「貧困陷阱第 2 鎖」。∴**食安是建設層前置閥之一非唯一**；afford/cost/cap 都是下游症狀，不獨立修（cost70 balance 值 keep=銀行，兩鎖解後才生效）。連結 [[means-end]]:前瞻買料 target 是拍死常數（cap 100）非由建造實際需求推導＝決策模型缺「為目標湊足所需」的缺口，facility-build keystone 頭號 exhibit。**★診斷史血證**:此線靜態推理三次全錯（117 框架→persona 1.13→實測 0.25），唯 measure 結案＝涉「隊會不會累積到某量」的判斷靜態不可信（動態 sell/urgency 沖銷），必實測。
  - **★★material = 開採/地理資源非耕作資源（用戶定 2026-07-24，脫貧真脊椎的 world-model 裁決）**：三腿（reserve/coin/hold）修完 afford 仍 0%——patch-gate-first 證 inflow 無非法閘，真 binding = **aggregate material SUPPLY + 地理 food-terrain≠material-terrain 錯位**（隊為食定居 plains[食8/材0.5]被斷離 forest[材12]；material 只能採不能造[無 recipe out:material]、被所有 recipe 吃）。**★裁決 = 地理張力是 intended feature（非 bug、不 flatten）**：food vs material 走**兩種不同經濟邏輯**——**food=耕作**（原地改良、farming 設施 `×(1+farming_level×0.5)`、作物**季節級快再生** → 改良**永續**產量 coherent）；**material=開採**（樹**年代級慢生** → **不能像耕作那樣永續增產**）。**★關鍵區別（用戶 2026-07-24）：育林/種樹增產不 coherent（樹慢長不出來），但『伐木場=加快開採』coherent——它不種樹，把現有的樹砍更快。** ∴ farming＝永續耕作放大器 vs 伐木場＝**開採加速器**。**★核心框架 = 賽跑（用戶定 2026-07-24，非個人 boom-bust 取捨）：forest 材料是有限存量，『誰先砍完誰優勢大』**——誰先搶到 forest、砍得快、清完，誰把那筆材料收進口袋 → 發展優勢滾雪球；永續採贏不了清伐者（別人直接清光）→ 誘因永遠是衝/搶/快砍。**★機制＝現行的就夠（用戶 2026-07-24 核對坐實，非新機制）**：`regenerate_tiles:93-97` material regen＝**additive +12/天往 `resource_cap` 補（慢慢長、非瞬補、cap-bound）**、harvest 扣池（`_collect_from_tile` current−gain）→ **可耗竭池 + 慢回 + cap 全已在**。∴只需加兩樣：①**森林初始材料庫存高一點點**（forest tile 開局材料近一個高 `resource_cap`＝老熟林大獎，world-gen 初始值非改 regen 機制）②**伐木場設施＝加快 material 開採速率**（forest-only，讓「砍得快」變能贏的選項）。**regen 機制不動（已是慢慢長）。** **★唯一 measure＝tune 數字非改機制**：現行 +12/天夠不夠慢讓清伐後先手優勢維持夠久（賽跑尖銳）、還是太快幾天長回（先手不夠）→ measure 後微調 regen 數字/初始庫存/伐木場 boost（**別預調，先量**）。**不加育林（不 coherent）。** ∴ forest 隊＝材料生產者（搶砍+出口），plains 隊取得 material 靠**控產地（擴張搶 forest tile）+ 貿易 + 遷徙**＝取得閥。**★選擇的後果（用戶明選）：材料稀缺真實、發展是『競爭性』非『普世』**——能控/搶砍 forest/買得到的隊才發展，控不到=發展不起，**地理遊戲核心張力非 bug**（搶 forest tile 衝突 + 材料貿易 + forest 材料國↔plains 農業國互賴 + 先手滾雪球）。**★snowball 平衡待盯**：先手優勢別變死局（「先手必勝、遊戲結束」），靠既有 prosperity-prey 自我修正（滾大的富隊→眾矢之的→崛起與傾覆戲）+ measure 盯，過火再 tune。ore→material 製造（選項 c）用戶未選=暫緩（未來 mountain-archetype 深度可回訪，別繞地理張力）。

### ★★ 統一路線圖：收散亂 oracle（結構稽核 2026-07-16，用戶定「照路線架」）
**核心判讀：DecisionEngine 統一是「半成品」**——引擎存在（23 option,已吸收 threat/survival/ambition）,但引擎外並存多條 dispatch 路 + 多份各算各的 need/threat/估值。`faction_ai_system.gd`（3781 行）是大雜燴載體。**不是從零建,是把散在裡面的東西抽出來收成統一思考驅動 oracle。**

**散亂全景（file:line 稽核坐實）：**
- **同一概念散多處各算各的（打架種子）**：食物需求/餓 **7+ 處**（5/7/10/14天+security+EMERGENCY）、威脅 **8 處**（3 種 rep 門檻）、估值 **5 處**、派系需求自成第 4 棵樹（不讀 team need）。
- **三重 dispatch 並存**：引擎 rank / 手派求生 / 手派威脅,散落 return-gate 手切（split-brain）＝「加東西=大改」結構根。
- **決策門檻焊死常數**（散 8+ 檔）：餓錨+行為門檻該人格/情境驅動（物理常數如食耗率正確留 flat）。
- **未系統化領域**：情緒（只 panic 一條線）、內部政治（散 4 處）、俘虜（空白）、設施決策（繞過引擎）。

**★統一原則（貫穿全路線）**：**框架只管規則（世界物理/機制）,思考驅動決策；同一概念收成單一思考驅動 oracle（非常數、人格/情境驅動）,所有子系統讀它,不各養一套。**

**優先序（用戶定「照路線架」）：**
1. **統一 need oracle（B1/B4）＝第一塊**：`NeedHierarchy` 升成全域 need 源。need＝自用（消耗品,消耗率×人格buffer 推導）+ 供應鏈（下游生產傳導）+ 貿易（全資源餘量,市場需求+致富+商隊可載,綁 deal 側）。**一石三鳥：解經濟（生產/商業共讀一個 need,不打架）+ 拆最大打架種子（7 套餓）+ 示範散亂→單一 oracle 模式。** 含：停產接需求（個別設施）、溢出落地守恆（不蒸發）、消耗品也可貿易（非互斥桶,貿易對全資源）。
   - **★兩軸 sharpen（2026-07-16）**：「7 套餓」兩軸混——**quantity 軸**（該留/產/賣多少）＝生產/商業打架根,**Arc 1 收斂**;**urgency 軸**（離餓幾天→survival 排序,DESPERATION/WARNING 天閾）＝NeedHierarchy L_SURVIVAL 已做,**順延 Arc 5 死常數人格化**。
   - **★★Arc 1 APPROVED + merged（藍圖批 2026-07-16）**：4 項乾淨證據全綠——①need 單一源（S6 遷 facility_deficit,**byte-identical 純 refactor**＝本該單一源現真讀）②goods 死鎖解（有貨+活 sell 單/公庫 demand 滿凍結非堆）③停產 52.78+溢出守恆④crossover 100%/守恆 PASS/starve 持平。**兩坑批前修**（mis-cite 矛盾率誤指標 / facility_deficit 殘各算,嚴查兩度擋假 clean）。**終端消耗 self-use 推導＝known-deferred（戰耗機制建了補）;矛盾率＝死法② 指標非 Arc 1。**
   - **★Arc 1 立的模式（Arc 2-3 照做）**：散亂→單一 oracle;**byte-identical refactor 驗**（遷了不變＝無回歸最強證據）;乾淨全量對指標+可溯源;嚴查（靜態查殘+measurer 對指標）擋假 clean。
2. ~~**收斂三重 dispatch**~~ **降級低優先（R① reframe 2026-07-16）**：4 個 `rank_*` 經 R① 查證是**同 applicable() 池 + 同 terms 的 filtered subset,非繞過引擎**——稽核「三重 dispatch = 繞過引擎結構病」是**過度宣稱,無 bypass 可拆**。∴ 收斂只是 cosmetic cleanup（非 de-patch 打架種子）→ 降級低優先（survival/threat 語意可併的開放 Q 併此）。**★threat oracle 上移為 Arc 2。**
3. **統一威脅 oracle（★上移為 Arc 2，2026-07-16）**：ThreatAssessment 單一源,消滅 `_threat_recent`/`_max_threat`/raw 掃描重複。**但前提（8 處各算/3 門檻 0.3-0.7 不一致）來自剛被 R① 打臉的稽核 → spec 前先 R① factcheck（8 處真各算還是同源 filtered?3 門檻真不一致?）驗實才做 oracle。稽核前提本 arc 一直被修正,不再假設。**
4. **拆 `_threat_recent` 軍備閘**：征服者主動備戰（intent/人格驅動 deficit,非反應式）。
5. **決策門檻死常數人格化**。
6. **情緒系統**（emotion 收成與 need 平行的 term 供給層,非只 panic）。
7. **內部政治 / 設施決策 / 俘虜**（中長期收成統一系統）。

**HOW（架構怎麼實作、怎麼 migrate、切幾 arc）＝系統；藍圖鎖「單一 oracle、思考驅動、框架只留規則、可擴充」的 WHAT + 優先序。每大框過 R①（前提 factcheck,本 arc 已 7 次被獨立查證推翻）+ R②。**

#### ★★大戰略校準：統一大半已完成 + 零殘留閘 = 框架硬驗收（2026-07-16）
- **稽核「各算」系統性 over-count（R① 三次打臉）**：need→2 軸+僅 1 真 de-patch(facility_deficit,Arc 1 已修)、dispatch→已統一(cosmetic)、threat→已統一(ThreatAssessment 單源)。**「憲法溶解」統一工作早統一大半 → 散亂 oracle 統一不用 grind Arc 2-7,那些不是漏的閘。** ∴ **剩項(valuation/emotion/prisoner/死常數/內政)先 R①-verify 真缺否才做,別假設稽核。**
- **★★用戶原則（2026-07-16）：只要剩一個非框架閘,模擬結果就變垃圾。** 整 arc 的垃圾結果正是隱藏閘（恆-hungry/執行鎖/`_threat_recent`）靜默汙染。∴ **框架驗收標準＝零殘留非框架閘,無「小可略過」取捨。**
- **∴ 真工作重新校準**：不是統一散亂 oracle（大半已完成），是**殲滅每一個殘留非框架閘**（稽核 section A：`_threat_recent`/`_evaluate_threat` 門檻/tribute override/紮營獵食硬門檻/applicable DESPERATION 天閾/diplomatic RNG 閘… + exhaustive 補漏）。每個都是汙染源,全殲。
- **★零殘留要機器證得出**：`constitution_gate.gd` 現只抓一閘型（禁引擎外 task 指派）→ 強化抓全閘型（硬門檻/override/continue/絕對閾/RNG 決策閘）→ **跑綠＝證零殘留 + 擋新閘。** 非人肉拍胸脯。
- **框架「做好」＝兩硬條件綠**：①零殘留非框架閘（殲滅+constitution_gate 抓全閘型跑綠）②可擴充（加新系統乾淨,擴充性稽核證）。**兩條硬綠才談 behavior/經濟（用戶定序：框架先，行為後）。**
- **★★god-view 後門＝殘留非框架閘的一種，屬「框架先」殲滅範圍（用戶戳「框架沒統一就看合理性」，藍圖認漂移 2026-07-18）**：god-view（讀真值繞過 belief）違感知鐵律＝汙染源，同 hidden-gate 家族。清單：`has_food_market` 掃全圖（`known_issues:35`）、**創世全知 `game_setup:569-578`**、near/far LOD 非中性。＝awareness/掃近隊 arc 的 belief-gate 部分（`line 577-585`）**是框架工作、非行為**。
  - **∴ 改序（認錯先前 economy-first 漂移）**：**框架 god-view 殲滅（slice2 感知 + awareness belief-gate）先 → 零殘留閘綠 → 才 economy balance。** 先前把 economy 排 awareness 前＝把行為排框架前＝違「框架先」。
  - **★硬理由（非只原則）**：`has_food_market` god-view **直接汙染 economy 決策**（隊全知所有市場位置）→ **28% doom / 貿易為何不流 在 god-view 髒基底上診斷不可信** → god-view 殲滅必須先於 economy 診斷。
  - **economy arc 第一動作＝補丁閘優先查**（28% doom ＝殘留閘造的 or 真稀缺？）→ 不假設 balance 問題就 tune。屬「先量測+先查閘」非「先調參」。

#### ★ threat-severity 行為意圖裁定（藍圖定 2026-07-17，threat-oracle 序3 收斂前置）
**問題**：threat 收斂進統一 rank 需 severity-scaling（否則強威脅被貿易 1.3/野心 1.5 量級結構性壓過，現靠 filtered-hard 子集 gate 硬保 threat 奪 argmax＝非 util 量級＝seam#1 血證）。但「威脅越大→越戰 or 越逃」＝行為 WHAT，系統呈裁。

**裁定：#3 人格分流 amplifier，且細化分兩支（超出系統框的加值）：**
- **威脅嚴重度＝amplifier（把 threat 拉進全 pool 有真量級競秤），非固定方向**。方向由**人格 × 可勝性**決定，不寫死。合憲法（引擎秤人格，不替 NPC 定行為）＋孿生條（不在引擎壓某率）。
- **備戰（defensive prep/arm）＝隨威脅普遍上升**——連謹慎/怯懦領袖被威脅也備戰（防禦＝低後悔對沖）。∴ **慎重在威脅下應「拉高備戰」非拉低**（現況 `terms.gd:176` 備戰不隨威脅變＝缺口）。人格調「幅度」非「方向」。
- **迎戰（offensive confront）＝committal 支，人格 × 可勝性 gated**——`好戰高 AND 可勝（相對戰力）` 才隨威脅上升；否則 severity 導流到 **逃/求和**（敗北出路，膽量秤，連 [[絕境經濟]]）。現況 `:180` 迎戰隨威脅「下降」＝把「怯者/不可勝者不敢正面」錯編進**通用**公式（那是分支，非全體）。
- **約束：severity＝感知威脅（belief，感知鐵律），非 god-view 真戰力**——虛張/偽裝必須有效（弱敵虛張嚇阻、強敵示弱誘攻）。threat-oracle 讀 `BeliefSystem.best_estimate` 不讀 `state.teams` 真值（連決策模型接線 §感知腳）。
- **emergent cost 不設閘**：severity 驅動的過度軍事化→餓民→饑民流串＝合意湧現（自帶資源代價，承 line 361），不加上限補丁。

**∴ threat util ＝ f(perceived_severity 拉量級) × 人格秤(好戰/膽量/求生) × 可勝性 → 分流備戰/迎戰/逃/求和。** 三支不同方向（備戰普遍升、迎戰 gated、逃/求和 outlet），非單一 monotone。

**補裁（異質 R² HALT 揭 2 缺口，藍圖定 2026-07-17）：**
- **① 可勝性＝慎重-加權 term，非硬 AND-gate（修上「好戰 AND 可勝」的洞）。** 異質審抓 `proud-doomed`（好戰高+慎重低+不可勝）落穿所有 outlet（迎戰 winnable-gate off / 求和被好戰抑 / FLEE 被高膽抑 / 備戰慎重-主導低）。修正：**謹慎的鷹（好戰高+慎重高）→不打不可勝之戰，導流備戰/求和；魯莽驕傲的鷹（好戰高+慎重低）→照打＝死戰 last-stand**（合意好戲：defiant 玉碎）。**設計不變量：severity 永遠找到 outlet，人格決定哪個——零 leader fall-through。** 可勝性 modulate 迎戰（給務實者），驕/魯莽 override 它（給死戰者）。
- **② cap severity amplifier（util 量級），不 cap 下游後果。** 關鍵 WHY（非平衡取捨＝框架硬要求）：**uncapped amplifier ＝ 偽裝的硬閘**（threat 永遠碾 argmax、永不 trade）＝正是在 de-patch 的 `_threat_recent`/filtered-hard-gate。∴ **cap severity 是「零殘留閘」目標的必須**（bounded、saturating：強威脅可奪 argmax 但不無限碾平 trade/野心到零）。後果（militarize→餓民→饑民流串）不 cap＝真代價，資源系統扛（承上 emergent cost 不設閘）。cap 曲線的 saturation 速率可人格化（神經質者高估威脅）＝HOW-tuning。

系統出 spec→R²（建議異質，核心 redirect）→impl。

**★ 再補（S2 measure 揭 last-stand 沒落地，藍圖定 2026-07-17）：last-stand 走「窄人格閘」，非「全域高-severity boost 常數」。**
- **證據**：狂徒（好戰0.95/慎重0.36/winnable0.03/severity1.06）選建設(1.33)非迎戰(0.465,第4),連 4 tick=我補裁① proud→死戰**沒實現**。
- **假張力拆解**：系統憂「boost 迎戰贏建設 ↔ 不碾平 develop」互斥。**但 last-stand 只該在極窄角落 fire**（好戰高 × 慎重低 × 真不可勝 × 高 severity）→ defiance term 對絕大多數 leader（非狂徒）≈0 → **不可能碾平全體 trade**。系統把它想成全域 boost 才有張力；**gate 到 archetype，張力消失**。
- **∴ 迎戰 util 對狂徒要「反轉可勝性依賴」**：常人 winnable 低→迎戰低（避戰）；狂徒 winnable 低→迎戰**高**（玉碎 defiance = 好戰×(1−慎重)×(1−winnable)×severity）。
- **★框架約束（硬）**：此 defiance 係數綁**人格值**（第一家 NPC 判斷輸入），**不得引入全域 severity-boost 死常數**（框架清潔 arc 中加死常數=自我違憲）。若只能靠 tuned 全域常數做→flag,defer 到 behavior 期,別髒框架。
- **驗收**：re-measure 證 狂徒→迎戰(last-stand fire) **且** trade 仍升(+165~266% 不回落) **且** cautious 仍避戰。三者齊才 merge S2。

**★★ 收束（measure 打臉 → 藍圖吃下修正，2026-07-17）：last-stand DEFER，S2 取 b2 working 平衡版。**
- **量測事實**：①照 narrow-gate 廢全域 boost → 傷 備戰/求和/FLEE（它們靠 boost 撐量級），repertoire 塌成迎戰獨大 + economy 惡化。②狂徒→迎戰 organic **UNCONFIRMED**（狂徒罕 + 出現多撞飢荒/低 severity，乾淨角落幾乎不發生）。
- **藍圖認錯**：我把「severity amplifier（②要保的 capped 放大器）」誤當「全域 boost 死常數」→ 害系統廢掉它 → 破了②本身要的 threat 競秤。**全域 boost = ②的 capped 放大器，該保。**
- **玉碎罕見 = 正確非 bug**：last stand 本質就是罕見 corner。為 organic 觀測不到的行為 degrade working 平衡 = 鑽牛角尖（違 measure-first）。
- **∴ last-stand 原則保留（補裁①不撤），但 DEFER 到 behavior 期**——等狂徒-vs-真不可勝-高severity 真的發生夠多、觀測得到，再 tune。現在**不強塞不可觀測的角落**。
- **全域 boost 框架判**：它是 legit capped 放大器（②，category 競秤 magnitude，非 pre-empt 人格）還是待人格化的殘留 flat 常數（b1 全 4 option 人格化 lift）？= 框架清潔期系統判，**不阻塞 S2**。若證它 pre-empt 人格 → 未來 de-patch slice（b1）；若只是 category magnitude → legit 留。
- **S2 merge**：取 calibrate working 版（threat 有意義 0.5%→1.9-5.1% + cautious 分流對 + trade +165~266% + 世界健康），減 last-stand。

**★★★ attrition accept 收回（premise 更正，藍圖 2026-07-18）：我 accept 的 +3x attrition 不是戰鬥、是餓死。**
- **真相（長窗 watch）**：annihilation=0 兩 seed → attrition 根因 = **STARVATION 非 combat**。且非乾淨穩態：seed42 拉長 5 個月 pop 掉 34%、**15 隊餓死**（bleed）；只 seed1337 乾淨 9.2%。系統早先「attrition=真 engage 好戲」framing 未驗就斷 combat = 錯。
- **我的判斷收回**：餓死 attrition ≠ 戰鬥好戲。那是**經濟餵不飽、世界萎縮**的失敗模式（正是那個 watch 要抓的 bleed）。我熱情「歡迎」建在錯前提上，撤。
- **★重判準（餓死 attrition 該用這尺，非「戰鬥就歡迎」）**：分**自限代價** vs **失控死螺旋**。
  - 可接受：過度軍事化 → 部分人餓 → **他們逃/搶/乞/投靠（絕境階梯 fire）** → 隊縮回、倖存者 OK ＝ 自限的侵略代價（合我 emergent cost 意圖）。
  - **不可接受**：隊**被動餓死到滅**（15 隊死）＝ 絕境出路**沒 fire**（bug）或 economy 根本餵不飽（更大問題）。**「不設閘」是指代價機制不硬 cap，前提是代價自限；不是指「隨世界餓死到滅」。**
  - ∴ 診斷關鍵問：**這些隊餓時有沒有先採絕境行動（逃/搶/乞/投靠），還是傻站著餓死？** 傻站著死 = 絕境經濟沒接好 = 真根，比 threat-oracle 大。
- **★連 B（更大世界）：這是 B 的前置 blocker。** 50-100 隊世界**不能架在會把隊餓死的 economy 上**——放大規模＝放大餓死。B 第一關不只 profile O(N²)，是**世界能否 sustain N 隊不餓崩**。先清這個。
- 系統正查 threat-oracle 是否推高飢荒（militarize 排擠覓食→餓死＝regression）。是→修 regression；世界固有→economy sustainability arc（B 前置）。
- **★解決（藍圖判準命中，systems fix merged `31f9833c`，2026-07-18）**：根 = threat-oracle S3 把 threat @70 但 survival 落 @50 → survival 無法 preempt → 又餓又被威脅的隊做威脅反應非覓食 → **傻站餓死**（正是我判準的 bug：絕境出路沒 fire）。非「militarize 排擠」是**優先序倒置** regression。**fix：survival 復位 @PRIO_SURVIVAL 80**（階梯正典）。結果：seed42 餓死滅團 15→0、attrition 自限 2.78%（低於 pre-threat-oracle ~9%=survival 保序在統一路更 robust）、threat 黏性未損。**attrition 現=自限型（餓→逃/覓食 fire→隊縮回）= 我 acceptable 判準。**
- **★B 第一關狀態**：**sampled 現規模（~25-50 隊）過**，非目標規模。**B 真第一關 = sustain 50-100 隊**（perf_scale world radius24/~100 隊）→ 下一步驗 scale sustain + O(N² profile 同一趟 + 多 seed + 確認世界仍 dynamic 非太靜。
- **★★未真過（multi-seed 更正，2026-07-18）：survival @80 fix 非普適，B 第一關 residual root。** measurer multi-seed：seed4201 乾淨，但 **seed1337 仍（去灌水後）真 3 隊 no_forage 傻站死**（原報 7 隊含 4 隊 famine_days=0 誤計，QA 判準對）。
  - **cause2（PRIO_COMBAT 鎖）被 QA 故事稽核推翻**：無一隊死於 literal 戰鬥（team19 combat_target=-1）。系統與我都猜錯、我還 elaborate 補丁閘框架＝白的（第 N 次症狀當機制）。
  - **★真根 ①（measurer 精確 locate，非猜）：survival 保序優先序「散在多條 dispatch 路」不一致。** cause1 的 survival @80 只做 `_decide_unified:1553`，漏 `_evaluate_solo:1902`（solo 隊一律 @50）→ team19（非 unified/非 subteam）survival @50 壓不過 安頓@50 → 凍餓死。系統上輪「code 坐實 camp 豁免」也錯（team19 撞 `:3225 return` 根本不到 camp code）。
  - **★WHAT：別 whack-a-mole 逐路補 @80。** 已 2 路（@80/@50），第 3 路可能再冒。**survival 優先序＝散落常數（正是統一 arc 的目標）→ 收成單一源**（survival-class 一律 PRIO_SURVIVAL，讀一處），才不會跨路分歧。**不變量：命運不看「走哪條 dispatch 路」**——solo/unified/subteam 的 survival 保序必須一致。統一後 detector 亦 trivial（一處可查 vs 掃跨路一致性）。
  - **★cause2＝補丁閘（藍圖判）**：絕對 PRIO_COMBAT=100 鎖 → 餓死隊不能選逃/覓食 = 絕對門檻 pre-empt 膽量秤逃決策（[[feedback_patch_gate_first]]）。fix ≠ 換優先序數字（survival 101>combat 100 = whack-a-mole，且破「戰鬥中不能覓食」正解）。
  - **★WHAT 意圖**：戰鬥 break-off/潰逃觸發**太窄**——`_mortal_flee_check` 只在 eff≤3（戰損近殲滅）fire，**只認戰損不認飢餓**。**該擴：餓到絕境的隊在戰鬥中也能潰逃求生（膽量秤，[[project_desperation_economy]] 絕境階梯延進戰鬥）。** 戰鬥仍高優先（鎖 legit），但餓死隊得有 desperation break-off option。HOW＝系統 trace exact 鎖點設計。
- **★process 教訓（3 度過早宣勝）**：attrition=combat / fix=decisive / fix=universal 皆 measurer multi-seed 抓翻。**claim「X 修好」前先 multi-seed（含已知硬 seed 如 1337），非事後**。measurer multi-seed backstop 有效，但該前移。

### ★ full-HD 正典原則：命運不看玩家臉色（與用戶成形 2026-07-14；perf-caveated）

> **一隊的命運不該因「玩家有沒有在看」而不同。full-HD（全隊全速決策）= 正典行為；LOD 是必須先證明 match full-HD 才准開的 perf 優化。**

**背景（本 session 血證）**：現行 LOD（near＝玩家≤3格每 1h 決策 / far＝每 10h + **跳過人物反應**）製造 fidelity bug——
- **thrash 是 near 專屬病**（每 tick 重決→自我打斷→買糧下不成→餓死）；far 低頻反而承諾成功→活。**近隊被害死＝命運看玩家臉色＝壞。** thrash-fix（執行鎖）即補此縫（near 收斂到 far 的碰巧正確行為）。
- **reaction_system（N1-N5 defect/riot/dissent + breed）near-only**（`sim_runner:221`，far 跳過）→ **all-far headless（所有量測）從沒跑過**（fullprobe `reaction.*` 全 0 坐實）。∴ 整個 ③ 內部政治基質 + 人口 renewal（breed→minor→10%/月長大→成年 anon，`population_system:7`）在量測裡是死的，世界只能單調萎縮。

**∴ 三個世界（全-far 量測 / LOD混合 出貨 / full-HD）本該相等；分化＝bug。** 正典＝full-HD；LOD 降級成「須證 match full-HD 才開」的未來 perf opt（fidelity by construction，非事後稽核補洞）。

**★perf caveat（系統可行性判 2026-07-14，`89b22ad3` lod_perf_bed）**：
- **原則對（correctness）**，但 perf **卡規模**：**~15-25 隊 full-HD 撐 1× play（474tps，2× headroom）；50+ 隊崩（~8tps）**，真根＝**O(N²) faction_ai**（每 faction rank 所有隊；full-HD 成本 96% 在 faction_ai）。
- ∴ **full-HD 正典＝現行規模已可落**；**50+ 隊規模待 O(N²) faction_ai perf arc**（攤平 rank：cadence/incremental/空間分區/快取；timescale-wave 真根，非死路）。**撐不住的是規模，非原則。**
- **★可玩天花板（1×=240tps，`89b22ad3` lod_perf_bed 坐實）**：**full-HD ≈ ~25 隊 / LOD ≈ ~40-45 隊**（15隊 full-HD=474tps、LOD=781；116隊 full-HD=18tps、LOD=25tps）。acceptance 可跑更大（慢可接受）。
- **★O(N²) 是「50+ 硬前提，不分 regime」（LOD 救不了）**：LOD@116=25tps 也崩，far-cadence 攤銷只買 **1.42×**——**LOD 當不了 50+ stopgap**。∴ O(N²) faction_ai arc 的優先序**與 full-HD 決定解耦**（想要大世界不管哪個 regime 都得修它）。**反過來加固 full-HD 轉正典**：既然 scale 卡的是 O(N²) 非 regime，選 full-HD 只多付 1.42×（小），換 correctness（命運不看玩家臉色）值得。
- **落地順序**：full-HD 現行規模先落（thrash-fix 在 full-HD judge）→ **gen 重校 slice**（含 breed/reactions 開機後的人口/凝聚動態，非只節奏；full-HD tick-time 已含 reaction/breed 成本）→ O(N²) arc 解鎖 50+ → LOD-as-fidelity-preserving-opt（真根修完、若還要更大規模才碰）。

#### ★ O(N²) 掃描瘦身的 vision 約束（藍圖鎖 WHAT，2026-07-18；機制=系統 measure-first）
真根：prey/threat 掃描迭代 **`team_discovered` 累積名單**（一旦發現永留）+ reachable 濾在迴圈**內** → 小圖每隊 discovered≈全隊 → O(N²)。修法方向＝**換迭代源**（掃「附近 + 顯著」有界集，非全累積名單）+ 地圖放大散開（密度不變）。**兩者並行才吃得到紅利**（大圖給「附近隊少」，換源才用得上）。
- **★約束①：掃描用信念位置，不用真實位置。** 「誰在附近」由觀察者**自己的 belief store（belief_pos + staleness）+ 當下 vision** 定，非世界真座標。用真距離挑近隊＝god-view leak（違感知鐵律）。
- **★約束②：不准砍掉記憶中的顯著威脅。** 掃描瘦身**只准砍「無關的陌生遠隊」，不准砍「記憶中重要的遠隊」**（世仇/大威脅/盟友遠也留，低頻評沒關係，但不能消失）。否則隊會忘了逼近的大敵＝壞 believability。
- **★洞見：感知鐵律 ＝ O(N²) 修法同一約束。** 全知掃真座標既是 believability 罪也是 perf 罪；**感知-local 掃描同時治兩者**（只處理「我感知得到的」，而感知天生局部）。霧戰 = perf 局部性。
- **機制不鎖（系統 measure-first）**：空間索引/salient 上限/cadence 待 profile O(N²) 熱點；**且先 audit `estimate_catch_up` 讀真值或信念（疑藏 god-view leak）**。現在硬鎖機制＝重犯「沒量就定案」。此節僅鎖 WHAT 約束，機制隨 O(N²) arc（B 前置 sustain 過後）設計。

### 決策模型接線現況（方向鎖了、線沒接完，2026-07-06 盤點）

模型是北極星，但實作只接了部分腳。**這是一條 post-arc 的「接線」脊椎，非零散 bug**：

| 腳 | 現況 |
|---|---|
| **人格** | ✅ 已接（weight() 讀 leader_values） |
| **現況／感知** | ⚠️ 接了但**讀真值**：評估別隊的 finder（`_find_weakest_prey` 等）讀 `state.teams` 真戰力，未走 `BeliefSystem.best_estimate` → 破感知鐵律（偽裝/虛張對它無效）。**自己狀態讀真值 OK**，違規僅限「別隊隱藏狀態」。 |
| **記憶** | ❌ **只寫不讀**：reaction 寫 memory(intensity)，但引擎 DecisionContext/Terms 完全不讀 → 「記憶染價值」腳空接（寫入無回饋迴路）。 |
| **情緒** | 🔨 序7 起步（stress→team_panic→survival FLEE，首次接線）。 |

**接線脊椎（post-arc，待排）**：①感知改讀 belief（訊息真融進決策；信念層 team_intel 已建，缺決策消費它 + 補戰力估計欄位）②記憶腳接進引擎（經驗→claim→決策自然讀，零新學習系統，承「經驗=自己的 claim」）③情緒腳續接。三者=同一條「決策模型完成」，非各修各的。第一步＝掃清「哪些 finder/ctx 讀別隊真值」清單。

**★感知腳＝征服可達性的唯一真閘（2026-07-06 measure 收斂）**：多 seed 揭征服 winner_prosperity=0 全 seed。曾疑兩閘（感知 + combat 結算），但 dogfood 診斷證 **combat 結算閘=量測假象**（`combat_decisive`/`win_absorbed` 只計全殲支，實戰走 retreat→`_try_subjugate` 捕獲、探針沒量那條；征服其實悄悄發生 capture.total 1-11）。

**★再翻案（2026-07-06 戰力欄實作 measure）**：戰力欄 fog-fallback 修對了（埋死常數 `armed_est=pop_est`→人格化 helper，合三個家），**但不解鎖征服**——兩因：①`winner_prosperity` **也是量測假象**（征服隊選攻擊時引擎在 faction_ai:1485 return，沒跑到 :1506 計數器；與 combat_decisive 同款）②弱點公式 `1−對方武裝/我自己武裝` **相對攻擊者自身武裝**——早期隊自己武裝弱→看誰都不夠弱→不攻擊。**∴ 征服真閘＝攻擊者武裝化（militarization），且這是正確設計（武裝完成才想征服，征服本來就晚）。** fog-fallback＝latent-correct 衛生修（攻擊者武裝夠才生效）。**征服儀表壞了（winner_prosperity+combat_decisive 皆假象）＝一直在鬼影上診斷**；建 per-cohort 活動/武裝化時序觀測（`militarization_arc_bed.gd`，誠實漏斗 want→committed→executing→capture）。gen readiness／food＝駁倒。

**★三閘定論（2026-07-06，3 seed×8 月 arc bed）**：儀表跑出征服卡在**三個上游閘**（漏斗每 seed 都塌在「want」；隊任何 seed 都不武裝，self_armed 平 ~0.20 無人選訓練）：
1. **dispatch veto**（`_commit_conquest_attack` 後的 continue-override）：引擎排攻擊#1 但驗證攻擊 scaffolding 未 dispatch 時，舊碼 continue 掉去用低選項（建設）替代＝dispatch 層推翻秤#1。**已溶解 merged**（continue→return，保子隊閘+scout scaffolding；`_is_prosperity_candidate` 實為子隊閘非 readiness veto，讀 code 更正）。憲法 prerequisite，但**當前經濟下 dormant**（隊太餓→攻擊從不排#1→分支不 fire）。→ ①了結。
2. **世界苦→意圖餓死**：die-off seed（pop 腰斬、forage+flee 主導）野心 2 月塌成求生。＝世界 harshness param（孿生條），defer。
3. **★意圖不點火（主閘）**：**seed 7＝健康繁榮世界照樣零征服意圖**。樣本驗證：seed 7 **確有 2 真霸主**（T23 野心0.92好戰1.0、T40 野心0.87，archetype=武力）但被閘住 → ③是真閘非抽樣。**機制＝死鎖**：想征服←需看見弱獵物←需武裝←需選訓練←`ambient_train_drive`平頭0.5太弱沒人選；且 `_intent_scores` viability 層在「無可見獵物」時把霸主 intent 降級成致富→去貿易→永不武裝→死鎖。
   **裁定（2026-07-06，破鎖）**：**霸主野心直接驅動 proactive 建軍**（不等可見目標；真軍閥先建軍再找目標）。`ambient_train_drive` 隨野心/好戰調製（照妖鏡：平頭常數→人格化），**狂者強到刪民生擴軍**（train util 壓過產/建）。湧現迴路：過度軍事化→餓自己民→饑民流串（串起③②）。「無可見目標」的反應該是「備戰+派斥候找目標」非「降級致富」。

### ★ A2 arc：faction 權威折入引擎（進度 2026-07-09）

reverse-engineering arc 第二脊椎（faction「leader 零引擎＋5 平行權威」）逐條折入統一秤：
- **A2b**（leader 隊戰術意圖）merged。
- **A2c-1**（整併/consolidate）merged 2026-07-09（`c047241`）：舊 pre-gate `continue` bypass（可併隊直接跳過引擎、不被重評）→ 折成 rank_scored option「整併」競秤。整併現與攻擊/生產/貿易一起被秤，非繞過腦。
- **教訓**：A2c-1 fold 曾疑「變靜 regression」→ upgrade 實驗（生存零改善）+ 多 seed（方向不一致=seed-1337 幽靈）雙破 → 純 fold ship、survival-value 撤。**相關≠因果、單 seed≠真、先量再斷。**

### ★ 絕境經濟（設計方向，未鎖 spec，2026-07-09 與用戶成形）

A2c-1 揭 **merge/join food-blind**：整併/投靠選 absorber 只看 capacity/proximity、**不看食物** → 餓隊併餓隊還是餓（survival-inert）。開一條設計線：
- **★絕境分岔＝4 選引擎湧現（四條機制全已存在，≈零新系統）**：餓/弱隊引擎秤四條，由合作→暴力：
  - **乞討**：求施捨、保獨立（`_resolve_aid_request`；target 依 honor/rep/greed 給，annoyance 自限）
  - **投靠**：棄獨立換保護（雙向握手，見下）
  - **獨撐**：覓食硬撐（survival forage）
  - **變匪**：掠奪（絕境搶現有；職業搶需 loot util 人格化，見下）
  - → **絕境經濟 ≈ 把四條現有機制正確走引擎秤（非 bypass）＋ loot util 人格化**。人格塑選擇（驕者少乞多搶、義者施捨、貪者變匪）。乞討被拒/不足 → 升級投靠/變匪＝**絕望階梯**。
- **★★絕望階梯「怎麼爬」intent 裁定（藍圖定 2026-07-18，code 揭階梯不會爬）**：measurer 坐實 `terms.gd` 絕境 option util **全與 famine_days 無關**（紮營=常數/乞食=常數/掠奪=看武裝/併入=看名聲），買糧觸底飽和 → **argmax 進危機就永久凍、失敗不升級**＝階梯有 rung 但不爬。裁定＝**與 threat-severity 同一結構（情境嚴重度放大、人格定方向）**：
  - **① famine 深度＝amplifier（缺的那塊）**：food_days→0 時，整個絕境 category 的 urgency **隨飢餓深化上升**。這是讓階梯「爬」的引擎——util 隨絕境重排，非 static。
  - **② 方向＝人格閘**（膽量/貪婪/榮譽/義氣/野心）：勇/貪/殘→**掠奪**、慎/榮→**乞討**、低野心/高求生→**投靠**、baseline→**覓食獨撐**。同 threat 的「severity 放大、人格定戰/逃」。
  - **③ 失敗升級＝需失敗回饋（★原「不需計數器」被 QA raw trace 推翻，藍圖認錯 2026-07-18）**：坐实=**famine-amp 只等比 scale 不換序**（camp/beg/join 各 static 人格 × 同 `famine_severity` → 深餓三格同比升 → 相對序不變 → 鎖人格偏好格更死、永不換）。∴「更絕境 option 自動蓋過」**假**——amplifier 是「人格選格器」非「階梯攀爬器」。**修=通用 action-stall 失敗回饋**：committed 到某 survival option 達 N 天仍無 food relief → 降該格權 → 次人格偏好格贏。= 推廣既有 `task_start_tick` timeout idiom（SCOUT/FLEE/STATION）到 survival，非新機制。**守框架**：N 天門檻由人格（耐性）+ relief-state 驅動、非全域死常數；降權後由人格選次格（軍閥卡紮營→改掠奪；農夫卡乞→改投靠）。[[feedback_symptom_vs_root_retry]] 此處**支持**回饋（X 卡著沒 relief=「X 現在做不成」→換格，非盲重試）。
  - **④ 無固定普適序**（駁系統選項 c 的固定 buy→loot→beg→join）：序本身**人格排**——驕傲軍閥「搶」在「乞」之前（寧搶不跪），怯懦農夫「乞/投靠」在「搶」之前。只有 baseline 物理序（覓食-自立恆在 < 買糧-需市場 < 社會/暴力-隨飢餓升）。
  - **★框架約束**：amplifier 讀 `famine_days`（第三家情境）× 人格（第一家），**禁全域 ramp 死常數**（框架清潔 arc，塞死常數=自我違憲）。
  - **★產出自限 attrition（我 acceptable 判準）**：每個 rung 都是**行動**（搶/乞/投靠/覓食）→ 解除或轉化飢餓（搶=得糧或戰死非餓死、投靠=被吸收、覓食=硬撐），**非被動站著餓死**。這正是餓死 attrition 從「傻站死」變「自限」的機制。
- **投靠＝雙向引擎決定，非強制併（憲法一致，2026-07-09 與用戶成形）**：合不合併是**兩邊各自的思考結果**，非機制硬塞。現行 `_find_absorber` 挑 capacity/proximity＝食物盲、且單向硬併＝破憲法。
  - **弱隊 3 選 1**（引擎秤）：投靠**能養的**強者（有餘糧＋夠強，真求生）／獨撐覓食／變匪（絕境分岔）。無「該併就併」硬 gate。「一群饑民一起還是饑民」。
  - **強隊秤收不收**（多動機）：**擴軍收**（得人力/戰力＝現況腳）／**友好收**（同勢力/恩情＝記憶腳）／**拒收**。強者非垃圾桶。
  - **握手成才併**；強隊拒 → 弱隊落獨撐/變匪。**「饑民變匪」＝投靠失敗的下游，不另寫邏輯。**
  - 三腳全落位：恩情＝記憶、同勢力/擴軍划算＝現況、貪/義＝人格 → 投靠握手**自然長在決策模型上**，非新機制。
- **饑民→掠奪→職業搶匪＝湧現非實體**：`山賊` 不是 archetype／目標錨，是**決策層湧現**——餓→引擎秤「掠奪」勝→搶；吃飽／搶不划算→選別的（悔改）。承接上「過度軍事化→饑民流串」。**不建搶匪系統、不放錨。**
- **職業搶匪＝確認的湧現缺口（量測 2026-07-09，用戶定發展方向非急）**：機會型盜匪**結構性零**——3 seed、**0/409** 征服決策選掠奪、`loot_lead` 峰值**全 0.00**（掠奪 util 從未領先次佳 option）。天花板結構性低於別 option，吃飽隊永遠選不到。只有**絕境搶**（`surv.loot_dispatch` 飢餓 override）是活的。
  - **掠奪＝手段非目標錨（2026-07-09 用戶校正）**：`征服(CONQUER)`＝錨（奪地野心）；`掠奪`＝**手段**，服務「致富(RICH，`find_prosperity_prey`)」或「生存(絕境，`surv.loot_dispatch`)」。**掠奪自己不是錨**——雙重印證「不放目標錨」。**職業匪＝致富野心的隊選「搶」當致富手段（而非貿易/生產）＝靠搶發財**，非征服者、非新錨。
  - **修法：人格評，不是死常數挑贏家**：設計者**不讓掠奪「贏」**（那＝硬挑贏家）。設計者讓**手段選擇（掠奪/貿易/生產）由人格秤**——貪婪/殘忍/低榮譽頭→掠奪 util 自然高→去搶；勤勉/榮譽頭→生產/貿易高。**匪從人格湧現，設計者不挑贏家。** 現在 0/409 無匪＝死常數壓平人格：`LOOT_SCORE_THRESHOLD=0.35`/`LOOT_READINESS_MIN=0.6`（平頭 TEST VALUE）+ weakness=0-if-armed 硬 gate，把再貪的頭也擋住。**修＝溶掉這些死常數，讓貪婪頭的掠奪估值誠實反映其貪**（歸[[照妖鏡 backlog]] 平頭常數→人格化）。**湧現非腳本、非新系統。**
  - 與征服共用 sub-problem：weakness 需獵物相對弱＋要先武裝才看得到弱者（三閘）；但野心層不同（致富-靠搶 vs 征服-奪地）。
- **★絕境經濟＝矩陣完成的驗收案例，非獨立 feature slice（2026-07-09 收束）**：
  - 死常數消失是**兩步鏈**：**統一（折 bypass 進引擎）＝暴露**常數成 util 項（折 ≠ 溶）；**照妖鏡（人格化）＝溶**常數（util 讀人格/記憶/現況而非死值）。統一是前提（躲在 bypass 的常數碰不到），兩步串。
  - **全義「矩陣完成」＝ decision-side 零全域常數**（承 line 152 + 三個家）→ 死常數全不見。
  - ∴ **絕境經濟（乞討/投靠/獨撐/變匪 + 職業匪）不是要另做的 feature，是「決策模型做完（統一＋照妖鏡）」的自然湧現副產品。** backlog 上標成**「矩陣完成的驗收/湧現案例」**，非待做 slice——它隨 arc（統一）＋ 照妖鏡（人格化死常數）自己長出來。
  - **匪下場迴圈＝全接既有機制（2026-07-09 驗證）**：**滾大**＝別絕境隊投靠成功匪（join）／**被剿**＝苦主 `form_feud`（npc_ai:20）→血仇 vendetta→攻擊 dispatch 走引擎（faction_ai:1513，人格 gated）／**悔改**＝吃飽 food_days≥7→`hunger_relief=1.0`→不再下修掠奪門檻→drive 降選回生產。三條全既有。**唯一待確認 wiring**：搶劫是否真觸發被搶方 `form_feud`（機制在，連線待查）。這些機制**自帶照妖鏡死常數**（`VENDETTA_INTENSITY=0.6`/`RELIEF_FLOOR=0.4` TEST VALUE）→ 再證絕境經濟＝arc＋照妖鏡下游。
  - 唯一可能的真新增：投靠**雙向握手**（強隊秤收不收）。待矩陣近完成時再評是否需獨立補。
  - join.resolve 隨 A2c-1 fold 降＝此症狀，非 blocker（`known_issues`）。

## ★ 孿生條：引擎=通用機制，好戲活在 seed／參數（不把 scenario／平衡寫進引擎，定 2026-07-05）

憲法禁「替 NPC 寫行為」；**孿生條禁「把 scenario／平衡寫進引擎」**。同一條線的另一半。

> **引擎 = 通用機制，零 scenario 假設。所有「調得出好戲」的旋鈕活在 seed／環境參數層（暴露、可調、人格化）。believability 尺只判「參數／seed 選得好不好」，不改引擎。**

**三條推論**：
1. **規模／結局是 seed 參數，非模擬器不變量**：同一引擎該能跑 5 隊／500 隊、一統／永久分裂、雪球／並立——全由 seed／param 長出。**引擎不假設也不強求任何規模或結局**（「~50 隊」「多強並立」是 scenario 設定，不得漏進引擎當寫死假設）。gen／承載力重校 = 給某 scenario 調參，不是修模擬器。
2. **塑造行為的常數 = 參數／人格驅動，不埋魔術數字**：凡影響行為的閾值（preempt margin、cadence、intensity gate…）要嘛由**人格／世界參數**驅動（膽小者早逃、悍將晚動＝同一 margin 由謹慎度調製，非全域常數壓平差異），要嘛誠實暴露成 seed 可調。世界「多神經質／多勇／多動盪」該活在暴露的參數層，非埋死常數。
3. **believability 尺留在 QA／param 側，不越線變硬限制**：世界感覺不對 → 解法是**改 seed／param 或補缺的世界機制**，**永不是**硬塞行為規則（例：反龜縮的正解＝給忙碌者「感知威脅」的能力，非「逼 NPC 打」）。藍圖的尺判參數選得好不好，不改引擎。

**判準**：你在寫「**任何世界都成立的機制**」還是「**這個 scenario 該長怎樣**」？前者進引擎，後者進 seed／param。動盪不安靠 seed＋環境＋未開維度（正統／繼承／叛亂／天災）製造，不靠在引擎壓某個率。

### ★ 三個家：常數的終局歸宿（定 2026-07-06）

> 願景：**沒有一個埋死的全域常數偷偷替 NPC 做決定。** 但這**不等於「零數字」**——目標是每個數字都有正確的家，共三個：

| 家 | 是什麼 | 例 | 終局形態 |
|---|---|---|---|
| **NPC 判斷輸入** | 人格／記憶／現況 | 好戰、慎重、這隊是仇人、我剩幾天糧 | **決策側零全域常數**——全溶進個體判斷 |
| **個體物理屬性** | per-NPC 身體／能力 | 代謝、體力、tier、技能 | per-entity 屬性（非全域、非判斷） |
| **世界／seed 參數** | 作者寫的舞台規則（暴露非埋死） | 糧耗率、戰鬥致死率、hex 距離 | 暴露成 seed／env param（孿生條） |

**關鍵分辨**：「他餓了要不要逃／搶／投降」＝**判斷**（進第一家，溶進人格/現況/記憶）；「他一天需要多少糧」＝**物理**（進第二/三家，NPC 不 judge 它）。**硬把物理塞進判斷 = 破憲法另一半（作者寫世界）＝沒有舞台，NPC 在虛空裡判斷。**

- 這是**雙憲法合起來的極限**：沙盒憲法推到底＝決策側零常數（全 NPC 判斷）；孿生條接手剩下（世界物理→參數/屬性，非判斷）。
- **照妖鏡 backlog（決策側該溶的行為常數）**：`PREEMPT_MARGIN=2.0`、combat 潰退門檻 `0.2`（該士氣/人格化＝勇者血戰怯者先逃）、readiness 門檻、feud/scarcity 門檻…＝全歸「決策模型接線」線逐一人格化。**戰鬥物理（回合/傷亡/retreat→capture）＝世界側，留參數不動。**

## AI 深度：逐步逼近完整，節流閥非上限

目標是**逐步逼近完整 AI**（真會規劃、推理，非查表選項）。做法 = **每加深一步過四關**（節流閥，非固定深度上限）：

1. **真變好戲**：這步讓活世界跑出更好的 believable 戲（故事更好，非「AI 更聰明」的自嗨）。
2. **跑得動**：LOD-scale——深推理只給 named/重要實體，anon/遠隊維持淺。perf 是真天花板。
3. **看得懂**：保持可 trace（指標 specimen 看得到它的計畫/推理）。變黑盒 = 失診斷力。
4. **還在賺**：加深到觀者看不出差別就停那方向（邊際遞減）。

過關就再深一步、通不過就停——**要多深有多深、看每步值不值**。既非武斷上限（舊「≠完美 AI」的死框），亦非無底洞（AI 完美化鑽牛角尖）。**紀律本身是安全帶。**

推論：**查表（flat util / flat gate）是起點不是終點**。行為該由**目標→子需求→驅動動作**的 means-end 規劃湧現（富則貿易囤貨、窮則征服搶資源），維度自己平衡，非手動逐維度調數字。

### AI 深度 roadmap（逐步逼近，每步過四關）

**反饋現況（2026-07-02 盤點）**：
- ✓ 世界狀態反饋（結果改資源/pop → 下次輸入不同 = 複利弧主迴路）
- ✓ 信息域反饋（口碑/識破/查證 = 真經驗學習，G3）
- ✓ 人格固定（by design 保分歧——全員從經驗優化會同質化，違「連貫≠同質」）

**深化一（done）**：intent→子需求→驅動戰術動作（`intent_fit`）。致富→貿易囤貨、征服→raid、匱乏→搶。

**深化二（候選，長窗觸發）**：**blocker→子需求**——目標被 gate 擋時，AI 知道「為何被擋」並把 blocker 變成子需求驅動行動（想立國卡糧→特意去攢糧；想結盟沒聲望→先做人情）。+ 選擇性遞迴一層（填補行動自己的前提）。
- **零新判斷器**：gate-ladder 探針的「為何被擋」信號已存在，AI 自己當消費者即可（同一信號、多一個 reader）。
- **觸發條件**：長窗數據見狼卡在「可解的 gate」前乾等（想立國不去湊盟友）= 該上的證據。
- LOD：深推理只給 named 主角。

**經驗=自己的 claim（G3/belief 擴充帶上，非新 arc）**：「經驗→行為傾向」fold 進 belief 域——被伏擊過→「那山谷危險」= 一條親見高信 claim → 決策讀 belief 自然避開。**記憶就是情報、經驗就是自己給自己的 claim**，零新學習系統。劇烈經驗塑造人格（慘敗→怯戰）= Trait 縫（第四脊椎，排隊）。

## ★ 遭遇 = 統一反應（憲法旗艦案例，定 2026-07-05）

威脅、貿易、外交、仇殺、掠奪——**不是五套系統，是同一件事的不同結局**：

> **「我的隊撞見另一支隊，我怎麼辦？」**

**一次遭遇 = 感知 → 引擎秤 → 挑一個結局。** 「友軍不理／敵軍戰逃／陌生去接觸」不是寫死的岔路，是同一個秤餵進不同的關係＋軍力，自然掉出的不同輸出：

| 讀到（關係＋軍力） | 湧現結局 |
|---|---|
| 友軍 | 不理／打招呼／順路貿易 |
| 宿敵＋我強 | 攻擊／掠奪 |
| 宿敵＋我弱 | 逃／備戰／求和 |
| 陌生＋不緊迫 | **派斥候／使者探底** |
| 陌生＋壓境能殺我 | 繃緊／先發制人（可能誤判釀仇） |

**★感知鐵律（可信度命脈）**：威脅／身分感知**只吃「看得見的表象」（數量／逼近／可見武裝）＋「已知關係」（盟友／宿敵）**；**不吃對方的 tag（商隊/軍隊/山賊）或真實意圖**——遠看根本分不出。**分不出就照最壞繃緊**（但「繃緊」可以是「派斥候」不必是「恐慌」）。這生出湧現好戲：**虛驚**（繃緊備戰結果是路過商隊）與**誤判釀仇**（先發制人射了一箭、結下本不存在的仇）。禁止任何「偷讀對方真身份→放鬆」的優化，那會把可信度打回 bug。

**★深度靠感知非規則（防坑鐵律）**：世界要更有深度，做法是**讓世界更多狀態可被感知**，讓同一引擎自己算出反應——**不是為每種社交組合寫一條新反應規則**（組合爆炸＝深度 AI 墳場）。

推論到 N 方（A 看到 B、C 交戰）：**不建三方交戰處理器**。做法＝把「交戰中／被打殘／威脅落在盟友身上」變成**可感知的世界事實**，則背刺殘敵、馳援盟友、撿尾刀等戲**自己長出來**（我們觀察，不腳本）。順序：先做完**兩方遭遇**的統一反應；N 方是它的**湧現延伸，靠加可感知事實非加規則，觀察後按需一次一個、每步過四關**。
- 成本標注：**背刺被打殘的敵人 ≈ 免費**（capability-grounding 已讓弱目標＝好打，只要讀對方當下戰力）；**馳援被圍盟友 = 要新增一種感知**（威脅落在盟友身上，現在威脅只算「對我」）＝有真成本，**不反射式建，等觀察到世界缺這齣戲再說**。

# 引擎裁定（2026-07-03，免未來重議）

**留 Godot（GDScript）**，理由：
1. **迭代速度=主資產**：GDScript 低摩擦撐起 measure→fix 高頻循環（本專案方法論的命脈）。headless 一等公民（整套 harness 靠它）。2D 地圖+面板=觀測 GUI 甜蜜點。
2. **願景已把世界 size 進引擎能力**：1-2 代尺度 + per-tick 有界硬不變量 = 世界刻意有界，有界世界內 GDScript 夠用。
3. **perf 病至今全是演算法非語言**（O(N²)/cadence 24×/die-off spike 全是設計 bug，修完 median 237μs @N~100）。

**重新考慮的條件（三者之一才議）**：①願景變千隊大世界 ②要 3D 表現 ③**量到**某 hot loop 演算法修無可修、純語言慢（至今零例）。

**退路（不換引擎）**：Godot C#（4-10×）/ GDExtension（Rust/C++ 原生速度），只抽模擬熱核、UI/loop 留。**統一 program（單寫者 bank/chokepoint/單一決策引擎）正在把熱核邊界鋪乾淨 = 燒矩陣同時在降未來移植成本。**

**引擎契約 = per-tick 有界不變量**：守著它，Godot 撐到出貨。

# 完整沙盒願景（定稿 2026-07-02）

> 藍圖×用戶願景討論定稿。**先做出完整模擬沙盒、玩家最後薄鏡頭貼上**（沙盒優先，非 MVP 玩家優先）。之後燒地基照此對齊、缺料回頭補。

## 設定 + 尺度
- **亂世**：五代十國 / 中西方嚴重戰亂期。武力割據、政權一代而亡。
- **時間尺度 = 1-2 代**（perf 倒推：玩家要「早晚期無延遲差」→ 世界大小全程有界 → 跑不了太多世代）。1-2 代 = 一個人的史詩 + 一次繼承交棒，剛好一個完整弧。
- **靈魂一句**：**「軍事易得，正統難守，傳承更難。」** = 那時代的戲，也是現在最缺的一半。

## 七維度（世界的 substance）
1. **經濟**：生產/貿易/財富（地形特化→交易網）。〔🟩 戲成〕
2. **征服/軍事**：崛起/戰爭/捕俘吸收。+**地理骨架**（河流/天險/咽喉/邊界=守江搶關的戲；河流未來項，成本=邊/線資料模型）。〔🟨 差 capture〕
3. **資訊**：belief/霧/欺敵/情報戰。〔🟨 Phase E 好、D queued〕
4. **正統/宗教/文化**（身分/信念層，接 G3）：**正統=誰該當王的 belief**（軟實力、可情報戰爭奪、無正統=篡逆短命）；**宗教=正統來源+身分群**；**文化=同化/內外別**（征服土地易、征服人心難）。〔🟥 未開〕
5. **關係/人物網**：忠誠/血脈/**聯姻**/世仇/結義（RelationGraph 現孤兒，需接線當 driver）。聯姻=綁盟+生嗣+跨文化的政治樞紐。〔🟥〕
6. **生命週期/繼承爭位**：生老死 + **爭位**（諸子/篡奪/幼主/弒兄），非只嗣位。**+性別屬性**（男嗣/無子之憂/過繼/女主/外戚；聯姻嫁女；戰損扭性別比=人口傷疤）。1-2 代的戲鉸鏈、第二幕。〔🟥〕
7. **天災/事件**（外生危機引擎）：歉收/地震/**洪水**…擾動 world-state → agent means-end 回應（接「匱乏→搶」）；創造+破壞（生新礦=淘金潮）；機率綁地理非純 RNG；**天災→belief「天命失」→正統跌→反**（天譴）。〔🟥 event 系統在、待擴〕

## 五底線（非維度，是全程要守的）
- **AI 深度**：逐步逼近完整（規劃/欺敵/記憶），節流閥四關。〔🟨 第一深化過〕
- **統一架構**：矩陣逐格燒 + 強制閘守退化。〔🟨 旗艦格燒完、剩約 6 成〕
- **per-tick 有界**：早晚期無延遲差＝硬不變量（世界大小全程有界；die-off spike 必收）。〔🟨 P0 加固、die-off 未收〕
  - **★世界統一 fidelity=不容相機選贏家（用戶定 2026-07-18，「命運不看玩家臉色」信念層）**：規模 perf **不得**靠 near/far LOD 雙-fidelity（便宜遠/貴近）——雙 fidelity 必然非中性（近 player 隊多拿 regen/outpost/reactions→系統性變強＝相機選贏家，破沙盒 bar「觀測改被觀測物」）。**廢 LOD 雙-fidelity**；正典=全隊等值模擬。規模靠**空間有界互動（掃近隊：只 scan/評估感知鄰近隊，＝感知鐵律正解）+ belief/message 傳遠方資訊**，非降級遠隊。
  - **★兩 channel（用戶戳出漏洞後補，2026-07-18）—— 遠方高危險不得隱形**：naive「只看半徑內」會讓遠方強敵進半徑前隱形＝盲區。修＝分兩路：**①掃近隊＝直接感知（空間、即時、精確）**＝O(N²) 成本所在，bound 這個省 perf；**②belief/情報網＝你知道的（近+遠、延遲、不確定、decay）**＝遠方危險經斥候/逃難者/商旅傳「大軍壓境」落進 belief，你對 belief 反應（備戰/結盟/逃）。非 god-view，是有霧降級情報，比現行瞬間精確 god-view 更真實。「近vs遠」非懸崖＝belief `uncertainty` 隨距離/時效 decay 的 confidence 梯度（模糊遠聞→派斥候；確認近敵→全動員）。
  - **★硬約束（成敗前提）**：掃近隊**絕不能讓遠方高危險隊消失**→ 設計硬要求「危險必須經情報網傳到你，獨立於直接掃」。若 belief 只從直接掃填→bound 掃＝盲區＝方法破，得先建「危險會傳播」。**情報網夠不夠帶『遠方威脅擴張』awareness＝systems R① make-or-break 必驗前提**（belief/message/inquiry 骨架在，充分性未證）。
  - **★決策考慮集 ≠ 當下視野（用戶再戳 2 案，2026-07-18）**：掃近隊只 bound「直接感知的**更新成本**」；**決策讀的是持久+顯著的 belief，非 raw 視野**。二精確化：
    - **①持久（抗 flicker/隱蔽）**：看過一次→進 belief（last-seen + confidence 逐漸 decay）；隱蔽/閃現（這 tick 看到下 tick 沒）**不瞬間忘**，belief 撐著→續對「剛那有敵」反應。殺 flicker-thrash（看到→反應→沒看到→忘→再看→再反應 抖動）；決策由持久 belief 驅動非瞬時可見性（連跨線才換道反 thrash 原則）。position-landmine 的極端版（belief 不 per-tick reset）。
    - **②恩仇永久記憶層（用戶定 2026-07-18，升級「不能忘」）**：決策考慮集＝**掃近隊（當下感知鄰隊）∪ 顯著記憶（世仇/恩人/已知大勢力/重要關係）**，後者**無視空間距離**——宿敵走出視線不從盤算刪。**兩層記憶**：短暫感知（路上隨瞥某隊）＝會 decay、有 cap；**重要記憶（恩仇/世仇/恩人/重要關係）＝永久，免疫 decay 與 cap 淘汰**（一輩子記得）。非「salience decay 慢」是「根本不淘汰」。
    - **perf 仍安全**：短暫感知 belief 有 cap（`MAX_CLAIMS_PER_OBSERVER=200`/`MEMORY_MAX`）+ decay；恩仇永久層 bounded（1-2 代世界、隊數有界→一個人結的「有意義恩仇」天生就少）→ 決策 iterate＝nearby(k)+永久恩仇(m) 皆 bounded，不退 O(N²)。**R① 加驗**：既有 belief 真有 persist+decay？恩仇永久層存在還是均勻 decay（會忘宿敵）？別假設。
  - **★★冷啟動悖論 + 創世 god-view 違憲（用戶戳出，2026-07-18，此 arc 頭號主樑）**：嚴格憲法（無全知、訊息靠實體傳播）下創世人人全盲→「怎貿易/外交/探索」？grep 坐實**現行作弊**：`game_setup.gd:569-578` 創世把**每隊塞進每隊 `team_discovered`＝人人開局全知＝違憲**，短路掉「資訊碎裂（`line 63` 遊戲前提）→發現弧」全部核心戲。**正確機器已存在**（`vision_system.tick_discovery`：本地視野半徑3+偵查技能+地形+隱蔽 gated 發現鄰隊＝憲法正確 discovery），只被創世作弊蓋掉。
    - **修＝拔創世 god-view seeding，改創世知識＝②+③ 混（用戶定 2026-07-18）**：創世知道＝**自己派系 + 本地地理鄰居 + 有淵源對象（傳統盟友/世仇）**；陌生遠方一律未知，玩中發現。justify：派系＝你的人且互相 relay（channel ②）；本地＝你知道你山谷有誰；淵源＝接恩仇永久記憶。**保留碎裂（遠方未知→探索/傳播/資訊戰有得玩）+ 不凍死（政治+地理保底 bootstrap，避開沙盒最大 fail「凍死」）。** 選型棄①純湧現（孤立隊凍死盲風險）、棄現行全知作弊。
    - **bootstrap = 本地先行→擴張**：第一筆貿易/外交/戰在視野+創世知識內（`diplomatic_ai:132`、`_find_trade_target` 已讀 `team_discovered`）；探索（need-驅動移動→vision 揭鄰）+ 傳播延伸觸角。**make-or-break（systems R①）**：拔全知後 need-驅動移動夠不夠 bootstrap 不凍？不夠→補輕量探索/好奇驅動 or 收窄創世 seed 半徑。同「危險會傳播」make-or-break 家族（belief populate 必須冷啟動就 work）。
    - **★★make-or-break 驗出反面：「派系互相 relay」的 discovery 假設不成立（2026-07-20，Slice B reviewer 異質載重坐實）**：`team_discovered` 寫入只經創世 + 直接視野（`vision_system`），**relay/message 從不寫 discovery，只傳已識隊的 belief 更新**——上面「派系＝你的人且互相 relay」「傳播延伸觸角」的 justify **機制不成立**，後-B discovery 曾是純 proximity-driven（永不經「聽說遠方有隊」而 discover）。**裁：(b) relay-discovery 需建**（非新願望，是兌現本段原有 justify + make-or-break 前置承諾）——relay/message 傳到且提及未識隊時，連帶觸發最小 discovery（`team_discovered=true`+初始粗糙 belief entry）。**範圍收窄**：只求這個最小閉環，不建含率/延遲/失真的完整情報網模型（那是「資訊操控維度」的活，見 `docs/notes/2026-07-19-info-warfare-verbs-brainstorm.md`，observe-gated 排後面）。併入 B 擴，非另開 arc。
  - **★世界特徵也 belief-gate（非只隊）+ 永遠要傳播、零豁免（用戶定 2026-07-19）**：「無全知」套所有東西——市場/糧點/資源/地形亦然。**一切知識只經傳播/發現進 belief，無「公開地標豁免」例外**（否決 invariants:186 舊裁）。
    - **市場（C 裁）**：現行 `has_food_market`/`_nearest_market_outpost` 掃全圖（`known_issues:35`/`invariants:186` 衝突）＝god-view 後門，堵。**市場存在/位置永遠經傳播習得**（去過 or 聽過），無豁免。**名市場≠豁免，是名聲高傳播率→自然廣傳進多數隊 belief**（與世隔絕沒聽到的隊就是不知道）。**「地標」只剩物理事實**：市場固定不會動→位置 belief 一旦習得就可靠（不像移動軍隊要重估）；但**取得永遠靠傳播**，且 STATE（還在營運?被毀?）可過期、待新傳播更新。
    - **∴ 系統改 `invariants:186`**：market 從「公開地標豁免 belief」→「belief-gate 如萬物，名聲高傳播率自然廣傳，位置固定故習得後穩定」。生存/經濟決策讀 belief 的已知市場，非全圖掃。
  - **★資訊地基早設計好（`game-design:765-964`）—— 此 arc＝落地+強制，非新設計**：`line 396`「感知鐵律＝O(N²)修法同一約束…感知-local 掃描同治 believability+perf」正是掃近隊洞見；765-964 已細設 無全知/傳播/來源可信/失真/技能=理解。**此 arc 工作＝堵所有 god-view 後門（belief-gate 隊+世界特徵+拔創世 seeding）+ 掃近隊 bound perf + 加恩仇永久層 + 創世②+③**。**主動情報操作（捏造/放謠言）＝情報操控維度 defer（`line 909` 明訂非急），非此 arc**（＝用戶定「地基非操控」scope 線）。
  - HOW（掃近隊怎麼 bound O(N²)、radius 定義、創世 seed 實作、feasibility）＝系統（handback `2026-07-18-blueprint-to-systems-drop-lod-scan-nearby` + refinement + awareness-arc-scope，R① 前提待驗）；排 B enabler（經濟 sustainability 之後）。
- **敘事可見**：史書/編年，讓自生的戲看得到（沙盒 bar「好看」的眼睛）。**史書本身是 belief 產物——勝者寫史、可偏可篡=敘事本身就是正統/情報戰**。〔🟥〕
- **玩家面**：玩家=最後薄鏡頭（player=agent 對稱，統一架構讓它便宜）；**自訂沙盒 + 起始劇本**兩模式。〔🟥〕

## 連結網（維度互扣）
- 經濟→權力（財富買忠誠/養兵/贊助宗教換正統）
- 天災→正統（天譴）
- 聯姻→正統+文化+繼承（一樁婚三效）
- 勝者寫史→正統（敘事即情報戰）
- 匱乏→征服搶資源（means-end 已建）
- 文化異→同化難（受控人力）

## 現況分界
- **在飛**：1 經濟 / 2 征服 / 3 資訊 + AI 深度 + 統一架構 + per-tick。
- **未開（未來大塊）**：4 正統宗教文化 / 5 關係聯姻 / 6 繼承爭位性別 / 7 天災 / 敘事可見 / 玩家面。
- **「軍事易正統難傳承更難」那組（4/5/6）= 靈魂、現在最缺的一半。**

## 燒序方向（大方向，非鎖死）
```
現在: 燒完統一矩陣(1/2/3 + 單寫者/互動收) = 地基
  → 4 正統宗教文化(接 G3,征服者要坐穩)
  → 5 關係聯姻(RelationGraph 接線)
  → 6 繼承爭位性別(1-2代鉸鏈)
  → 7 天災(危機引擎,可較早插=便宜加戲)
  → 敘事可見(讓上面看得到)
  → 玩家面(最後薄鏡頭) ‖ 地理/河流深化(征服維度深做時)
```

---

# 時間系統

# 統一時間尺度

整個世界使用統一時間系統。

無論：

- 大地圖
- 遭遇戰
- 行軍
- 生產
- 治療
- 建造
- 傳令
- 季節變化

都使用同一套時間。

世界不存在「切換場景後時間凍結」。

---

# 半即時回合制

遊戲採：

> 半即時回合制與回合制切換

世界持續推進。

但玩家可：

- 暫停
- 下達命令
- 規劃路線
- 管理隊伍

避免即時操作壓力過大。

---

# Tick 設計

世界以固定 Tick 推進。

建議：

- 1 Tick = 10 秒

避免過細模擬導致：

- AI 運算爆炸
- CPU 壓力過高
- 遊戲節奏過慢

本作核心是：

- 決策
- 情報
- 社會互動

而不是高速操作。

---

# Turn 與 Tick 定義（D-004 對齊）

- Tick：世界最小模擬時間單位。
- Turn：玩家操作節點，不是最小時間單位。

目前建議：

- 1 Turn = N Tick（N 可配置）
- 回合制：玩家移動 1 格推進 1 Turn
- 半即時回合制：依真實秒數累積 Tick，達到 Turn 門檻後更新需要 Turn 粒度的系統

這可確保：

- 大地圖移動
- 遭遇戰
- 情報延遲
- 聚落演化

使用同一個時間基準。

---

# 地圖系統

# 六角格世界

大地圖與遭遇地圖皆使用：

- 正六邊形格

原因：

- 路徑自然
- 移動距離一致
- 方便行軍與包圍
- 更適合戰術移動

---

# 世界尺度一致

遭遇戰與大地圖不是不同遊戲。

而是：

> 同一個世界的不同縮放。

例如：

若遭遇戰地圖從一端走到另一端需花費 M 單位時間。

則大地圖移動一格也需花費 M 單位時間。

這讓：

- 增援
- 傳令
- 包圍
- 撤退
- 截擊

都能自然成立。

---

# 行軍系統

移動速度受：

- 人數
- 地形
- 天候
- 負重
- 疲勞
- 組織度
- 馬匹
- 傷員

影響。

大規模隊伍不可能高速移動。

---

# 資訊系統（核心）

# 資訊不是共享的

世界中不存在全知資訊。

角色只知道：

- 自己親眼所見
- 別人告知的事情
- 傳聞
- 推測

因此：

- NPC 不知道玩家做過什麼
- 聚落不會立刻知道戰爭結果
- 命令不會瞬間傳達

---

# 資訊傳播

資訊需透過：

- 對話
- 商旅
- 流民
- 信使
- 軍隊
- 隊友
- 官方公告
- 書信

等實體單位傳播。

傳播會受到：
實體單位影響
- 傳播次數
- 傳播失真
- 人為操作

影響。

---

# 資訊來源

不同來源具有不同可信度。

| 來源 | 特點 |
|---|---|
| 親眼所見 | 高可信 |
| 隊友描述 | 中可信 |
| 商旅傳聞 | 延遲較高 |
| 酒館謠言 | 容易失真 |
| 官方公告 | 可能帶政治目的 |
| 書籍紀錄 | 可能過時 |
| 流民消息 | 情緒化且混亂 |

---

# 資訊可信度

每條資訊可擁有：

- 來源
- 時間
- 信任度(高低可影響NPC的決策)
- 是否被驗證(這該如何判斷? 或是拿掉這個由玩家自己判斷)

例如：

| 情報 | 來源 | 時間 | 信度 |
|---|---|---|---|
| 北方有盜匪 | 商人 | 3天前 | 中 |
| 城主重病 | 傳聞 | 昨晚 | 低 |
| 糧倉被燒 | 親眼目擊 | 今日 | 高 |

---

# 資訊失真

NPC 不一定會正確傳遞資訊。

NPC 可能：

- 誠實
- 隱瞞
- 扭曲內容
- 惡意欺騙
- 道聽塗說
- 不懂裝懂

---

# 資訊傳達方式

目前設計：

NPC 傳播資訊時可能：

1. 如實傳達
2. 扭曲內容
3. 不進行傳達

未來可擴充：

- 部分隱瞞
- 加入個人偏見
- 誇大內容
- 簡化內容

---

# 情報操控

資訊可被主動操作。

例如：

- 散播謠言
- 偽造軍情
- 假傳命令
- 收買信使
- 隱瞞疫情
- 封鎖消息

這可能成為後期核心玩法之一。

## 情報操控接線現況（2026-07-06 盤點：捏造缺口，但框架放得下）

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

## ★★ belief/知識 store 模型（brainstorm 定案 2026-07-19，awareness arc 地基）
> 承「永遠要傳播、零豁免」+ 感知鐵律。決策讀 belief（會錯/舊/被騙的知識），非真值。此節定 belief store 怎麼組織。HOW（schema/migrate，**byte-identical refactor 驗**）＝系統。

**1. 現況兩 store（泛化目標＝統一）**：訊息（`team_known`＝事件流，TTL 過期，carrier 相遇傳）+ 信念（`team_intel[obs][tgt]`＝對某隊 multi-claim 估計，可信度/失真/口碑成熟）。→ 泛化成**一個統一知識 store**，鍵 entity（隊/世界特徵/…），方便擴充（用戶定 #1：擴充性優先）。

**2. 三級 volatility（decay 配「被記物變多快」）**：
- **永久**（存在/身份/恩仇/市場位置）：免時效衰減，只被**矛盾事件**翻（razing/背叛/死亡）。
- **低頻**（leader/派系/佔哪據點）：繼承/政變/征服**事件**更新，不時效衰減。
- **高頻**（位置/戰力/情緒）：時效衰減 + 過期→未知（現 `belief_pos` 3 天已是此級，推廣至全高頻層）。
- **★「淘汰整隊」＝bug 病根**：分層後，過期只讓**高頻→未知**，entity + 永久層**永不消失**（你記得誰是頭、是你世仇，只是不知它現在在哪多強）。

**3. 不做硬 eviction，留全部 + 決策時 filter（用戶定 2026-07-19）**：
- 拆開「記憶體 bound」vs「決策相關性」（原 eviction 混這兩者→生出「刪整隊」bug）。相關性＝**決策時 filter**（fresh OR 重要才納入考慮集；過期+不重要＝記得但不判別），**不刪資料**。
- 永久層留一輩子（cheap，有界世界 met-entities 有界）；高頻層**古老無用可丟**（省記憶、不損決策、不忘身份）。

**4. monotonic id（單一源，硬前置 + 修確認 bug）**：現 `_next_team_id`＝`max(live)+1` → **回收死 id → belief 冒名頂替 bug**（team100 死→重用→新舊 entity 混）。修＝持久遞增 counter，死 id 永久退休，收 **7 份 team-id 重複**（game_setup/subteam/manpower/population/reaction/recruit_tutorial/**event_unrest_split**，systems exhaustive 坐實）+ **2 份 person-id**（game_setup/recruit_tutorial）成單一源。`_next_beast_id` 用負區段遞減＝已 monotonic 正範式（fix 參考）。**belief key 必須是永久穩定身份。**

**5. 恩仇掛人 vs 掛團（雙 key）**：跟人的仇隨人走（政變下台則跟下台者，`RelationGraph` 現孤兒/未接）、跟團的仇留給團。belief key 支援兩種；真接 RelationGraph＝關係維度（維度5）後續。

**6. 世界特徵 belief（gap A）**：市場/據點/資源＝知識 store 的 entity，存在永久、當前存貨高頻，**發現(vision)/聽說(message) 才進**，非全圖掃 god-view（修 `has_food_market`）。

**7. message→belief 橋（gap B）**：事件訊息到達 → 更新對應 entity 的 belief（**成長事件→實力估計↑→威脅判斷看得到成長**；威脅＝判斷非廣播，接 Slice D 讀 belief）。現兩 channel 部分脫節，要接。

**8. 隊數有界 + belief 安全閥（robustness，極端 case）**：
- **隊數 bound ＝ belief 與 perf 共用前提**（一人隊非 viable + anon-cohort 守 mass + named 升階有率；掃近隊本假設有界）。「全升 named + 各自成隊」＝打爆 anon-cohort 模型，源頭該擋。
- **belief 安全閥（縱深）**：正常留全部；**高水位只砍垃圾**（無關係 + 早死 + 只瞥一次的一人隊），**永不砍恩仇/大勢力** → 極端下優雅降級非爆。

**序**：**monotonic id ＝硬前置**（belief key 前提，也是乾淨 unification 6→1）；其餘接 awareness/god-view 殲滅 arc。HOW＝系統。

---

# 認知系統

# 玩家看到的是角色認知

玩家 UI 不顯示絕對真相。

玩家看到的是：

- 主角理解
- 傳聞
- 推測
- 不完整情報

例如：

不是：

「敵軍 300 人」

而是：

- 「似乎有大量敵軍」
- 「有人說超過百人」
- 「可能存在騎兵」

---

# 技能 = 理解能力

技能不只是數值。

而是：

> 「角色理解世界的能力」

---

# 技能不足

低技能角色可能：

- 無法理解事件
- 得出錯誤結論
- 被誤導
- 無法辨認專業資訊

例如：

醫術不足：

- 看不懂病因
- 相信偏方
- 無法辨識感染

軍略不足：

- 看不懂包圍
- 無法判斷伏兵
- 無法分析補給線

---

# 技能揭示

當技能達門檻後：

玩家可：

- 察覺矛盾
- 看懂專業內容
- 發現謊言
- 理解隱藏資訊

因此：

> 世界真相會隨角色成長逐漸展開。

---

# 「不知道自己不知道」

低技能但高自信 NPC ：

- 可能非常自信地講錯話

高技能但保守 NPC：

- 反而會保留意見
- 承認不確定性

這讓世界更接近真實人類社會。

---

# 玩家角色

# 主角控制

目前版本：

- 玩家可完全控制主角
- 主角沒有士氣限制
- 主角沒有價值觀限制

避免玩家失去操作權造成挫折。

---

# 身體限制

雖然沒有心理限制。

但主角仍受：

- 疲勞
- 飢餓
- 疾病
- 缺氧
- 傷勢

等物理條件影響。

---

# NPC 系統

# 聚合模擬

大部分 NPC 將以團體為單位。

遠離玩家時：

NPC 會以群體方式運算。

例如：

- 人口
- 資源庫
- 生產力

降低 CPU 消耗。

---

# 高重要 NPC

與玩家深度互動後。

NPC 才會生成完整人格。

包括：

- 技能
- 性格
- 價值觀
- 關係
- 記憶
- 好感
- 目標

---

# 玩家 Team 組成

玩家 team 以記名 NPC（named_members）為核心，但技術上支援混合：主隊可同時有記名成員與匿名人口（population - named count）。

**招募與吸收規則：**

- `recruit`：從外部 team 拉走低忠誠度記名成員，加入玩家 named_members
- `recruit_anon`：花費 coin 從外部 team 招募匿名人口，直接加入玩家主隊人口（匿名，不記名）
- 吸收（subjugate）時：
  - 被吸收方 leader + named_members → 玩家 named_members（已記名，直接加入）
  - 被吸收方匿名人口 → 自動成為跟隨子隊（parent_team_id = 玩家 team）

**設計意圖：** 玩家隊伍長期應以記名成員為主（可互動、可指令、有個性）。匿名人口可存在於主隊，但無法個別操作，視為背景人力。

玩家可透過「主動招募」晉升匿名人口為記名 NPC（PersonGenerator，待實裝）。

---

# NPC 目標

NPC 不只是狀態機。

NPC 可具有長期目標。

例如：

- 想活下去
- 想復仇
- 想發財
- 想獲得地位
- 想建立家族
- 想逃離戰亂

這些目標會影響：

- 行動
- 合作
- 忠誠
- 欺騙
- 背叛

---

# 社會身份

角色可能具有：

- 農民
- 商人
- 士兵
- 貴族
- 流民
- 僧侶
- 奴隸
- 盜匪

身份會影響：

- 社會地位
- 指揮權
- 法律待遇
- 情報來源
- NPC 態度

---

# 記憶系統

# 核心記憶

角色不記錄所有事情。

只記錄：

> 對情感與人生具有重大影響的事件。

例如：

- 被救援
- 被背叛
- 並肩作戰
- 家人死亡
- 被羞辱
- 被搶劫
- 長期照顧

---

# 記憶影響

記憶會改變：

- 信任
- 好感
- 仇恨
- 恐懼
- 忠誠
- 依賴

---

# 記憶強度

記憶具有強度：

- 輕微
- 深刻
- 刻骨

部分記憶會隨時間淡化。

但重大創傷可能永久存在。

---

# 社會與勢力

# 聚落需求

聚落需要：

- 糧食
- 水源
- 安全
- 勞力
- 武力
- 生產工具

才能持續存在。

---

# 社會崩潰

--補充 這部分我們用團體為單位

若需求不足：

可能導致：

- 飢荒
- 治安惡化
- 人口流失
- 流民化
- 叛亂
- 土匪化

例如：

農民可能變成：

- 流民
- 傭兵
- 盜匪

---

# 生產型群體

依靠：

- 農業
- 製造業
- 交易

維持生存。

---

# 武裝型群體

依靠：

- 徵收
- 支配
- 掠奪
- 保護費

獲取資源。

---

# 法律與習俗

不同地區可能：

- 擁有不同法律
- 擁有不同禁忌
- 擁有不同文化

例如：

- 禁止私藏武器
- 外地人不得入村
- 禁止女性參戰
- 某族群不可信

這會影響：

- NPC 態度
- 情報交流
- 行動限制

---

# 地圖探索

# 地圖資訊不完整

玩家不會一開始知道：

- 所有道路
- 所有聚落
- 所有資源點
- 所有勢力範圍

需要透過：

- 探索
- 詢問
- 購買地圖
- 商旅情報

逐漸掌握。

---

# 世界不是平衡的

世界不是公平遊戲棋盤。

有些地區：

- 天然富庶
- 易守難攻
- 商路繁榮

有些地區：

- 常年飢荒
- 匪患嚴重
- 資源稀缺

有些勢力會遠強於其他勢力。

這是世界的一部分。

---

# 遭遇戰系統

# 小規模戰棋

遭遇戰使用：

- 六角格
- 半即時回合制

---

# 指揮延遲

命令不是瞬間傳達。

角色只有在：

- 聽見
- 看見
- 接到命令

後才會行動。

---

# 指揮影響因素

傳令效率受：

- 地形
- 天候
- 距離
- 訓練
- 指揮鏈
- 士氣

影響。

---

# 視野與感知

角色只能感知：

- 視野內敵人
- 可聽見的聲音
- 已知情報

因此：

- 伏兵
- 夜襲
- 誤判

都可能發生。

---

# 戰鬥解算與敗北模型

## 全員潛在戰力

戰鬥不分「戰兵」與「旁觀者」。

全隊都是潛在戰力。

> 戰鬥重量 = Σ 各人人均戰力（依 tier 與武裝）× 參戰意志

- 平民人均戰力極低；老兵 / 菁英即使無武裝仍有戰力（會抄傢伙、會反抗）。
- 「有沒有武裝」與「tier 高低」是兩條獨立軸，不可混為一談。一個沒武裝的菁英 ≠ 農民。

## 人數有用，但有代價

一群平民能拉下武裝菁英——但：

- 人數品質重扣（50 名平民 ≈ 數名戰兵的重量，非 50 倍）
- 圍殺成功仍屍橫遍野（菁英死前先拖走十數人）

人海不會自動獲勝。

## 參戰意志

平民默認會逃（潰散），不站著等死，也不無腦群起。

只有絕境 / 無路可退時，意志拉高 → 死守、人海拚命。

沿用既有絕境驅動（desperation × values）：戰場死守＝同一原理套用於戰鬥。

## 敗北結果落全隊

勝負結果套用到敗方整隊 pop，按 tier 與角色加權：

- 平民承受最重（陣亡 / 被俘 / 潰散）
- 訓練兵多半生還、逃脫、反抗

因此「打到死」可能成立（一直打 → pop 漸減 → 滅團），但**非預設**；多數敗北是潰散 / 投降，殲滅是絕境的稀有結果。

**殲滅端稀度（rev2 定案，2026-07-10）**：殲滅機制在——但只在**雙方都高勇氣、勢力/pop 完全均等（str/pop≈1.000）的死戰**才觸發（合成床證 brave×brave 45%）。organic 世界裡此交集雙重窄縫相乘（高勇氣小隊本就少進絕境戰 × 敵方也需高勇），實測 219 場戰鬥 annih=0.0%。**設計上接受殲滅端在正常遊玩實質不可見**——它是理論賭注地板（正因全滅可能，逃才有重量），非常見收場。敗北常態＝逃/潰散（~83%）＋俘虜（中頻）。不為拉高殲滅率而放寬 courage 窗（那會稀釋「殲滅＝勇者專屬殘局」質感）。

**輸的代價載體＝追擊，非戰鬥內全滅**：殲滅可見與否不損賭注地板——敗北的真實痛感由**追擊三管道**扛（`npc_combat_system._apply_pursuit`）：①戰術追擊每次逼退放血 pop×PURSUIT_RATE(5%)、②潰逃殘部被俘（`capture_routed_as_captive`，organic 敗北收場中頻端）、③戰略追擊跨 tick 依 intel 刷 move_target 持續逐擊。故「逃」非安全脫身，只是把代價從「一次全滅」攤成「放血＋被俘＋地盤/資源損失」。追擊放血漸進（5%/次）＋捕獲/脫逃先收場 → 這也是 organic annih=0 卻仍有敗北後果的機制解。**殲滅可見度或隨 consolidation（隊整併變大→combat 有長度→均等死戰交集更常觸）自然升**，不必調 spread。

投資訓練（老兵 / 菁英）不只提升打擊，也提升敗仗存活——tier 因此有了生存價值。

## 損耗 / 俘虜 / 潰散：同一模型兩端

- 損耗（傷亡連坐全隊 pop）＝ 高烈度結算端。
- 潰散 / 投降 / 被俘 ＝ 低參戰意志端。

兩者非兩塊補丁，而是同一「重量 × 意志 → 結果」模型的兩端。屠 / 俘 / 放的最終命運裁定，歸戰俘處置設計。

## 對稱性

NPC-vs-NPC 與玩家遭遇戰共用此模型；無「玩家專屬的不可殲滅大軍」。

---

# 死亡與繼承

# 死亡不是結束

玩家死亡後。

可選擇 NPC 繼續遊玩。

可能是：

- 隊友
- 村民
- 後代
- 同勢力角色

---

# 世界歷史

世界會留下歷史痕跡。

例如：

- 廢棄村莊
- 舊戰場
- 被燒毀城市
- 古代遺跡
- 前任玩家留下的據點

讓世界具有歷史感。

---

# 開發優先順序

# 第一階段（核心）

最優先：

- 時間系統
- 六角格世界
- 基礎移動
- 資訊傳播
- 遭遇戰原型

---

# 第二階段

加入：

- NPC 關係
- 核心記憶
- 傳聞系統
- 技能揭示
- 聚落需求

---

# 第三階段

加入：

- 勢力演化
- 經濟循環
- 情報操控
- 長期歷史
- 社會文化差異

---

# 第四階段（遠期）

可能加入：

- 語言差異
- 宗教
- 深層政治
- 繼承與家族
- 多世代歷史

---

# 核心體驗

玩家不是全知者。

而是在：

- 不完整資訊
- 謠言
- 欺騙
- 延遲
- 社會壓力
- 生存需求

中做出決策。

真正重要的不是：

- 數值
- DPS
- 裝備稀有度

而是：

- 誰知道什麼
- 誰相信誰
- 誰願意合作
- 誰在操控資訊

---

# 玩家核心迴路（資訊不對稱下的崛起）

玩家體驗 = 崛起弧 × 資訊迷霧。

崛起（生存→招人→據點→勢力）是**目標**；資訊不對稱是**玩法**。

> 玩家不是上帝視角霸主，是靠情報在迷霧裡往上爬的人。
> 靠「知道得比別人準」贏，不只靠打得贏。

## 迷霧校準（中霧）

- **可靠**：自己 + 親眼所見（Tier0）。
- **迷霧**：感官之外的世界——別隊虛實、遠方事件、未來。
- 不挫折（自己的事清楚），但世界真的不確定。

## 認知，非真相

- UI 顯「玩家以為」而非絕對真相：不是「敵 300」，是「似乎大量敵軍 / 有人說破百 / 可能有騎兵」。
- 每條情報帶：來源 / 可信度 / 時效 / 疑點。
- 不確定性**看得見、可行動**（看得出沒把握 → 想去查證）。
- 技能 = 理解力：高技能看更多、判更準、識破謊言。

## 核心迴路（每天在玩的）

1. 認知殘缺
2. 蒐集 / 查證（斥候 / 問 NPC / 買地圖 / 酒館打聽 / 養線人；花時間 / 錢 / 風險）
3. 判可信度（技能 gate）
4. 照最佳理解下注 → 錯了世界咬你
5. 利用別人的無知（他們也不知你虛實 → 伏擊 / 虛張 / 欺敵）

## 玩家的資訊力（魂＝玩法）

- 蒐集：斥候 / 打聽 / 買圖 / 養線人
- 判斷：識破謊言、辨可信源
- 利用：打真弱的、避偽裝強的
- 操控（後期）：造謠 / 偽軍情 / 收買信使 / 勒索

## 不是什麼

不是上帝視角 RTS min-max。是瞇眼在霧裡賭殘缺情報，有時賭錯。

## 玩家 vs NPC

NPC 同處迷霧（資訊系統）。玩家不特殊——同樣霧中一人，但有完全操作權，edge = **主動把資訊玩得比 NPC 聰明**。

---

# 核心一句話

> 「理解世界，比戰鬥更重要。」

---

各系統細節見相關文件索引。
