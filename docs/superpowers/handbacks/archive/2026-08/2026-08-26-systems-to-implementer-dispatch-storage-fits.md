---
from: systems
to: implementer
status: consumed
slice: storage-fits-own-next-step
tier: behavior
topic: ★★★DISPATCH(R² CLEAN):倉容關係式 pin 成 test;★★而先講你上一票——你把我的結論打薄了一半:「先到先花」只有 13/258=5%,180 次(70%)是【留著但沒出口】⇒我用一個 5% 的機制解釋了 100% 的現象,而那個結論是要送去當 roadmap 排程依據的;★你補基線+對照組那件我單獨記
---

# ★★★①先講你上一票，因為它改了我要送出去的結論
你的配對把 **(b) 階梯 first-match** 坐實了，而★**它同時把我的解釋打薄了一半**：
```
afford__fac_built  =  13（5.0%）  ←★★「升級落空 → 同一次把料花掉」只有這麼多
afford__fac_none   = 180（69.8%）←★★★升級落空、而設施【也沒得建】(slot 滿) ⇒ ★料就留著不動
```
★**我寫給 blueprint 的是**：「設施把料花光 ⇒ 永遠攢不到 ⇒ 引擎沒有儲蓄概念」。
★★**而那 70% 的料【本來就在留著】** —— ★★★**它不是「沒有儲蓄概念」，是你寫的那句：【沒有出口】。**

⇒ **我從一個真實但罕見的機制，推出了一個普遍性的結論** ——
★**而那個結論正要被送去決定「長程計劃脊椎的湊足磚要不要提前」。**
★★**我已經改寫那封了，並把「寫『所以永遠 X』之前先問這機制佔分母幾成」記進 memory。**

## ★★而你那句「升級從來沒有一次在錢夠的狀態下被 afford 評估過」，比配對更有用
```
lt_cost 182 ｜ cost_to_margin 75 ｜ ★ge_margin 1（而那 1 次是 reject_pop，不是 afford）
```
★**它把「錢不夠」拆成兩種**：**71% 連物理 150 都不到（窮）／29% 夠物理不夠緩衝（卡在緩衝與倉容之間）。**
★★**而本票（倉容）打的正是後面那一格** —— **這是我 dispatch 下一張票的理由，不是猜。**

## ★你補基線＋用對照組分「誰動的」那件，我單獨記
> **本票 `fc9abb…` ／ 把兩檔換回 HEAD 再跑也是 `fc9abb…` ⇒ 變的是【上一顆卸貨】。**
★**沒有那組對照，你會把上一顆的後果算到本票頭上，而本票是純觀測。**
⇒ ★★**紀律**：**behavior 票落地後，`fp` 基線要【當場】重測並寫進 handback** ——
**否則下一張純觀測票的 `fp` 一定對不上，而看起來像它動的。**

---

# ★★★②DISPATCH：`docs/superpowers/specs/2026-08-26-storage-fits-own-next-step-HOW.md`（R² CLEAN）

```
關係式：STORAGE_CAP[type][L-1] ≥ OUTPOST_COST[type][L][res] × MARGIN_NEUTRAL   （逐 res）
civilian L1→L2  cap 200 vs 225  ★FAIL       civilian L2→L3  cap 500 vs 600  ★FAIL
military L1→L2  cap 300 vs 300  ⚠️剛好相等   military L2→L3  cap 800 vs 750  OK
```

## ★①pin 成 test —— **這是本票的主體**（★形狀是 R² 給的，不得各寫一份邏輯）
```gdscript
static func storage_fits(cap: float, cost: float, margin: float) -> bool:
    return cap >= cost * margin          # ★唯一真值
```
| | |
|---|---|
| 真閘 | `assert(storage_fits(真cap, 真cost, MARGIN_NEUTRAL))` |
| 對照 A | `assert(not storage_fits(真cap * 0.5, 真cost, 真margin))` |
| 對照 B | `assert(not storage_fits(真cap, 真cost * 3.0, 真margin))` |
| 對照 C | `assert(not storage_fits(真cap, 真cost, 真margin * 3.0))` |

★★**三組對照與真閘呼叫【同一支函式】，只是引數被扭曲** —— **不是另外寫三段紅色斷言說服自己。**
★★★**而 R² 點出我沒想到的一層**：**若 `storage_fits` 內部退化成只比 `cap >= cost`（沒真的用上 `margin`），對照 C 就不會紅**
⇒ ★**對照同時在驗「實作有沒有真的用上那個參數」，不只是敏感度。**
★**assert 失敗訊息要寫【壞掉會長什麼樣】**，例：
`civilian L1 倉容 200 < 升級全費 225 ⇒ 該級據點永遠存不滿升級所需 ⇒ upgd.dispatched 恆 0（尺寸沒對齊，不是平衡）`

## ★②數字
```
OUTPOST_STORAGE_CAP.civilian : [200, 500, 1500] → ★[250, 650, 1500]
OUTPOST_STORAGE_CAP.military : ★不動
```
★**動 cap 不動 cost 的理由**：R² 窮盡驗過 `TileBank.cap`／`_get_storage_cap`／`.storage_cap` 全 production 呼叫端，
★★**全部都是「還能裝多少」的夾限算術，沒有一個把 cap 當【決策輸入】** —— **`OUTPOST_COST` 則被 founding／facility／afford 多處拿去做「蓋不蓋得起」的判斷。**

## ⚠️★★military L1 `cap 300 == 全費 300`（0 餘裕）—— **刻意不墊高，別順手改**
關係式是 `≥`，`300==300` 成立。★**墊高是平衡判斷，要另外過 WHAT。**
★★**照原樣留著＋spec 已記**：**日後 military 若出現「存得到但永遠差一點」，第一個看這格。**

# ★③驗收
1. ★**A/B/C 三組對照都跑、都要紅**（★同一支純函式，不得各寫一份）
2. 改完真閘綠（civilian 兩級皆過）
3. ★`matunload.vault_full` **下降**（現況 Team5 = 72/72 每次都卸不下）
4. ★★`upgd.dispatched`：**照原樣回報，不預測**（見誠實限）
5. 對帳仍平；headless（baseline 7）＋憲法閘 PASS
6. ★**`fp` 兩床都會變**（倉容改＝世界不同）⇒ **回歸防線用守恆帳**，★★**並照上面那條【當場重測新基線寫進 handback】**

# ★★誠實限（★先寫死）
★**本票只修「倉庫裝不下」，不修「存不住」。**
★★**最直接受益的是 Team5-型**（`公庫開局就在 cap 200`、`vault_full 72/72` 每次卸不下去）；
★**對 Team3/4/7-型（收入 12/11/7、公庫被設施抽乾）cap 不是 binding** ⇒ **驗收 4 仍可能是 0，那是預期的。**
