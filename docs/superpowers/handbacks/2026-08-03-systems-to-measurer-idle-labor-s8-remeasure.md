---
from: systems
to: measurer
status: open
topic: "[§8 re-measure領導軸(B idle-labor→建設 merged dbc31952主線)·真驗B是否讓領導軸size-matter追平(execution-end,同§8框架+同SLICE A measured才宣稱精神)·核心問:B前領導軸ratio 0.38-0.45<1(大隊idle勞力浪費建設太晚),B後大隊idle_labor→建設util升→早建facility新增workstation吸收勞力→產出↑→領導軸ratio追平/≥1?·量(main dbc31952,或godot --path對主線,★禁原地checkout):①領導軸ratio(1隊pop40定居設施據點 vs 8×pop5分散等總量,同§8 fixture)B前0.38-0.45 vs B後?②大隊facility-build時機提前?(idle_labor>0→建設util含idle_employ_value→早建manufacturing新線,對比§8 day50才建)③守憲:大隊一格採食人均仍遞減+游牧仍餓+人手少全線比例(勞力池不變)④guardrail真世界:idle-labor只影響建設,非建設決策(combat/survival/trade/move)行為不變⑤世界沒凍雙seed+determinism三跑byte-identical·★implementer flag:Probe-on全經濟diag loop>590s超wrapper timeout→加大GODOT_TIMEOUT或關Probe跑ratio(fire-count可另probe短窗)·若ratio沒追平=誠實finding(idle_employ_value量級不足/建設仍太慢/need_weight壓too low)非paper over(守genuine_value_not_crank)·落地docs/measurements標path→我+blueprint判size真matter達成"
---

# §8 re-measure 領導軸（B idle-labor→建設 merged dbc31952）

**真驗 B 是否讓領導軸 size-matter 追平**（execution-end、同 §8 框架 + 同 SLICE A「measured 才宣稱」精神）。

**核心問**：B 前領導軸 ratio **0.38-0.45<1**（大隊 idle 勞力浪費、建設太晚）；**B 後大隊 idle_labor→建設 util 升→早建 facility 新增 workstation 吸收勞力→產出↑→領導軸 ratio 追平/≥1？**

## 量（main dbc31952、★禁原地 checkout）
1. **★領導軸 ratio**：1 隊 pop40（定居設施據點）vs 8×pop5 分散（等總量、同 §8 fixture）→ B 前 0.38-0.45 vs **B 後 ?**
2. **大隊 facility-build 時機提前？**（idle_labor>0→建設 util 含 idle_employ_value→早建 manufacturing 新線、對比 §8「day50 才建」）。
3. **守憲**：大隊一格採食人均仍遞減 + 游牧仍餓 + 人手少全線比例（勞力池不變）。
4. **guardrail 真世界**：idle-labor 只影響建設、非建設決策（combat/survival/trade/move）行為不變。
5. 世界沒凍雙 seed + determinism 三跑 byte-identical。

## note
- **★implementer flag**：Probe-on 全經濟 diag loop >590s 超 wrapper timeout → 加大 `GODOT_TIMEOUT` 或關 Probe 跑 ratio（fire-count 可另 probe 短窗）。
- **★若 ratio 沒追平＝誠實 finding**（idle_employ_value 量級不足/建設仍太慢/need_weight 壓 too low）**非 paper over**（守 [[feedback_genuine_value_not_crank]]）。
- 落地 `docs/measurements/` 標 path → 我 + blueprint 判 size 真 matter 達成。卡/timeout → 回 `to:systems`。
