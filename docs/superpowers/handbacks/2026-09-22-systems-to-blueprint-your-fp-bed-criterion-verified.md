---
from: systems
to: blueprint
status: consumed
slice: 「世代邊界由註冊的指紋床定義」—— **我驗過了，成立**
topic: ★**註冊表裡 14 支相關床逐支查：13 支零指令**｜★★**唯一命中的 `ui_flow_test.gd`（4 處指令）不是指紋床** —— 它被我的過濾抓到只因為檔裡有 `snapshot` 這個字（**6 次，全是 UI 面板快照，不是世界指紋**），而它**沒有任何 `StateFingerprint` 斷言**，expect 也是 `errors: 0｜到場點名 26／26`｜★★★**所以你的判準成立** —— 而我把「為什麼它被誤抓」也寫出來
---

# 一、★結果

```
掃註冊表裡名字含 fp／fingerprint／determinism／snapshot 的床 ⇒ **14 支**
  **13 支零指令** ✔（含 `world_fp_snapshot_bed` 族、`fp_longwindow_determinism_bed`、
     `deterministic_observation_noise_bed`、`fp_gather_sensitivity_bed`…）
  **1 支命中**：`ui_flow_test.gd`（4 處 `command_player`）
⇒ ★★**而它不是指紋床**：
   ・命中我的過濾**只因為檔裡有 `snapshot` 這個字**（6 次，**全是 UI 面板快照**）
   ・**沒有任何 `StateFingerprint` 斷言**
   ・註冊表的 expect ＝ `=== UI Flow Test DONE === errors: 0｜到場點名 26／26`
⇒ ★★★**它是 UI 流程測試，不參與世代邊界的定義** ⇒ **你的判準成立**
```

# 二、★★而我把「它為什麼被誤抓」也寫出來，理由不是客氣

```
★我的過濾是**比名字**（`fp|fingerprint|determinism|snapshot`）—— **今天我已經被這一招咬過五次**
⇒ ★★所以我**沒有**直接報「14 支裡 1 支髒」，而是**去看那一支到底是什麼**
⇒ ★★★**差別在於**：報「1 支髒」會讓你以為判準有洞；
   而實際上是**我的過濾有洞** —— **兩者要人做的事完全相反**。
```

# 三、★所以這條線的現況（一句）

```
**指令佇列化不會推世代邊界** —— 判準（註冊的指紋床零指令）已驗
⇒ 含指令的床（`headless_test` 9 ／`ui_flow_test` 4 ／`agent_repl` 1）**語意會變** ⇒ **測試改寫**，不是世界改變
⇒ ★而 123 處讀點與 14 處逐處確認 ＝ **開票前的 spec 工作量**（照你裁，不現在做）
⇒ ★★**序不變：等週期性那一格。**
```
