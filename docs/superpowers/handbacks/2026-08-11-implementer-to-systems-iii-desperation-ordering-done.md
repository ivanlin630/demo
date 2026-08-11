---
from: implementer
to: systems
status: consumed
topic: "[iii 絕境排序 DONE·feat/desperation-ordering commit 998b0ae7]兩靶 genuine 雙向 repricing 建完·靶1 herald catastrophe-hedge(_try_herald_side)=mini+=hedge、抽 static herald_hedge(severity,pmult)=clampf((severity-HEDGE_ONSET0.55)/(1-0.55),0,1)×HEDGE_CATASTROPHE_MAG1.0×pmult(②bounded:severity<onset→0 非 flat;pmult=0→0 人格 modulate)·靶2 defect consequence(event_faction_defect)=defect_util-=consequence、抽 static defect_consequence(food_days)=clampf(1-food_days/DESPERATION_DAYS,0,1)×DEFECT_CONSEQUENCE_MAG0.2(③連續走 food_days 零 if-branch;food_days=自隊自知 own food 感知鐵律)·驗全綠:unit test ALL PASS(②hedge bounded machine-demonstrate 曲線+③consequence 連續嚴格遞減+razor near-miss 翻+anti-crank 雙向)/headless 0-new/constitution 75/determinism 3-run byte-identical(md5 75126a00 零 RNG)·★fp intended-divergence 坐實 LIVE(seed8181 dispersed 45天 near-miss:baseline FP=168ad0a2→branch FP=5433290e DIVERGED、hedge peak0.317/consequence peak0.200 LIVE、herald letter 1→2)·★★兩透明 flag 呈報:(A)標準 fp 床(recovery/warring/peaceful)iii DORMANT byte-identical=分化只在 near-miss death-spiral 場景顯(recovery letter=false 無 near-miss team)(B)raw defect_fire 5→7 升非降+Team2 baseline pop1-factionless→branch gone(-99)=trajectory shift 非 clean 餓叛率降、TEST VALUE 待 measurer 校準+逐隊 emergent 序判·請 R²(②bounded machine-demonstrate+③連續無 branch+genuine 非 crank+fp 分化 intended)→measurer 量(④順序 emergent 硬 gate+餓叛率+人格分化+校 TEST VALUE)→QA specimen→merge"
branch: feat/desperation-ordering
commit: 998b0ae7
---

# iii 絕境排序 DONE（herald catastrophe-hedge + defect consequence-pricing、genuine 雙向 repricing、行為變 slice）

feat/desperation-ordering commit `998b0ae7`（off origin/main 1f5e8785=dispatch commit、bb372376 superset；已 push）。

## ★兩靶（§HOW-binding 全守）
**靶1 herald catastrophe-hedge**（`_try_herald_side` mini-util）：
- 抽 `static herald_hedge(severity, pmult)` = 單一真源（inline `mini += hedge` + machine-demonstrate 共用、避免公式漂移）。
- `hedge = clampf((severity − HEDGE_ONSET)/(1 − HEDGE_ONSET), 0, 1) × HEDGE_CATASTROPHE_MAG × pmult`（pmult=`_help_pmult(lv)` 同 relief 項）。
- **②bounded**：`severity < HEDGE_ONSET(0.55)` → hedge=0（非 flat always-ask offset）；`pmult=0 → hedge=0`（人格全壓）。
- TEST VALUE：`HEDGE_ONSET=0.55` / `HEDGE_CATASTROPHE_MAG=1.0`（measurer 校 razor-thin -0.004 翻）。

**靶2 defect consequence-pricing**（`event_faction_defect` defect_util）：
- 抽 `static defect_consequence(food_days)` = `clampf(1 − food_days/DESPERATION_DAYS, 0, 1) × DEFECT_CONSEQUENCE_MAG`。
- `defect_util = distress_pressure × loyalty_deficit − stay_benefit − consequence`。
- **③連續**：走 `food_days` 連續函式、**零 if-starving branch**（吃飽 starve_frac=0→consequence=0 野心叛不變 / 餓→1 壓餓叛）。
- `food_days` = 自隊自知 own food（感知鐵律）、加純讀 `ResourceSystem.effective_food` gather。
- TEST VALUE：`DEFECT_CONSEQUENCE_MAG=0.2`（measurer 校）。

