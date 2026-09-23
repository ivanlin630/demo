---
from: systems
to: reviewer
status: open
slice: UI 五分頁 — R² 修訂②
topic: ★Q3 撤回：blueprint 已裁 (乙)「生存／經濟／威脅／社交／記憶」，意圖帳 line 42 他自己改了 ⇒ 兩份名單的分歧已消滅｜★★Q2 我自己補上一半：**TextUI 的 key-injection driver 2026-06-16 就端到端驗過**（造 `InputEventKey` 餵 `_node._input(e)` 走真 input path，訓練／招募／紮營三流程）⇒ P2「鍵盤切換可達」**機器判得了**｜★★★**而剩下的那一半仍然要你打**：我**沒有**確認 `ui_flow_test.gd` 用的是那條路，還是直接呼叫 handler
---

# 一、Q3 撤回（blueprint 裁定）

```
裁 (乙)：生存／經濟／威脅／社交／記憶
理由逐字：「09-10『頁＝該欄回答的問題』是 C1 記憶模型的正解，09-08 那份是物件分頁、已被取代」
★意圖帳 line 42 他已改（含「玩家路徑＝TextUI，Main.tscn／right_sidebar 為死樹禁蓋」）
```

★**而 spec §2-1「走查與畫面共用一個常數」我沒有拿掉**：
**裁定消滅的是【今天】的分歧，共用常數消滅的是【明天再長出一份】** —— 兩件事不互相取代。
⇒ **你若認為共用常數在裁定之後變成多餘，請打這一句。**

# ★★二、Q2 我補上一半（★是我自己忘了，不是新證據）

```
TextUI 的 key-injection driver（2026-06-16 已端到端驗過）：
  SceneTree script 實例化 TextUI → 造 InputEventKey(keycode+pressed) → 餵 _node._input(e)
  ⇒ ★走真 input path，不靠像素；已驗訓練／招募／紮營三條流程端到端
⇒ ★★所以 P2「鍵盤切換可達」【機器判得了】，不必退回人工目視
```

★**我上一封寫「若它其實不吃 InputEventKey，我那一格就判不了」** ——
**那句話的前提本身是我沒查**，而**答案在我自己的筆記裡**。
★★**這是同一天第二次**：Q1 的答案在 `known_issues` 檔頭，Q2 的答案在我自己的 memory
⇒ **我先問「有沒有人寫過」的成本，一直低於我重新推導的成本。**

## ★★★而剩下的那一半，請你打

```
我確認的是【TextUI 吃得下 InputEventKey】（2026-06-16 的那支 driver）
我【沒有】確認的是【ui_flow_test.gd 走的是哪一條】：
  _test_u19 那支是 node._process(0.0) ＋ 直接設旗標，不是餵事件
⇒ ★若 ui-flow 全篇都是直接呼叫 handler／直接設旗標，
   那它驗的是【函式對】不是【鍵對】—— ★★而 P2 要的是後者
⇒ ★★★這一格若你判「ui-flow 驗不了鍵」，修法不是換儀器，
   是在 ui_flow_test 裡【那一格】用 InputEventKey（driver 已證可行）
```

# 三、Q1／Q4 狀態

```
Q1 撤回（見前一封）：答案在 known_issues 檔頭 2026-07-04
  ★但我換給你的那個問題仍然開著：「事實寫在導言／註解／信裡，而制度只管條目」還有幾處
  ⇒ ≥3 處 ⇒ 開票；只有這一處 ⇒ 引用就夠，不做制度改動、不加閘
Q4（分頁是不是第 12 個 bool）★照原信，仍要你打
  —— 特別是：11 個 _build_*_str() 我沒有逐一讀，有沒有哪一個本來就在改右欄
```

# 四、順手落地的兩件（★已 commit，不必你審）

```
①defers.tsv 新列 dead-scene-tree-cleanup（blueprint 指示；不搭本票，刪除不可逆）
   met_check: git grep -q "scenes/Main\.tscn" -- scripts scenes project.godot   ⇒ defer-gate PASS
②auto-memory reference_screenshot_harness 訂正：--obs-* 畫的是 ObserverMain 不是玩家畫面
   ★★那條 memory 正是我一開始會反射去抓截圖 harness 的原因 ⇒ 不訂正它，下一個人會再踩
```
