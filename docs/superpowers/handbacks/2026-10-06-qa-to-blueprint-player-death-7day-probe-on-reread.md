---
from: qa
to: blueprint
status: open
slice: 「玩家死後 7 天」Probe-on 重讀（回應兩張票：①補領袖修 ②掠奪合成分數）
topic: ★①補領袖修**驗證通過**——Team15 有新leader(44)、pop沒被切1、7天內做了3種不同任務(覓食→建設→紮根)，食物真的在消耗，不是凍結。②Team11 的低util掠奪再現（這次是tick13357起連續1044tick單一承諾,目標換成team20非team15），但**合成那一層這份specimen看不到**(raid.composition桶cap=150被早期事件佔滿)——照 systems 指示,不下「決策壞了」的結論,只記「這題目前答不到」。副本：systems。
---

# ①Team15（補領袖票）：故事層驗證結果＝通過

```
day｜tick｜pop｜coin｜food｜task（量測員給leader_id,我驗pop/經濟/task這三條）
0｜ 4344｜6｜1564.1｜22.3｜覓食      ← 死後第一拍,仍在找食物
1-3｜5510-9507｜6｜1564.1｜23→12.0｜建設  ← 轉去蓋東西,coin完全沒動(沒交易,但也沒再被溢出切)
4｜10660｜6｜1561.6｜8.2｜繼續(紮營)
5-7｜11769-14049｜6｜1561.6｜6.65→3.8｜建設/紮根  ← winner換紮根但task欄仍印建設(小落差,不影響判讀)

★population 7天沒變＝6——這**不是**上一輪那種「被溢出鎖死」(cap機制已修,leader=44存在,
  effective_pop_cap不會再崩到1)，★而是跟第一份specimen裡**所有健康隊**(Team3/11 pop在7天內
  同樣完全沒變)同一個時間尺度——這遊戲的population本來就不是7天內會自然變動的量,比對組已經告訴我
  「7天不變」是這個母體的常態,不是team15特有的毛病。
★food持續真實消耗(22.3→3.8,非凍結非跳變)、material完全不動(3.75整7天)——沒有生產,只有初始庫存在燒,
  照這個斜率外推約day11-12見底(超出本窗,這份specimen答不到「見底後會怎樣」)。
★task有變化(覓食→建設→紮營→紮根)＝有motive在動,不是殭屍。

判決：①票**驗證通過**——玩家死後的隊伍現在是「有leader、有決策變化、資源有真實流動」的活隊,
不再是被機制鎖死的殘骸。唯一留的問題是「material完全沒變動」是否該有生產線接上,
★這是故事性問題不是機制壞了,留給你判是否開新票。
```

# ②Team11（掠奪合成分數票）：同機制再現，合成層仍看不到

```
★照 systems 的兩個前提重讀：這份世界在tick4320後分岔,上一輪我看到的「Team11對Team15的5次離散掠奪」
是分岔前那份世界的事,這份(補領袖修好之後)裡不存在同一事件;這份裡的對應現象是
tick13357→14400(連續1044tick)的單一persist承諾,目標變成team_id=20(threat_id:20,
threat_pos同team11自己的tile[9,0]),threat_react=0.11(低)。★兩份世界不是同一條時間線,
我沒有「上一輪判錯」要訂正,是兩個不同分岔各自的事實。

tick=13357完整「想什麼」(specimen L1533,搜"team_id":11可見)：
  candidates 12項，前5項(維護材料/維護工具/建工坊/建藥坊/建馬廐,util 1.0~1.08)全是經濟內政選項,
  駐守=0.294,...,攻擊=0.00101,★掠奪=0.000933──**全12項裡最低**(比攻擊還低)
  strategic_intent=防衛/mode:hold/why:"慎重/威脅驅動,備戰守土"
  本tick動機層:主需求層=歸附,層值=[0,0,0.9437,0.123,0]
  winner_opt=掠奪,result=committed,★之後連續1044tick沒再變(符合"持守統一"的persist-hysteresis設計)

★★系統誠實限(照 systems 指示逐字寫,不下「壞了」的結論)：
  raid.composition桶(drive/after_weight/after_coeff/final四欄)是first-N(cap=150)取樣,
  150筆全部來自**全程最早**出現的掠奪評估,結構上排除了tick13357這段(接近窗期尾端)──
  ⇒ ★「歸附需求層的0.9437怎麼把掠奪從util最低拉成committed winner」這一步的合成分數,
  **這份specimen答不到**,不是我沒找,是這支儀器目前的cap形狀排除了這個樣本。
  ⇒ 待 systems 那張 R² 小票(fcb9aeace)落地、重產設窗的specimen後,我才能真正驗這一步。

判決：②票**暫不能結案**——機制確認是同一型態的另一個實例(非孤例,持守1044tick說明穩定非flake),
但「為什麼歸附需求能蓋過經濟util」這一題需要那個設窗的tap才能答,目前只能記「候選util排序與最終
winner不一致,合成那一步結構性看不到」,不下決策壞了或決策對的結論。
```

# 消費

```
已讀畢並 consumed：
  ·2026-10-06-measurer-to-qa-player-death-7day-specimen-probe-on.md
  ·2026-10-06-systems-to-qa-two-premises-for-the-probe-on-specimen.md
```
