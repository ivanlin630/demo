# Hand Back: ②a found_ally timeout + 信使外交（envoy 實體）+ F-I1 resolver 統一

Spec：`docs/superpowers/specs/2026-07-03-envoy-diplomacy-fi1-design.md`
Plan：`docs/superpowers/plans/2026-07-03-envoy-diplomacy-fi1.md`
Branch：`feat/envoy-diplomacy-fi1`

## 實作摘要（每檔一行）

- `scripts/data/team_data.gd`：加 `pending_proposal: Dictionary`（提案權威欄，對齊 active_orders pattern）。
- `scripts/simulation/faction_ai_system.gd`：
  - Task A 建國 in-flight guard 換 timeout 版：結盟走 `pending_proposal` + 逾時清 pending/cooldown；吞併(found_subjugate) task 逾時 release。
  - Task B `_dispatch_envoy`/`_equip_envoy_mounts`/`_tick_envoy`/`_recall_envoy` + `_founding_timeout`：建國結盟改派信使子隊（`TASK_HERALD`+`task_reason="envoy_proposal"`），提案存母隊、信使帶 proposal_id ref、撥馬、追蹤刷新（intercept 預測）、自配 timeout、母隊 release 回日常。
  - `_evaluate_subteam` 頂加 envoy 分支（追蹤刷新 + timeout）。
- `scripts/simulation/interaction_system.gd`：
  - Task C `_deliver_envoy_proposal`/`_recall_envoy_home`：信使同格送達 → 委派 `handle_diplomacy_message`（belief judge）；proposal_id 首達生效/後到 no-op；送達後歸隊。
  - Task C F-I1 `_try_diplomacy` 退役 god-view `team_strength` 接受公式 → 一律委派 `handle_diplomacy_message`（judge 淨 −1）。
- `scripts/simulation/diplomatic_ai_system.gd`：`_form_alliance` 補「兩獨立 → create_faction（強者 leader）」分支（F-I1 搬家；以 population 取代 god-view team_strength）。
- `scripts/debug/warring_harness.gd`：PROBE_KEYS 加 envoy 結局探針。
- `scripts/debug/longwindow_bed.gd`：漏斗表加 founding 段（信使外交漏斗）。
- `scripts/debug/headless_test.gd`：兩 founding 單元測改為 envoy 語意 + `_indep_add_named` helper。

## 與 spec 的差異（重要，待主/藍圖確認）

**① 信使 timeout 值遠大於 plan 建議（3.0 / 2 天 → 6.0 / 12 天 floor）。**
- Plan 建議 `FOUNDING_TIMEOUT_MULT=3.0`、floor `2×TICKS_PER_DAY`。實測此值下 **delivery=0、accept=0**（全 timeout）。
- 根因：信使追「移動中」的 target。步行信使僅有 named(0.75)>anon平民(0.7) 的**微速差**，收斂所需時間遠大於直線 ETA。seeded warring 種子隊 **mounts=0**（`warring_states_seed` 不配馬）→ `_equip_envoy_mounts` 撥 0 → 信使無馬 → 幾乎等速 → 永遠差 1 格（診斷探針 `diag_adj=106, diag_same=0` 證：能到相鄰、從不同格）。
- 加大 timeout floor 至 12 天後 **delivery>0、accept>0**（見驗收）。有馬則信使 3× 速→秒到，此 timeout 變寬鬆 slack。
- **這是「保險網 timeout 按距離/移速估」的合理延伸**（步行追移動 target 的收斂裕度），但值偏大=步行信使慢。**藍圖決策點**：是否要 (a) 讓 seeded warring / 世界經濟配馬（信使快、timeout 可縮回小值），或 (b) 給信使 courier 速度階（`speed_class` hook 已預留但未實作），或 (c) 接受「亂世步行信使慢=believable」。我採 (c) + 大 timeout，未動經濟/未加速度系統（守「零新系統」）。

**② 建國結盟需母隊有 spare named 成員**（信使子隊需 named leader）。
- 只有 leader + anon 的獨立隊**無法派信使結盟**（退守成累積，`_dispatch_envoy` 回 false）。稀有 by construction；征服/吞併路徑不受影響（走 prosperity→subjugate→create_faction）。
- 舊碼母隊自己 TASK_DIPLOMACY 追不需 named，但那正是 T32/T34 凍結源（追不到移動隊）。新碼「無 named→不派」也**不凍結**（不 dispatch、下 cadence 重評）。

**③ F-I1 統一後結盟接受門檻改由 `handle_diplomacy_message` 的 `_calc_diplomacy_score>0.55` 治理**（belief 公式），比舊 god-view 公式嚴（重 resource_need/power_gap/rep/relation/peace）。→ 結盟成功率下降、更 believable（陌生人不隨便結盟；缺糧/高信任才成）。行為變 = 預期 DIRTY。

## 驗收結果

