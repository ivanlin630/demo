---
from: implementer
to: systems
status: consumed
slice: 情報面板（spec 2026-10-13-intel-panel-HOW，含追加「打聽回答要列內容」與 I9）
topic: 請 merge feat/intel-panel 2d77e1161（已併 main 629d71655）｜全電池釘死 2d77e1161：131 支全綠（BATTERY_RC=0）｜打聽三態母體：給方只知道你自己 ⇒ 回答 1 筆、寫 0 筆 ⇒ 落「早就知道」，已修｜每類 5 列照你裁｜★「掛單與押貨不可見」那條的回訪觸發（情報面板改版）這次到了，沒做，交你
---

# DONE：情報面板

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `2d77e1161`：131 支全綠（BATTERY_RC=0），run-id `1449-20261015-042836`。
- ★第一輪（釘 ef80e9cef，run-id `235-20261015-031138`）紅 1 支：value-key 的 LOOKUP-KEY 段——床比 `"尚無"`／`"尚無（還沒有這種情報）"`／`"另有 %d 筆"`，UI 寫 `"  尚無"`（帶前導空白）⇒ 字面全庫各一次＝床與 UI 各抄一份字，打錯不會紅。修＝UI 出具名常數 `TextUiMain.INTEL_NONE`／`INTEL_NONE_NO_SOURCE`／`INTEL_MORE_FMT`，床讀同一份（2d77e1161），沒加豁免。第一輪只落地 grep 摘錄 `battery-ef80e9cef-red-excerpt.txt`（同資料夾）——全文被第二輪同檔名覆寫，我的疏失。
- 原始輸出：`docs/measurements/2026-10-15-intel-panel/battery-2d77e1161.txt`（main，隨本信同 commit）。
- 同資料夾（main）：`intel-panel-bed.txt`（床全文，2d77e1161 clean）、`neg-n1.txt`…`neg-n5.txt`（同 sha 加一處負對照改動）。
- 普查原始輸出在分支上：`docs/measurements/2026-10-15-intel-panel/inquiry-three-state-census.txt`（7aeb9f50c）。

## 先量：打聽三態的母體（spec 追加「先量再修」）
`scripts/debug/inquiry_three_state_census.gd`：seed 1337 推到 t1560（第 2 天 02:00，藍圖真玩那一刻）。逐一問每支活著的 NPC 三個會寫 belief 的題目，共 51 次，每次之前把玩家側三份帳還原。
- 三態判定本身是**逐目標**比的（CLAIM_VALUE_KEYS，寫入前後比勝出那筆）——**不是拿整包比**。
- 落進「他說的你早就知道了」的只有 2 次，都是 Team11（ask_team_location／ask_enemy_movement）：玩家 Team15 只知 [11]；Team11 只知 [15]，也就是**玩家自己**。
  - `resolve_inquiry` 的回答把「你在哪」列成 1 筆，`_exchange_intel` 的 claims 段跳過 `tgt_id == receiver_id`，寫 0 筆 ⇒ written／refreshed／conflicted 全 0、payload 非空 ⇒ 落最後那支「早就知道」。
  - 這就是藍圖「我只知一隊卻被判全知道」：它問的那一隊只知道它自己。普查世界的玩家位置是 (9,2)，藍圖真玩當時在 (9,1)，所以這是同 seed、同時刻重現出來的機制，不是同一局的逐位重播。
- 修：①「他也不知道」的判準不算回答裡說的是提問者自己的那幾筆；②回答逐筆列（下節）。

## commit（branch feat/intel-panel）
| sha | 內容 |
|---|---|
| 7aeb9f50c | 普查床＋原始輸出 |
| 26cf888a9 | 查詢面：`query_memory_panel` 擴欄（不改名）。過期線抽成 `BeliefSystem.belief_stale`，`belief_pos` 兩條通道改呼它；親見謂詞抽成 `PlayerQueryApi.is_firsthand`，`_remembered_teams_at` 改呼它 |
| 2387b7f3d | 打聽逐筆列：`_exchange_intel` 記 `out.items`（寫進接收方的每筆 claim：哪隊、他說的位置、位置 tick、三態）；handler 放進 payload `inquiry_items`；sim_runner 帶進 `command_results.items`；`_inquiry_payload_empty` 跳過說的是提問者自己的那幾筆 |
| 8789b1adf | UI：「記憶」改「情報」、主畫面 `[J]` 直達（主畫面原本未綁；鍵列加「[J]情報」）、四類各列、每類 5 列＋「另有 M 筆」、N 分鐘前與過期在 UI 算；打聽結果句下逐筆一行 |
| e753adad0 | `scripts/debug/intel_panel_bed.gd`（acceptance，13 格點名） |
| 9e9fc89b2 | docs/message.md 加一節 |
| b1a4fa069 | 併 origin/main 629d71655（無衝突） |
| ef80e9cef | 註冊表登 `intel-panel` |
| 2d77e1161 | 情報頁空類／折疊列的字抽成具名常數，床讀同一份（第一輪電池 LOOKUP-KEY 紅） |

