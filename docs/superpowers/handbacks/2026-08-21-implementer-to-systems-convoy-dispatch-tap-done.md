---
from: implementer
to: systems
status: open
topic: convoy dispatch chokepoint 常設 tap 小 slice DONE — 全閘綠、fp byte-identical、可 merge
branch: feat/convoy-dispatch-tap
commit: 64380327
---

# 小觀測 slice：convoy dispatch chokepoint 分母（照你 ④裁定）

**留兩個、撤其餘**：
- `convoy.dispatch_attempt`（函式入口）——成功與失敗共用同一入口 ＝ 比例才有意義
- `convoy.drop.inflight_convoy`（④ throttle 那支）——列舉輪實測唯一會燒的一關

**撤掉**：其餘六個 drop tap（兩 config 實測恆 0）＋上游 `convoy.route.*`（列舉已證上游零漏，route==attempt）。
production diff ＝ **6 行**，全部 `if Probe.enabled:` 包住。

## gate（全綠）

| gate | 結果 |
|---|---|
| TDD | **9/9 PASS**（`convoy_dispatch_tap_test.gd`）|
| det ×3 | `165399d135296899928d21bce66565ee` ×3 ＝ **與 main 同 fp（byte-identical）**，如你預期（純 Probe-gated）|
| 憲法 | **PASS sites=74** |
| headless | **0-new**（與 main baseline 逐行同形：3 FAIL + 6 assert + 同組 SCRIPT ERROR）|

TDD 九條：①Probe 關＝零計數（零成本）②已有 in-flight → 回 false + `attempt`/`inflight` 各 +1、連呼可累計
③★**新世界成功那次也記 `attempt`**（坐實它是真分母、不是只計失敗）。

★**過程誠實記一筆**：第一版 TDD 三條紅，我先當作 tap 有問題去診斷——**根因是我測試預期寫錯**
（第一發 Probe-off 呼叫本來就成功派出 convoy，所以第二發被 ④ 擋是正確行為）。
而且那版還有一條**空過**（「被 throttle 擋」實際是別關擋的）。診斷輸出坐實 `call0=true / call1 inflight=1 / call2 inflight=2`
後才改寫測試。**production code 一行未動**。

## 另交付：specimen（長跑硬規則）

列舉輪那支 peaceful 30 天長跑，我補了 specimen trace 送 QA 故事稽核（我下了 behavior 因果宣稱，規則要求附）：

**已落地 exact path**：`A:\GDS\demo\.worktrees\convoy-drop-enum\docs\measurements\convoy-drop-enum-peaceful.specimen.jsonl`
（219 entries / 245,209 bytes；`SPECIMEN_TEAM_ID=5` ＝ 全場唯一會出貨的領主；commit `6d0b5a92`，已 push）
——我開檔驗過存在。要我直接寄 QA 還是你轉，說一聲。

## 待你派

你裁的「**開一票量 RETURN 腿斷**，先答『貨款/剩貨有沒有回到母隊』（守恆問題）」——
我這邊沒有 open 的該票，等你的 dispatch。順帶預告我會怎麼量（免你重寫）：
①`convoy.return` 分母化（同本刀作法：DELIVER 完成 → 歸建 chokepoint 有 attempt/成功兩個數）
②守恆帳：DELIVER 前後對「母隊私產＋vault＋porter 身上」三處做 before/after 差，看貨款/剩貨落點
③porter 掉出 TASK_CONVOY 的那一刻抓 tick + 當時 phase（列舉輪只看到「後來變遊魂」，沒抓到轉換點）
——你要加減請直接改。

## 尚未 revert 的 temp taps
`feat/convoy-drop-enum` @ `6d0b5a92` 上那七站 + route + merchant taps **仍在該 branch**（沒污染 main）。
那支 branch 我當它是**證據 branch 不 merge**；若你要留它的 bed 進 main，說一聲我另開一刀補全閘。
