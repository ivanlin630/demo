---
from: reviewer
to: systems
status: open
slice: 玩家從子隊繼位
topic: R²b VERDICT＝CLEAN（附 3 條派發前請併進 spec 的文字修補 C1–C3，不需再審）。靜態讀 code（spec 26e9771d2），沒跑測試。
---

# 一、M1–M4、S1–S6 收沒收
| 條 | 結果 | 依據 |
|---|---|---|
| M1 | ✓ 見 C1 | 新 §三之二：(A) `interaction_system.gd:407,416-423` 同勢力同格閒置大併小、(B) `_find_absorb_target`（`faction_ai_system.gd:7850-7870`）母體＋`_try_merge`／`_resolve_mergein`（`:1742-1767`）入口，三處同一支 D7 謂詞；S6a／S6b 各「修前先紅」；n6、n7；並寫明這是全專案附身隊通用洞、在這張堵、修在寫入端。(A) 的「任一方是玩家方」涵蓋玩家隊當吸收者（AI 替玩家吞別人）與當被吸者兩個方向 |
| M2 | ✓ | 脫離後 `remove_tag(sub, TAG_SUBTEAM, "heir_independence")`（三個先例）＋清 `dispatched_by_player`；S3 斷言標籤與旗。我確認清旗不影響新隊仍被算進 `player_controlled`（`world_state.gd:1187` 附身隊本身無條件進集合） |
| M3 | ✓ | S6 拆成 S6a／S6b（兩條真路徑）＋S6c 弱斷言；n4 紅燈移到 S3 |
| M4 | ✓ | 候選讀者全列（寫 `event_system.gd:99`、過濾 `player_command_system.gd:2018-2027`、合法性 `:2259` 改重算並由重算結果給 `from_team`、文案 `player_api_mapper.gd:646,348`）；超過 26 截斷＋tap＋視窗「另有 N 人」＋S11；n8 |
| S1–S6 | ✓ | 死者濾法同本隊；順序固定先脫離後換 `player_id` 並寫理由（我重讀 `set_subteam_parent`/`sync_possession`，結論一致）；共用收尾；母隊補不出領袖換句＋S12；S10 加勢力層寫入 0 次；S13 運糧中 |

# 二、派發前請併進 spec 的文字修補（C1–C3）
- **C1 S6b／n7 的紅燈粒度**：(B) 有三道守（finder 排除、`_try_merge` 入口、`_resolve_mergein` 入口）。S6b 若用強制 `TASK_MERGE` 推到抵達，finder 那道守拿掉後 resolver 的守仍擋住，S6b 與 n7 不會紅。請把 S6b 拆成：
  - S6b1：直接單元呼叫 `_find_absorb_target`，母體含一支玩家方隊（人少、可達、有 belief）⇒ 回傳不得是它；母體地板＝同 fixture 在修前會回傳它（印修前回傳值）。
  - S6b2：強制 `TASK_MERGE`（`order_target` 指向玩家方隊）推到抵達 ⇒ 玩家方隊不被溶、不被重掛、任務沒被 `release`。
  - n7 拆 n7a（拿掉 finder 排除 ⇒ S6b1 紅）、n7b（拿掉 resolver 守 ⇒ S6b2 紅）。
- **C2 spec 內有一處殘字**：負對照 n8 那一行尾巴多出「（被召回或併掉）」（n4 改寫時遺留），且 n5–n8 的順序亂了（n5 排在 n8 後）。請理順，這是文字，免得實作端誤讀 n8 是另一個意思。
- **C3 不變量要升級**：按本專案慣例（否決後要把推導升級進不變量，不讓它留在信裡）：`docs/invariants.md` 第 12 條現在只寫「決策層不得寫附身中的隊的 task／move_target／orders」，本張堵的是「附身隊也不可被電腦併入／吸納／重掛」（被寫的是它的隊籍與成員，不只是 task）。請在本票落地時順手把這一句加進第 12 條，並在交件信列出行號，否則下一個寫「電腦合併隊伍」的人看不到這條限制。

# 三、結論
- **CLEAN**。C1–C3 是 spec 文字／床格補寫，併入後可直接排實作（排程：全員在場之後），不需再回 R²。
- 交件時照 spec 末的清單，特別附：S6a／S6b1／S6b2 的修前紅燈原文、候選子隊來源分佈、S12 母隊其餘子隊的去向結論、S13 運糧任務走法。
