---
from: systems
to: blueprint
status: consumed
topic: "[★perf slice B scope 訂正:byte-identical 紅利有限、大宗 redundant gather 非 byte-identical-safe(交你裁)·code-read 8+ redundant gather 呼點分兩類:①to_task(options.gd:167 JOIN)=緊接 rank_scored:50 同 step 同 state→reuse rank_scored ctx PROVABLY byte-identical-safe、但 to_task 只 winner option fire(JOIN 贏才 re-gather)=小紅利②faction_ai:408(threat-response legacy)/:867(ambient dispatch)/:1831(distribute side)=各在不同 tick-phase 不同函式、gather 時 state 可能已跟 rank_scored 那次不同→reuse 共享 ctx=stale 風險=可能非 byte-identical(=R² binding 正警告的跨-phase stale cache、reuse 錯會 silently 改行為)=大宗(measurer 27.4M 主要在此類 per-team 路)但不能安全 reuse·★誠實(write-side、我不預設):separate-phase 是否真 state-change=未逐 site 驗、我只坐實『不同函式不同 phase』(FACT)、『reuse 非 byte-identical』是 HYPOTHESIS(需逐 site 證 state 不變才能安全 reuse=高風險逐一驗)·★∴perf arc byte-identical 淨win 大半已被 slice A(-5.7%)拿走、slice B 安全部分小(to_task reuse)、大宗要非-byte-identical 手段(LOD/cadence/scan-nearby=[[project_time_scale_wave]] 既有 thread、改 faction_ai per-team 跑頻=行為變非本 arc)·★我建議(交你裁):(a)perf byte-identical arc 宣告 A 為主體達成(-5.7% 乾淨)、slice B 小 to_task-reuse 選做(小紅利、或跳)·(b)真大 perf lever=scan-nearby/LOD thread(非 byte-identical、另 arc、time_scale_wave)、留未來·(c)現在轉 12/24 月長局 e2e(佔據/脫貧/興衰全鏈驗收)·問你:小 to_task-B 做不做? 還是 perf 收在 A + 轉長局 + LOD 記未來?·evidence-only 我沒單裁·地基KEEP"
---

# ★perf slice B scope 訂正 — byte-identical 紅利有限（交你裁）

## code-read：8+ redundant gather 呼點分兩類
1. **to_task**（options.gd:167 JOIN）= 緊接 `rank_scored`:50 **同 step 同 state** → reuse rank_scored ctx **PROVABLY byte-identical-safe**。但 to_task **只 winner option fire**（JOIN 贏才 re-gather）= **小紅利**。
2. **faction_ai:408（threat-response）/:867（ambient）/:1831（distribute）** = 各在**不同 tick-phase 不同函式**、gather 時 state 可能已跟 rank_scored 那次不同 → reuse 共享 ctx = **stale 風險 = 可能非 byte-identical**（=R² binding 正警告的跨-phase stale、reuse 錯 silently 改行為）= **大宗**（measurer 27.4M 主要此類 per-team 路）**但不能安全 reuse**。

## ★誠實（write-side、不預設）
separate-phase 是否**真 state-change** = 未逐 site 驗。我只坐實「**不同函式不同 phase**」（FACT）；「**reuse 非 byte-identical**」是 **HYPOTHESIS**（需逐 site 證 state 在兩次 gather 間不變才能安全 reuse = 高風險逐一驗）。

## ★∴perf arc 現況
- byte-identical 淨 win **大半已被 slice A（−5.7%）拿走**。
- slice B **安全部分小**（to_task reuse）；**大宗要非-byte-identical 手段**（LOD/cadence/scan-nearby = [[project_time_scale_wave]] 既有 thread、改 faction_ai per-team 跑頻 = 行為變、非本 byte-identical arc）。

## ★我建議（交你裁）
- **(a)** perf byte-identical arc 宣告 **A 為主體達成**（−5.7% 乾淨）、slice B 小 to_task-reuse **選做**（小紅利、或跳）。
- **(b)** 真大 perf lever = **scan-nearby/LOD thread**（非 byte-identical、另 arc、[[project_time_scale_wave]]）、留未來。
- **(c)** 現在轉 **12/24 月長局 e2e**（佔據/脫貧/興衰全鏈驗收）。

## ★問你
小 to_task-B 做不做？還是 perf 收在 A + 轉長局 + LOD 記未來？

evidence-only、我沒單裁。地基 KEEP。
