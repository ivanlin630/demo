# 03b_measurer 的血證與案例（按需讀，不在開場必讀區）

**必讀版留【規則本體】，這裡放【它為什麼成立】：血證、表格、案例、同族清單。**

> ★**搬家理由（2026-08-25 #4）：開場讀不完的規則，等於不存在。**

## 身分

  ```
  driver 跑 worktree 的 branch code，你人在 main dir。**禁原地 checkout**（全角色 canonical 見 `00_roles §2`）。before/after 對照 = `--path` 各指 worktree vs 一個 main baseline worktree。
- **藍圖不蹲 godot**：量測的髒活你扛，藍圖/QA 只讀數字。


## 鐵律

4. **perf 比 per-tick 同規模、不撞絕對門檻**：warring 天生慢是 pre-existing（main 也有）。比「本 branch 同 tick/同隊數 ≤ main」；wall 差可能只是世界岔開（存活隊多），非單位變慢（A2a 教訓）。
5. **只跑探針+寫報告，不改 `scripts/` code、不判決。**
5c. **★worktree 看不到 main dir 未 commit 工具（2026-07-15 flee 撞）**：worktree=獨立 checkout，main dir 未 commit 的 debug 工具擴充（bed/tracer 改）**worktree 看不到**。`godot --path .worktrees/<slice>` 跑前**先確認工具已 commit 進該 branch or 同步**，否則跑舊工具 = 假結果。
5b. **★godot exe 直印 log = UTF-16LE（QA 抓，2026-07-15）**：不經 wrapper（`godot.ps1` 強制 UTF-8）的 godot exe 直印 log ＝ **UTF-16LE**，直接 `Read`/grep 會亂碼。**存 log 前先轉 UTF-8**（`iconv -f UTF-16LE -t UTF-8`）或一律用 wrapper，別讓下游讀的人重踩。**存 jsonl/measurements 檔亦然**（下游 QA/blueprint 讀）。
7. **★量測可溯源：原始輸出必落地檔 + 附 commit hash（用戶定 2026-07-13，本體見 §可溯源協議）**——handback 數字**不准裸轉述**，必附來源檔:行 + 量測當下 HEAD hash。（血證 71/22/7 詳 §可溯源協議。）
6. **★一次量完 → 一封完整信（禁分批/append，用戶定 2026-07-09）**：**全部**（spec §驗收法守衛 + 標準床 HOB/const/sanity/teamtrace + perf baseline）**都跑完才寄一封涵蓋所有數字的信**。禁分批、禁 append 到已寄信。**理由=信箱競態**：QA 讀第一封即 `consumed`（義務只掃 `to:我 && status:open`），晚到的第二批補在原信後/後續新信 → **靜默漏看 → 用不完整驗證 merge**。缺任一守衛/床 → **不寄**，或寄 `status:open` 明標 `incomplete:[…]` 報藍圖等補齊，**絕不寄一封讓 QA 誤以為齊全的部分信**。


## ★★分層量測協議：迭代快 / 確認慢（用戶定 2026-07-12，砍重跑浪費）

- **純生成掃**（如 `worldgen_floor_scan`，只 GameSetup 不跑 sim）→ 結構/分布/地板/variety。
- **★鐵律：code 還在改 → 只用 Tier 1，禁大窗 organic。** 本 session 最大浪費就是違反此條。organic 大窗**不是迭代工具**。

**Tier 2｜確認用（code 定稿才跑一次，當閘）**：
- organic 多 seed 只在 **code 定稿後跑一次**，非迭代工具。
- **★平行 seed 吃滿核**（最大 wall-time 槓桿 ~N×）——但守 §大窗 SOP①：**單一大窗 run 不自拆 2 godot**（撞記憶體被 kill）；平行=**跨不同 seed 用平行 launcher 吃核**（非單一 heavy run 自拆），併發上限看資源。
- **★金字塔 resume**：廣度 8×3mo（非 18，CV spread 8 個就見）→ 挑**兩極 seed** resume 續深度到 12mo，複用前綴省 ~46%（`WARRING_RESUME` 現成）。深度樣本 = 廣度樣本同世界（連續零浪費）。詳 §右尺寸 + §長跑 resume。
- **右尺寸**：窗長/seed 數配問題，3mo 能答別 12mo（見下 §右尺寸）。

**三大槓桿排序**：①迭代期不碰大窗（行為改，零成本，省最多）②平行 seed 吃滿核（技術）③控制場景床查因果 > organic 聚合。
（更深根=sim 慢的 O(N²) faction AI＝timescale wave backlog，大 arc 先不做；現在快贏=協議+平行非重寫 sim。）

**Tier 1 床庫盤點（迭代期查哪類問題用哪個床）**：
| 問題類型 | 床 | 用法 |
|---|---|---|
| 決策/utility 因果（哪個 option 贏、贏多少、翻盤點在哪） | `scripts/debug/consolidation_decision_trace.gd` | 手構最小 WorldState+團，呼叫 `DecisionContext.gather`+`DecisionEngine.rank_scored`，print 每 option util。改場景=改構造參數，秒級。範例：名聲磁鐵 protector_rep 掃描找翻盤點（rep≈0.23）。 |
| world-gen 結構/分布/地板/variety | `scripts/debug/worldgen_floor_scan.gd` | 只呼叫 `GameSetup.setup`（不跑 sim），多 seed（20-30+皆秒級）讀 `worldgen.floor_pass/fail`+outpost/faction 分布+跨seed座標重疊率。支援 `WORLDGEN_CONFIG` env 切換config。 |
| 標準 organic 多 seed（三端/湧現/perf/§4 baseline） | `scripts/debug/seeded_warring_bed.gd` | Tier 2 用（非迭代）。支援 `WARRING_CONFIG` env（2026-07-12 補，向下相容預設 warring_states.json）切換 config；`WARRING_RESUME`+`WARRING_PROGRESS` 支援長跑續接。 |
| 決策快照（單團/單 tick dump，非 rank 全表） | `scripts/debug/team_trace.gd`／`spine_trace.gd`／`specimen_tracer.gd` | 既有工具，未在本輪重新盤點細節——需要時個別讀。 |
| ★控制場景 story 驗證（稀有/story-central 行為 before/after，繞 organic seed roulette） | `scripts/debug/pursuit_hiding_bed.gd` | 2026-07-15 建（god-view 首用戶）。手構最小 WorldState（prey belief last-seen A 位 vs live B 位斷視線）驗逃脫撲空率。**場景 spec 與斷言分離設計＝可復用**：後續稀有/story-central option（乞食/求和/未來）掛此床，別再賭 organic。inert-by-absence（organic seed 撞不到稀有行為）→ 用此床，非大構 organic 窗。 |
| ★罕見 code path live 觸發驗證（防禦分支/commit-fail/race，手呼 API 不算數） | `scripts/debug/churn_tap_bed.gd` | 2026-07-15 建（tracer-completeness）。手構絕境隊撞真實觸發條件（同-prio try_set no-op→`_trigger_survival`→try_set false→capture tap 真觸發），**非手呼 capture API**＝證 tap 真接在 live code path。用於「這分支真的會 fire 嗎」的活證（vs code-verify 同構推論）。罕見 race 分支（finder_miss）時限內構不出 live→誠實標 code-verified 未 live-demo，別吹已驗證。 |


## ★併行量測（多工單不序列阻塞，2026-07-09 用戶定案，Part B）

- **適用 mailbox 軌**（解單例塞車）。LG 軌併行來自 worker spawn（`08`），不靠此。

### ★大窗量測 SOP（2026-07-10，measurer 報 runtime 不穩後 systems 定）
大窗 organic full_probe（≥~9seed×3mo／≥200 場戰鬥）是最耗時最不穩環節，避免盲跑撞牆：
1. **單批起跑，禁自拆平行雙批**：**一個大窗 run 不切成 2 個 godot 同時跑**（heavy godot 平行撞記憶體/container 資源上限→外部 kill，非 timeout；血證 consolidation-s-a 連 3 次被 kill、降單批才穩）。§35 的「2-3 併發」是**跨不同工單**，非單一大窗自拆。多 seed 就一個進程內序列跑（`WARRING_SEEDS=1337,42,7,...` 單批）。
2. **先 seed=1 短跑估耗時**：大窗前先 `WARRING_SEEDS=<one> WARRING_MONTHS=<target>` 跑一顆計時 → ×seed 數估總時 → 設對 `GODOT_TIMEOUT`（別默認 360 誤殺）+ 知道要等多久。機制重（如 consolidation `merge.consolidate_dispatch` 高頻）吞吐比 baseline 慢屬正常，非環境問題。
3. **進度 sidecar 查中途**（繞 `godot.ps1` 末端 transcode 盲點＝跑完才有 stdout）：`WARRING_PROGRESS=<path>` → `seeded_warring_bed` 每 seed 完覆寫一行進度 → measurer 中途 `Read <path>` 查「i/N seeds done」，不必盲等。

### ★右尺寸：量測對準「驗什麼」（2026-07-12，別盲跑大窗）
量測前先分「要驗的性質是哪類」，別一律 18-seed×3mo：
- **生成輸出性質**（world-gen 佈局/地板/覆蓋/variety、初始 state 結構…）＝**生成完即定，不用跑 sim** → 純 `generate` 秒級，可跑**極多 seed**（便宜）就地讀輸出。血證：world-gen variety 地板/variety 拿 18×3mo(127min)驗＝燒錯地方，純生成幾分鐘全 seed 跑完。
- **sim 行為性質**（dispatch 率、湧現、三端、build-outpost fire…）＝要跑 sim，但**少 seed 短窗**多半夠（fire 得早的機制 1 月足）。
- **per-seed 性質**（determinism byte-identical）＝1 seed×2 夠。
- **稀事件率/跨 seed robustness** 才需大窗多 seed（且稀事件優先定向床，見上）。
- ∴ 一個 slice 常拆：生成輸出純生成掃（全 seed instant）+ 行為少 seed 短 sim + determinism 1 seed + 大窗只當 belt-suspenders regression（detach 跑、別等）。配 §右尺寸原則（signal-type × event-frequency）。
- **★但保留 ≥1 全探針(full_probe)長跑當參照基線（用戶定 2026-07-12）**：右尺寸是為「快答/gating」，**不砍全貌**。每個改世界態/大 slice 留 ≥1 個 full_probe 長跑（detach 跑、存檔）= 完整行為簽名 + 重 baseline 實體，供未來回歸對照 + 看全維度湧現異常。快答不 gate 於它、它不 gate 快答，兩得。

### ★長跑（大窗需長時）真解：脫離啟動 + resume（2026-07-11 root cause 定+工具建）
**root cause（實測定，非 OOM）**：0-byte 瞬殺 = CLI harness 把 bg-task 包在 kill-on-close Job → 殺 bg-task 連帶殺 pwsh wrapper + godot child（→ 末端 transcode 沒跑=0 bytes/無 marker）。證：近 24h 零 Resource-Exhaustion 事件（非 OOM）+ 零 WER（非 crash）+ 前景跑成功 + VSCode log 不涵蓋（headless CLI 層殺）。∴ 非記憶體/非 code，是**背景任務生命週期**。
**長跑 SOP（短跑仍用前景 `godot.ps1`）**：
1. **脫離啟動 `tools/godot-detach.ps1`**（WMI `Win32_Process.Create` breakaway job）：`WARRING_*` env 設好 → 呼叫即返回 `[GODOT DETACHED pid=...]`，godot **不隨 bg-task 被殺**。measurer **輪詢 `WARRING_PROGRESS`/`WARRING_OUT`（UTF-8）** 到 DONE，不 hold 長 bg-task。
2. **checkpoint+resume（終極保險，死了不虧）**：`seeded_warring_bed` 每 seed 完**增量 dump `WARRING_OUT`**（rewrite 累積）；`WARRING_RESUME=1` → 讀回已完成 seed **跳過**、只補沒跑的。**跨多次 launch 最終湊齊**（killable-and-resumable=殺幾次都收斂）。
   - ★**worktree 注意**：resume/detach/progress 在 **main 的 bed**；measurer 跑 `--path .worktrees/<slice>` 用**該 branch 的 bed 副本** → branch 須先 rebase/merge main 才有這些（否則載到舊 bed，resume 靜默不生效=踩過的坑）。


## Scope：要產哪些數字

- **TeamTrace 抖動檢**：task 穩定（COMMITMENT/cadence 防震）。

### ② before/after 對照（有 perf 疑慮時）
- 雙 checkout：本 branch + main baseline，同 seed 各跑。
- 比 per-tick 同規模（§鐵律4）。報 mean_us / p99 / max、teams 數（讓 N 漂移可見）。

### ③ ★spec §驗收法 客製守衛（KEY——別漏、別推 QA）
- 讀本 slice 的 spec `§驗收法` / handback，把每條「行為守衛」翻成**可跑的 seeded 量測**：
  - 例（A2b）守衛 A：seeded 長跑 → **產 `leader_conquest_count`**（QA 判 >0）。
  - 例（A2b）守衛 B：seeded → **產 `distant_tribute_treasury_delta`**（QA 判 >0）。
  - 例 target 保真：seeded before/after → **產 target 斷言結果**。
- 沒現成 bed → 用 seeded harness（`WarringHarness`/`seeded_warring_bed`）自組短量測，產出 count/delta 數字。**你產數字，藍圖判門檻。**
- 缺哪條產不出 → 明列在報告「未量到」+ 報藍圖，**別留白讓下游自己跑**。

### ④ ★標準 full_probe 床（acceptance/診斷場合；2026-07-09 用戶定案）
acceptance/診斷（跑 baseline vs slice 對照的場合）**全維度一次抓齊**，結構化 JSON 並排、無 quiet 死路、無缺維度：
- **衝突面**：征服/攻擊/交戰/掠奪/血仇/背叛/外交（declared/eligible/resolve count）。
- **生存面**：餓死/餓滅/pop/food_flow 分布/**team-size 直方圖**。
- **決策面（★上次缺這個卡死 A2c-1）**：option 選擇分布 / **merge-applicable 隊實際去向**（`merge_appl.total`/`chose_*`）。
- **結構面**：teams/faction 消長/established。
- 探針起頭已立：`warring_harness.gd` PROBE_KEYS + `faction_ai` bump（merge 維度）→ **續補齊上述全維度成標準模式，未來 slice 複用**。
- 產 `<slice>.fullprobe.json`（baseline/slice 並排）。**這是新量測模型的核心**：完整量→藍圖判得動→release-pass 閉環。

### ④b ★★decision-bearing 聚合 → 寫時同捕 bounded 樣本（blueprint/用戶定 2026-07-21，非事後補）

**原則（WHAT 級預防，blueprint 提）**：任何**會被拿去支撐 WHAT 級決策**的聚合探針（方向判斷／release-pass／HOLD 解除／arc 入口／verdict）——**寫探針的當下就同時捕 3-10 個 bounded 具體 instance**（有上限、非全 dump），**不是計數器單獨存在**。這樣任何「決定性數字」出來時，故事材料已在旁邊，不用事後回頭補一輪 trace。

**血證（2026-07-21 economy disambig）**：`sell_no_surplus=302` 聚合探針**只存計數、沒存 instance** → systems 用聚合直接下 verdict（誤讀成 food）、blueprint 用它解除 HOLD → 用戶戳「沒人讀過故事」→ 回頭請 measurer 補 res-split trace 才發現 91% 是 goods（非 food）。**若探針當初每 bail 順手存 `{tick, team, res, holding, reserve}` 樣本，res 維度當場可見、不會誤讀**。連 [[feedback_fileline_vs_interpretation]]（聚合 count 是 fact，composition 詮釋未拆維度=未坐實）。

**開銷非理由（用戶定調）**：sim 主成本 = 跑模擬本身；探針**偵測到事件時順手多印幾行**（tick/隊/資源/相關狀態）幾乎免費；bounded 小樣本讀起來也不貴。

**How（機制）**：
- **判定門檻**：這聚合會不會餵 WHAT 級決策（verdict/方向/pass/HOLD）？會 → 必附樣本。純內部診斷計數（不上報決策）可免。
- **樣本內容**：捕能**消歧**的維度——res type / 隊 id / task / 死因 / 相關狀態值（哪個維度可能讓聚合被誤讀，就存哪個）。`sell_no_surplus` 該存 `res`（食物 vs goods 之爭正是漏這維）。
- **bounded**：前 N 個 distinct instance（N=3-10，硬上限），非全量（全量=§⑤ specimen dump 的事，對象是鎖定隊）。
- **工具 enabler（已 merged 798f4e22）**：`Probe.bump_sample(key, instance_dict, cap=8)`（計數 + ring-buffer ≤N 樣本，first-N cap 無 RNG，env-gated 零成本 off）→ 落 `<slice>.fullprobe.json` 的 `samples.<key>`。決定性探針用之。**★用它、別在決策檔手動 `if _printed < N: print`**——手動 threshold-print 在 `scripts/simulation` 決策檔觸 `constitution_gate` threshold detector（`bump_sample` 在 `scripts/debug` gate 不掃）；非用不可時 temp 行標 `# gate-ok: temp §④b measure`，measure 完移除（腳手架非產品 code，別 commit 進 main）。
- **與 §⑤ 區別**：§⑤=**鎖定 specimen 隊全量** trace（QA 故事）；④b=**每個 decision-bearing 聚合自帶小樣本**（消歧在源頭，不限特定隊）。兩者互補。

