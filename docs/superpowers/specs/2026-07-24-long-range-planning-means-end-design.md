# 長程計畫 / means-end 決策系統 — WHAT 設計（藍圖×用戶 brainstorm 2026-07-24）

> **定位**：這是 WHAT/願景設計（behavior/model/scope），非 HOW 架構 spec。定案後交 systems 做 HOW（架構 spec + 實作 plan + slice）。
> **起源**：material 供給調查一路挖到底，證實真 binding root = 決策模型無 means-end/長程計畫能力（`settle_fit` 等 flat 決策常數、need 不沿鏈傳、goal 沒表示成可鏈子目標）。用戶定：`健全的系統才有價值的模擬結果`+`整個長程計畫做完當一個 whole 再回頭 measure 找問題`。接 `docs/notes/2026-07-19-long-range-planning-brainstorm.md`。

## 1. 目的
讓隊能**追求需多 tick 才達成的目標**（發展、取得資源、蓋設施，未來史詩：王朝/天命/天災/造謠），行為**從決策引擎湧現**，而非逐個 hardcode。核心病：現在決策模型不會「我要 A，但 A 需要 B，那我先去弄 B」——缺料的隊連「去森林拿料」的念頭都沒有，只會坐著。逐個 patch（材料一條、武器一條…）= 無限打地鼠 + 每條都違憲 scripted 決策。**通用 means-end 機制 = 唯一不打地鼠的解。**

## 2. 範圍
- **機制（引擎）＝全建**（用戶定 scope B）：①持久遠慾望 registry ②means-end 依賴圖 ③applicability 湧現順序 ④折現/承諾。
- **內容（初始 goals）＝全部基礎層**（用戶定：不只材料/發展，含 food/material/tools/weapons/coin + 所有設施）。引擎在整個基礎經濟跑穩 = 健全地基。
- **史詩層 goals（王朝/天命/天災/造謠）＝之後當 registry 資料加**（通用性的價值：加 goal = 加資料、零決策 code）。
- **非目標**：不復活退役的 S2 腳本計畫層；不建顯式「總參謀」多工程組合規劃器（見 §9）。

## 3. 核心模型（脊椎）
1. **持久遠慾望**：隊攜帶多個「想要」（想要武器坊、想要控制材料、食物夠…），**跨 tick 持久**，不因當下不能做而蒸發。
2. **宣告式依賴 registry 拆子目標**：每個慾望經一張**資料表**拆成子目標鏈（想蓋武器坊 └需 material+tools └material 需 forest-access └需 forest 據點 └需 pop≥N）。
3. **applicability gate**：子目標「前置滿了才可選」（複用既有 `option.applicable`＝求生 look-before-leap 那道現實 gate）。前置未滿 → 不 applicable → fall through 到當下能做的子目標。
4. **每 tick 挑當下最高 util 的 applicable 子目標**（複用既有 `rank_scored`）。**無 plan-state、無腳本序列**——順序**湧現**：只能挑當下 applicable 的，applicability 鏈自己逼出順序。硬前置鎖序、軟路徑人格挑（軍閥 vs 商人走不同合法走法穿同一張圖）。
5. **need 沿鏈往上傳（means-end chaining）**：慾望生子 need，子 need 再生孫 need（想武器坊 → 生 material+tools need → 生 forest-access need…）。＝「拆得開」。**這是核心新增**（systems orientation：既有 `NeedOracle` 有 need 傳播、但不沿依賴鏈往上；缺口 = need-chaining + goal-as-chainable-option）。

## 4. 多線（平行）
- 隊的「戰略」＝它**同時掛著的一組持久慾望**（≥1 條線）。**非線性**：多條線同時活著、平行推進。
- **委派是選項之一**：「派小隊去做 X」跟「自己做 X」並列在 option 集，按 util 挑。
- **平行執行**：母隊 + 多支小隊各走各的子目標鏈（小隊1 採森林材料、小隊2 挖山地礦、母隊種田）＝多線並進。
- **餘力 gate 配額**：能同時跑幾線取決於有多少人/小隊可分（既有 dispatch pop-guard）。窮部落跑少線、強權鋪多線＝寫實。
- **跨線協調 = 隱式**（用戶核可）：哪條線的下一步 util 高又有餘力就先拿資源；util 排序 + 餘力 gate 自動分配，**不建顯式總參謀**（那＝planner 複雜度）。
- 「每 tick 挑一個最好的一步」是**每個 actor（人/小隊）**層級（一個身體一次一件＝物理限制）；**隊層級全平行**。

