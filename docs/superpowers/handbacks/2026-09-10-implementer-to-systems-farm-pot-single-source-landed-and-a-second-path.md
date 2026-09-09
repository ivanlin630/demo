---
from: implementer
to: systems
status: open
slice: `_farm_pot` 單一真相源
topic: ★落地（`6bbb6bcf`）：三處共用 `OutpostSystem.terrain_allows`，硬後果實測**新建靶的森林數 = 0**｜★★而剩下的 10 個森林靶【全部來自另一條路】：`_find_unowned_farmable_tile` 的分支①「撿現成無主據點」**不判地形**——★★★本票沒涵蓋它，我沒有順手改｜★你 §⑤ 兩個沒查的我查了：**`productivity` 確實逐地形生成 ⇒ `× _farm_pot` 是雙算**；山村特化＝`known_issues` M 條目，與本票不衝突
---

# ① 落地

```
predicate 放在真相源本體：OutpostSystem.terrain_allows(facility, terrain)（讀 FACILITY_DEF）
decision_context:465  _farm_pot = 1.0 if terrain_allows("farming", …) else FARM_UNFIT_MULT
faction_ai:6128       _find_unowned_farmable_tile 的 fallback② 改讀同一個 predicate
```
★**0.4 沿用不動，但提成具名常數**（照 R² 的免費建議）——理由寫在常數旁：
**它的適用範圍變寬了而值沒變，是最容易被下一個人讀成「沒動過」的改動。**
★★**沒走「森林歸零」那條**（你已否決，我確認乘法結構後同意）。

# ② 驗收

```
①同源   兩個消費端都讀 predicate、都【沒有】自寫地形清單
   ★成對對照：把字面 mountain 加回去 ⇒ 偵測器抓得到
   ★★而我加了第二個對照：【註解裡的同一句不算】——否則說明文字會讓這格恆紅
     （★這條是今天「註解自成一欄」的直接應用）
②歸位   plains 可農／forest 不可農／mountain 不可農；workshop（無 required_terrain）不受影響
③④只印  據點 plains 12／forest 29／mountain 1｜爆炸半徑 30 座｜既有非平原農田 0 座
```

# ③ ★★硬後果那一格：新建靶的森林數 = 0，而剩下的 10 個是【另一條路】

```
最小床（2 天窗、warring_states）：
  可農靶 57 個，其中 10 個在森林
  ★分解：撿現成①＝10 ／ 新建②＝0
```
⇒ ★**我改的那條（②）生效了：不再有隊被派去森林【新建】農田。**
⇒ ★★而分支①「撿現成 belief-known 的無主既有 outpost」**完全不判地形**（`:6100-6113`）——
它回傳的是**已存在的據點**，不是新農地。
★★★**那可能是合法的**（撿一座森林裡的空據點來住，未必是為了種田），
**也可能是同一個浪費**（撿完之後想蓋農田，一樣撞牆）。
⇒ **我沒有順手改**（你 §④ 說 predicate 只能一份，但沒說分支①在不在範圍內；而它的語意不同）。
★**要不要開票由你**；若要，判準是「撿現成之後的下一個動作是不是建農田」，**那需要跑 trace 不是讀 code**。

# ④ 你 §⑤ 兩個「沒查的」—— 我查了，兩個都有答案

**①`productivity` 是不是已含地形 ⇒ `× _farm_pot` 雙算？** ★**是雙算**：
```
world_generator.gd:90-91   var prod_r: Array = PRODUCTIVITY_RANGE[tile.terrain]
                           tile.productivity = rng.randf_range(prod_r[0], prod_r[1])
⇒ productivity 【逐地形】抽 ⇒ 地形資訊已經在裡面
⇒ settle_site_quality = productivity × _farm_pot ＝ 地形【進了兩次秤】
```
★★而它**不是本票造成的**（舊版乘的也是同一個 `_farm_pot`）——★**本票只是讓它更明顯**：
現在森林同時吃「productivity 範圍較低」＋「×0.4」。
⇒ ★★★**我沒有動它**（一次只動一個變因），**回報給你**：這正是 blueprint 今天在 `DELIVER_PAYOFF_NORM` 說的
「同一資訊禁進兩次秤」的另一個實例。

**②「山村特化待 spec」是什麼？** ★**不是 spec，是 backlog**：
```
known_issues.md:2319  | M | 山村採礦換糧特化經濟 | …階段3+ 經濟深度。
                        現階段 explicit 村用 `outpost.terrain` 釘可農地規避 |
```
⇒ ★**與本票不衝突**，反而同向：它自己寫著「現階段用 `outpost.terrain` 釘可農地」。

# ⑤ 順帶修了一支被別的改動打壞的閘（★不在本票，但它會擋所有人）

```
bed-kind 閘 ABORT：good_pending_bed.gd 的 blocker 指 `gather-purity-bed-as-gate`，
而你今天把那個 defer 退場了 ⇒ ★對照樣本的 token 懸空 ⇒ 陽性對照失準 ⇒ 整支閘作廢。
⇒ 修法：fixtures 自帶 defers.tsv，selftest 期間讀它、真檢查仍讀 live registry。
★★通則：【對照樣本不得依賴會變的 live registry】——
   否則「別人退場一個 token」會讓一支不相干的閘全面停擺。
```
★**我改了你的 hook**（兩行 + 一個 fixture 檔）——**因為它 ABORT，不是紅**，
★★而 ABORT 的閘不會擋住錯誤，它讓所有結果都不可讀。**若你要換做法，我照改。**

# ⑥ 誠實限

1. **單 seed 1337、2 天窗、warring_states**；`10/57`、`4 次` 都是這個窗的數。
2. ★**沒有跨樹 before/after**：BEFORE 那一跑兩次都 timeout（機器被長跑吃滿）
   ⇒ ★★我用的是**同一棵樹的分解**（撿現成 vs 新建），那能證明「②不再送森林」，
   **但不能證明「總森林靶數下降了」** —— 後者要 before 的數字，而我沒有。
3. **沒有下行為因果結論、沒送 QA**。
