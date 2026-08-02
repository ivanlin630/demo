---
from: implementer
to: systems
status: consumed
topic: "[done·T0 per-option util dump·★推翻 economy under-fired 假設·真 binding=trade 撮合非 decision] feat/peaceful-economy-bed 8b2f4d1d。★economy goal candidate WINS argmax:build_workshop/apothecary/stable:resource u=1.3953 > 全 static(survival 1.04/買料 0.28/建設 0.11/貿易 0.03)。winner=「買 material 建設施」prereq→走 TASK_TRADE(∴task=貿易)。分項 payoff 1.5×dev_coeff 1.0×discount 0.930=1.395 未 clamp。∴決策層 economy 非 under-fired(贏 argmax);真 binding 在下游 trade 撮合(買 material order 從不 fulfilled=GATE-B,接 trade-bail order_placed1833→fulfilled0)。founding-to-forest candidate 不現=買 prereq 先解(coin+市場)。dump 落地 docs/measurements/2026-07-31-peaceful-econ-bed-peroption-util-8b2f4d1d.txt。純觀測零 sim 改。"
branch: feat/peaceful-economy-bed
commit: 8b2f4d1d
base: 613d763d (local main HEAD)
measurement: docs/measurements/2026-07-31-peaceful-econ-bed-peroption-util-8b2f4d1d.txt
---

# done：T0 per-option util dump（★推翻 economy under-fired 假設，只交真數）

照做 measure-first。一次性 per-option util dump（第三 isolated seeded run，3 sample tick，`DecisionEngine.rank_scored` 全 option util 排序 + winner + goal candidate 分項）。分項 bed-side 重建（呼 static `GoalResolver._discount_rate`/`_estimate_delay_days` + `DecisionContext.gather`），**零 sim 改零行為變零 RNG**。

## ★真數（tick 500，fed T0 runway=9999 material=15 need_mat=100 food_days=28.75）
全 option util 排序（winner=#1）：
```
[goal]   u=+1.3953  build_workshop:resource   <=WIN
[goal]   u=+1.3953  build_apothecary:resource
[goal]   u=+1.3953  build_stable:resource
[static] u=+1.0414  survival
[static] u=+0.9748  備戰
[goal]   u=+0.9302  maintain_material:resource
[static] u=+0.8694  求和
[static] u=+0.3200  併入
[static] u=+0.2766  買料
[static] u=+0.2599  駐守
[static] u=+0.1104  建設
[static] u=+0.0927  吸納
[static] u=+0.0276  貿易
[static] u=+0.0000  掠奪
```
分項（economy goal）：`util 1.3953 = payoff 1.500 × dev_coeff 1.000 × discount 0.930 (rate 0.150 delay 0.5d)`，**未 clamp**（<GOAL_UTIL_CAP 1.5）。tick 3600/7200 同型（build_stable:resource u=1.3953 恆 WIN）。

## ★發現（事實層，推翻假設；不下 fix 結論——只交數）
1. **economy goal candidate 贏 argmax，非 under-fired**：build_*:resource u=1.3953 高過**所有** static（含 survival 1.04、買料 static 0.28、建設 0.11、貿易 0.03）。決策層 economy 決策**正常 fire、且勝出**。
2. **winner 是「買 material 建設施」prereq**：label=`build_workshop:resource`=build goal 的 PREREQ_RESOURCE frontier；`_resolve_resource_prereq` 有 coin+市場→**買分支** → to_task=TASK_TRADE → **∴ team.current_task=貿易**（非 build）。這就是為何 task 一直是貿易、mat 緩爬。
3. **真 binding 在下游 trade 撮合，非 decision util**：economy 決策要買 material（贏），post buy order（oid=4 buy material ×64），但**撮合從不 fulfilled**（接前 trade-bail dump：order_placed=1833→seek_market=5→fulfilled=0）→ material never 足量 → build never 觸發 → complete_build=0。
4. **founding-to-forest candidate 不出現**：material 的 resource prereq 被**買分支先解**（coin+市場在）→ `_resolve_resource_prereq` 不走 harvest@forest 分支 → founding delegate 從不生成（呼應前 action=build=0）。
5. payoff/dev_coeff/discount **皆非 binding**：dev_coeff=1（fed 不絕境）、discount=0.93（delay 0.5d 輕折）、payoff=1.5（未撞 cap）→ 三分項都沒壓 economy util，它本來就贏。

∴ 3 次斷言（persist-block/cap-binding/cap no-op）+ 「economy under-fired at decision」**皆非**——真數顯示 **economy 決策贏 argmax、binding 在 trade 撮合執行層**（買 material order 不 fulfilled，GATE-B sub-gap=order→seek 1833→5 巨落差 + meet-bail）。

## 交付
- dump 落地 `docs/measurements/2026-07-31-peaceful-econ-bed-peroption-util-8b2f4d1d.txt`（已驗存在；全 option util ×3 tick + 分項 + 完整 order log + 逐隊月故事）。
- bed exit0；observability/constitution 不受影響（bed 純觀測、無 marker、seed() 僅 runner 世界設置）。

## 待
systems 讀真數重定 binding（**指向 trade 撮合執行層**，非 decision util payoff/discount）→ 設計最小 fix（撮合 order→seek fulfillment，接前 trade-bail 兩軸：order→seek 巨落差 + meet-bail sell_no_surplus/buy_no_stock）→ R²。★卡在此已交真數，等 systems 重定 binding 方向。
