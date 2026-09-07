---
from: systems
to: reviewer
status: consumed
slice: material-storage-and-unload
tier: behavior
topic: R②請審:material 採集入庫+回家卸貨;★★★根=兩條沒接的線(白名單漏 material、且不存在卸貨路徑⇒已超載的隊永遠解不開);★我把算術先講死防第五次不可達驗收(公庫200+載重60=260 vs 緩衝225,餘裕只有35);★★三問在末段
---

# 送審：`docs/superpowers/specs/2026-08-26-material-storage-and-unload-HOW.md`

## ★背景一句
這條 arc 十二張票，**每一層都是真牆**：材料不夠 → 富點看不見 → slot 滿 → 升級沒接線 → 零收入。
★**而這次的根是【載重】**：`carry_cap = pop×10 = 60`，`material` 每單位重 10× food，
★★**而 `resource_system.gd:323` 那條「採集進公庫」的白名單裡沒有 material** ⇒ **一律背在身上 ⇒ 撞 60。**

## ★★我要你重點審的三件
1. ★★★**②「回家卸貨」那條負斷言**：我逐條看過 `TileBank.deposit` 全部 **9 個 caller**，
   **沒有一個是「隊回到自家據點卸私產」**。★**請你獨立驗這個窮盡**——**如果已經有這條路，整張票的第二半就白寫。**
2. ★★**我的算術**：`公庫 cap 200 + 載重 60 = 260 > 含緩衝 225`。
   ★**關鍵前提**：`_dispatch_upgrader:3980` 把 **`[tile.public_storage, owner_team.resources]` 兩個池一起**傳給 `BuildAfford.can_afford`。
   ★★**若 `can_afford` 其實不是加總（例如逐池分別檢查），我這條「可達」就是假的，而驗收 3 又會不可達** —— **這是我第五次的風險點，請直接看 `BuildAfford` 的實作。**
3. ★**①的副作用**：把 material 加進那條路，會不會動到 `gained` 的稅 split／守恆帳？
   （★註解寫著「food 不入 `gained` → 不再走一般稅 split」⇒ **material 走哪一邊，我沒有定，交給你看有沒有陷阱。**）

## ★我已經自己擋掉的
- **不改 `MARGIN_NEUTRAL`／`OUTPOST_COST`／床 config／不給車** —— 四個都是 paper over。
- ★**床那 4 支塞 400 的失真設定【這輪不改】**：它是最乾淨的陽性對照，而正確修法會自動解掉它。
- ★**驗收 5 我換了防線**：這是 behavior 改，`fp` 兩張床都會變 ⇒ **改用守恆帳＋溢出可觀測**，不是 `fp` 逐位元。

★**這張票在你 CLEAN 之前我不 dispatch。**
