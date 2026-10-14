# 顧問讀信念＋文本外置試點 — HOW

> systems 2026-10-15。
> WHAT 來源：
> - 意圖帳「顧問讀信念不擲骰」列（mechanism-intents.md:110）
> - 影子 note `docs/notes/2026-10-13-annihilation-advisor-trade-prisoners.md` §2／§2a／§2b
> - 藍圖排位信 2026-10-14 roadmap-board §4
> - 藍圖歸票信 2026-10-14 live-play-findings 第 6 條（交換畫面資源名＝鍵→顯示名層的第一個客戶）
>
> 位置：玩家可見批，游標即選中之後、第 7 張之前。

## 現況（file:line，本輪已讀）
- `advisor_system.gd` 共 87 行。
  - 準不準靠 `randf() < 技能`（:37）；錯了再擲一次 `randf() < 0.5` 選錯法（:59）。
  - 句子自己知道自己錯：TextBank 有 `wrong_*`／`biased_*` 句。
- 唯一呼叫點 `sim_bridge.gd:573 query_advisor_advice` 傳空 dict。
  - 敵我人數、敵意、糧天數全沒餵，句子裡的 `{enemy_pop}`／`{days}` 印成字面。
  - ★它是 UI 直接呼叫，卻耗用全域 RNG ⇒ 玩家「問一句」會改變世界的亂數序列（觀測改變被觀測物，同族血證見 memory「觀測儀器禁耗 global RNG」）。
- UI：`text_ui_main.gd:3438-3470`。顧問模式選人後開數字選單（情境＝`menu_situations()`，只有 3 個有模板）。結果走 `_log_event("[Advisor] 建議…")`＋結果行，不進世界事件。
- 模板 `text_bank.gd:51-89`。
  - 情境分析三組共 15 句。
  - 「主動警報」三組（food_critical／enemy_approaching／faction_betrayed）**全站零呼叫者**（grep 只命中 text_bank 本身）。note §2a「現有 3 組主動警報照留」的前提不成立，本票不碰它們，見 §範圍外。
- known_issues「顧問 strategic／intel_read 兩種情境沒有文字模板」：本票關。
- 交換畫面 `text_ui_main.gd:3641-3685 _build_trade_str` 直接印 `row["grade"]` 與出價的 key（`food`、`weapon_melee_low`…）。
- 資源中文名今天有**兩份**：
  - `ObserverEventText.RES_NAMES`（全名，20 鍵，與 `TeamData.resources` 預設鍵同集合）
  - `TeamUiHelper.RESOURCE_NAME`（短名 4 鍵：食／幣／材／貨）
  - 另有 `TeamUiHelper.ITEM_NAME`（低階／高階近戰武器…）與 RES_NAMES 的「粗製／精製」**用字衝突**，見 §範圍外。
- 決定性雜訊已有：`PathSystem.observation_noise01(tick, observer_id, target_id)` 走雜湊、零 RNG。另有 `BeliefSystem.observation_noise(base, skill)` 把技能換成雜訊幅度。

## 一、顧問讀信念（不擲骰）

### 1a 入口：一道玩家指令，不是 UI 直呼
- 新動詞 `ask_advisor {advisor_pid, situation, target_id}` 進 `PlayerCommandApi.VERB`／`dispatch`／`describe`。照例走 `command_player`（入列＋推進 1 tick，與打聽同形）。
- 理由：ledger 要求「出一則事件」，事件寫進世界狀態 ⇒ 只能在 sim 裡寫。UI 直呼＝今天那條改世界亂數的路。
- 刪 `sim_bridge.query_advisor_advice` 與 `_log_event("[Advisor]…")`，結果只走一條路：`command_results` ＋ 事件。
- 前置（handler 內，不在入列時）：
  - 附身隊存在。
  - `advisor_pid` 是附身隊活著的成員（顧問在身邊＝感知鐵律的 proximity）。
  - situation ∈ 五情境。
  - 需要目標的情境，`target_id` 在附身隊的 belief 裡。
  - 不過 ⇒ ok:false＋理由句。

