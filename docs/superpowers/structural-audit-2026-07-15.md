# 結構稽核報告（2026-07-15，systems 主導，用戶 commission）

> 補 measure-first（一路追幻覺症狀）後的結構視圖（[[feedback_structural_audit_complement]]）。4 維度讀 code 出結構圖，非跑數字。→ blueprint 按願景排收/序。**純唯讀稽核，不改 code。**

狀態：4 維度 ✅ 全回（4 平行 subagent），下方各維 + 跨維綜合 + 優先建議。

---

## ★跨維綜合（先講，給 blueprint 排序）

**一條主線貫穿三維**：*決策「統一走引擎」但「對不上現實」的缺口有一整族，且大多躲在同一類位置*：
- **grounded-ness（①）**：ungrounded 幻覺集中在**社交/外交類 option（需對方同意才有效果）**——買糧/併入已補，剩**求和/外交**兩個未補（求和還有 order_task 被丟棄的 seam bug）。
- **感知腳（③）**：最大單一違規＝**位置 god-view**（12 點）——選敵「打誰/多弱/多富」已 belief 化守鐵律，唯「目標**在哪**+追不追得上」全讀活體真值。belief 已存 last-seen 位置只差決策層改讀。**這是整族不變量違反，比任一 option 大。**
- **死常數（②）**：塑造行為的平頭常數該溶，但**逐個溶是錯的**——同型缺口成族（攻擊/佔村門檻族、food 安全線族、panic/膽識族、commitment 族），該建**共用人格函式**（`calc_engagement_margin`/收編 `food_security_target` band/`commitment_bonus`）讓整族走它。
- **矩陣（④）**：真殘＝prisoner_population 死路 + F-B1 known_member_states 雙 epistemics + decide_treatment 判斷器邊界；部分 doc **stale（低估** captive 進度）。

**systems 建議優先序（blueprint 按願景裁）**：
1. **感知腳位置 god-view（最高結構值）**：整族不變量違反、belief 已備修路現成、直接續 arc 的「決策對得上現實」精神（追兵不該全知躲藏者現址）。~12 點但共根（path_system reachability + decision_context `*_pos` 改讀 belief last-seen）。
2. **grounded-ness 求和/外交補完（小、續 arc）**：2 option + 求和 order_task seam bug。一次收乾淨 ungrounded 族尾。
3. **死常數「族」溶（建共用人格函式，非逐條）**：先攻擊/佔村門檻族（`calc_engagement_margin`）+ food 安全線收編。照妖鏡明星。
4. **矩陣 prisoner 死路清 + F-B1 epistemics 拆**（守恆/provenance 盲區）；decide_treatment 是否納 rank＝需你裁域專判斷器邊界。
5. 記憶/情緒腳泛化（記憶只讀仇、情緒只 panic→FLEE，且都 near-only 量測中死）＝深接線，較後。

---

## 維度①：grounded-ness 系統性掃（✅ 完）

**逐 option 判 applicable 有無 look-before-leap**（`options.gd` REGISTRY/applicable/to_task 全掃）。

### ★未補 ungrounded（剩 3 個，按價值）
1. **求和（最高）**：applicable 只驗 `threat_react≥threshold`，**零看敵方會不會接受和談**；既存 `diplomacy_reject_cooldown`（`interaction:413`）**沒像併入那樣回接 gate**。★**外加 seam bug**：`to_task` 傳 `order_task=TRIBUTE_OFFER`（求貢乞和）被 `_try_diplomacy` **硬寫 propose_alliance 丟棄**（`interaction:409-410`）→ 求和實際變「向威脅源提結盟」，語意錯。**補**：`has_pacifiable_threat`（讀 reject_cooldown + 對象接受和/貢可能）+ 修 order_task 傳遞。
2. **掠奪**：你已在修（food-weighted prey，`_find_weakest_prey:3324` 刪了 food 濾）。
3. **外交（低）**：同求和缺 reject-cooldown 回接，faction-directive-gated 較罕，衝擊低。修求和時共用 cooldown 回接。
### 已補/本 grounded：其餘 21 option（買糧/併入/返家/覓食/乞食/佔村/吸納/紮營/遷移找糧/攻擊/徵收/囤貨/貿易/生產建設駐守/訓練/歸建/FLEE…）applicable 皆驗得到世界效果或 emergent 撲空 release。**模式：社交/外交類（需對方同意）是 ungrounded 高發區。**

