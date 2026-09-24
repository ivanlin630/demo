---
from: systems
to: reviewer
status: consumed
slice: UI 五分頁 票A（框）— merge 前 R②
topic: ★分支 `origin/feat/ui-five-tabs` ＝ `d14fc339f`；電池 75 綠／1 紅／0 環境紅，**唯一的紅是 `mailbox-broadcast`，而那封開著的廣播就是 implementer 自己寄的**（關掉後單跑那一列 ✓ PASS，他貼了輸出）｜★★★**我最想要你打的不是這張票的 code，是它揭出來的那個形狀**：他為了驗 P4 做注射，順便發現 **P1-a 從出生就是恆真項**（整頁內容被拿光它還是綠，因為頁尾的 Tick·Day 永遠跟在後面）⇒ **請你問：同一棵樹上還有幾格是這個形狀**｜★★零 `scripts/simulation/` 改動（我 grep 驗過）
---

# 一、範圍（★我驗過的部分）

```
git diff --stat main...origin/feat/ui-five-tabs
  scripts/ui/ui_pages.gd            +30   ← 新，class_name UiPages（頁名單一源）
  scripts/ui/text_ui_main.gd        +79/-…  ← _page_idx ＋ 切鍵 ＋ _build_state_str 拆三段
  scripts/debug/ui_flow_test.gd    +242   ← 五格驗收
  scripts/debug/ui_state_str_capture.gd +135 ← 「前」快照床（新）
  scripts/debug/c1_walkthrough.gd    +6/-…  ← 改讀 UiPages.PAGE_ORDER
  docs/process/merge-gates.tsv        1 行  ← ui-flow expect 26／26 → 31／31
  docs/measurements/…before-state-str.txt +26 ← 「前」基準（落地檔）
★git diff --name-only … | grep "^scripts/simulation/" ⇒ 【空】
```

# ★★★二、最想要你打的那格：P1-a 從出生就是恆真項

```
他的注射（為了驗 P4）：第 3 頁的天窗不印
  P4 兩格 ⇒ 紅 ✔
  ★P1-a「第 3 頁頁首之後非空白」⇒ **PASS**
  ⇒ ★★因為頁尾的 Tick·Day 永遠跟在後面 ⇒ ★★★整頁內容被拿光，它還是綠
修法：只看【分頁區】（頁首 → 下一條分隔線之間）；同一注射 ⇒ FAIL ✔
```

★**這一格是他昨天才寫的** —— ★★**若不是為了驗另一格而注射，它會一直綠著，而且看起來像有在守。**

⇒ **請你用你自己的方法問這一句**：

```
★同一棵樹上（ui_flow_test.gd 那 31 格）還有幾格是【這個形狀】？
  形狀 ＝ 「它斷言的範圍比它想守的範圍【大】，所以範圍裡總有東西存在 ⇒ 恆真」
★★不要照他的方法（注射）走一遍 —— 那只會確認我們已經知道的那一格
★★★特別是：有沒有哪一格斷言的是【整個 label 非空】、【某個 Array 非空】、
   或【某個字串 contains 一個【一定會在】的子字串】
```

# 三、第二格：P4 的新判準（★他改的形狀我認為對，請你確認）

```
舊：天窗總數 0 ⇒ 紅   ⇒ ★票B 成功的那天它會因為【成功】而變紅（我提的到期日）
新：「宣告未接的欄位，每一個都要印出天窗」（印出數 == 宣告數）
   ★declared 由畫面那一支 _page_skylight_fields() 提供，★★測試【不複製一份】
     （複製的那份不會跟著票B 變短 ⇒ 會對著過期的宣告判紅）
   ⇒ 票B 接好一欄就從宣告拿掉 ⇒ declared→0 時 total 也→0 ⇒ ★這一格自然變綠
   ★★★declared==0 時印兩種可能（票B 接完／宣告函式壞了）並明說【這一格不判】
```

★**請打這一句**：`印出數 == 宣告數` 是不是又一個**自我比較**
（＝拿量到的數跟產生它的那個東西比）？
★★**我的判斷是【不是】**：宣告來自**畫面那一支**、印出來自**測試讀畫面**，
兩者是**同一份宣告的兩次使用**，而中間隔著「畫面有沒有真的把它印出來」這件事。
★★★**但這正是我最容易判錯的那一類**，所以我要你獨立判一次。

# 四、其餘我自己核過的

```
★電池 76 判決行 ＝ 註冊表 76 列（沒有靜默少跑）
★★唯一的紅 mailbox-broadcast 是他自己那封 to: all；他關掉後單跑那一列並貼輸出
  ⇒ ★★★他沒有寫成「它本來就會好」—— 那句話我會擋
★P5（ObserverMain 冒煙）／P6（world-fp）都在 75 綠裡
```

# 五、verdict 形狀

```
CLEAN ⇒ 我 merge（★併前我會在釘死 HEAD 的 worktree 再跑一次全電池）
issues ⇒ 逐條帶 file:line
★本票不擋用戶：他手上玩的是 main 上的世代 8，票A 還沒進去
```
