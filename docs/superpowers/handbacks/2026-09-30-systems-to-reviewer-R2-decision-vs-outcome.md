---
from: systems
to: reviewer
status: open
topic: R² 送審：④ 決定 vs 結果【分開講】（`feat/decision-vs-outcome` @ 050573024）——★這一張動產品碼（player_command_system／sim_runner）｜★★而它的鑑別力來源是控制②，不是那 9 個「一致」
---

# 要審什麼

**branch** `feat/decision-vs-outcome` @ `050573024`（remote 同 sha，基底 `1a01dd1cd`）
**檔面**（★我列出來讓你知道邊界，請自己核）：
`scripts/simulation/player_command_system.gd`／`scripts/simulation/sim_runner.gd`（**產品**）
＋`scripts/debug/decision_vs_outcome_bed.gd`／`_controls.py`／`ui_flow_test.gd`／註冊表一列（94 列）。

# 一、症狀與改法

```
症狀（用戶第二輪玩測逐字）：「按 T 還寫我拒絕」
舊句：`回應事件：accept：被拒絕（隊伍已滿，無法收留）`
新句：`回應事件：accept：你選了「收留（食物 -7.2,+9 人）」，但隊伍已滿，無法收留 ⇒ 沒有生效`
兩處改動（★都不是改措辭，這是我要你核的重點）：
  ①`respond_to_forced` 失敗時把兩半組起來：
     ·我的決定 ← `_label_pre`（＝`PlayerApiMapper.forced_label`，選項自己的 label）⇒ **零第二份中文表**
     ·世界的結果 ← handler 自己的 msg（**不動 handler** —— 那是世界的話）
  ②`sim_runner` 的失敗句抽成 `_refused_text()`，而 `respond_to_forced` 是**具名例外**：
     不再套「被拒絕」（沒有人拒絕玩家，是世界裝不下）；★其餘動詞照舊。
```

# ★★二、我要你咬的三格

```
①★★★**鑑別力在哪**：他報「母體 ＝ 回應集 × forced_event 全部組合 ＝ 9，
  一致 9 ＋ 要修 0 ＋ 不適用 0」。★而「要修 0」若只在修完之後量過一次，它沒有鑑別力
  （恆已達成那一族）⇒ 我要求他把兩道控制各紅哪一格寫上卷面，他寫了：
    ·控制① 把「分開講」那一段整段短路（`if false: pass`）⇒ msg 回到只有世界的結果
      ⇒ 紅在 P1「句子有【我的決定】那一半（『你選了』）」
    ·控制② 把 `_refused_text()` 裡 `respond_to_forced` 的具名例外拿掉
      ⇒ 失敗句又被套「被拒絕」⇒ 紅在 P1「句子【不得】說『被拒絕』」
      ★★而他自己指出控制② 同時是 **P2「沒有任何組合把我的決定說成別的決定」的鑑別力來源**
        （它把 join_request/accept 那一格推回「要修」）。
  ⇒ ★請核那兩句紅的原文真的出自那一輪 RED-OK，而不是事後補寫的描述。
②★「零第二份中文表」是不是真的：`_label_pre` 是否真的來自 `PlayerApiMapper.forced_label`
  （＝選項自己的 label），而不是在 `respond_to_forced` 附近又長出一份對照。
  ⇒ ★★這一格我特別在意：今天已經有一票是「兩份各自等於同一個值也會全綠」。
③★★具名例外的**範圍**：`_refused_text()` 只對 `respond_to_forced` 例外，其餘動詞照舊。
  ⇒ 請核那個例外是**指名**的（說得出是哪一支、為什麼），而不是一個「失敗時不要說被拒絕」
    的通用旁路 —— 後者會讓其他動詞真正被拒絕時也不說「被拒絕」。
```

# 三、我已經核過的（不用重做）

```
·母體是**動態拿**不手抄（回應集）；「不適用」那一欄的兩種理由**就地具名**
  （空回應集／沒有句子）—— 沒有具名它就是一個能把任何不方便的組合掃進去的桶。
·他不 commit 那份人讀清單的理由我裁【對】：在這裡 commit 會把那 41 筆假靜默
  （已知的錯數字）釘進主線；正確落地時機＝床的 TTL 修正 merge 之後用修好的床重跑的那一份。
·★前綴那個 `accept` 還是原樣 id ⇒ 那是票⑤的工作，本票明文不動它。
```

# ★四、我的揭露（請不要當前提）

```
·主線那一輪全電池（battery8，93 格）**還在跑**，world-fp 剛綠（514s —— 記憶體吃緊，
  用戶的遊戲佔 16.8GB ⇒ 比平常慢一倍）。⇒ 「main 現在是綠的」我不當前提。
·本票與床的 TTL 修正（`feat/exploration-bed-ttl-fix` @ 7195dddc4，你判 issues 後他已照裁定
  抽成共用函式並**弄壞一次驗過**：P8 與 P6 一起紅 ⇒ 它們真的讀同一份 code）是兩張獨立票，
  我會**先 merge 床**（它是量尺）再 merge 本票。
```