## 維度③：思考腳缺口（✅ 完）

三腳皆「狀態寫入端齊、決策讀取端窄」。
- **記憶腳**：主引擎**只讀仇**（feud→攻擊 util；join_rejected cooldown 已接）。`npc_ai:65` `p.relations`（betrayal/kindness/master/aided）+ gratitude/protect 邊**決策層零讀**（恩/信/懼某人寫入黑洞）。goals→utility 唯一橋 `check_goal_alignment` **只被 near-only reaction 呼**→all-far 量測中死。
- **情緒腳**：**只 panic→FLEE 一條**進團級秤（`terms.gd:80 threat_pressure += team_panic×0.4`），且 near-only（stress 主在 near step 刷、far 隊 panic≈0）。無 anger/greed/morale 欄；v2 §6④「情緒＝慾望↔現實瞬時調節器」未接。
- **★感知腳（最大破口）**：選敵/估值全 belief 守鐵律 ✅。**唯位置+可達性讀活體真值**（12 點，根 `path_system.gd:204/176/223` reachability/observe_velocity「trusted 恆 visible」+ `decision_context.gd` 各 `*_pos`）。核心＝「一旦 team_discovered 收錄過，對方當下真位置永久零延遲零迷霧可讀」→ 目標躲森林/繞路，追兵仍精準攔截。**belief 已存 tile_pos+last_tick**（`vision_system:113`）**只差決策層改讀 last-seen**（過時＝戲：追到空營）。★**修正稽核前提**：belief **有** food_est/coin_est/material_est/tile_pos（非「無 food_est 以外」）。

## 維度④：統一矩陣殘項（✅ 完，交叉驗 doc vs code）

