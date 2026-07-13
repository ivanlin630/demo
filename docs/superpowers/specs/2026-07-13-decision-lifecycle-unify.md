# 決策生命週期統一（②分流收斂 + ⑦釋放統一）— systems HOW

> 藍圖裁(`final-push-build`)：守門員全圖最後兩塊 N-瞎子核心。②四條決策路收斂單一路(尤 faction 成員無個人日常決策=最大洞)。⑦四套釋放判斷收斂「重評 cadence+crisis」統一框架。灰區(urgency 重疊/commitment/豁免)不動。自主全流程。

## ★★架構紀律（硬性，不可實作時簡化；藍圖 `architecture-discipline-reinforce`）
**合併≠統一**。收斂後**唯一做「選哪個行動」判斷的地方=rank_scored**（+既有允許例外：TaskArbiter 優先權插隊、cadence 節流本身）。
- **②**：unified/solo/subteam/member 四隊形差異→**表為餵進 rank_scored 的輸入維度**（ctx 旗標/需求金字塔/係數表的一個維度），**非**「四段 if-else 決策邏輯搬進同函式殼還各判各的」。判準：合併後 code 是否仍只有 rank_scored 一處選行動?任何「先過濾候選/先判情況」若自己決定行動=又一獨立決策點,禁。
- **⑦**：四套「何時重評」→**同一套急迫度/停滯偵測機制**驅動所有情境重評時機,**非** cadence 函式內又長四段 if 換殼。
- **final 報告必含此自檢**：實作後決策「判斷點數量」是否真收斂到 rank_scored 一處(+允許例外),非只報「4合1檔案變少」表面指標。

