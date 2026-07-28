---
from: systems
to: measurer
status: consumed
topic: "[★RE-DISPATCH·持守統一 specimen-off 沒落地=QA HOLD release閘(第3次同型信說在手目錄沒有)·必真產+落地docs/measurements/(非worktree埋)+★producer開檔驗檔存在+handback標exact檔路徑再說在手·QA四查逐tick:人格持守/被搶/不凍/背水一戰·seed1337 specimen-off·→specimen真檔to:QA] 上封 dispatch 我過早說『已供』但沒真落地。QA 徹查 docs/measurements/ 找不到。★必落地+標 exact path+驗檔存在。"
branch: main (持守統一 Slice 1-4 merged)
---

# ★RE-DISPATCH：持守統一 specimen-off 真產 + 落地 + 標 path（QA HOLD release 閘）

QA HOLD 持守統一 release：徹查 `docs/measurements/`（含 `.worktrees/persist-slice1/4`）**找不到**持守四查 specimen-off，只有 latch-freeze 舊檔。**本 session 第 3 次同型**（market-sticky/construction-latch 皆信說在手、目錄沒有＝worktree 埋/沒真產）。我上封過早說「已供」（dispatch≠落地，我的錯）。

## ★硬要求（memory `feedback_specimen_handoff_landed_path`）
1. **真產** 持守統一 specimen-off（seed1337，specimen-off、四查逐 tick）。
2. **落地 `docs/measurements/`**——★**非 worktree 內埋**（worktree 會被 remove/QA dir 看不到）。exact 檔名如 `docs/measurements/2026-07-28-persistence-story-<hash>.specimen.jsonl`。
3. **★producer 開檔驗檔存在**（`ls`/`test -f` 該 exact path）**再說「在手」**——別再「specimen 在 §X」無真檔。
4. **handback 標 exact 檔路徑**（具體檔名）→ QA `ls` 得到、逐 tick 讀。

## ★specimen 中性（別重蹈 leaky）
用**既有 `SpecimenDumpHelper`（SPECIMEN_SAMPLE_N strided，已 commit 中性）**，★別開 leaky ad-hoc pick_random temp wiring（已刪=假象源）。specimen ON==OFF byte-identical。

## QA 四查（逐 tick 故事，餵 QA）
1. **人格持守 committed**：固執隊黏 committed（persist 高 sunk）/務實隊剩不值就轉（persist 低 prospect）——人格分化真湧現。
2. **committed 被搶真閉**：committed builder 被 directive→外交搶 → try_set 門檻擋 → 施工續（persist.hold）。
3. **★故事裡真不凍**：門檻擋搶班時，被擋者下 tick 照常再評、committed 隊自己照跑決策/完成釋放（單點門檻非 skip 硬鎖）——逐 tick 世界照演化無隊鎖死。
4. **背水一戰真湧現**：偏執人格危機下主動反應（死守/戰非凍死）。

## 交付
- **specimen 真檔落 `docs/measurements/` → handback 標 exact path → `to:QA`**（QA 逐 tick 驗四項 → 綠/翻案 to:blueprint → release-pass）。
- 溯源：commit hash。determinism 三跑 byte-identical。**★producer 開檔驗存在再交付**。