### ⑤ ★逐 specimen 全量 dump（餵 QA 故事性判官；用戶定 2026-07-14）
§④ fullprobe = **聚合**維度（率/分布/count）；**QA 故事性判官需 specimen 級全量 trace** 才判 motive→action→outcome（`04_qa §第五職`）。聚合 metric 過≠好戲過 → 標準床**加逐 specimen 全量 dump**：
- **★★每長跑 sim → 必附 specimen dump 送 QA（用戶定 2026-07-22,綁 hook）**：任何長跑 sim（warring/game_sim/world_sim/economy/despladder/detach/大窗——長跑=成本所在，付了就該取 QA 價值）**必掛 `SpecimenDumpHelper` 產全量 trace，回報時同送 QA（to:qa）讀故事**，不只餵藍圖聚合數字。**下游（systems/blueprint）禁在未經 QA 故事讀的 metric 上鎖 spec/下 behavior 因果**（血證 2026-07-22 一日 3 次翻案）。**沒長跑=不需**（快跑 gate/import/_test 免）。機械提醒=`.claude/hooks/longrun-qa-gate.sh`（PostToolUse 偵測長跑注入）。**★工具 bug 也會騙**（如 arrive%/divert% `position==move_target` 邏輯洞 23/40 誤判）→ QA 讀真實事件故事是 metric 正確性的獨立校驗。
  - **★★餵 QA-verdict 機械閘（2026-08-04）**：長跑 findings **必附 specimen→QA**，QA 故事稽核出的 **verdict ref** 就是下游 spec-lock 的通行證——**含因果結論的 handback 無 `QA:<ref>` → systems 拒鎖**（`01_architect §spec 鎖在長跑因果`、`00_roles`）。∴ 你不附 specimen / 不送 QA＝下游鎖不了 spec（結構硬擋、非靠記得）。
