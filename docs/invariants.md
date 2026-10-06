# Invariants

## ★★★ 沙盒憲法（governing invariant，凌駕級，藍圖 2026-07-05，專案定義級）
> 靈魂層 owner=`game-design.md`；本節=架構 enforcement。**凌駕所有其他不變量**：與此衝突者無效。

**凡 NPC 行為必經統一決策引擎（means-end 子需求 + utility weigh，人格調製）。禁繞過引擎的行為規則/判斷器/行為 subsystem。行為是引擎輸出，永不是輸入。**

- **作者寫世界，不寫決策**：給世界（狀態/手段/代價/感知）+ 引擎。**不給行為規則。**
- **分辨線**：
  - ✅ **世界規則（物理，該有）**：食物耗盡/山難走/遠征累/被打傷/資訊霧 = 手段空間 + 代價。描述「世界怎麼運作」。
  - ❌ **行為規則（腳本，禁）**：`if 食物<X then 塞糧`、判斷器（prescribe 而非 weigh）、替 NPC 決定的行為 subsystem = 違憲。描述「NPC 該怎麼選」。
- **強制閘**：掃「替 NPC 決定的碼」——引擎外硬編 action selection / 判斷器 prescribe / 行為 subsystem = fail。
  - **機械實體＝site-freeze 防閘**：`constitution_gate.gd` 掃 simulation 的 transition／try_set 呼叫面比對 baseline；新增＝FAIL、移除＝PASS（arc 進度）。〔詳 detail#inv-site-freeze〕
  - **arc 溶入進度（序1–序N 的 merged sha／seeded 數）／coverage 誠實限制／arc 期間 `pre-commit` 硬掛／後勤應用例** → `process/detail/invariants-cases.md` 同標題節。★搬走的是進度與細則，上面那條**契約**（current ⊆ baseline）就是規則本體。
- **零例外**：絕境=survival utility 在引擎內支配（非 override 繞過）；遠方=疏非慢非笨（引擎決策，非變笨）。此二處驗沒偷寫行為腳本。
- **稽核收斂主軸**：既有行為 subsystem/判斷器 → 溶進引擎（非特例）。連 [[project_unified_decision_framework]] / [[project_unification_matrix]] / 「架構已定別打補丁」。

### ★北極星：遭遇=統一反應（arc 收斂點，藍圖 encounter-north-star 2026-07-05，WHAT owner=game-design.md「★遭遇=統一反應」節）

憲法旗艦案例：arc 各序溶解的終點＝五結局收斂進「一次遭遇的統一反應」（同一 encounter 評估的不同 option），不溶成五個孤島。〔詳 detail#inv-encounter-north-star〕

**兩鐵律（納設計，約束所有溶）：**
1. **★感知鐵律**：威脅／身分感知只吃**可見表象＋已知關係**（belief＋`known_reputations`）；**禁讀對方 tag 或真實意圖**；分不出照最壞繃緊（可派斥候探底）。〔詳 detail#inv-perception-iron-law〕
> ★★★**細則 1a：belief 通過 ≠ 內容任取**（藍圖立 2026-09-02；★★systems 2026-09-02 補洞：**不限「閘後」**）——
> **belief 閘只授權「要不要評估這個對象」，不授權讀它的 live 值。**
> ⇒ **決策路徑用到的每個他隊欄位都必須是 belief 欄位**（`belief_pos`／`best_estimate`，禁直讀 tile_pos／population）；belief 三態，**unknown 一律不通過、禁 fallback live**。〔詳 detail#inv-belief-fields〕
> ★★★**「閘前」比「閘後」更嚴重，而初版規則漏了它**：閘後直讀是**分數算錯**；★**閘前直讀是【live 真值決定這個對象算不算候選】** ——
> **連「該不該知道它」都被真值決定了**（血證 `_find_occupy_target:6080`：live `tile_pos` 查 tile 判 `outpost_level`，發生在 `has_belief` 之前）。
> ★**最會漏的地方是被呼叫出去的小函式**：呼叫端那一行看起來乾淨，live 讀藏在裡面。血證與掃法 → `process/detail/invariants-cases.md`。

