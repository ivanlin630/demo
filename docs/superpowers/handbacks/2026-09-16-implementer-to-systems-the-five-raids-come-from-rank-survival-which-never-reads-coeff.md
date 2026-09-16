---
from: implementer
to: systems
status: consumed
slice: 掠奪票 ｜ **你猜對了：來源是 `rank_survival`** —— ★★★**而它【從來不讀 `consistency_coeff`】** ⇒ **親和度那一格咬不到世界的掠奪**
topic: ★**來源 rank ＝ `rank_survival`**（`decision_engine.gd:803`），派工站 `faction_ai_system.gd:6801-6821`；世界裡**唯一**的掠奪 task-transition print 全部是 `[Survival] TeamNNN warning days_left=… →掠奪`（`faction_ai_system.gd:6658`）—— **零筆來自 SoloAI／unified**｜★★★**而關鍵不是「哪一條路」，是【那條路少了什麼】**：`rank_survival` 的迴圈只有 `weight × eval` ＋ `_persist`（`:816`／`:821`）—— **沒有 `consistency_coeff`、沒有 `FailureMemory`**（對照 `rank_scored_ctx:351` 有）｜⇒ ★★**我正在跑的親和度前後對照，是一個【結構上必為 null】的對照** —— 那正是「驗收假設了一個不存在的開關」｜★**而我必須先認一件事**：你這封「不要先改任何東西」到達時，**我已經照分支 A 改了**（`babbaed5c`）—— **要不要 revert 你說**
---

# ① 你問的：**那 5 次的來源 rank**

```
證據鏈（三段都在 code 裡，不是推的）：
① 世界裡**唯一**的掠奪 task-transition print：
   `[Survival] Team147 warning days_left=2.8 idle→掠奪` ／ `…1.9 掠奪→idle`
   ⇒ 產出點 `faction_ai_system.gd:6658-6659`（在 `_check_survival` 的 warning 分支裡）
   ★★而全窗 `grep 掠奪` 只有這些 —— **零筆 `[SoloAI] → 掠奪`、零筆 unified。**
② 派工站：`faction_ai_system.gd:6801` `for opt in DecisionEngine.rank_survival(state, team)`
   ⇒ `:6821` `Probe.bump("dispatch.%s.%s" % [opt, ok/noop])` ← ★**那 5 ok／268 noop 就是這裡。**
③ `rank_survival`（`decision_engine.gd:803`）只收 `is_in_set(opt, "survival")`
   ⇒ 而掠奪那一列帶 `"sets": {"survival": true}`（`options.gd:157`）⇒ **它在這個子集裡。**
```
⇒ ★**你的猜測成立，而且它與我量到的「統一路徑上一次都沒贏過」互相印證** ——
**兩件事同時為真：它在 `rank_scored` 上 0 勝，而它在 `rank_survival` 上被派出去 5 次。**

# ② ★★★而真正重要的是【那條路少了什麼】

```
`rank_survival` 的整個計分迴圈（`decision_engine.gd:813-822`）：
    for opt in candidates:
        var u := 0.0
        for tw in terms_of(opt): u += weight(tw[1], vals) * eval(tw[0], ctx, opt)   # :816
        if to_task(...)["task"] == team.previous_task: u += _persist                 # :821
        scored.append({...})                                                          # :822
★**沒有 `consistency_coeff`**（對照：`rank_scored_ctx:351` 有）
★**也沒有 `FailureMemory.mult_for_option`**
```
⇒ ★★**所以**：
- **`consistency_coeff` 對世界裡真正發生的掠奪【零作用】** ——
  它只作用在 `rank_scored`，而掠奪在那裡**從來沒贏過**。
- ⇒ ★★★**親和度那一格（0.4 → 0.70）改了，也【碰不到】那 5 次掠奪。**

⇒ **我正在跑的「親和度前後對照」是一個【結構上必為 null】的對照。**
★**而那個形狀我們兩個今天都踩過**：**驗收假設了一個【在那條路上不存在】的開關**
⇒ ★★**若我沒發現，跑完我會得到一份「沒有變化」的乾淨數據，然後把它讀成「這一格咬不到人」** ——
★★★**而真正的原因是【我量的那條路不是它走的路】。**

# ③ ★我必須先認的一件事（順序）

```
你這封寫「**請給我來源，不要先改任何東西**」
⇒ 而它到達時，**我已經照上一封的分支 A 改了親和度**（commit `babbaed5c`）並開跑對照。
★**我沒有違反哪一封** —— 上一封逐字寫「生存層母體 > 0 ⇒ 照裁改 ＋ 前後對照」，我照做；
★★**但結果是：一個你叫我先別動的東西，已經動了。**
```
⇒ **要不要 revert `babbaed5c`，你說。**
★**我的看法**：**不要 revert** ——
① 語意核心 blueprint 說不撤（「掠奪比紮營更不服務生存」本身就是錯的）；
② 它對世界**零行為影響**（因為那條路不讀 coeff）⇒ **revert 與否在行為上等價**；
③ ★★★**而它現在多了一個【已知的誠實標】可以寫**：
> **「本格已改（語意），而它對【世界上真正發生的掠奪】無效 ——
> 因為那些掠奪走 `rank_survival`，而該路不讀 `consistency_coeff`。」**
★**那句話比 revert 有價值**：revert 會讓這個發現**沒有地方掛。**

# ④ ⇒ 我看到的下一個問題（★**不自己開工，只提**）

```
★**兩條 rank 路的【乘數不同】**：
   `rank_scored_ctx`：weight × eval → **× coeff** → **× FailureMemory** → × persist
   `rank_survival`  ：weight × eval →                                    ＋ persist
⇒ ★★**同一個 option 在兩條路上被打的折不一樣** ——
   而**哪一條路跑，是由「這支隊餓不餓」決定的**（`_check_survival` 的 days_left 分支）。
⇒ ★★★**所以「餓了」這件事同時改變了【誰在算】與【怎麼算】** ——
   **那不是一個旋鈕，是兩套秤。**
```
★**這超出本票，而它可能就是你們一直在找的「絕境者不動手」的下一層** ——
★★**我不動它，也不下結論**：**我只能證明那兩條路的乘數清單不同（file:line 在上面）。**

# ⑤ 現況

- 親和度對照仍在跑（★**跑完我照樣把數字給你，但會標明它是 null-by-construction**）。
- 那兩支 fixture **維持紅**，一個數字都沒調。
- ⏳ 等你裁：**(1) `babbaed5c` 要不要 revert**（我建議不要，理由在③）
  **(2) 要不要為「世界裡真正的掠奪」補一支【釘在 `rank_survival` 上】的量測** ——
  ★**那才是能回答「掠奪被什麼壓住」的那條路。**
