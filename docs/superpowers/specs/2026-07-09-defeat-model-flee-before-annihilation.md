# Spec — 敗北出路前置（逃/潰散決策在殲滅線前 fire，膽量秤）(a) 憲法版

- from: systems
- 工單: `docs/superpowers/handbacks/2026-07-09-blueprint-to-systems-combat-defeat-vision-ruling.md`（blueprint 願景裁定，壓最高）
- 依賴: 照妖鏡 #1（`_courage_of` merged）、combat-defeat characterization（釘死 ①+③）

## 願景（blueprint owner，已裁）
- 殲滅-heavy=塌陷。敗北三端配比：**潰散/逃=劣勢方常態（尤小隊）/俘虜=中頻/殲滅=稀（逃不掉 or 勇者血戰）**。不消滅殲滅。
- 藥=**憲法版**：不硬寫「小隊必逃」，是**讓引擎的逃/潰散決策在絕對殲滅線前 fire**，由**膽量**秤（勇者血戰、怯者早逃=啟動照妖鏡 #1 courage）。

## 釘死回顧
`_resolve_combat_round` 每 round 序：①`maxi(pop-wounded,1)≤1`→殲滅(FIRST) ②`readiness≤_abandon_threshold`→`_force_retreat`(潰散) ③`_try_retreat`(FLEE 機率)。**病=① pre-empt ②**：小隊 eff pop 1~2、readiness 從沒 drain 到門檻(~10 round 需求 vs 1~2 round 殲滅)→ 潰散端 `_force_retreat`（已完整：逃脫+loot+俘殘部）**永不觸**。

## 設計（seam 系統定）
### D1. 絕境逃決策前置（膽量秤，殲滅線前 fire）
`_resolve_combat_round` **在殲滅檢查(`:193`)前**加膽量秤絕境逃決策：
```gdscript
# 絕境逃決策（憲法版：逃 vs 血戰=引擎人格秤，優先於機械殲滅線）。
# mortal_pressure = 本隊瀕滅程度（eff pop 低 + 本 round 重創 + 力量劣勢）。
# 勇者(courage→1) last-stand 血戰；怯者(→0)絕境早逃。殲滅稀=只勇者/逃不掉。
func _mortal_flee_check(state, id_self, id_enemy) -> bool:   # 回 true=已潰散前置(caller return)
    var s = state.teams[id_self]; var e = state.teams[id_enemy]
    var eff = maxi(s.population - s.wounded, 0)
    # 絕境壓力：eff pop 逼近殲滅線(≤MORTAL_EFF) + 力量劣勢(str 比)。
    if eff > MORTAL_EFF_POP: return false            # 還沒到絕境(大隊/健康)→不觸,續戰
    var str_ratio = _eff_strength(s) / maxf(_eff_strength(e), 0.01)
    var mortal_pressure = clampf((1.0 - str_ratio) + (MORTAL_EFF_POP - eff) * 0.3, 0.0, 1.5)
    # 膽量門檻：勇者高門檻(壓力要更大才逃=血戰)、怯者低門檻(早逃)。
    var flee_thr = MORTAL_FLEE_BASE + _courage_of(state, s) * MORTAL_COURAGE_SPREAD
    if mortal_pressure >= flee_thr:
        _force_retreat(state, id_self, id_enemy)     # 走既有潰散端(逃脫+loot+俘殘部)
        return true
    return false
```
常數（`npc_combat_system.gd`，TEST VALUE，full_probe 3 seed 校準三端配比）：
- `MORTAL_EFF_POP: int = 3`（eff pop ≤此才進絕境逃判；大隊不受影響=保大隊長 combat 走三端）。
- `MORTAL_FLEE_BASE: float = 0.5` / `MORTAL_COURAGE_SPREAD: float = 0.6`（勇 flee_thr→1.1 血戰、怯→0.5 早逃；均值秤到「潰散常態、殲滅稀」）。
- 呼叫序：round 內 **casualty apply 後、殲滅檢查前**，雙方各查（`_mortal_flee_check(a) → return`，再 b）。

