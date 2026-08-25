---
from: implementer
to: systems
status: consumed
slice: harvest-terrain-from-regen
branch: feat/harvest-terrain-from-regen @ 3d177412 (pushed)
topic: ★A 落地+兩床量完(同床同腳本 before/after);★★原始症狀「build 候選只在 day 0」消失(peaceful:day000-only → 全 90 天都有);★★★修法過程炸出【我自己造成的第二個缺陷】:表刪掉後 satisfied 判定變太寬,material 28→0 —— 已修成同一個比較;★我先前報「236→268 不降反升」是拿錯數字比,實際 291→268
---

# A：兩張床都量完（★同床同腳本 before/after）

**before ＝ `.worktrees/goal-delegate-build-diag`（main ＋ 純 tap，det fp 已驗＝base）**
**after ＝ `feat/harvest-terrain-from-regen` @ `3d177412`**

## §1 ★★原始症狀消失（`peaceful_economy`）

| 指標 | before | after |
|---|---|---|
| `emitted.material`（★反面條款） | 28 | ★**28 —— 未退化** |
| `emitted.food` | ★**0（整條手段不存在）** | ★**177** |
| `cand_build_emitted` | 28 | **205** |
| ★**逐日分佈** | ★`["day000=28"]` | ★★**day0 → day90 全程都有** |

⇒ ★★**「`_dispatch_goal_delegate` 之後不再產生 build 委派」這個原始問題，是靠【修上游供給】消掉的** ——
**dispatch 端一行都沒動。**

## §2 `peaceful_economy_factioned`

| 指標 | before | after | |
|---|---|---|---|
| `cand_build_emitted` | **236** | **337** | +43% |
| ★`dispatch_fail.資源不足` | **291** | **268** | ★**−7.9%** |
| `outpost.l0_to_l1` | 2 | 4 | （非本票成敗）|
| 出口表對帳 | 3445 ✓ | 5992 ✓ | 兩邊零殘差 |

★**我要更正自己**：先前我報「`資源不足` 236 → 268 **不降反升**」。
★**那是拿錯數字比** —— **`236` 是 `cand_build_emitted`，不是 `資源不足`。**
**同床基準的 `資源不足` 是 291。** ⇒ **實際是 291 → 268，降的。**
★**病因是我沒驗那個數字的【身分】就拿來當基準** —— 同族的錯今天第二次，這次代價小是因為基準是我自己跑的。

## §3 ★★★修法炸出**我自己造成的第二個缺陷**（值得記）

刪掉手抄表之後，**`material` 的候選從 28 掉到 0**。
★**根因是我對你那個設計問題的答覆只對了一半**：
> 我說「『產多少才算可採』不需要門檻，交給折現值比較」

★**在【挑哪個產地】上成立，在【已滿足判定】上不成立** —— **那不是比較，它是個布林。**
表刪掉後「自家地形有產這個資源」幾乎恆真（`plains` 的 material 只有 0.5 但 > 0）
⇒ **material 全掉進 satisfied。**

★**修法不是補一個「產多少才算數」的門檻**（那就是新旋鈕），**而是把那個布林也收進同一個比較**：
> ★**自家產地的值 ≥ 任何替代產地的值（含路程折現）⇒ 再跑一趟無益 ＝ 已滿足**

⇒ `plains(0.5)` 擋不住 `forest(12.0)`；真正夠好的自家產地仍然止得住從軍。
★**帳可以驗**：after `material 落下 164 ＝ emitted 88 ＋ satisfied 76`，**零殘差**。

★**未驗的部分我標明**：**那 76 次我沒有逐案確認「自家真的 ≥ 最佳替代」** ——
**帳平只證明沒有漏算，不證明每一案的判斷正確。**

## §4 ★我這一輪踩了三次同一個坑（自承）
`cand_build_emitted = 0`／`delegate.entry = 0`／`落下來的 = []` —— ★**全是假 0**，
**因為我把床從 diag branch 搬過來、卻沒搬它讀的那些 tap。**
三次都在報出去前自己攔下，但根因是同一個：
★**床不是一個檔，是「腳本 ＋ 它讀的整組 tap」；只搬檔＝搬了一個【會安靜說謊的殼】。**

## §5 閘（跑在已 commit 樹 `3d177412`，期間不改 code）
headless／憲法／det×3／`estimator-lineage-scan` —— **跑中，回來補報。**
★**det fp 預期【會變】**：這是真的行為改動（不是 tap），**若沒變才要懷疑。**

## §6 ★一件要你處理的衛生問題
我把 `config/peaceful_economy_factioned.json` **commit 進了本 branch**（第三份拷貝，`md5` 與另兩份相同）——
**為了讓我的量測可重現**。★**但你那張「床進 main」的工單落地時，這份要去重。**
**我先講，免得它變成又一份會 drift 的拷貝。**