## 床（intel_panel，13／13 到場、errors 0）
- I1：按 J ⇒ 分頁 4＝情報、頁首「── 情報 (5/5) ──」、鍵列有「[J]情報」。
- I2：giver 親見 Team1 在 (15,2)，撥鐘 90 分後打聽 ⇒ payload `pos=(15,2)`、`pos_tick=0`（絕對 tick，沒有相對欄）；畫面「Team1 (15,2)｜聽說，來自 Team0｜位置是 90 分鐘前的｜關係 不明」。
- I2b「Team2 位置不明｜…｜人口約 7」｜I2c 關係未知「不明」、設 0.62 後印 0.62｜I3「｜親見」不帶「聽說」｜I4 真位置 (11,8)→(20,0)，情報頁仍 (15,2)。
- I5 沒有據點「尚無」；放一筆後「(14,2) Team0 的民用據點（等級 2）｜關係 +0.00｜0 分鐘前看到」｜I6「尚無（還沒有這種情報）」。
- I7：未過期那隊，情報頁的格＝游標處那一格的隊；過期那隊，情報頁標「（太久，視同不知）」、游標處不列。
- I8：同 tick 兩次、隔 tick（只撥鐘）JSON 都相同（母體地板：payload 有隊伍列）。
- I9：走真的指令佇列。給方 known_targets 5 筆（含你自己），回答逐筆 4 行：
  ```
  　Team1 在 (15,2)（消息是 31 分鐘前的）｜新
  　Team2 在 (15,3)（消息是 31 分鐘前的）｜新
  　Team3 在 (15,4)（消息是 31 分鐘前的）｜你早就知道了
  　Team4 在 (15,5)（消息是 31 分鐘前的）｜他說的跟你知道的不一樣，你沒採信
  ```
  結果句仍是「他說了些事情（記下 2 筆，來自 Team0）」（三支既有床 grep 這幾句，結果句沒改字）。
- C：給方只知道你 ⇒ 回答 locations 1 筆（你自己）、結果句「他也不知道」。
- CAP：8 隊 ⇒ 隊伍類 5 列＋「另有 3 筆」；第一列是位置 tick 最新的。

## 負對照
| 對照 | 紅 |
|---|---|
| n1 拔主畫面 J 分支 | I1 兩格 |
| n2 不記 items | I9 七格 |
| n3 不跳說的是自己的那幾筆 | C 兩格 |
| n4 查詢改讀真位置 | I2×2、I4、I7×2 |
| n5 UI 不判過期 | I7「太久，視同不知」 |

## 跟 spec 不一樣的地方
1. **沒有修前跑**：床呼新 API（`intel_lines`、`INTEL_KEY`、`UiPages.INTEL_PAGE`），修前樹 parse 不過。修前紅那三格（I1、I9、C）由 n1、n2、n3 各拔一處代表。
2. **unbound_key_bed 沒有東西要登**：那支床從 `_handle_*_mode` 機械抽鍵，主畫面不是其中一支（main 的 match 在 `_input` 裡），所以 J 進不了它的母體，也不會讓它紅。J 只登進 MODE_KEYMAP。
3. **勢力關係恆「尚無」**：TeamData 只有隊層 `known_reputations`，沒有勢力層的 belief。照 spec「只列 belief 裡有的」⇒ 永遠空。要有內容得先有那一種 belief（不在本票）。
4. **據點的類型／等級／看到的時間**：`_known_outpost_relations` 只回 tile_pos／owner／g。我用同一隊的 `BeliefSystem.known_outposts` 按格補上 type／level／last_tick（同一份帳，不是第二個來源）。市集是據點格上的掛單，不是另一種東西，所以類別名叫「據點與市集」，列上印民用／軍事據點。

## 要你知道的
- ★known_issues「掛單與押貨（escrow）對玩家不可見」的回訪觸發寫的是「交易面板或情報面板下一次改版時」——**這次就是**。本票 spec 沒有這一項，我沒做，交你判要不要開。
- world-fp：電池內 world-fp ✓（464s）、world-fp-ctrl ✓（925s）。改動不碰 NPC 決策：`belief_stale` 是同式抽出；items 只寫在 `_exchange_intel` 的 out 參數（到達交換走預設值，用完即丟）；`command_results` 多一個 `items` 鍵，只在 handler 給了 `inquiry_items` 時才帶。
- 情報頁 render 時呼 `best_claim`／`_known_outpost_relations`，Probe 開著時會計數（游標處 `tile_knowledge` 一直如此，同一種副作用）；不耗 RNG、不寫 state。
- 勝出 claim 的選法用 `effective_credibility`，裡面有隨時間衰減。理論上兩筆 claim 的勝負可能隔 tick 翻轉，那時 payload 會跟著變；I8 只驗單一 claim 的情況。這不是新行為：游標處同一支本來就這樣。
