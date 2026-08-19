# 開發進度

## 🗺 進度快照 dashboard（藍圖 2026-07-02，視覺總覽；細節見下方系統 log）

```
【沙盒三維度 = 遊戲活起來沒】
  經濟  ████████▓░  戲成 ✓  交易網轉、商隊想致富真去貿易
  征服  ██████░░░░  差一哩  機制到 route×6.6，差 capture 完成
  資訊  ███░░░░░░░  地基好  Phase E done、Phase D 欺敵(玩家錨C) queued

【統一矩陣 burn-down】
  思考決策 ████████▓░ 85%  ★旗艦燒完→致富/征服錨活、交易轉
  單寫者   ███▓░░░░░░ 35%  coin/ledger/roster/leader done；剩 8/12(強制閘前提)
  belief   ████░░░░░░ 40%  Phase E；剩 known_states/audit
  互動     ██░░░░░░░░ 20%  BEG/JOIN 驗死待修；剩多 resolver 統一
  人力俘虜 ██░░░░░░░░ 20%  失能-capture；剩雙模型/prisoner 死路
  玩家面   ▓░░░░░░░░░  5%  幾乎未動(大 arc)
  強制閘   ▓░░░░░░░░░ 起步  ledger 有牙；待單寫者撐

【方法論/願景 定型 ✓】沙盒 bar｜AI 深度節流閥｜兩隻眼(measure+矩陣)｜3 不變量
【NOW】GUI 用戶親驗 ‖ 強制閘全立 ‖ 矩陣剩餘(人力/belief)  【queued】envoy 弧殘/cadence 殘餘/G3-D/玩家面
```

## ✅ §4c 選址反饋迴路 + 繼承-lite MERGED（2026-08-20）

- **§4c 結果反饋迴路**（思考層四缺件之一、**第一條反饋邊**）：建點結局 → 寫**自己 leader** 的記憶 → 下次選址讀回。三掛點=L0 decay／主動棄村（失敗）+ 據點升級完工（興旺）；`SettlementMemory.site_bias` 線性衰減 **TTL 30 天**（非永久黑名單）、以 `quality_multiplier` **乘既有選址品質項**（紮根/紮營，**不新增 term 線**）。self-knowledge（只讀自己 leader、**禁全域黑名單**、記憶隨人不隨團）。
  - R² 2 必查項均在 dispatch 前定案：①**禁原樣重用 `write_memory`**（它不是純 append，會無條件寫 `p.relations[subject_id]` → 傳 tile_id 會塞「跟一塊地的交情」假記錄）→ 新增薄函式 `write_site_memory`；②decay 掛點缺 founder 資料 → 加 `tile.camp_team_id`（**已進 fp**，否則 L0 歸屬變化=determinism 盲點）。
  - **systems merge-gate 退回 2 項（已修）**：**B** `quality_multiplier` clamp 下界 `0.0`→**`0.25`**——兩次同地失敗會讓乘子=0 → 選址 util 歸零＝**絕對門檻 pre-empt 引擎**（瀕餓隊唯一去處也不能紮）＝patch-gate 病型；**C** 補 tap（`site_memory.write` vs `.applied`）——`MEMORY_MAX=20` FIFO 且與人際記憶共用 `p.memory`，site 記憶恐**未到期先被擠掉**＝反饋靜默失效，零 tap 則大考時無法判定此 slice 有沒有在運作。
- **繼承-lite**：勢力領袖團死 → 最強成員接位（統領→pop→team_id **全序**），無成員才 `disband`（原行為）。單一 owner `WorldState.succeed_or_disband_faction`，三處死亡路徑全走它。
  - R² 必查項＝**dead-man-walking race**（`erase_teams` 批次期間 `state.teams` 仍持全部 dead_list、領袖隊先處理則同批死者被選為繼任）→ 三處接線各傳既有死集合（`erase_teams` 傳自己的 `dead`、另兩處傳 `teams_pending_erase`），**零新資料結構**。systems merge-gate 退回 **A**：`known_member_states.erase` 移出繼承函式（`npc_combat:733` 那條路**團還活著**、抹活隊 belief）。
  - 契約升格 → `invariants.md`〈死亡窗口（走屍隊）決策紀律〉。
- **gate（合併結果親跑）**：constitution **PASS sites=75**、兩支 TDD **ALL PASS（9 + 15）**、implementer 側 det×3 byte-identical。fp 與訂正前相同＝a4 warring 1000t 窗內**掛點 dormant**（無 L0 decay／完工／棄村／領袖團死事件），**非沒生效**——真效果要在 12mo 大考的長窗才顯。
- **待辦（D 裁定）**：§4b merge 後「擴點」一併乘 `quality_multiplier`（同層、不新增 term 線）。

## 🎓 12mo 大考 啟動閘（systems 立 2026-08-20、單一入口；細節散落各條，此處只收斂「能不能開考 / 開考看什麼 / 考前不准動什麼」）

**性質**：修復疊加後的**新基線**大考，**不是**與第一次大考（2026-08-13~14）byte-comparable 的重跑——中間 settlement S1~S4/農業a-b/labor-v2/churn-fix 全是**蓄意行為改動**，正是要被大考評判的東西。

### A. 開考 blocker（綠才開）
| # | 項 | 狀態 |
|---|---|---|
| 1 | **specimen 非中立性修**（specimen 開關改變世界軌跡→大考的 story-audit 全靠 specimen 讀故事、不修=讀到的不是被評的那個世界） | in flight（implementer） |
| 2 | §4b 有機 gate（measurer）+ §4c gate | in flight |
| 3 | 在飛 slice 全 merge 或明確排除（labor-v2/churn-fix 已 merged；§4a merged；繼承-lite dispatched） | 進行中 |

### B. 具名監看清單（開考時必看，非「順便」）
1. **經濟 4 科目**（`game-design.md:132` blueprint owner）：A 富裕農村 / B 製造樞紐 / C 戰爭經濟 / D 需求不足型衰退。
2. **accepted cost 定奪**（starve baseline 8 vs combined 28）——**★其分解數字（honest vs lag-window）已被 QA 判 REVISE、暫不可信**（EMA 非瞬時流）；大考前需 specimen 複驗瞬時 daily_rate。**預核槓桿**：若顯人口死亡螺旋（非趨穩）→ B5 觸發閾值調早，**免再請示**。
3. **`mint_level` 全世界 0%**：仍 0% → 紅旗查設施鏈（established 雞生蛋家族前科）；>0% → 發展曲線正常。併科目 B 看。
4. **零產出卡死**（`daily_rate` 恆 0.000 且 `task=return_home` 餓死）——新病型、獨立診斷。
5. **perf**：per-team +34% re-open candidate + k 值誠實 NULL → **「撞不撞牆」併大考本身觀察**、不再單開量測輪（perf 五路 2026-08-20 全 CLOSE）。
   ★**因此大考 run 必須開 phase profile + 週期取樣 `(tick, N_teams, per-tick ms, 6 階段 breakdown)`**——12mo 是**單一連續 run 內 N 自然成長**，天然消掉「跨 session CPU contention」與「跨 run config 差異」兩大 confound（正是 perf③ k 值測不準的原因）→ **scaling 曲線免費附帶**，這是唯一能乾淨回答 O(N) vs O(N²) 的機會，**別漏開**。
   perf re-open candidate 帳（大考後）：`FactionAISystem.new()` **全站 40 站點**全呼純 finder helper、該類 instance state 只有兩個 **print-dedupe** dict → helper 轉 static＝位元級安全道（量級大於 perf⑤ 的 26 站）；loop1 dedup 1.72%；JOIN same-target reassert 0.23%（reassert 事件中 **94.28% 是無進展純重申**）。
6. **政治質地**（外交/背叛密度）：blueprint (A) 簽字後的回設計值；過死 → (B) 補償調 `p` 走 tuning 流程，**觸發權在 Story QA verdict**。
7. **farming-as-pillar / FUY**、settlement 深根 pop、founding 碎片 spam / 鬼城比率。

### C. ★考前凍結範圍（**窄**、勿誤讀成全面凍結）
凍結的**只有**「會改變**大考正要評判的那個維度本身**的觸發頻率」的改動——具體=**loop1 faction dedup DEFER**（會腰斬外交/背叛觸發率 → 污染政治維歸因 + 毀掉與第一次大考的可比性；correctness 面不變、大考後單獨走）。
**不凍結**：settlement/農業/labor/繼承 等 slice 的行為改動——它們是大考的**受試對象**，merge 進去才是正確姿勢。
判準一句：**改「被量的東西」= 正常進考；改「量尺/觸發率本身」= 凍到考後。**

## 📍 當前狀態（2026-08-19）——settlement lifecycle arc（S1→農業a 全 merged）+ perf arc 收官 + labor/churn 在飛

### settlement lifecycle arc（12mo 期末考深根 → 鬼城/碎裂 lifecycle 修）
溯源：12mo 期末考（誠實成績單：佔據 metric +43% 但世界不健康、深根=碎裂→non-viable 小團→貧窮陷阱）→ founding 證據包坐實（seed1337 3mo：**founding 88.9% 是 pop1-3 碎片 spam**/median 1/0% pop11+=走投無路就地紮營非殖民；**鬼城 27.8% 卡死團 id**；takeover 現況 2.6% camp 96%）。

- **S1 死亡釋放+撿現成 → main（merge `94e2f826`，2026-08-15）**：①`erase_teams` 清死團 `outpost_owner=-1`（單 pass O(tiles) 配既有 dead:Dict）②`_find_unowned_farmable_tile` 前置 belief reclaim-scan（撿現成鬼城優先於新建、目標選擇讀 `team_market_known` belief=感知鐵律、抵達後既有 `_evaluate_outpost_takeover` 3 天 timer 認領）。**gate 全綠**：dead_owner **82→0**、takeover **4→40**（2.6%→27.2%、真端到端非只選靶）、不 over（check-and-set 雙層）、byte-identical、constitution 75。**硬禁 2 code 點守**（無新搶城動詞、不碰 solo_settle convert）。
- **own_granary null-caller pin → main（merge `e210c00a`，2026-08-15、12mo 量測解封）**：根 pin（runtime trace）=`TradeValuation.reserve` 有 `state=null` DEFAULT + `_attempt_barter`(interaction:990/997) **漏傳 state** → `own_granary_tile(null)` 崩；**onset 實際 day0.8 非 day15**（推翻 teardown 假說）。fix=**補傳型根修**（呼點補傳 state、own_granary 零改=非盲 guard、byte-identical）。**12mo full horizon 0 SCRIPT ERROR**（pre-fix 數百次）=**解封 12mo 量測**（深根 pop -87.4% 現乾淨可測）。★誠實：headless 仍 7 `world Nil` 殘留（第二源未 pin、known_issues 保持 OPEN 非 resolved）。
- **S2a L0 營地階梯 → main（merge `93d55923`，2026-08-18）**：L0=**新 `tile.camp_level` 獨立 flag**（`outpost_level` 保持 0——★窮盡驗 `outpost_level==0` 全樹 **47 站 14 檔**是「無據點」哨兵、L0 佔用會全誤判）+ **顯式納 `state_fingerprint`**（否則 L0 變化 determinism 盲點）。紮營→L0（不 set_owner=非領土、拔營無沉沒 decay→0 無廢墟）、L0 forage 低倍率單旋鈕讀腳下池（遊牧循環湧現）、L0 不入勞力池。**gate 全綠**+★interim 超預期：**pop 194→352(+81.4%)、starve 107→21(-80.4%)**、founding 253→0 徹底轉 L0、89% L0 真衰敗無廢墟。（measure-first：單 seed 3mo 鼓舞非定論。）
- **S2b L0→L1 紮根工期 → main（merge `3d30b3ed`，2026-08-18）**：複用既有 construction spine（`_tick_construction`/`_complete_construction` crude_camp 分支）、完工清 camp_level（L0 消融進 L1 無雙態）、工期中斷用既有 busy-preemptible、viability=付不付得起工期物理湧現。★**首輪 gate RED**（corvee 啟動後卡死 10/720 ticks、`construct.stall:progress=21546:273`）→ systems 診斷根②=**persist 查 `team.tile_pos` 非工地→floor miss→無回收** → 根修=新 `corvee_site`（TeamData 自己欄=self-knowledge 非 god-view）+ persist 查 corvee_site + abandoned-recovery（循 corvee_site 回頭續建進度保留）+ orphan cleanup。**RE-GATE 全綠**：auto-fire **74×**（零 force-start）、complete **6×**（vs 前 0）、**recovery 469×** 進度保留、viability 健康分布 ticks[39...718]、dualstate=0。★constitution **75→77**（`_evaluate_l0_settle` taskarbiter+threshold=**暫時 scaffolding**、**§4 de-scaffold=blueprint 硬 gate**「拆這 2 站+回 75」同 arc 內清）。
- **農業a 農田獨立生產線 + drift 正位 → main（merge `20a77c5c`，2026-08-18）**：★**意圖帳 drift 正位**（`mechanism-intents` 農田 row「獨立產糧不經野地池」vs code `resource_system:289 gain*=(1+farming_level×0.5)`=gather 乘數）→ 移除乘數 + 新獨立產線 `farming_level×FARM_UNIT_YIELD×farm_labor×harvest_factor` → `TileBank.deposit(...,"farm_yield")` chokepoint（owner-gate self-knowledge）+ farm_labor 接勞力池（guns-vs-butter）。**量化食物帳 gate 綠**：無 mass-starve 無爆倉、反淨改善（attrition 15.3%→9.7%、starve 10→5、ΔGRAND +317→+985）。★FARM_UNIT_YIELD=2.0 provisional（farm 未成主糧源=下游 FUY 調查起點）。
- **resource 分類學入 invariants**（零生成 礦寶/自然再生 野味藥草/生產類 食物 farm_yield 龍頭/木材採集加速/coin 唯一源 mint）：守恆=**可溯源非禁生成**。

### perf arc（用戶帶入 external agent 憲章 → Phase1 profile → Phase2 四刀 → 收官）
**憲章入 invariants**：①優化兩道分類（**位元級安全道**=cache/memo/index/減 alloc→FP byte-identical 機器證 vs **行為影響道**=降頻/deferred→時序變=intended-change+LOD 紅線）②**禁降故事生成 fidelity**（Team decision/message/reaction 不為 perf 犧牲）③每改→full sim→Story QA 不降。
- **Phase1 細 profile**：`GoalResolver.frontier_candidates()` 占 ctx_total **97.5%**（顛覆上輪「term 評分迴圈」推測）。
- **刀A `_hex_dist` static → main（merge `0f58c74a`，2026-08-18）**：砍 `FactionAISystem.new()` per-call alloc、**~8-13% wall/ctx gain**、byte-identical=**arc 唯一真 gain（banked）**。
- **刀B(call-scoped memo)/刀D(spatial index)/刀3(finder alloc sweep) 全 discard**：memo **0 命中**（509=509）、D 落噪聲（+1.7~4.3% < 同側波動 11-16%）、刀3 同落噪聲。**★止損準則觸發**（連續兩刀落噪聲→arc 收官不無限追）。
- **★★meta 血證**：profiling 指的熱點（frontier 掃描）≠ 真可優化成本（**alloc churn**）；**每刀 quantify 定生死**（n≥2 noise-check、單跑會被機器噪聲/背景負載污染誤判）；止損救場保住真 win。未來 re-open=長局跑出新明確熱點才開。

### churn-fix + labor-slice v2 MERGED（2026-08-19，★accepted cost 入帳=12mo 監控基線）
- **churn-fix（SurvivalMergeIn (b)arrival-never）→ main（merge `7877310a`）**：根=(iii) 移動 host+belief lag/失聯 + **結構根 `TASK_JOIN` 無完成/放棄契約**（TRADE/STATION 皆有 timeout、JOIN 無）。修三件全走既有結構：①JOIN timeout 進既有單源塊（鏡射 TRADE 殘距額度）②撲空 abort 讀**自己 belief**（`belief_pos(self,social_target)==(-1,-1)`=感知鐵律非 god-view）③`join_rejected` cooldown **防 release 後重選同 host 的 churn 換皮**。控制床決定性 PROVEN（換皮結構性不可能重演、不誤傷）、attribution=**pre-existing**（plain main 已顯 signature）。缺口：高壓規模（49→242/793ms）未復現、留農業b re-measure。
- **labor-slice v2 → main（merge `eb20531d`）**：治 FUY 鏈最終根（farm 勞力位只拿 21% 冗餘食競爭 + **level-cancellation**=發展農田不增產）。T1 食物真邊際分配（per-labor yield 分、double-count 移除）+T2 **production 解耦 fill/demand**（∝level×alloc）+T3 估算器同源（移 stale farming_bonus、含勞力飽和=ROI 誠實）。決定性 PASS：**production 隨 level 真升 L1 16.77/L2 52.0/L3 393.2（23×）**、B5 瀕餓保護 +59% 勞力回流、v1（只改 weight-side）曾 FAIL 對照測入 test。
- **★★accepted cost 入帳（churn-fixed 同床 controlled、blueprint 帳目紀律「接受真代價」）**：starve **baseline 8 vs combined 28（3.5×、delta 20）**、end_pop 64→38、teams 14→9、ΔGRAND +1665→+224（正但虛弱）。分解=**honest 主導**（chronic 12/ambiguous 16）、**lag-window=0**（B5 免嫌）——★★**2026-08-20 QA 稽核 verdict=REVISE、此分解數字暫不可信**：`food_flow_avg` 是 **5 日 EMA** 非瞬時流（`resource_system:20/241`），死亡明細多筆 EMA **單調爬向零**（team10 -0.016→-0.008、team0 -0.114→-0.062）=「真實日流已回正、EMA 沒追上」簽名 → 用 EMA 正負號在死亡瞬間分類**系統性低估 lag 死亡**、`lag-window=0` 可疑；且 tap 僅 4 欄、答不了「被搶/移動決策錯/勞力抽太乾」等替代死因。**honest 主導的『方向』未被推翻**，但**具體分解不可當 12mo 基線與 WHAT ruling 的定案依據**、**待 specimen 複驗**（瞬時 daily_rate 軌跡 + 3-5 起決策/資源軌跡）。**★對預核槓桿的意涵**：若 lag 其實存在（非 0），則「B5 觸發閾值調早」這個預核槓桿**更可能是對的**（非相反）=雙計移除後 food-labor 水位變誠實、部分團 genuine under-fed 本就該餓。舊 16×→3.5×=**分子降**（32→28 churn 人質放行）+**分母升**（2→8 churn-fix 讓 baseline 也顯露 honest 水位）雙向。**★12mo 大考 story-audit（經濟 4 科目）=此 accepted cost 的定奪處**。**★12mo 大考監看清單 +1（blueprint 2026-08-20、用戶戳中）**：**`mint_level` 全世界 0%**（農業b final round 90 天實測：cap<5 與 cap≥5 隊**皆 0.0%**）——**90 天分不出良性 vs 惡性**：良性=鑄幣廠屬高階投資、發展曲線還沒到；惡性=**設施鏈又斷**（established-chain 雞生蛋前科家族）。**12mo 分得出**：仍 0% → **紅旗、查設施鏈**；>0% → 發展曲線正常。**併經濟科目 B（製造樞紐）一起看**（鑄幣=coin 源頭、樞紐利潤循環一環）。**★★blueprint WHAT 裁=接受、不 mitigate**（2026-08-19；理由：①代價=拆假餵食 bug 後的**誠實世界**非新傷害 ②場景=3mo 高壓 warring 床（L0 碎片密）非健康世界參照、**在壓力鍋裡調藥=artificial 場景 tuning=premature** ③ΔGRAND 仍正 + 生產引擎真活（23×）=底不崩 ④12mo 大考（全修復疊加+經濟 4 科目+vitals 參照）才是真定奪處）。**★預先核准槓桿（standing、免再請示）**：**若 12mo 大考顯人口死亡螺旋（非趨穩）→ mitigation menu 啟動、B5 觸發閾值調早=第一槓桿**（既有機制內調參、非新旋鈕）。
- **`tools/godot.ps1` timeout-kill race 修 → main（`d18ff8fc`）**：`Kill()` 後 bounded `WaitForExit`+`FileShare::ReadWrite`+retry backoff → 長跑 stdout 不再憑空消失（measurer 本輪驗證有效）=量測基礎設施失憶風險解除。

### 在飛（2026-08-19，序：churn-fix=critical path）
- **★churn-fix（SurvivalMergeIn (b)arrival-never）=critical path**：農業b 長跑揪出 **698× SurvivalMergeIn churn**（team 暴增 49→242、per-tick 793ms=**40-70× perf degradation**）→ probe-pin 定案 **(b)arrival-never**（`join.resolve` ~10 vs commit 698=**1.4%**、joiner 從沒移動抵達 host、每 cadence 重 commit=**hand-obeys-brain 家族**、S2b corvee cousin）。investigation-slice 在跑（T1 runtime-trace pin i movement 不執行/ii cadence 重評 reset/iii 移動 host chase → T2 手不聽腦根修 persist-to-arrival）。
- **labor-slice v2（食物真邊際分配 + farm production level-decouple + 估算器 coherence）HOLD**：FUY 調查鏈（farm 未成主糧→農田廣度 76.9% 非未發展→**farm 勞力位只拿 21%**→code-read 排除 B5-escalation 嫌疑→per-team 坐實 **level 越高 flabor 越低 0.267/0.103/0.067=結構餓死進步者**）→ v1 只改 weight-side **FAIL** → 挖出 **level-cancellation 真根**（`fyield=level×FUY×flabor`、`flabor=fill=alloc/(level×K_FARM)`→level 分子分母相消→labor-starved farm production **level-independent**）→ v2 全鏈（真邊際分配+production 解耦 `alloc×per-labor-yield`+估算器整條替換）→ **決定性 gate PASS**（production 隨 level 真升 **L3=23×L1**）+B5 保護 PASS（瀕餓 food_share +59% 真飆回）+ΔGRAND 健康。★**HOLD 原因**：controlled 同床坐實 starve **2→32(16×)** 可歸因、分解=**honest 水位主導 lag-window=0**（B5 免嫌），但 **32 含 churn 人質**（弱隊想逃生卻到不了）→ blueprint 裁 **churn-fix 先 merge → labor-v2 疊上 combined re-measure 真 honest 水位** 才 merge+記真 accepted cost（帳目紀律：接受代價要接受真代價、否則 12mo 監控基線也錯）。
- **農業b（⑥ 據點結構放大器 pop-cap 乘法 `領導基數×(1+level×AMP+設施×AMP)`）HOLD**：pop-account **無爆**（p90=45/max=100 帽真拉高但零 runaway=⑥ 設計驗證通過）、pop-cap 自身 overflow 僅 3×（塌證據薄弱）；HOLD 因 churn 未修（merge 會把 churn-inflated baseline 寫進 main=違 closed-account）。floor 校準（cap<5 佔 5.3%）=churn 修完 re-measure 才定。

## 📍 當前狀態（2026-08-03）——logistics 甲 merged + 有大有小 arc（CASE B → 統一勞力池 merged 待 §8）

### 近期里程碑（2026-08-02~03）
- **甲 SLICE B 領主分配政策 MERGED（4cc5da15）**：統一光譜（給免費/賣公道/賣高價/賣外拋棄）、一 argmax 一 convoy+貿易脊椎、人格 weigh、**零新市場**（genuine-value）。organic firing 待 §5（領主有餘糧條件）。
- **★乙規模動態 = 誠實 pivot**：乙整併 util boost（ce369dca）**被用戶戳破＝arbitrary crank**（因不 fire 就 crank 分數讓贏＝腳本化）→ **完整 REVERT（08d10281）回 genuine baseline**。真根 measure 定案＝**CASE B：規模經濟 absent**（model 不獎勵 size 甚至反獎勵、4 維坐實 → 世界碎小團是正確湧現、整併低 util 是引擎正確）。→ 用戶裁 **size 該 matter**。
- **★統一勞力池 MERGED（506aaa64）**：讓 size 在生產 genuinely matter（治 CASE B、genuine-value 非 crank）。勞力=稀缺資源、`LaborSystem` 共享 allocator、labor_mult 取代 sqrt residue、need-gated full-stop（無 floor）、size 靠 facility breadth。unit 7/7 綠 + R² anti-crank CLEAN。**★size 真 matter 待 measurer §8 真世界驗才宣稱**（同 SLICE A measured 精神）。詳 `project_size_matter_arc`。
- **教訓**：util 必＝真實價值、禁 crank 遮 finding（`feedback_genuine_value_not_crank`）。

## 📍 當前狀態（2026-08-01）——經濟第一次真流動（flow-fix merged）+ 規模動態診斷

### 現況
- **決策模型統一（腦 means-end + 手 持守）DONE**。持守 arc RELEASED；team14 nuance 量測後溶解（非真卡死）。
- **經濟調查挖到真根（繞 7 次假根、全被量測打臉）**：不是缺動機、不是食物軸——是**供給產得出來卻不會跨距離移動**（採集自動上繳但公庫 tile-local、賣方菜單根本缺「送貨到市場」動作 → 貨物理從不離家 → 買方永不成交）。7 次假根：persist-block／cap-binding／cap-no-op／blueprint 放大鑽石／trade-trip-underfire／reserve-diagnosis／cargo-loss——**每個靜態斷言都被第一手 dump 駁**。
- **後勤/logistics arc（供給移動）WHAT 定案**（spec 2026-07-31）：三層各有用不互吃——後勤運補（運自己的）/領主分配政策（人格施捨↔剝削+餵 unrest）/貿易（換外面的+逃剝削）；徵收(coin)另議、公庫/生產不動。
- **★SLICE A 供給-delivery convoy：flow-fix measured 成功**——材料送達 **26%→80%**、成交 **0→4→6**、經濟第一次真流動（腳夫子隊複用子隊+載重、供需雙方派、散單協調修）。**非凍紅線 GREEN**（6mo warring 12.84% attrition + 月月 churn = 活世界；attrition=0 是 1mo 短窗 artifact）。**determinism 驗跑中**（run1/2 done、run3+seed42）→ **merge 待 determinism 確認**。
- **meta-fix（survival 天平條件化）DROPPED**：第一手 per-option util dump 證經濟決策 fire 正常（build 1.40>survival 1.04），根本非天平問題。

### 路線圖
- 腦+手決策維度收官 → 經濟根=供給移動 → 後勤 arc（SLICE A flow-fix 收尾中）。
- **序**：flow determinism→merge（經濟正式流動）→ SLICE B 領主分配政策 / C 貿易 → 勢力規模動態（join 瓶頸）+ perf（O(N²)）。
- runway/糧流 arc：A/B1 banked（正確 infra）、B2/B3/C paused（食物軸證非塞點）；糧橋成後勤現成零件。

### 偏離
- runway 食物軸追了 2 個溶解 victim（team14/A1），部分 over-build（B1 banked、B2/B3/C paused）。
- **7 次靜態斷言被量測駁 → 鐵律固化**：決策/貨流根**必 dump 真值（per-option util／per-convoy trajectory／現成資料）、禁靜態斷言**（讀 code 知「能」≠ runtime「真的」）。
- 淨判：路徑蜿蜒但沒空轉——落地真 win（經濟首流動 verified 非放大）+ 精確診斷剩餘 arc。measure-disciplined 收斂、非偏航。

### backlog（診斷完、排隊、logistics 後）
- **勢力規模動態**（用戶願景「活世界有大有小」，game-design 已記）：世界塌全小（6mo 實測 133 隊全 ~2.9 人、無大團、rung≥2 僅 6 隊）；真根=跨隊 join（投靠/併入）卡在 dispatch→resolve（155→24、85% 蒸發），現跑的 merge(322)是母隊自我回收臨時工=錯的整併。方向=de-patch join resolve 瓶頸（同執行完成家族）非新建整併。
- **perf**：warring O(N²) per-tick（每 tick 掃全隊名冊）、世界膨脹 130+ 超 50 目標；與規模動態同解（隊變少）。

## 📍 當前狀態（2026-07-15）——full-HD 觀察開跑 + flee 真修 + tracer 完整性 + god-view merged

