---
from: systems
to: implementer
status: open
slice: 備戰下架 ★派實作（R² 撤回 contradiction ⇒ CLEAN）
tier: slice
topic: ★R² 親自查 faction_ai:3720-3723 後【撤回】衝突:「備戰接住」在 code 層級從來不存在,只在 commit 訊息的文件化期待裡 ⇒ 可派;★★而 spec §2 已補上【字面字串】那五處(terms.gd:27-29 三常數／:333 gate／options:533／faction_ai:3022／decision_engine:681,689)—— 我原本的 const 搜索漏掉它們;★★★而兩個坑寫死在 spec §3:prep.* tap【一起移除】不留著印 0(幽靈 counter),殘留狀態【機械驗證】current_task=="備戰" 隊數 = 0
---

# 派工（spec = `docs/superpowers/specs/2026-09-04-delist-prepare-HOW.md`）
```
★①options.gd:427-435「備戰」entry ⇒ 從候選池移除
★②team_data.gd:20 const ／ faction_ai:454 清單成員 ／ movement:73 ／ sim_runner:414 ／ faction_ai:754 錯註解
★★③【字面字串那五處】(我原本漏掉,R² 抓到):
   terms.gd:27-29  PREP_A/PREP_B/PREP_K 三常數
   terms.gd:333    `if opt != "備戰": return 0.0`（prepare_drive 的 gate）
   options.gd:533  `if opt in ["備戰", "迎戰", "求和"]`
   faction_ai:3022 Probe tap ／ decision_engine:681,689 prep.* tap
★★★④prep.* 那組 tap【一起移除】—— 不要留著印 0(幽靈 counter:「沒發生」與「不存在」長得一樣)
```

# ★驗收（★spec §4，其中兩條是機械斷言）
```
1 「備戰」不在候選池（★optpool 母體仍要印,證明表沒壞）
2 ★prep.* tap 全部【消失】(★★不是變成 0)
3 ★★current_task == "備戰" 的隊數 ＝ 0（★★★機械斷言,不是論證）
4 determinism 同 seed 三跑一致（fp 會變 —— 候選池變了）
5 憲法閘 PASS ＋ 17 支 merge-gate 全綠
6 ★★★流向讀數:原本輸給備戰的 option 現在贏了什麼 —— ★照原樣報,不解讀
```
★**而我【預先登記】一個預測**（★寫在你跑之前）：
```
★QA 實測:18 次備戰勝出,17 次同 tick fallback 到【求和】、1 次【紮營】
⇒ ★★預測:下架後【求和】的勝場應接近增加原本備戰的量(而不是散給各種 option)
⇒ ★★★若散開 ⇒ 我的模型錯 —— 而那本身是新資訊(fallback 的第二名不是穩定的同一個)
```

# ★★順序（★別跳）
```
①★specimen 涵蓋 runtime-born（★★那一格【先解】—— 否則重跑的材料會有同樣盲區）
②本票實作 + 驗收 ⇒ ★停在 branch
③★★我解凍(刪 .exam-freeze) → merge → ★★★重建凍結(scope=C-seg2 前的 seg1 重跑) → 重跑 seg1×3
⇒ ★而重跑只要 22 分:【先把儀器修對再跑】,不要為了快而跑出第二份有同樣盲區的材料
```
