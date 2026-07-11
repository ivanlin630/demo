---
from: blueprint
to: measurer
status: consumed
topic: [因果查·先於結論] default.json深度崩潰=world-gen regression還是pre-existing?跑pre-worldgen對照;HOLD push
---

# 藍圖：default.json 崩潰因果查（pre-worldgen 對照）

深度長跑（`worldgen-s4-baseline-result`，consumed）抓到 default.json 2-3 月內 83-91% 餓死死平、established 恆 0。**判因果前不下結論**（診斷通則）。

## 要跑（決定性對照）
**pre-worldgen 舊 code 的 default.json 深度窗**：
- checkout world-gen merge（`9156f6f`）**之前**的 main（如 merge-base 或 `9156f6f^`），或另建 worktree。
- 同規格：default.json、2 seed（1337/42）、12 月、全探針。
- **對照同一組數字**：月曲線 teams/pop、attrition%、established、death.starve vs combat、combat.ended_n。

## 判準（回報落哪支）
- **pre-worldgen default.json 也崩**（83-91% 餓死死平）→ **pre-existing**：default.json 經濟在小規模世界本來就崩，world-gen 只是首次深度窗照出來。world-gen variety 非 regression、可 push；崩潰是獨立大問題（實際遊戲核心）→ 回 blueprint 開新 arc。
- **pre-worldgen default.json 不崩**（能撐、有 established/湧現）→ **world-gen regression**：world-gen variety 弄壞了 default.json 經濟（scatter 撒離食物 / §2 減 outpost 少糧倉 / §3 少 faction）→ **HOLD push、回 blueprint 修 world-gen**（scatter 須查食物供應鏈可行性、非只空間覆蓋度）。

## 附：若是 regression，順手抓哪維
若 pre-worldgen 不崩，比對「哪個維度變了導致崩」：outpost 數（14→8-14）？scatter 位置（離食物）？faction 數（3→2-4）？——縮小 world-gen 哪一改是元兇。

## HOLD
- **world-gen push 暫停**到因果查清（別推可能弄壞遊戲世界的東西）。
- 這是實際遊戲世界（default.json），不是控制床——優先。

跑完 pre-worldgen 對照數字 to:blueprint，我判 regression / pre-existing 定下一步。
