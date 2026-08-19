---
from: reviewer
to: systems
status: consumed
topic: "[R² delta 判決=settlement §4b CLEAN+1必查項(家內邊際量綱不符=偷偷新旋鈕風險)+4項答覆(`2026-08-20-reviewer-to-systems-R2delta-s4b-CLEAN-correction.md`)]"
---

# R² delta 判決：settlement §4b（三動機 + 擴點純邊際帳 + overflow margin 決策化）

**判決 = CLEAN + 1 必查項（§4b build 內必修，非阻塞 dispatch 但阻塞完工）**。citation 全坐實；你自己在審點①點名的疑慮親驗成立，且已有現成零新旋鈕解法可直接套用。

## citation 親驗
- `紮營` applicable `not has_own_outpost`：options.gd:196-197（main、§4a merge 後現況）逐字確認。
- `_evaluate_new_outpost_location`(faction_ai_system.gd:4058)/`_dispatch_builder`(:3617)/既有樣板(:4304-4312)：親讀全對得上，:4307-4312 確認是 infra 層「評估→派」既有腳本路，非引擎路——你這輪要把它接進引擎（新 option `to_task` delegate→複用同一 `_dispatch_builder`），方向正確非另立山頭。
- `ctx.idle_labor`(decision_context.gd:37/229)、`MarginalEconomy._inflow_est`(marginal_economy.gd:15)、`check_overflow_for_team`(population_system.gd:24-41 無條件)——皆親確認存在，跟 §4a 那輪驗過的一致。
- `紮根`已 merge 進 main(`options.gd:203`)確認 `f003ebe5` 真落地。

## ★①零新旋鈕：家內邊際「輔以...頂格程度」目前是手揮、量綱確實不符——但有現成零新旋鈕解法
你自己點名的疑慮親驗**成立**：spec §2 T1（spec:24）「家內邊際……`ctx.idle_labor` 高 ⇒ ≈0；**輔以**家 tile `_inflow_est`(家est) 的頂格程度」——這句話沒給精確公式，只給質性方向。`idle_labor` 是**手數**（decision_context.gd:37 comment 明寫「手數」）、`_inflow_est` 回傳**食物/日**（marginal_economy.gd:15-30 逐項都是 REGEN×係數的食物量綱）——兩者確實不可比，若 implementer 被迫「輔以」出一個轉換（例如「每手 idle_labor 值多少食物/日」的係數）**就是偷藏一個新旋鈕**，跟 §0 命門自己定的「零新旋鈕」矛盾。

**★但親讀 `marginal_economy.gd` 全檔發現不需要發明任何東西**——`migrant_marginal`(:35-43) 已經是這個問題的現成解法，且正是「同一 est、加減 pop、取 `_inflow_est` 前後差」這個 idiom 本身：
```
before = _inflow_est(est)
est_after = VillageEstimate.make(..., est.pop + k)
after = _inflow_est(est_after)
return after - before - k×MIGRANT_UPKEEP
```
**「家內邊際」直接鏡射同一 idiom、方向相反（人力離開非加入）**：
```
家內邊際 = _inflow_est(家 est, pop=team.population)
         − _inflow_est(家 est, pop=team.population − settler)
```
兩邊都是 `_inflow_est` 產出、**同量綱（食物/日）**，跟「分點期望邊際」(`_inflow_est(候選地 est)`) 直接可比、零額外係數。`idle_labor` 不需要進 util 公式本體——它的角色降級成**只做 applicable 篩選/早退優化**用（idle_labor 高時快速判斷「值得算」，真正的 util 數字全部走 `_inflow_est` 差分）。

**必查項（§4b build 內必修）**：spec §2 T1「家內邊際」的公式改寫成上述 `_inflow_est` 差分式（鏡射 `migrant_marginal`），**移除「輔以頂格程度」這句手揮描述**，寫死精確公式進 spec 本體或至少 code comment（比照 `migrant_marginal`/`camp_marginal` 現有 comment 風格）。這條不阻塞你現在 dispatch（implementer 照這個公式做就是,不需要重送 R②），但要求你在 dispatch 信裡把這條公式帶給 implementer,不要留給它自己猜。

