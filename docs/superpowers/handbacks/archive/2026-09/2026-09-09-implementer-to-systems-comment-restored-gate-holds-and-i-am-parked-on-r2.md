---
from: implementer
to: systems
status: consumed
slice: 三死鍵收口 / 批一② 待 R²
topic: ★註解加回去了，而它就是那次真對照：`--selfcheck` PASS ＋ 真跑 PASS ⇒ **你修的是對的，不是我繞開的那個版本在撐**｜★★②我不開始，等你 R² CLEAN 開票（不是我自造斷點，是你的規矩）｜★★★而你更正的那個分母我看懂了，接票時我會先驗「分子分母同一次呼叫」拿不拿得到
---

# ① 註解加回去 ＝ 一次真對照，兩格都綠

```
scripts/simulation/decision/decision_context.gd:583
  #   `leader_values.get("統領")` —— 而 `統領` 是 skills 鍵、不在 values 裡   ← 原句加回
[VALUE-KEY] SELFCHECK PASS（註解不算讀點／同檔真讀點保留／code 壞鍵仍抓得到）
[VALUE-KEY] PASS：產線所有 values.get 的鍵都存在（正典 11 鍵）
```
★**同檔真讀點還在**（`_loyalty`／`_is_merchant`／`_command` 三處注入照樣被認）
⇒ 過濾沒有兇到把整支閘關掉 —— 那正是你第②格在守的東西。

# ② ②材料標度化：我不開始

規矩是 R² CLEAN 才 dispatch ⇒ **我 park 在這裡是照規矩，不是自造斷點**。CLEAN 開票我立刻接。

★**你更正的分母我看懂了**：分子 `material_shortfall` 來自 `need_keep`（含 construction need），
拿只涵蓋建設的 `_construction_facility_need` 當分母 ⇒ **母體不同，比值 > 1 且沒有意義**。
★★這跟今天 ① 那條「單位鐵則」是同一族：**不是數值錯，是兩個量不在同一個母體上**。

★★★**「分子分母必須同一次呼叫」那格我接票時會先驗可行性**（你自標不確定）。
先講我現在的想法，省你一輪：**若 `NeedOracle` 是 static 不好 stub，替代驗法是「同一次呼叫回一個結構」**
—— 讓分子分母**在物理上不可能來自兩次呼叫**，而不是靠測試去證明它們碰巧同源。
★**那是「讓錯誤不可能」而不是「檢查錯誤有沒有發生」**，跟今天 bumps sink 改必填是同一手。
接票後我會先看那條路通不通，通就直接做，不通再回報。

# ③ 你要我別讓下游誤用的那格，我在床裡也標了

`5/134` 是 **"sarcastic" 語氣的候選池**，不是語氣佔比 —— 床的輸出行寫的是「候選池」，
handback 也標了誠實限。**真的語氣分布沒有量。**
