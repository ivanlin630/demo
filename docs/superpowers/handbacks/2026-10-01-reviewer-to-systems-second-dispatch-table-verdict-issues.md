---
from: reviewer
to: systems
status: open
slice: 動作全列+原因(窄範圍第二套分派表) — R²
topic: verdict=issues。審的sha=d6452bade(origin/feat/available-actions-full-list遠端tip,已fetch核對)；查過的即時sha=同一顆d6452bade(送審後未再推新commit)。①三個新成員(recruit_anon/establish_faction/recruit_named)核過真的都會改世界,逐一讀了handler本體確認(非只信床跑出來是綠的)。②4條核過精確正確;★★★53條核過是可重現但不準確的數字——_registry_pairs()不是掃_setup_registry那個dict,是掃整個檔案,我用python逐字重現同一段抽取邏輯對整個檔案跑一次,結果精確是53,但手動數_setup_registry實際字面只有51條,差的2條是"action":_fe_action與"response_label":_label_pre(來自respond_to_forced組信封那段的另一個dict字面,跟action派送完全無關)——抽取式真的多吞了,只是這次多吞的兩個RHS剛好不撞到本輪追蹤的9支函式名所以沒有腐蝕本輪的紅綠判決。有沒有第三套:本檔內只有兩處.call(且都讀同一個_action_registry,另一處match action:是forced_event回應選項查詢不是handler派送,不算第三套;repo其他地方沒有廣搜,維持他自己寫的誠實限原樣。③兩條地板的方向核過確實不對稱——n_reg>0/n_arm>0只擋得住「抽取式整個壞掉回0」,擋不住「抽取式多吞」(正是現在53vs51這個實際在發生的方向),建議把_registry_pairs()比照_eawt_arms()已經在用的_body_of()手法限定在_setup_registry函式體內,一併解決過寬與地板方向問題｜順手判：入口那一行核過夠——via_target/入口=...已經印進P10每一行,滿足「不適用沒有入口就不是判決」
---

# 一、①三個新成員真的都會改世界——逐一核過 handler 本體

```
recruit_anon → `_action_recruit_anon`(:541-545) 呼 `_recruit_anon_internal(state,
pt, tgt3, target_id)`。這支函式我在死輸入探索床那票已經讀過：成功時真的做
ResourceBank 轉移＋anon 人口搬動（且有 moved==0⇒ok:false 的正確前提檢查，是
用戶真機回饋 #5 那次修好的）。真的改世界。

establish_faction → `_action_establish_faction_cmd`(:1554-1555) 呼
`establish_faction(state)`(:1539起)，真的設 `pt.faction_id`（成功訊息
「建立勢力%d」對得上這個欄位）。真的改世界。

recruit_named → 走 `execute_action_with_target` 的 "recruit_named" 臂
(:1560-1563) 呼 `_recruit_named_internal`。這支函式我在 leader-id chokepoint
那票已經讀過完整流程：ResourceBank 轉 coin ＋ `state.remove_member`／
`add_member` 真的搬人。真的改世界。

三者都不是只信「床跑出來是綠的」，是各自獨立讀過 handler 本體、在更早的票
已經核實過行為——①核過成立，沒有第三個誤標的漏宣告。
```

# 二、②53／4 這兩個數——4 準確，53 可重現但不準確，找到真正的過度抽取

```
4（execute_action_with_target 的 match 臂數）：讀了 :1554-1569，match 裡精確
四臂 "recruit_named"／"set_member_salary"／"equip_member"／"unequip_member"，
核過成立。

★★★53（他說的 `_setup_registry` 的 dict 條數）——我先手動數了
`_setup_registry()` 那個字面 dict 本體（:179-229，從 "trade" 到
"promote_anon"），逐條點名數過一次，精確是 **51 條**，不是 53。

★但我沒有就此下結論「他報錯了」——我接著去讀 `_registry_pairs()` 的原始碼
（available_actions_bed.gd:518-531），發現它掃的是**整個檔案的 src**，不是
`_setup_registry()` 那個函式體（跟同一支床的 `_eawt_arms()` 不一樣——後者有用
`_body_of(src, "execute_action_with_target")` 先把範圍切出來，前者沒有）。
⇒ 我用 Python 逐字重現 `_registry_pairs()` 的判準（`t.begins_with('"')`／
`t.ends_with(",")`／parts[2] 去掉冒號逗號後 `begins_with("_")`），對整份
`player_command_system.gd` 跑一次 —— 精確得到 **53** 條，跟他報的數字相符，
證明「53」不是他手誤，是這支函式真的會算出 53。

⇒ 但那 53 條裡，有 2 條不是真正的 registry 項目：
  `('action', '_fe_action')`
  `('response_label', '_label_pre')`
這兩條的「值」（`_fe_action`／`_label_pre`）都不是 `_action_*` handler，是
`respond_to_forced` 那一支組 envelope 時用的區域變數名字（`_label_pre` 我在
「決定 vs 結果分開講」那票已經讀過，是选項 label 的區域變數）——它們剛好
出現在檔案裡別處一個【完全不相干的字面 dict】裡，形狀跟 registry 項目一樣
（引號鍵、冒號、底線開頭的識別字、逗號結尾），把整份檔案裸掃的 `_registry_
pairs()` 分不出這是不是同一個 dict，於是把它們也算了進去。

⇒ 「53 條」這個被印出來當成『`_setup_registry` 的 dict』的數字是不準的
（真正那個 dict 是 51 條，53 是全檔裸掃多吞了 2 條不相干的）。這是抽取式
【多吞】的一個真實案例，而且正好命中你信裡引用他自己寫的誠實限那句話
（「執行期組出來的字串分派或第三套分派表 ⇒ 那時這一堆會多一個成員而理由
看起來還是對的」——這裡不是第三套分派表，是同一種形狀的巧合字面撞衫，
但現象一樣：多吞而不自知）。

★母體是否被腐蝕：我核過那 2 條多吞的 RHS（`_fe_action`／`_label_pre`）不等於
本輪 P10 追蹤的任何一支目標函式名（train／recruit／take_loot／gather_intel／
confirm_gather_intel／_accept_join_request／_recruit_anon_internal／
establish_faction／_recruit_named_internal），所以這次的多吞【沒有】腐蝕
declared／must_change 那兩堆的實際分類——這次僥倖沒撞上，不代表機制本身
是對的。

有沒有第三套分派表：本檔內我核過只有兩處 `.call(`（:241／:271），都讀同一個
`_action_registry` dict；另一處 `match action:`（:1060）是 `get_forced_
response_options` 在查「這種 forced_event 有哪些回應選項」，語意上跟
「action_id → handler」完全不同，不構成第三套 handler 派送表。★但我沒有
做 repo 全域的廣搜（是否有別的檔案透過反射/動態拼字串呼叫這些 handler），
這超出本輪窄範圍審查的合理界線，維持他自己寫的那句誠實限原樣不動——
這是一個已承認的殘留不確定性，不是我核過清白。
```

# 三、③兩條新母體地板的方向——核過確實不對稱，且正好對不上現在發生的那個方向

```
他自己說「抽取式壞掉的方向是多吞，地板要擋的是多吞」——但實際寫的兩條：
  `n_reg > 0`（第一套非空）
  `n_arm > 0`（第二套非空）
這兩條的真實邏輯是【非空檢查】，擋得住的方向是「抽取式整個壞掉、回傳空
陣列」（少吞到底／掃描器死掉），擋不住「抽取式多算了幾條不相干的東西」
（多吞）——一個非空檢查看到 53（哪怕裡面有 2 條是垃圾）一樣會通過，因為
53 > 0 為真。這兩條地板現在擋的方向，剛好跟他自己講的「要擋多吞」的方向
不一致——而【多吞正是這一刻真實發生的事】（53 vs 真正的 51）。

建議：把 `_registry_pairs()` 比照同一支床已經在用的 `_eawt_arms()` 手法，
先用 `_body_of(src, "_setup_registry")` 把範圍切到那一支函式體內再掃，
這樣（a）能一併修掉多吞那 2 條不相干的項目，讓 53 變回準確的 51；
（b）修完之後 `n_reg > 0` 這條地板才是真的在保護一個被正確界定的母體，
不是在保護一個已經摻了雜質但因為非空所以通過的數字。
```

# 四、順手判：入口那一行——核過夠

```
P10 逐一試變體那段（:697-712）現在每一行都印
  `"%-22s 入口=%-22s 試了%d個變體｜曾改世界=%-5s｜ok=%-5s｜%s"`
——`入口=execute_action_with_target` 或 `入口=execute_action` 直接寫在
每一筆結果旁邊。核過這滿足你抄進判準庫的那句：「一個『不適用』沒有入口，
就不是一個判決」——現在每一筆都帶著入口，讀的人不需要再去猜它是問錯路
還是真的不適用。這格夠，無異議。
```

# 五、verdict

```
issues。①核過成立（三個新成員都真的改世界，逐一讀過 handler 本體，不是
只信床綠）。②4 條準確；53 條可重現但不準確，找到真正的抽取式過度吞噬
（掃了整份檔案而非只掃 registry 那個函式體），這次僥倖沒撞上目標函式名
所以沒腐蝕本輪分類，但建議修（把 `_registry_pairs()` 比照 `_eawt_arms()`
先用 `_body_of` 切範圍）。有沒有第三套：本檔內核過沒有，repo 全域未廣搜，
維持誠實限原樣。③地板方向核過確實不對稱（只擋少吞不擋多吞），而多吞正是
現在實際發生的方向，建議跟②同一顆 commit 一起修（同一個根因、同一個修法）。
入口那一行核過夠，無異議。
```
