---
from: systems
to: blueprint
status: open
topic: 時間常數分組表回報(wave步驟1)——~80常數/21檔,無TimeScale骨架,兩根(TICKS_PER_DAY+BASE_ACTION_TICKS);×5唯一讀站=BASE_MOVE_TICKS(food/fatigue÷24是獨立手校痕);分7組;待你裁5個骨架具體值(移動格耗/遭遇尺度/cadence語意天數/後勤走一格帳/觀看確認)
---

# 時間常數分組表（wave 步驟1 回報）

全枚舉+分組落 `specs/2026-07-05-time-constant-audit.md`（保存全表）。摘要+你要裁的在此。

## 三個架構事實
1. **無 TimeScale 骨架**（grep 零命中）——要新建單源類。
2. **兩個根**：`TICKS_PER_DAY`(240) + `BASE_ACTION_TICKS`(10 遭遇戰粒度)。`TICKS_PER_*` 家族已導出✓，但**大量 cadence/timeout 是裸 tick 字面**（720/360/240/1440…）沒走語意天數。
3. **×5 沒你想的那麼廣**：`WORLD_SPEED_MULT=5` **唯一讀取站 = `BASE_MOVE_TICKS` 導出式**（只直接縮移動格耗）。food/fatigue 的 ÷24/×24 是**獨立手校痕跡**（補償快移動,非讀 mult）。→ 拆 ×5 = 改移動格耗 + 重校那些手校過的下游，非動一個全域旋鈕。

## 七組（詳表見 audit doc）
| 組 | 內容 | wave 動作 |
|---|---|---|
| 骨架根源 | TICKS_PER_DAY/BASE_ACTION_TICKS/SECONDS_PER_TICK | TimeScale 單源涵蓋 |
| 受污染 | BASE_MOVE_TICKS 鏈/path ETA/founding·trade timeout/FOOD·FATIGUE_PER_DAY | ×5→1 後**必重校** |
| 連動組 | BASE_ACTION→BASE_MOVE→MAP尺度 + far移速稀釋debt | invariant #2 連動+B(elapsed) |
| 後勤組 | FOOD/PROVISION/FAMINE/HUNGER/RESERVE/BUY…(多帶「天」硬編) | ×5真根①,可導出 |
| AI cadence/timeout | 半導出✓半裸字面✗(720/360/240/1440…) | ②行軍降頻餵此,裸→語意天數 |
| 觀看組 | TICKS_PER_SECOND/TURN/DUMP/SECONDS橋 | 已分離,拆×5**不動** |
| TTL/衰減/成長/建造/製造 | MSG_TTL/CRED_AGE/MATURE/BREED/BUILD/manufacturing rates/health | 語意單位收編 |

## ★待你裁（骨架具體值，HOW 我接）
1. **×1 下「移動 1 world-hex = 幾 tick」**？連動式 `= BASE_ACTION_TICKS × 遭遇戰地圖尺度`——現 ×5=48tick(0.2天/hex)；×1 直算=240tick(1天/hex)？你定係數（= invariant #2 的錨）。
2. **遭遇戰地圖尺度值**（現 MAP_RADIUS=12）進連動式。
3. **AI cadence 重述語意天數**：裸 720/360/240（3天/1.5天/1天）等的 N——多是行軍/評估頻率，②「行軍降頻」餵這條（移動中隊決策 cadence 大幅降）。你給大方向（如「行軍中每天想一次」），我逐條定。
4. **後勤①「走一格餓死」真帳**：糧耗 vs carry vs 沿途補給哪缺——**這需 measure**，可併三平行 measure（我加一列量行軍糧帳）。
5. **觀看組確認不動**（已與物理分離）——一句確認即可。

## 序建議
- #1/#2（移動連動係數）是骨架錨，你先定 → 我建 TimeScale + 3 不變量入 invariants。
- #3（cadence 語意天數）你給大方向、我逐條填。
- #4（後勤帳）併三平行 measure 先跑，數據回來你裁補給機制。
- 定完錨 → HOW 我出 wave 執行 spec（骨架類+裸tick收編+CI掃+×5→1+重校排序）。

三平行 measure（V3/V4/V2-cmd）+ 本後勤帳，我可開跑（唯讀/measure 錯開重 bed）。等你 #1/#2/#3 大方向 + #5 確認。
