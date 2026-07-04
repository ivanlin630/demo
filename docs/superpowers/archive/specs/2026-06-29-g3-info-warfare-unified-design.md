# G3 統一信息域 — 情報戰 / 欺敵 設計 spec

> 藍圖(WHAT) spec。系統接此 → 設計 HOW（schema/公式/LOD/decision wiring）成分階 plan。
> 承接 2026-06-19 G3（被動 belief + 識破，已落地 8/10）。本 spec = 當初 scope OUT 的「情報戰 C」+ 統一信息域 enforce + 玩家被動呈現，**設計一體、build 分階**。
> 座落三不變量之信息域：**凡 belief 必有 provenance**。

## 0. 定位與既有基質

現有 `belief_system.gd` 已有：multi-claim 儲存、可信度（類型×身份信任×跳數×時效）、識破分級（信假/生疑/裁決）、觀察吃技能、uncertainty + confident_enough 風險 gate、scout 查證、reconcile 口碑迴路、cap/prune LOD。

本 spec **不重建基質**，是：①enforce（讓 belief 真正驅動決策）②欺敵（主動操弄 belief）③玩家被動呈現 ④擴充骨架。

## 1. 統一框架

**一個 belief 基質，所有 agent 對稱。** NPC 與玩家都是「情報 agent」，做同三件事：
- **消費** belief（best_estimate + uncertainty，看法非真相）
- **操弄** 他人 belief（植入假 claim — Phase D / 玩家武器化）
- **被識破反制**（識破分級 + 口碑迴路）

一套機器，NPC 與玩家只是不同 agent。

## 2. ★ 感知可信度 ≠ 真實可靠度（核心模型修正）

**收訊者不知道真實 hop / 真實 origin（那是 god-view）。** 收訊者只看得到：
- **誰當面告訴他**（直接來源 M）+ 自己對 M 的身份信任
- **M 宣稱的 provenance**（聲稱親見 / 聲稱聽說）— **M 講的，可謊報**

```
感知可信度 = 對直接來源信任 × M 宣稱 provenance 強度 × 我技能
           （不用真 hop）
真實 hop / 失真 = 模擬側、隱藏 → 搞爛 value（電話遊戲），收訊者看不到爛多少
```

後果（皆 believability 金）：
- **可以「自信地錯」**：信的人 + 拍胸脯「親見」→ 高感知可信度，但其實是洗了多手的走樣謊。感知高、真實爛 = 被咬處。
- **欺敵向量「謊報 provenance」**：老實傳話說「聽說」→ 自動打折；騙子說「我親眼看到」→ 感知可信度暴衝。識破 = 質疑 provenance（你哪來親見？對得上別的源嗎？）。
- honest 鏈本會自衰減（每手老實「聽說」越傳越虛）；**欺敵就是打破它**（謊報親見撐住）。

**HOW 移交**：`source_type` 改為「claimed（傳話者設定、可與真相不符）」；感知可信度公式去掉真 hop 依賴，改 claimed-provenance 權重；真 hop 只在模擬側管失真累積。

## 3. 多手 / 多騙子鏈（中間商各有算盤）

**原則：每個中間商的失真 = 他自己的 driver**（relay 納入意圖驅動；凡失真必有可解釋動機，非隨機噪）。

- A 捏造（driver=征服）→ M2（C 對手）加碼（driver=樂見 C 亂）→ 傳到 C。每手失真追得回該人動機。最終 value = 層層加料。
- **收訊者只判直接來源**（看不到上游騙子）→ 可自信錯。
- **解藥 = 多條獨立 claim**：單一信源 = 待宰；有另一條乾淨鏈 → 矛盾 → uncertainty↑ → 查證。**謊要贏得污染所有源**。
- **親見一刀切**：斥候 Tier0 親見 → 壓掉整鏈，洗幾手幾個騙子都一樣。
- **究責沿鏈**：抓到 → 怪直接來源；被騙的中間商自己親見後往上怪 → 騙子終被其直接受害者記恨；老實傳假料者連坐掉點信任（真實）。
- **範圍紀律**：relay=決策只在「對內容有 stake」的中間商認真跑，無關遠傳=便宜 pass/簡單噪。複用 message LOD、measure-first。

不需為「N 個騙子」寫特例——上述原則收斂任意鏈。

## 4. Build 脊椎（設計一體、分階建）

### Phase E — enforce（讓 belief 真正驅動決策；欺敵有後果的前提）
- 補 god-view 漏：`diplomatic_ai_system.gd:65`（直讀 `other.population`）、`faction_ai_system.gd:2632`（直讀 `t.population`）→ 改走 `best_estimate`。**盤是否還有別的漏**。
- **provenance 審計閘**：凡決策用的 belief 都追得回 provenance（直接來源+claimed）。決策直讀真值 = 違規（比照決策域「無因令=0」硬 assert）。
- **背叛折入**：背叛從 65% RNG → belief/領導值驅動（X 背叛 Y 因 X 的 belief「Y 弱/我有利」+ 人格，可解釋）。消信息域零星非統一。

