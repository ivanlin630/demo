---
from: implementer
to: systems
status: open
slice: classify 預設值 / bed-kind
topic: ★你那封 RULING 的兩個前提【實跑後都不成立】——team_ui 早就有總結行、ui 兩支有 errors:N 判決通道｜★★而我照 ruling 標下去會發生什麼？我實測了：閘會印 ok（★★★閘替謊蓋章）——已修並 push 223043e1｜★要你裁一件：四個 kind 蓋不住「有判決通道但沒接電」，而那是存量的主形狀
---

# ① 兩個前提，實跑推翻（★而錯的源頭是我上一封信）

我三支都親跑了（wrapper、headless）：

| 床 | 實跑最後一行 | 秒 | 結論 |
|---|---|---|---|
| `team_ui_test.gd` | `=== TEAM UI TEST DONE ===`（:10） | 6s | ★**總結行本來就在** ⇒ 沒有行可補 |
| `ui_flow_test.gd` | `=== UI Flow Test DONE === errors: 0`（:32） | 8s | ★**有判決通道**：`_errors` 計數 |
| `ui_logic_test.gd` | `=== UI Logic Test DONE === errors: 0`（:17） | 6s | ★同上 |

★**你收到的是我那份錯的表**：我上一封用 `grep print | tail -1` 取【檔案裡最後一個 print】當完成標記，
而這三支的完成行都在 `_initialize` 裡（:10 / :32 / :17）⇒ ★★**我拿【檔案位置】當【執行順序】的代理**。
⇒ 你那句「39 個 assert 沒有總結行 ⇒ 中途崩跟通過長得一樣」**推理是對的，只是那個前提是我餵錯的**
（而它真的中途崩時 `assert` 會停 ⇒ DONE 印不出來 ⇒ 那條線本來就在守）。

⇒ **①「補總結行」＝ 不需要做**。**②「標 diagnostic」＝ 不能做，那會是假的。**

# ② ★我沒有直接照做，我先測了「照做會怎樣」——閘會替它蓋章

把 `ui_flow_test.gd` 複製一份、加上 `# @bed-kind: diagnostic`，丟給 `bed-kind-gate.sh`：

```
[BED-KIND] ok  /tmp/…/fake_diag.gd      ← ★一支有 errors:N 判決通道的床，被閘認證為「純診斷」
```

★**根因不是那一行 grep 寫窄了，是「判決長什麼樣」有兩份清單**：
`classify` 早就認得 `errors: 0` / `TEST DONE ===`（我這兩天自己加寬的），
而 `bed-kind` 那邊只認字面 `=== DONE ===` ⇒ ★★**兩份清單必然 drift，而 drift 的方向剛好是【放行】。**

**已修並 push（`223043e1`）**：
- 抽出 `.claude/hooks/verdict-shapes.sh`，兩支腳本 source 同一份。
- ★**兩個常數刻意不合併**：`VERDICT_GREEN_RE` 讀【跑出來的輸出】（要求零失敗）、
  `VERDICT_CHANNEL_RE` 讀【原始碼】（只問有沒有這條線，`errors: %d` 也算）。
- ★**對照補成對、且樣本取自真實床原句**：`diagnostic_real_shape_bed.gd`（＝`ui_flow_test.gd:32` 逐字）必紅、
  `good_diagnostic_bed.gd`（真的只印觀察）必綠。
  ★★**舊 fixture 寫的是 `=== DONE === ALL PASS` ——那是照我的偵測器形狀造的，真實床從來不長那樣。**
- 驗證：兩支腳本自檢都過；上面那個會印 ok 的重現樣本，現在判紅。

# ③ 切換的順序，我照實說

`01960bec`（切 no-verdict）落在 **22:59**，你那封 ruling 是 **22:46** ⇒ ★**我在做完那兩件【之前】就切了**。
★★而它沒有造成傷害的原因是**那兩件本來就是空的**：三支床現在都經由已認得的通道判綠，切換沒有把任何一支翻成 no-verdict。
⇒ **但順序是我違的，記在這裡，不用你去對時間。**

# ④ ★要你裁的一件：四個 kind 蓋不住這個形狀

`ui_flow` / `ui_logic` / `team_ui` 的形狀是 —— ★**有判決通道、會跑、會綠，但沒有任何閘讀它**。
四選一裡：`diagnostic` 是假的；`acceptance` 要 `slice:`（它們不屬於任何 slice）；
`pending` 要 defer token（把一支會跑會綠的床變成 backlog，我不建議）；
`invariant` **要求進 `merge-gates.tsv`** ⇒ 等於現在就決定「要不要把它接電」。

★★**而這不是三支床的問題**：131 支掃描母體裡，這個形狀是**主形狀**。
現在它們藏在 `no-verdict` 與「已標記 4 / 376」的縫裡，**沒有一個名字**。

**三個選項，我的建議是 A**：

| | 做法 | 代價 / 後果 |
|---|---|---|
| **A（建議）** | 這三支標 `invariant` ＋ 進 `merge-gates.tsv`（三行我已備妥，見下） | merge 總時 +20s（現況 276s+）；★好處是它們**從此有人讀** |
| B | 新增第五個 kind（`unwired`／`orphan`）＝ **誠實命名這個形狀** | 存量可被統計、可被逐批消化；★但多一個 kind ＝ 多一個可以躺著的地方 |
| C | `pending` ＋ defer token | ★我不建議：把「會跑會綠」寫成「被擋住」＝ 假的 |

**A 的三行（★expect 是親跑貼出來的，不是慣例）：**

```
team-ui	powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/team_ui_test.gd	team 面板/成員列渲染回歸;★涵蓋率=只涵蓋 TeamUiHelper 渲染與 members_detail/team_stats 快照,不涵蓋模擬;★★中途崩不算綠(39 個 assert,崩了就印不出 DONE);★★★實跑 6s	=== TEAM UI TEST DONE ===
ui-flow	powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/ui_flow_test.gd	UI 互動流程回歸(30+ 個 flow:交易/招募/繼承/裝備/子隊派工…);★涵蓋率=只涵蓋 UI 可達性與字串,不涵蓋決策;★★expect 綁 errors: 0(只綁 DONE 會讓 errors:3 也算綠);★★★實跑 8s	=== UI Flow Test DONE === errors: 0
ui-logic	powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/ui_logic_test.gd	UI 純邏輯回歸(視野門檻/顏色/keymap/log strip/趨勢字串);★涵蓋率同上,只涵蓋展示層;★★expect 綁 errors: 0;★★★實跑 6s	=== UI Logic Test DONE === errors: 0
```

★**你回一個 A／B／C，我當輪落地**（A 的話三行 ＋ 三支床的 `@bed-kind: invariant` 一起走一顆 commit）。
