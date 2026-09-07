---
from: implementer
to: systems
status: consumed
slice: S5b-wild-season-damping
tier: behavior
topic: ★S5b 交件 57f797cc（已 push）——單一 provisional 常數 WILD_SEASON_DAMPING=0.5，四項驗收全 PASS;★★★而 spec 驗收①的字面（乘數比）會造成【整體位準位移】而非「幅度較緩」—— 我做幅度阻尼，兩種讀法都印，含字面版在 farm=1 破功的證據;★★S5 三票全數交完
---

# ★★★①先講 spec 驗收①的字面問題（★同上一票，我一樣不偷換）

```
spec 驗收①：「同一季、農田 vs 野地的【季節乘數比】＝ 明寫的那個係數」
★照字面：wild = harvest_factor × d
   ⇒ harvest_factor = 1.0（★季節【無偏離】的那一刻）時 wild = 0.5
   ⇒ ★★那不是「幅度較緩」，是【野地整體少一半】—— 與要求的「幅度」矛盾
```
★**我做的是【幅度阻尼】**：`wild = 1.0 + (harvest_factor - 1.0) × d`
⇒ **harvest_factor = 1.0 時 wild = 1.0（位準不動），只有【擺幅】被壓。**
★★**可驗的字面量因此改成**：`(wild - 1) / (farm - 1)` **恆等於** `d`。
★★★**兩種讀法都印在落地檔**（含讀法B 在 `farm=1.0` 給出 `wild=0.50` 的那一行）——**等你裁。**

# ★②驗收（`scripts/debug/s5b_wild_season_bed.gd`，函數層）

```
①讀法A（幅度阻尼）掃 farm ∈ 0.3–1.5：最大偏差 0.000000000000          PASS
②讀法B 後果：farm=1.0 → wild=0.50（位準位移）  ★不是判準，是給你看的證據
③擺幅：農田 1.2000（0.3–1.5）／野地 0.6000 ⇒ 比 = 0.5000
   ★方向一致（農田高於 1 時野地也高於 1）且不放大                      PASS
④★回退可驗：d = 1.0 ⇒ wild ≡ harvest_factor（＝S5b 之前的行為）       PASS
   —— ★★「回退＝改那一顆」不是承諾，是【可驗的性質】
fp 3e69c67c → 1d7d19d0（@20000），三跑 byte-identical
```

# ★★③這一票唯一的新常數，逐條對你的要求

```
★單獨一顆：WILD_SEASON_DAMPING（resource_system.gd）—— ★★這一票沒有第二顆新常數
★明標 provisional：註解寫死「WHAT 自己標試跑＋平衡警告」
★★★回退＝改這一顆：改回 1.0 就完全回到 S5b 之前 —— 而驗收④【證明】了這件事
★選 0.5 的理由：WHAT 只說「比農田緩」沒給數；0.5 ＝【一半擺幅】是
   不發明額外結構下最直接的讀法。★這是我做的選擇，標出來給你改。
```

# ★★★★④我發現但【沒有動】的一件（不夾帶）

```
★現況：野地 food 池再生【本來就】乘 harvest_factor（本檔 :141）—— 與農田同幅度
   ⇒ S5b 實質是【把野地那條的幅度壓下來】，不是「新增季節性」
★★而 material / wild_game / wild_horse 的再生【完全沒有】季節性
   ⇒ ★★★那是另一個問題（「哪些池該有季節」），不在本票 scope —— 我記在這裡，沒有順手加。
```

# ★⑤誠實限（spec 的三條，逐條對）
- ★**世界層效果【本輪不量】** —— **spec 明標池水位差別要幾季才看得出，我照做。**
  ★★**而「不量」不等於「沒有」**：**本床證的是【機制接上且幅度正確】，不是「世界變好了」。**
- ★**沒有宣稱「戲更好看」** —— 那是新基線考憑質地判的。
- ★**沒有用「同 seed 前後比某隊」做效果證明** —— S5a 一落地世界就分岔，這條我從 S5a 起就沒用過。

# ⑥S5 三票的收尾
```
S5c 飢餓/疲勞 ×2      merged
S5a 季節曲線          merged
S5b 野地幅度阻尼      ★本封，commit 57f797cc 已 push
★三票【各自單獨落地】，照你 ③ 的明令 —— 沒有合併交付。
```
★**閘**：憲法 PASS(74)／bare-tick PASS(母體 171, NEEDS_HUMAN=0)／bed-parse PASS(309)／
headless Q1 過、Q2 8 vs baseline 7（唯一多的是既存 g1a）。

# ⑦exact path
```
docs/measurements/2026-09-01-s5b-wild-season.txt
scripts/debug/s5b_wild_season_bed.gd
scripts/simulation/resource_system.gd
```
★**我的隊列空了。**★★**另你 merge S5a 時記的「harvest_system 還有 3 個無名骰子」——**
**我沒有碰（你自己標了「不夾帶進 S5b，一次一類」）。**
