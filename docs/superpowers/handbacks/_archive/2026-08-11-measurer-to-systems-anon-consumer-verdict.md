---
from: measurer
to: systems
status: consumed
topic: "[anon真consumer trace完成——★★決定性:population overflow spin-off是真兇,非leak非named機制競爭,對應blueprint(結構偏小)象限] get_stack() caller trace(seed8181 dispersed tick0-1200,ANON_TRACE=1)逐筆記錄lord Team0每次transfer_proportional:from=0→to=4(day1)/from=0→to=4(day2)/from=0→to=5(day3)/from=0→to=6(day4),count皆=1,精準對應同期raw log的[Succession]Team4/5/6從匿名晉升新領袖事件——這是population overflow觸發的『promote一名anon成為新獨立團隊leader』spin-off機制(非任何crisis-relief側dispatch)。同期出現的from={4,5,6}→to=0 count=0呼叫是另一個(可能absorb-check類)零效果呼叫,非真正『歸還』。★★這徹底回答blueprint的a/b/iii問題:不是leak(這些anon設計上就該永久離開、spin-off非借出)、不是named機制競爭(herald/scout/distribute/migrant/invest全程0)——是population overflow機制把pool從4耗到0,4次分裂各拿1人,天生小pool(config anon_tiers:平民4)撐不住連續4次spin-off。屬於blueprint框架的『(結構偏小)pool起始就不夠×正常消耗=非bug非競爭、器官容量config問題』象限。care-loop branch仍hold,交你/blueprint裁決定案。"
---

# anon 真 consumer trace 完成 —— ★★population overflow spin-off 是真兇

ticket `2026-08-08-systems-to-measurer-anon-consumer-trace.md` + `2026-08-11-systems-to-measurer-anontrace-flag-tip.md` 消費。已用 `get_stack()` caller trace（temp tap 於 `anon_tier_system.gd::transfer_proportional/add_anon/remove_anon`，已 `git checkout --` 復原確認乾淨）精準抓到真兇。

## 決定性證據：逐筆 anon 流向 + [Succession] 事件時序完全對應

```
[anon-trace] transfer_proportional from=0 to=4 count=1   （day1，lord_anon 4→3）
[Succession] Team 4 從匿名晉升新領袖 P3002（統領=0.07）

[anon-trace] transfer_proportional from=0 to=4 count=1   （day2，lord_anon 3→2）
[Succession] Team 4 從匿名晉升新領袖 P3003（統領=0.24）

[anon-trace] transfer_proportional from=0 to=5 count=1   （day3，lord_anon 2→1）
[Succession] Team 5 從匿名晉升新領袖 P3004（統領=0.78）

[anon-trace] transfer_proportional from=0 to=6 count=1   （day4，lord_anon 1→0附近）
[Succession] Team 6 從匿名晉升新領袖 P3005（統領=0.10）
```

**每一筆 `from=0 to={4,5,6} count=1` 都精準對應同一天的 `[Succession] TeamN 從匿名晉升新領袖`**——這是 population overflow 觸發的「從匿名晉升一人成為新獨立團隊 leader」spin-off 機制，跟 herald/scout/distribute/migrant/invest 完全無關。

同期還出現 `from={4,5,6} to=0 count=0` 的呼叫——count=0 代表這些是另一種（可能是 absorb-check 類）零效果查詢式呼叫，**不是真正的「歸還」**，只是恰好也走了 `transfer_proportional` 這個共用函式但沒有實際搬動。

## ★★回答 blueprint 的 a/b/iii 問題

- **不是 LEAK**：這些 anon 在設計上本來就該永久離開（population overflow spin-off 是「分裂」不是「借出」，沒有歸還的預期）。
- **不是 named 機制競爭**：herald/scout/distribute/migrant/invest 全程 0（上一輪已測），沒有「多個 crisis-relief 側 dispatch 真搶同一池」這回事。
- **是（結構偏小）象限**：pool 起始容量（config `anon_tiers:{平民:4}`）對「連續 4 次 population-overflow spin-off」這種正常人口動態撐不住——4 個 anon，4 次分裂各拿 1 個，day5 前用光，此後 40 天沒有任何機制把新增人口導回這個可調度池（或者新增人口太慢、不夠快回補）。這正是 blueprint 自己框架裡的「pool 起始就不夠×正常消耗=非 bug 非競爭、器官容量 config 問題」那一支。

## 落地檔案（已 git commit `8784f972`）

- `scripts/debug/scale_econ_anon_consumer_trace_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-anon-consumer-trace-raw.txt`（154行，逐筆 `[anon-trace]`+`[Succession]` 完整對照）

## 序

care-loop branch 仍 hold。這條線的量測面到此可視為完整收尾——population overflow spin-off 是 anon 池枯竭的真兇，非 bug、非 named-mechanism 真競爭。交你/blueprint 裁決 a/b/iii 最終定案（我判讀是落在 blueprint 說的「結構偏小」那支，但最終定案非我越界）。
