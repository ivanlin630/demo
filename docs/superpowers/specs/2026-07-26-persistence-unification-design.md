# 持守統一（Persistence Unification）— WHAT 設計（藍圖×用戶 brainstorm 2026-07-26）

> **定位**：WHAT/願景設計（behavior/model/scope），非 HOW 架構 spec。定案後交 systems 做 HOW（架構 spec + plan + slice）。
> **起源**：means-end 建完後，A1 施工卡在執行端；深挖發現「committed 卻落跑」是貫穿全專案的 recurring 家族（手不聽腦）。用戶點破：**「手（執行持守）統一是統一矩陣的一個維度，沒做＝系統不健康」**。盤點坐實現有 23 個散落持守機制（`docs/superpowers/2026-07-26-commitment-persistence-inventory.md`）。這是**腦（決策 means-end）已統一、但「持守」從沒被統一收過**的補課。
> **★重要區分（用戶釐清）**：決策層統一的是「**選**」（一個 rank 引擎）；「**持守**」（多堅持 committed 動作）是**橫跨決策層+執行層、兩層都散拼的另一個關注點**——本 arc 收的是它。
>
> ## ★★R①-corrected scope（2026-07-28，異質 R① code 坐實 + 用戶裁乙）——此段 supersede 下方過度宣稱處
> R①（異質框外 + code 坐實）三駁原 scope 過度宣稱，已調（**願景本體不變**：人格加權持守 + 不 over-latch + 背水一戰；改的是 scope 邊界 + 規模認知）：
> - **①分兩軸（危機 axis 排除）**：「持守」（同類內投入強度）vs「急迫/危機」（哪層贏、跨類排序 + `CRISIS_FLOOR` 反持守）= **兩獨立軸**。PRIO 階層 / combat_lock / emergency_guard / crisis-floor **排除本模型外、留原樣**（它們守命/反持守）。**§4「全收 27」作廢**，對齊 §3c。**★背水一戰仍保住**（來自危機 axis + 人格挑逃/戰，非持守 axis）。
> - **②progressive-only + 重掃**：沉沒成本/前瞻只套**有進度/終點**的動作（build/upgrade/campaign）；**FLEE**（開放無終點）+ TRADE/FOUNDING 一次性 timeout **排除、走既有**。27 表不齊（礦山豁免漏列）→ **寫 HOW 前重掃現有機制**。
> - **③規模誠實（用戶裁乙=執行層現在做）**：「兩層共讀同一持守值」**不是免費既有通道**——`COMMITMENT_BONUS` 零寫回、`try_set` 整數 tier 非 util、~29 call site 硬編 → 執行層 = **重寫任務仲裁成持守-aware = 真架構 build（如 means-end 是新子系統，非「收既有」）**。**★用戶裁乙**：執行層持守（A1 手不聽腦真標的）**本 arc 現在做**、當真 build 切 slice；決策層 bonus 家族（COMMITMENT/SOLO/FOUND + survival_committed_stall ~5-6 項 → 沉沒+人格加權）= 早期 slice。
> - **∴ 本 arc = 執行層持守（重寫仲裁成持守-aware，修 A1）+ 決策層 bonus-collapse，progressive 動作、危機 axis 除外、當真架構 build 切 slice、whole-system-first。**

## 1. 目的
把散落兩層的 23 個持守/反落跑補丁（決策層 12 個 flat bonus + 執行層 10+ 個 timeout/guard/immunity）**收成一套統一「持守」模型**，根治「committed 卻落跑/卡住」的 recurring 家族（crisis-override / subteam-idle / market-seek / TASK_BUILD / construction-stall…每個現在各補一套 = 打地鼠）。

## 2. 範圍（甲：一套、橫跨兩層、全動作通用）
- **一個「持守強度」值**，決策層 + 執行層**共讀**（同一數字兩處用），取代 23 個散機制。
- **適用所有多 tick committed 動作**（施工/遠行/trade run/遠征/founding…一視同仁），非每種各補——這就是「general」。
- **涵蓋兩種持守**：
  - **任務持守**：別中途放棄 committed 的動作（落跑去做別的）。
  - **★資源持守**：別把為 committed 目標保留的資源（如要蓋設施的 material）在非危機下賣/花掉。（＝本場 material-hold-protection 的一般化，folds 進來。★這條若坐實 A1 的「料被賣掉」屬此，則 A1 可能被本 arc 一併收掉——待 inflow-vs-drain 診斷定。）

## 3. 核心模型

