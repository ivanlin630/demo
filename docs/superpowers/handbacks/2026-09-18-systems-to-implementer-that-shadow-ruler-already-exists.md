---
from: systems
to: implementer
status: open
slice: 凍結終線｜`*multi` 感知蒐集塊（`feat/freeze-multi-perception`）
topic: ★收下：那顆陽性對照抓到的是**儀器**，而它是那條規則的第一個真實樣本｜★★★**但你造的那把尺已經存在**：`scripts/debug/ephemeral_state_hash.gd` 抓的欄位跟你 `_w_cadence_hash` **是同一組（而且是超集）** ⇒ **刪掉你那支，改呼它** —— 兩份手抄清單比一份更會 drift｜★你標的誠實限（手抄 vs 導出）在**同一個檔裡就有先例**（`state_fingerprint.gd::derived_excludes()` 是算出來的）⇒ 我登成另一張票，不在本票長大
---

# 一、先講結論：**這把尺不用你造**

```
你的 _w_cadence_hash 抓：team{consolidate_eval_next_tick, expand_eval_next_tick,
                            consolidate_target_cache, absorb_target_cache, expand_site_cached}
                        tile{labor_eval_next_tick, idle_employ_next_tick, idle_employ_cached, labor_alloc}

scripts/debug/ephemeral_state_hash.gd:21-22 抓：★逐字同一組（:42-43 team、:48-55 tile）
                        ＋ ephemeral 快取（food_runway／persist_strength／food_flow_avg／need_urgency）
⇒ ★它是你那份的【超集】
```
⇒ **改呼 `EphemeralStateHash`，刪掉 `_w_cadence_hash`。** 三個理由：
1. ★**兩份手抄清單比一份更會 drift**，而 drift 不會有東西紅 —— 這正是你自己標出來的那個誠實限，**造第二份等於把它乘二**。
2. ★★**換成超集之後你的斷言變【強】不是變弱**：不再只是「cadence 沒被寫」，而是「**指紋排除掉的那些欄位，一個都沒被寫**」。
3. ★★★它**已經有人在用** ⇒ 它比新造的那支更可能被維護。**沒有人負責讓東西變少，所以造之前先找有沒有現成的。**

★**這是今天第二次**：上一次是 `market-ads`（我要建的東西早就存在，真管線一直在讀 belief）。
⇒ **「我需要一把尺」的第一個動作是 grep【誰已經在量這件事】，不是開新檔。**

# 二、你抓到的那一格（我收下，而且它比我預期的更好）

```
① consolidate_eval_next_tick +1 ⇒ 指紋不變
② expand_eval_next_tick      +1 ⇒ 不變
③ labor_eval_next_tick       +1 ⇒ 不變
④ idle_employ_next_tick      +1 ⇒ 不變
⑤ current_task 改值          ⇒ ★變了（比較器自己會動）
```
⇒ ★**我預測的那一格成立**：那個 0 的範圍是「**0 次【指紋看得見的】寫入**」。
★★**而你自己指出的那一句才是重點**：`EXCLUDES_SUBFIELD` **逐字印在你每一輪的卷面上**，
**你印了它，卻沒有把它套回自己的下一句結論。**
⇒ **「寫下來」與「套回自己下一句」之間有距離** —— 而**卷面沒有辦法強迫自己被讀回**，
⇒ 所以正確的修法就是你做的那個方向：**讓看不見的那半有自己的雜湊**（只是那支雜湊已經存在）。

★**②那一格我也收下**：`population` 是衍生唯讀欄位、setter 靜默吞寫入（`team_data.gd:109-118` 自己的註解就寫著它是「永久的靜默失敗產生器」）
⇒ **一顆對照要能用，它自己得先能動**。★★而這跟 §1 是同一件事的兩面：**你用的工具有沒有作用，要先證明，不能假定。**

# 三、你那條誠實限的真正升級路徑（★**另一張票**，不在本票）

同一個檔裡就有先例：`state_fingerprint.gd:27-32 derived_excludes()` ——
**頂層欄位的排除清單是【算出來的】**（掃本檔原始碼有沒有出現 `state.<欄位>`），
而註解自己寫著理由：**「新增一個頂層欄位而兩邊都沒提到它」這種靜默缺席，在這個粒度上不會發生。**

⇒ ★**子層級可以照做**：列舉 `TeamData`／`HexTileData` 的 `var` 宣告，減去指紋原始碼裡讀到的那些
⇒ **兩把尺的聯集恆為全體**，`EXCLUDES_SUBFIELD` 那個手抄字串就可以退休。
⇒ ★★**但那是一張獨立的票**（動的是尺本身，不是本票的修法）——**我登成 defer，本票不長大。**

# 四、本票剩下的事

1. **把影子雜湊換成 `EphemeralStateHash`**，重跑那一格（★數字要重新印，不要沿用舊卷面 —— 換了尺＝換了母體）。
2. **註冊表那一列的 `expect` 跟著改**（★你釘的是【數】不是 PASS，這點很好，保持）。
3. **(丙-2) 開工**（含 1-i 內容錨）。
4. ★**1-h 重用 e 那一跑 ＝ 對的**（同輪三跑、不跟歷史字串比、沒有多跑一個世界）。
