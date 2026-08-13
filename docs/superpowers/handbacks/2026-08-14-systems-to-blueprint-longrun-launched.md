---
from: systems
to: measurer
status: open
topic: "[★12月長局 e2e LAUNCHED detached 過夜跑中(隔日你收數據→QA story-audit 二輪)·bed=phase3_longterm_story_audit_bed(LW_MONTHS default 12、seed1337 續 audit baseline)、via tools/godot-detach.ps1 WMI-parented 過夜存活、GODOT_TIMEOUT=36000000·確認運行:pid godot 活、stdout『長期故事驗證 seed=1337 12月 ticks=86400』day1 avg=61.7ms/tick(team 56 起、成長→per-tick 漲、12月86400tick 預估數小時)·★輸出(末端一次寫):docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json + .specimen.jsonl(SpecimenDumpHelper=QA 故事稽核料)·systems 已 arm 完成-watch(json 出現即通知)·★隔日你收:對照 2mo baseline 看佔據率/pop曲線/starve/碎裂分合比/established/combat/settle-into-existing 隨窗放大否/vitals(糧帳P-C-跑道/團規模分布)+★settle-into-existing 量(1月僅1、12月窗放大否=A2/A4 真效隨窗)·specimen→QA story-audit 二輪(motive→action→outcome、禁跳 QA 自讀 metric)·★若跑不完/太慢=LOD arc 轉 load-bearing real 證據(記 time_scale_wave)·序:你隔日收→QA 二輪→systems consolidate→blueprint 帶用戶期末考·地基KEEP"
---

# ★12 月長局 e2e LAUNCHED detached（過夜跑中、隔日 measurer 收）

## launch 確認
- bed = `phase3_longterm_story_audit_bed`（LW_MONTHS default **12**、seed1337 續 audit baseline 可比）。
- via `tools/godot-detach.ps1`（WMI-parented 過夜存活、GODOT_TIMEOUT=36000000）。
- **確認運行**：pid godot 活、stdout「長期故事驗證 seed=1337 12月 ticks=86400」、day1 avg=**61.7ms/tick**（team 56 起、成長→per-tick 漲、86400 tick 預估**數小時**）。

## ★輸出（末端一次寫）
`docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json` + `.specimen.jsonl`（SpecimenDumpHelper=QA 故事稽核料）。systems 已 arm 完成-watch（json 出現即通知）。

## ★隔日你（measurer）收
對照 2mo baseline：佔據率 / pop 曲線 / starve / 碎裂分合比 / established / combat / **settle-into-existing 量隨窗放大否**（1 月僅 1 fire、12 月窗放大=A2/A4 真效隨窗）/ vitals（糧帳 P−C−跑道 / 團規模分布）。
- specimen → **QA story-audit 二輪**（motive→action→outcome、禁跳 QA 自讀 metric [[feedback_qa_inversion]]）。

## ★若跑不完/太慢
= **LOD arc 轉 load-bearing 的 real 證據**（記 [[project_time_scale_wave]]）。

序：measurer 隔日收 → QA 二輪 → systems consolidate → blueprint 帶用戶期末考。地基 KEEP。
