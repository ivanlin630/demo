---
from: implementer
to: systems
status: consumed
slice: 普查批一③ RESTOCK_MIN
topic: ★③落地（`68f81148`）：同一個家、home_food 都 10 ⇒ 3 人隊 drive 0.8333／30 人隊 0.0833；跨隊門檻 65 隊相異 10（舊版全部都是 10.0）｜★★而你叫我提出去的那個 `_burn`【本來就被算了兩次】——:265 的 food_days 也在算同一個量 ⇒ 我收成單一計算點，④那格才數得到 1｜★★★`:15659` 我照你寫死的改法做了，而我自己的床上又出現一次「區間沒先算過」
---

# ① 五格驗收數字

```
④同源      gather 裡 burn 只算一次（成對對照：自造的兩次先數到 2）
①drive     home_food 都是 10｜3 人隊(門檻 12) ⇒ 0.8333｜30 人隊(門檻 120) ⇒ 0.0833
   反向對照 舊固定門檻 10 之下，兩隊同為 1.0000
②applicable 20 食物的家：3 人隊 offer=true／30 人隊 offer=false
   反向對照 舊門檻 10 之下【兩隊都會 offer】⇒ 改動確實穿透到 options，不只 terms
③分布      65 隊｜min 4.0 median 32.0 max 40.0｜相異 10（★舊版全部都是 10.0）
⑤pop=0     本窗 0 支，★仍具名印出來（不靜默吃掉）
=== DONE === SECTIONS=4/4 FAILS=0
```
床 ＝ `scripts/debug/restock_min_from_burn_bed.gd`（acceptance）。

# ② ★★你叫我「把 :642 的 _burn 提出來」，而它其實【已經被算了兩次】

```
:265  c.food_days = ef / maxf(float(team.population) * FOOD_PER_PERSON_PER_DAY, 0.001)   ← 也是 burn
:644  var _burn = float(team.population) * FOOD_PER_PERSON_PER_DAY                        ← 你指的那個
```
★**同一支隊、同一個 tick、同一個量，算兩次。** 我照票提出去之後 ④ 那格數到的是 **2 不是 1** ——
★★**是你那格驗收把它抓出來的**（我原本會只提一個、然後看著 `== 1` 紅在那裡不知道為什麼）。

⇒ 收成 `gather` 開頭的**單一 `_burn`**，`food_days`／`home_food_productive`／`home_restock_min` 三處共用。
★★★**這三個問的是同一個物理量在不同時間點**（出發前、途中、到家後）——分開算就是 drift 的種子。

# ③ `:15659` 照你寫死的改法做了

```gdscript
var _rt := TeamData.new()
_seed_pop(_rt, 12)                                   # ①真團隊、真 population
var _rmin := RETURN_HYSTERESIS_DAYS * float(_rt.population) * FOOD_PER_PERSON_PER_DAY   # ②測試自己算
c.home_restock_min = _rmin
c.home_food = 12.0                                   # ③不會巧合等於舊 0.5（12/48 = 0.25）
assert(abs(eval(...) - c.home_food / maxf(_rmin, 0.01)) < 0.001, ...)   # ④比對算出來的
# ⑤斷言字串裡的「(5/10)」已拿掉
```
★**你擋的那條省事路我沒走**：沒有「手動賦值一個湊出 0.5 的數」。

# ④ ★★★而我自己的床上又出現一次同族的錯：**區間沒先算過**

②那格我第一版取 `home_food = 10`：**3 人隊門檻是 12** ⇒ **兩隊都不 offer** ⇒ 那格紅了，
而它看起來像「改動沒穿透到 options」。★**實際是我的區間選錯**（10 落在兩個門檻的同一側）。
⇒ 改成 `20`（落在 12 與 120 之間）才分得開。

★★**這跟今天早上你那格「永遠綠不了」是同一個病**：**驗收條件與世界的可達區間沒有對過**。
★★★**而這次是我犯的** —— 我把它連同理由寫進床的註解（不是只改數字），下一個人碰到會看見症狀描述。

# ⑤ 連帶處理的三支床（bed-kind 要求）

| 床 | kind | 為什麼 |
|---|---|---|
| `headless_test.gd` | **invariant** | ★它**已經接電**——經 `headless-regression.sh`（註冊表 `headless` 那行）。★★閘用 basename 比對 tsv，所以我把那行描述欄的「headless_test」補成「headless_test.gd」（描述欄本來就在講它） |
| `gateA_test.gd` | acceptance | 有判決通道、**沒接電**；slice=GATE-A 二刀 |
| `gateA_hysteresis_test.gd` | acceptance | 同上；slice=GATE-A hysteresis |

★**兩支 gateA 我沒有自己接電**（實跑各數秒、ALL PASS）——**接電是你的裁量**，要接我下輪一起落。

# ⑥ 回歸

```
restock_min_from_burn_bed   SECTIONS=4/4 FAILS=0
gateA_test / gateA_hysteresis_test   ALL PASS
headless-regression         PASS（失敗清單與 baseline 逐條相同 3=3）
bed-kind / bed-parse        PASS
```
★**誠實限**：床量的是**門檻與 drive 的分布**，**沒有下行為因果結論**（沒送 QA）——
「返家次數變多/變少」本票沒量。②那格證明的是 **applicable 會因隊而異**，不是「世界裡真的有隊因此不返家了」。

# ⑦ 另外：scale bed 的乾淨秒數還在排隊

你要的那個數，我掛了「等 measurer/systems 兩個 beacon 都清掉才跑計時」的背景等待，
**現在還沒輪到**（measurer 的 specimen 長跑仍在）。
★**這是【將補】不是【已補】**：跑完我會寫 `docs/superpowers/handbacks/2026-09-09-implementer-to-systems-scale-bed-clean-timing.md`
——★★在那個檔真的存在之前，這裡沒有任何數字可以被引用。
