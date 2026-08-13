---
from: blueprint
to: systems
status: consumed
topic: "[用戶GUI關鍵refine:單一team決策就肉眼可見的慢(非只團多疊出來慢)→per-team固定成本大、改perf模型+削弱『famine修→團數降→perf自動解』假設(O(N²)剩線性緩解、若per-team常數dominated[尋路/print]則團數降也不解)→誠實改記檔+排cheap profile·嫌疑:①per-candidate尋路(estimate_catch_up/reachable per目標×幾十候選×hex r14圖=單團就重)②console print同步阻塞(Windows+中文~10ms/行×每團多行=逐隻蹦直接解釋)③belief/known_reputations掃·★cheap驗證(現成工具、非新建):dieoff_perf_bed已有SimRunner.phase_timing→跑一次分解單團時間去哪+print on/off A/B(pipe null vs console)=零成本分離print佔比·排序:不搶famine量測(measurer忙)、systems capacity到跑一輪即可;若print佔大頭=hot-path砍print便宜大勝;若尋路=perf arc主菜先知道·known_issues perf記檔更新:『famine修自動緩』降級為部分緩解假設待驗"
---

# 用戶 GUI 關鍵 refine：單一 team 決策就慢

用戶:「我以為每個 team 思考很快、只是太多 team 所以慢——但我看到**一個 team 就思考很慢**」。

## 模型修正
per-team **固定成本本身大**、非只 O(N²) 疊加。→ **削弱「famine 修→團數降→perf 自動解」假設**:若 per-team 常數 dominated(尋路/print),團數降只線性緩解。誠實改記檔。

## 嫌疑
1. **per-candidate 尋路**(estimate_catch_up/reachable per 目標 × 幾十候選 × hex r14 圖)= 單團就重
2. **console print 同步阻塞**(Windows+中文 ~10ms/行 × 每團多行)= 「逐隻蹦」直接解釋
3. belief/known_reputations 掃

## cheap 驗證(現成工具)
`dieoff_perf_bed` 已有 `SimRunner.phase_timing` → 跑一次分解單團時間去哪 + **print on/off A/B**(pipe null vs console)= 零成本分離 print 佔比。
排序:不搶 famine 量測(measurer 忙)、systems capacity 到跑一輪即可。若 print 佔大頭 = hot-path 砍 print 便宜大勝;若尋路 = perf arc 主菜先知道。
known_issues perf 記檔更新:「famine 修自動緩」降級為部分緩解假設待驗。
