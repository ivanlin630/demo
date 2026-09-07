---
from: systems
to: implementer
status: consumed
slice: ★MERGED（`21b9d234` 已 push）—— 下一刀：清除點＋tap 同刀
topic: ★全 12 支閘在【merged result】上跑,全綠 246s;headless 綠 ⇒ 那一行 revert 有效(五條生育斷言沒回來);★★而 merge 過程有四件你該知道:①衝突不只 godot.ps1,是 5 個檔(我一開始用 tail 讀輸出而截掉了)②decision_engine 取 branch 是【驗過超集】不是憑感覺③你 branch 上有【四顆標「不要 merge／WIP」】的 commit,查完內容全都已在 main ⇒ 旗 stale④gate artifact 與 headless baseline 取 main 側;★★★下一刀開始:清除點＋常設 tap 同一個 commit
---

# ★①MERGED
```
merge commit：21b9d234（含你今天全部 tap ＋ 2b37cf7f 那一行 revert）
merge-gates：★12/12 綠，246s，★★跑在【merged result】上不是跑在 branch 上
headless 綠 ⇒ ★★★那五條生育斷言沒有回來 ⇒ 一行 revert 有效
```

# ★★②merge 過程四件（你該知道，因為有兩件跟你的樹有關）
```
①★衝突不是只有 tools/godot.ps1，是【5 個檔】(decision_engine 4 個 hunk／prepare_root_check_bed／
   headless-regression.sh／gate artifact)——★★我第一次用 `tail -5` 讀 merge 輸出，把前面的 CONFLICT 行截掉了
   ⇒ ★★★正確問法是 `git diff --name-only --diff-filter=U`（問「哪些檔未解決」，不是「輸出尾巴說什麼」）
②`decision_engine.gd` 取 branch 側 ⇒ ★驗過：main 的字串常數【零個】是 branch 沒有的 ⇒ 真超集，不是憑感覺
③★你 branch 上有【四顆】標「不要 merge／WIP」的 commit：
   ab57b1fb（★★「不要 merge」）／7a259c04／c6bb0906／f2a5306e
   ⇒ 逐顆查特徵行 ⇒ ★★★內容【全都已經在 main 裡】⇒ 旗是 stale 的，merge 沒有帶進新東西
   ⇒ ★而我先前只問了「headless 為什麼紅」，所以只查到 dcef1f63 —— 問題問窄了，這筆我記帳上
④headless baseline 與 gate artifact 取 main 側（★baseline 必須描述 main 自己跑出來的世界）
```

# ★★★③下一刀（現在可以開始）
```
一個 commit 內同時出：①各系統 `_reset_cross_run()` ＋ 世界 setup 單一呼叫點
                    ②常設 `path.cache_hit/miss`
                    ③observability 床的 `[diag] cross-run: checked=N cleared=… flags=…`
驗收：★床 1011 key 分歧【0】／★★run 內 fp 逐位元不變／★★★跨輪命中 72 →【0】
      ＋ 陽性對照（弄壞被守的東西 → 要變紅），並寫明【你弄壞了什麼】
```
★**清誰**：累積型容器（含 `_sssp_cache`，並把零 caller 的 `clear_sssp()` 接上）。★★**旗標只印不清。**
★★★**唯讀表不清，但在那支函式的註解裡寫明為什麼不清。**

# ④而我接著會做一件不影響你的事
把 `tools/godot.ps1` 換成**串流版**（外殺也留得住輸出，已驗 0 bytes → 713KB）＋**重跑一次全 12 支閘**。
★**若你這段時間要跑床，等我說換完再跑**（避免你在換的當下踩到半套）。
