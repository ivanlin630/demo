---
slice: camp-access
tier: full
qa: required
from: systems
topic: 折現磚世界層裁定 —— 「蓋了就丟」不是缺新磚，是磚只鋪了一半
---

# 裁定：折現磚 world-layer 阻塞（`discounted-future-flow` @ `52f08fdf`）

implementer 交還兩個裁定點並**正確拒絕 merge、正確拒絕調參掩蓋**。以下為 HOW 裁定。

## §1 先講結論（一句話）

**「營地 89% 蓋了就丟」不是缺一塊「住下去」的新磚 —— 是折現磚只鋪了 `camp_drive` 一端，
同場競技的另一半（覓食）還在用舊尺，而且舊尺是【位置盲】的。**

### 坐實（file:line，非詮釋）

| 選項 | 它的估值讀什麼 | 出處 |
|---|---|---|
| **紮營** | ★折現後的**未來真實流量** − 真實 baseline | 磚（本刀） |
| **覓食** | `clampf((2×SLACK_COMFORT_DAYS − ctx.food_days) / SLACK_COMFORT_DAYS, 0, 1)` | `terms.gd:113` |

⇒ `survival_pressure`（＝覓食品質）**只是 `food_days` 的函數**。
**不讀產出、不讀地力、不讀腳下 tile 是不是自己剛蓋的營地。**

⇒ **在自家營地上覓食，與在寸草不生的荒地上覓食，util 完全相同。**
∴ 隊伍蓋完營地後，**沒有任何估值把它留在原地**；下一輪它就走了 →
無人 collect → `camp_ticks_left` 遞減（`harvest_system:36-37`）→ `camp_level=0` → 回到零被動收入。
`紮根`(L0→L1) 永遠等不到窗口 ⇒ **`outpost.l0_to_l1 = 0`**，與 implementer 實測完全吻合。

## §2 裁定 1：**不**把 `TASK_CAMP` 塞進 `PROGRESSIVE_HOLD_TASKS`

implementer 選項 (a) 的前半 **駁回**。理由：

- `PROGRESSIVE_HOLD_TASKS`（`task_arbiter.gd:22`，**全 repo 唯一定義體**）的成員語意
  ——見其自帶註解——是「**有終點會完成**的 progressive 動作」。
- **紮營瞬間完成、沒有終點**（`faction_ai:4917` 直接 `camp_level = 1`，不設 `construction_ticks_left`）。
  塞進 hold list ⇒ **永久 latch**。**latch 凍世界是本專案有血證的病**，不重犯。
- ★ 且「該不該留下」本來就該是**估值**的答案，不是**仲裁鎖**的答案。
  持守統一 arc 的定案語意就是「**util 偏重、非硬鎖**」。

**改用**：`survival_pressure` 補上流量項（見 §3），讓「留在自家營地」**贏得起**，而不是被鎖住。

## §3 裁定 2（本刀主體）：磚鋪滿**四選項同秤**，`camp_drive` 不得單獨吃磚

> **v2 修訂（blueprint 2026-08-21 ⑤，依用戶 settlement §3 既裁「撿／投／紮／流浪四選項同秤、無寫死偏好」）**
> 範圍由「覓食」擴為**四選項全體**。R② 已 CLEAN 本節原則（「磚鋪滿同場」），本次為**範圍界定 delta**。

### ★四端現況：只有紮營在秤「未來能拿到多少食物」

| 選項 | `terms` eval | 它實際秤什麼 | 出處 |
|---|---|---|---|
| **覓食** | `survival_pressure` | `f(food_days)` ── **存量、位置盲** | `options.gd:53` → `terms.gd:113` |
| **遷移找糧**（流浪） | `survival_pressure` | 同上 ── **同一顆存量函數** | `options.gd:354` |
| **併入**（投靠） | `join_drive` | `0.5 + host protector_rep × W × 0.5` ── ★**只秤名聲，不看 host 有沒有飯** | `options.gd:155` → `terms.gd:188-195` |
| **佔村**（撿） | `occupy_drive` | `1.0 / 0.3` ── ★**死常數二值，不看那個村產不產糧** | `terms.gd:185-187` |
| **紮營** | `camp_drive` | ★**折現後的真實未來流 − 真實 baseline** | 本刀磚 |

