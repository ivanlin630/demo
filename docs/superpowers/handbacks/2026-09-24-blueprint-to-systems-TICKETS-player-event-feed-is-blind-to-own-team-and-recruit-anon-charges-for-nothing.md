---
from: blueprint
to: systems
status: consumed
slice: 玩家實跑回饋 #4 #5（用戶 2026-09-24：「隊友離隊不會顯示事件等 還有招募匿名好像不work? 不確定是不是對方人太少(9人」）
topic: ★#4 結構缺口：玩家事件流只有兩種 diff 事件（encounter_triggered／new_team_spotted，sim_bridge.gd:244-253）＋兩處 player_alerts（外交/資源），自己隊的成員離隊/死亡/出生/招到人/挨餓【一件都不進事件流】⇒ 裁：事件流改吃世界自己的事件匯流排（WorldEvents）按附身者感知過濾，自家隊的事＝self-knowledge 全知｜★★#5 真缺陷（不用等用戶重現）：_target_has_anon 用 population>1 代替「真有匿名」（player_command_system.gd:74-75），對方全具名時扣 50 coin、搬 0 人、印「招募成功」⇒ 修＋床；另 recruit_anon 本身是花錢買人無對方意願＝STUB（:38 自書），WHAT 另票
---

# 一、#4 隊友離隊沒事件（file:line）

```
sim_bridge.gd:244-253  _diff_events：只產 encounter_triggered、new_team_spotted 兩種
player_alerts 寫入點：diplomatic_ai_system.gd:352、resource_system.gd:261（只兩處）
WorldEvents.emit 已有 kinds：leader_death/team_extinct/betrayed/famine_crossed/combat_engaged/
  labor_crisis/convoy_stranded/construction_stalled|abandoned/plan_invalidated/rung_changed/intel_arrived（供 NPC 喚醒）
⇒ 玩家事件流跟世界的事件匯流排【沒接】；成員離隊（reaction_system.gd:433-439 defect 分支）根本沒有 emit
```

裁（WHAT）：
```
①玩家事件流的來源＝世界的事件匯流排，零特例（資訊網那一行：一個資訊模型零特例）。UI 不再自己 diff。
②過濾＝附身者的感知：發生在【自己隊】身上的事＝self-knowledge 全知（成員離隊/死亡/出生成年/招到人/挨餓/被偷/收到情報）；
  發生在別隊的事＝走既有 belief/intel（看得見或傳到了才進）。
③離隊要有【原因人話】（他為什麼走：忠誠崩/餓/被挖角）——執行失敗反饋那一行的鏡像：離開是事件，不是人口數字少一。
④缺的 emit 補：member_left／member_died／member_joined／member_born(成年)／starving 至少這五種；HOW 定 kind 名。
⑤事件流每筆帶 tick，畫面印「第 N 天：某某離隊（原因）」。
```

# 二、#5 招募匿名「不 work」

```
player_command_system.gd:74-75   _target_has_anon(tgt) = tgt.population > 1      ← 沒看 anon 數
:1142-1167 _recruit_anon_internal：扣 50 coin → AnonTierSystem.transfer_proportional(tgt, pt, 1)
anon_tier_system.gd:199-201      total<=0 ⇒ 回 moved 全 0（不搬）
:1163-1167                        不看 moved，照印「招募成功（新人口 N）」
⇒ 對方 9 人若全具名（或 anon 池 0）：扣錢、搬 0、報成功、人口不變 ⇒ 用戶看到的就是「不 work」
   （用戶那句「不確定是不是對方人太少」= 對，但門檻不是人數，是【匿名數】，而 code 查錯欄位）
```

裁：
```
①_target_has_anon 改查 AnonTierSystem.total_pop(tgt) > 0；不足時選單不列或當場拒絕「對方沒有匿名成員」（這是讀世界的，走消費點）。
②_recruit_anon_internal 看 moved 總數：0 ⇒ 不扣錢、回 ok=false。
③床：對方全具名 ⇒ coin 前後相同且 msg 為拒絕；對方 anon≥1 ⇒ 人口 +1 且對方 −1（守恆）。陽性對照＝還原 ① 那格必紅。
④★WHAT 另票（不在本票）：recruit_anon 現況＝固定 50 coin 買人、對方零意願零人格（:38 自書 STUB）——違「util=真值／人格 MODULATE」；正版＝對方領袖秤（關係/價碼/自身缺工），價由秤出不由常數。登意圖帳待裁。
```

# 三、序

```
#5 ①②③小、先修（用戶正在玩、每次招募都在漏錢）；#4 是一張中票，排游標真值之後、故事結束之前。
```
