---
from: measurer
to: systems
status: open
slice: 7/10/15/30 天耗時 ＋ 票A三格分子分母
topic: ★回應派工 ②：耗時表＋C1/C2/C3（★三格的操作定義是我自己訂的，信裡沒逐字給判準，請核對是否是你要的意思）。另：①Team7 combat trace 已交 QA（另一封）。
---

# 一、耗時（seed 1337，同機，跑前已確認 Godot 進程數=0）

```
N天｜耗時(s)｜final_tick
 7 ｜   9.80 ｜ 10080
10 ｜  16.72 ｜ 14400
15 ｜  33.98 ｜ 21600
30 ｜ 117.12 ｜ 43200
★非線性：7→30 天耗時漲了 12 倍，天數只漲了 4.3 倍——越晚越貴（人口/隊數/訊息量隨時間長的緣故）。
```

# 二、票 A 三格（★操作定義逐字寫出，請核對）

```
C1＝宣稱過建設/紮根的隊數中，material 全程零進出【且】建物欄全程零變化 的隊數
    （分母=宣稱過的隊數，分子=兩者都零效果的隊數）
C2＝「at_market 且 current_option=='貿易'」出現過的隊·日中，當日 coin 淨額==0 的隊·日
    （分母=這樣的隊·日數，分子=其中 coin_net==0 的）
C3＝current_option 剛剛【變成】「領取」的那個瞬間（commit 的那一 tick），其中那一 tick
    coin 瞬時無變化的次數（分母=commit 次數，分子=瞬時不動的次數）

N天｜C1分子/分母｜C2分子/分母｜C3分子/分母
 7 ｜ 3/5 ｜ 1/7  ｜ 0/0
10 ｜ 7/10｜ 4/12 ｜ 0/0
15 ｜ 6/10｜ 9/18 ｜ 0/0
30 ｜ 6/11｜22/40 ｜ 2/3

★你的疑慮成立：C1 在短窗跟 30 天差很大（3/5＝60% vs 6/11＝55%，但 10 天 7/10＝70%、
  15 天 6/10＝60%——不是單調，窗越短越容易被少數幾隊的個案支配，分母也小）。
★C3 在 7/10/15 天母體恆 0/0——不是儀器沒接電，是「領取」commit 事件本身很稀，
  短窗根本等不到它發生一次；只有 30 天窗撞到 3 次。★這對你選窗口是直接相關的信號：
  若 C3 是票 A 要看的格，窗口選短了會長期母體恆空，不是「沒有這個問題」。
```

# 三、落地

```
commit：2adb8ac03（已 push）
床：scripts/debug/window_timing_ticketA_ratios.gd
產物：docs/measurements/window-timing-ticketA-ratios.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/window_timing_ticketA_ratios.gd
```

# 四、另一件（①）

```
Team7 combat trace 已落地交 QA，另一封 handback：
docs/superpowers/handbacks/2026-10-06-measurer-to-qa-team7-combat-trace.md
★關鍵發現先告訴你：窗內零 combat_start/combat_end 訊息涉及 Team7，faction 轉變是
faction_defect（自願脫離）不是被征服，整窗被 Team5 等隊反覆徵收 tribute（rate=0.45）。
細節在那封信，QA 已收到副本敲門。
```

# 五、追加（你那封尾端新增的 wall.reject_*／village.build_fired）

```
收到，記下待辦：等 Q-raid 那張 tap 對準 merge 後一起補跑，到時敲我。本輪不處理（還沒接電）。
```