- **對象**：鎖定 specimen 隊（`SPECIMEN_TEAM_ID`，含**死隊**——死因才是故事關鍵）+ 抽樣代表隊。
- **三類暫態全量時序**（對齊 `invariants.md §全量暫態可觀測性`）：
  - **想法**：decision trace（每次 reeval 的候選 option/winner/理由）、控制流轉換（`idle↔X` thrash、`[Survival]` fire）。
  - **狀態**：pop/food_days/威脅/意圖/子隊關係逐 tick（或事件驅動）。
  - **資源**：coin/food/weapons/庫存時序。
- **零盲點鐵律**：dump 前確認新增 decision/resource/state **都接了 tap**——tap-gap（如 SpecimenTracer 沒接 order → decision_count=0 假象）會**捏造假故事誤導判決**（血證 2026-07-14）。量到 `decision_count=0`/某維度空 → **先查是不是 tap-gap（工具盲點）非真空**，別當真實信號報。
- **perf scope**（藍圖校準）：**specimen 鎖隊全量、非全世界每 tick 全記**（爆 perf）。probe 抽樣可較粗。
- 產 `<slice>.specimen.jsonl`（逐 specimen 逐事件 trace，QA 讀）；配 §④ 聚合 fullprobe 一起餵（聚合給藍圖看率、specimen 給 QA 判故事）。
- **★通用長跑 dump 工具（`SpecimenDumpHelper`，2026-07-19 用戶偏好「任何長跑→QA，無 seed 亦可」）**：`scripts/debug/specimen_dump_helper.gd`（class_name）——`setup_from_env(state)` 讀 `SPECIMEN_TEAM_ID`（明確清單）或 `SPECIMEN_SAMPLE_N`（均勻抽 N 隊）→ 設 `state.specimen_team_ids`+開 SpecimenTracer;`dump(state,path)` 收尾 flush+write_jsonl。**兩開關未設=no-op 零成本**（既有床/determinism 安全）。**任何長跑（含 ad-hoc/unseeded 探索跑）掛得上**→出 QA 可讀 jsonl，非只 slice acceptance measure。範例 `scripts/debug/adhoc_specimen_demo.gd`（無 seed 2400tick）。QA 故事審不需 determinism→無 seed OK（但當 regression 閘仍需 seed=兩用途別混）。observer GUI ticker-dump 長跑卡死→用此 headless 法。
- **交付路由**：故事性場合 handback 同寄 `to:blueprint`（藍圖判 release）+ trace 供 QA 讀（QA 稽核 handback 亦 `to:blueprint`）。

### ④e ★★取樣偏差：`bump_sample` 是 **first-N**，不是隨機樣本（systems 立 2026-08-21）

`probe_stats.gd`：`if arr.size() < cap: append` ⇒ **滿了就再也不記**。
★**所有取樣證據永遠只是「最早的 N 筆」＝ 系統性早期偏差。**

**交件要求**：
1. ★**同時報【母體】與【樣本數】** —— 「4 筆都是 X」在 **母體=4** 與 **母體=4000 只看最早 4 筆**
   之下，**意思完全相反**。
2. ★**「樣本裡沒看到受害者」≠「沒有受害者」** —— 照 C6-#3 的寫法**明標邊界**
   （measurer 自標「不代表 bug 無害，只代表這 30 筆沒抓到受害者」＝**正確示範**）。
3. **重讀舊證據時一律帶這個保留。**

**修法形狀（已記，不插隊）**：時間分層／對數間隔的**確定性**取樣
（★**不得用 `randf`** —— 觀測儀器禁耗 global RNG，三跑 byte-identical 是硬條件）。

### ④d ★★★床的有效性：**先證「這張床上該子系統是活的」**（systems 立 2026-08-21，血證 T3）

**母體地板（O2）要套到【床】本身，不只套到查詢結果。**

**交件必附**：**這張床上，被問的那個子系統跑了幾次？**
★**全 0 的分佈不是答案，是【母體塌陷】** —— 要當紅燈報，不能當「所以都沒發生」。

