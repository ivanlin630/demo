---
from: implementer
to: measurer
status: consumed
topic: S-A 併決策統一 done → organic full_probe 3 硬 gate（餵養真解/湧現非腳本/side-observe）→ blueprint
---

# S-A done：併決策統一（@e8d7d52 feat/consolidation-s-a，base main 8b15d23）

食壓驅併=有機政體湧現。spec §HOW-1/2/3 全上。

## 做了什麼
- **HOW-1 term 退 flat**：`consolidate_drive` eval 退 flat `CONSOLIDATE_DRIVE`→食壓 scaled（mirror join）；weight 退 flat 1.0→`求生欲*0.6+(1-野心)*0.4`。`join_drive` eval 去冗餘 `has_strong_neighbor`（已在 options applicable :99 側）；join weight +low-ambition factor。刪死碼 CONSOLIDATE_DRIVE const。
- **HOW-2 `_find_absorber` 餵養 gate#1（靶A 防搬餓）**：吸附者須有糧 + 併後合隊餘命 `>= ABSORBER_MIN_SURVIVE_DAYS(7)`；`consolidate_target_of` 同路一致。
- **HOW-3 accept-util 薄層（靶C）**：`_resolve_join`/`_try_merge` 接觸時 absorber 秤**單一 util**（`(野心*0.6+統領*0.4)*feed_ok`，`feed_ok=clampf(combined_days/MIN,0,1)`）≥`ACCEPT_UTIL_THRESHOLD(0.3)` 才收，拒則發起方回退。**★嚴守單一 util 比較（非 absorber 全 rank）=未滾第二引擎**（邊界誠實，contact-time bespoke 薄層）。
- 探針 + bed 更新（食壓 scaled + 餵養 gate case A2 + Task4 食壓觸發）。
- **options.gd 無改**：`has_strong_neighbor` 本已在 applicable :99 側（eval 去冗餘 gate 即滿足 spec「降 applicable 前提」）。

## 我驗
- `--import` parse 綠、`a2c1_consolidate_bed` **fail_count=0**、multi-sanity(coin_eq/inv=0)、constitution PASS。
- determinism：seed 1337 3mo 兩跑 `[bed] probe` **byte-identical**（term/gate/util 純值、零新 randf）。
- consol 探針**真 fire**（seed 1337 3mo）：`merge.consolidate_dispatch=198`、`accept.join_accept=1`/`consol.accept_n=1`/`join.resolve=1`。★`accept.merge_accept=0`（整併 TASK_MERGE 極少到達 absorber 接觸→_try_merge 罕觸；單短 seed 樣本）。

## ★跑什麼（organic full_probe 大窗，3 硬 gate）
1. **gate#1 餵養真解非搬餓**：`consol.combined_days_sum/consol.accept_n` vs `consol.absorber_days_sum`/`consol.joiner_days_sum`（併前兩隊餘命）——須 **combined > min(併前兩隊)**（實質改善）。搬餓=FAIL。
   - **★空真守衛（reviewer R②）**：先驗 `consol.accept_n > 0`；**=0 → INCONCLUSIVE 非 PASS**，回報 `ABSORBER_MIN_SURVIVE_DAYS(7)`/`ACCEPT_UTIL_THRESHOLD(0.3)` 可能過嚴致機制啞（同 pursuit 截斷病型）。單 seed accept_n=1，大窗應足；若大窗仍稀→標門檻。
2. **gate#3 湧現非腳本**：grep 確認**無** `pop<N 就併` 硬寫（consolidate_drive=食壓 argmax 驅）。
3. **gate#2 = side-observe（不判 pass/fail）**：隊規模分布（`consol.absorber_pop_sum/accept_n`）+ annih 記數，不為它調任何東西。
- 三端/戰鬥不退化、determinism 綠。

**判準**（→blueprint）：餵養真改善生存 + 併=食壓湧現=達標。搬餓/機制啞=打回調常數（我同 branch）。
**merge 閘**：reviewer 對實際 diff CLEAN + 你 gate#1/#3 + blueprint 判有機政體湧現。worktree @e8d7d52。
