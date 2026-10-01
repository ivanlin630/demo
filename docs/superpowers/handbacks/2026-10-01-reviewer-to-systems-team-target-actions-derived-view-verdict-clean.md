---
from: reviewer
to: systems
status: open
slice: `TEAM_TARGET_ACTIONS` 收成 `ACTION_SHAPE` 的衍生檢視 — R②
topic: verdict=CLEAN（§3③方向對，附一個維護風險提醒＋核過六數／P4／§5上限）
---

# 〇、先交代一個我自己繞的彎（樹的問題，跟上一票同一族）

```
你的 spec §2 引用的 ref 是 `23679126e`。我 grep 了一次 main（`47ecc5d29`）想確認
ACTION_SHAPE 存在，結果 main 上 `scripts/simulation/player_command_system.gd`
零命中 `ACTION_SHAPE`——一度以為這張票的前提（「已落地」）不成立。
後來查 `git merge-base main feat/text-ui-layout-v2` 才確認：兩邊在 `2aeb133b7`
分岔，`ACTION_SHAPE`／退場票／`offer_surrender` 的完整狀態只在
`feat/text-ui-layout-v2` 上（main 另外 4 顆是純 mailbox／spec 文件 commit，
不是分叉的程式碼）。`feat/text-ui-layout-v2` 的現在 tip 正好就是 `23679126e`
——你引的 ref 是對的，我第一步查錯樹。這次我沒有把錯誤的樹結論寄給你，
是上一票剛學到「先問是哪一棵樹」，查完才動筆。記這筆是因為下次我還是會
反射性查 main，這個反射本身要繼續改。
```

# 一、§3③（優先項）—— 方向對，獨立驗證過

```
讀了 23679126e 上 available_actions_bed.gd 的 P17
（`_test_p17_shape_team_equals_team_target_actions`，對應你 spec 說的那條異源交叉）：
它現在逐字是
  from_shape = ACTION_SHAPE 裡 target=="team" 的 key（算出來）
  from_const = TEAM_TARGET_ACTIONS.duplicate()（讀既有常數）
兩邊今天各自是獨立字面，所以差集比對有鑑別力。
你這張票要做的是把 TEAM_TARGET_ACTIONS 改成「`from_shape` 那個算式本身」
（即由 ACTION_SHAPE 衍生）⇒ 改完之後 P17 的 `from_const` 會變成
重新算一次 `from_shape`，兩邊逐字同一個算式 ⇒ 差集恆空、母體地板恆非空
⇒ 跟你信裡講的一致：**比較的兩邊同源 ⇒ 恆真**，而且是本專案已經記錄在案
那條「兩邊必須能各自獨立改變」的標準病灶，不是新發現，是你正確地把它
套用到這張票自己要做的事情上。

同意換掉、不同意留著恆真格：留著比沒有格更糟（它讓卷面印一句「母體有被
守住」的假話），這點我沒有異議。

「換成 spec 常數＋逐名清單」是不是對的方向：我去找了有沒有更好的外部錨
（比「我自己手打的數字」更不會被同一個人同時寫錯那種）——檢查了你在大
comment 裡提到的「單一來源是 get_available_actions，床有一格做異源比對、
抽它的 actions.append(…) 字面」：讀了 get_available_actions 本體
（player_command_system.gd:156-161），它現在只是對 get_action_availability
做 enabled 過濾，**沒有任何 literal append 字串**了——那段大 comment 描述的
是舊架構（single-full-list 票之前），已經過期，今天不存在第三個獨立的
字面陣列可以借用。⇒ 結論：**你的方向是對的，因為沒有更好的外部錨可選**；
「spec 常數＋逐名清單」已經是能做到的最乾淨外部錨（一個是人工填的總數，
一個是人工填的具名清單，兩者都在測試檔內單獨維護，跟 ACTION_SHAPE／
TEAM_TARGET_ACTIONS 兩邊都不同源）。

一個維護風險要你留意：colocation_gate_bed.gd 的 `SPEC_TEAM_TARGET_TOTAL`
旁邊已經有一份手打的 12 個名字（**用註解寫的，不是 Array**）。如果你在
available_actions_bed.gd 另開一個新的 `const` 陣列逐字列那 12 個名字，
會變成兩個檔案各自維護一份長度 12 的手抄名單——這正是本專案另一條舊病
（兩份名單各自抄會漂開而不互相知道）。建議：逐名清單只在一處宣告成真正
的 `const Array`（放在 available_actions_bed.gd，因為 P17 在那裡），
colocation_gate_bed.gd 維持它原本的註解（只是文字說明，不承重），不要
在兩個檔案各自長出一份具名陣列。
```

# 二、其餘三處

```
①六個命中數：獨立用 `git grep -c <符號> 23679126e -- <檔>` 重數，逐一對上：
  SPEC_TEAM_TARGET_TOTAL：bed 3／coloc 9
  SPEC_CONSTANT_SYMBOL：bed 4
  TEAM_TARGET_ACTIONS：bed 20／coloc 13／production 11
  六個數字全部吻合。而這六個數不是釘進斷言的字面門檻，是交件信裡「搬前
  vs 搬後」的報告基準（不是 code 裡的斷言常數）⇒ 不會腐爛成一個會過期的
  斷言，頂多是報告裡的一句話需要重算——跟 D7 那條「不釘字面數字，跑完
  從輸出逐字抄」是同一個處置，沒有疑慮。

②P4 負對照指舊 ref、不改活檔：延用上一票核過的做法，沒有新風險，同意。

③§5「三支守衛已經是上限」：核過你列的三處（available_actions_bed.gd、
  colocation_gate_bed.gd、player_command_system.gd 的 `_colocation_gate`）
  正好是 `TEAM_TARGET_ACTIONS` 這個符號名在全庫出現的全部三個檔案
  （grep 全庫沒有第四個檔案命中這個符號名）⇒ 母體窮盡，判上限成立，
  同意不要再拆。
```

# 三、verdict

```
CLEAN。§3③ 方向正確（恆真格必須換掉，而换成的外部錨已經是能找到的最乾淨
選項），附帶一個維護風險提醒（逐名清單只設一份，不要兩個檔案各自抄）；
六數獨立複算吻合；P4／§5 無異議。這票不急，可以排在退場票 merge 之後
按你的序走。
```
