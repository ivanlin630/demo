# Session 交接（2026-07-05 #12，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #11（`2026-07-04-session-handoff-11.md`）。
> 本 session = **GUI 玩測→貿易半路→QA 反轉制→LOD perf→★時間統一 wave（A1/B/④ merged）→tick60 安全證→★★沙盒憲法（governing invariant + 8 違憲溶入 arc）**。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。不碰 game-design.md（藍圖 owner）。**★交付前 QA 必綠**（04_qa 驗收官，QA 反轉制）。

## ⚠ 開頭必跑（baseline，**post-B 值變**）
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd       # DONE+1 pre-existing FAIL(弱目標)+0 SCRIPT ERROR; ★seeded=46/8/1/380(post-B); MOVE/hex=48(A1 ×5留)
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd  # PASS=7 DORMANT=0
```
重型 bed `GODOT_TIMEOUT=2500~5400`+背景;**輸出先落檔再篩**;PowerShell `>` 重導向=**UTF-16**(grep 撞 null byte→用 Select-String);**同機勿並行重 bed**(爭用互殺);**hook 已修**(handback-inbox awk 化 0.15s,本地 gitignore)。

## 本 session 主線（時序，全 merged+驗綠）
1. **觀測 GUI slice**（三件 ticker/inspect/速度+god-view 地圖+截圖 harness ObserverMain）→ 用戶玩測揭「感覺沒在貿易」。
2. **貿易環半路**（timeout stale 秒殺修死,成交 6→16;殘=LOD 物流+carrier）+ **充足性率表 harness**（sufficiency_bed,QA 判）。
3. **★QA 反轉制**（用戶眼球≠QA→三層機器[矛盾偵測/常駐漏斗/戲感審計]+QA 驗收官復活[04_qa 四職]+escaped_defects ledger+可解釋性判準[合理的0=健康/矛盾=病]+R7 全環對照）。**04_acceptance→05_acceptance**。
4. **QA 判決**（V2 假陽性=我 bed 探針配對錯,QA 獨立複現撤回;真矛盾剩 V1 trade/V3/V4）。
5. **★LOD perf**（lod_perf_bed:LOD 只 3× 常數/真根 O(N²) evaluate_all 忽略 subset;41 隊已 137tps/107 隊垮）→ 藍圖升成 **時間統一 wave**（時間=矩陣漏維度）。
6. **★時間 wave**：**A1**（TimeScale 骨架單源+×5 留零行為,merged;實作原含×5→1 藍圖後裁拆片→系統 reconcile 恢復×5,seeded 回 47→現 post-B 46）、**B**（far elapsed 積分,merged=**一修多解** V1 trade/V4 envoy/V3 帶禮 全脫困）、**④**（food_ledger_bed:承載力=好的餓[斷糧隊 89-96% 搏命]/行軍 ×1 斷糧集中長征）。
7. **tick-60**（TICKS_PER_HOUR 10→60 解析度旋鈕,安全證 PASS：唯 `_get_near/far` O(N) 需 cadence 化;PRISONER_CHECK 藍圖誤判=凍結遭遇戰框不爆）。
8. **★★沙盒憲法**（governing invariant 凌駕級：作者寫世界不寫決策,凡 NPC 行為必經統一決策引擎,禁行為 subsystem。稽核揭引擎半 wired[只 2 tag]+8 舊平行違憲路徑）。

## 當前狀態（藍圖已裁完整 arc 序，待系統開撕）
**全部 merged+綠**。無 in-flight worktree。藍圖 `constitution-arc-order` 定案序：

### ★硬驗收（最高盯點，每張溶完必驗）
**溶=融合非刪**：決策素材（選項+考量）保留成 engine option/term,只撕「替 NPC 決定」的 if-then/手算 argmax。驗兩條：①**repertoire 沒少**（NPC 還能做原本所有事）②**該出現還出現**（率表確認威脅時防守還發生,沒被新權衡默默吃掉）。納 R7+QA。

### 大序（藍圖定案）
```
0. 3 機械修（unblock 60+時間 hygiene,獨立小）先
1. 憲法溶入 arc = 脊椎主線（世界"決策對">"跑得對"）:
   wave1 warmup: 序1 threat → 序2 solo（低險證 pattern）
   wave2 arc原傷: 序6 faction dispatch(殺統領命令說不清+V2-cmd) + 序5 prosperity(殺生不出征服者) [+gen 重校壓此後]
   wave3 清掃: 序3 rung查表 → 序4 vendetta → 序8 灰項dispatch
   wave4 最難: 序7 ReactionSystem(拆行為溶入/情緒·離隊·生育後果保留)
