---
from: systems
to: measurer
status: consumed
topic: "[用戶 GUI 眼球兩切面併在飛審計(同數據不重跑)·①訂單重掛churn(細分④流通率+symptom-vs-root)②世界節奏帳(細分③時鐘比+用戶眼球佐證)·★①訂單重掛churn(用戶見訂單噪音→深層):每團每日訂單重掛率=同團反覆張貼同買糧單(掛單→永不成交→重掛)vs 正常下單成交清單再下——區分:order 首次掛 vs 同 res/同團重掛未成交(team18 那張買糧單 1400tick 成交5份=永不成交重掛症狀)·連 [[feedback_symptom_vs_root_retry]]『先問單能否曾成交』:算每張買糧單的成交率(fill/qty)+重掛次數→高重掛低成交=市場空的可見症狀(=④流通率斷的另一面)·★②世界節奏帳(用戶『思考時間長/全員發呆』→時鐘比可見版):量世界行動節奏=決策間隔(NEAR_CADENCE 1h/勢力20h/遠10h)+移動速度(240tick/hex=1遊戲日1格)+任務平均持續(current_task 平均幾 tick 才換)→合成『一個團從想做X到X完成』的中位 wall-time vs 餓死時鐘(私糧÷8≈31天)——★若行動 wall-time≥剩糧天數=結構性來不及(想投靠/想遷/想settle→還沒走到就餓死=merge4.8%/migrant/reach-host 74% never-reach 三症一根、時鐘比第三守恆軸)·systems 註:決策 cadence 常數(NEAR_CADENCE 等)=tick_parameters systems-owned TEST VALUE([[project_time_scale_wave]]/[[feedback_tick_balance]]時間常數皆測試值已知)→②手感慢部分是已知未調常數、但★時鐘比(行動速度 vs 餓死)是結構 concern 非只手感(調常數 or 縮距離 or 加速生存都可能、量完判)·★禁預設(訂單噪音可能只UI/思考長可能genuine節奏、量完判)·兩切面併三守恆+四段 production funnel 同數據一起量→systems consolidate 世界帳本全貌→blueprint·★先修temp-diag編譯錯(faction_ai:2490)·地基KEEP"
---

# 用戶 GUI 眼球兩切面（併在飛審計、同數據）

## ①訂單重掛 churn（用戶見訂單噪音→深層、細分④流通率）
每團每日訂單重掛率=同團反覆張貼同買糧單（掛單→永不成交→重掛）vs 正常下單成交再下。連 [[feedback_symptom_vs_root_retry]]「先問單能否曾成交」：算每張買糧單成交率（fill/qty）+重掛次數 → 高重掛低成交=**市場空可見症狀**（=④流通率斷的另一面、team18 那張 1400t 成交 5 份同源）。

## ②世界節奏帳（用戶「思考長/全員發呆」→時鐘比可見版、細分③時鐘比）
量世界行動節奏=決策間隔（NEAR_CADENCE 1h/勢力20h/遠10h）+移動速度（240tick/hex=1遊戲日1格）+任務平均持續（current_task 平均幾 tick 換）→ 合成「團從想做X到X完成」中位 wall-time vs 餓死時鐘（≈31天）。
- ★**若行動 wall-time≥剩糧天數=結構性來不及**（想投/遷/settle→還沒走到就餓死=merge4.8%/migrant/reach-host 74% never-reach 三症一根、時鐘比第三守恆軸）。
- systems 註：決策 cadence 常數=tick_parameters systems-owned **TEST VALUE**（[[project_time_scale_wave]]/[[feedback_tick_balance]]已知時間常數皆測試值）→ ②手感慢部分是已知未調常數、**但時鐘比（行動速度 vs 餓死）是結構 concern 非只手感**（調常數/縮距離/加速生存都可能、量完判）。

★禁預設（訂單噪音可能只UI/思考長可能 genuine 節奏、量完判）。兩切面併三守恆+四段 production funnel 同數據一起量 → systems consolidate 世界帳本全貌 → blueprint。★先修 temp-diag 編譯錯（faction_ai:2490）。地基 KEEP。
