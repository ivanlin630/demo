# 長程計畫 / means-end 決策系統 — WHAT 設計（藍圖×用戶 brainstorm 2026-07-24）

> ★arc 未開工;本檔=WHAT 骨架,HOW 檔已標重寫。
> **定位**：WHAT/願景設計（behavior/model/scope），非 HOW 架構 spec。定案後交 systems 做 HOW（架構 spec + 實作 plan + slice）。
> **起源**：material 供給調查挖到底，真 binding root = 決策模型無 means-end/長程計畫能力（`settle_fit` 等 flat 決策常數、need 不沿鏈傳、goal 沒表示成可鏈子目標）。用戶定：`健全的系統才有價值的模擬結果`+`整個長程計畫做完當一個 whole 再回頭 measure 找問題`。接 `docs/notes/2026-07-19-long-range-planning-brainstorm.md`。

## 1. 目的
隊能**追求需多 tick 才達成的目標**（發展、取得資源、蓋設施，未來史詩：王朝/天命/天災/造謠），行為**從決策引擎湧現**非逐個 hardcode。核心病：現在決策模型不會「我要 A，但 A 需要 B，那我先去弄 B」。逐個 patch = 無限打地鼠+每條違憲 scripted;**通用 means-end 機制 = 唯一不打地鼠的解。**

## 2. 範圍
- **機制（引擎）＝全建**（用戶定 scope B）：①持久遠慾望 registry ②means-end 依賴圖 ③applicability 湧現順序 ④折現/承諾。
- **內容（初始 goals）＝全部基礎層**（不只材料/發展，含 food/material/tools/weapons/coin + 所有設施）。
- **史詩層 goals＝之後當 registry 資料加**（通用性的價值：加 goal = 加資料、零決策 code）。
- **非目標**：不復活退役的 S2 腳本計畫層；不建顯式「總參謀」多工程組合規劃器（見 §9）。

## 3. 核心模型（脊椎）
1. **持久遠慾望**：隊攜帶多個「想要」，**跨 tick 持久**，不因當下不能做而蒸發。
2. **宣告式依賴 registry 拆子目標**：每個慾望經**資料表**拆成子目標鏈（武器坊 └需 material+tools └material 需 forest-access └需 forest 據點 └需 pop≥N）。
3. **applicability gate**：前置滿了才可選（複用既有 `option.applicable`）;未滿 → fall through 到當下能做的子目標。
4. **每 tick 挑當下最高 util 的 applicable 子目標**（複用既有 `rank_scored`）。**無 plan-state、無腳本序列**——順序**湧現**自 applicability 鏈;硬前置鎖序、軟路徑人格挑。
5. **need 沿鏈往上傳（means-end chaining）**：慾望生子 need、子生孫 need =「拆得開」。**核心新增**（既有 `NeedOracle` 有 need 傳播、但不沿依賴鏈往上）。

## 4. 多線（平行）
- 隊的「戰略」＝同時掛著的一組持久慾望（≥1 條線）、平行推進。
- **委派是選項之一**：「派小隊做 X」與「自己做 X」並列 option 集按 util 挑。
- **平行執行**：母隊+多小隊各走各的子目標鏈;**餘力 gate 配額**（既有 dispatch pop-guard）：窮部落跑少線、強權鋪多線。
- **跨線協調＝隱式**（用戶核可）：util 排序+餘力 gate 自動分配，不建顯式總參謀。
- 「每 tick 挑一步」是**每個 actor** 層級（物理限制）;隊層級全平行。

## 5. registry 一列結構（前置種類）
一個目標的前置只有幾種固定**種類**（引擎認種類、資料隨目標變）：

| 前置種類 | 引擎怎麼追 | 例 |
|---|---|---|
| **資源** | 取得該資源（採/產/買，遞迴其鏈） | 武器坊需 material+tools |
| **定位** | 移動到/控制該地形的 tile | 材料需「在 forest」 |
| **人力** | 長 pop 到門檻 | 建據點需 pop≥N |
| **設施/狀態** | 蓋該設施 / 達該狀態 | tools 需 workshop |
| **子目標** | 遞迴達成另一目標 | 王朝需嗣（史詩層） |

