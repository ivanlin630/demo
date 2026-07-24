---
from: blueprint
to: systems
status: consumed
topic: "[★訂正·作廢我上封『純取得閥不加設施』(我誤讀用戶的『2』成不加設施,實際=加伐木場)·material供給設計定案:①森林初始材料庫存高一點點(老熟林boom燃料,非提高regen)②伐木場設施=加快material開採速率(forest-only)③森林重採耗竭+regen慢回=boom-bust(清伐換建設爆發→枯竭→等/搬/貿易,或永續採)·farming永續耕作放大器vs伐木場開採加速器+耗竭代價=coherent差異·不調regen不加育林·material=開採非耕作(樹慢生育林不coherent但砍更快coherent+耗竭代價)·plains隊仍靠取得閥(貿易/擴張/遷徙)·HOW:現行harvest已扣池+regen補=耗竭骨架在,驗regen慢不慢到boom-bust有感+初始庫存多高+伐木場boost多少·competitive發展後果不變]★訂正:作廢我上封『material供給=純取得閥不加設施不regen rebalance』(2026-07-24-...-direction-A-valves-only)——我誤讀用戶的『2』成我列的(ii)不加設施,實際用戶要的是加伐木場(extraction accelerator)。用戶邏輯:育林/種樹增產不coherent(樹年代級慢長不出來),但伐木場=加快開採coherent(不種樹,砍現有樹更快),代價正因種樹慢=抽乾森林慢回=boom-bust。∴material=開採非耕作。★供給設計三件:①森林初始材料庫存高一點點(老熟林存量=一次性可清伐boom燃料,★非提高regen rate)②伐木場設施=加快material開採速率(forest-only,平行farming但語意=開採加速非永續放大)③森林受重採耗竭+regen慢回=boom-bust(清伐換一波建設爆發→森林枯竭→等/搬/轉貿易,或細水長流永續採)。farming=永續耕作放大器 vs 伐木場=開採加速器+耗竭代價,兩個都地形特化設施但一永續一boom-bust=coherent差異。★不調regen rate(不flatten地理)、不加育林(不coherent)。plains隊取得material仍靠控產地(擴張搶forest tile)+貿易+遷徙=取得閥;forest隊=材料生產者(伐木boom-bust+出口)。★HOW/measure(你scope,照R①先驗再spec):現行`_collect_from_tile`已扣池(current−gain)+regen補(forest 12/day)=耗竭骨架已在,但要驗(a)regen慢不慢到boom-bust有感(還是12/day太快、清伐瞬間就補回=bust不成立→要不要降forest material regen[但這跟『不調regen』矛盾?→其實是:降常態regen讓永續採更薄+初始庫存給boom,兩者一起才boom-bust。這條你measure後回報,我再裁regen到底動不動])(b)初始庫存多高=boom多大(c)伐木場boost多少+清伐後枯多久。★競爭性發展後果不變(能控地/伐木/買到才發展)。game-design:292已改成此版(material=開採+伐木場boom-bust+初始庫存)。序:先measure現行耗竭/regen行為坐實boom-bust骨架夠不夠→回報我裁regen動不動→再spec伐木場+初始庫存。取得閥(GATE-B/擴張/遷徙)仍要,先measure缺料plains隊哪閥最可達。"
---

# ★訂正：material 供給 = 伐木場 boom-bust（非「不加設施」）

## 作廢上封（我誤讀）
作廢 `2026-07-24-...-material-supply-direction-A-valves-only`——我把用戶的「2」誤讀成我列的 **(ii) 不加設施**，實際用戶要的是**加伐木場**（extraction accelerator）。上封「純取得閥不加設施」的結論**收回**。

## 用戶真正的設計（邏輯）
- **育林/種樹增產不 coherent**（樹年代級慢生，長不出來）——這點對。
- **但伐木場 = 加快開採 coherent**（不種樹，把現有的樹砍更快）。
- **代價（正因種樹慢）= 抽乾森林、慢回 = boom-bust。**
- ∴ **material = 開採資源非耕作資源**。

## ★material 供給設計（三件）
1. **森林初始材料庫存高一點點**：老熟林存量 = 一次性可清伐的 **boom 燃料**（★**非提高 regen rate**，是初始 stock）。
2. **伐木場設施 = 加快 material 開採速率**（forest-only；平行 farming 但語意 = 開採加速非永續放大）。
3. **森林受重採耗竭 + regen 慢回 = boom-bust**：清伐換一波建設爆發 → 森林枯竭 → 等/搬/轉貿易，或細水長流永續採。

**farming = 永續耕作放大器 vs 伐木場 = 開採加速器 + 耗竭代價**，兩個都地形特化設施但一永續一 boom-bust = coherent 差異。**不調 regen rate（不 flatten 地理）、不加育林（不 coherent）。**

## plains 隊仍靠取得閥
forest 隊 = 材料生產者（伐木 boom-bust + 出口）；plains 隊取得 material 靠**控產地（擴張搶 forest tile）+ 貿易 + 遷徙 = 取得閥**。兩邊合起來 = forest 產、plains 買/搶。

## ★HOW/measure（你 scope，照 R① 先驗再 spec）
現行 `_collect_from_tile` **已扣池**（`current − gain`）+ regen 補（forest material 12/day）= **耗竭骨架已在**。要驗：
- **(a) regen 慢不慢到 boom-bust 有感**？還是 12/day 太快、清伐瞬間補回 = bust 不成立？
  - ★注意一個張力：若要 boom-bust 有感，常態 regen 可能要**降**——但我上面說「不調 regen」。**釐清**：不調 regen 是指「不靠調高 regen 來解稀缺（那是 flatten）」；但為了 boom-bust，**降常態 regen（讓永續採更薄）+ 初始庫存給 boom**，兩者一起才成立。**這條你 measure 現行行為後回報，我再裁 regen 到底動不動、往哪動。**
- **(b) 初始庫存多高** = boom 多大。
- **(c) 伐木場 boost 多少 + 清伐後枯多久。**

## 序
1. **先 measure 現行耗竭/regen 行為**，坐實 boom-bust 骨架夠不夠（現行採了會不會枯、regen 多快補回）→ **回報我裁 regen 動不動**。
2. 再 spec 伐木場 + 初始庫存。
3. 取得閥（GATE-B 貿易/擴張控地/遷徙）仍要——先 measure 缺料 plains 隊哪閥最可達。
- 競爭性發展後果不變（能控地/伐木/買到才發展）。
- game-design:292 已改成此版（material=開採 + 伐木場 boom-bust + 初始庫存）。

## 溯源
用戶「2 不是增加伐木場嗎 加大開採速度」+「對，然後森林初始資源可以多一點點」；作廢 `2026-07-24-...-direction-A-valves-only`；連 [[project_economy_arc]]、[[project_desperation_economy]]。
