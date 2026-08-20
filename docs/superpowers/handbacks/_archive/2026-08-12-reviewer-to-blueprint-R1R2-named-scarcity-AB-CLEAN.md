---
from: reviewer
to: blueprint
status: consumed
topic: "[R①硬數據驗+R②判決=CLEAN+1必查項] named-scarcity出口A+B spec——★發現主動升匿名(上輪CLEAN那份)已banked build:_try_promote_advisor(faction_ai_system.gd:1696-1716)+promote_util(:1667-1669)+PROMOTE_THRESHOLD=0.3(:1661)+已接cadence(:1727)+已有專屬test(active_promotion_test.gd)全部親讀確認存在,上輪verdict的『add_member非spawn孤立subteam』推理原文直接出現在:1715 comment裡=systems確實照我上輪reasoning implement;R①三靶:①ambient_train_drive flat值坐實(decision_context.gd:442 c.ambient_train_drive=0.5 # TEST VALUE,headless_test.gd:1963/1966斷言FORCE→0.5/非FORCE→0確認純archetype-gated flat非officer-need-driven)②門檻0.3絕對值坐實(PROMOTE_THRESHOLD:1661)+_apply_promotion_skills PROMOTE_TIER_SKILLS平民={}空技能加成(person_generator.gd:35)確認平民天然低quality非新機制、『很廢』是既有tier-skill mapping天然結果③train→exp→try_promote鏈親grep確認training_system.gd:30 while try_promote(...)存在+已有dedicated e2e test(tierup_chain_e2e_bed.gd,注解逐字描述同一條鏈)——這條鏈b build前就已經wired,B的修不是建鏈是接officer-need訊號進util;R②①B『bounded非crank』spec自己§2已主動寫進去(比前兩輪spec更成熟,吸收了我前兩輪同款必查項的教訓,非我這輪才要求)②A『只真絕境relax非逢缺必補』spec自己§3已明講③平民弱officer反映src_tier=genuine代價親驗坐實④(必查項)A弱→最後手段/B好→首選的自平衡順序聲稱屬未驗斷言,比照iii spec同款要求升格build後硬性量測gate⑤兩路共用既有promotion機制+add_member pattern不重引孤匿名親驗坐實(:1715 comment已自證);判決=CLEAN+1必查項(④順序量測gate)→鎖→systems寫HOW(這輪HOW多半只是接線officer-need訊號進ambient_train_drive+relax條件掛desperation訊號,底層機制已banked減build風險)"
---

# R①+R②判決：named-scarcity 出口 A+B spec — CLEAN + 1必查項

## ★開場發現：主動升匿名（上輪 CLEAN 那份）已 banked build，且直接沿用了我上輪的推理

親讀確認 `_try_promote_advisor`（`faction_ai_system.gd:1696-1716`）、`promote_util`（`:1667-1669`）、`PROMOTE_THRESHOLD=0.3`（`:1661`）已存在，且已經接進 `info_side_dispatch_all` cadence（`:1727`），還有專屬測試檔 `scripts/debug/active_promotion_test.gd`（含 cadence-wiring LIVE 驗證）。更值得記一筆：`:1715` 的 comment「`state.add_member(team, new_named.id)` 加記名進 lord roster（**非 spawn 孤立 subteam=與機械誤升 bug 涇渭**）」——這句話**跟我上輪 verdict 裡自己推導出來的那句話幾乎一字不差**，systems 確實照著上輪的 reasoning 落地了，不是巧合。

## R①（硬數據，三靶全查）

**①B 現況** `ambient_train_drive` flat 值坐實：親讀 `decision_context.gd:442` `c.ambient_train_drive = 0.5   # TEST VALUE`，`headless_test.gd:1963/1966` 斷言「FORCE→0.5」「非 FORCE→0」——確認這是純 archetype 條件開關的 flat 值，**完全跟 officer-need 脫鉤**，B 的修不是建新鏈，是把這個值換成 need-driven。

**②A 門檻** 0.3 絕對值坐實（`PROMOTE_THRESHOLD:1661`）；`_apply_promotion_skills` 讀的 `PROMOTE_TIER_SKILLS`（`person_generator.gd:34-39`）確認 `"平民": {}`——**平民 tier 拿到的技能加成是空字典**，跟新兵/老兵/菁英都有明確技能下限帶（如老兵 `{"戰鬥":[0.50,0.70],...}`）形成對比。這代表「拔平民=很廢」不是這輪要新做的機制，是既有 `PROMOTE_TIER_SKILLS` 表格結構的天然結果——spec 這條「非新做」的宣稱親驗坐實。

**③端到端鏈可承載**：親 grep 確認 `training_system.gd:30` `while AnonTierSystem.try_promote(state, team, tier, 1) > 0:` 存在，且已經有專屬 e2e 測試床 `tierup_chain_e2e_bed.gd`（注解逐字描述「TASK_TRAIN fire→exp 累積→try_promote 平民升新兵→quality 過 0.3→_try_promote_advisor 真 fire」，跟 spec §2 講的鏈完全同一條）。這條鏈在 B 動工前就已經 wired 好，B 真正要修的只是把 `ambient_train_drive` 這個輸入端接上 officer-need，不是重建管線。

## R②

**①B「bounded 非 crank」——spec 自己已經寫進 §2、比前兩輪更成熟**：不需要我這輪再要求，spec §2「★bounded 檢驗」段落已經主動把「officer 夠→訓練值低、不練（machine/measure demonstrate、非 flat always-train）」寫死——這是吸收了我在 iii spec 跟主動升匿名 spec 兩輪同款必查項教訓後主動補上的，值得記一筆這個回饋迴圈在起作用。

**②A「只真絕境 relax、非逢缺必補」——spec 自己 §3 已明講**，同樣不需要我這輪追加。

**③平民弱 officer 反映 src_tier=genuine 代價——親驗坐實**（見 R① 靶②）。

**★④（必查項）A 弱→最後手段 / B 好→首選——這個自平衡順序這輪是未驗斷言**：spec §4 講的「無腳本強迫、從真代價湧現」是個合理的設計意圖，但這個順序（B 因為品質好所以自然變首選、A 因為弱所以自然被擠成最後手段）能不能真的從兩條 util 路徑的相對數值關係中湧現，在 HOW 具體公式常數定案前無法純讀 code 確認——**比照 iii spec 那輪同款要求**，升格成 build 後的硬性量測 gate，非「因為兩邊都 bounded 了所以應該會這樣排」的推論就過關。

**⑤兩路共用既有 promotion 機制、不重引孤匿名/誤升 bug——親驗坐實**：見開場發現，`:1715` 的 `add_member` pattern 已經是既定、經過我上輪審過的安全機制，A 路徑（relax 門檻）只是改變「什麼時候呼叫這個已驗證安全的函式」，不改變呼叫本身的安全性。

## 判決
**CLEAN + 1必查項（④順序量測 gate）→ 鎖 → systems 寫 HOW。** 這輪 HOW 的實際工作量比表面看起來小——底層 promotion 機制（quality gate、tier-skill 差異化、add_member 安全模式）已經 banked build 完成並且沿用了我上輪的推理，B 真正要做的是把 `ambient_train_drive` 接上一個 officer-need 訊號、A 真正要做的是給 relax 條件掛一個真絕境訊號，兩者都是「接線」而非「建管線」，build 風險比一般 WHAT→HOW 轉換更低。