- **F-M 人力俘虜**：★`progress.md:16「20% 失能-capture」= STALE 低估**——captive means-end 待遇/軌跡引擎（`manpower_system.gd` 全檔 + `anon_tier_system:209-379` + P1 audit）已大幅收。**真殘**＝prisoner_population 死路（`encounter:1295` 寫、零 sim 消費）+ npc_combat/encounter **雙 capture 入口** + 雙 injury/skill/equipment（結構型 by-entity）。
- **F-B belief**：`progress:14「40% 剩 known_states/audit」準確`。known_member_states **雙 epistemics 混寫**（god-view `world_state:409` 7 caller live + belief `faction_ai:636`）+ `invariant_audit:134` 只查 team_discovered dangling（team_intel/team_known 無稽核）。
- **S6 無主欄**：fatigue/work_morale/strategic_assignments **真殘無 chokepoint**（僅事後 audit）；current_option **半收**（引擎設但 faction_ai 6+ 站直寫繞）；ambition_* 有 AmbitionLadder de-facto owner（doc 列「無主」略保守）。
- **其他 un-collected**：F-D6 threat term **已收**（doc 已標）；**F-I1 雙 diplomacy resolver**（god-view `_try_diplomacy` vs belief `handle_diplomacy_message`，互動域主殘，同 verb 相反 epistemics——與①求和 seam bug 同根）；reaction named 9-react 獨立 scorer（結構型個體反應）；decide_treatment 獨立 scorer（穿人格秤但非 DecisionEngine rank，邊界待裁）。
- **誠實 stale 揭**：無「doc 說 done 但 code 還在」的反向 stale；反而 captive 被 doc **低估**（進度領先文件）。

---

## 維度②：死常數照妖鏡盤點（✅ 完）

**掃 270 個 `TEST VALUE`**。判準：該常數決定「NPC 何時做/不做某行為」的門檻＝**該溶**（人格化/世界化）；純機制/校準＝可留。

### ★該溶清單（塑造行為，按優先序）
| 優先 | 常數 | 檔:行 | 現值 | 該由什麼算 |
|---|---|---|---|---|
| ★★★ | PANIC_WEIGHT（作者自標 B 債） | terms.gd:54 | 0.5 | 這隊膽識（panic→survival 加權） |
| ★★★ | PREEMPT_MARGIN | faction_ai:114 | 2.0 | 慎重/膽識（打斷進行中 task 的威脅門檻） |
| ★★★ | FEUD_ATTACK_MIN | options.gd:55 | 0.5 | 好戰/信義/報復心（血仇開打門檻） |
| ★★★ | ATTACK_STRENGTH_RATIO | faction_ai:37 | 0.8 | 慎重/好戰（姊妹 calc_readiness_threshold 已人格化，此條沒跟上） |
| ★★ | DESPERATION_DAYS | terms.gd:6 | 3.0 | 求生欲/慎重（絕境門檻；該併 food_security_target） |
| ★★ | SURVIVAL_SATED_DAYS | need_hierarchy:16 | 5.0 | 求生欲（生存急迫歸零線；該併 food_security_target） |
| ★★ | SCARCITY_RAID_MIN | terms.gd:35 | 0.55 | 世界劫掠傾向 or 連續軟因子（現平頭切線） |
| ★★ | LOOT/ATTACK_SCORE_THRESHOLD | faction_ai:24,30 | 0.35/0.25 | 世界稀有度 or 好戰 |
| ★★ | AMBITION_FOUND_MIN | faction_ai:46 | 0.55 | 世界稱霸傾向（多少領袖立國） |
| ★★ | OCCUPY_WIN_MARGIN/POP_RATIO | faction_ai:143,142 | 1.3/0.6 | 慎重/好戰（與攻擊門檻同族） |
| ★★ | commitment 慣性叢集（COMMITMENT_BONUS+SOLO/COMMANDER/FOUND） | decision_engine:6;faction_ai:84,40,47 | 0.3/0.15×3 | 慎重/衝動（NPC 多固執；散 4 檔平頭複製） |
| ★ | ATTACK/LOOT_READINESS_MIN | faction_ai:36,25 | 0.75/0.6 | 膽識（出擊戰備） |
| ★ | PANIC_STRESS/LOY | decision_context:20,21 | 0.6/0.4 | 個人膽識/忠誠（panic 源判定，與 PANIC_WEIGHT 同叢集） |
| ★ | WAR_CHEST_MIN / GRADUAL_DECLINE_FLOW / VIABLE_ARMED_RATIO / MINING_GREED / is_military 門檻 | 見報告 | — | 野心/求生欲/好戰/世界稀有度 |
| ☆低 | NON_MERCHANT_TRADE_FACTOR / SURPLUS_FOOD_DAYS / GOVERN_MATERIAL_TARGET 等邊際 | — | — | 多屬機制，低優先 |

### ★★結構信號（比逐條溶更重要——同型缺口=架構信號）
1. **攻擊/佔村 prudence 門檻一整族平頭**（ATTACK_STRENGTH_RATIO/OCCUPY_WIN_MARGIN/POP_RATIO/ATTACK_READINESS_MIN/LOOT_READINESS_MIN）——但姊妹 `calc_readiness_threshold` 已人格化。**建一個 `calc_engagement_margin(leader_values)`（慎重↑要碾壓、好戰/膽識↓敢劣勢打）讓全族走它**，非逐個補。
2. **食物安全線已有單一 home（`food_security_target()` 已人格化）卻被繞過**：DESPERATION_DAYS/SURVIVAL_SATED_DAYS/SURPLUS_FOOD_DAYS 仍各開平頭死線＝「架構已定卻打平頭補丁」→ 收編進同函式的 band（絕境/知足/餘糧），消多常數。
3. **膽識/panic 叢集缺聚合**：PANIC_WEIGHT + PANIC_STRESS/LOY + readiness 門檻共缺一個「隊伍膽識」聚合（領袖膽量+成員士氣）。潰退/絕境逃已用 courage，**決策層 panic 未接同一 courage 源**——同軸一次接通。
4. **commitment 慣性散 4 檔各開 0.15/0.3** → 收斂成單一 `commitment_bonus(leader_values)`（衝動/慎重）。

### 已溶好樣板（不用動，供對照避重工）
潰退門檻（npc_combat:16 ABANDON_COURAGE_SPREAD）/絕境逃（MORTAL_COURAGE_SPREAD）/戰後屠殺（PURSUIT_CRUELTY_K/GREED_K）/食物安全存量（food_security_target 慎重野心）/Maslow 降權陡度（STEEP_CAUTION/AMBITION）/攻擊戰備（calc_readiness_threshold 殘忍好戰慎重）——照妖鏡已落實樣板。

### 可留（純物理/校準/機制）
量級正規化 base、人格函式的機器參數（斜率/floor）、重評 CADENCE（O(N²) 攤平）、timeout/防 latch 安全網、空間/物理常數、戰鬥物理率、belief policy、語意結構（AFFINITY dict/schema/task 陣列）。

---

（①③④ 維度回齊補上，然後綜合優先序 → blueprint。）
