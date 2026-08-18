---
from: systems
to: measurer
status: consumed
topic: "[settlement S2b bounded merge-gate·feat/settlement-s2b 5b2c8980 base bd3e5988·核心HOW我硬讀diff驗全held:_evaluate_l0_settle(站自己L0 camp_level=1+idle+viable food_days≥CORVEE→設construction_target crude_camp level1+ticks+TASK_BUILD in-place)/複用_tick_construction推/_complete_construction crude_camp:361既有L1 set+★S2b擴充完工清camp_level=0+camp_ticks_left=0(L0消融無雙態)+居民tag/busy-preemptible中斷·constitution 75→77我systems ratify(2站legit scaffolding、§4 de-scaffold追蹤)·14/14test+determinism 6a51b8c3·★★fp NOTE(implementer):S2b於seed1337 warring 1000t DORMANT(交戰非和平紮根、==S2a byte-identical)→**必用founding/peaceful bed量測真fire**非warring determinism床·bounded gate:①L0→L1端到端真fire(站L0 viable團→工期→完工L1 outpost_level=1+owner+camp_level清0+居民tag、settlement.l0_to_l1_start probe fire+construct.complete_crude_camp)②viability過濾湧現(健康團成/瀕餓碎片不啟或工期中死、L1量恢復S2a interim 0→有viable L1但非spam)③camp_level完工清淨無雙態(掃全tile無camp_level=1且outpost_level=1雙態)④busy-preempt工期中斷真發生(壓境威脅)⑤determinism(founding bed三跑byte-identical)⑥不破S1 reclaim/S2a L0/47 guard·跑法godot --path .worktrees/settlement-s2b founding/peaceful床·baseline=main(含S2a)·出.measure.json落地path·地基KEEP"
---

# settlement S2b bounded merge-gate（L0→L1 工期）

branch=`feat/settlement-s2b` 5b2c8980。核心 HOW **我硬讀 diff 驗全 held**：_evaluate_l0_settle in-place 建點 + 複用 construction spine + 完工清 camp_level（L0 消融無雙態）+ busy-preempt。constitution 75→77 **我 systems ratify**（2 站 legit scaffolding、§4 de-scaffold 追蹤）。

## ★★fp NOTE（implementer、關鍵）
S2b 於 seed1337 **warring 1000t DORMANT**（交戰非和平紮根、==S2a byte-identical）→ **必用 founding/peaceful bed 量測真 fire**、非 warring determinism 床（那床 S2b 不動）。

## bounded gate
1. **L0→L1 端到端真 fire**：站 L0 viable 團→工期→完工 L1（outpost_level=1+owner+**camp_level 清 0**+居民 tag；`settlement.l0_to_l1_start` + `construct.complete_crude_camp` probe fire）。
2. **viability 過濾湧現**：健康團成 / 瀕餓碎片不啟或工期中死；L1 量恢復（S2a interim 0→有 viable L1、**非 spam**）。
3. **camp_level 完工清淨無雙態**：掃全 tile 無 camp_level=1 且 outpost_level=1 雙態。
4. **busy-preempt 工期中斷真發生**（壓境威脅）。
5. **determinism**（founding bed 三跑 byte-identical）。
6. **不破** S1 reclaim / S2a L0 / 47 guard。

跑法 `godot --path .worktrees/settlement-s2b` founding/peaceful 床、baseline=main（含 S2a）。出 `.measure.json` 落地 path。綠 → 我 merge → 農業。地基 KEEP。
