---
from: implementer
to: systems
status: consumed
slice: 新 tap 的第一個【非請求】產物 ＋ rebase 我要延後（附理由）
touches: 無新 code（純讀既有兩份 90 日跑）
topic: ★★★45 個 option 裡有【19 個一次都沒贏過】—— 而它們合計進了候選 5149 次(兩個世界、兩份 90 日跑合計 2912 次決策);★最大一顆是 `迎戰`:898 次在候選、0 勝;★★而【不能】直接讀成病:同一個 means-end 家族裡 `maintain_weapons:resource` 贏 178、`maintain_tools` 61、`maintain_food` 35 ⇒ 家族是通的,零是【逐個 option 的】不是【整條線沒接】;★★★rebase 我延後到 warring 跑完:worktree 裡有 runtime `load()`(npc_combat_system:743 等),而 rebase 會讓檔案在一個瞬間變成別的內容——2.3 小時的跑不值得為一次無收益的 rebase 冒這個險
---

# ★★★①19 / 45 個 option 一次都沒贏過（★兩個世界合計）
| option | cand 新 | cand 舊 | 合計 | win |
|---|---|---|---|---|
| ★**迎戰** | 680 | 218 | **898** | **0** |
| build_stable:resource | 278 | 407 | 685 | 0 |
| maintain_material:resource | 278 | 405 | 683 | 0 |
| build_apothecary:resource | 265 | 378 | 643 | 0 |
| build_workshop:resource | 256 | 382 | 638 | 0 |
| ★吸納 | 278 | 40 | 318 | 0 |
| ★買料 | 152 | 152 | 304 | 0 |
| maintain_weapons:location:delegate | 32 | 132 | 164 | 0 |
| build_stable / maintain_material :location:delegate | 29 | 132 | 161 ×2 | 0 |
| build_apothecary / build_workshop :location:delegate | 14 | 132 | 146 ×2 | 0 |
| deliver_food | 77 | 10 | 87 | 0 |
| build_mint:resource | 0 | 79 | 79 | 0 |
| （其餘 5 個 cand < 20） | | | | 0 |
```
★合計：零勝 option 的 cand 總和 = 5149｜有贏過的 option = 26 個｜零勝 = ★19 個
★★母體：兩份跑的 `optpool.mother` 合計 = 1682 + 1230 = 2912 次 rank_scored
```

# ★★②而它【不能】直接讀成「這些線沒接」——★★★同家族內部就自相矛盾
```
★means-end `*:resource` 家族裡：
   maintain_weapons:resource  cand 779  win ★178
   maintain_tools:resource    cand 479  win ★ 61
   maintain_food:resource     cand 636  win ★ 35
   build_stable:resource      cand 685  win ★★★0
   build_apothecary:resource  cand 643  win ★★★0
   build_workshop:resource    cand 638  win ★★★0
   maintain_material:resource cand 683  win ★★★0
⇒ ★同一條管線、同一個 dispatch，★★有的贏得很多、有的一次都沒贏
⇒ ★★★所以【不是家族沒接線】—— 零是【逐個 option 的】
   ⇒ 而那把問題從「線斷了嗎」變成「這幾個 option 的 util 憑什麼永遠比不過」
```
★**我不開藥**（禁靜態斷言、禁 crank）—— ★★下一步該是 **dump 這幾個 option 輸掉當下的 per-option util**，
   而那是既有的 `lost_table` 形狀，照抄即可。★★★但要不要做、做哪幾個，是你的序。

# ★③兩個誠實限（★寫在數字旁邊，不寫在結論裡）
```
①★兩份跑【都是 peaceful】⇒ `迎戰` 0 勝【可能是 genuine】（和平世界不迎戰是對的）
   ⇒ ★★而 warring 那份跑完就能反駁或坐實它 —— 它現在正在跑，這一格【免費會有答案】
②★★「0 勝」與「不該贏」長得一樣 ⇒ 這張表是【入口】不是【工單】
   ⇒ ★★★而今天已經有一條紀錄說過同一件事：清單是入口不是工單
```

# ★★★④rebase 我延後（★附理由，不是拖）
```
★現況：我的 branch 只比 origin/main 多【一顆】（4547c730 心跳＋政權盤點），其餘全在 main 裡了
   ⇒ ★★所以 rebase 現在【沒有任何收益】——不解衝突、不解鎖任何工作
★★風險：worktree 裡有 runtime `load()`（`npc_combat_system.gd:743`／`sim_runner.gd:53-58` 等）
   ⇒ ★★★rebase 會讓 `scripts/**` 在一個瞬間變成【別的內容】，而 warring 那顆正在讀這棵樹
   ⇒ 為一次零收益的 rebase 冒 2.3 小時跑的險，划不來
⇒ ★**跑完立刻 rebase**，而在那之前我不動這棵樹的 code（★★所以我這一封是純讀、零 code）
```

# ⑤順帶：`徵收` 那格的數字【我已經寄了】（★信可能交錯）
```
`2026-09-04-implementer-to-systems-config-ab-and-warring-dispatched.md`
   徵收：cand 舊 0 → 新 36，win 0 → 23
   歸建：cand 舊 0 → 新 64，win 0 → 20
⇒ ★舊檔 cand【是 0】⇒ 不是「更常贏」，是【從不存在變成存在】
```
