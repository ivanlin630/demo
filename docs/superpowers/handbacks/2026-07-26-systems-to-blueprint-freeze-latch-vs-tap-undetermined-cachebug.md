---
from: systems
to: blueprint
status: consumed
topic: "[★凍源診斷誠實現況·確定:main健康+凍在branch(37f2ce31 fresh真凍_snapshot真值)·未定:latch vs tap(我5b對照cache-stale invalid)·乾淨重測中·★我3次翻轉教訓(non-tap→tap→latch皆過早,code/json猜非fresh重現)·context爆提交接] 凍結診斷:確定 main 健康、凍在 branch、seed1337-specific;但 latch vs tap 因我測試 cache-stale bug 未定,乾淨重測中。"
---

# 凍源診斷：誠實現況（latch vs tap 未定 + 我的診斷 bug）

## ✅ 確定
- **main 健康**（fresh 現 main means-end 無 latch，daily churn teams 62-75、pop 動、新 faction）→ **本場 means-end measurement 沒在半凍世界，結論不用全重估**（好消息不變）。
- **凍在 branch，真凍非 artifact**：37f2ce31（latch+tap）fresh 重現 seed1337 month1-6 全 71/438 凍。`warring_harness._snapshot` 讀真 `state.teams.size()`+`_total_pop`（**非 curve dump bug**）→ 真 state 逐月不變 = 真凍。
- **seed1337-specific**：seed42 動（62→60），只 seed1337 凍。

## ❌ 未定：latch vs tap（我的測試 bug）
- 我「5b166eb1 latch-only 對照」（by72vni25）**cache-stale invalid**：worktree 之前 import 37f2ce31 class cache，我只 checkout 2 檔沒 re-import → 跑的還是 cached 37f2ce31，非 5b166eb1。∴ 那次「5b166eb1 也凍」**不可信**。
- **乾淨重測中**（bkwt2l1gr：清 .godot cache + checkout 5b166eb1 all + full re-import + 跑 seed1337 2mo）→ 定 latch vs tap：
  - 5b166eb1 動 → **tap 引入凍**（純 Probe.bump 零 RNG 卻改軌跡＝非 RNG observer side-effect，機制待查）。
  - 5b166eb1 凍 → **latch 凍化 seed1337**（非 tap！翻用戶「latch valid 健康」前提，latch 不該 folds 進手統一 until 根治）。

## ★矛盾未解（需乾淨重測答）
`latch-resume-a1-6mo.json`（measurer 跑 5b166eb1）seed1337 **attrition 12.39% 動**，vs 我 fresh 37f2ce31 seed1337 **凍**。同 latch base 一動一凍 = 要嘛 measurer json config 不同、要嘛我 cache bug、要嘛 tap 差異。乾淨重測釐清。

## ★我的診斷教訓（誠實）
凍源我**3 次翻轉**（non-tap → tap → latch），每次都是 **code 坐實/json 對照猜、非 fresh 乾淨重現**：
1. 「tap 零 RNG 非 tap」= code 論證（Probe.bump 純 counter）→ 過早，fresh 重現打臉（37f2ce31 真凍）。
2. 「tap 引入凍」= json attrition 對照 → 過早，未分 latch。
3. 「latch 凍化」= cache-stale 對照 → invalid。
**教訓**：measurement 凍源必**乾淨 fresh 重現對照**（full re-import 排 cache stale），別 code/json 猜。連 `feedback_avoid_rabbithole`（先量再開藥別理論化）。

## ★context 爆，提交接
我 context >90%，診斷多輪。bkwt2l1gr 乾淨重測結果 + 後續（latch 凍機制深查 / 手統一 arc latch 重估）建議下個 systems session 續（或我 compact 後續）。**好消息（main 健康、非 pre-existing、非世界 regression）已確定可用**。material PARK。手統一盤點底稿已交（可續 brainstorm，不 block 於凍源）。
