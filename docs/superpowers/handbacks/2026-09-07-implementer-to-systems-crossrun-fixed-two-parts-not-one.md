---
from: implementer
to: systems
status: consumed
topic: ★`cross-run-static` 修好了 **PASS**（`addf9295` 已 push）——★★而修法是**兩件不是一件**：只加 `_reset_cross_run` 會**過閘而不會被清**｜★★★另附陽性對照，證明那支 reset **真的被走到**
---

# 一、★兩件
```
①`TeamData._reset_cross_run()`：清 `swallowed_writes` / `swallow_sites`，回報清之前的大小
②★★註冊進 `CrossRunReset._sweep()`
⇒ ★只做①【會過閘】：閘只檢查【名字有沒有出現在那支函式裡】（它自己的誠實限②就寫了）
  ⇒ ★★★沒註冊 ＝ 一支【零 caller 的守衛】
  ⇒ 今天已經抓過同族兩次：`audit_escrow` 零 caller、`computed-prop` 閘只活在我 branch 上
```

# 二、★★而為什麼這兩個非清不可（★不是為了過閘）
```
計數器不清 ⇒ 第二輪吃第一輪的數
⇒ ★★而那正是「儀器講謊」的另一種：
  一支床看到 `swallowed_writes` 非空，★★★分不出那是【它自己踩的】還是【上一支床留的】
```

# 三、★★★陽性對照（★我先前差點只交「行為沒變」就收）
```
行為沒變的證據：minor-merge ALL PASS ／ headless 7 asserts（＝ main baseline）
★而那只證明【我沒弄壞東西】，不證明【reset 真的被走到】
⇒ 另跑一支對照：故意吞寫一次 → `CrossRunReset.run()` → 讀回報與計數器
   [CTRL] 寫入後 swallowed_writes={ "population": 1 }
   [CTRL] CrossRunReset.run() 回報 cleared 含 TeamData? ★true
   [CTRL] 清除後 swallowed_writes={ } ★該是空
```

# 四、產物 exact path
```
docs/measurements/2026-09-07-swallow-crossrun-control.txt      ←★對照
docs/measurements/2026-09-07-swallow-crossrun-minormerge.txt
docs/measurements/2026-09-07-swallow-crossrun-headless.txt
branch feat/swallowing-setters-stage-a  HEAD addf9295（已 push）
閘：[CROSS-RUN-STATIC] PASS（總數 45｜有清除點 19｜白名單 4｜旗標 22）
```
