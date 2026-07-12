---
from: blueprint
to: reviewer
status: consumed
topic: [R②設計審] 立國門整體重思——B1(≥2成員)+存續時間為主閘,B2統領/B3野心/B4readiness降級為立國速度/聲望修飾非硬門檻；用戶已裁(vision選項2)
---

# 立國門整體重思 —— 設計送審（R②）

## 背景（真根，established調查鏈六輪已摸清全貌）
established全程恆0——非單一門，是四重AND閘疊加：
- B1（≥2成員，結構）
- B2（統領≥~0.35，雞生蛋累積型，唯一成長被繁榮閘鎖，已部分緩解裂縫4.2%）
- B3（野心≥0.6，靜態人格值終生不變，且此門檻>建國門檻0.55，倒序）
- B4（readiness≥0.7，軟食物gated，combat drain>recovery timing）

四門同時要求「統領高+野心高+戰備滿」= 只有繁榮好戰faction過得了關，溫和/和平faction structurally立不了國。詳見`2026-07-12-systems-to-blueprint-b4-readiness-and-establishment-synthesis.md`。

## 用戶裁定（vision，已選）
**整體重思立國門**（非逐層tune）：立國該代表「政治穩定/存續」，不該綁「戰鬥力/繁榮度」。多數faction只要撐得夠久、夠穩定就該能立國——不管是溫和派還是好戰派。

## 設計意圖（WHAT，細節交systems判斷HOW）
1. **主閘簡化**：established主要條件改為 **B1(≥2成員) + 存續時間（faction tenure，撐夠久）**。具體tenure天數/週期由systems評估，比照現有INFRA_INTERVAL等cadence量級抓一個「數週到數月」級別的門檻——目標是「穩定撐過一段時間」而非「瞬間高數值」。
2. **B2/B3/B4降級為修飾非硬門檻**：統領技能、野心、readiness不再是「過不了就永遠established=false」的AND閘，改為**影響立國速度快慢/立國後聲望高低**的加成——例如統領高+野心高+戰備滿的faction可以更快達成established（tenure門檻打折）或立國後獲得額外聲望/效果，但缺乏這些的faction只是「慢一點/樸素一點」立國，不是「永遠立不了國」。
3. **不動**：faction形成本身的A門(人口/food surplus/可達盟友)，那是farming死鎖鏈已處理的上游部分，established重設計只動B門(faction→established)本身。

## 為何（vision對齊）
現狀established=0一路恆0，這不是「難」而是「structurally只有特定faction類型過得了關」——溫和/剛立足的faction無論多穩定都被三重篩擋死。用戶要的世界=多元faction都能立國（溫和小國+好戰帝國並存，差異在立國速度/聲望，非能不能立國）。

## 審查重點（factcheck/skeptical）
1. tenure怎麼算/從何時起算——faction形成(B1達成)那刻起計時？中斷（成員跌破2人又補回）算不算重置？需systems定義清楚避免歧義。
2. B2/B3/B4降級為「加成」的具體機制——是否有既有pattern可循（例如某種modifier/multiplier架構），還是要新設計。
3. 這是否影響既有「established」語意在其他系統的下游使用（例如外交/信用幣等後期機制是否依賴established當前置條件，降級主閘後下游是否受影響）——查`is_established`欄位的其他讀取點。
4. determinism/regression：這是行為大改（非純調常數），預期established分布會從「恆0」變「有正值」，這是預期效果非regression，但需向measurer/QA說明這是刻意的vision改動。
5. 範圍是否過大需拆分：若「tenure機制+B2B3B4降級」牽涉多個檔案/多個系統交互，考慮是否分兩個slice（先建tenure主閘，再拆B2B3B4降級），降低單一slice風險。

CLEAN後推systems出正式spec（含B2/B3/B4降級的具體機制設計）。
