# 框架收尾「兩硬綠」program — 零殘留閘 + 可擴充（WHAT / vision）

status: LOCKED（2026-08-07：R² re-verify CLEAN、6 findings 全訂正 → systems F0 起）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-07
溯源：用戶定 2026-08-06「兩個都完成」+ 排序 A；grounding `2026-08-06-framework-grounding-audit.md`（file:line re-verified）；R² 異質框外審 `2026-08-07-reviewer-...-ISSUES`（Opus agent 深讀 + reviewer 親複驗、6 findings）。連 [[project_unification_matrix]] + [[project_framework_seams]]。

## §0 grounding 定案（省盲改）
- **① 行為零殘留 = largely machine-proven**：`constitution_gate` v2 已抓全 9 閘型、**75 sites baselined removed=0**。§殲滅清單 A 前 6 條全 stale/已修。
- **② 可擴充 = 主戰場**：faction_ai **5350 行**（grounding 基準 ~5018、recovery merge 後漲 330+＝★移動標靶，見 §2.6）= 209 func / ~8 行為域。

## §1 兩硬綠 = 完成標準（R² 訂正後、據真數字具體化）
- **★硬綠①：零殘留非框架閘（機器證）**。★R²-⑤ 訂正：75 baselined sites **性質不一**（reviewer 親驗：只 ~9 真 threshold 型，其餘 god-view/dispatch-entry 等 = 不同性質、多已 blessed）。**故非單一 checkbox**：
  - (a) threshold 型（~9 + agent 挖出灰色常數 FORAGE_VIABLE_POP/ABSORBER_MIN_SURVIVE_DAYS/SMALL_TEAM_RATIO/OCCUPY_ETA_MAX/GOVERN_MATERIAL_TARGET/FOOD_BRIDGE_SAFE_MARGIN…）→ **逐一 triage physical-viability[留] vs death-constant[§5 人格化]**。
  - (b) god-view/dispatch-entry 型 → 已 blessed / 不同性質，**確認 machine-gate 覆蓋即可、不入照妖鏡 triage**。
  - 達成 = threshold 子集全 triaged + death-constant 全人格化 + god-view 子集 machine-gate 覆蓋確認 + diplomatic:325 補 gate-ok 標 + `constitution_gate` 綠無 un-triaged。
- **★硬綠②：可擴充**。★R²-①④ 訂正（措辭收緊、判準 operational 化）：
  - **(a) 消滅 god-object + code-locality**：faction_ai 拆成有邊界模組、每模組單一行為域。**誠實界（R²-④）**：拆檔給的是 **code-locality**（模組好懂好改）**非 state-ownership 解耦**（62 系統仍逐欄位共讀 WorldState = §2.5 park）。
  - **★(b) 統一註冊點（R²-① 揭的真工作）**：現況「加新行為域」字面上動 **≥2-4 處**（options.gd REGISTRY + need_hierarchy.gd:82 AFFINITY[漏列靜默落 _AFFINITY_UNIFORM=行為差異非 no-op] + terms.gd match + decision_engine/options OPTION_SET 手動清單）。**硬綠② 的 operational 判準 = 把這些散註冊收斂成單一註冊點** → 屆時「加 = 動一處 + 引擎註冊」才**字面成立且 machine-verifiable**（擴充性稽核：加 mock 行為域、machine 檢查只碰單一註冊點 + 其模組）。

## §2 ★守則（防 crank / 防 regression / 防 scope creep）
1. **① 分類 = genuine（§5 照妖鏡）**：threshold 代表人格無關物理真實 → 留；代表該人格秤的決策 → 人格化（util 讀人格/記憶/現況、genuine 非 crank）。
2. **★★純結構重構 = 行為保持，安全網 = 真 state-fingerprint（R²-② 最要害訂正）**：
   - **現行「determinism」實為 `coin_eq`（單一加總純量比較）非逐位元 hash**（reviewer 親 grep：var_to_bytes/state_hash/sha256 全落空）→ coin_eq **只偵測 test+seed 覆蓋分支**、分支外行為變更**漏網**。**∴「byte-identical＝證無行為變更」用詞過重、撤回。**
   - **★F0 前置 slice（新增、prerequisite）= 建真重構安全網**：全 world-state 逐 tick fingerprint（結構化 hash，涵蓋 teams/persons/factions/belief 等，非只 coin）+ 多 seed × 多床 regression 快照。**先有安全網、才動任何結構 slice**（measure-first 用在重構自身）。
   - 每純結構 slice：F0 fingerprint 三跑一致 + 多 seed regression 快照不變 = 真證「只搬位置」。行為變更（①人格化）與結構搬移（②）**分 slice 不混**。
