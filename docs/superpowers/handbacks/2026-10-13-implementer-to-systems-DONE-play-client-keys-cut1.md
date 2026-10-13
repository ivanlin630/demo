---
from: implementer
to: systems
status: open
slice: 客戶端不解釋遊戲鍵 第一刀（play.py 刪 q／quit 離開）
topic: 請 merge 6c6cedb40（只動 tools/play.py）｜全電池釘死 6c6cedb40：119 支 BATTERY_RC=0（3708s）｜branch fix/play-client-keys 遠端 tip 是 c6a49235b（含第二刀，第二刀還沒交）
---

# 第一刀：可以 merge

- **要 merge 的 commit**：`6c6cedb40`（branch `fix/play-client-keys`）。
  - ★遠端 tip `c6a49235b` 已經疊了第二刀 ⇒ 第一刀請只 merge `6c6cedb40`（它是 c6a49235b 的父）。
- **改了什麼**（只有 `tools/play.py`）：
  - 主迴圈的離開判斷抽成 `is_quit_line(line)` ＝ `line.strip() == QUIT_TOKEN`。`q`／`quit` 照原樣送進遊戲。
  - 離開路只剩 `:quit` 與 Ctrl+C（`key_token` 把 Ctrl+C 轉成 `:quit`）。
  - 拿掉 :301-304 那段過期註解；橫幅改成「（Ctrl+C 離開）」（第二刀再改成 Esc×2）。
  - `--selfcheck` 加 Q5：`is_quit_line` 對 q／Q／quit／QUIT 回假、對 `:quit` 回真；`key_token("q")` ＝ "q" 且不算離開。
- **驗**：
  - `python tools/play.py --selfcheck` errors 0；`python tools/play_selfcheck.py` errors 0。
  - 負對照：`is_quit_line` 放回 `in ("q","quit",QUIT_TOKEN)` ⇒ selfcheck 紅 5 格。
  - 全電池：detached worktree 釘死 6c6cedb40，119／119 ✓，BATTERY_RC=0，總時 3708s，摘要 `docs/measurements/.battery/1017-20261013-213849.txt`（那棵樹）。
- **第一刀之後、第二刀之前的一個中間態**（照 spec 分刀本來就會有）：主畫面送 q 會進到遊戲的 `KEY_Q` ⇒ `get_tree().quit()` ⇒ 遊戲結束。play.py 那時還沒有 EOF 分支 ⇒ 下一鍵可能撞已關的連線。第二刀把兩邊都收掉（KEY_Q 不再離開、play.py 讀到空／連線重設就印「遊戲已結束」退出碼 0）。
- 電池產物 `docs/measurements/2026-09-30-scripted-exploration.txt` 只有 sha 行變 ⇒ 不帶。

## 第二刀狀態
- `c6a49235b` 已 commit：Esc×2、拿掉 KEY_Q、戰後一鍵一派（引擎廣播那條路修前實測紅：戰後按 W 同時移了主畫面游標）、情報帶內容、play.py EOF。床 `play_client_keys_bed.gd` 0 錯、play_selfcheck Q3 綠。
- 還沒交：①回饋 #6 的折疊與 written／refreshed（已在工作區寫一版、未 commit），等你收審查員 2de9898a9 的四點（比較鍵清單、三態結果句）；②負對照與全電池。
