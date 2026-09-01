---
status: DRAFT(機制段可審;★表值留參數位,等 build-eta 實測回來才填)
owner: systems
slice: S6-build-duration-table
what: 2026-08-20-time-reanchor-tier-design.md §3c（用戶核可）
authority: ★blueprint 2026-09-01 分層——用戶 WHAT ＝【相對意圖】（全面變慢 4~8×、紮根＝數天級真機會成本）;
           ★★絕對人時數 ＝【推導產物】，證偽後照「真舊 × 4~8」重推導、重簽 blueprint 即可;
           ★★★動到「紮根 72 人時」這顆錨的【語意本身】⇒ 呈用戶。
---

# ★★★§0 前置：單位真相（★擋住表值，機制段不受阻）
```
sim_runner.gd:7    NEAR_CADENCE = WorldState.TICKS_PER_HOUR
outpost_system.gd:113  build_ticks_per_day() = TICKS_PER_DAY / NEAR_CADENCE
                       ★換根前 240/10 = 24 ／ 換根後 1440/60 = 24 ⇒ ★★每日 24 次,不隨根變
outpost_system.gd:311  _tick_construction 每呼叫扣 maxi(pop, 1)
⇒ ★1 個 `ticks` 單位 ＝ 1 person-hour ⇒ farm 72 = 3 天（★★code 註解 :48 自述「farming 72 ≈ 3 天」✓ 自洽）
```
★**而 §3c 表寫「農田舊 7.2 人時」＝ 0.3 天** ⇒ ★★**差 10 倍，實測票已派**（`build_eta_single_source_test`）。
★★★**表值在實測回來前留【參數位】；以下機制段不依賴表值。**

---

# ★★§1 機制一：**單位正典化 —— `ticks` 這個名字在說謊**
```
現況：outpost_system.gd:24  BUILD_TICKS            （據點）
      outpost_system.gd:51+ FACILITY[*].cost.ticks （設施）
      outpost_system.gd:125 build_eta_days(ticks_left, pop)   ←★連參數名都說謊
★三處的單位【都是 person_hours】,而三處都叫 ticks
```
★**改名 `person_hours`（欄位、常數、參數）** —— ★★**這不是美觀：它是【病6 命名說謊】的同族**，
★★★**而今天已經證過那一族的危險——名字會在換根/換 cadence 時把人騙去改錯東西。**
★**純改名，零數值變動**（fp 必須逐位元不變 ⇒ 這是本段的驗收）。

# ★★§2 機制二：**一顆錨推全表（★禁手抄）**
```
★唯一數字 ＝ 紮根當量尺 SETTLE_PERSON_HOURS（值待定，見 §0）
★★其餘全是【倍數】：紮營 ⅓ ／ 農田 ½ ／ 工坊·藥坊 ×1 ／ 馬廄·熔爐·武坊·甲坊 ×2
                    ／ 鑄幣 ×4 ／ 據點 L2 ×3 ／ L3 ×6（★倍數＝設計，來自 WHAT §3c，不動）
★★★寫法：const FARM_PH := int(round(SETTLE_PERSON_HOURS * 0.5))  —— 不得寫死 36/72/144
```
★**理由是用戶立法**（`feedback_no_handcopied_physics`）：**估值必須同源推導**。
★★**而這裡的「同源」是【錨】** ⇒ ★★★**改工期＝改一顆錨，不是改八個數字**——**否則下一次改，又會漏掉其中三個。**

# ★★★§3 機制三：**工地取消 ＝ k × 預期工期（相對錨定）**
```
現況：outpost_system.gd:31  CONSTRUCTION_TIMEOUT = 30 * WorldState.TICKS_PER_DAY   ←★絕對值
WHAT：「工地取消 = k × 預期工期（相對錨定）自動跟」
新法：timeout_days = clampf(k * build_eta_days(初始 person_hours, ★動工當下 pop), FLOOR, CEIL)
```
## ★★★而這裡有一個會把守衛變成廢物的陷阱，我先寫死
```
★若用【即時 pop】算預期工期：pop 掉到 0 ⇒ 預期工期 → ∞ ⇒ ★★timeout 永不觸發
⇒ ★★★而 CONSTRUCTION_TIMEOUT 的註解自述它是「防永久卡死黑洞」—— ★黑洞會原樣回來
⇒ 硬條款：pop 取【動工當下】並凍結；★★且必須有 CEIL（上限），FLOOR 防短工地秒取消
```
★**`build_eta_days()` 已經是「六個估值點的唯一入口」**（`:125`）⇒ ★★**timeout 走它，不另算一份。**

# ★★§4 機制四：**雙軌對帳（WHAT 明列「審計必查」）**
```
★列出【所有】讀工期的地方，逐處標它讀的是新表還是舊制：
  decision_context.gd:389/392（建置成本攤提）／goal_resolver.gd:913（估算）
  faction_ai_system.gd:4129/4133（ETA_total）／:5086 SURVIVAL_BUILD_MAX_TICKS/:5133 預設 72
  outpost_system.gd:486/509/586/615/617/625/717/770／player_command_system.gd:9/239/242
★★窮盡搜索（不 head 不 glob）,每處標【新/舊/不適用】,並對帳總數
★★★特別查 :5086 SURVIVAL_BUILD_MAX_TICKS 與 :5133 的預設值 72 ——
   它們是【拿工期當門檻】的地方,工期一改它們的語意就變,而它們不會報錯
```

# ★§5 驗收（★每條寫下【怎麼會失敗】）
```
①改名段：fp 逐位元不變 ★失敗長相＝fp 變了 ⇒ 改名不小心改到值
②錨推表：把 SETTLE_PERSON_HOURS 改一個值 ⇒ ★全表八項【全部】等比例跟著變
   ★★失敗長相＝有幾項沒跟 ⇒ 那幾項是手抄的
③timeout：★造一個 pop 中途歸零的工地 ⇒ 仍必須在 CEIL 內取消
   ★★失敗長相＝永不取消 ⇒ 用了即時 pop
④雙軌對帳：★讀工期的處數合計 == 窮盡搜索的處數（不平 ＝ 有一處沒被分類）
⑤★★★世界層：S6 前後跑同床同 seed，工期相關量的變化【方向】必須與最終裁定一致
   （慢就要真的變慢）—— ★基線 before 腿已在 `S6-baseline-before.measure.json`（commit 1af956fa）
```

# ★⑥不做的事
```
★不改倍數（倍數是 WHAT，用戶核可）
★★不動「紮根＝數天級真機會成本」的語意（★動到就呈用戶，不是我裁）
★★★不在本票順手修病3 MOVE_TILES_PER_DAY —— 同族但另票（接線病）
```
