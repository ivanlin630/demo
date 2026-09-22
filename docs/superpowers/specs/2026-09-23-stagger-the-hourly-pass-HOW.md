# HOW：把每小時那一趟 pass 按隊錯開相位（裁定 A）

```
狀態      DRAFT ——（R② 未過，未 dispatch）
上游      blueprint 裁定 2026-09-23「ruling-A-stagger-the-hourly-pass-itself」
前置票    faction_ai 吃自己的批次 ⇒ ✅ 已 merge `16c5e0409`（指紋逐字未變）
R①       reviewer 兩輪已回（第二輪 verdict=issues，premise_contradiction=true）
          ⇒ 該矛盾就是前置票，已修、已併 ⇒ 本 spec 的前提現在成立
世代      這張票【改變世界】⇒ 指紋床預期紅 ⇒ 世代 8（窗 #4）
```

## §0 一句話

`if current_tick % NEAR_CADENCE == 0` 這個閘讓**全世界的隊在同一顆 tick 上一起決策**，
那顆 tick 就是 2.0–4.2 秒的凍結本身。**頻率不動**（每隊仍每小時一次），
**只把「在哪一顆 tick」按隊散開**。

---

## §1 前提（已由 R① 坐實，file:line）

```
sim_runner.gd:358    if state.world.current_tick % NEAR_CADENCE == 0:   ← 唯一的掃描點
sim_runner.gd:400    _run_systems(state, all_teams, NEAR_CADENCE, …)    ← 26 格全部吃 all_teams
sim_runner.gd:216    SYSTEMS registry 26 entry ＋ forced_event 區塊（:370）＝ 量測表的 27 格
```

量測（`docs/measurements/2026-09-23-pass-tick-ceiling-gen7.md`，兩顆種子）：

```
seed1337：7 格「必須同 tick」每 pass 平均 500.0ms；near.faction_ai 單格 1301.5ms（50.8%）
seed42  ：7 格同樣 <1000ms；           near.faction_ai 單格 1111.1ms（45.6%）
S_fixed（7 格＋faction_ai）＝ 70.3% ／ 72.5%（門檻 ≤40%）⇒ 當時判【天花板不夠】
```

★**前置票落地後這個數字怎麼變**：`faction_ai` 從「不可錯開」變成「可錯開」
⇒ 它退出 S_fixed。**同一份量測、同一個分母**（`pass_dt_over2s`），所以可以相減：

```
S_fixed(post-fix) = 70.3% − 50.8% = 19.5%   （seed1337）
                  = 72.5% − 45.6% = 26.9%   （seed42）
⇒ 兩顆種子都落在 40% 門檻【之內】
```

★★**這是推導不是量測** —— 但分母共用這件事**已經從原始 log 反推核對過**（2026-09-23）：

```
seed1337（pass-tick-ceiling-gen7-seed1337-v3-faiadd.log:8604-8606）
  fai=143,167,037us（印 50.8%）｜S_fixed=198,169,389us（印 70.3%）
  ⇒ 由 S_fixed 反推分母 281,891,023us ⇒ 回算 fai = 50.79%（對得上）
  ⇒ 7 格 = 55,002,352us = 19.51%；★55,002,352 ÷ 110 pass = 500,021us
    ＝ 卷面「7 格每 pass 平均 500.0ms」那一行的同一個數（母體沒換）
seed42（…seed42-v3-faiadd.log:8139-8141）
  反推分母 148,703,801us ⇒ 回算 fai = 45.58%（印 45.6%，對得上）⇒ 7 格 = 26.92%
```

★★★若兩個百分比用的是不同分母，拿其中一個反推的分母回算另一個**不會**落在
四捨五入誤差內。兩顆種子各對一次，都在 0.02 個百分點以內。
真正的確認仍在驗收 P1／P7；這裡的推導用來決定「值不值得寫這張 spec」。

---

## §2 ★★★最容易做錯的那一個（code 裡已經有人踩過並留了字）

