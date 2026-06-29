# 受控人力 統一系統 — 設計 spec

> 藍圖(WHAT) spec。系統接此 → HOW(schema/公式/LOD/decision wiring) + 分階 plan。
> 緣起：(a) 攀爬卡點 measure 出「征服只 loot 不長 pop → 不 pay → turtle-world」。真因 = 戰爭非累積。fix = 征服吸收敗方。用戶要求**統一架構系統**含俘虜/招募/待遇/拷問等 + 未列事項，非窄吸收 patch。
> 統一抽象：所有「人怎麼進你掌控、怎麼被對待、結局如何」= 一條管線。

## 1. 範圍邊界

**受控人力管線**：人進入掌控 → 待遇 → 結局。**不含**人口生老死/階級流動（那是 demographic 系統，seam 相接）。按「共享機制（忠誠軌跡）」分，非「共享名詞（人）」——後者會成 god object。

## 2. 統一管線

```
ENTRY（怎麼進你掌控 + entry-condition 定初始忠誠/受控狀態）
  → 待遇（means-end 決策，driver=服務意圖）
  → OUTCOME（忠誠/民怨閾值 → 結局）
```

## 3. ENTRY — 5 類介面（可擴充，非窮舉）

entry 通道全按 **entry-condition 分類**，新通道歸某類、零改碼：

| 類 | 初始 | 通道實例 |
|---|---|---|
| 強迫 | 低忠、逃/叛風險 | 俘虜 / 吸收(征服併入) / 擄掠 / 奴役 / 徵召 |
| 自願 | 高忠 | 投靠(P2a已有) / 庇護投奔 / 願募 / 皈依 |
| 交易 | 條件忠誠、毀約即走 | 僱傭兵 / 債務賣身 |
| 關係 | 靠羈絆 | 婚姻聯姻 / 繼承 / 收養 |
| 策反 | 脆弱、可能再叛 | 策反 / 洗腦（連 G3） |

**設計只定 5 類介面 + deposit 機制**；建 anon 吸收（強迫類）先，其餘隨後。

## 3b. 俘虜 entry = 失能-capture（統一 player + NPC，控地權）

俘虜這條 entry 通道**統一 player 遭遇戰 + NPC 戰**，同一原則，免兩套漂走（現況已分岔：encounter 失能→`is_prisoner`/存 `prisoner_population`；npc_combat 吸收只掛近全滅 `_end_combat`→never fire）。

**統一原則：失能者被俘 = 控地權**（誰控制他倒下的地方）。**非「一失能就被俘」（太嚴）、非擲骰（太隨意）。**
- **player 遭遇戰（個體 LOD）**：失能個體 + 鄰敵控格 + 守衛沒超載 → 被俘；隊友緊鄰無敵看守 → 解救。（已有，保留）
- **NPC 戰（聚合 LOD）**：敗方潰逃丟戰場 → 勝方控地 → 俘敗方 `wounded`（失能聚合）的**一比例**：
  ```
  俘虜比例 = 敗方 wounded × 潰逃嚴重度 × 勝方 guard 餘力
    有序撤退抬走傷員 → 俘少 ｜ 崩潰潰逃丟下 → 俘多 ｜ guard 滿 → 俘不下
  ```
- **確定性、非 RNG**（driver-complete：被俘因=敵控地+有餘力，非憑空）。兩 LOD 同語意、LOD 適配實作，非硬塞單函式。
- **修 (a) 上游真因**：NPC 吸收從「近全滅才觸發」改「失能者被俘（潰逃留下的 wounded）」→ 戰鬥決勝不再需殲滅 → 征服 pay。**「決勝在潰逃非對撞」**：潰得越慘、控地越徹底、俘越多。
- **#3 E-2 投降** = 失能-capture 的士氣版（整隊士氣崩→降→被俘），後續豐富。**否「放寬決勝門檻」**（那是全滅端，反失能-capture、反個體不自殺）。

**存儲統一**：encounter 俘虜（`prisoner_population`）+ NPC captive → **同一受控人力 captive 表示**（受控狀態欄），非兩個池。

## 4. 受控狀態欄（子團 ↔ 主團 軌跡）

一個 **受控狀態欄**（free / captive / slave / conscript / mercenary）掛在 subteam（跟隨子隊）/anon cohort 上。複用既有「被吸收 anon → 跟隨子隊」。**非奴隸特例 class**。

```
entry → 子團（受控狀態≠free）  ← 低信任、隔離、看管
  ├─ 同化（厚待 + 忠誠過閾）→ 併入主團：anon→主團 free pop / named→named_member
  ├─ 暴動（民怨高，複用 event_unrest_split/replace）/ 逃 / 贖 / 屠 → 離開
  └─ slave/merc/conscript = 鎖該狀態，不放行同化（除非改狀態）
```

**子團 = 持有狀態，主團成員 = 同化狀態；待遇推移動。** 一開始都子團（不信任者不入核心），同化是併入主團的閘。

## 5. 待遇 = 意圖驅動決策（means-end）

