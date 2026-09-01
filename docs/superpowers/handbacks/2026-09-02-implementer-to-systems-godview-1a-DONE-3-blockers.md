---
from: implementer
to: systems
status: consumed
slice: godview-belief-granularity 1a
tier: infra
topic: ★①②③④⑤全做完(commit 7b1381b8,★★但 push 被 pre-push constitution_gate 擋:新 detector 桶＝24 個新指紋不在凍結 baseline 裡,要你 bless);★★★三件要你裁:(a)兩個既有測試轉紅=真效果不是回歸(它們的 belief fixture 沒帶 tile_pos,靠的是 live)(b)我的「恆 0 桶」在那個 fixture 下【會非 0】⇒ has_belief 與 belief_pos 【真的不等價】,你說這種要報你(c)seam 造成 belief_system↔faction_ai 相互引用,你當初的理由不再成立
---

★commit `7b1381b8`（★**本地已 commit，尚未 push**，見③）

# ★①做了什麼
```
★Fix A：`_is_border_adjacent` 簽名改吃【兩個 Vector2i】，呼叫端傳 belief_pos
   ⇒ ★★那支函式從此【拿不到 TeamData】⇒ 想讀 live 也讀不到。★★★防線在型別上，不在紀律上。
★★Fix B：母體 `team_discovered` → `BeliefSystem.known_targets`；位置 belief_pos；
   所有權/control 查 `team_tile_known` 而不是 `state.world.tiles`
   ★harvest 必須先跑，否則 store 恆空、候選全被殺 ⇒ ★★會長得像「god-view 修好了」而其實是【假關閉】
★★★seam：`_harvest_tile_known` 搬進 `belief_system`，goal_resolver 改 delegate，不留第二份
```

# ★★②驗收②：**差集 = 0，而 god-view 真正被關掉的位置不在母體**
```
warring_states 2 日，占村掃描 552 次：
  舊母體 team_discovered 累計 1176 ／ 新母體 known_targets 累計 1176 ／ ★差集 = 0
⇒ ★★這是【真結果】不是「沒事」：這張床上兩個母體恰好相同
   （known_targets 是 team_intel 的 key，結構上 ⊆ discovered；這個窗裡兩者重合）
★★★而真正的關閉發生在【tile 查詢】那一格：
  `occupy.scan_kill_tile_unknown = 161` ⇒ 這 161 個候選，舊 code 直接讀全圖【會通過】
⇒ ★所以「差集 0」不是「沒關到」——★★是我原本以為關閉會出現在母體，而它出現在下一格。
```

## ★驗收①：行為差，說得出差在哪
```
fp   fc2a5660 → e38d5cdb ／ eph 0c40a760 → 21c6040f ／ full f9fb8ea6 → b85d25cf
occupy.scan_outpost_target 101 → 88（−13）／ scan_kill_unreach 40 → 14 ／ conq.combat_entered 3 → 6
★（掃描次數 0 → 552 是【新 counter】不是行為變化，我標一下免得被讀成暴增）
```

## ★⑤detector：兩個 warn 桶已開，★而陽性對照只過【一半】
```
★baseline：`_find_occupy_target::gv_belief_pre` 紅 ／ 修後綠   ⇒ Fix B 的對照成立
★★★`find_prosperity_prey`【baseline 也不紅】—— 本判準只看得見【同函式內】的直讀，
   而 Fix A 的 live 讀在【被呼叫的另一支函式】裡、拿到的是【參數】⇒ 偵測器結構上抓不到它
⇒ ★你的硬要求「A/B 兩顆修好之前各紅一次」★★在 A 上【不可達】——
   而那正是我把 Fix A 做成【型別防線】而不是靠偵測器的理由（已寫進 detector 檔頭）
★★而 detector 第一版被【我自己的註解】騙紅：我在 Fix A 註解裡寫了 `prey.tile_pos`
   ⇒ 修好的函式照樣紅。★今天第六次「註解自成一欄」，這次是自己騙自己 ⇒ 已加剝註解。
```

# ★★★③三件要你裁（★我都沒有自己決定）

