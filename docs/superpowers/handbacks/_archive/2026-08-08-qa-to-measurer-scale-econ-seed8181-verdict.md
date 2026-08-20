---
from: qa
to: measurer
status: consumed
topic: "★seed8181 dispersed Team2餓死故事verdict=REFRAME(『genuine labor-survival collapse無關convoy/relief』premise不成立,故事比這複雜得多且更有價值):①Team2決策層有真嘗試對外求助,非從沒評估——逐tick讀specimen day13-35:求和(diplomacy)/買糧/乞食/紮營/併入(join另隊)全部輪番真中選(argmax真贏非死常數),util隨絕境程度真上升(如買糧1.16→2.98連續攀升)、raw log也證實Team2真post了買糧市場單(day20/25/30/35/40每5天一次,非只早期routine單)——decision層完全沒問題,是我抓到的第一個關鍵修正②真根很可能是雙重卡點:(a)day24 Team2(+Team3+Team7同批)觸發脫離勢力(勢力0解散),疑似同event_faction_defect.gd機制(今天已在established-fragility/moderate-distress驗過),脫離後任何faction-scoped救濟(distribute_side)結構性失資格——同T3故事同款;(b)[Market].*Team2全文0命中=Team2的買糧單從頭到尾一次都沒真正撮合過,疑似同jia-distribute診斷坐實的co-location-gated撮合死角(propagate_on_arrival)同一根——這兩點合起來看,這極可能是資訊網arc已診斷過的『propagation死角』在規模經濟這個新fixture裡的第N次復發,非這個fixture獨有的『小隊天生撐不住』故事③Team0(lord)同期(day20-27)pop5/food40穩定無恙,非自己陷危機;relief_dispatched_to_t2=false但尚未查清是day24前(仍同faction時)Team0有沒有評估過對Team2的distribute候選——這條我還沒查完,標記待辦。建議：(a)查Team0 day13-24候選有無distribute/relief選項對準Team2(b)查Team2買糧單是否卡在co-location(c)若(a)(b)證實,這個故事應改寫成『資訊網propagation死角在規模經濟fixture下的第N個症狀』而非『規模不夠撐不住』,對規模經濟力底查這個新arc的因果框架有直接影響,建議回報systems前先跟我這條發現對齊"
---

# ★seed8181 dispersed Team2 死亡故事 verdict — REFRAME（比 premise 複雜得多）

裁：**「genuine labor-survival collapse、無關 convoy/relief」這個 premise 不成立**——逐 tick 讀 specimen 後，故事遠比這句話豐富，且很可能連到資訊網 arc 已診斷過的根因，非這個 fixture 獨有現象。

## ①Team2 決策層真嘗試對外求助——非從沒評估

逐 tick 讀 `2026-08-08-scale-econ-tier2-seed8181-3mo.specimen.jsonl` day13-35（tick3120-8560）：

```
day13-20: 求和(外交) 持續贏 argmax，util 0.66→0.88（連續攀升，非死常數）
day21起: 買糧/乞食/紮營 開始進候選集，util 隨絕境攀升(買糧 0.11→1.16→2.98 連續遞增)
day24-30: 買糧/併入(join另隊)/乞食/遷移找糧 輪番真中選argmax
```

**這不是「decision 層根本沒有向外求助這個選項被評估過」**——求和/買糧/乞食/紮營/併入全部真的進候選集、真的贏過 argmax，util 數值連續反映真實絕境程度（非硬編）。raw log 也證實 Team2 真的貼出買糧市場單，且不只早期 routine 單——`[Order] Team2 buy food` 在 day20/25/30/35/40/45/50 每 ~5 天規律出現，貫穿整個危機期。**這條是我抓到的第一個關鍵修正：decision 層完全正常，問題不在這裡。**

## ②真根很可能是雙重卡點，疑似資訊網 arc 已診斷根因的復發

**(a) day24 集體脫離勢力**：raw log 見 `[Faction] Team2 脫離勢力0 / Team3 脫離勢力0 / Team7 脫離勢力0` 同一 tick 齊發、緊接 `勢力0 解散`。這跟今天早些時候 established-fragility/moderate-distress 床驗過的 `event_faction_defect.gd`（unrest_turns 累積→defect_util 公式）機制型態高度吻合（多隊同 tick 集體觸發、非偶然）。**Team2 脫離勢力後，任何 own-faction-scoped 救濟機制（`_try_distribute_side`/`_village_est` 硬性要求 `owner.faction_id==team.faction_id`）結構性失資格**——跟資訊網 arc 的 T3 故事同一種「脫離即孤兒」模式。

**(b) 買糧單從頭到尾零撮合**：全文 grep `[Market].*Team2` = **0 命中**——Team2 這些持續貼出的買糧單，整場沒有一次真正撮合成交。這高度疑似資訊網 arc `jia-distribute-zero-diagnostic.json` 已經坐實的 **co-location-gated 撮合死角**（`propagate_on_arrival:79` 要求買賣雙方同 tile 才傳達）——同一個根因家族。

**這兩點合起來看：這極可能是「資訊網 propagation 死角」在規模經濟這個新 fixture 下的第 N 次復發，不是這個 fixture 獨有的「小隊規模不夠、天生撐不住」故事。**

## ③Team0(lord) 同期狀態——查一半

day20-27：Team0 `pop=5 food_private=40` 穩定無恙，**非自己也陷入危機**。`relief_dispatched_to_t2=false` 你已 tap 確認。**但我還沒查完**：day13-24（Team2 脫離前、仍同 faction 時）Team0 自己的候選清單有沒有出現過 distribute/relief 類選項指向 Team2——這條決定「lord 有沒有機會救但選擇不救」還是「這個窗口內從未被評估過」，標記待辦，需要再一輪讀 Team0 specimen 才能坐實。

## 建議

1. 查 Team0 day13-24 候選清單有無 distribute 選項對準 Team2（回答你原問題③）。
2. 查 Team2 買糧單卡在哪一步（posted 但未 co-located、還是連 posted 都算不進 received_buy_orders）——確認是否真是 jia-distribute 同根。
3. 若①②證實，這故事該改寫成「資訊網 propagation 死角在規模經濟 fixture 下的症狀」，非「規模不夠撐不住」——對規模經濟力底查這個新 arc 的因果框架有直接影響。**建議回報 systems 前先跟我這條發現對齊**，別讓 premature 的「genuine labor-survival」框架鎖進 spec。

---
*QA 驗收官 · 2026-08-08*
