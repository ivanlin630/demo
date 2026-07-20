# spec：god-view Slice B — 創世全知 → ②+③ 創世知識

> 層級：L2（創世 discovered seed，8 config 影響，measure）。off main HEAD。god-view 殲滅 arc（B，A/F/E/D/null-belief-flee 已 merged）。
> 來源：god-view audit Slice B。blueprint WHAT 裁（2026-07-19-godview-rulings-B-C）：**創世全知=bug 非 intentional**，emergence/sandbox bed 全改 ②+③ 創世知識；窄例外=純機制 unit test 留 explicit 全知但標明非預設。

## 感知鐵律違憲（創世全知）
`game_setup._setup_explicit_teams`（`:569-578`）**all-pairs discovered**：每隊創世即 discover 每隊（`team_discovered[ta].append(tb)` 全配對）→ 開局全知。**8/11 config 用 explicit**（demo/econ_bed/game_sim_test/merchant/survival_start/tyrant/warzone/world_sim）→ 多數 sandbox/demo run **開局全知**（污染 emergence：初識/外交/威脅該靠 belief 傳播長出，全知抹掉冷啟動戲）。

## blueprint WHAT 裁：②+③ 創世知識
創世隊該知道的（非全知）：
- **② 派系**：知自己 faction 的其他 member（同勢力共享情報，合 invariants「刻意豁免同-faction」）。
- **③ 本地鄰居**：創世 proximity 內的隊（出生就認識附近的隊）。
- **③ 淵源對象**：有淵源關係的隊（parent/founding/split，若 config 有）。

## 修
`:575-578` all-pairs loop 替換為 ②+③ seed：
```gdscript
# ② faction 成員：同 faction 互相 discovered
for ta_cfg in teams_cfg:
    var ta_id = ta_cfg["id"]; var fa = ta_cfg.get("faction_id", -1)
    for tb_cfg in teams_cfg:
        var tb_id = tb_cfg["id"]
        if ta_id == tb_id: continue
        var known := false
        # ② 同 faction
        if fa != -1 and int(tb_cfg.get("faction_id", -1)) == fa: known = true
        # ③ 本地鄰居（創世 proximity；CREATION_KNOW_RADIUS TEST VALUE，≥VISION_RADIUS）
        elif _hex_dist(ta_pos, tb_pos) <= CREATION_KNOW_RADIUS: known = true
        # ③ 淵源（若 config 有 parent/origin 關係）
        elif <config origin 關係>: known = true
        if known: state.team_discovered[ta_id].append(tb_id)
```
- **`CREATION_KNOW_RADIUS`** = TEST VALUE（創世認識半徑；出生認識附近，可 ≥ live `VISION_RADIUS=3`——創世認識比即時視野稍廣合理，measure tune）。
- **淵源**：explicit config 若有 `parent_team_id`/founding 關係則納；無則只 ②+③本地。
- **★窄例外（純機制 unit test）**：加 config flag `omniscient_discovery`（**default false**）→ true 時保留 all-pairs 全知。**測試須顯式標**（純機制測某互動不想被 discovery gate 干擾）→ 標明非預設（sandbox/emergence config 一律不設=②+③）。

## ★measure（8 config 影響，emergence 敏感）
創世知識縮（全知→②+③）→ 隊開局知較少 → 初識/外交/威脅靠 belief 傳播漸長。**驗 emergence 仍運作**（非崩）：
- before/after doom-delta（seed1337/42/4201）：真隊存亡不崩（開局不全知該是更真實冷啟動非災難）。
- **emergence 對照**：初期 discovery 曲線（隊逐漸認識彼此經 vision/relay）、外交/貿易/威脅觸發不因開局不全知而卡死（情報網 message/relay 撐得起遠識）。
- 逐 config sanity（8 個 explicit config headless 跑不崩）。

## 驗收
- **TDD**：①②同 faction 創世 discovered ②③本地鄰居（proximity≤半徑）discovered、遠隊不 ③`omniscient_discovery=true` 保 all-pairs（純機制測用）④default（無 flag）= ②+③ 非全知。
- **gate** PASS / **headless** 0 new（★注意：8 explicit config 測 fixture 可能靠開局全知——依賴全知的測改設 `omniscient_discovery:true` 或補 belief setup；區分「測 fixture 該顯式全知」vs「測真實遊戲情境」逐個判，同 slice2 fixture 教訓）/ **determinism** 2 跑 byte-identical。
- **measure**：上述 emergence 對照 + doom-delta。

## out-of-scope
C（市場 belief-gate+store）/1119 = 後。

## 排序
B（獨立，blueprint 確認先）。off main HEAD。R²（②+③ 判準+config flag+fixture 依賴全知的處理）→ dispatch + measure。
