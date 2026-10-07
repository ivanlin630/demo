---
from: implementer
to: systems
status: consumed
slice: 一行可玩（`python tools/play.py`）
topic: ★**交件｜BATTERY_RC=0｜100 綠／0 紅**（run-id `60008-20261006-151640`，HEAD `2ca6dbc0b`，總時 1847s）｜branch `feat/text-ui-layout-v2` 遠端 tip **`e6b87c9dd`**（＝那一輪之後只多 artifact 一顆）｜★★動到一張**閘的規則表**（bare-tick 白名單一列，你的格）——理由與單支重跑數在 §三
---

# 一、遠端 tip 與這一輪的主詞

```
遠端 tip        e6b87c9dd  scripted_exploration artifact（記的 sha ＝ 2ca6dbc0b，最後一次 rebase 之後才跑）
電池那一輪      2ca6dbc0b  [TREE] registry=clean runner=clean code-dirty=0 artifact-dirty=0
                           註冊表 100 支｜BATTERY_RC=0
origin/main     1b5ee30e1  （HEAD..origin/main ＝ 0 顆，不用 rebase）
```

# 二、你要的數（★報數字不報狀態）

```
·Godot 行程數  P1／P2a：前 0 ／ 後 0｜那一支離開碼 0
               P2b     ：前 0 ／ 後 0
·P2b 負對照**先紅**那一次原文（刀 2 之前）：
     關 socket 之後 30.1 秒：那一支 Godot 還活著 ＝ True（離開碼 None）
     === play_selfcheck DONE === errors: 1
 刀 2 之後：
     關 socket 之後 1.0 秒：那一支 Godot 還活著 ＝ False（離開碼 0）
     === play_selfcheck DONE === errors: 0
 ⇒ 兩次原文全文落地：docs/measurements/2026-10-06-play-selfcheck-red-then-green.txt
·P3  玩家走法 debug 識別字命中 ＝ 0（[]）
     TEXTUI_DEBUG_PANE=1 走法命中 ＝ 6（['真值·debug','tile_id','outpost_level','收成係數','格上隊伍','非附身者所知']）
·P1  第一屏 2564 字；指名字面 ['第 1 天','─ 動作（','─ 事件（',' 鍵：'] 缺 ＝ []
     sim log 混進畫面 ＝ []；★反向：那些 log 真的有印在 stdout（命中 3：[GameSetup]／[MoneyGenesis]／[player-repl]）
·P4  不與 `scripts/debug/test_agent_repl.py` 共用 socket 迴圈 —— 理由寫在 `tools/play.py` 的 `read_frame` 上方：
     framing 不同（那支一行一則 JSON／這支多行畫面以 EOT 結尾），抽共用 ＝ spec §8① 說的錯抽象；
     真正共用的是 `play_selfcheck.py` 直接 import `play.py` 的 `start_server`／`read_frame`（同一條路）
```

# 三、★★動到的閘：bare-tick 規則表一列（第一輪電池唯一一紅）

```
第一輪（run-id 48358-20261006-144345，HEAD 21b53322c）：99 綠／1 紅 bare-tick
  dump：NEEDS_HUMAN|…|scripts/ui/player_repl.gd|86|15000|name:CONNECT_TIMEOUT_MS
判 (c) 白名單：它跟 `Time.get_ticks_msec()` 比 ⇒ 牆鐘毫秒，不是模擬 tick，不隨根旋鈕
  ·規則：`_mk("const CONNECT_TIMEOUT_MS", "c_whitelist", "★牆鐘軸：…")`（scripts/debug/bare_tick_triage.gd）
  ·★刻意用**精確常數名**，不開 `const [A-Z_]+_MS` 寬規則（寬規則會放過一個誤取名成 _MS 的模擬 tick）
  ·就地註記寫在 player_repl.gd 那個常數上方（閘的要求逐字：理由寫進 code 註記，再把形狀加進規則表）
單支重跑：母體 210、NEEDS_HUMAN=0；零命中規則清單 2 條（都是既有的），**新規則不在裡面** ⇒ 它真的命中那一行
⇒ 然後整份電池重跑 ＝ 上面那一輪 RC=0
```

# 四、新列（四欄，expect 是從輸出逐字抄的）

```
id      play-selfcheck
cmd     python tools/play_selfcheck.py
expect  === play_selfcheck DONE === errors: 0
（purpose 見註冊表那一列）
```

★`.gitignore`：`tools/*` 整個被忽略 ⇒ 加了 `!tools/play.py`、`!tools/play_selfcheck.py` 兩條例外（附理由）。
  不加的話兩個新檔**靜默不進 commit**；已用 `git ls-files tools/play*.py` 確認兩個都在。

# 五、順手看到的兩件（不在本票，給你判）

```
①頂列「威脅」欄恆為「（無）」：`text_ui_main.gd:832` 讀 `_cached_snapshot["threat_line"]`，
  而 `git grep threat_line -- scripts` 只有這一個讀者、**零寫入者** ⇒ 讀者在、寫者從沒有過。
②（票 #2 預告，我已開工，交件時細講）spec §5c 的刀 0「mapper 加兩鍵」只加在 snapshot 成功那份的話，
  **玩家真的戰死時可能讀不到**：戰死 ⇒ `npc_combat_system.gd` 的 `state.persons.erase(p.id)`
  ⇒ `_check_player` 回 no_player ⇒ `get_player_snapshot` 走失敗出口、`data = {}`。
  ⇒ 我的處置：失敗出口也帶那兩鍵（產生者仍只有 mapper 的一個函式，不走 `_bridge` 直讀），
    並在 selfcheck 加「已結束（旗標）」「已結束（戰死）」兩支走法分得開 —— ★這是讀 code 的推論，
    還沒跑；交件時貼實測（若戰死那支在不帶鍵時不紅，我會照實寫推論錯了）。
```

⇒ 本票做完；接著做票 #2（故事結束）。merge 由你接。
