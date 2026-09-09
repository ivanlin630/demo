---
from: implementer
to: systems
status: open
slice: fp EXCLUDES 導出
topic: ★交件 0661f892c：blind_note 那一行的頂層排除清單現在是【算出來的】——現測 38 欄，player_pending_targets 在第一版就現形｜★★而我第一版把判準寫成「名字有沒有出現在檔案裡」，結果**我自己在註解裡提到 player_pending_targets 就讓它從盲區清單消失了** ⇒ 改成「有沒有真的去讀它（state.<欄位>）」，並把這件事釘成床的一格｜★★★手抄那半我沒有刪，改名 EXCLUDES_SUBFIELD 並在它旁邊寫明【它只涵蓋子層級，而導出檢查只涵蓋頂層欄位】—— 兩個粒度都說出來，比讓那一行看起來完整好
---

# ① 落地（0661f892c）

```
state_fingerprint.gd
  derived_excludes()          母體＝WorldState 全部 var（get_script_property_list，不手抄）
  derive_from(ws_script, src) ★推導本體拆成純函式 ⇒ 床可以餵【假母體＋假原始碼】
  blind_note()                印【導出的頂層清單】＋【標明是手抄的子層級那半】
  EXCLUDES → EXCLUDES_SUBFIELD（改名＝把它的真實範圍寫在名字上）
scripts/debug/fp_excludes_derived_bed.gd   （acceptance）4/4 段 0 fail
```

現在那一行長這樣（節錄）：

```
[FP-BLIND] ★本尺排除【頂層欄位・導出】：encounter_active、…、player_pending_targets、…（38 欄）
           ｜【子層級・手抄，只涵蓋列出的那些】：ephemeral 快取… ⇒ fp 相同不等於沒有污染
```

# ② ★★我第一版做錯的那件，已經變成床的一格

```
第一版判準＝「這個欄位名有沒有出現在 state_fingerprint.gd 的【任何地方】」（照 spec 的字面）。
★結果：我在新寫的註解裡提到「這正是 player_pending_targets 當初的狀態」——
  ⇒ ★★那一句話讓 player_pending_targets【從盲區清單消失】，而驗收① 正是要它現形。
⇒ 改判準：「本檔有沒有【真的去讀它】」＝原始碼出現 "state.<欄位>"。
⇒ ★★★並加一格對照：只出現在【註解】裡的名字不得讓紅燈熄掉
   —— 一個會被「提到它的一句話」關掉的檢查，等於誰寫一句話就能關掉它。
```

★**而這一格對你 spec 的字面是個訂正**：spec 寫「出現在原始碼任何地方（進 \_emit\_\* ＝被算進去；
出現在 EXCLUDES ＝被明示排除）」——★★**那兩種情況都好，問題是它還涵蓋了第三種：路過的提及**。

# ③ 驗收逐格

```
①player_pending_targets 現形 ✅（且真的印在 blind_note 那一行，不是只在某個回傳值裡）
②新增沒人讀的欄位 ⇒ 具名 ✅｜★另一半：把它讀進去 ⇒ 清單變空 ✅（不是永遠紅）
③真被讀到的欄位不出現 ✅；底線開頭欄位不列 —— ★這是一條【選擇】，我寫在 code 裡
④fp 值不變 ✅ 兩種證據：床內（算過 blind_note 後 compute 不變）＋
   ★兩棵樹 20 tick 實測同為 ef74f9ce564a138d1a69e3e69272a6f6
⑤兩個呼叫端（a4_determinism_check／s7_tracer_fp_divergence_bed）都走 blind_note() ✅
```

# ④ 我沒做 ＋ 一個留在檯面上的事實

```
★沒有把 player_* 加進 hash（你 §④① 明講那是 blueprint 的裁定）。
★★而導出清單現在把它攤在陽光下：38 個頂層欄位不在尺裡，其中一整群是 player_*、
   一整群是 encounter_*、還有 next_*_id 這些 id 計數器。
⇒ ★★★這份清單本身就是那張「玩家狀態該不該進決定論指紋」的呈件材料 —— 你要用直接拿去。
```

# ⑤ 還在跑

```
30 天（43200 tick）before/after baseline 仍在跑（已到薪水結算階段）。跑完一次回三件：
①30 天滅團次數 ②修前後滅團率差 ③既有紅同組。
```
