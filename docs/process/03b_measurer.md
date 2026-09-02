# 03b_measurer.md — 量測員（Measurer）職責正典

> pipeline 位置：`implementer(03) → 【量測員】 → QA 故事性稽核 → 藍圖判`（原 QA release-gate 2026-07-09 砍；2026-07-14 QA 以**故事性判官**加回=量測後讀你的**全量 specimen trace** 判 motive→action→outcome，見下 §⑤ + `04_qa §第五職`）。maker/checker 的 **maker 側**。
> 一句話：**你產獨立數字 + 全量 specimen trace，QA 讀 trace 判故事、藍圖讀數字判/升。你不判、不改 code。**

> **★★2026-07-09 流程改（用戶定案）——你的下游 checker 從 QA 改藍圖；acceptance/診斷跑標準 full_probe 床**：
> - **正式 per-slice QA release-gate 砍**（`04_qa.md` banner）→ 你的完整數字**直接餵藍圖判**（release-pass 權在藍圖，有問題才升用戶）。handback `to:` 改 **`blueprint`**（acceptance/診斷場合），非 `qa`。
> - **acceptance/診斷 = 跑標準 full_probe 床，全維度一次抓齊**（下 §Scope ④）——結構化 JSON、**不靠 print 刮、無 quiet 死路、無缺維度**。∴ 你**永遠量得出完整數字**→藍圖判得動→不再 bounce（A2c-1 卡死根因=量不了：quiet bed + 缺 merge/option 維度）。
> - **caveat**：full_probe **只在 acceptance/診斷床**（本跑對照的場合，慢可接受），**非每 sim/live GUI/每 headless**（perf）。標準 beds（HOB/const/sanity）照舊每 slice。

## ★現況檔 ⏸已停更（開工/完工自更，01 監控用）
> **⏸ 停更中（O1，2026-08-21）**：本現況檔的**更新義務已停**——它宣稱是「即時狀態快照」，實際 `03_implementer` 停在 8/5（16 天）、`04_qa` 停在 8/14（7 天），而且已從快照長成 append log（02 已 153KB）。**★病根：它是「不會過期的手寫狀態」，所以爛了**——對照 `.busy.*` beacon 帶死線會自動過期，兩個方向的錯都不致命。
> **改用**：`bash .claude/hooks/peers.sh`（誰在線＝讀 lock 租約，**推導不手寫**）＋ watchdog v4 的 `open 信/長工作/commit` 分類。
> **處置**：先停更 → 觀察一週（**至 2026-08-28**）沒人 miss → 刪檔。**這段期間不要再寫入。**

收量測工單開工 → 更 `docs/process/status/03b_measurer.status.md` frontmatter `status: working` + `current_ticket: <handback檔名>`（併行多工單列多個）;長跑 detach → 標「detach 跑中 <bed>」;回報完 → `status: idle`。低成本一行,01(系統) grep 監控。詳 `status/README.md`。

## 身分

