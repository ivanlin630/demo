# 客戶端不解釋遊戲鍵＋離開不綁 Q＋情報帶內容——HOW

狀態：草稿，待 R²
來源：藍圖 2026-10-13-blueprint-to-systems-TICKET-play-py-hijacks-q-so-battle-move-quits-the-game（第五輪用戶真機回饋 #1）
順位：插到「附身隊後續三件」之前（實作端手上那張停在乾淨點，branch 上 commit，回頭續做）

## 事實（main b67eb8d11 之後）
- `tools/play.py:301`：`line.strip().lower() in ("q","quit",QUIT_TOKEN)` ⇒ 送 `:quit` 並 break ⇒ **q 永遠到不了遊戲**，戰鬥裡六向移動的 Q 一按就斷線。
- 遊戲側：`text_ui_main.gd:605-609` 主畫面 `KEY_Q` ⇒ `get_tree().quit()`（遭遇中 pass）；鍵列 `text_ui_main.gd:1104` 寫「[Q]離開」。
- `player_repl.gd:66` `QUIT_TOKEN=":quit"` 是 harness 層離開，與遊戲鍵分開。
- 情報：`belief_system.gd:317` `WorldEvents.emit(state,"intel_arrived",[obs_id],_wake)` 不帶 info；`world_events.gd:368` 只能印「X 收到了情報」。全 scripts 只有這一個產生者。

## 改法
1. **play.py 不解釋任何遊戲鍵**：刪掉 `"q"`、`"quit"` 兩個字面；只認 `QUIT_TOKEN`（`:quit`）與 Ctrl+C（`key_token` 已把 Ctrl+C 轉 `:quit`）。所有其他 token 原樣送。拿掉 :301-304 那段過期註解。
2. **遊戲側離開不綁 Q**：`KEY_Q` 主畫面分支拿掉 quit（主畫面 Q 無作用 ⇒ 走既有「此鍵無作用」路）。離開改 **Esc 兩段**：主畫面（沒有任何面板／模式開著時）第一次 Esc ⇒ 結果行「再按一次 Esc 離開」並記旗標；下一鍵若是 Esc ⇒ 離開；其他鍵 ⇒ 旗標清掉、照該鍵原意處理。
   - 先查：主畫面 Esc 目前有沒有綁別的意思（面板／模式內的 Esc 是關閉，照舊——只有「什麼都沒開」那一層才進兩段）。有衝突 ⇒ 交件信列出、不自行取捨。
   - 鍵列「[Q]離開」改「[Esc×2]離開」，`KEYMAP_NEEDS` 同步。
   - 終端路徑：`PlayerRepl` 對 Esc 已有命名鍵（F5 `NAMED_KEYS`）；確認 Esc 能經 `press_on` 進到這一層。
3. **戰鬥結束那一拍不吃下一鍵**：戰後畫面到主畫面的切換那一刻，同一次按鍵不得同時被兩個模式解讀（例：戰後「按任意鍵離開」吃掉一鍵後，同一鍵又落到主畫面）。實作端先用床重現（管道送「戰鬥最後一鍵＋一個主畫面有意思的鍵」），重現得到才修，修在模式切換的入口（一鍵只派給一個模式）；重現不到 ⇒ 交件信寫明試了哪些序列。
4. **情報帶內容**：`intel_arrived` emit 帶 info `{tgt: tgt_id, pos: fields["tile_pos"]}`（都是觀察者這次寫進 belief 的值，不是真值——感知鐵律）；`describe` 改「<隊> 得知 Team<tgt> 在 (q,r)」。info 缺欄 ⇒ 退回舊句（不印空對象）。
   - 「糧源情報同型」：目前沒有糧源情報這種事件（糧源 belief 種類在深層批）⇒ 本票不做，在交件信註明。

## 驗收（床，管道餵鍵走 play.py 同一條路或 PlayerRepl）
- Q1（修前紅）：進遭遇戰後送 `q` ⇒ 連線不斷，結果行是移動句或邊界句。
- Q2（修前紅）：主畫面送 `q` ⇒ 程式仍在，結果行「此鍵無作用」型。
- Q3（修前紅）：主畫面 Esc 一次 ⇒ 仍在＋提示；Esc 兩次 ⇒ 離開；Esc 後按別的鍵 ⇒ 不離開且該鍵照原意。
- Q4：面板開著時 Esc ⇒ 只關面板（不進兩段）。
- Q5：play.py `--selfcheck` 加一格：`key_token` 後的 `q` 照原樣送出（不轉 `:quit`）。
- Q6（若 3 重現得到）：戰後切換那一鍵只被派一次。
- Q7（修前紅）：事件區出現 intel_arrived 時句子含對象與座標；全跑一次 E2E，「收到了情報」0 筆。
- 負對照：play.py 放回 `"q"` ⇒ Q1 紅；`describe` 放回舊句 ⇒ Q7 紅。
- terminal E2E 照綠；有既有步驟用 Q 離開的 ⇒ 改成 Esc×2，交件信列出。
- world-fp 不變（info 多帶欄位不進世界狀態）。
