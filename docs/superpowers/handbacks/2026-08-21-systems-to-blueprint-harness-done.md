---
from: systems
to: blueprint
status: consumed
topic: "[★harness 完工(＝你的恢復扳機)·0-9 全落地+O1停更+O2掛閘+P7三態+P9 SOFT+plan 裁定完,閘全綠·★★但有兩件【要你先做才會生效】:①watchdog v3 還在你 session 跑著、v4 要你 TaskStop 後重 arm ②各角色要重 arm 才吃到 inbox-watch v2(hook 天然灰度)·★兩處 note 前提被實測推翻(handbacks 1293/扁平→實際頂層 239+有_archive;plans/ 空→52份在_archive且 session-role 至今指向空目錄,已修)·★順手抓到 json_str 對雙引號零跳脫=你的 SessionStart context 一直是壞 JSON,已修·恢復後第一批照舊快照"
---

# systems：harness 完工

**恢復扳機依你的定義已全部滿足**：階段 **0–7 落地** ＋ **O1 停更生效** ＋ **O2 掛閘** ＋ **P7 三態過一輪** ＋ **P9 SOFT 上線** ＋ **plan 裁定完**。
**merge 前閘全綠**：憲法閘 `PASS (sites=74, removed=1)`／`expect-min` 五項達地板／`seam-gate --selftest` 過／`stale-claims` 全新鮮。

## ★★兩件要你先做，否則新東西不會生效（hook 天然灰度）

1. **watchdog v3 還在你的 session 跑著**（v4 已在磁碟）。v3 每 300s 刷 lock ⇒ v4 會一直待命拿不到當家。
   → 請 **TaskStop 舊的那條 Monitor，再 arm 一次**：`Monitor(command="bash .claude/hooks/watchdog.sh", persistent=true, description="watchdog v4(停滯分類器)")`
2. **六個角色都要重 arm 信箱**才吃得到 v2（搶佔／`SEEN` 不重吐／誤寫 consumed 撈一次）。
   v2 是**搶佔式**：直接重 arm 即可，**不必殺進程**；同 session 重 arm 會印 `✅ 覆蓋仍在（已驗）`。

## ★兩處 note 前提被實測推翻（你的 note，非指責——只是別讓數字繼續被引用）

- **§3.4「handbacks 1293 檔（扁平目錄）」**：實測**頂層 239 封活躍信**、**遞迴 3544**（含 `_archive` 3305＋assets），**且不是扁平**。
  ☆我自己也踩了同一隻：照 1293 把 O2 地板設成 500，**第一次跑就紅燈**——**R6 的活範例**（引用了沒帶 commit/日期的數字）。
- **§4「`plans/` 是空的」→ 前置裁定已下**：頂層 0 份，但 **52 份全在 `_archive/`、最新 2026-07-13**。
  **裁定：不恢復產出，改 doc 宣告——plan 已被 HOW spec 吸收**（spec 自帶任務拆解＋驗收法，維護第二份＝雙寫）。
  ★真正的問題不是空目錄，是 **`session-role.sh` 到今天仍叫 implementer「照 `docs/superpowers/plans/` 逐 task 做」＝指向空目錄**，已修成 `specs/<日期>-<slice>-HOW.md`。

## ★順手抓到的真 bug（不在工單裡）

- **`json_str` 對雙引號完全沒跳脫** ⇒ 注入內容含 `"` 就吐**非法 JSON**。
  **你的 SessionStart 專屬 context 本來就含 `Monitor(command="…")`** ⇒ **那段一直是壞的**。兩支 hook 都換成 awk 版，`json.load` 驗過往返正確。
- **harness 原本 0 個檔在版控**（`.claude/` 整包 ignore）⇒ note §2.9「每步可獨立 revert」的前提不成立。已納管（機密續 ignore、逐項 `check-ignore` 驗過）。

## 你要知道的三個取捨

- **arm 搶佔＝新的一定贏**：誤開第二個同角色 session，被踢的是舊的（可能才是正在工作的那個）——但**它會印讓位訊息，看得見**。土法分辨：**5 分鐘內看到第二次「讓位」＝真有另一個同角色 session 活著**。
- **每 turn 閘刻意 warn-only／fail-open**：閘門自己有 bug 就 brick 六個 session；讀不到 `session_id` 一律不報警。
- **P9 現在是 SOFT（只印不擋）**，且**只對宣告了 `slice:` 的產物生效**。轉 HARD 是背景事項、**不擋恢復**。
  ★**派工時請注意**：dispatch handback 的 frontmatter 要帶 `slice:`（＝branch 名去掉 `feat/`）與 `tier:`（`full`｜`probe`）。
  **tier 由 systems 定、做的人不得自選**（能自己選輕流程的 agent，是在改自己的考卷）；**兩檔都不砍 review**。

## 恢復後第一批（照原快照，未變）

1. **生育二修**——**(a) 讓 anon 也能生**是 WHAT 級，**待你帶用戶拍**。建議**排在 A1／時間包之前**：`n_persons` 凍結讓人口與經濟科目全部讀不出東西。
2. **convoy RETURN 收尾** spec——R² CLEAN、**可直接 dispatch**（已帶 `slice: convoy-return-conservation`）。
3. **失敗律 spec**——**尚未送 R²**；若示範族成立，**A1 從五個修法縮成五處接線**。

**systems 待命，等你的恢復廣播。**
