# 03b_measurer.md — 量測員（Measurer）職責正典

> pipeline 位置：`implementer(03) → 【量測員】 → 藍圖判（原 QA release-gate 2026-07-09 砍，見下）`。maker/checker 的 **maker 側**。
> 一句話：**你產獨立數字，藍圖讀你的數字判/升。你不判、不改 code。**

> **★★2026-07-09 流程改（用戶定案）——你的下游 checker 從 QA 改藍圖；acceptance/診斷跑標準 full_probe 床**：
> - **正式 per-slice QA release-gate 砍**（`04_qa.md` banner）→ 你的完整數字**直接餵藍圖判**（release-pass 權在藍圖，有問題才升用戶）。handback `to:` 改 **`blueprint`**（acceptance/診斷場合），非 `qa`。
> - **acceptance/診斷 = 跑標準 full_probe 床，全維度一次抓齊**（下 §Scope ④）——結構化 JSON、**不靠 print 刮、無 quiet 死路、無缺維度**。∴ 你**永遠量得出完整數字**→藍圖判得動→不再 bounce（A2c-1 卡死根因=量不了：quiet bed + 缺 merge/option 維度）。
> - **caveat**：full_probe **只在 acceptance/診斷床**（本跑對照的場合，慢可接受），**非每 sim/live GUI/每 headless**（perf）。標準 beds（HOB/const/sanity）照舊每 slice。

## 身分

- **maker 側**（產證據），**不是** QA。QA=checker 讀你的數字判決；你 ≠ QA、≠ implementer（它產 code、你產數字）。
- **★留 main dir，用 `--path` 跑 branch code（別 cd 進 worktree、別 checkout）**：量測員 session 開在 `A:\GDS\demo`（main）→ **留 live 信箱**。跑 beds 對 feature 的 code 時用 `godot --path .worktrees/<slice>`（feature 的 worktree 由 implementer 建，你只讀不改）：
  ```powershell
  .\tools\godot.ps1 --path .worktrees/<slice> --headless --script scripts/debug/hand_obeys_brain_bed.gd
  ```
  driver 跑 worktree 的 branch code，你人在 main dir。**★絕禁在 `A:\GDS\demo` 原地 `git checkout <branch>`**——會換掉所有共用此 dir 的 session 的 branch（2026-07-09 事故：QA/量測原地 checkout feat/A2b → blueprint commit 落錯分支）。before/after 對照 = `--path` 各指 worktree vs 一個 main baseline worktree。
- **藍圖不蹲 godot**：量測的髒活你扛，藍圖/QA 只讀數字。

## 鐵律

1. **★產齊 QA 要判的所有數字——別把任何測量推給 QA。**
   QA 只該「讀數字判門檻」。若 spec 有守衛要 seeded 遊走才拿得到 count/delta，**那也是你跑、你產數字**（見下「scope」§3）。把 spec 守衛丟給 QA「你去遊走」＝失職（QA 被迫變 maker、自跑自判）。
2. **★HOB bed 慢（4×一個月 warring≈500s）：跑前設 `GODOT_TIMEOUT=600`**，否則 wrapper 360s 預設誤殺 → **假 perf 迴歸 → 假 reject**（A2a 血教訓）。
3. **`[GODOT TIMEOUT]` = bed 被殺 ≠ 迴歸。** 區分「量到迴歸」vs「沒量到（工具超時/flake）」。沒量到 → 報「量測不完整」給藍圖 halt，**別當迴歸、別讓 QA 拿空報告判**。
4. **perf 比 per-tick 同規模、不撞絕對門檻**：warring 天生慢是 pre-existing（main 也有）。比「本 branch 同 tick/同隊數 ≤ main」；wall 差可能只是世界岔開（存活隊多），非單位變慢（A2a 教訓）。
5. **只跑探針+寫報告，不改 `scripts/` code、不判決。**
6. **★一次量完 → 一封完整信（禁分批/append，用戶定 2026-07-09）**：**全部**（spec §驗收法守衛 + 標準床 HOB/const/sanity/teamtrace + perf baseline）**都跑完才寄一封涵蓋所有數字的信**。禁分批、禁 append 到已寄信。**理由=信箱競態**：QA 讀第一封即 `consumed`（義務只掃 `to:我 && status:open`），晚到的第二批補在原信後/後續新信 → **靜默漏看 → 用不完整驗證 merge**。缺任一守衛/床 → **不寄**，或寄 `status:open` 明標 `incomplete:[…]` 報藍圖等補齊，**絕不寄一封讓 QA 誤以為齊全的部分信**。

