---
from: systems
to: implementer
status: open
slice: S3-tiered-cadence
tier: behavior
topic: ★★★scope 擴了(blueprint 裁,推翻我):七支【全部】要經由 CadenceStagger,不只 GOAL;★★而搬完的直接證據不是統計量,是【範圍要從 [4320,4320] 變散開】——剛性範圍本身就是「沒走單一真值」的指紋;★★★序不變:GOAL 先修(它壞著),五支接著;★perf 預期改善要【量】不能只宣稱
---

# ★①scope 變更（★blueprint 推翻我的「另立一票」，而他的理由比我的好）
```
★原本我判：GOAL 這輪修,另五支另立一票（理由:它們現在「過」,不要在要收的票上改正在過的東西）
★★他裁：五支走 CadenceStagger =【在 S3 範圍內】
   ①「搬家」的完整定義 = 遷入新節律【經由排程單一真值】⇒ 繞過 =【沒搬完】不是「搬完了但形狀不同」
   ②★★★lockstep 是 S3【自己造成的】病:cadence 拉長會把 burst 濃縮
      —— 10h 時 105 個 actor 分散在多批,3 天時【全部疊在同一 tick 重想戰略】
   ③繞過單一真值 = 平行特例病本尊
```
★**我錯在用「它現在過不過」當 scope 判準** —— ★★**而間隔判準只驗【多久】，驗不到【經由誰排程】。**

# ★★②要做的（★序不變，GOAL 先）
```
①★GOAL_CHECK → CadenceStagger（它壞著,非改不可,先修先驗）
②★★另五支 → CadenceStagger：ALLIANCE / BETRAY / FACTION_UPDATE / INFRA / STRATEGIC
   ★把 `if current_tick % X == 0` 換成排程式（per-actor next_tick），★★不要自己寫累加器
★★★七支【全部】用錯峰型判準：平均 = C(±2%) / 最小間隔 >= C/2 / 印分佈(min/median/mean/max)
```

# ★★★③而「搬完了」的直接證據不是統計量
```
★★★範圍必須從 [4320, 4320] 變成【散開】
   —— 剛性範圍本身就是「沒走單一真值」的指紋,而散開是「真的經過它」的指紋
```
★**這條比任何容差都硬**：**它驗的是【形狀變了沒】，不是【數字落在容差內沒】。**
★★**若某一支改完範圍【仍然剛性】⇒ 那就是接線沒接上，不管平均多漂亮。**

# ★★★★④perf：**預期改善，而預期要量**
★**既有量測**：`burst tick dt 中位數 14.9M vs non-burst 4.2M ＝ 3.5×`（`cadence_stagger.gd` 檔頭）。
⇒ ★★**七支攤平後，T3 尺度的 burst 應該消失** —— ★★★**但那是【預期】：要有前後數字，不能只宣稱。**
★**最省的做法**：**沿用既有那個 burst/non-burst dt 比的量法**，**前後各一次。**（★若你有更省的，你決定。）

# ⑤`fp` 與閘
```
★fp 必變（相位全變）——★★交件先聲明走的是哪一種
憲法閘 / 裸 tick 閘 / 床解析閘 / headless Q1；★新 class_name 先 --import
```
★**做完 S3 ＝ 7/7 且七支都走單一真值，那時才談 merge。**
