# 據點裝得下自己的下一步：關係式 pin（HOW）

`from: systems`｜`tier: behavior`｜**WHAT**：blueprint 裁定 2026-08-26 ——
★**結構約束：「每級據點的儲量上限 ≥ 該級自身的升級全費（含緩衝）」。**
★★**pin 的是【關係】不是常數**（改任一邊就紅）；**具體數字歸 HOW。禁只把 200 拍成 230 完事。**

## ★病（★算出來的，不是舉例）
```
關係式： STORAGE_CAP[type][L-1]  ≥  OUTPOST_COST[type][L][res] × MARGIN_NEUTRAL   （逐 res）

civilian L1→L2： cap 200  vs  need material 225      ★FAIL（缺 25）
civilian L2→L3： cap 500  vs  need material 600      ★FAIL（缺 100）
military L1→L2： cap 300  vs  need material 300      ⚠️ OK 但【剛好相等】
military L2→L3： cap 800  vs  need material 750      OK
```
⇒ ★★**civilian 兩級都不成立 ⇒ 一個 civilian 據點【裝不下自己的下一步】⇒ 升級結構性不可能。**
★**活證＝Team5**：`公庫開局就在 cap 200`、`matunload.vault_full = 72`（**每一次都卸不下去**）。

## 修法
### ①**pin 成 test**（★這是本票的主體，不是附屬）
在 headless 加一段**逐 type、逐 level、逐 res** 檢查上面那條關係式的 assert。
★**失敗訊息要寫【壞掉會長什麼樣】，不是「請勿修改」**：
> 例：`civilian L1 倉容 200 < 升級全費 225 ⇒ 該級據點永遠存不滿升級所需 ⇒ upgd.dispatched 恆 0（不是平衡問題，是尺寸沒對齊）`

### ★★★寫法（R² 給的形狀，2026-08-26 —— ★不得各寫一份邏輯）
```gdscript
# ★唯一真值：真閘與三組陽性對照【都呼叫這一支】，不得各寫一份
static func storage_fits(cap: float, cost: float, margin: float) -> bool:
    return cap >= cost * margin
```
| | |
|---|---|
| **真閘** | `assert(storage_fits(真cap, 真cost, MARGIN_NEUTRAL))` —— **讀真常數** |
| **對照 A（cap 敏感？）** | `assert(not storage_fits(真cap * 0.5, 真cost, 真margin))` |
| **對照 B（cost 敏感？）** | `assert(not storage_fits(真cap, 真cost * 3.0, 真margin))` |
| **對照 C（margin 敏感？）** | `assert(not storage_fits(真cap, 真cost, 真margin * 3.0))` |

★★**「不是自我證明」的關鍵**：**三組對照與真閘呼叫【同一支函式】，只是餵扭曲的引數**
—— ★**不是另外寫三段紅色斷言去說服自己，是【同一份判斷邏輯】在三種扭曲輸入下必須翻臉。**
★★★**而它可證偽**：**若 `storage_fits` 內部退化成只比 `cap >= cost`（沒真的用上 `margin`），對照 C 就不會紅** —— **對照抓得到它。**

★★**它必須對【三邊】敏感**：改 `OUTPOST_STORAGE_CAP`、改 `OUTPOST_COST`、改 `MARGIN_NEUTRAL` **任一個**都要能紅。
★★★**這正是四常數那顆的做法**——**pin 關係，不 pin 數字。**

### ②數字（★HOW 的判斷，理由寫在這裡供推翻）
```
OUTPOST_STORAGE_CAP.civilian : [200, 500, 1500] → ★[250, 650, 1500]
OUTPOST_STORAGE_CAP.military : 不動
```
★**動 cap 不動 cost 的理由**：`OUTPOST_COST` 是**價格階梯**，全域經濟都在讀它（founding／facility／afford 判斷）；
**倉容只被「裝得下多少」讀** ⇒ ★★**動它的爆炸半徑小得多。**
★**250 / 650 怎麼來**：**225 / 600 各留約 10% 週轉餘裕** ——
★★**若餘裕剛好是 0，據點在存夠升級費的那一刻【連一粒日常產出都收不下】。**

### ⚠️★★★而 military L1 現在【正好是 0 餘裕】（cap 300 == 全費 300）—— **我不偷偷墊高它**
★**這一格會通過 assert（`≥` 成立），但它是本票量出來的一個真實緊繃。**
⇒ ★★**照原樣留著並記在這裡**：**若日後 military 出現「存得到但永遠差一點」的症狀，第一個看這格。**
★★★**我沒有把它一起改掉，因為 blueprint 給的關係式是 `≥`，而把它墊高是我自己加的平衡判斷 —— 那要另外過 WHAT。**

## 驗收
1. ★**assert 存在且【對三邊都敏感】**：★★**照上面那個「同一支純函式＋三組扭曲引數」的形狀**（★**不得各寫一份邏輯**）—— **A/B/C 三組都要跑、都要紅**
2. **改完 assert 綠**（civilian 兩級皆過）
3. ★**`matunload.vault_full` 下降**（現況 Team5 = 72/72 每次都卸不下）
4. ★**`upgd.dispatched`**：★★**照原樣回報，不預測** —— **本票只解「裝不下」，不解「存不住」**（見誠實限）
5. **對帳仍平**；headless（baseline 7）＋憲法閘 PASS
6. ★**`fp` 兩張床都會變**（倉容改＝世界不同）⇒ **回歸防線用守恆帳，不是逐位元**

## ★★★誠實限（★先寫死，免得驗收 4 又被當成失敗）
★**本票只修「倉庫裝不下」，【不修】「存不住」。**
**實測 Team3 的公庫曾到 200、再被設施施工花到 143** ⇒ ★★**即使 cap 變 250，設施照樣會把它花掉。**
⇒ ★★★**「為了更貴的目標而現在不花」＝ blueprint 已裁定歸【長程計劃脊椎的湊足磚】，不在本票。**
★**所以驗收 4 若仍為 0，那是【預期的】，不是本票失敗** —— **而它正好是脊椎排程的輸入。**
