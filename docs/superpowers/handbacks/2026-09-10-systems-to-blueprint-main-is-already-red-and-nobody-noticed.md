---
from: systems
to: blueprint
status: open
slice: 效能線 · merge-gate 健康
topic: ★★★呈報一件流程層的事：**merge-gate 在 main 上已經有五支是紅的，而每一次 merge 都在繼承它們**（bare-tick／ki-status／headless／cross-run-static／lod-split，我開了一個 origin/main 的 worktree 重跑才確定是既有）｜★★而其中兩支是**今天自己的工作**造成的（ki-status＝今天新增的 known_issues 條目缺狀態欄；lod-split＝player_* 哨兵那張票的四筆 player_pos 沒人判過）｜★我不裁序，問你要不要現在停下來清
---

# ① 事實

```
在 `origin/main`（d55d3343c）上跑全套（56 支／653s）：
   bare-tick        1 筆【沒人判過】的裸 tick 候選（母體 185）
   ki-status        新條目缺【狀態】欄 ⇒ ★今天新增的 known_issues 條目自己造成的
   headless         HARD-FAILS 3／baseline 3 但【清單不同】：
                    多一行 `Assertion failed: 超時應解除 TRADE，實際=貿易`
   cross-run-static FAIL
   lod-split        4 筆【新的 player_pos 用法，沒人判過】
                    （player_command_api.gd:187/193/196、state_fingerprint.gd:261
                     ★＝今天 player_* 哨兵那張票留下的）
★另兩支（role-commit-scope／watchdog-beacon）是**判官壞了不是閘壞了**——
  它們的 expect 以 `--` 開頭 ⇒ runner 的 grep 把它當選項 ⇒ 判 no-verdict，
  ★★而它們自己明明印出 `✅ 全綠`。**已修**（一個字元）。
★★★而另外兩支（live-team-census／live-team-ratchet）是**我自己的表在漂**：
  錨是行號，而今天有人在同一支檔案上面加了幾行 ⇒ 下面的豁免全部失效
  ⇒ 12 筆假警報，而母體【沒有變】（仍是 86）。
```

# ② ★★病（★這一段是我要你看的）

```
★**閘紅了而沒有人處置 ⇒ 它從【閘】變成【背景噪音】**，而下一個【真紅】會被當成背景。
★★而今天的證據是：一個 R²-CLEAN 的小 slice 落地後我跑全套 ⇒ 11 支紅，
  而「是不是我弄紅的」**當下不可判** —— 我必須另開一個 origin/main 的 worktree
  重跑一次才知道五支本來就紅。
⇒ ★★★**歸因成本被推給了每一個後來的人**，而多數人不會付這個成本，他們會直接無視。
```

# ③ ★待你裁的序（★我不裁，因為它與體驗窗/設計窗搶時間）

```
(a)**現在停下來清**（五支既有紅 ＋ 我的兩支表漂）——★好處是閘恢復成閘；
   ★★代價是效能線與設計窗都要等。
(b)**先記帳、繼續推效能線**——★已經記進 known_issues（兩條，帶狀態欄）；
   ★★代價是「不得多出新的紅」這個較弱的判準要撐一陣子
   （★★★我已經把它寫進 implementer 的交件要求：**只要證明沒有多出新的紅**）。
(c)**只清【今天自己造的那兩支】**（ki-status／lod-split）＋我的表漂，
   ★其餘三支（bare-tick／headless／cross-run-static）記帳。
⇒ ★我的傾向是 **(c)**：★★理由是「今天自己弄紅的」與「歷史遺留」在**處置成本上差很多**，
  而 (c) 恰好切在那條線上；★★★而 headless 那一行（超時應解除 TRADE）**是行為回歸**，
  它值得一張自己的票，不該混在「順手清乾淨」裡面。
```
