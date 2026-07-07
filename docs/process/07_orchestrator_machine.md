# 07_orchestrator_machine.md — langgraph 編排機器（設計，待用戶過目）

> 取代 `06_pipeline_orchestration.md` 的「藍圖 spawn ephemeral subagent」機制（subagent 死=work vanish、我 babysit）。
> 核心原則：**流程 = graph 強制節點，不是 doc 建議**（doc 會腐，graph 不會——05/06 腐爛教訓）。
> **承重假設已驗（2026-07-07）**：`claude -p` headless 可程式呼叫（回 PONG exit 0）、langgraph 1.2.8、python 3.11 在。

## 為何是這台（三約束同時滿足）
| 約束 | 怎麼滿足 |
|---|---|
| durable（停不死，非 subagent-death） | state 全在 **git**（handback+commit）；langgraph **checkpoint** 存 graph 位置；node 撞上限 → 從 checkpoint resume（die-and-resume，效果=停不死） |
| 乾淨 context（角色不互污） | 每 node = 全新 headless `claude -p`，只載自己 role + 相關 handback → 零互污 |
| 無人肉 relay | langgraph edge 自動觸發下一 node；用戶只在 interrupt 點回來 |

**subagent 穩定性碰不到專案**：node 只讀/寫 **已 commit 的 git 狀態**，死了=無害重跑。今天的 bug（subagent 握未 commit 狀態）在此架構下不可能。

## 節點圖

```
        ┌─ interrupt(用戶) ─┐
        ↓                   │
[N0 藍圖]──brief──>[N1 對抗①fact-check]──clean──>[N2 系統spec]
 WHAT,互動           grep 驗前提 code 斷言          01
                        │issues↑(回N0)                 │spec
                                                        ↓
                                          [N3 對抗②spec審]──clean──>[N4 實作]
                                           02 完整對抗設計審         03,worktree
                                              │issues↑(回N2,限次)      │commit+測
                                                                        ↓
                        merge<──[N6 閘]<──green──[N5 QA]<──────────────┘
                       ↑pass    05 驗收鏈        04 讀committed code對抗驗
                                constitution_gate  │red↑(回N4,限次)
                                +融合+不變量bed
                                  │fail↑(回N4/interrupt)
                        [N7 merge+回報用戶]（按自主邊界）
```

## 每節點契約（input=git讀 / output=git寫 / effect-check）

| N | 角色 | headless role | 讀 | 寫 | effect-check（過節點的硬證） |
|---|---|---|---|---|---|
| N0 | 藍圖 | 互動(我+用戶) | game-design/memory | `slice_brief`(blueprint→systems,含WHAT+code refs) | brief 檔存在 |
| N1 | 對抗①fact-check | reviewer | slice_brief + 引用的 code | `factcheck_verdict`{clean\|issues:[{claim,file:line,真相}]} | verdict 檔存在 + 結構合法 |
| N2 | 系統 | systems | fact-checked brief + invariants | `spec` | spec 檔存在 |
| N3 | 對抗②spec審 | reviewer | spec + findings/invariants | `review_verdict`{clean\|issues} | verdict 存在 |
| N4 | 實作 | implementer | spec (worktree) | commits + `impl_handback` | 有新 commit + handback |
| N5 | QA | qa | **已commit** diff + beds | `qa_verdict`{green\|red:[...]}（05 三層） | verdict 存在 |
| N6 | 閘 | **非claude**,純 script | worktree | constitution_gate+融合+bed 結果 | 全 exit 0 |
| N7 | merge | 純 script + 我彙整 | verdicts | merge→main、handbacks consumed、progress 更新 | main 有 merge commit |

**node = headless claude 的呼叫**：`SESSION_ROLE=<role> claude -p "<讀X→做role職責→寫Y handback→commit>"`，cwd=main 或 worktree(N4)。node 跑完**驗 effect 發生**（檔/commit 出現）才算過——不是「claude 回了就算」（驗效果非能力，本 session 鐵律）。

