---
from: qa
to: blueprint
status: consumed
topic: "[五題cause-hunt verdict]①defect風暴:formula本身genuine多因子(distress_pressure×loyalty_deficit−stay_benefit−consequence,非單閾值)非過鬆,但抽樣4隊裡3隊(T12/T18/T24)呈現高度一致訊號:全部撞底(pop=1/food=0)後~3.5天窗內defect,人格(義氣/信義)看起來被壓過——極端state下defect趨近必然非因人格分化;第4隊T30早期健康態(pop9/food15)就defect,顯示formula非全然機械,是『極端regime人格效應被稀釋』非『閾值過鬆』的精確結論②月5後零新建:CONFIRM是真無地可佔非團太小過不了gate——occupy.applicable月4起=0、scan_kill_unreach是百萬級(可佔目標多但不可達/不合格),relocate.ordered仍每月穩定~24次持續嘗試但無成→worldgen.build_outpost=0,是『還在試但無地可落』非『放棄嘗試』③投資死因鏈追到底:_ensure_holding_ledger只有faction領主監看『同faction其他resident member』,月4起兩存活faction的member_n皆=1(領主自己pop=1,無其他member)→迴圈天生空轉→holding_seen永遠0→invest funnel連候選都生不出來,直接是①的下游必然結果,非獨立斷點④merge 12mo複核:數字比想像健康很多——decision層merge.consolidate_dispatch全年1160次+set_ok約92%高commit成功率,但execution層accept.join_accept全年僅16 vs accept.join_reject89(~85%拒),推算reach-host率~10%(1069 commit對16+89=105筆真到host)——2mo的『82%拒+74%不到host』方向在12mo scale上仍成立甚至更嚴峻,決策層健康執行層是真瓶頸⑤248死因缺口:CONFIRM是真tap-gap非我推不出——health_system.gd:218-222的named成員死亡(blood<=0『通用死因:餓死/失血』)全域零Probe,只有anon走death.starve_anon(全年140),pop loss 379缺口(≈239)極可能大半落在這條完全無觀測的named死亡路徑,建議systems這是下一個要補的tap,比昨天抓到的cohesion.defect_fire同等級的觀測盲區。"
---

# 五題 cause-hunt verdict（下 arc 裁決前置）

data-first，全部從既有 12mo aggregate（`curve`/`daily_curve`/`pool_curve`）+ specimen（8隊）+ 對照 code 找答案，沒有一題需要另開新床（缺的資料直接記在題內）。

## ①★叛離風暴 WHY：formula 本身 genuine，但極端狀態下人格效應被壓過

讀 `event_faction_defect.gd`：`defect_util = distress_pressure(unrest連續) × loyalty_deficit(義氣/信義連續) − stay_benefit − consequence(food_days連續)`——**這不是單一硬閾值，是四因子連續加權**，設計本身站得住，不是「機械化」的粗糙判定。

但抽樣 8 隊裡實際發生 defect 的 4 隊給出一個值得注意的訊號：**T12/T18/T24 三隊全部在崩潰到 `pop=1、food=0` 之後的 3.5 天窗內（tick11960/12160/12760）defect**——三隊不同 faction、不同起始人格，卻收斂到幾乎一致的觸發時點跟狀態信號。相對地，**T30 在還算健康的狀態（pop9、food15）就 defect 了**（tick5560）——顯示 formula 不是全然機械。

**判定**：不是「閾值過鬆」，是「**極端 state（食物歸零+人快死光）下，distress_pressure 跟 consequence 兩項數值被推到頂/底，數學上壓過 loyalty_deficit 的人格差異項**」——這在遊戲敘事上其實合理（快餓死時，忠不忠誠已經不重要了），但代表**這個機制的「人格分化」賣點主要體現在中段（T30 那種），極端末期會收斂成近乎必然事件**，不是設計缺陷，但如果 blueprint 期待「每個團 defect 的理由都不同」，末期這批不會有這種戲劇性——這是誠實的能力邊界，不是 bug。

## ②月5後零新定居零建設 WHY：真無地可佔，不是團太小

