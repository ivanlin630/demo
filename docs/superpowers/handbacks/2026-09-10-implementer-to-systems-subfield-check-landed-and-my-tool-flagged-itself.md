---
from: implementer
to: systems
status: open
slice: fp 子層級導出檢查（R² 兩格已補）
topic: ★交件 137fb7b62：兩格都補了 —— 判準綁【型別相符的那個變數】(R²(3))＋登記表本身也導出(R²(1))，床 5/5 段 0 fail｜★★而床第一次跑就抓到一件事：**我把切函式本體的 helper 命名為 `_emit_body`，於是它被「static func _emit_」掃到、變成一支【未登記的 _emit_*】** —— 我的工具誤報我自己，改名 `_slice_fn_body`｜★★★數字：TeamData 尺內 30／沒看到被讀 97，而 HexTileData 那 34 欄裡有 apothecary_level／mint_level 這種【會影響產出】的設施等級 —— 那是【發現】不是我要修的（本票只讓它們具名）
---

# ① 兩格 R² 要求的補完

```
(1) 登記表本身也導出：emit_registry_gaps() ＝ 本檔所有 static func _emit_* × 已登記 ⇒ 差集具名
    ★兩支【明示不適用】：_emit_belief／_emit_player（序列化裸 Dictionary，無 class_name 背書）
    ⇒ 現況：未登記 ＝ 0；★★母體地板一起驗（真的掃到 7 支，空母體不得判綠）；
      ★★★登記 5 ＋ 不適用 2 ＝ 7 ⇒ 沒有第三種狀態。
(2) 判準綁型別變數：先從函式本體抓 `var X: <該類>`，再組 "X.<欄位>"
    ⇒ 床有一格：`other.beta` 不得讓 `Fake.beta` 被算成讀過了。
    ★而【抓不到型別變數】時回「本類不可判」——★★不偷偷降級成寬鬆比對
      （判不了要說判不了，這是今天第 N 次用同一條）。
    ★★★WorldData 沒有型別宣告（一律 state.world.<欄位>）⇒ 走 accessor 欄，
      且它的欄位散在 _emit_world 與 _emit_tiles 兩支 ⇒ 這一類用整份原始碼。
```

# ② ★★我的工具誤報我自己（床第一次跑抓到）

```
我把「切出某支函式本體」的 helper 命名為 _emit_body
⇒ ★它自己就符合「static func _emit_」⇒ 被 emit_registry_gaps 掃成【一支未登記的 _emit_*】。
⇒ 改名 _slice_fn_body，並把這句血證寫在它旁邊。
★★形狀：**一個用【命名前綴】當母體的檢查，會把【自己的工具】也算進母體。**
   （今天你們記過的「列舉要挑引擎決定的軸」是同一族：我挑的是【我自己也能取的名字】。）
```

# ③ 現況數字（★三桶相加 ＝ var 總數，每一類都沒有第三種狀態）

```
類           尺內  字串鍵  ★沒看到被讀   總數
TeamData      30     0        97        127
PersonData     7     0        19         26
FactionData    7     0        15         22
HexTileData    8     1        34         43
WorldData      2     0         7          9
★第三桶（字串鍵）是【量出來的】不是設計的：farming_level 走 t.get("farming_level")
  ⇒ "<變數>.<欄位>" 看不到它 ⇒ 自成一桶，★★不併進尺內（併進去會隱藏一個真的缺口）。
```

★**而清單裡有一群我要指名給你看**（本票不修，照 §④①）：

```
HexTileData 那 34 欄裡有：apothecary_level／mint_level／armorsmith_level／manufacturing_level…
⇒ ★這些是【設施等級】，而設施等級影響產出 ⇒ 它們不在 fp 裡
⇒ ★★對攻擊門那張票的意義與你排這張票的理由完全一致：
   **一個會改動據點/生產的大票，若拿 fp 當證據，這 34 欄的變化它看不到。**
⇒ ★★★而我不判它們該不該進 fp（有些可能是衍生值）—— 這是逐欄的判斷，交你排。
```

# ④ 驗收逐格 ＋ 誠實限

```
①清單是導出的：假類假本體對照（讀進尺內／沒讀具名／讀了就離開）✅
②不得亂紅：population／current_task／tile_pos／resources／recent_failures 都沒被誤判 ✅
③★提及 ≠ 讀取：註解裡的 t.gamma 仍留在排除清單 ✅（★★而這一格第一次跑是【紅的】——
   我把剝註解放在只有真實檔案會走的那支 helper 裡 ⇒ 保證沒有跟著判準走
   ⇒ 改成在 derive_subfield_from 內部剝，★★★保證要跟做判斷的那段 code 住在一起）
④blind_note 兩個粒度都印、且「三層以下看不到」那句住在輸出裡 ✅
⑤fp 值不變（2fa046add9b0bc7219046b8ef86bfd4a）✅
⑥每類三桶相加 ＝ var 總數 ✅
★誠實限：①本尺仍看不到【第三層】（dict 內部的鍵）②經 helper 間接讀到的欄位看不到
  ③字串鍵那一桶要人眼判（它可能是欄位讀取，也可能只是同名的 dict 鍵）。
```
