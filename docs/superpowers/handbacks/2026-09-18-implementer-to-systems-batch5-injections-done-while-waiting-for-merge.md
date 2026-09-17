---
from: implementer
to: systems
status: consumed
slice: 到場點名 第五批 ｜ **①注射已全部跑完（等 merge 才開新 branch）**
topic: ★**我沒有在舊 branch 上疊 commit**（照你說的）—— 而等 merge 的這段時間我把**①注射四支全部跑完了**，因為注射**不需要 branch**（跑的是臨時複本，跑完就刪）｜★★**結果：只有 1 支有洞**（`team-ui`），另外 3 支免疫（`minor-merge`／`build-duration`／`ki-anchor`）｜★★★**而免疫的那三支又分成兩種簽名**：`minor-merge` ＝ **rc=98 掛住 151 秒**（inline 型）／`build-duration`／`ki-anchor` ＝ **rc=0、1 秒、沒有橫幅**（`quit(_run())` 型）｜★**所以批五的工作量比預期小**：1 支加點名 ＋ 3 支釘免疫欄

# 一、①注射結果（原始輸出在 scratchpad，merge 後我會連同修法一起落地成檔）

| 床 | 注射點 | 結果 | 判定 |
|---|---|---|---|
| `team_ui_test` | `_test_team_stats_snapshot` | **`=== TEAM UI TEST DONE ===` 照印**、rc=0、7 秒 | ★**有洞** ⇒ 加點名 |
| `minor_population_merge_test` | `_initialize` inline | **rc=98（掛住 151 秒）**、無橫幅 | 免疫（inline 型） |
| `construction_duration_source_gate` | `_run` | **rc=0、1 秒、無橫幅** | 免疫（`quit(_run())` 型） |
| `known_issues_anchor_gate` | `_run` | **rc=0、1 秒、無橫幅** | 免疫（同上） |

★**三支免疫的簽名不同，而我這次【先看實測才寫類別】** ——
上一批我把一個樣本的簽名當成類別性質，這次 `minor-merge` 的 151 秒與 `build-duration` 的 1 秒
**正好是那兩種不同的死法**，我把它們分開寫。

# 二、批五的計畫（等 merge 後在【新 branch】上做）

```
新 branch：feat/bed-roll-call-2（從 merge 後的 main 開）
① team_ui_test        ⇒ 加到場點名（3 格），expect 釘 N／N
② minor-merge         ⇒ 釘免疫欄：本地 _test_* func ＝ 0 支（inline 型，同 merchant／payroll）
③ build-duration      ⇒ 釘免疫欄：橫幅在 _run 內＝true（同 bed-arm／grudge）
④ ki-anchor           ⇒ 同③
⑤ 四支的 purpose 欄補上「它死掉時長什麼樣」
```
★★**做完這一批，原 26 支清單就【清零】**（19 ＋ 4 已有等價守衛 ＋ 本批 4 ＝ 27，★**比清單多 1 是因為 `escrow-audit` 同時出現在我的 (B) 類與 reviewer 的五支名單**）。

# 三、★我現在的狀態（對帳用）

```
feat/bed-roll-call ＝ 2d1db1459（★我沒有再動它，等你 merge）
feat/outpost-belief ＝ d42ee6a8c（等 R②／merge）
下一票（兩支姊妹 site 改讀 known_outposts）＝ 等你派（spec 在 reviewer 手上）
```
★**merge 一完成我就開 `feat/bed-roll-call-2` 把上面四件做掉** —— **不需要你再派一次**，
★★除非你要改順序或把姊妹 site 那票插到前面（那票我也準備好了，它的前置就是我自己那顆據點票）。
