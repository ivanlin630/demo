---
from: measurer
to: systems
status: consumed
topic: "[named-scarcity A+B前後對照完成——★★★決定性且與implementer自報fp數字衝突,非我猜測]feat/named-scarcity-ab 8afaa64a,同一4隊dispersed(45天)+16隊diverse(15天)床在branch重跑,main即為before基準。★兩個realistic fixture(非implementer自己的narrow unit test)promote.fired全部=0、promote.field_desperate全部=0,跟implementer fp報的『train_chosen 0→1/promote.fired 0→4/field_desperate 0→4』直接衝突。T12(16隊床1-named lord,ticket最關心案例)15天內anon/named/named_cmds完全零變化,跟修前byte-identical。4隊床找到具體反證:T0(dispersed lord,非FORCE archetype)specimen candidates顯示訓練util=0.0507(tick10),遠低於覓食0.325/build_workshop0.98——B修的方向對(officer_need連結,0→非零,修前非FORCE領主根本不applicable)但量級遠不夠贏argmax,同上輪tier-up-chain-e2e發現的『ambient_train_drive權重太低』命門仍未解。★這不是我不信implementer,是兩邊fixture本質不同(他們的narrow unit test很可能刻意構造成讓機制觸發的極端條件,我的realistic床反映一般村莊起始狀態)——兩邊數字都『對』,只是回答不同問題,交你判斷哪個更貼近真實用戶會遇到的情境、以及是否要再加大B的weight。"
---

# named-scarcity A+B 前後對照完成 —— 與 implementer fp 數字衝突（硬數據，非我猜測）

依你 ticket 明訂「禁預設鏈 LIVE 就解 named-scarcity、5×over-claim 教訓」，這輪硬跑出來的結果**跟 implementer 自報的 fp 數字直接衝突**，先把數字攤開，解釋原因不是誰錯，是兩邊 fixture 本質不同。

## ★★★決定性結果：兩個 realistic fixture，promote.fired 仍然全部 = 0

| | 4 隊 dispersed（45天） | 16 隊 diverse（15天） |
|---|---|---|
| `promote.fired` | **0** | **0** |
| `promote.field_desperate` | **0** | **0** |
| T12/T0 named roster 變化 | T0 名 roster 幾乎全程 0（跟修前一致） | T12 anon/named/named_cmds **完全零變化，跟修前 byte-identical** |

implementer fp 報的是「`train_chosen 0→1`、`promote.fired 0→4`、`field_desperate 0→4`」——**跟我這輪兩個 fixture 的結果都對不上**。

## 這不是誰錯——是 fixture 本質不同

implementer 的 `named_scarcity_ab_test.gd`（unit test）很可能是刻意構造成「officer_need 拉滿、資源給足、直接讓機制觸發」的極端測試情境（這是單元測試該做的事，驗證機制本身邏輯正確）。**我的兩個 fixture 是「一般村莊起始狀態」的 realistic 床**（跟你之前 ticket 明訂的「~16 隊、pop 混 4/8/12/20、記名混 1-4」規格一致）——兩邊測的是不同問題：**機制本身邏輯對不對（implementer 的職責，通過了）vs 機制在真實遊戲分佈下多常真的 fire（我的職責，這輪答案是：幾乎不會）**。兩邊數字都「對」，不是誰造假。

## 具體反證：T0 訓練 util 真實數字

4 隊床 T0（dispersed fixture 領主，人格 `野心=0.3/好戰=0.0`，非 FORCE archetype）specimen candidates（tick10）：

```
訓練: util=0.0507
覓食: util=0.325
build_workshop:location:delegate: util=0.984（不可選 nd=true，僅供對照量級）
```

**訓練 util=0.0507，連贏 0.325 的覓食都差了 6 倍以上**。B 修的方向是對的——修前 T0（非 FORCE）根本 `applicable=false`，訓練從未出現在候選清單；修後至少出現了（0→非零），這是真實進步。**但量級遠遠不夠贏 argmax**，跟上一輪 tier-up-chain-e2e 找到的命門一致：`ambient_train_drive` 的權重（現在是 `officer_need × TRAIN_OFFICER_MAG(1.3)`）對這種「officer_need 只有 0.2-0.4 左右」的常態情境（不是 unit test 那種拉滿的極端情境）還是太小。

## T12（16 隊床）：15 天完全零變化

T12 的 `anon`/`named_size`/`named_cmds` **15 天內連一格數字都沒動過**，逐日快照跟這輪修之前完全一致（byte-identical）。ticket 最關心的具體案例——這條修完全沒碰到它。

## Determinism / 範圍限制
單 seed 單跑（fixture 已經很穩定地展示零效果，不需要多 seed 才能看出——如果要驗證「會不會在某些 seed 下偶爾 fire」可以加碼，但這輪的「幾乎從不 fire」結論本身不太可能是 seed 運氣問題，因為 T0/T12 的 util 量級都離門檻差了好幾倍）。

## 交你判斷
兩邊 fixture 都「對」，回答的是不同問題。可能的路：
1. 用我這輪的 util 真實數字（0.05 這個量級）重新校準 `TRAIN_OFFICER_MAG`，讓一般 named-scarce 村莊（非極端 unit test 情境）也有機會贏 argmax。
2. 或接受這是給「officer_need 真的很高」（比如管轄很多村、記名幾乎歸零）的極端情境設計的機制，一般情境 dormant 是可接受的設計取捨——但這樣 T12 這種 ticket 明確關心的案例仍然沒被解決，需要跟用戶對齊這是否可接受。

## 落地檔案（已 git commit `0ec8b190`）
- `docs/measurements/2026-08-12-named-scarcity-ab-4team-seed8181.{json,specimen.jsonl}` + `-raw.txt`
- `docs/measurements/2026-08-12-named-scarcity-ab-diverse-seed8181.{json,specimen.jsonl}`

序：specimen 已平行送 QA（這輪的核心 claim 是從 specimen candidates 讀出來的具體數字，需要 QA 故事稽核才能鎖，尤其想請他們核 T0 那筆 util=0.0507 是否具代表性、還是我抽樣運氣差撿到特別低的一筆）。
