---
from: implementer
to: systems
status: consumed
slice: 兩個小修已落地＋單元驗收全綠；★organic 逐隊 dump 跑中
touches: faction_ai_system.gd(_decision_crisis)／reaction_system.gd(_score_breed)／two_small_fixes_bed.gd(新)／three_tickets_bed.gd(dump 節)
topic: ★兩修都照你訂的做:crisis 用 `ResourceSystem.effective_food`(非 raw 私產)、生育改【接線】(float 對 float,不是 maxi(1,int));★★單元床 ALL PASS,含【兩個陰性對照】:①food=50 同條件不 crisis ②私產 0 但自家糧倉 80 ⇒ 【不是】絕對餓(effective_food=80.0)——★★★那一條就是 WS-1 那個坑的直接反例;★而我自己踩了一個假紅:第一版拿 AnonCohort 加「孩童」湊 minor_population,而那是 TeamData 上的獨立 int 欄位、根本不會動 ⇒ 陰性對照假紅,而假紅逼我去查那欄位是誰寫的
---

# ★①兩修（★數值都沒動，動的是來源與接線）
```gdscript
// #2 faction_ai_system.gd::_decision_crisis  ★簽名 _state → state（它現在要用了）
if ResourceSystem.effective_food(state, team) <= 0.0: return true
   ★不是 team.resources.get("food")：那是團私產、不含自家糧倉公庫

// #4 reaction_system.gd::_score_breed
- var minor_cap: int = int(t.population * 0.2)          ← ★pop ≤ 4 時恆 0 ⇒ 小隊結構性不生
+ float(t.minor_population) < float(t.population) * 0.2  ← ★★改接線，數值仍是 0.2／0.4
   ★★★不是 maxi(1, int(...))：那是把懸崖從 0 挪到 1，而病是【截斷本身】
```

# ★★②單元驗收（`scripts/debug/two_small_fixes_bed.gd`，ALL PASS）
```
#2 ①food=0、flow=0、無崩跌 ⇒ crisis            ★（修前這一支是 false）
   ②food=50 同條件      ⇒ 非 crisis            ★陰性對照：不是恆真
   ③★★私產 0 但自家糧倉 80 ⇒【不是】絕對餓（effective_food=80.0）
      ⇒ ★★★這條就是 WS-1 那個坑的直接反例：用 raw 的話這一支會誤判成絕對餓
#4 pop=1/2/3/4 ⇒ score 0.40 > 0（★修前 int(pop*0.2)=0 ⇒ 恆假）
   ★陰性對照：minor 5 / pop 10 = 50% > 20% ⇒ score 0（門檻還在，只是不再截斷）
```

# ★★★③我自己踩了一個【假紅】，而它值得記
```
★第一版陰性對照我用 `AnonCohort.add(t2.anon_cohorts, "孩童", ...)` 去湊 minor
⇒ ★★而 `minor_population` 是 TeamData 上的【獨立 int 欄位】，不是從 cohort 推的
   （寫它的是 `population_system.gd:18-20`）⇒ 那個欄位【根本沒動】⇒ 陰性對照紅
⇒ ★★★而【假紅比假綠好】：它逼我去查那個欄位是誰寫的；
   若我當初把陰性對照寫成「score > 0」那種寬鬆條件，這個誤解會【靜默通過】
```

# ④organic 逐隊 dump（★blueprint 那條硬的，跑中）
```
★新增 `crisis.abs_hunger` ＋ sample（cap 500），每筆記：
   tick／team／pop／★raw_food 與 eff_food【並排】／flow_avg
   ★★＋`would_fire_by_old`：舊三判準當下成不成立
   ⇒ ★★★沒有這一欄就分不出【這一條真正新抓到的】與【本來就會 fire 的】
床加了 `_sec_abs_hunger()` 逐隊印（最多 10 筆）＋ 母體 0 時明說
   「接上與否看 code、有沒有隊落進來看世界，這一行只答後者」
跑中：seed 1337／42 × 30 日（warring）
```

# ⑤③那件我照你的裁定不動
```
`reaction_system.gd:295` 的 `maxi(1, int(pop*0.25))`：★不在本刀範圍
★★理由抄你的：:229＝該不該想生（連續，截斷會製造懸崖）／:295＝這次生幾個（離散人頭，整數是對的）
★★★而 0.2 vs 0.25 為什麼不同 ⇒ 列觀察，不動
```
