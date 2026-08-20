# spec：material-buy v2a — full build-need + 買料 utility 校正（Gate B 半破→閉環①③）

> 層級：L3（2 處 tune，決策模型 measure-sensitive）。off LOCAL main（★接 v1 ca199844 之後 / 或 v1 merge 後）。
> 來源：v1（ca199844）QA 故事判=3 層 stack coherent、Gate B **半破**（want 接上 no_want 82→72% 但 buy-to-80 未達）。blueprint 續做。**本刀 = ①③（②coin 另 slice）**。

## v1 半破根（QA + code）
- **① dilution**：`_construction_facility_need` line 51 `total += cost_mat × desire`（desire=0.3→80×0.3=24 非 80）→ reserve 只認 ~24、want<80 → 買不到 80 建 weaponsmith。
- **③ util 太低**：買料 applicable 6044× 只勝 102（1.7%）→ 跟建設/覓食比 weight 太低，rank 搶不到。
- **② coin 貧困**（另 slice）：mil loot→anon_treasury 但不流到 team.coin buy 口袋 → has_specie 擋。

## 修（①③，都繫「想建 facility」的 means-end 信號）
### ① full build-need（desire = gate 非 multiplier）
`need_oracle._construction_facility_need`：`total += cost_mat * desire` → **`total += cost_mat`**（desire 已在上方 `if desire < CONSTRUCTION_DESIRE_MIN: continue` 當 **gate**——過閘=夠想建→carry **全 cost**，非按 desire 比例稀釋）。
- 理由：**想建 weaponsmith 就需全 80 material 才建得成**，非「想 0.3 就買 24」（24 建不了、白買）。desire gate 決定「算不算這 facility」，非「買多少」。
- cap（CONSTRUCTION_MATERIAL_NEED_CAP=100）仍在（多 facility 疊爆防護）→ gate 後 full-cost 疊加 clamp。

### ③ buymaterial_drive 校正（繫 construction desire，競建設）+ ★food-ok gate（reviewer R² 結構要求）
**★★food-ok gate（reviewer R² 必加，結構防餓死）**：買料**非-survival-class**（`SURVIVAL_OPTION_SET` 不含）→ `rank_scored` 統一 util 競 survival；買料若 util 高，**餓隊會買料而非買糧/覓食 → 餓死**。spec 原「survival_pressure 壓過」是**磁量希望非結構**（buymaterial_drive 用 intrinsic `_facility_deficit`，非 survival-yielded）。∴ **買料 `applicable` 加 `ctx.food_days >= DecisionTerms.DESPERATION_DAYS`**（食足才買料，**鏡射買糧的 `food < DESPERATION` gate = 互斥**——餓時只買糧不買料，食足才投資建設料）。結構保證：餓隊買料 not applicable → 不搶 survival rank。
```gdscript
"買料": {
    "applicable": func(ctx): return ctx.food_days >= DecisionTerms.DESPERATION_DAYS \
        and ctx.material_shortfall > 0.0 and ctx.has_material_market and ctx.has_specie,
    ...
}
```

**buymaterial_drive util 校正**（食足前提下競建設）：現 = shortfall band 0.5-1.0（太低）。**改繫 construction 迫切**——買料是建設的**前置**（想建但缺料 → 買料與建設同級 urgent，非墊底）：
- `buymaterial_drive` = 標度化（`material_shortfall / CAP`）**× 建設迫切**（reuse means-end：team 對 material-facility 的 max `_facility_deficit`）→ 想建強+缺料多 → 競得過建設。
- weight「buymaterial」穿人格（貪婪/商業）保留。
- **★語意**：買料 util ≈ 建設 util（買料=建設必要前置），不再 1.7% 墊底。**但 food-ok gate 已結構擋餓隊**（util 高不會害餓死，因餓時 not applicable）。measurer/QA 校準勝率合理區間（別過衝變只買不建）。

## ★② coin 另 slice（本刀不含）
mil coin 貧困=獨立層（loot→anon_treasury 不流 team.coin）→ v2b 另 investigate（measure：mil loot coin 量/extract 到 team.coin 率/為何貧困）。**本刀 measure 預期**：①③ 讓**有 coin 的 mil 隊** buy-to-80 達 + 建成（驗機制）；**無 coin 隊仍卡**（確認 coin=唯一剩 blocker→v2b）。

## 驗收
- **TDD**：①想建 weaponsmith→need_keep(material)=full 80（非 24）②多 facility→cap 100 ③買料 drive 隨 construction 迫切升 ④**★food-ok gate：food<DESPERATION 隊→買料 not applicable（餓時不買料，鏡射買糧互斥）；food>=DESPERATION→applicable**。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★★measure（→measurer，帶 §④b+specimen；長跑→QA 新規則）**：material buy DEAL / no_want 率（72→?）/ **買料勝率**（1.7%→?合理）/ **有-coin mil 隊 buy-to-80 達成率** / weaponsmith 建成 / doom-delta / 回歸。**送 QA 判故事**（想建→買料達 80→建成 coherent；無 coin 隊卡=確認 v2b）。

## 排序
①③ 一刀（都繫 means-end 建設信號，同批 measure 乾淨）。R²（full-need gate 語意/util 繫建設是否過衝/cap 交互/無 RNG）→ dispatch。②coin = 下 slice。
