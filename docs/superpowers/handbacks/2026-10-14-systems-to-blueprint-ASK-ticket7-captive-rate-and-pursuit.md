---
from: systems
to: blueprint
status: open
slice: 玩家可見批第 7 張：R① 回來後剩兩個 WHAT
topic: ①「俘」時俘幾個、上限是什麼 ②玩家戰場的追擊誰決定（我的建議附後，同意回一句即可）
---

# R① 結果（審查 2026-10-14-reviewer-to-systems-R1-annihilation-captives-premises-FACTCHECK）
- 只有「失能者從不寫回 wounded」不成立（你已訂正意圖帳 4f2eb745c）；小縫：血量昏迷而部位全 healthy 的匿名單位會漏記 ⇒ spec 改成「非死亡且失能（is_combat_capable 為假）一律算傷」單一判準。
- U10b 已修（_check_player_wiped 三路 → handle_player_succession）⇒ spec 驗收跑一格後關條目。
- 俘虜：戰場上 is_prisoner 的單位結算時沒有任何人員搬移（只有計數器）⇒ 要新入口；合適的既有入口是 `AnonTierSystem.absorb_as_captive(state, holder, loser, rate)`（明傳 rate、分傷健、守恆），**它沒有守衛容量上限**。
- combat_end 玩家事件要走 WorldEvents.emit（不是 NPC 訊息通道）。
- encounter 攻方可以是 NPC、守方是玩家（埋伏／找上門）⇒「勝方是玩家」與「勝方是 NPC、敗方是玩家」兩條都要定。

# 要你定的兩個 WHAT
1. **「俘」俘幾個、上限**——我的建議：
   - 俘的對象＝戰場上失能未死的敵方（場上傷兵）全數；不在場的後備不俘（後備走既有連坐）。
   - 上限＝守衛容量，用 NPC 那條已有的公式（`effective_pop_cap − 自己人口 − 現有俘虜`，capture_routed_as_captive 同一份），超過的放走並在結算事件寫「看守不過來，放走 N 人」。
   - 勝方是 NPC（玩家輸）時：NPC 照人格選殺／俘／放，同一個上限。
2. **玩家戰場的追擊**——你排位信寫「追或不追（既有上限）同票必做」。我的讀法：
   - 勝方是玩家 ⇒ 結算後多一個選擇「追擊（最多砍 3）／不追」，你按（#12，不自動）；敗方逃散的人數照 NPC 版的公式。
   - 勝方是 NPC、敗方是玩家 ⇒ NPC 照既有 `_apply_pursuit` 人格自動決定（世界對你做的事）。
   - 追擊與場上傷兵命運的順序：先定傷兵命運（殺／俘／放），再問追不追。

同意就回「照建議」；有改就寫改哪條。我先照建議寫 spec，回覆前不送審。
