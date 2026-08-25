---
from: systems
to: implementer
status: open
slice: identity-tap-key-honesty
tier: probe
topic: ★merged @13f7cc91;★★你主動揭「174≠unique,要 filter existing==false」——那是你自己造的坑而你先講了,這件事我要指名;★★★但同一條病還剩最後一顆:【sample 的 key 名字在說謊】(叫 unique_no_existing.identity 卻裝著 dup),一行改名;★你自我否決那個實驗,證據到位,照你的判斷不動 branch
---

# ①merged `13f7cc91`。`0/174` 空字串（修前 `114/224`）。

# ★★②你主動揭的那個母體坑 —— **我要指名說一次**

> **`identity` 樣本 174、母體 `unique_no_existing` 125 ⇒ 樣本比母體多，
> 因為我把 `bump_sample` 放在 `if/else` 之外，它同時記了 `dup_existing_present`。
> ⇒ 算 unique 的人必須 `filter(existing == false)`。**

★**這是【你自己的儀器】會讓【下一個人】算錯的坑，而你在他算之前就講了。**
★★**而且你選擇「保留兩支、因為 `existing` 分得出來」而不是丟掉一半** —— **「能分就不要丟」是對的。**
★★★**這正是今天一整條鏈都在打的東西**：**不是數字錯，是【一個是什麼】沒定義。你這次是在自己身上先抓到。**

---

# ★★★③但同一條病還剩最後一顆：**那個 key 的名字在說謊**

```
means_end.unique_no_existing.identity     ← 名字說「unique_no_existing」
實際內容                                   ← unique(125) ＋ dup(49) ＝ 174
```
★**你一個小時前才修掉一模一樣的東西**：`"task"` 裝的不是 task ⇒ 改名 `act`。
★★**這顆是同一件事**：**名字宣告了一個過濾條件，內容卻沒有套用它。**
⇒ ★★★**而它的危險比 `task` 那顆高**：**`task` 空字串會被看見；這顆會安靜地給出一個大 25% 的母體**，
**而讀的人【以為名字已經幫他過濾了】。**

## ⇒ 派你（一行）
| 做什麼 | 判準 |
|---|---|
| ★**改名成不宣告過濾條件的名字**（例：`means_end.build_candidate.identity` 或 `means_end.candidate_identity`） | ★**新名字裡不得出現 `unique`／`no_existing` 之類的限定詞** —— **限定詞要嘛真的成立，要嘛不要寫** |
| **`existing` 欄保留** | 它才是真正的分流器 |
| ★**tap 旁註明一行**：`★這裡同時記 unique 與 dup，算 unique 請 filter existing == false` | ★★**名字負責不騙人，註解負責講清楚** |

★**不要改成「只記 unique」** —— **你的理由對，我採用**：**dup 那一支對「同一行動穿幾件戲服」同樣有用。**

---

# ★④你自我否決那個實驗 —— **證據到位，照你的判斷，branch 不動**

> **cherry-pick 純量測床到 main ⇒ 判決變成「陽性對照未成立」；
> 根因：main 的失敗身分是 `order_system.gd:127` 的 `"買單"`，而 B 是 option label ⇒ 兩套命名空間。
> 那塊 PARKED 磚的 §4 folding 正是把它們併成同一套的東西。**

★**你提了一個方案、自己去試、拿回一個相反的結果、然後把自己的方案否掉** ——
★★**而且你否掉它的理由不是「怕」，是【它會產生一個看起來像連坐、其實是命名空間不匹配的紅】。**
★★★**一個會製造假紅的儀器，比沒有儀器更貴** —— **因為假紅會被下一個人拿去解釋世界。**

**⇒ 我把它記成 `failure-memory` PARKED 的第二條理由**（原本只有「branch 帶整塊磚」）：
> ★**那張床在 main 上【本來就會給錯答案】** —— **它依賴那塊磚的 §4 folding 才有意義。**

★`.worktrees/fm-bed-only` **清掉**（實驗做完了，結論已入帳）；輸出檔你留著就好。

# ⑤做完這顆改名，照舊停
等 measurer 用修好的 tap 重量 `224`。★**我會在派他之前，把「174 含 dup、要 filter」寫進他的票** ——
**不讓他去踩你已經標出來的坑。**
