---
from: blueprint
to: systems
status: consumed
topic: commander-unify v2 核心 WHAT — 手段-目的意圖驅動模型(意圖=目標predicate/子需求=前提回推/行動=多義affordance/viability/driver invariant/深度1增量)
---

# commander-unify v2 — 核心 WHAT spec

整合多輪藍圖×用戶走查。這封 = commander-unify 的核心願景，**取代** war-priority 補丁與前版「單姿態」。系統據此寫 v2 plan。HOW（資料結構/查詢）你 owner。

## 北極星（已升 invariant，見 intent-driver-invariant handback）
**凡 named 意圖必有可解釋驅動**，追得回根。本 spec = 在統領層第一個落實這條。

## 模型：手段—目的 貢獻匹配（讓 AI 真「思考」非查表）

### 1. 意圖 = 目標狀態（goal predicate），不掛子需求清單
```
征服X = "X outpost 歸我 / X 不再獨立"
致富   = "treasury > T"
立國   = "有 capital 且被承認"
防衛   = "領土不失"
```
統領用 utility 選**主意圖**（吃人格/belief/可行性、resource-aware——湊不出總力征服就選更小意圖）。意圖要 commitment-hysteresis（戰略別每 tick 翻）。

### 2. 子需求 = 主行動「未滿足前提」對 live 世界現算（不手寫清單）
資料掛在**行動**上（效果+前提），不在意圖上。子需求機器現算：
```
意圖征服X → 主行動「攻擊取X勝」
  前提 vs 現況：
    我軍力>X軍力? 不足 → 開「補軍力」→ 徵兵/結盟 命中
    能抵達X?      X有盟擋 → 開「阻敵盟」→ 欺敵外交/離間 命中
    X 本無盟      → 此子需求不開（隨世界變）
```
加新意圖 = 寫一句 predicate，**自動**用既有行動 schema 分解。無 per-意圖 表。

### 3. 行動 = 多義 affordance 集（非單一 effect）
每行動帶多條 affordance = (效果, 服務哪類目標, 執行模式)：
```
貿易 = +coin(致富) / 砸敵經濟-斷供(削敵=貿易戰:收購敵供/傾銷) / 讓利好感(結盟) / 情報(認知)
外交 = 真結盟 / 欺敵 / 離間敵盟 / 緩兵 / 求承認
建設 = 都城 / 城防 / 產能 / 威望
徵收 = 籌資 / 壓迫控制 / 削弱屬民
攻擊 = 削敵軍力 / 掠奪得資源
```
開放子需求**選中**哪條 affordance → **染執行模式**（貿易戰 vs 致富貿易 = 同行動不同臉）。

### 4. util（匹配，無表）
```
util(行動 | 意圖, 世界) = Σ(行動 affordance ∩ 意圖開放子需求) × 人格適性 × 可行性
```
→ 湧現協同 scheme：多肢、每肢可解釋（driver=填了哪條開放子需求）、欺敵自然並發。

## viability 防漏 bar（驗收，取代「跟戰 3/4」）
舊「跟戰 3/4」作廢（外交是征服的肢、義氣 member 去欺敵=服務非缺席）。新驗收**兩條都要**：
1. **每選擇可解釋**：driver→意圖 追得通。
2. **scheme viable**：意圖**真被實現**——征服下確有足夠實打力，欺敵/籌餉是**輔非替**；核心手段優先填，輔助肢從適性餘裕抽。
**一句**：不數跟戰幾個，看「征服意圖→真有實打(intent realized) ＋ 每 member 選擇連得回意圖」。

## affordance 真實性 invariant（防假效果）
**affordance 必須真模擬得出**：貿易戰宣稱「砸敵經濟」→ 經濟 sim 要真讓「收購敵供→敵缺貨」傳導。宣稱了模擬不出 = **孤兒 affordance**（假效果）= 違反 viability/driver-completeness。**先有真模擬效果，才掛該 affordance**（靠已建市集/供應 plumbing 撐）。

## 玩家錨 C 連結（為何這是金礦）
世界 driver-complete + 行動多義 → 玩家情報遊戲 = **看可見 action 反推不可見 driver**（X 收購我供應商=致富還是貿易戰？拋外交=真心還是欺敵？）。多義+欺敵 = 霧裡推理/被咬的心臟。

## 範圍紀律（往死裡守，別 boil ocean / 別又白做一輪）
- **統領層先**，小行動集（攻擊/外交/徵收/貿易/建設/結盟），小意圖集（征服/致富/防衛）。
- **深度 1**：只算主行動未滿足前提→填補行動命中即用，不遞迴填補行動自己的前提。
- **affordance 先寫明顯幾條**，證了再擴；別一次每行動列十臉。
- **measure-first**：grep `_update_goals` 現況、量現發幾個無因令當基準；證 means-end util 跑出湧現 viable scheme 再擴種類。
- 不做完整階層 planner——淺回推（深度1）足以「思考」。

## 待系統
寫 v2 plan（上模型）→ brainstorm/spec → dispatch。前版單姿態 + war-priority 作廢。affordance 真實性處先盤點經濟 sim 撐不撐貿易戰，撐不住的 affordance 暫不掛、列債。