### observability-path-completion（tap-gap 家族系統性收 + 盲點閘）→ main（merge `7a9640bf`，2026-07-15）
full-HD 觀察 unblock 內政的觀測 infra。tap-gap 撞出 4 個（order/survival-churn/unified-solo/person-reaction）→ blueprint 令系統性掃別打地鼠。**已修**：Fix1 person-reaction tap（reaction winner 進 specimen，誰/reaction/why loyalty·stress→內政 defect/riot 可判真因，riot 樣本 person33 loyalty0.88/stress0.9/food0=stress 驅動好戲非 loyalty bug）+ Fix2a unified capture 挪 try_set 後帶真 result（修 predetermined committed 虛高）+ Fix2b solo 三早退 tap（idle_skip/finder_miss/try_set_noop）+ Fix3 threat dispatch tap + **Fix4 盲點閘 `observability_gate.gd`**（新決策/commit-fail/reaction 路徑未 tap→FAIL 系統性守衛，打地鼠結束）。**★HALT 修（觀測禁改世界第 4 次同族）**：tracer re-query（best_estimate/to_task）bump Probe 污染 counter→`_begin/_end_observe`（Probe.enabled=false+suppress_observe_noise）包裹→on/off 含 Probe 全 byte-identical（15917 行 0 diff）；invariants 升（禁 RNG→禁 RNG+Probe）。**觀測工具全維度收完**：全生命(heartbeat)+全路徑(attempt-tap+person-reaction+unified/solo/threat)+零擾動(RNG+Probe)+盲點閘守衛=「全量暫態可觀測性」不變量真落地。**教訓**：先窄後寬撞 confound 第 2 次（TDD 小場景 Probe 差不顯，full-HD 才爆），spec 該要求 Probe-neutral（已補 invariant 驗收）。

### full-HD live 觀察 slice 開跑（觀察先於設計，blueprint）
三大 arc（desperation/god-view/tracer-completeness）落地→**現在有可信 tracer**→開沉睡世界（反應/生育/情緒 near-gated，`SimRunner.force_full_hd=true` 全隊 near 自然開，零 gate 改）。**交付=觀察報告非修**。measurer 跑四維（人口/內政/情緒/經濟）+ 全生命 specimen。**立刻兌現真問題**（見下 flee）。

### flee 恢復位移（FLEE no-op 根治，live 觀察後第一個真修）→ main（merge `12d3d7b1`，2026-07-15）
**arc 敘事**：full-HD 觀察 + 故事 QA 揪出 Team1 128 天原地逃 3080 churn（75% 人生）。blueprint 初判「缺執行鎖」→ **patch-gate-first 挖到底翻轉**：真根非缺鎖，是 **FLEE 從不移動**（序1 wave-dissolution 誤刪 `_flee_target` + 留假註解「mover 接手」，mover 不算＝dead-code 病）。加 lock=治症（隊仍卡原地）；治根=恢復位移。

**已修（de-patch）**：FLEE dispatch（3 站 threat/unified/solo）算**遠離 threat belief 位**的可達 move_target（讀 belief 非活值，守感知鐵律；god-view 已提供 belief_pos）→ 隊真逃遠→`ThreatAssessment.score` 距離衰減→out-of-vision→`_has_active_threat` false→**自然 release=有終點**（非硬 lock）。修假註解。

**★cascade（一根解兩假警報）**：`N1_flee -52%/-18%`、**`defect_leave -79%/-93%`**（probe key 被 flee-離隊+defect-離隊共用，flee-churn 反覆觸發灌虛高）、`riot -47%/-13%`。**「逃跑巨量」「內政 defect 千級」兩 aggregate 異常大半是此 flee-churn 虛高，非情緒太高/loyalty 太弱**——先修觀測工具+觀察才揪得出這是虛高非真病。

**★god-view 連動**：flee 讀 threat belief 反向位移 + god-view 位置 belief 化 = **完整逃脫迴路**（逃者真移動→god-view 讓追兵 belief 過期→撲空→真逃脫 organic 湧現）。flee-restore **解鎖 god-view 逃脫在真實遊玩發生**（先前逃者不動→god-view 逃脫 organic 發生不了）。

**QA 獨立複判**：churn 3080筆/128天→**162筆/6.75天**（有限會解除）+ Team1 全生命連貫 + flee 真逃 396 次移動。憲法 sites=29、TDD 7 綠。**教訓**：patch-gate-first 第 2 次抓治症（execlock、flee-lock），挖到 dead-code 真根（[[feedback_symptom_vs_root_retry]]）；reviewer 抓 spec 派發站幽靈（survival:3213 非 FLEE 站）。

### tracer-completeness（specimen 全生命+全路徑，第三觀測洞根治）→ main（merge `2a805d35`，2026-07-15）

**arc 敘事**：用戶+QA 抽樣戳「從沒量過全程紀錄的樣本」——觀測不變量**第三次同族破**（LOD-exemption 換世界→RNG-confound 換世界→現在 lifecycle 窗口）。specimen jsonl＝**成功-commit 窗口**非全生命（Team26 錄 day76-85 漏 day24-75）。**根因 code 定音**：capture 全 commit-gated（`capture_decision` 只在 try_set 成功點 tap）→ no-commit 期（IDLE/survival relatch commit 反覆失敗/子隊）零 entry、commit-fail churn 全隱形。**tap-placement 非 perf 非觀測改世界**。修好＝story-QA 地基（往後 organic trace 可信）。

**已修（三 Fix）**：
- **時間維 heartbeat sweep**：`evaluate_all` 末尾對 specimen 無決策期補輕 entry（`HEARTBEAT_CADENCE`=6h）→ timeline 無 >6h 洞（Team26 gap 1680→60 tick）。
- **路徑維 attempt-tap**：`capture_decision` 加 `result`（committed/finder_miss/try_set_noop），survival loop 補 commit-fail 分支 tap → churn 現形不靠掃描撞。
- **★零擾動（觀測禁改世界硬紅線）**：tracer on/off 兩跑 **byte-identical**——觀測不變量破三次的核心終於確認**觀測不改世界**（新 tap 零 state mutation/零 RNG）。
- **盲點閘**：runtime churn 床（斷言 gap≤cadence + commit-fail 現形）+ static tripwire baseline 6/2/2。第二個 Tier1 控制場景床 `churn_tap_bed.gd` 進 repo。

**★誠實（別吹）**：`try_set_noop`＝真 code path **live 活證**（手構絕境隊撞同-prio→`_trigger_survival`→try_set false→capture @3235 真觸發）；**`finder_miss`＝code-verified + 同構於 live-verified try_set_noop（緊鄰同 for 迴圈），但時限內未 live-demo**（罕見 race：ctx 可行 but to_task 失敗，organic 也從未撞）→ known_issue 留觀。

**invariants 升條**：觀測不變量段收斂三洞（specimen 完整性 + 禁燒 RNG + 全量可觀測）+ 盲點閘③（specimen 完整性閘已落地）——`invariants.md §觀測不變量`。三次同族破全修完。

### god-view 位置 belief 化 → main（merge `6aa3ee18`，2026-07-15）

**arc 敘事**：結構稽核揭 god-view 位置＝感知鐵律最大債（選敵+位置感知全知）。敵情/社交目標位置從 god-view 活值 → belief last-seen。**世界從全知變有迷霧**——位置認知腳補上，「決策對得上現實」最大一塊。

**已修（三介面一致 + finder gate）**：
- **dispatch-time target**（`options.gd to_task` 9 處）→ `belief_pos`（staleness gate `BELIEF_STALE_TICKS`=3天 + 跨-faction→BeliefSystem last-seen / 同-faction→known_member_states 通道分流 + ★fallback (-1,-1) 禁退自身）；佔村→outpost tile 靜態真值（打村格）。
- **movement_system**（combat/merge/join 逐 tick 追蹤）→ belief_pos（(-1,-1)→不退自身）。
- **`_refresh_attack_pursuit`（Fix F）engage 後追擊 vision-gate**：engage≠永久鎖 god-view。三態＝①本 tick 可見(`last_tick==current_tick`)→live 攔截合法 / ②斷視線→去 belief last-seen 搜(prey 已移=撲空) / ③過期或無位→release re-eval。
- **`_nearest_independent`** 補 has_belief gate（只選有情報目標，belief 距離）。
- **★逃脫成立**：prey 斷視線移走→追兵鎖 last-seen 撲空（非 god-view 直取 live）。QA 撲空核心故事判連貫（motive 斷視線→action 真移動→outcome 撲空舊座標）。解鎖逃脫/迷霧/伏擊/斥候的位置基礎。**首個「控制場景 story 驗證床」`pursuit_hiding_bed.gd` 收進 repo**（可復用 infra，稀有/story-central option 掛它繞 organic roulette）。

**★known_issue（非已驗，別吹）**：**撲空後 aftermath 未觀測**——追兵到空 last-seen 後搜索/放棄/凍結完全沒驗（pursuit 床單 tick 靜態驗證非 multi-tick trace）。需延長 bed 幾 tick 判（backlog / tracer-completeness 順帶）。門檻④ sanity/HOB=implementer 自報（headless 3+3/TDD16 綠，未獨立複驗——小 code 面 Fix F+床 infra，HOB 回歸風險可忽略：belief_pos 非 LOD-gated、行為只斷視線 rare case 岔開）。

**過程**：測試遷移裁定(a)逐函數補（禁 record_claim 補預設＝god-view 漏回）；v1 瞄錯靶（dead decision_context 欄位）→異質框外審(Fable)抓真 wire（options.gd to_task + movement）→v2 重定靶；Fix F R² CLEAN（pipeline 序 vision 在 faction_ai 前無 off-by-one）。門檻①-④ 齊（wiring code-verified / vision-gate / Tier1 撲空演示 / determinism 兩跑 byte-identical + 憲法 sites=29）。

### 絕境找糧 A/B/A-2 + SpecimenTracer RNG confound → main（merge `24c0c442`，2026-07-15）

**arc 敘事**：起於「thrash-fix（execlock）」——被 QA 故事 regime 揭穿=換皮不換骨（買糧從不出貨），退回重診斷，一路挖到真根＝**絕境隊選了兌現不了的路**。中性世界 QA 雙綠驗證（觀測 confound 修後可信）。

**已修**：
- **買糧幻覺→look-before-leap**：`has_buyable_food`（received food 賣單，不濾 stale）gate；餓世界無賣方不追幻覺，真出貨驗綠。
- **遷移找糧（新絕境路）**：`food_seek_target`（VisionSystem 視野內 wild_game[繼承 pop 守衛] / received 食物賣單，PathSystem 可達）→ 離死市集移向糧源；抵達 release→引擎重秤（零新 try_set）。
- **併入 A-2（learn-from-rejection）**：`_resolve_join` 拒絕寫 `join_rejected` 記憶 + `has_acceptable_join_host` 查可達且非近期被拒 host（cooldown，鏡射 to_task 優先序）→ 被拒不再纏 loop。接決策模型記憶腳。
- **連貫窮死（C 驗收準）**：QA 故事判官驗（Team26 遷移→覓食→掠奪→賣貨求併入四路全試才力竭死＝合法悲劇）。
- **★SpecimenTracer RNG confound 修**：`capture_options→to_task→observe_velocity` 耗 randf 無 suppress→偏移全域 RNG→換世界（同世界 0/71/88）。修＝tracer 額外 path-work 包 `suppress_observe_noise`（鏡射 HOB）。**觀測不變量最深違反根治**；升顯規則（invariants + memory `feedback_observer_no_global_rng`）。

**★未修/下個真根（誠實記，不吹）**：**thrash 未完全根治**——Team26 早段 56 次同快照 thrash（貿易↔掠奪↔idle）仍在。根＝**掠奪資源錯配**（搶到 material 不解 food→餓著再決策→震盪）。**下個 slice（一修解殘留 thrash + 絕境隊餓死，patch-gate-first）**，待 greenlight。

**★留觀**：併入 faction_id 真成功尚未驗證（3 trace 累計 0 成功）——餓世界 feed_ok≈0 恆拒＝預期，抱團模型（pooling follow-up）才讓 merge 真成。

**arc 過程血教訓（全入 memory）**：症狀 vs 根（治抖動=治症 `feedback_symptom_vs_root_retry`）、觀測禁耗 RNG（`feedback_observer_no_global_rng`）、不虛構授權（`feedback_no_fabricated_authority`）、Windows merge lock（`feedback_windows_git_merge_lock`）。**兩道閘 + 異質框外審 + 故事 QA + 全量可觀測性一路揪換皮/假前提/感知鐵律違反/觀測假象。**

### 統一商業框架 market-as-place + coin 循環 → main（merge `eb047b6f`，2026-07-15）
經濟維第一個交付。**10 層 measured 剝殼**（供給可見性→撮合→移動→co-location→成交條件→coin→sell_no_surplus）後，用戶裁 hole-by-hole 打地鼠+互 confound → **整個商業框架一次做**（market-as-place 骨幹）。**已修**：market-as-place（貨在 outpost、買方到市場買/賣 stock、免賣方在場，解 65% 賣方漫遊撲空；`_resolve_market_at_outpost` owner-mediated 雙側 coin 雙向、履約 order_id 權威直沖）+ effective_holding 統一 6 讀點去 absorb/spill + 掛單人格化 + reserve 液化（SURVIVAL food+medicine 保 floor）+ de-patch kill-list（雙 resolver 收斂/死常數叢/三 fallback）+ coin 循環（`_collect_member_tax` 破私囊鎖 salary 單向枯竭）+ invariants 市集=公開地標豁免。**量測**：機制證明 deal_market 0→2、**coin 大勝 buy_no_coin 30421→27(-99.9%) coin 雙向流動**、守恆 CoinAudit=0、byte-identical、盲點閘綠。**★誠實標**：機制+coin 通但市場未大 revive（deal 仍~1-2）——新主牆 `sell_no_surplus 51.7%`（訪客沒貨賣=供給存在性）**待生產 arc**（甲建 surplus 經濟/乙接受薄貿易，patch-gate-first 中）。**★方法教訓**：hole-by-hole 6+ 刀全 inert（打地鼠+互 confound）→ 整框架一次做；異質框外審抓 3 結構缺口；wiring gap（新 resolver 死碼 TDD 單測漏 measurer full-HD 抓）；stale commit 審核陷阱。3 閘 merge（R² CLEAN+probe 核+誠實 log）。**held 不 merge inert 全程守，0 白 merge。**

## 📋 結構 backlog（用戶定「都要處理」，序，2026-07-15）
結構稽核揪出，用戶定調**沒框架 + 多求解器 + 矩陣殘＝都要處理**（非一次性 flag 忽略）。**全用統一框架式做**（族走共用人格函式、雙 resolver 併一、思考腳走引擎讀取＝同發展模型統一框架精神）。**非現在急**（經濟 freeze arc + 發展模型統一框架化在飛），經濟 arc 收一段落挑下一個，blueprint 出願景→systems spec。序（blueprint 願景排，systems HOW 調）：

1. **★死常數照妖鏡「族」**（最大「沒框架」，高值，直接續「決策穿人格非平頭」）——**建共用人格函式讓整族走**非逐條溶：
   - `calc_engagement_margin(leader_values)`（攻擊/佔村門檻族：ATTACK_STRENGTH_RATIO/OCCUPY_WIN_MARGIN/POP_RATIO/READINESS_MIN）
   - 收編 `food_security_target` band（DESPERATION_DAYS/SURVIVAL_SATED_DAYS/SURPLUS_FOOD_DAYS）
   - 「隊伍膽識」聚合（PANIC_WEIGHT+PANIC_STRESS/LOY+readiness，接潰退已用的 courage 源）
   - `commitment_bonus(leader_values)`（散 4 檔 0.15/0.3 收斂）
2. **F-I1 雙 diplomacy resolver**：god-view `_try_diplomacy` vs belief `handle_diplomacy_message`（同動詞相反 epistemics）→ **統一走 belief**（連求和 seam bug 同根，一起）。
3. **矩陣殘**：prisoner_population 死路（`encounter:1295` 寫零消費）清、F-B1 known_member_states 雙 epistemics（god-view 7 caller live + belief）拆。
4. **思考腳（記憶/情緒）泛化**（深接線，最後）：記憶只讀仇（恩/信/懼寫黑洞）、情緒只 panic→FLEE → 決策讀取端拓寬（承 v2 §6 情緒調節器 + 記憶染價值）。
5. **★多-tick 動作 latch/承諾 統一機制（churn 家族系統性，blueprint 2026-07-15）**：flee(重commit never move)/pursuit(重refresh live位)/掛單噪音(重掛)——**「多-tick 動作缺 latch→重選震盪 never complete」同一家族**（決策模型 v2「承諾」原則）。**★merchant-target 經 trace 證實非 churn（target 穩定 28000 tick 僅切 6 次、有到達）→ 移出家族**（binding 是 threat-preempt+meet_nodeal 非 churn，見經濟 arc）。逐個修=打地鼠（flee 修了 merchant 又冒）。**該系統性**：共用「多-tick 動作 latch/承諾」機制（pick target→鎖到 arrival/completion/threat-resolve→release，配 timeout=in-flight latch 必 timeout 不變量），全族走它。**經濟 binding 先修**（merchant latch + accessor 統一，解眼前經濟死）；系統性 churn-latch 排此後（同死常數族/雙 resolver 統一框架式）。
關 [[project_unification_matrix]]/[[project_framework_seams]]/[[feedback-patch-gate-first]]/[[feedback_symptom_vs_root_retry]]（churn 家族）。溯源 handback `2026-07-15-blueprint-to-systems-structural-backlog-confirmed` + `-trade-binding-fix-direction` + 結構稽核 `docs/superpowers/structural-audit-2026-07-15.md`。

## 📍 前狀態（2026-07-14）——Slice A 求生層統一 merged

### 求生層統一（survival-layer-unify）→ main（merge `a630f2ab`，2026-07-14）

用戶裁定(a)直接 merge。merge 前閘序全綠：R② reviewer CLEAN（升異質框外審 refute-first）｜憲法 site-freeze PASS(sites=29,removed=0)｜regression：branch 與 main 同 3 既有失敗、零新增。

- **內容**：人格化資源預算架構——層0 boost + 候選2 統一門檻 + 層5 + 候選1 + Fix3c（武備隊 barter food 5→142，滿手武器不再餓死）。求生決策搬進引擎/人格秤（`need_hierarchy.gd`/`decision_engine.gd`/`terms.gd`/`faction_ai_system.gd`）。
- **驗收全貌**：性格顯性化 PASS（食安目標隨慎重遞增／option 分化）｜武備隊 Fix3c PASS｜P25 活教材 PASS（抽搐普通人→雄心開國君 pop 8→11）｜established seed1337 0→1（改善）｜determinism/憲法 PASS。
- **trade（非純改善）**：attrition 3.7× 惡化 → 修到 1.3-1.7× main（fullprobe 64隊3seed branch 22.97/17.1/21.8% vs baseline 13.5/11.8/16.7%）。本質=死亡率換決策真實性。
- **殘根=tuning follow-up（非架構絕症）**：軍備堆積餓死型（Team14 死時 coin=47/weapons=3/food=0=有錢優先軍備餓死）。「第三種死法」查證=假象（decision_count=0 是 SpecimenTracer tap-gap 非 AI 沒碰到）。
- **★follow-up backlog（merge 後 tuning，未 dispatch）**：①層5 餓時食物權重壓過軍備 / weapon-buy drive 調弱 → fullprobe attrition 壓回 baseline 附近（走 patch-gate-first 查為何餓時不 pre-empt 買糧）②boost 觸發頻率 10.52% 偏高觀察（常觸發=上游備糧沒做好靠安全網兜）。
- **溯源**：fullprobe `docs/measurements/2026-07-14-sliceA-fullprobe-branch-67d4a47.json` vs `-mainbaseline-68c8feb.json`；死因 `2026-07-14-samewrld-team14-deathcause-67d4a47-dirty.log`。
- **⚠ 既有測試債（非本 slice）**：headless_test 3 個 assertion 失敗 main 早存在（p2a join weight 0.41 / beg_join combat 197 擋 / strategic ladder 擴張未選）——merge 前後同、零新增，屬獨立既有 bug（見 known_issues 待查）。

### workflow 改（用戶定案 2026-07-14）——故事性 QA + 全量暫態可觀測性

藍圖轉用戶親定兩件，系統已落地 owner docs + memory（本 workflow 對**後續 slice** 生效，不回改 Slice A a630f2ab；thrash-fix slice 當首個試驗）：
1. **QA 加回=故事性判官**（`04_qa §第五職`/`00_roles 五角色+接力流向`）：量測後讀全量 specimen trace 判 motive→action→outcome=好戲關可稽核閘，餵藍圖（非 release-gate）。
2. **全量暫態可觀測性=不變量**（`invariants.md §全量暫態可觀測性`，憲法同級）：code 改不准製造量測盲點，新 decision/resource/state 必接 tap。
- 量測員標準床升級逐 specimen 全量 dump（`03b_measurer §⑤`）撐 QA 判官。

**★★full-HD 轉正典（用戶+blueprint 定 2026-07-14，已落 `game-design.md §full-HD 正典原則`）**：
- **正典行為原則**：命運不看玩家臉色（一隊命運不該因玩家看不看而不同）。full-HD=正典，LOD 降級成未來「須先證明 match full-HD 才准開」的 perf 優化。
- **血證**：thrash 是 near 專屬病（near 被害死/far 活=命運看玩家臉色）；reaction_system(N1-5 叛變/暴動 + breed 生育)在 all-far headless **從沒跑過**（reaction.* 全 0）→ 我們過去所有量測是「不能生育、無內部政治」的殘缺世界。
- **★perf 可行性（systems 量測 `lod_perf_bed@89b22ad3`，部分否決）**：~15 隊 full-HD=474tps（1× 撐、4× 勉強不到、hitch 103ms）；**116 隊 full-HD=~8tps 崩**。真根=**faction_ai O(N²)**（每 faction rank 所有隊，assign_tasks/unified.rank/assign.members 116隊時 213-270ms）。∴ **full-HD 正典現行規模(~15-25隊)可落，50+ 隊否決待 O(N²) arc**。
- **落地順序**：①full-HD 轉正典現行規模先落（thrash-fix 在 full-HD judge，進行中）②gen 重校 slice（含 breed/reactions 開機動態）③**O(N²) faction_ai perf arc=50+ enabler**（timescale-wave 真根，攤平每 faction rank 所有隊）④LOD-as-fidelity-preserving-opt。
- **★backlog（待 greenlight，未 dispatch）**：gen 重校 slice / O(N²) faction_ai perf arc（大 arc）。
- **★絕境階梯完整性 arc（blueprint 2026-07-15，desperation 刀衍生，待 greenlight）**：desperation-food-seeking 刀補完「絕境隊不選兌現不了的路」（買糧/併入 look-before-leap+rejection-learning、遷移找糧）後，剩絕境階梯的完整性題：①**盲乞食**（乞食 belief 門檻 `food_est` 太嚴→絕境隊從不乞；改對可見鄰居盲試，人格 gate 肯不肯乞——WHAT 已裁，見 known_issues）②**抱團模型**（併入/consolidation 弱隊主動抱團求生的完整 lifecycle）③**食物流通**（餓世界無食物賣方=買糧供給側，D 經濟供給題，併 full-HD live 觀察）。三者同族（絕境求生的供給/社交面），observe/經濟 arc 一起做。
- **★O(N²) 歸因 refine（LOD@116 補跑 2026-07-14）**：116 隊 **LOD=25tps / full-HD=18tps 都崩**（都 <<240），LOD far-cadence 攤銷**只買 1.42x**→ **O(N²) 是「50+ 隊」硬前提、不分 LOD/full-HD，LOD 當不了 stopgap**。可玩天花板(1×)外推：full-HD~25隊/LOD~45隊，都搆不到 50+。∴ O(N²) arc 與 full-HD 決定**解耦**（想要大世界就得修，不管 regime）；full-HD 額外只 1.42x=加固 full-HD 轉正典決定（scale 問題本就是 O(N²) 非 regime）。

**★衍生 backlog（本 workflow 導出，未 dispatch）**：
- **觀測盲點閘（待建·可行性系統評）**：憲法閘同精神的 site-freeze tap-coverage baseline——新增 decision/resource/state 未接 tap→FAIL。現況=不變量已立、機械閘未建。可行性初判：`constitution_gate.gd` 有現成 site-freeze 樣板可仿（掃 tap 註冊面 vs baseline），但「暫態」語意覆蓋比 TaskArbiter mutation 面廣，需先定 tap 註冊點契約。
- **逐 specimen 全量 dump 床（部分工具化）**：SpecimenTracer 補接 order 系統等 tap-gap（本 session 血證 decision_count=0 假象）+ jsonl trace 輸出。
- **thrash-fix slice（首個試驗，待用戶 greenlight）**：真活=求生 fire 後鎖執行到買糧單下成，別每 tick 被底層任務打回 idle（Team14 subteam 貿易↔idle 抖 122 次餓死）。走 patch-gate-first 查誰跟求生控制器搶。**★藍圖推翻早前「層5 餓時食物壓過軍備」方向**——真根是 thrash（手不聽腦）非權重，非 tuning。

## 📍 前狀態（2026-07-01）

