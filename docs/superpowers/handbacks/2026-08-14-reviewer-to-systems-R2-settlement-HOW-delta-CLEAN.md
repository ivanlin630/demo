---
from: reviewer
to: systems
status: open
topic: "[R②delta判決=CLEAN+1必查項(set_owner同步性)] settlement HOW delta對四訂正對齊——親讀更新後WHAT spec(status:LOCKED四訂正入版)+HOW spec §1 S1b逐字核對:(1)★S1b真只兩code點確認:§1明列①_tick_solo_settle加owner=-1分支②安家選項目標池擴充,§0四通道class name已訂正(我上輪必查項已納入),occupy明講不碰,無第三個code點或新action字樣,符合訂正④的硬禁;(2)owner=-1『空』判定belief-gated親讀_tick_solo_settle既有body(:1969-1982,前輪已讀過)確認現況邏輯已經是『抵達後讀腳下tile』(team.tile_pos所在格,自身站立處=proximate非god-view)——這個既有pattern本身就合法(團永遠能看見自己腳下),新owner=-1分支掛在同一個『抵達後檢查』點上結構安全;真正需要belief-gate的是touch-point②(決定要不要『走去』一個遠方owner=-1據點這個旅行前決策)而非touch-point①(抵達後的即時檢查),這個區分HOW spec的§0/§1文字有點清但沒有把兩個touch point的god-view責任分開講,建議措辭更精確(抵達檢查=live合法/目標選擇=須belief)避免implementer誤以為兩處都要走belief查詢造成不必要複雜化,或反過來誤以為抵達檢查也不用管god-view;(3)L0池現量讀法讀腳下tile(proximate)無god-view,跟establish_crude_camp既有pattern(state.world.tiles.get(team.tile_pos...))一致;(4)★必查項:先到先得set_owner chokepoint要求implementer必須check-and-set同步(owner==-1判定跟set_owner寫入在同一次function呼叫內完成、非deferred到tick末批次處理)——這樣單執行緒逐團processing天然保證first-come-first-served,若implementation不慎把owner判定跟寫入分開兩階段(例如先收集全部候選再批次寫)才會有雙認領風險,要求HOW明講這條同步性約束非留implementer自己選;判決=CLEAN+1必查項(check-and-set同步性寫進HOW-binding)→S1 plan→dispatch implementer"
---

# R②delta判決：settlement HOW delta 對四訂正對齊 — CLEAN + 1必查項

親讀更新後 WHAT spec（`status: LOCKED` 四訂正入版）+ HOW spec §1 S1b 逐字核對。

**(1) S1b 真只兩 code 點確認**：§1 明列「①`_tick_solo_settle` 加 `owner=-1` 分支」「②安家選項目標池擴充」，§0 四通道 class name 已訂正（我上輪必查項已納入，`ScoutSystem`/`MessageSystem` 已換成真名），occupy 明講不碰，全文找不到第三個 code 點或任何「新 action」字樣。符合訂正④的硬禁。

**(2) owner=-1「空」判定 belief-gated——親讀既有 `_tick_solo_settle` body 確認結構安全，但建議措辭更精確**：親讀 `_tick_solo_settle`（`:1969-1982`，前輪已讀過完整 body）確認現況邏輯本身就是「抵達後讀腳下 tile」（`team.tile_pos` 所在格，自身站立處=proximate、非 god-view）——這個既有 pattern 本身合法（團永遠能看見自己腳下），新 `owner=-1` 分支掛在同一個「抵達後檢查」點上，結構安全。

真正需要 belief-gate 的是 **touch-point②**（決定要不要「走去」一個遠方 `owner=-1` 據點，這是旅行前的目標選擇決策），而不是 **touch-point①**（抵達後的即時檢查，這裡讀 live 是合法的、因為已經站在那格）。HOW spec 的 §0/§1 文字沒有把這兩個 touch point 的「god-view 責任歸屬」講清楚分開。**建議**措辭更精確：「抵達檢查=live 合法（已站在格上）/ 目標選擇=須 belief（決定往哪走前）」，避免 implementer 誤以為兩處都要走 belief 查詢造成不必要複雜化，或反過來誤以為抵達檢查也不用管 god-view。這是措辭建議，非阻塞。

**(3) L0 池現量讀法**：讀腳下 tile（proximate）無 god-view，跟 `establish_crude_camp` 既有 pattern（`state.world.tiles.get(team.tile_pos...)`）一致。

**★(4) 必查項：先到先得 `set_owner` chokepoint 的同步性**：單執行緒逐團 tick processing 天然保證 first-come-first-served——**前提是** `owner==-1` 判定跟 `set_owner` 寫入在**同一次 function 呼叫內同步完成**（比照 `establish_crude_camp` 的 `OutpostOwnerBank.set_owner(tile, team.team_id, "camp")` 那種立即寫入 pattern，非 deferred 到 tick 末批次處理）。若 implementation 不慎把「判定候選」跟「實際寫入」拆成兩階段（例如先收集全部候選再批次處理），才會真的出現雙認領 race。**要求** HOW 明講這條同步性約束（check-and-set 必須原子式在同一次呼叫內完成），寫進 §1 S1b 的 binding 條件，非留給 implementer 自己選實作方式。

## 判決
**CLEAN + 1必查項（check-and-set 同步性寫進 HOW-binding，防雙認領 race）→ S1 plan → dispatch implementer。** 四訂正對齊確認：S1b 真只兩個 code 點、無 scope creep；belief-gate 責任區分在 touch-point②非①，結構安全但措辭可以更精確；L0 讀法/first-come-first-served 機制方向皆正確。
