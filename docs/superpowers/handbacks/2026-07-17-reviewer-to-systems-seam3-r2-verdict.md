---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] seam#3 sim_runner registry：非 CLEAN，抓到 1 個 premise_contradiction（rebuild_team_tile_index 非 far 專屬，near 也呼叫，:191 vs :242）+ 1 個完全漏盤點的 near-only 步（_step4b_outpost_tick）。兩處皆機械可修，修完免重整輪。"
---

# R② 判決：seam#3 sim_runner registry — 非 CLEAN，2 個 premise 缺口（file:line 坐實）

## 逐行比對 near（:184-228）vs far（:238-261）呼叫序

近乎逐一對照後，**BOTH 類共同步彼此相對順序確實一致**（vision→equip→strategic_move→move→[rebuild]→messages(3子步)→interactions→[outpost_tick]→faction_snapshot→ambush→resources→[regen]→manufacture→consumption(3子步)→faction_ai→training→strategic_ai→[reactions×2]→events→emit→[tutorial]，方括號=near-only）。**systems 審問①「near/far 共同步順序真一致否」答：一致，除下列 2 處 spec 記載有誤**。

## ★finding 1（premise_contradiction，須修）：`rebuild_team_tile_index()` 非 far 專屬

Spec §根：「**far 專屬**：`state.rebuild_team_tile_index()`（`:242` far move 後刷新；near 位置本 tick 不再變不需）」。

**逐 code 核對，此前提錯**：
```
sim_runner.gd:191   state.rebuild_team_tile_index()   # post-move rebuild → 下游 co-location/hostile 查見 post-move 位置
sim_runner.gd:242   state.rebuild_team_tile_index()   # post-move rebuild（far 隊移動後刷新，near 隊位置本 tick 不再變）
```
**near 分支（:191）在自己的 `_step2_move_teams`（:190）後，也呼叫同一函式**，comment 講的正是同一種「post-move 需刷新供下游查詢」理由，跟 far（:242）的呼叫是**同型別的兩次獨立呼叫**，不是「far 才需要」。spec 把它歸類「far 專屬、registry 外手插」——若 S1 implementer 照此字面理解，重寫 near loop 時很可能認定「near 不需要 rebuild」而**漏掉 :191 這行**，這是實質行為回歸（下游 co-location/hostile 查詢在 near-move 後讀到 stale tile-index），非僅觀測層問題。

**正確定性**：`rebuild_team_tile_index()` 是 near/far **都要**的 post-move 步驟（各自在自己的 move 步後呼叫一次），只是**兩處理由 comment 各自強調不同面向**（near 強調下游查詢即時性、far 強調自己剛移動完需要新鮮 index）。應歸類為 **BOTH-lod、registry 外顯式插在 move entry 後**（near loop 插一次、far loop 插一次），非「far 專屬」。

## ★finding 2（premise 遺漏，須補）：`_step4b_outpost_tick` 完全沒被盤點

Spec §根列出的「共同步」清單（vision/equip/.../events/emit）與「far 跳」清單（reactions/cleanup/tile-regen/forced_event/tutorial）**都沒提到 `_step4b_outpost_tick`**。逐 code 核對：
```
sim_runner.gd:203   _step4b_outpost_tick(state)      # near 分支，interactions 之後、faction_snapshot 之前
```
far 分支（:238-261）**完全沒有這個呼叫**——不在 spec 認列的「far 跳」清單內，等於**沒被記錄成 near-only，也沒被記錄成 BOTH**，是個盤點死角。`_step4b_outpost_tick(state: WorldState)`（`sim_runner.gd:363`）簽章＝單參數 `(state)`，跟 `_step6e_strategic_ai`/`_step9_emit_messages` 同 args_shape 型，機械上好處理——**須補列為 `lod:NEAR, args_shape:(state)`**，位置在 registry 序上緊接 interactions 之後、faction_snapshot 之前（對齊 :203-204 原位）。若不補，implementer 若假設「spec 沒特別標近-only 的都是 BOTH」去寫統一迴圈，會誤把 outpost_tick 塞進 far 分支＝真行為回歸（far 隊據點被每 far-cadence 誤 tick）；若 implementer 反而按「spec 沒提到＝不動，維持原地顯式呼叫」則不會出錯但擴充性目標（加系統=1 entry）沒達成，遺留技術債且未來人不知道還有這個沒收的殘留。

## 審問②③④⑤逐項回覆

- **② phase_timing group 邊界**：near 的 `_pht` 標記多半是**多步聚合成一組才觸發**（例：`near.move` 收 strategic_move+move+finding①的rebuild+bookkeeping 共4段；`near.messages` 收3子步；`near.outpost_ambush` 收 outpost_tick+faction_snapshot+ambush 共3步；`near.economy`/`near.consume`/`near.strategic_ai`/`near.reactions`/`near.events_emit` 同理各收多步）。Registry schema 的 `timing_label` 若只掛在單一 entry 上，**必須明確定義「掛在該組最後一個 entry，迴圈跑完該 entry 才 fire」**，且**因 finding①（rebuild 是顯式插入，非 registry entry）夾在 move 群組中間**，統一 loop 不能是純 `for sys in SYSTEMS: sys.fn()` 平坦迴圈，需要**在 move entry 後插入顯式 checkpoint（rebuild + 條件式 bookkeeping）才能 fire `near.move` 邊界**——這點 spec 該明講，非只在「far 專屬」段帶過。
- **③ far-rebuild-index 順序位置**：已併入 finding①，near/far 皆對，位置皆在各自 move 後、messages 前，正確。
- **④ args_shape 三型**：核過 `_step4b_outpost_tick`(state)/`_step6e_strategic_ai`(state)/`_step9_emit_messages`(state) 同型，`_step1b_update_vision`(state,teams,mult)不在文中列的三型內——**還有第4種 shape**：vision 多帶 `time_vision_mult` 參數（:184/:238，near/far 皆傳同一個 `time_vision_mult` 全域變數，非 per-branch 值）。Registry 的 `args_shape` 枚舉若只設 `(state,teams,cadence)`/`(state,teams)`/`(state)` 三型，vision 這種「還多一個非 team/非 cadence 的額外參數」會塞不進去，需再加一型或把 `time_vision_mult`/`time_speed_mult` 也算進 args_shape 維度（move 步也用 `time_speed_mult`）。
- **⑤ near-only 步分類（reactions/tile-regen/tutorial/forced_event）**：核實正確，皆 near-only，far 確實跳過，無誤判。

## 判準結果
**非 CLEAN**——2 處須修正（finding① 為 premise_contradiction，finding② 為遺漏項）+ 1 處 schema 待補（vision/move 的額外時間乘數參數需新 args_shape 型）。三者皆機械性修正，**不影響 spec 整體方向**（SYSTEMS registry + 統一 loop 本身設計合理，seam#1/#2 pattern reuse 正確）。systems 補完 spec 後**免重整輪 R②**，可直接 dispatch S1 implementer，惟 implementer 落地時對 finding①②③ 逐一 file:line 核對（`:191`/`:203`/`:184`+`:238` vision 參數）。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-seam3-sim-runner-systems-registry.md`；systems handback `2026-07-17-R2-systems-to-reviewer-seam3-sim-runner-registry.md`；`sim_runner.gd:123-266`（近遠雙分支全文逐行比對）+ `:363`/`:435`/`:453`（函式簽章）。
