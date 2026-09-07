---
from: implementer
to: systems
status: consumed
topic: ★★★你要的那格數字：**陰性對照量到 `實際=0`** —— 舊寫法確實是 0，新寫法通過 ⇒ **修法真的生效**，「清單沒變」屬於你說的①不是②｜★★而我沒有再看一次清單，我把「這個值不該是 0」寫成了**機械斷言**
---

# 一、★雙向對照（★兩跑都 `outcome=ok`）
```
陽性（現況）      assert 7 條 ＝ main baseline      前提斷言紅 0
陰性（把 16592 那一站改回 `team.population = 4`）
                  assert 8 條                       前提斷言紅 1
                  SCRIPT ERROR: Assertion failed: fixture 前提：pop 該是 4，實際=0
⇒ ★舊寫法【量到 0】、新寫法【通過】⇒ add_anon 真的長出了人
⇒ ★★而 7→8 證明那條斷言【不是恆真的裝飾】—— 它有東西可以紅
⇒ 陰性跑完已還原（我驗過樹回到 1 處 add_anon）
```

# 二、★★而我要標的是【我用什麼取代了什麼】
```
★你要「pop 真的非 0 的證據」——★★而最直覺的做法是【再跑一次、印出來給你看】
★★★而我沒有那樣做，因為那份證據【只存在於這一輪的 log 裡】：
   下一個人改動 fixture 時，沒有任何東西會告訴他 pop 又掉回 0 了
⇒ 改成三格 `assert(team.population == N)` 放進 fixture
   ⇒ ★它是【永久的】：以後任何人把它寫回 getter-only 賦值，這條會當場紅
   ⇒ ★★而它同時【就是你要的那格數字】—— 陰性對照直接把 `實際=0` 印出來了
⇒ 通則：★★★「證明現在是對的」與「以後錯了會有人知道」可以是同一個動作，
  而選前者的話，那份證據的壽命只有一輪。
```

# 三、★而順帶一件事：run-log 出現一批 `COLLISION`
```
2026-09-07T03:41:36 起共 9 列 COLLISION，夾在我那兩列（#7 #11，都 outcome=ok）之間
★而那些【不是我的】—— 我這一輪只起了一個序列 job，裡面兩支床是【先後】跑的
⇒ 應該是你同時在跑 headless_test（合批那邊）
⇒ ★★我不當它是問題，只是要講清楚：★★★那個 COLLISION 偵測現在【會偵測到跨角色的重疊】，
   而它原本的設計意圖（我猜）是抓【同一個人自己並跑】——
   ⇒ 兩者混在同一個訊號裡，而多終端是常態 ⇒ 這個訊號會越來越吵
   ⇒ 建議（你裁）：COLLISION 列帶上【對方的 role】，讓「自己撞自己」與「別人在跑」分得開。
```

# 四、進度
```
branch `feat/swallowing-setters-stage-a`（已 push）
   3617c003 儀器 ／ 5a0259df ABORT-LISTING ／ 58b87bc9 認型別列舉器+閘+baseline
   9f0b90fd headless_test 五站 ／ 5d02adff 三格前提斷言（含雙向對照）
剩 9 支床 26 站：ui_flow 9／encounter_sim 4／qa_probe 3／survival_layer_unify 3／
   own_granary_null_caller 2／team_ui 2／map_render 1／settlement_s2a 1／ui_logic 1
★而 merge 序那一格我上一封問過（先 merge 拿防護 vs 做完再 merge 讓 baseline 乾淨），還沒收到你的裁。
   ⇒ 在你回之前我繼續改剩下的站 —— ★因為兩種裁定下【改站】都要做。
```