### 1b 五情境各讀什麼（★全部只讀附身隊自己的帳）
| 情境 | 技能 | 讀 | 目標 |
|---|---|---|---|
| assess_enemy | 戰術 | `BeliefSystem.best_claim(附身隊, tgt)` 的 `population_est`、`estimate_armed(bel, pop_est, 顧問.values)`。己方用自家真值（自知合法）：武裝人數＝與遭遇戰同一支己方武裝計數，實作端交件信列出用了哪支。 | 要選 |
| diplomatic | 交涉 | 附身隊 `known_reputations.get(tgt, 0.5)`。加上：附身隊成員的 `relation_edges` 有沒有對 tgt 隊長的 feud 邊（自家人的仇＝自知）。 | 要選 |
| resources | 生產 | 糧撐天數。★與頂列同一支：`PlayerApiMapper._food_days` 改公開為 `food_days`，兩處都呼它。 | 無 |
| strategic | 計謀 | 已知敵對隊。★把 `map_threat_line` 那個 best_estimate 迴圈抽成 `PlayerApiMapper.threat_scan(state) -> {enemy_id, enemy_d, enemy_n, beast_id, …}`，威脅欄與顧問都呼它（一個身體；P5「本函式體內 best_estimate 呼叫＝1」那條守衛改指向 threat_scan）。 | 無（取最近敵對） |
| intel_read | 偵查 | 附身隊所有 claim 裡**最新一筆非親見**（`!PlayerQueryApi.is_firsthand`）的 `effective_credibility`。 | 無（取最新傳聞） |

- 目標選單：assess_enemy／diplomatic 選完情境，再開第二層數字選單。
  - 列附身隊 belief 裡、未過期（`BeliefSystem.belief_stale`）的隊，最多 9 個。
  - 排序與情報頁隊伍類同一個（位置 tick 最新在前）。
  - 走既有 `_open_input` 數字選單，不開新輸入態。
  - 沒有可選 ⇒ 不開第二層，直接以「不知道」入列（target_id=-1）。

### 1c 準不準＝雜訊，偏頗＝偏移（★零 RNG）
- 估計值 `x'` ＝ `x × (1 + (2u − 1) × amp)`：
  - `u = PathSystem.observation_noise01(tick, advisor_pid, salt)`。
  - salt＝target_id；無目標的情境用 `-(情境序號+1)`。
  - `amp = BeliefSystem.observation_noise(0.0, 顧問該技能)`。技能 1.0 ⇒ 0；技能 0 ⇒ `OBS_SKILL_NOISE_GAIN`。
  - 同一 tick 問同一件事，答案相同；隔 tick 可不同。
- 人格偏移：`bias = (好戰 − 慎重) × ADVISOR_BIAS_GAIN`（新具名常數，TEST VALUE 0.3）。
  - assess_enemy／strategic：敵方估計 × (1 − bias)。好戰者看敵人小。
  - diplomatic：名聲 − bias × 0.5。好戰者看人更敵意。
  - intel_read：可信度 − 慎重偏移。（慎重 − 0.5）× ADVISOR_BIAS_GAIN 往下壓，慎重者更多疑。
  - resources：不偏移（ledger 只寫了戰事方向的偏頗），只有雜訊。
- 判斷帶（優／均／劣）從**偏移後的數字**算，不另寫鷹派句：
  | 情境 | 優 | 劣 | 其餘＝均 |
  |---|---|---|---|
  | assess_enemy | 己方武裝 ÷ 敵估 ≥ 1.3 | ≤ 0.77 | |
  | diplomatic | 名聲 ≥ 0.6 且無 feud | ≤ 0.4 或有 feud | |
  | resources | ≥ 10 天 | < 5 天（沿用舊句門檻） | |
  | strategic | 最近敵對 > 視野 2 倍 | 最近敵對在視野內且 assess 判劣 | |
  | intel_read | 可信度 ≥ 0.6 | ≤ 0.3 | |
  - 帶寬全是具名常數（TEST VALUE），放 AdvisorSystem 檔頭。
