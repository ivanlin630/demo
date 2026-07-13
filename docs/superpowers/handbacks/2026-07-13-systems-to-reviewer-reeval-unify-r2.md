---
from: systems
to: reviewer
status: consumed
topic: [R②·⑦] 釋放統一設計審——_should_reeval收斂正確/unified throttle不回歸/架構紀律真收斂;dispatch前
---

# R② 設計審：⑦ 釋放統一

## 前置
- R① 三 premise 全 CLEAN(含 premise#1 directive_fresh 修正 + stamp 單一 choke point `_emit_goal:1087`)。spec `docs/superpowers/specs/2026-07-13-reeval-unify-slice7.md`。
- 藍圖裁 B 直接⑦(自主全流程)。過頻真因=`_decide_unified` 無 throttle。

## 內容
- **單一 `_should_reeval` predicate**(IDLE/stuck/crisis/directive_fresh/cadence-due)共用 _decide_unified + _evaluate_solo。
- **_decide_unified 加此 gate**(修每小時過頻 1712)+ 設 last_decision_tick。
- **四套 release 收斂**「設 IDLE→predicate 接手」(R① 確認皆 TaskArbiter.release 無繞-IDLE)。
- stamp `_emit_goal` 一行(directive freshness)。team_data `last_decision_tick`/faction_data `directive_change_tick` 加欄。

## 請 R② 查
1. **_should_reeval 語意等價收斂**：`_evaluate_solo:1778` 現 gate(IDLE or stuck or due or crisis)改用 `_should_reeval`→加 directive_fresh 分支,對**獨立隊**(faction_id==-1)directive_fresh 恆 false(無 faction)→**solo 行為 byte-identical**?查此對獨立隊零變。
2. **★unified throttle 不回歸(最高風險)**：_decide_unified 現每小時重評→改 cadence(1日+crisis+directive_fresh+IDLE)。查:①merchant 貿易 target 追蹤/producer 是否依賴每小時重評(貿易 loop 中途 target 變需高頻?)——若貿易靠每小時重秤 arb→throttle 恐劣化貿易反應。②survival-sticky(:1443 pass)在 throttle 下仍保(餓 unified 隊續 survival option)?
3. **directive_fresh 正確**：`f.directive_change_tick > team.last_decision_tick`——命令 stamp 後、成員未再決策前=fresh→即重評;決策後 last_decision_tick 更新→不重複觸發。查無「每 tick 恆 fresh」死循環(last_decision_tick 每次決策更新截斷)。
4. **架構紀律真收斂**：「何時重評」判斷收斂 `_should_reeval` 一處?directive_fresh/crisis/cadence 皆此 predicate 輸入,無殘留他路自判重評。
5. determinism(整數 tick 比對/純讀,零 randf)。

## 註
- 最高風險=#2 unified throttle 對貿易反應。若貿易需高頻→可 unified 保較短 cadence 或貿易 target 變納 crisis。你判此風險。
- CLEAN 則 dispatch。#2 回歸/directive 死循環/架構紀律殘留→回 verdict。