⇒ **四個 survival 選項用四把不同的尺**：存量／存量／名聲／死常數 ── **只有紮營講真話**。
「89% 蓋了就丟」是這張表的必然結果，不是 bug。

### 同秤的定義（**唯一驗收標準**）
**四個選項都改成秤同一件事：「選它之後，我未來拿得到多少食物流」**，一律過折現磚。

- **覓食／遷移找糧**：流量 ＝ **腳下（或目標）tile 的真實所得**（血統①讀真實狀態）。
  ★**在自家營地覓食 vs 在荒地覓食，必須不同價** ── 這是本刀最小可驗行為。
- **併入（投靠）**：流量 ＝ **host 村的被動收入流**，且**即時接上（無工期延遲）**。
  ⇒ 折現下 **弱隊（H_eff 短、折現率高）天然贏在這裡**：現成的流打贏要等的流。
  ★**現況缺陷可直接驗**：**高名聲但自己快餓死的 host，目前一樣拿高分。**
- **佔村（撿）**：流量 ＝ 那個村的實際產能，非二值常數。

**★這不是 scope creep** ── blueprint 明示：**這是同一塊磚的完整形狀**。
磚只鋪一端 ＝ 製造出「唯一講真話的選項碾壓其他三個」的假象。

### `CAMP_MARGINAL_CAP` 的處置：**先量測、後動刀，本刀不動**

`terms.gd:196-206` 的 `clampf(marg/daily_need, 0, CAMP_MARGINAL_CAP)` 是**舊基準線時代的補償夾具**。
implementer 觀察「長期坐在 cap 上」若成立 ⇒ cap **吃掉折現磚的全部鑑別度**，紮營變成常數滿分
⇒ **人格失效**（這正好解釋「義氣隊未投靠」）⇒ 屬**補丁閘**，修法是 **de-patch 不是調值**。
**但這一句目前只是高信度假說**：要 measurer 用 `discount.*` tap 報 **saturation 率** 才算數
（`fileline_vs_interpretation`：有行號 ≠ 坐實因果）。**本刀先不動 cap。**

## §4 headless 5 條紅的分流（**禁用調參掩蓋任何一條**）

| 失敗 | 分流 | 預測 |
|---|---|---|
| `[p2a] 義氣隊未投靠 task=紮營` | ★**§3 投靠的 host 流入秤**（主因）＋ cap saturation（次） | 修完應回綠 |
| `[p2a] 投靠玩家未寫 forced_event` | 同上（連帶） | 修完應回綠 |
| `Path 3 應 投靠，實際=紮營` | 同上 | 修完應回綠 |
| `[p2b1] 義氣 homeless 未投靠` | 同上 | 修完應回綠 |
| ★`承諾(current_option=掠奪) → 應續掠奪，實際=紮營` | ★**承諾泛化缺件**（磚 #2） | **本刀修不掉** |

⇒ **若修完仍剩最後一條**：那條**標 `known-blocked-by: 承諾泛化磚`，不得改測試、不得調參**。
**四條回綠＋一條有主的紅**是可接受交付形狀；**五條全綠但靠調參**不是。

## §5 不在本刀（另立，避免 branch 膨脹）

- **工期單一真相源** `OutpostSystem.build_eta_days()` —— 見 `estimator-ledger.md` §E（**六份公式全錯**）。
  ★**例外升級條款**：若 measurer 實測坐實 §E-#4（糧橋 `_eta_build` 高估 24×）
  **正在擋住建造隊派遣**，則該顆**升 critical path，插隊本刀之前**
  ——因為那會讓本刀的世界層量測全部建立在「隊根本派不出去」的假地基上。

## §6 閘

`headless`（見 §4 分流）／`det×3` fp 穩定／`constitution_gate`／
★新增 `.claude/hooks/estimator-lineage-scan.sh`（**本刀期間 🔔 advisory**，單一真相源落地後轉 🔒）
