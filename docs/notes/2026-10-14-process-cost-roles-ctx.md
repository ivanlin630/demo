# 工程量／角色膨脹／ctx 固定開銷——三問三答（用戶與影子 2026-10-14）

status: NOTE（影子藍圖；全部數字當日量，指令附於 §末；待裁＝0，建議三條歸 systems）
from: 影子 blueprint session（不發信、不寫 memory）
to: 正藍圖（願景序）→ systems（HOW：角色開關、doc 瘦身、hook 輸出）
date: 2026-10-14

---

## §1 工程量與成果合理嗎

| 項 | 數 |
|---|---|
| 期間 | 2026-04 → 10（約 5.5 月） |
| commit | 12,948；只 21% 碰 `scripts/` |
| 模擬核心 | 41K 行（`scripts/simulation`） |
| UI | 8.6K 行 |
| 測試／量測 | 113K 行、547 檔（核心 2.7 倍） |
| handback | 9,707 檔、399K 行（核心 **10 倍**） |
| spec／plan | 514 檔、54K 行 |
| 閘／hook／defer | 124／75／126 |
| known_issues | 5,706 行 |
| 成果 | 終端 UI 第五輪試玩；無存檔；玩家可見批 11 票 |

判：**核心合理，過程不合理，兩者綁著。**
- 合理：41K 行做出 belief 層零上帝視角、統一決策秤、供給側經濟、敗北三端、六角色 session。測試 2.7 倍在湧現 sim 不算肥。code commit fix:feat ≈ 521:828。
- 不合理：信比 code 多十倍（9 月一天 190 commit，多為信與 status）；玩家面落後世界面（5.5 月才到「一格格走」；「UI 先」10-08 才立）；124 閘每支是一次 agent 假斷言的疤，但每支加每輪成本；9.7K md 在 repo 裡拖慢 git／grep／hook。
- 成因：①湧現 sim 每 feature 要證明「會 fire」，天生貴；②agent 假斷言 ⇒ 對策＝加角色加閘加信，有效但膨脹；③一人裁六 agent，等裁期間 agent 互相寫信。

## §2 角色為何越加越多

| 時間 | 角色 | 血證 |
|---|---|---|
| 5–6 月 | 00／01 拆 WHAT／HOW | 兩建築師同目錄撞檔；討論 >> 實作；兩收斂者定不一致 invariant |
| 6 月 | 實作（worktree） | 設計腦自己 commit 進 main，共用 index 事故 |
| 06-16 | QA | 用戶眼球≠QA：到不了／顯示錯／不對稱沒人掃 |
| 7 月 | 審查 R①R② | file:line 不存在；systems 自己 spec 自己過 |
| 07-08 | 量測員 | A2c-1 卡死根因＝量不了；systems 自讀 metric 把餓死讀成戰鬥好戲 |
| 07-09→08-04 | QA 砍又回四次 | 每次整鏈跳 QA 後出事 |

用戶判「本質＝不信單一 agent」，精確一格：**不信 agent 自驗自己**。六角色＝五種謊各配一個檢查者。兩個後果：
1. 檢查者也是 agent也會謊 ⇒ 又長 124 閘。閘比角色便宜：機械謊（沒 commit／動別人 index／沒跑電池）hook 抓；判斷謊（spec 前提錯／故事讀錯）才要人形角色。方向對，角色沒跟著減。
2. 角色只加不減（memory「沒有人負責讓東西變少」）。QA 砍四次又回＝價值真、位置假（最下游最晚最貴，人人跳）。第四第五輪用戶自己試玩寫日記＝QA 被用戶本人取代；量測員在 UI 票上無物可量。

**建議：角色跟階段走。**
- 世界層票：六角色全開，量測與 QA 必經。
- 玩家可見批（現在）：三終端——設計（00＋01 併）、實作、審查；用戶＝QA；量測員只在票寫「要量」才開。
- 不刪 doc 不刪定義，只不開終端。`00_roles` 本就寫接力「非同時」。
- 已有 hook 覆蓋的謊角色不重驗。

## §3 ctx 最小壓縮：動機對，執行一半

每次開場／compact 固定付：

| 項 | 大小 |
|---|---|
| CLAUDE.md | 4.5KB |
| invariants.md | 8KB |
| 00_roles.md | 11KB |
| MEMORY.md 索引（106 份 memory） | 17.5KB |
| 角色 doc：01_architect 23KB／**game-design 98KB** | 23–98KB |
| SessionStart hook 注入（doc-bytes 報表、simp-lint 清單、peers 表、superpowers 全文、caveman ×2） | 約 8–10KB |
| 合計 | systems 約 65KB、藍圖約 140KB（doc-bytes hook 目標 60KB） |

- **多角色把變動 ctx 除以六，把固定 ctx 乘以六。** compact 洗規則所以固定開銷非付不可。
- **真吃 ctx 的是工具輸出不是信**（信均 3.5KB；grep 全掃 docs 一次 2,435 命中）。角色拆不治，只有子代理（輸出不進主 ctx）與 `head_limit` 治。
- 違反自己規則處：①game-design.md 98KB 沒照「domain doc 瘦成 glance-aid」裁定做（history 檔已存在才 19KB）；②hook 輸出本身沒人量（doc-bytes 量 docs 不量 hook）；③caveman 注兩次＝`.claude/settings.local.json` 與 `~/.claude/settings.json` 各掛一份。
- 更正：影子口頭曾說「MEMORY.md 每行 200 字以上」，量後 108 行只 5 行超 200 字元（把位元組當字數）。索引肥在份數不在行長。

**建議（省最多先）**
1. game-design.md 拆：正典裁定 ≤30KB，歷史血證入 `game-design-history.md`。（內容切分＝正藍圖；搬＝systems）
2. hook 輸出收一行判決：doc-bytes 只印超標行、simp-lint 只印數、superpowers 不在 compact 後重注、caveman 去重一份。（systems）
3. memory 106 份 prune：合併同族（守衛類七八條可併一條索引）。（systems＝單寫者）
4. 角色隨階段關（§2）：固定開銷的「六」變「三」。（用戶裁，已口頭「好」）
5. 掃描型查詢走 Explore 子代理；可加 PreToolUse 擋 Grep 無 head_limit 全掃 docs/。（systems；注意「不要一直加閘」——這條只在 2 做完仍超標才加）

## §末 量法
```
git rev-list --count HEAD; git log --format=%ad --date=format:%Y-%m | sort | uniq -c
find scripts -name '*.gd' | xargs cat | wc -l; find docs/superpowers/handbacks -name '*.md' | wc -l
wc -c CLAUDE.md docs/invariants.md docs/process/00_roles.md docs/game-design.md ~/.claude/projects/A--GDS-demo/memory/MEMORY.md
git log --date=short --diff-filter=A -- docs/process/0*.md
```
