---
from: reviewer
to: systems
status: open
slice: own-camp-in-decision-model
topic: R②判決:issues——①案A可行但不是字面「延伸同一張表」,查了_rebuild_owner_outpost/_oo_map,outpost跟camp是不同欄位(outpost_owner/level vs camp_team_id/level)不能塞同一個map,要建同架構的姊妹索引(自己的epoch+自己的3個chokepoint),不是逼出爛形狀而是要講清楚「延伸」延伸的是機制不是同一張表;②查了rooting_drive+settle_eta_days,距離已經折進util了,橫跨全圖走回家的病態被既有feasibility機制自然壓低,不是全新風險;③churn疑慮是真的,查到具體漏洞:「紮營」的applicable沒有排除「已有own_camp_pos」,中途被打斷時會贏過紮根導致沿途重紮,修法是同一天稍早recamp-candidate-exclusion那票同一個家族的延伸,紮營applicable加own_camp_pos==(-1,-1)
---

# 判決：`issues`，`premise_contradiction: false`

## ①seam選擇——**案A可行，但不是字面「延伸同一張表」，要講清楚延伸的是機制**

讀了 `owner_outpost_index.gd` 跟 `world_state.gd:202-220`：現有結構是 `_oo_map`（`WorldState` 上單一 dict，keyed by `team_id`），由 `_rebuild_owner_outpost()` 迭代 `world.tiles` 找 `outpost_owner`/`outpost_level>0` 建出來，`epoch`/`shadow_check` 都是**這張特定表**的機制。★**camp 用的是完全不同的欄位對**（`camp_team_id`/`camp_level`，非 `outpost_owner`/`outpost_level`）——**一支隊理論上可以同時有一座已建成的 outpost（在 A 格）跟一個 L0 camp（在 B 格），兩個位置不同**，硬塞進同一個 `_oo_map`（keyed by team_id、值只能是一個 tile_id）會互相覆蓋，選不出對的那個。

⇒ **「延伸 OwnerOutpostIndex」不會逼出爛形狀，但字面上不是同一張表，是同一套【架構模式】的姊妹實例**：新建一個 `_camp_map`（獨立 dict）＋自己的 `_rebuild_owner_camp()`（迭代找 `camp_team_id`/`camp_level>0`）＋自己的 epoch（不共用 `OwnerOutpostIndex.epoch`，理由見下）。★**理由不共用 epoch**：camp 的寫入/清除點（spec 已列：`faction_ai_system.gd:5811` 寫、`harvest_system.gd:67`／`outpost_system.gd:470` 清）跟 outpost 的三個 chokepoint（`set_owner`／等級跨0／`erase_teams`）**不是同一組事件**——共用一個 epoch 會讓 camp 表在**每次 outpost 變動時都被迫重建**（camp 沒變也重建，白工），分開 epoch 才精準對應各自的 chokepoint，也是 `OwnerOutpostIndex` 自己的既有紀律（chokepoint-based invalidation）忠實複製一份，不是新發明。

⇒ **建議**：spec 把案A 寫成「新建同架構的姊妹索引（獨立 map/rebuild/epoch/shadow_check），複製 `OwnerOutpostIndex` 的機制而非表本身」，implementer 才不會誤以為要把 camp 塞進 `_oo_map` 那個 dict 裡。

## ②util 有沒有折路程——**查過了，已經折了，橫跨全圖走回家的病態被既有機制自然壓低**

讀了 `decision_context.gd:362-363`：`c.settle_eta_days = OutpostSystem.build_eta_days(...) + float(_dist)`（`_dist = _hex_dist(team.tile_pos, _site_pos)`）——**距離已經加進 `settle_eta_days`**。再讀 `terms.gd:249-259`（`rooting_drive`）：
```gdscript
var _need_days: float = ctx.settle_eta_days * ROOTING_SAFETY_FACTOR
var _feasible: float = clampf(ctx.food_runway_days / maxf(_need_days, 0.001), 0.0, 1.0)
return _feasible * clampf(ctx.settle_site_quality, 0.0, 1.0)
```
**距離越遠 → `settle_eta_days` 越大 → `_need_days` 越大 → `food_runway_days` 固定的情況下 `_feasible` 被壓低 → util 自然下降**——這是既有的、原本就管「撐不撐得過工期」的同一套可行性帳，現在同一套帳也管「撐不撐得過走回家的路程」，不需要新機制。

★**唯一沒被這套帳擋住的情況**：糧食餘裕真的很夠（`food_runway_days` 夠大）的隊，即使距離很遠 `_feasible` 仍接近 1，牠會理性選擇長途跋涉回家——★**這不是病態，是這個功能存在的目的本身**（給隊一個真正的家可以走回去）；沒有食物餘裕支撐的隊，距離一遠 util 自然崩潰，不會出現「快餓死還橫跨全圖走回家」這種真正的病態。

⇒ **這格不用在 spec 裡特別寫「本刀會讓它現形」的警語**——查完的結論是：既有機制已經處理了這個風險，是好消息不是待觀察項。

## ★★★③churn 迴圈——**疑慮是真的，查到具體漏洞，修法是今天稍早那票的同族延伸**

讀了 `options.gd:192-201`（"紮營"）：
```gdscript
"applicable": func(ctx: DecisionContext) -> bool:
    return ctx.has_farmable_tile and not ctx.has_own_outpost,
```
**這個條件完全沒有檢查「我是不是已經有自己的 own_camp_pos」**——`has_own_outpost` 只看 `outpost_level>0`（L1+），一支只有 L0 camp（尚未升級）的隊，`has_own_outpost` 恆為 false，「紮營」永遠是活候選。**若這支隊正在往 `own_camp_pos` 走的半路上被打斷重新評估，牠站的那一格若剛好可耕，「紮營」applicable 成立、跟「紮根」（現在因距離折扣分數較低）互相競爭——若「紮營」贏，隊伍會在半路的錯誤格子上重新紮營，放棄回家，正是你擔心的 churn。**

★**這跟今天稍早 `recamp-candidate-exclusion` 那票是同一個病灶家族**——那票修的是「已經站在自己已紮的那格,紮營候選沒排除自己」，這次是「已經在別處有自己的 own_camp_pos,紮營候選也沒排除這件事」，只是觸發位置不同（站上 vs 途中），根因一樣：候選生成端沒讀「我是不是已經有家」。

⇒ **建議修法（小，同源）**：「紮營」的 applicable 補上 `and ctx.own_camp_pos == Vector2i(-1, -1)`——★這個 ctx 欄位正是本票要新增的那個，不需要新機制，只是把它多接一個既有 option 的 applicable。這樣中途被打斷時，「紮營」會因為 own_camp_pos 已存在而不再是候選，隊伍只能在「紮根（走回家）」跟其他非駐紮類選項之間選，不會在路上散落新camp。

⇒ **spec 驗收要補一條**：構造「走到一半被打斷重評估、當下站的格子可耕」的場景，驗證「紮營」不再贏（若沒有這條，你自己標的「移動中被打斷」那格會一直是設計缺口，不是 known unknown）。

## ⇒ 要你補的
1. ①：spec 訂正案A的描述，講清楚是「同架構姊妹索引」不是「同一張表」，附獨立 epoch 的理由。
2. ②：不用補，查完是好消息，既有機制已擋住。
3. ③：「紮營」applicable 補 `own_camp_pos == (-1,-1)`；驗收補一條「移動中被打斷」的構造場景。

**premise_contradiction: false，①③處理過即可整票 CLEAN。**
