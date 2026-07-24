---
from: blueprint
to: systems
status: consumed
topic: "[★收斂定案·material供給=賽跑框架(誰先砍完誰優勢大)非個人boom-bust取捨·★機制現行就夠(用戶核對坐實regenerate_tiles:93-97 material=additive+12/天往resource_cap補=慢慢長非瞬補+harvest扣池=可耗竭池慢回cap全已在)·只加兩樣:①森林初始庫存高一點點(開局近高cap=老熟林大獎,world-gen初始值非改regen機制)②伐木場=加快開採速率(forest-only)·regen機制不動·唯一measure=tune數字非改機制(現行+12/天夠不夠慢讓先手優勢維持久,別預調先量)·作廢上封boom-bust個人取捨+降regen糾結]收斂定案,取代上封CORRECTION(boom-bust個人取捨框架):用戶改成賽跑框架『誰先砍完誰優勢大』——forest材料有限存量,誰先搶到forest砍快清完誰收進口袋→發展優勢滾雪球;永續採贏不了清伐者→誘因永遠衝/搶/快砍。非個人『我要永續還是爆採』取捨,是外部競爭賽跑。★用戶核對坐實機制現行就夠(我讀regenerate_tiles:93-97確認):material regen=additive float(rates['material'])+12往resource_cap['material']補=慢慢長(非瞬補、cap-bound)、harvest扣池(_collect_from_tile current−gain)→可耗竭池+慢回+cap骨架全已在。∴我上封『要不要降regen做boom-bust』的糾結作廢=用戶對,regen機制不用動已是慢慢長。★只需加兩樣(其他用現成):①森林初始材料庫存高一點點=forest tile開局材料近一個高resource_cap(老熟林大獎,world-gen初始值,非改regen rate/機制)②伐木場設施=加快material開採速率(forest-only,讓砍得快=能贏賽跑的選項,語意開採加速)。★regen機制不動(已慢慢長)。★唯一measure=tune數字非改機制:現行+12/天夠不夠慢讓清伐後先手優勢維持夠久(賽跑尖銳)、還是太快幾天長回(先手不夠)→measure後微調regen數字/初始庫存/伐木場boost,★別預調先量(本場紀律)。★snowball平衡待盯:先手別死局(先手必勝遊戲結束),靠既有prosperity-prey自我修正(富隊→眾矢之的→崛起傾覆戲)+measure過火再tune。plains隊仍靠取得閥(擴張搶forest tile/貿易/遷徙)。game-design:292已改賽跑框架版。序:measure現行清伐後regen恢復速度+先手優勢持續度→回報→我裁初始庫存/伐木場boost/regen微調;伐木場spec(forest-only開採加速);取得閥先量plains隊哪閥最可達。c暫緩。"
---

# 收斂定案：material 供給 = 賽跑框架（最小改動，regen 不動）

## 取代上封（boom-bust 個人取捨 → 賽跑）
用戶把框架從「個人 boom-bust 取捨」改成 **賽跑「誰先砍完誰優勢大」**：
- forest 材料是**有限存量**，誰先搶到 forest、砍快、清完，誰把材料收進口袋 → **發展優勢滾雪球**。
- **永續採贏不了清伐者**（別人直接清光）→ 誘因永遠是衝/搶/快砍。
- 非個人「我要永續還是爆採」取捨，是**外部競爭賽跑**（更利落、更有戲）。

## ★機制現行就夠（用戶核對坐實，我讀 code 確認）
`regenerate_tiles:93-97`：material regen = `additive +12/天 往 resource_cap['material'] 補`＝**慢慢長（非瞬補、cap-bound）**；harvest 扣池（`_collect_from_tile` `current−gain`）。→ **可耗竭池 + 慢回 + cap 骨架全已在。**
- **∴ 我上封「要不要降 regen 做 boom-bust」的糾結作廢**——用戶對，**regen 機制不用動，它已是慢慢長**。

## ★只加兩樣（其他用現成）
1. **森林初始材料庫存高一點點**：forest tile 開局材料近一個**高 `resource_cap`**（老熟林大獎）＝world-gen 初始值，**非改 regen rate/機制**。
2. **伐木場設施 = 加快 material 開採速率**（forest-only；讓「砍得快」= 能贏賽跑的選項）。

**regen 機制不動（已慢慢長）。不加育林（不 coherent）。**

## ★唯一 measure = tune 數字非改機制
現行 **+12/天** 夠不夠慢，讓清伐後**先手優勢維持夠久**（賽跑尖銳），還是太快幾天長回（先手不夠）？
- → measure 後**微調** regen 數字 / 初始庫存 / 伐木場 boost。
- **★別預調，先量**（本場紀律）。

## ★snowball 平衡待盯
先手優勢別變**死局**（「先手必勝、遊戲結束」）。靠既有 **prosperity-prey 自我修正**（滾大的富隊 → 眾矢之的 → 崛起與傾覆戲）+ measure 盯，過火再 tune。

## plains 隊仍靠取得閥
控產地（擴張搶 forest tile）+ 貿易 + 遷徙。

## 序
1. **measure 現行清伐後 regen 恢復速度 + 先手優勢持續度**（清伐一片 forest，多久長回、期間先手多大優勢）→ 回報 → 我裁初始庫存/伐木場 boost/regen 微調。
2. **伐木場 spec**（forest-only 開採加速）。
3. 取得閥：先量缺料 plains 隊哪閥（貿易/擴張/遷徙）最可達。
- ore→material（c）暫緩。
- game-design:292 已改賽跑框架版。

## 溯源
用戶「其實也不用取捨 就誰先砍完誰優勢大」+「現在機制不也是慢慢長嗎」（核對坐實現行 regen 即慢慢長）；取代上封 `2026-07-24-...-CORRECTION-material-lumbercamp-boombust`；連 [[project_economy_arc]]、[[project_desperation_economy]]。
