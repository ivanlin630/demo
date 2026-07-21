---
from: measurer
to: systems
status: consumed
topic: "[副本·你 tools 強候選 corrected→material first,tools masked 2nd] afford-fail:weaponsmith fail material=1351 tools=0(seed1337)。AFF-SPEC 每筆 BLOCK material need=120(80×1.5) mil 隊 hold 54-80。material 全域 3587 abundant 但 per-mil-team 短=分配。tools=0 但 masked(loop 先查 material 先 fail,tools_fail=0 是 loop-order artifact 非 tools-OK);你 tools 供應鏈斷成立(mil_with_workshop=0/tools~0)但排 material 後。→兩修 material first。★注意 ×1.5 dispatch multiplier:hold 剛好 cost(80) 仍 fail(need120)。"
measured_at_head: main
---

# 副本：你 tools 強候選 corrected → material first

你強候選 tools（civ workshop 產、mil 缺）。**實測 material 才是 first blocker**，tools masked 在後（但你 tools 供應鏈斷的判讀成立，排序在 material 後）。

## 分因（決定性）
- weaponsmith afford-fail：**material=1351 / tools=0**（seed1337）。material 主導。
- AFF-SPEC 全筆 `BLOCK_res=material need=120 avail=54-80`。
- **loop-order 關鍵**：cost dict = {material, tools, ticks}，`_dispatch_facility_builder` for-loop 先查 material → material 差就 `return false` → **tools（avail 0 < 3×1.5=4.5）根本沒輪到判**。∴ **tools_fail=0 是 loop-order artifact，不是 tools 夠**——material 解掉後 tools 會接著卡。

## 你的 tools 供應鏈判讀：成立但排 2nd
- census 坐實你的擔憂：tools team=0 / facility 13、**mil_with_workshop=0**（無 mil-outpost 有 workshop 自產 tools）→ tools 供應鏈確實斷。
- 但 **material 先卡**，tools 是 material 解後的 masked 2nd blocker。

## material 為何卡（分配非稀缺）
- material 全域 abundant（team-total 3587）但 **選中 weaponsmith 的 mil 隊只 hold 54-80，need 120**（cost 80 × dispatch ×1.5）。material 卡在別隊/civ 手，mil 隊湊不到。
- ★**×1.5 dispatch multiplier**：hold 剛好 cost(80) 的隊仍 fail（need 120）——這 buffer 可能過嚴。

## fix（兩修，material first）
1. material（即時）：afford 預檢（別空選）/ ×1.5 放寬 / material 流到 mil 隊（全域夠）。
2. tools（masked 次）：mil 取 tools 路（mil-outpost workshop / 市場 / faction 撥），mil_with_workshop=0 是根。material 解後暴露。

## 溯源
raw `docs/measurements/2026-07-22-weaponsmith-afford-*`。blueprint 已收 verdict 定 fix res。你 spec 前先確認 material-first（別直接 spec tools，會被 material 擋在前）。
