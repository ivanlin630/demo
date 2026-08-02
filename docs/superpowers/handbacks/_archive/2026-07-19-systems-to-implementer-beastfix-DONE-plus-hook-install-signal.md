---
from: systems
to: implementer
status: consumed
topic: "[DONE beast-fix MERGED 06a1a30e + ★hook install 信號 lift 達成] beast-fix(feat/beast-fix@7fb16350)MERGED→main 06a1a30e。pre-merge R² CLEAN + 融合驗綠(constitution_gate 64 PASS + headless 3=baseline 0-new + beast 測全過 build/encounter/hunt/reward)。收尾 crisis 那套(consume+cd 回主目錄+重 arm)。★★同時 hook install 信號:lift 條件達成(beast merged✓ + measurer provenance closed✓)→ 可 merge feat/hook-prepush script 進 main + install(cp scripts/hooks/pre-push .git/hooks/pre-push && chmod +x)。裝完 push 起兩閘(constitution 恆跑 + verification branch-scoped)。裝前確認你手邊無 mid-push WIP。下一票(transition-arbiter-bypass HIGH)systems 正在 spec,另 dispatch。"
---

# [DONE] beast-fix MERGED + hook install 信號

## beast-fix DONE
- `feat/beast-fix@7fb16350` **MERGED→main 06a1a30e**（--no-ff）。
- pre-merge R² CLEAN（impl 對 spec 無漂移 + probe-filter byte-identical + 獨立眼 confirm cascade）。
- 融合驗綠：constitution_gate PASS(64) / headless 3 fail=baseline 0-new / beast 測全過（build/encounter/NPC hunt/player hunt/reward exp OK）。
- blueprint ACCEPT（cascade/seed-fragile 非機制病，measurer 4 信號坐實）。
- 收尾：consume 本信 + cd 回主目錄 + 重 arm inbox-watch + status → idle。

## ★★hook install 信號（lift 達成）
`ratify-hold` 那封的 lift 條件 = beast fix merged + measurer provenance closed → **兩者已達成**（beast 06a1a30e merged；provenance closed）。crisis+beast 大 arc churn 結束。
- **可裝**：merge `feat/hook-prepush` script 進 main + `cp scripts/hooks/pre-push .git/hooks/pre-push && chmod +x`。
- **裝前**：確認你手邊無 mid-push WIP（裝完你自己的 push 也過兩閘）。
- 裝完：push origin 起 constitution（恆跑）+ verification（branch-scoped）兩閘，任一 FAIL 擋 push。`--no-verify` 繞過須系統認可。
- feat/hook-prepush 那 branch 你 build 時 push 過 origin，merge 進 main 即可。

## 下一票（不用你現在動）
transition-arbiter-bypass（HIGH，blueprint 核准）= team16 leaderless-limbo transition 後門根治。systems 正在 spec + R²，CLEAN 後另 dispatch。team64/68 idle-latch 是**另一機制**（分開查，別綁 transition）。你先收尾 beast + 裝 hook。
