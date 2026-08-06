---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] recovery-path Slice R3(遷村令，復甦arc收官slice)——★①村遷村執行端compound reuse親驗坐實非空想:_action_abandon_outpost(player_command_system.gd:525-536,main分支)親讀確認機制極簡(單行OutpostOwnerBank.set_owner(tile,-1,'abandon')),零player專屬耦合,generalize到AI側零架構風險;_convert_to_resident親確認實際定義在InteractionSystem(interaction_system.gd:1363-1382,非spec引用位置faction_ai:2142,那是呼叫點faction_ai_system.gd:2110附近,行號drift非函式不存在)——親讀完整函式體確認寫得夠通用(TAG_SUBTEAM/流亡tag移除皆用state.remove_tag條件式非強制假設存在、detach_subteam對無parent的team應為安全no-op)這代表這個函式不是只服務『剛分裂出的小型subteam』這個窄情境,套用在『整個既有resident team棄舊據點遷徙後落腳』這個更寬情境上沒有明顯地雷,compound reuse claim通過直接code驗證非只信文字類比;spec自己要求的『測真全advance_tick pipeline驗村真完成遷』這個驗執行端硬標正確且必要,build-time測試須包含這個具體風險點(整team非subteam走這條路是否有任何被略過的細節)非只驗決策fire;②relocate目標god-view防線親驗跟§1.0 VillageEstimate同款結構(領主令=own-faction行政知/村自願遷=vision-explored鏡射既有遷移找糧options.gd:288 pattern,本session已多輪驗證這個vision-explored pattern合法)防線齊;③relocate_value=MarginalEconomy第3 marginal,god-view結構跟R1/R2用的VillageEstimate同一套已驗證防線非新開一條;④從抗人格秤結構genuine(忠懼/傲戀土兩極對應從/抗非死常數門檻)+unrest reuse cohesion在本arc前幾輪已反覆驗證;⑤letter kind=relocate延伸親驗屬於已確認的trivial extension(letter travel/timeout/intercept infra kind-agnostic,只deliver分支需要新case,這是我在recovery-path R①那輪已經親驗過的具體claim);⑥抗命後果留鉤子(武力押遷=軍事arc)+P5起義/叛離出口承接暴君逼反,範圍切分誠實非把軍事arc硬塞進來;CLEAN→dispatch implementer build(feat/recovery-r3)"
---

# R②判決：recovery-path Slice R3（遷村令，復甦arc收官slice） — CLEAN

## ★①村遷村執行端compound reuse——親驗坐實，非空想類比
這是這輪標成「驗執行端命門」的重點，我沒有停在spec文字層級，往下追每一段reuse claim的實際code。

**`_action_abandon_outpost`**（`player_command_system.gd:525-536`，main分支）親讀完整函式：機制極簡——`OutpostOwnerBank.set_owner(tile, -1, "abandon")`一行核心操作，前面只是輸入驗證（位置合法/outpost存在/owner是自己）。這個函式雖然現在的輸入來源是`state.player_state`（玩家指令），但核心的狀態變更操作本身**零player專屬耦合**——generalize到AI側只是換一個輸入來源（AI決策給的target），不需要重寫核心邏輯，架構風險低。

**`_convert_to_resident`**——親grep確認spec引用的行號（`faction_ai:2142`）指的其實是**呼叫點**（`faction_ai_system.gd:2110`附近，`InteractionSystem.new()._convert_to_resident(state, sub)`），函式本體實際定義在`interaction_system.gd:1363-1382`——這是行號因為檔案持續增長而drift的常見現象（本session已見過多次），非函式不存在。我親讀完整函式體：

```
func _convert_to_resident(state: WorldState, subteam: TeamData) -> void:
	if not subteam.tags.has(TeamData.TAG_PRODUCE):
		state.add_tag(subteam, TeamData.TAG_PRODUCE, "convert_resident")
	state.remove_tag(subteam, TeamData.TAG_SUBTEAM, "convert_resident")
	state.remove_tag(subteam, "流亡", "convert_resident")
	...
	state.detach_subteam(subteam)   # 變居民脫離母團（雙向同步）
```

這個函式寫得**夠通用**——`TAG_SUBTEAM`/`流亡`tag的移除都用`state.remove_tag`（條件式，非強制假設這些tag存在）、`TAG_PRODUCE`的添加也有`if not has`前濾、`detach_subteam`對一個從來不是subteam（`parent_team_id==-1`）的team呼叫應該是安全no-op（雙向同步機制的既有設計慣例）。這代表這個函式**不是只服務「剛分裂出的小型subteam」這個窄情境**，套用在「一整個既有resident team棄舊據點遷徙後在新地方落腳」這個更寬的情境上，沒有看到明顯的地雷（沒有寫死假設「這一定是個剛spawn的小隊」）。這個compound reuse claim通過我直接讀code驗證，非只信spec的文字類比。

spec自己要求「測真全`advance_tick`pipeline驗村真完成遷」——這個驗執行端硬標正確且必要，我認同要保留、且要求build-time測試務必包含這個具體風險點：**整個既有team（非新spawn的subteam）走abandon→mobile→TASK_SETTLE→convert_to_resident這條路，有沒有任何被既有測試覆蓋範圍略過的細節**（例如這個team的`named_members`/`memory`/`dispatch_ledger`等既有身分資料在這個轉換過程中會不會被意外清空或錯誤處理）——這條路徑至今只被「新subteam安頓」的情境測過，「既有team整team搬家」是這次真正的新組合，值得在測試裡明確標一個獨立案例非只信「兩邊函式各自沒問題所以組合也沒問題」。

## ②relocate目標god-view防線——親驗跟既有VillageEstimate/vision-explored同款結構
領主令target=own-faction行政知（同`§1.0 VillageEstimate`結構欄來源，這條防線上兩輪round2/Slice R2已經親驗過）；村自願遷target限vision-explored/reachable（鏡射既有「遷移找糧」`options.gd:288`的視野可達pattern）——這個vision-explored pattern本session稍早已經反覆驗證過是合法、既有的感知鐵律模式，非新發明。防線齊。

## ③relocate_value——沿用已驗證的結構防線
`MarginalEconomy`第3個marginal量，god-view結構跟R1（移民）/R2（投資）用的`VillageEstimate`是同一套已經被我逐行驗證過兩輪的防線，非新開一條路徑，這輪不需要重新驗證輸入面。

## ④從抗人格秤+⑤令延伸+⑥抗命後果——皆沿用本arc已驗證的機制
從/抗兩極對應忠懼/傲戀土人格值、非死常數門檻，`unrest`reuse cohesion——這些是勢力凝聚力arc已經反覆驗證過的genuine結構。`in_transit_letters`加`kind="relocate"`——這正是我在recovery-path R①那輪親自驗證過的具體claim（letter的travel/timeout/intercept整條生命週期完全kind-agnostic，只有deliver分支需要新增一個case），非這輪才第一次評估。抗命後果留鉤子給軍事arc、不在這個slice裡實作強遷——範圍切分誠實，沒有把不屬於這個arc的東西硬塞進來。

## 判決
**CLEAN → dispatch implementer build（`feat/recovery-r3`）→ 量（令送達+從抗分化+怨→叛/起義劇情鏈）→ QA → merge = 復甦arc收官。** 這輪最重要的工作是把「compound reuse」這個claim拆開，逐一讀到三個被組合的既有函式的實際程式碼（非只看函式名字對不對），確認`_convert_to_resident`寫得夠通用、`_action_abandon_outpost`零player耦合——這是這個arc最後一個slice，通過的話整個復甦路徑三動詞就閉環了。
