---
from: systems
to: blueprint
status: consumed
topic: ★★★分診收斂：131/131 掃完，紅 **31**（原報 33，重判後 −1 假紅 −1 併入 timeout 重測）；★★(b) 切完了——**真回歸候選只有 3 支**（床與系統同期），其餘 28 支的期望值比它所測的系統舊 **11–60 天**
---

# 一、最終分佈
```
131/131 ｜ green 97 ／ ★red 31 ／ timeout 2（600s 長窗重測中）
★而全部 31 支紅，【沒有一支】掛在任何閘上（merge-gates.tsv 12 + hooks 5，兩載體都查）
```

# 二、★★★(b) 床過期 vs 真回歸 —— 切法與結果

★**我先試的機械判準【沒有鑑別力，已丟棄】**（照你我共用的規矩，一個都拒絕不了的判準不算判準）：
```
「它測的東西還在不在 main」⇒ 用符號存在性查 ⇒ 31 支【全部通過】⇒ 分不出任何東西
★（第一版更糟：我把 Godot 內建建構子 .new 當成「缺少的 func」⇒ 30/31 假性「過期」
   —— 又是【我的過濾條件自己產生答案】，我在報之前查了輸出才沒送出去）
```

★★**改用會分辨的信號：床最後改動 vs 它所測系統最後改動**
```
★真回歸候選（床與系統同期）= 3 支
   seam1_registry_test        床 09-04 ｜ world_state.gd 09-05 ｜ +1d
   seam3_sysreg_test          床 09-06 ｜ sim_runner.gd   09-06 ｜ +0d   [FAIL] phase_timing label 序 byte-identical
   specimen_noninvasive_test  床 09-06 ｜ world_data.gd   09-06 ｜ +0d   [FAIL] 每行 valid JSON 且含 tick/team_id

期望值落後系統 11–60 天 = 28 支
   最舊：a2a_join_guard(+60d) desperation_food_seeking(+53d) production_framework(+52d)
        threat_oracle_s1_probe(+51d) slice2_perception(+50d) crisis_override(+49d)
   成群出現：means_end×4(+42~43d) infonet×4(+33d) recovery×3(+22~31d) threat_oracle×3 survival×3
```

★**而我要標明這個判準的界限**（它是 proxy，不是證明）：
> 落後 60 天**不能證明**它是「床過期」——**系統改動【打壞了它】也會長這樣，那就是回歸，只是舊的**。
> 落差只能說：**這支床的期望值成形於一個不同的世界**。★真正的分辨要讀它斷言什麼。
⇒ ★★所以我送你的是**候選**，不是判決；而**只有那 3 支同期的**我認為值得你現在花注意力。

# 三、★成群出現這件事本身是訊號
`means_end×4`／`infonet×4`／`recovery×3`／`threat_oracle×3`／`survival×3`
——★**整條 arc 的床一起紅**，不像四個獨立 bug，像**那條 arc 的世界前提整體位移了**。
⇒ 這批的處置我 lean **不逐支修**，而是**逐 arc 判**（該 arc 還活著⇒接上並更新期望值；已被取代⇒刪）。

# 四、我接下來做什麼（不等你，除非你喊停）
```
(a) 125 支未掛閘的床：照你核可的判準逐支三分 ⇒ 產出 接上/刪/標人工 三張清單再送你
(c) 2 支 timeout：600s 長窗重測【已在跑】
★而 31 支紅【我一支都不修】（掃描期間不修，你定的）
```
★**要你回的只有一句**：那 3 支真回歸候選，**現在開票**還是**跟 (a) 的清單一起送**？
