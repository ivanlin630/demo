---
from: implementer
to: systems
status: consumed
topic: convoy dispatch-drop 結構列舉 DONE（evidence-only）— 七關只有④在燒、上游零漏、★另抓到 RETURN 腿斷
branch: feat/convoy-drop-enum
commit: e6f00720
---

# convoy dispatch-drop 結構列舉（evidence-only、禁 fix 遵守）

七個靜默 `return false` 各具名 tap + `convoy.dispatch_attempt` + 上游一層 `convoy.route.delegate_entered[.solo].<kind>`
＋ ⑤ 附 sample（team/res/want/私產/vault）＋ 順手 `merchant.target_attempt` / `merchant.drop.no_known_market`。
全 Probe-gated、零行為零 RNG，標 `TEMP TAP` 待 revert。**沒有補任何守衛、沒有放寬任何條件。**

## ①七站分佈

**peaceful_economy / seed 1337 / 30 天（完整跑完）**

| 站 | 次數 | 佔 attempt |
|---|---|---|
| `convoy.dispatch_attempt` | **10** | — |
| 0_dispatched（真派出） | 1 | 10.0% |
| ①no_target | 0 | 0% |
| ②parent_pop | 0 | 0% |
| ③cargo_empty | 0 | 0% |
| ★④inflight_convoy | **9** | **90.0%** |
| ⑤load<1.0 | **0** | 0% |
| ⑥no_advisor | 0 | 0% |
| ⑦subteam_fail | 0 | 0% |

**warring_states / seed 1337 / 25 天（★partial：跑到 GODOT_TIMEOUT 被砍，數字取 day25 sidecar，照實標）**

| 站 | 次數 | 佔 attempt |
|---|---|---|
| `convoy.dispatch_attempt` | **58** | — |
| 0_dispatched | **51** | 87.9% |
| ④inflight_convoy | 7 | 12.1% |
| 其餘六站 | 0 | 0% |

★**六站（①②③⑤⑥⑦）在兩個 config 都是 0**。你要分辨的那個問題有答案了：
**不是「世界真的沒貨」（⑤=0）**，也不是母隊太小/沒人帶隊/子隊生成失敗（②⑥⑦=0）。
**唯一會燒的是 ④「一隊同時只一 convoy」的 throttle**——而且它在 peaceful 燒 90%、warring 只燒 12%。

## ②★★上游對照（你要的那個更前面的問題）

**沒有上游斷點。** 兩個 config 都對得死緊：

- peaceful：`opt_chosen.deliver_material 10` → `route.delegate_entered.deliver 10` → `dispatch_attempt 10`
- warring：`delegate_entered.deliver 24` ＋ `delegate_entered_solo.deliver 34` ＝ **58** ＝ `dispatch_attempt 58`
  （★注意 solo 路徑貢獻 34＝多數，你原本的 10 次是只看 `opt_chosen` 的下界）

∴ **「選中 → 呼叫 `_dispatch_convoy`」之間零漏，不必再往上列舉一層。**

## ③★時間線（peaceful，這才是真故事）

| day | attempt | dispatched | ④blocked | 現場 |
|---|---|---|---|---|
| 5 | 0 | 0 | 0 | — |
| 10 | 1 | 1 | 0 | porter=12（parent=5）**OUTBOUND**、cargo=material 64、pop=1 |
| 15 | **10** | 1 | **9** | `convoy.deliver_settled=1`（貨已送到） |
| 20 | 10 | 1 | 9 | porter 12 已**不是** TASK_CONVOY，task=**貿易** |
| 25 | 10 | 1 | 9 | porter 12 task=**逃跑** |
| 30 | 10 | 1 | 9 | porter 12 task=**外交**、`convoy.return` **= 0** |

**兩個獨立現象，別混為一談：**

**(a) ④ throttle 只在「那一趟在飛」的 day10–15 窗內擋掉 9 次**——它是真 binding，但**只在那個窗**。

**(b) ★day15 之後 `attempt` 完全凍在 10**：throttle 早就放開了（porter 不在 TASK_CONVOY 了），
但**領主再也沒選過 deliver**（`opt_chosen.deliver_material` 也凍在 10）。
∴ 你 90 天只看到 1 次派出，**不是 90 天都被 throttle 擋著**，而是「一趟賣完就再也不想賣了」。
這個「為什麼不再選」在**選項生成/秤價那一層**，本票的 tap 看不到（我沒擴大 scope 去追）。

## ④★意外撿到：RETURN 腿斷（peaceful）

`convoy.deliver=1 / deliver_settled=1`，但 **`convoy.return=0`**，而 porter 12 **沒回家也沒解散**——
它掉出 TASK_CONVOY 之後變成一支 **pop=1 的遊魂子隊**，逐段漂成 貿易 → 逃跑 → 外交（tags 只剩「子團」）。
warring 那邊 `return=23 / dispatch=51`，所以回程**有時**會走完。

我的判讀（**未經第二輪坐實、標為假說**）：DELIVER 完成後把 porter 交還一般決策，
沒有「回家/歸建」的收尾 → 貨款/剩貨是否真的回到母隊，本票沒量。
這條看起來比 ④ 更像「手不聽腦」的真身：**派得出去、回不來**。要不要開一票量它由你裁。

## ⑤ seek_market 側（順手、未擴大）

- peaceful：`merchant.target_attempt=28`、`g1.seek_market=0`、`merchant.drop.no_known_market=0`
  → 28 次進來但兩邊都沒 bump ＝ 全走 arb 分支或 archetype 不符（本票未再細分）
- warring：`target_attempt=698`、`g1.arb_attempt=490`、`g1.seek_market=208`（490+208=698，帳平）

## 交付

- branch `feat/convoy-drop-enum` @ `e6f00720`（已 push，基於 origin/main b022f56b）
- **TEMP TAP 未 revert**：你讀完數字要我 revert 我就 revert；或你要留成常設 tap（我建議至少 ④ 與 `dispatch_attempt` 留著，
  「全量暫態可觀測性」不變量本來就要求 dispatch 這種 chokepoint 有分母）——一句話我照辦。
- **未跑**憲法/det/headless：本票 evidence-only、code 只加 Probe-gated tap，不打算 merge 進 main；
  若你要 merge 我再補全閘。
- bed：`scripts/debug/convoy_drop_enum_bed.gd`（env：`LW_CONFIG` / `LW_MONTHS` / `PERF_SEED` / `PERF_OUT`）
  ——每 5 日印七站分佈 + 上游對照 + in-flight convoy 持有者 + 子隊下場。

★注意 warring 那段是 25/30 天的 partial（timeout 砍）。要完整 30 天我可以重跑一輪。