leader 秤 屠/招降厚待/贖/賣/奴役/釋放/拷問… driver=服務意圖（征服→吸收厚待壯大、致富→贖/奴役、要情報→拷問、威懾→屠）。待遇逐時改 loyalty/unrest/stress。
- **LOD**：named 俘虜個別決；anon 批次 default。
- **零新政策系統**——待遇只是更多 affordance，跟攻擊/貿易同框。

## 6. 跨域待遇 affordance 槽（高階功能的家）

受控的人 = **多域資源**；待遇 affordance 效果可伸進別域：
```
拷問   → G3 情報（抽 claim，但受刑者可能餵假料 → G3 識破照套）
奴役   → 經濟（強迫勞動產出）
人質質子 → 外交（脅制敵派系、嚇阻攻擊）
策反洗腦 → entry 通道（敵 named 轉我）
公開處決 → 威懾/口碑（鎮民怨 or 激 feud）
招降   → 兵力成長（(a) 那條）
```
- **架構備此槽**，免未來 patch。
- **每個跨域 affordance 被目標域 gate**（affordance 真實性 invariant）：目標域沒到 = 孤兒，不掛。拷問需 G3、人質需外交、奴役需經濟。

## 7. OUTCOME + stakes

- 忠誠高且久 → 同化｜民怨高 → 暴動｜低忠+機會 → 逃｜贖/賣 → 交易退出｜屠 → 移除(口碑/feud 代價)。
- **stakes**：guard-cap（關俘耗守衛 → 上限 → 逼決策別囤）｜救援（原派系來救 → 觸 feud）｜暴動風險 = 持有數 × 待遇苛度。

## 8. ★ (a) 攀爬 怎麼解（本系統的首要交付）

- 征服 → 吸收敗方 **anon pop**（強迫類、低忠 captive 子團）。
- **同化才算數**：厚待 → 同化 → 併主團 free pop → 算攀爬 pop → 兵力長 → 爬。
- **征服只有「消化」才 pay**（光持有不長兵力，苛待→暴動/逃）。逼出待遇決策、真實（吞下要消化得了）。
- → 征服 pay → means-end 選征服 → pop 累積通 → 出征服者。
- **rung2→3 卡（T32）= 獨立另案**（野心階梯轉換，不在本系統）。

## 9. 複用（多半 wiring 既有，非新造）

loyalty_bank（Pattern B 忠誠）/ event_unrest_split·replace（暴動）/ anon_tier（pop·LOD）/ subteam_system（跟隨子隊）/ means-end（決策）/ 投靠·recruit（既有通道）。本系統 = wiring 既有 + entry→初始忠誠 + 受控狀態欄+軌跡 + outcome 閾值 + guard-cap/救援 stakes。

## 10. 不變量

- **driver-complete**：待遇有 driver（服務意圖）；一個人的忠誠**追得回（entry-condition + 待遇史）** = provenance。接「凡 state 變化必有可解釋來源」。
- **affordance 真實性**：同化/暴動/逃/跨域效果要真模擬，非 flag。跨域 affordance 被目標域 gate（孤兒不掛）。

## 11. Build 分階（設計一體、build 分階）

```
Phase 1：anon 吸收通道 + 受控狀態欄 + 批次待遇 + 同化/暴動/逃 核心（解 (a)，純 anon，零跨域）
Phase 2：named 俘虜戲（個別招降/贖/屠 + feud/關係）+ 其他 entry 通道 fold（投靠/招募/徵召）+ stakes（guard-cap/救援）+ 待遇 richness
Phase 3：跨域待遇 affordance（拷問→G3｜奴役→經濟｜人質→外交｜策反→entry），各 gated by 目標域
```

## 12. 驗收

- **(a)**：戰國 seed CONQUER 0→小正、吸收後同化 pop 累積、climbers 兵力長（配 rung2→3 另修可爬 rung3）、**不 over-war**。
- **believability**：苛待→暴動/逃（非白吃）、厚待→同化、guard-cap 逼決策、救援觸 feud、奴役換產出但高叛亂。
- **driver-complete**：忠誠追得回 entry+待遇。
- **守恆**：pop 守恆（吸收=轉移非憑空增）；coin_eq delta=0；1000+ tick 無錯。

## 13. 給系統 HOW（移交重點）

- 受控狀態欄 schema（掛 subteam/cohort）+ 軌跡轉換（同化/暴動/逃，閾值 TEST VALUE）。
- entry deposit：5 類 condition → 初始忠誠/狀態。Phase 1 只接 吸收（征服 npc_combat 後）。
- 待遇 affordance 進 means-end（option 集擴充，跨域 gated by 目標域）。
- 同化 = anon cohort 併主團 pop（複用 anon_tier 晉升路徑）/ named 晉 named_member。
- guard-cap/救援/暴動 wiring（救援接 feud、暴動接 unrest_split）。
- measure-first、TEST VALUE 戰國 seed 校（CONQUER 0→小正、不 over-war）。
