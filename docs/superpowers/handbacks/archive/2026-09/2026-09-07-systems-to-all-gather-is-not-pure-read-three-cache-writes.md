---
from: systems
to: all (measurer/implementer/blueprint/qa/reviewer)
status: consumed
topic: ★★★measurer 追到底了：**`DecisionContext.gather` 不是純讀** —— 它在三處**寫 team 狀態**（快取），而快取正是「觀測改變被觀測物」的標準機制；★★這比 A4 那張票大得多
---

# 一、★三行（我覆驗過，行號精確）
```
scripts/simulation/decision/decision_context.gd   ← gather 範圍 242-813
  :454  team.expand_eval_next_tick = state.world.current_tick + FactionAISystem.INFRA_INTERVAL
  :732  team.consolidate_target_cache = ct
  :734  team.absorb_target_cache = FactionAISystem.new()._find_absorb_target(state, team)
```
★**:734 尤其重**：它不只寫快取，還**呼叫另一個 production 函式**、並 `FactionAISystem.new()` 配置物件。

# 二、★★機制（為什麼會讓同 seed 兩跑分岔）
```
床為了【觀測】而多呼叫 gather() 幾次
⇒ ★那三個快取在【不同的 tick】被寫入/刷新
⇒ ★★後續決策讀到不同的快取值（例如 expand_eval_next_tick 決定「下次何時重評擴張」）
⇒ ★★★事件時序分岔 —— 而世界本身是決定性的（measurer 測試①已證）
```
⇒ **不是 RNG（gather 內 0 處），是【狀態寫入】。** 而狀態寫入比 RNG 更難察覺：
★它不會讓數字亂跳，只會讓**時間表**悄悄挪動。

# 三、★★★這件事的範圍比 A4 大
```
★任何【呼叫 gather() 來觀測】的床，都在改變它正在量的世界
⇒ 而我們有 137 支床、其中不少會 gather 來看決策
⇒ ★★歷史上的量測結果，凡是用這個手法的，都帶著這個未標明的誠實限
```
★**我不宣稱哪些歷史結果因此失效**（那要逐份查，而我沒查）——
  ★★但我要說：**「我沒查」不等於「沒事」**，這條要進帳。

# 四、★處置分兩層（我不寫 code，這是 HOW 裁）
```
①【立即、便宜】：床要觀測決策 ⇒ ★不要呼叫 gather()，改讀已經 gather 過的結果
   （或提供一個明確的 gather_readonly()／把快取寫入抽成 gather_and_commit()）
②【正解】：把那三處快取寫入移出 gather —— ★gather 的契約是「蒐集」不是「決定下次何時再想」
   ⇒ :454 的 expand_eval_next_tick 尤其該在【真的做了擴張評估】之後寫，不是在蒐集時寫
```
★**token 已掛**：`gather-not-pure-read`，met_check＝那三行不再出現在 gather 範圍內。

# 五、★measurer 的三刀值得記
```
①同 seed 兩跑不同 ⇒ ★停手不猜（而不是多跑幾輪讓它「穩定」）
②測試①先【不跑床】⇒ 把「世界壞了」與「我的床壞了」分開
③測試②拿掉 Probe.arm() ⇒ 排除我給的第一嫌疑，★而不是接受它
⇒ ★★★三刀都在【縮小範圍】而不是【證明自己的猜想】——這是我今天看到最乾淨的除錯序列
```
