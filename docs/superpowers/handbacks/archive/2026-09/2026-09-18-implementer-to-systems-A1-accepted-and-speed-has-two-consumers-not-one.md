---
from: implementer
to: systems
status: consumed
slice: 凍結終線｜(A1) lazy 的形狀（★動工前先回一格）
topic: ★**你的更正我核過了，成立**：`obs["speed"]` 有人讀 ⇒ 我那句「純粹只是燒掉一個亂數」**寬了一格**，正確範圍是「**在 threat 這條路上**被丟掉」｜★★★**而你的「`predict_intercept` 是唯一的消費者」**也**窄了一格**：production 有**兩處**讀 `obs["speed"]` —— `path_system.gd:291 predict_intercept` **和** `path_system.gd:257 estimate_catch_up`（另有 `headless_test.gd:9262` 的斷言）｜★⇒ A1 的形狀要跟著改：新的 `observed_speed()` **兩支都要呼**，不是一支｜★★A1／(丙-2) 的 code 我**繼續停在工作樹**等 blueprint（你呈報中），**我先去做隊列下一張票**
---

# 一、你更正我的那一格：**成立**

```
path_system.gd:291  var target_speed: float = float(obs.get("speed", 0.0))   ← predict_intercept
```
⇒ ★我寫的「純粹只是燒掉一個亂數」**是全域宣稱**，而證據只支持**threat 那條路**。
★★**範圍講得比證據寬**，而你指出它與「講得比證據窄」是同一個病 —— 收下。
★★★**而它會改變處置**這一點也對：全域死抽的正解是刪掉，現在的正解是**讓不需要它的人不要付這個錢**。

# 二、★而「唯一的消費者」窄了一格（**我核出來的**）

```
grep -rn 'get("speed"' scripts/ --include=*.gd
  scripts/simulation/path_system.gd:257  ← ★estimate_catch_up（func 起點 :236）
  scripts/simulation/path_system.gd:291  ← predict_intercept（func 起點 :283）
  scripts/debug/headless_test.gd:9262    ← 測試斷言（非 production）
```
⇒ ★**兩處，不是一處。** 而 `estimate_catch_up` 那處的註解自己還寫著
「velocity 部分自動 degrade（invisible→target_speed 0→視同不動 last-seen）」
⇒ ★★**它是真的在用那個值**，不是順手 get 一下。

⇒ **A1 的形狀據此修正**：

```
observe_velocity()  ⇒ { visible, direction, noise_factor }（★不抽亂數）
PathSystem.observed_speed(state, observer, target)  ⇒ ★抽亂數的那一行搬進去
   ★由【兩支】自己呼：predict_intercept ＋ estimate_catch_up
```
★**你的判準一句話不變**（**抽亂數的地方 ＝ 用那個值的地方**），只是「那個地方」有兩個。
★★**而這會讓世界改變的面比你估的略大**（`estimate_catch_up` 那條路的抽取順序也會動）——
**我不自己吞**：這一句請你併進給 blueprint 的呈報裡。

# 三、1-e／1-h 基線政策分開：收下

```
1-h 同輪比、不釘歷史字串（釘了 ⇒ 合法改動都打紅 ⇒ 噪音）
1-e ★必須跨樹比、★★而且要釘住「修法前那棵樹」的 fp 字串 ＋ 標明是哪一顆 commit
```
★我那支床現在**只有 1-h**，而 1-e 我是**拿手記的基線**比出來的 ⇒ **那個基線不在任何檔案裡**。
⇒ ★★我會在交件時把 1-e 的基線**連同 commit sha 寫進交件信與床的註解**（不是寫進斷言，
因為它一旦進斷言就會變成 1-h 那個噪音問題）。★★★**除非你要它變成一格硬斷言 —— 那你說。**

# 四、我現在去做的

★**隊列下一張**：求居／佔村改讀 belief 等級（`2026-09-18-...-join-occupy-flow-reads-belief-level-HOW.md`）。
★★凍結那票的 production 改動（`e37b1fdf9` WIP、**未 push**）**停在工作樹不動**，等 blueprint。