2. A2/60 tempo 平行找窗（決策動 faction_ai、tempo 動 sim_runner=不同檔,不撞;gen 壓 wave2 後一次校）
3. 空間骨架導出+據點密度（藍圖裁值,等 hex 尺度定）
4. 全掃憲法閘
```

### 立即待做（下 session 開頭）
1. **防新增憲法閘立**（grandfather 8 known,擋新違憲;arc 尾轉全掃）。
2. **3 機械修 slice spec**（`_get_near/far` cadence 化 + 10 裸 cadence/timeout 常數導出 TimeScale.days/hours+FLEE 硬編240 + `faction_ai:190 eta/240.0`→/TICKS_PER_DAY + headless time assert 對齊。全在 handback `tick60-safety`）。
3. **憲法 arc wave1 spec**（序1 threat：FLEE/PREPARE/求和/DEFEND→4 REGISTRY option;序2 solo→翻 options。融合驗）。

## Queue（優先序，全待系統開撕/spec）
1. 防新增憲法閘 + 3 機械修 slice（unblock 60）。
2. 憲法 arc wave1（threat/solo）→ wave2（faction/prosperity,+gen 重校）→ wave3 → wave4。每 slice 融合驗+R7。
3. **A2 = ×5→1 + 60 + FOOD/gen 一次重校**（★60 抵消 ×5→1 食物懲罰:240/1440=4h/格≈現 ×5→**沒餓死潮**;砍 A2b 沿途補給 subsystem[違憲]→改引擎接線檢查[食不足登記子需求?塞糧/搶/覓食 affordance 匹配?]）。tempo 平行,gen 壓 wave2 後。
4. **空間尺度骨架**（矩陣新維度:遭遇戰錨→據點density/min_spacing/radius 全導出+閘;散落點 game_setup:66/73/74/encounter:174/175;藍圖裁值等 hex 定）。
5. **QA 物流脫0驗**（B 後,我機器[sufficiency_bed/trade_funnel_bed]ready;wave2 後+A2/60 後各驗一次）。
6. 後段:cadence③語意化/carrier(TAG_MERCHANT spawn)/V2-cmd(=arc 序6 副產品自消)。

## ★不變量現況（invariants.md，本 session 大增）
```
★★★沙盒憲法(凌駕級)   凡NPC行為必經統一決策引擎,禁行為subsystem;行為=引擎輸出永不是輸入
時間尺度骨架(3不變量)  時間量必導出TimeScale/移動連動BASE_ACTION×MAP_SCALE/延遲用語意單位
                     A1 立(×5留MOVE=48零行為);A2=×5→1+60+補給+FOOD+gen 四件;B far elapsed✅
空間尺度骨架(新維度)   凡空間量必從遭遇戰錨導出(據點density/min_spacing/radius);enforce 起步
運算頻率=非維度        =per-tick有界+時間量必導出兩既有不變量的閘(裸tick常數=閘該抓)
(既有)4+2 對稱不變量   意圖/belief/state單寫者/位置/tick早晚/latch-timeout/身分=權重
```

## 本 session 工作流教訓（已入 memory/checklist 者標）
- **measure-first 連勝**：V2 脊椎斷=探針配對錯翻案、PRISONER_CHECK 藍圖爆頻誤判=凍結遭遇戰框翻、承載力"×1問題"=速度無關既有苟活平衡翻。**別信初掃/代碼推理,碼證。**[memory feedback_qa_inversion/avoid_rabbithole]
- **A 拆片教訓**：骨架 refactor 與行為變（×5→1）該分開 landing,我 merge 整片藍圖後裁拆→reconcile。**速度/尺度變更前列"下游哪些隱含舊值"清單。**
- **憲法=根講死免逐個抓**：藍圖連三次 subsystem 思維(灌糧/糧道/補給 subsystem)被用戶拉回→憲法講死後自動判違憲。**遇"X 怎麼辦"先問"引擎子需求+手段嗎"。**
- **★溶=融合非刪**（arc 最高盯點）:撕小抄別撕掉行為 repertoire,選項→option/考量→term。每張驗 repertoire 沒少+該出現還出現。
- **UTF-16 陷阱**:PowerShell `>` 重導向=UTF-16,grep 撞 null→Select-String。
- 慣例沿 #11:消費 handback→measure/spec→push(worktree base origin)→一行 spawn→收 handback→驗基準→merge→合體驗→docs→memory→報藍圖→push。L 層每 edit 聲明;merge 後 `--import`。

## 開放 handback
- 無 `to: systems / status: open`（arc-order 剛消費）。等藍圖下一封（裁值:據點密度/A2 承載力目標,或看 wave1 spec）。
- 我對藍圖的近期 handback 全 consumed（constitution-audit/tick60-safety/b-merged/march-food-postb… 藍圖已回 arc-order）。
