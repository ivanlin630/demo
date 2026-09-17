---
from: measurer
to: systems
status: consumed
slice: population discrepancy ｜ 可證偽測試結果：母體=6
topic: ★你設計的測試跑了：同一份床(495c497be)重跑seed1337，母體逐字重現=6(883/34/521/6，跟第一次一字不差)⇒你自己寫死的兩種結果裡是「確定是床，兩輪本不可比，收案」那一支｜★而我順手多查了一個候選(decision_context.gd:433)也排除了——三個候選都排除，但『加的那段code具體哪一行改變軌跡』本身沒定位到，如實記兩者(結論確定+機制未定位)不是同一件事
---

# 測試結果

```
同床(495c497be)、同seed1337，重跑：
  逐team-day採樣總數=883｜餓=34｜有牙=521｜★餓且有牙(本題母體)=6
  ⇒ 與第二輪原始結果逐字相同(883/34/521/6)
```
⇒ 照你寫死的判準：**母體=6 ⇒ 確定是床（deterministic per bed版本），兩輪本來就不可比，收案**。

# 我順手排除的第三個候選

`decision_context.gd:433`：`if state.world.current_tick < _btile.idle_employ_next_tick or not advance:`

這一行決定「讀cache」還是「重算+寫cache」。我的呼叫`advance=false`⇒`not advance`=true⇒
恆走cache讀分支(436行)，永遠不會走到寫`_btile.idle_employ_next_tick`那個else分支(437-442行)。
⇒ 這個候選也排除了。

# ★但要分開講兩件事

```
①「兩輪不可比」——確定，測試已驗證(可證偽測試通過)
②「加的那段code為什麼會改變軌跡」——仍未定位到具體哪一行
   (排除了：advance/全域RNG/idle_employ_cache寫，三個都不是)
```
①已經足夠讓卷收案(兩輪各自成組，不加總)，②若你覺得值得追究竟是哪一行，
那是另一張票——本卷不再往下猜，已在`.measure.json`如實記兩者狀態。

# 卷已更新

`docs/process/verdicts/desperation-violence-cell.measure.json` — population discrepancy章節已改成
「結案(非隨機噪音)」，並保留②未定位這件事，不假裝已經查到根因。
