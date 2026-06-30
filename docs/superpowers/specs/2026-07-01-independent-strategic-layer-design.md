# 獨立戰略層 — 野心獨立隊建國 intent（統一決策 arc 第三塊）

> 系統 HOW spec。承藍圖 `independent-strategic-layer`（下放戰略意圖層到獨立野心隊=補完統一、非 founding 補丁；複用 create_faction；接 commander-v2 means-end）。= (a)/征服者湧現最後一哩。
> measure 證（碼+數據）：rung2→3 卡＝能人是獨立隊（T32 cap4/食2207/pop9 全過唯卡 fid=-1）；commander-v2 戰略意圖 faction-level only→獨立不跑→無建國 drive。

## 統一決策 arc 缺口（補第三塊）
```
隊任務層    ✓（DecisionEngine 商隊/生產切片）
派系統領層  ✓（commander-v2 _update_goals 意圖驅動）
獨立戰略層  ✗ ← 本塊（野心獨立隊無戰略 drive）
```
**野心是普世驅力，不該被「在不在 faction」gate。** 草莽能人累積到爆卻無「拉班底建國」drive=野心階梯上半截對獨立者死路。

## measure 路徑可達（grounding，別猜）
獨立能人 founding 路徑候選（warring seed 量）：**結盟（獨立鄰）T18=2/T32=3＝最順**；吞併（弱可達）T18=0/T32=2＝機會性；宣告（solo）pop 夠但需新機制。→ **結盟 primary、吞併機會、宣告 defer。**

## 範圍

**做**：野心獨立隊（leader 野心高+統領+累積夠、fid=-1）跑**戰略意圖層**（mirror commander-v2 means-end），秤「建國」strategic option → means-end 子行動 **結盟（primary）/吞併（機會）** → 複用既有 `create_faction`（interaction:333 結盟 / npc_combat:524 subjugate）→ 成 faction → 跑 commander-v2 → 爬 rung3+ → 立國 → 征服候選。

**非目標**（明文）：
- **非 founding 補丁**（不「野心獨立+夠 pop→自動 create_faction」fiat）；建國是 means-end 秤的 option（driver=野心，driver-complete）。
- **宣告（solo declare）defer**（需新「無對象自宣告 faction」機制；結盟/吞併複用既有路徑先）。
- 不碰 commander-v2 faction 意圖（已 done，獨立成 faction 後自然接）、不碰隊任務層、不新 create_faction 機制（複用結盟/吞併）。
- 不碰 P1/食物/G3/讀 B。

## 設計

### 1. 獨立戰略意圖層（mirror commander-v2 `_select_intent`）
- 觸發：team `faction_id == -1` + leader 野心≥AMBITION_FOUND_MIN（TEST VALUE，~0.55 對齊 ambition_cap STATE 門檻）+ 累積夠（pop≥EXPAND_MIN_POP + 食盈餘＝已達 rung EXPAND）。cadence（沿用 ambition/commander cadence）。
- 意圖集（獨立）：`{建國, 守成}`（守成=default 繼續累積/個體行為）。**征服/徵收等 = 成 faction 後 commander-v2 給**（不在獨立層重做）。
- 建國 viable = 有 founding 路徑可達（結盟候選 or 吞併候選）+ 累積夠 + 野心高。argmax + hysteresis（戰略承諾）。

### 2. 建國 intent → means-end 子行動（複用 create_faction）
```
建國 intent → 秤子行動 util（viability × 人格）：
  結盟  ← 有可達獨立鄰（measure 最順）：TASK_DIPLOMACY → interaction:333 兩獨立聯盟 create_faction
  吞併  ← 有可打贏弱鄰（belief+readiness，殘忍/好戰染）：TASK_ATTACK → npc_combat subjugate:524 create_faction
  （宣告 defer）
argmax → dispatch 該子行動（driver={intent:"建國", why, mode}=driver-complete）
```
- 結盟/吞併 = 既有 task + 既有 create_faction 路徑（**不新機制**，只加獨立隊的「建國」drive 去走它們）。
- 成 faction 後：leader 成 faction leader → 下 cadence 跑 commander-v2 _update_goals → 爬 rung3/立國/征服。

