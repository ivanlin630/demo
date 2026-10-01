# HOW：`TEAM_TARGET_ACTIONS` 收成 `ACTION_SHAPE` 的衍生檢視（★連三支守衛的錨一起搬）

- **來源**：`defers.tsv` 的 `team-target-actions-not-yet-derived`（★該列 2026-10-01 已解除並**把它點名的符號錨逐字搬進本檔** —— 那一列的全部價值就是這些錨）
- **HOW owner**：systems｜**排在**「不配對直接成交」退場票 merge **之後**
- **R②**：未審（dispatch 前必過）
- **這張票不是「改一個常數」**：它是**同時搬三支守衛的錨**，而失去主詞的長相是一片綠

---

## §1 為什麼它一直被延後（原裁定逐字保留）

```
★理由 ＝ **母體風險不是工作量**：有**兩支床＋同格閘**在逐字引用那個【符號名】
⇒ 一起改會讓**三支守衛同時失去主詞**，而失去主詞的長相是**一片綠**。
★過渡期的保護 ＝ **異源交叉斷言**（`ACTION_SHAPE` 裡 `target=="team"` 的集合
  ＝ `TEAM_TARGET_ACTIONS`，兩邊**各自可獨立改變** ⇒ 不是恆真格）。
★★收斂那一票要做的是【把三支守衛的錨一起搬】，不是只改常數。
```

## §2 ★符號錨（★刻意不寫行號 —— 行號版過期過一次，而讓它過期的正是「加註解」）

```
①`SPEC_TEAM_TARGET_TOTAL`      available_actions_bed.gd ／ colocation_gate_bed.gd
②`SPEC_CONSTANT_SYMBOL`        available_actions_bed.gd
③`TEAM_TARGET_ACTIONS`         available_actions_bed.gd ／ colocation_gate_bed.gd
                               ／ player_command_system.gd（★同格閘的第一條件）
★實測（`23679126e`，命中數不是行號）：
  SPEC_TEAM_TARGET_TOTAL  bed 3｜coloc 9
  SPEC_CONSTANT_SYMBOL    bed 4
  TEAM_TARGET_ACTIONS     bed 20｜coloc 13｜production 11
⇒ ★★**動工前先在你自己的 ref 上重數一次這六個數**，並把**兩組數一起貼進交件信**
  （★★★命中數會因為別的票而動 ——「不釘字面數字」那條；要比的是**搬之前 vs 搬之後**）。
```

## §3 做什麼

```
①`TEAM_TARGET_ACTIONS` 由手抄 dict 改成 `ACTION_SHAPE` 的衍生檢視
   （`target == "team"` 的那些 id）—— ★**單一定義**，不留第二份名單。
②★三支守衛的錨一起搬：它們現在引用的是**那個符號名**
   ⇒ 搬完之後它們要引用**新的那一個**，而**不是靜默地繼續引用一個已經變成衍生物的名字**
   ⇒ ★★判準：搬完之後「`ACTION_SHAPE` 的 team 集合 ＝ `TEAM_TARGET_ACTIONS`」那條
     **異源交叉斷言會變成同源** ⇒ ★★★**它必須被換掉，不是留著** ——
     留著就是本專案最常見的那個病：**比較的兩邊同源 ⇒ 恆真，而卷面長相是綠**。
③換掉它的形狀：把 `ACTION_SHAPE` 的 team 集合拿去跟**外部期望**比
   —— ★`SPEC_TEAM_TARGET_TOTAL`（spec 的常數）＋**逐名清單**（不是只比數目）。
★★★【R② 補的維護風險，已採納為硬約束】**逐名清單只准有一份** ——
   放 `available_actions_bed.gd`（★理由：P17 在那裡）；
   而 `colocation_gate_bed.gd` 的 `SPEC_TEAM_TARGET_TOTAL` 旁邊**已經有一份手打的 12 個名字（註解形式）**
   ⇒ ★**不得**在 `available_actions_bed.gd` 另開一個真的 `const Array` 逐字列同一份名單
     （那會變成**兩個檔各自手抄同一份清單** ＝ 這張票正在消滅的那個病）
   ⇒ ★★colocation 那一邊**維持純註解、不承重**（它不是被斷言的對象）。
```

### ★R② 已查過、所以不要重查的一件（`c74113684`）

```
我 spec 的註解提過「`get_available_actions` 的 `actions.append` 字面」可能是另一個外部錨
⇒ ★**它已經不存在了**：`23679126e:player_command_system.gd` 的 `get_available_actions`
  現在只是對 `get_action_availability` 做 `enabled` 過濾（★我自己開檔重核過，確認無字面陣列）
⇒ ★★所以「spec 常數 ＋ 逐名清單」**已經是能找到最乾淨的外部錨**，沒有更好的選項
  （★★★這一句寫下來的目的：免得下一個人再去找一次那個已經不存在的錨）。
```

## §4 地板（P）

```
P1 [單一定義] 全庫 `TEAM_TARGET_ACTIONS` 的**手抄 dict 字面** ＝ 0 處（指名，不數數）
P2 [★不得變恆真] 原本那條交叉斷言若還在 ⇒ **紅**；換成「衍生集合 vs spec 常數＋逐名」才算過
   ⇒ ★★負對照：把 `ACTION_SHAPE` 裡某一列的 `target` 從 `team` 改掉 ⇒ **必紅並指名那個 id**
P3 [★三支守衛都還有主詞] 三處各自**指名**它現在錨在什麼上（交件信逐條寫）
   ⇒ ★★而「搬之前 vs 搬之後」的六個命中數一起貼（§2）
P4 [同格閘沒被弄壞] `colocation-gate` 那一格綠，且**它的第一條件仍然擋得住**
   ⇒ ★負對照：拿掉第一條件 ⇒ 必紅（★該負對照**指到舊 ref 驗紅**，不要改活檔）
P5 [電池] 全電池；★本票改的就是床與守衛 ⇒ 那幾格的綠**必須是新檔的綠**
```

## §5 不在本票

```
✘ `ACTION_SHAPE` 本身的欄位增減（它是上一張票的產物）
✘ `listed` 的語意（已裁，見 `own-team-actions-full-list-HOW.md`）
✘ 任何「順手把別的手抄名單也收掉」—— ★一次只搬一組錨（三支守衛已經是這張票的上限）
```


## §6 R② 紀錄（reviewer，`c74113684`，verdict ＝ **CLEAN**）

```
·§3③ 方向對：他讀了 `23679126e` 的 P17（`_test_p17_shape_team_equals_team_target_actions`），
  確認今天 `from_shape` 與 `from_const` **各自獨立字面**，改完後 `from_const` 會變成
  **重算一次 `from_shape`** ⇒ 同一算式 ⇒ 差集恆空 ＝ 恆真 ⇒ 與我的診斷一致。
·★他找過有沒有更好的外部錨 ⇒ 沒有（見上）。
·★★他補的維護風險 ⇒ 已採納為硬約束（逐名清單只一份，見 §3③）。
·六個命中數他用 `git grep -c <符號> 23679126e -- <檔>` **獨立重數全部吻合**
  （bed 3／coloc 9｜bed 4｜bed 20／coloc 13／production 11）。
·§5 上限：他 grep 全庫確認 `TEAM_TARGET_ACTIONS` 這個符號名**只在那三個檔出現**
  ⇒ **母體窮盡**，「三支守衛已是上限」成立。
·P4 沿用上票做法（指舊 ref 驗紅）無異議。
```

★**放行**：可 dispatch，**排在退場票 merge 之後**。