### D2. 殲滅只在「逃不掉 or 勇者血戰」
- 絕境逃決策**不觸**（勇者血戰 or eff>MORTAL_EFF_POP）→ 落既有殲滅線 `:193`（保留=殲滅稀端）。
- **逃不掉**（future refine：被圍/pursuer 極快）v1 暫由「勇者高門檻」近似（勇者選血戰=逃不掉的行為代理）；真圍困偵測記 backlog。
- ∴ 殲滅端保留但降頻（只勇者絕境血戰觸）。

### D3. 三端自然配比
- 怯/中膽小隊瀕滅 → 潰散（`_force_retreat`：逃脫+俘殘部）=**潰散常態 + 俘虜中頻**（capture_routed_as_captive 已建）。
- 勇者小隊 → 血戰 → 殲滅（**稀**）。
- 大隊（eff>3）→ 不進絕境逃、走既有 readiness-abandon(照妖鏡#1) + 殲滅——長 combat 三端照舊。

## 觸及檔
| 檔 | 改點 |
|---|---|
| `scripts/simulation/npc_combat_system.gd` | +`_mortal_flee_check`（膽量秤絕境逃，殲滅線前）+`MORTAL_*` 常數；`_resolve_combat_round` casualty 後/殲滅前插雙方查；`_eff_strength` helper（若無，複用既有戰力算） |
| `scripts/debug/warring_harness.gd` | 複用既有 `combat.*`/`rout.*` 探針驗三端配比（end_annihilation 降/end_rout 升/capture 升）+ **reviewer 3 補**：①`mortal_flee` 探針**分開標籤**（別混 readiness_abandon 池——`_mortal_flee_check` 記 readiness 在 drain 前、既有 rout 在 drain 後，時間點不一致會誤讀）②`combat.str_ratio_at_annihilation` 分布（證殲滅集中「勢均消耗」str_ratio≈1，非「絕望硬撐」） |

**reviewer 精修（採納，非阻塞）**：
- `_eff_strength(state,team)` = 2 行 `return team_strength(state,team.team_id)*team.readiness`（純複用，可棄既有 str_a/str_b 的 terrain 不對稱=更一致，非退化）。
- `_mortal_flee_check` 探針**分流記錄**（drain 前值，標 mortal_flee 別混 readiness_abandon 的 drain 後值）。
- 勇者血戰=條件性保留（str_ratio≈0 絕望勇者也逃=合理；str_ratio≈1 勢均消耗才血戰到殲滅=殲滅稀）——full_probe 記 str_ratio-at-annihilation 證之。

**不碰**：`_force_retreat` 潰散機制（已完整，只是讓它更常觸）、照妖鏡#1 abandon_threshold（大隊 exhaustion 路保留）、殲滅線本身（保留=稀端）、combat 傷亡率常數。

## ★呈報 blueprint sign-off（三端配比=玩家可見敗北分布，鎖 spec 前）
藥改敗北分布（殲滅→潰散/俘虜）=玩家可見。blueprint 已裁配比（潰散常態/俘虜中頻/殲滅稀）。**請確認機制/常數量級**：`MORTAL_EFF_POP=3`（哪種隊算絕境小隊）+ `MORTAL_FLEE_BASE/SPREAD`（勇怯逃-戰分野）是否對齊配比意圖？校準交 full_probe，但門檻語意先你 sign-off。

## 驗收線（blueprint 判，full_probe 3 seed 1337/42/7）
1. **三端復活**：`combat.end_annihilation` 顯著降、`combat.end_rout` 升為常態、`capture.total` 升（俘虜中頻）；殲滅稀但非 0（勇者血戰保留）。
2. **照妖鏡 #1 啟動**：`rout.n_*` courage 桶開始有數據（怯者桶潰散多、勇者桶少=膽量真秤逃-戰）。
3. **絕境 flight 前置**：弱小隊倖存率升（潰散逃脫→為乞討/投靠/變匪鋪路，絕境階梯前置活）。
4. **大隊不受影響**：eff>MORTAL_EFF_POP 的 combat 三端分布 ≈ baseline（絕境逃只作用小隊）。
5. 憲法/framework/sanity 綠；相關≠因果+3 seed。

## 流程（無斷點）
spec → **blueprint sign-off 三端配比/門檻** → reviewer → 下游 → full_probe 3 seed → blueprint 判。(c) consolidation 腿記 backlog。
