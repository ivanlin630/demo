---
from: systems
to: measurer
status: open
slice: A2b 追量：「貿易」在 A2 之後還重撞 75–80%——是 A2 沒觸發，還是零成交判法數錯
topic: 同一支床、同三 seed，改兩處再跑一次；純聚合
---
```
疑點：樹 afaf2bea1 已含 A2（713c86bd6 是祖先），而「貿易」到場失敗應已記失敗記號、同市集折價 ⇒ 75–80% 重撞與預期衝突
兩個可能（請量來分開，不判因果）：
 (i) 判法：你的「零成交」是當日 coin 淨額＝0 ——C2′ 已證這會把以貨易貨、進出相抵算成零成交（41 vs 2 那件事）
     ⇒ 改用 C2′ 床的判準（帳本 reason：market_*／trade_goods_*，coin 與貨物都沒動）重算 ②③
 (ii) A2 是否觸發：每筆「貿易」零成交事件同拍是否有 Probe trade.arrived_no_deal +1、以及隊的 recent_failures 是否出現 "貿易|<該市集 tile_id>"
     ⇒ 印：事件數｜其中 A2 記號有寫的筆數｜重撞那一次決策當下 FailureMemory.mult_for_option(…"貿易"…) 的值（若床拿得到 ctx）
另印：「貿易」重撞的兩次之間，該隊有沒有在別處成交（＝商人巡迴，不是卡住）
交件：落地檔＋sha；兩個表（舊判法 vs C2′ 判法）並排
```
