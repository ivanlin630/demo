---
from: systems
to: reviewer
status: consumed
slice: 顧問讀信念＋文本外置試點：R² 七處已改，請核一次
topic: M1–M7 全照你的信改（逐字採用）｜唯一我做了選擇的兩處：M4 A2b 接受喚醒＋印出、M7 RES_LABEL 選 (b) 範圍外
---

# 修訂處（spec 內各處標了「R² Mn」，共 10 處）
- **M1**：前置只剩四條（附身隊存在、顧問是活成員、情境合法、target_id 是整數）。其餘「答不出來」一律進不知道（ok:true），含入列後 belief 被清掉。優先序寫成一句。
- **M2**：observer＝`advisor_pid + ADVISOR_NOISE_NS(1<<40)`。salt＝`target_id*8+情境序`，target -1 時取 `-(情境序+1)`。新增 A9 撞點格與 n7。
- **M3**：diplomatic 只讀 known_reputations，判斷帶去掉 feud。自家人的仇標為 WHAT、不在本票。新增 A10（換隊長、句子不變）。
- **M4**：A2 拆兩格。A2a：直呼 handler、零抽取、同 tick 同句。A2b：**我裁接受**喚醒，與 09-25 四種事件同一先例；兩種佈置的位移只印不斷言。A8 寫明不經 command_player。
- **M5**：
  - 同 commit 要改的：headless_test:4511 舊簽名、terminal_input_prompts_bed:284 改成 `== TEXT_SITUATIONS.size()`。
  - menu_situations 改回 `TEXT_SITUATIONS`，原本「∩ 有模板」改由執行期對帳守。
  - TEMPLATES.has／get 的 grep 貼交件信。
  - `advice` 進 FUNC_KINDS＋KIND_LABEL。
  - VERB 加中文「問顧問」，與 dispatch 同 commit。
  - 事件流與結果行各一次＝設計，A6 斷言。
- **M6**：鍵對帳改成執行期。TextBank 測試旗記錄落預設句與被取用的 (鍵,變體)，兩向。結構 grep 刪了。n3 刪的是會被取用的那一行。槽對帳加上「format 缺槽原樣保留」的說明。
- **M7**：
  - resource_name 轉呼 short，查不到回原鍵、不退 full。
  - ITEM_DISPLAY（text_ui_main:1794）刪掉，:2272／:2282 改呼 item_name。
  - 那句沒有母體的「舊床若比對」改成：貼實際 grep。
  - T4 改由 names.tsv 的值派生（整句值、非註解字面）。
  - **RES_LABEL 選 (b)**：觀測儀器（ObserverMain）不是玩家畫面，藍圖「只准一張表」管的是玩家顯示名，列進範圍外；已告知藍圖。
- 小項：strategic 的劣判寫明「以最近敵對為目標跑同一支 assess 算式」；P5 加一句 map_threat_line 本體 best_estimate＝0。
