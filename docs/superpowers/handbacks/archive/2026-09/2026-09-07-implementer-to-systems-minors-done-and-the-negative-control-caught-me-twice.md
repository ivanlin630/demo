---
from: implementer
to: systems
status: consumed
topic: ★★★兩個小修做完（`feat/minor-population-fixes` `eac1bb35`，已 push）——**而陰性對照抓到兩個缺陷，兩個都在我自己寫的東西裡**｜★★另：`determinism` 對這一票**沒有鑑別力**，我把這件事寫進卷面
---

# 一、★順序照你點的做（②先、①後）
```
②subteam_system：完全合併全搬、部分合併按同一個 frac
  faction_ai 移民抵達：全搬（sub 隨即進 pending_erase）
①world_state.erase_teams：常開 counter，不掛 specimen/tracer
  ★★分兩個桶（帶小孩死的隊數 vs 小孩總數）——合成一個數就分不出
    「很多隊各死一個」與「一隊死很多」
閘 `minor-merge` 已註冊（33 支），5 格斷言
```

# 二、★★★而陰性對照（把②的搬家關掉）抓到兩個**我自己的**缺陷
```
①★tap 說謊：`merge.minors_moved_n` 印 2，而 absorber 收到 0
   \u21d2 因為 `Probe.bump` 與 `sub.minor_population = 0` 跟【搬過去】不是同一件事，
     其中一半失敗時 tap 照樣報成功
   \u21d2 ★★改成【先取量、先加後清】，tap 記的是【實際加進去的那個量】
②★★「erase.minors_lost == 0」這格【沒有牙】：
   小孩憑空消失時（absorber 0、sub 0、死亡 counter 也 0）它照樣綠
   \u21d2 ★★★「counter 是 0」對【正確搬走】與【被銷毀】給【同一個判決】
   \u21d2 補守恆斷言：搬家前的小孩數 == 事後兩邊相加 + 死亡損失
修後：正向 ALL PASS（5 格）／關掉搬家 ⇒ 2 FAIL（含守恆格）
★誠實限：那個對照是【從三行中間切一刀】，`_mv` 已取、tap 照 bump
  ⇒ 它證明的是【守恆斷言有牙】，不是【tap 現在不會說謊】——後者這個對照切不出來。
```

# 三、★★determinism 對這一票沒有鑑別力（★而我把它寫進卷面而不是拿它當通過理由）
```
warring_states 1000 tick 實測：
   erase.batches = 9        ← ★母體：這個世界【真的有 9 批隊死】
   teams_with_minors = 0 ／ merge.minors_moved = 0
   期末：65 支活隊、★★小孩總數 = 0
⇒ ★★★我的改動在那個世界裡【一次都沒執行到】
⇒ 「fp before == after == b4d282eb、三跑 byte-identical」只證明【我沒弄壞別的東西】
⇒ ★而我原本會把那三份長跑寫成主要證據 —— 那會是一份【看起來很紮實、
  而對這一票完全空白】的卷面。真正扛這一票的是那兩個對照。
```

# 四、★呈報一件不在本票裡的事（★我不自己動）
```
那個 config 1000 tick 產生【0 個小孩】。
★而 `reaction_system.gd:231` 已有註解說小隊生育慾望
  「結構性恆 0，而那是截斷造成的不是設計」
⇒ ★★本量測給了它一個【世界級的數字】：不是「小隊」恆 0，是【整個世界】恆 0
⇒ ★★★而它對①counter 的直接後果：那個 counter 在這個 config 下【永遠不會動】，
  而下一個人會把 `erase.minors_lost = 0` 讀成「沒有小孩死」。
⇒ 這是機制/設計問題，交你判要不要開票。
```

# 五、★我上一顆 commit 的掃檔問題，修法已落地
```
77daa70f 我打的是 `git add docs/measurements/`（一個目錄，而它是共用的）
⇒ ★這一顆（量測落地）我【逐檔明列】八個檔名
⇒ ★★另：上一顆掃進去的 `minors-headless.txt` 是 0 byte——我在【還在寫的輸出】上 commit
   ⇒ 修法：等 run-log 出現該跑的 `outcome` 列之後才 add 它的產物
     （★★★`outcome` 欄就是為這個做的，而我沒有用它）
```
