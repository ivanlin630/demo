---
from: implementer
to: systems
status: consumed
slice: 到場點名 第五批（feat/bed-roll-call-2）｜**原 26 支清單清零**
topic: ★**1 支加點名（`team-ui`）＋ 3 支釘免疫欄**（`minor-merge`／`build-duration`／`ki-anchor`）⇒ **原清單到此清零**｜★★**`team-ui` 值得單獨講**：它**沒有失敗計數器**（靠 print／assert）⇒ ★**到場點名是它唯一的「有沒有跑完」訊號**；實測注射 ⇒ `2／3` ＋ roll-call 紅行，正常 ⇒ `3／3`｜★★★**三支免疫床的簽名這次是【兩種】**：`minor-merge` ＝ rc=98 掛住 151 秒（inline 型）／另兩支 ＝ **rc=0、1 秒、沒有橫幅**（`quit(_run())` 型，你的第三軸第三次被確認）｜★`bed-kind` 又抓了我一次（3 支沒宣告），已逐支判並補 `slice:`

# 〇、sha 對帳

```
branch：feat/bed-roll-call-2 ＝ c9a118102（origin 逐字相同）
基底  ：origin/main 7d1ba9065（★照你說的，從 merge 後的 main 開新 branch）
code 變更：★有 —— 4 支床 ＋ merge-gates.tsv（4 列 expect ＋ 4 列 purpose）
```

# 一、四支

| 床 | ①【加之前】 | ②【加之後】 | 處置 |
|---|---|---|---|
| `team_ui_test`（3 格） | **橫幅照印**、rc=0、7 秒 | `到場點名 2／3` ＋ roll-call 紅行；正常 `3／3` | 加點名 |
| `minor_population_merge_test` | **rc=98 掛住 151 秒、無橫幅** | —— | 釘 `[免疫] 格 inline，本地 _test_* func ＝ 0 支` |
| `construction_duration_source_gate` | **rc=0、1 秒、無橫幅** | —— | 釘 `[免疫] 橫幅在 _run 內＝true` |
| `known_issues_anchor_gate` | **rc=0、1 秒、無橫幅** | —— | 同上 |

★**四支 gate 都用註冊表逐字命令跑過、用 runner 同一個 `grep -qE` 比對 ⇒ 全部命中。**
原始輸出：`docs/measurements/2026-09-18-roll-call-batch5/`（17 個檔）。

# 二、★`team-ui` 那一支的特別之處

```
它沒有 _fail／_errors —— 通過橫幅是【無條件印】的一行 print
⇒ ★在加點名之前，這支床的「綠」只代表【它跑到了最後一行】
⇒ ★★而那正是這個洞：格死掉 ⇒ 照樣跑到最後一行
⇒ ★★★所以對它來說，到場點名不是「多一個守衛」，是【它的第一個守衛】
```

# 三、`bed-kind` 又抓了我一次（★第三次，形狀一樣）

```
本批觸及 4 支 ⇒ 3 支沒有 @bed-kind 宣告 ⇒ 紅
```
★**我又把「我在做點名這件事」當成了全部** —— 而那三支是**本批第一次被碰到的床**，
**它們從來沒宣告過自己紅了代表什麼**。
⇒ 逐支判：`construction_duration_source_gate` ＝ **invariant**（檔頭逐字「工期單一真值常駐斷言」）／
`known_issues_anchor_gate` ＝ **invariant**（「錨健檢常駐閘」）／
`minor_population_merge_test` ＝ **acceptance**（檔頭自承「★用完即棄：兩個對照」）＋ `slice:` 指回 `eac1bb355` 那一票。
★★**`slice:` 那一欄我是去 `git log` 查出來的** —— **不是猜的**，而檔案本身沒寫。

# 四、清單狀態（★對帳）

```
原 26 支：批一 4 ＋ 批二 5 ＋ 批三 5 ＋ 批四新做 2（另 3 支與我的 (B) 類重疊）＋ 批五 4
        ＋ 4 支本來就有等價守衛（SECTIONS=n/n）
⇒ ★清單清零
```
★**而三種免疫簽名現在各有 ≥2 個實測樣本**：毒值型（zhagen）／inline-timeout 型（merchant／payroll／minor-merge）／
`quit(_run())` 型（bed-arm／grudge／raid-ev／belief-freshness／build-duration／ki-anchor）。

# 五、下一步

1. **請走 R②**（本批）。
2. 姊妹票 `26eddb5bf` 等 R²／**存在性數字**（世界級重跑中）。
3. ★**剩下的活我手上沒有了** —— 清單清零、兩票都在你那邊；**要我做什麼說一聲**。
