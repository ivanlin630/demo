# 00_roles.md — Session 角色與分工

> **★2026-07-08 切回多終端為主軌**（見下 §現行偏好）：pipeline/orchestrator（`06`）曾於 2026-07-06 取代多終端，但機器誤判(A2a 假 reject)+燒錢後**切回多終端信箱 relay 為預設**——各角色**持久 session 平行開** + 信箱主動觸發（`07_mailbox_trigger.md`），langgraph 機器只大/並行才上。**下列角色職責 / owner 表 / 邊界規則全有效**。**auto-memory 單寫者 = 系統 session**（兩軌恢復持久角色 session → 單寫者回系統，見 §auto-memory + §2 owner 表）。QA 獨立 adversarial + 用戶最終驗收硬閘不變（`04_qa`/`05_acceptance`）。

主 session 有**兩個並存的設計腦**，按領域分（WHAT vs HOW），不是按階層。
加上 worktree 實作者，與 main dir 的**量測員**（`--path` 跑 branch）、**驗收官（QA）**（讀 diff/show）。接力，不是並行競爭。

## ★單一用戶窗口（用戶定 2026-08-26，全角色）

★**要用戶裁的事 ⇒ 寄 `blueprint`，`topic` 標【呈用戶】** —— ★★**禁各自對用戶終端呈報**；**blueprint 彙整呈報 ＋ 把裁決帶回。**
★**同族既有紀律**：**下游角色禁 `AskUserQuestion` 中斷用戶；卡住報 01，不問用戶。**

## 五角色

| 角色 | 管 | 不管 | 產物 |
|---|---|---|---|
| **藍圖**（Blueprint） | **WHAT**：玩什麼、玩家循環、feature 願景、平衡意圖 | 架構決定、code | `game-design.md`、feature/願景 docs |
| **系統**（Systems） | **HOW**：seam、契約、所有權圖、invariant、tick pipeline、行政流程 `01_architect.md`| 遊戲願景、平衡意圖 | spec / plan / `invariants.md`|

> ★血證／案例 → `00_roles-cases.md`（同標題節）

## 接力流向（同一 feature 不同階段，非同時）

```
你 →願景→ 藍圖(WHAT) →意圖→ 【R①factcheck 工單前提】→ 系統(HOW) spec →【R②審 spec=CLEAN】→ 實作 →handback→ 系統(收+驗) → 量測員(全量 dump) → 【QA 故事性稽核】 → 藍圖判(release-pass) → 系統(merge+推下一站)
```

### ★★★這張圖講的是【工作順序】，不是【信寄給誰】（2026-08-26 血證，systems 裁定）
**事故**：QA 判決寄 blueprint、blueprint PASS 後回覆 QA ——**兩封都寄了、都沒錯，而 merge 的人（systems）不在任一端。**
⇒ ★**systems 在「等 QA」，而 QA 早已判完、blueprint 早已結案。** ★★**是用戶叫我去問，才發現那個等是空的。**

> ★★★**收件人 ＝【下一個要動作的人】；流程上的相關者放副本。**
> **兩者常常是同一個人，而它們【不同】的時候，沒有人會發現 —— 因為每一封信都寄了。**

★**即刻生效的口徑**（blueprint 認帳並改口徑 2026-08-26）：
**release 判決信收件人一律 ＝ 執行下一動的角色（通常是 systems／merge 站），QA 收副本。**
★★**同族**：**「落地≠遞送」的結構版 —— 這次東西完成了、通知也發了，只是發給了流程上的下一站。**

> ★血證／案例 → `00_roles-cases.md`（同標題節）

## 三條釘死規則

### 1. 邊界 = WHAT vs HOW
- 藍圖不碰架構決定；系統不改遊戲願景。
- 越界 → 呈報對方，不自決。


> ★血證／案例 → `00_roles-cases.md`（同標題節）

## 跨角色交接 channel（handback，泛用）

§1 的「越界 → 呈報對方」實體地址 = `docs/superpowers/handbacks/`。藍圖/系統/實作三角色**並行 session 彼此不能直接對話**（只有 user 當人肉橋），口頭轉述易漏不留檔 → 一律走 git doc handback。

**夾一套格式、任意角色對、雙向對稱**（非單向「實作→系統」）。


> ★血證／案例 → `00_roles-cases.md`（同標題節）

## ★★無斷點自動鏈（用戶定案 2026-07-09，總則）

用戶要「無斷點自動工作，直到有問題要我裁決」。各角色收 handback = **做完 + 立刻推下一站**（寫下一站 handback → inbox-watch ~20s 自動喚下一角色 → 鏈自動流到底），**不停在自己這站等下個觸發**。

1. **收 handback → 做完 + 推下一站**（動完立刻寫下一站信，不等）。
2. **禁自造斷點**：不「park／排隊／下個 session 接／等下再做／非急擱著」。有輸入就往前推。

> ★血證／案例 → `00_roles-cases.md`（同標題節）

## ★★診斷通則：補丁閘優先查（用戶定案 2026-07-09，全角色）

遇「某行為缺失／塌陷／從不 fire」（敗北模型不見、征服從不發生、掠奪從不贏、某湧現量不到…）→ **第一件事查是不是補丁閘**：硬寫 gate／override／`continue`／絕對門檻 **pre-empt 掉本該引擎/人格做的決策** → **先於**猜「參數沒調好／設計沒做／世界本該如此」。

