# HOW spec：床的【種類標記】——分辨常設不變量床 vs 用完即棄的驗收床

owner: systems ｜ 2026-09-08 ｜ player_reachable: no ｜ 狀態：待 R²

## §1 病（今天兩次獨立血證，機械數字在下面）

```
①薪資床 wage_penalty_test.gd  ALL PASS，而【情境根本沒造出來】——
   斷言 `paid_full + underpaid_willful > 0` 被【它本該排除的情形】滿足。
②gather 純度床 gather_observation_purity_bed.gd  在 main 上躺著，
   判準是 fp，而 fp【不涵蓋】那七個被修的欄位 ⇒ 把修法 revert 掉，它印一樣的東西。
⇒ ★★★兩支都【看起來像守衛】。而「床在」與「床會紅」是兩件事。
```

### 普查（2026-09-08，`git ls-files scripts/debug/*.gd`）

| 類別 | 數 | 判準 |
|---|---|---|
| 已接線成 merge 閘 | **14** | 檔名出現在 `merge-gates.tsv` 的 command 欄 |
| ★印得出閘可 match 的判決行、卻沒接線 | **200** | 含 `ALL PASS` / `=== DONE` |
| 有斷言但無彙總行（接不上閘） | 78 | 有 `assert(` 或 `_ok(`，無彙總 |
| 純診斷（正確地不接線） | 79 | 兩者皆無 |
| **合計** | **371** | |

★ 而 `docs/invariants.md` 點名的床 ＝ **0 支**
⇒ **「這支床守的是哪一條不變量」這個問題，目前在 repo 裡沒有任何地方答得出來。**

★★ 驗證過的既有機制（**不重造**）：`bed-arm-whitelist.txt` + `bed_arm_gate.gd`
**有**接線（`merge-gates.tsv:52`），表頭自陳「條目數＝盲區規模、應單向下降」，
而實測 09-01 → 09-07：**273 → 272 → 270**（且減少主要來自刪過期床）。
⇒ 那條線是誠實的、插著電的，**它管的是 arm 順序，不管「這床該不該是閘」**——本 spec 補的是後者。

## §2 為什麼不能「把 200 支全接上」

```
①閘套件會爆（merge 前要跑完的清單長大 ⇒ 沒人跑完整份 ⇒ 回到 CLAUDE.md 已經寫過的那個病）
②★大多數是【用完即棄】：某個 slice 當時的驗收證據，slice merge 之後它的工作就結束了
③★★而有些現在是【紅的】：接上去＝第一天就擋住所有人（gather 那支正是為此被刻意不登記）
⇒ ★★★問題不是「接不接」，是【沒有任何標記能分辨這三種】，於是每次都要有人重新讀一遍 code 才知道。
```

## §3 修法：床自己宣告種類（一行 header），閘檢查【新增/改動】的床有沒有宣告

### §3a 標記格式（床檔第 2 行，緊接 `extends`）

```gdscript
extends SceneTree
# @bed-kind: invariant      ← 常設不變量守衛。★必須在 merge-gates.tsv 有一行
# @bed-kind: acceptance     ← 某 slice 的一次性驗收。★必須註明 slice: <名>
# @bed-kind: diagnostic     ← 純量測/探針，無判決通道。★不得有 ALL PASS 彙總行
# @bed-kind: pending        ← 想成為 invariant 但【現在是紅的】。★必須註明 blocker: <token 或票名>
```

★ 四選一，缺一不可解釋。`pending` 這格是**為 gather 那支床而存在的**：
它的真實狀態不是「忘了接」，是**「它現在會紅，而紅的原因是已知未收口」**——
★★ 而那個狀態**過去沒有名字**，所以只能靠 `defers.tsv` 的一則散文記著。

### §3b 閘（新增一道，加進 `merge-gates.tsv`）

```
bed-kind   檢查【本次 diff 觸及的】scripts/debug/*.gd：
  ①沒有 @bed-kind          ⇒ 紅
  ②kind=invariant 而不在 merge-gates.tsv ⇒ 紅（★宣告是守衛就必須接電）
  ③kind=diagnostic 而含 ALL PASS 彙總行  ⇒ 紅（★有判決通道就不是純診斷）
  ④kind=acceptance 缺 slice: / kind=pending 缺 blocker: ⇒ 紅
★只檢查 diff 觸及的檔 ⇒ 存量 371 支【不用一次補完】（止血優先，on-touch 補齊）
★★而閘每次印一行：已標記 N / 總數 371 —— ★★★不印的話，存量會靜靜地永遠是存量
   （這一條抄 bed-arm-whitelist 的表頭，它那句是對的）
```

### §3c 陽性對照（★本 spec 自己也要有牙）

```
①造一支【故意不標】的床 ⇒ 閘必須紅
②造一支【標 invariant 但不進 tsv】的床 ⇒ 閘必須紅
③★反向：一支【標好且合規】的床 ⇒ 閘必須綠（防恆滿）
④★★而 ①②必須在【本閘寫好之前】先跑一次確認它們現在是綠的
   —— 否則分不出「閘會紅」與「這兩支床本來就紅」
```

## §4 不做什麼（明講，免得被當成漏掉）

```
★不回頭標 371 支存量（on-touch 補）
★★不改任何既有床的判準（那是逐張的活，不是本 spec）
★★★不動 bed-arm-whitelist / bed_arm_gate（不同軸：它管 arm 順序，本 spec 管種類）
```

## §5 驗收

```
閘 bed-kind 進 merge-gates.tsv；四種紅各有一格陽性對照且【先驗過修法前是綠的】
存量計數行印出來（已標記 N / 371）
gather 那支床標成 pending + blocker: gather-purity-bed-as-gate
  ⇒ ★它從「沒人知道為什麼沒接」變成【有名字的已知狀態】
```