## 現況（守門員全圖坐實）
- **②分流**：`_process_faction_ai` loop(665-696)：subteam→`_evaluate_subteam`；獨立(faction_id==-1)→`_evaluate_independent_strategy`+`_evaluate_solo`；**成員(faction_id!=-1)→只 `_evaluate_independent_strategy`(戰略層),日常任務由 faction leader `_assign_tasks`(:639/1352) push,成員無個人 rank_scored 決策**(債縫#3)。`_evaluate_solo` 內 `uses_unified`→`_decide_unified` vs solo rank。
- **⑦釋放**：survival release(food-recovery hysteresis :3042)/threat release(no-threat :368 + FLEE_TIMEOUT :95)/stuck release(_is_stuck :1792)/timeout latch——四套獨立「何時重評」。

## Slice ②-1（★優先，最大洞）：faction 成員個人日常決策路
**目標**：成員也跑統一決策(rank_scored)。faction 命令由既有 `faction_duty` term(攻擊/徵收/外交/歸建 響應 faction goal)pull;無命令時成員自主日常(生產/貿易/覓食…)。填「成員無腦」洞。

**設計（faction 令 push→pull 轉換）**：
- `_assign_tasks`(:1352) **降為設 faction goal/target context**(寫 `f.goals`/directive),**不再直接 push 成員 current_task**。faction 意圖成為成員 `ctx.faction_stakes`(gather 已讀 :248)→成員 rank 經 faction_duty term 響應。
- loop(684-696) 成員段：`_evaluate_independent_strategy` 後 **加 `_evaluate_member_decision`**(=成員版統一決策,鏡射 `_evaluate_solo` 但成員語意:含 faction_duty pull + 個人日常;subteam-gate 不適用)。
- **保 faction 協同**：faction_duty term weight=`_duty_factor(loyalty,野心)`→忠誠成員 rank 選 duty option(聽令);不忠→個人(叛意)。協同由「命令進 context + 忠誠成員 rank 選它」保,非硬 push。
- **survival/threat 分軌保**：成員一樣走 `_evaluate_survival`/`_evaluate_threat`(loop3 全隊,已含成員)→絕境/威脅反射不變。

## Slice ②-2：決策路收斂（unified/solo/member 三入口→單一）
**目標**：`_decide_unified`/`_evaluate_solo`/`_evaluate_member_decision` 共用單一 `_decide(state, team)` 核心(rank_scored+reorder+dispatch loop),路差(unified survival-sticky/subteam STRATEGIC-gate/member faction 語意)化為 **ctx 旗標/applicable-gate**,非分離函式。
- 收 `uses_unified` 分岔(survival-sticky 差異→ctx.is_unified 旗標,rank 內處理)。
- subteam 保 `_evaluate_subteam`(lifecycle 特殊:歸建 move/merge queue),但其**決策部分**也委派 `_decide` 核心(STRATEGIC_SELFINIT gate 已在 applicable)。
- **風險**：三路現有細微行為差(commitment 基準/survival-sticky/dispatch aux wiring)→收斂須逐一保 byte-identical 或明列變更。**②-2 較 ②-1 大且風險高**,可 ②-1 先 merge 驗再做 ②-2。

## Slice ⑦：釋放統一（四套→重評 cadence+crisis）
**目標**：survival/threat/stuck/timeout 的「何時重評」收斂——皆表為「觸發一次重評」,經統一 `DECISION_CADENCE + _decision_crisis` 框架,非各自獨立 early-return/release。
- **survival release**(食恢復)→ 保 hysteresis 語意,但「脫離 survival→重評」走統一重評(release→IDLE→下個 cadence/crisis 重決),非特殊路。
- **threat release**(no-threat/FLEE_TIMEOUT)→ 威脅消失/逾時=「觸發重評」條件,併入 `_decision_crisis` 或 cadence(threat 消失=state change→crisis-bypass 提前重評)。
- **stuck release**(_is_stuck)→ 已是重評觸發條件(:1778 gate 含 stuck),保留但語意統一為「卡住=該重評」。
- **統一**：定義單一「該重評?」判準 `_should_reeval(team) = IDLE or stuck or cadence-due or crisis(含威脅消長/食恢復/pop驟變/FLEE逾時)`,四套 release 觸發點皆改為「設條件使 _should_reeval 真」,不各自 early-return-with-release。
- **保**：緊急插隊(PRIO_SURVIVAL/THREAT 反射)=刻意例外不動(藍圖裁保留)；release 只管「何時回主重評」。

## 驗收（final 一次性，中途不量測）
- **成員有決策**：faction 成員 trace 顯示個人日常決策(非純 faction push);忠誠成員聽令、不忠自主。
- **faction 協同不散**：consolidation/攻擊令/徵收 organic 不回歸(成員仍響應 duty)。
- **釋放統一無回歸**：famine(食恢復脫 survival)/combat/threat(FLEE 逾時脫離)行為保。
- **代表隊 trace**(Team7 手法)+ **established>0?** + 改動清單。
- determinism byte-identical、融合閘、9-zero 分布不回歸。

## R① premise（factcheck 對象）
1. **成員 faction_duty pull 能替代 _assign_tasks push 而不散協同**?——faction_duty term(:113 terms.gd)+ faction_stakes context(:248 gather)是否足表達所有 `_assign_tasks` 現派的命令(攻擊/徵收/外交/歸建);有無 _assign_tasks 派但 faction_duty 未涵蓋的命令型別→若有,該命令型別須先補成 term(輸入維度),否則收斂會留獨立決策點(違架構紀律)。
2. **成員跑 rank_scored 無其他隱藏 push 衝突**?——成員現除 _assign_tasks 外有無別處寫 current_task(雙寫源)。
3. **⑦四套 release 語意可統一到單一急迫/停滯機制 而不破 famine/combat/threat**?——各 release 的 hysteresis/timeout 語意是否可無損表為**同一套**重評觸發條件(非四段 if 換殼)。
4. **★架構紀律可達成?**——四隊形差異(unified survival-sticky/subteam STRATEGIC-gate/member faction 語意)是否真能全表為 ctx 輸入維度,**無殘留**「該隊形特判行動」的獨立決策邏輯?若某差異本質是行動選擇(非輸入),須揭示(可能該保為 applicable-gate 輸入 or 明列為新例外待藍圖裁)。

## 拆分序（自主執行）
②-1(成員決策,最大洞)→融合閘+determinism→⑦(釋放統一)→②-2(路收斂,最大風險殿後)。每 slice R②。②-2 若風險評估過大→可 defer(②-1+⑦ 已解主要行為洞)。
