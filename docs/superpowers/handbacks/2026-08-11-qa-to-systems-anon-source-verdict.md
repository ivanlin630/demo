---
from: qa
to: systems
status: consumed
topic: "★anon drain真源定案(讀既有數據非重跑)——①真源=event_unrest_split.gd的_split_team(),非overflow-spinoff非succession(兩者皆已排除):讀anontrace-caller-raw.txt找到決定性行『[AnonTrace] from=0 to=4 count=1 caller=?:-1』,caller雖沒抓到但code逐一核對transfer_proportional全部呼叫點(9處),唯一符合『unrest高+創新team+轉移anon』特徵的是event_unrest_split.gd:102——這是團隊分裂/兵變機制:team.unrest_turns>=30(UNREST_SPLIT_THRESHOLD)+存在忠誠度<0.35的named異見者+異見者與領袖goal衝突→觸發,_split_team()選一個異見者當新領袖,轉移hard異見者(named)+soft追隨者(機率式)+anon_split=round(領袖統領×魅力×parent_anon×0.3)上限parent.population/3——這解釋了非日邊界tick(EventSystem.process_events呼叫頻率非TICKS_PER_DAY gate,同段code今天稍早已見)+Team4 leader_traits異於Team0(新領袖是原本的異見者person,人格本來就不同)。②anon池41天不回補=CONFIRM真實(讀raw表anon欄3→2→1→0(day0-4)後day17/20/25仍=0,逐位元核對);但merge回(Team0←Team4/Team5完全合併)有沒有真的補anon回去我沒能100%坐實——merge本身code(昨已驗)是資源乾淨的(will_empty分支100%清空sweep),但table顯示merge後anon仍未回升,最可能解釋=被merge回的那個team自己在merge前anon已經是0(該team自己的anon可能又被自己的側派/或再一輪split耗掉)——這是推論非直接tap坐實,若要100%確定需要在merge事件當下加一個merge前absorbed.anon快照tap。③中性事實陳述供用戶判:這整條anon消耗鏈是genuine、非causeless/非mechanical——是一個完整、有動機的『兵變/分裂』故事(unrest累積→異見者不滿+目標衝突→領袖帶人分家,人格權重決定帶走多少anon跟隨者),非隨機或無因的世界機制故障。是否要調整(例如這個團首4天就經歷分裂是否太快/太頻繁、下游一整串relief/care-scout/builder因此41天派不出是否是想要的難度曲線)屬於平衡/設計裁量,非bug"
---

# ★anon drain 真源定案（讀既有數據，非重跑）

裁：**①真源 = `event_unrest_split.gd` 的團隊分裂/兵變機制（非 overflow-spinoff、非 succession，兩者皆已從既有數據排除）；②anon 41 天不回補 = CONFIRM 真實，但 merge-back 為何沒讓 anon 回升未 100% 坐實；③中性事實：這是 genuine 有動機的分裂故事，非 causeless/mechanical bug**。

## ①真源：`event_unrest_split.gd::_split_team()`

`anontrace-caller-seed8181-raw.txt` 找到決定性行：
```
[AnonTrace] from=0 to=4 count=1 caller=?:-1 func=?
```
`caller` 沒抓到（同你回報的死路），但**逐一核對 `AnonTierSystem.transfer_proportional` 全部 9 個呼叫點**（`event_unrest_split.gd`/`faction_ai_system.gd`/`player_command_system.gd`/`population_system.gd`/`subteam_system.gd`×5），唯一符合「unrest 高 + 創建新 team + 轉移 anon」特徵的是 **`event_unrest_split.gd:102`**。

讀完整 `_split_team()`：
```gdscript
const UNREST_SPLIT_THRESHOLD: int = 30
const LOYALTY_LEAVE_THRESHOLD: float = 0.35
# check(): unrest_turns>=30 + 存在 loyalty<0.35 的異見named成員 + 異見者與領袖goal衝突 → 觸發
# execute(): 選異見者當新領袖，轉移hard異見者(named)+soft追隨者(魅力機率式)
#   + anon_split = round(新領袖統領×魅力×parent_anon×0.3)、上限 parent.population/3
```

這是一個**團隊分裂/兵變機制**——`team.unrest_turns` 累積過門檻 + 有低忠誠異見者 + 異見者跟領袖目標不合 → 異見者帶著一批人（named+機率soft+人格權重決定的 anon 跟隨者）自立門戶。

**這完整解釋了兩個你先前卡住的疑點**：
- **非日邊界 tick（100/700/1000）**：`EventSystem.process_events` 的呼叫頻率不是 `TICKS_PER_DAY` gate（跟今天稍早查過的其他 event 呼叫模式一致），非例行日檢。
- **Team4 leader_traits 異於 Team0**：新領袖就是原本的異見者 person，人格本來就跟 Team0 原領袖不同——不是巧合，是機制設計的必然結果。

## ②anon 41 天不回補：CONFIRM 真實，但 merge-back 細節未 100% 坐實

讀完整表格 anon 欄：`t100(d0)=3 → t400(d1)=2 → t700(d2)=1 → t1000(d4)=0 → t4080(d17)=0 → t4800(d20)=0 → t6000(d25)=0`——**逐位元核對，day4 見底、day25（最後一筆）仍是 0**，真實不回補。

`[Merge] Team0 ← Team4/Team5 完全合併` 事件確實有發生（表示分裂出去的隊事後真的合併回 Team0）——但 anon 欄在這些 merge 之後**仍未回升**。昨天我已 code-verify `_merge_into` 的資源轉移本身是乾淨的（`will_empty` 分支有 100% 清空 sweep）——**問題不在 merge 機制漏轉，最可能是被合併回來的那個 team 自己在合併前 anon 已經是 0**（可能自己的 anon 又被自己的側派 dispatch 或再一輪 split 耗掉）。**這是推論、非直接 tap 坐實**——若要 100% 確定，需要在 merge 事件當下加一個「被吸收方 merge 前 anon 快照」的 tap。

## ③中性事實陳述——供用戶判斷 genuine vs bug

這整條 anon 消耗鏈**是 genuine、非 causeless/非 mechanical**——是一個完整、有動機的「兵變/分裂」故事：unrest 累積 → 異見者不滿 + 目標衝突 → 領袖帶人分家，人格權重（統領×魅力）決定帶走多少 anon 跟隨者。不是隨機或無因的世界機制故障。

**是否需要調整，屬於平衡/設計裁量，非 bug**：例如「這個團首 4 天就經歷分裂是否太快太頻繁」「下游一整串 relief/care-scout/builder 因此 41 天派不出是否是想要的難度曲線」——這些是設計選擇問題，我只陳述事實，不下裁定。

---
*QA 驗收官 · 2026-08-11*
