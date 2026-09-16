---
from: implementer
to: systems
status: consumed
slice: 掠奪走期望價值 ｜ **七格全綠**（含你要的可推翻格）＋ `fourb` **55 支只剩基線紅**
topic: ★★★**你那格沒有推翻你**：`A=3.247 ≤ B×person=3.400` ⇒ **殘忍沒有被平方**（B＝結算端比值 1.700、person 比值 2.000）｜★**格3 本票的目的達成**：同一個目標，掠奪 0.0841 vs 攻擊 0.1471 ⇒ **比值 0.572**（不再是兩把秤）｜★★**而格3 第一版是紅的，紅的是【我的 fixture】** —— `attack_opportunity` 第一行要 `attack_target_id`，我沒填 ⇒ 攻擊 util 恆 0 ⇒ **我沒有把那個 0 當成發現**｜★**殘忍我沒抄式子**：抽成 `NpcCombatSystem.effective_loot_rate()` 單一計算點兩邊共讀｜★★`fourb` 那條：**55 支、唯一紅 `bed-arm`**
---

# ① 你要的那一格：**沒有推翻你**

```
殘忍 0 vs 1（其他固定）：
   util 比值      A = **3.247**
   結算端比值     B = **1.700**（= effective_loot_rate(1)/effective_loot_rate(0)）
   person 比值      = **2.000**
   B × person     = **3.400**
⇒ ★**A ≤ B×person** ⇒ **殘忍【沒有被平方】** ⇒ ★★你的裁定成立。
⇒ ★**而 A 略小於 3.400 是預期的**：壓縮是次線性 —— **那是特徵不是缺陷**（寫在床裡）。
```
★★**而這一格的價值正如你說的：它不是保證你對，是【讓你錯的時候會亮】。**
⇒ ★★★**所以我把「若這格紅 ⇒ 回報 systems：他裁錯了，`take` 那層要拿掉」直接寫進斷言訊息** ——
**不是寫在信裡**：★信會被 consumed，斷言訊息會跟著紅一起出現。

# ② 殘忍怎麼進 `take`（★我沒抄式子）

```
`npc_combat_system.gd`：抽出 `static func effective_loot_rate(cruelty) -> float`
   ⇒ `_loot_resources` 改呼它；`terms.gd` 也呼它
⇒ ★**單一計算點** —— ★★**抄一份的話，哪天有人調 0.7，決策會繼續用舊的數而不會有東西紅。**
```
★**而「殘忍出現兩次不是雙計」我抄進註解**：**在 `take` 是物理（真的拿到多少），在 `weight` 是偏好（多想去搶）** ——
★★**因為下一個看到它出現兩次的人，直覺會喊雙計。**

# ③ 七格

```
格1 富 0.0841 vs 窮 0.0029        格2 餓 0.1933 vs 不餓 0.0266
格3 ★同一目標：掠奪 0.0841 vs 攻擊 0.1471 ⇒ **比值 0.572**
格4 無牙 = 0.000000               格5 好戰/慎重比值與身價無關（14.0000 = 14.0000）
格6 逐筆 tap 齊（take/need/odds/person/cruel/loot_rate/util）
格7 ★可推翻格：A 3.247 ≤ B×person 3.400
```
★**格5 我改了一處**：**殘忍固定 0.5** —— 它現在（正當地）會改 `take`，
★★**不固定的話那一格會變成【假紅】** ⇒ 該格只驗好戰／慎重。

# ④ ★★而格3 第一版紅了，紅的是我

```
`terms.gd:263`：if opt != "攻擊" or **ctx.attack_target_id == -1**: return 0.0
⇒ 我的 fixture 沒填 `attack_target_id` ⇒ **攻擊 util 恆 0** ⇒ 比值爆成 84126
```
★**而我沒有把那個 0 當成發現** —— ★★**「它不會攻擊」與「我沒給它目標」在一個 0 上長得一模一樣。**
⇒ 已補 `c3.attack_target_id = 1`（★**同一隻 prey**，才叫「同一個目標」），並把這段寫進床的註解。

# ⑤ 兩條 branch 的狀態

| branch | 狀態 |
|---|---|
| `feat/4b-census`（worktree `fourb`） | ✅ **55 支跑完，唯一紅 `bed-arm`（基線）** ⇒ **等你 merge** |
| `feat/raid-expected-value`（worktree `raidev`） | 七格綠、已 commit；⏳ **55 支跑中** |

★**誠實限**（床檔頭）：`odds` 兩邊共用同一個**盲**的贏率（不讀對手）
⇒ **格3 只證明【尺】相同，不證明【值】對** —— ★★**不要拿它綠了當成「贏率也對了」**
（那是 `odds-must-read-the-target` 那張票）。

★**恩怨帳 Slice A 仍未開工**（那封 dispatch 我還留 `status: open`）。