```gdscript
# sim_runner.gd:403-409（solo_think 那一票留下的字，逐字適用於本票）
#   ★它【故意】不在上面那個 `% NEAR_CADENCE` 閘裡：在閘裡檢查 ＝ 只看得到 60 的倍數
#   ⇒ CadenceStagger 的 offset 會被取樣格吃掉（offset≥1 就跳過一個檢查點 ⇒ 間隔 120）
#   ⇒ ★★98.3% 的隊思考頻率砍半 —— 而那不是工具壞，是【它被放錯了取樣格】。
```

⇒ **本票的到期檢查必須跑在每一顆 tick 上**，不得留在 `% NEAR_CADENCE == 0` 內側。
★這一條若做錯，症狀是「頻率砍半」而**驗收 P3 會抓到**（每隊每日次數 24 → 12）。

---

## §3 分組表（★本表是權威；實作照抄，不得憑 `shape` 欄推斷）

★**為什麼不能看 `shape` 欄**：`faction_ai` 的 `shape` 寫 `teams`，而它的函式體
`for fid in state.factions` 跑全世界、完全忽略 `_team_ids` —— 前置票修的就是這個。
**綱要與簽章都會說謊，只有函式體不會。**

### 3a 整點組（`% NEAR_CADENCE == 0` 才跑，吃 `all_teams`，行為與今天逐字相同）

| # | entry | 為什麼留在整點 |
|---|---|---|
| 1 | `vision` | 跨隊視野；R① 乙組 6 支之一，未逐行證完 ⇒ 保守留 |
| 2 | `move` | 移動後 `rebuild_team_tile_index()`，下游同格／敵對判定全吃它 |
| 3 | `letters` | `shape: state`，非 per-team（沒有「按隊散」的對象） |
| 4 | `propagate` | 吃 `moved` 批次；`moved` 由 move 產出 |
| 5 | `intel` | 同上 |
| 6 | `market` | 吃 `arrived` 批次 |
| 7 | `interactions` | 成對遭遇；雙方必須在同一顆 tick 上被看見 |
| 8 | `outpost_tick` | `shape: state` |
| 9 | `faction_snapshot` | ★見 §3c：R① 坐實「會壞」的兩支之一 |
| 10 | `regen` | `shape: regen`，不吃 team_ids |
| 11 | `strategic_ai` | `shape: state` |
| 12 | `emit` | `shape: state`；`RecruitTutorial` glue 掛在它之後 |
| — | `forced_event` 逾時區塊（:370） | ★見 §3d |

### 3b 錯開組（每 tick 跑，吃「這顆 tick 到期的隊」）

| # | entry | R① 判定 |
|---|---|---|
| 1 | `equip` | 第一輪逐行讀完：可錯開 |
| 2 | `strategic_move` | 純 per-team（`team.strategic_assignments`／`tags`） |
| 3 | `ambush` | 第一輪：可錯開（★早退見 §5c） |
| 4 | `collect` | 內層 `LaborSystem` 從 `state.teams` 全域建池，**不吃批次** ⇒ 結構上對錯開免疫 |
| 5 | `manufacture` | 同上 |
| 6 | `consumption` | 純 per-team |
| 7 | `salary` | 迴圈本體純 per-team；唯一碰 `state.teams.size()` 的是 Probe 診斷 |
| 8 | `fatigue` | 第一輪：可錯開 |
| 9 | `faction_ai` | ★前置票之後才成立（`16c5e0409`） |
| 10 | `info_dispatch` | 正確用 `for tid in team_ids`，且**自己已經有 per-team cadence** |
| 11 | `training` | 第一輪：可錯開 |
| 12 | `reactions` | 雙層 for 是 O(N×M) 的效率訊號，不是跨隊訊號 |
| 13 | `cleanup` | 第一輪：可錯開 |
| 14 | `events` | 第一輪：可錯開 |

★**12 ＋ 14 ＝ 26**，與 registry 的 26 個 entry 對得上（外加 forced_event 區塊 ＝ 量測表的 27 格）。

### 3c `faction_snapshot`：用【擺位】解，不改 code

