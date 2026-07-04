---
from: blueprint
to: systems
status: open
topic: ★時間納統一矩陣(漏掉的維度)——時間骨架單一來源+三時間不變量+84常數稽核成分組表+強制閘掃裸tick;×5拆三真根(後勤/行軍降頻/觀看倍速);A(O(N²)bound,目標~50隊)+B(far elapsed)+gen及污染常數重校=一個time-scale wave;放行三平行measure
---

# 時間統一 wave（+ LOD/perf 裁定 + V2 收尾 + 平行放行）

一連串走查收斂成一件大事：**時間是統一矩陣漏掉的維度**。×5 只是第一個爆的補丁，底下 84 個時間常數散在 21 檔、各自硬編、互相隱含假設 = 矩陣在殺的「同概念多處各寫」，只是稽核實體×領域時沒把時間當一格。

## 前置收尾（先確認）
- **V2 撤回收下**（QA 自驗坐實假陽性，maker/checker 抓 measure 自己的錯）+ probe 交叉驗升格（feasible/happened 必量同族群）。真🔴 縮 3 條全物流。
- **LOD 數據 reframe 收下**：LOD 只 3× 常數、真根 O(N²)（faction AI 忽略 subset）。「拿掉/重定義 LOD」是下游、非旋鈕。
- **放行三平行 measure**（不卡 WHAT）：V3 accept 路徑 / V2-commander 征服路 probe / V4 envoy timeout。measure-first，修向等數據。

## ★ 時間納統一矩陣（新維度）
矩陣加一格：領域「**時間尺度**」（之前漏）。

**時間骨架 = 單一來源**：所有時間量從 `TimeScale` 導出，禁裸硬編 tick。
```
基準：TICKS_PER_DAY(240) + BASE_ACTION_TICKS(10=遭遇戰動作粒度)
導出（連動非獨立塞）：
  移動/格 = BASE_ACTION_TICKS × 遭遇戰地圖尺度   ← 連動不變量
  行軍糧耗 = f(移動時間)                        ← 後勤連動
  cadence/timeout = TICKS_PER_DAY × 語意天數      ← 強制全部
```

**三時間不變量（納 invariants，同意圖/belief/state family）**：
1. 凡時間量必從 TimeScale 骨架導出（禁裸硬編 tick）。
2. **移動-遭遇戰連動**：大地圖格 = 遭遇戰動作 × 遭遇戰地圖尺度（不准倍率打破）。
3. 凡延遲/timeout/cadence 以語意單位（「3 天」非「720 tick」）。
→ **強制閘可掃**：裸 tick 常數 / 繞骨架的倍率 = CI fail。= 時間版「無因令=0」，根治 ×5 那類補丁。

## ★ WORLD_SPEED_MULT=5 拆三真根（用戶揭：它一個旋鈕硬扛三件事）
```
×5 混在一起補的三個真問題,各歸真根:
  ① 走一格餓死    → 行軍後勤真機制（帶乾糧/沿途補給/raid,接後勤裁定）
                    measure「走一格餓死」真帳:糧耗 vs carry vs 沿途補給哪缺→補
  ② 移動中白算思考 → 移動中隊進「行軍狀態」:決策 cadence 大幅降
                    （每天一次/事件觸發,非每 tick）=believable(行軍悶頭走)+減 O(N²)負,餵 A
  ③ 圖世界跑快     → 觀看倍速(GUI 1×/4×/MAX 已有),不碰物理
拆完 → WORLD_SPEED_MULT→1、移動回 240/格=連動,補丁安全拿掉
```

## A（throughput O(N²)）：目標 ~50 隊 → 必修
- **目標規模上限 = ~50 隊**（五代十國多強並立要夠演員;14 太稀、100 垮）。
- **A 必修**：41 隊已 137tps<240 + 1s hitch = 撞 per-tick 有界硬不變量（引擎契約）。50 隊更糟。非可選。
- **方向**（HOW 系統定精確排法）：**空間分區為主**（複用既有 `teams_by_tile` 索引,O(N²)→O(N)、九成成本=跟遠隊比對砍掉）+ **honor-LOD**（evaluate_all 真收 subset,3 行止血）+ **cadence 攤**（削峰保 per-tick,②行軍降頻餵這條）。全接既有基建、大工非難工。known_issues 早標的債到期。

## B（far elapsed）：即修
far 隊移速/思考 elapsed 積分（疏非慢非笨）——詭異感+物流(貿易/envoy)一修雙解。與 A 正交、不等規模裁定。

## carrier + gen 重校（V1 wave 其餘）
- carrier：專職商隊該存在（商旅=真階層、經濟網需載體）。致富→行商湧現為主 + gen priming。
- **gen 重校 + 受污染時間常數 一起重校**（照乾淨連動速度 240/格）。

## 整個 = 一個 time-scale wave
```
1. 時間參數稽核（QA/系統）→ 84 常數分組表（受污染/獨立/該導出/連動組/後勤組/AI組/觀看組）
2. 時間骨架重建（TimeScale 單一來源 + 三不變量）+ WORLD_SPEED_MULT→1（連動）
3. ×5 三真根分流（後勤 measure→修 / 行軍降頻=②餵A / 觀看倍速歸GUI）
4. A（空間分區+honor-LOD+cadence,目標50隊）+ B（far elapsed）
5. gen + 受污染常數 重校（乾淨速度）
6. 強制閘掃裸 tick/倍率 + checklist 補「時間量必導出」
7. R7 全環對照 + QA 充足性重跑（確認 wave 沒壞既有戲）
```

## 藍圖自檢
- 這 wave 大——但**本來就欠**（時間出貨前必理乾淨，×5 只是第一個爆的）+ **零新方法論**（矩陣稽核+單一來源+不變量+閘,套到時間維度）+ **一次性**（骨架成後調節奏=動一基準全連動,不再 84 地雷）。
- 你可能問「又要重校 gen」——是，但這次連污染時間常數一起，是**最後一次**（骨架立起後速度變只重校一次、不再漂）。

## 待
時間稽核放 wave 最前（QA/系統）→ 分組表回報 → 藍圖裁骨架/連動具體值 → 全 wave 燒。三平行 measure（V3/V4/V2-cmd）不卡此,先跑。