- 每個未滿前置 → 遞迴成子目標。加新鏈 = 填格 = 資料。**種類固定（有界）** = 通用性的實體。

## 6. 折現（看得遠）
- 只有**投資型**子目標折現（現在花、N tick 後回本）;即時動作不折現。
- 投資型 util = **預期回報 × 折現(延遲, 人格)**。
- **人格 = 折現率**：耐心折現輕（看得遠）、衝動/絕境折現重（顧眼前）→ 餓=短視/穩=遠視，**權重非 gate**。
- **HOW 待 systems**：「預期回報」估法（淺啟發非完整經濟模型，守有界）。

## 7. 承諾（守得住，複用既有）
既有 `COMMITMENT_BONUS` hysteresis + timeout + priority 層 pre-empt 已提供「守得住」，**複用不重造**。means-end 補「拆得開」、折現補「看得遠」。

## 8. 基礎 goal-set（初始填）
- **資源維持**：food / material / tools / weapons / **coin**——每個「維持夠用 X」慾望 → 取得鏈。★coin 取得鏈與 harvest 不同：走「有可賣餘量+有買家」前置自然表達;coin-liquidity 症被「需 spendable coin → 需 extract」自然涵蓋。
- **設施發展**：每座設施 →「想要設施 F」慾望 →「資源+定位+人力」鏈。
- 這兩類蓋掉整個基礎層。

## 9. 有界 / 非目標
- **淺、有界**：registry 鏈幾層;每 tick 只查 **local applicable**，永不算整張圖、不追 plan-state（與退役 S2 的根本差別：無 plan-state 可壞，危機 pre-empt 後從當下 applicable 重抓）。
- **不建顯式總參謀**：多線靠「多慾望+多 actor+餘力 gate+util 排序」湧現。
- **不復活 S2 腳本計畫層**。

## 10. 憲法對齊
- **utility 餵 utility 非 scripted**：零 hardcode 決策 edge（「缺料→去森林」是圖走出的路徑）。
- **人格 WEIGH 不 GATE**：人格進折現率/util 權重。
- **通用非 bespoke**：加 goal = 加 registry 資料。
- 世界結構約束（terrain 產量、outpost-type、allowed_outpost）保留＝物理。

## 11. 規模：全建中等新子系統（R① 異質 reviewer 訂正 2026-07-24）
原句「擴既有機械」= 樂觀低估，R① 判 premise_contradiction 訂正;**願景本體不變**、改的只是規模認知：
- **真複用（薄）**：`rank_scored` argmax ＝湧現順序本體;新子系統做「合成 candidate options 併入 rank 池」。
- **要真新增（= 中等新子系統）**：①宣告式 goal/前置 schema + runtime resolver（`options.gd` 靜態手寫 entry 對 per-target goal 不通用;含通用定位型 resolver）②`NeedOracle` chaining 擴到 5 種前置（現只覆蓋資源型）③持久 goal-state = 全新 `TeamData` schema（現有三欄全不能用）④委派泛化成真 peer option（現 `_try_dispatch_or_invite` 是 rank 池外手評 heuristic）⑤折現 100% 新 code。
- whole-system-first 不變（建完當 whole 才 measure）。

## 12. 成功判準（★整個系統建完才 measure，用戶原則②）
- 建完前不邊建邊 measure 個別症狀。
- 建完後回頭 measure：整個基礎經濟**活起來**——為缺料去森林建據點、缺武器蓋 weaponsmith（走完整鏈）、多線平行發展、人格差異化投資取捨;EXPAND/harvest/facility-build/deal 不再近零;material 供給、coin liquidity、hollow-economy 等 parked 症狀自然消退。
- material 供給側 tuning ＝此根修好後的下游，那時再 measure 定。

## 溯源
brainstorm 2026-07-24（藍圖×用戶）；`docs/notes/2026-07-19-long-range-planning-brainstorm.md`；material 調查鏈；用戶兩原則；systems 架構 orientation；連 [[project_unified_decision_framework]]、[[project_causal_spine]]、[[project_economy_arc]]。
