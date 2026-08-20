---
from: reviewer
to: blueprint
status: consumed
topic: "[R①全靶citation驗+R②判決=CLEAN+3必查項(非阻塞、要求HOW-binding寫死)] iii絕境排序spec——R①:靶1親讀faction_ai_system.gd:2011確認mini=severity×_help_pmult(lv)×INFO_RELIEF_EXPECT−INFO_ANON_COST逐字對得上,常數親讀:1642-1643確認INFO_RELIEF_EXPECT=DESPERATION_DAYS(3)×FOOD_PER_PERSON_PER_DAY(0.8)=2.4、INFO_ANON_COST=FOOD_PER_PERSON_PER_DAY=0.8皆對;-0.004 near-miss親算tick5800數字(0.722×0.4592×2.4−0.8=−0.00431≈−0.004)算式吻合非唬爛;靶2親讀event_faction_defect.gd:23確認defect_util=distress_pressure×loyalty_deficit−stay_benefit逐字對得上,零consequence項屬實;threat-dominance非靶親查decision_context.gd:259 threat_react=_best_t(真state-derived blend非死常數)結構上支持genuine claim;R①全數坐實無citation錯,非F1那種halt;R②:①genuine非crank方向正確(WHAT層級公式未定,方向=補option-value/consequence真值非boost/砍,符合本session一貫判準);★②(必查項)herald hedge項必須寫死bounded證明——要求HOW明確demonstrate這個catastrophe-hedge項不會退化成『alternative夠慘就unconditional正』的crank(e.g.低severity時hedge項該接近零、不能是flat offset讓herald變成無視cost-benefit的always-ask),否則等於用『真值』包裝一個變相boost;★③(必查項)餓叛≠野心叛的差異化必須從HOW用同一個連續state變數(如既有distress_pressure/food_days)驅動consequence項強度,非新增if-starving/if-not-starving兩條branch(那是隱性寫死非湧現)——要求HOW明講consequence項是現有starvation-state訊號的連續函式;★④(必查項)『求援先於叛離』順序聲稱屬未驗斷言、非既成事實——要求build完必須量測驗證這個順序真的emergent(非只是文字宣稱),spec§3已承諾但這輪判給CLEAN前特別點名這條是硬性量測gate非aspirational;⑤結構獨立side-channel零耦合親查_faction_stay_benefit(:4984-5004)讀的是relief_mem(過去已受助記憶飽和值)非『herald是否in-flight』即時訊號,證實herald跟defect這輪不存在隱性同tick耦合,『零耦合』宣稱成立;判決=CLEAN(premise全對、方向正確)+3必查項(②③④)折入HOW-binding、非halt也非要求blueprint重寫WHAT→鎖→systems寫HOW"
---

# R①+R②判決：iii 絕境排序 spec — CLEAN + 3必查項

## R①（全靶 citation，非 exempt 任何靶——F1 halt 教訓守）

**靶1**：親讀 `faction_ai_system.gd:2011` `var mini: float = severity * _help_pmult(lv) * INFO_RELIEF_EXPECT - INFO_ANON_COST` 逐字對得上 spec 引述。常數親讀 `:1642-1643` 確認 `INFO_RELIEF_EXPECT = DESPERATION_DAYS(3) × FOOD_PER_PERSON_PER_DAY(0.8) = 2.4`、`INFO_ANON_COST = FOOD_PER_PERSON_PER_DAY = 0.8`——兩個數字都對得上。

**-0.004 near-miss** 親算：`0.722 × 0.4592 × 2.4 − 0.8 = 0.79569... − 0.8 = -0.00431 ≈ -0.004`——算式吻合，不是唬爛的數字，這個「差銅板厚」的宣稱是真的、可重現。

**靶2**：親讀 `event_faction_defect.gd:23` `var defect_util: float = distress_pressure * loyalty_deficit - stay_benefit` 逐字對得上，零 consequence 項（沒有任何 factionless/死亡風險相關的項）屬實。

