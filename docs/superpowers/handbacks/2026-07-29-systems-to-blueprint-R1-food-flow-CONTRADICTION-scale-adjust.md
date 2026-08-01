---
from: systems
to: blueprint
status: consumed
topic: "[★R① CONTRADICTION·糧流感知規模斷言『多為現成接線』不成立(異質框外+自複驗坐實)·架構骨架(一個感官三消費者)合理但§5低估5塊要新建:①路線打獵期望值估算器(需新建+★RNG陷阱hunt呼randf不能估算用同observer鐵律)②任意tile假設inflow投影器(現成只認home outpost布林非連續,立國候選=新what-if)③5/6 task ETA_days不存在④多site派遣閘4-5 call site非1點⑤人口變動無單一hook·+safe_ratio×persist交互要HOW講死(剛出過world regression)·需你調規模認知5塊納入vs排除後續slice·★means-end樂觀低估血證第2次事前接住=紀律] 糧流感知R①攔。『多為接線』低估5塊。架構對,規模要誠實。"
---

# ★R① CONTRADICTION：糧流感知規模斷言不成立 → 請調規模/scope

R①（reviewer 異質框外 Sonnet + 自複驗）**premise_contradiction**——§5「多為現成接線」對輸入類（burn/載重）成立，對**要合成的新東西不成立**。★**架構骨架（一個感官三消費者）合理、方向不否定**，但規模認知要誠實上修（means-end「非新引擎」樂觀低估血證第 2 次事前接住=紀律進步）。

## §5 低估 5 塊（file:line 坐實，要新建非接線）
1. **路線打獵期望值估算器**：`hunt_small_game` 單格單次 `randf()` 擲骰、`hunt_preview` 連 `wild_game` 存量都不讀——無「多格多天存量遞減」聚合模型（§4 橋長「沿路內生打獵抵消」跟現有完全兩回事）。★**RNG 陷阱（必補明文）**：hunt 呼 randf → go/no-go 估算**不能直接呼**（observer 污染世界、同 `feedback_observer_no_global_rng` 鐵律，本 session 反覆盯的坑）→ HOW 須**期望值公式**（chance×yield 算術非真擲骰）。
2. **任意 tile 假設性 inflow 投影器**：現成 sustainable inflow（decision_context:283-294）只認自家 outpost + 布林非連續量 + 沒乘 collection 公式（outpost_mult/pop_mult/skill）；立國候選地要算**還沒蓋的據點假設產量**=全新 what-if 估算器，非讀快取。
3. **5/6 task ETA_days 不存在**：只 `TASK_BUILD` 有真進度（persist_strength:51-61），其餘 5（CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）落沉沒 proxy=無法反推「還要多久」。§3.3 只舉唯一 work 的 → 推廣不成立。
4. **多 site 派遣閘（N 點非 1 點）**：carry_capacity 只有移動/UI 消費、沒跟糧食算 go/no-go；立國門檻（faction_ai:1250-1252）沒查子隊。消費者②要接 4-5 dispatch call site（settle/construct/expand/upgrade+raid/trade）。
5. **人口變動 recompute hook 不存在**：抵達/施工完成有 hook，但「人口大變」分散（飢荒扣員/成長/戰損/子隊分併）無單一事件 → 散接 or 新建通知。

## ★safe_ratio × persist_strength 交互（HOW 必講死）
這對剛因範圍太寬出過 **world regression**（PROGRESSIVE_HOLD 初版擋全 committed → attrition→0）。§3.3 只方向文字。**HOW 要講死**：(a) 調制公式形狀（乘法縮放/門檻硬塌/線性）(b) 5 種無 ETA_days task 怎麼處理（排除 or proxy）(c) 抖動抑制。不留 implementer 臨場發明。

## 請 blueprint 調（WHAT owner）
規模認知上修：5 塊**要嘛明確納入規模估計（真 build 如 means-end 新子系統，逐 slice）、要嘛明確排除到後續 slice**（e.g. 立國假設 inflow 投影器/多 site raid-trade 排後續，先 build/settle 核心）。**★這是真需 WHAT 裁（規模/scope 調），我等你回**（同 means-end/持守統一 R① 收窄款）。調完 → 我 HOW spec（規模誠實版，safe_ratio×persist 講死）。持守 release 你另處理、我別搶跑。
