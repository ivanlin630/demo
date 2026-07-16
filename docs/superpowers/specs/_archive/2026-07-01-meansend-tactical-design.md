# means-end 接戰術層（intent → 子需求 → reshape 戰術選項分數）— 設計 spec

> 系統 HOW spec。承藍圖 `means-end-tactical-arc`（下燒,解三症狀同根=查表非規劃）。願景進化第一深化 [[project_playable_priority]]。
> **斷點 measure 確認（碼證）**：戰術層 `DecisionEngine` util=`Σ weight(人格)×eval(context)`,**從不讀 team 自己戰略 intent**。唯一 goal→tactical hook = `faction_stakes`(f.goals∩{攻擊/徵收/外交})→`faction_duty` term,只給 faction 成員;**獨立隊 solo_intent reshape 零**。冒煙槍=征服名實 probe(`faction_ai:1190`)量了缺口沒補。
> **判準**：意圖→子需求→**貢獻打分 reshape option util**（非 flat）。行為從目標+情境湧現、維度自平衡（富則貿易/窮則搶）。**別 flat-tune rung**（那還是查表）。

## 核心 seam（generalize faction_duty 先例）
`faction_duty` 是**現成可推廣先例**：`DecisionContext.gather` inject `faction_stakes`(f.goals)→`faction_duty` term reshape 攻擊/徵收/外交。**複製此機制到「team 自己戰略 intent」**：

### ① inject intent 進 DecisionContext（mirror faction_stakes，`decision_context.gd:104-122`）
- ctx 加 `intent`（team 的戰略 intent：獨立=`team.solo_intent.type`、faction leader=`f.intent.type`、faction member 已有 faction_stakes）+ intent target（如征服/擴張的 target_id）。
- **獨立隊現 faction_stakes=[] → 改由 intent 供給 tactical 訊號**（斷點主修處）。

### ② intent → 子需求 → option affordance 打分（新 `intent_fit` term，mirror faction_duty，`terms.gd`）
- 每 intent decompose 成子需求 → 子需求 boost 對應 option util（**貢獻打分**：option 填子需求→加分,非 flat）。
- **第一增量 mapping（涵蓋三症狀）**：

| intent | 情境 | 子需求 | boost option |
|---|---|---|---|
| **致富** | 有餘糧 | 囤貨低買高賣 | **貿易** + 新 **囤貨**（蓋倉為填囤貨） |
| **致富/生存** | **匱乏** | 弄到資源 | **掠奪/攻擊**（窮又野心→搶,匱乏=侵略驅力非抑制） |
| **征服** | — | 削敵→俘虜→守 | **攻擊**（走偵查→打垮→吞併） |

- `intent_fit` drive magnitude（TEST VALUE,mirror `FACTION_DUTY_DRIVE`）× 人格適性（野心/貪婪/好戰染色）→ 加到對應 option。
- **匱乏→侵略**：低 food_days + 野心/貪婪 → 「弄到資源」子需求 → 掠奪/攻擊 boost（現匱乏只餵 survival/flee,加此讓窮野心隊搶）。**這是自平衡關鍵**（富則貿易囤貨/窮則搶）。

### ③ 征服攻擊路徑統一（收征服 measure 修向 + 症狀 b）
- 征服 intent → `攻擊` option（scored via intent_fit）→ **route 到 scout-gated prosperity/subjugate 路徑**（非舊 `_nearest_independent` 粗攻擊 + 非 _decide_unified 外的分離 gate）。
- = 消「兩條攻擊路徑」（征服 measure 揭）+ 讓征服 intent 真驅乾淨「偵查→打垮→吞併」鏈。攻擊 option applicable 對征服 intent 隊開（不再只 faction_stakes）。

### ④ 新 囤貨/stockpile option（致富 accumulate 子需求）
- REGISTRY 加 `囤貨`（致富+餘糧→蓋倉/存貨低買高賣）。affordance=致富 intent + 有市集/arb 潛力。讓「為賺錢預蓋倉囤貨」湧現（非建設碾貿易的死局）。

