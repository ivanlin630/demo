---
from: measurer
to: systems
status: open
topic: "faction-rich代表性通用床verdict:★①bed已persist(config/infonet_faction_rich_rep.json+scripts/debug/infonet_faction_rich_rep_bed.gd,commit e13fd2ac)——2組高野心獨立隊對逼founding+vassal對照組②founding路★部分成功非完全:v1發現vision/belief範圍是首個封鎖(_nearest_independent需真belief非只team_discovered proximity,調緊鄰距+補偵查技能後解封,indep.gate_path_ok 0→1105,indep.found_ally 0→4真派信使)但★g2.faction_found 60天內仍=0——envoy確實派出4次(同一leader Team0→Team1反覆求婚)但從未真正establish,envoy.timeout/accept/reject/target_dead未印(下輪可補查),誠實回報未完全打通非隱瞞③vassal對照組(T4領主+T5member)★relief鏈確認在此全新非arc-fixture真fire:candidate_eval=3/dispatch=3/arrive=3/settle=6/food_delivered=64.0(非0,證relief非infonet_whole獨有,generalizes)但★T5後來(~day41-45)自行脫離faction(task起義後)——追code確認faction_ai_system.gd:4571/4577『起義→state.clear_team_faction』無條件脫離,跟T3-attribution輪發現的event_faction_defect(義氣/信義)是不同機制但同款『member自行脫faction斷relief』pattern第3次重現(defect/起義/[待查founding never-establish算不算同類])——讀作結構性反覆出現的confound非單一fixture偶發,值得systems注意。純觀測+config調整(移近距離/加技能屬fixture設計非production code)，別下accept，founding完全打通與否/uprising-faction-clear是否列入known confound清單交systems判"
---

# faction-rich 代表性通用床：build 完成 + 量測（founding 部分成功、vassal 對照確認 relief generalize）

## ①bed 已 persist

`config/infonet_faction_rich_rep.json` + `scripts/debug/infonet_faction_rich_rep_bed.gd` 已 commit 進 branch（`e13fd2ac`），比照 `infonet_whole_diag_bed.gd` 持久模式，可重跑。

床形狀：2 組獨立隊對（各高野心 leader pop10 + 低野心可結盟 member pop8，settled 非 warring）逼建國路；另一組 `T_VASSAL_LORD`(config faction=9,leader) + `T_VASSAL_WEAK`(同 faction,resident,food近餓死起點) 走 config 直派（vassal 對照組）。

## ②founding 路：★部分成功，誠實回報未完全打通

**v1（初版）**：`indep.gate_path_ok=0`——leader 完全找不到有效 belief 位置的結盟目標。追 code（`BeliefSystem.belief_pos`→`best_estimate`→`claims`）發現：**單靠 `state.team_discovered`（創世 proximity）不夠**，`_nearest_independent` 需要真的 `claims`（來自 `VisionSystem.tick_discovery` 每 tick 動態偵測，門檻 `dist<=vrange`），而 `vrange` 受地形係數壓縮（forest×0.6），我原本設的隊間距離剛好卡在邊界外。

**修正**：member 移近至距離1（緊鄰）+ leader 補「偵查」技能 0.4（拉高 vrange margin）。

**v3（60天）結果**：
```
indep.gate_ambitious=6319 gate_fail_pop=4179 gate_fail_busy=1024 gate_fail_nopath=11 gate_path_ok=1105
indep.found_ally=4 indep.found_subjugate=0 indep.found_timeout=0
g2.faction_found=0
```
- `gate_path_ok` 0→**1105**、`indep.found_ally` 0→**4**（Team0 確實 4 次真的派信使向 Team1 求結盟，log：`[IndepStrategy] Team0 野心建國→派信使結盟 Team1`）——**封鎖已解，機制真的在動**。
- 但 **`g2.faction_found` 60 天內仍是 0**——4 次提案都沒有走到真正 establish（無 `[Faction] 立國` 印出）。`indep.found_timeout=0` 也顯示沒有透過超時清空路徑重置（否則會有 timeout tap），意味著提案可能透過別的清空路（如信使死亡/迷路）默默消失，本輪未加 `envoy.dispatched/delivered/accept/reject/target_dead` tap 去精確定位卡在哪一步——**如實聲明：founding 路本輪只打通到「真派信使」，沒打通到「真建國」，未继续深挖**（時間/範圍考量，可另開票細追）。
- Team2(FOUND_B_LEADER) 全程未出現任何 `[IndepStrategy]` log——連信使都沒派過一次，兩組對稱設計卻只有一組真的動了，暗示還有隨機性/timing 敏感度，非穩定可靠觸發。

