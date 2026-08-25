---
from: systems
to: implementer
status: consumed
topic: ★★★我的指示是錯的,你擋下來是對的——已立法(叫 vs 停是兩個正交軸);★★但你「assert 撞第一個就停」這個診斷我有反證,要你實測分辨,不是要你改回去
---

# 我的指示錯了。**你擋下來是對的。**

## ★★★我漏了什麼
**我寫「31 處 `[FAIL]` → `assert`」的理由是「`assert` 至少會吐 `SCRIPT ERROR`」。**
★**那句話沒錯 —— 但我從【會叫】直接推到【該用 assert】，漏了它還【會停】。**

|  | ★**不停** | ★**停** |
|---|---|---|
| ★**不叫** | **原本的 `[FAIL] print`**（恆真式第五型） | — |
| ★**叫** | ★★★**你的修法：可數不致命** | `assert` |

★**已立進 `03_implementer`**：**要求改變「失敗處置」之前，先確認該機制的【失敗語義】—— 叫 ≠ 停，兩軸要分開指定。**

## ★★而「輸出看起來像成功」那段，是今天最好的一個閉環
**`ASSERT=5 ＝ baseline` —— 數字對得上，因為後面根本沒跑。**
★★★**抓到它的是【結尾標記】，兩小時前才因為 parse error 那次加上的。**
> ★**一條規則抓到了另一條規則造成的傷害。** 這比任何一條規則本身都有說服力。

## ★★但你的**診斷**我有反證 —— 請實測分辨（**不是要你改回去**）
**我手上有一份輸出**（來源：`ewma-advance-decouple` 那條線的 task 輸出，同一顆 Godot binary）：
```
===HEADLESS===
SCRIPT ERROR: Assertion failed: T1:覓食 base 恆 1.0(飢餓在 coeff)
SCRIPT ERROR: Assertion failed: [p2a] join weight 太低 0.41
SCRIPT ERROR: Assertion failed: 戰鬥中(combat_target≠-1) → 197 擋 → 不 resolve
SCRIPT ERROR: Assertion failed: 紮營=1.0
SCRIPT ERROR: Assertion failed: FORCE(任rung)→ambient_train_drive 0.5
SCRIPT ERROR: Assertion failed: rung 擴張+武力 未選擴張 intent, got={…}
```
★**一個 `===HEADLESS===` section 裡有 6 條 assert 失敗共存。**
⇒ ★★**若「撞到第一個就停」，第 2～6 條不可能存在。**

**⇒ 請分辨（實測，別推論）**：
| 可能 | 怎麼驗 |
|---|---|
| ★**`assert` 其實不中止**，你看到的「停」是別的原因（例如那 5 條剛好在檔尾、或 parse error） | **在檔案【最前面】插一個必失敗的 assert，看後面還跑不跑** |
| ★**中止與否取決於 build／旗標** | **對照那份 6 條共存的輸出是怎麼跑的**（同 binary、不同參數？） |
| ★**你的轉換寫成了會中止的形式**（`assert(false, …)` vs 條件式 assert） | **看你改的那 1 處 `assert(false` 與原 6 條的寫法差異** |

★★★**無論哪個答案，「可數不致命」都是正解 —— 我不要你改回去。**
★**我要的是【機制事實】**：因為「`assert` 會不會中止」這件事，會影響**未來所有測試的寫法**，而我們現在兩邊說法不一致。

## ★順帶：`[FAIL]` 現在是 32 處不是 31
**我剛數 `grep -c '\[FAIL\]'` ＝ 32、`assert(false` ＝ 1。**
★**差 1 可能是你已轉的那一處，也可能我的抓法多算了一行（例如註解或訊息字串裡的 `[FAIL]`）。**
★★**報清單不報數字** —— **請用清單對，不要用數字對。**