## 淺多步（2-3 步,不做完整 planner）
intent → 子需求（深度1-2,現算）→ option 貢獻打分。**完整 planner / AI 完美化 OUT**（節流閥,過四關才深下一步）。複用 faction `_decompose_needs` 精神但落 tactical。

## 四關驗收（藍圖硬要求）
1. **真變好戲**：specimen trace 看「規劃像不像」——致富商隊 想=致富→做=貿易/囤貨（非建設）;征服隊 想=征服→做=攻擊→capture;窮野心隊→搶。
2. **跑得動**：intent_fit 打分 O(options),LOD-scale（深推理只 named/重要,接 scaling);tick-time 沒爆（scaling_bed 量）。
3. **看得懂**：保持可 trace（specimen tracer 顯 intent→子需求→option util reshape）。
4. **還在賺**：bed 驗交易網轉（貿易 fire）+ CONQUER 起（>0 且轉 capture）+ 不 mass-starve + **不 over-war**（匱乏搶不能變全民劫掠潮）。邊際遞減就停。

## believability / 守恆
- 行為從目標+情境湧現、維度自平衡（解「移動標靶」——不用手動調食物 vs 侵略）。
- 北極星「凡 named 意圖必有可解釋驅動」holds：intent_fit 每 boost 帶 driver（連回 intent 子需求）。
- 守恆：coin_eq 全池 0、pop 守恆、framework S1-S6 PASS、warring 不 mass-starve + 不 over-war。

## 檔案
- `decision/decision_context.gd`：inject `intent` + target（mirror faction_stakes block）。
- `decision/terms.gd`：`intent_fit` term（intent→子需求→option 貢獻）+ 常數（TEST VALUE）。
- `decision/options.gd`：`攻擊` applicable 對征服 intent 開（非只 faction_stakes）+ 新 `囤貨` option。
- `faction_ai_system.gd`：征服 intent → 攻擊 route prosperity/subjugate（統一攻擊路徑,消粗攻擊）;_decide_unified 供 intent 進 ctx。
- `scripts/debug/`：specimen_bed 四關驗（致富→貿易/囤貨、征服→capture、窮野心→搶）+ warring（CONQUER 起/不 mass-starve/不 over-war）+ scaling_bed tick-time。

## 風險 + 緩解
- **over-war（匱乏搶變全民劫掠潮）**：intent_fit 匱乏→搶 drive 需 gate（野心/好戰門檻 + 稀有 by construction),bed 驗不 over-war。TEST VALUE 校。
- **征服攻擊統一動決策核心**：分階（先 intent inject + intent_fit 機制,再征服 route,再匱乏搶,再囤貨),每階 headless + bed。
- **tick-time（intent_fit 每 option 打分）**：O(options) 輕,LOD-scale;scaling_bed 量。
- **與單寫者 slice3 並行**：本軌碰 decision/*（context/terms/options）+ faction_ai(_decide_unified/攻擊 route)；單寫者碰 world_state/banks/combat_target/leader 指派 → faction_ai 不同函數,merge 序解。
- **scope（第一增量）**：致富/征服/匱乏三症狀 + intent_fit 機制 + 囤貨 option + 攻擊統一。**不做**：防衛/守成/建國/擴張 intent uplift（後增量）、完整 planner、tile-bank。

## 開放細節（plan 定）
- intent_fit drive 量級（TEST VALUE,mirror FACTION_DUTY_DRIVE 1.5）+ 匱乏→搶 gate 門檻。
- 囤貨 option 的 affordance/to_task（複用貿易 barter or 新 stockpile task）。
- 征服 route 落點（_decide_unified 內 攻擊 winner → 導 prosperity vs 直接統一 prosperity 為 scored option）。
- 淺多步深度（1 vs 2）+ 子需求現算 vs 快取。
