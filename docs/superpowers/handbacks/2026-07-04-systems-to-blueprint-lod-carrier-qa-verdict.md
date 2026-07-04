---
from: systems
to: blueprint
status: open
topic: 兩軌 merged;貿易主斷修死但半路(6→16/2→5),殘因兩塊域外=你裁：①LOD far移速10×稀釋(世界節奏=平衡意圖+gen重校)②default無carrier(TAG_MERCHANT=0=gen);+QA判決題(絕對矛盾率0.71-0.76:機器綠=done?)由QA session出;率表首跑觀察素材附
---

# 貿易半路 + 兩塊域外裁權 + QA 判決題

貿易環+率表 harness 兩軌 merged，合體驗全綠（headless DONE/0 error、seeded 47/8/1/380、framework 7/0、coin_eq×4 delta=0）。**「一修雙解」你的假說被實測坐實**——envoy 弧默與貿易不成交同根=LOD 物流。

## 貿易：主斷修死，但誠實半路

- 主斷=timeout stale 秒殺（派 TRADE 拿 stale start_tick→tick>1440 派出即死，兩 seed dispatch 5.6萬/到場 0）。修=單源+廢平行欄（家族病第四次重演，這次結構性關）。
- 成交 6→16 / 2→5。**非數十=沒到你的「肉眼可見」bar**。殘因兩塊都在貿易域外，實作無權動，上交：

## ★裁權 1：LOD far 移速 10× 稀釋（世界節奏=你的 WHAT）

- 病：far 區隊 1 hex≈3 天（10× 慢）。無玩家世界全隊=far→跨格物流全癱=**貿易旅程永不到場 + envoy 馬鏈 6 月不貫通同根**。
- **HOW 我有**（修法三行已驗：movement 收 elapsed_ticks）：seed1337 成交 **6→30（達數十）**、到場 0→43(33.9%)、鏈全通。
- **但代價=你的平衡意圖**：世界節奏×10→pop 172→68(-60%) 塌房——gen 校準是在舊(慢)速度下做的，改對速度=gen 承載力/緩坡/狼密度全要重校。
- **裁點**：要不要把世界節奏改「對」（物流真能跑），接受 gen 全重校一輪的代價？還是接受 far 慢=世界設定、另找貿易/envoy 出路（如商隊走 near 通道/物流特殊尺）？**這是 WHAT+平衡，我等你定方向再出 HOW。**

## ★裁權 2：default 無 carrier（gen=你的 WHAT）

- default 兩 seed 全程 TAG_MERCHANT=0。跑單主體只剩商 archetype 流浪隊（多數 survival 自顧不暇）→商隊 funnel deal_merchant=0。現有的 16/5 成交全是 resident 村攤互售，不是「商隊接單跑單」那條你要看的弧。
- 修=gen 產專職商隊 or 既有隊晉升 TAG_MERCHANT 的路。**要不要有專職商隊階層=你的世界設計。**

## ★QA 判決題（交 QA session，非我判）

實作備了誠實機器：矛盾率 gate PASS（=「未比今天更壞」回歸證書），但**絕對矛盾率 0.71-0.76 印真值=病未清**（有效想要大量落空）。「機器現綠 = 貿易環 done？」照 QA 反轉制=**QA 驗收官判決，系統/實作不自判**。gate 綠 ≠ 健康證書；若 QA 要絕對率降健康帶才算 done，則卡在上述兩塊域外。率表 harness 已 ready 供 QA 全量跑。

## 率表首跑觀察素材（未判，QA 的活；你可先看方向）

default 自然世界兩 seed 6 月，幾條顯眼（**判決歸 QA，我只轉素材**）：
- **envoy 送達/派出 = 0%(1337) / 20%(2674)**——首列病單候選（=LOD 同根）。
- **立國 found/夠格 ≈ 0%**（26713 夠格檢查/2 立國）——但這可能是「合理的 0」（夠格瞬時多、真立國稀有 by design），QA 判。
- **event 多型 0 fire**（unrest_split/replace/faction_defect 六月零觸發）——可解釋 vs 啞火，QA 判。
- **消費/送達 1.7-3.3%**——非 order 類訊息無消費 chokepoint=結構性觀測缺（補探針題，非病）。
- 健康帶看起來 OK 的：belief 實質讀 40%、口碑比對 70-91%、G3 識破 9-16%、捕俘 27-67%、同化 50-67%。

## 我的建議序（你裁）

LOD 是貿易+envoy 共同鑰匙、且是「大地圖與遭遇戰共用時間尺度」invariant 的違反者——**優先級最高**。但它綁 gen 重校=大工。若你要先讓 QA 跑全量充足性稽核（率表已 ready）拿到全景判決表再定修序，也合理。等你定。
