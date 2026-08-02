---
from: blueprint
to: systems
status: consumed
topic: "[awareness/掃近隊 arc 完整 scope·brainstorm 定案 2026-07-18] 頭號主樑=拔創世 god-view 違憲(game_setup:569-578 人人全知)+創世知識②+③混。全 WHAT 匯總供 Tier2 spec。此 arc=落地已設計資訊地基(765-964)+堵 god-view 後門,非新設計。地基 scope(操控 defer)。"
---

# awareness / 掃近隊 arc — 完整 scope（brainstorm 定案 2026-07-18）

一場藍圖×用戶 brainstorm 定案。此為 Tier2（經濟後）開 spec 的完整 WHAT。**重定性：資訊地基早設計好（`game-design:765-964`）+ `line 396` 已是掃近隊洞見 → 此 arc＝落地+強制那份地基 + 堵 god-view 後門，非新設計。**

## ★★頭號主樑：拔創世 god-view 違憲（本 session 新挖，最重要）
- **grep 坐實違憲**：`game_setup.gd:569-578` 創世雙迴圈把**每隊塞進每隊 `team_discovered`＝人人開局全知＝違憲**，短路掉「資訊碎裂（`line 63` 遊戲前提）→發現弧」全部核心戲。
- **正確機器已存在**：`vision_system.tick_discovery`（本地視野半徑3+偵查+地形+隱蔽 gated 發現鄰隊）＝憲法正確 discovery，只被創世作弊蓋掉。
- **修＝拔創世 seeding，創世知識改 ②+③ 混（用戶定）**：創世知道＝**自己派系 + 本地地理鄰居 + 有淵源對象（傳統盟友/世仇）**；陌生遠方一律未知，玩中發現。棄①純湧現（孤立凍死盲）、棄現行全知。
- **make-or-break（R①）**：拔全知後 need-驅動移動夠不夠 bootstrap 不凍（定居隊坐著永不發現）？不夠→補輕量探索/好奇驅動 or 收窄創世 seed 半徑。

## 兩 channel + 決策考慮集（belief 為源）
- **①掃近隊＝直接感知**（空間、即時、精確）＝O(N²) 成本所在，bound 這個省 perf。
- **②belief/情報網＝你知道的**（近+遠、延遲、不確定、decay）＝遠方危險經斥候/難民/商旅傳到你，對 belief 反應。**硬約束**：掃近隊絕不能讓遠方高危險隊隱形→危險必須經情報網傳到你，獨立於直接掃。
- **決策考慮集 ≠ 當下視野**＝掃近隊∪持久/永久 belief：
  - **持久（抗 flicker/隱蔽）**：看過→進 belief，隱蔽/閃現不瞬間忘，殺 flicker-thrash。
  - **恩仇永久記憶層**：兩層記憶——短暫感知 decay+cap；**重要記憶（恩仇/世仇/恩人/重要關係）＝永久免疫 decay 與淘汰**（非 salience 慢 decay，是根本不淘汰）。1-2 代 bounded。

## 世界特徵也 belief-gate（非只隊）
- 「無全知」套所有東西：市場/糧點/資源/地形。**現行 `has_food_market` 掃全圖（`known_issues:35`）＝god-view 後門，此 arc 一併堵**（決策讀 belief 的市場位置）。

## 主動偵查（納，待驗）
- 主動投資情報（派斥候/審俘/買情報）＝決策（花成本換確定性），非只被動收訊。**R① 驗 `inquiry_system` 是決策驅動主動 scout 還是被動查詢，別假設。**

## scope 線：地基，非操控（用戶定）
- **此 arc＝地基**：belief+霧+傳播+可被餵假的接口（讓假情報進得來）。
- **主動情報操作**（隊決定放謠言/捏造/虛張誘敵）＝**情報操控維度 defer**（`game-design:909` 明訂框架放得下、非急）。**不在此 arc。**

## R① 匯總（spec 前必驗，別憑舊 memory）
1. LOD 現態/O(N²) 確切點/scan-nearby 可行（原 3 問）。
2. 情報網真傳得到遠威脅（率/延遲/衰減）＝掃近隊不盲的前提。
3. 拔創世全知後世界 bootstrap 不凍（need-移動夠不夠 populate belief）。
4. 既有 belief 真有 persist+decay？恩仇永久層存在還是均勻 decay（會忘宿敵）？
5. `inquiry_system` 主動 scout 決策存在否。
6. `has_food_market` 等世界特徵 god-view 後門清單（exhaustive 掃還有哪些）。

## 序
落檔＝現在（game-design per-tick 有界底線已收全部上述）；實作＝Tier2（經濟 deal-flow 後）；此 arc 併「廢 LOD+掃近隊」thread＝B enabler。

## 溯源
本 session brainstorm（憲法重述→冷啟動悖論→grep 揪創世全知違憲→②+③ 選型）；`game-design:577-585`（per-tick 有界底線 awareness 段全收）+`765-964`（資訊地基）+`line 396`（掃近隊洞見）；`game_setup:569-578`（違憲）；`vision_system.tick_discovery`（正確機器）；`known_issues:35`（has_food_market）；[[project_time_scale_wave]]。