## 閘=條件 edge（graph 強制，非良心）
- N1 issues → interrupt 回 N0（前提假，浮給用戶）。
- N3 issues → 回 N2 修 spec（限 K 次，超過 interrupt）。
- N5 red → 回 N4 修（限 K 次）。
- N6 fail → 回 N4 或 interrupt。
- **05 驗收鏈 = N5+N6 硬節點**：不 green+不過閘，graph 到不了 merge。**doc 腐爛病在此絕跡**（略過=graph 跑不完）。
- **surprise-interrupt（跨節點）**：任一節點 verdict 帶 `premise_contradiction:true`（前提被自己產出打臉）→ 不走正常 retry edge，直接 interrupt 回用戶。矛盾偵測器，接 readiness-打臉/錨-存在 這類。

## 自主邊界（B→C 漸進，用戶定案 2026-07-07）

**終態=C（每 arc 全自動）**，但**漸進掙來，非一步跳**：
- **第一個 arc 用 B**（merge 前煞車，用戶瞄一眼才 merge）：機器未證明過，別同時押「未驗機器+arc自動」兩風險。跑 B 看 02/QA 命中率、看它接不接得住東西、建信任。
- **機器證明會抓東西後 → 升 C**（可觀測自動）。

**★C 從設計就是「可觀測 + 隨時可插手」，不是黑箱丟出去**（解用戶核心風險：閉迴路這種 reframe 是他中途發現的，full-arc 不能產、只能靠他在看時接）：

三道防瞎跑（irreducible 風險 = 機器產不出新 reframe，故靠人可觀測接）：
1. **02 逼 reframe 到前面**：對抗②被 prompt「這 spec 閉迴路，還是只把閥移位?」→ 設計不健全類（含閉迴路）在 arc 開頭 02 審就現形，不拖到中途。機器抬地板。
2. **surprise-interrupt 節點**：任何**前提矛盾**（fact-check 打臉／QA red 暗示方向錯／審查者報違反原則）→ **自動暫停回用戶**，不硬闖。（本 session 的 readiness 打臉、錨存在=此類，機器該停不該闖。）
3. **可觀測 + 隨時 interrupt**：機器**串流**每節點 verdict/metrics（用戶看得到，非跑完才給）；用戶直覺一 fire 隨時 langgraph user-interrupt → checkpoint 暫停 → 塞新 brief → resume。**自動≠瞎；省的是 relay 雜務，非知情權。**

**誠實殘餘**：需要人直覺、但不觸發矛盾偵測器的 reframe，只有用戶在看時才浮。**可觀測性=安全網，非自動化能取代。**

## 流程自量表（解「02二次值不值」）
每 node 落 `docs/process/metrics.jsonl`：{slice, node, verdict, found_issue, wall_clock}。累積命中率 → 02②、任何節點該不該留**用數據裁,不猜**。對抗①(近免費)常開;對抗②掛 log,~10 slice 空手→砍。

## 狀態物件（langgraph state）
`{slice_id, autonomy_mode, brief_path, spec_path, worktree, commits:[], verdicts:{factcheck,review,qa,gate}, retries:{review,qa}, metrics_ref}`。內容在 git 檔,state 只持指標+verdict。

## durability
langgraph checkpointer(SqliteSaver,`tools/orchestrator/checkpoints.db`)存 graph 位置+state。crash → resume 該 node。node 讀 git(冪等) → 重跑安全。

## 落地（增量,每步測,不一口氣建7節點）
1. **node-runner primitive**：`run_role(role,prompt,cwd)→shell claude -p→捕輸出→effect-check`。trivial role 測通。（承重已部分驗）
2. **git-handback helpers**：寫/讀/status + verdict 結構化解析(claude structured output)。
3. **langgraph 骨架**：stub 節點 + checkpoint + 一個 interrupt 跑通。
4. **填真節點**：先 N1 fact-check(唯讀最便宜)端到端 → N2/N3 → N4/N5/N6/N7。
5. **dogfood A1a**：第一個真 slice 走全機器。

**住哪**：`tools/orchestrator/`(python 機器,獨立 GDScript 遊戲碼)。自帶 langgraph dep。

## 角色↔舊 doc 映射
N0=藍圖(00)、N1/N3=對抗審查(02 新,一角色兩道)、N2=系統(01)、N4=實作(03)、N5=QA(04)、N6=閘(05 驗收鏈)。06 被本 doc 取代。編號 digit 之後理,位置為準。