**threat-dominance（非靶）**：親查 `decision_context.gd:259` `c.threat_react = _best_t`——是真實 state-derived 的 blend（comment 講 approach+hostility+power），不是死常數，結構上支持「genuine 主導」的宣稱（不是說我親自重跑了 tick5800 那場模擬驗證 0.95-2.35 這個具體數字範圍，但這個值的**來源機制是真的**，非虛構函式）。

**R① 結論**：全數坐實，沒有 citation 錯誤，跟 F1 那次的 halt 不是同一種情況——這次 blueprint 給的三個靶（含「免查」的 threat-dominance）file:line 都經得起查。

## R②

**①genuine 方向正確**：這輪 spec 是 WHAT 層級，公式常數還沒定，但方向講的是「補 option-value/consequence 真值」而非「boost 逼 fire / 砍掉 defection」，符合本 session 一貫的 genuine 判準（[[feedback_genuine_value_not_crank]]），§1 的三條命門文字也把乙教訓的雙向陷阱都寫進去了。

**★②（必查項）herald hedge 項必須寫死 bounded 證明，非阻塞但要求 HOW 交代**：靶1 要加的「catastrophe-hedge」項——本質是「alternative 越慘、這個便宜可逆選項的邊際值越高」——這個方向本身合理，但**必須小心它退化成一個變相的 crank**：如果 hedge 項在 severity 低時沒有自然趨近零、而是一個 flat offset，效果就等同於「因為 alternative 夠慘就無條件加分」，這正是用「真值」包裝的 boost（乙教訓的鏡像陷阱）。**要求** HOW 明確 demonstrate 這個 hedge 項是 severity/alternative-catastrophe-degree 的連續函式、低 severity 時自然趨近零，不是一個常數加項。

**★③（必查項）餓叛≠野心叛必須從同一連續 state 湧現，非新增 if-branch**：靶2 的 consequence-pricing 項要讓「餓著叛=壓」「吃飽野心叛=不壓」這個差異出現，**正確做法**是讓 consequence 項的強度是現有 starvation-state 訊號（例如既有的 `distress_pressure` 或 `food_days`）的連續函式——吃飽的隊，這個訊號本身就低，consequence 項自然趨近零，不需要額外判斷。**錯誤做法**是寫兩條分支（`if starving: apply consequence else: don't`）——那是隱性寫死兩規則，跟 spec §1 自己講的「非兩條寫死規則」矛盾。**要求** HOW 明講 consequence 項掛在哪個既有連續變數上，非新增條件分支。

**★④（必查項）「求援先於叛離」順序這輪是未驗斷言，非既成事實**：spec §3 已經承諾要量測「可救的餓隊求援先於叛離 fire」，這條在我這輪判 CLEAN 前要**特別點名成硬性量測 gate**——這個順序能不能真的從兩個公式的相對閾值-crossing 點自然湧現，在具體常數定案前無法用純閱讀 code 確認，必須是 build 完的**量測結果**（不是「因為兩個公式都補了真值所以應該會這樣」的推論就過關）。這不是新要求，是把 spec 自己§3 已經寫的東西升格成 R②的硬性條件，避免 build 完只驗了「兩個 util 都變 genuine」但漏驗「順序真的湧現」。

**⑤結構獨立 side-channel 零耦合——親驗成立**：親讀 `_faction_stay_benefit`（`:4984-5004`）確認它讀的是 `relief_mem`（透過 `_benefactor_strength` 讀 leader **過去記憶**中已受助次數的飽和值），不是「herald 是否 in-flight」這種即時訊號——證實 herald 跟 defect 這兩個機制在同一 tick 內不存在隱性耦合，`零耦合` 宣稱成立。（過去受助記憶會提升未來的 stay_benefit 是既有機制、非這輪新增，不算耦合副作用。）

## 判決
**CLEAN + 3必查項（②③④折入 HOW-binding）→ 鎖 → systems 寫 HOW。** 非 halt，premise 全對、設計方向正確；這三條必查項不是要求推翻 WHAT，是要求 HOW 階段把「hedge 項 bounded」「consequence 項連續非分支」「順序是量測驗證非推論假設」寫成硬約束，避免 build 完才發現公式細節悄悄退化成乙教訓警告過的那種 crank。
