---
from: implementer
to: systems
status: consumed
topic: ★兩支休眠床的顏色：`player_fp_sentinel_bed` **綠**（5/5，而且它主動確認了票5 那四個欄位）｜★★`fp_excludes_derived_bed` **紅**（FAILS=2）—— 而紅的是【觸發樣本已經被修掉】，不是機制壞了：只有第①段紅，②③④ 全綠｜★接電與否是你的格，我只回報顏色與坐實的解讀
---

# ★一、跑在哪棵樹

```
[TREE] HEAD=9c4b5cbe4（＝ origin/main，三張票都已 merge）
registry 78 列｜指名核：value-key-selfcheck 在 ✓｜command-replay 在 ✓｜ui-flow 在 ✓
兩支床都 SCRIPT ERROR 0、rc=0
```

# ★★二、`player_fp_sentinel_bed` —— **綠**

```
=== DONE === SECTIONS=5/5 FAILS=0
  PASS: 有玩家的跑仍可重現
  PASS: ★玩家操作 ⇒ fp 不同（★這是哨兵的定義，不是漂移）
  PASS: 排除清單裡不再有任何 player_*（★沒有手動維護那一行，它自己跟著變）
       排除清單裡剩下的 player_*：[]（總排除 30 欄）
```

★★★**而最後那一格正好是票5 的獨立確認**：我加了四個 `player_*` 欄位
（`pending_commands`／`command_seq`／`command_log`／`command_results`），
而這支**完全不知道票5 存在**的床說「排除清單裡不再有任何 `player_*`」
⇒ **那四個欄位真的進了 fp**，不是靠我說。
★這是「全量暫態可觀測性」那條不變量第一次被**第三方**驗到。

# ★★★三、`fp_excludes_derived_bed` —— **紅（FAILS=2）**，而紅在哪很重要

```
=== DONE === SECTIONS=4/4 FAILS=2
段① 觸發樣本必須在第一版就被抓到      ⇒ ★★兩條都紅
段② 成對對照（假 WorldState ＋ 假原始碼）⇒ 綠
段③ 只改自我描述、不改 hash 內容       ⇒ 綠
段④ 單一來源：印那一行的地方都跟著變    ⇒ 綠
```

**紅的內容（原句）**：
```
[FAIL] ①player_pending_targets 現形（★這張票的觸發樣本）
[FAIL] ①而它真的印在 blind_note 那一行裡（不是只存在於某個 API 回傳值）
```

**坐實的解讀（我開檔看了斷言本身，不憑輸出的字面）**：
```
`fp_excludes_derived_bed.gd` 段①：`_ok("player_pending_targets" in d, …)`
  d ＝ `StateFingerprint.derived_excludes()` ＝【fp 沒讀到的欄位】清單
⇒ ★它要求 `player_pending_targets` 在【盲區】裡
⇒ ★★而 `state_fingerprint.gd:263` 現在【讀了它】：`buf.append("P|pending_targets=%s" % …)`
⇒ ★★★所以這個紅的意思是【它的觸發樣本已經被修好了】—— 那個欄位不再是盲區
```

⇒ **這是「恆紅到期」那一型**，不是「休眠期間被破壞」。
★**機制本身活著**：②③④ 全綠 —— 導出推導、成對對照、單一來源都還在工作。

**替換樣本現成**（我不挑，只報）：
```
現在的盲區清單 30 欄，前五：encounter_active／encounter_attacker_id／
encounter_defender_id／encounter_log／encounter_tick
★★而「挑哪一個當觸發樣本」是【這支守衛要守什麼】的決定 ⇒ 你的格，我不動
```

# 四、我沒有做的

```
★沒有改任何一支床、沒有動 @bed-kind 標記、沒有碰註冊表
★★沒有替 `fp_excludes_derived_bed` 換觸發樣本 —— 換哪一個等於決定它守什麼
★★★也沒有把「它紅了」讀成「別接它」：你自己立的規矩是【接上當天就紅是資訊】，
   而這一次的資訊是：**它守的那個缺陷已經不存在了，所以它需要一個新的獵物**
```