- **🧭 中長期計畫層 = 主動攀爬取代反應式苟活（✅ S1-S4 全 merged，2026-07-13，established 鏈根治方向）**：established 五層調查鏈用戶裁定的根治——決策只有短期反應無中長期規劃 → 加「承諾式攀爬計畫層」（延伸野心階梯非新求解器,plan_phase=feedback controller 餵 rank_scored 偏置 term）。**S1 rung 事件驅動**（`efa2c69`,milestone_met 升/連續 K 失守降,棄每 10h 瞬時 target_rung 重算抖動;S1 blocker 裁定棄 EWMA 綁 milestone——implementer trace 抓 EWMA 對常數 metric 恆正 demote 永不 fire）。**S2 phase 導出+偏置**（`0af34ec`,缺口×個性×隊形→plan_phase{求糧/成長/聚勢/立國}→plan_phase_drive term;S2 blocker 裁定 B——貿易移出 SEEK_FOOD:貿易=致富主表達由 intent_fit 驅,設計原則「phase map 排他 intent 主表達」化解 reviewer 雙偏置 watch + TC7 個性分歧 collapse）。**S3 survival-bypass**（`6ffcb2b`,劇變 pop驟降30%/food深負-2/leader失→立即重算 rung 為承載力無視遲滯;目標階層≠行動層 survival override）。**S4 GUI**（Observer 露 plan_phase+rung+archetype 攀爬軌跡可讀）。全 slice R²×gate 綠+determinism。**★process 亮點**:plan trace 先於 build 連抓兩設計 bug（S1 EWMA/S2 貿易 collapse）零 merge 污染。**現況**:機制面完成,established 仍恆0——揭 phase 同質化（GROW 獨大=食物修成功不缺糧+attrition 縮 pop<8,pop 成長多路受限:繁殖 safety>0.7鎖+征服吸收 flee-heavy 節流,訂正「繁殖鎖=唯一」over-simplify）+ **ESTABLISH phase 零偏置=立國未接計畫層**（純機械 B-gate）。**下階段=立國 redesign**（加立國意圖進 argmax mirror 建國+B2/B3/B4 硬閘降 modifier+填 ESTABLISH 偏置）=established 最後一哩。plan `2026-07-12-midlong-term-plan-layer`;memory [[project_established_chain]]。
- **🍖 苟活地板 tune = 解急性餓死崩（✅ merge `0661d19`，2026-07-12，established 五層調查鏈第五輪）**：default.json 深度量測揭 established 恆0，逐層 patch-gate-first 挖出**五層雞生蛋**：①farming 死鎖（獨立隊無食物基建，de-patch `feat/depatch-build-rights` 已 merged）②建國 A 門 pop≥8（82.7% 卡，早崩吃人口）③B2 統領繁榮閘（統領唯一成長=P4_expand 被 `_score_expand` food>100 閘鎖，絕境隊統領凍 ~0.25<門檻~0.35）④leader 週轉吃成長（command-tenure 單獨測 B2 仍卡=leader 死太快，統領累積 170-430 日 >> 在任）⑤**共享上游根=月1-3 急性餓死崩**（86-96% 隊開局負食物流,attrition 45%）。真根=食物 income 路徑結構不足（`_collect_from_tile` task-gated 採集 + farm-gated 倍率 + buffer 800 只 outpost-owner）。**反冗餘 lens 擋掉新建苟活地板**（已存在:`_evaluate_survival`→rank_survival PRIO_SURVIVAL forage + `_forage_subsist_buffer` latch）→ 改 **tune 現有 placeholder 常數**（`FORAGE_FLOOR_DAYS` 1.5→5 給韌性 margin、`PASSIVE_BASE_CHANCE` 0.08→0.30 降空手、wild_game regen 複用 regenerate_tiles）。**★balance 守**:floor 5 天=pop×4.0 < 建國 7 天門 pop×5.6 → 苟活保命但不成長（farming/貿易對繁榮仍必要）。measurer 3mo A/B:attrition 47%→17-31%,5 天優於 7 天（7 無額外改善+貼建國門風險）,苟活≠繁榮守住,determinism CLEAN。融合閘 constitution PASS+headless 零新增。**command-tenure（統領日常成長,loop2 外層 cadence `_grow_leadership_tenure`）已併 worktree 重測 B2**（急性崩腰斬→leader 活久→tenure 累積前提變）——鬆動則一修多解實證,仍卡則加碼（succession 繼承/授XP）。specs `2026-07-12-{depatch-build-rights,command-tenure-growth,forage-floor-tune}-technical`。**教訓**:五層 patch-gate-first 逐層挖（每層修露下一層）最終收斂到共享上游急性崩;反冗餘 lens 擋重複建設改成小改常數;右尺寸砍 A/B（3mo 答急性崩不必 12mo×3seed×2檔 ~4hr→~1hr）。
- **🌍 world-gen variety = 每 seed 開局變化（✅ merge `9156f6f`，2026-07-12）**：開局世界更變化，去 key-order 固定布局。**§1 據點 seeded 散布**（`world_generator.pick_start_positions` rng scatter+位置熵護欄，棄 key-order；determinism byte-identical，randf 序不洩漏）。**§2 據點數 range**（`randi_range(OUTPOST_MIN,OUTPOST_MAX)` 8-14）+ **硬上限**（`OUTPOST_DENSITY_CAP` map_cap 夾）。**§3 勢力數 range**（2-4）+ **config 分工**：`default.json`（玩家遊戲世界，UI 全載）移除 `total_count`/`count`/`weights` 顯設 → 觸發 range 放野；`warring_states.json`+場景 config 保留顯設**釘死**=量測隔離控制基線（`if ocfg.has("total_count")` 分支）。**§3 全域結構地板（能跑保證）4 項 AND**：①每勢力≥1可達據點 ②領土非孤島(軟標準 `_hex_dist≤FLOOR_CONNECT_MAX`,非嚴格連通圖) ③散布覆蓋度≥COVERAGE_MIN ④獨立隊起點鄰格可通;違反→`FLOOR_RETRY` retry,耗盡→**deterministic fallback 補位**（`scored_positions_pure` 純評分降序,零 rng,非靜默送不合格）。**gates 全綠**：四維地板 60/60（兩 config 各 30 seed）+ fallback 分支構造退化 config 20/20 觸發（determinism 含 fallback byte-identical）+ constitution PASS(sites=29) + headless FAIL 集與 main byte-identical **零新增**（5 pre-existing TDD-red）+ **R²×2 CLEAN**（首輪抓 §3 縮水 halt→補齊→re-R² CLEAN）。**★process 教訓**：measurer 首輪「地板30/30綠」只量 code 實作的覆蓋度單維,漏 spec 承諾另 3 維（characterize 家族病=量實作非量承諾）→ R² grep file:line 抓實 halt→往後硬 gate 對 spec 逐項驗。**兩非阻擋觀察**（known_issues）：§3①「可達」實作只查 tile.has+鄰格存在（本引擎無不可通行地形,近乎恒真,風險本不存在）；fallback 成功記 floor_pass 無痕（可選加 `floor_fallback_used` probe 追主路徑失敗率）。spec `2026-07-12-worldgen-variety-technical`。**§4 重 baseline**：`seeded_warring_bed` baseline 重生（§1 scatter 改所有 config 位置,標位移非迴歸）+ **深度長跑參照 = 2 seed × 12 月(1 sim 年) 全探針**（用戶定,看長程湧現:經濟/征服弧展開/人口曲線/late-game perf,非 18-seed×3mo 廣度;default.json 為主）（measurer 處理中）。
- **🤝 consolidation 名聲磁鐵 = 活路（✅ merge `14c08f9`，2026-07-12）**：combat consolidation 長弧終局。**8 層 seam de-patch + 雙向(弱push/強pull) + 完整 utility 全 organic ~0**——決策系統完整正確，理性得出「弱隊 survival-locked 逃/散、強隊寧武力征服（收益>和平吸納）」＝**和平 team consolidation 非此世界 emergent**（9383 evals 決策到位仍 dispatch~0）。**★用戶洞察翻案**：不硬修機制/不動征服平衡，改**名聲驅動跨 faction 自願歸附**（弱隊主觀投奔「戰場護過我 + `protector_rep` 高」的保護傘=pull 繞征服死結）。β 分軸（`protector_rep` 道德名聲，語意獨立 `known_reputations` 情報信任=防污染 belief 認知數學）+ 閉環2（aided/looted 道德事件喂 rep）+ 閉環3（`_find_strong_neighbor` axis="rep" 選護過我的）。**大窗確認活：18-seed 196 次完成 vs 前版 4-19＝10 倍跳、跨 faction 自願歸附穩定、mega-blob 受控均 34.67 隊、三端/gate#1 綠**。決策統一 win（consolidate_drive flat 修/join+整併合一/order_target/movement/priority de-patch/完整 utility/loyalty init）一起 ship。**gossip 名聲傳播 defer 資訊維度 Phase D（接口已留）**；現階段「中性 rep 無差別投靠」接受（無名聲資訊時投誰都合理）。spec `2026-07-11-reputation-magnet-slice` + `2026-07-10-consolidation-s-a-technical`。**教訓**：diagnostic 紀律極致 dogfood——8 層假根因逐一實證翻案、5 型 characterge 覆蓋盲點全被下游接住（memory [[feedback_structural_audit_complement]]）；最終解非工程是換視角（強吸弱→弱選仁君）。
- **⚔ combat-into-engine S1 追擊人格化 ✅（merge `db04407`，2026-07-10）**：pursuit 放血由固定 5% → 勝方領袖 **殘忍/貪婪** 秤。**★三 rev 收斂教訓**：rev1 `int(pop*5%)` 截斷→0、rev2 跨事件累積器→0（每場只追一次 carry 不跨 1.0）——**兩次零效揭真根非捨入，是 `pop-% × 小效果` 在小隊世界（organic 全小隊）本質恆~0**。→ blueprint 停機制修補，**rev3 改絕對 straggler-kill**：`clampi(int(round(殘忍*2.0+貪婪*0.8)), 0, 3)`——scale 無關（小隊也見血）、天生 bounded、人格 gated（慈悲→0/中性→1/軍閥→3）。質感達判準：`loss_sum=6`（首次>0）、pursuer 均殘忍 0.669、逃 82.9% 三端穩、`extinct.combat=0` 無暴漲。**★世界級 emergent（非 regression）**：總戰鬥 219→199（**-9%**）=追擊真殺人→隊變小/團滅→少下季再打→全局戰鬥密度降=窮追讓 warring 人口漸疏（追擊終於有持久後果，非永恆重打）。+§D4 `_cas_carry` 顯式 erase 補債。融合閘 constitution PASS(sites=29)/Coin=0/Invariant=0/Pursuit fires。閘紀律全程守（每 rev 走 R②，reviewer 抓 premise_contradiction 常數未宣告=parse 錯 merge 前擋下）。spec `2026-07-10-combat-into-engine §S1 rev3`。**S2 rank_combat 接續**（納地板1 硬gate/靶C→S4）。
- **🏳 敗北逃決策 rev2 ✅（merge `3892761`，2026-07-10，絕境戲總開關）**：combat 殲滅-heavy（絕對殲滅線 pre-empt 逃）=絕境根 blocker，rev2 三改活敗北三端。①`_mortal_flee_check`（膽量秤，殲滅線前 fire）**pop-based 公式**（`criticality=(4-eff)/3` + `outnumber×0.5`，棄 v1 str_ratio pop-blind 反噬——1 猛將小隊 str 虛高壓負 pressure 病灶結構消失）②`capture_routed_as_captive` severity=`max(1-readiness, pop_criticality)`（reviewer 挖 readiness-gate 脫鉤根因，pop-flee 退場 readiness 還高→俘率偏低修）③**§D4 傷亡分數累積器 de-patch**（★補丁閘型病：`loss=int(round(eff*str*0.1))` 對 eff≤3 積 ≤0.3<0.5 **恆捨入 0** → mortal zone 零流血 → 殲滅**結構不可能**；累積器跨 round carry 分數餘量 floor 取整，零新增 randf=determinism 保）。**三端 organic 大窗（219 場）**：逃/潰散 83.1% 常態 ✅、俘虜 14% 中頻 ✅、殲滅 0.0%——**用戶裁「接受不可見」**（機制正確=對稱床 brave×brave 45%/str·pop=1.000 均等死戰質感精準，但「勇者×小隊×被圍×均等」窄縫疊窄縫 organic 罕觸=理論賭注地板，正因全滅可能逃才有重量）。不放寬 courage 窗（稀釋「殲滅=勇者專屬殘局」質感）。融合閘：constitution PASS(sites=29)/CoinAudit=0/Invariant 違反=0/21600tick 無崩。守衛床 `defeat_flee_annih_exercise_bed.gd` 留檔複跑。設計事實入 `game-design.md` 敗北模型段。spec `2026-07-09-defeat-model-flee-before-annihilation`（§D1 rev2+§D4）。
- **🔭 observer inspect 擴充 ✅（merge 2026-07-09，read-only god-view）**：隊詳情露全非零資源（原只 food+coin）；據點 inspect（點格/列表面板/被 owner 駐隊佔的據點→隊詳情附「駐守據點」段）；設施顯示全 8 種非零（FACILITY_DEF 權威：農場/工坊/藥坊/鑄幣/馬廄/冶煉/武器坊/護甲坊，原只 weaponsmith）。constitution PASS sites=30、query 測 32/32、用戶手驗。純觀測零 sim 動。**用戶手驗連帶抓 2 缺口**：weaponsmith 顯示不全（=spec 漏列全設施，已修）；**初始隊生地圖外**（`game_setup _random_near` 越界=獨立 sim bug，spec `2026-07-09-spawn-offmap-guard` 在飛）。
- **🤖 A2c-1 consolidate 折入引擎 ✅（merge `c047241`，2026-07-09，純 FA5 fold）**：faction 整併（小隊併大隊/戰前集結）從 weigh 前 pre-gate bypass 折入引擎 rank_scored 「整併」option（consolidate_drive term + ctx consolidate_target_id + 拆 `_assign_member_tasks` pre-gate）。**merge-gate 全綠**（constitution sites=29 / framework 7 / HOB obey92%+determinism PASS / sanity 4-config 0違反）。**★續議 survival-value 升級撤銷**：full_probe 3-way 顯 upgrade 逼 100% 併卻 starve 不動→多 seed(1337/42/7) 證「純 fold=regression」是 seed-1337 幽靈（starve 方向不一致 +3/−24/0）→ 解假問題。**已知限制**：`merge_teams` food-blind=survival-inert（併餓隊入非餘糧 absorber 不生食物；逼併 320 vs 154 世界逐位元同）→ 歸未來絕境經濟 slice（`known_issues`）。**教訓**：相關≠因果+單seed≠真，三步收斂（full_probe相關→upgrade實驗證無因果→多seed破幽靈）。**新驗收模型首/二實戰有效**（full_probe 完整數字→藍圖 pass 權判→REJECT過修+多seed破幽靈→SHIP純fold，無bounce/橡皮章）。phantom current_option（faction_ai:1487）獨立待修不變。spec `2026-07-09-A2c1-consolidate-into-engine`（survival-value spec 標撤銷）。
- **🤖 A2a 子隊決策納統一 DecisionEngine ✅（merge `06e10a0`，2026-07-08，v2 機器首個完整走完+驗收 slice）**：子隊 idle 決策從手寫 argmax（`_evaluate_idle_subteam`）+ randf 中途叛離（`_check_deviation`）遷移到全框架 `rank_scored`——歸建(duty)↔掠奪(greed) loyalty-gated 競秤湧現，母團命令複用 faction_duty/loyalty term（非子隊專屬分支），strategic-gate 通用規則，`_try_join_target` helper（scope B：玩家 target→forced_event 不 fallthrough / NPC→try_set JOIN）。`SUBTEAM_CADENCE` 1日/次攤平成本。**量測（seed=1337 HOB bed，main vs 分支對照）**：**subteam_bypass 11→0**（子隊不再繞引擎=slice 目標達成）、obey 98.0%→98.6%、determinism PASS、非擾動 MATCH、13 join-guard 斷言 PASS、憲法 sites=30。**★②reject 為誤判、藍圖 measure-first 翻案**：measurer 記的「360s perf 迴歸」實為 HOB bed 跑 4×一個月 warring≈500s 超 wrapper 預設 360s timeout（**main 自身也 392s**）；lod_perf 同規模每 tick A2a ≤ main（LOD 12593<13241us）無迴歸；wall 多＝世界岔開存活隊多(59 vs 53)非單位變慢。真 O(N²)=`near.faction_ai` 60隊 warring **pre-existing**（歸 timescale/LOD wave）。merge 只帶遊戲碼 7 檔（stale-base 分支 orchestrator 檔舊，避 revert 機器強化）。spec `2026-07-08-A2a-subteam-decision-routing`。**follow-up**：join-consent-consolidation、HOB/team_trace bed 對 360s gate 提速。
- **🧠 憲法 arc 序7 reaction 溶入 ✅（feat/reaction，2026-07-06）**：audit 標「最大最難」，★measure reframe=**其實小**。坐實：9 反應 apply 幾乎全 state-effect（情緒/loyalty/unrest/food/coin/離隊/生育/memory 後果），**唯一行為選擇=聚合 panic-flee bridge**（`reaction_system.gd:48-60` 手算 try_set TASK_FLEE）。∴ 序7=拆 1 bridge + 保 9 反應為 consequence scaffolding。**溶**：ctx 加 `team_panic`（高 stress 低 loyalty named 成員/pop 聚合=決策模型情緒腳首接線）→ `threat_pressure` term 疊 `team_panic × PANIC_WEIGHT(0.5)` → 引擎 survival option FLEE 自然勝（潰散壓過 leader 勇氣，非旁路 try_set）。★FLEE 三源序保（真絕境 survival 80 > panic 70，PANIC_WEIGHT max 0.5 << survival 絕境量級 12=不喧賓奪主）。個體反應 apply 全不動。自建 `reaction_dissolution_check.gd`（4 段 ALL PASS）；gate removed evaluate_all（reaction_system 零 TaskArbiter 面）；framework 7-0、全融合驗綠、seeded 49/8/1/381 零漂移。bridge seeded fire=0（dormant）→撤除零影響。**B 債**：PANIC_WEIGHT 全域 const 待人格化。**backlog**：memory 腳仍 dormant（DecisionContext 不讀 person.memory=決策模型 gap）、反應觀測空白。handback `2026-07-06-wave1-reaction-dissolution`。
- **⏱ 時間統一 wave 進行中（2026-07-05）**：時間=統一矩陣漏的維度（~80 常數散 21 檔硬編）。藍圖 5 錨定：①移動 240tick/hex=1天(BASE_ACTION×遭遇尺度,×5拿掉)②遭遇尺度24③cadence 決策層級語意化④後勤走一格帳 measure⑤觀看組不動。**目標規模=~50 隊**（LOD perf 量測揭:LOD 只 3× 常數/真根 O(N²) faction AI 忽略 subset/41隊已137tps+1s hitch/107隊全垮→A必修=空間分區+honor-LOD+cadence攤）。
  - **✅ slice A1（feat/timescale-skeleton，merged + 拆片 reconcile）**：新 `time_scale.gd` 單源類（承既有根,單向 TimeScale→{WorldState,Encounter}）+ `MOVE_TICKS_PER_HEX = BASE_ACTION×MAP_SCALE/WORLD_SPEED_MULT(5) = 48` 連動 + 3 時間不變量入 invariants。**★A 拆 A1/A2（藍圖 five-rulings 防餓死潮）**：實作原含 ×5→1(=240)已 merged，藍圖後裁「×5→1 須綁 ④補給+FOOD重校+gen 四件一 landing」→ **系統 reconcile 恢復 ×5(MOVE 48)=A1 零行為**（seeded final 回 47/8/1/380 鐵證零擾）、×5→1 推 A2。headless DONE/time assert(MOVE=48)/framework 7-0/coin_eq 0。
  - **平行 measure done（夜班）**：三病共根=**far-zone 移速稀釋(B)一修多解**(V1 trade+V4 envoy+V3 帶禮結盟);④後勤×1>10格斷糧真帳;V3(b)直解結盟0.55恆false+V2-cmd結構shadow=判準題。全入 known_issues,報藍圖 `parallel-measures`。
  - **✅ B far elapsed（feat/far-elapsed-movement，merged）**：movement process 收 elapsed_ticks(near=NEAR_CADENCE/far=FAR_ZONE_INTERVAL)+多格迴圈保餘數→修 far 10× 稀釋。**一修多解 confirmed**：V1 trade arrive 3→21/deal 16→42/矛盾率0.758→0.605、V4 envoy delivered 大漲(seed42 4→32)、V3 帶禮 accept 0→1。不塌房(pop 反升)、perf +28%(far 真做 path)無新 spike。headless DONE/framework 7-0/確定性守。**seeded 值變=B 預期→post-B baseline=46/8/1/380**(headless reproducible 自比確定性,無 hardcode 值改;seeded_warring_bed=on-demand diff 非 auto-gate)。殘因(正交移速,非本 slice)：deal_merchant=0=carrier 存在性(TAG_MERCHANT=0)、envoy accept 低=決策端拒絕(送達成功)。
  - **✅ ④ 承載力=好的餓（food_ledger_bed）**：駐紮承載力邊緣(60%負流/20%斷糧,速度無關)但**斷糧隊 89-96% 搏命**(覓食/投靠/回家補給)→餓→行動 trigger 健康、稀缺引擎在跑。藍圖裁**別灌糧**(拔引擎)→ A2a 只 recalibrate ×1 承載力維持。
  - **★沙盒憲法（藍圖 2026-07-05，專案定義級 governing invariant，凌駕級入 invariants）**：作者寫世界不寫決策，凡 NPC 行為必經統一決策引擎，禁繞過引擎的行為規則/判斷器/行為 subsystem。稽核既有違憲碼溶進引擎=統一矩陣收斂主軸（稽核 spawned）。
  - **tick60 解析度（藍圖裁）**：`TICKS_PER_HOUR` 10→60（動根 TICKS_PER_DAY 240→1440），安全證 PASS（唯 `_get_near/far` 需 cadence 化）。裁1=3 機械修獨立 slice 先做（_get_near/far gate+10 裸常數導出+eta/240+FLEE）。裁2=**60 併 A2**（60 抵消 ×5→1 食物懲罰:240/1440=4h/格≈現 ×5 4.8h → 沒餓死潮,×1+60=最終節奏一次校）。裁3=**砍 A2b 沿途補給 subsystem（違憲）→改引擎接線檢查**（食物-on-journey 登記引擎子需求?塞糧/買/搶/覓食 affordance 匹配?缺→接引擎）。裁4=空間維度全連動導出。
  - **後續序**：0.憲法閘+違憲稽核清單 1.3 機械修 slice 2.A2=×5→1+60+FOOD/gen 一次重校(砍補給subsystem) 3.空間骨架導出+據點密度 4.QA 物流重驗+食物最終節奏重量+憲法稽核 5.cadence③/carrier/V2-cmd 後段。
- **💰 貿易環點火 ✅ 半路（feat/trade-loop-ignition，2026-07-04）**：六站漏斗定主斷=**timeout stale 秒殺**（`TRADE_TIMEOUT` 讀平行欄 `trade_task_start_tick`，只三路寫，unified/ambient 派 TRADE 拿 stale 0→tick>1440 派出即死，兩 seed dispatch 5.6萬/到場 0）→修=改讀 TaskArbiter 恆蓋章的 `task_start_tick` 單源+**廢平行欄**（家族病：2026-06-11 同病補記過，第四路又漏=散落純量 drift 活教材，故廢欄非再補記）；順修 ambient TRADE target=自格（→`_merchant_trade_target`）+途中相遇即 release（→到點才 release）+timeout 按殘距估。成交 **6→16/2→5（~3×/~1.5×）**、meet 16、arrive 3。**錯修二連 revert 入檔**：過期單濾（撲空=G1d 活性設計勿濾）、駐村隊 viability guard（村攤營業=需求側環實體勿擋）。**Task 3 三機器並綠**：①矛盾率 gate（`TRADE_CONTRADICTION_MAX=0.85` 回歸 baseline，絕對率 0.71-0.76 印真值不隱藏）②常駐六站漏斗③`--obs-ticker-dump` TSV。**誠實揭半路**：成交非數十、絕對矛盾率仍病=**殘因兩塊域外**（①LOD far 移速 10× 稀釋②default TAG_MERCHANT=0 無 carrier）→報藍圖裁。不塌房（funnel sanity pop/faction_found/capture 同量級）、回歸全綠。plan/handback 同名。
- **📊 全系統充足性率表 harness ✅（feat/sufficiency-rate-harness，2026-07-04）**：新 `scripts/debug/sufficiency_bed.gd`——default 自然世界（`player_id=-1`）× seed 1337+2674 × 6 月自跑，輸出全系統率表（每列 `想要/可行/發生` 三元組＋率＋月切面 delta＋表尾 `[SUFF_JSON]` 一行/列＋事件流 dump `SUFF_DUMP`=global+observer messages）。復用 `Probe`（enabled-gated、RNG-free），各鏈補缺失 counter（純加行）：message（sent/prop_candidate/prop_done/delivered/distorted/lie_claim）、belief（has_belief call/true、best call/hit、claim 新鮮度桶、reconcile 機會/比對）、diplomacy（proposal sent/handled/accept）、RelationGraph（tribute eval/with_edge/edge_flipped，snapshot 法逐位元等價）、intent（sel_<type>/goal_emit 讀側）、event（各型 check/fire）。既有漏斗（capture/assimilate/occupy/founding/envoy/scout）收編其輸出格式不重做。**中立性硬證：seeded warring 三 seed 逐點 `total_diffs=0`**（counters 不碰 RNG 流）。framework 7/0、coin_eq delta=0、headless DONE。**純機器不判不修**——率表原始輸出交 QA 判（合理 0 vs 斷鏈 0）。貿易列=佔位引貿易軌六站漏斗。plan `2026-07-04-sufficiency-rate-harness`、handback 同名。**觀察素材（未判）**：envoy delivered≈0（首列病單候選）、消費/送達 1.7%（非 order 類無決策消費 chokepoint=結構性缺）、意圖→行為非征服 intent 未到 task 層、event fire 多型 0（split/replace/defect 六月零觸發）——全交 QA。

- **👁 觀測 GUI 輕 slice ✅（feat/observer-gui-slice，2026-07-04）**：三件全上（事件 ticker 人話+隊過濾 / 隊伍 inspect+地圖三方同步 / 速度四檔+時間）+ god-view 地圖（archetype 色+faction 環+outpost 標）+ 截圖 harness（`--obs-seed/run-months/shots/select/out`）。Task0 事件補洞（assim/revolt/flee/captives_taken）走新 `emit_ambient`→`observer_messages` 獨立 channel（global_messages.size() 被 order_system 借作 oid 空間，append 會擾訂單行為——逐點 diff 實測抓到後改道，total_diffs=0）。玩家路徑零 diff、seeded warring 同 hash、framework 7/0。bar 場景 seed 1337/2674 六月跑滿，狼弧鏈畫面可讀。hitch 偶發（≈1/月，delta clamp 蓋幅度）→ far.total 不動。handback `2026-07-04-observer-gui-slice`。

- **🤝 互動統一 F-I2/I4/I5/I7+I6 ✅（feat/interaction-unification-fi，2026-07-04）**：屈服單一公式 `tribute_accept`（belief-gated+feud/gratitude 邊權重，三舊公式退役）、失真單引擎 `DistortionEngine`（三引擎+dormant 第4退役）、F-I5 judge=接線（feud/gratitude 活;killed/protect dormant 入 known_issues）、F-I7 `_should_attack` 轉 belief（無估→保守不攻）、F-I6 type 欄補。C 類退役不並存全程。seeded finals 量級不崩（hash 變=預期）、coin_eq 0、framework 7/0。TRIBUTE_* TEST VALUE 待平衡 pass。互動格矩陣殘=F-I8（NPC recruit 個體）。handback `2026-07-04-interaction-unification-fi`。

- **🏛 沙盒 bar arc（(a) 崛起/經濟底）— 連串 measure→fix**：commander-v2 後戰國 seed 揭 default 龜縮（CONQUER=0/established 卡1）。measure-first 逐層挖（別猜）：能人 pop 崩=**飢餓非戰敗** → ①**戰鬥不決勝**(0 擊潰，撤退先於殲滅，吸收掛 `_end_combat` never fire) ②**食物模型沒統一**(成長 surplus gate 讀私產 silo→糧倉/交易糧餵不到成長→非 plains 注定餬口)。
  - **🍞 統一食物存取 ✅（merge）**：`reaction_system` `_score_expand`/`_evaluate_life_events` surplus gate → `ResourceSystem.effective_food`(coherent，對齊 ambition_ladder)。統一非補丁、不 nerf regen、保交易摩擦。乾淨 bed forest pop 6→12（原餬口）。coin_eq 0/framework PASS/餓隊不誤放寬。**藍圖 🟡：讀 A（非 plains 能累積）收下＝(a) 攀爬「累積」段解凍；讀 B（特化-交易環真轉）未到＝下一經濟 arc**（trade loop 沒 fire＝覓食勝買糧）。plan `2026-07-01-econ-food-unify`。
  - **⚔ 失能-capture（戰不決勝 fix）= (a)-征服鏈 keystone ✅（merge）**：藍圖裁「失能者被俘=控地權」。measure 證 NPC 戰 0 擊潰（撤退先於殲滅）→P1 吸收掛 `_end_combat` never fire。修：npc_combat `_force_retreat`（潰逃）勝方控地俘敗方 **wounded 一比例**（=(1−readiness)×FACTOR cap，確定性非 RNG，guard 餘力限）→ captive_groups（P1 複用）。**決勝在潰逃非對撞**。warring 量證 **[Capture] 0→5、p1.assimilate 0→2**（captive dormant→fire）。守恆綠。plan `2026-07-01-incapacitation-capture`。存儲統一（prisoner_population）=Phase 2。
  - **🏛 獨立戰略層（統一決策 arc 第三塊）= (a) 收尾 founding ✅（merge）**：measure 證 rung2→3 卡＝能人是**獨立隊**（T32 cap4/食2207/pop9 全過唯 fid=-1）；commander-v2 戰略意圖 faction-level only→獨立無建國 drive。修＝**下放戰略意圖到野心獨立隊**：`_evaluate_independent_strategy`（fid=-1+野心≥AMBITION_FOUND_MIN+累積夠+路徑可達→秤建國 vs 守成，means-end）→ 結盟(primary,TASK_DIPLOMACY→interaction:333)/吞併(TASK_ATTACK→subjugate:524) → 複用既有 `create_faction`（非補丁）。**T32 建國 deterministic 證**（fid -1→正 members=2）、不 over-found、守恆。**★S3 回歸主 session 抓修**（子 session 誤稱 pre-existing）：獨立戰略 preempt prosperity-scout→修＝**遇 prosperity 候選+belief-弱 prey→defer**（讓 prosperity scout-gated→勝 subjugate 也達建國，不繞 G3d 誘殺）。framework PASS=7 復原、indep 5 測綠、coin_eq 0。**統一決策 arc 三層全補（隊/派系統領/獨立戰略）**。spec/plan `2026-07-01-independent-strategic-layer`。
  - **✅ (a) 機制里程碑封存（藍圖驗收通過 2026-07-01）**：三源全活（累積[食物統一讀A + 失能-capture]/founding[獨立戰略層]/征服[commander-v2+P1]）。**統一決策 arc 三層全補完成（隊任務/派系統領/獨立戰略）= session 開頭「決策不統一」真根徹底清。** handback `a-milestone-go-parallel`。
  - **🟡 新：沙盒征服維度（機制✓ / 活世界戲✗）**：established 1→多 / CONQUER 明顯**未在混亂 seed 顯現**＝不算完全達成（不打勾自欺）。**emergence 平衡 + consolidation = 經濟穩後 revisit**（不現在 tune＝打移動標靶；藍圖疑真根＝**consolidation：founded 守不住、T3 立國後失據點崩**，非純 attrition 數字→經濟穩後 measure-first 再修，連受控人力守征服）。
  - **▶ 轉平行（藍圖裁，各推一沙盒維度）— 兩軌 ✅ merged（2026-07-01 平行子 session）**：
    - **讀 B 覓食=苟活地板 ✅（merge）**：覓食來源食物 net-bank cap 到 subsistence buffer（`pop×食/人日×FORAGE_FLOOR_DAYS 1.5`，`hunt_system` source-gate：達 buffer→不獵不耗 wild_game 不 bank=守恆乾淨；超額 min-clamp、剩肉腐敗 sink）。只封 team private food **非 granary** → 定居繁榮不誤傷、地形 regen/forage 決策權重不動。headless 3 測綠（subsistence cap/no-growth/settled-grows）、coin_eq 0、framework PASS。**★次閘（measure 出，非本改造成）**：trade loop 仍不 fire，真閘=**定居隊 granary 自填**（forest regen 3 也填 granary 到 ~cap→成長由 granary 非交易驅動）→ 屬 granary/harvest 域另 slice（見 known_issues）。**誠實：「繁榮須交易」emergence 未到**（覓食封了、granary 旁路未封）。spec/plan `2026-07-01-foraging-survival-floor`。
    - **G3 Phase E enforce ✅（merge）**：5 god-view leak 補 `BeliefSystem.best_estimate`（1a 求貢 power_gap / 1d 收貢回應 / 1b 強鄰投靠 / 1c 施援目標 / 1e 背叛 ally 實力，無情報→保守 fallback 非偷讀真值）+ 背叛去純 RNG（`betrayal_assessment` 純函數：driver=人格+belief advantage「盟弱我利」，confidence gate，deterministic-hard + margin tie-break，取代 `score>0.65 and randf()<0.1`）。同 faction 內部協調/tally/位置=刻意豁免（共享情報，納 invariants）。1c 裁定維持 belief-strict（snapshot 豁免=可選增益、不擴 scope）。headless 5 測綠、warring g3.betrayal=21 合理、coin_eq 0、framework PASS。**誠實：enforce 到位（決策真跟 belief 走）但「自信地錯」emergence 需 Phase D 植假 + 專屬 probe 才量得到**（短窗量不到）。spec `2026-06-29-g3-info-warfare-unified`、plan `2026-07-01-g3-phase-e-enforce`。
  - **🔧 team-ref 根因修：create_faction bidir-safe ✅（merge）**：foraging branch warring seed RNG-shift 掀出 **pre-existing 結構 bug**——`create_faction`(`world_state.gd:75`)直寫 `leader.faction_id` 沒退舊 faction 成員籍（不像 bidir-safe `set_team_faction`）。已是成員的隊建自己 faction（獨立戰略層 rung2→3 複用 create_faction）→ faction_id 翻新、舊 `member_team_ids` 殘留懸空 id → 該隊 erase 時 faction_id-gated cleanup 只清新 faction、舊懸空 → `_assign_member_tasks`(faction_ai:1043) `require_team` assert crash flood。修=create_faction 改走 `set_team_faction`（退舊籍再入新，單源非補丁）。warring seed 1337 驗 **require_team 17850→0**、combat_target Nil 0、SCRIPT ERROR 0、跑滿 24 月 DONE、established 1→2。**實作正確沒打 null-guard 補丁（team-ref 域=系統 domain），呈報主 session 裁**（[[feedback_no_patch_on_settled_architecture]] + team-ref A 類契約）。
  - **backlog（不阻塞）**：存儲統一 prisoner_population→captive / solo 宣告 founding = 受控人力 Phase 2；rung2→3 已解。3+1 對稱不變量骨架（決策✓/信息 G3/所有權 Pattern B/凡位置✓獨立戰略）已納 invariants。

