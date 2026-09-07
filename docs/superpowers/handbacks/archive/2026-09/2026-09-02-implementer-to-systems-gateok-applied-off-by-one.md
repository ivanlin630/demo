---
from: implementer
to: systems
status: consumed
slice: 27 顆 gate-ok apply
tier: infra
topic: ★41 行標完(26 個指紋),站點 94→69 ＝ −25 ⇒ ★★【對不上 1 顆】,我沒有自己調:成因定名＝`faction_ai_system.gd:4941` 是一行【註解】裡寫著 `for tile_id in state.world.tiles:`,而既有 gv_mapscan 偵測【不剝註解】;★★★今天第七次「註解自成一欄」,而這次在【既有偵測器】不是我加的那半;★另退回 4 顆判不出來(reviewer 理由涵蓋不到那一行的具體讀,不延伸);★順帶抓到偵測器一顆誤判並照實寫進標記
---

★commit `6b6ef525`（branch 已 push）｜閘 `PASS (sites=69, removed=9)`｜gv_belief_* WARN 21 → **4**

# ★①照裁定做的
```
★標在【偵測器指到的那一行】（★我先用鏡射偵測邏輯的定位器把函式級指紋還原成行級位置）
★★理由逐行寫【這一行讀什麼、為什麼那個讀合法】——不是複製 reviewer 的函式級句子
★逐行貼、禁批次 sed
⇒ 共 41 行 ／ 26 個函式級指紋
```

# ★★②【對不上 1 顆】—— 我沒有自己調，成因定名
```
站點 94 → 69 ＝ −25，而我標的是 26 顆 ⇒ 差 1
★成因：`faction_ai_system.gd:4941` 是一行【註解】：
   「★★迭代順序的 pin【仍然有效、不解除】：`for tile_id in state.world.tiles:` 一行沒動、」
⇒ ★★既有的 `gv_mapscan` 偵測【不剝註解】⇒ `_evaluate_infrastructure::gv_mapscan` 沒消失
⇒ ★★★而我的 `gv_belief_*` 那半【上一輪已經加了剝註解】—— 所以只剩既有那半會踩
```
★**今天第七次「註解自成一欄」**，而這次在【既有偵測器】。
★★**修法我沒有動**：把剝註解加進 `gv_teamstate/gv_mapscan` 那一支，
★★★**會讓 baseline 裡某些 mapscan 靜默消失**（若它們也是註解命中）—— 那是 baseline 語意改動，**你的**。
⇒ ★**而它可以順便當一次體檢**：baseline 74 行裡有幾行其實是註解命中？我沒查（不在本票）。

# ★★★③退回【判不出來】的 4 顆（不硬標）
```
①`_evaluate_all_body::gv_belief_post`
   reviewer 理由＝「本身就是 belief harvest 正確消費模式」
   ★而那幾行讀的是 `parent.tile_pos`（:946/954/955/956/961）
   ⇒ ★★理由【涵蓋不到這個讀】⇒ 依你的裁定【不准延伸】⇒ 退回
   （★我知道它多半 legit——parent 是自己的母隊——★★但那是【我】的推論，不是 reviewer 判的）
②`consolidate_target_of::gv_belief_pre`
   reviewer 理由＝「同既有 baseline 標記 74（gv_teamstate）同一函式同理由」
   ★而 74 指的是【那一行 gv_teamstate】；:2742/:2746 是另外兩行、讀的是別的東西 ⇒ 退回
   （★:2738 那一行【就是】74 講的那顆 ⇒ 已標）
③`_try_invite_nearby_exile::gv_belief_post` —— 本票只解一半，等 blueprint 裁 belief 欄位
④`_update_escort::gv_belief_pre` —— 你說不要猜
```

# ★④順帶抓到【偵測器誤判】一顆，並照實寫進標記
```
`diplomatic_ai_system.gd:153`：
  `var _other_pop_est: int = _get_pop_est(state, self_team.team_id, other.team_id, self_team.population)`
★這一行讀的是 `self_team.population`（自己）
★★而偵測器把 `other.` 之後【同一行稍後出現】的 `.population` 誤配成 `other.population`
⇒ ★★★我把這件事【寫進那一行的 gate-ok 理由】，而不是假裝它是個 legit 的他隊讀
   （★否則三個月後有人看到「gate-ok: 他隊讀合法」會以為我們核可了一件沒發生的事）
```

# ★⑤另修一個我自己造的 parse error（★而它是結構衝突不是手滑）
```
`:4974` 原本是 `\` 續行 ⇒ ★而 `# gate-ok` 是【行級】標記，★★不能放在 `\` 之後（語法錯）
⇒ 把續行併成一行（純排版、零行為）才貼得上
⇒ ★★★這是【行級標記 vs 續行語法】的結構衝突：任何多行條件式都會撞到它
   ⇒ 而它會以【parse error】現形，不是靜默 —— 這次是好的那種失敗
```

# ⑥驗
```
★constitution_gate：PASS (sites=69, removed=9)｜gv_belief_* 21 → 4（＝我退回的那 4 顆）
★★headless_test：HARD-FAILS 3 ＋ assertion 數 11 ＝ baseline
★★★而 removed=9 裡有 8 顆是我標掉的 baseline 舊 marker、1 顆是先前就 removed 的 `_find_own_outpost`
```

# ⑦誠實限
```
①★定位用的是【我自己鏡射偵測器邏輯】寫的 locator ——★★若我鏡射錯了，會標錯行
   ⇒ 而【站點數對帳】就是抓這件事的機制：25/26 對不上那一顆，正是它抓出來的
②★★41 行的理由是我逐行寫的，★★★而其中【26 條是 reviewer 判的、15 條是同函式其他行由我延伸】
   —— ★延伸的部分我限制在【同一個讀的重複出現】（例如同函式三行都是 `parent.tile_pos`）
   ⇒ 若你認為連這種延伸都不准，我可以再退回一批，說一聲
③★baseline 裡有幾行其實是【註解命中】我沒查（不在本票，但那是 ② 的自然延伸）
```
