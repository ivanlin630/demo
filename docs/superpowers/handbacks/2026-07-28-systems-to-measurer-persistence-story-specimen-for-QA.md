---
from: systems
to: measurer
status: open
topic: "[measure·持守統一 arc release 前 QA 故事稽核用 specimen·★specimen-off 乾淨 tracer(用既有 SpecimenDumpHelper SPECIMEN_SAMPLE_N strided 中性,別開 leaky ad-hoc pick_random)·抓持守故事:隊真按人格持守committed/背水一戰真湧現/故事裡真不凍/committed被搶真閉·seed1337/42·→specimen to:QA] blueprint 派 QA 故事稽核持守 arc(release 前硬紀律,大聚合結論必逐tick故事驗)。measurer 產 specimen-off 乾淨 specimen 餵 QA。"
branch: main (持守統一 Slice 1-4 merged)
---

# measure：持守統一 arc QA 故事稽核 specimen（release 前）

持守統一 arc（Slice 1-4 merged，機制達標）release-pass 前 blueprint 派 QA 故事稽核（本場硬紀律：aggregate 漂亮但故事翻的前科=means-end A1 假閉環/latch 假象）。measurer 產 **specimen-off 乾淨 specimen** 餵 QA。

## ★specimen 中性硬要求
- **用既有 `SpecimenDumpHelper`（SPECIMEN_SAMPLE_N strided，2026-07-28 已坐實中性 + commit 進 repo）**，**★別開 leaky ad-hoc pick_random temp wiring**（那支已刪、是 latch 假象/世界岔開的源）。
- specimen ON==OFF byte-identical 前提下抓（觀測中性、不擾動被觀測世界）。

## ★抓持守故事（餵 QA 逐 tick 故事稽核）
1. **隊真按人格持守 committed**：固執/恆心人格隊追 committed 動作（build/campaign）黏著久（persist 高、sunk 加權）；務實/機會人格隊剩不值就轉（persist 低、prospect 加權）。★人格分化真湧現（aggregate 固執0.3/務實0.06，故事裡真按人格行為否）。
2. **背水一戰真湧現**：偏執/狂信人格隊危機下**主動反應**（死守/戰，非凍死呆住）——危機 axis+人格，非持守 axis。
3. **★故事裡真不凍**（latch 大憂逐 tick 驗）：committed 隊被 persist 門檻擋搶班時，**被擋的搶班者下 tick 照常再評、committed 隊自己照跑決策/完成釋放**（單點門檻非 skip 硬鎖）——逐 tick 看世界照演化、無隊呆住鎖死。
4. **committed 被搶真閉**（手不聽腦核心）：committed builder（已 start_build）被 directive→外交 argmax 搶時 → try_set 門檻擋 → 施工續（persist.hold=376 aggregate，故事裡逐 tick 真保護否）。

## 交付
- **§specimen（持守 arc 隊 goal_state + persist_strength + committed 動作 + try_set 門檻擋 trace）→ `to:QA`** 故事稽核（隊真按人格持守/背水一戰/不凍/被搶真閉逐 tick）。
- 溯源：落檔 + commit hash。determinism 三跑 byte-identical（觀測禁 RNG）。seed1337/42。
