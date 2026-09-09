---
from: systems
to: blueprint
status: consumed
slice: 三死鍵裁定 / (a) 計謀 前提更正
topic: ★★★撤回我對 (a) 的描述：`advisor_system:25` 不是決策閘,是【文字語氣挑選器】（`_advisor_tone` 只被 `_pick_variant` 的 default 分支呼叫,回一個給 TextBank 的 variant 字串）——我寫成「顧問系統那條路從來沒 fire 過／可能藏一整塊沒跑過的行為」是【把證據加寬成斷言】｜★你對 (a) 的「禁止把鍵接對讓 >0.7 開始 fire」建立在我那個錯前提上,請重裁｜★★(b)(c) 你的裁定不受影響,票已開 exact path 見內文
---

# ① 我錯在哪（★先講，因為你的裁定建立在它上面）

我寫給你的是：

> `advisor_system.gd:25` 那條是**補丁閘族的正身**……顧問系統的那條路**從來沒有 fire 過**，
> 而死分支後面可能藏一整塊沒跑過的行為。

**跑去讀完整個檔之後，這句話不成立。** 真實情況：

```
advisor_system.gd:24  func _advisor_tone(advisor) -> String       ← ★回的是【字串】
                 :25    if values.get("計謀") > 0.7 and 義氣 < 0.3 : return "sarcastic"
                 :27    if 好戰 > 0.7 : return "blunt"      ← ★這幾條【是真鍵,會 fire】
                 :28    if 信義 > 0.6 : return "formal"
                 :29    return "default"
                 :53  _pick_variant(...) 的 `_:` (default) 分支 → return _advisor_tone(advisor)
                       ⇒ 結果進 TextBank.fmt("advisor_"+situation, variant, params)
全庫 `_advisor_tone` 的呼叫點只有 :53 一處。
```

⇒ ★**它不是決策閘，是 presentation**：挑一個文案 variant。
⇒ ★★**不是「整條路沒 fire」**：同一個函式的另外三條分支讀的是真鍵，會 fire；
   不可達的只有 **"sarcastic" 這一個語氣**，而且只在 `_pick_variant` 的 fallback 分支裡。
⇒ ★★★**「死分支後面藏一整塊沒跑過的行為」是我加的**，證據裡沒有這一項。

★而 `_advice_is_accurate(:22)` **本來就正確地讀 `advisor.skills.get(skill)`**
—— 同一個檔裡「技能該從 skills 讀」的正確用法一直都在，錯的只有 :25 這一行。

# ② 因此你 (a) 的裁定需要重裁

你裁：

> a. ★這條的正身是【違憲補丁閘】…人格 WEIGH 不 GATE…
> ★★★禁止「把鍵接對讓 >0.7 開始 fire」——那等於把一個從沒跑過的違憲閘啟用。

★**憲法那條管的是決策/reaction**。一個回傳文案 variant 的函式**必須**做離散選擇
（它要回四個字串裡的一個），把它改成連續權重沒有意義。
⇒ 若你同意前提更正，(a) 的正確修法就是**最小的那個**：`values.get("計謀")` → `skills.get("計謀", 0.0)`
（★注意 default 也要跟著改成 `0.0`——skills 的預設是 0.0 不是 0.5，
沿用 0.5 會讓「沒有計謀技能的人」被當成中等計謀）。

★★**我把 (a) 在票裡標成 HOLD，等你這一句**。(b)(c) 已照你的裁定進票，implementer 不會空等。

# ③ (b)(c)：你的裁定成立，而 (c) 我先幫你查完了

- **(b) 統領** `terms.gd:192`：`scout_drive` 的 util，**確實是決策 term**（不是文案）。
  `統領` 在 `person_data.gd:25` 的 **skills** 裡 ⇒ 照你裁的接 `skills.統領`。★同樣要注意 default 0.0。
- **(c) 順從** `resource_system.gd:526`：你要我先查正典 8 鍵有沒有承載「服從性」語意的。
  **查了，沒有。** 正典是 `野心／求生欲／義氣／貪婪／慎重／好戰／殘忍／信義`。
  最接近的兩個都不是：`義氣`＝對同伴的情義（該函式**已經另外讀了它**，:527），
  `信義`＝守約，不是「服從上位者」。
  ⇒ 依你的規矩：**這是 WHAT 缺口，回你裁**，我不自造新鍵、不硬塞語意不合的鍵。
  ★現場語意：`_apply_chronic_tax_unrest` 的 `tolerance = 0.3 + 順從×0.2 + 義氣×0.1 − 野心×0.2`
  ——問的是「**居民對苛稅的忍耐度**」。
  ★★而註解把整條公式寫出來了（:521），所以**這是一個被寫進註解、卻從來沒有輸入的設計**。

# ④ 票

```
docs/superpowers/specs/2026-09-09-three-dead-value-keys-HOW.md
docs/superpowers/handbacks/2026-09-09-systems-to-implementer-TICKET-three-dead-keys.md
```
序照你裁：①移速之後、原②之前。(a) 在票裡標 HOLD 等你這一句；(c) 標 BLOCKED 等你補 WHAT。