- 「不知道」：需要目標而 `best_claim` 空、或 `BeliefSystem.uncertainty ≥ ADVISOR_UNKNOWN_U`（0.8）、或 strategic 已知敵對 0 支、或 intel_read 沒有任何非親見 claim ⇒ 印「不知道」句。
  - ★它不是失敗：ok:true、事件照發，依據欄寫「無」。
- 刪：`_advice_is_accurate`、`_pick_variant`、兩處 `randf()`、TextBank 的 `wrong_*`／`biased_*`。

### 1d 出口：一則事件＋結果句
- `world_events.emit(state, "advice", [附身隊], false, info)`。
  - info＝{advisor, situation, target, text, basis:{source_word, source_id, tick}}。
  - `describe` 加 `advice` 分支 ⇒ 回 info.text。
  - 不進 ADVANCE_STOP_KINDS（是你自己這道令的回音）。
- `command_results` 帶同一句 text ⇒ 結果行「{顧問名}：{text}」。
- 依據：`source_word` 與情報頁同一個分類（親見／聽說，來自 TeamN）。
  - 該分類若能分出「打聽」寫入的 claim ⇒ 三個來源詞；分不出 ⇒ 兩個，交件信列出。
  - 「幾天前」＝ `(now − claim.tick) / TICKS_PER_DAY`，不到一天印「今天」。
  - 自知類（resources）依據＝「自家帳」。

## 二、文本外置試點（advisor.tsv＋names.tsv）

### 2a 檔與讀法
- `data/text/advisor.tsv`、`data/text/names.tsv`，UTF-8，每行 `鍵<TAB>變體<TAB>句`，`#` 開頭為註解。
- `TextBank` 加 static 快取：第一次 `fmt` 時讀 `EXTERNAL_FILES` 列的檔。
  - 同一 (鍵,變體) 在檔裡與 `TEMPLATES` 同時存在 ⇒ `push_error`（第二份真相），床也紅。
  - 外置過的鍵從 `TEMPLATES` 刪掉。
- `fmt(type, variant, params)` 介面不變：先查外置表，再查 TEMPLATES，最後預設句。

### 2b advisor.tsv 內容（≈28 行，草稿，句子可由藍圖／用戶直接改檔）
- 鍵 `advisor_<情境>`，變體 fact／good／even／bad（5×4＝20 行）。
  - 例 assess_enemy fact：「{target}約 {pop} 人，{armed} 人帶兵器——{source}，{age}。」
  - 例 good：「我們佔上風。」
- 鍵 `advisor_tone`，變體 default／blunt／formal／sarcastic（4 行，全情境共用的語氣尾）。
  - 選法沿用今天的 `_advisor_tone`（呈現層，不是決策閘，藍圖 2026-09-09 裁）。
- 鍵 `advisor_unknown`，變體 default（1 行）：「這我不清楚，沒人去看過。」
- 鍵 `advisor_source`，變體 親見／聽說（／打聽）（2–3 行）。
- 組句：fact ＋ 判斷句 ＋ 語氣尾；不知道時＝不知道句 ＋ 語氣尾。

### 2c names.tsv（鍵→顯示名那層）
- 鍵 `res.<資源鍵>`。
  - 變體 full：20 行，內容＝今天的 `ObserverEventText.RES_NAMES`，逐字搬。
  - 變體 short：4 行，內容＝今天的 `TeamUiHelper.RESOURCE_NAME`，逐字搬。
- `TextBank.res_name(key, variant="full")`。查不到回原鍵（今天 `resource_name` 的行為，終端自驗 (d) 會咬）。
- `ObserverEventText.RES_NAMES`／`TeamUiHelper.RESOURCE_NAME` 兩個常數刪掉。原呼叫點改呼 `res_name`：`resource_name()` 保留函式名、body 改轉呼。⇒ 兩份變一份，不是第三份。
- 交換畫面 `_build_trade_str`：物品列與出價列的 key 都改印 `res_name(k)`。