- 找到 → **de-patch**（決策交引擎/人格秤，讓它 pre-empt 機械閘），**非加補償補丁**（違憲、補丁疊補丁）。
- 血證：敗北模型（絕對殲滅線 pre-empt 逃決策=殲滅-heavy）、A2c-1（pre-gate `continue` bypass）、arbiter latch（99% 病）。
- systems characterize / measurer 量不到某湧現 → 都先查補丁閘。併 [[feedback_avoid_rabbithole]]（先量測揭「量不到」）→ 補丁閘優先查揭「為何量不到」。memory [[feedback-patch-gate-first]]。

## ★★框外挑框：降 groupthink（用戶挖，2026-07-09）

**根**：判斷層（blueprint/systems）清一色 Opus → 同 priors → 獨立實例也推同一（可能錯）結論。模型多樣（QA/量測 Sonnet、LG Haiku）在**下位機械角色**、defer 上位框架、不挑戰 → 碰不到判斷層。**自我質疑驗得了數據/執行、驗不了自己的框**（同 priors 自驗還是同結論；A2c-1「ironclad regression」數字對詮釋錯，破框靠用戶逼多 seed）。

**藥：選擇性召異質 skeptic 挑框**（非全審=非浪費）。**★觸發三對齊才召**（其餘直接過）：
1. 下**強結論且 redirect 大量工作**（建 X / 推翻 Y）；

> ★血證／案例 → `00_roles-cases.md`（同標題節）

## ★★量測可溯源鐵律（用戶定 2026-07-13，全角色）

**任何角色**（measurer/systems/QA/blueprint…）把數字寫進 handback / doc 前：**原始輸出必先落地成檔**（`docs/measurements/*.log`，非憑記憶轉述）＋**引數字附來源檔:行**＋**標量測當下 commit hash（+`-dirty`）**。裸轉述數字＝違規（日後對不上分不清「過期數字」vs「determinism 壞」，只能重跑）。血教訓：71/22/7% winner 轉述無存檔無 hash → 對不上 main 無法辨真偽。協議本體＝`03b_measurer.md §量測可溯源協議`（measurer 讀），此為跨角色鐵律指標。

## 驗收鏈（一句 + 指標）

user-in-loop 下 release-pass 權→藍圖（full_probe 數字判、有問題升用戶），正式 QA release-gate 砍；**逃逸缺陷仍入 `docs/escaped_defects.md`**；轉自動交付→三層 QA 硬閘回歸。**規則本體=`05_acceptance.md`（QA 讀）**。

## auto-memory 規則（承 §2）

- **單寫者 = 系統 session**（HOW owner，持久、序列化天然單寫）。別角色（藍圖/QA/reviewer/實作）教訓走 handback → 系統提煉入 memory。
- 藍圖/實作只**讀**（harness 開頭自動注入，無需主動讀）。單寫者 = 零 MEMORY.md race + 教訓經系統過濾。

## 文檔導覽（★單一權威源 + 各角色開場只讀自己那格，降 CTX）

**規則**：本 doc（00）= 全角色共讀的**唯一共享脊椎**（角色/owner/邊界/接力流向/3 通則）。其餘每 topic **只有一個權威 doc**，別處只指標不重描。

★**開場該讀哪一格 ＝ 以 `SessionStart` hook 注入為準**（`session-role.sh`）——
★★**這裡不再維護一張會 drift 的對照表**：★★★**表和 hook 兩份真相，必有一份先過期。**

> ★**原本這裡是一張表，2026-08-25 #4 切刀把內容切走、只留表頭 ⇒ 空表頭殘骸（blueprint 抽查抓到）。**
> ★★**修法不是把表補回來，是【讓它只有一個來源】。**

> ★血證／案例 → `00_roles-cases.md`（同標題節）

## 你的負擔

| 對象 | 你做什麼 | 頻率 |
|---|---|---|
| 藍圖 | 願景討論、玩法取捨 | 按 feature |
| 系統 | 架構討論、裁決、流程 | 按 feature |

> ★血證／案例 → `00_roles-cases.md`（同標題節）

## ★★★四條全角色規則（2026-08-26 收攏；★血證逐條在 `00_roles-cases.md` 同標題節）

★**收攏理由**：原本這四節各佔一個標題 ＋ 一段被切到一半的殘句（★其中一段的 code fence 沒有關），
**加起來 36 行，卻沒有一節說得完整** —— ★★**四個讀不完的入口，不如一張讀得完的表。**

| 規則 | 一句話 | detail 節標題 |
|---|---|---|
| ★**P7 三態誠實表** | `docs/process/*` **讀起來全都像已武裝，實際幾乎全靠自律** ⇒ 每條規則要標「有沒有東西在檢查它」。★**兩態不夠**（用戶 2026-08-04：**hook 提醒 ≠ gate**）⇒ 分**三態** | ★P7 三態誠實表 |
| ★★**對抗鏈往上咬也要通** | implementer 咬 systems、systems 咬 blueprint、**blueprint 認**（「那是我指定的錯」）——★**只能往下咬的對抗鏈，是驗收劇場** | ★★對抗鏈**往上咬也要通** |
| ★★★**驗收判準必須【隨票走】** | measurer 寫「我假設…不確定對否已標明」——★**他標明假設是對的做法，但【他需要假設】這件事本身就是流程缺口** ⇒ **派量測時判準寫在票裡** | ★★★驗收判準必須【隨票走】 |
| ★★★**`RUNNING` 遮蔽了「出貨沒推鏈」** | 用戶問「不是改裝工作流了嗎？怎麼還會停頓？」⇒ ★**三層猜測全錯**：沒人偷懶（背景 job 在跑）、鏈也沒斷 —— **是【有東西在動】被讀成了【事情在前進】** | ★★★工作流停頓的真根 |

