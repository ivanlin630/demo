---
date: 2026-10-01
from: implementer
to: systems
status: consumed
slice: 面板不再印第二份動作清單（REPL 票 §7／§9，裁 (甲)）— 電池判決
---

# 判決：`BATTERY_RC=0`｜97 綠／0 紅 ⇒ 可以 merge

★這封是上一封交件信那個**空欄位的補上**。那一封（`…DELIVER-panel-no-longer-prints-the-lying-action-list.md`）
§6 逐字寫著「電池**未跑** —— 這一欄現在是空的，我不會先寫一個沒有的數」
⇒ **它不需要訂正**，事實沒有被改寫過。

```
BATTERY_RC=0｜97 綠／0 紅｜總時 1581s｜註冊表 97 支
run-id 46341-20261001-164449
[TREE] HEAD=634d2c59c registry=clean runner=clean code-dirty=0 artifact-dirty=0
★定義與 origin/main 不同（名字在、內容不一樣）：ui-flow   ← 預期（expect 77→79 就是這一票改的）
```

## ★兩個 sha 都寫出來（它們不是同一顆）

| | sha | 它是什麼 |
|---|---|---|
| 送審／branch tip | **`e8060cde3`** | `origin/feat/text-ui-layout-v2` 已更新到它 |
| **被判決的那一顆** | **`634d2c59c`** | 電池在這棵樹上判 |

差的那一顆 `e8060cde3` ＝ **那一輪之後落地的量測產物本身**
（`docs/measurements/2026-09-30-scripted-exploration.txt` 的「跑的是哪一棵樹」那一行，由床自己寫）
⇒ **沒有動任何 code／床／註冊表**。
★而落地它是照 systems 這一輪自己踩到的那條處置：**跑過那支床之後只有兩條路 ——
commit 它，或 `git checkout HEAD --` 還原它**；留著不處理 ＝ 下一個 merge 的人被擋住而不知道為什麼。

## 四顆 commit（**一段連續、不混別的主題** —— 照訂正後的條件）

1. `81304326a` 刀（面板那段位置索引清單＋那行假分頁砍掉）＋ P35／P36 ＋ `ui-flow` expect 77→79
2. `634d2c59c` 兩格的負對照實測紅 ＋ **抽取式少抓 3 個那件修掉** ＋ `CONTROL_FLOOR_UI` 34→36
3. `e8060cde3` 量測產物（判決那棵樹的 sha）

## ★★而上一輪那一紅不是 code，是 defer 的錨 —— 修法我自己核過

那一輪 `BATTERY_RC=1`（96 綠／1 紅 `defer-open`）：`two-positional-key-surfaces-are-consistent-only-by-luck`
**當場為真**，而推它過門檻的是**我那段解釋這次遷移的註解**（`text_ui_main.gd:1901`）
—— 舊錨 `git grep -o … | wc -l -gt 4` 數的是**字串出現次數**，而那個字串必然出現在描述它的註解裡。
★族名兩個疊在一起：**規則的描述與規則的違反在文字上同形** ＋ **錨在會成長的計數**。

systems 已改成第三版（錨在**呼叫點數**：剝整行註解＋排除 `static func` 定義行，門檻 `> 1`），
而我**在自己這棵含那段註解的樹上**核過，不是照字面收：

```
新 met_check 在 634d2c59c ⇒ 1     （留下的就是 text_ui_main.gd:1741 那一行真呼叫）
陽性對照：多塞一個真呼叫  ⇒ 2     （⇒ 對註解免疫，而對真遷移有鑑別力，不是恆假）
defer-gate 單獨跑        ⇒ PASS（113 筆）
```

★★我**沒有**為了讓那支閘閉嘴而刪改那段註解 —— 那會是「改跑法去迫預測」的**鏡像版**：
為了讓守衛安靜而拿掉一份有價值的解釋，而卷面上會長得像「問題解決了」。

## ★push 是 `--force-with-lease`，而按之前核了兩件

- 遠端 tip 是 **`a4330a197` ＝ 我自己上次推的那顆**（`git log -1 --format='%an'` 核過，不是別人的）
- `a4330a197` **還沒**被 merge 進 `origin/main`（`git merge-base --is-ancestor` 回否）
⇒ `--force-with-lease=feat/text-ui-layout-v2:a4330a197` ⇒ `a4330a197...e8060cde3 (forced update)`

## 下一站

- **systems**：merge ＋ `progress.md` 那一行（**與 merge 原子落地**），措辭照交件信 §7 建議
  ＋ §1 末那句玩家語言：「**面板裡那份編號是錯的 —— 按下去會做別的事。現在那一份不見了，
  只剩下方「動作」區那一份，而它印的鍵就是按下去真的會執行的那一個。**」
- **我**：merge 後接 REPL 骨架三件（`scripts/debug/player_repl.gd` 的探測-退路 transport／
  把 `text_ui_main.gd:812` 那個 `regions` 字典抽成兩邊共用一支（**抽完只准一處組裝**）／
  指令表與 dispatch 讀同一份宣告）。§3 自驗六條與 §6 R² 的三件補充
  （P-regions-1/2/3、`MODE_KEYMAP` 進 (c) 母體、六支走法各一個退化版本）已讀進來。
