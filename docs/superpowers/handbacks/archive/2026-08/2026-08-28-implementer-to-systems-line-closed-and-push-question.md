---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: infra
topic: ★這條線從我這邊收乾淨了：拆掉回滾後恆為 0 的 seen_next 死欄，四閘綠、工作樹乾淨;★★一個要你裁的：origin 停在 2c5d55bf，之後【12 個 commit 未 push】——推不推你說;★★★另：我把「要不要推」寫在終端而不是寄信，那等於沒問——這封是補的
---

# ★①收尾清理：拆掉 `seen_next` 死欄

雙緩衝回滾後，「下一 tick 才看到」在結構上不可能發生 ⇒ `seen_next` 恆為 0。
★**照這條線立的規矩（不留下不做事的機制／欄位）拆掉。** commit `e7138422`。

閘：bare-tick PASS(母體 171, NEEDS_HUMAN=0)／constitution PASS(74)／bed-parse PASS(306)／
headless Q1 過、Q2 8 vs baseline 7（多的是既存 g1a）。工作樹乾淨。

# ★★②要你裁的一件：**未 push 的 12 個 commit**

```
origin/feat/old-growth-forest 停在 2c5d55bf
本地 HEAD  e7138422 ——★之後 12 個 commit【尚未 push】
內容：rung_changed（behavior，已 merge 過的那顆之後的）／雙緩衝（★已回滾）／
      輪詢與旗子命運的儀器／量測產物
```
★**我不自動 push 未經你看過的 behavior 改動** —— **推不推、推哪些，你說。**
★★**而現況有一個副作用要講**：**你在 main 上 grep 不到這些量測檔**
（★這一輪已經因為這件事害你白找過一次）。

# ★★★③一個關於我自己的訂正

★**我上一輪把「要我 push 說一聲」寫在【終端輸出】裡，而不是寄信。**
★★**那等於沒問** —— **你不讀我的終端，而 Monitor 靠信不靠 commit。**
★★★**這跟我今天報過的「落地≠通知」是同一型，只是這次的載體是【我自己的話】。**
⇒ **這封是補的。**

# ④這條線的狀態（我這邊）
```
★t0-emit-ordering：不修，具名記錄（你裁）—— 我沒有留下任何雙緩衝的殘骸
★★per-actor 消費：不派（你裁）—— 我沒有動它的 code
★★★LADDER 9.81% 那一格：具名，等它成為議題時的現成起點 —— 我沒有替它單獨做東西
★儀器保留：旗子命運（flag_consumed / lost_ordering / lost_not_visited）
   ⇒ 它現在量的是【真實現況】，不是某個修法的效果
```
★**我的隊列空了。下一票等你派。**
