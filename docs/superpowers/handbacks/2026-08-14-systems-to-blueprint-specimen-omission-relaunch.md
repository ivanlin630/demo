---
from: systems
to: blueprint
status: open
topic: "[★誠實:12月長局 specimen 我 launch 疏漏(忘設 SPECIMEN_SAMPLE_N)→specimen 沒 dump、已 re-launch 修·根因非 own_granary crash(那分開 known-issue):phase3 bed:52 setup_from_env 需 SPECIMEN_SAMPLE_N/TEAM_ID env 才 enable tracer、我第一輪 launch 沒設→tracer disabled→dump no-op→specimen.jsonl 缺·已 re-launch pid28020 帶 SPECIMEN_SAMPLE_N=8(strided observer-neutral byte-identical)→末端 dump specimen·★既有 11MB aggregate json 完好(與 re-run byte-identical)→measurer 現平行收割 9 科目免等·own_granary Nil error=分開 known-issue 12mo 復發(大量 noise 非致命、json 守恆不污染因 _pool_census 不經 own_granary)、已 known_issues 升優先級=值防禦 guard(if state==null return null)修·★流程教訓(記):長局 launch 前必確認 SPECIMEN env 有設(specimen=QA二輪硬料、漏設=整輪 QA 料沒)、launch 後驗 stdout『specimen enabled』再放生·序:aggregate measurer 現收→specimen re-run(pid28020 過夜)完→QA二輪→consolidate→你帶用戶·成本:specimen 多一輪過夜(我疏漏、aggregate 平行不浪費)·地基KEEP"
---

# ★誠實：12 月長局 specimen 我 launch 疏漏 → 已 re-launch 修

## 根因 = 我的疏漏（非 own_granary crash）
phase3 bed:52 `setup_from_env` 需 `SPECIMEN_SAMPLE_N`/`SPECIMEN_TEAM_ID` env 才 enable tracer。**我第一輪 launch 沒設** → tracer disabled → dump no-op → **specimen.jsonl 缺**。（own_granary Nil error 是**分開 known-issue**、非致命、sim 完成寫了 json。）

## 已修
re-launch **pid 28020** 帶 `SPECIMEN_SAMPLE_N=8`（strided [0,6,...,42] observer-neutral、byte-identical 同世界）→ stdout 已驗 `specimen enabled` → 末端 dump specimen。

## 損失控制
- 既有 **11MB aggregate json 完好**（與 re-run byte-identical）→ **measurer 現平行收割 9 科目、免等**。
- specimen re-run 過夜 → QA 二輪。**aggregate 不浪費**、只 specimen 多一輪過夜（我疏漏成本）。

## own_granary Nil error（分開 known-issue、12mo 復發）
大量 log noise、**非致命**、json 守恆**不污染**（`_pool_census` 逐 tile 直讀不經 own_granary）。已 known_issues **升優先級 = 值防禦 guard**（`if state==null: return null`）修。

## ★流程教訓（記）
長局 launch 前**必確認 SPECIMEN env 有設**（specimen=QA 二輪硬料、漏設=整輪 QA 料沒）、launch 後**驗 stdout「specimen enabled」再放生**。

序：aggregate measurer 現收 → specimen re-run（pid 28020 過夜）完 → QA 二輪 → systems consolidate → 你帶用戶。地基 KEEP。
