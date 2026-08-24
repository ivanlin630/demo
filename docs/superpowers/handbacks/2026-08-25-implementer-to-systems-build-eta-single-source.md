---
from: implementer
to: systems
status: consumed
slice: build-eta-single-source
branch: feat/build-eta-single-source @ 26b87684 (pushed, base=main a9e96082)
topic: ★交件·estimator-lineage-scan 規則2【已轉綠】(本票存在理由);六處接線全改·分母由 cadence 同源推導禁手抄 24;★24×/10× 從「帳上斷言」變成「測出來的」;det fp 變=intended-change 且三跑穩定
---

# `build-eta-single-source`：交件

**branch**：`feat/build-eta-single-source` @ `26b87684`（已 push；base ＝ merge 後的 main `a9e96082`）

## §1 ★本票的存在理由：`estimator-lineage-scan.sh` **規則2 已轉綠**
```
── 規則2：工期換算單一真相源
  OK 無域外手抄換算
★PASS 估算器血統掃描
```

## §2 單一源
`OutpostSystem.build_eta_days(ticks_left: int, pop: int) -> float`

- **真值只有一處**：`_tick_construction` 的 `ticks_left -= maxi(pop, 1)`（`outpost_system.gd:311`），
  它掛在 `SimRunner.SYSTEMS` 的 `outpost_tick`（`lod = LOD_NEAR`）
  ⇒ **一天執行幾次 ＝ 一天有幾個 near cadence 窗**。
- ★**分母由 cadence 同源推導、禁手抄 24**：`TICKS_PER_DAY / NEAR_CADENCE`。
- ★**假設不靜默**：另有 `_outpost_tick_runs_in_near_pass()` **讀 registry**（不手抄），
  若哪天 `outpost_tick` 不在 near pass 了 ⇒ `Probe.bump("build_eta.cadence_assumption_stale")`。
  **驗收標準「改掛別的 LOD 六處自動跟著改」因此成立，而且失效時看得見。**

## §3 六處接線（窮盡，照你 §3 的表）

| # | 站點 | 舊寫法 | 錯法 |
|---|---|---|---|
| 1 | `goal_resolver` `BUILD_DAYS_EST` | flat `3.0` | 只在 pop≈10 才對 |
| 2 | `decision_context` `settle_eta_days` | `CORVEE_DAYS + dist` | 把「person-ticks 的來源」當成天數 |
| 3 | `persist_strength:95` | `ticks ÷ pop` | ★**高估 24×** |
| 4 | `faction_ai` `_eta_build` | `ticks ÷ pop` | ★**高估 24×** |
| 5 | 求生蓋田閘 | `ticks ÷ pop ÷ 240` | ★**低估 10×** |
| 6 | `decision_context` 擴點成本 | `ticks ÷ 240`（**連 pop 都沒除**） | 差一個量級 |

**窮盡確認**：`grep -rn "BUILD_TICKS|construction_ticks_left" --include=*.gd scripts/simulation/`
剩下的命中全是**讀進度/判有沒有在施工**，**沒有第二個做「換算成天數」的地方**。

## §4 ★24×／10× 從「帳上斷言」變成「測出來的」
TDD 床 `build_eta_single_source_test.gd`（**零手抄物理**：不寫 24、不寫 240）：
判準是**把真值那個扣 person-ticks 的迴圈真的跑一遍**，看 accessor 預測得準不準。

```
gate1  720/pop1  → 預測 30.0000 天 vs 真跑 30.0000     （誤差 < 1 窗）
       720/pop5  →      6.0000        6.0000
      1200/pop8  →      6.2500        6.2500
        72/pop3  →      1.0000        1.0000
      2400/pop12 →      8.3333        8.3333
gate2  每日推進次數 = TICKS_PER_DAY / NEAR_CADENCE = 24.0（由常數推導，沒寫 24）
gate3  outpost_tick 仍在 near pass（假設成立）
gate4  人多→短 / 剩多→長 / 完工→0 / pop=0 夾到 1（同真值那行的 maxi(pop,1)）
gate5  舊兩種寫法一高一低夾住真值 ⇒ ★高估 24.0× / 低估 10.0×
ALL PASS（fail=0）
```

## §5 行為變化（**全部 intended-change，照你 §4 要求列**）

| 站 | 方向 | 為什麼這是修對了 |
|---|---|---|
| #3 持守 | **變寬鬆** | `safe_ratio = runway / eta`，eta 曾被高估 24× ⇒ 分母暴增 ⇒ **提早放手**。現在不再被一個假數字嚇跑 |
| #4 糧橋 | **變寬鬆** | 同上，門檻曾過嚴 |
| #5 求生蓋田閘 | ★**變嚴** | 曾低估 10× ⇒ **放行了餓死前蓋不完的案子**。變嚴＝閘開始做它該做的事 |
| #2 紮根 ETA | 小隊變長／大隊變短 | 舊式等於假設 pop≈10 |
| #1 delay 估 | 隨人力變 | 舊式 flat 3.0 |
| #6 擴點成本 | 歸位 | 舊式差一個量級 |

★**harm 未坐實這條我照你 spec 寫的守住**：C6-#3 的 30/3785 樣本沒抓到受害者
⇒ **修法理由是正確性，不是已證明傷害**，帳上不升格。

## §6 閘

| 閘 | 結果 |
|---|---|
| `estimator-lineage-scan.sh` 規則2 | ★**綠**（本票存在理由）|
| headless | **8 ＝ main baseline，0-new** |
| det×3 | `fp=c1e3f7c5db444fc06c6a826efa77b146` × 3 —— ★**fp 變了 ＝ intended-change**（估值變→決策變，spec §4 明寫），**三跑穩定** |
| 憲法 | **PASS**（sites=74, removed=1）|

★`seam-gate`（HARD）需 QA verdict，我沒跑、**不用 `SEAM_MODE=soft` 繞**。
（spec 標 `tier: probe` / `qa: not-required`，seam-gate 要不要跑請你判。）

## §7 順手收斂的一顆說謊 tap
`food_rescue.gate_check` 的欄位名把 bug 寫死在裡面
（`build_eta_days_ESTIMATE_bug÷240` / `build_eta_days_TRUE÷24` / `passed_with_bug`）——
bug 已消滅，欄位改成 `build_eta_days` / `passed`。
★**留著舊欄名會讓半年後的人以為那個 bug 還在。**

## §8 下一站
照你的排程接 **`camp-construction-duration`**（★**開票就指定兩趟法** ＋ **per-action stall 拆分**）。
★**順序理由已成立**：這張票把 `persist_strength:95` 的 24× 高估修掉了 ⇒
「為什麼棄工」的答案不會再被那個已知錯誤蓋住。
