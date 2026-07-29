---
from: systems
to: reviewer
status: open
topic: "[R²·和平經濟觀測床(measure-first Step0)·spec=2026-07-30-peaceful-economy-bed-HOW.md·用戶核可measure-first(別憑2victim溶解訊號理論pivot,先量confound:runway建錯軸vs測錯條件warring壓經濟)·零sim-code改:新config/peaceful_economy.json(explicit seeded 好戰=0全隊 sharp缺口~12隊)+reuse WarringHarness.run(4問tap全在PROBE_KEYS)+薄peaceful_economy_bed.gd(讀-print 4問報告+逐隊月故事,零RNG)·量4問(founding dispatch?發展?貿易?runway機制fire?)gate funnel分動機無vs卡gate·★HOW選擇:sharp hand-fixture非random全規模和平旗(零code改+最決斷,透明報blueprint可否決)] 和平經濟床。審sharp-fixture選擇+缺口設計真驅動4行為+tap覆蓋齊+零RNG。"
---

# R²：和平經濟觀測床（measure-first Step0）

## spec
`docs/superpowers/specs/2026-07-30-peaceful-economy-bed-HOW.md`（讀它）。

## 一句話
用戶核可 measure-first：**別憑「兩 victim 溶解」訊號理論式 pivot**，先量掉 confound（runway 建錯軸 vs 測錯條件=warring 壓經濟）。做 seeded 和平床看得見經濟→量 4 問（founding dispatch?發展?貿易?runway 機制 fire?）→資料裁分支（economy 有+runway fire=續 runway/economy 無=動機壞 pivot material arc）。

## 做（零 sim-code 改）
- 新 `config/peaceful_economy.json`（explicit seeded、`好戰=0` 全隊、sharp 缺口 ~12 隊、4 類各對一問）。
- reuse `WarringHarness.run`（4 問 tap 全已在 PROBE_KEYS：indep.found_*/construct.*/trade.*/foodflow/bridge/persist.hold）。
- 薄 `peaceful_economy_bed.gd`（讀-print 4 問報告+逐隊月故事，零 RNG、可加 @observe-pure marker）。

## ★reviewer focus（異質 refute）
1. **★HOW 選擇：sharp hand-authored fixture vs random 全規模「和平旗世界」**——我選 sharp（零 code 改+最決斷「隊明顯該 found 卻不 found=動機壞」）。**這選擇對否**？sharp fixture 的 artificiality 會不會被質疑「碰巧沒隊想 found」＝confound 沒真掉（vs organic「warring 世界減戰爭」才是乾淨 counterfactual）？值不值得改 person_generator 做 organic 版？
2. **缺口設計真驅動 4 行為否**：material=0+forest 在旁+有 means→真該 found（means-end 鏈 known_issues:9-11 標 PARK/broken——**這正是要測的**：sharp 案下 founding 到底 fire 否）。缺口設計會不會漏了某行為的必要前置（如 founding 還需啥 gate 我沒給）？
3. **tap 覆蓋 4 問齊否**：§3 列的 probe key 有沒有漏（如「發展」除 construct.complete_upgrade_* 還有別的 develop 訊號？「runway fire」除 foodflow/bridge/persist 還有 safe_factor 本身的 tap？）？
4. **bed 零 RNG + LOD all-far 對 team 決策足否**（team-strategic all-far 照跑我斷言對否／person breeding 排除合理否）？

## 判
CLEAN → implementer（config+薄 bed）→ measurer 產 4 問數 → 回 blueprint 裁分支。有洞（尤其 1：sharp vs organic 選擇）→ 回 `to:systems`。這是 measure-first 的量測基礎，方法論要穩。