## ③vassal 對照組：★relief 鏈在全新 non-arc-fixture 確認真 fire（generalize 證據）

```
distribute.candidate_eval=3 distribute.dispatch=3 convoy.deliver(arrive)=3 distribute.deliver(settle)=6 food_delivered=64.0
```
T1/T3（founding路 member）全程 `faction=-1`（從未真正入 faction），relief 不可能對它們 fire。**這組非零數字只可能來自 T4(vassal lord)+T5(vassal resident)**——這是**跟 arc 原 fixture（`infonet_whole.json`）完全獨立的第二個 config**，relief 鏈在這裡一樣真的跑：candidate 生成→dispatch→travel→arrive→settle 全通，food_delivered=64.0（真實送達量）。**★這正面回答本工單「(A) 機制 fixture→general 是否真通」——是，在第二個獨立設計的 config 上機制照樣運作，非 `infonet_whole.json` 特調巧合**。

## ★意外重複模式：T5 後來自行脫離 faction（第 3 種同族機制）

追 T5 逐日快照：day40 仍在 faction（`T5:0`），day45 起變 `T5:-1`——task 序顯示 tick~9900（約 day41）觸發「起義」（uprising）。追 code 確認：
```gdscript
# faction_ai_system.gd:4571/4577（守城/流亡兩路徑皆同）
state.clear_team_faction(team)   # 起義脫離 faction（雙向同步）
```
**起義事件無條件清空 team 的 faction 歸屬**——跟 T3-attribution 那輪查到的 `event_faction_defect`（義氣/信義門檻）是**不同的機制**，但**同款「member 自行脫離 faction → relief 永久失效」的 pattern，這是第三次見到同族現象**（T3 defect / T5 起義 / +founding 本身「提案發不出去或發了沒成」某種意義上也是同族的「faction 關係建立不穩」問題）。**純觀察、不下因果判斷**，但這個 pattern 重複出現在兩個獨立 fixture 上，讀作結構性而非單一巧合，值得你們列入已知 confound 清單。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-infonet-faction-rich-rep-v3.txt`（1962行，含 v3 完整 log + 逐站 tap + T1/T3/T5 逐日曲線）
- `docs/measurements/2026-08-05-infonet-faction-rich-rep-diagnostic.json`（1581行，結構化 dump）
- （v1 探索版本未落地——純用來定位 vision/belief 封鎖點，數字已在本信引用；若需要可另跑）

## 清理狀態

- bed 本身（config+harness）已依工單指示 persist（commit `e13fd2ac`），不刪除。
- worktree 期間再次看到另一 session 動 `docs/measurements/2026-08-05-t3-crossfaction-targeting-diagnostic.json`（implementer 自己的檔），未觸碰。

## ★誠實淨判

- **(A) 機制 fixture→general 轉正**：**vassal 路徑上證實成立**（第二個獨立 config 上 relief 鏈全通、真送達）；**founding 路徑上部分成立**（求婚機制真的在動，尚未看到真正 establish，未排除是這 60 天窗口不夠長或提案接受端另有條件）。
- 別下 accept。是否需要另開票深追 founding 的 envoy accept/establish 卡點、以及 uprising/defect 這類「member 自行脫 faction」pattern 是否要正式記入已知 confound 清單，交你們/blueprint 判。
