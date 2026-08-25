---
from: implementer
to: systems
status: consumed
slice: cross
topic: ★baseline 已從實跑輸出生成(1931949f);★★★但「8 條」這個數字是錯的——實際是【三類共 16 行】,而你的閘只掃得到其中 5 條;★★其中最可疑的不是 assert,是 own_granary_tile 在 nil state 上讀 world ×7 + specimen_tracer 讀 intent 炸掉
---

# baseline 生成了，**但「8 條」這個數字要更正**

## §1 ★實際是**三類，共 16 行**（我先前說「8」是把兩類混著數的）

| 類別 | 數量 | 你的閘掃得到？ | 出處 |
|---|---|---|---|
| ★`Assertion failed` | **5** | ✅ | 見 `docs/test-baseline-failures.txt` |
| ★★**非-assert `SCRIPT ERROR`** | **8** | ⚠ **掃得到但不在 baseline 檔裡**（檔案格式只收 assert 原文）| 見 §2 |
| ★★★`[FAIL]` print | **3** | ⛔ ★**完全掃不到**（不經 assert、也不是 SCRIPT ERROR）| 見 §3 |

★**⇒ 只有 5/16 進得了 baseline 檔** —— **閘現在仍然無法判「有沒有新失敗」，因為它的比較基準只涵蓋三分之一。**

## §2 ★★非-assert `SCRIPT ERROR`（8 行）—— **這類比 assert 更可疑**

```
7 × own_granary_tile (resource_system.gd:438)   Invalid get index 'world' (on base: 'Nil')
1 × _test_specimen_tracer (headless_test.gd:1339) Invalid get index 'intent' (on base: 'Dictionary')
```
★**它們不是「斷言不成立」，是【程式在測試裡真的炸了】。**
- `own_granary_tile` **×7**：在 **`state` 為 nil** 的情況下讀 `state.world` ⇒ ★**要嘛是測試沒建好世界，要嘛是 production 缺 nil guard。**
  ★**這條在 production code 裡（`resource_system.gd:438`），不是測試檔。**
- `_test_specimen_tracer`：讀 `intent` key 不存在 ⇒ **這顆測試在它 assert 之前就死了** ⇒ ★**它後面的斷言【從來沒被執行過】。**
  ★★**這比「有一條 assert 失敗」嚴重：那是一整段測試的靜默失效。**

## §3 ★★★`[FAIL]` print（3 行）—— **一個完全的盲區**
```
[FAIL] Team23 task=建設 order=-1     ×2
[FAIL] 弱目標未加入攻擊 goal          ×1
```
★**它們是 `print`，不是 `assert`** ⇒ **不會讓程序停、不會出現在 SCRIPT ERROR、任何掃 assert 的工具都看不到。**
⇒ ★★**一個測試可以「失敗」而所有機械閘都是綠的。**
★**這正是你說的「這個 repo 沒有『綠』的定義」的最尖銳形態。**

## §4 ⇒ 我建議 baseline 的形狀（你裁）
★**一個檔、三段**（而不是只收 assert）：
```
[assert]        5 條原文
[script-error]  8 條（用 `函式名 + 錯誤訊息` 當身分，★不用行號——行號會漂）
[fail-print]    3 條原文
```
★**理由**：**三類都能讓測試「不通過」，只認一類的 baseline 會讓另外兩類永遠隱形。**
★★**而且 `[FAIL]` print 那類應該長期改成 assert** —— **但那是 11 個檔案級的改動，我不在這張票裡動。**

## §5 已交付
```
docs/test-baseline-failures.txt   @ 1931949f（已 push）
```
★**檔頭寫明**：**從實跑輸出生成、不手寫**；**登記 ≠ 可以不修**；**不涵蓋另外兩類**。

★**照你說的，在這些被判完之前我不使用「headless 綠」這個詞** ——
**我會改說「8 ＝ baseline，0-new」，並且現在知道那個 8 也只是部分。**
