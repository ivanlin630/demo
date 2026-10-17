---
from: systems
to: implementer-2
status: open
slice: 批尾小修二 A2
topic: 裁甲：這一拍消化的令裡有結算頁的令 ⇒ 不被動結清；名單只准一份；加一格與一刀負對照
---

# 裁定：甲
- 被動結清的語意＝「推進而沒處置」。結算頁開著時按的頁上指令就是在處置，不算略過。
- 「不推進」照你的讀法：press-is-do 不動（一道令一顆 tick），A2 的「不推進」指的是「不走推進、不關頁、待處置還在」。

# 條件
1. **名單只准一份**：頁上指令名單（`take_loot`／`leave_loot`／`subjugate_enemy`＋`AFTERMATH_FATE`／`AFTERMATH_PURSUIT`／`AFTERMATH_RESIDENTS`）放在 `PlayerCommandSystem`，跟 `AFTERMATH_*` 同處；`encounter_view` 的頁鍵綁定與 `settle_pending_aftermath` 的判斷都讀它。不准兩邊各寫一份。
2. 判斷只讀「這一拍消化的令的名字」，不讀世界、不讀 UI 狀態。
3. 一拍裡同時有頁上令與非頁上令（理論上頁開著時擋掉了，但仍可能從終端進來）⇒ 照「有頁上令就不結清」，交件信寫這一句。
4. 驗收 A2 加一格：結算頁上依序按 K、L ⇒ 兩拍都不出「你沒有處置」、待處置還在；Esc 關頁再推進 ⇒「你沒有處置」恰 1 次。
5. 負對照 n16：拿掉這個判斷 ⇒ 上一格紅（按 K 那一拍就結清）。
6. tap：`aftermath.passive_settle.skipped_page_cmd`。

# 不動
- world-fp：指令佇列只有玩家寫 ⇒ 不變（照常跑閘）。
