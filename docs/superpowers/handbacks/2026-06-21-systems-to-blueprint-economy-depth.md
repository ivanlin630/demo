---
from: systems
to: blueprint
status: open
topic: 經濟 arc 比預期深 — 6 層 plumbing 全通，剩 2 件碰平衡/WHAT（商隊貿易優先序 + 市集交易模型），要你拍板
---

# 經濟：plumbing 全通，但卡在「商隊不想貿易 + 市集撲空」兩件設計題

承 `economy-direction`（你裁 B 市集 + 上限 + 糧倉）。我照裁定一路實作 + measure-first 剝洋蔥，**比預期深得多**。誠實盤點 + 要你兩個方向。

## 做了什麼（6 層，全 merged、main 全綠、守恆 0）
| 層 | 修了什麼 |
|---|---|
| WS-2 | dispatch 角色卡死 + 訂單 pos 路由到市集 |
| WS-1 | 食物進 capped 糧倉 + 硬上限（囤糧 4-5萬→封頂崩） |
| WS-3 | carry cap 硬化 + 馬車載量 load-bearing |
| WS-2b | 市集看板（訂單登錄 outpost + 抵達親讀，破訂單可見性死鎖，守 G3 傳播） |
| WS-2c | food accessor 單源（破商隊「自以為餓」survival 二階鎖） |
| WS-2d | 旅途乾糧（解「糧倉拴住商隊」——離家就誤判餓被拽回家） |

**真進展（world_sim 權威量測）**：0 交易 → 商隊現在**到得了市集、讀得到看板、首次出現 1 筆履約**。每層都是真 bug，不是空轉。

## 但 [Market]成交仍 0 — 剩兩件已離開 plumbing，進你的領域

### 病 1：商隊根本不想貿易（task 優先序 = 平衡/feel）
探針實況：
- 有 outpost 的商隊（T1）→ 坐家裡 **生產**，不出門。
- 獨立商隊（T6）→ 永遠 **覓食**。
- **貿易意圖在 AI task 仲裁裡贏不過 生產/覓食**（且只在 IDLE 才重評貿易 → 商隊永遠在忙別的、輪不到貿易）。

→ **要你定 WHAT**：商隊（商隊 tag/商業 archetype）該**多優先貿易**？
- (a) 商隊 = 貿易專職，貿易壓過生產/覓食（除真絕境）→ 世界看得到跑單幫，但商隊不自己種田。
- (b) 商隊也要顧生存/生產，貿易只在有餘力時 → 貼現狀但貿易稀少。
- 我傾向 (a)（你選 B 市集的本意 = 要貿易真發生；商隊就該以貿易為業）。但這是 feel，你定。

### 病 2：市集交易要 order-owner 本人在場，但大家都在跑（WHAT：市集是攤 vs 倉儲）
現模型：貿易 = 商隊與 order-owner **同格碰面** `_resolve_market`。但 residents 也在動（生產/徵收/return_home）→ 商隊到市集常**撲空**（看板在、人不在）。

→ **要你定 WHAT — 市集是哪種**：
- (A) **有人顧的攤**：交易需 order-owner 在場。則需「居民駐守自家市集」行為（residents 別亂跑）。較擬真、有「商隊撲空」emergent，但要 AI 駐守。
- (B) **自動倉儲/depot**：商隊對市集 `public_storage`（公庫）**直接買賣**（按看板訂單與倉儲結算，無需 order-owner 本人）。市集變自主貿易站。穩定點亮經濟，但市集「無人化」(少了攤主互動 feel)。
- 我傾向 (B)（最穩破成交 0 + 你要的「固定市集成交必發生」+ 倉儲＝據點經濟容量已有 public_storage 基礎）。但 (A) 更有人味。你定。

## 為何回報而非繼續鑽
前 6 層是純 HOW（plumbing bug），我自決照做。這兩件 = **平衡（商隊多想貿易）+ WHAT（市集人味 vs 倉儲）**，碰你的領域。我不該再自動往下調 AI 權重/改市集語意 = 那是你的意圖決定。

## 你回什麼
兩個方向各一句（病1 a/b、病2 A/B）。我據此出 spec/plan → 子 session。預期這是經濟 arc **最後一哩**（plumbing 全通，補上「商隊想貿易 + 市集成交得了」就活）。

## 附帶（與此無關，知會）
world_sim 長跑 InvariantAudit 偶報 `known_reputations 含死 Team` dangling-ref = 既有 B-class（G3 信譽圖，非經濟引入，headless clean-state audit 綠）。已在 known_issues，待另排。
