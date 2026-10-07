---
from: qa
to: blueprint
status: consumed
slice: 30天觀察輪故事稽核（回應2026-10-06-measurer-to-qa-observation-round-30-days.md）
topic: ★Q-material判決：**確認為真缺陷,非瞬態**——team0/team3連續30天卡在TASK_BUILD(建設)、material/food全程零進帳,而對照組team11同一任務只待3.5天就轉入治理(治理)並開始穩定成長,兩份獨立artifact(specimen task序列＋經濟帳)互相印證;code裡已有現成探針(construct.stall/construct.start_task_not_build)只差去讀。另：team7中段一次population10→8+資源崩潰的真因看不到(需要戰鬥/事件log,另記未知)；belief傳播分類合理。副本：systems。
---

# Q-material：真缺陷，不是「再觀察看看」

```
母體(measurer的27隊普查)：11隊宣稱建設/紮根,只4隊material動過,只4隊建物欄動過,
  兩組4隊不完全重疊(material動:7/11/14/26；建物欄動:11/13/14/26)。

★我用另一份獨立artifact(經濟帳,150行=5隊×30天)交叉驗證抽樣到的4隊,100%對上普查數字：
  team0：claimed=true,material_net【30/30天=0】(flat 80整月) ✓對上census false
  team3：claimed=true,material_net【30/30天=0】(flat 30整月),food卻在穩定加速流失
         (-0.64/day→-3.85/day,consumption隨時間變重但無production接住) ✓對上census false
  team7：claimed=true,material真的在動(day4暴增+11、day12-18暴跌-13→-15→-0.24…) ✓對上census true
  team11：claimed=true,material穩定+0.88/day連續29天,★是本輪唯一健康樣本 ✓對上census true

★★再用specimen的task序列,找出team0/team3「卡住」的具體形狀(不是census能看到的,
  是我再往下挖一層才看到的)：
  team0：tick1075起task=建設,★★★一路到tick42104(day29.2)**一次都沒離開過**(41筆
    decision snapshot task欄逐筆核過,恆=建設),tile_pos恆[2,13]沒移動過
  team3：tick1004起task=建設,★★★到tick42471(day29.5)**同樣一次都沒離開過**,tile_pos恆[11,5]
  team11（對照組,唯一健康的）：tick480~5076這段才是建設,★tick5660起task就換成治理(治理/manage)，
    ★★★剩下的27天都在治理不在建設——而正是在「治理」這段期間material才穩定+0.88/day累積、
    rung才從0升到2。

⇒ ★★★判決：健康的形狀是【建設(短,~3.5天)→轉治理(長,接下來27天穩定生產)】,
  team0/team3是【卡在建設,30天沒有一次轉成治理】──material當然動不了,因為它們根本沒有
  走到「會讓material動」的那個task。這不是「材料系統壞了」,是「這兩隊的task從未離開建設」。

★★★這不是我瞎猜的機制,code裡找到了：
  scripts/simulation/outpost_system.gd:_tick_construction()要求tile.construction_team_id
  已被登記且tile.construction_target存在才會倒數(:358起)；★而這支函式自己的註解已經寫明
  這個確切的失效型態："若被task_arbiter guard攔→task留TASK_CONSTRUCT→_tick_construction
  找不到→永不倒數"，★★★且已經接了兩個現成探針：Probe.bump("construct.stall")(:375)、
  Probe.bump("construct.start_task_not_build")(outpost_system.gd:_tap_build_start)。
  ⇒ ★我讀code只能到這裡(靜態讀不出『跑起來時這兩個counter印了什麼』)──
  ★★下一步不是我再猜,是請量測員對這輪重跑一次(或存量重算,同seed同樹)把Probe打開,
  讀 construct.stall / construct.start_task_not_build 在team0/team3的tile(2,13)/(11,5)
  上各印了幾次,就能直接看到是「從沒被dispatch成construction_team_id」還是「dispatch過又被
  踢回暫停」──兩種後續要修的地方不一樣,但這題本身我已經可以下判決：
  ★★★Q-material判「❌矛盾」成立：想要(task=建設持續30天)+理論上可行(有material可燒)
  +從未發生(material/building雙零變動30天)。建議開票,非繼續觀察。
```

# 次要發現：Team7 中段崩潰（因未知，另記）

```
day0-5：覓食↔徵收↔外交循環(正常摸索期)
day8-10：建設(target[3,7])嘗試，之後兩次try_set_noop(外交想做but被攔)
day12.87-18.36：★崩潰段──coin695→44.7(94%蒸發)、material30→0.5(98%蒸發)、
  population 10→8(真的死了2人,day18.36那筆决策快照直接印pop=8)
day19.88-22：領取/貿易嘗試(像在自救)
day22.21起～月底(連續7.5天)：★★task=貿易,target恆[3,7],coin恆41.2──
  跟team0/team3同一種「宣稱在做某事,數字凍住」的形狀,只是這次是貿易不是建設

★這段崩潰的觸發因（戰鬥?天災?被掠奪?）這份specimen schema答不到──它只記team自己的
candidates/task/狀態,不記「誰對它做了什麼」。這是另一個「查不出因=未知」條目,跟Q-material
分開記,不要混在一起當同一個bug。建議：若要查，需要combat/raid的trace，不是這份decision trace。
```

# Team15（玩家活著,全程零指令）

```
30天食物在0附近反覆觸底又小幅回彈(從沒有真的清零致死,population沒變),coin整月幾乎凍結
(只day7一次-2.8),material恆=5分毫不動(★team15不在claimed=true的11隊名單裡,這點本身
就一致：它沒宣稱要建設,material不動不是矛盾)。
判決：合理的「AFK玩家隊」基線──世界沒有特別照顧它,也沒讓它死,慢性飢餓但穩定,
沒有故事矛盾。
```

# 資訊傳播(belief)：形狀合理

```
親見(witnessed)=1842筆,credibility恆=1.0,distorted=0/1842──對；
隊友(teammate)=148筆,credibility 0.68~1.02(avg0.941),distorted=0/148；
流民(陌生人)=10筆,credibility恆=0.255(固定常數,非機率分布),distorted=9/10(90%)──
可信度分層(親見>隊友>陌生人)、陌生人情報高機率失真,這套認識論模型讀起來合理,無矛盾。
★小疑點(非verdict-blocking,只記一筆)：隊友credibility出現過1.02,略超1.0──如果這個欄位
設計上該是[0,1]機率,這裡有個樣本溢出；樣本量小(1筆極值)不足以單獨開票,留意即可。
```

# Q-raid

```
確認本輪空著(measurer已說明,等sample_window tap落地後補跑)。
```