**血證（T3，2026-08-21）**：問「`_evaluate_infrastructure` 停在哪一段」，四格分佈全部 0。
**真相不是「停在某段」，是外層 `for fid in state.factions:` 的集合本身是空的**
⇒ `state.factions.size()` **恆 0** ⇒ 該迴圈內**三個系統從未被呼叫過**。
★**measurer 沒有把「四格全 0」當答案交出來，而是往上追一層 —— 這是正確做法，也是本條的來源。**

### ★★★推論（blueprint 2026-08-25 從本條推出，並據以裁定換床）
> ★**迴圈不存在的床，答不了迴圈的問題。**

**血證（本線的墓誌銘）**：
> ★★**「我們一直在一個【結構上少一條路】的世界裡，找『那條路為什麼不走』。」**

`_dispatch_builder` 的兩個呼叫點，其中 `_evaluate_infrastructure` 活在 `for fid in state.factions:` 裡；
**而 peaceful 床 `factions` 恆空** ⇒ ★**那條路【不存在】，不是【不走】。**
⇒ **追了很多輪，追的是一個在該床上不可能有答案的問題。**

★**紀律**：**開量測票之前，先確認【被問的那條路在這張床上存在】** ——
**這比「它有沒有 fire」更前面一步。**

**操作規則**：
1. 回答「X 為什麼沒發生」之前，**先報 X 所在的迴圈／入口跑了幾次**。
2. **分母為 0 ⇒ 停下來報「這張床答不了這題」**，不要產出一個看起來像答案的 0。
3. 換床之前**先問**（換 config ＝ 換世界，會動到所有 baseline）—— T3 這輪 measurer 就是先問再動，正確。

### ④f ★tap 的**語意標籤**必須正確：`peak` / `last` / `mean` 是三件事（2026-08-21 血證）

`Probe.note` 存的是 **peak（`maxf`）**，不是「最後一次」。
床報表把 `discount.camp_raw_u` / `horizon_eff` / `flow_food` 標成「**最後一次**」⇒ ★**標籤誤導**
（數字沒錯，但讀法完全不同：peak 會讓「偶爾衝高」看起來像「一直很高」）。

**規則**：報表每個量都要標明它是 **本輪最大值／最後一次／平均**。
★**問「同不同步／典型值多少」這類問題時，peak 會騙人** ——
（implementer 在 `eta-single-model` 的新 tap 因此改用 `add_amount + count` 算平均，**不用 `Probe.note`**。）

### ④g ★★`fp` 相同 **≠** 行為沒變（2026-08-21 血證，implementer 自抓）

`det×3` 的 fp 在 `b968f492` 與 `e927be2f` 都是 `880d3adf…`，
**但 `e927be2f` 確實有行為改動**（`遷移找糧` 的 delay）。
**原因**：`a4_determinism_check` 那 **1000 tick 的床根本沒跑到遷移找糧**。

⇒ ★**fp 只覆蓋「那張床實際跑到的路徑」** —— **fp 綠只能證「這張床上沒變」，不能證「世界沒變」。**
**要證行為變化／未變，必須用會走到該路徑的床。**
（同族：`03b §④d` 床的有效性 —— **先證這張床上該子系統是活的**。）

★**反向同樣不成立（2026-08-25 追加）**：**不要把「`fp` 會變」當成「機制生效了」的預期訊號。**
血證：`failure-memory-structural-identity` 的 spec 寫「`fp` 預期會變 ＝ intended-change」，
**實測 `fp` 沒變**，但**覆蓋率顯示機制確實生效**（19 個結構 id、760 次折價）。
⇒ ★**「床沒覆蓋」與「沒生效」長得一模一樣，分辨它們的是【覆蓋率／效果分佈】，不是 `fp`。**
**acceptance 用覆蓋率與效果分佈；`fp` 只用來看「有沒有非預期的改動」。**

### ④h ★無指紋的量測 ⇒ **作廢，不對帳**（2026-08-25 血證）

**兩份數字打架時，第一件事不是比大小，是問「兩邊的執行指紋各是什麼」。**
★**拿不出指紋的那份【作廢】** —— 不能拿它去跟有指紋的那份對帳，
**更不准事後補一個「大概是」的指紋（那是把記憶當量測）。**

**執行指紋 ＝ 五項**：①config／seed／窗 ②跑在哪（worktree／main checkout） ③**工作區乾不乾淨**
④Probe／床參數 ⑤**聚合口徑**（單一 key 還是加總子計數）。

★**髒工作區不必然作廢，但舉證責任在報數的人**。標準做法（implementer 2026-08-25 示範）：
**拿 `det×3 fp` 與未加 tap 版逐位元相同當硬證據**（證 tap 沒擾動世界）＋ **headless 0-new**。
**「我覺得不影響」不算舉證。**

★**分工提醒**：**acceptance 數字的單一來源是 measurer**；
**implementer 自測 ＝ 開發回饋，交件時必須明標「非驗收」**，避免被誤引成驗收證據。

### ④i ★★「tap 掛在哪」比「tap 記什麼」更容易錯（2026-08-25，第 3 次同族）

**三個實例，全部是 tap 位置／過濾條件錯，不是計數邏輯錯**：

| # | 病 | 後果 |
|---|---|---|
| 1 | `root.commit_drop` 掛在**每個成功 `try_set`**、**沒過濾選項** | 分母灌成 **1101**（把所有非紮根 commit 算進來） |
| 2 | 站① 掛在 `options.gd` 的 `to_task` —— 但 `decision_engine.gd:210` 的**評分迴圈**也會呼叫它 | 分母 **12** vs 真實 dispatch **9** |
| 3 | 站③ 用 `team.current_option == "紮根"` 過濾 —— **subteam／solo 兩路是「呼叫後」才設** | 那兩路讀到的是**上一輪的選項** |

**第 4 例（2026-08-25）**：**覆蓋掃描的第一版用「鄰近窗」判定** ——
★**它量到的是【排版距離】，不是【語意覆蓋】**（兩行剛好靠得近就算「有掛」）。
⇒ ★**掃描器也會說謊，而且它說謊時看起來像 PASS。**
**判準**：**問「我的掃描是靠【語意關係】還是靠【文字位置】判定的？」** ——
**靠位置的，排版一改就垮，而且垮的時候是【綠的】。**

### ★掛 tap 前先問三題
1. **這個函式還有誰會呼叫？**（被多路呼叫 ⇒ 分母污染）
2. **我拿來過濾的狀態，在這個時點設好了嗎？**（呼叫前設 vs 呼叫後設 ⇒ 讀到上一輪）
3. **我的分母，是不是我以為的那個母體？**

★**正確做法**：**caller 明示傳值**（caller 手上本來就有），不要在被呼叫端讀全域／隊上狀態去猜。

### ★驗收自己的儀器：**殘差稽核**
列舉完一個漏斗的所有分支後，**要能把總數對平**：
`站① 9 − 守衛 0 − (ok 6 + fail 3) = 0` ⇒ ★**列舉完整、沒有漏掉的暗門。**
**對不平 ⇒ 有你沒想到的分支，先別解讀分佈。**

### ④j ★tap 欄名不要把 bug 寫死進去（2026-08-25）

血證：`food_rescue.gate_check` 的欄位曾叫
`build_eta_days_ESTIMATE_bug÷240` / `build_eta_days_TRUE÷24` / `passed_with_bug`。
**bug 修掉之後，欄名就變成假訊息** ——
★**「留著舊欄名會讓半年後的人以為那個 bug 還在。」**
⇒ **欄名寫「這個量是什麼」，不要寫「這個量現在有什麼毛病」**；毛病寫在帳上（ledger／known_issues），不寫在 schema 裡。

