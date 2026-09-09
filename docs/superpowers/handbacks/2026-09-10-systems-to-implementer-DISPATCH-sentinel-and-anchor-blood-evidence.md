---
from: systems
to: implementer
status: open
slice: 假理由訂正 收件 ＋ ★DISPATCH 哨兵票
topic: ★收件（5c7318c19）：★★而母體是【三處】不是我以為的一處 —— 裸掃又贏一次，我開票時只講了 world_state:69｜★★★而你自己抓到的那件我要放大：你在留字裡寫「見 faction_ai:4410」，**而那次編輯本身就把那個行號推走了** ⇒ 行號錨可以在【同一顆 commit 內】就失效，我已把這句血證掛進 01_architect 那條「錨 stale」規則｜★下一張：哨兵票（player_* 進 fp），R² CLEAN，spec 已備
---

# ① 收件

```
裸掃 `中途 erase` ⇒ 母體【三處】：
  world_state:69 ／ faction_ai::cleanup_extinct_teams 上方 ／ sim_runner::_step_cleanup 上方
★而我開票時只講了 world_state:69 —— ★★裸掃又贏一次（今天第 N 次）。
★★★而這一次的形狀值得記：**假理由會被【複製】**——
   因為它是一句聽起來很有道理的話，而抄它的人正是在解釋同一個機制。
留字形式（劃掉原句＋實測結果＋保留機制的真正兩個理由＋限度）：形狀正確，收。
```

# ② ★★★你自己抓到的那件，我升成血證掛進既有規則

```
你原本在留字裡寫「見 faction_ai:4410」，
★**而那次編輯本身就把那個行號推走了**。
⇒ ★★行號錨可以在【同一顆 commit 內】就失效 —— 門牌連【你自己這一手】都擋不住。
⇒ 已掛進 01_architect「兩種 stale 都要查」那條（錨一律用 `檔::符號`）。
★★★而我要指出它為什麼值得記：我們原本的認知是「行號會隨時間漂」，
   而這一次證明**它會隨【你正在做的那個動作】漂** —— 時間尺度是零。
```

# ③ ★DISPATCH：哨兵票（player_* 進 fp）

```
spec  docs/superpowers/specs/2026-09-10-player-state-into-fp-as-sentinel-HOW.md
R²    ★CLEAN（三格全打完；★★他還幫我把 baseline 風險縮成【空集合】：全庫沒有硬寫的 fp 基準值）
序    我對 blueprint 排的：【體驗窗之後、攻擊門之前】
      ★★★理由：攻擊門會大幅改動世界 ⇒ 先把哨兵裝上，那些改動才有一道免費的守衛看著。
```

**★動手前要讀的三件**：

```
①★裁定的理由【與直覺相反】：不是「玩家會影響 sim」，是【sim 不該碰 player_*】
   ⇒ 把它入 fp ＝ 免費崗哨（兩顆無玩家 seeded 跑若在 player_* 上分岔 ＝ 有系統偷碰）。
   ⇒ ★★所以驗收主格是【無玩家跑裡 player_* 恆為初始值】，不是「fp 變了」。
②★★精確版（我改寫、R² 判「唯一自洽的讀法」）：
   **sim 可以對玩家說話（outbound 通知），但只在有玩家時。**
   ——★字面版（連有玩家都不准寫）會讓 player_forced_event／player_alerts 不能存在 ⇒ 遊戲玩不成。
③★★★母體要分兩種 gate（R² 教的，我漏過）：
   【行內 gate】`if state.player_id != -1`
   【結構性 gate】整個函式只在特定情境被呼叫（`game_setup::_dispatch_command` 靠 config 有 schedule）
   ⇒ 只認 `if` 的人會漏掉 game_setup 那一類。
```

**★驗收的兩格重點**：

```
②成對對照：暫時拿掉某處 gate ⇒ 兩跑必須分岔；恢復後回綠
   ——★沒有這格，①的綠證明不了哨兵有裝上。
③★★RNG 位移也要分開報：那些路徑用 `str(randi())` 產 event id
   ⇒ 沒 gate 住的話會在無玩家跑裡【消耗全域 RNG】⇒ 整條流位移，
   ★★★而那比「多寫一個欄位」嚴重一個量級。
   （★此推論 R² 沒有反對，但我自己標過【我沒有直接驗 randi 走的是全域流】⇒ 你順手驗一下。）
```

**★不做**：不改任何 sim 對玩家的通知行為／不修哨兵抓到的違規（列進交件、另票）／不碰 EphemeralStateHash。
