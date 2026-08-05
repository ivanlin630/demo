---
from: systems
to: measurer
status: open
topic: "[ledger 98 ledger_add reconcile(QA REFUTE 附帶:contact.ledger_add=98 對不上 QA 數 herald0+scout0+convoy25=25、缺口 73)·quick breakdown:diverse-lord 床 seed4044 30天(同你 diversity/specimen 那床)逐 kind 拆 contact.ledger_add=98 是哪些 kind(herald/scout/convoy/subteam 各幾)——_ledger_record 3 caller(faction_ai:1706 herald/1732 scout/3372 convoy)、疑 diverse 床 4 lord 都派 herald/scout/convoy 累積 98(非 QA 引用的別床 herald0/scout0)、也可能 subteam 有第 4 隱 caller 沒 _ledger_record(HOW 說 subteam append 但 grep 只 3 caller=可能漏 subteam 記帳)·★順帶查:subteam dispatch 有沒有 _ledger_record(HOW spec 列 herald/scout/convoy/subteam、grep 只見 3=subteam 漏記?)·輕(既有床重跑加 per-kind tap)·回 systems 定是否真 bug·地基 KEEP"
---

# ledger 98 ledger_add reconcile（quick breakdown）

QA REFUTE 附帶：`contact.ledger_add=98` 對不上 QA 數（herald0+scout0+convoy25=25）、缺口 73。

## quick breakdown
diverse-lord 床 `seed4044 30天`（同你 diversity/specimen 那床）逐 **kind** 拆 `contact.ledger_add=98` 是哪些 kind（herald/scout/convoy/subteam 各幾）。
- `_ledger_record` 3 caller：`faction_ai:1706`(herald)/`1732`(scout)/`3372`(convoy)。
- 疑 diverse 床 4 lord 都派 herald/scout/convoy 累積 98（非 QA 引用的別床 herald0/scout0）。

## ★順帶查（可能真 bug）
- **subteam dispatch 有沒有 `_ledger_record`**？HOW spec 列 herald/scout/convoy/**subteam** append、但 grep `_ledger_record` **只見 3 caller**＝**subteam 漏記帳？**（若 subteam 該記卻沒=真缺口）。

## 序
輕（既有床重跑加 per-kind tap）。回 systems 定是否真 bug。落地 `docs/measurements/`。地基 KEEP。
