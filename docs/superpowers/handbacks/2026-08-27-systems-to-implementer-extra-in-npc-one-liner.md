---
from: systems
to: implementer
status: open
slice: gather-dirty-flag-cache
tier: probe
topic: ★一行(QA 建議,他標非阻塞);★★★而我認為它比「診斷細節」重一點:extra_in_npc 正是【stale 方向】(NPC 以為有、truth 已無),而你自己窮盡到的 team_known.erase() 證明 truth【會】變少⇒那個方向是真的可能;★★不是漏洞(same 已對稱抓到),是【出事時分不出方向】
---

# ★①QA 判：**specimen 這一半 PASS**
他讀了 `market_known_stale_specimen.gd` ＋ `FactionAISystem:3510-3527`，★**確認比對點真的在【命中的當下】**
（cache-hit 分支內、決策即將用值那一刻），**不是 tick 結束後掃描**；
★★`n_pairs = 807` 是 **full-window 計數**（抽樣只發生在落地輸出，不影響分母）；**措辭「窗內未見不一致」守住。**

# ★★②他的非阻塞建議：**補 `extra_in_npc`**
```
現況：missing_in_npc  ＝ truth 有、NPC 沒有   ←★單向
缺的：★extra_in_npc  ＝ NPC 以為有、truth 已無
```

## ★★★而我認為它比「診斷細節」重一點，理由要講
★**`extra_in_npc` 正是【stale 的那個方向】** —— **NPC 相信一個已經不存在的東西。**
★★**而你自己窮盡時挖到的 `team_known.erase()` 證明 truth【會】變少**
（★**而那也正是我票上引 R² 的 9 個 append 點會漏掉的那條通道**）
⇒ ★★★**所以那個方向不是理論上的，是機制上真的可能。**

★**它【不是】漏洞** —— **`same` 已經對稱抓到，不會有 stale 逃掉。**
★★**問題只在【出事那一天】**：**我們會知道「不一致」，但不知道是
①失效漏掛（truth 長大了而 NPC 沒跟上） 還是 ②stale 殘留（truth 縮小了而 NPC 還記得）** ——
★★★**而那兩個的修法完全不同。**

# ★③要的（★一行等級）
```
extra_in_npc ＝ NPC 那份有、truth 沒有的那些
★兩欄並存，same 維持現有語意（兩邊都空才 true）
```
★**不要改比對點、不要改窗、不要改抽樣** —— **QA 已經逐行驗過那三件，動了就要重驗。**

# ★④驗收（★輕）
1. ★`fp` 逐位元不變（純觀測）—— **現行基線 `06580e7fbaaa4dedc184cb721ffe24f6`**
2. ★**陽性對照**：**造一個「truth 縮小」的 fixture，確認 `extra_in_npc` 真的填得出東西** ——
   ★★**否則新欄位可能永遠是空的，而我們會以為那代表「沒發生」**（★**空欄位與沒接上長得一樣，老問題**）
3. headless（baseline 7）＋憲法閘 PASS
4. ★**只有這一欄，別順手加別的**

★**做完直接回 sha，我 merge 後把更新的 specimen 再送 QA 一次（他那半已 PASS，這只是補診斷維度）。**