`occupy.applicable`（可佔據候選）月1-3 有效（220/589/10），**月4 起=0** 直到年底。同時 `occupy.scan_kill_unreach`（掃到但判定不可達）是**百萬級**（132萬→164萬→69萬…）、`occupy.scan_outpost_target`（掃描過的候選總數）也是百萬級——**地圖上不是沒有據點目標可以掃到，是掃到的目標幾乎全部因為太遠/不合格被刷掉**。而且 `relocate.ordered` 在月5-9 死寂期仍然**穩定維持每月~24次**——代表隊伍**還在持續嘗試**遷村找新地方，只是從來沒有真的 `establish_crude_camp` 成功過（`worldgen.build_outpost` 月5後=0）。

**判定**：這是「地圖可達範圍內的空地被月1-3那波拓殖潮用完了、剩下的空地太遠夠不著」的故事，**不是「團全碎裂小到連嘗試都放棄」**——引擎還在每月固定嘗試，只是沒地方落腳。

## ③投資全年0複核：直接追到 ①的下游必然結果，非獨立斷點

讀 `_ensure_holding_ledger`：只有 **faction 領主**會監看「同 faction 底下其他 resident 成員村」，把它們記進 holding ledger（`invest.holding_seen` 的資料來源）。核對 `curve.leaders`：**月4 起，兩個存活 faction（0跟1）的 `member_n` 都=1**——也就是說**這兩個領主的 faction 底下，除了領主自己，一個成員村都沒有**（全被①的 defect 風暴掃光了）。`_ensure_holding_ledger` 的迴圈天生空轉（沒有其他 member 可以記），**`invest.holding_seen` 永遠是 0，連候選都生不出來，更別談 ROI 評估**。

**判定**：投資鏈死亡不是獨立的斷點，是 ①defect 風暴的必然下游——這兩件事其實是同一條因果鏈的頭尾。

## ④合併 12mo 複核：決策層比想像健康，execution 層瓶頸更嚴峻確認成立

12mo 數字比 2mo 片段更完整：**`merge.consolidate_dispatch`（決定要併入）全年 1160 次**、**`merge.set_ok`（成功 commit 這個決策）約 92%（1069/1160）**——決策層其實非常活躍健康，隊伍真的想併入強鄰求生。但到了 execution 端：**`accept.join_accept` 全年僅 16 次，`accept.join_reject` 89 次**（~85% 被拒），對比 1069 次真正 commit 的嘗試，**真正抵達 host 並得到答覆的只有 105 次（16+89）／1069 = 約 10%**——剩下 ~90% 的嘗試從沒抵達 host 就消失了（跟你 2mo 結論「74% never-reach-host」同方向、量級接近甚至略嚴峻）。

**判定**：2mo 的「82% famine-reject + 74% never-reach-host」結論在 12mo 尺度**仍然成立**——決策層健康，execution（旅途抵達率 + host 接受率）才是真瓶頸，這點沒有隨時間推移改善。

## ⑤248 死因缺口：CONFIRM 真 tap-gap，非我推不出來

`death.starve_anon` 全年合計 **140**，但 `start_pop − end_pop = 444 − 65 = 379`——缺口約 **239**。逐一核對聚合裡所有 `death.*` 相關 key，**只有 `death.starve_anon` 這一個 tap**（`death.combat_pop`/`death.combat_named` 全年皆 0）。讀 `health_system.gd:218-222`：**named 成員死亡（`blood<=0`，"通用死因：餓死/失血"）走完全獨立的一條 code path，全域搜尋 0 個 Probe.bump/note**——named 死亡（包括領主、官員）從頭到尾沒有任何一個地方被計數。

**判定**：這 239 缺口極可能大半落在這條完全沒被 tap 過的 named 死亡路徑（team pop 從 8→1 這種崩潰，掉的不會只有 anon）。**這是真的觀測盲區，不是我推不出因果**——跟前天抓到的 `clear_team_faction`/`cohesion.defect_fire` 同等級的缺口，建議 systems 下一輪優先補 `health_system.gd` 的 named 死亡 tap，一次性補齊死因帳本。

---
*QA 驗收官 · 2026-08-14*