## 5. registry 一列結構（前置種類）
一個目標的前置只有幾種固定**種類**（引擎認種類、資料隨目標變）：

| 前置種類 | 引擎怎麼追 | 例 |
|---|---|---|
| **資源** | 取得該資源（採/產/買，遞迴其鏈） | 武器坊需 material+tools |
| **定位** | 移動到/控制該地形的 tile | 材料需「在 forest」 |
| **人力** | 長 pop 到門檻 | 建據點需 pop≥N |
| **設施/狀態** | 蓋該設施 / 達該狀態 | tools 需 workshop；武器坊需軍事據點 |
| **子目標** | 遞迴達成另一目標 | 王朝需嗣（史詩層，後加） |

- **一列 = 「目標 G：需要 [資源…, 定位…, 人力…, 設施…, 子目標…]」**。每個未滿前置 → 遞迴成子目標。
- 加食物鏈/武器鏈/王朝鏈 = 填這幾格 = 資料。**種類固定（有界）**、資料隨目標變 = 通用性的實體。

## 6. 折現（看得遠）
- 只有**投資型**子目標折現：現在花、N tick 後才回本（例：派隊走幾天去建 forest 據點）。即時動作（現在採糧）馬上回報、不折現。
- 投資型 util = **預期回報 × 折現(延遲, 人格)**。延遲越長折現越重。
- **人格 = 折現率**：耐心/慎重折現輕（看得遠、肯投遠利）；衝動/絕境折現重（只顧眼前）。
- 效果：快餓死的隊不會起步走遠路建 forest 據點（回報太遠、折到趨近零、輸給眼前糧危）；穩定的隊會。**人格差異化 + 情境感知（餓=短視/穩=遠視），用權重非 gate。**
- **HOW 待 systems**：「預期回報」精確估法（可能是「解掉的上層慾望 util × 延遲折現」的淺啟發，非完整經濟報酬模型，守有界）。

## 7. 承諾（守得住，複用既有）
- 既有 `COMMITMENT_BONUS` hysteresis（rank 前偏置現任 option）+ timeout（撐多久放棄）+ priority 層 pre-empt（危機蓋過）已提供「守得住」。
- 本系統**複用**，不重造。means-end 提供「拆得開」、折現提供「看得遠」，補齊筆記自評的兩缺口。

## 8. 基礎 goal-set（初始填）
- **資源維持**：food / material / tools / weapons / **coin**——每個「維持夠用 X」慾望 → 取得鏈。
  - ★**coin 取得鏈與 harvest 不同**：走「有可賣餘量 + 有買家（市場/貿易）」，非採集。registry 用「資源/定位/狀態」前置自然表達（coin 前置 = 可賣 surplus + 觸得到的買家）。本場 coin-liquidity（salary→anon_treasury illiquid）也會被 means-end「我需要 spendable coin → 需 extract」自然涵蓋（取代 extract flat 0.4 閘）。
- **設施發展**：每座設施（farming/workshop/apothecary/mint/stable/smeltery/weaponsmith/armorsmith）→「想要設施 F」慾望 → 「資源+定位+人力」鏈。
- 這兩類蓋掉整個基礎層。

## 9. 有界 / 非目標
- **淺、有界**：registry 鏈幾層（非 10 步規劃器）；每 tick 只查 **local applicable**（當下能做啥），**永不算整張圖**、不追 plan-state。這是它跟退役 S2 的根本差別（S2 算完整序列、被打斷就壞；本系統無 plan-state 可壞，危機 pre-empt 後從「當下 applicable」重抓）。
- **不建顯式總參謀**（多工程組合規劃器）：多線靠「多持久慾望 + 多 actor + 餘力 gate + util 排序」湧現，不靠顯式跨線調度。
- **不復活 S2 腳本計畫層**。