R① 坐實：它的 `pos_map` 是**從批次 `team_ids` 建的**（`sim_runner.gd:558-566`）
⇒ 一旦錯開，同格同勢力的兩隊若落在不同相位，**永遠看不到對方**——而那是**靜默**的漏。

⇒ 本票**把它留在整點組**，一行 code 都不改。★**問題消失是因為前提消失**，
不是因為我們修好了它。★★若之後有人要把它移進錯開組，**先改成從 `state.teams` 全域建 `pos_map`、
只對批次內的隊寫入快照**——但那不是這張票。

### 3d `forced_event` 逾時區塊：留在整點（systems 裁，非阻塞問題）

它讀的是**單一全域** `state.player_forced_event`，語意是「上一個小時刻給玩家的窗口到期」。
沒有 per-team 的對象可以散。★留在整點的後果：玩家回應窗口仍是**整 60 tick**，與今天逐字相同。
★★這一格我按 HOW 自己裁了（保守選項＝語意逐字不變）；blueprint 若要別的擺法，這是可逆的一行。

---

## §4 實作形狀

### 4a 新欄位（★沿用既有形狀，零新結構）

```gdscript
# scripts/data/team_data.gd —— 逐字沿用 solo_think_next_tick／solo_think_last_tick 的形狀
var pass_next_tick: int = 0     # 下次進入每小時 pass 的 tick
var pass_last_tick: int = 0     # 上次真的跑過 pass 的 tick（量間距用）
```

★**兩個都必須進存檔與指紋**：它們是排程狀態，掉了會讓載入後的世界重排相位。

### 4b 到期與排程（★逐字照抄 `faction_ai_system.gd:8119-8167` 的形狀）

```gdscript
if team.pass_next_tick == 0:
    # ★首次【不當場跑】，而是排一個錯開過的到期時間 ——
    #   否則所有隊的第一次 pass 會集中在同一顆 tick，正是這張票要消滅的形狀。
    team.pass_next_tick = CadenceStagger.next_tick(
        cur, cur, team.team_id, SimRunner.NEAR_CADENCE)
    continue
var due: bool = cur >= team.pass_next_tick        # ★★★必須是 >= 不是 ==
```

★★★`>=` 不是 `==` 的理由：`ambush` 早退（§5c）或任何原因讓一顆 tick 沒跑完，
`==` 會讓那一隊**從此再也不到期**——而那是靜默的（它不會紅，它只會變窮然後餓死）。

★**沒有 woke 旁路**：事件喚醒屬於決策路徑（`solo_think` 那一票的護欄①），
本票搬的是**大宗經濟／維持**那一趟。兩者不共用閘。

### 4c `_run_systems` 的改法（★單一迴圈，registry 順序不得被拆散）

registry 加一欄 `"grp"`：`"hour"` 或 `"stag"`。`_run_systems` 每 tick 都呼叫一次：

```gdscript
for sys in SYSTEMS:
    var is_hour: bool = String(sys.get("grp", "hour")) == "hour"
    if is_hour and not hour_tick: continue        # ★連它的 glue 與 _pht 一起跳過
    if not is_hour and due_teams.is_empty(): continue   # ★★★見下，這一行不是最佳化
    var batch: Array = all_teams if is_hour else due_teams
    …（match shape 的部分逐字不動）…
```

★★★**空批次那一行是【構造保證】，不是最佳化**。

我原本要寫的理由是「`LaborSystem.ensure_fresh` 會全域掃，所以空批次不是 no-op」——
**開檔之後那個理由不成立**，如實記在這裡：`ensure_fresh(state, tile, advance)`
吃的是**單一 tile**，由 `collect`／`manufacture` 的 per-team 迴圈**內部**呼叫
（`resource_system.gd:70` 與 `manufacturing_system.gd:123` 都是進函式就 `for tid in team_ids`）
⇒ 批次為空時那個迴圈一次都不跑，`ensure_fresh` 不會被呼叫。

★**真正的理由是【我不想靠 14 支系統各自剛好是 no-op】**：那是清單保證，
而清單保證會因為**有人漏列一支**而變綠。一行 `continue` 是構造保證 ——
它對「某一支系統在空批次下其實會做事」這件事**不敏感**。

