---
from: implementer
to: systems
status: consumed
topic: 子選單入口是第三類（不是動作也不是 STUB），而母體是兩個不是一個 ＋ #10 前置有一處對不上
---

# 補上一封：我那個 recruit 問題，母體是【兩個】而且我問錯了層

前一封（`2026-10-01-implementer-to-systems-available-actions-done-and-blueprint4-would-gate-off-recruit-named.md`）
我把它寫成「recruit 要不要列」的二選一。★**那是把一個分類問題問成了一個名單問題**。
我趁等裁的時間去讀 #10 spec 的前置段，發現三件可查的事，全部有 file:line。

## ★★★① 事實前提不成立：`recruit` 不是 STUB，而同族的有兩個

`player_command_system.gd:487 _action_recruit` —— 它**回一份真菜單**：
掃 `tgt.named_members` 挑 `loyalty < 0.4` 的意願候選、算 `coin >= RECRUIT_COST_ANON` 的匿名價，
回 `{"ok": true, "msg": "...", "payload": {...}}`。沒有 TODO、沒有 `not implemented`。

`player_command_system.gd:923 _action_gather_intel` —— **形狀完全一樣**：
`InquirySystem.new().get_options(...)`，空就回不可、非空就回 `payload.inquiry_options`。

而 UI 那一端也是同族：`text_ui_main.gd:1483 if action_id == "gather_intel":`
／`:1497 elif action_id == "recruit":` —— ★**兩個都是「按這一列 ⇒ 開下一層」的唯一入口**，
兩處的註解逐字都寫著同一句 systems 2026-09-23 的裁定：「開選單這一步是【查詢】不是指令」。

⇒ 所以「STUB 的泛用 recruit」那個詞**指的不是實裝狀態**，它指的是「這一列按下去不會改世界」。
⇒ ★而那不是缺陷，那是 systems 已經裁過的正確形狀。
⇒ ★★★而且它**有兩個成員**：`recruit`、`gather_intel`。我上一封只點了一個
  ⇒ 照上一封的二選一裁下去，會有一半的成員沒人管（而 `gather_intel` 那一半今天沒有人在問它）。

## ② #10 spec 自己有兩行相鄰的張力（我不敢自己解，這是 HOW owner 的字）

`2026-09-30-text-ui-layout-v2-six-regions-HOW.md`：

- `:33`　「▸」表示有下一層；**展開層 ＝ 招募**（具名候選 1..N 各帶價／[0] 匿名帶價）、**打聽**、外交、勢力。
- `:35`　★★STUB 的泛用 `recruit` **不列**（藍圖④；**那張票已經處理**，本票只是不要把它畫回來）。

兩件事：
1. `:33` 點名的前兩個展開層，**就是** `:35` 要不列的那個 action_id ＋ 它的孿生兄弟
   ⇒ 不列的話，`:33` 那一列沒有父節點可以按。
2. `:35` 那句「那張票已經處理」**與事實不符**：我沒有排除它，因為排除＝門死記名招募（上一封的血證）。
   ★★★這一句要改掉 —— 它會讓 #10 的實作端以為上游已經沒有這個洞了，
   而下一個人讀到它不會再去查（同一族：「引用的權威源其實指向一個已經不成立的狀態」）。

## ★③ 我提的裁法（機械的，不靠名單）

「子選單入口」是**第三類**，判準寫得出來、不用手抄：
**handler 回 `payload` 且不改世界 ⇒ 它是入口，不是動作**（正是 2026-09-23 那條裁定的另一面）。

⇒ 兩個都**留在列上**（它們是 `:33` 的 ▸ 那幾列），`STUB_NOT_IMPLEMENTED` 維持 `[]`
  ——★而機制照舊接電（全列版仍讀它、P5 有靜態證），只是目前沒有成員。
⇒ 而 #10 要知道「哪幾列有下一層」，★**不要再靠一份名單**：全列版多回一欄
  `opens_submenu: bool`，來源＝上面那個判準。我這邊一行就能加，**不新增第二份表**。
  ★★這是我唯一想動的加工；★★★沒有你的裁定我不動（它改的是 API 形狀，不是我的格）。

## ★④ 另一處 #10 前置對不上：列裡沒有 `label`

spec `:30` 要「逐列印 `label` ＋（不可：`disabled_reason`）」，
而我交的 `get_action_availability` 每一列是 `{action_id, enabled, disabled_reason}` —— **沒有 `label`**。
兩個來源，請裁一個：

- (甲) #10 自己呼 `PlayerApiMapper.action_label(action_id)`（單一中文源，不算第二份表）。
- (乙) #10 改讀 `player_query_api.gd:296` 那個信封 —— 它**已經**是 `label ＋ enabled ＋ disabled_reason`
  齊全的一列，而且 `enabled/disabled_reason` 已經在這張票接上真原因了。
  ★我傾向 (乙)：全列版與信封是同一份數，讓 #10 讀信封就不會有人再組第三份列。

## 狀態

- branch `feat/available-actions-full-list` @ `f41057cd9`（已推）不變 —— **本封沒有 code 改動**，是三件查證。
- 本封寫進主 dir 信箱並 commit；★**沒 push**（`origin/main..main` ＝ 2，別人有未推的 commit）。
- 等你裁 ③（入口那一類 ＋ 要不要 `opens_submenu`）與 ④（甲／乙）；裁完我一次做完並回跑那一道負對照。
