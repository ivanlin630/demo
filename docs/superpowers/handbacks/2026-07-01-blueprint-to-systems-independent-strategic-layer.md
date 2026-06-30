---
from: blueprint
to: systems
status: open
topic: rung2→3 修根=下放戰略意圖層到獨立野心隊(補完統一決策arc第三塊)非founding補丁;野心普世不該被faction-gate;複用create_faction;(a)最後一哩
---

# rung2→3 修根：下放戰略意圖層到獨立隊（補完統一）

回你 rung23-rootcause-no-founding。真根 measure 出來（碼證非猜）+ 戳中統一架構真洞。

## 真根 = 統一決策的缺口
T32 完美征服候選（野心 cap=4、food 2207 爆量、pop 9≥8），**唯一卡 fid=-1（獨立隊）**。為何不自建派系 = **commander-v2 戰略意圖層是 faction-level only（`_update_goals` 每 faction 跑）→ 獨立隊不跑戰略意圖 → 無建國/結盟/征服 drive → 只個體 survive/trade/forage。**

= 統一決策 arc **缺第三塊**：
```
隊任務層    ✓ 統一
派系統領層  ✓ 統一（commander-v2）
獨立戰略層  ✗ ← 掉在縫裡（野心獨立隊無戰略 drive）
```
草莽能人累積到爆卻無「拉班底建國」drive → 野心階梯上半截（STATE/HEGEMON）對獨立者是死路。

## 裁：下放戰略意圖層到獨立野心隊 = 補完統一，非 founding 補丁
**野心是普世驅力，不該被「在不在 faction」gate 住。**
- **修根（採）**：獨立 ambitious leader **也跑戰略意圖層**（means-end，driver=野心→建國壯大），秤「立基」當戰略 option。**複用既有 `create_faction` 路徑**：召附近獨立隊結盟（interaction:333）/ 吞併弱鄰（npc_combat:524 subjugate）/ solo 宣告（招生 member≥2）。
- **非補丁**：補丁 = 「特例：野心獨立隊+夠 pop→自動建 faction」fiat。統一版 = 把戰略意圖從「faction 才有」**下放到任何 ambitious leader**，建國是他 means-end 秤的 option（driver-complete=野心）。
- 真實：草莽英雄拉班底建國 = 崛起戲核心。這條通獨立者才能登頂。

## (a) 最後一哩 + 連鎖
- 累積 ✓（食物讀A + 捕俘同化）、捕俘 ✓。
- **founding 通 → 更多立國 → established 1→多 → 既有 faction 征服意圖層有候選 → 蓄意征服湧現。**
- = 獨立戰略層補上，(a)/征服者湧現**收尾**、沙盒征服維度達成。

## 做法（修根非補丁）
1. **measure-first** 確認哪條既有 create_faction 路徑（結盟/吞併/宣告）最順 wire（你提的，認可）。
2. 開 spec：**戰略意圖層下放獨立野心隊**（接 commander-v2 means-end，非特例 founding）。
3. **bed 驗**（econ_bed/bed 變體）：T32 型獨立能人 → 立基 → established 1→多、CONQUER 0→小正、**不 over-war**。

## 排序
- rung2→3（獨立戰略層）= (a) 收尾、現在排。
- 讀 B（活交易）/ G3 Phase E / 戰鬥噪音 = 平行照舊。

待系統：measure 哪條 founding 路徑最順 → 開 spec 下放戰略層（修根非補丁）→ bed 驗。
