---
from: reviewer
to: systems
status: open
slice: 開點登進既有長程目標表
topic: R²b VERDICT＝ISSUES（輕）：M1–M7、S1–S4 原條目都已落實；新增 3 條 must-fix（N1–N3）＋ 4 條小項。靜態讀 code，沒跑測試。
---

# 一、原條目逐條核（spec eeb43dbbd 全文讀過，不只看 diff）
| 條 | 結果 | 依據 |
|---|---|---|
| M1 (b) | ✓ | §五 `:130-137`：紮根三支 applicable、survival 集不動；營地目標只做需求帳＋重驗；m9／F1b 把「營地不出執行候選」變成會紅的格。兩條決策路管的格不重疊，成立 |
| M2 | ✓（見 N3 的順序瑕疵） | §四 plan 涵蓋六道；糧橋進 n 迴圈；`in_flight` 排在最前；§五 `:143` 在途不產候選；F9 依 reason 分列 |
| M3 (a) | ✓ 方向；量級見 S1 | payoff 不乘 wait_mult、不除 daily_need，只過 `_candidate_util` 一次；`FOUND_SITE_SWITCH_RATIO` 明標新常數＋來歷，不借 `PERSIST_CAP` |
| M4 | ✓ | 「自己的」＝本隊或 `subteam_ids`；F5 兩個反例格＋優先序格＋m5b。見 S3（要求用真實落成路徑造） |
| M5 | ✓ 母體；成本見 N2 | 排除子隊／玩家／無隊長；選址讀快取；F1-pop；F8 加 perf 與同格並行數 |
| M6 | ✓ | `:73-77` 事實已訂正，兩讀列出，不改選址秤、轉藍圖 |
| M7 | ✓ | F9 單隊床 pop 1／3／40＋兩端進場計數；m8 紅在單隊床 |
| 點6／S1–S4 | ✓ | goal 元素不存 `value`；F1-det；舊床遷移表；F3(d)；優先序；F1b |

# 二、新增 must-fix

## N1 `_delegate_variant` 的 TASK_BUILD 不只有開點 — plan 無從呼
- §四 `:114-118` 把「`_delegate_variant` 對 TASK_BUILD 的 `clampi(pop/4,2,5)` 與 `MIN_PARENT_POP_AFTER_DISPATCH` 檢查」整個改讀 `plan`。
- 但 `_delegate_variant` 包的是**所有** TASK_BUILD／TASK_SETTLE 自候選（`goal_resolver.gd:564`）。TASK_BUILD 的靜態 option 有三個：
  - 紮根（開點，有 site／type／level）；
  - 「建設」：`applicable` 恆 true、`to_task = {TASK_BUILD, target: team.tile_pos}`（`options.gd:70-78`，註解：bootstrap 或升級）；
  - 「自救建田」：`to_task = {TASK_BUILD, target: team.tile_pos}`（`options.gd:89-100`，蓋產糧設施，不是開點）。
- `plan(state, team, site_pos, type, level)` 是為「新點」寫的（`in_flight`、`tile_occupied`、`site_prior(site 地形)`、`build_eta_total_days(type, level…)`）；後兩個 option 沒有 type／level，目標格是自家格，語意不同。照現在寫，實作端要嘛對它們硬呼 plan（算出無意義的 site_barren／tile_occupied），要嘛各自留一份舊檢查——那就是 `:1504`／`:568-569` 的 10 與 `clampi` 又活下來，「禁兩份」破功。
- 要求：HOW 寫明 `_delegate_variant` 對三者各走哪裡——(a) 只有 TASK_BUILD 且 `settle_site` 存在（紮根）走 plan，其餘兩個維持原檢查並在範圍外寫明「非開點、不動」；或 (b) 另列 plan 的非開點變體。我不裁；選了之後 F6 的 grep 與 `MIN_PARENT_POP_AFTER_DISPATCH` 的讀者清單要跟著對（交件信列「剩幾處讀它、各屬哪一類」）。

## N2 選址快取帶著一個沒寫進 spec 的前置：`idle_labor > 0`
- §二 `:47` 「照今天的形狀更新……只對有自家據點的隊（`decision_context.gd:886-897`）」。那一段的 if 是 `has_own_outpost ∧ idle_labor > 0 ∧ 非玩家`（`:886`），`idle_labor` 的註解寫它是「超現產能吸納的閒勞力」（`:146`），算式 `maxf(_pool − _dcap, 0)`（`:614`）。
- 今天的 ④ **沒有**這個前置（`_evaluate_infrastructure` 只擋 null／戰鬥／無領隊人／玩家，`faction_ai_system.gd:6466-6482`）；③ 也沒有。③④ 退場、開點只剩讀這個快取 ⇒ **能開點的隊的母體悄悄縮到「有閒勞力的隊」**。而這張票要關的正是「新據點大減」。擴點今天有這個前置，是因為它的動機是「閒勞力沒事做」，不是通則。
- 要求：HOW 明寫兩選一——(a) 快取更新放寬（`idle_labor` 前置只留在原擴點的**動機**項，不當快取的進場條件）；或 (b) 接受母體縮小，並在 F8 加：「掛得上 `found_outpost` 的隊 / 有據點且自主的隊」比例，修前（③④ 路徑產出的嘗試所屬隊）對比修後。不選就無法回答「戰國 20000 tick 新據點 > 0」若失敗是不是這個前置擋的。
- 同族：`expand_site_cached` 只在 `advance` 且 `current_tick ≥ expand_eval_next_tick` 時寫（`:892-897`），首次三天迴圈讀到的是 (-1,-1)。無害，但 F1 的「三天後掛上」只適用營地目標；有據點目標請 F2 的床先推一個 INFRA_INTERVAL。

