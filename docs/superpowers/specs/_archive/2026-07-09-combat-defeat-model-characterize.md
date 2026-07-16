# Spec — combat 殲滅-heavy characterization（絕境根 blocker，釘死再開藥）

- from: systems
- 工單: `docs/superpowers/handbacks/2026-07-09-blueprint-to-systems-zhaoyaojing-1-judge-and-pivot.md`（blueprint 壓最高 priority）
- 性質: **characterization only（探針+釘根因，無 fix）**——A2c-1 血教訓：先 characterize 再開藥。釘死回 blueprint 判願景。

## 願景框架（blueprint owner）
- **絕境根 blocker**：`rout.total=0`、combat 打到殲滅不逃 → 沒「弱隊倖存變絕境」→ 乞討/投靠/變匪前置全斷。整個絕境經濟卡這。
- **違背敗北模型**（game-design:1130 損耗/俘虜/潰散=同模型三端）→ combat 塌成殲滅-only=三端剩一端。
- **釘死問**：為何 combat 幾乎殲滅收場？候選 ①每 round 太致死（casualty 快過 readiness drain）②潰退/俘虜/潰散路徑存在但罕觸 ③小隊 pop 太少撐不過 drain。

## 現況 race（grep，待量證）
`npc_combat_system._resolve_combat_round` 每 round 依序查：
1. `maxi(pop-wounded,1) <= 1` → `_end_combat`（殲滅端）。
2. `readiness <= _abandon_threshold`（~0.2）→ `_force_retreat`（潰退端）。
3. `_try_retreat`（僅 FLEE，機率脫離）。
常數：`ROUND_CASUALTY_RATE=0.1`、`ROUND_READINESS_DRAIN=0.08`（wounded>0.3 ×2）、`readiness 初=1.0`。粗算 readiness→0.2 需 ~10 round（cascade 5）；但 wounded 累積使 `pop-wounded` 快掉→殲滅端可能恆先觸。**精確 race 要量**。

## D0. characterization 探針（新增，無 fix）
1. **結束原因分布**：`combat.end_annihilation`（pop-wounded≤1）/`combat.end_rout`（readiness 門檻）/`combat.end_retreat`（FLEE 機率）計數。
2. **race 直量**（每場 combat）：`combat.rounds_to_eff1`（effective pop 掉到 1 的 round 數）vs `combat.rounds_to_rd_thr`（readiness 掉到門檻的 round 數）——**哪個恆先=釘死殲滅為何贏**。
3. **wounded 累積率**：`combat.wnd_ratio_at_end` 分布（wounded 是否快到 cascade 0.3→加速殲滅）。
4. **combat 規模**：`combat.pop_at_start` 分布（小隊 pop 太少=候選③證據）。
5. 對照：`capture.total`/subjugate 現況（敗北三端另二端多罕）。

## 釘死判準（→ blueprint 判願景）
- 若 `rounds_to_eff1 << rounds_to_rd_thr` 恆成立 → **①每 round 太致死**（casualty/wounded 快過 readiness drain）→ 藥=調 casualty/drain 比或 wounded→effective 邏輯（待 blueprint 定願景後另 slice）。
- 若 readiness 根本不 drain 到門檻（drain 太慢/combat 太短）→ 交界候選①/③。
- 若小隊 pop 恆 <典型撐不過 → **③**。
- **釘死後回 blueprint**：判「殲滅-heavy = bug/塌陷 vs 世界本該如此」+ 潰散/俘虜該多常發生（敗北模型意圖=blueprint owner）→ 定願景方向再開修藥 slice。

## 觸及檔（純探針）
| 檔 | 改點 |
|---|---|
| `scripts/simulation/npc_combat_system.gd` | `_resolve_combat_round`/`_end_combat`/`_force_retreat` +結束原因/race/wounded/pop 探針 bump |
| `scripts/debug/warring_harness.gd` | `combat.*` PROBE_KEYS |

**不碰**：combat 邏輯/常數（此步純量，不改行為；修藥待 blueprint 願景方向）。

## 驗收（characterization done）
- `--headless --import` 綠、sanity、constitution 綠（純加探針）。
- 產 `combat-defeat.fullprobe.json`（3 seed 1337/42/7）：結束原因分布 + race 數據 → 釘死 ①②③ 哪個。
- **無 fix**——釘死回 blueprint 判願景方向，再開修藥 slice。

## 流程（無斷點）
spec → implementer 加探針跑 characterization → 回 systems 釘死 → systems 綜合回 blueprint 判敗北模型願景 → 修藥 slice。
