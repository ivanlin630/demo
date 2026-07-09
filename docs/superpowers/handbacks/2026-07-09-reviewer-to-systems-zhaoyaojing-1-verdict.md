---
from: reviewer
to: systems
status: consumed
topic: 照妖鏡#1 spec 審畢——CLEAN，2 項需你留意（均值守恆非保證/probe 建議加碼）
---

# 照妖鏡#1 spec 對抗審結果

spec: `docs/superpowers/specs/2026-07-09-zhaoyaojing-1-combat-abandon-courage.md`

## 查項 1：均值守恆真否——分析上**不保證對稱**，你的顧慮成立，非過慮

核 `person_generator.gd:25-29` ARCHETYPES 表：影響 `好戰`/`慎重` 的 archetype **非對稱**：
- 好戰：`霸主`/`屠夫` 兩者 `hi_v` 推高、`懦夫` 一者 `lo_v` 壓低 → 高/低 archetype 數 2:1（淨偏高）。
- 慎重：只 `謀士` 一者 `hi_v` 推高，**無任何 archetype 壓低** → 淨偏高、無對沖。

`:60` 基礎值（無 archetype 命中時）走 `rng.randf_range(NORMAL_LO, NORMAL_HI)`——這段本身對稱；但 `:74-80` 以機率 `rate` 命中某 archetype 時疊加偏態，且好戰/慎重兩者都偏「高」方向。`courage = 0.5+(好戰−慎重)×0.5` 的分子是**兩個同向偏態值的差**，能否抵消要看兩者偏態幅度/命中率是否剛好對稱地互相抵——**純代數無法證明淨零**，需 full_probe 實測。

**結論**：你的顧慮正確、非過慮，**驗收線 2（aggregate 不系統性偏移）是必要非充分的實測閘,不是形式證明**。spec 已自帶這條驗收線 + median-centering/接受小 shift 的備案，流程正確，**不阻塞**——僅確認「均值守恆」現階段是**待驗證的假設**而非已證明的性質，measurer 跑 full_probe 時把「aggregate 潰退率跟 baseline 對照」列為**必查**（不能只看 courage-bucket 內部分布而漏看 aggregate shift）。

## 查項 2：零新判斷器——CLEAN

`courage`（`:28` `clampf(0.5+(martial-caution)*0.5,0,1)`）是連續浮點導出，非 band/enum/if-branch 分類器，`_abandon_threshold` 亦連續映射（無新 match/分支表）。淨判斷器數不升，符 `01_architect` 盤點原則。

## 查項 3：`:197/200` 對稱改法 + null leader fallback——CLEAN

`npc_combat_system.gd:197`(`a.readiness<=COMBAT_ABANDON_THRESHOLD`)/`:200`(對 b 對稱) 核實逐字對應，改 `_abandon_threshold(state,a)`/`(state,b)` 各自算,對稱無漏。`ldr==null→return ABANDON_THRESHOLD_BASE`（:25）合理（無 leader 退回中性均值,不因缺數據誤判為某種膽量傾向）。

## 查項 4：`rout.by_courage` probe——你的疑慮成立,建議加更直接一維

「潰退隊 courage **分布**」只證「哪些 courage 的隊潰退了」，**不直接證**驗收線1「勇者晚逃（退時 readiness 更低）< 怯者（退時 readiness 更高）」這個**機制性因果**——分布可能受戰局規模/who-fights-whom 干擾，非門檻差異的直接證據。

**建議**：加 `rout.readiness_at_retreat_by_courage_bucket`——在 `_force_retreat` 觸發當下（`npc_combat_system.gd:197/200` 命中瞬間）記錄**該隊 `readiness` 數值**，依 courage 分桶（如高/中/低三桶）。這才是直接量「退時血條剩多少」——勇者桶應集中在低 readiness（門檻低,撐到快死才退）,怯者桶集中在較高 readiness（門檻高,早早就退）。比純看「誰退了」更貼近驗收線1 的因果宣稱。非阻塞，探針設計補強建議。

## 查項 5：`_try_retreat`(:205) 交互——CLEAN，兩機制無碰撞

核 `npc_combat_system.gd:190-206`：`_force_retreat` 判斷（門檻,:197/200）在**同一 round 內排在 `_try_retreat`（:205,經 `_skill_sys.on_combat_round` 之後）之前**——每回合先查閾值,命中就 `return`（提前結束,不會走到後面的機率撤）。且 `_try_retreat`(:409-423) 本身**只在 `team.current_task==TASK_FLEE` 時才生效**（是「已決定撤退後,能否成功脫離」的獨立機率,非撤退決策本身）——兩者是「決策(門檻)→執行(機率脫離)」序列關係非平行競爭，改門檻不會被機率撤蓋過,順序天然保序。

## 裁決

**CLEAN，可鎖 spec 排 implementer。** 查項1提醒 measurer 驗收線2 是實測閘非形式保證（本就流程內)；查項4 建議 probe 加一維更直接證因果，供你判斷是否值得多加一個 bump（非必要,不加也能跑,只是證據力較弱）。均非阻塞。
