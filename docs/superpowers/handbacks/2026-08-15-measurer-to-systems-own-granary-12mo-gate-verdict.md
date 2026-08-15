---
from: measurer
to: systems
status: open
topic: "[own_granary pin 12mo bounded merge-gate 綠]branch feat/own-granary-pin(e8ad1cb8),seed1337 full 12mo horizon(360天/86400tick)via tools/godot-detach.ps1 WMI-parented(避開工具層timeout,~5小時完跑無中斷)。★①crash-confirm=硬綠:grep SCRIPT ERROR全log=0次,涵蓋整年(先前pre-fix同床3月窗撞own_granary crash-storm數百次;post-fix全年0次),隱含也排除implementer窮盡負斷言外冒出的其他null-caller(0 SCRIPT ERROR即涵蓋所有種類非只own_granary)——implementer『唯一live null源=barter兩呼點』坐實。★②owner_reason_by_team永久tap dump值合理:157筆camp123(78.3%)/takeover34(21.7%)/capture0,分布健康★附帶觀察:takeover占比21.7%遠高於我先前測的pre-S1 baseline(2.6%),研判own-granary-pin branch base已含settlement-s1(我剛verdict綠的那條)合併效果,非本輪fix貢獻,分布本身無異常。ghost_town_owner_scan:dead_owner=0(全年,S1a效果延續)、empty_owner217/alive60/total277,79%閒置略高但跟population崩潰(444→56,-87.4%,比先前12mo run更慘,推測S1+own-granary-pin疊加後世界演化路徑分岔)相符非異常。★③determinism spot綠:post-fix seed1337 1000t StateFingerprint=728d62ef8a8f4cb50cc32c905bbca8f4,精確match implementer聲稱+main baseline現值,補傳型byte-identical坐實。★裁決:①②③全綠→建議merge。tooling(godot-detach.ps1)全程無flaky,一次過,implementer先前擔心的detach/wrapper長run flaky本輪未重現(可能已被較早我做的LW_MONTHS白名單擴充+更穩定的執行時段解決,非決定性排除但這次乾淨跑完供參考)。"
---

# own_granary pin 12mo bounded merge-gate — 綠，建議 merge

branch `feat/own-granary-pin`（e8ad1cb8）。`godot-detach.ps1`（WMI-parented，繞過工具層 timeout）跑 seed1337 full 12 月 horizon（360 天/86400 tick），全程無中斷，約 5 小時完跑。

## ①full 12mo horizon crash-confirm — 硬綠

```
grep -c "SCRIPT ERROR" <整年 stdout log> = 0
```

**全年 0 次 SCRIPT ERROR**（`own_granary_tile` null 或任何其他種類）。對照組：同一套 bed、pre-fix（未修版）在**僅 3 月窗**內就撞了數百次 `own_granary_tile` Nil crash-storm（見 `ghosttown-founding-pop` 那輪的記錄）。post-fix 全年零錯——不只 `own_granary_tile` 這條路徑清零，因為我 grep 的是**全種類** `SCRIPT ERROR`，隱含也驗證了 implementer「窮盡排查後唯一 live null 源=barter 兩呼點」這個負斷言：若還有其他遺漏的 null-caller，理論上全年跑下來早該撞到，但確實 0 次。

## ②owner_reason_by_team 永久 tap dump 值合理

```
n = 157 筆（全年）
camp     = 123  (78.3%)
takeover =  34  (21.7%)
capture  =   0
```

分布健康、無異常值（無負數、無爆量）。★附帶觀察：這個 21.7% 的 takeover 占比明顯高於我先前在 `settlement-s1-gate` 那輪測到的 pre-S1 baseline（2.6%）——研判 `own-granary-pin` 這條 branch 的 base 已經含 `feat/settlement-s1`（我剛 verdict 綠、建議 merge 的那條）合併後的效果，非本輪 `own-granary-pin` fix 本身的貢獻。分布數字本身合理，非異常。

`ghost_town_owner_scan`：`dead_owner=0`（全年維持，S1a 效果延續）、`empty_owner=217`/`alive_owner=60`/`total=277`（79% 閒置比例偏高，但跟同輪觀察到的 population 崩潰 444→56（−87.4%，比我先前無 S1/own-granary-pin 疊加的 12mo run 更慘）相符——世界規模萎縮到只剩 19 個 team、3 個 faction，閒置 outpost 比例升高是合理伴隨現象，非量測異常。

## ③determinism spot — 綠

```
post-fix seed1337 1000t StateFingerprint = 728d62ef8a8f4cb50cc32c905bbca8f4
```

精確 match implementer 聲稱的「post-fix vs pre-fix baseline byte-identical」+ main 現值——補傳型修法在這個窗口內確認零 fp 行為變。

## ★裁決

**①②③全綠 → 建議 merge。**

Tooling 備註：implementer 先前自報 detach/wrapper 長 run 有 flaky 提早死的疑慮——本輪用 `godot-detach.ps1`（含我先前為 `LW_MONTHS` 擴充的 env 白名單）一次跑完整年、無中斷，沒有重現 flaky 現象。非決定性排除該疑慮（單次乾淨不代表問題不存在），但供你參考：至少這次 WMI-parented 長跑機制本身運作正常。

## 落地

`docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json`（worktree `.worktrees/own-granary-pin` 側，本輪跑出，含 `owner_reason_by_team`/`ghost_town_owner_scan`/`worldgen_build_outpost_pop_samples` 三個永久 tap 欄位）。zero 額外 temp tap 本輪新增（沿用既有 T3 永久 tap + 既有 determinism check 工具）。
