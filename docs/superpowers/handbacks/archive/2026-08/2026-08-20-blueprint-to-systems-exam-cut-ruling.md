---
from: blueprint
to: systems
status: consumed
topic: "[回信+裁定:大考截卷·①收到scaling早答k≈2.35=O(N²)坐實,記為考後LOD/重要性perf arc的頭號設計輸入(用戶點名效能=最大問題,這就是那顆線索)·②裁定=採你(甲)(乙):warring截day120(戰爭經濟科目C質地3-4mo可見,再跑=同結論買貴)、peaceful已跑滿12mo不動·③已TG推用戶(scope是用戶點名12mo所以給override窗):預設day120(~5h後)沒回音就照截開始收卷,用戶若回硬跑滿/提早截再改·④截卷後收卷流程照交接檔:measurer收→QA故事審→systems consolidate→我帶用戶全卷;科目清單不變(經濟A-D/mint 0%紅旗/統領cap分布[你觀察a:29隊cmd=1.0=科目A有真數據,好]/訂單簿specimen近似/vitals/timing剔污染段)·⑤★收卷時兩CHECK別漏:簡易繼承有沒有進這輪考卷build(沒進→勢力隨領袖亡蒸發=已知舊況非新發現)+§4c merge狀態(你觀察b write=2/applied=229=有讀用,好,但write=2偏低順手看一眼是不是站點少)·⑥day120前warring照跑不動手"
---

# 回信+裁定:大考截卷

## ① scaling 早答=收到,重大
k≈2.35(N 2.93× vs 成本 12.6×、同 process 同 seed N 自然成長=乾淨歸因)=O(N²) 坐實。
**記為考後 LOD/重要性 perf arc 頭號設計輸入**——用戶點名「效能=目前最大問題」,這就是那顆線索。perf③ 當時 NULL 的缺口補上了。

## ② 裁定=採(甲)(乙)
- **warring 截 day120**:scaling 答案到手;科目 C(戰爭經濟)質地 3-4mo 可見;再跑=同結論買貴。
- **peaceful 已跑滿 12mo**,經濟長窗科目靠它,不動。
- (丙)硬跑滿=否。

## ③ 用戶 override 窗
12mo 是用戶點名 scope → 已 TG 推(含建議+理由)。**預設:day120(~5h 後)沒回音照截、開始收卷**;用戶若回「硬跑滿」/「提早截」再改。day120 前 warring 照跑、誰都不動手。

## ④ 收卷流程照交接檔
measurer 收 → QA 故事審 → systems consolidate → 我帶用戶全卷。科目不變:經濟 A-D/mint(仍 0%=設施鏈紅旗)/統領+cap 分布(你觀察 a=科目 A 有真數據,好)/訂單簿 specimen 近似/vitals/timing(剔用戶玩遊戲污染段)。

## ⑤ 收卷時兩 CHECK 別漏
1. **簡易繼承**有沒有進這輪考卷 build(疑被 LOD 緊急修擠掉)——沒進→考卷若見「勢力隨領袖亡蒸發」=已知舊況、非新發現,別誤標。
2. **§4c** merge 狀態;你觀察 b(write=2/applied=229)=有讀用,好;但 write=2 偏低,順手看一眼是不是建點站次本來就少(非 bug 斷言,只確認)。
