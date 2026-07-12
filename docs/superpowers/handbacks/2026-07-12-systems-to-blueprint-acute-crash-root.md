---
from: systems
to: blueprint
status: open
topic: [急性崩真根·零跑+算] 非單一init死常數—食物income路徑結構不足:task-gated採集+farm-gated倍率+buffer只outpost-owner;=farming死鎖另一面+task競爭;修=merge farming depatch+被動苟活地板
---

# 月1-3 急性餓死崩真根：income 路徑結構不足（非 init 死常數）

patch-gate-first 查完 + 算。**答案：非單一 init 死常數/初始化 bug，是食物 income 路徑結構性不足——largely farming 死鎖的另一面 + task 競爭 + buffer 分配。**

## 食物收支（file:line + 算）
**消耗（sink）**：`resource_system:116-131`——pop × FOOD_PER_PERSON_PER_DAY(0.8)/日,從 team.resources + 自家糧倉扣。pop 8-10 → **6.4~8/日**。
**income（source）**：`resource_system:243 _collect_from_tile`——**task-gated 採集**：
- 隊須**主動生產/覓食 task 站在食物 tile** 才取食（gain = productivity×current×COLLECT_RATE×**(1+farming_level×0.5)**×(1+prod_skill×0.3)×harvest_factor×work_morale）。
- regen 進 `tile.resources`（:87-91），**不自動給隊**——要採集 task 才轉成隊/糧倉食物。
- **idle/移動/戰鬥/蓋非農設施的隊 → income=0**（還在耗 pop×0.8）。
**buffer**：`opening_granary_food=800` **只 outpost-owner 拿**（`game_setup:307`「有主才給」）→ owner ~100 天緩衝;**非 owner 隊只 starting food 50 → ~6 天**。
**regen**：plains 8/forest 3（design-intent marginal，comment :4）——plains 8 ≈ pop 10 break-even（**須全採**）,forest 3 << pop 8。

## ∴ 86-96% 負流從開局（三結構因子疊,非單一 bug）
1. **income task-gated**：多數隊沒在主動採食 tile（做別的/移動/戰鬥）→ income=0 → 純耗 buffer。
2. **income farm-gated**：就算採，無 farm → gain×(1+0×0.5)=base，marginal vs pop×0.8。**= farming 死鎖的另一面**（無 farm income 不夠）。
3. **buffer 分配**：800 只 owner;非 owner 50 食 ~6 天 → 開局就負。

## blueprint 問：獨立真根 vs farming 死鎖另一面?
**主要是 farming 死鎖的另一面 + task 競爭 + buffer 分配,非獨立 init 死常數。**
- 不是「初始 pop 生成 bug」或「落點全 mountain」那種可單點修的 init 錯。
- 是**系統性 marginal 經濟:income 路徑被 farm-gate + task-gate 雙鎖**,開局多數隊沒有可行的食物 income → 耗 buffer → owner 撐 ~100 天、非 owner ~6 天 → 45% 月1-3 死。
- design-intent「regen marginal 須 farming/貿易」是真的,**但逃生閥全鎖**（farming 死鎖 + 貿易 util 被建設碾[known_issues] + 採集 task 競爭）→ marginal「苟活」惡化成「急崩」。

## ★上游修候選（一修多解,你/用戶裁）
共享上游根 = **開局缺可行食物 income 路徑**。四層門（farming/A門人口/B2統領/週轉）全被此早崩重置吃掉。修這個 = 一修多解：
1. **merge farming de-patch**（已 build worktree `feat/depatch-build-rights` 已 merged;`command-tenure` 擱置）——**必要但可能不足**（farm 建 3 天 + 需 civilian outpost + 採集 task,急性窗內未必來得及）。
2. **★被動苟活地板**（建議核心）：隊**站在可食 tile 被動獲得 subsistence income**（不需贏 task 競爭）——覆蓋急性窗,idle/transit 隊不餓死。拔「income 必 task-gated」的早期死亡。對齊 `game-design` 苟活門檻,但要真能覆蓋 pop×0.8。
3. **buffer 普及**：非 owner 隊也給開局 buffer（現只 owner 800）→ 拉平 ~6 天 vs ~100 天懸殊。
4. **gen pop 配承載力**：別在 forest/低 regen 落點 spawn pop 10（結構超載）。

## 判讀 + 序建議
- **這不是繞回 farming 死鎖就沒事**——farming de-patch 解「獨立隊能不能蓋農場」,但**急性窗（farm 未建成前 + 非農隊)仍缺 income**。需**被動苟活地板（#2）當急性窗的保底 income**,farm/貿易當中長期成長。
- 兩者互補:苟活地板撐過急性窗 → farm/貿易接手成長 → pop/統領/readiness 累積得起來 → 四層門一起鬆。
- **建議 spec 方向 = 被動苟活地板（#2）為主 + buffer 普及（#3）**,farm de-patch 已 merged 當中期。gen pop（#4）次要。
- 需用戶裁（改食物 income 語意=設計決策）→ brainstorm→對抗→spec。
- measurer 可實證:隊「有無主動採食 task」比例 + 非 owner 隊開局食物存量分布（坐實 task-gated + buffer 懸殊）。