- **🔬 granary 真根定位 + 指標 specimen tracer + scaling 加固 P0（藍圖 anchor-probe-and-hardening，2026-07-01 平行子 session）**：
  - **granary 真根定位（碼證，推翻藍圖 net0 前提）**：`regenerate_tiles`(`resource_system.gd:78`)+harvest(`:222`)**未 day_fraction 縮放**、consumption(`:91,108`)**有** → 供給 24× 快於需求 → forest **秘密 net-positive**、超額 trap 進封頂 granary(釘 2000=爆倉非停滯)。更大：整個世界食物太鬆=無 starvation/無 trade need/turtle 部分源此。**R1(供給 day-scale)=economy-wide rebalance 跨 WHAT 域→呈報藍圖，R1 食物緩**。handback `granary-rootcause-cadence`。
  - **🔬 指標 specimen tracer ✅（merge，觀測 only 零行為變）**：指定指標團 LOD-exempt trace 決策 timeline（想什麼 intent+全候選 util+belief / 做什麼 winner+task / 狀態 pop·food收支·rung·faction·資源）。`SpecimenTracer`(static, default off)+`specimen_bed.gd`。tap：`decision_engine.rank scored[]`(全候選 util)、`_emit_goal`(+state, commander intent)、solo intent、winner commit。**★measure 結論（藍圖要的經濟真根，修正假設）**：不是「錨有名日常無實」，而是 **(a) 獨立商隊零 named 致富 intent**（commander-v2 只給 faction intent、獨立隊無致富意圖節點 → 交易純 emergent utility 非錨驅動）+ **(b) 日常交易有實但被 survival/食物壓力碾成覓食/買糧**（早期 100% 貿易→晚期覓食107/買糧35 碾 貿易，賺 coin 轉買糧/逃命無複利）。conqueror specimen：commander 征服 intent 0、攻擊來自 survival-loot(掠奪54)+vendetta 非 means-end 鏈。**tracer 證食物壓力是掐致富的直接手（R1 雖緩但相關）**。spec/plan `2026-07-01-specimen-tracer`。**待藍圖**：致富要不要成 named 意圖（獨立隊致富 intent 節點=統一決策 arc 延伸）。
  - **⚡ scaling 加固 P0 ✅（merge，零行為變）**：`teams_by_tile` 共用空間索引（每 move rebuild）→ co-location **O(N²)→O(N)**（N=400 3.26×、speedup 隨 N 拉大）、hostile-within/residency 索引化（sparse frontier tail 保險）；`team_intel` **erase-prune**（top memory leak 修：erase 隊清 observer row + 各 observer 對其 target claims）；`sim_runner` **tick 計時 instrument**（`[TickPerf]` 日邊界聚合）；`scaling_bed.gd`（大 N 100/200/400 + 滅團潮）。**honor-LOD 量到不需**（evaluate_all 誠實 O(N)、索引已足）故不做（measure-gated）。**die-off erase O(N) spike 誠實標未收**（不在 P0，另案 known_issues）。零行為變證（加固前後隊數逐點同）、warzone 21600 tick InvariantSummary 0/coin_eq 0。spec/plan `2026-07-01-scaling-hardening-p0`、評估 `late-game-scaling-assessment`。

- **🗺 統一矩陣 program（藍圖 refactor 止打地鼠，2026-07-01）**：反覆冒「沒統一」根因=缺結構視圖 → 開實體×領域稽核。**逐檔窮盡 sweep 全 76 production 檔**（8-batch fan-out 逐行；first-pass grep 版自糾:誤稱 team.resources 被 53 直寫繞、實乾淨）。全貌 `specs/2026-07-01-unification-matrix-audit`（9×7 矩陣 + 30+ fork）。**核心對**（同 TeamData + computed getter no-op setter=最強單寫者）**但 fork 遠比 4-cluster 多、第3不變量單寫者大面積未實現**。教訓 memory `feedback_structural_audit_complement`（measure-first 只抓近端需結構互補;過早喊 done 誤導;+claim-time trigger 自糾）。program 四塊(矩陣稽核✓/強制閘/checklist/逐格燒)。**燒序首三軌並行 merged**：
  - **🎯 首燒 戰略 intent 統一 ✅（merge）**：`select_strategic_intent` 統一 scorer「任何 leader 一套菜單」`{致富/擴張/征服/防衛/守成/建國}`,獨立隊得全菜單(前截斷{建國/守成})。**致富錨接上**(specimen 商隊 想=致富263→做=貿易120,前「日常」無 driver=tracer 揭的經濟真根解)。F-D3(strategic_ai 降空間 affordance 層、單一 intent source)/F-D4(solo_intent struct 廢一槽兩義)/F-D6(threat un-stub belief-based,不壓 P2a survival)收。warring **CONQUER 0→1**(不再結構恆0=前 histogram 僅計 faction 假象)、RICH 主導、EXPAND/FOUND 顯化、DEFEND 高+CONQUER 稀=非病態全民開戰。framework 7/7 PASS、coin_eq 0。**誠實標:征服名vs實斷點**(unified 好戰獨立 想=征服但 winner=掠奪、`_decide_unified` 掠奪 option 搶在 prosperity attack 前;錨顯化非乾淨征服→攻擊)=follow-up。spec/plan `2026-07-01-strategic-intent-unification`。
  - **🪙 單寫者 slice1 coin 守恆 ✅（merge，零行為變）**：`CoinAudit.total` 全池(team.resources+anon_treasury+person.coin+tile.public_storage.coin+abandoned_coin)、`adjust_person_coin` person.coin 單寫者(4 site 含 reaction:292 勒索,plan 沒列一併收)、mint `Probe.add_amount("mint_coin")` ledger + **順修舊 known_issues「mint coin-cap 燒 ore off-ledger」**(先算 coin room 只鑄容得下量、不燒 ore)。裁 **coin_eq 剔 ore**(ore=採集產出非守恆,計入會憑空長)。baseline delta=0(無既有洩漏,值=audit 覆蓋補全 person/tile vault 盲區+單寫者紀律+常駐守恆閘)。spec/plan `2026-07-01-coin-conservation-singlewriter`。
  - **🔍 BEG/JOIN 死路探針 ✅（merge，measure-first 零行為變）**：F-I3 量到 **JOIN=中**(radius14 66/月 runtime 100%空轉,兩 failure mode:197 combat_target 早退 + **根本無 interaction handler**)、**BEG=低**(resolver:247 存在但被 197 擋、prosperity 期 dispatch~0)。機制死路單元測證。**修=follow-up**(建議合併修 combat_target「社交 target≠戰鬥 target」語意拆=共根)。spec/plan `2026-07-01-beg-join-deadpath-probe`。
  - **🍞 B 食物張力 ✅（merge，行為變已校準）= 經濟維度機制到、交易網未轉（露下一閘）**：**R1** regen(`resource_system:78`)+harvest(`:222`) day_fraction 對齊（修 24× cadence bug、移 far 分支冗餘 regen=雙記元凶）、`FOOD_PER_PERSON 2.4→0.8` 校準（REGEN 常數不動、散落硬編一併引 const）;**R2** `food_flow_avg` EMA（日均淨食物流）、breed/ambition rung gate 讀 **flow 非 stock**。econ_bed **forest 苟活 6→7**（非爆倉 6→12、eff_food→0 手到口想交易）、**plains 繁榮 6→8**;warring **不 mass-starve**（涓滴非潮）;framework 7/7。**★誠實標:致富→交易仍未接**——granary 爆倉閘拆、露**下一閘=建設 util 碾貿易**（0.79>0.26,決策權重域非食物,another slice）。行為變:ambition rung 讀 flow → prosperity-attack 需經濟盈餘（飢餓不主動開戰）。TEST VALUE 待平衡。spec/plan `2026-07-01-food-tension`。
  - **🔐 單寫者 slice2 ✅（merge，零行為變）= 強制閘首個可查對象**：**Pattern B driver-ledger 真記**（`world_state.driver_ledger` off-by-default ring-buffer、5 bank reason 現真 append 非丟棄）+ **roster chokepoint**（`add_member`/`remove_member` named_members↔person.team_id bidir、33 production site 遷、2 明示豁免）+ InvariantAudit roster bidir（forward）。**audit 立刻證價值**：揭 pre-existing **leader/team_id desync**（roster chokepoint tyrant 4→0、merchant P0 殘留=leader 指派非-named 路徑,root fix 行為變交 triage）= 第3不變量首個真實可查對象。零行為變（headless 綠、pre-existing FAIL 驗 baseline）。tile-granary-bank/combat_target 延後 slice。spec/plan `2026-07-01-singlewriter-ledger-roster`。
  - **⚔ 征服名實 measure ✅（merge，measure-first 證偽首燒假設）**：量到 **首燒假設錯**——征服隊 **100% 非-unified**（`_decide_unified` 對它不跑、`conq.declared_unified=0`）、舊 solo path 征服 winner **96.8% 攻擊非掠奪**（「想征服做掠奪」在此 seed 假）。**真斷點=攻擊→capture 轉化崩**（243 攻擊決策→1 capture）:**兩條攻擊路徑**（舊 solo 粗攻擊 `_nearest_independent` 無 scout/rung gate vs `_evaluate_prosperity_attack` 細攻擊 weakest-prey/scout-gated/導 subjugate）,粗的優先觸發淹沒細的。**修向=統一征服攻擊路徑**（非-unified 好戰隊 TASK_ATTACK 委派 prosperity）,**非動掠奪**（打錯靶）。follow-up spec（measure 支持）。spec/plan `2026-07-01-conquest-name-vs-deed-measure`。
  - **🧠 means-end 接戰術層 ✅（merge）= 願景進化第一深化（三症狀同根=查表非規劃）**：斷點 measure 確認**戰術層 flat/intent-blind**（`DecisionEngine` util=人格×context,從不讀 team 自己戰略 intent;唯一 goal→tactical hook=faction_stakes→faction_duty 只給 faction 成員、獨立隊 solo_intent reshape 零）。修=**generalize faction_duty → `intent_fit` term**（inject `intent` 進 `DecisionContext` + intent→子需求→貢獻打分 reshape option util）。**★症狀 a（致富→貿易）全解**（貿易 2.08/囤貨 1.27>建設 0.20,前建設碾;merchant specimen 想=致富→做=貿易 100%）+ 新 `囤貨` option。**症狀 b（征服→攻擊統一）機制成**（征服 intent→scored `攻擊`→route scout-gated prosperity,route 6.6×[13→86]）**但 capture 轉化未升**（吞併完成 depth 低=combat/subjugate 完成率 pre-existing、scope 外）;conqueror specimen food_days≈3 survival-trap→掠奪(「餓則搶」emergence 但食物軌壓過戰略層)。**症狀 c（匱乏→搶）gated**（匱乏+野心→掠奪、溫和不搶,防 over-war;over-war 4pp 落 unseeded 噪）。**四關**:①④部分(capture 未升)②③PASS。守恆全綠 framework 7/7、coin_eq 全池 0、北極星 holds（intent_fit boost 帶 driver）。TEST VALUE 待校。spec/plan `2026-07-01-meansend-tactical`。**移動標靶下一步**:capture 完成 depth + conqueror 食物 survival-trap（跨食物軌）。
  - **🔐 單寫者 slice3 ✅（merge，leader desync 根修）**：`set_leader` chokepoint（leader_id↔person.team_id force-sync,**根修 slice2 audit 揭的 leader/team_id desync**）+ `is_dead` 留屍標記 + **反向 roster audit**（person→roster,is_dead/team 不存在跳）+ `driver_tick_hint` 接線（ledger tick 溯源真）。game_sim_multi ×3 全配置 forward+反向 roster InvariantSummary=0（含 warzone）。**結構保證**（chokepoint 強制同步 + 反向 audit 常駐）非 case 復現（merchant desync unseeded 間歇）。納 invariants（規則 2 set_leader / 規則 3 反向 / 所有權域 desync 根修）。combat_target/tile-bank 延後 slice。spec/plan `2026-07-01-singlewriter-slice3-leader-desync`。
  - **🎯 combat_target/social_target chokepoint + BEG/JOIN 死路修 ✅（merge，2026-07-02,下燒平行軌）**：**social_target 拆 combat_target**（語意:社交投靠/乞食 ≠ 戰鬥）+ `set_combat_target`/`set_social_target` chokepoint（F-S4,mirror set_leader,dangling audit）。BEG/JOIN dispatch 改 social_target → 過 `_try_interact:197` 戰鬥早退;**新 JOIN resolver**（merge_teams full absorb）+ BEG/JOIN resolver 上移過 same_faction 塊。**F-I3 死路消**（join.resolve 0→4、arrived_no_handler 0;beg unit 決定性驗）。combat_target 9 site 遷 chokepoint（thin wrapper 零戰鬥變）。framework 7/7、coin 全池守恆、InvariantAudit（含 social_target dangling）OK。**行為變=絕境投靠/乞食復活**（藍圖 marker1）。納 invariants（規則 2 combat/social_target + 所有權域）。spec/plan `2026-07-02-combat-target-social-split`。
  - **🎲 seeded warring 回歸 harness ✅（merge，2026-07-02,純 infra 零 sim 變）= 解 recurring unseeded 盲點**：`WarringHarness.run(world_seed)`（`seed()`+`config.seed` 逐 tick 逐隊確定）+ `seeded_warring_bed.gd`（before/after pointwise diff,同 seed total_diffs=0=noise floor）+ `warring_states_seed` 加 `WARRING_SEED`。RNG 盤點:72 global randf 納 seed、setup local via config.seed、scaling_bed 自有 rng scope 外記。重現性 TDD 綠。→ **warring emergence/over-war 自此硬-verifiable**（noise floor=0→任何跨 code delta=訊號;實際 pre/post 需 dump `WARRING_OUT` baseline 切後 `WARRING_BASELINE` diff）。**但 game_sim_multi/world_sim 仍未 seed**（[[reference_multi_sanity_unseeded]] 更）。spec/plan `2026-07-02-seeded-warring-harness`。
  - **⚔ capture 完成 depth ✅（merge，2026-07-02,下燒核心）= 戰內 PAY 修、但 measure 揭主崩上游**：measure-first 漏斗（14400 tick）——**主崩=intent 126→combat_entered 12（~10% 到真戰鬥）**=攻擊派了追不到/target 消失（targeting/reachability 上游,**非本軌 scope**）。戰內兩病修:①戰不決勝（retreat 7>>decisive 1）②潰逃零 PAY（5/7 wnd=0 俘 0、`_force_retreat` 不 loot=主流戰果零收）→ **潰逃兩路皆 PAY**（掃戰場 loot + `capture_routed_as_captive` 俘 healthy `HEALTHY_ROUT_FACTOR 0.35`）。framework 7/7、coin 全池守恆、InvariantAudit 0、rout capture 測 OK。**★誠實標**:capture.total 3 仍低（戰鬥本身稀有=上游 attack→combat 轉化崩,需 targeting 補）;Task3 survival-trap 自解**上游阻**（specimen 想征服打不到）;以戰養戰人側 assimilate cadence 慢（morale 0.25→0.75 ~25 天,churn 下 P1Absorb=0=manpower 平衡）。spec/plan `2026-07-02-capture-completion-depth`。**下燒三軌全 merged。征服者 emergence 下一瓶頸=attack→combat 轉化(targeting/reachability)。**
  - **🍞 B 食物張力（R1 cadence + R2 flow-not-stock）✅（子 session，branch `feat/food-tension` 未 merge）**：granary爆倉 真根修。**R1**：`regenerate_tiles`(food_regen)+`_collect_from_tile`(harvest gain) 乘 day_fraction（與 consumption 同基準，修 24× 供給不對稱 bug）+ **移除 far 分支冗餘 `regenerate_tiles`**（near 分支已每小時全域再生所有 tile，far 重複=24× 雙記元凶之一）→ 供給真 per-day（forest regen 3/day marginal，REGEN_RATE 常數未動）。**張力校準**：`FOOD_PER_PERSON_PER_DAY 2.4→0.8`（穩態食物 income≈regen[plains op1 ~8/day]；0.8 使 plains op1 養小鎮微盈餘=繁榮、forest op1 微赤=苟活須交易；赤字溫和不成餓死潮）。**R2**：成長讀 flow 非 stock——`team_data.food_flow_avg`（日均淨食物流 EMA，`resource_system._update_food_flow` 每 cadence 更新）、生育 gate(`reaction:201`)+野心積累 rung(`ambition_ladder:52`) 讀 `food_flow_avg` 非 `effective_food` → **granary 爆倉不再驅動成長**（滿倉但 net~0→不長）。**bed 驗每步**：econ_bed **forest pop 6→7 苟活(不死/food_buy=Y 想交易)、plains 6→8 繁榮**（前 forest 6→12 純爆倉）；warring 1月 famine=69(1-anon-at-a-time 涓滴,非潮;能人 25→4 但活且回充/T18 forest 24→19 較 pre 24→6 溫和/T32 9→9 持平)=**不 mass-starve**。headless 全綠(修 ~18 assert:breed/rung 改設 flow、消耗/beg/food_days 數值×const)、framework **7/7 PASS**、coin_eq/InvariantAudit 綠。**誠實標經濟維度 emergence**：**致富→交易→成長鏈未接**——specimen 商隊 想=致富262/263 但 winner=**建設**263/263(建設0.79>貿易0.26)，**從不貿易**。granary爆倉閘已拆，露出下一閘=**建設 util 碾壓貿易(決策層權重,非本軌 scope)**。spec/plan `2026-07-01-food-tension`。**待主 session 裁**：①野心 rung 改讀 flow → 新隊/marginal 隊 flow=0 起步暫 SURVIVE(需持續盈餘才升 rung/prosperity-attack)＝**戰略層行為變**(founding 用獨立 stock gate 未動,S1 PASS;但 prosperity 侵略需經濟盈餘)；②warring 8月全窗跑不完(健康隊多=sim 變重,600s timeout,反證不 mass-starve);③FOOD_PER_PERSON 0.8/flow 門檻皆 TEST VALUE 待平衡 pass。

- **🪖 受控人力統一系統 Phase 1（anon 吸收解 (a)）✅（merge）**：(a) 攀爬卡點 measure 揭「征服只 loot 不長 pop → 戰爭非累積 → turtle-world」。fix = 征服**吸收敗方殘餘 anon pop** 成隔離 captive（低忠，不入 population getter=非戰力）→ 待遇 means-end 決策（厚待/苛待/釋放，driver=holder leader 野心/殘忍/缺糧意圖）→ 軌跡：**厚待→morale 升→同化（captive→holder free pop，population getter 漲＝解 (a)）/ 苛待→morale 崩→暴動（脫離+鎮壓戰損+holder unrest）/ 低 morale+機會→逃（脫離成流民隊）**。**純 anon、零跨域（Phase 2/3 後續）**。**架構**：captive 持有 = `TeamData.captive_groups: Array`（**非 subteam**——subteam dispatch 強制 named leader + cohort 鍵固化，純 anon captive 走 holder 上獨立結構）。**守恆（命脈）**：吸收/同化/暴動/逃全經 `AnonTierSystem.absorb_as_captive/assimilate_captives/detach_captives`（pop 轉移非憑空；暴動鎮壓亡=真死亡路由非消失）。`absorb_as_captive` 插入 npc_combat `_end_combat`（敗方陣亡結算後、erase 前）。`ManpowerSystem.tick_all` sim_runner 每日 cadence。`InvariantAudit` 加 captive cohort 自洽網。**driver-complete**：captive group 帶 `entry/origin_faction/treatment_history`（provenance 追得回吸收+待遇史）。**結果**：headless 4 mp1 測（吸收守恆/待遇軌跡/decide driver/believability）+ 全綠、framework S1-S6 PASS、game_sim_multi InvariantViolation=0 + coin_eq delta=0（含 warzone 戰鬥場景）。常數全 TEST VALUE（CAPTURE_RATE=0.5/CAPTIVE_INIT_MORALE=0.25/ASSIM_T=0.75/REVOLT_T=0.08）。spec/plan `2026-06-30-controlled-manpower-*`。**待主 session**：(a) climb/warring seed 量測解讀（CONQUER 0→? 能人 pop 累積否 不 over-war 否）、常數平衡、Phase 2 named 俘虜起點、rung2→3 另案。
- **🏛 commander-v2 統一統領決策（means-end 意圖驅動）✅（merge）→ 統一決策 arc 真根最後一處收編**：隊層早已統一進引擎，但**統領層 `_update_goals` 仍多閾值並行**（measure 證每 persona 同發 ≥2 無因令、好戰霸主 4 令矛盾=arc 在殺的同隻病最後一處）。**藍圖多輪修正**：①先單姿態（作廢，氣點非發多令是令無法解釋）②升**北極星不變量「凡 named 意圖必有可解釋驅動」**（納 invariants）③means-end 模型（意圖=目標 predicate→子需求=主行動未滿足前提現算→行動=多義 affordance→util=Σ(affordance∩子需求)×人格×可行性）④裁 A：先真 affordance（affordance 真實性盤點 7 action/47 真/29 孤兒，**欺敵外交/貿易戰=孤兒** sim 不產出→列 anchored-pre-player 承諾 arc，玩家面前必落地）。**實作**：`_update_goals` 重構——`_select_intent`（征服/致富/防衛/守成 argmax，人格×belief×viability×hysteresis；征服 gated by `_conquest_viable` 我力含補力餘裕≥belief 敵力）→`_decompose_needs`（深度1，攻擊主行動 force_ge_target 不足→開「補力」need；can_reach 擋敵盟→欺敵孤兒→**不開不假塞**）→`_match_fillers`（補力←結盟(外交 ally,義氣) vs 徵收(fund_war,貪婪) util 比較選）→`_emit_goal`（每令記 `f.goal_drivers[goal]={intent,why,mode}`=北極星）。小集（意圖4/行動3 真 affordance）+深度1+resource-aware（湊不出力退更小意圖，不發打不贏攻擊令）。掠奪移除（team P1）、war-priority `FACTION_DUTY_DRIVE_LESSER` revert（單意圖後 moot）、緊急徵收=survival override、立國=既有分離 gate。**驗收=可解釋+viability 非跟戰數**（藍圖明令）。**結果**：measure 4/2 無因令→**每令有 driver、無因令=0**（assert）；意圖 argmax 人格/belief/viability 分歧（好戰→征服[攻擊+補力肢]、貪婪→致富、敵強→退守成）；headless cmd 3 測+P2/P3/P4 全綠、coin_eq 0、framework S1-S6 PASS、world_sim 2yr teams=8 穩無意圖反覆。**means-end 真跑非退化**（filler 現算+util 比較證）。**子 session 誠實標**：湧現協同 scheme 只在「力不足但 viable」窗口（力足→單令攻擊、力太低→退守成）=正確 means-end 但 world_sim 該 seed 未捕捉到 viable 窗口（派系少/短命），靠 unit+P3 證；窗口真實頻率待真人玩測。spec/plan `2026-06-28-commander-decision-unify-v2`（v1 單姿態作廢）。**統一決策 arc 兩半（隊+統領）全收編。下一塊=欺敵 sim arc（anchored-pre-player）**。
- **🏛 P4 頂層 stakes options（徵收/外交）✅（merge，他域鏈第五步，承藍圖 ruling P3-A）**：unified 隊全響應派系 stakes（攻擊 P3 + 徵收/外交 P4）。**泛化** P3 `faction_directive`(單攻擊)→`faction_stakes: Array`（`STAKES_SET=[攻擊,徵收,外交]` ∩ f.goals；立國=leader-level `_declare_established` 非 member option、掠奪=日常個體、結盟⊂外交、大徵收=徵收）。加 `徵收`(TASK_TRIBUTE→`_richest_member`，**雙重排除自身** gather+to_task)/`外交`(TASK_DIPLOMACY→`_nearest_independent`) option（mirror 攻擊：`[[faction_duty,faction_duty],[levy_drive/diplo_drive, levy/diplo]]`）；`levy` weight=貪婪/好戰染色、`diplo`=義氣/計謀染色；全 stakes 共用脫軌逃閥 `_duty_factor`。霸主決策步複用 `_update_goals`（既有徵收/外交 gate）。**子 session 抓真 believability bug**（正確停手未硬改）：多 stakes 共存時忠誠溫和 member（好戰0.1）因 `weight(diplo)0.60>weight(attack)0.33`、faction_duty 對兩 option 等值 → 轉外交 skip 戰爭 → 跟戰 **3/4→2/4**，違反藍圖 A 裁定明文「忠誠=連勉強也到場非缺席」「B 鬆協同=戰爭溶回個體 noise」。**war-priority fix**（實作藍圖 A 原則，非新願景決策）：`攻擊`(存亡級戰事)faction_duty drive `FACTION_DUTY_DRIVE 1.5` > `徵收/外交`(次級)`FACTION_DUTY_DRIVE_LESSER 1.0` → 多 stakes 共存戰事優先、跟戰 **3/4 復原**（外交 sole-directive 仍 fire 1.06>daily）。**結果**：headless P3 不回歸（soldier→ATTACK）+ P4 全綠（levier→徵收/envoy→外交/rebel→建設脫軌/染色 ug0.199>um0.067/危時→覓食）、war_scenario 跟戰 3/4、world_sim 2yr teams=8 穩無 over-coordination、coin_eq 0、framework S1-S6 PASS。皆 TEST VALUE。spec/plan `2026-06-27-p4-faction-stakes-options`。**他域鏈 P0-P4 全完成**（P2b-2 全退 entry = polish 債）。**待藍圖**：war-priority（攻擊>徵收/外交）認可否 + FACTION_DUTY_DRIVE 量級（handback `p4-faction-stakes-options-war-priority`）。
- **🍞 買糧求生 option（Phase 1）✅（merge，承藍圖 ruling 2026-06-26 §2 取食對稱）**：measure-first（`buyfood_measure.gd`）證**餓商隊 food_days=0.10+coin=500+鄰市集售糧 → 引擎首選紮營(util1.08)/乞食(0.87)，有錢不買糧**（搶=option[掠奪] 買≠option=不對稱，乞食變成向賣家乞討而非買=荒謬）。修=補 `買糧` engine survival option：`buyfood_drive`=`hunger(DESPERATION_SCALE×(3−food)) × 旅費折扣(BUYFOOD_DIST_FULL 6/max(dist,6))`、weight `buyfood`=商隊 1.0/他隊 0.3（role 權重非 gate，守 tc7）、applicable=food<DESPERATION+有市集+有錢（`has_specie`=coin>0 or goods≥10，無錢=乞食真語意不入）、to_task=最近市集（`_nearest_market_outpost` 複用）→ `TASK_TRADE`（到場 `_resolve_market` 餓隊 food local_value 高→買 food）。入 `SURVIVAL_OPTION_SET` → P2b-1 委派 `rank_survival` **自動全隊化**（軍隊等有錢也買）。**結果**：measure 重現 rank=[買糧,紮營,乞食,建設,survival] **首選買糧**（util 3.48）、headless 全綠、world_sim 2yr 無 mass starvation/seek_market=43、coin_eq 0、framework S1-S6 PASS。**known（Phase 2）**：買糧量級(DESPERATION_SCALE 1.2×)<覓食(survival_pressure 4×)→ 小隊(pop≤15)鄰市集仍覓食非買 = same-frame 量級未統一；撲空（市集無糧）無專屬探針。皆 TEST VALUE。spec/plan `2026-06-26-buyfood-survival-option`。**Phase 2（距離折扣 retrofit 掠奪/返家補給 + same-frame 量級統一）延**（藍圖「同框」完整模型，獨立 slice）。

