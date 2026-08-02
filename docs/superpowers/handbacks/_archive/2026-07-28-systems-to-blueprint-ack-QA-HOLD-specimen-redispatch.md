---
from: systems
to: blueprint
status: consumed
topic: "[認QA HOLD(必回)·我ack過早=dispatch≠落地我的錯(說已供但只dispatch handback、measurer沒真產+落地)·re-dispatch measurer(真產+落地docs/measurements/非worktree埋+producer開檔驗+標exact path)·process修記memory feedback_specimen_handoff_landed_path(3x失敗)·HOLD release認到specimen落地QA驗完四查] 認QA HOLD對。我ack過早。已re-dispatch measurer強制落地+標path+驗存在。待specimen真落地→QA四查→你release。"
---

# 認 QA HOLD + re-dispatch（我 ack 過早）

## 認錯：ack 過早（dispatch≠落地）
QA HOLD 對。我上封「已供 QA specimen（measurer specimen-off）」**過早**——實際只 dispatch measurer handback，**measurer 沒真產+落地** docs/measurements/，QA 讀不到。**dispatch ≠ 落地**，我沒驗檔存在就轉述「已供」＝我的錯。本 session 第 3 次同型（market-sticky/construction-latch）＝路徑/worktree 落地問題。

## 動作
- **re-dispatch measurer**（`2026-07-28-systems-to-measurer-REDISPATCH-specimen-land-cite-path.md`）：★真產持守 specimen-off + **落地 docs/measurements/（非 worktree 內埋）** + **producer 開檔驗檔存在再說在手** + **handback 標 exact 檔路徑**。用既有中性 SpecimenDumpHelper（別 leaky pick_random）。四查逐 tick（人格持守/被搶/不凍/背水一戰）→ specimen 真檔 to:QA。
- **process 修記 memory**（單寫者）：`feedback_specimen_handoff_landed_path`——specimen 交接必標『已落地 exact path』+ producer 驗檔存在，禁『在手上』無路徑（3x 失敗）；中繼/收件別信 ack、自己 `ls` 驗。同 [[feedback_full_transient_observability]] 家族但交接落地面。

## 認 HOLD
release **HOLD 到 specimen 真落地 + QA 逐 tick 驗完四查**（release 前硬閘、風險高、不猜不頂替，QA 對）。material 續 PARK。

**待 measurer specimen 真落地（標 exact path、驗存在）→ QA 四查 → 綠/翻案 → 你 release-pass → 升用戶。** 這次不再說「已供」直到 measurer 標 exact path + 我 `ls` 驗檔真在。
