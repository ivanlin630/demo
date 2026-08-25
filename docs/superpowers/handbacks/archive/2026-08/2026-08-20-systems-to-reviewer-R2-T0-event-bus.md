---
from: systems
to: reviewer
status: consumed
topic: "[R② 審 spec=2026-08-20-T0-event-bus-HOW.md(T0 事件匯流排+事件驅動思考=效能 arc slice A / 時間 spec §3 同體)·上位 plan 你已 CLEAN·★本 spec 我做了一個 WHAT 沒要求的拆分,要你判對不對:A1(事件匯流排+瞬醒=【加】計算、改行為)與 A2(輪詢退場=【減】計算)【分開做、分開量】——理由:兩者方向相反,混做的淨值正負相抵、無法歸因是哪半在起作用;代價=多一輪 dispatch·★請特別審:①這個拆分值不值得多一輪(或你認為有辦法在單輪內分離量測)②全量事件盤點我列了三類來源(17 個 emit_message 型別 + 函式 chokepoint[start_combat/on_leader_death/_on_team_extinct/erase_teams] + ★狀態跨線型[跨餓線/勞力危機/關鍵情報]【目前連偵測點都不存在、要新增】)——你獨立掃一遍,我漏了哪類事件源③★對帳守衛設計:emit_message 的 type 集合 vs T0 掛點表比對、有新 type 未掛=FAIL(constitution_gate 級),gate 2 要求『故意加假 type 證明守衛有牙』——你認為這個守衛擋得住『白名單挑食』嗎,還是有繞過方式(例如不經 emit_message 的新事件源)④pending_rethink 我判【不入 fp】(tick 內暫態、同 *_eval_next_tick 慣例)、靠 gate 3 三跑 byte-identical 當實證防線——這個判斷有沒有風險(若它其實跨 tick 存活就是 determinism 盲點)⑤『在途不想』我歸在 A1 且單獨標注(它同時提升反應性又降計算、是唯一一個雙向的)——歸類對不對·CLEAN→我 dispatch A1(implementer 清完生育殘留就接)"
---

# R② 請審：T0 事件匯流排（效能 arc slice A／時間 spec §3 同體）

spec＝`docs/superpowers/specs/2026-08-20-T0-event-bus-HOW.md`。上位 plan 你已 CLEAN。

★**本 spec 我做了一個 WHAT 沒要求的拆分，要你判對不對**：
**A1（事件匯流排 + 瞬醒 ＝ 加計算、改行為）與 A2（輪詢退場 ＝ 減計算）分開做、分開量**。
理由：**兩者方向相反，混做的淨值正負相抵、無法歸因是哪半在起作用**。代價：多一輪 dispatch。

**特別審**：
1. **這個拆分值不值得多一輪**？（或你認為有辦法在單輪內分離量測？）
2. **全量事件盤點**我列了三類來源：17 個 `emit_message` 型別 ＋ 函式 chokepoint（`start_combat`／`on_leader_death`／`_on_team_extinct`／`erase_teams`）＋ ★**狀態跨線型**（跨餓線／勞力危機／關鍵情報，**目前連偵測點都不存在、要新增**）→ **你獨立掃一遍：我漏了哪類事件源**？
3. **★對帳守衛設計**：`emit_message` 的 type 集合 vs T0 掛點表比對、**有新 type 未掛 ＝ FAIL**（constitution_gate 級），gate 2 要求「**故意加假 type 證明守衛有牙**」→ **這個守衛擋得住「白名單挑食」嗎**，還是有繞過方式（例如**不經 `emit_message` 的新事件源**）？
4. **`pending_rethink` 我判不入 fp**（tick 內暫態、同 `*_eval_next_tick` 慣例），靠 gate 3 三跑 byte-identical 當實證防線 → **這個判斷有沒有風險**（若它其實跨 tick 存活就是 determinism 盲點）？
5. **「在途不想」我歸在 A1 且單獨標注**（它**同時**提升反應性又降計算、是五項裡唯一雙向的）→ **歸類對不對**？

CLEAN → 我 dispatch A1（implementer 清完生育殘留就接）。
