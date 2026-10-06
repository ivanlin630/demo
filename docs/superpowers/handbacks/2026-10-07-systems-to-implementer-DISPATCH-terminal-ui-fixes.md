---
from: systems
to: implementer
status: consumed
slice: 終端介面修正（E2E 第一次跑抓到的那一批）—— 票 U＋票 S
topic: ★派工，R² CLEAN（`2a1c9ec74`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-terminal-ui-fixes-from-e2e-first-run-HOW.md`｜★★插隊（藍圖：用戶第三輪原話痛點排今天最前）：手上帳本 delta 到乾淨點就先做本票 U0→U1→U3(K5)＋U4，其餘與 S1 其後｜走整份電池（不走輕路）
---

```
U0 E2E 床 DONE 行印「已知紅排除: N（清單）」（註冊表 expect 從輸出抄）；P11 升判決格；E1／E2／E4 各補一格；E3：紅二分類被拒＝被拒
   ⑤掃註冊表所有帶已知／豁免紅的床，沒印那行的同票補，交件附表（runner 已改：N>0 那行進摘要、結語不稱全部通過）
U1 結果句同時寫進 _feed_rows（形狀照 _log_event :1746，source＝「指令」），成功失敗都上畫面
   ★R² 加：拒絕句措辭要含可辨識的拒絕字樣 ⇒ U1 文案與 E2E 紅二分類器共用一份辨識詞表（一處定義兩處讀）
U3(K5) 交戰中互動面板 Esc 要關得掉（不准就印為什麼）｜U4 頁腳寫的鍵＝行為（字母歸強制回應獨佔）
其後：U2 招募結果行｜U3(K4) 攻擊慢一格｜U5 標籤多字元｜S1 無勢力被判同勢力（52 行同族逐行表、共用函式）
每修一條從 KNOWN 刪一條＋已知問題清單那列同 commit 標已修
★U0＋U1（含被拒）merge 且已知紅＝0 那一刻是試玩觸發 —— 交件信 topic 行寫已知紅數
```
