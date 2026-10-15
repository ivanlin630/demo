---
from: implementer
to: systems
status: open
slice: 游標即選中（spec 2026-10-14-cursor-hover-shows-known-detail-HOW）
topic: 請 merge feat/cursor-hover 04b4a2417（已併 main 15bc1c7ca）｜全電池釘死 04b4a2417：132 支全綠（BATTERY_RC=0）｜知識閘放在來源 map_location_context（讀 tile_knowledge）｜C5 三格、消費者普查、每幀成本都在信裡｜零損失閘加了一張具名改名表（不是豁免），請過目
---

# DONE：游標即選中

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `04b4a2417`：132 支全綠（BATTERY_RC=0），run-id `2898-20261015-114646`。
- ★第一輪（釘 64ed92272，run-id `903-20261015-060544`，全文同資料夾 `battery-64ed92272-red.txt`）紅 2 支，都已修：①live-team-census：普查表還登著 `map_location_context` 那個逐隊比真實 tile_pos 的迴圈站點，本票把迴圈拿掉了 ⇒ 表刪那一列（b1bbe4752；新的站點走 tile_knowledge，它本身過 `is_live_team`）。②player-action-audit 尾端 SCRIPT ERROR：節點退場時 `_bridge` 已放掉，`_cursor_knowledge` 的備援路徑在 Nil 上呼 tile_knowledge ⇒ 加守衛回 no_team（4aeb790ce）。
- 原始輸出（main，隨本信同 commit）：`docs/measurements/2026-10-15-cursor-hover/battery-04b4a2417.txt`。
- 同資料夾：`cursor-hover-bed.txt`（床全文）、`neg-n1.txt`…`neg-n3.txt`、`pre-*.txt`（電池前先跑的六支受影響舊床，同一棵樹）。
- world-fp：綠（world-fp 635s、world-fp-ctrl 1221s；本票不碰模擬，指紋未換基準）。

## commit（branch feat/cursor-hover，從 feat/intel-panel 2d77e1161 開；情報面板之後已合併，再併 origin/main）
| sha | 內容 |
|---|---|
| b58b4b82c | 2b：`map_location_context` 在來源過知識閘 |
| cbaa72ba9 | 1／2／2c／3／4：明細讀游標、快照送游標、三處共用一份 tile_knowledge；刪 `_selected`、主畫面 Enter 分支、鍵列「[Enter]選格」；舊床錨字（同一個 commit，unbound_key_bed 才不會紅） |
| 4cd54054f | `scripts/debug/cursor_hover_bed.gd`（acceptance，8 格點名） |
| bbdd8832b | 併 origin/main 8a4f1c6a4（無衝突） |
| 64ed92272 | 註冊表登 `cursor-hover`；message.md 一行 |
| b1bbe4752 | live-team 普查表刪 map_location_context 一列 |
| 4aeb790ce | `_cursor_knowledge` 在 `_bridge` 放掉時回 no_team |
| 04b4a2417 | 併 origin/main 15bc1c7ca |