### 3a. 持守強度 = 人格加權(沉沒成本 + 前瞻價值)
- **不 flat**（現行病＝全 0.15 flat，「剛起念」與「投一半」同值）。
- **沉沒成本（往回看）**：已投入越多越不捨放。**固執/恆心型人格權重高** = 死硬完成者（投了就拚到底，即使不理性＝好戲，如死守敗局圍城的軍閥）。
- **前瞻價值（往前看）**：離完成/回報越近，該動作 util 越高、越自然勝出。**務實/機會型人格權重高** = 靈活轉換者（剩下還值得做才做、肯放爛投資）。
- **★人格決定「沉沒 vs 前瞻」的混合比**——持守變成一個**性格維度**（死硬完成者 vs 靈活轉換者），接上 archetype 多元 + 湧現角色感。
- 人格→權重 mapping（哪些值偏沉沒/偏前瞻，如 慎重/固執→沉沒、貪婪/機會→前瞻）＝細節，spec/plan 定，非本設計釘死。

### 3b. 兩層共讀同一持守強度
- **決策層**：讀它當「別亂換」的 rank 偏置（贏過它才切非危機的新目標）。
- **執行層**：讀它當「別中途落跑/別賣掉 committed 資源」的 gate。

### 3c. 危機地板（全人格通用、人格不可關）
- 真危機（求生/戰鬥，現 PRIO 階層 COMBAT/SURVIVAL/THREAT）**強制隊做出主動反應**——**必須動（逃 或 戰），永不無視、永不凍死/呆住**。（這條防 latch 式凍結。）
- **反應「逃還是戰」＝人格 util**：務實逃、**偏執/狂信 → 背水一戰**（動作、不是凍結）。**偏執狂人死在最後一戰＝好戲，非 bug**；真 bug 是「隊呆住什麼都不做、世界鎖死」。
- 非危機的「換不換發展目標」→ 走 util + 持守比（要贏過當前動作持守強度才切）。
- **∴ 硬危機用階層守命（守住不無視survival）、軟選擇用持守比湧現、但地板內容＝「強制反應」非「強制逃」（保住背水一戰）。**

### 3d. 硬約束（latch 血證）
持守是 **util 偏重、絕不是硬鎖**——**任何情況都不准凍死世界**。construction-commitment latch（本場 A1 首修）就是踩了這條（持守做成硬 latch → 凍 seed1337 全世界）→ **latch 不 folds、是反面教材**，由本統一模型（做對、util-based、無硬鎖）取代。latch branch **不 merge**。

## 4. 取代 23 散機制
決策層 12 flat bonus + 執行層 10+ timeout/guard **全收進本模型**；成熟樣板的好性質（TRADE/FOUNDING timeout 距離縮放、survival-stall 人格×relief）**吸收進統一模型**，非另留。

## 5. 憲法對齊
- **utility 餵 utility 非 scripted**：持守是 util 權重（rank 偏置 + gate），非寫死決策 edge。
- **人格 WEIGH 不 GATE**：人格調沉沒/前瞻混合比 + 危機反應選擇，是權重非硬類別閘（唯危機地板「必須反應」是全通用 floor，非人格 gate）。
- **通用非 bespoke**：所有多 tick 動作走同一套，加新動作免補新 timeout。
- **非硬鎖**（latch 反例）：util 偏重、永不凍世界。

## 6. 非目標
- 不做硬 latch（latch 凍世界＝禁）。
- 危機地板＝「必須反應」非「必須逃」（保背水一戰）。
- 不碰「選」的統一（means-end 已做）——本 arc 只收「持守」。

## 7. 與 A1 / latch 的關係
- **latch** = 持守做錯的首次嘗試（硬鎖凍世界），本 arc 做對取代之；latch 不 merge。
- **A1** = 若其「材料進不來」根因是**資源被非危機 urgency 賣掉**（drain，＝資源持守失敗），則本 arc（含資源持守）**可能一併閉 A1**；若是純 inflow 太慢（供給側）則不閉、A1 另等供給。**待 inflow-vs-drain 診斷（先挖現有 log/clean 重跑）定。**

## 8. 成功判準（★整個系統建完才 measure，用戶原則②）
建完後 measure：
- 隊**不 thrash**（照人格堅持 committed 多 tick 動作：死硬型完成率高、務實型適度轉換）。
- 隊**不凍死**（危機一律觸發反應、非危機不呆住）；**世界永不凍結**（latch 反例不重演）。
- **背水一戰真湧現**（偏執人格危機下死守）+ 務實人格逃——人格分化。
- committed 資源不被非危機賣掉（資源持守）；A1 施工若 drain 主因則完工。
- 23 散機制移除/subsumed、無殘補釘（constitution_gate + 新機器閘驗）。

## 9. 溯源
brainstorm 2026-07-26（藍圖×用戶，走 superpowers:brainstorming）；`docs/superpowers/2026-07-26-commitment-persistence-inventory.md`（23 機制底稿）；`docs/notes/2026-07-19-long-range-planning-brainstorm.md`（commitment 現況）；latch 凍世界血證（clean repro）；連 [[project_unification_matrix]]（持守＝矩陣新維度）、[[project_hand_obeys_brain_arc]]、[[feedback_observer_no_global_rng]]（勿重蹈觀測污染）。