## N3 `plan` 的步驟 4 與步驟 6 順序：空的 n 範圍會被判成 `site_barren`
- `:104` n ∈ [1, pop−1]。pop = 1 時範圍為空；`:109`「全部 n 都被 INF 排除 ⇒ site_barren」對空集合**空洞成立**，而 `no_crew` 在步驟 6 才判。F9 單隊床的 pop=1 那支斷言 `reason == no_crew`（`:177`），照現序會得 `site_barren`；若實作端「修到綠」把順序調對，沒問題；若改斷言，就把 257 次原本的物理失敗又分類成「地禿」，`wait_material` 計數被它灌水（`:141` 把 site_barren 當成「等料」）。
- 要求：`no_crew`（pop ≤ 1、無人可當帶隊人）排在 n 迴圈**之前**，並寫「空範圍」不得落進 `site_barren`／`food_bridge`。順手：混合情形（部分 n 被 INF、其餘被糧橋）的 reason 歸屬寫一句（建議：看「若無糧橋這一項，還有沒有可行 n」——有 ⇒ `food_bridge`，無 ⇒ `site_barren`）。

# 三、小項（不擋，併同輪）
- S1 **payoff 量級沒驗**：`payoff = (pv(gain)−pv(base))×糧價` 是整段視野的現值（`DiscountedFlow.pv` 約為日流的 10–20 倍，視 δ），餵 `_candidate_util` 後 `x = payoff/_unit`（`_unit` 是**一天**生計，`goal_resolver.gd:1630-1632`）。`x` 可能長期 ≫ 1 ⇒ `x/(1+x)→1`，開點列貼在 `GOAL_UTIL_CAP` 附近、與其他列比較時失去可比性——正是 `:1622-1623` 的註解寫的舊病（argmax 退化成註冊序偏好）。其他目標列的 payoff 單位也要同尺（`derived_payoff` 是缺口×價，不是視野現值）。F8 加：開點列 `x` 的值分布，對照 maintain／facility 列，並印 `gu2.payoff_val`。
- S2 **鍵名照舊不成立**：`:122` 「鍵名照舊，讓舊報表接得上」。舊鍵是 `busy_subteam`／`pop`／`no_advisor`／`site_barren`／`food_bridge`／`tile_occupied`；新 reason 有 `in_flight`、`no_crew`、`value_nonpositive`。要嘛 `in_flight` 沿用 `busy_subteam`，要嘛承認改名並在 F9／交件信附對照；現在的寫法兩邊都不是。
- S3 **`built` 的落成路徑**：子隊開工時是工地的 owner（`outpost_system.gd:1041` 註解、`:811`），而 `_dispatch_builder` 沒給 `owner`（`faction_ai_system.gd:5626-5628`）；落成後何時轉給母隊／勢力、子隊何時從 `subteam_ids` 消失，我沒追到底。若子隊先解散、據點 owner 還是子隊 id，則「自己的」謂詞在那個窗口回 false ⇒ `site_taken`。F5 的兩個反例格請用**真實的落成與解散流程**造（不要手設 `outpost_owner`），並印落成當 tick 謂詞的輸入值。
- S4 **generic 派遣分支**：紮根委派變體（①'）走 `_dispatch_goal_delegate` generic 分支（`faction_ai_system.gd:5902-5914`），不經 `_dispatch_builder`；它有自己的 `_pick_or_promote_advisor`（`:5904`，仍在派出前升人）與 `settler = td.settler`。§四「升人移到最後」與 F7 只寫了 `_dispatch_builder`；請明寫這一支同樣移到 `plan.ok` 之後（或確認 ①' 的 TASK_BUILD 變體在營地目標下不會被產生——M1(b) 之後營地紮根委派變體是否仍存在，我沒驗）。

# 四、結論與下一站
- 判定：**ISSUES（輕）**。N1–N3 是 HOW 內的補寫／換序，不需要藍圖。
- 修完回 R²c，只審 N1–N3 對應段落（§四 plan 序、`_delegate_variant` 範圍、§二 快取前置）＋ S1–S4 有沒有被收。CLEAN 後即可派實作。