## 📍 前狀態（2026-06-22）

- **🏛 P0 G1a 礦村（山村特化）✅（merge `61af5c4`）→ 鑄幣脈絡 default 真活**：量測推翻 stale premise（[[feedback_verify_backlog_fresh]]）——非「無金礦 tile / 鑄幣 code 壞」，真根 = **金礦只在山地、山地住不了人(food 再生 0.5)、採礦需在地 → 金礦物理上不可開採**（雞生蛋死鎖）。用戶裁模型 **B 礦村**（蓋在含礦山的不自給 civilian outpost，外部供糧）。最大複用既有（自格採 ore/mint facility/_pick_facility/food 買單/糧倉/subteam 建造）。S1 礦脈保證 guard / S2+ 貪婪 leader 選 **ore-mountain 本身**（非鄰接平原，threshold gate 保稀有=非貪婪不建）/ S3 bootstrap 攜糧+market food buy / 施工子隊韌性（survival/betrayal/tribute/encirclement/discipline/tag-shift 豁免，皆 10 日 CONSTRUCT timeout 或 build 完成或滅團兜底，**只豁免行為不碰死亡/守恆**）。**結果**：default.json r8 自然 fire 4/5 run（mine_founded>0、mint>0、coin 增）、world_sim 1/1、真鏈端到端證（ground ore→vault→mint→coin，無 pre-seed）、coin_eq 0、InvariantAudit 0、framework S1-S6 PASS DORMANT=0。3 輪 review（含 opus 終審 APPROVE）抓並修：far-construction 雙計(LOD 前提錯→刪)、distance 免疫過廣、zombie latch、facility_deficit 洩漏、測試 pre-seed。spec/plan `2026-06-23-g1a-mint-mining-village`。**backlog（known_issues）**：mint coin-cap 燒 ore off-ledger(pre-existing,G1a 首 fire 才浮現)、非貪婪 leader 在無平原時仍可建礦村(稀有邊際)、dense map distance 免疫未測。
- **🏛 P1 個體域 掠奪 option ✅（merge，承他域 ruling #1 日常 op=個體人格）**：unified 隊（merchant/produce）加人格加權 `掠奪` engine option——殘忍×0.5+好戰×0.3+貪婪×0.2 weight、`loot_drive` base 1.0（has_weak_prey 時）→ loot util ≤~0.8（危時 survival_pressure ≥2 仍碾壓=餓隊先求生非日常打劫）；複用 `_find_weakest_prey`(belief-read)+TASK_LOOT+既有 loot/extort interaction（小徵收隨 loot 來，不另做 option）。`_decide_unified` 加 combat_target wire（`td.has("combat_target")` 守衛=既有 option 零影響）。**scope 嚴**（防 P0 sprawl）：只 掠奪、non-unified 零碰、無新 TASK_*、無 exemption 鏈。**偵查延 backlog**（下游消費存疑=避 dormant code）。headless 全綠（人格分歧+餓隊不日常掠奪驗）、coin_eq 0、framework S1-S6 PASS。**注**：world_sim 該 run unified 隊沒 fire loot（RNG 沒生殘忍商隊 leader）=機制 headless 證、rare tail + P2 loot 遷移基建，非 dormant。spec/plan `2026-06-23-p1-individual-options`。**解鎖 P2 loot option**。
- **🏛 他域遷入 ruling 到 + HOW 序定（P0/P1 完成，P2-P5 待）**：藍圖裁 `otherdomain-ruling`（consumed）解鎖全卡項。**協調=混合**（stakes-to-faction→頂層協同 faction_duty 壓人格；team 日常 op→個體人格）；**believability 守則**（頂層決 WHETHER 人格染 HOW + 脫軌逃閥非 100% 服從）；**主動開戰=稀有+蓄意+吃 belief**（霸主決策、readiness 門檻）；**mint 現在排 G1a**（覆前判緩做）。**HOW 序**（小切片先、dependency-correct，每 Phase spec→plan→worktree→跑驗證套件 TC+S 魂）：
  - **P0 G1a mint ✅ done**（merge `61af5c4`，見上條）：礦村模型 B，default 自然 fire 4/5。
  - **P1 個體域 options ✅ done**（merge，見上條）：掠奪 option（scout 延 backlog）。解鎖 loot。
  - **P2 survival 全隊退役 + loot/join 還經濟隊**（依 P1 loot）：退役舊 `_evaluate_survival` 雙 owner、loot/join/camp/beg/hunt 遷引擎+全隊化。閉框架完成塊③ + 經濟↔衝突橋（藍圖標記1債）。**切兩片**：
    - **P2a 絕境 option ✅ done**（merge，承標記1 join 債）：unified 隊（merchant/produce）加 `投靠`/`紮營`/`乞食` engine option，補齊 survival repertoire（loot P1 已做，今補 join/camp/beg；hunt 無 TASK 延 P2b）。drive=desperation magnitude（`DESPERATION_SCALE 1.2 × (DESPERATION_DAYS 3 − food_days)`，吃飽→0=健康隊不選）× weight（join=義氣0.4+信義0.3+求生欲0.3、camp=野心0.4+統領0.3+求生欲0.3、beg=求生欲×`BEG_FLOOR_FACTOR 0.5` 墊底，複用 `_join_pref`/`_camp_pref`）。applicable food_days<DESPERATION gate（健康隊不入榜=TC1/4/6/7 零影響）。複用既有 finder（`_find_strong_neighbor`/`_find_unowned_farmable_tile`/`_find_aid_target`）+ 既有 TASK_JOIN/CAMP/BEG。**2 seam wrinkle**：W1 camp-arrival 立營 hoist 到 unified gate 前（否則 unified 隊走到 camp tile 永不立營）；W2 `_decide_unified` player-join guard（投靠玩家→forced_event 非自動 merge，且 interaction layer 155-188 雙保險不 auto-merge 進玩家）。**non-unified 路徑零碰、不退役雙 owner（P2b）、不動 ~20 test 直呼點**。結果：headless 5 新測 PASS、world_sim 2yr 存活穩 7（`CrudeCamp`×3/`SurvivalJoin`×1=**標記1 join 債閉**/絕境轉移×2，無 over-camp）、coin_eq 0（4 config）、InvariantViolation 0、framework S1-S6 PASS。皆 TEST VALUE。spec/plan `2026-06-23-p2a-survival-options`。**解鎖 P2b**。
    - **P2b survival 全隊退役**（切兩片）：
      - **P2b-1 survival 選擇統一 ✅ done**（merge，消 survival 動作選擇雙 owner）：non-unified `_trigger_survival` 動作選擇改委派 `DecisionEngine.rank_survival`（survival 子集 = `返家補給`/`覓食`/`掠奪`/`投靠`/`紮營`/`乞食`，applicable 過濾、不寫 current_option、承諾比對 current_task）。**刪**手寫 `desperation×values` branch + `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` const + `_loot_pref`/`_join_pref`/`_camp_pref` helper（公式併入 `DecisionTerms.weight` 單一 owner）。**`返家補給` generalize**：任何有家隊絕境（food<DESPERATION 3）→返家（非僅商隊 proactive food<5），保熱路徑。`覓食` viable-pop 守衛移入 applicable（pop≤15）。保 `_evaluate_survival` gate + `_trigger_survival` entry + `PRIO_SURVIVAL` + hunt fallback + player-join guard（同 P2a W2）。**measure-first 修正前提**（[[feedback_verify_backlog_fresh]]）：spec 稱 1037 `[Survival]` 多為 return_home **不準**——baseline 即 **idle-release churn 主導**（927/1032=攻擊隊輕飢→survival 無可派→release→idle→再攻，**pre-existing**，927→932 本塊未引入）；返家機制由單元測 deterministic 證。**已知行為變**（spec 明列可接受）：①遠家殘忍隊「就近掠」距離 nuance 丟失（restock_need 非距離感知→返家；loot 稀有，backlog「restock_need 距離衰減」）②severity gate 簡化（靠 drive 量級，warning「不放棄當前 task」nuance 移除，實測 churn 未增）③unified produce 隊絕境也得返家補給候選 + unified 大軍（pop>15）絕境無覓食候選（generalize/pop 守衛副作用，believability 改善/可接受）。調 4 處既有直呼點 assertion（同義：pref→weight、契約變：非商隊絕境返家；退化：Task5 LOOT→RETURN_HOME 已知）。結果：headless 全綠、world_sim 2yr 無 mass starvation（存活 6→5 噪內）、loot dest=0（無 over-loot）、coin_eq 0、framework S1-S6 PASS。spec/plan `2026-06-25-p2b1-survival-selection-unify`。**解鎖 P2b-2**。
      - **P2b-2 全退 entry（待，耦合 P3/P4）**：全退 `_evaluate_survival`/`_trigger_survival` entry（non-unified survival 整路由 engine entry）需軍隊 attack/threat/vendetta 入 engine = P3/P4 後。`_evaluate_solo` survival scoring（camp/join 手寫）仍雙 owner，並此塊或獨立清。
  - **P3 混合協調 seam ✅ done**（merge，他域鏈第四步）：unified 隊（merchant/produce）經引擎響應派系 stakes directive。**探碼揭縫**：`_decide_unified` 完全忽略 faction goals；non-unified 已響應（802-827）；霸主決策步**已存在**（`_update_goals:687-705` 攻擊 gate=野心/好戰/readiness/belief-strength=稀有蓄意吃 belief，守 ruling §3）。**做**：`DecisionContext` 加 faction directive/target/loyalty 欄（gather 讀 `f.goals` 攻擊 + `_nearest_independent` + loyalty 注入 `leader_values["_loyalty"]`）；`faction_duty` term（WHETHER）+ `attack_drive` term（HOW 染色）+ **共用脫軌逃閥因子 `_duty_factor=clampf(loy−max(0,野心−0.5)×DEFECT_K,0,1)`**（faction_duty weight 與 attack_drive 齊受 loyalty 調=低忠誠高野心 member 兩驅力齊壓 0=「這不是我的仗」）；啟用 `攻擊` engine option（REGISTRY `[[faction_duty,faction_duty],[attack_drive,attack]]`、applicable=directive=攻擊+有 target、to_task=TASK_ATTACK+combat_target）。**believability 2 不變量寫 invariants.md**（混合協調段）：①頂層決 WHETHER/人格染 HOW（攻擊 util=`duty_factor×(FACTION_DUTY_DRIVE+attack_weight×ATTACK_DRIVE_BASE)`，同忠誠下好戰>溫和）②脫軌逃閥（faction_duty=加權 term 非 hard override，by construction 非 100% 服從）+ 日常個體（貿易/掠奪/scout/survival 無 faction_duty）+ 危時 survival 碾壓。**非 dormant**：`攻擊` directive 既有 producer（`_update_goals`）+ non-unified 已示範消費。**偏離 plan**（認可）：`attack_drive` 亦乘 `_duty_factor`（plan 寫 flat 0.3 會讓 rebel 仍攻擊=逃閥失效）。**scope 緊**：只 `攻擊`（徵收/外交/立國/結盟/大徵收=後續 slice）、不碰 non-unified、不改霸主決策、無新脫軌機制、TC3 未接（feud 仍走 vendetta PRIO_VENDETTA 獨立路徑）。結果：headless 3 測 PASS（faction_duty loyal=0.90/rebel=0.00、soldier→ATTACK/rebel→建設/peace→建設、好戰染色 u_f=0.314>u_m=0.103/餓→覓食）、coin_eq 0、framework S1-S6 PASS。**⚠ world_sim 該 run 無派系觸發攻擊 directive**（僅 1 faction 商業 archetype 未達 gate）→ **協同戰 feel 改由構造場景驗（藍圖 ruling 2026-06-26 §3「要」）**：`scripts/debug/p3_war_scenario.gd`（好戰霸主派系 A 多 persona member + 和平商業 B + 弱敵）量測，**4 條 ruling feel 全綠**——跟戰 3/4（忠誠者跟、叛逆脫軌）、人格染色（忠誠好戰 util 1.70 > 忠誠溫和 1.44）、不 over-war（全世界僅 3 隊出兵=派系 A 成員，B 不被拖入）、脫軌叛離真發生（低忠0.15+高野0.9→不參戰）。**setup 教訓**：攻擊 directive 需 leader 過 strength gate（`own_armed≥敵 armed_est×0.8`）→ leader 須設 `armed_anon_ratio`（weapon 在 resources 沒裝備到人時 own_armed≈0）。**待藍圖**：faction_duty 偏強協同（忠誠溫和也跟，util 1.44）→ 強協同(A)/鬆協同(B) feel 方向，調 `FACTION_DUTY_DRIVE`（handback `p3-war-feel-report`）。皆 TEST VALUE。spec/plan `2026-06-25-p3-hybrid-coordination`。**解鎖 P4 stakes options**。
  - **P4 頂層 stakes options**（架 P3 上）：主動開戰攻擊（稀有+蓄意+吃belief+readiness gate）→結盟/外交→立國深做→大徵收動員。**解鎖 TC3 + 誘殺閉環**。
  - **P5 戰俘**（耦合 combat-unification E-2 撤退門檻/意志，跨 arc）。
  - standing flag（非阻塞）：履約脫 0 unseeded → 經濟底 🟡，待 seeded harness 確認穩定成交。
- **🏛 框架驗證套件實作完成（B，merge `1a5eee3`）**：Part1 TC2(survival=高權重輸入非latch)/TC5(經濟+情報為輸入) headless 行為測過（TC1/4/6/7 早過；**TC3 feud→脫軌攻擊需引擎攻擊 option=他域 skip**）。Part2 `scripts/debug/framework_validation.gd` harness — S1立國/S2feud+vendetta/S3scout/S4ambush/S5mint/S6經濟閉環 **全 PASS（證 6 魂可 fire）**。default world_sim fire:faction_found/feud/order_fulfilled；vendetta/scout/mint/ambush default 休眠（harness 證可觸發,記 known_issues backlog）。**S5 mint 揭真 gap**：碼可運作(harness mint=1)但 default 無金礦 tile + 無 AI 建鑄幣廠路徑=供給斷（G1a mint arc）。回歸全綠。
- **🏛 Pattern B 所有權 banker 全 5 池完成（autonomous goal-run）**：state-fight-scope Pattern B（一值多寫、delta vs 絕對 set 無銀行）全收編——各池單一 owner banker + 禁裸寫(grep 驗) + coin_eq/InvariantAudit 守恆閘：① **UnrestBank**(`3a883a6`,unrest_turns 14 寫)② **LoyaltyBank**(`6bfc719`,loyalty 25 寫,cap 參數保 clamp)③ **AnonTreasuryBank**(`05ba648`,anon_treasury 24 寫,原子 transfer 守恆;揭既有 off-map leak 記 known_issues)④ **OutpostOwnerBank**(`7631aa3`,outpost_owner 16 寫,集中化保 last-writer-wins)⑤ **ResourceBank**(`3a72fc9`,team.resources 124 寫/21 檔,簡 wrapper 保原數學=守恆 by construction)。各跑 2yr world_sim invariants=0。**Pattern B 完成 = 框架債「所有權圖縫」收編**。refinement：outpost race-policy/pending_owner_change_tick 退役、coin_eq 註冊進 InvariantAudit、transfer 原子抽象（非守恆必需）。
- **🏛 框架 arc 後續 goal-run（autonomous，照藍圖）**：① **gate→權重**（merge `b15297a`）貿易去 is_merchant 硬 gate+economic_opp 角色因子 0.3=清藍圖 gate 債第一條（生產隊能 roam-trade 但很少）。② **food 買單側**（merge `a4c4cf8`）缺糧隊發 food buy=食物雙向市集（補 WS-1 只賣）。③ **性別資料+生育需兩性**（merge `e3828d4`）PersonData.sex+anon_female_ratio+balance gate=全男隊內部不繁衍 emergent（④Trait 前置）。各跑 2yr world_sim+回歸全綠+coin_eq/InvariantAudit 0。**⏸ 他域遷入（攻擊/掠奪/徵收/結盟/立國/scout/誘殺/鑄幣）= 未決**：撞協調語意 WHAT（faction-goal 頂層 vs 個體人格驅動 + 主動開戰 feel）→ handback 藍圖求裁（`otherdomain-coordination`），暫緩。**耦合他域待 ruling**：戰俘（capture 需 combat）、survival 全隊退役+loot/join 還經濟隊、驗證套件 TC2/3/5+S 魂場景（隨域驗）。

