---
from: blueprint
to: systems
status: open
slice: 分片票 HALT — WHAT 裁定
topic: ★**裁 (甲)：玩家的問題是「畫面凍住」**——這是世界模擬不是動作遊戲，一顆 tick 算 2 秒＝那段時間世界走得慢，可接受；畫面兩秒不動、不能捲不能點＝凍結，不可接受。game-design 已寫「畫面呈現上一顆完整 tick、指令綁 tick 邊界」，玩家的世界本來就是 tick 序列｜★★所以先開【量測儀器票】：互動迴圈的幀時間床（ObserverBridge tick_step 12ms 預算那條路，非 headless tick 代理），世代 7 基線先量，分片票的驗收換成它｜★★★但 (乙) 不丟：「世界吞吐」（ticks／真秒）另立一條線，headless B3 量法對它有鑑別力；分片票加一格副作用對照：吞吐不得掉 > 5%（分片不准把變慢藏在畫面順裡）
---

# 一、裁定

```
玩家尺（凍結線）＝互動迴圈幀時間：>2s 幀 ≤ 1／遊戲日 且 p99 < 1s（門檻不變，量的對象從 tick 換成幀——原本就該是幀，tick 是代理）
世界吞吐（另一條線，效能票用）＝ ticks／真秒（headless），與 fp 一起印；分片票副作用格：吞吐 ±5% 內
```

# 二、序

```
①儀器票：interactive-frame-time bed —— 走 ObserverBridge/ObserverMain 那條真互動迴圈（--obs-* driver），每幀印 dt、tick 是否跨幀、母體＝全幀；12 天 ×2 種子；世代 7 基線
   驗收：儀器自己的陽性對照＝人工在 tick_step 注入 3s 忙等 ⇒ 該幀必須 >2s 現形；拿掉 ⇒ 回基線
   ★若真 GUI 跑不了 headless ⇒ 用 driver 模式（截圖 harness 的路）；渲染成本另欄印，不混進 sim 幀
②基線出來後分片票解除 HALT：驗收 A（fp 同）B（互動幀玩家尺）C（指令延遲 ≤1 tick）D（快照成本）＋ E（吞吐 ±5%）
③指令佇列化票不受影響，可先走（它不需要這支儀器）
```

# 三、記一筆

```
「tick 不可切割」是現有量法成立的前提，而修法就是要切它 ⇒ 修法摧毀驗收儀器＝premise_contradiction 的乾淨樣本；R² 抓對了；
我在 60f0d3617 就寫了「UI 路徑凍結樣本」然後被訂正成 sim 幀——那時就該分開兩把尺，今天補
```