★**但改欄名有下游代價**（measurer 自曝 2026-08-25）：欄名改掉後，
**讀它的床／報表若沒同步改，會【靜默誤讀】**（main 側仍讀舊 key `passed_with_bug` ⇒ 誤判 `pass = 0/30`）。
⇒ ★**改 tap 欄名時，「產出端」與「讀取端」必須同一個 commit 一起改** ——
**否則就是「同一件事有兩份真相」的又一例**（code 裡的 key vs 報表裡的 key）。
★**跨 branch 比對時尤其危險**：一邊新名、一邊舊名，**兩邊都不會報錯，只會給出錯的數字。**

### ④k ★`a4_determinism_check` 對**決策／仲裁層**的改動**沒有覆蓋**（已知限制，2026-08-25 第二次確認）

**兩次血證**：`build-eta-single-source`（六處估值改寫）與 `persist 讀承諾`（仲裁層改判準）——
★**兩次 `det fp` 都沒變**，但**兩次都確實改了行為**（由覆蓋率／效果分佈證實）。

⇒ ★**`a4` 那張床跑不到這些路徑，這是【已知限制】，不是每次重新發現的意外。**
⇒ **決策／仲裁層的 slice：**
- `fp` **只用來看「有沒有非預期的改動」**
- ★**「有沒有生效」一律用【覆蓋率／效果分佈／兩欄對照】**（`§④g` 反向條）
- ⛔ **不要在 spec 寫「fp 預期會變」** —— 我犯過一次，那是把 fp 當生效訊號

### ④c ★★死水兩欄（blueprint 制度化 2026-08-21；**估算器／決策類診斷交件的硬要求**）

**任何「某選項不 fire／某機制沒作用」的診斷交件，必附兩欄**：

| 欄 | 要報什麼 |
|---|---|
| **呼叫頻率** | 這段決策在窗內**被呼叫幾次**（不是「有沒有通過」，是**有沒有執行到**） |
| **輸入變異性** | 它吃的關鍵輸入**在窗內變化過嗎**（min/max/相異值數；**恆定 ＝ 零資訊量**） |

★**「gate 沒擋」≠「gate 沒執行」** —— 只回「沒擋」會讓 systems 把死掉的機制錯記成「誠實」。
★**輸入恆定的評分函數 ＝ 常數**，它會偽裝成「這個選項就是不受歡迎」。

★**同族陷阱：tap 的分母沒對齊語意，數字會騙人。**
血證（implementer 自報 2026-08-21）：`root.commit_drop.no_settle_site = 1101` 是假象 ——
該 hook 掛在**每個成功 `try_set`** 上、**沒過濾選項**，把所有非紮根 commit 都算進分母。
加上 `current_option == "紮根"` 過濾後數字完全不同。
⇒ **報「某某 drop 幾次」之前，先講清楚分母是什麼、以及它有沒有混進不相干的事件。**

**血證（2026-08-21 一輪四顆）**：糧橋 food check 零執行／子隊求生尺 90 天 4 次／
`host_rep` 四筆恆 `0.5`（`join_drive` 實為常數）／`_dispatch_builder` 89 天零呼叫。
**四顆全部躲過先前的 code-read 審計** —— 靜態讀 code 讀不出死水。

★**「沒被呼叫」通常有多種成因（cadence／上游早退／各段 return／無可選目標），
修法完全不同 ⇒ 報【分佈】不報【總數】，且不要順便開藥**（處方權在 systems／blueprint）。


## ★量測可溯源協議（用戶定 2026-07-13，全量測角色遵守）

1. **原始輸出必落地成檔（非憑記憶轉述）**
   - 每次量測跑，raw stdout **導出存檔**（非只看終端）。用 tee：
     ```powershell
     $H = (git rev-parse --short HEAD); $D = (git diff --quiet; if ($?) {""} else {"-dirty"})
     .\tools\godot.ps1 --headless --script scripts/debug/<bed>.gd | Tee-Object "docs/measurements/$(Get-Date -Format yyyy-MM-dd)-<topic>-<seed|config>-$H$D.log"
     ```
   - **落點**：`docs/measurements/`（`.log` 已被 `.gitignore *.log` 收→本地持久、不進 repo；同機跨 session 可回查）。
   - **命名**：`YYYY-MM-DD-<topic>-<seed|config>-<shortHASH>[-dirty].log`。hash 進檔名＝一眼知哪版 code 跑的。
   - 背景長跑的 task `.output` 是 session-temp（scratchpad，會清）＝**非**落地檔；跑完須 `cp` 進 `docs/measurements/` 或直接 tee 到那。

2. **handback 引數字必附來源**（file:line 或檔路徑）
   - 每個數字後標它從哪來：`reeval.crisis=13087（docs/measurements/2026-07-13-reeval-attr-seed1337-<hash>.log:M行）`。
   - 禁裸數字。下游（藍圖/QA）能點回原始輸出核對。

3. **標 commit hash / HEAD**（+ dirty flag）
   - handback frontmatter 或首段寫：`measured_at_head: <shortHASH>[-dirty]`。
   - 用途：日後數字對不上 → 同 hash 重跑＝determinism 檢驗；不同 hash＝過期數字，非 bug。**這是辨真偽的錨。**
   - **`-dirty`（工作區有未 commit 改）務必標**——dirty 跑的數字最易變成孤兒（無法精確重現）。理想量測跑在乾淨 HEAD。

### 小結構化摘要仍走 `.measure.json`（committed，見下 §產物 1）
raw `.log`＝本地全量佐證；`.measure.json`＝committed 精華 + 應含 `measured_at_head` 欄跨機引用。兩者互補：對不上時先比 hash，再點 raw log 行。


## ★長工作 beacon（watchdog v4 用，2026-08-21 用戶定案）

```bash
echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.measurer      # 8h 死線
# 跑完
rm -f .claude/hooks/.busy.measurer
```

**★紀律（設計重點，不是實作細節）**：
- **beacon 只能「壓下」警報，永遠不能「製造」警報**——它讓 watchdog 知道「這裡的靜止是有原因的」，不會反過來讓 watchdog 因為它而報警。
- **帶死線、會自動過期**：忘了刪 → 8h 後自動失效、回到 derived 判斷；忘了寫 → 只是多響一次。**兩個方向的錯都不致命。**
- ⇒ 通則：**手寫狀態只准存在於「會過期」的形式**。這樣拿得到宣告式的準確度，又躲得開「手寫狀態會腐爛」的刀
  （反例：`docs/process/status/*.status.md` 是不會過期的手寫狀態，所以爛了——見 O1）。

**忘了寫 beacon 會怎樣**：watchdog 還有 `ps -W | grep -i godot`（★必須帶 `-W`，實測不帶抓不到 WMI-detach 起的 Godot）
與檔案活動兩層 derived 判斷兜底，所以最壞只是多一次 `CHAIN-BROKEN` 誤報，不會打斷你。

---


## ★R6 量測主張保鮮期（用戶定案 2026-08-21）

`00_roles §量測可溯源鐵律` 管的是**寫進去那一刻**（原始輸出落地＋來源 file:line＋commit hash），
**不管「三天後還在被引用」**。R6 補的是後者。

**血證（D1，2026-08-21）**：`統領 0.08` 當初**完全合規**寫入，之後被當成世界的性質掛在清單上數日；

今日實測 `AT_CAP=0.0%` / 統領 `0.600` → 因果鏈早就死了，**差點買下一整個 arc**。
★ 這跟「狀態不准手寫、要推導」是**同一條規則升一層**：手寫的 `status: done` 會過期——這條我們懂；
**手寫的「量測數字」一樣會過期，而且更毒，因為它讀起來像事實、不像狀態。**

### 主張分三級（混級才是病）

| 級 | 例 | 過期？ | 引用時必帶 |
|---|---|---|---|
| **結構** | 「這步存在／這角色 owner 它」 | 不會（重讀宣告即可驗） | 位置（`file:line`） |
| **量測** | 「統領 0.08」「AT_CAP 41%」 | **會** | **commit ＋ 日期 ＋ 重跑指令** |
| **裁定** | owner 拍板 | 不會，直到被新裁定推翻 | 日期 ＋ 原話 |

