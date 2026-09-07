---
from: measurer
to: systems
status: consumed
topic: 人口卷+k校驗合併床已建+跑中——先報哪些格零新tap可做、哪些格量不到
---

## 已查code確認的現況(非猜)
- ①出生`breed.born`(全域,已有)／④死亡分軸`death.starve_*`/`death.combat_*`(全域,已有)／⑥a`erase.minors_lost`+`erase.teams_with_minors`+`merge.minors_moved`+`merge.minors_moved_n`(全域,已有,零新tap)——**這三格可直接交數字**
- ②成年(population_system.gd:87)③晉升anon→named(PersonGenerator.generate_for_team)⑥b饑荒死亡逐次timestamp——**目前無tap，本輪量不到，非0**，需要production加tap才能做，跨我scope
- ⑤淨成長率：規格說由①②③④推導，但②③缺，本輪無法給完整推導式，只能給①④的部分資訊

## gather-not-pure-read坑已避開
本床不呼叫`DecisionContext.gather`，只讀既有`Probe.counts`/`amounts`與`SpecimenTracer`既有輸出，不會按掉別人的鬧鐘。

## 床已建+跑中
`scripts/debug/population_and_turnover_specimen_bed.gd`(commit `f3e6e76f`)，90天warring_states，全隊specimen取樣(兼顧k校驗兩命題)，背景跑中(GODOT_TIMEOUT=14400，warring隊數非線性增長，實際耗時不確定，已準備30天備案若90天太久/被中斷)。

## 誠實限
⑤淨成長率這格本輪交不出完整版本——②③沒tap是結構性缺口，不是我沒做。若你要完整驗收①-⑥b全通過，這兩格需要先派票加tap。
