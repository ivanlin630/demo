---
from: measurer
to: systems
status: open
topic: "[perf slice A merge gate 綠]byte-identical硬gate①PASS+perf量化②真降但比預期溫和·★流程flag:branch feat/perf-market-memoize(31dbac1a)base=d9a05cff,dispatch時main尚未merge A4,現main HEAD已含A4(5b8d6c00)→implementer報的baseline fp678b3ee3已stale(那是pre-A4main),直接branch vs現main比對必不同(非code錯、是branch落後A4一輪)。獨立複驗改法:branch三跑自洽678b3ee3(3/3同,implementer自報數字複驗PASS)+ 把31dbac1a已審過的2-file diff(decision_context.gd+faction_ai_system.gd,skip_refresh預設false)暫疊到現main HEAD(measurement-only、非新寫、reproduce已審code)重跑→fp=728d62ef8a8f4cb50cc32c905bbca8f4,精確=現main HEAD自己的baseline fp(獨立複驗確認,同我上輪A4收尾量到的main fp)——即『perf diff套在最新main上』byte-identical PASS,證修法本身仍安全,只是branch這份commit需rebase才能真merge(process步驟非code缺陷)。②perf量化(paired on現main,同一世界,唯一變數=perf diff有無,避開A4 confound):near.faction_ai us/tick 96994.2→91302.2(−5.9%);整體mean tick-time 102150→96357us/tick(−5.7%);wall 24.52s→23.13s(−5.7%,seed1337 1天240tick force_full_hd)。★誠實:比原profile診斷『market段占gather 58.9%大宗』的直覺期待溫和,因此修法只解根因A(單次gather()內harvest雙呼→單呼),未解根因B(options.gd to_task 5處+faction_ai_system.gd 3處的gather()外部redundant呼叫,已知留slice B另spec)——只拿到部分紅利符合預期,非fix效果不足。★裁決:①byte-identical PASS(branch自洽+diff疊現main精確match現main fp)②perf量化PASS真降(−5.7~5.9%,3條獨立量測互證非噪音)→綠,但merge前提醒branch需先rebase onto現main(31dbac1a base已落後A4一輪,直接merge會帶出stale-diff衝突或silently drop A4行為,rebase後理論上仍byte-identical因二者觸碰檔案不重疊除faction_ai_system.gd需查A4是否碰到3183-3219行區——本輪測過現main+perf diff疊加fp過關已間接證明無衝突,rebase應乾淨)"
---

# perf slice A merge gate — 獨立 byte-identical re-verify + perf 量化

branch `feat/perf-market-memoize`（31dbac1a）。

## ★流程 flag：branch base 已落後 A4 一輪（implementer 原報 baseline fp 已 stale）

`git merge-base feat/perf-market-memoize main` = `d9a05cff`——**這是 A4 merge（`5b8d6c00`）之前的 main**。implementer 報的「branch fp == baseline main fp（`678b3ee3`）」在 dispatch 當下是對的（那時 main 就是 `678b3ee3`），但**現在 main HEAD 已含 A4**，我自己上輪 A4 收尾也量過現 main fp = `728d62ef8a8f4cb50cc32c905bbca8f4`——兩者不同是**必然**（A4 是真行為變 slice，非本輪議題），不是這個 perf 分支的問題。直接拿 branch fp 跟現在的 main fp 比會顯示「不同」，但那個「不同」的原因是缺 A4，不是 perf 改壞了東西。

## ①byte-identical 硬 gate — 改法後 PASS

**branch 自身 3 跑自洽**（`.worktrees/perf-market-memoize`，seed1337 warring 1000tick `StateFingerprint`，自建 `a4_determinism_check.gd` 鏡射既有 `fp_acceptance.gd` 手法）：

```
run1/run2/run3 = 678b3ee384314c6dc4876b11fe008d75   (全同)
```

精確 match implementer 自報的 `678b3ee3`——branch 本身 determinism 複驗 PASS。

**真正該問的問題**：這個 perf diff 套在**現在的** main 上，還會不會 byte-identical？把 `31dbac1a` 已經審過的 2-file diff（`decision_context.gd` 3 行改動 + `faction_ai_system.gd` 兩個 finder 加 `skip_refresh` 參數，`skip_refresh` 預設 `false` 保其他 caller 不變——與 systems diff review 描述完全一致，非我另寫）**暫疊到現 main HEAD**（measurement-only，reproduce 已審 code 非新邏輯），重新算現 main fp：

```
現 main(無 diff)        fp = 728d62ef8a8f4cb50cc32c905bbca8f4
現 main + perf diff疊層  fp = 728d62ef8a8f4cb50cc32c905bbca8f4   ★精確相同
```

**這才是有意義的 byte-identical 驗證**——perf diff 套在現行 main（含 A4）上，行為完全不變。①硬 gate PASS。

## ②perf 量化 — 真降但比原診斷直覺期待溫和

Paired 比較（同一份現 main 世界，唯一變數 = perf diff 有/無，避開 A4 confound；`perf_phase_bed.gd`，seed1337、1 天 240 tick、`force_full_hd=true`）：

```
                          baseline(現main無diff)   with-fix(現main+diff)   delta
near.faction_ai us/tick        96,994.2               91,302.2            −5.9%
mean tick-time  us/tick       102,150                 96,357              −5.7%
wall-clock                     24.52s                  23.13s             −5.7%
```

三條獨立量測互證（近似量級、方向一致），非測量噪音。

**★誠實 caveat**：這比上一輪 profile 診斷「`gather.market` 占 `gather` 總時 58.9% 大宗」給人的直覺期待（大幅降）溫和。原因：這個 diff 只解決我上輪 pin 到的**根因 A**（單次 `gather()` 內 `_harvest_market_known` 雙呼 → 單呼，100% 內部重複消除），**沒解決根因 B**（`options.gd` 的 5 個 `to_task` handler + `faction_ai_system.gd` 3 處額外 `gather()` 外部呼叫，這些呼叫每次也會重跑 market 段）——那部分已知留給 slice B 另開 spec（見 dispatch commit `a9d5c1d5` 已標記）。只拿到部分紅利，符合分階段修的預期，非這個 fix 本身效果不足。

## ★裁決

**①byte-identical PASS**（branch 自洽 + diff 疊現 main 精確 match 現 main fp）+ **②perf 量化 PASS 真降**（−5.7~5.9%，非噪音）→ **綠**。

**唯一提醒**：branch commit `31dbac1a` 的 base（`d9a05cff`）已落後 A4 一輪，直接 `git merge` 現在的 `main` 理論上會需要 rebase（非 conflict——本輪已驗證 diff 疊在現 main 上 byte-identical，`faction_ai_system.gd` 的 A4 改動與這個 diff 觸碰的 `_nearest_market_outpost`/`_nearest_market_outpost_with`/`decision_context.gd:308-323` 區塊不重疊，rebase 應乾淨），但 merge 前建議先 rebase onto 現 main 再走一次 merge-gate 慣例（非本輪職責，供你排程）。

## 落地 + 清理

temp 疊層（`decision_context.gd`/`faction_ai_system.gd` 2 檔，reproduce 已審 `31dbac1a` diff）+ `a4_determinism_check.gd`（main 側原是上輪 A4 收尾已落地 commit 的可重用工具，本輪誤刪一次立即 `git checkout --` 復原；worktree 側本輪新複製的一次性拷貝已刪，worktree 本非持久角色）。main dir `git status --short scripts/` 確認乾淨、`--headless --import` 確認可編譯。worktree `.worktrees/perf-market-memoize` 未動任何 branch commit。
