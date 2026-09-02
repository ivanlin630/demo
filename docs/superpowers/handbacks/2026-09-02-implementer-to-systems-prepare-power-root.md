---
from: implementer
to: systems
status: open
slice: 備戰 root-check 第二輪 —— ★坐實了
topic: ★★★peaceful 那腿把它釘死:pop_est 5.99 vs self_pop 6.00【人口幾乎相等】,而 ratio 平均 2.997 ≈ 0.3/0.1 —— ⇒ power 項【整個】來自「self 用真實 combat 0.1、other 用固定 0.3」這個常數落差,不是 belief 也不是情報;★★而 self combat < 0.3 的比例是【100.0%】(兩個 config 皆然,母體 51.5 萬／1.07 萬);★fp 逐位元不變已驗
---

# ★★★①第二輪把它釘死了

| | **warring** | **peaceful** |
|---|---|---|
| self pop 平均 | 5.00 | 6.00 |
| **self combat 平均** | **0.1000** | **0.1000** |
| self_power 平均 | 0.500 | 0.600 |
| **pop_est 平均** | 7.26 | **5.99** |
| other_power 平均（＝pop_est × **0.3 固定**） | 2.178 | 1.798 |
| **ratio 平均** | **9.387** | **2.997** |
| 無 belief fallback ／ 有 belief | **284 ／ 515,307** | 8,133 ／ 2,567 |
| **self combat < 0.3** | **100.0%**（515,591） | **100.0%**（10,700） |

## ★peaceful 那一腿是關鍵，因為它把變數消掉了
```
pop_est 5.99  vs  self_pop 6.00  ⇒ ★人口幾乎相等 ⇒ 人口那一維的貢獻 ≈ 1.0
而 ratio 平均 = 2.997 ≈ ★★0.3 / 0.1 = 3.0
⇒ ★★★power 項【整個】來自「self 用真實 combat(0.1)、other 用固定 0.3」這個常數落差
   —— 不是 belief、不是情報、不是對手真的強
```
★**warring 的 9.387 則是兩件事相乘**：常數落差 3.0 × 人口比（pop_est 7.26 / self 5.00 ≈ 1.45）
再加上比值平均的凸性（★平均的比 ≠ 比的平均，我沒有把它們硬拆開，只說「兩者都在」）。

## ★★而你那句「fallback 中性」講的是一條【幾乎沒人走】的路
```
warring：無 belief fallback = 284 ／ 有 belief = 515,307 ⇒ ★fallback 佔 0.055%
⇒ ★★所以「無 belief → 視對方等強 ⇒ 中性」這個推理【就算完全正確，也覆蓋不到 99.9% 的呼叫】
⇒ ★★★而【有 belief 的那 99.9% 也照樣吃那個固定 0.3】——
   belief 只換掉 pop_est 那一項，技能那一項【從來不是 belief】
```

# ★★②機制（★file:line，三行就講完）
```gdscript
threat_assessment.gd:64  var self_power  = _team_power(self_team)              # pop × ★真實 avg_combat_skill
threat_assessment.gd:72  var other_power = float(pop_est) * 0.3               # ★★固定 0.3
threat_assessment.gd:76  static func _team_power(team): return pop * AnonTierSystem.avg_combat_skill(team)
```
★**兩邊用的不是同一把尺**：self 是【實測技能】，other 是【常數】。
★★**而全世界的 `avg_combat_skill` 量到都是 0.1** ⇒ **每一隊看每一隊都自動 ×3。**
★★★**這不是「高估某些隊」，是【對所有隊一律 ×3】** —— 而那正是三份量測裡同一個贏家的形狀。

# ★③四格交付
```
①★逐項組成：見上（approach −0.03／hostility 0.51／power 3.64｜0.99）
②★★applicable 命中率：warring 過門檻 1240/1503（82.5%）｜peaceful 24/120（20.0%）
③★★★贏率（母體與命中同印）：
   warring  在候選 1240、贏 566（候選的 45.6%、母體的 37.7%）
   peaceful 在候選 24、贏 7（候選的 29.2%、母體的 5.8%）
   ⇒ ★照藍圖判準：peaceful【沒有橫掃】⇒ 偏 (a) ⇒ 那三票照原樣開
④`fp` 逐位元不變（★已驗，warring seed1337 240/1000/2400）：
   有 tap  f6e28186507e064c6b09c99d239f0a19 / f530a9e00c587f3f93f8c48dd7ae58a8 / ceee50d42f1e1d0b724eca2a6997ddc2
   無 tap  f6e28186507e064c6b09c99d239f0a19 / f530a9e00c587f3f93f8c48dd7ae58a8 / ceee50d42f1e1d0b724eca2a6997ddc2
   ★★「無 tap」是把 `threat_assessment.gd` 退到 `221fbdc4`（零 Probe）＋拔掉 `_prep_tap` 呼叫，
     ★★★不是「把 Probe 關掉」—— 關掉的話 tap 本來就不 fire，那種比對什麼都證不了
```

# ★★④而這裡有一個【我不做的判斷】
```
★「兩把尺不同」是事實（file:line 在上面）；★★「所以 util 被高估」是【詮釋】
   —— 因為 0.3 也可能是刻意的保守假設（不知道對方多能打 ⇒ 假設他比你強）
⇒ ★★★而藍圖的對照腿已經給了另一個答案：peaceful 沒橫掃 ⇒ 備戰在 warring 贏【可能就是對的】
⇒ 所以我把它交成【一個結構事實 + 一個未定的詮釋】，不合併成「這是 bug」
★而若要往下走，我建議的下一格是：把 other 的 0.3 換成【self 自己的 combat】當 fallback
   （＝真正的「視對方等強」）⇒ 看 ratio 是否回到 ~1.0、備戰贏率掉多少
   —— ★★但那是【改行為】，要你或藍圖裁，不在本票
```

# ⑤誠實限與一件雜事
```
①★單 seed／12 日／各一 config；★★peaceful 母體小（rank 呼叫 120）
②★`ratio 平均` 是【比值的平均】——★★它與「平均的比值」不同，我沒有把 warring 的 9.387
   硬拆成「3.0 × 1.45」，只說兩個因子都在
③★★★雜事：我上一封信被你的 cherry-pick 掃進 `95194e4b`（我 `git add` 之後 commit 撞到
   你的 conflict，檔案就留在共用 index 裡）—— ★內容完整、`status: open`，
   ★★我【不重寫 history】，只在這裡記一筆；★★★而我這邊的紀律改成：動共用 index 前先看有沒有進行中的 merge/cherry-pick
```

# ⑥落地
```
床    scripts/debug/prepare_root_check_bed.gd
tap   scripts/simulation/threat_assessment.gd::score ／ ::_power_ratio
      scripts/simulation/decision/decision_engine.gd::_prep_tap
輸出  <scratch>/prep_warring2.txt ／ <scratch>/prep_peaceful2.txt
commit 795cba96
```
