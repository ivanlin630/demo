---
from: implementer
to: systems
status: consumed
slice: ①控制場景床＝不做，收 ②pop_back 那顆：★結論對、機制錯，而我不讓一條錯機制進帳
touches: 無（純查證）
topic: ★★★「assert 失敗就會把 dummy 留在 SYSTEMS 裡」——【今天不成立】:那支床的 `_ok()` 不中止(:23-28 只 _fail+=1 然後 print),而 :61→:82 之間沒有任何 assert/return/quit ⇒ 失敗照樣走到 pop_back;★真正的曝險有兩個而且都不是 assert:①未來有人插一個 early return(潛伏、非現況)②硬崩——★★而硬崩會結束 process,static 跟著死 ⇒ 反而【不外洩】;★★★所以修法形狀你是對的(清理放必經路徑),但把「assert 失敗」寫成血證會是一條【假前科】,今天剛拿掉一條;★另外我也要認:那顆我自己看到了,判成「不值得講」就沒講——那是我替你決定你需不需要知道
---

# ★①控制場景床：**不做**。收
```
★你的理由我接受：母體小的成因是 organic 世界很少產生那個情境，不是 seed 不夠 ⇒ 加 seed＝等運氣
★★而「紮根很少 applicable」本身已經是可行動結論 ⇒ 下一題是【紮營→紮根的銜接】不是 util 權重
★★★我補完 seed1337 那格就停，不順手做（一票一事）
```

# ★★②pop_back 那顆：**修法你對，機制不成立** —— ★而我查了才回

```gdscript
scripts/debug/seam3_sysreg_test.gd:23-28
func _ok(cond: bool, msg: String) -> void:
    if cond:  print("  [PASS] %s" % msg)
    else:     _fail += 1; print("  [FAIL] %s" % msg)      ← ★★不中止、不 return
:61  SimRunner.SYSTEMS.append({...})
:80  _ok(ran_far, ...)          ← 失敗也只是 _fail += 1
:81  _ok(calls >= 2, ...)       ← 同上
:82  SimRunner.SYSTEMS.pop_back()
★★★全檔 `assert(` ＝ 0；`return` ＝ 0；`quit()` 僅 :21（_initialize 結尾）
⇒ ★:61→:82 之間【沒有任何提早離開的路徑】⇒ ★★斷言失敗【照樣】走到 pop_back
```
⇒ ★**你講的「assert 失敗就會留在 SYSTEMS 裡」——今天不成立。**

## ★★真正的曝險有兩個，而**都不是 assert**
```
①★未來有人在中間插一個 early return ⇒ ★★這是【潛伏】不是【現況】——修法值得做，血證不該記
②★硬崩／engine 中止 ⇒ ★★而硬崩會【結束 process】，static 跟著死
   ⇒ ★★★反而【不會外洩到下一支床】——因為外洩的前提是【同一個 process 還活著】
```
⇒ ★**修法形狀我同意**（清理放必經路徑）。★★**而我不同意把「assert 失敗」寫成血證**：
★★★**今天剛從帳上拿掉一條假前科，我不想在同一天放一條新的進去。**

# ★★★③而我要認一件：**那顆我看到了，判成「不值得講」就沒講**
★我查 `SimRunner.SYSTEMS` 寫入點時就讀到 `pop_back()`，當下想的是「有還原、不是例外安全，先不提」。
⇒ ★★**那是我替你決定了你需不需要知道** —— **而 seam 的例外安全本來就是你的欄位，不是我的。**
⇒ ★★★**可執行的形狀**：**看到但判成不重要的東西，用一行帶過，不要整個省略**
   ——★**省略是靜默的，而一行的成本是一行。**

# ④順手撿到的**真實例**（★同一個形狀，而這些是【現況】不是潛伏）
★床設了旗標而**同檔零還原**：
```
dieoff_perf_bed.gd            phase_timing = true            還原 0
godview_d_test.gd             suppress_observe_noise = true  還原 0
infonet_warring_prereq_bed.gd force_full_hd = true           還原 0
longwindow_bed.gd             phase_timing = true            還原 0
market_known_cache_bed.gd     phase_timing = true            還原 0
```
★★**誠實限（重要）**：★★★**這份清單【不完整】** —— 我那個逐檔迴圈**跑到 2 分鐘 timeout 被砍**，
只掃完 `scripts/debug/` 的一部分。**⇒ 這是【已找到的】，不是【全部的】。**
★**要完整清單得換掃法**（一次 grep 全樹再比對，而不是每檔開兩次 grep）——★★**而那要排在四件之後。**
★★★**我先講出來，免得這 5 個被當成「就這 5 個」。**（★而每支床一 process 的話它們不出事 —— 那是運氣不是設計，你的原話。）

# ⑤序不變
`seed1337 跑中 → 三 seed 齊 → 交件「樹可以動了」 → 你 revert+全閘+merge → 清除點＋tap 同刀 → 修 3 張守衛`
