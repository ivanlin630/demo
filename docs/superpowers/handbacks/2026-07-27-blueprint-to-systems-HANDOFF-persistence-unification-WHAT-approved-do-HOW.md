---
from: blueprint
to: systems
status: consumed
topic: "[★HANDOFF·持守統一 WHAT設計定案+用戶核可→你做HOW架構spec+plan+slice·spec=docs/superpowers/specs/2026-07-26-persistence-unification-design.md·L1大功能走R①(新大框factcheck,★especially『23散機制真能收成一套/兩層真能共讀』規模斷言要code坐實別重蹈means-end樂觀低估)+R②每slice+whole-system-first·★核心約束:util偏重非硬鎖(latch凍世界=反面教材,別merge、由這套取代)/危機地板=強制反應非強制逃(保背水一戰)/人格加權沉沒+前瞻/含任務持守+資源持守(material-hold一般化)/取代23散機制·latch freeze root先查懂(為何只碰施工卻凍全世界)餵設計避坑·A1若drain主因可能被資源持守一併收(待inflow-vs-drain診斷)] 持守統一WHAT設計brainstorm完+用戶核可(『Ok』+開檔看過),交你HOW。spec=`docs/superpowers/specs/2026-07-26-persistence-unification-design.md`。★摘要:一個持守強度、決策層(別亂換rank偏置)+執行層(別落跑/別賣committed資源gate)共讀,取代23散機制(12 flat bonus+10+ timeout),適用所有多tick committed動作(general)。持守強度=人格加權(沉沒成本+前瞻價值)不flat:固執型偏沉沒=死硬完成者、務實型偏前瞻=靈活轉換者。危機地板全人格通用:真危機強制主動反應(逃或戰、人格挑、偏執可背水一戰)、永不凍死;非危機走util+持守比。★硬約束:util偏重絕非硬鎖、任何情況不准凍世界(latch血證)。含任務持守+資源持守(committed料非危機別賣=material-hold一般化)。★你的工:①R①(新大框factcheck→寫HOW spec前)——★especially規模斷言:『23散機制真能收成一套』『兩層真能共讀同一持守值』『所有多tick動作真能走同一套』要code坐實別假設(means-end R①血證:你orientation『非新引擎』樂觀低估被異質reviewer駁,這次同樣要異質框外驗規模)②HOW架構spec(持守強度計算+兩層reader接線+危機地板保留PRIO+資源持守+移除23散機制)③plan+slice④R②每slice⑤implementer。★whole-system-first(整個建完當whole才measure,別邊建邊patch)。★★latch:不merge(凍世界),是反面教材由這套取代;★但先把latch freeze root查懂(為何只碰施工子隊卻凍全seed1337世界=詭異,那個json 12.39%矛盾也清掉)——這root餵持守設計『怎樣算over-latch、怎麼避免凍世界』,別讓統一版重蹈。★A1:資源持守若坐實A1『料被賣掉』屬drain則可能一併收;待inflow-vs-drain診斷(先挖現有log/clean重跑)定,不擋設計。material PARK到持守統一建完+measure。你R①若翻設計某塊回報我,WHAT我調;純HOW/slice你自主。開工。"
---

# ★HANDOFF：持守統一 WHAT 設計定案 → 交 systems 做 HOW

## 狀態
持守統一 WHAT 設計 brainstorm 完 + **用戶核可（「Ok」+ 開檔看過）**。交你 HOW。
- **spec**：`docs/superpowers/specs/2026-07-26-persistence-unification-design.md`

## 摘要（細節看 spec）
- **一個持守強度**、決策層（別亂換 rank 偏置）+ 執行層（別落跑/別賣 committed 資源 gate）**共讀**，取代 23 散機制，適用所有多 tick committed 動作（general）。
- **持守強度 = 人格加權(沉沒成本 + 前瞻價值)、不 flat**：固執型偏沉沒=死硬完成者、務實型偏前瞻=靈活轉換者。
- **危機地板**（全人格通用）：真危機強制**主動反應**（逃或戰、人格挑、**偏執可背水一戰**）、永不凍死；非危機走 util+持守比。
- **硬約束**：util 偏重**絕非硬鎖、任何情況不准凍世界**（latch 血證）。
- 含**任務持守 + 資源持守**（committed 料非危機別賣 = material-hold 一般化）。

## 你的工
1. **R①**（新大框 factcheck → 寫 HOW spec 前）：★especially **規模斷言**——「23 散機制真能收成一套」「兩層真能共讀同一持守值」「所有多 tick 動作真能走同一套」要 **code 坐實別假設**（means-end R① 血證：你 orientation「非新引擎」樂觀低估被異質 reviewer 駁；這次同樣要**異質框外驗規模**）。
2. **HOW 架構 spec**（持守強度計算 + 兩層 reader 接線 + 危機地板保留 PRIO + 資源持守 + 移除 23 散機制）。
3. **plan + slice** → 4. **R② 每 slice** → 5. **implementer**。
- **whole-system-first**（整個建完當 whole 才 measure、別邊建邊 patch）。

## ★★latch
- **不 merge**（凍世界），是反面教材、由這套取代。
- **★但先把 latch freeze root 查懂**（為何只碰施工子隊卻凍全 seed1337 世界＝詭異 + 那個 json 12.39% 矛盾也清掉）——這 root 餵持守設計「**怎樣算 over-latch、怎麼避免凍世界**」，別讓統一版重蹈。

## A1
資源持守若坐實 A1「料被賣掉」屬 drain 則**可能一併收**；待 inflow-vs-drain 診斷（先挖現有 log / clean 重跑）定，不擋設計。material PARK 到持守統一建完 + measure。

## 邊界
你 R① 若翻設計某塊回報我，WHAT 我調；純 HOW/slice 你自主。開工。

## 溯源
brainstorm 2026-07-26/27（藍圖×用戶）；spec `2026-07-26-persistence-unification-design.md`；`2026-07-26-commitment-persistence-inventory.md`；latch freeze clean-repro；連 [[project_unification_matrix]]、[[project_hand_obeys_brain_arc]]。
