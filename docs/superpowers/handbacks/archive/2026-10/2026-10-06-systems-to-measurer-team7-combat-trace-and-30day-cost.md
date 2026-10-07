---
from: systems
to: measurer
status: consumed
slice: 兩件：①Team7 中段崩潰的 combat trace（給 QA）②量一次 30 天模擬耗時（票 A 床的窗口）
topic: ①藍圖觀察輪表 E：Team7 t25339／25399 pop 10→9→8、t28706–29312 rung 0↔2 十次、t31933 faction 1→-1 ⇒ 決策 trace 看不到 ⇒ 要 combat trace｜②票 A 第一階段床要決定窗口 N 天 ⇒ 需要「seed 1337 跑 N 天」的耗時｜★Q-raid＋施工 counter 照舊等 tap 對準 merge
---

```
①seed 1337、同樹（≥ 6718af005）、窗 t25000–t32000，Team7 的 combat trace（誰打誰、傷亡、資源搬移、rung 變化點）
  ★已落地 exact path ＋ 一行母體邊界 ⇒ 交 QA
②量：seed 1337 跑 7／10／15／30 天各耗多少秒（同一台機器、Godot 數 0 時跑）
  ★並在每個窗上順手印票 A 三格的分子／分母（C1 宣稱建設且零效果的隊數／C2 at_market 貿易零 coin 變動隊·日／C3 領取零 coin 變動次數）
  ⇒ 我用它決定床的窗口與基線（★30 天的 7/11 不能當較短窗的基線）
```

---

# 追加（systems，QA 票 A 因果 `03a0ef88c` 之後）：tap 對準 merge 後的補跑清單多兩族

```
A1（建設 29 天零效果）QA 判「最接近從沒成功 dispatch」，而**哪一道閘擋住**這一層他答不到
⇒ 補跑時除了 Q-raid ＋ `construct.stall`／`construct.start_task_not_build`，再加：
  `wall.reject_*`（`outpost_system.gd`）＋ `village.build_fired`（`faction_ai_system.gd`）
⇒ ★這些多半是**全域計數**：分隊要靠樣本 ⇒ 先核它們有沒有 bump_sample、隊伍鍵叫什麼
  （`construct.stall` 叫 `ct_id`）⇒ 沒有樣本的那幾個，只能在「只剩 Team0 一隊在宣稱建設」的窗上讀全域計數，
  而那時要把「這個窗裡還有誰在建設」印在同一行（否則全域數會被讀成 Team0 的數）
```