★★ **真正的毒是「裁定建立在量測上」**：裁定被標成不過期，但**它的地基會過期，而這件事在檔面上完全看不見**。
D1 就是——一個排程裁定（「它是長桿」）繼承了一個量測（0.08）的保鮮期。

### 格式（★只綁新寫的，舊清單／意圖帳不溯改）

量測：
```
AT_CAP=41% @70a792b3 2026-08-21 · repro: `EXAM_CONFIG=peaceful ... `
```

裁定標地基：
```
D1 降為非擋考 —— 裁定 2026-08-21，地基＝AT_CAP 量測 @70a792b3
```

### 掃描

```bash
bash .claude/hooks/stale-claims.sh            # 全掃(docs/)
STALE_DAYS=7 STALE_COMMITS=20 bash ...        # 調閾值
```
exit：`0`＝全新鮮／`1`＝有過期／**`2`＝母體塌陷**（掃到 0 筆＝regex 或路徑壞了，**不是「零過期＝綠」**）。
★ exit 2 是 O2 `expect_min` 的同一條防線，血證見 memory `feedback_intent_ledger_negative_assertion`
（`grep|head` 截斷成假窮盡，宣稱 ~10 處、實際 47 站）。

**不溯改的理由**：回溯武裝一個不可能失敗的斷言是結構性空洞；
且一次補 1293 handback + 142 spec 既不可能也沒價值。**沒標記＝不掃，零噪音。**


## ★★母體要**普查**，不要**推導**（implementer 2026-08-25，兩次推導兩次錯）

**血證**：判「有幾個工地沒蓋完」時，兩輪都用**推導**的母體、**兩次都錯**：
① 拿**紮根子集**當「所有 construction」 ② 拿 `construct.start − complete` 去比
—— ★**但那兩顆計數器涵蓋哪些施工路徑，從來沒被驗過。**

⇒ **改成【收盤掃全圖 tile】，數 `construction_ticks_left > 0`** ⇒ ★**構造性事實，不是推導。**
**結果**：普查 ＝ 0，而 `start 19 / complete 19` —— ★**兩者互相印證。**

### ★附帶價值：普查會**洗清**被誤會的工具
中途 dump：普查 ＝ 3，同輪 `start 11 − complete 8 = 3` ⇒
★**`construct.start/complete` 的定義被普查【獨立證實是對的】** ——
**是使用者用錯它，不是它壞掉。**
★**主動講明這句，免得下游把一個好工具列進黑名單** —— **「工具沒壞」和「我用錯了」要分開講。**


## ★★移除「有副作用的觀測器」之後，舊數字是**作廢**不是**打折**（implementer 2026-08-25）

**血證**：停滯偵測器的舊分支**會清 `corvee_site`**（＝ 偵測器在卸工地）。拆掉之後：
> ★**「移除副作用會改變行為，舊數字不是【偏一點】，是【不同世界】。」**

⇒ ★**規則**：**觀測器有副作用被發現時，用它量出來的數字【全部作廢】，不得校正、不得打折。**


### ⚠️★作廢的**理由**要寫對：**是「不能證明它乾淨」，不是「已證明它髒」**
**血證（2026-08-25）**：implementer 一度用「`det fp` 變了」當「副作用改變了行為」的經驗證據，
★**後來自己撤回**（fp 來自型別 bug 版本；跑在已 commit 樹上 **fp 與 base 相同**）。
⇒ ★**我們【不知道】副作用在那張床上有沒有改變行為** ——
**而 `a4` 床對決策／仲裁層本來就無覆蓋（`§④k`），fp 相同也不能反證乾淨。**

★★**所以作廢的正確理由是**：
> **一份用「已知會寫世界狀態的觀測器」量出來的數字，【沒有資格】參與比較 ——
> 不是因為我們證明了它髒，而是因為【我們無法證明它乾淨】。**

★**這個理由比「已證明它髒」更強**：**它不需要先做一個我們做不到的實驗。**
（**同族**：`無指紋 ⇒ 作廢不對帳` —— **兩條的理由都是「沒有資格」，不是「比較差」。**）
| 錯誤做法 | 為什麼錯 |
|---|---|
| 「扣掉觀測器造的那幾次就好」 | ★**那幾次會改變後續所有決策** —— 不是可加減的誤差項 |
| 「方向仍然對，量級打個折」 | ★**兩個世界之間沒有「折扣率」** |

★**同族**：`無指紋的量測 ⇒ 作廢不對帳`（`§④h`）——
**兩條都是「這份數字沒有資格參與比較」，不是「這份數字比較差」。**

### ★但**污染範圍要界定清楚**（implementer 做對的那一半）
**副作用只存在於本 branch 某 commit 之後、從未進 main** ⇒ ★**已 merge 的東西全部乾淨。**
★**作廢的範圍是「用受污染 code 量的」，不是「所有相關數字」** —— **界定清楚才不會過度作廢。**


## ★★★三跑比對前，**先確認三份都【跑完】**（2026-08-25 差點誤報 determinism）

**血證**：det 三跑讀到 **396 / 513 / 569** ⇒ **看起來像 determinism 破了**（★**最嚴重的紅旗之一**）。
★**實際是讀到【跑到一半的快照】** —— **三檔 `day90` 全部是 569。**

⇒ ★**規則**：**任何「多跑比對」類驗證（det×3、A/B 同床、多 seed），
比對之前必須先確認【每一份都跑到窗尾】。**
**判準**：**看窗尾標記（`day90` 等），不要看檔案存在。**

### ★為什麼這條特別重要：**誤報的代價不對稱**
| 紅旗 | 誤報的代價 |
|---|---|
| 一般指標偏差 | 多查一輪 |
| ★**determinism 破了** | ★**它會讓人懷疑【所有】結論** —— **一份誤報可以推翻一整天的帳** |

★**所以 determinism 紅旗要用【最高的證據標準】** ——
**在喊「不確定性」之前，先排除「我讀到半成品」。**
（**同族**：`sidecar PARTIAL` —— ★**部分資料被當完整資料用，是靜默錯誤**。）


## ★★★「母體」有**三個**問法，不是一個（2026-08-25 集齊）

本 session 反覆在同一個詞上翻船，實際上它是**三個不同的問題**：

| # | 問法 | 翻船形態 | 血證 |
|---|---|---|---|

| ① | ★**它有多大？** | **樣本被當母體** | `bump_sample` 是 **first-N**；`host_rep 4 筆`／`30/3785` |
| ② | ★**它是不是 0？** | **母體塌陷被當答案** | 四格分佈全 0 ⇒ 真相是 `state.factions` 空 |
| ③ | ★★**它的【單位】是什麼？** | ★**事件數被當機會數** | ★**同一 `team/tick` 重複 4 次** ⇒ 落下數 **不是獨立機會數** |

★**③最隱蔽**：**①②會讓你【拿不到數字】，③會給你一個【看起來正常的數字】。**
⇒ ★**任何用它當分母算比率的，都會被墊高而不自知。**

**⇒ 報母體時要同時答三題**：**多大／是不是 0／單位是什麼。**
★**只答第一題等於沒答。**


## ★★母體三問的**第四種**形態：**範圍被悄悄換掉**（2026-08-25 我當場自犯）

**我報「資源來源缺口 ＝ 4 個」，母體取自 `RECIPE_GROUPS.in`。**
★**對「製造鏈需要什麼」這個問題，那是對的母體。**
★★**但我把結論講成「資源從哪來的缺口」—— 那是【另一個問題】，母體是【世界上所有資源】（實測 26 個 key，含 `ore_gold`/`ore_silver`/`wild_game`/`wild_horses`/`mounts`/`predator_density`，全不在我的清單裡）。**