- **🏛 統一決策框架 arc — 統一隊 survival 切片 ✅（merge `b57c79c`）→ 履約首次脫 0**：survival 遷引擎第一切片。真根（measure-first 三次剝洋蔥，含我兩次估算錯=carry-cap 漏 food weight 0.1 / restock util 沒實算→作廢一 spec、見 `[[feedback_avoid_rabbithole]]`）= 引擎 utility-survival **無牙**（survival_pressure cap 1.5 < 貪婪 trade ~1.8），逼停貿易的是引擎外 785 latch；商隊離家無糧源 drift 餓死。修：survival-class term **量級重標度**（food≥3→0、food<3→`4×(3−food)` 碾壓 trade；restock_need `1.5×(5−food)`）+ survival 威脅化（threat_pressure，hunger 走覓食/返家補給）+ 覓食接真格 + **切片邊界**（unified 隊跳舊 `_evaluate_survival`、`uses_unified` hoist 到 member/solo 的 IDLE/survival gate 前 = 退 785 latch；非 unified 隊舊 survival 原樣零改）+ 返家補給 option 地基（先前 merge `c97fc5b`）。**藍圖裁定:角色=權重輸入非硬 gate**（撤回 gate 設計、TC7 原樣）。**結果**：world_sim `order_fulfilled 0→5`、`restock_chosen 0→131`、`[Market]成交` 常態、TC1/4/6/7 原樣、coin_eq/InvariantAudit 0。**believability 缺口已修（dispatch-fallback，merge `1181b67`）**：`DecisionEngine.rank`(util 降序+index tiebreak=decide 行為不變) + `_decide_unified` 退次佳「可派」option（覓食無格→退返家補給/建設→不凍）。T1 無家隊修前 d30 凍死→修後動作存活 90d+（藍圖標記 2 達標：無凍死 believable 退化）。spec/plan `2026-06-22-dispatch-fallback`。**⚠ order_fulfilled 為 unseeded world_sim 變異**（某 run 0 某 run 5，[[reference_multi_sanity_unseeded]]）→ 機制運作（restock_chosen 維持/engine_survival 降）為準、別當絕對閾。**債**（藍圖標記，框架完成塊清）：loot/join 必還經濟隊、is_merchant 硬 gate→權重、舊 survival 全隊退役。spec/plan `2026-06-22-unified-survival-slice`。
- **🏛 統一決策框架 arc — sub-project A 經濟生產隊納引擎 ✅（merge `e6433e9`，foundational 第二塊）**：商隊已接（sub-proj1），本塊把經濟生產/定居域也接同一 `DecisionEngine`（閉經濟環另一端）。三改：①`uses_unified` 加 `TAG_PRODUCE`（生產隊 member+solo 兩 gate 都導向 `_decide_unified`，舊生產者短路=單一 owner）②`applicable()` 角色守衛——貿易加 `and ctx.is_merchant`（roam-trade 限商隊角色，生產隊原地掛單賣不漂）③建設改恆候選（bootstrap 無據點建新+升級，無據點生產隊不被困）。新 context 欄位 `is_merchant`。**判別子用角色 tag 非據點**（商隊也可能有 outpost，`not has_own_outpost` 會誤殺商隊貿易爆 TC1/TC7）。下單不動（`tick_team_orders` 自動 cadence，獨立決策切片）。**驗收**：TC1(changes=0)/TC4/TC6/TC7(建設/貿易/駐守 3 分歧) 全過、role applicable + unified seam OK、headless 全綠、coin_eq=0、InvariantAudit 0（只改決策面）。**履約未 robust 脫 0**：measure-first 證生產側 plumbing 對（生產隊 d60 起原地駐守 `task=生產` 不漂、糧倉 vault food≈1996 可掛單、`order_placed≈3300`/`board_register≈3057`），但**卡商隊 survival latch**（`merchant_survival≈164`、商隊幾乎不出門 seek_market→不 co-located→`order_fulfilled`=0~1 flaky）= 既有 WS-2b 探針標記的真壓制因（faction_ai:786-789，handback #6 §2），出本塊範疇。spec/plan `2026-06-21-economy-settle-unified*`。**系統決策**：商隊 survival 參數修列 sub-project B 首序（履約真脫 0 前置）；生產 task owner 引擎 vs AmbitionLadder rung-task 重疊待統一傘收編。TEST VALUE 沿用。
- **🏛 統一決策框架 arc — sub-project 1 決策引擎+商隊切片 ✅（merge `9c66a7e`，foundational 第一塊）**：經濟死真根 = AI 決策框架不統一（6 子系統各自 latch task 互搏，無一隊一連貫決策）。建 `DecisionEngine`（utility weigh：Σ 人格權重×驅力 term + 承諾慣性，argmax，單一生產者）+ 商隊-tag 切片（`uses_unified` seam，舊 faction_ai member hoist/solo 生產者跳過）。新 `scripts/simulation/decision/`（decision_engine/decision_context/options/terms）。term 複用既有（effective_food/best_arbitrage/team_strength/feud/_merchant_trade_target）= 非重寫。**驗收全過**：TC1 震盪消失（商隊承諾 25+天零震盪、`[unified]` 單一 owner、THE bug 死）、TC4 野心有牙（野心高→建設/低→駐守）、TC6 權衡、**TC7 分歧硬 bar 過（霸主→建設/商人→貿易/隱士→駐守，人格分歧 by construction）**。headless 全綠、coin_eq=0、InvariantAudit 0（只改決策面、不碰守恆）。**履約仍 0=正確**（兩商隊定居人格→引擎讓人格贏 tag→選治理/駐守，正是修 tag-vs-人格本意；S6 履約脫 0 需擴定居隊=後續子專案）。w_term retune（ambition floor 去除防抹平、ambition_drive 放生產/建設非貿易）= 分歧核心。spec/plan `2026-06-21-unified-decision-engine*`。**後續**：Pattern B 所有權 banker、他域遷入(戰鬥/外交/立國/scout/鑄幣=各加 Option row)、S6 擴定居隊。TEST VALUE：COMMITMENT_BONUS=0.3/w_term 映射。
- **經濟 arc WS-2c food accessor 單源 ✅（merge `bb63f18`）**：破商隊 survival 二階死鎖。根因 = WS-1 把定居隊 food 搬糧倉只改消耗（resolve_consumption 讀合併池）、**漏改 10+ AI 決策讀者**（仍讀 team.resources food=0 → 定居/商隊自以為餓 → 永卡 survival/return_home → 永不貿易）。修：`ResourceSystem.effective_food(state,team)` static accessor（team food + 自家糧倉，複用 `own_granary_tile`），路由 10 決策讀者（survival:2070/solo FLEE gate:1001/急徵稅/復工/hungry/ambition…）。純讀取改、**不碰守恆**。headless 全綠（4 新測 + 既有飢荒鏈 OK）、coin_eq=0、InvariantAudit 0。**world_sim 重大進展**：`merchant_survival` 18837→~0、`market_arrive` 0→100-250（商隊終於出門到市集）、世界穩 6 隊無過餓。**但履約仍 0%**——下一層 `board_read≈0`（站上市集讀不到別隊單，見 known_issues）。框架教訓 [[project_framework_seams]]：搬資源位置=所有讀者跟著走。plan `economy-ws2c-food-accessor`。
- **經濟 arc WS-2b 市集訂單可見性 ✅（merge `2ee85bb`）**：破訂單可見性死鎖（WS-1/2/3 merge 後 world_sim 量測仍 0% 的真 root——訂單只在發起隊 team_known、跨隊只靠碰面傳播、商隊只在有 arb 才出門→死鎖）。修：`tile.market_orders` 看板（訂單登錄 outpost tile）+ `read_market_board` 抵達親讀（firsthand honest，`outpost_level>0` 守衛=無在場讀不到，**守 G3 傳播原則**：轉述他隊仍走既有 propagate 失真零改）+ `sim_runner._step3c` arrival 讀步 + 商隊無 arb 巡最近市集 `_nearest_market_outpost`（破死鎖=有理由出門）。`_sync_board` 保看板與 active_orders 一致（無幽靈單）。純資訊+派工，**不碰守恆**。headless 全綠（market board register/read/seek market/trade chain OK fulfilled=1）、coin_eq=0、InvariantAudit 0。**機制確定性測通，但 world_sim 仍 0%**——卡上游商隊 chronic survival（market_arrive=0/merchant_survival=18837，疑二階死鎖），= 下一個 measure-first WS（見 known_issues）。留 4 探針驗收。**教訓**：WS-2 的「[Market]5→8」是 game_sim_test 量的（隊密集碰面遮蔽 bug）→ 經濟驗收必走 world_sim。plan `economy-ws2b-market-visibility`。
- **經濟 arc WS-3 carry cap 硬+馬車 ✅（merge `17940d0`）**：carry cap 從「只軟速度懲罰」→ 硬上限（intake 受限）。`movement_system` 新 `remaining_carry_space`/`carry_space_for_res`；enforce 兩處 intake：①`interaction._attempt_trade_direction` 買方進貨 qty 受 carry 空間限（+coin 取 min）②`resource_system._collect_from_tile` else 分支（移動無 outpost 隊）gain 受 carry 限、超額留 tile。`get_carry_capacity`（含馬車/獸 BONUS）從裝飾→load-bearing。**intake-cap at source = 守恆安全**（貨留 tile/seller、零 drop/零 coin 觸碰）。headless 全綠（carry cap trade/forage/throughput OK + 既有覓食/絕境/飢荒/trade 全綠=無凍結）、coin_eq=0、InvariantAudit 0。**throughput 證**：確定性測 無車進貨=50→2 馬車=130（馬車 load-bearing 確認）；world_sim 移動隊不再無限囤、無凍結。**systems ack 偏離**：`coin` 改 weightless（`_resource_weight: coin→0.0`）——coin 原 default weight 1.0 → 富買方 carry_space=0 → 買不了 → **凍結貿易**（反 WS-3 意圖），coin 非貨物 → weightless 正確且回歸必需（連帶移除「囤 coin 拖慢移動」artifact，回歸全綠）。spec `economy-marketplace-caps-design`(WS-3)、plan `economy-ws3-carry-cap`。TEST VALUE：BASE_CARRY=10/MOUNT_BONUS=15/WAGON_BONUS=40（沿用）。
- **經濟 arc WS-1 食物糧倉+硬上限 ✅（merge `cde372c`）**：殺食物幽靈囤（`resource_system:213` uncapped）。三修：①`_collect_from_tile` food route 進 outpost public_storage capped（像礦，over-cap drop=food sink）+ `outpost_system` food 專屬 cap array（staple 放大 civilian [2000/6000/18000]）②`resolve_consumption` 從「team.resources+自家糧倉」合併池吃（food 在哪都不餓死）③food 加入 `_ORDER_ELIGIBLE_RES` + `tick_team_orders` 糧倉滿(>cap×FOOD_SELL_RESERVE_RATIO 0.5)發 food sell 單（鐵則：cap 改變決策=滿了賣 fire）。純 food sink，**不碰 coin**（CoinAudit delta=0）。headless 全綠（food granary cap/consume from granary/food surplus sell OK + **既有飢荒測試全綠=無誤餓**）、coin_eq=0、InvariantAudit 0。world_sim：囤糧崩（4-5萬幽靈囤→food 全在糧倉 capped≤18000）、food sell 單 fire（227 筆）、無過餓（FoodLedger income==burn）。**⚠ 食物稅語意變更（systems ack）**：food 進糧倉後不走一般稅 private/public split（=整批入自家村庫，等義 `_apply_normal_tax` 原註「採集者即 owner→自己存自己村」）；implementer 改 4 既有稅測 fixture（split 機制覆蓋移到 material，**未放寬斷言**）。**UI 後續**：定居隊 team.resources food 現=0（在糧倉），面板讀 team food 會誤判「沒糧」→ 顯示層需讀合併池（記 known_issues）。food **買**單側未做（只 sell；飢荒隊買 food 待後補）。spec `economy-marketplace-caps-design`(WS-1)、plan `economy-ws1-granary`。
- **經濟 arc WS-2 市集+角色卡死 ✅（主角，merge `81bd56b`）**：藍圖裁定 B 市集後首個落地——讓 NPC 貿易決策真 fire。三病三修：①`order_system.post_order` 會合 pos route 到下單隊最近自家 outpost 市集（`_market_pos`，固定點，解 co-location，非隨隊移動舊 snapshot）②`faction_ai._assign_member_tasks` 商隊-tag member 有真 arb 單時 hoist 貿易（搶在徵收/外交 preempt 前）③`_evaluate_solo` 商隊-tag TASK_TRADE 加 `MERCHANT_TRADE_BONUS`（勝 CAMP/尋家，FLEE 生存仍優先=絕境不貿易）。**僅商隊 tag**（軍隊/生產/定居派工不變）。純決策/派工/order pos，**不碰 resources/coin**（成交走既有 `_resolve_market` 守恆）。headless 全綠（market routing/merchant dispatch/trade chain end-to-end OK）、coin_eq=0、InvariantAudit 0。**證主角通**：world_sim `[Market]成交` 2 年 5 次→8、履約率 0%→1.5%、商隊確被派貿易、無 over-trade（趨勢煙霧，world_sim 非確定）。履約絕對值受 throughput 限（一次搬多少=WS-3 carry cap）。spec `economy-marketplace-caps-design`、plan `economy-ws2-marketplace`。TEST VALUE：MERCHANT_TRADE_BONUS=0.5/hoist 門檻。
- **#1 經濟閉環 plan-1 訂單履約 ✅（merge `186e433`）**：訂單流接最後一步——`interaction._resolve_market` 交易後 `OrderSystem.settle_orders` 按交易窗（absorb/spillback 間，team.resources=完整持有）內 res 淨變沖 `active_orders.qty_remaining`、填滿移除 + 點亮 `g1.order_fulfilled`/`g1.arb_hit`（Probe 早有這倆死指標於 ProbeSummary 履約率/命中率公式，本 plan 補 bump）。**純記帳**：零 resources/coin 變動 → coin_eq/InvariantAudit 守恆無關（回歸 0 為形式確認）。不新建 order-directed 交易（估值交易負責搬貨，結算只認帳；供需不 align→撲空留單=emergent）。單測證機制正確（履約/部分/撲空/sell 對稱）。headless 全綠（`order fulfillment OK`）、coin_eq=0、InvariantAudit 0。spec/plan `2026-06-20-order-fulfillment*`。**⚠ 上游發現（見 known_issues）：world_sim 該 run `arb_attempt=0`、`[Market] 成交=0` → 商隊 runtime 根本沒交易 → 履約率仍 0%（非結算 bug，settle 單測正確）。order/trade 迴路 runtime 半 inert，需 measure-first 查根因（商隊沒成形/message 沒到/range 外）。** plan-2 腐壞/儲限 spec ready（未派，待藍圖 feel + 此上游釐清）。
- **A 類 feud 放寬 ✅（merge）**：血仇由「被侵害」本身形成（非只倖存被搶）+ 滅族 faction 餘部繼承 + severity×個性 gate。集中 `NpcAiSystem.form_feud`（唯一形成點：`severity × (FEUD_BASE + 義氣×0.7 + 好戰×0.4)`，`FEUD_MIN=0.30` gate 擋例行劫掠/寬厚放下/公平交手）+ `spread_feud`（同 faction 餘部 ×0.6，事件當下 erase 前傳；**非血親**=待 ④Trait/家族樹）。現有 3 觸發（looted/extorted/betrayal）改走 gate（Probe.bump 移進 form_feud 不雙計）+ 新增 subjugate 觸發 + 屠村/戰敗滅團 call site（subjugate spread 必在 `set_team_faction` 前）。`_activate_goal` 轉 static。複用 RelationGraph feud 邊，零新資料結構、不碰守恆。headless 全綠（`feud gate OK`/`feud spread OK 餘部 0.64`/`massacre wiring OK`、既有 `_test_g2a_memory_writes_edges` 受害者義氣 0.9 跨閾對齊未放寬 gate）、coin_eq=0、InvariantAudit 0。**⚠ world_sim 重量驗不到 feud — seed 77 該 run 零戰鬥**（非 gate 太嚴，無侵害事件可觸發；world_sim 非確定性，他 run 有戰鬥）→ feud emergent 量遞延 #1（經濟壓力→搶資源→更多侵害）+ scout/ambush 場景。TEST VALUE 暫不調（無有效重量數據）。spec/plan `2026-06-20-feud-broadening*`。
- **#0b 升 named 忠於來源 tier ✅（merge `c596258`）**：補 #0 戲劇尾巴的晉升稀釋缺口。`generate_for_team` 原呼 `generate()` 不看 tier + `kill_random` 按 count 抽（平民最多）→ 菁英 anon 升 named = 隨機低技能、老兵本事蒸發。改：`kill_random(team,1,"promote",PROMOTE_TIER_WEIGHT)`（偏高 tier=提拔精銳）用回傳取來源 tier → `_apply_promotion_skills` 依 tier 設戰鬥/戰術/統領帶（`maxf` 不蓋 archetype 尾巴；seeded rng）。複用 AnonTierSystem 零改、簽名不變、不碰守恆。headless 全綠（`tier fidelity OK 菁英戰鬥=0.76/平民=0.18`、Task7 平民升 coin share 不變）、coin_eq=0、InvariantAudit 0。非戰鬥技能刻意不動。TEST VALUE：PROMOTE_TIER_WEIGHT/SKILLS 帶值。spec/plan `2026-06-20-promote-tier-fidelity*`。**⚠ 量測發現見 known_issues：world_sim 非確定性（ProbeSummary 不可作回歸/歸因閘）**。**#0 全收（#0 尾巴 + #0b 晉升忠 tier）**。
- **#0 world-gen 戲劇尾巴 ✅**：generate 窄帶凡人 + per-person archetype 狂人簇（霸主/屠夫/謀士/懦夫）+ config 種極端 leader。重量證 root（立國 0→1、識破裁決 0→7，純人格值無場景）。詳 `world-gen-dramatic-tail*`。
- **G3-targeting 攻擊/掠食目標選擇讀 belief ✅ → 誘殺脊椎閉環**：補 G3d-2 揭的漏網——`find_prosperity_prey`/`_find_weakest_prey` 本直讀 prey 真 population/resources（god-view），G3d-1 gate 只調「commit 把握」(uncertainty)、不調「選誰」(value)。本 plan 補 value 面：richness/weakness/pop 一律經 `BeliefSystem.best_estimate`，`has_belief` 守衛無情報不評估（**禁 fallback 回真值**，否則 god-view 回潮）。weakness 吃 `armed_est`（tier2 偽裝低報載體，退 pop_est）、richness 經 `_belief_richness`（tier2 sum/100 → resource_scale 粗估 → 0）。自身真值(`team.population`)照讀、位置 reachability 讀真位（物理 OUT）。**誘殺 emergent**：偽裝/失真 relay → 假弱 belief → 選假弱目標 → 戰鬥按**真**實力結算 → 莽者踢鐵板、慎重者 scout(G3d-2)看穿真強→不選→避誘殺。**至此 G3 誘殺迴路真整條落地**：偽裝/失真(G3c)→選假弱目標(本)→gate 把握(G3d-1)→scout 查證或莽者照衝(G3d-2)→戰鬥按真實力結算。回歸：headless 全綠（prey select belief / survival prey belief OK）、coin_eq=0、InvariantAudit 0、`[ProsperityAttack]`+`[SurvivalLoot]`+`[Scout]` 並見（不凍結）。行為非保留（選擇吃 belief→偽裝/失真改變誰被打）。新測置尾避擾前段 unseeded RNG 序。TEST VALUE：`_belief_richness` 粗細混排、survival food 門檻（belief 無 food_est 不擋）。延 post-measure（同 G3d-2 OUT）：威脅(防禦)uncertainty、team_known claim 化、情報戰 C。
- **G3d-2 scout 主動查證 + uncertainty cred-weighted ✅ → G3 核心迴路落地**：慎重者的**被動按兵**(G3d-1)升級為**主動 scout 查證**——攻擊性 commit gate-fail → dispatch `TASK_SCOUT`(move_target=prey best_estimate 位)；斥候移入視野→vision 寫親見→下 prosperity cadence uncertainty 塌→`release` scout 後 try_set ATTACK（同 PRIO_DISPATCH 須先 release 換手）。前提修：**uncertainty 重定義 = credibility-weighted**（`clamp((1−top_eff_cred)+cred 加權值分歧,0,1)`），親見高 cred 主導→壓謊→scout 可收斂（舊 raw `(max-min)/max` 下親見壓不掉舊假 claim → 永不收斂）。莽者(低慎重)恆過 gate→不 scout→攻假 belief→誘殺（不變）。收斂保證：scout 中允許重評 + `SCOUT_TIMEOUT` 逾時 release（防永 scout 卡死）；prey 親見顯強→find_prosperity_prey 不選→自然放棄（避誘殺）。**至此 G3 核心迴路全鏈落地**：情報不對稱(G3a/b)→可信度/時效(G3c-1)→技能識破/觀察(G3c-2)→決策風險 gate(G3d-1)→查證/誘殺(G3d-2)。回歸：headless 全綠（cred-weighted uncertainty / scout verification / attack gate OK）、coin_eq=0、InvariantAudit 0、1000 Tick、`[Scout]`+`[ProsperityAttack]` 並見（不凍結、scout 收斂非永卡）。行為非保留（uncertainty 公式 + scout 行為）。TEST VALUE：SCOUT_TIMEOUT=TICKS_PER_DAY*3、uncertainty top/spread 權重、（既有 GATE_CONF_LOW/HIGH 沿用）。
  - **延 post-measure（本 plan OUT，待核心迴路量測後評估）**：①**威脅(防禦)uncertainty-gate**（§8，極性與攻擊相反，enrichment）②**team_known 事件謠言 claim 化**（§3「主味」獨立 arc，碰 WHAT → **請藍圖確認延後**：核心隊伍情報迴路先量，event 謠言獨立排）③斥候被抓/被餵假（C 情報戰）。
- **G3d-1 決策讀 uncertainty + 風險 gate ✅**：belief 層（G3b/c）首度有決策後果——攻擊性 commit 從「只讀 best_estimate 單值」→ 讀 (best 值 + uncertainty)，按 `個性慎重 × uncertainty` 風險調節（WHAT §7）。共用 gate `BeliefSystem.confident_enough(state, 觀察者, 目標, 慎重)`：`confidence=1-uncertainty`、`threshold=lerp(GATE_CONF_LOW(0.0),GATE_CONF_HIGH(0.6),慎重)`。插**攻擊性主動 commit**：faction_ai prosperity attack + survival loot(`_find_weakest_prey`)、diplomatic demand_tribute。不確定且慎重→本 tick 不 commit（**被動按兵**，下次 cadence 重評）；莽者門檻低→照衝→**假情報誘殺**（魂訊號首度由決策生）。survival loot gate 失敗 → 落回其他絕境路徑（不凍結）。**不 gate**：威脅(防禦,極性反)、vendetta(私仇 G2d)、結盟/求和。既有無-belief 攻擊測試補親見對齊。headless 全綠（confidence/attack/diplomacy gate OK）、coin_eq=0、InvariantAudit 0、200 Tick sim **仍有攻擊/掠食發生**（gate 不凍結 AI）。行為非保留（攻擊 commit 受 uncertainty 調節）。TEST VALUE：GATE_CONF_LOW=0.0/GATE_CONF_HIGH=0.6。
  - **G3d-2 待**：①scout 主動查證迴路（不確定→dispatch scout→親見壓謊→才動，加速慎重者；裁決級識破觸發查證在此接）②**威脅(防禦)uncertainty-gate**——**告知藍圖**：WHAT §8「威脅」延 G3d-2，因防禦極性與攻擊 commit 相反（不確定威脅→更該警戒/查證，非按兵）→ 與 scout 查證一併設計較一致 ③team_known 事件謠言 claim 化（G3d-2/專案）。
- **G3c-2 技能識破 + 觀察吃技能 ✅**：技能 = 理解力（WHAT §6）。**識破**：收 distorted claim 時 `BeliefSystem.detection_discount(我 max(偵查,計謀), 對方計謀)` 折 stored credibility（信假1.0/生疑0.5/裁決0.2）→ best_estimate cred 排序消費（謊低於誠實/親見）。**非 un-distort**（claim.value 不動，只壓信）→ 高計謀大說謊家騙過低技能、笨拙謊對高技能透明。is_suspicious 由分級寫（降 UI/G3d flag，消 G3b dormant，取代舊 randf 塊）。**觀察吃技能**：`observation_noise(base, skill)` 疊噪——vision pop_est 吃偵查、interaction armed_est 吃戰術 → 低技能親見也誤判，**cred 仍 1.0**（深信的錯值）。兩 helper pure static 進 `BeliefSystem`。headless 全綠（detection/observation OK）、coin_eq=0、InvariantAudit 0、1000 Tick。行為非保留（識破排序 + 觀察噪 = 真行為變）。TEST VALUE：DETECT_SCHEME_GAIN=0.8/SUSPECT_T=0.3/ADJUDICATE_T=0.6/SUSPECT_MULT=0.5/ADJUDICATE_MULT=0.2/OBS_SKILL_NOISE_GAIN=0.5。**G3c 全收（c-1+c-2）→ 魂的「源質+理解力」層完成；缺決策消費（G3d）**。OUT：決策讀 uncertainty + scout 主動查證（G3d；裁決級觸發查證在此接）、team_known 謠言 claim 化（G3d/專案）、戰術識破伏兵（戰鬥域 OUT）。**watch（記 known_issues）**：觀察吃技能 → 親見 truth 可能錯 → reconcile_firsthand 拿錯 truth 比 relayed → 可能誤罰對的 source；balance watch。
- **G3c-1 可信度公式 + 身份信任 + 類型基準 ✅**：claim 可信度 G3b interim flat → 真公式 `effective_credibility = source_credibility(類型基準 CRED_BASE × 身份信任 × 跳數) × 時效衰減`（寫時存 cred、讀時乘 time_decay）。`best_estimate` 改排 effective（新鮮勝陳舊）。source_type 正名真來源類別（親見/隊友/商旅/流民，relay 依 giver；distort 另存 flag）。身份信任 = `TeamData.known_reputations`（team→team 動態，覆寫 HOW spec trust 邊，不開 RelationGraph person 邊）；親見比對 relayed pop_est → `update_reputation(±)`（準升騙降，被動查證，record_claim 單一 choke）。修 G3b relay 雙重 HOP。headless 全綠、coin_eq=0、InvariantAudit 0。行為非保留（best 排序變）。TEST VALUE：CRED_BASE/TRUST_FLOOR=0.5/BELIEF_HOP_DECAY=0.15/CRED_AGE_FULL_DECAY=30天/CRED_TIME_FLOOR=0.2/TRUST_DELTA=0.05/reconcile 門檻。OUT：G3c-2（技能識破/觀察吃技能）、G3d（決策讀 uncertainty + scout 主動查證）、team_known 謠言 claim 化。known_reputations coupling（外交/belief 共用）= interim，量測後評估拆專用 trust。詳見 known_issues G3。
- **G3b multi-claim 儲存 ✅**：`team_intel[obs][tgt]` 單 dict → Array of claim（值/源/時效/可信度/失真，不覆蓋）。寫端（vision/interaction 親見、message 傳播）遷 `BeliefSystem.record_claim`：同源更新、跨源 append、停 confidence-max 覆蓋；`best_estimate` 聚合最高 credibility、`uncertainty` 換 claim 分歧、caps 剪枝。讀端 sim_bridge/inquiry 收尾走 accessor（`known_targets`）。讀容錯舊 Dict。改動全藏 BeliefSystem accessor 後（G3a de-risk）→ 決策讀者零動，但多源時值會變（行為非保留：多源不覆蓋 + 分歧不確定為真 WHAT 變化）。headless 全綠、coin_eq=0、InvariantAudit 0、1000 tick。TEST VALUE：MAX_CLAIMS_PER_TARGET=4 / PER_OBSERVER=200 / uncertainty 欄選 population_est / relay cred interim。下一步 G3c（可信度 trust 公式 + 技能）/ G3d（決策讀 uncertainty + 查證）。詳見 known_issues G3。
- **G1d 商隊訂單驅動 + 短缺買單 ✅（閉環 G1b）**：商業 archetype 隊 targeting 改讀 `team_known` 訂單（`OrderSystem.best_arbitrage_order`，殘缺/可失真情報），取代 `_find_trade_target` 的 `team_discovered` 上帝視角（後者降 fallback，最終應刪，符「目標決策讀殘缺情報」總則）；`tick_team_orders` 短缺發買單（料/武器 < `SHORTAGE_QTY`）→ G1b infra 半 inert 解除（賣盤有 reader、生產買單有來源）。到場履約走既有 interaction 同格 trade（守恆）。撲空 = 訂單 stale → `local_value` glut（emergent 無新機制）。headless 全綠、game_sim_multi 21600 tick 無崩潰、coin_eq=0、InvariantAudit 0。剩 refinement：部分履約記帳、distort×params、信用幣(③G3)、arbitrage 公式調平衡。詳見 known_issues G1。

## 📍 前狀態（2026-06-17）

- **玩家動作 parity 已 merge（`81e245b`）**：QA P5 走查重frame C-1~C-6（NPC task=AI 抽象 ≠ 玩家直接控,真對稱=動作 parity）。新 `_action_train`（一次性 coin 30→`add_exp`+`try_promote`,玩家版比 NPC 完整）+ `_action_camp`（紮營 Y版:免材料/無即時糧只抬cap/距離spacing/限時建造,reuse construction）+ **panic 收口**（reaction 恐慌橋加 `leader_id!=player_id` 守衛,玩家主隊不被劫持移動,其餘恐慌效果保留）+ 玩家隊狀態列「任務:」→「狀態:」。spec `2026-06-16-player-action-parity-design`、plan 同名、handback 同名。功能經 key-injection driver 端到端驗（訓練/招募/紮營）。
- **QA P5 修復已 merge**：B-1 收留撞 pop_cap 守恆（食物按量測 delta 扣、msg 報實際併入,不謊報）+ A-1 記名招募在 TextUI 主場景可達（消費 recruit menu payload）。
- **W4 promote 層1 修（`4d1e540`）**：`training_system` 補 `try_promote` tick caller（原只 add_exp 永不升階,NPC 一旦訓練即升）。層2（NPC AI 鮮少選 TASK_TRAIN）遺留。
- **NPC crude_camp 即時糧移除（`ad67869`）**：A/B 量測非 load-bearing（died=0,pop 不掉）→ 移除即時種子糧(留 cap),恢復絕境稀缺,與玩家紮營版一致。
- **W8 coin 產出鏈休眠（2026-06-17 量測新發現）**：純coin 鑄造Δ=0、ore 挖礦Δ=0 → 金銀礦從沒挖、鑄幣廠從沒用,coin 純零和集中。詳見 known_issues W8 / roadmap。
- **refactor R1-R6 + known_issues 瘦身 479→225**（已修 42 項移 `docs/archive/resolved_issues.md`）。
- **P3 全動作覆蓋確認已達**（50/50 覆蓋審計 + ui_flow 面板測綠）;**Bug2 欠薪後果確認已存在**（reaction N3_defect 離隊鏈,原「未做」=stale）。
- 全測綠、coin_eq delta=0（4 config）。

## 📍 前狀態（2026-06-16）

- **階段2 招人成幫已 merge（2026-06-16）**：投靠（NPC 絕境同格→`join_request` forced event→玩家收留,扣食物 onboarding[一餐×人數,消耗品非守恆] + reuse `merge_teams` 整團併入,守恆）+ 招募（玩家主動→coin 挖角,既有 recruit）。成本**按觸發分流**(投靠=食物/招募=coin)。隊能力讀數 DTO(`capabilities`:按真技能聚合——求生 named 平均→獵率/產出、戰鬥逐個體→戰力 proxy、pop→日耗)+ status 顯示 = emergent legibility。tutorial onboarding(食物盈餘閾值一次性送 1 堪用 named+3 tier0 anon→走真投靠流程)。reuse merge_teams/hunt 公式/forced 路徑/dispatch_subteam(specialist→子隊長),零新系統。headless+ui_flow 全綠、coin_eq 守恆。spec `2026-06-16-stage2-recruitment-design`、plan 同名。
- **養得起/離隊** = reuse 既有 famine/loyalty/defect(不新做);**部署** = emergent 自動貢獻(不做逐人指派 UI,YAGNI)。

## 📍 前狀態（2026-06-14）

**玩家核心迴路定為 Kenshi 型下而上生存**（spec `2026-06-14-stage1-survival-forage-hunt-design`）。階段拆分：1 開局生存 / 2 招人 / 3 據點 / 4 成勢力。

- **階段1 Plan 1（覓食地基）已 merge**（`ff646f6`）：無據點隊覓食食物（FORAGE_RATE/食物only/枯竭/scale鎖）+ NPC survival forage path（pop≤15 門檻防大軍蟑螂）+ 釋放條件 + `survival_start` 開局 config。2 年 multi died=no、coin_eq delta=0、大軍無覓食、小隊 23→41。遺留見 known_issues W7。
- **階段1 Plan 2a（小獵物食物層）已 merge**：wild_game world-gen + 月再生 + `HuntSystem.hunt_small_game`（求生 roll/枯竭/食物）+ NPC 覓食被動小獵 + 玩家 hunt 指令 + `_collect_from_tile` 排除活物。2 年 multi died=no/coin_eq 0/survival_start 23→36。
- **Bug7 已修**（interaction:233 stale-id race，一行守衛；warzone 2 年 OOB 3→0）。
- **階段1 Plan 2b-1（野獸戰鬥核心）已 merge**：爪牙武器 grade + predator_density 生成/再生 + BeastSystem pseudo-team（負 id）+ encounter beast spawn/逃戰行為/爪牙攻擊/得肉清除 + npc_combat beast_strength/reward + 玩家 hunt_beast 指令。reuse 人類戰鬥機制。6 測試綠/2 年 multi died=no/coin_eq 0/無 beast 殘留。
- **階段1 Plan 2b-2（野獸伏擊+偵測）已 merge**：AmbushSystem.detect（偵查/求生 vs 掠食者隱蔽）+ 伏擊編排（玩家→encounter/NPC→npc_combat 遵 Bug9）+ sim_runner 接入 + 獵勝戰鬥 exp + 掠食者 infamy 計數 + NPC 主動獵獸。7 測試綠/2 年 died=no/coin_eq 0/[Ambush]×5。
- **subsistence 改狩獵唯一（Plan 2c）已 merge**：移除被動覓食食物噴泉（量測 income~44>>burn~7、囤 300+天糧）→ 食物唯一來源=狩獵 wild_game。
- **tile_food_init→cap bug 修 + outpost.terrain 釘地形**：村餓死真因（tile_food_init 不設 cap、村在山地）；survival_start 村釘平原 → 23→22 穩。
- **絕境驅動多元生存行為（desperation-survival）已 merge**：`_trigger_survival` 重構 desperation×values（warning 個性門檻 / urgent 解閘人人有活路）+ pref helpers + 紮營（依個性軍/民 + 升 tag 清流亡 = 流浪→定居攀爬）。2 年 multi 行為多元（loot130/camp17/forage14/beg15/join9/hunt6）、survival_start 23→21、coin_eq 0、無誤觸。
- **✅ 階段1（開局生存）整套完成 + 求生行為多元化**：覓食(已退場)→狩獵唯一 + 野獸戰鬥/伏擊 + 絕境多元生存。世界 2 年無崩、守恆 0。
- **NPC 向上攀爬**：吞併→建勢力（npc_combat/interaction）、建造/紮營→定居成生產/軍隊（auto_settle + crude camp）、W4 設施階梯、pop→分裂。流浪→定居這階補齊。

- **SoloAI 主動尋家 + 承諾慣性已 merge**：`_evaluate_solo` 加 紮營/投靠 value 加權（無家團、bypass _tag_weight 避流亡歸零）+ solo_intent 慣性（止 flip-flop）。churn 修（主動 camp 免糧足釋放 + 到達兜底）。2 年×3 roving 主導非 uniform、安身率↑、守恆 0。流浪→定居 bottom-up 進展接上。

- **文字 UI 翻新 P1（API 暴露+邊界）已 merge**：DTO 暴露 stage-1（food_days/starving precarity、wild_game/predator 認知分級、available_actions hunt/hunt_beast Layer6）+ text_ui 唯一洩漏(encounter_active)走 bridge。invariants 加 UI 邊界。spec §4 含全動作覆蓋審計矩陣。
- **文字 UI 翻新 P2（chrome 重整）已 merge**：status 增強(food_days/趨勢/成員健康)+hint 行+feedback 行+LogStrip(panel 共存)。helper 單元測綠;**GUI 視覺已人工 run-verify ✓**(2026-06-14 chrome 四區正常顯示)。玩測順帶抓 pre-existing 遭遇戰/互動 UI bug。
- **遭遇戰/互動 UI bug 批修已 merge**：U10 戰後凍結✅/U11 命中回饋✅/U12 交易誤判✅/U13 卸裝[U]✅/U14 進場數(非bug)/U15 戰後按鍵閃退✅/U16 地圖迷霧 axial 投影(pre-existing 未修,記錄)。headless+ui_logic 全綠;**U10/U11/U12/U13/U15 GUI 待人工 run-verify**。**P3(全動作覆蓋照 §4 矩陣 + 調薪 set_member_salary 指令) 待寫**。

