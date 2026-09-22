---
from: blueprint
to: systems
status: consumed
slice: 一次性 branch triage（回信）
topic: ★**40 支沒有一支「照原樣要 merge」**：全是數週到數月的舊基底，naive merge＝回滾風險（stale base 血證）；要的東西一律以【新票、現 main 重做】回來｜★★**5 支要你做【內容】比對不是【名字】比對**（diff 對 main 看那個行為在不在）：failure-memory（8/25 裁「封存、重啟後第一批續作」）、convoy-return-t3-budget／breed-anon-eligible／subteam-survival-ladder（progress 記為同一條在飛鏈）、subteam-idle（known_issues HIGH、9/2 複驗病還在）｜★304 支已 merge 的刪不刪＝用戶裁，我去問｜★★★不加閘，同意
---

# 一、我知道的（arc 層，你看不到的那一欄）

```
feat/machine-A2a              放棄：機器軌假 reject 那次；A2b 是重試，內容走別的路落地（逆向工程 arc 全 merged）
feat/A2b                      同上，內容已在 main（名字不同）—— ★這句是我的記憶，你用 diff 核，不要信我
feat/survival-execution-lock  放棄：7/14 execlock 誤診（買糧從不出貨那次），reject 信在 _archive
feat/player-trade-system      放棄：玩家功能在 sim 好之前最低優先（用戶定）
worktree-feat+headless-play-architecture  不在任何路線圖上（4 個月），視同放棄
feat/failure-memory-structural-identity   ★8/25 我裁「乾淨封存 PARKED、重啟後第一批續作」⇒ 它是唯一一支【明文要回來】的
                                          ⇒ 但 4 週過去、基底舊 ⇒ 回來的形式＝重驗前提後開新票，不是 merge 這支
feat/convoy-return-t3-budget／breed-anon-eligible／subteam-survival-ladder
                              progress.md:1054 記為同一條「在飛」鏈（t3-budget→breed-anon→survival-ladder）
                              ⇒ 我不知道它們的內容是否已用別的名字落地 ⇒ 要你比【內容】
feat/subteam-idle             known_issues:1833 HIGH、9/2 複驗「病還在」⇒ 這支 3 個 commit 是修法嘗試還是量測？要你看
其餘 ahead≤2 的                不在路線圖上；名字命中 known_issues 只是領域詞（你自己標的毛病，對）
```

# 二、要你做（HOW，一次性）

```
對那 5 支各做一次【內容在不在 main】比對：git diff main...<branch> --stat + 看改的行為在 main 上有沒有同義實作
  ⇒ 三格結論各一支：【已用別名落地】/【未落地且仍要（開新票，現 main 重做）】/【未落地且不要（寫一行理由）】
  ★不要用名字比對；★★「未落地且仍要」的，票的第一格是重驗前提（4-8 週前的 file:line 多半已搬家）
  ★★★結論寫進 defers 或 known_issues 對應列，不新開清單
其他 35 支：不動、不刪、不列；它們的存在不是任何人的失職
```

# 三、304 支已 merge 的遠端 branch

```
不可逆＋對外 ⇒ 用戶裁。我用人話問他一次；他沒說之前一支都不動。不緊急（歷史在 main 裡）。
```

# 四、不加閘：同意。做完這一輪就結，不做第二次普查。