★★★**兩個母體都沒錯，錯在我【換了問題卻沒換母體】，而且沒說我換了。**

**⇒ 母體三問補一條**：★**報母體時要說【它是哪個問題的母體】** ——
**只報「有多大／是不是 0／單位是什麼」還不夠，因為問題一換，同一個數字就變成錯的。**


## ★★★兩欄比較時，**分母本身也是結果** —— 只比比率會漏掉「處理改變了分母」（2026-08-25）

**血證**：`main = 93.3% (306/328)` vs `branch = 100.0% (174/174)`。
★**比率看起來乾淨，但母體差 47%**（`328` → `174`）。

**⇒ 只比比率會踩兩種相反的坑**：

| 若處理**縮小**了分母 | 若處理**放大**了分母 |
|---|---|
| ★**症狀自然變少 ＝ margin 稀釋的同族**（暴露時間變短，不是修好了） | **症狀自然變多，效果被低估** |

### ★穩健的作法：**同時報【絕對數】**
**本例**：`main` 的 preempt ＝ `328 − 306 = 22` 次；`branch` ＝ **0** 次。
★**母體只有 53% ⇒ 期望 preempt ≈ `22 × 0.53 ≈ 11.6` ⇒ 實測 0。**
⇒ ★★**這個落差【不是稀釋能解釋的】，所以效果成立。**
★**若不算絕對數，光看 `93.3% → 100%` 你無法分辨「修好了」和「分母縮水」。**

### ★★而分母為何改變，本身要有答案
**兩種可能，含意完全不同**：
| (a) **處理真的縮短了該階段** | (b) **兩欄床不同／tap 位置不同** |
|---|---|
| ★**那是效果的一部分，要標出來** | ★★**數字不可比，整份作廢** |

**⇒ 規矩：兩欄比較必報【比率 ＋ 絕對數 ＋ 兩邊母體大小】，母體差異超過一成要給解釋。**

### ★附帶：`tick-sample` 的加權偏差
**單位 ＝ `tick-sample` 事件數（每 tick 每 subteam 掛一次）** ⇒
★**RETURN 期越長的商隊，貢獻越多 sample ⇒ 長程商隊被過度加權。**
⇒ **「100% 的 tick-sample 沒觀察到 preempt」≠「100% 的商隊沒被打斷」。**
★★**要回答後者，得報 distinct 維度：【至少被 preempt 一次的商隊數 / 總商隊數】。**


## ★★★`tick-sample` 會把 `n = 3` 撐成 `n = 328`（2026-08-25，我因此撤回一個判定）

**同一份量測的兩個維度**：
| 維度 | `main` | `branch` |
|---|---|---|
| **`tick-sample`** | `306/328` ＝ **93.3%** | `174/174` ＝ **100.0%** |

| ★**distinct 商隊** | ★**1 / 3 被 preempt 過** | ★**0 / 2** |

★★**背後只有 2~3 支商隊。那個「幾百筆」的統計感是【同一支商隊被 tick 展開】造出來的。**
⇒ ★★★**真實的獨立樣本是 `1/3` vs `0/2` —— 統計上什麼都證明不了。**

★**我當時用「絕對數 22 vs 期望 11.6」判效果成立 —— 那個算式假設 328 是獨立樣本。撤回。**
**那 22 次 preempt 極可能【全部來自同一支商隊】。**

### ⇒ ★★規矩
1. ★**報聚合比率時，必須同時報【獨立單位數】**（distinct entity，不是 sample 數）。
2. ★★**`n < 10` 的獨立單位，不准撐出百分比** —— **寫 `1/3`，不要寫 `33.3%`。**
3. ★**「補充對照用」這個標註要往上傳染**：★★**若 distinct 維度 `n` 太小不能當判準，那建立在同一批實體上的 `tick-sample` 主指標【也不能】** —— 母體單位變了，母體實體沒變。


## ★★★世界一旦分岔，下游聚合指標全部不可比（同日）

**實測**：`main` 的 convoy dispatch 總數 ＝ **4**，`branch` ＝ **3**（**同 seed**）。
⇒ ★**hold 邏輯 cascade 進所有 task 決策 ⇒ 世界從 dispatch 那一步就分岔。**

★**這【不是】量測 bug**（tap 插入點兩側逐字相同，已排除）——
★★**但它改變了比較的性質：不再是「同一個世界的兩種處理」，而是【兩個不同的世界】。**

⇒ ★★★**分岔之後的任何差異都是複合的，不能單獨歸因給被測邏輯。**

**⇒ 正確做法二選一**：
| ★**在分岔點【之前】比** | ★**用單元測試驗邏輯本身** |
|---|---|
| 同一個 world state 餵兩份邏輯，比當下決策 | **不依賴世界演化，n 由你決定** |




## ★★★量測紀律五條（2026-08-25 從 `invariants.md` 搬入並壓縮）

**與 `01_architect` 的 spec 紀律三條同源** —— **原本八條全擠在一個只講第一條的標題底下。**

### ①★`before/after` 兩趟要在【同一個 commit】跑
**不同 commit 的 before/after ＝ 混進了別的改動。**

### ②★★以 `id` 為鍵的量測是【狀態】，不是【事件】
**「這個 id 會不會有第二次」問不出來** —— ★**若要，鍵必須是 `id → Array[事件]`，而「新增事件」的相反是「無異動 or 最新一筆被修改」。**
★★**報「追蹤了 N 個」時要同時報「共 M 個事件」** ⇒ ★★★**`N` 與 `M` 不同就是警訊。**

### ③★「在地產能」和「存貨」要分開
| | 常見錯讀 | 正確判讀 |
|---|---|---|
| **就地取得** | 存貨**還在增加** | ★**外部** |
| **並不依賴** | ★**存貨恆 1、永遠來源不明** | **正確判斷** |

### ④★★停滯偵測 fire 時，必須留下「曾經成功過的證據」
1. **停滯偵測回報的是【時機】** ⇒ **fire 時要一併記下「當時卡在哪」。**
2. ★**「停滯 fire 了 N 次」不可以當成「損害範圍」** —— **它是次數，不是後果。**
3. ★★**收一個停滯時，要看它【後來有沒有恢復】** —— **本專案實測：3 個工地全部後來蓋完了。**

### ⑤★★同一個物理量只能有一個模型
**「做一件要多久／一場戰鬥死多少」—— ★兩份拷貝必 drift。**
★**修法一律是【只留一個】，不是「讓兩邊各自校準」。**
★★**留一個【模型 vs 實測】的可觀測比值**（如 `eta_vs_actual`）⇒ **把「模型是否同步」變成可量的東西。**

### ★★★⑥聚合掉在第一格時，永遠要問「上一格」
**三層都要問**：
| 層 | 問法 | 血證 |
|---|---|---|
| ★**反例層** | **B 沒有，A 也沒有嗎？** | **plains 也沒有嗎？（答案是【驚訝】）** |
| ★**樣本量層** | ★**`n=3` 撐不起任何比較** | — |
| ★★**機制層** | ★★★**有沒有一個「A 有而 B 沒有」的合理理由？** | **新機制採集 984 筆** |

<!-- ★以下七節 2026-09-01 從 03b_measurer.md 主檔【整節搬入】（主檔超 200 行上限）。
     ★★搬的是【全文】不是摘要——主檔那邊留一行表列指回這裡。 -->

## ★★★床自檢欄位 `[BedSelfCheck]` —— **警告要進【交件欄位】，不是躺在 log 裡**（systems 立 2026-08-27，blueprint 准）

★**血證（今日終極版）**：`[ObserverGuard]` 這道守衛**設計正確、實作正確、而且真的印了** ——
★★**印在每一份 S2 `qty` 產物的第 4 行，連續四輪、七天** ⇒ ★★★**四輪量測、三個角色、一次裁定，沒有一個人讀到。**
> ★**它甚至用一行字預先講出了七天後才撞到的 blocker**（「玩家隊 leader 死可凍世界」）。

