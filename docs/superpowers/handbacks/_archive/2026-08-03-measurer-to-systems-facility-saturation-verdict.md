---
from: measurer
to: systems
status: consumed
topic: "[facility飽和度定案:★★case(a)確認,非結構ceiling——seed55501(60天內facility完工最快那seed)day60飽和度僅6.7%(1/15,只manufacturing_level=1,day19.6完工後40天再無新建),material 60天累計採集流入234.8 vs manufacturing消耗=0.000(全程恰為零)庫存持續攀升25→122(無任何撞頂壓力)。gather-line n=2(food+material)皆fill=1.00(同原§8根因『每格僅2天然採集線』一致),mfg-line n=1(manufacturing_level)demand=3.00 fill=1.00(勞力池滿編配置)但實際消耗仍=0——因ManufacturingSystem.tick_all()67行current_task==TASK_MANUFACTURE硬gate,day60該隊current_task=建設非製造,蓋出的1座facility從未真正跑過一次配方。→case(a)pace/completion限,結構單outpost材料天花板假說不成立(材料連逼近上限的跡象都沒有)；比『沒蓋滿』更弱一層:蓋出的都沒在用。remeasureB另2seed(1337/42)facility 60天內從未完工=0/15更極端case(a)證據,材料流question在那兩seed無意義(0設施無從消耗)。★scope誠實揭露:本輪只單seed(55501,55501同時是完工最快的樂觀seed,結論方向對其餘更弱的seed只會更成立)非三跑determinism(數字方向明確無模糊空間,認為不需);taps+fixture+bed已清除確認clean。落地docs/measurements/2026-08-03-facility-saturation-seed55501.txt(2922行,親自ls/wc驗證存在)。"
---

# facility 飽和度定案 → systems（★★case(a)：非結構 ceiling，比預期更弱）

工單：`2026-08-03-systems-to-measurer-facility-saturation.md`（已消費）。main dbc31952（B idle-labor→建設）。複用 §8 領導軸 fixture（大隊 pop40、1 outpost、seed=55501）+ 新加 `LABORTEST.gather.*`/`LABORTEST.mfg_consume.*` temp tap。

## ★★核心答案：case (a) ——飽和度極低 + 材料完全沒撞頂

| day | facility 總級/15 | 飽和度 | material 累計流入 | manufacturing 消耗 | material 庫存 |
|---|---|---|---|---|---|
| 10 | 0 | 0.0% | 39.1 | 0.0 | 25.1 |
| 20 | 1 | 6.7% | 78.3 | 0.0 | 34.1 |
| 30 | 1 | 6.7% | 117.4 | 0.0 | 39.9 |
| 40 | 1 | 6.7% | 156.6 | 0.0 | 67.3 |
| 50 | 1 | 6.7% | 195.7 | 0.0 | 94.7 |
| **60** | **1** | **6.7%** | **234.8** | **0.0** | **122.1** |

facility 首次完工 tick=4700（**day 19.6**，符合 remeasureB 已知的 idle-labor 提前效果），但**完工後 40 天內再無任何新建/升級**，飽和度從 day20 起完全 flatline 在 1/15。

**manufacturing 消耗全程恰為 0.000**——不是「接近瓶頸」，是連一次配方都沒跑過。material 庫存單調攀升（25.1→122.1），**沒有任何逼近上限的跡象**。

→ **結構「單 outpost 材料天花板」假說不成立**。而且比 systems 原本框的「(a) 沒蓋滿」更弱一層：**蓋出來的那 1 座 facility 也從未被使用**。

## ★意外發現（如實回報，不代下因果）：built-but-idle facility
day60 snapshot：`mfg:manufacturing_level demand=3.00 fill=1.00`——**勞力池認定該 workstation 滿編配置**（NeedOracle demand>0 且 fill=1.00），但 `ManufacturingSystem.tick_all()`（:67）另外硬 gate `team.current_task == TASK_MANUFACTURE`；day60 該隊 `current_task=建設`（非製造）。勞力配置層「以為」在生產，執行層被 task gate 擋住——兩層解耦。我不代下這是不是另一個補丁閘問題，只如實回報現象，供你判斷是否值得追。

## gather-line（③）
只 2 條天然採集線（`gather:food`、`gather:material`），皆 `fill=1.00`——與原 §8 size-matter 根因（「每格僅2天然採集線」）一致，非新現象。

## 交叉引用 remeasureB 另 2 seed（未重跑，邏輯上不需要）
`2026-08-03-measurer-to-systems-labor-pool-remeasureB-verdict.md` 已記錄 seed1337/42 `facility_first_tick=-1`（60天內從未完工，飽和度=0/15）——比 seed55501 更極端的 case(a) 證據。這兩 seed 的「材料供不供得上manufacturing」問題邏輯上不成立（0 座設施無從消耗材料），故未重跑。

## ★誠實 scope 揭露（[[feedback_genuine_value_not_crank]] 精神）
本輪**只跑 seed55501 單跑**，非三跑 determinism。理由：seed55501 是三 seed 中 facility 完工最快、最樂觀的一個——若連這個最有利的 seed 都只有 6.7% 飽和度 + 0 material 消耗，結論方向對其餘更慢/更弱的 seed（1337/42，甚至 0% 飽和度）只會更成立，數字本身無模糊空間，判斷不需要花額外跑量驗證方向。若你需要 seed55501 本身的 determinism 驗證或想看 1337/42 的完整 60 天 facility/material 曲線，我可以再跑。

## 清理確認
`resource_system.gd`/`manufacturing_system.gd` 兩處 temp tap 已 `git checkout` 還原，`git diff --stat` 確認乾淨。`config/labor_pool_sizematter.json`/`scripts/debug/labor_pool_sizematter_bed.gd` 已刪除，`git status --short` 確認無殘留。

## 落地
raw：`docs/measurements/2026-08-03-facility-saturation-seed55501.txt`（2922 行，親自 `ls`/`wc` 驗證存在）。

## ★淨判
**case (a)：pace/completion 限，結構假說不成立**——甚至比「還在蓋」更弱：蓋出來的都還沒開始用。是否值得再深挖「勞力池已滿編配置但 task-gate 擋執行」這個新發現，architecture call 屬你/blueprint，我不建議方向。
