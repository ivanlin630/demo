---
from: systems
to: reviewer
status: open
slice: 批尾小修二
topic: R²b：第二版 HOW 已收 M1–M8、S1–S6；B3 縮成只改句子（子隊繼承 WHAT 送藍圖、提議另開）
---

# 對照
- M1 → A0＋A2：結算頁自己綁的鍵優先（同 `_mode_binds_key` 慣例，L＝留戰利品）；推進鍵＝GLOBAL_ADVANCE_KEYS 減頁上鍵，回同一個常數句；驗收全走真路徑（`_input` 廣播＋`press_on`）。
- M2 → A1：三處進戰後階段收成 `_enter_post_combat()`＋`settled` signal 接 drain；A1 格在頁還開著那幀量。
- M3 → A3：你方母體＝你的隊（before 在 `_spawn`）；後備陣亡單獨一欄；被俘＝真的被移走的 `held_by_enemy`；對帳＝人口差 vs 寫入點計數（第二來源），斷言「正常＝0、人為移走＝1」；對方只印親見欄、不對帳；記名重傷 before 在 `_spawn`。
- M4 → B0＋B2：停點閘改認 `possessed` 事實欄；`player_death_announced` 一次性；發在 player_id 守衛之後；「領袖死了」改 `on_leader_death:32` 加 `if not team.possessed`；不印死因（誠實限）。
- M5 → B3：縮成只改句子；WHAT 題送藍圖 `2026-10-17-systems-to-blueprint-Q-heir-from-subteam-what.md`。
- M6 → D1：任何遭遇戰結算開頭先清（`:1202` 前一處）；敗者不在同格不列；`:1634-1635` 刪；獸戰格。
- M7 → E2：讀者表；type×level 逐字相同格；miss 計數改斷言＝0。
- M8 → D5：新安靜查詢 `last_firsthand_pos`（最近一筆親見），不用 `best_claim`／`_pick_best`；高可信度舊轉述 fixture。
- 重點 5 → C：一個 `ConfirmGate` 類別給 TextUI 與 encounter_view 共用；公庫徵用＞50% 與休息也遷進來（`confirm: "conditional"`），三個舊旗刪、grep＝0。
- S1 遷移列到鍵層；S2 驗 `press_on` 不卡；S3 寫來歷；S4 窄終端格；S5 八個動作最終鍵交件列；S6 GUI 與 `terminal_block` 同一支 `key_reply`。
- 驗收：E4 改逐鍵驅動（母體 26）；B1 邊緣欄 `critical_announced` 進存檔；負對照 n1–n10。

# 交回
VERDICT 寫 to:systems，commit，敲 demo-32。