- **UI-flow 測試 harness 已 merge**：headless 實例化 TextUI.tscn + 注入 + 驅動 + 斷言 → 輸入流/選單/內容 class bug 自動回歸（省手動 GUI 驗）。`scripts/debug/ui_flow_test.gd`。
- **B3 玩測 bug 批修已 merge**：attack_select 操作提示 / U14b 自隊武裝數(DTO+status) / U10b 玩家全滅→game-over。配 harness 自動測。
- **B4 成員管理已 merge**：set_member_salary(S9)/set_armed_anon_ratio(U18)/equip_member·unequip_member(U13b) 指令+UI。守恆(裝備扣/還 team 池)。armed_anon_ratio 下游 encounter/npc_combat 有讀=有效。
- **UI 修路線圖（「都做」）全完成**：B3 ✅ → B4 ✅ → **交易 offer-builder ✅** → **P3 全動作覆蓋 ✅（2026-06-15 merge）**。U16 地圖迷霧(axial 投影)真視覺待互動迭代。
- **P3 全動作覆蓋已 merge（2026-06-15）**：6 孤兒動作補玩家 UI 路徑（對稱性閉合）。公庫面板[K](deposit/withdraw+翻頁)、outpost build_facility 設施選單/abandon 二次確認、faction extract_treasury 比例輸入+>0.5 二次確認、互動選單 emit recruit_anon/invite_settle。零新後端邏輯。DTO/emit/守恆/flow 全綠。**L3 後修**：invite_settle 經選單預設 settle_pos=玩家腳下（修死按鈕）。
- **交易 offer-builder 已 merge（2026-06-15）**：`get_trade_session` DTO（雙方清單+估值+公平天平+NPC 接受預估，reuse local_value/evaluate_offer，零新交易邏輯）+ text_ui offer-builder（我給/我要欄+數量+天平+送出+翻頁），取代舊 auto-trade confirm。買/賣/以物易物同介面。DTO/守恆/flow 全綠。
- **P3 全動作覆蓋 spec+plan 已寫（2026-06-15，待子 session）**：審計找 6 孤兒動作（公庫 deposit/withdraw、outpost build_facility/abandon、faction extract_treasury、team-target invite_settle/recruit_anon）。plan 5 task A→D→B→C→E。spec `2026-06-15-p3-action-coverage-design`、plan `2026-06-15-p3-action-coverage`。
- **🗺 路線圖 + 已知問題解方彙整：`docs/roadmap.md`（2026-06-15 建）**。近期=P3→GUI run-verify 債清償（最高槓桿，轉 ui_flow 自動回歸）→U16；中期=tune/階段2 招人/②目標錨；含 Bug2/W4/Bug5/Bug6/Bug8/Bug9/U16 各附建議解 + 工量。圖形 UI 項（U5/U6/U7/S4）moot（TextUI 主用）。
- U11 戰報/U12 交易/U13b 等 GUI 顯示部分：wiring 已接（harness/headless 驗 flow），真視覺待人工偶查。
- **bug 批修 + known_issues 對齊（2026-06-15）**：Bug6(schedule 注入+dispatch)/Bug8(stale test)/Bug9(player_id 守衛)/**Bug10(屠村 _massacre_residents 鑄幣+丟公庫,守恆 +60 → 修,Bug6 連帶撈到)** 全修。Bug2(floor 已修)/Bug5(量測證非缺陷,NPC 勒索休眠→roadmap) 結案。known_issues 全條目對齊現碼（7 項漂移已標正）。
- **行為量測儀器裝好（2026-06-15）**：`game_sim_multi` 加 `[TaskHist]` 月取樣 task team-time 佔比。**量測裁決:世界健康,不需 tune**。tyrant 掠奪 15.6%(劫掠型本該)/逃跑 15.6%/徵收 13.3%/攻擊 11.1%/治理 11.1%；warzone 治理 22.8%/idle 19.6%/紮營 12%/掠奪 5.4%。兩場 coin_eq delta=0。原「loot 偏高 130」= 原始計數假象,佔比正常。SoloAI 投靠低(2.2%)+warzone idle 偏高 = polish 非問題。**measure-first 結論:健康世界不硬調,轉階段2。**

### 佇列（下一步選項）
- ~~狩獵受傷→醫療~~ **已涵蓋**：危險獸走真戰鬥（encounter/npc_combat）→ body_parts 傷 → 戰後 `resolve_negative_flags` 耗 medicine。小獵物抽象 roll 免傷（合理）。無需另做。
1. **UI 接入（player 可玩性）**：stage-1 全機制（覓食/狩獵/hunt 指令/野獸/伏擊/求生）目前**僅 headless 驗,玩家無法經 UI 玩**。原 arc 目標「世界合理→轉玩家迴路」。team0 harness 餓死症結也因玩家無 UI 自驅。
2. **量測 tune 階段1 全 TEST VALUE**：loot 偏高 130 / SoloAI proactive 投靠占比低（0 次,門檻嚴）/ FORAGE/BEAST/AMBUSH 數值。一次一變因（世界已穩,非急）。
3. **②深層目標錨**（待 spec）：接 dormant goal 系統,長弧（盜匪→建國）。先量測承諾慣性夠不夠。
4. 階段2（招人成幫）。

### 殘留 bug / 量測限制
- **team0(玩家隊)在 multi 餓死 = harness 限制**（玩家隊 _evaluate_survival early-return + auto-driver 不代跑玩家生存）非 cascade bug。要量測玩家生存需 NPC-觀測 config 或 auto-driver 補生存代跑。
- Bug8（滅團 food 公庫 baseline）；Bug9（encounter player_id==-1 latent）。
- invariants 新增：對稱性、玩法節奏（decisions-not-chores + 激情時刻）。
- invariants 新增：對稱性（無玩家專屬機制）、玩法節奏（decisions-not-chores + 激情時刻）。

---

## 📍 前狀態（2026-06-13 session 末，重啟交接）

### 本 arc 已 merge（依序）
設施改制 A 期（slot/8設施/軍民/三級成本/守恆審計）→ B 期材料層（herb/馬鏈/選址滾動拓殖）→ 經濟一致性（per-unit 製造 + 全表定價 + 飢荒5x）→ 馬爾薩斯修正（選址diff/復工門檻/COLLECT_RATE 0.01→0.05）→ 飢餓致死鏈（famine_days + hunger→blood + 昏迷 + blood=0死）→ 封建財政公庫（一般稅自動進公庫 + 建造扣公庫 + 特別稅 + 慷慨光譜 + 兩稅不滿）→ W4 caravan-load 派工提領 + leader 治理 → **W5 task latch 大修**（核心）→ W6 死亡資產守恆 → 經濟死水解鎖（自給階梯 + 治理faction leader + 生育分層）

### 🔑 本 session 最大發現：task latch 凍結世界（W5）
TeamTrace 遙測（`scripts/debug/team_trace.gd`，gated game_sim_test 每日 dump）量出 **92% team-time 凍結在不釋放的 survival(p80)/panic(p70)**。世界非窮而是**癱瘓**。修 survival 糧恢復釋放 + 逃跑 timeout + 乞食釋放 + 餓死團清除後，**所有機制自己活起來**：

| 機制 | latch 修前 | 解凍後（2年×4config）|
|---|---|---|
| 戰鬥 Combat Start | ~0 | 13 |
| 貿易 Market 成交 | 0 | 11 |
| 徵稅 / 援助 | 稀有 | 12 / 6 |
| 生育長大成人 | 0 | 39 |
| 設施建造 | 2 | 4 |
| coin_eq 守恆 | — | delta 0.00 ×4 |

**重要結論**：W1/W2「0 combat/0 trade」**不是擦肩會合問題，是 latch 症狀**（速度差本就存在，team 凍住沒去追）。會合機制不用做。

### ✅ 軍閥型 config 已達標（2026-06-13 後續，config-first 解）
前況：tyrant 60→0 全滅、warzone 54→3。**純 config 修**（未動 AI）：
1. 每軍閥 faction 加一座生產村（生產 tag + civilian L1 outpost + tile_food_init 500，複製受壓村模式）→ faction 自給
2. tyrant `敵對暴君` tile_pos (8,5) 出界（hex_dist=5 > radius 4）→ 修 (7,5)。整個 faction 1 原坐空 tile 無法收糧 = 主要崩因（交接舊記「(7,7)」為誤記，真凶 (8,5)）

跑 21600 tick（2.5 年）結果，**達「合理」門檻全部**：

| config | pop | teams | died | 戰鬥(Round) | 貿易(Market) |
|---|---|---|---|---|---|
| tyrant | 88→57 | 5→14 | no | 166 | 59 |
| warzone | 134→128 | 5→28 | no | 33 | 211 |

順帶修 `vision_system.tick_discovery` race：team_ids 快照含本 tick 內滅團 id → `state.teams[tid]` 報 Invalid get index。加 `state.teams.has(tid)` 守衛（[Extinct] 增多才觸發）。修後 SCRIPT ERROR 0。

**結論：世界已合理 → 下一步轉玩家可玩性迴路，勿再追 NPC 完美化。** 殘留 [Survival] 6399 次警告為高頻但非 latch（戰鬥/貿易/製造/分裂全流動，team 數淨增），低優先可後看。

### 🎯 重啟後的決策（已與用戶確認）
- **遊戲類型 = 世界模擬器，合理 NPC+經濟是可玩前提**（不能把玩家迴路硬接在自毀世界上）
- 但「合理」≠「完美 AI」。標準：**2 年無荒謬全滅 + 各 config pop≠0 + 戰鬥/貿易≠0**。達標即收手，**勿掉回 NPC 完美化無底洞**
- ~~下一步：改軍閥 config 給生產基礎 → 跑 2 年 → 資料說話~~ **已完成，世界達標（見下「✅ 軍閥型 config 已達標」）**
- **現在下一步：轉玩家可玩性迴路**（世界已合理，不再追 NPC 完美化）
- 順手（非優先）：`faction_ai_system.gd` 2000+ 行怪獸拆檔（每次都改它，編輯可靠性受損）

### 待修小項
- W4 遊牧軍閥 leader 不駐留（建造仍卡 tyrant/warzone）— 部分修
- Bug2 salary coin 無下限
- config 在 radius 外 spawn team（(7,7) 超 radius 4）隱患
- 全參數 TEST VALUE 待正式平衡

---

## 已完成

### 資料結構層（`scripts/data/`）

| 檔案 | 內容 |
|---|---|
| `person_data.gd` | id, name, role, team_id, age, needs, stress, fear, loyalty, salary, coin, goals, attributes(4：智力/體力/毅力/魅力), skills(14：統領/戰鬥/弓箭/求生/生產/製造/工程/醫療/戰術/計謀/交涉/商業/偵查/潛行), values(8：野心/求生欲/義氣/貪婪/慎重/好戰/殘忍/信義), memory, relations, body_parts(6部位/status), equipment(right_hand槽), get_effective_speed, get_skill_mult, get_attribute_mult |
| `team_data.gd` | team_id, leader_id, named_members（取代 advisors+members）, population, minor_population, resources(19種), move_speed, equip_order, armed_anon_ratio, tags, current_task, unrest_turns, faction_id, tile_pos, move_target, move_tick_acc, combat_target, readiness, wounded, guard_ratio, fatigue, strategic_assignments；TAG_* 常數（7種）；TASK_* 常數；pop_cap_from_leadership |
| `tile_data.gd`（HexTileData） | tile_id, terrain(plains/forest/mountain), resources, productivity, farming_level, harvest_factor, occupied_by, outpost_type/level/owner, manufacturing_level |
| `world_data.gd` | tiles dict, current_tick, current_turn, ticks_per_day(24) |
| `world_state.gd` | world, teams, persons, factions, team_known, team_discovered, team_intel, player_id, player_state, encounter_active/units/attacker_id/defender_id/pursuit_edge_offset, snapshot_faction_member(), create_faction(), disband_faction() |
| `faction_data.gd` | faction_id, faction_name, is_established, leader_team_id, member_team_ids, tribute_rate, goals(string), strategic_goals(dict), strategy, relations, known_member_states |
| `message_data.gd` | id, type, description, source_pos, origin_team_id, origin_tick, strength, is_distorted |

---

### 模擬系統層（`scripts/simulation/`）

| 檔案 | 內容 |
|---|---|
| `sim_runner.gd` | Tick 循環 14 步（含日夜乘數、遭遇戰暫停分支）；LOD：近區每 Tick，遠區每 FAR_ZONE_INTERVAL=10 Tick |
| `resource_system.gd` | 資源收集（outpost → food_gain）；消耗結算（0.1/人/Tick）；needs/stress/fear 更新；tile 再生 |
| `outpost_system.gd` | 據點建立/拆除；civilain/military 兩類；建設 ticks 進度 |
| `harvest_system.gd` | 主動採集：team 到資源格採收 tile.resources |
| `manufacturing_system.gd` | 6 種配方優先序（工藝品 > 高階武器 > 冶煉 > 低階武器 > 一般製造） |
| `reaction_system.gd` | 10 種反應（P1–P5、N1–N5）；skills/values/goals 整合效用函數；每 10 Tick 更新目標 + 呼叫 NpcAiSystem.check_goal_alignment 調整 loyalty；`on_attack_defeat` event（named loyalty / leader stress，依義氣/信義/慎重）|
| `skill_system.gd` | on_reaction / on_combat_round / on_volley / on_combat_end 技能成長；屬性乘數；部位損傷修正 |
| `equipment_system.gd` | 記名 NPC 武器槽分配；armed_anon_ratio 計算；死亡武器歸還 |
| `vision_system.gd` | 迷霧：scout_range（偵查）+ exposure（人口+潛行+地形）；dist_factor 衰減；team_discovered；Tier 0/1 intel 快照寫入；偵查/潛行技能成長 |
| `interaction_system.gd` | 接觸結算：齊射→多回合戰鬥；flanking/morale cascade/pursuit；loot；body part 命中；_try_subjugate / _try_diplomacy / _try_merge / _resolve_tribute；貿易；玩家遭遇戰觸發（同陣營豁免）；execute_prisoner；Tier 2 intel；夜間突襲判定 _check_night_raid（待接入）；`process_on_move`（取代 process_on_arrival，每 tick 移動 team 對全 team 掃同格 try_interact）|
| `movement_system.gd` | tile_pos 移動（`_step_team` 用 A* `_calc_next_step`，繞山）；weighted 均速 (NAMED_WEIGHT=3 + tier-aware anon speed)；time_mult（日夜）；fatigue/超載懲罰；wagon 地形懲罰；strategic_assignments 優先邏輯；移動時記 `last_tile_pos`；BASE_MOVE_TICKS=TimeScale.MOVE_TICKS_PER_HEX=240 → 1 天/hex（×5→1,錨①連動）；process 回傳 `{arrived, moved}`；stuck log 加 source（task + strategic_assignments）|
| `path_system.gd` | A* `find_path`（同-tick cache）；`eta_ticks`/`_team_speed_mult`；`observe_velocity`（限視野+距離雜訊）；`estimate_catch_up`（reachable/eta/reason，ETA cap=AI_ETA_LIMIT 1200 tick = 5 hex plains at 240 tick/hex）|
| `event_system.gd` | Registry 架構；on_leader_death；PersonGenerator fallback |
| `person_generator.gd` | 從匿名人口晉升記名 NPC；tag 屬性/技能偏移 |
| `faction_ai_system.gd` | 策略層 evaluate_all；values 整合；成員 task 指派；SoloAI；tag 過濾；discovered-only 目標；`_find_*_target`（trade/prey/strong/aid）用 `PathSystem.estimate_catch_up`（reachable 過濾 + eta score）；每 20 Tick 外交評估；每 BETRAY_CHECK_INTERVAL 背叛評估；`_evaluate_prosperity_attack`（野心驅動征服 cadence 3 日，軍隊 tag 加倍 1.5 日，個性公式 attack_score / readiness threshold / find_prosperity_prey）；`_trigger_survival` Path 1 B 分支（遠 outpost + 殘忍/好戰 → 改 TASK_LOOT）；stuck 視為 idle 允許重評（_is_stuck → STUCK_TASKS）|
| `diplomatic_ai_system.gd` | _calc_diplomacy_score（5 因子）；try_proactive_diplomacy；handle_diplomacy_message（4 動作）；_form_alliance；_update_reputation；consider_betrayal；_execute_betrayal |
| `strategic_ai_system.gd` | 戰略目標更新（expand/defend/trade_net）；包圍指派；突圍指派；威脅評估（team_discovered，非全知）；in-map check（off-map target → nearest_valid_tile）；ENCIRCLE_DIST=1 / BREAKOUT_DIST=2 / BREAKOUT_NEAREST_THRESHOLD=3（trade_net dispatch 序8 溶入引擎已刪，致富交易走引擎貿易/買糧/囤貨 option）|
| `npc_ai_system.gd` | write_memory（修剪+relations+goals觸發+G2a feud/gratitude/protect 邊）；generate_birth_goals（values 門檻）；check_goal_alignment（目標×任務 delta）；vendetta_target（G2d 讀 feud 邊+衝動 gate→脫軌仇人 team）；cleanup_goals（target 死後重定向） |
| `salary_system.gd` | 每 30 Tick 結算；fair_salary = skills × 2.0；超付 → loyalty 上升 + kindness 記憶；欠付 → loyalty 下降；anon wage 改用 `AnonTierSystem.total_wage()` |
| `anon_tier_system.gd` | 4 tier（平民/新兵/老兵/菁英）；TIER_STATS（combat/speed/base_wage）；PROMOTION_EXP_THRESHOLD + ×count；leader 戰術 cap 訓練上限；菁英需 weapon_melee_high；kill_random weighted；transfer_proportional；avg_speed/avg_combat_skill/total_wage computed |
| `training_system.gd` | TASK_TRAIN team 每 tick 為 tier 累積 exp（速率 = leader 戰術 × n）|
| `day_night_system.gd` | get_time_period（dawn/day/dusk/night）；get_speed_mult / get_fatigue_mult / get_vision_mult；get_camp_vision_range（guard_ratio 守夜） |
| `population_system.gd` | 超額強制分裂（每 10 Tick）；有 advisor → dispatch 子隊；無 advisor → 獨立流亡 + PersonGenerator 晉升 |
| `subteam_system.gd` | dispatch / try_merge_back / 護衛跟隨；動態人口上限；紀律失效脫離 |
| `message_system.gd` | emit_message；propagate_on_arrival；4 種失真模式；去重衰減 |
| `world_generator.gd` | hex 地圖（radius 可配）；地形三型；ore_iron 分布 |
| `player_api_mapper.gd` | pure static DTO mapping（map_player_summary / map_forced_interaction / map_inventory_state / **map_members_detail** / **map_team_stats** 等） |
| `player_query_api.gd` | snapshot 查詢組合（get_player_snapshot / get_team_details / get_location_context 等） |
| `player_command_api.gd` | 指令驗證+分派（dispatch / move_to / respond_to_forced / execute_action 等） |
| `sim_bridge.gd` (更新) | query_player / command_player facade；UI 與 WorldState 玩家欄位完全隔離 |
| `encounter_system.gd` | 六角遭遇戰：init_encounter / _spawn_team_units（含匿名）；進場位置（attacker/defender/pursuit）；裝備分配；箭矢系統；decide_action 戰術 AI；advance_round 戰鬥解算（範圍/近戰/撤退/逃跑）；俘虜判定；傳令兵退出（SubteamSystem stub 待接）；resolve_encounter_end 結算（含勝方 occupy outpost 三 path：屠/放棄/強佔，依 leader 個性 + 居民拒投靠 reputation 判定；anon kill 改 `AnonTierSystem.kill_random`；戰場存活 exp +5 + 勝方 +5）|

---

### 事件層（`scripts/simulation/events/`）

| 檔案 | 內容 |
|---|---|
| `base_event.gd` | check() + execute() 基底 |
| `event_unrest_split.gd` | 分裂：unrest≥30 + 義氣<0.4 + 目標衝突；reset_loyalty_on_transfer |
| `event_unrest_replace.gd` | 替換：unrest≥20 + 統領≥0.3 |
| `event_faction_defect.gd` | 脫離：faction≠-1 + unrest≥20 + 義氣<0.35 |
| `event_tag_shift.gd` | tag 增減：好戰/野心→+軍隊；戰損>50%→+流亡；資源穩定→-流亡 |

---

### 測試

| 檔案 | 內容 |
|---|---|
| `scripts/debug/headless_test.gd` | 1000+ Tick headless 模擬；涵蓋所有系統驗證（資源/反應/戰鬥/faction/子團/視野/薪水/疲勞/日夜/外交/戰略/玩家/遭遇戰/**members_detail/team_stats**） |
| `scripts/debug/team_ui_test.gd` | 成員快照欄位驗證 + TeamUiHelper 所有渲染函數覆蓋測試 |
| `scripts/debug/ui_flow_test.gd` | **UI-flow 整合 harness**（2026-06-15）：實例化 TextUI.tscn → 注入 bridge state → 驅真鍵盤 handler/_process → 斷言 label/state。免手動 GUI 驗。首批覆蓋 U19 forced 自動進互動 / U21 互動選單分頁(10+) / U12 交易顯示 / hunt 動作可選。**未來修 UI 加對應 flow 測試自動回歸。** |

---

### 文件

| 檔案 | 狀態 |
|---|---|
| `docs/person.md` | 四層決策、14技能、部位健康、慎重契約 |
| `docs/team.md` | 欄位、人口規則、unrest 門檻 |
| `docs/world.md` | Tick 循環、LOD、資源、迷霧 |
| `docs/event.md` | Registry 架構、現有事件 |
| `docs/message.md` | 三層架構、衰減公式、4種傳播 |

---

## 待完成 / 技術債

### 功能缺口

| 項目 | 說明 | 優先 |
|---|---|---|
| `_check_night_raid` 接入 | interaction_system 已有函數，尚未在 `_try_interact` 呼叫；遭遇戰 encounter-system 負責整合 combat_type="pursuit" | 中 |
| 傳令兵 SubteamSystem 接口 | `_messenger_exit` 呼叫 SubteamSystem.create_subteam（不存在）；目前 has_method 保護為空殼 | 低 |
| `generate_birth_goals` → world_generator | NpcAiSystem 已有邏輯，world_generator 另有初始化；兩套並行，可統一 | 低 |
| `_evaluate_alliance_need` → 實際觸發外交 | 目前僅 print 警告；需呼叫 DiplomaticAiSystem._form_alliance | 低 |
| PLAYER_MAX_WEIGHT 強制執行 | PlayerSystem 定義 30.0 但未在 add_to_inventory 執行重量限制 | 低 |
| text_ui `_player_cmd.get_available_actions` | text_ui_main.gd 互動模式仍直呼 `_player_cmd`（非 bridge），未完全隔離 | 低 |
| text_ui `_build_interact_str` 直讀 state | pending targets 顯示仍直讀 `_state.teams`；body_slots 直讀 `_state.persons` | 低 |
| `player_forced_event_id` 碰撞風險 | 目前 `str(randi())`；可改雙 randi 或 UUID，但碰撞機率極低 | 低 |
| Agent REPL encounter 測試 SKIP | seed=42 radius=3 在 5000 ticks 內未觸發遭遇戰；AC#13-16 GDScript 端已實作，需調整測試條件 | 低 |
| Agent REPL stdin stdout 污染 | stdin 模式下模擬 print 混入 stdout JSON Lines；TCP 模式無此問題 | 低 |
| `preview_trade` 精確度 | `preview_trade()` 用簡化比例公式，與 `resolve_trade_direct()` 實際計算略有差異 | 低 |

### 系統整合缺口

| 項目 | 說明 |
|---|---|
| salary → kindness 記憶 | ✅ 已完成（2026-05-28） |
| check_goal_alignment 接入 | ✅ 已完成（reaction_system，2026-05-28） |
| threat_map → team_discovered | ✅ 已完成（strategic_ai，2026-05-28） |

### 平衡（所有 TEST VALUE 未正式調整）

| 分類 | 涉及系統 |
|---|---|
| 疲勞速率/恢復 | SimRunner FATIGUE_PER_TICK=0.002 / FATIGUE_RECOVERY=0.01 |
| 日夜乘數 | DayNightSystem speed/fatigue/vision mults |
| 視野常數 | VisionSystem VISION_RADIUS=3 / SCOUT_BONUS=2.0 |
| AI 追擊上限 | PathSystem AI_ETA_LIMIT=1200（≈10 plains hex）|
| 薪資比例 | SalarySystem SALARY_PER_SKILL_POINT=2.0 / OVERPAY_BONUS=0.02 |
| 外交門檻 | DiplomaticAiSystem score 0.55/0.6 |
| 遭遇戰數值 | EncounterSystem 射程/命中/傷亡率 |
| 戰略 AI 間隔 | StrategicAiSystem STRATEGIC_INTERVAL / ALLIANCE_CHECK_INTERVAL |
| 生育機率 | ReactionSystem BREED_BASE_CHANCE=0.15（+醫療×0.1）；minor cap=maxi(1,int(pop×0.25))（2026-06-13 economy-bootstrap）|
| 治理門檻 | FactionAISystem GOVERN_MATERIAL_TARGET=75（公庫達標放手擴張）|

### 序0 憲法防閘 + 時間 hygiene（2026-07-05 done，merged 3f2765f）

時間統一 wave 與憲法溶入 arc 的鋪路 slice，4 Task 全零 sim 行為變（seeded 46/8/1/380 守恆、framework PASS=7）：
- **修1 near/far hoist**（`sim_runner.gd`）：per-tick 無條件 O(N)×2 team scan 搬進各自 cadence gate（命中才算），消 gate-miss 純浪費，順減 O(N²)。
- **修2 十常數導出**（`faction_ai_system.gd`）：10 裸 cadence/timeout const → `TimeScale.TICK_PER_DAY*N`（跨類別 const 引用，非 `days()` static func）；順修 `FLEE_TIMEOUT` 硬編 `5*240` → 跟根。`time_const_check.gd` 斷言值不變。
- **修3 eta 除數**（`faction_ai:190`）：`/240.0` → `/float(TICKS_PER_DAY)`，殺硬編漂移。
- **★憲法 site-freeze 防閘**（`constitution_gate.gd`+`constitution_baseline.txt`）：鎖 `TaskArbiter.transition/try_set` 面（32 指紋凍結，8 known 違憲標 `# 序N`）。current⊆baseline，新增=FAIL、移除(arc溶解)=PASS。**限制**：不覆蓋 return-task-字串式違憲（coverage 誠實聲明，見 invariants）；**未掛常駐鏈**（known_issues 追）。
- **根值未動**：`TICKS_PER_DAY` 仍 240，60 切換綁 A2（×5→1+補給+FOOD+gen 四件一 landing）。本 slice 為 A2 鋪好導出面。

### 憲法溶入 arc — wave1 序1 threat done（2026-07-05，merged 804432e）

**溶=融合非刪** 首張。threat 手算 argmax（`_dispatch_threat_response`）撕除 → 引擎 `rank_threat` 秤：
- 4 反應成 REGISTRY option（FLEE 複用 `survival`；補 備戰/迎戰/求和 + eval term + weight key 人格 crosswalk）。**term = additive personality-dominant**（weight=1.0，人格 baked in eval，同既有 intent_fit/attack_drive 法）——因 `threat_react` unbounded（power_ratio 達 3.27）multiplicative 會爆量壓過 survival 絕境；additive 忠實鏡射舊公式，非 hack。
- 架構鏡射既有 survival 雙路：unified 隊 threat option 進主 rank（`_decide_unified`）；non-unified 隊 loop3 `_evaluate_threat` 保 trigger/release，內部換 `rank_threat`。trigger/release scaffolding（idle-gate/cadence/FLEE_TIMEOUT）保留=世界機制。
- **融合驗雙關綠**（`threat_dissolution_check.gd`）：①repertoire 4 原型各達（FLEE/DEFEND/PREPARE/求和）+ 居民守衛 ②率表 flee13/prepare4/defend1/pacify0=18>0（non-unified 逐類 bit-identical，該出現還出現）。
- **seeded 漂移 46/8/1/380 → 48/8/1/382**（新 baseline）：漂移純來自 unified 隊 threat option 進主 rank 微調軌跡（non-unified 逐類零變）；factions/established 守恆、pop 穩、無滅團潮 = **合理非退化**（交 QA 覆判，wave 級交付前）。
- 憲法閘：`_dispatch_threat_response` 指紋 removed=arc 進度；dispatch 移入保留的 `_evaluate_threat`（sites=32 不變，PASS）。
- **殘（watch，known_issues）**：unified 隊 迎戰/求和 下游 resolver（DEFEND prosperity_target 消費 / tribute_offer 外交鏈）未端到端驗；survival option 雙語意（主 rank reputation-filtered soft / rank_threat raw hard，刻意分離已註釋）。

### 憲法溶入 arc — wave1 序2 solo done（2026-07-05，merged f7ce320）

`_evaluate_solo` 非-unified 手算 argmax 撕除 → 引擎 `rank_scored`（鏡射 `_decide_unified`）；去 `_tag_weight` hard-gate（tag 不硬鎖）；attack/loot **capability-grounded**（藍圖 tag-soft-ruling）。
- **capability-grounding**：`ctx.self_armed_ratio = _calc_own_armed / pop`（equipped 戰力，storage 武器不算）；loot_drive/_intent_fit 攻擊 × `capability_factor = clampf(ratio/VIABLE_ARMED_RATIO[0.3])`；prey-weakness 改比 self **ARMED** 非 POP。→ 無牙商隊掠奪 util **0.000**（rank[0]=貿易，非劫匪化）；重甲商隊絕境可揮刀；軍隊 rank[0]=攻擊。**憲法**：戰力歸零=送死=世界事實（非 tag-label 禁攻）。
- **融合驗雙關綠 + 反向**（`solo_dissolution_check.gd`）：repertoire 9 各達 + 反向 3（商隊≠劫匪/重甲可揮刀/軍隊≠雜貨商）+ unified 守恆 3。threat 融合驗仍綠（共用 eval 未破）、threat 率 18 守恆（loop3 未餓死，measure 證）。
- **seeded 48/8/1/382 → 52/8/1/380**（QA wave 級判；factions/established 守恆、無滅團潮）。
- **★框架債揭（重要，見 known_issues + [[project_framework_seams]]）**：`_tag_weight` 是 solo/prosperity **隱形去衝突閘**——舊靠 `=0` 讓 FORCE 隊 attack 歸零→留 idle→loop3 prosperity 接精算征服鏈。去它 + 引擎「建設」option 恆 applicable→solo 每 idle tick 必派→餓死 loop3-idle-gated 路（S3 scout 一度 DORMANT）。實作加 **yield 閘補**（FORCE 征服候選 cadence 到期 return 讓 loop3）=橋，真結構修在序6（loop3 dispatch subsystem 溶入）。軍隊攻擊 occupancy 0%→22.5%（QA 判過度侵略否）。獨立隊 ambition-diplomacy 具體行為流失（engine 外交需 faction_stakes；獨立隊走 _evaluate_independent_strategy 結盟/建國+threat 求和；藍圖判要否保）。

### 憲法溶入 arc — wave1 序3 rung_task done（2026-07-05，merged 50dc86f）

`ambition_ladder.rung_task` `(archetype,rung)→task` 查表判斷器撕除 → archetype/rung 當 weight（`ctx.ambient_train_drive` 等）驅動 option。
- **冗餘識別**：rung_task 7 mapping，6 條既有 option 已覆蓋（TRADE→貿易/SETTLE→生產/建設/等），**唯一真缺=訓練 option**（FORCE 累積階練兵）→ 補之。刪查表。
- **idle-filler 走 `rank_ambient`**（收窄，系統裁定風險#1）：loop3 野心階梯 idle-filler 原 spec 走全 `rank_scored`→誤派 FLEE 86 次/1200t（team 到此已過 loop3 survival/threat 評估，ambient 不該二次猜）。修=`AMBIENT_OPTION_SET=[訓練,貿易,生產,建設,囤貨,駐守]` + `rank_ambient`（鏡射 rank_threat）。**FLEE churn 86→0（結構除，非壓 magnitude）、徵收 10→0**。
- **★序1 threat「率18」部分是 churn 假象（重要 measure 洞察）**：86 ambient-FLEE 隨機逃跑=隊間威脅遭遇主要製造者→序1 驗的 threat 率 18 部分虛胖。churn 除盡→seeded threat.dispatch 3→0（世界變靜）。`_evaluate_threat` 未改、仍 loop3 先跑、真威脅仍派。→ **threat 融合驗 5b 從「seeded 湧現硬斷」改「確定性 live-seam 硬斷」**（構威脅隊直呼 _evaluate_threat 斷言實派+probe bump=更 robust，seeded 值降資訊性）。教訓：湧現率斷言可被無關 churn 虛胖，確定性 seam 測才穩。
- **融合驗綠**：rung repertoire（訓練/貿易/生產/建設/讓位）+ threat（新 live-seam）+ solo 全 ALL PASS；framework PASS=7；gate PASS 32（rung_task 回字串無 TaskArbiter→不在指紋）。
- **seeded 52→48/8/1/380**（QA wave 判；pop/factions/established 守恆；48–56 帶繞 52）。**watch（藍圖/QA）**：世界變靜（threat 遭遇↓）是否過龜縮（反龜縮 bar）。

### ★★憲法溶入 arc 完成 — 序8 灰項 done（2026-07-06，merged 57f7d39）= 8 違憲全溶

`strategic_ai::_dispatch_trade_net`（唯一剩餘引擎外 task-dispatch 灰項，序6 後致富成員走引擎已成死路 trade.dispatch.trade_net=0）撕除 → 致富交易走引擎貿易/買糧/囤貨 option。gap 檢無淨增（純買家囤貨/買糧覆蓋）。gate sites 31→30 全為保留 scaffolding。融合驗綠、framework PASS=7（S6 order 不 DORMANT）、seeded 49/8/1/381 零漂移。
- **★★憲法 8 違憲全溶完（序1 threat / 序2 solo / 序3 rung / 序3.5 preempt / 序4 vendetta / 序5 prosperity / 序6 dispatch / 序7 reaction / 序8 灰項）**——「決策不統一」根因 arc 完成。所有 NPC macro 行為經統一決策引擎（DecisionEngine util weigh + 人格調製），憲法閘鎖 30 sites 全為 world-mechanic dispatch/scaffolding（非個體 utility 判斷器）。
- **arc 尾待**：撤 pre-commit site-freeze 閘 → 轉全掃常駐鏈（另 slice）。
- **arc 後平行軌**：gen readiness recalibrate（probe slice→重跑 baseline→調，待藍圖）；決策模型接線脊椎（感知腳 audit done、情緒腳序7 起步、位置god-view/戰力欄/記憶腳待）；全 pipeline 工作流切換（脊椎開軌時）。
- **殘（follow-up）**：C 類貿易 finder dedup（`_find_trade_partner` god-view vs `_find_trade_target`）；player_command trade_net override 語意（正交，另議）。

### 憲法溶入 arc — 序7 ReactionSystem 行為選擇溶入 done（2026-07-06，merged 2edf120）★reframe=其實小

audit 標「最大最難」，**measure reframe=其實小**：9 反應 apply 幾乎全 state-effect（情緒/loyalty/unrest/離隊 spawn/生育/memory 後果）——**唯一行為選擇改 task=聚合 panic-flee bridge**（`reaction:48-60` 兵卒大量恐慌整隊裹挾潰逃 try_set TASK_FLEE）。
- **溶=拆 1 bridge + 保 9 反應**（合藍圖 arc-order「拆行為 vs 情緒/離隊/生育後果保留」）：bridge 撤 → `ctx.team_panic`（高 stress 低 loyalty named 成員/pop 聚合）→ `threat_pressure` eval 疊 `team_panic×PANIC_WEIGHT(0.5)` → 引擎 survival option 自然 FLEE（潰散由統一秤輸出非旁路）。個體反應 apply 全不動=consequence scaffolding。
- **★FLEE 三源序保**：真絕境 survival util(12) >> panic-only(0.4)，PANIC_WEIGHT 不喧賓奪主。
- **★ctx 首讀 person stress/loyalty = 決策模型情緒腳首個接線起步。**
- **融合驗 4 錨 ALL PASS**（行為溶入/FLEE 三源序/反向/個體後果保）；threat/preempt/faction-dispatch/全融合驗綠；framework PASS=7；**gate sites 32→31**（evaluate_all 指紋 removed=reaction 零 TaskArbiter 面）；**seeded 49/8/1/381 零漂移**（bridge 此 seed dormant）。
- **殘（backlog）**：PANIC_WEIGHT/PANIC_STRESS/PANIC_LOY=B 債（該由膽識算，常數人格化軌）；記憶染價值腳 dormant（引擎不讀 memory=決策模型 gap，接線脊椎軌）；反應零 probe=觀測空白；玩家隊 FLEE 保護靠既有 per-path 玩家 guard（實作驗玩家到不了引擎 survival dispatch）。

### 憲法溶入 arc — wave2 序6 faction 成員 dispatch done（2026-07-06，merged 2b4a427）★最高收斂動主幹

`_assign_member_tasks` goal→task if/elif hand-dispatch（含 V2-cmd 徵收 shadow 攻擊）撕除 → faction **成員**（非 subteam）走 `_decide_unified`（引擎 rank_scored 競秤）。
- **★只改成員 dispatch gate（`parent_team_id==-1`），不動全域 `uses_unified`**（陷阱：uses_unified 兼 `_evaluate_threat` skip，擴全域會繞過序3.5 preempt scaffolding=反龜縮又斷）→ 成員 macro 走引擎 + threat/preempt/survival loop3 scaffolding 保。**教訓同序2 `_tag_weight` 隱形去衝突閘：去/擴多職 gate 前先問它兼哪些職。**
- **★V2-cmd 自消**：`rank_scored_ctx` argmax（非 if/elif 短路）→ {徵收,攻擊} 雙 goal 競秤，好戰成員攻擊 util(1.91)>徵收(1.67) 贏、貪婪成員反轉（分歧非抹平）→ 攻擊-eligible 成員不再被徵收 elif 序死。
- **★成員打草穀 raid 接回**（掠奪 option has_weak_prey 自然競秤，序5 待項）+ **框架債縫#3 完全結清**（成員退 loop3-idle-gate，主 rank 每 cadence 重評）。外交 goal 對軍隊現通（舊 tag_weight=0 走不到）。
- subteam guard 補（`parent_team_id==-1`，防 loop1/loop2 雙寫，現缺）；MERGE consolidate→`_try_consolidate_merge` scaffolding（faction 整併非個體決策）；probe 遷移引擎路。
- **融合驗 6 錨 ALL PASS**（repertoire/V2-cmd 解/raid/preempt 保/subteam/本業）；threat-preempt/prosperity/threat/solo/rung/vendetta 全綠；framework PASS=7；gate PASS 32（`_assign_member_tasks` 指紋刪=arc 進度）。
- **seeded 52→49/8/1/381**（成員 raid+V2-cmd 解→分佈變，逐點重現）。**★gen 重校 follow-up ripe**（藍圖 seq5-judgment：等序6 全溶對完整征服/掠奪圖調——現完整）。
- **殘（watch）**：MERGE 現對商隊/生產成員亦 eligible（罕觸，誤併→加 tag guard）；member_atk seeded=0=結構（此 seed 無 faction 攻擊 directive，harness 確定性已證解）；leader dispatch=序6b defer。

### 憲法溶入 arc — wave2 序5 prosperity done（2026-07-05，merged 16ab3bc）★arc 最大 slice

`_evaluate_prosperity_attack` gate cascade（archetype/attack_score/readiness/find_prey 硬閘 prescribe TASK_ATTACK）決策溶進引擎 攻擊 option。
- **readiness→權重**：`_intent_fit` 征服 × `readiness_factor=clampf(readiness/readiness_thr_eff)`（沒本錢 util 趨 0=capability grounding，非硬閘）+ 信義 penalty（對齊舊 attack_score 野心+好戰−信義）。富 prey targeting（find_prosperity_prey 經 ctx.intent_target）。
- **scout-verify 保 scaffolding**（`_commit_conquest_attack`：不確定+慎重→TASK_SCOUT/confident/莽者→TASK_ATTACK；`_tick_conquest_scout` 生命週期）——means-end 非 option（派斥候探底 option 排 trade/diplomacy 溶）。**S3 scout=1/S4 ambush=1 誘殺保**。
- 刪 cascade + 序2 yield 閘（框架債縫#3 部分結清）+ unified reroute → FORCE 隊征服走主 rank。
- **融合驗 6 錨 ALL PASS**（repertoire/readiness閘/斥候/照衝/hunger_relief/富prey）；framework PASS=7；gate PASS；seeded 52/9/1/381→**52/8/1/380**（非凍死，churn 在）。
- **★征服率發現（gen 重校輸入）**：征服 intent 隊 rank **掠奪(小承諾)壓過攻擊(出征)** → prosperity_reached 2→0=「沒本錢征服隊改掠奪」=合設計；ready+armed 隊攻擊會贏。conquest 仍經 loot→combat→capture（combat_entered=15）。**非 fail**（藍圖：雪球≠fail 唯凍死=fail，churn 在）。
- **★interim gap（序6-bound）**：舊 loop3 cascade 對 faction 成員也跑打草穀 raid；序5 刪 loop3→成員征服只宣告無 dispatch 路→**成員 raid 暫失**（獨立 FORCE 隊征服鏈完整=主交付）。序6 loop3 全溶接回（縫#3 結清）。
- **殘（arc 尾清）**：orphaned `calc_attack_score`/`ATTACK_SCORE_THRESHOLD`/`PROSPERITY_CADENCE(_MILITARY)`；cascade 單元測遷移/退役。**B 債**：`VIABLE_ARMED_RATIO`/`INTENT_FIT_DRIVE`/信義 k=0.4 待人格化（`readiness_thr_eff` 已含慎重✓）。

### 憲法溶入 arc — wave1 序3.5 threat-preempt done（2026-07-05，merged 4afbcaf）

反龜縮 seam 修：忙碌目標對逼近攻擊者盲（`_evaluate_threat` idle-gate，measure 坐實 IDLE 反應/BUSY 不反應）→ 強威脅 preempt 非緊急進行中 task。**接 approach→感知→反應因果脊椎，非新機制。**
- `_evaluate_threat` idle-gate 改三分支：idle→原路；busy-preemptible + threat_react≥`threat_threshold+PREEMPT_MARGIN(2.0)`→打斷派 defensive；busy-urgent→不評。`PREEMPTIBLE_TASKS`=生產/製造/建設/貿易/治理/訓練/覓食/紮營（8）。PRIO_THREAT(70)>DISPATCH(50) 打得斷。
- **PREEMPT_MARGIN=2.0**（measure 校，非初設 0.5）：threat_react 的 approach/hostility(weight 1.0)壓過 power(0.5)→逼近但弱敵=1.49、碾壓=5.52→margin 2.0 要 power_ratio≳5 才觸=天然「能傷你」。TEST VALUE 待 wave QA 校抖動。
- **★TASK_PRODUCE 納入**（follow-up，系統確認定居 resident 生產隊 `interaction:1065` 進 TASK_PRODUCE 非 MANUFACTURE）→ 藍圖核心「犁田遇劫匪放犁」case 接上。
- **感知鐵律守**（北極星）：preempt 門檻只讀 threat_react（belief 表象+known_reputations+approach），**禁讀 tag**。反向守 3+③ case（弱/中立/帶刀商隊/逼近弱→續 task）由低 threat_react 自然滿足，非 tag 打折。
- **融合驗雙關+③ ALL PASS**：該出現（忙碌/定居隊遇壓境→放 task 反應）+ 反向守（不抖動）+ resident guard（居民迎戰排除→給逃跑不卡死）。
- **反龜縮 flee 0→12**（defensive threat 對忙碌目標顯化）。**seeded 48→52/9/1/381**（factions 8→9=defensive 反應活化世界；QA wave 判）。
- **殘（watch）**：preempt→威脅退→release 回 idle 非續原 task→頻繁遭遇下潛在 churn（THREAT_CADENCE 1日緩解，實測 12 FLEE/1200t 無暴 churn）；PREEMPT_MARGIN=2.0 TEST。

### 憲法溶入 arc — wave1 序4 vendetta done（2026-07-05，merged 2506e6e）

hand vendetta dispatch（`faction_ai:733-741` 直塞 TASK_ATTACK@PRIO_VENDETTA）撕除 → `feud_pull` term（已存在未掛）掛進 攻擊 option。**優先序→權重序**：血仇>致富攻擊=feud_pull weight（`strongest_feud×(0.3+好戰×0.5)`）讓攻擊贏 rank；威脅>血仇=PRIO_THREAT(70)>DISPATCH(50) + rank 內 survival util 碾壓。
- 加 `ctx.feud_target_id`（vendetta_target 掃描）+ 攻擊 applicable 血仇路（`strongest_feud≥FEUD_ATTACK_MIN(0.5) and feud_target_id≠-1`）+ to_task 攻擊多源 target（faction directive>征服 intent>血仇）。`g2.vendetta_trigger` probe 移引擎 dispatch。
- **融合驗 4 錨 ALL PASS**（攻擊 rank[0]、血仇>致富、target=仇敵、威脅>血仇）；framework PASS=7（★S2b vendetta_trigger=1 不 DORMANT）；threat/solo/rung 綠；gate PASS；**seeded 零漂移 48/8/1/380**（feud 攻擊 repertoire 加項、此 seed 罕觸）。
- **感知鐵律守**：feud=已知關係（feud memory/known_reputations），合法。
- **殘（watch/藍圖）**：feud_pull **無 capability gate**（無牙血仇仍攻=送死；舊 hand dispatch 亦無 cap→語意保；血仇=衝動非理性 arguably 對，vs 序2 loot/attack 的 cap grounding 不一致=藍圖裁）；攻擊 target 多源（私仇被 faction 令蓋=directive 優先，藍圖確認要否私仇覆蓋）；FEUD_ATTACK_MIN=0.5 TEST。

### 待開發（大功能）

| 項目 | 狀態 | 說明 |
|---|---|---|
| **Mounts/Wagons 速度** | 🚧 plan + sub 中 | mount bonus max 3X + size_penalty / wagon -30% / 1 人 1 獸 / stable facility / wild_horses 野採 / mount 吃糧 / loot 公式 |
| **NPC 會合/攔截**（W1+W2）| 🚧 spec + plan 寫好，待 mounts merge 後 dispatch | ThreatAssessment + predict_intercept + 4 反應 + trader → outpost-only + trade timeout |
| **戰場 mount unit-level** | 未開 spec | mounts/wagons spec 後續：encounter 騎兵 unit + 衝擊 + 機動 + 戰場 mount 死亡 |
| **named 升階機制** | 未開 spec | 從 anon 抽 → tier 決定 named 初始屬性 |
| **戰俘處置 spec** | 未開 spec | 賣 / 屠 / 招降 / 釋放，loyalty 規則 |
| **外交招募 spec** | 未開 spec | 投靠 / 雇傭軍 / 直接買高 tier |
| **tag drift** | 未開 spec | leader values / event 改 tag（軍隊變商隊等）|
| ~~salary 欠薪後果~~ | ✅ 已存在(2026-06-17 確認) | Bug2 stale：減薪→掉忠誠(salary:73)→N3_defect 離隊鏈已完整 |
| **NPC promote/train AI（W4 層2）** | ⚠ 層1 已修 | promote tick caller 已補(training_system)；遺留：NPC AI 鮮少選 TASK_TRAIN |
| **coin 產出激活（W8）** | 未開 spec | 2026-06-17 量測:金銀礦/鑄幣全休眠,coin 零生成純零和集中。激活 NPC 採礦+鑄幣決策 |
| **UI / 渲染** | ✅ text_ui_main / popup_layer / main.gd 已透過 SimBridge 隔離 WorldState 玩家欄位 |
| **玩家操作介面** | ✅ PlayerApiMapper + PlayerQueryApi + PlayerCommandApi + SimBridge 玩家 API 邊界已建立 |
| **成員檢視 UI（team_ui）** | ✅ 三欄式 member inspector 完成（2026-06-02）：PlayerApiMapper.members_detail + team_stats；TeamUiHelper 靜態渲染；text_ui_main member_mode 狀態機（W/S 選人，1–4 切換子模式：快覽/健康/裝備/能力）；headless_test + team_ui_test 驗證 |
| **anon tier UI** | team panel tier 分布 / 升等進度條 / combat 死亡分檔 |
| **遭遇戰 UI** | EncounterSystem 已有邏輯層，需 hex 地圖渲染 + 玩家指令輸入 |
| **天氣/季節系統** | 影響地形乘數、採集效率、疲勞 |
| **宗教/文化系統** | 新 values 或 faction 屬性 |
| **PersonGenerator 其他 call site** | 玩家招募、天賦事件 |
| **存檔/讀檔** | WorldState 序列化 |

## 統一生產框架 merged（生產 arc 甲，2026-07-16，merge dac824cb）
供給牆破。de-patch 設施決策入思考層（框架管規則·思考歸引擎人格）。
- **S1** 製造 precondition 規則 + no-op tap（A2 補缺 + E 可觀測）。
- **S2** food-security survival-crush 項編進秤（farming×(1+CRUSH×urgency²)，軟連續，food_security_target 人格調變）+ granary 位置 seam 修 + 常數分層（×0.8 flat/×7 人格化）。S2 gate：餓隊 farming 13.80>workshop 4.40（精確 match R① 手算）。
- **S3** means-end 統一發起涵蓋 faction_id=-1 獨立隊。
- **S4** 移 A1 override + A4 govern de-patch（單 owner 引擎駐守）+ 礦山 civilian de-patch（ore 融人格秤）+ farming 不拆/survival 農田特例=規則明文。
- **measurer full-HD**：has_facility 恆1→10%~31.3%（含獨立隊 27.3%）、成品池 26→480(18x)、[Manufacture] 6→4348、no-op=0、urgency 真 fire、starve 2→2 無回歸、守恆 PASS、觀測閘 byte-identical。
- **閘鏈**：R①（異質手算擋天真 de-patch）→re-verify CLEAN→R² issues(5 閘)→R² CLEAN→impl(S2 gate)→measurer→觀測閘全綠→blueprint 批。
- **誠實標記**：供給破=強證；人格分化 mechanism-present 待 multi-seed fast-follow；deal 側成交牆(死法②)=下個 arc。

## ★統一路線圖 v2（用戶定「照路線架」2026-07-16）
全庫稽核:DecisionEngine 半成品(引擎存在但引擎外多 dispatch 路 + 各算各的 need 7處/threat 8處/估值 5處,faction_ai 3781 行大雜燴)。路線=收散亂成單一思考驅動 oracle。**7 序 + 執行狀態**:
1. **統一 need oracle（Arc1，🔵在飛）**：NeedOracle 獨立 module,兩量 need_keep(自用+供應鏈)+demand(貿易);生產/商業共讀餘量防打架;停產+溢出落地雙 sink+消耗品可貿易+退役 TARGET_PER_POP。R①CLEAN+R²CLEAN(異質抓核心單標量混反向缺陷)+S1 done(c25abfb7),S2-S5 fresh session 續。
2. 收斂三重 dispatch（威脅/求生全走引擎 rank）— ⚪待。
3. 統一威脅 oracle（ThreatAssessment 單源，8 處收斂）— ⚪待。
4. 拆 `_threat_recent` 軍備閘 — ⚪待。
5. 決策門檻死常數人格化（照妖鏡族）— ⚪待。
6. 情緒系統 — ⚪待。
7. 內部政治 / 設施 / 俘虜 — ⚪待。
紀律:每 arc 前提先驗(R①)+R²(大框升異質)+measurer full-HD。三處耐久:game-design(WHAT)+memory+progress(此)。

## ★Arc1 統一 need oracle MERGED（統一路線圖第一塊，2026-07-16，merge e483f85c）
need-quantity 收斂成單一思考驅動 oracle。
- **NeedOracle 獨立 module**（NeedHierarchy 零改動），兩量 need_keep(自用+供應鏈)/demand(貿易);生產/商業/facility 共讀（餘量=holding−need_keep 防打架）。
- S1 骨架+food 推導 / S2 供應鏈 gap / S3 貿易 demand 非幽靈 / S4 共讀兩量+per-recipe 停產+TARGET_PER_POP 退役 / S5 溢出雙 sink 落地守恆 / S6 遷 _facility_deficit 消殘各算。
- **measurer 對指標全綠**：①單一源(byte-identical refactor) ②goods 死鎖解量化 ③停產+溢出守恆 ④crossover 100%/守恆/starve 持平。
- **批前兩坑修**：mis-cite(矛盾率=死法②)+incomplete single-source(S6)。**known-deferred**：終端消耗品 self-use 值待戰耗機制。**死法②=下 arc**。
- **★立模式（Arc2-3 照做）**：單一 oracle+既有零改動邊界+byte-identical refactor 驗+乾淨全量對指標+前提先驗 R①+判準(源統一硬/值推導軟債)。
- **路線圖狀態更新**：1🟢merged / 2🔵next(三重 dispatch 收斂) / 3-7⚪待。

## 統一路線圖重排（2026-07-16，R① reframe 後）
- **Arc2 dispatch 收斂 → 降級低優先**：R① 揭 4 個 rank_*（survival/threat/scored/ambient）全是同 DecisionOptions.applicable() 池 + 同 terms filtered subset，**非繞過引擎、無 bypass 可拆**=cosmetic cleanup 非 de-patch → 降級（含 survival/threat 語意併=北極星，日後）。
- **Arc2 = 統一 threat oracle（原 Arc3 上移，🔵R① 驗中）**：roadmap 稱 8 處各算/3 門檻不一致=真高值打架種子。**★前提先驗 R①**（稽核前提連兩次被打臉[need 7處→2軸、dispatch 三重→4 filtered]→不假設，驗 8 處真各算還是同源 filtered）。
- **★鐵律**：稽核前提不可靠、連被 R① 修正 → 每 arc spec 前 R① factcheck，永不在稽核假設上寫 spec。路線序動態（非固定）。

## ★生存經濟 access arc + 12mo 期末考（2026-08-13~14）
③長期故事驗證（退一步跑長局找世界故事）→ 收斂：世界**非**資不抵債（嚴格守恆帳 CLOSE、GRAND 僅 -8.1% 溫和、tile 池滿）= 分配/接入問題非產能。深根鏈：team.food 崩=91% 流浪不定居→背糧一路吃只出不進 + 安家後 gather 卡（labor 分配）+ 接入執行斷（紮營/settle/建設）。

**生存經濟 access arc（全 slice MERGED）**——WHAT=blueprint、HOW=systems、R² CLEAN、measurer bounded gate：
- **B4/B5**：settle→即刷 labor cache（新居民採糧非硬零）+ food need 隨飢餓升（NeedOracle `_self_use` 接 famine、material 排擠 food 根修）。
- **A1**：紮營價值=`MarginalEconomy.camp_marginal` 真帳（camp_drive 死常數 1.0→state-reading、anti-crank 雙防線）=correctness（佔據非其 lever）。
- **A2**：拓寬 invite 候選（`_try_invite_nearby_exile` filter `流亡`→非 PRODUCE 非戰鬥遊蕩團）=settle-into-existing funnel 頂。
- **A4**：forage de-patch（`survival_pressure` eval 1.0→隨 food_days 衰減、吃飽讓位 settle）+ solo-convert（TASK_SETTLE 抵空 outpost 去 pairwise pair 要求）+ 9 筆 invite_settle 入 ENGINE_SOURCES。
- **佔據率 7.69%→11.02%（+43%）**、determinism byte-identical、bounded 不誤傷瀕餓。
- ★診斷 CLOSE 但非 bug 的：**try_set 共根=genuine**（99% priority_lower 正確仲裁、被擋團全 survival/threat 態、禁 priority-crank）；**crisis-density 半 inflated**（覓食 util flat 吃飽仍 forage=A4 lever）**半 genuine**（threat 真高留、warring 質地）。

**perf arc slice A MERGED**：gather market-finder 冗餘消除（`_harvest_market_known` 單 gather 二刷→一刷、byte-identical fp==baseline、-5.7% tick-time）。redundant-gather 大宗=跨-phase 非 byte-identical-safe（收 A）；LOD/scan-nearby 記 [[project_time_scale_wave]] 未來。

**★12mo 期末考（誠實：metric 升健康未升=必要非充分）**：佔據率升 80% 高原**但主靠 founding 非 settle-into-existing**（convert_via_settle 全年僅 1）；★**residents 反而全世界最餓**（wanderer 才吃飽=「佔據↑=世界好」被推翻）；深層 dysfunction 長年：pop -85%、established 全年 0、combat 死全年 0、factions 8→2、守成心態、終局崩。WHY 待 QA specimen 二輪。

**掛用戶**：B6 小團 pool 地板 / vitals 生存預算 invariant（spec 待核）/ closed-account memory-rule / checkpoint-resume 基建 / LOD arc 排序。
