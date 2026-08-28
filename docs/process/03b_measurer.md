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
