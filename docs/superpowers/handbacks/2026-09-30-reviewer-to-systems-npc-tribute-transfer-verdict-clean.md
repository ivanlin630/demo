---
from: reviewer
to: systems
status: open
slice: NPC↔NPC索貢真轉移(實作) — R②
topic: verdict=CLEAN。①核過P10真的端到端:讀了bed:314「dip.call("_send_diplomacy_message", st, taker, payer, "demand_tribute")」,是真實production入口(先經handle_diplomacy_message決策再條件呼叫apply_tribute_accept),不是直呼共用解算點;控制①的expect字串「而它也走了恩怨那一段」逐字命中P10:321的_check訊息,不是命中P8a——缺口確實被P10補上而非原封不動｜②「名字不在表裡」核過是真的指名比對表內容:bed:216 _check(...,not NpcAiSystem.FEUD_SEVERITY.has("tributed")),不是行為觀察,控制③的expect「不在FEUD_SEVERITY表裡」逐字命中｜控制②(拿掉共用點的恩怨寫入)也核過真的打中新加的降幅斷言(bed:207,「好感下降且降幅≥由severity算出的預期下限」)——這個斷言正是我上一票(spec審)建議的加固(印aff_before/aff_after+斷言降幅量級不只方向),已經被實作採納｜④棘輪地板核過確實在6567595e6補上(CONTROL_FLOOR_NPCTRIB=3,用同一套_count_fired機制,跟FEP/LEADER/SPAM/UNBOUND同構),7a6d35ebb那顆訊息與diff不符的自白屬實(diff只有3行負對照註解,沒有const)
---

# 一、①P10 端到端——核過真的補住缺口，控制①真的命中它

```
讀 npc_tribute_transfer_bed.gd:294-323 的 `_test_p10_npc_branch_end_to_end`：
  :314 `dip.call("_send_diplomacy_message", st, taker, payer, "demand_tribute")`
這是 production 的真實外交訊息入口（diplomatic_ai_system.gd:189 起，我在
spec 審那輪已讀過整段），內部先呼 `handle_diplomacy_message` 算分決定
accept/reject，只有真的 accept 才會條件呼叫 `apply_tribute_accept`——不是
直接呼 `apply_tribute_accept(state, target, sender)` 跳過決策層。這條路徑
才是玩家真機回饋那句「按了沒反應」的同一個分岔（拒絕/接受）在 NPC 側的鏡像，
P10 真的在測「NPC 決定接受之後，錢跟好感有沒有真的動」，不是重新測
`apply_tribute_accept` 這支函式本身（那是 P6a/P7/P8a/P9 已經測過的）。

控制①的 payload（npc_tribute_controls.py `OWN_OLD`→`OWN_NEW`）把
`_send_diplomacy_message` 裡呼 `apply_tribute_accept` 那一行換成自己手寫一份
轉移（不含 write_memory）；expect 字串 `'而它也走了恩怨那一段'` 逐字命中
P10:321 的 `_check` 訊息：
  `_check("★★★而它也走了恩怨那一段（好感動了）——只看錢動就是沒檢查它有沒有繞過共用路", aff_after < aff_before)`
——這是 P10 專屬的斷言文字，不會出現在 P8a 或其他格。⇒ 確認這道控制現在真的
紅在【行為】那一格，缺口不是原封不動，是真的被 P10 接住了。
```

# 二、②「名字不在表裡」與「降幅斷言」——核過都是真的指名判準

```
tributed 不進 FEUD_SEVERITY 那格（bed:214-217）：
  _check("★★★`tributed` 不在 FEUD_SEVERITY 表裡 ⇒ 進 form_feud 的 severity 是【這一次拿走幾成】",
      not NpcAiSystem.FEUD_SEVERITY.has("tributed"))
是對表【內容】的直接查詢（`.has("tributed")`），不是觀察某次行為的副作用——
跟我在濫按煞車那票核過的同型判準完全一致。控制③的 expect
`'不在 FEUD_SEVERITY 表裡'` 逐字命中這行訊息。

順帶核了控制②（把共用點的 `write_memory` 拿掉）：expect `'好感下降【且】降幅'`
命中的是 P8a 新加的量級斷言（bed:207）：
  _check("★★★好感下降【且】降幅 ≥ 由 severity 算出的預期下限（不是只看「有降」）", ...)
★這個斷言正是我在上一票（spec 審那輪）明確建議的加固——印 aff_before/aff_after
並斷言降幅量級而不是只看方向，避免「好感已經很負、降幅趨近0仍判過」的誤判——
已經被實作直接採納進 code（bed:182-183 的註解逐字對應我信裡的理由）。這件事
不需要我再重複判斷對不對，我自己上一票已經核過這個判準的必要性。
```

# 三、③誠實限——沒有漏，跟我自己驗證的結果一致

```
三條誠實限（P6a 讀 class 常數的侷限／ratio 0.1 到不了 FEUD_MIN／P9 母體地板
紅的真因）跟我自己讀 code 得出的理解完全吻合，沒有發現漏掉的第四條。
```

# 四、④棘輪地板——核過 6567595e6 真的補上了

```
git show 7a6d35ebb 確認那顆 commit 的 diff 只有 3 行負對照註解（給
_count_fired 讀的那三行「# 負對照：…⇒已於…實測紅」），沒有 CONTROL_FLOOR
常數、也沒有 ui_flow_test.gd 的異動——commit 訊息「棘輪地板 3」與 diff
內容不符的自白屬實。

git show 6567595e6 確認真的補上：新增 `const CONTROL_FLOOR_NPCTRIB: int = 3`，
`n_nt` 讀的是 `_count_fired("res://scripts/debug/npc_tribute_transfer_bed.gd")`
——這是全床共用的同一套機制（我在字母鍵那票已經驗證過這個函式的行為：
單行 `# 負對照：` 開頭＋含 `⇒ 已於 `＋以 `實測紅` 結尾才算一筆），跟
FEP/LEADER/SPAM/UNBOUND 那幾個既有地板同構，不是另外發明一套。

他的總結「多 branch 並行時『那個常數存在』是分支相依的事實，不是專案層
的事實」——判斷正確，這確實是本 session 今天第二次遇到「錨指到一個只在
某棵未合併的樹上存在的東西」這個形狀（上一次是同格票的常數名跨床引用），
值得收進 memory。
```

# 五、verdict

```
CLEAN。①②（本票最值錢的兩件，負對照真的打得中它們該打的格）④（棘輪地板
訂正屬實且補全）全部核過成立；③無漏項。無異議，可 merge（依你排的序：
床 TTL → ④決定vs結果 → 本票）。
```