★★已知確實會在空批次下做事的一支（所以這一行不是假想）：
`manufacturing_system.gd:132` 的 `_manufacture_is_cadence_compensated()` 假設檢查
掛在 `for` **之前**、由 `Probe.enabled` 守。不跳過的話，它每小時被評 60 次而不是 1 次。
★它不影響指紋（Probe 在 production 是關的），但它影響**量測那一輪**的成本與計數。

```
不跳過的後果①：相位計時表上多出 60 倍的零成本取樣點 ⇒ 每格平均值被稀釋（★儀器改變被觀測物）
不跳過的後果②：★樁關掉時，非整點 tick 仍然走進那 14 支的函式本體
             ⇒ §4e 的「指紋逐字相同」變成【要逐支證明】的事，而不是【構造上成立】的事
```

★★★因此跳過必須在 `_pht` **之前**。

★**為什麼是一個迴圈而不是兩個 pass**：兩個 pass 會讓「整點組與錯開組的相對順序」
變成**另一份要維護的知識**。一個迴圈 ⇒ 順序就是 registry 順序，**永遠**。
★★相位 0 的隊在整點那一顆 tick 上，兩組交錯的順序與今天**逐字相同**。

★★★`due_teams` 的順序必須是 `all_teams` 的子序列（照 `state.teams.keys()` 過濾），
**不得**用 Dictionary 或 Set 重建——★同一集合 ≠ 同一順序，而順序決定先到先得。

### 4d `cadence` 參數維持 `NEAR_CADENCE`（＝60），★並把誤差寫下來

`teams_cadence` 那 5 支（collect／manufacture／consumption／fatigue／reactions）
用 cadence 把「每小時量」換算出來。錯開之後**同一批裡不同隊的實際間距不同**
（輪轉讓間距 ＝ 60 ＋ offset 差）。

★**仍然傳 60**，理由是誤差會自己抵銷：

```
第 k 次到第 k+1 次的實際間距 = 60 + (o_{k+1} − o_k)
N 次之後的累計實際 tick 數  = N×60 + (o_N − o_0)
N 次之後的累計發放          = N×60
⇒ 誤差 = −(o_N − o_0) ∈ [−59, +59]，【有界且不累積】
```

★★★**例外**：`CadenceStagger` 的 wrap clamp（`MIN_GAP = cadence/2 = 30`）會打斷上式的
telescoping。⇒ 加 tap `pass.gap.%04d.%d`（逐隊間距直方圖），床斷言**間距落在 [30, 119]**。
★若之後要把誤差歸零，做法是改成傳 `cur − team.pass_last_tick`，
但那會動到 5 支系統的簽章 ⇒ **不在這張票**。

### 4e 樁開關（★給 P6 陽性對照用，不是遊戲旋鈕）

```gdscript
# WorldState
static var pass_stagger_enabled: bool = true    # ★test-only；production 路徑不讀設定檔
```

關掉 ⇒ 所有隊在 `% 60 == 0` 一起到期 ⇒ **那一趟 pass 與今天逐字相同**。
★★★因此「關掉之後指紋必須與世代 7 **逐字相同**」是一個**極強的等價證明**：
它把「重構本身有沒有改行為」跟「錯開有沒有改行為」**分成兩個可以各自判的問題**。

---

## §5 護欄

### 5a 母體不得塌
`due_teams` 為空的 tick 是**正常**的（隊少於 60 隊時多數 tick 為空）。
★但「**永遠**為空」與「這一顆 tick 剛好沒有」長得一樣 ⇒ 床必須驗
**一個完整小時內每一隊恰好出現一次**（§6 P3）。

### 5b 新隊／死隊
新隊 `pass_next_tick == 0` ⇒ 4b 的首次分支排相位。
死隊在 tick 末由 `_step_cleanup_extinct_teams` 清除，與今天相同。

