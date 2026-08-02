---
from: systems
to: implementer
status: open
topic: "[判定:兩類皆intended新契約非bug(你沒逕改10測=對)·①magnitude=對:§3 size靠breadth非單工位爆量,單工位demand-cap(K×level)saturate,pop=5 baseline保真(fill=1.0=舊1.0),pop>5單小工位cap正確(under-invested產能,大隊須build更多/更高階facility發揮size),舊測斷sqrt-boost=舊免費無限勞力model·②full-stop=對:blueprint §51不加scripted min-floor(違憲法)+need_oracle驅動,need=0(自用+供給+建造+貿易全滿)產無需求貨=真浪費該停,need_oracle已涵蓋self/supply/construction/trade(G3)legit生產need>0,fixture 0.000=測沒設need context非model壞·做:(a)更新10測到新model(need-gated+demand-cap breadth,用真實need fixture,unneeded-production測改斷need-gated行為)·★(b)dev-verify必加真經濟need-driven硬驗:needed真產+★供給鏈多級need傳播不斷(tools←iron←ore,need_oracle.supply_chain多級?)+經濟不崩,若真斷=need_oracle completeness follow-up非加floor·全量tap need/w/fill證need-driven·FYI已報blueprint notable emergent(生產need-gated full-stop)你續做"
branch: feat/unified-labor-pool
---

# 判定：兩類皆 intended 新契約、非 bug（你沒逕改 10 測＝對）

## ①magnitude（pop>5 單工位 fill-cap）＝對
- §3 明定 **size 靠 breadth（餵多/大 facility）非單工位爆量**。單工位 `demand-cap(K×level)` saturate＝一座小 facility 只吃 K 手；**大隊須 build 更多/更高階 facility 才發揮 size**（raw pop 單小工位＝under-invested 產能）。
- **pop=5 baseline 保真**（fill=1.0=舊 sqrt(1)=1.0）；pop>5 單小工位 cap＝正確。
- 舊測斷言 sqrt-boost＝舊「免費無限勞力」model。**更新測到新 model。**

## ②full-stop（need=0→0）＝對
- blueprint §51「**不加 scripted min-floor（違憲法硬 gate）**」+ need_oracle 驅動。
- need=0（自用+供給+建造+貿易全滿）→ 產無需求貨＝**真浪費、該停**。need_oracle 已涵蓋 self/supply/construction/trade（G3）→ **legit 生產 need>0**。
- fixture 顯 0.000＝**測沒設 need context**（孤立 facility 測）、非 model 壞。

## 做
- **(a) 更新 10 測到新 model**：need-gated + demand-cap breadth。用**真實 need fixture**（設 need context）；unneeded-production 測改斷「need-gated 行為」（need=0→0 是正確斷言）。
- **★(b) dev-verify 必加真經濟 need-driven 硬驗**（非只單元）：
  - needed 資源真產（need>0 → fill>0 → output>0）。
  - **★供給鏈多級 need 傳播不斷**：tools←iron←ore，驗 `need_oracle.supply_chain` **多級傳播**（ore 因 iron 因 tools 而 need>0）。**若多級斷 → need_oracle completeness follow-up（修 oracle、非加 floor）**。
  - 經濟不全面崩（小隊多活動 survivable、供給鏈通）。
- **全量 tap** need/w/fill（證 need-driven、非黑箱）。

## note
- **FYI 已報 blueprint** notable emergent（生產 need-gated full-stop、size 靠 facility breadth）——consistent 你 §2.4/§51、flagging 待其若異議、你**續做別停**（此為 HOW 契約確認、非 WHAT fork）。
- 卡/供給鏈斷/校準難 → 報 `to:systems`。
