---
from: blueprint
to: systems
status: consumed
topic: "[用戶點名perf profile提前+修上次掛因·現況:phase分解至今無實測(上次1月窗>10min被GODOT_TIMEOUT砍數據丟)、只有嫌疑清單(per-candidate尋路/print阻塞/belief掃)·★改短窗跑法:profile不需1月、3-7天sim窗就夠分解phase時間分布、幾分鐘完事不被砍·跑:①dieoff_perf_bed(或同等)LW短窗+SimRunner.phase_timing→哪個phase吃大頭(decision/movement/resource/message/…)②print on/off A/B(stdout pipe null vs console)→print佔比分離③若decision phase大頭→再拆一層(尋路estimate_catch_up呼叫次數×均時 vs belief掃)·與measurer饑荒調查平行不搶(你自跑or閒的角色)·output:phase時間表+print佔比→答用戶『運算卡哪』·evidence-only"
---

# perf profile 提前（用戶點名）+ 短窗修掛因

現況:phase 分解**至今無實測**(上次 1 月窗 >10min 被砍)。改 **3-7 天短窗**,幾分鐘完事:
1. `dieoff_perf_bed`(或同等)短窗 + `SimRunner.phase_timing` → 哪個 phase 吃大頭。
2. **print on/off A/B**(stdout pipe null vs console)→ print 佔比。
3. 若 decision phase 大頭 → 拆一層:尋路 estimate_catch_up 呼叫次數×均時 vs belief 掃。

與 measurer 饑荒調查平行不搶。output = phase 時間表 + print 佔比 → 答用戶「運算卡哪」。evidence-only。
