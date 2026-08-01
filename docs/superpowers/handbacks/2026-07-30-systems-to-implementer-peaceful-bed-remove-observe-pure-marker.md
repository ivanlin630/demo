---
from: systems
to: implementer
status: consumed
topic: "[R²後修·1行·移 peaceful_economy_bed.gd 的 # @observe-pure marker(systems spec錯:bed是runner/harness seed跑自己世界=非pure-observe helper,seed()合法世界設置非觀測擾動→observability_gate ③正確FAIL on :110 seed()·bed determinism由seeded保證非零RNG·pure-observe marker只給嵌入式觀測helper如specimen_dump_helper/tracer)·移bed marker(保liveness_test marker=它t0純讀無seed)·跑observability_gate確認PASS+bed exit0+commit+handback] 移bed @observe-pure marker(我spec錯,bed是runner非observe-helper)。跑observability_gate確認PASS+commit+handback。"
branch: feat/peaceful-economy-bed
---

# R² 後修：移 bed 的 @observe-pure marker（systems spec 錯）

**我 spec 錯**（已訂正 spec）：`peaceful_economy_bed.gd` 標了 `# @observe-pure`，但 **bed 是 runner/harness**（`seed(SEED)` 跑自己的世界，同 `WarringHarness.run:52-55`）——`seed()` 是**合法世界設置、非觀測擾動**。observability_gate ③ 正確 FAIL：`peaceful_economy_bed.gd:110 observe-pure 檔耗 global RNG: seed(`。**marker 貼錯**（pure-observe marker 只給「觀測既有 sim 的嵌入式 helper」如 specimen_dump_helper/tracer/probe_stats；runner bed determinism 由 seeded 保證、非零 RNG）。

## 修（移 1 行）
`peaceful_economy_bed.gd` **移除檔頭 `# @observe-pure ...` marker 那行**（連同其說明註）。
- ★**保 `peaceful_economy_liveness_test.gd` 的 @observe-pure**（它 t0 純讀 need_keep、無 seed()/無跑 sim＝真 pure-observe，gate 沒 flag 它）。
- 移 marker 後 bed 不再被 observability_gate ③ 掃（且檔名 `_bed` 後綴→WARN 也 skip）。

## 驗
1. `.\tools\godot.ps1 --headless --script scripts/debug/observability_gate.gd` → **PASS**（無 peaceful_economy_bed FAIL、無新 WARN）。
2. bed 仍 exit0（`peaceful_economy_bed.gd` 跑）+ liveness 仍 ALL PASS + constitution 74。
3. commit（零行為/tap/數字變＝4 問數不變）+ handback `to:systems`（新 commit hash）。

★純移 marker 註、無 sim/數字變。收尾即可，卡住報 `to:systems`。修完 → 我 merge → dispatch measurer。
