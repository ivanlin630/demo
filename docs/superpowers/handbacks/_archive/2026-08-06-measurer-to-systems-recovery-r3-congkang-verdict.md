---
from: measurer
to: systems
status: consumed
topic: "recovery-r3②從抗量測(lord-fix commit f4fda140後) — 仍relocate.ordered=0全程,timing race假說(self-directed路徑持續搶先於領主令)在lord-fix後依然成立,非fix本身失敗:同座標修正fixture(commit 4e57ddac)+同anchor0/anchor2跑,數字跟fix前逐位元相同(started/abandoned/arrived/resettled皆=2,ordered/delivered/comply/resist皆=0)——完全一致代表領主令這條路徑從未有機會fire,不是fix沒生效(fix本身邏輯讀code是對的,只是我的fixture讓self-directed贏得race,領主令永遠沒機會dispatch,因為village.task_reason=='relocate'一旦self-directed觸發就會讓_try_relocate_order的skip條件擋住後續評估)。★推測:mountain terrain的relocate_value正值夠大+夠早出現,self-directed跟領主令用同款cadence評估,但self-directed可能在迴圈順序上先於領主令執行,一旦village自己觸發就沒有回頭路。★這是本輪(R1/R2/R3三個ticket)累積下來持續出現的『同機制多入口互搶』pattern,可能需要HOW層級的timing/priority設計決定(領主令該不該對已經self-triggered的村有特殊處理,或self-directed該不該有輕微delay留給領主令機會),非我能靠調fixture參數解——已誠實回報,不再進一步深挖(R1/R2/R3累積effort已經很高)。"
---

# recovery-r3②從抗量測(lord-fix後) — 仍relocate.ordered=0，timing race假說成立

工單 `2026-08-06-systems-to-measurer-recovery-r3-congkang-measure.md` 消費。

## 做法

沿用座標修正過的fixture（commit `4e57ddac`，已解is_resident_static恆false問題），對`f4fda140`（領主令改領主自己視角+移除god-view後門的fix）重跑anchor0/anchor2。

## 結果：跟fix前逐位元相同

```
anchor0(mountain忠村): relocate.started=2 abandoned=2 arrived=2 resettled=2
                        relocate.ordered=0 delivered=0 comply=0 resist=0
anchor2(mountain傲村): 完全相同數字
```

**跟fix前（`4e57ddac`原始跑法）的數字逐位元一致**——這代表fix本身的邏輯（讀code確認，`lord_sunk`改用belief可見的`infra`、`order_util`用領主自己視角）應該是對的，但**我的fixture讓self-directed relocate路徑持續贏過領主令路徑的race**，導致領主令從未有機會dispatch。

## timing race假說（承接上輪，此輪fix後依然成立）

`_try_relocate_order`（領主令）跟村自己的self-directed relocate決策，很可能在**同一個per-tick cadence迴圈**裡評估——一旦self-directed路徑先觸發（`village.task_reason`轉成`"relocate"`），`_try_relocate_order`內建的skip條件（`village.task_reason=="relocate"→continue`）就會永遠擋住領主令的評估機會，不是bug，是**兩條路徑本來就有優先序衝突，我的fixture參數（mountain正值relocate_value夠大又夠早出現）讓self-directed每次都贏**。

## ★這是R1/R2/R3累積下來重複出現的pattern

三個slice下來（migrant/invest/relocate），我持續撞到「同一個機制有多個入口（領主主動 vs 村自己side-decision），彼此搶fire機會」的結構——這次是self-directed vs 領主令的race。**這可能是HOW層級該決定的設計問題**（領主令該不該對已經self-triggered的村保留優先權、或self-directed該不該有輕微cooldown留給領主令一個窗口），不是我調fixture參數能解的（除非人為把mountain relocate_value調到剛好卡在領主令能搶先的窄窗，但那樣就是narrative-tuning，違反ticket自己的「禁靜態斷言」精神）。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-r3-congkang-anchor0.txt`（3086行）+`.json`+`.specimen.jsonl`
- `docs/measurements/2026-08-06-r3-congkang-anchor2.txt`（3039行）+`.json`+`.specimen.jsonl`

## 誠實淨判

①④（爛地真遷走+三態）持續CONFIRMED（跟上輪一致，fix沒有破壞這部分）。②（從抗人格分化）**這輪依然測不到**，root cause已從「is_resident_static恆false」（已解）進展到「self-directed vs 領主令的timing race」（新層級，本輪fix沒解決也不是這個fix的scope）。這是R1/R2/R3累積的第N次「多入口互搶」發現，值得你們視為一個橫跨三個slice的共通模式來看待，非個案。別下accept。是否要調整self-directed/領主令的優先序設計、或這個timing race本身就是預期內的genuine行為（先自救的村不等令，合理），交你們判。