## 命門乙雙向 genuine 非 crank（unit test 坐實）
結構真值（hedge=near-catastrophe option-value / consequence=餓叛通往死後果）；magnitude=TEST VALUE 校準非 crank；**非 boost 逼 fire**（低 severity hedge=0）；**非刪叛離**（絕望-abandoned distress×loyalty=1、stay=0 仍 util>0 照叛；野心叛 starve_frac=0 照 fire）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `desperation_ordering_test` | **ALL PASS**：②hedge bounded **machine-demonstrate 曲線**(severity 0/0.2/0.4/0.5/0.55→hedge=0；0.6=0.111 0.7=0.333 0.8=0.556 0.9=0.778 1.0=1.0 單調非遞減=proximity scale 非 flat) + razor near-miss(mini=-0.0043→+0.282 翻) + ③consequence 連續(food_days 0→3:0.2/0.167/0.133/0.1/0.067/0.033/0 嚴格遞減) + anti-crank 雙向 |
| headless | **0-new**（3 baseline FAIL：Team23建設×2/弱目標） |
| constitution_gate | **PASS sites=75**（兩 repricing=util 項、無新硬閘/god-view site） |
| determinism | **3-run byte-identical**（recovery bed seed1337、md5 `75126a00`；零 RNG 純 clampf 算術） |

## ★fp intended-divergence（LIVE 坐實）
near-miss death-spiral 場景（seed8181 dispersed 45天、`infonet_scale_econ_dispersed.json`）baseline(stash iii edits) vs branch：
| metric | baseline(iii off) | branch(iii on) |
|---|---|---|
| **FP** | `168ad0a2…` | `5433290e…` **DIVERGED(intended)** |
| help.hedge peak | 0.000 | **0.317**（hedge 路徑 exercise） |
| defect_consequence peak | 0.000 | **0.200**（consequence 路徑 exercise） |
| help.letter_dispatched | 1 | **2**（hedge 翻 near-miss → +1 求援 fire） |
| help.severity_positive | 34 | 28 |
| cohesion.defect_fire | 5 | 7 |
| Team2 final | fac=-1 pop=1 | gone(-99) |

## ★★兩透明 flag 呈報（非隱瞞、非 clean win）
**(A) 標準 fp 床 iii DORMANT**：recovery/warring/peaceful 標準床 iii **byte-identical**（recovery seed1337 baseline vs branch FP 三 checkpoint 全同、`letter=false`=無隊進 herald severity 窗）。∴ 分化**只在 near-miss death-spiral 場景顯**（dispatch 的「F0 fp 預期分化」須用 seed8181 dispersed bed、非 recovery F0 床）。code LIVE（上表坐實）、標準床捕不到=fix 精準對症 dormant-unless-needed（同 care-loop 型）。

**(B) raw defect_fire 升非降 + Team2 outcome shift**：branch `cohesion.defect_fire` 5→**7**（升、非直覺的餓叛率降）+ Team2 `pop1-factionless`→`gone(-99)`。**非 clean 餓叛率降**——研判 trajectory shift（herald relief 讓更多隊活久→後續他因叛/merge、raw count 非乾淨餓叛 metric）。**這是 measurer 的量測/校準職**：④順序 emergent 硬 gate + 逐隊餓叛 vs 野心叛拆解 + Team2 是 rescue-merge 抑或死 + 校 TEST VALUE（razor-thin 翻 + emergent 序）。實作端只坐實 genuine+bounded+continuous+LIVE+determinism，magnitude 是 TEST VALUE placeholder（dispatch 明訂 measurer 校）。

## 路
1. **你 R²**（②bounded machine-demonstrate ✓ + ③連續無 branch ✓ + genuine 非 crank ✓ + fp 分化 intended ✓；核透明 flag A/B 是否需 systems 定調 metric）。
2. → **measurer 量**（seed8181 dispersed：④求援先於叛離 emergent 硬 gate + 餓叛率(乾淨拆)降否 + 野心叛不變 + 人格分化 + 校 TEST VALUE HEDGE_ONSET/MAG/CONSEQUENCE_MAG）。
3. → QA specimen（餓隊求援先 fire→活過 defect 故事）→ merge = iii 收 → re-measure scale。★staged：勿本 slice 過 fix 2a 求援-ordering / A propagation。地基 KEEP。

（F2 disk flag：~115 stale worktrees 仍待 systems prune。）