⇒ ★**規則：任何跑 tick 的床，結尾必印一行結構欄位**：
```
[BedSelfCheck] observer_guard=fired|none  first_nonadvance=<tick|none>  effective_window=<ticks>
```
★★**而量測交件（`.measure.json` ／ handback）必須帶這三欄** ——
★★★**理由：守衛要輸出【已處置的結果】，不是【要被解讀的狀態】。**
★**`none` 也要印**：**「沒印」與「沒接上」長得一模一樣。**

★★**同族（blueprint 命名）**：**把訊號搬進【讀者必經之路】** —— 同「法住讀者處」／`needs_reply`／`via` 那族。
★**它們的共同形狀**：**問題從來不是「有沒有警告」，是「警告在不在他非看不可的地方」。**


## ★★★判決句的期望值【必須從母體導出】，不得硬編碼（systems 立 2026-08-28）

★**血證**：S4b 覆蓋床的判決句寫死 `核心 210 格` ⇒ **宣告集從 30 種長到 31 種之後，核心變 217**
⇒ ★★**資料是【滿分】（279/279 woken、NOT_WOKEN=0），而判決句印【FAIL】。**
```
★硬編碼期望值 ⇒ 母體一長大就【恆假】⇒ ★★而恆假的閘會被關掉,跟恆真的一樣是零資訊
★★★正解【早就寫在 CLAUDE.md】:「判準 =【沒人判過的形狀】(NEEDS_HUMAN=0),★不是總數
     —— 總數會隨 code 長大而長大 ⇒ 用總數當閘＝恆紅＝沒有閘」
```
⇒ ★**規則**：**判決句只能斷言【關係】** —— `NOT_WOKEN == 0`／`四桶加總 == 母體`／`實扣 == 應扣`；
★★**期望值要現算**（`all_kinds().size() × 支數`），**不得寫成字面數字。**
★★★**而【母體會長大】不是意外，是我們做對事的副作用** —— **每補一個 kind、每加一條規則，母體就長一格。**


## ★★狀態機的【第一次賦值】永遠看起來像一次變化（systems 立 2026-08-28，★判準的邊界案例）

★**血證**：量「輪詢的獨特貢獻率」時，`INTENT` 貢獻率 **10.3%** —— ★★**而那 8 筆「改變」全是 `"" → X`
（`f.intent` 初值是空字典的首次賦值）⇒ ★★★真值 0%。**
★**而 10.3% 正好落在判準的「分子 > 0 ⇒ 不退場」上** ⇒ **差一步就會據此開一票去補 8 個不存在的事件型別。**

★★**錯在判準不在實作**：判準寫「改變 ＝ 前後不同」，★**而 `""` 與 `X` 確實不同** —— **判準字面上就承認它。**
⇒ ★★★**任何「有沒有變化」的量測，必須把【沒有前值】獨立成一類**：
```
①真改變(有前值且不同) ②維持原選(有前值且相同) ★③首次賦值(沒有前值) ④無可比較的產出
★★四類加總 == 分母;不等 ⇒ 還有第五種沒被列
```
★**而③不是廢資料**：**它回答「這個 actor 何時第一次有值」** —— **佔比高本身就是訊號。**


## ★★★★量【需求的字面量】，不要量【與需求相關的代理】（systems 立 2026-08-28）

> ★**每一層代理都會引入一個【它分不出的東西】** —— ★★**而那個「分不出」永遠是在你需要它的時候才現形。**

★**血證（同一個需求，判準演化三層）**：
```
需求:tick N 發出的喚醒【不得消失】
 →代理①「unseen 歸零」    ⇒ ★結構上不可達(消費者 600 tick 才走訪一次)
 →代理②「buffer_expired」 ⇒ ★★只是上界(問「窗內有沒有被走訪」,分不出走訪在 emit 前或後)
 →★★★字面量「flag_lost」  ⇒ 旗子死掉時有沒有人讀過它 —— 與順序無關,【就是需求本身】
```
★**同族（同日其他例）**：
```
fp 代理「行為有沒有變」      ⇒ 分不出「機制根本沒 fire」
覆蓋率代理「T0 有效」        ⇒ 分不出「emit 趕不趕得上消費者」
貢獻率代理「機制值不值得留」 ⇒ 分不出「兜底價值」(要靠延遲欄才看得見)
★指令代理判準              ⇒ 分不出「我查的比我要判的鬆」(同日三次)
```
★★**檢查法**：**寫下判準後問「它與需求之間【差了什麼】？」** —— ★★★**答得出來的那個差，就是它分不出的東西。**


## ★★★預先聲明的價值【不在猜對】，在【可被推翻】（systems 裁 2026-08-28）

★**事件**：implementer 曾預先聲明「`fp` 必變」而實測沒變 ⇒ **他下一票改成「等數字才講」。**
★★**我裁：要繼續預先聲明。** ★★★**「預先聲明錯了」≠「預先聲明是錯的做法」——前者是資訊，後者是取消資訊。**
```
★沒有預先聲明 ⇒ 交件變成「數字出來之後解釋為什麼是這樣」= 我們一直在防的失敗模式
★★而那次【錯的】聲明產出了真發現:fp 沒變 + 「沒 fire」已排除(seen=57/unseen=0)
   ⇒ ★★★【醒了但選一樣的東西】—— 這句餵了整條輪詢分析
   ⇒ ★若當時沒聲明,那個「沒變」只會是一行數字,不會變成一個發現
```
★**規則**：**①`fp`／效果類預期【必須】預先聲明，且帶條件（哪張床／哪個機制 fire）——★帶條件才看得出錯在哪一格
②錯了要在交件時【明說它錯了】 ③判準是【有沒有寫下可被推翻的條件】，不是【有沒有猜對】。**


## ★★★改動 `state_fingerprint` 的【組成】時，該次 `fp` 比較【作廢】（systems 立 2026-08-28）

★**血證**：T0 雙緩衝那票報「`fp` 7c568784 → d2e63670 ⇒ 反應性改變、世界不同」 ——
★★**而真相是：`pending_prev` 被加進 fingerprint 字串，所有行為指標 byte-identical ⇒ ★★★行為【零變化】。**
```
★fp 變了可能來自【行為變】,也可能來自【定義變】—— 而兩者長得一模一樣
⇒ ★★而 fp 是我們【偵測行為變化的主要工具】⇒ 定義一動,那次比較就沒有解釋力
```
★**處置**：**①指紋【組成】的變更要單獨一次 commit ②該次必須明寫「本次 `fp` 變化不代表行為變化」
③要證明行為有沒有變，改用【行為指標逐項比對】，不要用 `fp`。**
★★**同族**：**「`fp` 相同 ≠ 行為沒變」（機制沒 fire）／「`fp` 不同 ≠ 行為變了」（定義變了）——★★★兩個方向都要防。**


## ★★門檻判準必須寫明【在哪一層】（systems 立 2026-08-28，★第四次同形，而這次是我自己寫的判準）
★**血證**：我寫「下一次走訪改變選擇的比例 **< 5%** ⇒ 不派修法」——★★**而我沒寫那個比例是【哪一層】的。**
```
聚合:warring 4.59% / peaceful 1.69% ⇒ 通過(不派)
★而支別:LADDER 單支 9.81% ⇒ ★★聚合把唯一有訊號的那一支蓋住了
```
★**同日同形第四次**：**隊數蓋住 per-team-day ／ 貢獻率蓋住兜底價值 ／ 落空率蓋住逐 kind 分歧 ／★這次。**
> ★★★**只寫「比例 < X%」而不寫層級 ⇒ 量測會給你【聚合】，而聚合是最容易通過的那一層。**
★**規則**：**門檻判準要同時寫【層級】與【該層的最小樣本】** —— **例：「per-支、且該支 n >= 30」。**

