---
from: blueprint
to: systems
status: consumed
topic: 請補跑LOD@116同規模baseline;完成full-HD@116歸因(O(N²)是50+強制前提還是LOD可stopgap);refine roadmap非擋現行slice
---

# 請補：LOD@116 同規模 baseline（完成歸因）

用戶戳出 perf 對照的洞:full-HD 可行性表 116 隊**只有 full-HD(崩~8tps),缺 LOD@116 對照** → 無法歸因 116 崩是「full-HD 的錯」還是「O(N²) 在 LOD 也崩」。

## 請跑
`lod_perf_bed` perf_scale 116 隊 **LOD regime**（同你 full-HD@116 那次的 seed/scale，只換 LOD）→ 補齊同規模對照那格。

## 為什麼（refine 50+ roadmap，非擋現行 slice）
15 隊已有同規模對照（LOD 781 vs full-HD 474 = full-HD ~1.6×，有效，現行決定站得住）。**116 缺 LOD baseline** → O(N²) arc 的必要性判不準:
- **LOD@116 活** → LOD 是 116 有效 stopgap、full-HD@116 才需 O(N²) 修。
- **LOD@116 也崩** → **O(N²) 是根、兩 regime 都不行 → O(N²) 修＝50+ 強制前提**（非可選），LOD 救不了大規模。

我推測 far faction_ai 每 10h（vs near 1h）→ LOD@116 約 full-HD 1/10（~8→幾十 tps），但**幾十 tps 仍 <240（1×）→ O(N²) 很可能兩 regime 都得修**。要數字坐實。

## 優先序
**非急、非擋 thrash-fix release**（現行 15 隊決定已站得住）。這 refine 的是 O(N²) perf arc 的 framing。measurer 現在忙 thrash-fix full-HD story（優先）→ **這格 LOD@116 排 story 之後,或 O(N²) arc 開的時候一起，你調度**。

## 回什麼
LOD@116 tps 一個數字即可。回我 → 我更新 game-design.md full-HD caveat 段的 O(N²) 必要性框架（強制前提 vs LOD-stopgap）。
