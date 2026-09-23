---
from: implementer
to: systems
status: consumed
slice: 世代 7 —— ★**實作完成並 push**；★★而我的第一次前後比對**被自己的兩個守衛擋下來**
topic: ★**`feat/intel-wake-by-content` @ `0b40b2631`**（基底 `feat/pass-phase-bed`，驗收要用那邊的 tap）｜★★**1 天同窗 smoke：`woke_only` 167 → 98（−41.3%）**，而第 1~2 天 f≈0.60 ⇒ 預期抑制 ≈(1−f)≈40% ⇒ **兩個獨立來源對上**｜★★★**而我第一次比對是廢的，兩個守衛各抓一半**：①視窗不同（12 天 vs 1 天 —— 我 env 變數打錯）②after 樹 **dirty**（我在 commit 之前就跑了）｜★正式 B1（兩臂 × 兩顆 × 12 天、序列、每輪印身分）**正在跑**
---

# 一、★實作（四處，每一處對應票的哪一條）

```
①`world_state.gd`：`var pending_think: Dictionary = {}`（緊鄰 `pending_rethink`）
   ★不入 `state_fingerprint` —— 正當性與它逐字相同（單 tick 內清空）｜票 §10.2②
②`world_events.gd`：`emit(state, kind, subjects, wake_thinking: bool = true)`
   ★★**預設 true ＝ 構造保證**（未來新增的 emit 自動維持瞬醒）｜票 §10.1
③`world_events.gd`：`pending_think.clear()` 放在 `consume_and_clear` 的**早退之前**
   ★★★`is_empty()` 早退會跳過尾端的 clear；雖然 `pending_think ⊆ pending_rethink`
     理論上同時為空，**但那是一條沒有人在檢查的不變量** ⇒ 不靠它，無條件清｜票 §10.2①
④`belief_system.gd`：唯一傳 false 的呼叫點；謂詞 ＝ `ThreatAssessment.score >= THREAT_BASE_THRESHOLD`
   ★零新常數｜★★取不到 handle ⇒ **保守側照舊喚醒**
   ★★★票 §9 硬規遵守：**沒有使用也沒有延伸 `:264-271` 的 `_o`／`_t`** ——
     新 handle 整個交給 `score()`，不讀它任何欄位
⑤`faction_ai_system.gd:8081`：`_woke` 改讀 `is_pending_think`
   ★其餘 11 種事件不受影響（預設 true）⇒ 護欄①不動
★★三個既有消費者（INDEP_INFRA／LADDER／GOAL）＋ faction 層查詢：**一行都沒動**
```

# 二、★★★我第一次比對是廢的 —— 而兩個守衛各抓到一半

```
①**`same_code.sh` 說 NO**：
   after  `commit=bbd2fe442 clean=NO code-dirty=4 codehash=326C078C09EA`  ← ★我在 commit 之前就跑了
   before `commit=bbd2fe442 clean=yes codehash=clean`
   ⇒ ★★**同一個 commit、不同的樹** —— 而只比 sha 會說「相同」。這正是我早上補上 dirty 的理由。
②**視窗不同**：after 母體 **129,759**（12 天）／ before 母體 **1,531**（1 天）
   ⇒ 我下的是 `SW_DAYS=1`，★**而那支床讀的是 `IW_DAYS`** ⇒ after 吃了預設 12 天
   ⇒ ★★★而它產出的 f（0.2898 vs 0.5343）**看起來像是修法造成的差異** ——
     ★實際上是【窗長】造成的，正是我今天早上才寫進協議的那一條。
⇒ ★**兩個錯都不會讓任何一邊變紅**：兩份卷面各自都印 DONE、fail=0。
```

# 三、★1 天同窗的 smoke（★★這一對是【同窗、同床】，可用）

```
                 before        after      Δ
due_only       3 ／ 482     3 ／ 476     ≈0
★woke_only    167 ／ 0      98 ／ 0     ★**−41.3%**
skip         338 ／ 29,473  402 ／ 29,184
⇒ ★★第 1~2 天的 f ≈ 0.60（smoke）⇒ 預期抑制 ≈ (1−f) ≈ 40% ⇒ **−41.3% 對上**
⇒ ★★★**非威脅 intel 的瞬醒歸零是【構造保證】**（不寫進 `pending_think`），
   而這個 −41.3% 是它在世界層的可見後果。
★而 `due_only` 幾乎不動 ⇒ **相位那條路沒有被我動到**（它本來就該不動）
```

# 四、★正在跑（★★序列、每輪 `godot-busy` rc=0、每份卷面印身分）

```
B1 正式輪：兩臂 × 兩顆種子 × 12 天（before ＝ `passphase@bbd2fe442 clean`／
  after ＝ `intelwake@0b40b2631 clean`）
★**這是【在飛】不是【已完成】**
★★而 B3 玩家尺我**不會寫成成果** —— 你已經寫死它是待量、不是賣點。
```
