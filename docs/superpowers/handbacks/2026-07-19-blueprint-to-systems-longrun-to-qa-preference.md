---
from: blueprint
to: systems
status: consumed
topic: "[用戶偏好·soft] 有長時間模擬就給 QA 看(無 seed 亦可,QA 故事審不需可重現)。①記偏好入 memory ②修/建『長跑→QA可讀 trace』機制(observer ticker-dump 卡死跑不動/或加 headless event-dump)。"
---

# 用戶偏好：長跑模擬 → 給 QA 看（soft，無 seed 亦可）

## 用戶定（2026-07-19，soft 非硬性）
**「有長時間模擬就給 QA 看。」** + 校正:**QA 故事審不需要可重現** —— seed(可重現)是量測/回歸用;QA 讀「已發生的故事判 coherent 否」,drift 不影響。∴ **長時間無 seed run 也是 QA 好素材**（比窄 seeded 回歸 specimen 更能抓長跑才現形的故事斷裂）。

## 請 systems 做
### 1. 記偏好入 memory（你單寫者）
- 「長跑模擬 → 餵 QA 故事審(soft)；無 seed 亦可(QA 判 coherence 不需可重現,seed 是量測用非故事審用)。」可併現有 QA/量測協議 memory（[[feedback_qa_inversion]] / [[reference_measurement_protocol]]）。

### 2. 修/建「長跑 → QA 可讀 trace」機制（gap，現無可用）
- **設計本已存在**：observer `--obs-ticker-dump`（跑完全量事件流落檔 tick/type/teams/text → QA 世界句子審計）。**但 observer harness 卡死**（blueprint 2026-07-19 headless 試 2 分 timeout 零輸出；2026-07-13 measurer 亦卡 25 分,根因未查）。
- **三選一（你 HOW）**：
  1. **修 observer ticker-dump**（原設計,乾淨敘事）——含查那個 headless GUI scene 卡死根因。
  2. **加 headless 長跑 event-dump**（`game_sim_multi` stdout 已有 `逃跑/覓食/FoodLedger/Order` 事件,結構化落檔即 QA 素材）——繞開卡死的 GUI scene。
  3. 過渡:QA 直接讀 multi-sim 原始 log（糙但即用）。
- **我傾 2**（headless dump 繞開卡死的 GUI,最省且可靠）,但你 HOW 定。

## 注意
- 這是**觀測/QA infra**,非遊戲行為改動 → 不佔框架 god-view 殲滅主線,可平行/低優先做。
- 當前「seeded specimen → QA 對當前世界正式判」請求(to:measurer)照跑,不受此影響。

## 溯源
用戶「故事會飄但 QA 還是能判、希望長跑就給 QA」(soft);blueprint over-weight seed 已收回;observer ticker-dump 設計(observer_main.gd:4)卡死;[[feedback_qa_inversion]]。
