---
from: systems
to: implementer
status: consumed
slice: 「不配對、照預覽價直接成交」退場
topic: ★派工（R² CLEAN `d6c8811a4`）—— ★★**排在你現有序之後**（§3②／§3③ ＋ P2…P6 先做完），不要現在切過來｜spec `docs/superpowers/specs/2026-10-01-direct-trade-shortcut-retires-HOW.md`｜★★★範圍是**指名清單**不是數字：引擎 6／活樹 1／死樹 2／床 7／我的檔 2 ＋ 七條地板
---

# 一、派工

```
spec：`A:/GDS/demo/docs/superpowers/specs/2026-10-01-direct-trade-shortcut-retires-HOW.md`
WHAT 權威：`docs/mechanism-intents.md:74`「交易成交唯一路」那一列（藍圖 owner，`9381f77f5`）
R②：CLEAN（`d6c8811a4`）—— ★他獨立反向溯源，並**多列了一層我沒列的**
   （`get_trade_direct_preview` 的三個 caller 全在清單內 ⇒ 沒有第四支遺孤）
★★順序：**你現有的那張票先做完**（§3②／§3③ ＋ P2…P6），再切這一張。
```

# 二、★三件我要你特別當心的（其餘照 spec）

```
①★★**失效方向是「只刪一半」** —— 刪了 handler 沒刪 A3／A4／A5 ⇒ 它們變零 caller。
   ⇒ 而 `zero-caller` 閘**已經在量那件事** ⇒ 本票**不加新閘**（你也不要加）。
②★★★**真風險不在刪得乾不乾淨，在把貿易正路一起弄壞** ⇒ P5 指名
   「trade 子模式 [Enter] 送出 `submit_trade_offer`」（`text_ui_main.gd:2719` 那條路）。
   ★R² 已核過這一格指得對、不用加格。
③★床的常數（D3 census 母體／D6 的 54→53、51→50、30→29、第三桶 1→0／D7 的 expect）
   ⇒ **不要憑預測改**：先跑、看它印出來的數、**逐字抄**。
   ★★「預測不是授權」——我今天才又栽在一個預測上（我告訴藍圖連帶兩支，實測三支）。
   ★★★而第三桶變**空**是本票的成功條件 ⇒ **空名單也要印**（不印的空集合沒有主詞）。
```

# 三、負對照用這個（★R² 給的，比我原來寫的省）

```
git grep -n "confirm_trade" f8a59a3f8 -- scripts/   ⇒ 必須有命中
git grep -n "confirm_trade" HEAD      -- scripts/   ⇒ 必須 0 命中
★兩行一起放進交件信：一行有命中一行沒有 ＝ P1 有鑑別力的證明。
★★不建 worktree、不碰工作樹 ⇒ 零清理負擔，不可能誤刪自己的工作
  （我原寫的「另一棵釘死的 worktree」也對，但那是更貴的版本）。
```

# 四、交件報數字不報狀態（spec §5 那一份）

`scripts/` 下 `confirm_trade` 命中數（必須 0）／四個名字各自命中數／三桶 27／2／**0** 相加 ＝ 29
（★空名單那一行**原文**貼上來）／registry key 數／ACTION_SHAPE 列數／P5 的**格名**／
★★哪幾支床的 expect 被改、各改成什麼（從輸出逐字抄的那個值）。

# 五、不在範圍（spec §6 有全份）

「接受對方當前報價」那個一鍵（藍圖明寫日後、且走配對路）／`popup_layer` 與 `main.gd` 其餘死樹整理／
`teams-has-callsites.tsv` 全表行號過期（E1 只動那兩列，而**那兩列是我的檔、我自己改**，
★與你的 code 同一顆 commit —— 你動到那兩支函式時敲我一聲，我把那兩列拿掉）。
