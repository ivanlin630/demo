---
from: systems
to: reviewer
status: open
slice: ui-flow 決定性修正 — merge 前 R②
topic: ★分支 `fix/ui-flow-determinism` ＝ `f97cd51d2`｜★★★**這一票修的是【註冊表上那支閘本身不可靠】**：`ui_flow_test.gd` 與 `ui_state_str_capture.gd` 都沒播全域 RNG ⇒ 世界每次不同 ⇒ `_test_pages_zero_loss` 隨機紅（實測 6 跑 2 紅）｜★★**而「隨機紅」比「恆綠」更糟**：它會被當成雜訊，然後整支註冊表上的閘被降級｜★要你打的是：**seed 放的位置對不對**，以及**那份重取的「前」能不能被信**
---

# ★一、證據（★兩個人各跑一輪，而結果不一致 —— 那本身就是讀數）

```
systems（.worktrees/battery ＠ ed128a1e7）：3 跑 ⇒ 3/3 綠
implementer（.worktrees/tauto ＠ 3b661eba6，★scripts 逐位元相同）：3 跑 ⇒ ★紅／紅／綠
⇒ 合計 6 跑 2 紅（~33%）
紅的那一格：_test_pages_zero_loss
  逐行報告：「舊 1 次 → 新 0 次：狀態: 覓食  疲勞: 0%」
★而同一卷面上「世界：tick=120/120 teams=16/16 persons=43/43」【對得上】
⇒ ★★所以既有那道「世界對不上 ⇒ 不可判」的守衛【攔不到它】：變的是【內容】不是規模
```

# ★★二、根因與修法

```
根因：兩支床都沒有 seed(...) ⇒ runtime 那 72 處 bare randf()/randi() 每跑一條新流
  ★config/default.json 的 "seed": 42 只餵 GameSetup 的【局部】rng（game_setup.gd:58）
  ★★而擷取床【第一版本來有 seed】—— 是他改寫時跟著 UC_CONFIG 一起拿掉的
  ⇒ ★★★所以那份「前」是【浮動的】，而 P1-b 拿一個浮動的基準去比對
修法：兩支床在 instantiate【之前】seed(1337)（場景在 _ready 就建世界）＋ 用同一顆種子重取「前」
前例：warring_harness.gd:120／observer_main.gd:51 都是這個形狀
驗證（他跑的）：同一棵樹連跑 5 次 ⇒ 5/5 errors: 0｜31／31
```

# ★★★三、要你打的兩格

```
(1) seed 放的位置：他說「instantiate 之前」，理由是場景在 _ready 建世界
    ⇒ ★請核：_ready 之前真的沒有別的東西先吃掉全域 RNG？
      （★★若有，那 seed 只覆蓋了一部分 ⇒ 仍然浮動，而它會從 33% 降到某個更低的頻率
        —— ★★★那比現在更難抓）
(2) 那份重取的「前」：它現在是「用種子 1337 跑出來的一份快照」
    ⇒ ★請核：擷取床與 ui_flow_test 兩邊【真的用同一顆種子、同一條路徑】建世界？
      ★★若兩邊有任何一處不同（例如 config 不同、instantiate 順序不同），
        那份「前」與比對它的那次跑【仍然是兩個世界】，只是變得穩定而已
    ⇒ ★★★判法我建議：拿【兩個不同種子】各跑一次擷取床 ⇒ 輸出必須【不同】
      （相同 ⇒ 那顆種子沒接上，同他今天抓到的 UC_CONFIG）
```

# 四、範圍

```
git diff --stat main...origin/fix/ui-flow-determinism ⇒ 只有兩支 debug 床 ＋ 重取的「前」快照
★零 production 改動；★★獨立於票B，可先 merge
```

# 五、verdict

```
CLEAN ⇒ 我 merge（併前跑全電池）
issues ⇒ 逐條帶 file:line
★★★而在它併進去之前，ui-flow 的每一次綠【都可能是運氣】—— 這一句請你確認我沒有誇大
```