- **headless**：1 FAIL（`弱目標未加入攻擊 goal`=pre-existing 容忍）、0 SCRIPT ERROR、InvariantAudit（population/faction/subteam/roster 雙向+反向）全 OK。兩 founding 單元測 PASS（envoy dispatch + envoy→accept→create_faction）。
- **framework_validation**：7/7 PASS，DORMANT=0（S1 立國含）。
- **seeded_warring（seed=1337, 2 月）**：`g2.faction_found=1`、`indep.found_ally=2`、`indep.found_timeout=0`；envoy 探針 `dispatched=4 delivered=2 accept=1 reject=1 timeout=0 target_dead=0`。→ **envoy.accept>0 ✓、建國仍活 ✓、非全 timeout ✓**。attrition=42.2%（月線 sanity，隊數 82/factions 9，未崩）。
- **F-I1 grep**：`_try_diplomacy` + diplomatic 決策路徑無 `team_strength` 呼叫（殘留 team_strength 僅 `_should_pay_tribute`/`_resolve_tribute`/npc_combat = 戰鬥/勒索域，非外交）。
- **長窗解凍（LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1，43200 tick，無 crash）**：
  - **T32/T34 不再跨月卡 found_ally ✓**：全 6 月 [WolfGate] **無任何狼顯示 外交/found_ally/信使 task 佔用**（舊 T32 卡 4 月、T34 卡 6 月 → 消失）。結構上必然：母隊派信使後即 release，永不自持 found_ally task。
  - **T32 raid 曲線恢復 ✓**：T32(狼餬口) task 逐月輪轉 — 月1 治理→月2 **攻擊**→月3 return_home→月4/5/6 **攻擊**（掠食恢復，非凍死在建國步）。
  - founding 漏斗（6 月）：found faction=1、`indep.found_ally=3`、`indep.found_timeout=1`（保險網釋放 1 次）；envoy `dispatched=5 delivered=2 accept=1 reject=1 timeout=1 target_dead=0`（**accept>0 ✓**）。
  - 殘留 [GateWait] 2 狼（T36 readiness=0.23<0.42 / T29 定居 score<0.30）= **raid/readiness gate 乾等**（藍圖 ai-depth 既有 backlog），**非** found_ally 凍結、非本波引入。
  - perf：median=260us、max=962ms、spike 10.34%（= 滅團潮 O(N) die-off spike，known_issues 既有 perf backlog；隊數 104→38 滅團波，非本波）。
  - 月線 sanity：teams 104→38、pop 633→261（warring 滅團潮，未崩，founding/attrition 合理）。

### envoy 結局分佈（= 藍圖要的「怎麼沒結盟」fail 分佈，seed 1337 / 2 月）
```
dispatched=4  delivered=2  accept=1  reject=1  timeout=0  target_dead=0
（4 派 = 2 次建國 ×2 冗餘騎；2 送達 = 每次首達 1 騎；另 2 騎 no-op 或仍在途）
```

### TEST VALUE 清單（本波新增，平衡 pass 調）
| 常數 | 值 | 說明 |
|---|---|---|
| `FOUNDING_TIMEOUT_MULT` | 6.0 | 單程 ETA × 此 = 信使追移動 target 收斂裕度 |
| `FOUNDING_TIMEOUT_FLOOR_DAYS` | 12 | 步行信使收斂下限（plan 建議 2，實測太緊） |
| `ENVOY_POP` | 1 | 信使子隊人數 |
| `ENVOY_REDUNDANCY_FOUNDING` | 2 | 建國提案冗餘騎數 |

## 連動風險（待主 session 判斷是否補修）

- **`movement_system` / 世界經濟**：信使速度全靠 mounts；種子世界無馬 → 信使慢 → 需大 timeout。若後續配馬經濟成熟，`FOUNDING_TIMEOUT_*` 應可縮小。無馬經濟是**框架缺口**（差 (a) 標記，見上「差異①」）。
- **`diplomatic_ai_system._form_alliance`**：新增兩獨立 create_faction 分支用 `population` 比較（非 god-view team_strength）。此為兩隊合意的結構性動作（非敵對評估），不列入 G3 belief-leak 稽核；但若日後要嚴，可改 belief best_estimate。
- **faction 外交 goal 路徑（`_assign_tasks`/`_assign_member_tasks` 的 `外交`→TASK_DIPLOMACY 直追）** 仍是**無 timeout 的 in-flight latch**（本波只改獨立建國路徑）。同「凡 in-flight latch 必有 timeout」不變量，屬**後續同型缺口**（plan 明示他波，未動）。建議列 known_issues。
- **G3 攔截/收買 hook**：spec 明示先不做（實體先行）。信使可被殺/攔的 channel 語意已備（信使=實體、死=提案落空），G3 未來接。

## 待主 session 確認

1. **timeout 值 6.0/12 天**是否可接受，或要走「配馬經濟 / courier 速度階」讓信使快（差異①）。
2. **F-I1 結盟接受門檻**（`_calc_diplomacy_score>0.55` belief 公式）是否符合藍圖對「結盟稀有/believable」的意圖，或需調 threshold。
3. **faction 外交 goal 直追無 timeout**（連動風險③）是否本波順修或列 backlog。
4. pointwise 預期 DIRTY（行為修）→ 建議不跑 pointwise baseline 對照，改月線 sanity（已附 seeded warring 前後量）。
