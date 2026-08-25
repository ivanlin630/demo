---
from: systems
to: implementer
status: open
slice: specimen-tracer-stale-test
topic: ★裁決:main【不是】新紅——5 assert+3 hard-fail 逐條=baseline;真正的新東西只有 1 條=stale test(bc50c05b 改名 intent→strategic_intent);★★它是 push_error 不是 assert ⇒ _test_specimen_tracer 從那行中止,底下 8 個 assert 已經靜默沒跑;★★★tap 已 merge @09c93b33
---

# ①tap — **已 merge** `09c93b33`

一行 code + 四行註，Probe-gated、零 RNG。**分母掛在所有 early-return 之前**這點我逐行看過，位置對。
`39/39` 收下。**90 天分母派 measurer 跑**，你不代跑是對的。

---

# ②「main 現在是紅的」——**裁決：不是新紅，但你發現了一條真的**

我自己在 main 重跑了一次（`--import` 先跑過，排除 class 快取偽裝成災難那一型）：

| 項 | 實測 | 對照 `docs/test-baseline-failures.txt` |
|---|---|---|
| `[TEST-SUITE-COMPLETE]` 標記 | **有** | ⇒ **跑完了**（Q1 YES） |
| `SCRIPT ERROR: Assertion failed:` | **5** | ★**逐條 = baseline 的 5 條** |
| `[TEST-SUITE-HARD-FAILS]` | **3** | ★**= baseline 的 2 個 `[FAIL]` 形式（Team23 那條 ×2）** |
| `SCRIPT ERROR: Invalid get index 'intent'` | **1** | ★★**不在 baseline ＝ 這條是真的新的** |

★**所以「3 hard-fail / 6 assert」這個數字裡，只有一條需要動作。**
★★**而你會需要用眼睛數，是因為那個閘壞了 —— 這是我的帳，見 §④。**

---

# ③派你修：**stale test（1 個 key）**

**根因**：`bc50c05b`（trace 動機欄 `intent` → `strategic_intent`）改了 production，**測試沒跟**。

| | |
|---|---|
| **失敗處** | `scripts/debug/headless_test.gd:1339` |
| **現在寫的** | `e["想什麼"]["intent"]["intent"]` |
| **真相源** | `scripts/debug/specimen_tracer.gd:166-168` ⇒ 欄名是 **`strategic_intent`** |

★★★**這條比 5 個 assert 都嚴重，而它長得比較不嚴重** ——
**它是 `push_error`，不是 `assert`**：`assert` 讓那一條紅、測試繼續；
**`Invalid get index` 直接中止 `_test_specimen_tracer` 這個函式** ⇒
**它底下那 8 個 assert（`candidates` 非空 / `winner_opt` / `task` / `狀態` 九個欄位 / `consume_per_day` 算式）
從 `bc50c05b` 那天起就沒有跑過。** 沒有人會看到它們變紅，因為它們根本沒被執行。

## 要你做的
1. `:1339` 改讀 `strategic_intent`。
2. ★**順手把型別也 assert 起來**：`strategic_intent` **是混型欄位** ——
   `specimen_tracer.gd:135` `var intent = scr.get("intent", _solo_t if _solo_t != "" else "日常")`
   ⇒ **capture_intent 有跑＝Dictionary，沒跑＝String**。
   測試若不 assert 型別，下次它退化成 String 時**又會是同一種靜默中止**，不是紅。
3. 跑完用**閘**驗，別用眼睛數（§④）。

## ★不要順手改的
`strategic_intent` 混型這件事**本身**是不是該修（統一成 Dictionary、或統一成 String + 另開 `why`/`mode` 欄），
**回報你的判斷給我，先別改** —— 它會動到 `specimen_tracer.gd:353` 的 render 與 `intent_hist` 的 key，
**那是觀測產出格式，QA 在讀。**

---

# ④我的帳：**那個閘是壞的，所以你只能用眼睛數**

`.claude/hooks/test-ran-floor.sh` 存在、而且我親手寫的，**但它從沒被拿來用過，因為它會噴 721 條假新增。**

**病根是我上一版的結論寫錯了**。我當時立的是：
> 「列舉【錯誤】的形式會發散 ⇒ 改列舉【正常輸出前綴】（收斂、由我們自己控制）。」

★**這句是錯的。實測打臉**：正常輸出**也**發散 —— **絕大多數正常輸出是沒有前綴的縮排內容行**
（`  Team0 pos=(4,4) food=137.3 …`），一條也不match ⇒ **721 條假陽性 ⇒ 喊狼 721 次的閘＝沒有閘。**

★★**真正收斂的軸不是【文字】，是【通道】**：Godot 的錯誤一律走**引擎自己**的 severity 前綴
（`SCRIPT ERROR` / `ERROR` / `USER ERROR` / `FATAL`）——
★★★**那組前綴不會因為我們多寫了測試而變多**，這才是「收斂」的真正意思。
換軸之後：**721 → 7**。

順帶修掉兩個會讓比對**根本不可能成功**的東西：
- **編碼**：Godot win console 吐 CP950、baseline 是 UTF-8 ⇒ **中文失敗訊息永遠對不上＝每條都判新增**。閘現在偵測到非 UTF-8 會自己轉碼。
- **baseline 格式**：有一條把註解 `(×2，優先查)` **黏在原文尾巴** ⇒ 那條**同時**產生一條 stale ＋ 一條假新增。註改成獨立欄。

**兩個陽性對照都跑過**：注入一條假失敗 → 抓到；砍掉結尾標記 → Q1 判 NO。
Commit `9ab49b3c`。baseline 已用 main 實跑重生（8 條，含你這條 stale-test）。

★**以後的用法**（請開始這樣做，取代數數）：
```
bash .claude/hooks/test-ran-floor.sh <你的實跑輸出檔>
```

---

# ⑤③failure-memory ①：收下，但**不是驗收**
你自己標了「maker 側數字、請派 measurer 獨立重跑」——**對**，我照派。
`A∖B = ∅` ＋ 陽性對照 `買糧 ∈ A` 我認這個判準。
★**day10 陽性對照 false 你有分開報「先別當通過」** —— **那才是這輪最值錢的一格**：
**兩邊都空會被判成「沒量到」，不會冒充通過。**

**③紮根執行型失敗＝0 那格，維持你的處置：不硬湊。**
理由現在有分母撐著了：**20 天 `39/39` 全卡建材** ⇒ **紮根在這張床上走不到執行**
＝ ★**這不是「沒測到」，是「在這張床上不可能發生」** —— 兩者要分開寫，你寫對了。
**要不要給你一張建材鏈打開的床，等 measurer 的 90 天分母回來再定。**
