# 思考模型的長程計劃（決策 v2 §4 深化 + 現況接地）— 未來 arc 停車筆記

> 藍圖×用戶 brainstorm 2026-07-19（無信箱藍圖 session，純未來願景）。**非現在派工**。存 `notes/`。**偏「當前已知缺口」而非遠 epic**（計畫層退役 + means-end 斷鏈是 game-design 現有 issue，只是排 framework 後）。接 game-design v2 §4（承諾）+ [[2026-07-19-decision-model-v2-deepening-brainstorm]]。
> **定位：這是讓今天所有維度能被「追求」而非「一時衝動」的脊椎**——沒它，軍閥煉不成天命、王朝立不起來、發展維度爬不上、造謠戰役撐不完（全多-tick）。

## 現況接地（file:line 坐實，藍圖看 code）
現在的「計劃」不是計畫層（S2 退役沒回來），是這幾塊拼的：

- **✅ 抗抖＝已解（COMMITMENT_BONUS hysteresis）**：`COMMANDER/FOUND/SOLO_COMMITMENT_BONUS` 全 0.15，rank 前偏置現任 option（`faction_ai_system:886/1213`）。**但 flat hysteresis，非累積 sunk-cost。** 配 timeout 滿地（SCOUT/FLEE/TRADE/STATION/FOUNDING，距離縮放）＝撐多久放棄。
- **✅ 一個能跑的長程 pattern＝立國**（獨立隊多-tick 意圖，FOUND_COMMITMENT_BONUS + FOUNDING_TIMEOUT + 信使 dispatch）。**證明 pattern 成立**，但 bespoke 一條。
- **⚠️ 目標表示＝粗糙 tag 集**：`f.goals`＝字串 tag 陣列（`if "立國" in f.goals`），**faction-level**（獨立隊 faction_id=-1 沒有＝斷鏈缺口）。`PersonData.goals` 欄位**死的**（沒人讀）。
- **✅ StrategicAI**＝faction 級戰術-戰略（包圍/突圍/結盟/找貿易夥伴，每 10h），非通用多-tick 規劃器。
- **TaskArbiter**＝單一 current_task + priority 層 preemption（COMBAT100/SURVIVAL80/THREAT70/PLAYER60/VENDETTA55/DISPATCH50/FACTION30/AMBIENT10）+ task_start_tick。

## 缺口（v2 §4 願景 vs 現況）
| v2 §4 要的 | 現況 |
|---|---|
| 延遲價值折現（估未來收益流值不值開工，折現率人格化）| ❌ 無（只 hysteresis 偏置現任，不估未來）|
| means-end 鏈（想goods→需設施→發起建）| ❌ 無（means-end 斷鏈）|
| 多步目標序列 | ❌ 無（goals 平坦 tag 集非序列）|
| 累積 sunk-cost | ⚠️ 只 flat 0.15 不累積 |
| 承諾擋雜訊不擋危機 | ✅ 有（priority 層 + 跨線 pre-empt）|

**一句現況：有「守得住」（commitment），缺「看得遠」（discounting）和「拆得開」（means-end）。**

## 設計＝泛化立國 pattern，非復活 plan-layer
現況剛好證實方向：「機會主義 + 承諾」那半已在（立國 + hysteresis + timeout），缺的正是「遠慾望 + means-end + 折現」那半。

> **長程計劃＝持久遠慾望（慾望泛化 registry）× means-end 依賴圖 × 折現/承諾（延伸現有 commitment-bonus），機會主義跨 tick 拼。**

## ★先後順序：從「前置依賴」湧現，非腳本序列（用戶戳「計畫要有先後」）
means-end 不是平坦子慾望清單，是**依賴圖（dependency graph）**：
```
立朝 └─需 嗣 ── 需 配偶 ── 需 聯盟價值 ── 需 權力/名聲
```
- 前置未滿的子目標＝**不 applicable**（就是求生 look-before-leap 那道現實 gate）→ 引擎選不了，fall through。
- 「生嗣」（無妻）fall through →「娶妻」（無聯盟價值）fall through →「建權」applicable→做 → 權力長→「娶妻」applicable→做 → 有妻→「生嗣」applicable→做。
- **∴ 順序＝「每步前置滿才 applicable」自動排出來。** agent 永遠抓「當下可行且最高 util 子目標」，applicability 鏈**強制順序卻不需腳本序列**。

**跟退役 S2 差（為何非復活它）：**
| 腳本計畫層 S2（退役）| 湧現順序（這個）|
|---|---|
| 算完整序列逐步執行、追 plan-state | 不算序列，只查「當下哪些子目標 applicable」（local/shallow）|
| 被打斷就壞（plan-state 亂）| 抗打斷：危機 pre-empt→空了從「當下 applicable」重抓，無 plan-state 可壞 |
| 替 agent 定路徑 | 人格挑路：硬前置（嗣需妻）依賴圖鎖、軟路徑（建權靠 打贏/貿易/結盟）人格選 → **軍閥 vs 商人走不同合法順序穿同一張圖** |

**紀律**：依賴圖**淺、有界**（幾層非 10 步規劃器，承 ⑤ 拒深樹）；每 tick 只查 local applicable，不算整圖。

**一句**：**順序真實存在，但長在「前置依賴 + applicability gate」裡讓引擎走出來，非腳本排。硬依賴鎖順序、軟路徑人格挑 → 同一計畫圖湧現多種合法走法。**

## 連今天維度
長程計劃是脊椎，今天的維度全是它承載的遠目標：軍閥煉天命（多路 means-end：打贏/加冕/聯姻）、立王朝（依賴圖 上例）、爬發展維度（累積）、造謠戰役（持久）、天災後重建（承諾抗打斷）。

## 溯源
本 session brainstorm（現況接地 code → 守得住/缺看得遠+拆得開 → 依賴圖 applicability 湧現順序 vs 腳本 S2）；`task_arbiter.gd`、`faction_ai_system.gd`（COMMITMENT_BONUS/timeout/f.goals/founding）、`strategic_ai_system.gd`、`person_data.gd`（死 goals 欄）；game-design v2 §4 承諾 / means-end 斷鏈 line 281；[[project_established_chain]]（計畫層 S1-4 退役）；[[project_unified_decision_framework]]；接 [[2026-07-19-decision-model-v2-deepening-brainstorm]]。
