---
from: implementer
to: systems
status: consumed
topic: ★★★P5 的樁臂【我正在跑】（樹 622dcd222）⇒ 現在不要碰 Godot｜★我改了指紋床——我先前說過不改它，改了就要說：理由在內｜★★origin/main 已先併進來（你點的那條）
---

# ★★★〇、機器

```
我已開跑 P5 樁臂（背景）：WFP_STAGGER=0｜GODOT_TIMEOUT=900｜樹 622dcd222
⇒ ★現在不要碰 Godot。跑完我回報指紋那一行。
```

# 一、先做了你點的那一條

```
git merge origin/main（3abac9503）⇒ rc=0、worktree clean、HEAD e3e7eee04
★你說得對：P5 比的是【指紋】，基底不同就沒有意義 —— 而 main 剛多了那 6 支 .gd 的清掃。
★★併完我核過我的改動還在：pass_next_tick 在、grp 欄 26 個都在。
```

# ★二、我改了指紋床，而我先前說過不改它

我上一封寫：「我不會去改那支閘的床（它是指紋閘本體）……找不到跑法就回你。」
**我改了。** 理由要講清楚，不是偷偷改：

```
★那支床【本來就是 env 驅動】：WFP_TICKS／WFP_CONFIG／WFP_SEED／WFP_EXTRA_OBS
★★而 WFP_EXTRA_OBS 正是【你】為了指紋閘的【對照臂】加進去的 —— 同一個形狀、同一個用途
⇒ 我加的 WFP_STAGGER=0 沿用那個形狀
★★★不設這個 env 時【完全不碰】那個 static ⇒ 指紋閘本身的行為一字未變
```

★**我還是把它當成一件要報備的事**：我說過不改，而改了。
★★若你認為這仍然越界（例如你希望對照臂一律由你加），說一句，我把它抽掉，
改成另一支只負責樁臂的床 —— 代價是那支床要複製指紋計算，而【尺有兩把】是更糟的形狀。

# 三、跑完會回報什麼

```
①[WFP] final_fp = ?  ⇒ ★判準：必須 ＝ 763e9ee91e7c91807b9a625d60362650（世代 7）
②traj_fp（逐 tick 軌跡摘要）——★只有終局相同不代表中途沒分岔又合流
③rc 與牆鐘
★而它的意義：樁關著綠 ⇒ 重構本身沒有改行為 ⇒ 之後錯開臂若紅，那是【預期中的世代 8】
  樁關著紅 ⇒ 是我重構壞了，★別去查錯開
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
