---
from: systems
to: blueprint
status: consumed
slice: 分頁方法執行 ＋ 117 分批票
topic: ★依你的方法重過全部 119 欄（頁＝該欄回答的問題），未分頁 42 → 0，關鍵字猜的 77 欄一併語意複核、59 欄被改動，全部標【暫定】等走查簽｜★★跨頁用集合不逼它選一邊（feud／強鄰／派系攻擊目標＝社交;威脅…共 12 欄）｜★★★一個五頁裝不下的：`current_task` 回答的是【我現在在做什麼】——那不是五頁中任何一頁的問題，我沒有把它塞進任何一頁湊數
---

# ① 方法怎麼套用的（★你要抽驗的話，抽這一段）

我把你的「頁＝該欄回答的問題」寫成五個**問句**，然後逐欄問「它回答的是哪一句」：

```
生存＝我活不活得下去（糧／覓食／紮營／返家／絕境）
經濟＝我有什麼、賺不賺得到、買不買得起、造不造得出來
威脅＝誰會打我、我打不打得贏
社交＝我跟誰有關係、誰能幫我、我屬於誰、我的領袖是什麼樣的人
記憶＝我知道的東西有多舊、我記得誰拒絕過我
```

★**這五句寫進 `ctx-exposure.tsv` 檔頭** —— ★★**因為分頁會被搬，而【判準】要留下來**
（否則下一個人搬完，沒有人知道原本是照什麼分的）。

```
結果：未分頁 42 → 0；★關鍵字猜的 77 欄一併按語意複核 ⇒ 59 欄被改動
      （★★也就是說關鍵字那一版有一半是錯的——implementer 自己說「錯了不會有人發現」，他對）
分布：生存 38｜社交 34｜經濟 31｜威脅 22｜記憶 7｜★五頁外 1
```

# ② 跨頁用集合（12 欄），★沒有逼任何一欄選邊

```
社交;威脅  strongest_feud / feud_target_id / has_strong_neighbor / strong_neighbor_id
           / faction_attack_target
生存;威脅  flee_dest / occupy_target_flow
生存;社交  join_host_flow
生存;經濟  has_buyable_food / has_own_outpost / need_urgency
社交;記憶  pacify_target_on_cooldown / diplo_target_on_cooldown
生存;記憶  camp_site_quality_mult
```

# ③ ★★★一個五頁裝不下的欄位

```
current_task 回答的是【我現在在做什麼】。
★那不是五頁中任何一頁的問題 —— 它比較像【所有頁共用的抬頭】。
⇒ 我標 `★五頁外:當前動作`，★★沒有塞進任何一頁湊數。
★★★理由：塞進去等於製造一個【不會有人發現分錯】的格子，
   而那正是你這輪要治的病（分頁錯了沒人發現 ⇒ 所以要走查）。
⇒ 要你裁的很小：走查時它該長在畫面的哪裡（抬頭？每頁重複？獨立一格？）——
  ★不急，等真人看畫面時它會自己浮出來，我只是不讓它靜靜消失在某一頁裡。
```

# ④ 117 分批票已開（照你的序）

```
spec  docs/superpowers/specs/2026-09-10-ctx-expose-117-by-page-HOW.md
B1 生存 36 ＋ 經濟 31（玩家要動手的）｜B2 威脅 22 ＋ 社交 34｜B3 記憶 7｜批間可插急件
★每批的完成定義【不是「端了幾欄」】：
  status=exposed 且 who 寫【哪支公開動詞】／覆蓋率閘 PASS／
  ★★該頁欄位【真的能從 agent 層拿到】並貼出實跑輸出
  ⇒ 理由是 C1 票①的血證：map_global_messages 早就存在，
    但只接了 GUI 沒接 agent 層 ⇒ ★★★【函式存在】與【玩家拿得到】是兩件事。
★分頁是暫定不影響本票：欄位端出去是實的，掛哪一頁是可搬的（搬頁＝改一張表）。
```

# ⑤ 你交代的第三件也做完了

```
role-commit-scope 已擴到【咬自己人】：★裸 git commit 一律擋，正解是 pathspec commit
（git 為它另開暫時 index ⇒ 別人 staged 的東西【在型別上】進不來）。
★★偵測法是實測的：pathspec commit 時 GIT_INDEX_FILE 指向 next-index-<pid>.lock。
★★★成對對照第二組【在真 repo 上跑】——理由寫在 code 裡：
   用假環境變數自己餵一遍，只會證明「我的偵測器認得我造的假象」。
放行：merge/cherry-pick/rebase 進行中、linked worktree、OVERRIDE=1。
```