2. **★深度靠感知非規則**：加深度＝讓更多世界狀態可被感知、同一引擎自算反應；**禁為每種社交組合寫新規則**（N 方不建三方處理器）。〔詳 detail#inv-depth-by-perception〕

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
- **★B 重框＝落地債**：行為門檻只能活在世界代價或人格／記憶／現況裡；**塑造行為的全域常數門檻不該存在**（例：PREEMPT_MARGIN 該由謹慎度算）。〔詳 detail#inv-b-reframe〕
- **★溶入驗收多一條隱性標準**（所有後續溶）：**該行為是否真穿過人格/記憶/現況的秤，非某全域規則/常數直達。冒出具名 margin/gate/threshold 常數=照妖鏡響。**
- **★★域專判斷器邊界**：獨立 domain scorer 合法＝①真穿人格／記憶／現況 ②讀跟主引擎同一組人格值；敵人是硬寫、繞過 dispatch 的死常數 gate。〔詳 detail#inv-domain-scorer〕
- **★★★人格 WEIGH 不 GATE**：人格只能加權傾向、不能開關選項；persona 門檻 on/off 或 archetype 標籤擋行為＝違憲，一律轉 soft 權重；世界物理約束不算。〔詳 detail#inv-weigh-not-gate〕
- **★★★兩條框架健全不變量（用戶問 2026-07-16，納入框架驗收機器證——3 流全綠=兩問有機器證）**：
  - **① 下游零決策**：思考層決策、下游純執行；下游偷做決策（行為閘／硬門檻 override／RNG 開閘）＝違規；下游供狀態給思考層讀＝OK。〔詳 detail#inv-downstream-no-decision〕
    - **★手不聽腦不變量**：引擎決策的求生 task 必被執行；所有 current_task 寫入（try_set＋transition）守 arbiter 鎖；emergency 正當退場走 release。〔詳 detail#inv-hand-obeys-brain〕
  - **② 下游零干擾**：(寫) 一狀態一 owner；(算) 同概念多處各算＝干擾，單一源 oracle 殺之；(順序) sim_runner 系統 registry 統一 tick loop。〔詳 detail#inv-downstream-no-interference〕
  - **★機器證組合**：`constitution_gate` v2（零決策+近似重複）+ CI-scan（單寫者）+ oracle 單一源（零各算）+ sim_runner registry（tick 序）**全綠 = 用戶兩問「下游不影響決策 + 互不干擾」有機器證**。別讓下游偷決策 or 跨系統亂寫/各算。
  - **★RNG 判準 3 案（用戶精修 2026-07-17）**：`constitution_gate` rng detector 抓的逐個照此判：
    - **① 純骰無人格替決策 = 行為閘 → de-patch**（personality-blind randf 選行為）。
    - **② 世界不確定 outcome = 合法留**（訊息有沒有送到/事件/event-ID 生成/遭遇/外交成敗/戰鬥擲骰=世界怎麼回應，非替 NPC 決策）。
    - **③ 人格加權機率決策**＝合法 IF 曲線陡＋走框架＋seeded：清楚案例推兩端、骰只斷中間；曲線平 ⇒ 陡化，不是拆 RNG。〔詳 detail#inv-weighted-random〕
    - **systems 驗**：③ 類逐個驗曲線陡度——陡則 gate-ok、平則陡化（把人格影響放大到兩端），非拆掉 RNG。血證：`consider_betrayal` 陡(ok)、`try_proactive_diplomacy` 0.2~0.7 平(陡化)、`_check_discipline` fail-under-stress=②outcome(ok)。
- **★★單一源 oracle 判準**：oracle 外另算同概念＝違規、必遷；oracle 內某分量暫為常數＝可接受的 deferred。源統一是硬標準，值的推導是軟債。〔詳 detail#inv-single-source-oracle〕

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

**已坐實的層（2026-10-06）**：隊伍資源層無不經 ResourceBank 的寫入（30 天 43199 tick 零不吻合）；tile 倉庫／自然池／person.coin 由帳本守恆床證。〔詳 detail#inv-ledger-proven〕
**現實校準（藍圖給，免落地做歪）**：「所有暫態每 tick 全 dump」爆 perf（fullprobe 已重）。可實作版＝
- **tap 必須存在、零盲點**（可觀測性=不變量，不打折）。
- **dump 可 scope**：specimen 鎖隊全量 / probe 抽樣，不必全世界每 tick 全記。
- **原則不稀釋**（不准有量不到的暫態），**perf 平衡=系統 HOW**。

**★觀測者禁耗 global RNG＋禁污染 Probe**：觀測的額外呼叫包 `_begin/_end_observe`；驗收＝同 seed、specimen A／B／無三跑，除 tracer 外世界＋Probe 全 byte-identical。〔詳 detail#inv-observer-neutral〕

**★specimen 完整性**：指標 specimen 的 trace 涵蓋完整一生（heartbeat ≤6h 無洞）＋全決策路徑（含 commit-fail attempt）；新決策路徑必接 specimen tap。〔詳 detail#inv-specimen-complete〕

**★decision-bearing 聚合必附 bounded 樣本**：會餵 WHAT 決策的聚合探針，寫時同捕 3–10 個 instance（`Probe.bump_sample`）；只有計數＝詮釋未坐實。〔詳 detail#inv-aggregate-samples〕

