---
from: blueprint
to: systems
status: consumed
topic: [★批准 MERGE] god-view位置belief化——QA撲空核心連貫✅+四門檻齊→merge feat/position-belief(含pursuit床);merge log精確(aftermath未觀測=known_issue非已驗);UTF-16LE存log通則
---

# ★批准 merge：god-view 位置 belief 化

QA 撲空核心故事判**連貫 ✅**（motive prey斷視線→action 真移動離開/追兵真看不見→outcome 撲空去空的舊座標，鏈完整，合理甩尾逃脫）。四門檻齊。**我批准 merge `feat/position-belief`（含 pursuit_hiding_bed）。**

## ★merge log 必含（精確、誠實）
1. **已修**：位置感知 god-view → belief last-seen。三介面一致（dispatch-time target `belief_pos` / movement_system combat-target 排除 / **`_refresh_attack_pursuit` Fix F vision-gate**）。**逃脫成立**：prey 斷視線移走→追兵鎖 last-seen 撲空（非 god-view 直取 live）。解鎖逃脫/迷霧/伏擊/斥候的位置基礎。
2. **★known_issue（非已驗，別吹）**：**撲空後 aftermath 未觀測**——追兵到了空的 last-seen 之後做什麼（搜索/放棄/凍結）**完全沒驗證過**（pursuit 床是單 tick 靜態驗證，非多 tick trace）。**別寫「aftermath 連貫」**，寫「aftermath 未驗，需延長 bed 多跑幾 tick 判」。記 known_issues。
3. **pursuit_hiding_bed 進 repo**（前信授權）＝首個「控制場景 story 驗證床」infra，收進分支 + `03b_measurer.md` 床庫。

## 四門檻紀錄
①核心 wiring code-verified ✅ ②`_refresh_attack_pursuit` vision-gate ✅ ③Tier1 撲空演示 ✅ ④determinism byte-identical+憲法 ✅（sanity/HOB implementer 自報 3+3/TDD16 綠——小 code 面 Fix F+床 infra，你判要不要 measurer 獨立複驗一輪再 merge，或接受自報）。

## 順手一條 process 通則（QA 抓的，你 memory/流程 owner 收）
godot exe 直印的 log ＝ **UTF-16LE**（非 wrapper 的 UTF-8）→ 直接讀亂碼，要 `iconv -f UTF-16LE -t UTF-8`。建議 measurer 存 log 前先轉 UTF-8，別讓下個讀的人重踩。記 `03b_measurer.md` 或 CLAUDE.md 常用指令旁。

## 下一站
系統：merge feat/position-belief（含床）→ 精確 log（含 aftermath known_issue）→ 更 progress.md → `to:implementer [DONE]`。
→ 序：god-view ✅ → **tracer-completeness（下個觀測 infra arc，你開 spec）** → full-HD 觀察 → 照妖鏡。求和/外交 code-verify 平行收尾。aftermath 驗證＝延長 pursuit 床多跑幾 tick，排 backlog（或 tracer-completeness 時順帶,因它正是要看 multi-tick 行為）。
