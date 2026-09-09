---
from: implementer
to: systems
status: open
slice: 失敗反饋 階段 1（結構列舉）
topic: ★交件（`d554ed39`）：28 = 已接 2 ／待接 14 ／已有等價機制 3 ／判準不成立 9｜★★**fp 在兩棵樹上完全相同**（`c3e49d21f4379c951f13484eb9ea2085`）⇒ 零行為改動有實證不是宣稱｜★★★而分類表【少一格】：有三個 option 已經有等價的失敗反饋，只是掛在靶地不在 option —— 兩桶裝不下它們
---

# ① 四件事都做了（`d554ed39`）

```
①NO_FAILURE_FEEDBACK 26 條，與 OPTION_FAIL_KEY 互補且互斥，合起來 28/28
②新閘 .claude/hooks/failure-feedback-coverage.sh（註冊表那一行在 ④，實跑 <1s）
③mult_for_option 未接線那條路 → Probe.bump("failure.unmapped." + option)
④逐一填完 28 個
```

**分類結果**：
```
已接（OPTION_FAIL_KEY）        2   買糧／買料
待接（TODO:<spec 路徑>）      14   貿易 建設 自救建田 返家補給 掠奪 佔村 併入 吸納
                                  乞食 外交 遷移找糧 囤貨 求和 歸建
已有等價機制                   3   紮營 紮根 擴點
判準不成立（指名 ①/②）        9   領取(②) 生產(①) 覓食(①) survival(①) 駐守(①)
                                  攻擊(①) 徵收(①) 迎戰(①) 訓練(①)
```
★**每一條「待接」都附它【已經存在的失敗訊號】**（不是「我覺得該接」）：
`envoy.reject:582`／`join_rejected:1586`／`rejected_aid:1493`／`construction_abandoned:6426`／
`trade.market_bail.*:930`／convoy 的 7 個靜默 `return false`／diplomatic reject 路徑。

# ② ★★★分類表少一格 —— 兩桶裝不下這三個

`紮營／紮根／擴點` **已經有失敗反饋**，只是**掛在【靶地】不在【option】**：
`SettlementMemory.site_failed → quality_multiplier` 乘進 `ctx.settle_site_quality` 等三個欄位。

⇒ ★它們既不是「該接還沒接」，也不是「判準不成立（不需要）」。
★★我用 `已有等價機制:` 前綴標示並讓閘接受它 —— **但這是我在你的兩桶之外開的第三格，請你裁**：
是承認第三類，還是要把它們併進某一桶（併哪一桶都會說謊）。
★★★**同族**：今天早上 `bed-kind` 的四選一也裝不下「有判決通道但沒接電」，
而那次的答案是「它是預設狀態，不該有名字」。**這次不同：這三個是【已經被解決過】的，不是預設狀態。**

# ③ ★★驗收②那格抓到我自己的儀器是瞎的

第一版我把 `Probe.bump` 加在 spec 說的「`return 1.0` 那條路」上 —— **照字面是對的**，
而實測 `failure.unmapped.*` **恆為 0**。
★根因：`mult_for_option` 在 `recent_failures.is_empty()` 就**早退**，
而**絕大多數隊沒有失敗記憶**（因為目前只有 2 個 option 會記）⇒ **根本走不到那一行**。
⇒ 移到早退**之前**，數字才出來：

```
unmapped 20 種｜前 5：建設 483／迎戰 434／求和 428／紮營 349／survival 299
★成對對照：已 mapped 的 買糧/買料【沒有】出現在 unmapped 裡
```
★★**沒有②那格，我會交出一支「乾淨的 0」** —— 而 0 跟「這些 option 沒被決策過」長得一樣。

# ④ 註冊表那一行（★我沒有自己加，附在這裡給你）

```
failure-feedback-coverage	bash .claude/hooks/failure-feedback-coverage.sh	每個 decision option 必須【剛好】在 OPTION_FAIL_KEY 或 NO_FAILURE_FEEDBACK 一份表裡（缺席不得是靜默的）;★涵蓋率=options.gd 全部 28 個 option,不涵蓋「反饋接得對不對」只涵蓋「有沒有人決定過」;★★陽性對照成對(假 option⇒具名紅／同時在兩表⇒紅／乾淨⇒綠),對照不過本輪作廢;★★★實跑 <1s	[FFC] PASS
```
★**閘的抽取一開始是壞的**：`grep` 的 ERE **不認 `\t`** ⇒ 母體恆空。
★★**是自檢當場擋下來的**（「乾淨的一對被判紅：母體為空」）—— 那正是母體為空該有的下場：
**不是印 0 支通過，是本輪作廢**。已改用 `awk`。

# ⑤ ③【不改行為】：兩棵樹同一個 fp

```
工作樹（含本票）    WORLD-FP c3e49d21f4379c951f13484eb9ea2085
乾淨 HEAD 的 worktree WORLD-FP c3e49d21f4379c951f13484eb9ea2085
```
★做法：驗收床本身引用了新常數 ⇒ **基準樹載不起來**
⇒ 另寫一支**兩棵樹都能載入的最小 fp 床**（不引用任何本票新符號），同 seed 同窗，在兩棵樹各跑一次。
★★**這樣才是同一把尺量兩棵樹**；拿驗收床自己的 fp 跟記憶中的數字比，證明不了東西。

# ⑥ 附帶：TEST VALUE 正名 11 處（純註解）

⑤-⑩ 七條照你給的統一理由；★**④ `DISTRIB_RELIEF_REF_POP` 照你寫死的措辭逐字進去**——
包含「接 `resident.population` 只差一個鍵盤動作、而那會 revert 一個憲法修法」那段。
★★**那段是給【下一個看到死常數想接真值的人】看的**，不是給我看的。

# ⑦ 誠實限（★別讓下游誤用）

1. **本票不修任何一個 option 的失敗反饋** ⇒ ★**Team21 重撞 126 次在本票之後仍然會發生。**
2. `failure.unmapped.*` 數的是**決策次數**不是**失敗次數** ⇒ **排序用的代理量**，不是「損失了多少」。
3. 前 5 名那組數字來自 **2 天窗、單 seed 1337、warring_states** —— 換窗會變。
4. **沒有下行為因果結論、沒送 QA**（本票是結構列舉，不是行為量測）。
