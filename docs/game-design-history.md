# game-design 歷史紀錄（從 game-design.md 搬出，按需讀）

> 2026-10-07 瘦身搬入。這裡的段落是當時的稽核／裁定快照，進度已過期；仍具效力的裁定以 `docs/mechanism-intents.md` 為準。原位置 game-design.md 第 285–374 行（搬出前）。

### ★★ 統一路線圖：收散亂 oracle（結構稽核 2026-07-16，用戶定「照路線架」）

> **★段落狀態(2026-08-21 瘦身註)**:本節=2026-07-16~18 結構稽核+裁定的**歷史紀錄**(逐項進度快照已過期,現況=2026-08-21 模型完工清單+意圖帳)。**仍具效力的裁定**:threat-severity 人格分流 amplifier(矩陣 Arc 2/3 建成時的 WHAT 輸入)/「零殘留非框架閘」驗收標準/survival 保序單一源不變量。
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

#### 大戰略校準(2026-07-16) → 校準史搬 `progress.md` §大戰略校準。**留規則**:框架驗收=兩硬綠——①零殘留非框架閘(用戶:「只要剩一個非框架閘,模擬結果就變垃圾」;constitution_gate 機器證非人肉)②可擴充。兩硬綠才談行為/經濟(框架先,行為後)。

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

### 命運不看玩家臉色(2026-07-14;已被零 LOD 新法整個取代) → 歷史全文=`docs/archive/2026-07-14-full-hd-vs-lod.md`。現行正典=意圖帳「世界存在性」row:模擬層零 LOD,計算跟隨事件密度不跟隨觀察者。

#### ★ O(N²) 掃描瘦身的 vision 約束(藍圖鎖 WHAT 2026-07-18;**仍具效力=效能 arc 剪枝刀的 WHAT 約束**)
真根：prey/threat 掃描迭代 **`team_discovered` 累積名單**（一旦發現永留）+ reachable 濾在迴圈**內** → 小圖每隊 discovered≈全隊 → O(N²)。修法方向＝**換迭代源**（掃「附近 + 顯著」有界集，非全累積名單）+ 地圖放大散開（密度不變）。**兩者並行才吃得到紅利**（大圖給「附近隊少」，換源才用得上）。
- **★約束①：掃描用信念位置，不用真實位置。** 「誰在附近」由觀察者**自己的 belief store（belief_pos + staleness）+ 當下 vision** 定，非世界真座標。用真距離挑近隊＝god-view leak（違感知鐵律）。
- **★約束②：不准砍掉記憶中的顯著威脅。** 掃描瘦身**只准砍「無關的陌生遠隊」，不准砍「記憶中重要的遠隊」**（世仇/大威脅/盟友遠也留，低頻評沒關係，但不能消失）。否則隊會忘了逼近的大敵＝壞 believability。
- **★洞見：感知鐵律 ＝ O(N²) 修法同一約束。** 全知掃真座標既是 believability 罪也是 perf 罪；**感知-local 掃描同時治兩者**（只處理「我感知得到的」，而感知天生局部）。霧戰 = perf 局部性。
- **機制不鎖（系統 measure-first）**：空間索引/salient 上限/cadence 待 profile O(N²) 熱點；**且先 audit `estimate_catch_up` 讀真值或信念（疑藏 god-view leak）**。現在硬鎖機制＝重犯「沒量就定案」。此節僅鎖 WHAT 約束，機制隨 O(N²) arc（B 前置 sustain 過後）設計。