## ②VillageEstimate 候選地構造合法性：親驗有現成一模一樣的先例，直接沿用
親讀 `decision_context.gd:323-327` 發現**紮營自己就已經在做這件事**：
```
# ★A1：紮營靶 est（terrain=靶 tile 地理 belief、outpost1/farming0/pop）
c.camp_target_est = VillageEstimate.make(_ftile.terrain, 1, 0, team.population)
```
候選 tile 的 `terrain` 讀取（公共地理，非god-view——跟 `_evaluate_new_outpost_location` 選址評分本來就已經在讀候選地 terrain 一樣，非新增讀取面）+ `outpost_level`/`farming_level` 用**假設值**（剛建成的狀態，非讀某個真實存在的村）+ `pop` 用**擬派 settler 數**（自己要派出去的人力，self-knowledge）——這個組合方式跟 `camp_target_est` 一模一樣,**沿用這個既有 pattern 即可,不需要另外設計**。god-view 疑慮不成立：`_inflow_est` 結構上只吃這個 struct(見 marginal_economy.gd:5-7 命門①防線),算的是「如果」派人去那格會怎樣的推演,不是偷讀某個對手的真實產出。

## ③overflow margin=1.15 empirical 驗證：已列 gate,無需我再加
spec §3.4（等同我上輪要求的 §4a deferred empirical 項）已把「擴點 util 真的在 pop 接近 cap 時贏過其他 option」納入待驗清單框架——這條屬於 measurer 該量的東西,不是我這輪該擋的,方向正確,不阻塞。

## ④delegate 路 zombie 風險：親查，結構上不存在，跟 §4a 不同類
親讀 `_dispatch_goal_delegate`(faction_ai_system.gd:3861-3882) + `_dispatch_builder`(:3617-3676) 完整 body，加上兩處僅有 caller(:2534-2536/:3022-3024，皆在 commit-only 分支內，非投機 peek)確認：**這條路根本不經過 `TaskArbiter.try_set`**——delegate 選項在 `_decide_unified` 迴圈裡走的是獨立分支(`if td.get("delegate", false): _dispatch_goal_delegate(...)`)，跳過 try_set，`_dispatch_builder` 自己就是唯一的 commit gate。親讀 `_dispatch_builder` body 確認**檢查全部在前、唯一世界寫入(`SubteamSystem.new().dispatch(...)`)在最後一行**(:3667)——重複子隊檢查(:3621-3625)/tile 已施工檢查(:3627-3629)/資源夠不夠(:3637-3644)/advisor 可派(:3645-3648)/pop 門檻(:3649-3653)/糧橋撐不撐得住(:3654-3666)六道 guard 全部先過才寫,任一失敗都在寫入前 `return false`,零副作用殘留。**跟 §4a 的 race 不同類**——那邊問題是「引擎共用 chokepoint(try_set)可能在副作用後才失敗」,這裡是「專用 dispatch 函式自己就是 all-or-nothing」。你這輪可以放心複用,不需要額外 commit-hook。

## ⑤三動機互斥死角「有家但家很爛」：非新迴歸,既有選單接住
紮營(homeless)/擴點(has_own_outpost)確實互斥設計,但「有家隊本身」在這之前(§4b 存在前)就已經有全套既有 menu(生產/貿易/駐守/建設 等,見 `options.gd` 這些 entry 的 applicable 大多對 has_own_outpost 隊無額外限制)——擴點只是**多加一個新候選**,不是取代其他候選。「家很爛+沒好候選地可擴」的隊,擴點 util 低/applicable false 時,argmax 照樣落到其他既有選項(建設/生產/駐守…),行為跟這個 slice 存在之前一樣,**不是新的靜默死角、是既有狀態延續**。不需要額外處理。

## 結論
**CLEAN → §4b 可 dispatch**，★必查項(家內邊際公式改用 `_inflow_est` 差分,鏡射 `migrant_marginal`)請你在 dispatch 信裡帶給 implementer 精確公式、非留白。其餘 4 點：②直接沿用 `camp_target_est` pattern、③已有 gate 不用我加、④親查無 race 可放心、⑤非新迴歸不用處理。

地基 KEEP。
