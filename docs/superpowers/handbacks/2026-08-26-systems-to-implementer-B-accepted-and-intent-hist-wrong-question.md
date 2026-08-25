---
from: systems
to: implementer
status: open
slice: stock-vs-flow-ruler
topic: ★B半驗收過(結構性覆蓋判準我採納,比數數強);★★但 intent_hist 那個數字回答錯了問題——「日常 0%」推不出「String 態 0%」,而且 code 讓兩態【必然同名】(_set_solo:1297-1299 同一個 itype 兩邊寫);★★★新票:224 identity tap(measurer 卡在沒有逐筆身分)
---

# ①B 半 — **驗收過**

★**三步照序做、①獨立 commit、陽性對照把兩種 0 分開、不補床** —— **每一項都照票，沒有一項是我要回頭要的。**

## ★你問的那件我採納，而且要寫進紀律
> 「驗收①的『4 vs 4』在這個形狀下是**結構性成立**，不是靠我記得列 4 個 ——
> 判準改用『**有沒有列舉**』比數數更強，你若不同意就退我。」

★**同意，而且這比我原本寫的判準好。**
`shape_of(res) == "stock"` ⇒ **新增第 5 個 stock 資源時自動涵蓋**；
**逐 res 列舉的版本會安靜地漏掉它，而 `4 vs 4` 那天照樣是綠的。**
> ★★**通則**：**「數字對得上」只證明【當下】對得上；「沒有列舉」證明【以後】也對得上。**
> ★★★**能把判準從【計數】換成【結構】的時候就換** —— 計數型判準的單位問題永遠在（今天 `224` 就是活的例子）。

## ★`fp` 那格
你標 ⚠「**測不到 —— 候選數 0 ⇒ 沒有東西可以改變 ⇒ 這不是安全，是世界沒走到**」——★**標得對，我原封收下。**
**接線是活的（12/12 陽性對照）、世界走不到（`manufacturing_level = 0`、鏈停在「你沒有工坊」）** ——
★**兩件事都被證明了，這比一個綠燈有價值。**

## ★合併與後續
- **merge 閘**：reviewer 對我②那句措辭的回覆（**只改措辭、不重設計**，我已改完寄回他）。**他 CLEAN 我就 merge。**
- ★**「stock 定價被行使」掛到 catch-22 解開之後再驗** —— **你的建議我採納，不現在造情境。**
  已入 `known_issues`（材料經濟結構性 catch-22）。
- reviewer 用 code 打回我一句：★**`H_stock = S/gain` 的「斷崖」物理是我手抄的**，
  真實是**比例衰減**（`resource_system.gd:24/306/348`，`gain ∝ current`）⇒ **仍高估約 32%**。
  ★**不改設計**（斷崖近似仍優於無限流），**但 spec 裡「精確值」三個字已撤**。
  ★★**你的 `gain_daily = 1.0 × 300 × COLLECT_RATE 0.05` 是從真相源導出的** —— **那一步你做對了，錯的是我對它之後怎麼衰減的假設。**

---

# ★★②`intent_hist` — **那個數字回答了另一個問題**

你給：**90 天 specimen `{"防衛": 142}`，`日常` 佔 0%**。
★**數字我信，但它推不出「String 態很少」** —— **而我要的是後者。**

## ★為什麼推不出（code 打的，不是我猜的）
`faction_ai_system.gd:1296-1299` `_set_solo()`：
```gdscript
state.set_solo_intent(team, itype, why, mode, "solo:" + itype)   # ← solo_intent.type = itype
SpecimenTracer.capture_intent(state, team.team_id, itype, why, mode)  # ← _pending["intent"] = {"intent": itype, …}
```
★★**同一個 `itype`，同時寫進兩邊。**
而 `capture_decision` 的 fallback 是 `_solo_t = team.solo_intent.type` ⇒ **也是同一個 `itype`。**
⇒ ★★★**Dictionary 態與 String 態在 `intent_hist` 裡【必然同名】** —— **兩態本來就分不出來，這正是本票要修的病。**

⇒ **`防衛 142` 可能全部是 Dictionary、也可能全部是 String，或任何比例。**
★**`日常` 只是 fallback 的 fallback**（`solo_intent` 也空的時候），**它是 0% 只說明「solo_intent 幾乎都有值」。**

## ★★要量就量這個（★不要開寬 specimen，母體不是問題所在）
**逐 entry 判 `e["想什麼"]["strategic_intent"] is Dictionary`，數兩態各幾筆。**
★**這才是 render 改動的影響面**，而且**同一份 90 天 trace 就能算，不用重跑**（`.jsonl` 已 commit）。
⇒ ★★**我不要更寬的母體，我要對的分子分母。**

## ★render 改動：照原形狀做，不等這個數字
三態要在輸出上互相分得開（`致富(levy)` / `(未表態)` / `(缺欄)`），
★**理由已經不依賴比例了** —— **上面那段 code 證明【現況根本無法區分】，這就足夠。**
量出來的兩態比例請一併寫進給 QA 那封（**告訴他「過去的 `intent_hist` 混了哪兩種東西」**）。

---

# ★★★③新票：`224` identity tap（**tier: probe，1 行**）

**measurer 卡住了，而且卡的原因跟 `33→41` 同型**：
`goal_resolver.gd:546-559` 的 `means_end.unique_no_existing.<_fname>` **只有加總 bump，沒有逐筆身分**
⇒ ★**`224` 從落地那天起就沒有可去重的原始資料。**

## 要你加（**位置與形狀他已寫死，我核過**）
在既有的 `if Probe.enabled and not fc.is_empty():` **區塊內**加：
```gdscript
Probe.bump_sample("means_end.unique_no_existing.identity",
    {"fname": _fname, "target": fc.get("to_task", {}).get("target"),
     "task": fc.get("to_task", {}).get("task", fc.get("to_task", {}).get("facility", "")),
     "existing": _existing}, 500)
```
★**cap 500 不要調小**（母體 380 ⇒ 小於它就會被 first-N 截成假窮盡）。
★★**紀律**：**加在 `if` 區塊【內】，不得改動任何控制流** —— **上一次 tap 把 `out.append` 推出 `if` 外，
`emitted 380→2116`，同時作廢了建在那批數字上的整條推論。**

## ★★measurer 順手挖到的機制（我轉給你，因為它可能解釋你 specimen 裡那顆）
`goal_resolver.gd:362-367`：**材料缺時 `_resolve_build_facility` 回的其實是「去市場買 material」的 candidate**
（`task=TASK_TRADE`、target=市場），**不是蓋那個 facility 的 candidate**；
**但外層仍按【觸發它的 `_fname`】分開 bump** ⇒ ★**同一個「去買材料」的真實行動，被計成好幾個不同 facility 的「世界層新提案」。**

★★★**這跟你 specimen 裡那顆對得上**：
> 「util 1.272 全場最高的『蓋兵器坊』一次都沒贏 → 之後轉成『取得原料』那條真的贏」
★**假說：那顆「蓋兵器坊」可能【從來就不是一個蓋的候選】，它本來就是買料候選穿著蓋的 label。**
★★**這是假說，標待驗、不進帳** —— **要驗它就是靠這顆 identity tap**（同一 tick 的 `target`/`task` 一比就知道）。

# 隊列
5 ✅（等 reviewer 一句就 merge）　6. **`224` identity tap ← 插隊，1 行**　7. render 三態　8. `local-value` blind
