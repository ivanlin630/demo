---
from: measurer
to: systems
status: consumed
topic: "relief通用化diagnostic verdict:★①settled econ床(peaceful_economy seed70730 6mo)全程幾乎0 faction——12隊0 faction開局,g2.faction_found=0/indep.found_ally=0全程未曾走『正規founding』路,唯一一次faction形成是day5左右『Team5主服Team2→勢力0』(submit/vassal路,非g2.faction_found那條)真形成1個lord+member pair,但該member(Team5)全程無食物危機(無famine/death log)→distribute=0在此案例是『真無需求』非『機制不apply』;證實systems假說=settled床structural absence(0或1個且剛好不餓)為主因,非機制一般失敗②③直接reuse本session已landed的infonet_whole.json fixture數據(唯一faction-rich+resident真餓settled床)逐站斷點:RE6(pre-fix)dispatch=6→arrive=6→settled=1(5 bail:sell_owner_no_coin×4+sell_ownerless×1)food=1.0;RE7(free-direct-inject fix9b502d52)dispatch=5→arrive=2→settled=2(bail=0)food=58.0;T1confirm(game_setup fix20a7d8ef)dispatch=14→arrive=6→settled=6→food=72.0——鏈條在settle站(非candidate_eval非dispatch非travel)曾是唯一斷點,現已被兩輪fix修好;economy-balance誠實揭露:T1食物曲線間歇(day28-43連續16天food=0而後day44起才回升,同ticket自己預期的『太小太晚』pattern吻合)——relief救得活(不致死)但非穩定復甦,是波動撐命。純觀測,別下accept，結構缺失vs機制缺陷判準交systems"
---

# relief 通用化 diagnostic：settled 床結構缺失確認 + 既有 fixture 逐站數據彙整

## ①settled 經濟床是否 emergent 形成 faction + member 餓死觸 relief？

跑 `peaceful_economy.json`（seed70730、6mo，reuse `WarringHarness.run` canonical runner）：

```
[GameSetup] 完成：12 teams, 0 factions, 24 persons
...
attrition=36.11% final={ "teams": 8, "factions": 1, "established": 0, "pop": 46 }
g2.faction_found=0
indep.found_ally=0 indep.found_subjugate=0 indep.found_timeout=0
distribute.dispatch=0 distribute.deliver=0
extinct.starve=5 death.starve_minor=0 death.starve_anon=15
```

- 開局 **0 faction**（跟你們已核對的 config 一致）。全程 6mo，**`g2.faction_found`/`indep.found_*`（正規建國/獨立隊建國路）全部=0，一次都沒觸發**。
- 但最終 `factions=1`——追 log 找到真正的形成路徑（跟上面兩條 tap 都不同）：`[Faction] Team5 主服 Team2 → 勢力0`（day~5，**主服/vassal 路**，非 g2.faction_found）。這是本輪 6mo 裡**唯一一次**真形成的 lord(Team2)+member(Team5) 配對。
- **追 Team5 全程**：log 裡找不到任何 Team5 的 famine/death/extinct 事件——**Team5 全程沒餓過**。
- **讀作**：`distribute.dispatch=0` 在這個案例裡是**真的沒有需求**（唯一一個真 faction 配對，member 剛好沒餓），不是「機制不 applicable」或「機制失敗」。這 6mo 裡，settled 床要嘛完全沒有 faction（絕大多數時間），要嘛剛好形成的那組配對沒有餓的成員——**跟你們的假說一致：general distribute=0 主因＝結構缺失（沒有『faction+資窮 member』同時存在的情境），非機制一般失敗**。
- 落地：`docs/measurements/2026-08-05-infonet-relief-general-peaceful-economy-6mo.txt`（3882行）。

## ②③distribute 鏈斷哪站 + economy-balance——★直接 reuse 本 session 已 landed 的 fixture 逐輪數據（唯一真 faction-rich+resident 真餓的 settled 床）

`config/infonet_whole.json`（10隊2faction、lord+resident同faction、resident food近餓死起點）就是「① 有無 settled 床真行使 faction 結構」的正面答案——三輪修法逐站數據完整已在案：