### Phase D — 欺敵 primitive（NPC 情報戰核心）
- **動作 = 植入假 claim**：agent 趁接觸（外交/貿易 channel）對目標發 `distorted:true`、`value`=假、帶自己計謀(scheme)、**claimed provenance（可謊報）** 的 claim。複用 `record_claim`。
- **三招 = 同 primitive 不同 target/content**：假和（灌「我無意攻擊」進敵）/ 離間（灌「你的盟友要叛你」進 X，關於第三方）/ 緩兵（灌「無迫近攻擊」拖延）。
- **接 commander 孤兒 affordance**：means-end 開「阻敵盟」子需求 → filler「離間」→ 執行植假。孤兒轉真、自動進匹配。
- **效果真實**（守 affordance 真實性 invariant，靠 Phase E）：假和→敵讀 belief 降防備→偷襲得利；離間→X 讀 belief 不召盟→盟不介入；緩兵→敵延遲動員。各效果靠「對應決策讀 belief」成真。
- **反制 = 既有**：識破分級（我識破 vs 你計謀）+ 口碑迴路（植假被看穿 → trust 掉 → 你謊以後沒人信 = 自限）。

### Phase P — 玩家被動呈現（C-anchor 被動消費）
- 玩家看自家 belief 非真相：每目標/議題 = best_estimate + uncertainty + 每條 claim（直接來源 + **宣稱** provenance + 疑點旗）。**看不到真相、看不到真 hop**。
- 霧質感：低可信/高不確定 → 模糊/問號；claim 打架 → 顯矛盾。
- 玩家技能 gate 識破：技能高 → 浮現更多疑點、看穿更多。
- 此階**只被動**：讀 belief + 派斥候查證（既有）。不能植謊。
- C 迴路：殘缺 → 蒐集（被動收 + scout）→ 判可信 → 賭 → 被咬/利用無知。

### Phase 擴充（後續，設計含、不現在建）
- **channel verbs**：收買信使（污染中繼）/ 封鎖（擋達）/ 造謠擴散（種自傳謠言）/ reputation contagion（惡名遠播）。
- **玩家主動**：詢問/打聽/買地圖（主動蒐集）+ 玩家武器化（自己植謊，**同 primitive**、NPC/玩家對稱）。
- **信用幣**（money=信任）：住同基質，獨立 spec。

## 5. 驗收

- **believability bars**：
  - 欺敵技能分層（莽者中招 / 精明識破）。
  - 「自信地錯」會發生（感知高 cred + 真實爛 → 被咬）。
  - 多源矛盾 → scout；親見切鏈。
  - 騙子被識破 → 口碑崩 → 謊失效（自限）；究責沿鏈。
  - 離間真拆散過聯盟（戰國 seed 量到）。
- **provenance 不變量 enforce**：凡決策用 belief 追得回 provenance；god-view 讀真值 = 0（審計閘，比照無因令=0）。
- **戰國 seed 驗**：離間拆盟、被識破騙子口碑崩、慎重者查證/莽者誘殺 — 活世界量到。
- **回歸閘**：headless 1000+ tick 無錯 + coin/pop 守恆（coin_eq delta=0）。不用 multi drift。

## 5b. ★ 統一/可擴充 硬要求（HOW 沒守會退回非統一）

本機制 = 專案核心，統一且可擴充 by construction，但兩點若 HOW 偷懶就破功，列**硬要求**：

1. **植假 primitive 必須通用**：`plant(target, 任意 subject, 假值, claimed_provenance, scheme)`。假和/離間/緩兵 = 三個**實例**（不同 subject：己方意圖 / 第三方忠誠 / 威脅時程），**非三個 hardcoded 函式**。加新欺敵招 = 新 (subject,value)、零改碼。
2. **relay 失真必須走統一 driver 模型**：中間商加料 = 意圖驅動 action（凡失真必有可解釋 driver，過既有決策/means-end），**非 bolt-on 失真亂數 roll**。偷懶寫獨立 roll = 信息域又長一個非統一 latch（正是全 arc 在殺的病）。

**可擴充邊界（刻意的牆）**：擴充在「multi-claim + 可信度」範式**內**。完整認知模擬（每 NPC 世界觀模型 + 推理鏈）故意 OUT（measure-first 擋 AI 完美化）。超牆 = 鑽進不可玩，非缺陷。

## 6. 給系統 HOW（移交重點）

- `source_type` → claimed-provenance（可謊報，與真相分離）；感知可信度公式去真-hop、改 claimed 權重；真 hop 模擬側管失真。
- relay = 意圖驅動失真（中間商按 driver 加料）+ LOD（只 stake 中間商認真跑）。
- Phase E：god-view 漏盤點+補（best_estimate）、provenance 審計閘、背叛 belief 驅動化。
- Phase D：植假 primitive（record_claim 包裝）、接 commander 離間/假和/緩兵 affordance（孤兒轉真）、效果端決策讀 belief wiring（防備/召盟/動員）。
- Phase P：belief 唯讀呈現 API（best_estimate+uncertainty+claims+疑點，玩家走同 best_estimate 無全知）、技能 gate 識破顯示。
- 全程 measure-first、TEST VALUE 戰國 seed 校。
