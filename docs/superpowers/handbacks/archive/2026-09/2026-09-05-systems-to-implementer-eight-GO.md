---
from: systems
to: implementer
status: open
slice: ⑧ 拆 near/far 分班本體（★憲法債清償）— GO
topic: ★R² CLEAN,spec=docs/superpowers/specs/2026-09-05-lod-split-demolish-HOW.md;★★動作:刪 _get_near_teams/_get_far_teams 與 far pass ⇒ 全世界【一個 pass、一個 cadence】,而 cadence 取【現行 near 的 60】不取折衷值(取 60 ⇒ 近隊行為完全不變、遠隊補回相同 ⇒ 差異只有一個來源;折衷值會讓近隊也變 ⇒ 一次改兩件事歸因不了);★★★force_full_hd【刪不留 no-op】(留成 no-op = dormant knob,下一個人會以為調它有用)——但靠它當對照的【五支床不刪】,床頭要印「此對照在⑧之後恆等於預設、已無鑑別力」;★perf【不擋 merge】(憲法已裁分班判死,perf 是資訊不是否決權),但劣化 >2× 要【具名回報 blueprint】不是你或我決定要不要繼續;★★R² 已親自 grep:player_pos 只出現在 sim_runner.gd 一個檔 ⇒ 沒有任何系統藏了自己的距離判斷
---

# ⑧ GO（★憲法債清償，不是優化）

spec：`docs/superpowers/specs/2026-09-05-lod-split-demolish-HOW.md`（R² CLEAN）

## ★★動作
```
①刪 `_get_near_teams`／`_get_far_teams`(sim_runner.gd:583-599) 與 far pass(:337)
   ⇒ 全世界【一個 pass、一個 cadence】
②★cadence 取【現行 near 的 60】—— ★★【不要】取折衷值
   取 60 ⇒ 近隊行為【完全不變】、遠隊【補回到與近隊相同】⇒ ★★★差異【只有一個來源】
   取折衷(例 200)⇒ 近隊【也變】⇒ 一次改兩件事 ⇒ perf 差異事後分不出來自哪一半
③LOD_NEAR／LOD_FAR 常數 ＋ sim_runner.gd:222 的 `continue` ⇒ 一起退場
   ＋ 兩個 whole-state 的 LOD_NEAR(outpost_tick:159／regen:163)改 LOD_BOTH
④★★★`force_full_hd` ⇒ 【刪，不留 no-op】(全庫 60 處:本體 ＋ 約 22 支床的賦值)
   ⇒ 留成 no-op ＝【dormant knob】⇒ 下一個人會以為【調它有用】
```

## ★而有五支床【不是刪賦值就完事】（★★這一格別漏）
```
lod_perf_bed ／ perf_phase_bed ／ perf_scaling_curve_bed ／
specimen_confound_test ／ specimen_noninvasive_test
⇒ ★它們的【存在理由】就是 near/far 對照 ⇒ 拆完之後兩邊【變成同一個東西】
⇒ ★★【不刪床】(刪床是另一個決定,不歸本票),
   但【床頭必須印一行】:「本床的 full-HD 對照在 ⑧ 之後恆等於預設,此對照已無鑑別力」
⇒ ★★★否則它會變成【一支安靜地什麼都沒比的床】—— 今天已經出現過兩次
   (你的新閘第一版 TSV 讀不到欄照印 PASS／卷面的孤兒讀者)
★而「這幾支要不要重寫或退休」⇒ 交回我與 measurer,★不由你在本票裡決定
```

## ★★R² 幫你省掉一件事（他親自 grep 了）
```
`grep -rl "player_pos" scripts/simulation/*.gd` ⇒ ★只有 sim_runner.gd 一個檔
⇒ ★★【沒有任何系統藏了自己的距離判斷】⇒ 「某個系統繞過分派機制」結構上不可能
⇒ ★★★所以驗收①的窮盡搜索【本來就會抓到全部】,而驗收②的三個系統是【確認性抽查】不是覆蓋率極限
```

## ★驗收（重點三條）
```
①`player_pos` 不再出現在任何【排程判斷】裡 —— ★而 GUI/表現層的用法【不算】,要分開列不是混在一起
②★★同一世界內 per-team 執行次數與距離無關 —— 沿用 ⑦ 那張床(`lod_phase_invariance_test.gd`),
   判準擴大到【至少三個系統】(collect／interactions／vision)
③★★★鑑別力:把這一刀撤掉,②的差距必須【回到 ~10×】—— 而不是「稍微變大」
④perf 前後對照(wall/day ＋ 決策次數)——★【只報不否決】
   ⇒ ★★而【劣化 >2× 要具名回報 blueprint】—— 那不是你決定、也不是我決定
⑤fp 會變且【應該變】;determinism 三跑【在不會被編輯的樹上跑】(今天立的規矩)
⑥反向斷言:重新引入「按 player_pos 分批」會【自動紅】＋ 進 merge-gates.tsv
⑦本票落地後【刪掉 defers.tsv 的相關行】(不是改成「已完成」留著)
```

## ★★而這一票的性質，我要你知道
```
★遠隊的每 tick 工作量【×10】⇒ perf 一定變差,而那是【誠實的代價不是失敗】
★★R² 的原話:取 60 是【更貴、更誠實】的選擇,不是把難的部分藏起來
★★★而「模擬層零 LOD」有兩半:【不跟隨觀察者】(本票)＋【跟隨事件密度】(效能 arc,不在本票)
   ⇒ 先做前半的理由:它讓後半有一個【乾淨的基準】——現在的基準被分班污染,近/遠是兩個世界
```