## 10. 憲法對齊
- **utility 餵 utility 非 scripted**：所有選擇走 util 排序 + applicable gate，零 hardcode 決策 edge（「缺料→去森林」是圖走出的路徑，非寫死規則）。
- **人格 WEIGH 不 GATE**：人格進折現率/util 權重，不設硬類別閘。
- **通用非 bespoke**：加 goal = 加 registry 資料，非寫新決策 code（不打地鼠）。
- 世界結構約束（terrain 產量、outpost-type、設施 allowed_outpost）保留＝物理，非決策閘。

## 11. 規模：全建中等新子系統（R① 異質 reviewer 訂正 2026-07-24）
> ★原句「擴既有機械、非新引擎」是 systems orientation 的樂觀低估，R①（異質 Sonnet）factcheck 逐點 refute、判 premise_contradiction（與 §2「機制=全建」自相矛盾）。訂正如下。**願景本體不變**（scope B 四塊/5 前置/湧現順序/憲法全成立）；改的只是規模認知。

- **真複用（薄）**：`rank_scored` 的 argmax（挑當下最高 util applicable）＝**湧現順序本體**，這塊成立、直接用。新子系統要做的是「**合成 candidate options 併入這個 rank 池**」。
- **★不能複用（要真新增，= 中等新子系統）**：
  - `options.gd` ＝ ~25 個**靜態手寫 string-key entry + 專屬 finder、零動態生成** → 「通用」只對「再手寫命名行為」成立，對 **per-target goal（每個 forest tile 一個、每個 facility target 一個）不成立** → 要**宣告式 goal/前置 schema + runtime resolver**（含定位型通用「找滿足條件 C 最近可達 tile」resolver——現有 finder 全一次性、無通用版）。
  - `NeedOracle` chaining 真、但硬 scope `CONSTRUCTION_COST_RES` **只覆蓋「資源」1 種前置**；定位/人力/設施/子目標**其餘 4 種零機制** → 要擴。
  - 持久 goal-state ＝ **全新 `TeamData` schema**（現有三欄全不能用：`PersonData.goals` 脫節、`FactionData.goals` 每 cadence 重建、`strategic_goals` invariants:372 明文禁當獨立權威）+ 候選池組裝變更。
  - **委派非真 option**：現 `_try_dispatch_or_invite` 是 rank 池外的手評 heuristic → §4「委派跟自己做並列按 util 挑」要**把委派泛化成真 peer option**。
  - **折現 100% 新 code**。
- **∴ 規模 = 全建中等新子系統**（宣告式 schema + runtime resolver + 持久 goal-state + 委派泛化 + 折現），**接進既有 `rank_scored` 湧現本體**。非「純擴既有」。slice 上修更多，但 whole-system-first 不變（建完當 whole 才 measure）。

## 12. 成功判準（★整個系統建完才 measure，用戶原則②）
- 建完前**不邊建邊 measure 個別症狀**（broken 系統 measure 無意義）。
- 建完後回頭 measure：整個基礎經濟**活起來**——隊會為缺料去森林建據點、缺武器去蓋 weaponsmith（走完整鏈）、多線平行發展、人格差異化的投資取捨（穩定隊遠視發展、絕境隊短視求生）；EXPAND/harvest/facility-build/deal 不再近零；material 供給、coin liquidity、掛單噪音（hollow-economy）等本場 parked 症狀**自然消退**（都是此根的下游）。
- material 供給側（伐木場/賽跑/初始庫存/regen）＝此根修好、forest 有隊之後的下游 tuning，那時再 measure 定。

## 溯源
brainstorm 2026-07-24（藍圖×用戶）；`docs/notes/2026-07-19-long-range-planning-brainstorm.md`；material 調查鏈（race-collapsed → settle material-blind → means-end 三段全缺）；用戶兩原則（健全系統先 / 整個做完再找問題）；systems 架構 orientation；連 [[project_unified_decision_framework]]、[[project_causal_spine]]、[[project_economy_arc]]。
