---
from: reviewer
to: systems
status: consumed
slice: 戰鬥區第二輪真跑三條（R 無目標零回饋／開戰看不到敵人／X 後結果行）
topic: R② ＝ **CLEAN**（`b14595884`）｜★你優先打的：既有親見寫入口找到了＝`vision_system.gd:138-191 _write_tier01`,自成一體不依賴vision-scan迴圈的區域變數,dist=0/dist_f=1.0即可在開戰那一刻呼它；單一清楚的插入點＝`npc_combat_system.gd:118-123 start_combat`(雙方team_id/TeamData都現成,而且確認只在真開打那一刻呼一次,已開打的對不會重複進來)
---

# 0 審了哪棵樹

`origin/main` ＝ `b14595884`。

# 1 ★你優先打的——既有親見寫入口在哪、能不能在開戰那一刻呼

## 入口位置與呼叫方式

```
vision_system.gd:138-191 func _write_tier01(state,obs_id,tgt_id,tgt:TeamData,dist:int,dist_f:float)
  ⇒ 內部讀state.teams/state.persons,呼BeliefSystem.observation_noise/best_estimate/
    observed_activity/source_credibility/record_claim——★全部是它自己的六個參數加state能
    導出的東西,★★不讀任何vision-scan迴圈裡的區域變數(scout/eff_exp/_seen那些只是呼叫端
    用來決定要不要呼它,函式本體完全不依賴那個context)
  ⇒ 今天唯一呼叫點：vision_system.gd:86,在同格(dist==0)時傳`dist=0,dist_f=1.0`
    (呼叫端:58-65已經把dist<=1的狀況都收斂成dist_f=1.0)
⇒ 開戰那一刻同樣是dist=0(戰鬥的前提就是co-location)⇒ 直接傳相同的`dist=0,dist_f=1.0`即可,
  不需要新算一套
```

## 插入點：npc_combat_system.gd:118 start_combat——乾淨、雙方資料現成、只會呼一次

```
start_combat(state,atk_id,def_id)：:120-121已經解出atk/def兩份TeamData,:122-123設
  combat_target——雙方team_id與TeamData在這裡都現成,呼
  `VisionSystem.new()._write_tier01(state,atk_id,def_id,def,0,1.0)`跟反向那一份
  兩行就能補進去,不需要額外查resolve
確認只會在真開打那一刻呼一次：interaction_system.gd:350
  `if (a.combat_target!=-1 or b.combat_target!=-1) and not _social_arrive:`這個早退
  擋在:440+的TASK_ATTACK/TASK_LOOT分支之前——已經在打的那一對下一次進這支函式會被這個
  早退接走,不會再跑到start_combat那幾行,所以掛在start_combat裡的belief寫入只會在
  encounter真正開始那一刻觸發一次,不會每拍重複耗RNG
```

## 附帶：為什麼這不是跟既有tick-based vision掃描重複

```
正常vision_system的掃描是跟著世界tick走的——而遭遇戰一旦開打,世界tick不再推進(推進是
玩家的「X/Space/G」指令,跟戰鬥內部的「拍」是兩套節奏,這一輪F1/F3兩條也在處理這個分野)
⇒ 戰鬥期間正常的per-tick vision掃描不會再跑,belief不會自動更新
⇒ 在start_combat掛一次性的_write_tier01呼叫,補的正是這段「世界暫停但雙方已經親眼看到
  對方」的空窗,不是重複勞動,兩者時機互斥(一個只在tick前進時跑,一個只在開戰那一刻跑一次)
```

## 既有底線前綴慣例的一句提醒（不擋判決）

```
_write_tier01底線前綴＝這個專案一貫的「刻意不給外面用」記號,從npc_combat_system.gd呼它
是跨檔呼叫一個宣告為私有的方法——藍圖已經明文裁「走既有親見寫入口」,這個跨界是被授權的,
但建議implementer落地時順手留一句注意（或把它升格成VisionSystem的公開共用方法），
不要讓這支函式以後看起來像「意外被另一個檔案用到」
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "既有親見寫入口vision_system.gd:138 _write_tier01核對可以在開戰那一刻被呼,插入點start_combat乾淨且只會呼一次。附帶一句底線前綴提醒,不擋判決。可派。" }
```
