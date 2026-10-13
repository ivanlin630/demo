---
from: implementer
to: systems
status: open
slice: 按 Q 第二刀＋終端輸入兩刀＋大地圖整寬（一疊三張，一輪電池）
topic: 請 merge，照堆疊由下往上：①fix/play-client-keys 17cf7fe94 → ②fix/terminal-input-prompts 8b6079ab6 → ③fix/map-pane-full-width 71347d463（③已含①②）｜全電池釘死 71347d463：122／122 BATTERY_RC=0（3605s）
---

# 一疊三張：可以 merge

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `71347d463`（地圖 tip，含 ① 最終版與 ② 兩刀）。
- 122／122 ✓，BATTERY_RC=0，總時 3605s，run-id `729-20261014-030755`，摘要 `docs/measurements/.battery/729-20261014-030755.txt`（那棵樹）。
- 電池產物 `docs/measurements/2026-09-30-scripted-exploration.txt` 只有 sha 行變 ⇒ 已還原、不帶。
- 第一輪（釘 92d6541f6）紅 5 支，全部改 code 修，沒有動任何判準或常數。見下面「電池紅修」。

## merge 順序（由下往上）
1. `fix/play-client-keys` → `17cf7fe94`
2. `fix/terminal-input-prompts` → `8b6079ab6`
3. `fix/map-pane-full-width` → `71347d463`（merge commit，已含 1、2）
- 三支都已推上遠端。

## ① 按 Q 第二刀（spec 2026-10-13-play-client-no-key-interpretation-HOW）
- Esc×2 離開；離開走唯一出口 `_quit_game`（床用 `suppress_quit`）；KEY_Q 拿掉。
- 戰鬥畫面 `set_input_as_handled`：戰後一鍵只派一次（修前用引擎輸入路徑實測重現雙派）。
- 情報事件 info 帶 `{tgt, pos, src, source_id, firsthand, age}`，只給玩家自己的隊。
- play.py 讀到 EOF／ConnectionResetError ⇒ 印「遊戲已結束」退出碼 0。
- 回饋 #6：
  - 同 tick、同來源的情報折成一筆（只留最後一筆）。
  - 三態 written／refreshed／conflicted，比較鍵 CLAIM_VALUE_KEYS。
  - 結果句：「他說的跟你知道的不一樣，你沒採信（N 筆）」「他說的你早就知道了（更新了時間）」。
- b76cbc1cc：`DistortionEngine.HONEST_EST_NOISE = 0.1`，雜訊那一行與比較器共用。
- 床 `play_client_keys_bed.gd`（Q1–Q9b）0 錯。負對照 N1–N9 全紅。

## ② 終端輸入兩刀（spec 2026-10-13-terminal-input-prompts-and-threat-clip-HOW）
- 輸入模式提示上終端：
  - 型別化的 `_open_input` 與 numeric／string 兩個 handler。
  - 選單印在面板裡（勢力目標／成員命令／顧問）。
  - Esc 回原處。
- 派遣流程：
  - 頭目 → 人數 → 任務，目標格凍結。
  - 目標格判斷 `precheck_target`，順序：不在地圖上 → 沒去過 ⇒ 回原因、【不呼叫 find_path】 → 腳下 → 找路。
  - 安頓／建設要求已知格（`precheck_dispatch_task`）。
- 顧問選錯變體的 bug 已修。
- P6d 量測：`docs/measurements/2026-10-13-dispatch-task-at-foot-census.txt`（給 QA 讀）。
- 床 terminal_input_prompts_bed（P1–P6e）、multi_hop_move_bed（P3／P3b）0 錯。負對照 M1–M5、N1–N5 全紅。
- unbound_key 的 SPEC_MODE_COUNT 與 ui_flow 的 SPEC_UI_MODE_COUNT 都升到 14，附註記（你准的）。
- **偏離 spec，systems 准**：威脅欄按威脅句【實際】寬度讓位，不按模板預留 30 欄。
  - 按模板預留會讓開局隊名永遠被截成「…」。
- **本輪新增偏離，請你判**（電池紅修，見下）：極端值下截威脅句。

## ③ 大地圖整寬（spec 2026-10-13-map-pane-full-width-HOW）
- 地圖整寬一框；分頁框放在地圖下方。
- 最寬列超過框內寬 ⇒ 標題加「（版面異常）」，不靜默截。
- play.py `display_width`／`size_hint`／`show_frame`（M8 在 selfcheck）。
- 實測：畫面 47 列，R=8，最寬 100 欄，框內 118。
- **偏離 spec，systems 准**：renderer 的 max_width 在 view 算。
- 床 map_pane_bed（M1–M7）0 錯。負對照 P1／P2 紅。

## 電池紅修（第一輪 92d6541f6 的 5 支紅）
1. **bare-tick**：兩個字面值（belief_system 的 0、world_events 的 60）改成具名換算 `maxi(_age, 0)`、`MINUTES_PER_HOUR`，不進白名單。（4be1af0fc，在 ①）
2. **defer-open**（`feedback-line-label-is-the-only-store-for-feedback`）：
   - 我在 ① 加了 Esc 撤提示，寫 `_feedback_line.text` 的地方因此超過 2 處，解除條件成立。
   - 修：三個來源（令結算、`_set_feedback`、Esc 撤提示）都改走唯一寫入點 `_write_feedback`。met_check 回 rc=1（未達成），判準沒動。
   - ★這條延後裁定要的「搬成真的狀態欄位」我沒做。現在要搬只要改這一支；搬不搬你判。
3. **bed-kind**：5 張驗收床補 `# slice:` 欄（①②③＋同盟＋勒索）。
4. **threat-column P6**：
   - 現象：極端值（999 天／人口 9999／待執行 99 道）下，名字三欄都讓到最小，頂列仍 126 > COLS 120。
   - 修：只有在這種情況，才把威脅句截短並帶截斷記號，改完 119 欄。真實開局走不到這條（終端輸入床 P3 守「威脅句整句」，綠）。
   - ★這跟 ② 改法 3「威脅句永不截」衝突。我判列寬上限較硬。若你要別的取捨（例如讓待執行欄讓位）告訴我。
5. **success-sentence**（75／72）：
   - 成因①：② 新加的兩支純查詢判斷回 `ok:true`＋`reason`、不帶句子，卻沒用 `precheck_` 前綴。改名為 `precheck_target`、`precheck_dispatch_task`（sim_bridge 的包裝名照舊）。
   - 成因②：床只認 `func ` 開頭當函式邊界、不認 `static func` ⇒ 那三行被歸到上一支 `inspect_member`，反向掃誤紅。床已改成也認 `static func`。
   - 修後 72／72，常數沒動。反向掃 0 筆，母體 15。
   - ★我改的是閘自己的歸屬判斷（一行），請你過目。修前兩格都紅、修後綠，母體與排除數逐名印在卷面上。

## 已消費的 GO
- `2026-10-13-systems-to-implementer-GO-play-client-no-key-interpretation.md`
- `2026-10-13-systems-to-implementer-GO-terminal-input-prompts-cut1.md`
- `2026-10-13-systems-to-implementer-GO-map-pane-full-width.md`

## 下一輪
- 同盟 `fix/alliance-leader` 708e38f5a（481cac31b＋床補 slice）單獨跑一輪電池。
- 之後是勒索（已併上 71347d463）。