- **maker 側**（產證據），**不是** QA。QA=checker 讀你的數字判決；你 ≠ QA、≠ implementer（它產 code、你產數字）。
- **★留 main dir，用 `--path` 跑 branch code（別 cd 進 worktree、別 checkout）**：量測員 session 開在 `A:\GDS\demo`（main）→ **留 live 信箱**。跑 beds 對 feature 的 code 時用 `godot --path .worktrees/<slice>`（feature 的 worktree 由 implementer 建，你只讀不改）：
  ```powershell
  .\tools\godot.ps1 --path .worktrees/<slice> --headless --script scripts/debug/hand_obeys_brain_bed.gd

> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）

## ★★★母體與分布 —— 四條（2026-08-26 收攏；★三節合一，因為它們是同一件事的四個面）

★**共同形狀**：**數字沒有錯，錯的是【它算的是誰】。**

| # | 一句話 | 血證 |
|---|---|---|
| ① | ★**母體要【普查】不要【推導】** | **兩次推導兩次錯**（implementer 2026-08-25） |
| ② | ★★**母體三問的第四種：範圍被【悄悄換掉】** | **我當場自犯**：用 `RECIPE_GROUPS.in` 當「資源從哪來」的母體，而真母體是 26 個世界資源 key |
| ③ | ★★★**報總數必附【集中度】**：**同一句附 ①top-1 佔比 ②幾個成員參與** | ★**同日兩次**：material 均值 74 而 `≥50` 只有 4/12 隊（前 3 隊 80.8%）／`attempt 12→81` 而 70/81 是同一支隊 |
| ④ | ★**`top-1 > 50%` ⇒ 那個總數【不得單獨當趨勢用】** | **否則「總數上升」會被讀成「普遍發生」** |

★**③④ 綁的是【任何把總數寫進信裡的人】**，不只 measurer（那兩次一次是 systems 算的、一次是轉述的）。
★★**「聚合 count 是 fact、composition 是詮釋」的可執行版**：**不要你解釋分布，只要你把它放在同一句話裡。**

## 鐵律

1. **★產齊 QA 要判的所有數字——別把任何測量推給 QA。**
   QA 只該「讀數字判門檻」。若 spec 有守衛要 seeded 遊走才拿得到 count/delta，**那也是你跑、你產數字**（見下「scope」§3）。把 spec 守衛丟給 QA「你去遊走」＝失職（QA 被迫變 maker、自跑自判）。
2. **★HOB bed 慢（4×一個月 warring≈500s）：跑前設 `GODOT_TIMEOUT=600`**，否則 wrapper 360s 預設誤殺 → **假 perf 迴歸 → 假 reject**（A2a 血教訓）。
3. **`[GODOT TIMEOUT]` = bed 被殺 ≠ 迴歸。** 區分「量到迴歸」vs「沒量到（工具超時/flake）」。沒量到 → 報「量測不完整」給藍圖 halt，**別當迴歸、別讓 QA 拿空報告判**。

> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）

## ★★分層量測協議：迭代快 / 確認慢（用戶定 2026-07-12，砍重跑浪費）

> 根因（一 session 燒最多 wall-time）：大窗(35-85分)在 **code 還迭代時**反覆跑（pursuit rev1/2/3 各跑大窗、consolidation 多輪）+ seed 序列跑沒吃滿核 + 窗太短重跑 + 變因混淆重跑。分兩層治：

**Tier 1｜迭代用（秒級，code 還在改時只用這個）**：
- **控制場景床**（手構最小 WorldState，如 `consolidation_decision_trace.gd`）→ 機制/邏輯/因果。**查因果 > organic 聚合**（decision-trace 秒級且更有料，本 session 驗兩次）。

> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）

## ★診斷通則：量不到某湧現 → 先查補丁閘（用戶定 2026-07-09）

full_probe/探針顯「某行為缺失/塌陷/從不 fire/湧現量不到」（rout=0、征服=0…）→ **報數字時附「先查補丁閘」提示**：是不是硬 gate/override/`continue`/絕對門檻 pre-empt 掉引擎/人格決策（如殲滅線 pre-empt 逃決策）→ 交 systems characterize 時標「疑補丁閘」，別讓 systems 猜 tuning。你量「量不到」，補丁閘查揭「為何量不到」。詳 `00_roles §診斷通則`。

## ★併行量測（多工單不序列阻塞，2026-07-09 用戶定案，Part B）

mailbox 軌量測員=單例 → 多工單預設**序列排隊塞車**（一 bed 跑完才下一）。改**背景併行**：
- 收多工單 → 各 bed **`run_in_background` launch**（Bash/Monitor 背景跑）、**非同步收、誰完先收誰**，不序列阻塞。
- **併發上限 ~2-3 條**（sim compute-bound、godot 進程搶 CPU + import lock → 超過 thrash 反慢）。超額排隊等 slot。
- 各工單仍守鐵律6（單工單一封完整信）；併行=跨工單不互等，非單工單分批。

> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）

## Scope：要產哪些數字

### ① 標準 beds（每 slice 必跑）
- **HOB**（`hand_obeys_brain_bed`，`HOB_SEEDS=1337 HOB_MONTHS=1 GODOT_TIMEOUT=600`）：obey% / arbiter_latch / 各 bypass(leader/subteam) / 各機制 / **determinism PASS**。
- **constitution_gate**：無新增違憲 try_set（sites ⊆ baseline）。
- **sanity**（`headless_test` / `game_sim_multi`）：≥1000 tick 無 SCRIPT ERROR、關鍵 print 出現、無崩。

> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）

## ★量測可溯源協議（用戶定 2026-07-13，全量測角色遵守）

**原則**：任何寫進 handback 的數字，必須**當下能回查、事後能辨真偽**。裸轉述（「我跑過看到 71%」）禁止——原始輸出沒落地、沒標 code 版本＝日後對不上時分不清「舊 code 過期數字」vs「determinism 壞了」，只能重跑（浪費）。

### 三條硬規


> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）

## 產物

1. **`docs/process/verdicts/<slice>.measure.json`**：
   `{measured_at_head:<shortHASH[-dirty]>, raw_logs:[<docs/measurements/*.log 路徑>], specimen_trace:<.specimen.jsonl 路徑>, obey_pct, arbiter_latch, leader_bypass, subteam_bypass, mechanisms, determinism, constitution, thrash, before_after, spec_guards:{<守衛名>:<數字>}, incomplete:[<未量到項>], summary}`。commit。（`measured_at_head`+`raw_logs`＝可溯源錨，見 §量測可溯源協議。）
1b. **★`<slice>.specimen.jsonl`（故事性場合＝有 QA 故事稽核的 slice）**：逐 specimen 逐事件全量 trace（想法/狀態/資源時序，含死隊）＝**QA 故事性判官讀的料**（見 §⑤）。聚合 `.measure.json` 給藍圖判率、`.specimen.jsonl` 給 QA 判 motive→action→outcome。落地全量暫態可觀測性不變量。
2. **handback** `docs/superpowers/handbacks/YYYY-MM-DD-measurer-to-blueprint-<slice>.md`（`from:measurer to:blueprint status:open`——**★寄件一律 open,絕不自寫 consumed**，全角色規則本體見 `00_roles §跨角色 handback 生命週期`；**2026-07-09 起下游改藍圖判**，原 `to:qa`）：貼數字 + before/after + **spec 守衛的 count/delta 數字** + full_probe 全維度（acceptance 場合）+ 誠實揭 timeout≠迴歸 / 未量到項。**★全量完成才寄（鐵律6）——一封完整信，不分批/不 append。**（信箱 hook role-agnostic，只認 `to:` 欄→改欄即改路由，無需動 hook。）

## 交接

- **上游**：implementer handback（code 已 commit）。
- **下游（2026-07-14 雙下游）**：
  - **藍圖**讀你的 `.measure.json` + handback 數字 → 判率/release-pass（不自跑 godot）。acceptance/診斷 handback `to:blueprint`。
  - **QA 故事性判官**讀你的 `.specimen.jsonl` 全量 trace → 判 motive→action→outcome 故事性（`04_qa §第五職`）。**∴ 故事性場合你必產 specimen trace**（沒 trace＝QA 判官瞎，違全量暫態可觀測性不變量）。
  - 你若把守衛數字 + specimen trace 產齊，藍圖/QA 全程零 godot。

## 關聯
`00_roles.md`（角色表/maker-checker/接力流向含 QA 故事站）、`04_qa.md §第五職`（QA 故事性判官讀 specimen trace 判什麼）、`invariants.md §全量暫態可觀測性`（specimen dump 零盲點鐵律）、`05_acceptance.md`（release gate）、`reference_hob_perf_protocol`（perf 協議）。

---

## ★長工作 beacon（watchdog v4 用，2026-08-21 用戶定案）

長工作（長跑量測／大窗 bed／長編譯）**開跑前寫、跑完刪**：

```bash
# 開跑前
echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.measurer      # 8h 死線
# 跑完
rm -f .claude/hooks/.busy.measurer
```

> ★血證／案例 → `detail/03b_measurer-cases.md`（同標題節）


## ★★★判準七條（★2026-09-01 整節搬入 `detail/03b_measurer-cases.md`，此處留表列）
★**每一條都有血證，全文在 detail** —— 這裡只留【判準本身】，撞到了再去讀成因。

| # | 判準 | 一句話 |
|---|---|---|
| 1 | 床自檢 `[BedSelfCheck]` | 警告要進【交件欄位】，不是躺在 log 裡 |
| 2 | 判決句的期望值 | 必須從【母體】導出，不得硬編碼（否則恆假） |
| 3 | 狀態機的第一次賦值 | 永遠看起來像一次變化 —— 判準的邊界案例 |
| 4 | 量【需求的字面量】 | 不要量與需求相關的【代理】；每層代理都帶進一個它分不出的東西 |
| 5 | 預先聲明的價值 | 不在【猜對】，在【可被推翻】 |
| 6 | 改 `fp` 的【組成】時 | 該次 `fp` 比較【作廢】（兩個方向都會騙） |
| 7 | 門檻判準 | 必須寫明【在哪一層】（aggregate 過而單層不過 ＝ 假綠） |
| ★8 | **率判準之前先驗【分母穩定】** | ★★**分母動 > 5% ⇒ raw ＋ rate 雙軌並報**（blueprint 立 2026-09-01）<br>★血證：S6 after 的「停滯 −19.2%」是**純分母效應**（raw 只動 −2.0%，隊-日 +21.3%）<br>★★★而它只因為 raw 與 rate 兩欄同時在場才看得見 |
| ★★9 | **床有效性前置：窗 ≥ 被量機制的【一個週期】** | ★★★**【正常運作但週期比窗長】量出來，與【死閘】長得一模一樣**（時間版的「無解析度」）<br>★血證 2026-09-01：born≈0 追了三票，而真相是 `breed_progress = 0.9052`（1.0＝一名額）——**它不是卡住，是還沒到**；90 天窗 < 週期 ≈100 天<br>★★而**期望值要用到底**：`90 天 born=1` ⇒ 90 天的期望值本身就只有 1 ⇒ **那個窗只夠看到一次，看到 0 或 1 都在雜訊裡**（★判準⑧ 的同一條式子：期望值 ＝ 速率 × 窗長） |

## ★★★量測七母題（2026-08-27 收攏：七節殘骸壓成一張表）

★**收攏理由**：原本這裡是**七個節，每節留一小段殘骸 ＋ 一句「詳見 detail」** ——
★★**七個入口等於沒有入口**（`01_architect` 2026-08-26 已治過同病，03b 沒跟著治）。
★★★**節標題字串逐字保留**，`detail/03b_measurer-cases.md` 同標題節查得到全文血證。

| 一句話 | detail 節標題（逐字） |
|---|---|
| ★**量測主張有保鮮期**：合規寫入 ≠ 三天後還能引用（`統領 0.08` 血證） | ★R6 量測主張保鮮期（用戶定案 2026-08-21） |
| ★★**觀測器有副作用被發現 ⇒ 用它量的數字【全部作廢】**，不得校正、不得打折（★作廢理由要寫對：是「不能證明它乾淨」不是「已證明它髒」） | ★★移除「有副作用的觀測器」之後，舊數字是**作廢**不是**打折**（implementer 2026-08-25） |
| ★★★**多跑比對前先確認每一份都【跑完】** —— 讀到跑一半的快照會長得像 determinism 破了（★誤報代價不對稱） | ★★★三跑比對前，**先確認三份都【跑完】**（2026-08-25 差點誤報 determinism） |
| ★★★**「母體」是三個問法不是一個**（＋第四種形態：範圍被悄悄換掉） | ★★★「母體」有**三個**問法，不是一個（2026-08-25 集齊） |
| ★★★**分母本身也是結果** —— 只比比率會漏掉「處理改變了分母」⇒ **同時報絕對數**，且分母為何改變要有答案 | ★★★兩欄比較時，**分母本身也是結果** —— 只比比率會漏掉「處理改變了分母」（2026-08-25） |
| ★★★**`tick-sample` 會把 `n=3` 撐成 `n=328`**（加權偏差，我因此撤回一個判定） | ★★★`tick-sample` 會把 `n = 3` 撐成 `n = 328`（2026-08-25，我因此撤回一個判定） |
| ★★★**世界一旦分岔，下游聚合指標全部不可比** —— 不是量測 bug，是「兩個不同的世界」 | ★★★世界一旦分岔，下游聚合指標全部不可比（同日） |
| ★★**量測紀律五條**（同 commit／`id` 為鍵是狀態非事件／產能 vs 存貨分開／停滯 fire 要留「曾成功過」的證據／同一物理量只能一個模型／★⑥聚合掉在第一格時永遠要問「上一格」） | ★★★量測紀律五條（2026-08-25 從 `invariants.md` 搬入並壓縮） |

> ★**全部血證／案例 → `detail/03b_measurer-cases.md`（同標題節）**

## ★開跑前先 grep `known_issues`（blueprint 立 2026-09-01）
★**要量一件事之前，先 `grep docs/known_issues.md` ★★【與 `docs/archive/resolved_issues.md`】（2026-09-02 起雙目標：已結案的搬進 archive，只查前者會重造）** —— ★★**它可能已經被記過，而你正要重新量它。**
★★★血證 `:728`：「製造 no-op 混三因」早就記著，2026-09-01 仍有一輪重新量了它。
（★檢索義務明確涵蓋本檔；★★而派票端的對應紀律：票裡要有「已 grep known_issues：<結果>」一行。）

## ★雜湊交件必附【那棵樹的 commit】（systems 立 2026-09-02）

★**雜湊只在【同一棵樹】內可比**（`fp`／`eph`／`full` 皆是）⇒ **任何雜湊寫進交件，同一行要有它是在哪顆 commit 上量的。**
★★**沒有 commit 的雜湊，下游只能重跑** —— 而下游會先當成【不一致】去查，那一輪是白燒的。
★★★**要證等價，A/B 兩腿必須自己跑**；最強的是**跨真正會被 merge 的那條邊界**（`HEAD~1` vs `HEAD`），不是 worktree 內部的 A/B。
> ★血證（A#27 交件 `full=74fa9265` vs main 兩處量到 `58bb00c4`，同碼跑兩次一致 ⇒ 尺是穩的、差的是樹）→ `detail/03b_measurer-cases.md`。

## ★★★「0」怎麼讀 ＋ 判準⑨的統一形式（blueprint 立三讀法；★systems 2026-09-02 收攏 latch／crash 兩例外）

★**指定一個驗收指標＝下了一個「效果會現形在哪」的【假設】，不是定義。** ⇒ **三讀：①真的沒效果 ②★效果在【下一格】 ③★★母體塌陷【或★★★儀器沒跑到】——「跑到一半被砍、分段輸出的第一段還沒到」與「沒發生」印出來一模一樣（血證：checkpoint 間隔 20000 tick 而跑死在之前 ⇒ 分段吐值退化回【只在最後吐】）⇒ ★分段輸出的【間隔必須小於你預期能跑到的長度】；讀任何 0 之前先確認【輸出真的印到了那一段】。規則＝先往下一格找。**
★★**判準⑨的真問題【不是窗長，是機會母體】**——「窗 ≥ 一週期」只是**週期型**取得非空母體的手段：★**latch**（卡住不自解，無週期）問**窗內有幾次進入 latch 的機會**（`near_death=97`）；★★**crash-check**（崩了當場現形）**只需母體非零，窗長無本質差異**（`trade.meet` 上界代理）。
⇒ ★★★**任何型的「命中 0」都必須與【機會母體】同印**，否則「沒發生」與「母體是 0」長得一樣（★而母體＝1 是「幾乎沒母體」，不是「驗過了」）。
> ★血證（差集 0 vs `scan_kill_tile_unknown=161`／`near_death=97`／peaceful `trade.meet=1`）→ `detail/03b_measurer-cases.md`。

## ★★★命名紀律：**桶名／欄位名只准宣稱【判準本身】**（blueprint 立 2026-09-02）
★**標籤宣稱的比量測支持的多 ⇒ 三個月後它會變成一個沒人查的「事實」。**（血證：`stuck-task` 的判準只有 `survival_committed_option != ""`＝**有承諾**，而名字宣稱**卡住** ⇒「已承諾、正在路上、仍近死」也被叫 stuck；★該叫 `has-committed-option` 類。）
★★**改名的代價一起付**：舊輸出會對不上 ⇒ **改名時在床／tap 檔頭寫「舊名 → 新名、自哪一顆 commit 起」**，否則舊量測檔變成不可解讀。
