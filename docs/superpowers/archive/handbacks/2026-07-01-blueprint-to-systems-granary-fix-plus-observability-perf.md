---
from: blueprint
to: systems
status: consumed
topic: #1 granary先(定位measure→修根結構非補丁) + 探針加強(process追蹤非只end-state) + 每-tick計時 + 後期scaling卡死評估(=沙盒bar長跑要求)
---

# #1 granary 先 + 探針/perf 三要求

排序：**#1 granary slice 先**（小、收尾經濟、解鎖貿易戰）→ 之後 #2 G3 Phase D。用戶加三個附加要求（探針/perf 基礎設施），一起交。

## ① granary：先定位 measure → 修根（症狀確定、根待定位）
- **確定**：forest net0 卻 granary 填滿 → 交易網不 fire。
- **未定位**：為何 net0 還填滿（harvest 獨立 fill path？消耗沒扣 granary？cap/tile 池 init？）。**先精準 measure 定位到碼**（同前每個根：leader弱/攀爬/餓死/rung2→3 都先量到碼點）。這**不是 measure 來回**（那是反覆量混亂 seed），是**定位一次**。
- **修根方向**（結構、非補丁）：**成長吃「持續盈餘（flow：收入>消耗）」，非「糧倉滿（stock）」** → forest net0 無盈餘→不長→逼賣木買糧轉正才長。
  - **別 nerf 地形 regen**（forest 仍 3，不是不能活，是光靠 regen 長不大、繁榮須交易）。
  - **別砍 granary cap 補丁**（那是平衡調、治標）。定位真根後修結構。

## ② 探針加強：追「過程」非只「結尾」
用戶點名：**跑完後看不到過程**。一路 measure 都只數 end-state tally（2yr 跑完數事件），**看不到 what happened when / why**。
- **加 process 探針**：關鍵事件/決策**帶 tick timeline**（誰、何時、為何選了啥），不只最終計數。
- **助診 emergence gap**：現在 emergence「機制✓活世界✗」一直診不清，正因只看結尾的 0；**看得到過程**才知「征服者為何沒湧現」是哪個 tick 哪個決策斷。
- = 這是 measure-first 方法論的基礎設施升級，服務所有後續診斷。

## ③ 每-tick 計時 profiling
- **記錄單位 tick 跑多久**（tick 時長 log，帶 tick 數）。
- 供判斷 per-tick 成本 + 哪些系統吃時間。

## ④ ★ 後期 scaling / 卡死評估（= 沙盒 bar 長跑要求）
判斷**遊戲後期會不會卡死**：
- **什麼隨世界規模長**：belief multi-claim（200/observer × 多 observer）、captive、faction、RelationGraph 邊、feud 史、team 數…
- **per-tick 成本會不會超線性** → 世界越跑越大 → late-game 卡死風險。
- **為何是願景要求非只工程**：沙盒 bar = 世界**長跑 standalone 產出戲**。**若後期卡死，我們一直等的 emergent 大戲永遠跑不到**。長跑不退化 = 沙盒 bar 的硬要求。
- 產出：scaling 評估（哪些系統 O(N²)/爆、late-game 投影、要不要 LOD/剪枝加固）。

## 待系統
1. **#1 granary**：定位 measure（探針帶 process/timeline）→ 修根（結構、非補丁、非 nerf 地形）→ bed 驗交易網轉。
2. **探針加強**（process 追蹤）+ **每-tick 計時**：這塊順手鋪，服務所有後續。
3. **後期 scaling 評估**：報告哪些系統會爆、late-game 卡死風險、加固建議。
4. #2 G3 Phase D 排 #1 之後（我會先 brainstorm 欺敵 WHAT）。

granary 收尾經濟維度；探針/perf 是長跑沙盒的地基。
