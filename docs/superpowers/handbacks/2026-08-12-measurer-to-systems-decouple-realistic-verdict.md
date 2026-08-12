---
from: measurer
to: systems
status: open
topic: "[decouple-suspicion-promotion realistic驗證完成——relief確實解卡(promote.fired 0→4),T12仍未解但根因不同,①野心差異化本輪fixture答不了]feat/decouple-suspicion-promotion 7ee9ec29,同16隊diverse床(15天)重跑,before=前輪officer_need branch的0/0。★決定性:promote.fired 0→4、field_desperate 0→4——T4/T8(先前卡在pmult太低)這次真的解卡,T8身上drain→promote→need降→再drain→再promote完整週期重複3次,每次promote後named穩定回1(bounded非疊加失控)。T0(named=4已足額)officer_need全程=0,bounded control確認不受影響。★T12仍完全零變化——不是decouple沒生效,是T12從未有機會真dispatch drain(獨立根因,decouple只解pmult門檻不解『沒dispatch機會』這個更早瓶頸,同前幾輪已確認)。團數21→24小升(officer補得快、lord能更頻繁care/scout,非明顯runaway)。★誠實限制:現有diverse床4個lord野心值全相同(0.4),無法測①野心差異化(rate高低對照)這題;另跑spare0結構性床(T0野心0.4/T2野心0.9)確認無regression但該床兩隊tick0即刻雙雙fire同樣測不出rate差異——這題手上fixture都答不了,交你判斷是否需要專門新床。"
---

# decouple-suspicion-promotion realistic 驗證完成 —— relief 確實解卡，T12 仍未解（不同根因）

feat/decouple-suspicion-promotion `7ee9ec29`（promote_util 去慎重壓制項）。同 16 隊 diverse 床（15天）重跑，before 基準沿用前輪 officer_need branch 的 `promote.fired/field_desperate=0/0`（同一 fixture、只差這個 commit，不需要重跑 main）。

## ★★★③relief 解卡 —— CONFIRM，行為層真解卡

```
promote.fired:            0 → 4
promote.field_desperate:  0 → 4
```

**T4、T8（先前卡在 pmult 太低，desperate_util≈0.15-0.195<threshold）這次真的解卡了。** T8 身上甚至看到**完整週期重複 3 次**：drain（真 dispatch 耗盡 bench）→ promote（need 降）→ 再 drain → 再 promote……每次 promote 後 `named` 都穩定回到 1，**不會失控疊加**——這同時是③relief 解卡跟④bounded 的雙重證據。

implementer fp 報的「promote.fired 4→5/field_desperate 4→5」跟我這輪的絕對數字不完全一樣（我這輪 15 天床跟他們的環境不同），但**方向一致**——realistic 床確認了行為層真的解卡，不是只有他們自己的 unit test 才 fire。

## ④bounded 反證 —— CONFIRM

T0（`named=4`，已經足額）`officer_need` 全程 15 天 = 0，一次促發都沒有——well-benched 領主不會被誤觸發，bounded 乾淨。

## ★T12 仍完全零變化 —— 但這不是 decouple 沒生效

T12 的 `anon`/`named_size`/`officer_need` 15 天內一個數字都沒動過。**這不代表 decouple 沒生效**——是 T12 從頭到尾**沒有機會真的 dispatch 過**（跟前幾輪已經反覆確認的獨立根因一致：T12 沒有真 dispatch → bench 從未 drain → `officer_need` 卡在標準 proxy 值 0.5，連 desperate 門檻 0.9 都到不了，decouple 修的是 pmult 這個閘、不是「有沒有機會 dispatch」這個更早的瓶頸）。這題不需要 decouple 解——需要另一條線處理「T12 型領主為什麼從來沒有派遣情境」。

## ⑤vs 玩壞

團數 21→24，小幅上升——可能是官員補得快讓領主能更頻繁執行 care/scout 側動作（`care.scout_dispatched` 5 vs 前一輪 3），沒有看到明顯 runaway 跡象（不是每天暴增、也沒有看到 named 爆增或 anon 被榨乾到異常程度）。

## ★誠實限制：①野心差異化這題，我手上的 fixture 都答不了

現有 16 隊 diverse 床的 4 個 lord（T0/T4/T8/T12）**野心值全部相同（0.4）**——這個床從設計之初就不是為了測野心差異化蓋的，沒辦法比較「高野心 vs 中野心 vs 低野心」的 promote 率/rate。

我另外跑了一次既有的 spare0 結構性床（T0 野心 0.4 / T2 野心 0.9 warlord）確認**沒有 regression**（`promote.fired=2/field_desperate=1`，跟 decouple 前完全一致），但那個床的設計是「兩隊 tick0 就結構性 spare=0」，**兩隊幾乎同時 fire**，一樣測不出「rate」差異（要看 rate 差異需要像 T8 那種「反覆 drain-refill 循環」的情境，搭配野心真的不同的領主）。

**這題目前手上的 fixture 都答不了**——如果這個 claim 需要硬坐實，需要一個新床：多個領主、野心明顯不同、都處在會反覆 dispatch-drain 的環境（像 T8 那樣）。是否要加碼建這個新床，考量這個 arc 已經投入相當多輪，交你/blueprint 判斷 ROI。

## Determinism
單 seed 單跑（兩個 fixture 都清楚展示效果方向，效果幅度大到不像是 seed 運氣：0→4 次 promote 的變化）。

## 落地檔案（已 git commit `466912d9`）
- `docs/measurements/2026-08-12-decouple-diverse-seed8181.{json,specimen.jsonl}`
- `docs/measurements/2026-08-12-spare0-structural-DECOUPLE-seed8181.{json,specimen.jsonl}`（regression check）

序：specimen 已附。這輪的核心 claim（T4/T8 解卡、T8 三次完整週期）是逐日 named/need 軌跡的 state 直讀，不涉及候選 util 推論，QA 若要核可選。整體建議：③④已 realistic-confirm，可以推進 consolidate；①野心差異化留待你判斷是否值得再開一輪。
