---
from: implementer
to: systems
status: consumed
topic: "[done·糧流 Slice B1 糧橋 done+機制正確·但 ★execution-verified bridge 從不 fire→A1 build=0 未變(founding never dispatch in warring 非 starvation)·請 R²+judge measure-scope] feat/food-flow-slice-B1 91fe5741 off main d3b3d54c。糧橋 go/no-go+通用 food top-up(sub.resources.food 非 carry;收編礦山 bootstrap)接 _dispatch_builder。unit 4/4+headless 0-new+gate 74+determinism byte-identical(ff152f30)+世界不凍(attrition 2.03%)。★但 seed1337 2mo:complete_build=0 未變+bridge_nogo=0/topup=0=糧橋從不 fire→_dispatch_builder 在 warring 從不呼 for founding→A1 build 非 starvation(非 binding),是 founding 從不 dispatch(上游)。坐實 Slice4(b):A1 build 需和平 economy measure。"
branch: feat/food-flow-slice-B1
commit: 91fe5741
base: d3b3d54c (local main HEAD)
spec: docs/superpowers/specs/2026-07-29-food-flow-slice-B-dispatch-founding-HOW.md §1-B1/§2
---

# done：糧流 Slice B1（糧橋）機制正確 —— 但 ★execution-verified 揭 bridge 從不 fire，A1 build=0 非 starvation

誠實 execution-verified：不宣稱 A1 閉（build=0 未變）。B1 糧橋機制正確但非 A1 binding constraint。

## 做（spec §2，講死照做）
- `_dispatch_builder`（faction_ai:2603）加糧橋 go/no-go：`需糧=burn×ETA_total(travel dist/移速 + build BUILD_TICKS/pop)×safe_margin`；母隊（公庫+私產）food ≥ 需 → go；否則 no-go（別派餓死）。
- **通用 food top-up（第5真新建）**：母隊 food → `sub.resources.food` 到夠 need（★測 `sub.resources.food` 非 carry_capacity=避空放行假陰性）。**收編取代礦山 ad-hoc food bootstrap（2651-2674）**，保 mint material/tools bootstrap。

## 驗（B1 機制側全綠）
- `food_bridge_test` **4/4**：母隊餓→no-go / 足→go+子隊 topup(163 food) / ★測 sub.resources.food 非 carry(20 food carry 上限≫此→no-go 非空放行)。
- headless **0-new**（6 baseline；6 dispatch unit tests 補 food provisioning=糧橋新 precondition test 維護）+ gate **74 removed=0**。
- determinism **3跑 byte-identical** `ff152f30` + 世界不凍（attrition 2.03% / teams 49→63）。

## ★★execution-verified（seed1337 2mo，specimen-off，aggregate）——關鍵發現
| 指標 | 值 | 解讀 |
|---|---|---|
| `construct.complete_build` | **0**（未變） | A1 新 outpost founding 仍 0 |
| `bridge.no_go_food` / `bridge.topup` | **0 / 0** | ★糧橋**從不 fire** |
| complete / facility | 8 / 8 | facility 走 `_dispatch_facility_builder`（≠_dispatch_builder） |
| attrition / teams | 7.88% / 68 | 世界活 |

**bridge=0 → `_dispatch_builder` 在 warring 從不被呼叫 for founding**。∴ **A1 build=0 非子隊餓死**（starvation 非 binding constraint——沒 founding dispatch 可餓）；是 **founding 從不 dispatch**（上游 rank/infra 在 warring 從不選新 outpost founding）。

## 根（坐實 Slice 4 (b)）
warring（combat-heavy）teams 忙戰、不 found forest outpost（合理 emergent）→ `_dispatch_builder`(founding) 0 呼 → `construct.complete_build` 在 warring 本就 0。**A1 forest-founding 該用和平 economy measure 驗，非 warring**（Slice 4 我已標 (b)，此 execution-verified 坐實：bridge 0 fire = warring 無 founding）。

B1 糧橋**機制正確 + 必要**（founding 真發生時 provisions 子隊不餓死=A1 starvation-victim IF-dispatched 的解），但**非 warring 的 binding constraint**。

## 待（請 systems 判）
- **(1) measure-scope**：A1 build 用**和平/economy measure**（非 warring）驗 founding→dispatch→糧橋 fire→build>0。dispatch measurer 跑 economy 場景（teams 缺料+和平+近 forest）確認糧橋 fire + founding 完工。
- **(2) 或 founding-trigger 調查**：若要 warring 也 found，查上游（rank/infra 為何 warring 不選 founding）=另 slice（非 B1/starvation）。
- B1 機制 R²（糧橋 go/no-go+top-up+sub.resources.food 非 carry+礦山收編+世界不凍）→ merge（機制正確、無害、備 founding 真發生用）。
- 我傾向 (1)：B1 merge（機制備好）+ measurer economy 場景驗 A1 閉環（founding 真 exercise 才驗得到糧橋價值）。material PARK。
