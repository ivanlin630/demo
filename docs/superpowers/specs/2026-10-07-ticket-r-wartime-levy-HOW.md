# 票 R：戰時徵用（特別稅改題）—— 主詞＝盟主、取額＝盟主的決策輸出、有宣告才可選（HOW）

```
票源 ＝ 藍圖裁 `ae23c656c`（四問）＋`50172ed7d`（紅基線 11/11）＋`e52932ccb`（②宣告）＋★`22b0d73dd`（取額＝決策輸出，取代 e52932ccb 的①③）
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
Q3 ~~率＝勢力自己的…兩條底線（①不取到 5 天儲備以下 ②每應急每成員一次）~~
   ★★藍圖改裁（`22b0d73dd`，回用戶「留量要寫死 5 天嗎」）：**無硬底線、無硬次數** ⇒ 取額＝**盟主的決策輸出**
   ⇒ ★HOW 邊界（藍圖明寫）：**不准先做「5 天版」**；「留一半」「pop×14」「×1.5」三個手抄全部退場
   ⇒ 形狀：一支取額秤 `WartimeLevy.choose_amount(state, overlord, member) -> {amount, cands}`，在**結算那一刻**（雙方同格、
      `_resolve_tribute` 特別稅分支）對**離散候選**逐一算 util、取 argmax（藍圖允許的「離散幾檔」形）
      ·候選＝ 0（不徵）＋ 成員**當下** food 庫存的幾個比例（格子由你定、表放函式旁；★格子是候選不是底線：最大一檔必須是全部）
      ·util ＝ 收益 − 三個成本，**同一單位**（★util 必＝真值，禁為了讓它 fire 而調）：
        收益：填戰爭基金缺口（`WAR_CHEST_MIN` − 盟主隊 material 的差額；超過缺口的部分收益遞減），乘盟主 野心／好戰
        ★徵後糧撐推估（R² 核：沒有現成公開純函式；`FoodFlow.update()` 直接寫 `team.food_runway`、`_sustainable_inflow` 底線前綴私有）
          ⇒ 在 `food_flow.gd` **抽一支公開純函式**（把 update() 裡算 runway 的式子抽出來，參數帶「假設庫存」），update() 與徵用秤**都呼它**
          ⇒ 不另抄算式、不伸手進私有函式；★抽完 update() 寫出的值必須逐字不變（fp 床那一格會證）
        成本①推成員向挨餓：以徵後 `member.food_runway` 推估值對 `SURVIVAL_SATED_DAYS`（`need_hierarchy.gd:16`）為**參考點**，
              低於它曲線變陡、**連續、單調、不 clamp**（不是牆）；乘盟主 慎重／義氣
        成本②忠誠流失：成員對盟主的關係帳現值（兩層關係帳）—— 關係越薄，抽多越貴
        成本③最近才徵過：距上次徵同一成員的 tick 數（新狀態：勢力上記 member → last_levy_tick；★全量暫態可觀測性要有 tap）
      ·人格鍵用既有正典鍵（貪婪／慎重／義氣／野心／好戰 —— `interaction_system.gd:757-759` 已在讀其中三個），**先 grep 確認每個鍵存在**
   ⇒ ★tap（藍圖點名）：每次 choose_amount 一筆樣本 {tick, overlord, member, gap, member_runway, 每個候選的 {amount, gain, c1, c2, c3, util}, chosen}
   ⇒ 成員回應＝決策：照勒索那條 `DiplomaticAiSystem.tribute_accept(state, member, overlord, threat)`（`diplomatic_ai_system.gd:49`，
      呼叫形狀見 `interaction_system.gd:446`）；拒絕 ⇒ ~~不轉移、記入關係帳、後果照勒索拒絕那條既有路（不另寫）~~
      ★★R² 打回（第四輪）：勒索拒絕的既有路 ＝ `_should_attack`（`interaction_system.gd:466-481`）→ `start_combat`（`npc_combat_system.gd:118-133`），
        兩支**零 faction 檢查** ⇒ 照抄 ＝ **盟主對自己的成員開戰**；今天沒出事只因沒有東西把同勢力兩隊送進那個分支，本票會是第一個
      ⇒ 改：只重用 **tribute_accept 的判斷**，**不呼 `_should_attack`／`start_combat`**；拒絕 ⇒ 零轉移＋關係帳記一筆（盟主對成員的好感下降，
        走既有關係寫入口）＋tap 記 refused；社會性後果只有 Q4 那一套（記怨／可能脫離），**不並存第二個後果模型**
      ⇒ 「拒絕可能引發內戰」**不是本票的設計**；若要，另開票，且在呼 `_should_attack` 之前**明判 faction_id** 讓那個決定看得見
      ⇒ 床：P6 補一格「拒絕之後同 tick 與後 24 tick 雙方 combat_target 都不是對方」
      ★★藍圖確認問「它是不是無條件接受」⇒ 核過（`diplomatic_ai_system.gd:49-103`）：**不是**，回 `score > TRIBUTE_ACCEPT_THRESHOLD`，score 讀
        人格（慎重／義氣／求生欲）＋fear＋**兩層關係帳**（好感 `leader.relations` ＋ typed 邊 feud／gratitude）＋belief 實力比＋threat
        ⇒ ★**缺兩樣**：①成員**自身處境**（food_runway）②**被要求的量** —— 今天對它來說抽 1 糧與抽光一樣
        ⇒ 本票補：tribute_accept 加一個可選參數「這次要求佔我庫存的比例」＋讀自身 food_runway（同樣以 SURVIVAL_SATED_DAYS 為參考點），
          兩項都讓 score 下降（要得越多、自己越窮 ⇒ 越可能拒）
        ⇒ ★既有呼叫點（勒索兩處 `interaction_system.gd:446/:455` 等，交件時 grep 列全）不傳 ⇒ 該項＝0 ⇒ **行為逐字不變**（負對照：不傳參數時勒索那支床的 score 序列不變）
        ⇒ threat 參數在同勢力徵用：填盟主隊 readiness（同勒索的定義）—— R² 若判語意不合再改
   ⇒ ★argmax＝0 ⇒ 不徵、不發訊息、tap 照記（「決定不徵」也是一個決策結果）
Q1 有宣告才可選 ⇒ ★R² 核過：**全站沒有廣義的 at_war 旗標**；唯一可用的是 `FactionData.strategy == "戰爭基金"`（`faction_ai_system.gd:1999`）
   ⇒ ★而它**範圍窄**：只在「野心或好戰 > 0.6 **且** 盟主隊 material < 200」時才是這個值 ⇒ **材料充足的戰爭不會被抓到**
   ⇒ 「緊急徵收」是**糧食危機**，不是戰爭 —— 不准混進來
   ⇒ 本票照**窄範圍**做（只認「戰爭基金」），spec 明寫「這不是廣義的戰爭宣告」；要不要另立廣義宣告狀態 ＝ WHAT ⇒ ★藍圖裁：照窄範圍做，**登 defer**（`defers.tsv` 列 `ticket-r-declaration-narrow-until-war-flag`，
     錨＝faction／world 出現戰爭狀態欄位的那一天，宣告條件改接它）
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
P1 [紅基線 → 0] 30 天世界：「無宣告**或**非盟主而成功徵用」的次數 ＝ **0**（基線 11／11，Team5→Team7）
P2 [人格鑑別]（藍圖點名）同缺口、同成員處境，只換盟主人格：貪婪 0.9 vs 慎重 0.9 ⇒ 取額**分佈分得開**（印兩組 chosen 與差）
   ★反向：把秤裡的人格項拿掉（負對照）⇒ 兩組必須塌成同一個值 ⇒ 證明是人格造成的差，不是佈置
P3 [不得一條線]（藍圖點名）全世界所有徵用的「徵後 food_runway」分佈：不得集中在單一值（印直方圖；特別看 5.0 與「庫存的一半」兩處有沒有堆積）
P4 [曲線不是牆] 佈置：缺口極大＋貪婪極端的盟主 ⇒ 允許取到 food_runway < SURVIVAL_SATED_DAYS（印出實值）；慎重極端 ⇒ 取額明顯較少
P5 [再抽變貴] 同一成員連續兩次結算 ⇒ 第二次的 c3 > 0 且 chosen 不大於第一次（同條件下）
P6 [成員可拒] 佈置成員關係薄＋威脅低 ⇒ tribute_accept 回 false ⇒ 零轉移、關係帳有紀錄
P6′ [量與處境會被讀] 同一成員、同關係：要求比例小 vs 大、自身 runway 高 vs 低 ⇒ score 單調下降（印四個 score）；★不傳參數的勒索路 score 與修前逐字相同
P7 [名字] 同 tick 訊息機制名＝「戰時徵用」＋實抽量 ＝ 帳本 reason（wartime_levy_out／in）對照出的機制名；守恆兩 tag
P8 [tap] choose_amount 樣本存在、每筆含所有候選與三個成本項
P9 fp 會變 ⇒ 量、原子落地
```