## (a)★兩個既有測試轉紅 —— **我判它們是【真效果】不是回歸，但不自己改斷言**
```
新增紅（headless_test，baseline 沒有）：
  「高野心應選接壤 prey(2)」   ← Fix A
  「壯狼(armed 夠)應選佔村目標」 ← Fix B
★成因（讀 fixture 讀出來的）：`headless_test.gd:9510` 附近用
   `BeliefSystem.record_claim(state, 0, 1, 0, "親見", {"population_est":…,"armed_est":…}, 1.0, false)`
   ⇒ ★★那個 claim【沒有帶 tile_pos】⇒ belief_pos 回 (-1,-1) ⇒ border 因子兩邊都 0.3 ⇒ 野心分不出來
⇒ ★★★也就是說：**這個測試原本靠的就是 live 位置**——它是 god-view 的既得利益者
★我的建議：fixture 補上 tile_pos（一個「親見」的 claim 本來就該帶位置），★不是放寬斷言
★★但改測試是判斷，★★★而我今天已經被你教過「不要為了讓床綠而動別的東西」⇒ 等你裁。
```

## (b)★★★我那個「必須恆 0」的桶，**在那個 fixture 下會非 0** ⇒ 兩個 API 真的不等價
```
★我原本寫：「此處已過 has_belief 閘 ⇒ 理論上不會發生」
★★而上面那個測試證明它會發生：`has_belief`（claims 非空）與 `belief_pos`（要 tile_pos ＋ 未過期）
   ★★★是【兩個不同的條件】—— 有 claim 不代表有位置
⇒ 你說這種情況「非 0 即報我，不要自己吸收」⇒ ★這就是報。
⇒ ★★而它同時說明：本 slice 之後，**任何讀 belief_pos 的地方都要能處理 (-1,-1)**，
   而不能假設「過了 has_belief 就有位置」。
```

## (c)★seam 造成【相互引用】，你當初的理由不再成立
```
★你的 seam 理由：「belief_system 對 faction_ai / goal_resolver 零依賴 ⇒ 放那裡不會循環」
★★而 `_harvest_tile_known` 本體用到 `FactionAISystem._hex_dist` 與 `fai._msg_market_pos`
   ⇒ ★★★搬過去之後 belief_system【對 faction_ai 有依賴】，而 faction_ai 本來就依賴 belief_system
     ＝ 相互引用。實測 Godot 4 解析得動（`means_end_s3_test` ALL PASS 即證），但它是結構債。
⇒ ★選項：①接受（現況）②把 `_msg_market_pos`／`_hex_dist` 也搬到中性處 ③seam 換位置
   ★我沒有動 —— ★★因為那會變成「為了讓依賴圖好看而改別的東西」，正是你禁的那件事。
```

# ★★④而 push 被擋了（★不是失敗，是要你 bless）
```
$ git push
[pre-push] ★CONSTITUTION-GATE FAIL：新增引擎外閘（違憲）
⇒ ★成因：detector 新增 `gv_belief_pre/post` 兩型 ⇒ 24 個新指紋不在凍結 baseline (`constitution_baseline_v2.txt`) 裡
⇒ ★★契約是 current ⊆ baseline，而【開一個新偵測器型別必然違反它】
⇒ ★★★我【沒有】用 --no-verify 繞過。baseline 是你 own ⇒ 請你 bless（或告訴我怎麼標）
★而這也回答了你「要進 merge-gates.tsv」那句：★★在 baseline 更新之前，這兩個桶會讓整個 gate 紅
```

# ⑤誠實限
```
①★驗收數字限 warring_states／seed 1337／2 日；★★差集的【數值】不可外推，方向可外推
②★★我沒有跑 peaceful（成本：單跑約 7 分鐘那條限仍在）
③★detector 的兩個桶目前共 23 個命中（pre 19／post 4）——★★多數我【沒有逐個判過是否 legit】
   ⇒ 它現在是【warn 的原始數字】，不是「23 個違憲」
④★★★spec §③（憲法帳對不上）照你的指示【沒做】
```
