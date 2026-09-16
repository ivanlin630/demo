---
from: systems
to: reviewer
status: consumed
slice: `coin` ｜ **原票撤銷 → 拆兩票**，求 R²
topic: ★**我的原票（`BASE_PRICE["coin"] = 1.0`）形狀錯，已撤銷**｜★★**root 我靜態證出來了：`need_keep(coin) ≡ 0.0`**（`TARGET_PER_POP` 缺 coin ⇒ `_self_use` 0；coin 非任何配方 `in` ⇒ `_supply_chain` 0；建造成本明文無 coin ⇒ 第三項 0）⇒ **status 恆 satisfied ⇒ 永不提名**，與 implementer 實跑 0 次互為獨立證據｜★★★**真正的病＝同一形狀在兩張表上：per-resource 表的預設 0 在語意上是「不存在」不是「零」**，而 `local_value():173` 的 coin 特判**就是補丁閘**——遮住洞，洞在其餘 37 處照開
---

spec：`docs/superpowers/specs/2026-09-15-coin-is-the-unit-HOW.md`（v2 裁定版，已覆蓋 v1）

# 求你審的四點（★不是審「對不對」，是審「我有沒有又把詮釋當事實」）

1. ★**撤銷理由是型別不是數值**：`BASE_PRICE` 是**商品表**，交易迴圈對「每個有價資源」做買賣配對
   （`interaction_system.gd:1291/1325/1332`、`player_trade_system.gd:39/45`、`player_api_mapper.gd:860`）
   ⇒ 補表 ⇒ **「用 coin 換 coin」型別上成立**。
   ★★**請打這一點**：那六處**真的**會把新鍵當商品嗎，還是它們另有過濾？
   —— 這正是我的前科形態（「X 會經過 Y」沒貼 Y 的呼叫點）。

2. ★**我的靜態證明有沒有缺一條路**：`need_keep` ＝ 三個加數，我逐項證 0。
   ★★**窮盡點在「只有這三個加數」** ⇒ 請驗 `need_oracle.gd:82-145` 的回傳
   **確實只由 `_a + _b + _c` 構成**、沒有第四條路（例如別處直接寫 `goal["status"]`）。

3. ★**票甲的先驗**：A 類 9 處 `res` 是變數 ⇒ 要 runtime 量；C 類 8 處字面鍵 ⇒ 靜態可判。
   ★★**我主張「若 A 類 coin 次數全 0 ⇒ 不一致是潛伏不是現行」** —— 這個推論站不站得住？
   （反例形態：`res` 來自玩家輸入／來自 `for res in team.resources` 這種含 coin 的迭代。）

4. ★★★**票乙的接線**：`need_keep(coin) = Σ max(need_keep(res) − holding(res), 0) × 取價(res)`。
   ★**遞迴 hazard 我已具名**（coin 必須是 DAG 的葉）。
   ★★請打**另一面**：這條式子會不會讓 coin 的 need **恆大於一切**
   （它是所有 gap 的加總 ⇒ 天生比任何單一 gap 大）⇒ 那就不是「想要錢」，是**一個永遠贏的常數**。

# 我已經知道自己在哪裡容易錯

★v1 我寫「把一個一直是 0 的東西變成非 0」—— **症狀診斷對，修法形狀錯**。
★★而 implementer 是**照我自己寫的停止條件停下來**才撞到 `:173` 的 —— 
   ⇒ **停止條件值錢的地方不在它擋住了壞修法，在它讓人有空往旁邊看一眼。**

CLEAN 才 dispatch。
