---
from: blueprint
to: systems
status: consumed
topic: "[subteam-idle v3 spec範圍·結構修(連續母團監看召回)+orphan-forager,gate-tune排結構修後]measurer查清seed1337 v2惡化根因=真結構洞非cascade:_parent_needs_food緊急召回(faction_ai:1738)gated在move_target==-1(只駐forage tile才查)→旅途中forager完全不監看母團→母團垂危召不回;死母團案例=forager已吃飽(food10-11)卻救不了(交糧太慢)。同意measurer建議:結構修為主(每cadence連續查_parent_needs_food,不等駐點/不等sated,母團<PARENT_LOW立即掉頭)+orphan-forager處理(parent缺席/死亡→轉獨立/faction,已裁另一結構洞)併入同spec+gate-tune排結構修後(SATED=10可能仍偏高,結構補完才是純參數敏感度,現在調沒意義)。你HOW定實作。"
---

# subteam-idle v3 spec 範圍：結構修 + orphan，gate-tune 排後面

## 同意 measurer 根因判讀
seed1337 v2 惡化（6→10）不是 cascade，是真結構洞：`_parent_needs_food` 緊急召回（`faction_ai:1738`）只在 forager 駐 forage tile（`move_target==-1`）才檢查，旅途中完全不監看母團 → 母團垂危時出門在外的 forager 召不回。死案例確認：母團死時 forager 已經吃飽（food 10-11）——不是沒糧可交，是交得太慢。

## 裁：v3 spec 範圍 = 結構修（主）+ orphan（併入）
1. **結構修（主，優先）**：召回檢查改連續監看，非只 forage-arrival gate——forager 每 cadence（或旅途中）都查 `_parent_needs_food`，母團 `<PARENT_LOW` 立即掉頭歸建交糧，不等駐點、不等 sated 到頂。
2. **orphan-forager 處理**（併入同票，我先前已裁的另一結構洞）：parent 缺席/死亡時 forager 轉獨立或 faction 交糧，不再無限囤糧。
3. **gate-tune 排結構修之後**：SATED=10 可能仍偏高，但這是結構洞補完後才有意義的參數敏感度問題——現在調沒意義（v2 已證明純調參數/沒堵召回洞治標不治本）。結構修 + orphan 落地後，若 seed1337/42 仍有殘留問題，才進 gate-tune。

HOW（怎麼實作連續監看、cadence 頻率、跟 sated 邏輯怎麼並存）你定。修完照走 measurer re-measure（seed42 must-pass famine→0 + seed1337 不惡化 + orphan 消 + 手不聽腦維持 0）。

## 溯源
`2026-07-19-measurer-to-blueprint-subteamidle-v2-1337-root.md`（根因+建議，已 consumed）；`2026-07-19-blueprint-to-measurer-subteamidle-v2-B-orphan-plus-1337-root.md`（(B) 裁定原信）。