3. **★序 = 逐模組定、非全體 A→B（R²-③ 訂正）**：
   - **決策密集模組**（facility scoring 等）：**先行為抽引擎**（反序＝白工）。
   - **純程序/機械模組**（envoy 家族 / 公庫徵用 / 非計分 residency dispatch）：**可先結構切**（不白工、提前瘦身降噪）。
4. **每 slice 有界 + gate 驗**：constitution 過閘 + headless 無新錯 + F0 fingerprint/regression + R²。禁大爆炸重寫。
5. **★scope 邊界（R²-④ 確認正當 park）**：**WorldState 逐欄位共享狀態的 state-ownership re-architecture 不在本批**（62/64 共讀 + single-writer chokepoint = 更底層、全解近乎重寫、風險/報酬不成比例）。本 program 攻 **god-object 消滅 + code-locality + 統一註冊點**（用戶真痛「加東西大改」高槓桿處）。state-ownership 解耦 = documented 未來獨立問。
6. **★移動標靶治理（R²-⑥ 新增，spec 原缺）**：refactor 進行期間**新 merge 的 faction 行為 code 禁再堆回 faction_ai**——入新有邊界模組（或 holding）。machine-check：**faction_ai 行數天花板 ratchet-down**（每模組抽出後上限下調、只降不升）+ 新 faction 行為走統一註冊點。防邊拆邊長回 god-object。

## §3 track 結構（高層、systems 切 HOW slice）
- **Track ①（行為零殘留、bounded）**：§1① 的 threshold 子集 triage + 死常數人格化 + god-view 子集 gate 覆蓋確認 + diplomatic:325 標。
- **Track ②（結構可擴充、主戰場）**：
  - **(A) decision-dense 抽引擎**：faction_ai decision chunks（戰略 scorer/意圖/目標評估 895-1311）→ 引擎 util term、瘦身。
  - **(B) 結構切模組**：5 有邊界模組（基建 lifecycle ~1200 / side-dispatch ~480 / 公庫徵用 ~220 / outpost-residency ~280 / envoy ~350）；純程序模組（envoy/公庫/residency）可先切（§2.3）。
  - **★(C) 統一註冊點**（§1②b）：收斂 REGISTRY/AFFINITY/terms/OPTION_SET → 單一註冊 = 硬綠② operational 前提。
- **平行（clean-extractable）**：marginal/message/labor（2-3 ref）seam 文檔化。

## §4 slice 序（高層、systems HOW 定確切切法）
1. **★F0（prerequisite）**：建真 state-fingerprint + 多 seed regression 安全網（§2.2）。**無此不動結構 slice。**（★R² 輕量觀察：F0 自身 effort/scope 邊界——幾 seed/幾床才算夠——由 systems F0 HOW 界定，判準＝覆蓋度足以攔住結構 slice 可能引入的行為漂移類型，非任意數字。）
2. **F1**：Track ① threshold 子集死常數審 + 人格化 + diplomatic:325 標（bounded、推硬綠①）。
3. **F2**：純程序模組先切（envoy/公庫/residency、§2.3、byte-fingerprint 驗）+ clean-extractable seam 文檔。
4. **F3**：Track ②(A) decision-dense 抽引擎（behavior-first）。
5. **F4**：統一註冊點（§3C）→ 硬綠② operational。
6. **F5+**：剩模組逐切（基建 lifecycle 等、一模組一 slice、fingerprint 驗、可 revert）。

## §5 量測（硬綠驗收）
- **硬綠①**：`constitution_gate` 綠 + threshold 子集全 triaged + death-constant 人格化後**行為分化可觀測** + determinism（coin_eq + F0 fingerprint）。
- **硬綠②**：**擴充性稽核**（加 mock 行為域 = machine 檢查只碰單一註冊點 + 其模組）+ 無 god-object（faction_ai 行數 ratchet 達標、無單檔巨物）+ 每純結構 slice **F0 fingerprint 三跑一致 + 多 seed regression 不變**。★誠實：此證 code-locality + 註冊統一，**非** state-ownership 解耦（那 = park）。
- **無 regression**：全程 headless 1000+ tick 無崩 + 既有 arc 回歸綠（recovery/cohesion/info-net）+ F0 多床快照不變。
