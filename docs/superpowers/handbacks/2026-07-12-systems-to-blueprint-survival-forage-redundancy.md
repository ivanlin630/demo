---
from: systems
to: blueprint
status: consumed
topic: [反冗餘·零跑] 苟活地板已存在別重建—survival-priority forage(PRIO_SURVIVAL不被搶)+1.5天latch;修=tune現有floor(太低/hand-to-mouth零韌性)非新機制;measurer先確認死隊有無在forage
---

# 反冗餘結論：苟活地板已存在，別重建（框架內冗餘 lens 命中）

零跑純讀。**你的反冗餘直覺對——苟活地板已建，新建 = 重複。** 現有機制 + 為何不夠：

## 現有「求生覓食」= 已是苟活地板（file:line）
1. **survival-priority，不被一般 task 搶**：`faction_ai:2967 _evaluate_survival` → `DecisionEngine.rank_survival` → `TaskArbiter.try_set(...PRIO_SURVIVAL=80...)`（:3118）。**PRIO_SURVIVAL(80) > PRIO_DISPATCH(50)** → 飢餓觸發後覓食 task **不被日常 task 搶**（絕境優先權已有）。
2. **subsistence 地板 latch**：`resource_system:388 _forage_subsist_buffer = pop × 0.8 × FORAGE_FLOOR_DAYS(1.5) = pop×1.2`。`hunt_system:17` 覓食把 team food 頂到 1.5 天份就停（「食物已足苟活封頂」，超額不 bank）。
3. **明確設計語意**：comment「覓食=苟活地板」（hunt_system:13/resource_system:6）——**已是刻意的絕境保底 income**。

∴ **新增「被動苟活地板」= 框架內冗餘**（同一求解器）。**別重建,修現有。**

## 但現有 floor 為何擋不住 45% 死（真問題在這）
現有 floor 是 **1.5 天 hand-to-mouth latch，零韌性**——四個結構脆點：
1. **latch cap 太低（1.5 天）**：食物頂到 pop×1.2 就停,**任何中斷（hunt roll 失敗/離開獵物 tile/wild_game 枯竭）→ 1.5 天內見底 → famine**。無 margin 吸收波動。
2. **refill 靠 hunt roll**：`hunt_system:20-22` 被動命中 `PASSIVE_BASE_CHANCE=0.08`（很低）+ 求生技能。**passive 覓食 8% 命中 → 常空手 → 連 1.5 天 latch 都填不滿**。
3. **wild_game 枯竭**：`hunt:24` 每次成功枯竭 1 隻 wild_game → 獵物 tile 採乾 → refill 斷。
4. **entry timing 錯位**：`_evaluate_survival` 只在**已飢餓才觸發**。owner 隊有 800 granary（~100 天）→ 早期不飢餓→不覓食→也沒好好採集（income 洞）→ buffer 耗盡才掉進 1.5 天 latch,此時已無 margin。非 owner（50 食 ~6 天）更快掉入。

## 判讀：修現有 floor，非新機制
- **不是缺苟活地板,是現有地板 1.5 天太薄 + refill 太不可靠 + entry 太晚**。
- **修候選（tune 現有,非新建）**：
  1. **抬 `FORAGE_FLOOR_DAYS`（1.5 → 5-7）**：給覓食隊韌性 margin,吸收 hunt 波動,不一中斷就死。最小改、對症。
  2. **抬 passive 覓食可靠度**（`PASSIVE_BASE_CHANCE 0.08` 太低 / wild_game 枯竭補回）：讓 latch 填得滿。
  3. **entry 提前**（buffer 未見底就開始輕度覓食）或 **buffer 普及**（非 owner 也給開局糧,拉平 6 天 vs 100 天）。
- **設計語意問題（需用戶裁）**：現有「1.5 天苟活」是刻意「不死但不長,逼交易/farming」。但實測 45% 死 → **這個「苟活」根本沒苟活住**（latch 太薄+refill 太差=慢性餓死非苟活）。用戶要決定:苟活地板該「真的保命（不死）」還是「僅減速死亡」？前者=抬 FORAGE_FLOOR_DAYS + refill 到真能覆蓋 pop×0.8;後者=現狀（但那 established 永遠起不來）。

## 序建議
1. **measurer 先確認斷點**（決定修哪個脆點,measure-first）：死掉的隊**有沒有在 forage**（survival task 有無 fire）？
   - 若**有 forage 但仍死** → floor 太薄/refill 太差（脆點 1/2/3）→ 抬 FORAGE_FLOOR_DAYS + hunt 可靠度。
   - 若**沒 forage 就死** → entry timing/task 沒觸發（脆點 4）→ 查 _evaluate_survival entry gate。
   - 既有 probe `reaction.*`/`g1.engine_survival`（faction_ai:1492）+ SurvivalForage print（:3140）可能已有料。
2. 定位後 → brainstorm（tune 現有 floor 哪個脆點）→ 對抗 → spec。**不新建苟活機制。**
3. **這比新建省**——反冗餘擋掉一個重複 slice,改成 tune 現有常數/可靠度（小改）。
