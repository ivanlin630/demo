---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN + 1 spec 文字澄清] 糧流感知 Slice A 實作——講死項全落地+team14根治數字合理，1個HOW spec內部矛盾(§1 vs §2)需澄清非新洞，merge放行"
---

# R② 判決：糧流感知 Slice A 實作 — CLEAN

## persist×safe_ratio 講死項——逐條核對落地
`_safe_factor`：`eta_days=ticks_left/max(pop,1)`（親對 `outpost_system.gd:307` 倒數公式一致）、`safe_ratio=food_runway/eta_days`、`ratio_floor=clampf(BASE+(flex-stick)×SPAN,MIN,MAX)`——固執(stick高)→`(flex-stick)`負→floor低→撐久；務實(flex高)→floor高→早放，方向跟 HOW §4b 文字精確對應。乘法縮放（`base_persist×safe_factor`）非硬塌，5 無 ETA task 排除（`if current_task==TASK_BUILD` 才進 safe_factor 分支，其餘落原 `base_persist` return）——三項要求全部照做，非空話。

## team14 根治數字——親算合理性
`固執0.05 vs 務實0.002`（同 runway）——兩人格軸複合：`lean`（Slice1既有，固執本就 base_persist 較高）+ `ratio_floor`（本 slice 新增，固執 floor 較低=同 runway 下 safe_factor 較高）**同方向疊加**，非互相矛盾——~25倍差距是兩個獨立人格因子相乘的合理結果，非算式錯誤或爆炸。

## ★spec 文字內部矛盾（非本輪新洞，我 R②時該抓到）
HOW spec §1 明文把「假設 tile inflow 投影器」列入延後 Slice B 清單；但 §2 描述 inflow 來源時又寫「自家outpost被動產**+**當前tile可持續採」，把後者聽起來像 Slice A 範圍內。實作選擇：`_sustainable_inflow` 只認**已完工**自家 outpost（`outpost_level==0 or outpost_owner!=team.team_id → return 0`），沒有 outpost 的 tile（含**正在蓋、還沒完工的新據點**——team14/A1 那種情境）inflow 恆零。

**核對這是否等於「當前tile可持續採」被漏做**：確實是同一項——「非home outpost的tile可持續量」正是 §1 已經明文延後的「假設tile投影器」，TDD `_test_inflow_harvest_only` 把它跟「狩獵」併在同個 comment 底下延後，語意上算對（同一塊未完成的估算能力），只是 §1/§2 兩處文字沒對齊，我當時 R②沒抓出這個內部矛盾。

**判斷不擋這輪 merge**：①team14 這個 slice 的**主要動機**（runway/ETA 比對觸發提前放手）就算 inflow 在施工期間恆零也照樣正確運作——純看存量消耗速度 vs 剩餘工期，不需要「這塊地蓋完後多會產糧」這個前瞻資訊②現狀（inflow=0 during 施工）比 Slice A 之前（完全沒有 safe_ratio 調制）更保守，不是退步，是尚未做到最聰明的版本③不影響已驗證的世界不凍/危機打斷/RNG 潔淨等硬回歸項。

**要求**：把這條記進 Slice B 待辦（跟你自己已列的「假設tile投影器」合併，非另開新項），HOW spec §2 的措辭在 Slice B 定案時一併修正，避免下次讀者又被兩處文字搞混。

## 其餘
TDD 6 函式 9 條斷言核對到位；世界不凍數字（attrition 2.03%/teams 49→63）跟前幾輪同款健康信號；危機仍打斷/RNG 潔淨/tap 觀測皆延續憲法對齊。

## 判決
**CLEAN → merge。** Slice B（打獵 EV+ tile 投影器+派遣閘）dispatch 前的 R①/R②，我會把這條 spec 文字矛盾一併列入待驗清單。
