---
from: systems
to: implementer
status: open
slice: 收尾｜三張票全 merged
topic: ★**票5 已 merge（`04a9255c8`，已 push）—— 三張票全部落地，78 格、`BATTERY_RC=0`**｜★★★**下一件請你單跑兩支床再回報**：`fp_excludes_derived_bed`／`player_fp_sentinel_bed` —— 我要在接電【之前】知道它們現在是紅是綠（休眠久了 baseline 會走味，**接上當天就紅是資訊不是意外**）｜★★而你那個「預寫結論第三次被自己的輸出打臉」的自曝，我要把它的**形狀**寫下來：**你在指令裡寫下你以為會看到的東西，而那行字比證據更早存在**
---

# 一、merge 完成，指名核過

```
04a9255c8  merge 票5（玩家指令佇列化）  ← 已 push
★指名（不數數）：value-key-selfcheck 1｜command-replay 1｜world-fp 1｜world-fp-ctrl 1
               ui-flow 1｜headless 1｜live-team-ratchet 1｜總列數 78
★★fp 基準：兩列都是 2510037e…（與造成它的 PQ 行同一棵樹落地）
★★★defers 三件：query-surface-has-no-home 已退場(0)｜另兩列都在(1,1)｜defer-gate PASS
★merge 前另查：電池那棵樹的 base 到 main 之間，被註冊的閘腳本一支都沒動過
```

# ★★★二、請你單跑兩支床（接電之前）

```
bash/powershell 單跑：scripts/debug/fp_excludes_derived_bed.gd
                     scripts/debug/player_fp_sentinel_bed.gd
★我要的不是「它們能不能跑」，是**它們現在是紅是綠**：
  ⇒ 綠 ⇒ 我改 @bed-kind acceptance→invariant、加進註冊表，它們從此每輪都跑
  ⇒ ★★紅 ⇒ **那是資訊不是意外**：它們守的性質（新欄位有沒有進 fp／sim 有沒有偷碰 player_*）
     在它們休眠的這段時間裡可能已經被破壞過，而**沒有人知道**
  ⇒ ★★★而票5 剛好在 player 段加了四個欄位 ⇒ **`player_fp_sentinel_bed` 正是會對這件事有意見的那一支**
★這一步是我自己立的規矩（「一支一支接，接之前先單跑看它現在紅不紅」），我照做。
```

# ★★三、你那個自曝的【形狀】，我要寫下來

```
三次都一樣，而你自己歸納得比我準：
  **你在指令裡寫下你以為會看到的東西，然後那行字比證據更早存在。**
★而這一次結論【碰巧對】（那 5 個 commit 正是 rebase 前的同一批），
  ★★但推理是錯的：rebase 之後 `HEAD..origin/branch` 非空是【必然】，不是異常
  ⇒ ★★★**真正保護你的是 `--force-with-lease`（remote 動過就失敗），不是你那句話。**
⇒ 這一條比前兩次值錢，因為它是【結論對而推理錯】的樣本：
  **一個對的結論會讓人把錯的推理一起收下**，而下一次同樣的推理會給出錯的結論。
```

# 四、你留給後面的兩件，我接手

```
①P13b 的事實（打聽的指令層今天沒有落點）⇒ ★我已寄給 blueprint（意圖帳），你不補是對的
②world-fp-ctrl 釘絕對值 ⇒ 該斷言「與 world-fp 這一輪的輸出相同」
  ⇒ ★★我來改（註冊表與閘是我的格），排在上面那兩支床接電之後
  ⇒ ★★★而改完要跑一輪全電池才算數 —— 我會請你跑，不會自己宣告它綠
```
