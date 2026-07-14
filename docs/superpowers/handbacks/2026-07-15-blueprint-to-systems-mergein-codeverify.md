---
from: blueprint
to: systems
status: consumed
topic: [裁定] 掠奪過關(移動延遲非幻覺);併入=量測判不了→讀code(_resolve_join/_resolve_mergein)定幻覺or漸進吸收;乞食0樣本=死rung另案;merge唯卡併入定音
---

# 裁定：絕境選項覆蓋——三選項逐一處置

measurer 追蹤三選項世界效果。我裁：

## 掠奪：★過關，不需 look-before-leap
非幻覺,是**移動延遲**：Team26 選掠奪 33 次,前 26 次 material delta≈0（走向目標中重評同 winner）,**後 7 次真收益到帳**（material +1.8、coin +3.3）。與買糧幻覺性質不同——買糧是「根本不可能兌現卻選」,掠奪是「會兌現但要先走到」。**選中→走到→交戰得手＝連貫故事,機制正常。** 不套 look-before-leap。同意 measurer。

## 併入：★量測判不了，請讀 code 定音（不是再量一輪）
2/2 樣本（Team18/Team26 共 42 次選中）`faction_id` 皆不動,**但 Team26 併入窗口內 pop 3→2→1 逐步掉**。兩解讀量測分不出：
- (a) 併入無效（幻覺）,pop 掉是別的機制巧合同時。
- (b) 併入**漸進吸收**（個別 member 先被吸走→pop 降,`faction_id` 整隊旗標最後一人才切）,其實有效只是慢。

**量測到頂了,要 code 才能定音**：請讀 `_resolve_join`/`_resolve_mergein`——
- **觸發條件是否太嚴/根本達不到**（→幻覺,同買糧,補 look-before-leap 完成 A）;
- 還是**真有漸進吸收 lifecycle**（→連貫,faction_id 最後才切=正常,不需補）。

**這是 merge 唯一卡點**。code 判完：幻覺→補 look-before-leap→重跑→QA→merge;有效→直接 merge（併入連貫,pop 降是吸收非死）。

## 乞食：★死 rung，另案（非本刀 merge 卡點）
6 specimen 全程**從沒選過乞食**,log 也無 beg print → **不是「幻覺」,是「引擎幾乎不選它」**（never-selected 不可能守幻覺）。∴ **不擋本刀 A 完成**（A=不選幻覺;乞食沒被選,無 A 問題）。

但這是**絕境階梯的一個死 rung**（該乞食的謙卑窮隊從不乞食）→ **記 backlog 另案**：查乞食 utility 權重/applicability 為何從不贏（可能 drive 太低）。連 [[game-design.md 絕境經濟]] 的絕境階梯。要專測得換 `survival_start.json`（tick0 零資源隊逼乞食情境）——**另案,非現在**。

## ∴ merge 路徑收斂
A 完成 = 買糧✅（已修驗綠）+ 掠奪✅（機制正常）+ **併入（讀 code 定音，唯一 pending）**。乞食=死 rung 另案不擋。
- 併入有效 → 全綠 → merge `feat/desperation-food-seeking`。
- 併入幻覺 → 補 look-before-leap → 重跑 → QA 複判 → merge。

## 附（前封已提,續辦）
- taps + bed 修 cherry-pick main（獵樣本需要）。
- known_issues：凍結威脅 + combat-death trace 盲點 + **新增乞食死 rung**。
