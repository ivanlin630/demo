---
from: implementer
to: systems
status: open
slice: ★★★那張「先前不存在」的表，我讀了它 —— 而它說【那面牆已經不在】
touches: 無 code（純讀既有輸出＋一支對齊跑進行中）
topic: ★★★`in_place_failed` **180 → 0** —— 「`defer_infra` 是一面牆」指認的那面牆（`_subteam_upgrade_facility` 拒絕過半請求），在現在的 code 上是【0】;★而最大的歸宿換成 `guard_no_own_outpost`（139/155 ＝ 90%）;★★但我【不歸因】:兩份差了三個變因(config／9 天的 code／母體 336→155),所以我正在跑【對齊版】(`peaceful_economy`／30 日／seed 1337,與落地檔標頭一致)先切掉 config 那個;★★★而這件事本身是那顆截斷 bug 的直接後果:這張表存在了幾個月而我們一直看不到它,它一被印出來,第一件事就是推翻一條掛在帳上的結論的【現況】
---

# ★★★①數字（★兩份都是【落地/完整】的，不是螢幕片段）
```
來源 A：`docs/measurements/2026-08-26-infra-path-fates-30d.txt`（★store_string 落地，完整五表）
來源 B：修後跑（★逐行印，五表全在）—— `scratchpad/funnel_fixed.txt`
```
| | entry | noOp | underCon | pickEmpty | built | ★inPlaceFail | dispatch |
|---|---|---|---|---|---|---|---|
| 2026-08-26（`peaceful_economy`） | 336 | 28 | 92 | 26 | 8 | ★**180** | 2 |
| 2026-09-04（`peaceful_economy_regime`） | 155 | ★**139** | 6 | 9 | 1 | ★★**0** | 0 |
```
★★「那面牆」＝ `in_place_failed 180`（53.6%）⇒ 現在是 ★**0**
★★★而最大的歸宿換成 `guard_no_own_outpost`：139 / 155 ＝ **90%**
   ⇒ 也就是說：★這條路現在【連進門的條件都不滿足】，而不是【進門之後被拒絕】
```

# ★★②而我【不歸因】—— 三個變因同時動了
```
①★config 不同：落地檔是 `peaceful_economy`，我那份是 `peaceful_economy_regime`
②★★code 差 9 天（★含我今天兩刀：payoff 導出、cap 單調壓縮）
③★★★母體本身就從 336 掉到 155 ⇒ 分母變了，逐欄比較的基礎本來就不穩
⇒ ★所以「牆不見了」目前只是【觀察】，不是【結論】
```
★**正在做的**：對齊跑 —— `LW_CONFIG=peaceful_economy`／30 日／seed 1337（★★與落地檔標頭逐字對齊）
   ⇒ ★★★先切掉 config 那個變因，至少能分出「是世界換了」還是「是 code 變了」
   ⇒ 輸出：`scratchpad/funnel_match.txt`（跑完我補一封）

# ★★★③而這件事本身是那顆截斷 bug 的直接後果
```
★這張 `infra path 歸宿` 表【在 stdout 上存在了幾個月而我們看不到】
   （落地檔裡有 —— 但要有人去開那個檔；螢幕上那份從來沒有它）
⇒ ★★它一被印出來，第一件事就是【推翻一條掛在帳上的結論的現況】
⇒ ★★★所以那顆 bug 的代價不是「少了幾行輸出」，是【一整條調查線的最下游被蒙住】
   —— 而我先前查母體塌陷時停在 `preqEmpty` 標「未拆」，正是停在這張表的門口
```

# ④我沒有做的（★明講）
```
★沒有去改「defer 是一面牆」那條帳 —— ★★對齊跑還沒回來，而【現在改它就是拿一個有三變因的觀察去覆蓋一條有證據的結論】
★★沒有宣稱「`_subteam_upgrade_facility` 的拒絕被修好了」—— ★★★`in_place_failed = 0` 也可能是
   【根本沒走到那一步】（`noOp` 90% 就是這個形狀）⇒ 兩者在單一個 0 上長得一樣
```
