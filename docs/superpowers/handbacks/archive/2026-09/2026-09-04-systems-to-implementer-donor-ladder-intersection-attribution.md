---
from: systems
to: implementer
status: consumed
slice: donor-ladder-intersection-attribution
tier: probe
topic: ★量測票:施主階梯交集 0→2 的成因(逐階條件名,禁猜);★★做法=同一顆 code 跑兩個 config 把【政權注入】跟【順序相依 bug 修】分開——wrapper UTF-8 只碰 stdout 我先驗證式排除但不拿它當結論;★★★判讀表含「兩邊都 0=不可重現」那列,別讓它被讀成沒事;計數類可並跑,不擋 warring pilot
---

# 三格（缺一不可）

```
自變數 ＝ config 檔（舊 config/peaceful_economy.json ↔ 新 config/peaceful_economy_regime.json），
         ★code 固定在同一顆 = main HEAD（兩跑同一個 binary、同 seed）
母體   ＝ 施主階梯【被評估的總次數】(entry)，不是「命中的那幾筆」
印在輸出哪一行 ＝ `[DonorLadder] entry=N stage.<條件名>=N ...  hit=N`
                 ★★每一階印【條件名】而不是序號 —— 序號會在有人插一階時整排錯位
```

# ①要分開的是**兩個**變因，不是三個

同一輪換了三樣：**政權注入(config)／`_setup_explicit_teams` 順序相依 bug 修(code)／`tools/godot.ps1` force UTF-8**。
★第三個**只碰 stdout 解碼、不進 sim** ⇒ 我先驗證式排除它。
★★**但我不拿這個推論當結論** —— 下面的兩跑本來就會把它一起吃掉（同一顆 wrapper 跑兩邊）。

⇒ **兩跑，code 同一顆：**
```
跑1  main HEAD + config/peaceful_economy.json          ←★舊 config
跑2  main HEAD + config/peaceful_economy_regime.json   ←★新 config
```

# ②★★★判讀表（我先寫死，含「沒有單一主因」那格）

| 跑1(舊config) | 跑2(新config) | 判定 |
|---|---|---|
| 0 | 2 | ★成因＝**政權注入**（config 這一側） |
| 2 | 2 | ★成因＝**順序相依 bug 修**（code 這一側；因為舊 config 在**舊 code** 上是 0） |
| 0 | 0 | ★★★**那 2 筆不可重現** ⇒ **這不是「沒事」**，是「上次那 2 筆的來源沒被這兩個變因解釋」⇒ 回報我，別自己收尾 |
| 兩邊都 >0 但**不相等** | | ★**沒有單一主因** ⇒ 照原樣報數字＋逐階條件名，**不歸類** |

# ③逐階要求

1. ★**先印 `entry`**（這條階梯被走到幾次）—— **沒有它的話，逐階全 0 跟「這段從沒被呼叫」長得一模一樣**（你自己在 `_evaluate_infrastructure` 那顆證過的形狀）。
2. ★★**逐階互斥且窮盡＋對帳**：`Σ各階擋掉 + hit == entry`，不平就在該行下面印 ❌。
3. ★**命中的那 2 筆要能被指認**：印出 `team_id` 與**它通過的每一階條件名**，不是只印總數。
4. ★**`fp` 逐位元不變**（純觀測、不動控制流）。

# ④排程

★**計數類，可並跑** ⇒ **不擋你手上的 warring pilot**（那顆是時間類、已自標 `EXCLUSIVE=unknown`）。
★★**跑多久／跑幾次／要不要分批你自己定**，我不問跑法排程；有歧義的是**票本身**才回我。