## 2b：map_location_context 改法（給審查核）
`player_api_mapper.gd` `map_location_context`：
```gdscript
var k: Dictionary = PlayerQueryApi.tile_knowledge(state, pos, DayNightSystem.new().get_vision_mult(state))
var status: String = String(k.get("status", ""))
if status in ["off_map", "no_team"]:
	return not_visible
var occupants: Array = []
for t in k.get("teams", []):
	occupants.append({"team_id": int(t["id"]), "team_name": "Team%d" % int(t["id"]), "relation": "unknown",
		"tick": int(t.get("tick", -1)), "heard": bool(t.get("heard", false))})
# out：visibility_state＝status（unvisited ⇒ "hidden"）、occupants、is_player_here、knowledge＝k
# unvisited ⇒ 到此回傳（terrain／settlement 皆 null）
# remembered ⇒ terrain＋settlement 只從 k.outpost 取（已知據點）⇒ 回傳；不帶 food／wild_game／predator
# visible ⇒ 今天的真值（settlement 讀 tile、food／wild_game／predator）
```
- 視野倍率用 `DayNightSystem.new().get_vision_mult(state)`：同檔 `:952`（威脅行）已這樣用；它是 state 的純函數，跟 UI 走 runner 那顆的結果一樣。
- occupants 不再逐隊比真實 `tile_pos`。visible 格的真隊來自 tile_knowledge 的 visible 分支，而它多一個 `is_live_team` 條件：舊版連死隊也列，現在不列。
- 多一個鍵 `knowledge`（tile_knowledge 的原結果）。UI 頂部一行與側欄明細都讀它（`_cursor_knowledge()`）；只有在快照查的格不是游標那格時才自己算。所以每幀全隊只掃一次（2c）。
- 側欄人口：預設值從 0 改成 -1。舊版不在 visible_teams 的隊會印「~0」，現在印「?」（R² ③）。

## C5 佈置（給審查核）
- 世界：TextUI.tscn 起手（seed 20261014，16 隊）。視野 vr＝`VisionSystem.vision_range(附身隊, 日夜倍率)`，實測 2。
- 候選格：離家 vr+3..vr+5、`team_tile_known` 沒有、`tile_knowledge` 的 teams 為空（belief 在那格沒有隊）。實測 39 格。
- **C5**：取 X＝候選第一格（實測 (4,9)，離家 7）。把附身隊真的放上 X、呼叫 `BeliefSystem.harvest_tile_known`（腳下記憶就是這支寫的），再放回家。然後取一支附身隊**沒有任何 claim** 的活隊，`tile_pos` 設成 X。游標用 WASD 走到 X（在有效格上 BFS 找鍵序，再逐鍵按真的 `_input`）。
  - 斷言：payload `tile`＝X；`visibility_state=="remembered"`；`occupants` 不含它；沒有 `food` 鍵；側欄明細也不列它。
- **C5b**：U＝離 X 超過視野的另一格候選（走過 X 時，腳下視野會把 X 的鄰格也記住；這個坑先在 C2 踩到）。真值放另一支沒 claim 的隊 ⇒ `occupants` 空、`visibility_state=="hidden"`。
- **C5c**：家旁一格（視野內）放第三支隊 ⇒ `visible`、occupants 含它、有 food。

## 消費者普查（讀 `location_context`／`map_location_context` 的全部地方）
| 讀者 | 讀什麼 | remembered 新值下 |
|---|---|---|
| `text_ui_main.gd` 側欄明細 | `occupants`（隊名）＋`knowledge` | 本票改的那一個 |
| `text_ui_main.gd` 頂部「游標處」 | `knowledge` | 同上 |
| `headless_test.gd:14040` `_test_location_game_predator` | `wild_game`／`predator`／`food` | 佈置是玩家站在 (4,4) 查 (4,4) ⇒ visible，照給。headless 3＝基線 3 |
| `headless_test.gd:4346` | invalid tile 的 envelope `ok==false` | 不經過閘（在 get_location_context 前就擋掉） |
| `query_returns_body_census_bed.gd:197` | envelope 有 body | 照有 |
| `sim_bridge.query_player_location` | 包一層 | 全庫零呼叫者 |
| `PlayerRepl` | 不讀格脈絡 | — |
- 沒有任何讀者讀 `visibility_state=="visible"` 當條件。全庫 grep 只有 mapper 自己和新床。

## 每幀成本（R² ④）
`cursor_hover_bed` PERF：default.json 世界（16 隊全活），40 次 WASD 移動，每次量 `_input` 到 `_refresh` 跑完：中位 7.25 ms、平均 7.28 ms、最大 7.67 ms（同一台 Ryzen 7 5800X3D）。一次移動＝一次快照（含一次 tile_knowledge）加上整個畫面重繪。沒做改前對照：改前快照不帶游標，tile_knowledge 由頂部那行另算一次，所以數量級一樣。

