# HOW spec（草案；★待 R²）— **拆物價 clamp**（第⑩票）

WHAT：用戶裁「拆」（TG 2026-09-06），blueprint 轉；**定義域裁定**同日。
意圖帳權威：`docs/mechanism-intents.md` 物價行（「拆閥定案」＋「floor 0 是定義不是閥」）。

## §1 現況（★file:line）
```
trade_valuation.gd:158-163
   var shortage := (target - stock) / maxf(target, 1.0)          ★恆 <= 1.0(見 §2)
   if res in SURVIVAL_GOODS and shortage > 0.5:
       shortage = 1.0 + (shortage - 0.5) * 6.0                    ★飢荒不對稱放大 = 原設計,【留】
   var sr := clampf(shortage, -0.5, 4.0 if SURVIVAL_GOODS else 1.0)   ★★後加的穩定閥 = 【要拆的】
   return BASE_PRICE[res] * (1.0 + sr)
```

## §2 ★★★而【上臂是結構性死碼】—— 拆它是零行為改動
```
`stock` = ResourceSystem.effective_holding = team.resources[res] + 自家糧倉 public_storage[res]
   ⇒ ★兩項皆 >= 0 ⇒ shortage = (target − stock)/maxf(target,1.0) 【恆 <= 1.0】
   ⇒ 生存品放大後 = 1.0 + (1.0−0.5)×6.0 = 4.0 ★★【恰好等於上界,永不超過】
   ⇒ 非生存品 <= 1.0 ★★【恰好等於上界,永不超過】
⇒ ★★★所以【上臂從來不夾任何東西】:拆掉它 `fp` 應該【逐位元不變】
⇒ ★而下臂(-0.5)【是真的會夾】⇒ 拆它才是【真正的行為改動】
⇒ ★★兩段的風險【不對稱】,而驗收要分開講(見 §4)
```

## §3 動作
```
①刪 `clampf(...)` 兩段 ⇒ `sr = shortage`(飢荒不對稱放大【保留】)
②★保留【價格定義域 floor 0】—— blueprint 裁:「價格不得為負」是【這個量的定義】不是閥
   ⇒ 形式:`return BASE_PRICE[res] * maxf(1.0 + shortage, 0.0)`
   ⇒ ★★而【它要寫成定義域不是閥】:code 註解寫明
     「爛大街 ⇒ 白送(0);而『倒貼你拿走』的物流世界不在本作 scope」
③★★★而【不得】把 floor 寫成一個具名常數(那會讓下一個人以為它可調)——直接寫 0.0
```

## §4 驗收（★★兩段分開，因為風險不對稱）
| # | 判準 |
|---|---|
| 1 | ★**只拆上臂 ⇒ `fp` 逐位元不變**（★★它是死碼，**若 fp 變了 ⇒ §2 的推導錯了**，那才是要停下來的時刻） |
| 2 | ★★**拆下臂 ⇒ `fp` 會變且【應該變】**；而**價格分布**要印（★★★最低價 / 有多少次落在 0） |
| 3 | ★**第四桶（`shortage < -1`）的實測值**：它非 0 ＝「**白送區真的存在**」（blueprint：**有戲不是 bug**） |
| 4 | ★★**負價不存在**：全窗 `local_value` 最小回傳值 **>= 0**（★而這是 floor 的直接斷言） |
| 5 | ★★★**下游不炸** —— ~~枚舉三處~~ **★★★★【R² 訂正：改成窮盡】**：`local_value(` 的呼叫點**實測 37 處、跨 10 個檔**（`interaction_system`／`order_system`／`player_api_mapper`／`player_trade_system`／`marginal_economy`… **全是我原本沒列的**）⇒ **逐站 confirm**，判準 ＝ **全窗每一個呼叫點的回傳值最小值 >= 0**。★而 `interaction_system.gd:1170,1172` 已有 `maxf(...,0.001)` 除零防護**不會炸** —— ★★**但那正是「機制存在」需要被驗收【明確覆蓋】而不是【假設沒事】的例子** |
| 5b | ★★★★**第二層證據（R² 給，比只看 fp 更直接）**：**全程 `team.resources` ／ `tile.public_storage` 的每一個 res 最小值 >= 0**。<br>★**理由**：`ResourceBank.remove()` 有 `clampf(amt, 0.0, have)` 保底，★★**而 `add()` ／ `set_amt()` 【沒有下限保護】** ⇒ 若某處傳負 `amt` 且超過現有量，`stock` 會變負 ⇒ **§2「shortage 恆 <= 1.0」的前提就破了**。<br>★★★**而這條的價值是：它把「我的推導對不對」變成【一個直接可量的斷言】，而不是只靠「fp 有沒有變」去反推** |
| 6 | ★**讀數紀律**：D 格分流（命中高⇒先治上游／低⇒直接拆）**只用在下界桶**；★★上界桶恆 0 是**構造性的**，**不得**拿它推論「閥沒在扛事」 |
| 7 | determinism 三跑（★不會被編輯的樹）＋ 全部 merge-gate |

## §5 排程
```
★經濟窗(與⑨貨幣創世／B-v0 市場厚度同批)⇒ 對比輪之後
⇒ ★★已登記 defer token(met_check 同⑨/B-v0)
★★★而【D 格的命中率讀數要先有】—— 它是【拆前安全讀數】:
   下界命中率【高】⇒ 上游短缺迴圈正在被閥扛著 ⇒ 先治上游再拆
   下界命中率【低】⇒ 直接拆
   —— ★而【兩種情況拆都是終點】,不再是選項(用戶裁)
```