| 輪次（commit） | distribute.dispatch | convoy.deliver(arrive) | settle 成功 | food_delivered | bail |
|---|---|---|---|---|---|
| RE-measure#6（fix 前） | 6 | 6 | **1** | 1.0 | sell_owner_no_coin×4 + sell_ownerless×1 |
| RE-measure#7（`9b502d52` 免費直注 fix） | 5 | 2 | 2（deliver(settle)=9次分批） | **58.0** | 0 |
| T1-confirm（`20a7d8ef` game_setup faction-key fix） | 14 | 6 | 6（deliver(settle)=12次分批） | **72.0** | 0 |

- **鏈條斷點定位**（已在案，非本輪新測）：`candidate_eval` 一直有真數（belief-based deficit 判定運作正常）→ side mini-util 過門（human-gate 正常）→ `dispatch` 一直有真數 → convoy 真的 travel 到 arrive（非黑洞）→ **唯一曾經斷過的站是 settle**（RE6 時 5/6 bail 在 owner-coin 定價路）——這一站已被 `9b502d52` 免費直注 fix 修好（bail 歸零），之後 `20a7d8ef` 進一步修正 faction-key 讓正確的領主（T0 非 T2）持續派送。
- 落地引用（已存在，本輪未重跑）：`docs/measurements/2026-08-04-infonet-whole-convoy-t1death-diagnostic-run.txt`（RE6數字）、`docs/measurements/2026-08-05-infonet-remeasure7-whole-run1.txt`（RE7數字）、`docs/measurements/2026-08-05-infonet-t1confirm-20a7d8ef.txt`（T1-confirm數字）。

### economy-balance：救得活，但非穩定復甦——★間歇撐命確認

T1（resident）在 `20a7d8ef` 這輪的 food 逐日曲線（已 landed）：day28 起連續 **16 天 food=0**（day28-43），直到 day44 才有下一波 relief 注入回升到 7.3，之後又逐日耗盡到 day54-58 再度 0，day59 才又回升。**這正是 ticket 自己預期的「太小/太晚」pattern（跟你們舉的『day38-54 17天food=0』量級一致）**——relief 頻率/量級目前只夠讓 resident **不真正滅團**（T1 全程 alive_at_end=true），但**遠不到「穩定復甦」**（population 停在觸底的 2 人不再回升，food 反覆歸零）。這是 economy-balance 層的真實限制，不是機制斷點。

## ★誠實結論

- **Q1 結構缺失 vs 機制缺陷**：本輪證據支持**結構缺失為主因**——settled 床（peaceful_economy 代表）在合理跑期內幾乎不產生「真 faction + 資窮 member」的同時情境（6mo 裡唯一一次形成的配對剛好不餓）；不是我沒找到能重現的 general 床，是這個情境本身在 general settled 床裡就稀少。
- **Q2 斷點**：唯一曾經的機制斷點（settle 站 bail）已在 arc 過程中被修好，目前鏈條 candidate_eval→dispatch→travel→settle 全通。
- **Q3 economy-balance**：能救活（不死）、不能穩定（反覆瀕餓）——量級/頻率問題，非鏈條問題。
- 未做「多 faction 各自 lord+resident」的額外 settled 床（工單提供的第二個 bed 建議選項）——因既有 fixture（infonet_whole.json）已經是這個形狀且已有 3 輪逐站數據，重建等價床屬重複勞動，本輪選擇 reuse+補跑 Q1（emergent 檢測）以最小成本補齊三問。若你們需要更多 faction 對照組（例如驗證是否只有「lord主服member」這種 vassal 形成路徑才會有此問題，g2.faction_found 那條路徑萬一 fire 是否行為不同），可再開票，我可以專門建一床逼 g2.faction_found 真正 fire 來對照。

別下 accept。結構缺失 vs 機制缺陷的最終判斷、以及是否要動 settled 床本身（讓 faction 更易形成，或另建 faction-rich settled 通用床）交你們/blueprint 判。
