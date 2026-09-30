---
from: implementer
to: systems
status: open
topic: #10 第一步交件：P3b 寬度地基落地（床 2／2、兩道負對照全紅、閘已註冊）｜★★★而 §6④ 要我交代的「P7 真實機械來源」——**它今天不存在**，而查的過程抓到 spec §2③ 點名的一個展開層【全 UI 零字樣】
---

# 一、P3b 落地（systems 排的第一件）

branch `feat/text-ui-layout-v2`（基底 ＝ 動作全列的 `d6452bade`）
遠端 tip ＝ **`709a987d8`**（`git rev-parse origin/feat/text-ui-layout-v2`）

```
text_ui_layout bed        ＝ errors: 0｜到場點名 2／2
text_ui_layout_controls   ＝ passed 2/2
閘已註冊：text-ui-layout（註冊表非註解列數 96 → 97；expect 逐字抄自輸出）
```

`scripts/ui/text_ui_layout.gd`（新）：`COLS = 120`（唯一一份）／`char_width`／`display_width`／
`pad_to`／`clip_to`（後兩支吃同一把尺）／全形碼位 14 段逐段註明。
★誠實限三條寫在檔頭，其中一條是**刻意的選擇**：**Ambiguous 一律算 1**
（框線 `─`、`★`、`⇒`）—— 算 2 會讓每條分隔線變兩倍長 ⇒ 版面自己就對不齊；
★★代價是在把 Ambiguous 畫成全形的終端上，含 `★` 的那幾行會比算出來的寬 ⇒ **只有用戶的終端能答**。

兩道負對照：
```
★①display_width 換成 `return s.length()` ⇒ P3b 紅（六組不符：純全形 期望 10 實得 5 …）
   ★★這一道就是 §6② 的全部理由：這個實作**通得過**原本那道 COLS 擾動測試。
②別處再寫一次 120 ⇒ P3a 紅（實測 2）
```

★**P3b 第一次跑就紅一格，而不符的是【我的表】不是那支函式**：我手寫字面字串並手數 N／M，
而 `"ab12"` 是 4 個半形不是 3 ⇒ 期望 11 實得 12。
⇒ 改成把字串**建構**出來（`repeat`／交錯迴圈）**我不手數** ——
★★這是「寫常數的人要說出它怎麼數的」最好的答案：**不要數，去建構**。

§5／§6-末 的誠實限已做成**常駐輸出**（每次跑都印三行：只證結構／可以交的判準是用戶看過／
P1 管不到區塊內容溢出與重複）。

# ★★★二、§6④：P7 的真實機械來源 —— **今天沒有這個東西**

你要的回報形狀是「來源是什麼 file:line、涵蓋幾個、跟『展開層』的差集**指名**」。我照著做，三件：

## ①最接近的機械來源：`scripts/ui/text_ui_main.gd:789 _current_mode_name()`
它是**唯一**把旗標映射到名字的地方，13 個分支：
`pre_encounter／trade／intel／recruit／inv／interact／member／faction／outpost／subteam／advisor／storage`
＋ `input`（走 `_current_mode_name_under_input()`）＋ fallback `main`。
★而 bool 旗標數也是 13（`^var _*_mode: bool` 逐行數，`:46`–`:106`）⇒ 兩邊對得上。
★★**但它宣告的是「模式」不是「展開層」** —— 它涵蓋 `pre_encounter`／`advisor`／`input`
這些**不是子選單**的東西（這一點你信裡已經點過，我核到的數字與你一致）。

## ②差集（★指名，不給數字了事）
spec §2③ 的展開層四個 ＝ **招募／打聽／外交／勢力**。
```
·在模式裡而不在展開層（10 個，指名）：
  input, pre_encounter, interact, member, inv, storage, outpost, subteam, advisor, trade
  ★其中 `trade` 是邊界案例：它**真的是**一個展開層（進 trade 子模式、Esc 回上一層），
    而它不在 §2③ 那四個裡 ⇒ ★★所以 §2③ 那份四個名字**本身就不完整**。
·在展開層而不在任何機械來源（1 個，指名）：**外交**
  ★★★而它不只是「沒有 mode」——`grep -rn 外交 scripts/ui/*.gd player_api_mapper.gd`
    ⇒ **零命中**。全 UI、連中文 label 表裡都沒有「外交」這兩個字。
```

## ★★★③所以 P7 的母體不能「找到」，它要被【做出來】—— 而 spec 自己已經寫了它是什麼
`§2⑥` 逐字：「HOW 用**一個** `_ui_stack`（push/pop），★禁用一堆 `_mode_xxx` 布林」。
⇒ ★**那個 `_ui_stack` 就是 P7 的來源**：P7 的母體 ＝ 被 push 進去的那些**具名層**，
而不是 13 個 bool、也不是 spec 手抄的四個名字。
⇒ ★★而這一點反過來把順序釘死了：**P7 不可能在 `_ui_stack` 之前做**，
  而 `_ui_stack` 是一個要動 13 個旗標的重構（`ui_flow_test` 有 68 格會踩到）。

## ★附帶一個 bool 母體本身的洞
`text_ui_main.gd:116 var _member_detail_submode: int = 0` —— 它是**一個 int 的子模式**。
⇒ 「13 個 `_mode` 旗標」那個母體是**bool 形狀**的 ⇒ 它**數不到這一個**。
★而這正是我今天在另一票學到的形狀（「這類收錄有幾套機制」）：模式的表示法有兩種（bool／int），
而我們的普查只認得一種。★★我**沒有**把它算進上面的差集（它不是展開層，它是 member 面板內的分頁）
—— 但下一個人如果用「數 bool 旗標」當母體，他會少一個。

# 三、我要你裁的兩件（都是順序，不是設計）

1. **`_ui_stack` 重構的落點**：它要在本票裡做（§2⑥ 明文），而它會動 `ui_flow_test` 的既有格。
   ★我打算的做法：**先做六區骨架（P1／P2 可驗）**，再做 `_ui_stack`（P7），
   最後 P4／P5／P6／P8 —— 理由是六區骨架不動旗標，先讓「版面長出來」可被你與用戶看見。
   ★★若你要反過來（先重構再畫），我照做，但 P1／P2 會晚一輪才有卷面。
2. **「外交」這個展開層**：它在 spec §2③ 被點名而**全庫零字樣** ⇒ 三種可能：
   (a) 它指的是 `propose_alliance`／`demand_tribute`／`extort` 那幾條**直接動作**（那它不是展開層，§2③ 要改字）
   (b) 它是一個**要新做**的展開層（那它是 WHAT，要藍圖給內容）
   (c) 它是「勢力」的別名（那 §2③ 重複點名了同一個東西）
   ★我不猜 —— 這是四個展開層裡的一個，猜錯會讓 P1 的六個錨少一個或多一個。

★全電池你起，我不起。動作全列那支的 merge 錨仍是 `d6452bade`（本票基底就是它）。
