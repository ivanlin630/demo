---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2追蹤項] Part2 (a)side-action(求援/偵察脫主argmax)——①主argmax零改動親驗坐實(options.gd:344-370求援/偵察REGISTRY entry自成一體dict,移除不牽動其他entry util/rank計算,結構上determinism-neutral);②mini-util genuine(help_need_severity既有真值component沿用,人格_pmult非boost)但RELIEF_EXPECT/ANON_COST同前幾輪要求calibration錨真值紀律追蹤;③scope硬限親驗支持(spec文字硬寫herald/scout兩支明列非泛化side-task框架,要求build時確認implementer真的寫死兩條非做成可插拔機制);throttle機制親grep確認task_reason=='help_call'/'info_scout'字串跟既有code(faction_ai_system.gd:1497,1847,1851)逐字對上+既有『避免重派spam』in-flight guard前例(:531)支持buildable;④de-patch定性=blueprint已裁的WHAT層判斷(求援≠主任務/category error)非HOW越權事項,我只查有沒有偷渡泛化;⑤感知鐵律/determinism沿用前兩輪已驗證的anon carrier零特權+throttle讀既有task_reason零新RNG;CLEAN→build續feat/info-network-whole"
---

# R②判決：Part2 (a) side-action（求援/偵察脫主argmax）— CLEAN + 2 追蹤項

## ①主argmax零改動——結構親驗坐實
親讀worktree `options.gd:342-370`：`求援`(:344-355)/`偵察`(:358+)兩個REGISTRY entry是**各自獨立的dict**（`terms`/`applicable`/`to_task`三key封裝在自己entry內），跟REGISTRY其他option entry之間沒有共用中間變數或交叉引用。移除這兩個entry，主`rank_scored`argmax迴圈遍歷的候選集合就是少兩項，不會改動任何剩下option的util計算路徑——這個「移loser對argmax中性」的claim在結構上站得住，非空口承諾。determinism byte-identical（除herald spawn本身的世界效果外）合理。

## ②mini-util genuine——親驗坐實+同款calibration紀律追蹤
`help_need_severity`(`decision_context.gd:341`)是本session已經驗證過多輪的真實runway缺口值，這次mini-util直接沿用而非重新發明。人格`_pmult`是modulate傾向(務實/傲/義氣)非直接boost分數，跟本session一貫要求的genuine結構一致。**`RELIEF_EXPECT`/`ANON_COST`兩個新常數**——spec自己已經誠實列為R²追蹤項要求錨真值（RELIEF_EXPECT錨食物活命價值/ANON_COST錨1 anon真邊際產出食耗），這跟idle-labor(`PER_HAND_OUTPUT`)/mfg-hub(`GOODS_UPKEEP_RATE`)/bootstrap系列已經要求過的同款紀律一致——**我原樣延續這個要求**：implementer訂值時必須交代錨定依據，非反推「調到剛好讓求援fire」。per-team mini-util dump（務實早求vs傲撐分化）留作驗收項。

## ③scope硬限——親驗支持，要求build時鎖死非做成可插拔
spec §2「新side-dispatch pass」文字明列**兩個具名分支**（herald一段、scout一段），不是寫一個「REGISTRY裡標`type:"side"`的entry都自動跑這個pass」式的泛化機制。這個文字設計支持「非泛化side-task框架」的claim。★但這是我對spec**文字**的檢查，不是對最終code的檢查（這輪是pre-build）——**要求**：implementer落地`_step6b2_info_dispatch`時，這兩支必須是寫死的`if`/具名函式呼叫(`herald`/`scout`各自明確調用)，不能抽象成「掃描某個標記讓未來任何option都能掛進來跑」這種通用plugin機制，否則就是繞過主argmax紀律的後門——這不是我猜測會發生，是明確標注給build階段的紅線，QA/measurer階段順手看一眼`_step6b2_info_dispatch`函式體是不是真的只認這兩支。

## throttle——親驗字串/機制對得上
親grep確認`task_reason=="help_call"`(`faction_ai_system.gd:1847`)、`task_reason=="info_scout"`(`faction_ai_system.gd:1497,1851`)跟spec寫的throttle判斷字串逐字一致，非我猜measurer/systems編的名字。既有`:531`「是否已有in-flight子隊朝該outpost安頓中（避免重派spam）」這個既有helper模式證明「查自家subteam_ids裡有沒有matching task_reason的in-flight子隊」這個throttle手法在這codebase已經有前例可循，非發明新機制。

## ④de-patch定性——WHAT層判斷已由blueprint裁定，非我這輪要重新論證的事
「求援≠主任務、逼進單task argmax互斥=category error」是blueprint在`2026-08-04-blueprint-to-systems-side-action-ruling-diagnostic-first.md`已經親自裁定的WHAT判斷（跟「信使≠subteam」同一家族推理）——這屬於WHAT owner的權責範圍，我這輪R②只確認HOW落地有沒有偷渡范圍外的東西（見③），不重新質疑這個category-error判斷本身是否成立。

## ⑤感知鐵律/determinism
anon carrier零特權（只送simple distress、名冊target_pos position-only）沿用前兩輪(bootstrap fix/dispatch fix)已經親驗過的機制，這輪沒有新增讀取路徑。throttle讀既有`task_reason`字串比對零RNG，mini-util算術判斷零RNG，spawn沿用既有`_spawn_anon_herald`（上輪已驗證）。

## 判決
**CLEAN + 2追蹤項（calibration常數錨真值紀律／build時鎖死兩支硬編碼非做成可插拔side-task框架）→ 回systems → build（續`feat/info-network-whole`）→ re-measure whole（`help.herald_dispatched>0`+`distribute.dispatch/food_delivered>0`連動+人格分化+主argmax determinism byte-identical+Part1/3不退）→ QA故事稽核。** ①②③三個最需要戳的點都往下追到file:line/既有前例層級，非停在spec文字表面；④屬於已裁WHAT非這輪重審範圍。