**enforcement（觀測盲點閘）**：未接 tap／RNG 不中性／specimen 有洞／Probe 污染 ⇒ FAIL；機械閘＝`observability_gate.gd`＋`tracer_completeness_test`＋`_begin/_end_observe`。〔詳 detail#inv-observability-enforcement〕

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
★★★**第三端：【顯示】不受感知鐵律管，但要自己的執法點**——玩家走法不印「真值·debug」區，它只活在明確的 debug 走法；自驗：玩家輸出零 debug 識別字＋debug 走法下必出現。〔詳 detail#inv-display-boundary〕
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
| **域**（純標題，全文在 detail 同標題節）：World／Map／Time／Information／Simulation／關鍵設計規則／對稱性／玩法節奏／UI 邊界／NPC／Interaction／Anon／Task／財產 / 守恆／飢餓 / 人口／team reference 契約／Leader 繼承單一 owner／訂單系統／隊目標單一 owner = leader 野心階梯 |
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
| ★★★觀測器**禁任何副作用**：不耗 RNG；查詢面不交出本體（回傳複本）；被當查詢用的指令，其寫入路徑在查詢版走不到（逐條路徑問「這條路有沒有寫」）。〔詳 detail#inv-observer-no-side-effect〕 |
| ★means-end / 前提解析的「無手段終止」不得靜默（2026-08-25） |

> ★**搬家不是廢止**：每一條都在 `detail` 檔裡完整保留、原文在 `git log`；★★**要引用時查 `detail`，開場只需要記得憲法級那幾條。**

## ★★★近期立的不變量（一條一行；★血證／為什麼一律在 `process/detail/invariants-cases.md` 同標題節）

> ★**一張表而不是 N 個標題**：N 個標題＝N 個入口＝開場讀不完 ⇒ 規則存在但不會被用到；★★**搬走的只有【為什麼】那一半，規則本文一行都沒少**——判事情讀這裡，要說服人去讀 cases。（★★★而新增一行就要**同檔省回一行** —— 2026-09-22 加第 7 條時 doc-cap 當場 601>600，這一行就是那時併的）

| # | 不變量（★這一行就是規則本體） | 立 |
|---|---|---|
| **1** | ★**跑 tick 的床必須接 `advance_tick` 回傳值，印首次非推進的 tick 與原因**（沒有也印「無」）；per-day 分母＝有效窗。〔詳 detail#inv-1〕 | systems 2026-08-27 |
| **2** | ★**T0 事件瞬醒**：喚醒單一真值＝`WorldEvents`、排程＝`CadenceStagger`；預設全喚醒、例外就地寫理由；新決策支在 cadence 閘前讀 `is_pending`。〔詳 detail#inv-2〕 | 用戶裁定；S4b 2026-08-28 |
| **3** | ★**守衛要掛在【一定會發生的事】上，不是掛在【有人來問】上** ——「只在有人問的時候才檢查」的守衛＝沒有守衛。★★掛在「每 tick 都會走」的 dispatch（主動），不要掛在「有人查詢時才走」的估算器（被動）。★★★**它的失效是靜默的**：沒人問 ⇒ 沒告警 ⇒ 跟「一切正常」一模一樣。 | systems 2026-09-01 |
| **4** | ★**儀器要自述盲區，形式＝印在它的輸出上**（「本尺排除：…」）；拿設計上排除某類 bug 的儀器去驗那類 bug＝無效驗收。〔詳 detail#inv-4〕 | blueprint＋systems 2026-09-01 |
| **6** | ★**回傳【決定】的介面必須能同時回傳【依據】**（同一次計算的孿生視圖），不得讓下游事後重算（重算常會寫 state）。〔詳 detail#inv-6〕 | systems 2026-09-16 |
| **5** | ★**文件引用 tick 常數時寫【時長】不寫【tick 數】**：寫「＝2 天，值見 code」，★**不寫 tick 字面數**。★★理由與「估算器禁手抄物理」同源——**改接線不是改數值**；把 480 更新成 2880，下一次換根它會再爛一次。 | systems 2026-09-01 |
| **7** | ★**記帳可以閘，語意不可以**：`Probe.enabled` 後面只掛 tap，production 語意一行都不得依附它；至少一格驗收跑在 Probe 關閉下。〔詳 detail#inv-7〕 | systems 2026-09-22 |
| **8** | ★**只動相位不等於行為中立**；「頻率」拆計數與間距兩欄；只換賦值方式的 slice 必須守母體與結果；錯開的單位必須等於系統的粒度。〔詳 detail#inv-8〕 | systems 2026-09-22／23 |
| **9** | ★**`state.teams` 裡有真隊／野獸 pseudo-team／在外子隊三種，量測必須聲明指哪一種**；世界變糟看 extinct／starve／combat，不看 teams.size()。〔詳 detail#inv-9〕 | systems 2026-09-22 |
| **10** | ★**按鍵意義不得由會在同一 tick 內改變的計數決定**；判別子必須是玩家自己改變的狀態；強制回應獨佔字母，兩個數字母體各自獨佔 1..9 與頁計數，不靠位置偏移。〔詳 detail#inv-10〕 | systems 2026-09-30 |
