# spec：extraction de-patch — need-driven（coin liquidity·死常數人格化）

> 層級：L3（1 func 重寫 + coin_need 信號，決策模型 measure-sensitive）。off main。
> 來源：coin-cause 坐實=salary illiquidity（coin 鎖 anon_treasury 取不回）。blueprint 裁 fix=**de-patch extraction gate→need-driven 非 tune 0.4**（`...-coin-liquidity-WHAT-depatch-extraction-need-driven`）。= poverty-trap coin 逃生閥。
> ★這是 afford 兩腿之一（食安 GATE-A + coin），最終讓隊脫貧→afford→建設→發展。

## 根（file:line 坐實）
- `_consider_extraction`（faction_ai:2357-2367）：`extract_score = greed - prudence×0.5`，`if >0.4: extract(greed×0.3)`。=**flat 人格死常數硬門檻**，**不讀任何 need 信號**。
- **中位領袖（greed 0.5/prud 0.5 → 0.25 < 0.4）永不 extract** → salary 存入的 anon_treasury coin 永鎖 → spendable team.coin 慢性低 → **has_specie=false → 買糧/買料 not applicable → 材料湊不到 → 湊不到 afford**（連 poverty-trap 兩鎖 + material means-end）。
- **coin_need 信號不存在**（need_keep 是 resource 非 coin）→ 需 means-end 延伸（extraction target 由「要花 coin 做 X」推導，接今天 material means-end 架構）。

## 修（de-patch：need-driven extraction + persona buffer texture）
### ① coin_need 信號（means-end 延伸，reuse 既有 buy-intent）
`coin_need(team)` = 隊當前**真 coin-用途**估算（要 spendable coin 才做得成的 buy-intent）：
- **material-buy**（construction means-end）：`NeedOracle._construction_facility_need(material) > 0` → 想建設但缺料 → 需 coin 買料。估 coin ≈ material_shortfall × material_ask（或簡化 proxy：material_shortfall 標度）。
- **food-buy**（食壓）：`food_days < DESPERATION` → 需 coin 買糧。估 coin ≈ food_shortfall × food_ask。
- coin_need = Σ 上述（clamp 上限防爆）。

### ② `_consider_extraction` 重寫（need-driven，砍 flat gate）
```gdscript
func _consider_extraction(state, team):
    # guards（anon_treasury>0 / 非玩家 / leader）不動
    var spendable = team.resources.get("coin", 0)
    var need = coin_need(state, team)          # ①
    var shortfall = need - spendable
    if shortfall <= 0: return                  # spendable 已夠 → 不 extract（不亂徵）
    # ★need-driven:有真缺才 extract;人格當 texture=保留 buffer 厚薄
    var buffer = _extract_buffer(leader)       # prudent 留厚 / greedy 留薄(見③)
    var target = shortfall + buffer            # 補到夠用 + 人格 margin,★非清空
    var amt = minf(target, team.anon_treasury)
    _extract_treasury(state, team, amt/team.anon_treasury, "need_driven")
```
- **砍掉 `extract_score = greed-prud×0.5 > 0.4` flat 門檻**（死常數人格化：改 need 驅 + 人格 texture）。

### ③ persona buffer texture（守護：別 swing 到 always-extract-all）
`_extract_buffer(leader)` = 人格化保留 buffer（extract 後留在 anon_treasury 的緩衝）：慎重↑→buffer 厚、貪婪↑→buffer 薄。**★下限（reviewer R² 必補）**：`buffer = lerp(BUFFER_MIN, BUFFER_MAX, prudence)`，**`BUFFER_MIN > 0`（TEST VALUE，如 5-10 coin）**——**貪婪只降到正下限非降到 0**（否則極貪婪 leader extract 後 anon_treasury 真清零=違「非清空」texture 守護；spec 原質性描述允許 buffer→0=文字自矛盾，補下限修正）。=**人格決定「補到多夠用」非「抽不抽」**（抽由 need 決；texture 是 margin）。★extract=補 shortfall+buffer margin，**非清空 treasury**。

## 為何 de-patch 非 tune
- 不是調低 0.4（tune 壞閘=中位人格還是可能卡）——是**移除 flat 人格門檻，改 need 驅動**（隊有真 coin-用途才抽）。= 本場整條 arc 型（flat 常數 gate→utility/need 湧現）+ 憲法「utility 餵 utility 非 scripted」+ 死常數人格化。emergency 路徑（飢餓緊急）保留。

## 驗收
- **TDD**：①中位領袖（greed.5/prud.5）+ coin_need>spendable → **extract**（原永不）②無 coin_need（無 buy-intent+食足）→ **不 extract**（不亂徵）③persona buffer：慎重領袖 extract 後留 buffer > 貪婪領袖 **+ ★即使最貪婪 leader（greed=1.0）buffer > 0**（斷言 `buffer_greedy > 0`，非只相對值，測「真清空」反例）④shortfall≤0（spendable 已夠）→ 不 extract ⑤守恆（anon_treasury→team.coin 搬，CoinAudit=0）⑥emergency 路徑不變。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（純算術/人格值，無 randf）。
- **★★measure（→measurer §④b+specimen→QA 長跑）**：extraction fire 率（中位人格 0→?）/ spendable team.coin 分布升 / **coin_urg 降（91%→?）**→ reserve_factor 升 → **has_specie up → 買糧/買料 up → material 累積 up → afford up → facility 建成 up**（脫貧鏈端到端）/ ★守恆 CoinAudit=0 + texture（慎重隊仍留 buffer，無 swing always-extract-all，通膨/coin 池不爆）/ 無新餓死。
- **送 QA 判故事**：中位隊有真需（想建/餓）→ 取回自己 anon_treasury coin → 買得起 → 脫貧鏈動 coherent；貪婪 vs 慎重 buffer texture 差異可見。

## 排序
一刀（need-driven extraction）。R²（coin_need 估算/means-end 遞迴[coin_need 讀 material/food need，非 facility-output，無環]/persona buffer 不 swing/守恆/無 RNG/emergency 保留/砍 flat gate 不破 G1a coin 池）→ dispatch。食安 GATE-A + 此 coin = afford 兩腿。queue-limit/bootstrap 排後。
