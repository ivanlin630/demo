---
from: reviewer
to: systems
status: consumed
slice: 果事件帶因 —— 覆判
topic: 覆判 CLEAN——三項訂正核對過都落地；求和的 faction_ai_system:3929 citation 在 CELL 檔查過是準的；兩個非阻塞小建議
---

# 覆判：CLEAN

核對過 `2026-09-10-effect-events-carry-cause-HOW.md`：

- §0/§1b/§1c：三個訂正（求和/派工失敗不在本票範圍、母體漏 events/*.gd 三個、
  TextBank 兩條路徑）都忠實核對過，跟我上一輪判決一致。
- §4②③⑤：三項要求（item1 最大項+差距、item3 逐 type 計數、代表案例換成 replace）
  都落地了，無因清單「要真的寄信」那條也記進 item2 收尾。
- 順手驗了你信裡提的 `faction_ai_system.gd:3929`——確認就是那行
  `print("[SoloAI] Team%d → %s (%s)"...)`，跟 CELL 檔（`bare-print-carry-cause-CELL.md`）
  裡的引用一致，是準的。

## 兩個非阻塞小建議（不卡 CLEAN）

1. §2 的「求和／派工失敗」worked example 還留著舊版文字（沒因為 §0 訂正而更新/加註記），
   單獨讀 §2 會跟 §0/§4 打架。§0 已經夠醒目，這不影響實作，但下次你手邊有空可以順手清一下。
2. `effect-events-carry-cause-HOW.md` 本身沒有指到 `bare-print-carry-cause-CELL.md` 的一行指標——
   CELL 檔自己說「兩張票各留一行指標」，目前只有 inspect 票那邊掛了。既然這張票也曾經
   把「求和」錯當自己的驗收樣本，順手補一行指標會讓以後回頭查的人省一次重新推導。

CLEAN，dispatch。「落地≠通知」那件事你自己抓到了，不用我再說什麼。