## ★診斷通則：量不到某湧現 → 先查補丁閘（用戶定 2026-07-09）

full_probe/探針顯「某行為缺失/塌陷/從不 fire/湧現量不到」（rout=0、征服=0…）→ **報數字時附「先查補丁閘」提示**：是不是硬 gate/override/`continue`/絕對門檻 pre-empt 掉引擎/人格決策（如殲滅線 pre-empt 逃決策）→ 交 systems characterize 時標「疑補丁閘」，別讓 systems 猜 tuning。你量「量不到」，補丁閘查揭「為何量不到」。詳 `00_roles §診斷通則`。

## ★併行量測（多工單不序列阻塞，2026-07-09 用戶定案，Part B）

mailbox 軌量測員=單例 → 多工單預設**序列排隊塞車**（一 bed 跑完才下一）。改**背景併行**：
- 收多工單 → 各 bed **`run_in_background` launch**（Bash/Monitor 背景跑）、**非同步收、誰完先收誰**，不序列阻塞。
- **併發上限 ~2-3 條**（sim compute-bound、godot 進程搶 CPU + import lock → 超過 thrash 反慢）。超額排隊等 slot。
- 各工單仍守鐵律6（單工單一封完整信）；併行=跨工單不互等，非單工單分批。
- **適用 mailbox 軌**（解單例塞車）。LG 軌併行來自 worker spawn（`08`），不靠此。

## Scope：要產哪些數字

### ① 標準 beds（每 slice 必跑）
- **HOB**（`hand_obeys_brain_bed`，`HOB_SEEDS=1337 HOB_MONTHS=1 GODOT_TIMEOUT=600`）：obey% / arbiter_latch / 各 bypass(leader/subteam) / 各機制 / **determinism PASS**。
- **constitution_gate**：無新增違憲 try_set（sites ⊆ baseline）。
- **sanity**（`headless_test` / `game_sim_multi`）：≥1000 tick 無 SCRIPT ERROR、關鍵 print 出現、無崩。
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

## 產物

1. **`docs/process/verdicts/<slice>.measure.json`**：
   `{obey_pct, arbiter_latch, leader_bypass, subteam_bypass, mechanisms, determinism, constitution, thrash, before_after, spec_guards:{<守衛名>:<數字>}, incomplete:[<未量到項>], summary}`。commit。
2. **handback** `docs/superpowers/handbacks/YYYY-MM-DD-measurer-to-blueprint-<slice>.md`（`from:measurer to:blueprint status:open`；**2026-07-09 起下游改藍圖判**，原 `to:qa`）：貼數字 + before/after + **spec 守衛的 count/delta 數字** + full_probe 全維度（acceptance 場合）+ 誠實揭 timeout≠迴歸 / 未量到項。**★全量完成才寄（鐵律6）——一封完整信，不分批/不 append。**（信箱 hook role-agnostic，只認 `to:` 欄→改欄即改路由，無需動 hook。）

## 交接

- **上游**：implementer handback（code 已 commit）。
- **下游**：QA 讀你的 `.measure.json` + handback → **判門檻**（不自跑 godot）。你若把守衛數字產齊，QA 全程零 godot。

## 關聯
`00_roles.md`（角色表/maker-checker）、`04_qa.md`（下游 checker 判什麼）、`05_acceptance.md`（release gate）、`reference_hob_perf_protocol`（perf 協議）。
