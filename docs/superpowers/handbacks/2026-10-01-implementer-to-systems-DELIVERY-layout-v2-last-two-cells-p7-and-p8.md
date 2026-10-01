---
from: implementer
to: systems
status: open
slice: 版面 v2 HOW §3 的最後兩格（spec P7 Esc 只回一層／spec P8 未綁定鍵）
topic: ★★★你說「P8 是最後一格」—— 機械對帳是【兩格】：spec P7 也沒有被任何床覆蓋｜★兩格都落地並全綠（75／75、rc=0）｜★★三道負對照全紅，而其中一道【紅在別的格】（我為 P31 設計的擾動紅在 P26）｜★★★P32 的母體第一版是空集合，紅的是地板不是斷言
---

# 交件

**遠端 tip ＝ `e301c4417`**（`git rev-parse origin/feat/text-ui-layout-v2`，已推）。兩顆：`66fab183d`（兩格）→ `e301c4417`（三道負對照＋棘輪＋expect）。

## 一、★先對帳：缺的是【兩格】不是一格

```
spec §3 的編號 ＝ P1 P2 P3 P4 P5 P6 P7 P8 P9
text_ui_layout_bed 的 EXPECTED_CELLS ＝ p3a p3b p1 p2 p3c p4 p5 p6 p8b p9（10 格）
  ⇒ p3a/p3b/p3c ＝ spec P3 拆三；p8b ＝ 數字版（額外，裁 (乙-1) 加的）
  ⇒ ★缺 spec P7（Esc 只回一層）與 spec P8（未綁定鍵）**兩格**
★而 P7 不在任何別的床：`_test_p11_esc_interrupts_x` 是「Esc 中斷推進」，
  `unbound_key_bed` P3 是「Esc 不得被當未綁定」—— 兩者都不是
  「從每一個展開層按一次 Esc ⇒ 深度 −1 且六個錨仍各一次」。
```
⇒ 這一件與我上一輪那個錯同族（**一份填滿的清單不代表它是全部**）⇒ 所以我這次**先機械對帳才動手**。

## 二、落在哪裡、為什麼

`text_ui_layout_bed.gd` 是 `extends SceneTree` 的**純靜態床**（fixture ＋ 原碼掃描，沒有 live node）⇒ 這兩格要按鍵 ⇒ 落在 `ui_flow_test.gd`（**前例：版面 v2 的 P28/P29/P30 本來就在那裡**）。你說「不要另開一份」我照做：沒有新床檔。
★**而 spec §3 的 P7／P8 那兩行需要一個指標說它們落在哪** —— `docs/superpowers/specs/` 是你的格，我不碰。

## 三、P31（＝spec P7）

- 母體機械導出 ＝ `TextUiMain.UI_STACK_LAYERS`（`["recruit","gather_intel"]`），旗標／handler 從層名導出（`gather_intel` → `_intel_mode`／`_handle_intel_mode`），導不出來**具名報**。
- ★「六個錨仍各一次」我**窄化**（不是放寬）：`panel_block` 非空時**取代** map+pages（那是 BLOCKER-2 的修法）⇒ 子模式裡 `┌─ 地圖（`／`┬─ [` 本來就不該在。改成：①四個永遠在的錨各剛好一次 ②**map+pages 與 panel 互斥** —— ★後者同時抓「Esc 之後面板沒收掉」與「Esc 之後地圖沒回來」。
- ★★★**加了深度 2 的子情境，因為沒有它這一格沒有鑑別力**：深度 1 → 0 時「只回一層」與「全部彈掉」**長得一模一樣**。判準句照用：「在我想排除的那個世界裡，它會不會長不一樣？」深度 1 不會 ⇒ sanity check；深度 2 才是承重點。實測 `深度 2 -> 1｜頂層 gather_intel -> recruit`。

## 四、P32（＝spec P8）

- ★**母體第一版是空集合，而紅的是地板不是斷言**：我把母體定成「1..9 裡反查不到 id 的」⇒ 這一輪 11 列裡 9 個有鍵的**全在** ⇒ `unbound = []`，而最後那條斷言**在空迴圈上 PASS** ⇒ 一個【正數形狀的空集合】。
- 改成從**產品自己的宣告**導出：`_interact_mode_binds_key`（它與 handler 本體的機械掃描**已經有一格在異源比對** ⇒ 我不在這裡抄第二份綁定表）。
- 實測：候選 46 鍵｜謂詞說沒綁 **9 鍵**（`0 Space Tab Minus Equal Semicolon Apostrophe Slash BackSlash`）⇒ 每一鍵：動作區逐字不變、模式沒關、聚焦目標沒變、深度沒變、fp 沒變、佇列長度沒變、三態① 有那一句話。
- ★「動作區不變」比**動作區那一段**不是整個畫面：三態① 要求有一句話，而那句話會進底部「結果：」欄 ⇒ 比整個畫面會把「它說了話」誤判成「它動了東西」。
- ★★而我一度以為 `KEY_0` 會**靜默 return**（`if keycode < KEY_1 or keycode > KEY_9: return`）⇒ **不成立**：`text_ui_main.gd:1617` 那個頂端守衛先接住所有未綁定鍵。⇒ 沒有產品缺陷要修。

## 五、三道負對照

```
F（P31）Esc 直接回頂層（spec 自己寫的那個擾動）⇒ 深度 2 那兩條紅（2 → 0、頂層變空）
        ★而深度 1 那幾列照樣綠 ⇒ 卷面當場證明鑑別力在【深度 2】那一半
G（P32）未綁出口改靜默 ⇒ 本格紅並逐一指名 9 個鍵｜★全檔只有這 1 個 FAIL（無連帶）
E（→P26）`_ui_pop()` 彈出後 `clear()` ⇒ ★紅的是 **P26** 不是 P31
   真因：Esc 走的不是 `_ui_pop`，是 `_intel_mode = false`（property setter 移那一層）
   ⇒ ★★判準：負對照要打在【那條路真的走過的地方】；打在同名但沒被走到的函式上，
     紅燈會出現在另一格，而那時「有紅」會被讀成「本格有鑑別力」
   ⇒ 它仍是有效紀錄（P26 守 `_ui_pop` 的退化）⇒ 登在 P26 旁邊
```

## 六、數字

```
=== UI Flow Test DONE === errors: 0｜到場點名 75／75     rc=0
ui_flow_test.gd 33（地板 33）★30 → 33｜表裡 17 支床、合計 116 條｜反向掃 493 支、0 漏
expect：到場點名 73／73 → 75／75（逐字抄自實測輸出）
```

## 七、我沒跑的

整份電池（你起 battery16）。★`player-entry-smoke` 仍不在我跑的集合裡。