### 2d 兩支守衛（同一支床，註冊表一列 `text-keys`）
- **鍵對帳**：
  - advisor：code 端的鍵集合＝AdvisorSystem 的 `TEXT_KEYS` 常數（組鍵只准從它來）。結構 grep：scripts 內除 text_bank.gd 與 TEXT_KEYS 定義行外，零個 `"advisor_` 字面。它與 advisor.tsv 的 (鍵,變體) 兩向相等。
  - names：`TeamData.new().resources.keys()` 與 names.tsv full 兩向相等；short 是 full 的子集。
  - 少一邊、多一邊都紅，紅時印出是哪一個。
- **槽對帳**：
  - 對每個 (鍵,變體)，從句子 regex 取 `{槽}` 集合。
  - 把 AdvisorSystem 組 params 的那一支（`_params_for(situation, …)`，唯一一支）在床的佈置上跑一遍，取它回的 key 集合。兩者相等；多給、少給都紅。
  - names 句無槽，斷言槽集合為空。
- ★不另開「外置總閘」：本票只對帳兩檔；其餘五檔搬的時候把檔名加進 `TextBank.EXTERNAL_FILES`，同一支床就涵蓋（不加第二支閘）。

## 驗收（床 `advisor_belief_bed.gd`＋`text_keys_bed.gd`，修前跑：A1／A2／A6／T3 修前紅）
- A1 三帶：同一目標佈置三組 belief（己方 10 武裝，敵估 5／10／20）⇒ 判斷句分別是 good／even／bad。fact 句的人數＝belief 值經雜訊，不是真值：真值設 40，句子印的落在 belief×(1±amp)。
- A2 不擲骰：同 tick 問兩次句子相同。問之前、之後各取 `randi()` 與不問的對照世界相等（全域 RNG 沒被動到）。
- A3 不知道：目標無 belief ⇒ 不知道句、ok:true、事件依據「無」。strategic 零敵對、intel_read 零傳聞同樣。
- A4 技能：同 belief，技能 0.9 與 0.1 各問 30 個 tick ⇒ 平均絕對誤差前者小於後者（印兩個數）。
- A5 偏頗：同 belief、同技能，好戰 0.9／慎重 0.1 對好戰 0.1／慎重 0.9。前者的敵估 < 後者，判斷帶不劣於後者（印數字）。
- A6 事件：一則 `advice` 進玩家事件流，帶依據（來源詞、幾天前）；`command_results` 同句；畫面不再出現「[Advisor]」。
- A7 選單：五情境都在；目標選單只列 belief 裡未過期的隊。佈置一支真在旁邊、但附身隊沒 belief 的隊 ⇒ 不在列。
- A8 不讀真值：問之後把目標真人口改成 3 倍，同 tick 再問（撥鐘不推進）⇒ 句子不變。
- T1 鍵對帳兩檔綠；T2 槽對帳綠。
- T3 交換畫面：佈置雙方有 food／material／weapon_melee_low／coin ⇒ 面板無 ASCII 資源鍵，印糧食／木料／粗製近戰武器／錢。
- W：無玩家世界 world-fp 不變（電池內）。

### 負對照（同 sha 加一處改動，每支必紅）
| 對照 | 該紅 |
|---|---|
| n1 assess 改讀 `state.teams[tgt].population` | A1 的「不是真值」格、A8 |
| n2 噪聲改回 `randf()` | A2 |
| n3 advisor.tsv 刪一行 | T1 |
| n4 某句多一個 `{槽}` | T2 |
| n5 交換畫面改回印原鍵 | T3 |

## 範圍外（交件信不用做，已記）
- 三組「主動警報」模板零呼叫者：留在 TEMPLATES 不動、不外置。要不要接上歸藍圖（本 spec 送審同時告知）。
- `TeamUiHelper.ITEM_NAME`（低階／高階）與 RES_NAMES（粗製／精製）用字衝突：本票不統一（戰鬥畫面裝備欄用 ITEM_NAME）。藍圖定用字後，搬 encounter_view 那張順便合。
- 其餘五檔外置：照 note §2b，哪張票重寫那檔的句子就順便搬。
- `trust[顧問]`：note 說先不長。

## 交件信要列
- 1b 己方武裝讀哪支（file:line）。
- 來源詞是兩個還是三個。
- A4／A5 的數字。
- threat_scan 抽出後，威脅欄的 E2E 格逐字不變。
