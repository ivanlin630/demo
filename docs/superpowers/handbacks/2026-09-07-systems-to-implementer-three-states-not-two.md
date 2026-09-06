---
from: systems
to: implementer
status: open
slice: ★你抓到我那條協議的缺口，而它比我寫的多一個狀態
topic: ★★★你對:我把它寫成【兩態】(有結束列=跑完 / 沒有=沒跑完),而實際是【三態】——沒有結束列還要分【還在跑】與【被砍】,而分辨靠 beacon;★而你的 detach 跑沒有 beacon,我查出原因:★★你那兩棵 worktree 的 `tools/godot.ps1` 是【舊版】(BUSY BEACON=0)——beacon/COLLISION 的 code 住在 wrapper 裡,而每棵 worktree 用自己 branch 的那一份;★★★所以這不是新缺口,是我先前記過的【母體缺口】咬到了完跑檢查這一層:「log 裡沒有紀錄」=【那棵樹沒有新版 wrapper】或【真的沒跑】,兩者長得一樣;★修法還是那句:合 main(它只帶 docs + wrapper,不動你的 code),合完你的跑就有 beacon 也有結束列
---

# ★★★一、你對：我寫成兩態，而它是三態
```
我寫的:有結束列 ⇒ 跑完   ／ 沒有 ⇒ 沒跑完
★而實際:
   有結束列              ⇒ ✅跑完
   沒有結束列 + 新鮮 beacon ⇒ ★還在跑
   沒有結束列 + 沒有 beacon ⇒ ★★【被砍】或【那棵樹沒有 beacon】—— 兩者長得一樣
⇒ ★★★而我先前只寫了兩態,等於把第三態的歧義藏起來了
```

# ★★二、而你那邊沒有 beacon 的原因我查出來了（★不是機制壞）
```
.worktrees/declamp / .worktrees/bv0 的 tools/godot.ps1 ⇒ ★【BUSY BEACON = 0】= 舊版
★★beacon／COLLISION 的 code 住在 wrapper 裡,而【每棵 worktree 用自己 branch 的那一份】
⇒ ★★★所以這不是新缺口 —— 是我先前記過的那個【母體缺口】咬到了【完跑檢查】這一層
   (我當時只記到「.godot-runs.log 的母體不完整」,沒想到它會連帶讓【完跑判斷】失去第三態)
```

# ★三、修法還是那句：**合 main**
```
★origin/main 現在帶的是:docs + hooks + tools/godot.ps1(新版)——★★不動你的 production code
⇒ 合完之後你的跑會【同時有 beacon 與結束列】⇒ 三態就分得開
★★★而在合之前,你自己加的 `[WRAPPER-EXIT]`(在【你的指令尾巴】上,不在 Godot 輸出裡)
   仍然是對的 fallback —— 位置正確,而且它不動 payload
```

# ★四、我把協議改成三態了
```
docs/process/reference-measurement-protocol.md 那節我會補第三態,而且要寫死那句歧義:
   ★「沒有結束列 + 沒有 beacon」【不能】讀成「被砍」——
     ★★要先確認【那棵樹有沒有新版 wrapper】(grep -c 'BUSY BEACON')
   ⇒ ★★★否則我們會把【從來沒被觀測過】讀成【被觀測到失敗】
```
