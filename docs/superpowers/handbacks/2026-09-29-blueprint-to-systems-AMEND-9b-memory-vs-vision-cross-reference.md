---
from: blueprint
to: systems
status: consumed
slice: #9 補二（用戶 2026-09-29：「記憶與可視距離如何互相參照? 畢竟有偵查範圍與模糊處理」）
topic: ★三層一張圖：現在看得到（半徑內＝真值）／記得（最後一次觀測）／聽說（relay 進 belief 的）——★★renderer 只畫 belief store 說的，【不自己模糊、不自己過期、不自己算半徑】：模糊住在資訊模型（distorted claim），過期用既有 BELIEF_STALE_TICKS（belief_pos 已回 (-1,-1)），半徑用 VisionSystem.VISION_RADIUS（renderer 已引用）；斥候的視野＝另一支隊的 belief，回報到了才變你的記憶
---

# 一、參照規則（WHAT）

```
①現在：以你這隊為中心 VisionSystem.VISION_RADIUS 內＝真值（共位必見），畫大寫／隊號。半徑是 sim 權威源，renderer 已引用不另抄。
②記得：半徑外、team_tile_known 有的格＝最後一次觀測。三種內容三種壽命，都不由 renderer 決定：
   地形＝永久（世界裡地形不變）；據點＝到被否證或新觀測覆蓋；他隊位置＝到 belief_pos 說過期（BELIEF_STALE_TICKS 既有常數）⇒ 過期那格回地形字元。
③聽說：relay／訊息進 belief 的格與隊，跟②同樣畫法（小寫／N?），來源差異只在游標面板印「來源：親見／聽說（來自 TeamX）」，不另造字元——字元語言只表達「現在／記得／沒去過」三態，來源與新鮮度走面板。
④模糊：資訊網已把失真放在 claim 本身（message_system.gd:312 distorted claim）⇒ 地圖畫的就是失真後的位置／內容，renderer 不再加一層模糊，也不修正。★兩層模糊＝觀測改變被觀測物的鏡像（畫面自己編故事）。
⑤斥候／子隊：子隊在外是另一支隊（不變量 #9），它看到的進它的 belief；回到隊上或訊息送達才進你的表 ⇒ 地圖上斥候走過的格在回報前仍是 ?。這是資訊網「always 傳播靠衰減非硬擋」的直接後果，不特例。
```

# 二、驗收補

```
把 BELIEF_STALE_TICKS 改大一倍 ⇒ 「N?」多活一倍時間（renderer 沒有自己的時鐘）。
一條失真的 relay claim ⇒ 地圖把隊畫在失真位置、面板印「聽說（來自 TeamX）」；renderer 不得把它畫回真位置（陽性對照：讓 renderer 讀 live 位置這格必紅）。
子隊派出去看 5 格回來 ⇒ 回來那一刻（或訊息到達）那 5 格才轉小寫，之前是 ?。
```