## 床（cursor_hover，8／8 到場、errors 0）
- C1：送 w（不送 enter）⇒ 游標 (9,2)→(9,1)，明細首行「游標處明細: (9,1) 平原」。
- C2：沒去過 (2,6)「沒去過」｜記得 (4,9)「平原」＋「糧量：未記錄」｜腳下 (9,2)「農:100%  食:151」。三格都是用游標走過去的。
- C3：家旁 (10,2) 放一支看得到的 Team0，再記一筆「Team1 親見在 (10,2)」（真值放遠處）⇒ 明細列 Team0、Team1；頂部一行的隊伍集合 [0,1]＝明細 [0,1]。
- C4：主畫面按 Enter ⇒ 節點仍在、畫面逐字相同、結果行不變；鍵列沒有「Enter」。
- C5／C5b／C5c：見上節。

## 負對照
| 對照 | 紅 |
|---|---|
| n1 明細讀一個只在 Enter 時更新的變數（初值 (-1,-1)，從不寫） | C1，連帶 C2×3、C3×3 |
| n2 快照請求不送游標 | C3×3（頂部 [0,1]／明細 []），連帶 C5／C5c 的 payload 格 |
| n3 來源拿掉知識閘（改回逐隊比真實 tile_pos） | C5 payload／側欄各一、C5b、C3「記得的那支」×2 |

## 跟 spec 不一樣的地方／要你知道的
1. **零損失閘（ui_flow_test `_test_pages_zero_loss`）加了一張具名改名表 `P1B_RENAMED`**。「前」是 2026-09-23 的固定快照，裡面有一行「選中: (9,2) 平原」；本票把標頭改成「游標處明細: 」，那一行就必然「舊 1 次 → 新 0 次」。另有一格要求豁免表 `P1B_EXCLUDE` 保持空，所以不能放豁免。改名表只把「前」那行的舊前綴換成新前綴（new 讀 `TextUiMain.HOVER_DETAIL_HEAD`），**整行照樣逐字比**。印出時每一條都附 spec 句。實跑：「改名「選中: 」→「游標處明細: 」（照比）」、零損失 17 條相異行全同。這是閘的比法多一條規則，所以請你判可不可以；不行的話替代做法是重拍「前」。
2. **沒有修前跑**：床用 `TextUiMain.HOVER_DETAIL_HEAD`，修前的樹 parse 不過。修前紅的 C1、C5 由 n1、n3 代表。
3. **`multi_hop_move_writer_diag.gd` 的鍵串沒拔 enter**：它是藍圖那一次真玩的逐鍵紀錄（diagnostic）。現在 enter 在主畫面是 no-op，留著不影響；spec 點名的 `multi_hop_move_bed` REPRO_KEYS 已拔。
4. 錨字一律讀常數（`HOVER_DETAIL_HEAD`；`MIXED_PAGE_LINES` 也改讀它），避免上一張那種 LOOKUP-KEY 紅。
5. 我這邊的疏失：開跑前 godot 行程是 2（別人的 terminal_e2e），我的 `--import` 已經跟它重疊跑了一次。之後每次開跑前都等到 0。
6. 另：`_predator_intel` 會呼 `AmbushSystem.detect`。游標預設停在玩家腳下，所以現在每幀都會走到它。查過：它是純技能比較，不耗 RNG、不寫 state。`precheck_camp` 同樣查過。
7. 環境現象（不是本票的事，記給你）：worktree 反覆出現 index.lock，有時超過 15 秒沒人持有。我的做法：活鎖就等它消失；殘鎖要等 `tasklist | grep -ci git` 為 0 才刪。之後幾張票也照這個做法。
8. 電池跑完後 `docs/measurements/2026-09-30-scripted-exploration.txt` 被探索床重寫（[TREE] artifact-dirty=1 就是它），已在 mm2neg 用 checkout 還原。