### 3. 接點（HOW，plan measure 定）
- 獨立隊決策現經 `_evaluate_solo`(SoloAI) / `_decide_unified`（unified tag）/ ambition rung_task。**建國戰略層插哪**（faction_ai per-team 迴圈加獨立戰略 step / 或 _evaluate_solo 加建國 option）= plan measure 既有獨立決策路徑定。傾向 faction_ai per-team 迴圈（與 _evaluate_survival/prosperity 同層加「獨立戰略」step，僅 fid=-1+野心夠觸發）。

## believability
- **野心普世**：能人不論在不在 faction 都有戰略野心（建國=獨立者的戰略意圖）。
- **driver-complete**：建國 driver=野心（追得回）；子行動（結盟/吞併）帶 why。
- **草莽崛起**：獨立能人累積→拉班底（結盟）/吞弱鄰→建國→爬頂→征服=崛起戲。
- **稀有**：建國門檻（野心高+累積+路徑）→ 非每獨立隊建國（多數守成）；強野心累積者才崛起=戲劇尾巴。

## 驗收（bed 驗，藍圖列）
- **獨立能人建國**：bed（econ_bed/變體：強野心獨立隊 + 可達獨立鄰）→ T32 型獨立隊**結盟/吞併→create_faction→成 faction**（fid 從 -1→正）→ 爬 rung3。
- **established 1→多**：戰國 seed 獨立能人建國 → established 數漲（非卡 1）。
- **CONQUER 0→小正**：更多 established faction → commander-v2 征服候選 → 蓄意征服湧現。
- **不 over-war / 不 over-found**：建國稀有（門檻）、多數獨立隊守成；world_sim 量無建國潮。
- **守恆**：結盟/吞併走既有 create_faction/interaction/combat 守恆；coin_eq 0、InvariantViolation 0、framework S1-S6 PASS。

## 檔案
- `scripts/simulation/faction_ai_system.gd`（或新 `independent_strategy`）：獨立戰略意圖層（fid=-1+野心夠→秤建國→結盟/吞併 dispatch）。
- 可能 `scripts/simulation/decision/`：若複用 commander-v2 means-end 結構（intent/option），擴獨立隊。
- `docs/invariants.md`：「隊目標單一 owner」/混合協調段補——戰略意圖層涵蓋獨立野心隊（建國），非 faction-only；野心普世驅力。
- `scripts/debug/headless_test.gd`：新測（獨立能人秤建國 + 結盟/吞併 dispatch + create_faction + 成 faction 後跑 commander-v2 + 非能人不建國 + 守恆）。
- bed：`econ_bed.json`/變體（強野心獨立隊 + 獨立鄰）驗整環。

## 風險 + 緩解
- **接點選擇**（faction_ai per-team vs _evaluate_solo vs decision/）：plan measure 既有獨立決策路徑定，避雙寫/漏觸發。
- **over-found（建國潮）**：門檻（野心高+累積+路徑可達）+ hysteresis + 稀有人格分布 → world_sim 量。
- **結盟雙方意願**（interaction:333 需對方接受）：複用既有 diplomacy 接受邏輯（diplomatic_ai score）；單方有 drive 不保證成 faction（emergent，被拒則重評/改吞併）。
- **宣告 defer 的洞**：無對象（無獨立鄰+無弱鄰）的孤立野心隊暫無路（守成累積）；記 backlog（solo declare 後續）。
- **scope**：複用 create_faction（不新機制）、獨立層只 {建國,守成}（征服等 commander-v2 給）、宣告 defer。

## 開放細節（plan 定）
- 接點（faction_ai per-team step vs _evaluate_solo vs decision/ 擴展）。
- `AMBITION_FOUND_MIN` / 累積門檻 / hysteresis 量級（TEST VALUE，bed 校）。
- 結盟 vs 吞併 means-end 權重（結盟 primary，吞併殘忍/好戰染；viability 決）。
- 複用 commander-v2 means-end 結構程度（共用 intent/option vs 獨立輕量秤）。
