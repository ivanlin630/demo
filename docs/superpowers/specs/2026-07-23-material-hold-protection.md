# spec：material-hold-protection — construction-material 對 coin_urg 免疫（脫貧第三腿）

> 層級：L3（reserve 分流 + coin_need 對齊，決策模型 measure-sensitive）。off main（extraction merge 後）。
> 來源：extraction merge（coin 腿）後 QA/measure 坐實脫貧鏈未閉=material 也被 reserve_factor urgency-suppression 賣掉。blueprint 三腿 reframe + WHAT 精修（`...-merge-extraction-material-hold-WHAT-guard-acute-survival`）：**decouple 兩 urgency**——construction-material 對 coin-urgency 免疫、acute food-survival 仍釋放。
> ★脫貧第三腿（食 GATE-A + coin extraction + 本刀 material-hold）；三腿齊才端到端。

## 根（file:line 坐實）
- `trade_valuation:94`：非活命品 `reserve = need_keep × _reserve_factor`（material 走這）；`:90-91` food/SURVIVAL_GOODS `= need_keep`（protected）。
- `_reserve_factor`（:97）`= 0.6+(hoard-.5)×.5 - _urgency×.4`；`_urgency`（:103-108）`= max(food_urg, coin_urg)`。
- ∴ **coin_urg 高（91% chronic）→ 壓 reserve_factor（0.25）→ construction-material（means-end 抬高 need_keep）reserve 低 → 賣掉 → coin 買了又賣 → 不累積 → afford×1.5 湊不到**。

## 修（decouple 兩 urgency，帶 acute-food 守護）
### ① construction-material reserve 用 food-only urgency（對 coin_urg 免疫）
- **`_reserve_factor_food_only`**（新，= `_reserve_factor` 但 `_urgency` 只用 **food_urg**，不 max coin_urg）。
- `reserve(material)`：**若 material 有 active construction-need**（`NeedOracle._construction_facility_need(material) > 0`）→ `reserve = need_keep × _reserve_factor_food_only`；**否則**（無 construction-need 的 material）→ 照舊 `× _reserve_factor`（max 兩 urgency）。
- ∴ **coin 焦慮但食 OK 的隊**：construction-material reserve 不被 coin_urg 壓 → **守住要蓋的料不賣**（本 case 的病治了）。

### ② acute food-survival 仍釋放（★blueprint 守護，防抱料餓死）
- food-only factor 仍含 **food_urg**：`food_days < DESPERATION → food_urg 高 → factor 降 → construction-material reserve 降 → 可賣**。
- ∴ **真餓的隊**（acute food）：protected material **釋放**（賣去買糧求生）→ **不抱料餓死**（survival first 不變）。
- = ranking **material > coin-anxiety-selling 但 < acute-food-survival**（非 material=food 全保護）。

### ③ coin_need 對齊 afford×1.5（blueprint 認可，extraction 拉夠）
- `_consider_extraction` 的 `coin_need` material 分量 = **對齊 afford 缺口**：`material_need_to_afford = cost×1.5 − material_holding`（想蓋 facility 的 material 缺到 afford×1.5，非只 need_keep shortfall）→ 估 coin ≈ 該缺口 × material_ask → extraction 拉夠 coin 去買足量 material。

## 為何非全保護（blueprint 守護）
- 全保護（reserve=need_keep 不乘 factor）= survival 級 → 餓隊抱著不能吃、規則說要留的 material 餓死=新失敗模式。**food-only factor 保留 food_urg 驅動 → acute food 自動釋放**，避此迴歸。

## 驗收
- **TDD**：①construction-material + coin_urg 高 + food OK（food_days≥DESPERATION）→ reserve **高**（food-only factor，不被 coin 壓）→ 不賣 ②construction-material + **acute food**（food_days<DESPERATION）→ food_urg 高 → reserve **降** → **可賣**（★守護：餓隊能賣 protected material 求生）③非-construction material → 照舊（max 兩 urgency）④無 construction-need → 照舊 ⑤coin_need material 分量 = cost×1.5−holding（對齊 afford）⑥守恆/無 RNG。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術/urgency 讀狀態，無 randf）。
- **★★measure（→measurer §④b+specimen→QA 長跑，三腿齊[extraction merged + food GATE-A + 本刀]）**：construction-material 累積（賣壓降/holding 升）/ afford×1.5 達成率升 / **★facility 建成端到端升（blueprint 判準：三腿齊 facility 升=成功、不升=還有漏）** / coin_urg/material reserve 分布 / **★★守護硬迴歸**：**有沒有隊抱著 protected material 餓死**（acute food 隊 protected material 有無釋放；QA 故事稽核必查）/ 無新餓死 total。
- **送 QA 判故事**：committed 想蓋隊守住料熬過 coin 焦慮→買齊→建成 coherent；**★acute 餓隊仍賣料求生不抱料餓死**（守護）；貪婪 vs 慎重 texture。

## 排序 + generalize 標記
- 三腿之三。R²（food-only factor decouple 語意/construction-need 判定[reuse _construction_facility_need]/acute-food 釋放真防抱料餓死/coin_need afford×1.5 對齊/遞迴[reserve 讀 need_keep 讀 construction，同既有 guard]/無 RNG）→ dispatch。
- **★generalize 標記（blueprint，先別做）**：means-end committed 資源（任何 goal-buy、means-end 抬 need_keep 的）都可 hold-protect 此式，但**先 scoped material**（別 over-reach，本場數次過度下注教訓），material 腿驗證有效再推廣。