### 5c `ambush` 早退
`ambush` 在錯開組 ⇒ `encounter_active` 造成的 `player_turn` 早退現在**可能發生在任何一顆 tick**
（今天只可能在整點）。★這正是 4b 必須用 `>=` 的理由：早退讓該 tick 後面的系統沒跑，
下一顆 tick 那些隊仍然到期。

### 5d 感知鐵律
本票**不新增任何跨距讀值**：每一支系統吃到的仍然是它今天吃到的東西，只是批次變小。
★`faction_snapshot`（唯一有跨隊讀取的那支）留在整點組 ⇒ 它看到的母體與今天逐字相同。

---

## §6 驗收（★數字在資料之前寫死；blueprint 已預註冊，本節只補【用什麼量】）

```
母體：世代 8、HW-2、12 天 × 2 種子（1337／42）
```

| 格 | 判準 | 儀器 | 假設為假時長什麼樣 |
|---|---|---|---|
| P1 | `n_deciders` 尖峰：11+ 桶 tick 數相對世代 7 **方向性不得上升**；相位保留率 100% → **<10%**；60-tick 間距佔比（>2s 事件）**< 20%** | `pass.phase.%02d`（tick%60 直方圖）＋既有 `pass.byteam.%04d` | 尖峰不是 pass 造成的 ⇒ 這一格不降 |
| P2 | headless B3：>2s **≤ 1/日** 且 p99 **< 1s** | `freeze_sample_bed.gd`（tick 原子未變 ⇒ tick 時間＝幀時間代理仍成立） | 凍結來自單一系統而非同時性 ⇒ 不動 |
| P3 | 每隊每日 pass 次數 median **±5%**（＝24）；每隊兩次 pass 間距 median **＝ 60 ±1**；間距全部落在 **[30, 119]** | 新 tap `pass.gap.%04d.%d` | §2 那個坑（到期檢查留在取樣格內）⇒ 這裡變 12 |
| P4 | `extinct`／`starve`／`combat` **帶主詞**同量級；子隊外出終止原因分佈不變 | 既有床 | 錯開讓某些隊系統性少拿資源 ⇒ 餓死數變 |
| P5 | 指紋床**預期紅** ⇒ 世代 8；★**樁關掉時指紋必須與世代 7 逐字相同** | `world-fp` 閘 ＋ 一次 `pass_stagger_enabled=false` 的手跑 | 重構本身改了行為 ⇒ 樁關掉也紅 |
| P6 | 陽性對照：把相位關回整點 ⇒ **P1 的尖峰必須回來** | 同 P1 儀器 ＋ §4e 樁 | 儀器根本沒接上 ⇒ 開關兩邊一樣 |
| P7 | 吞吐：ticks／真秒 **±5%**（散相位不該改變總工作量） | 既有 perf 床 | 錯開反而讓總量變多（例如某支被重跑 N 次） |

★★**P1 與 P2 必須同時綠才算**：blueprint 明文——「若尖峰不是 pass 造成的，
P1 不降、P2 不動 ⇒ 兩格一起綠才算」。

★★★**P5 的樁那一格是本票最便宜的真相**：它一次就分開了
「我重構壞了」與「錯開改變了世界」。**先跑它**，再跑其餘六格。

---

## §7 不做的事

```
①不動頻率：每隊每小時一次，一次都不多一次都不少
②不切 tick、不動執行緒模型（分片票／儀器票仍 HALT，門票＝(A) 落地後 B3 仍紅）
③不碰 faction_snapshot 的 pos_map（§3c：用擺位解）
④不動乙組 6 支（vision/move/market/propagate/intel/interactions）——
  ★R① 沒有逐行證完它們，保守留在整點；它們合計 500.0ms／pass，本來就在門檻內
⑤不加任何遊戲旋鈕（§4e 的樁是 test-only）
```

## §8 留給下一張票的（★寫下來，否則下一代要重挖一次）

```
①乙組 6 支逐行證完 ⇒ 若其中有可錯開的，S_fixed 還能再降
②teams_cadence 那 5 支改吃【真實間距】⇒ §4d 那個 ±59 tick 的誤差歸零
③faction_snapshot 改成全域 pos_map ⇒ 它才有資格進錯開組
```
