# 票 R：戰時徵用（特別稅改題）—— 主詞＝盟主、率＝勢力自己的、有宣告才可選、不取到儲備以下（HOW）

```
票源 ＝ 藍圖裁 `ae23c656c`（四問）＋`50172ed7d`（紅基線 11/11）
基準樹 ＝ `8c8efb64f`｜序 ＝ 它改經濟流向 ⇒ 觀察輪重跑要在它之後（藍圖）；我排在 A1 之後
```

## §0 現況（file:line）

```
觸發：`interaction_system.gd:391-396` 同勢力、收稅方 task＝TASK_TRIBUTE（徵收）、繳稅方帶 TAG_PRODUCE ⇒ `_resolve_tribute` 的特別稅分支
本體：`:679-700` rate ＝ **繳稅方的 tax_rate（它地主人格定的）× SPECIAL_TAX_MULT 1.5**；基礎＝庫存扣儲備（food 留 pop×14、coin 留一半）
  寫帳：`ResourceBank.set_amt(payer, …, "raid_out")`＋`ResourceBank.add(collector, …, "raid_in")`
紅基線（量測員）：Team7 那 11 刀 —— 無宣告 11／11、收稅者非盟主 11／11（盟主始終 Team4）、扣後低於儲備 0／11
```

## §1 做什麼（四問各一條）

```
Q2 主詞＝**盟主**（`FactionData.leader_team_id`，`faction_data.gd:6`）
   ⇒ ★列的條件＝做的條件：非盟主對同勢力生產隊的「徵收」**不列**（決策層），不是在結算時才擋
   ⇒ 「明示委派」：★R² 核過：**沒有**（TASK_HERALD 是信使不是授權）⇒ 本票只認盟主，委派另開
   ⇒ 成員對成員要拿東西 ⇒ 走既有勒索路（`_resolve_extortion`，`:487`）—— 本票不改勒索
Q3 率＝**勢力自己的**：盟主人格＋戰況的活變數 ⇒ 一支**新**函式（★R² 核過：`f.tribute_rate` 只是玩家指令可設的死欄位，零 NPC 動態導出 ⇒ 沒得重用）
   ⇒ 禁借繳稅方地主的 tax_rate、禁 ×1.5（`SPECIAL_TAX_MULT` 退場）
   基礎可以是庫存，兩條底線：
   ①不得取到繳稅方**生存儲備**以下 ⇒ 用既有定義，★禁另抄常數（今天的 `pop×14`／`coin 留一半` 是手抄的，一併換掉）
     ★R² 打回：~~`goal_resolver.gd:462 _resident_food_runway`~~ —— 它被 `goal_resolver.gd:418` 自己的註解標過 **god-view 嫌疑**
       ⇒ 改用 **`team.food_runway`**（`team_data.gd:168`，`food_flow.gd:27` 每日寫入的快取，零 RNG、自家數）
     ★門檻值：量測員報告用的「糧撐 3 天」—— **先查它的來源常數**；找不到 ⇒ 那是 WHAT 數字，回藍圖，不發明
     ★「貧困鎖」（coin 的底線）：`git grep "貧困|poverty"` **全站零命中** ⇒ 沒有既有定義 ⇒ 已問藍圖：只守糧、還是 coin 也要一條
   ②**每個應急狀態對同一成員只徵一次** ⇒ 勢力上要記「這一次應急」的身分＋已徵名單（新狀態 ⇒ ★全量暫態可觀測性：要有 tap）
Q1 有宣告才可選 ⇒ ★R² 核過：**全站沒有廣義的 at_war 旗標**；唯一可用的是 `FactionData.strategy == "戰爭基金"`（`faction_ai_system.gd:1999`）
   ⇒ ★而它**範圍窄**：只在「野心或好戰 > 0.6 **且** 盟主隊 material < 200」時才是這個值 ⇒ **材料充足的戰爭不會被抓到**
   ⇒ 「緊急徵收」是**糧食危機**，不是戰爭 —— 不准混進來
   ⇒ 本票照**窄範圍**做（只認「戰爭基金」），spec 明寫「這不是廣義的戰爭宣告」；要不要另立廣義宣告狀態 ＝ WHAT，已問藍圖
   ⇒ 沒有宣告 ⇒ 不列
Q4 名字＝**戰時徵用**：訊息印徵用者、率、應急理由；帳本 reason 改成 `wartime_levy_out`／`wartime_levy_in`
   ⇒ ★改 reason 的爆炸半徑在讀者：`raid_out` 的字面讀者今天是**量測員的三支床**（`tax_cadence_both_channels`／
     `team7_tax_reconcile_strength_ratio`／`wartime_levy_preconditions`）—— 交件時列出、通知量測員（不改他的床）
   ⇒ ★寫帳一律 `ResourceBank.add`（delta）—— 不再用 `set_amt`
   繳稅方關係帳記**大怨** ⇒ ★R² 核過：呼 **`NpcAiSystem.form_feud`**（`npc_ai_system.gd:36`，「唯一形成點」），
     `FEUD_MIN = 0.30`（`:13`）正好是那一層 ⇒ 給 severity 過門檻即可，**不另寫 if**；脫離勢力是正確後果（不加任何保護）
```

## §2 驗收

```
P1 [紅基線 → 0] 30 天世界：「無宣告**或**非盟主而成功徵用」的次數 ＝ **0**（基線 11／11）
P2 [儲備底線，佈置證] 把成員庫存壓到儲備邊再徵 ⇒ 扣後 ≥ 儲備（★儲備值印出、來自既有函式）
P3 [一次] 同一應急狀態對同一成員第二次 ⇒ 不列（或 ineligible「本次應急已徵」）
P4 [名字] 同 tick 訊息機制名＝「戰時徵用」＝ 帳本 reason 對照出的機制名
P5 [陽性對照] 盟主＋有宣告 ⇒ 徵得到、率＝勢力那支函式的值
P6 fp 會變 ⇒ 量、原子落地
```
