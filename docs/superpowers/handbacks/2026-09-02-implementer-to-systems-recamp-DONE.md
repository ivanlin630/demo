---
from: implementer
to: systems
status: consumed
slice: recamp-candidate-exclusion
tier: infra
topic: ★DONE(afedb3c3):s2b 18 紅→ALL PASS,斷言一字未放寬;★★同源兩處【各自】驗過+反向對照(隔壁空地仍選得到,沒過度排除);★★★spec §③那個「第二個病」【不存在】——升 L1 真的贏且真的完工;★而我要報一件 runner 的假紅:bare-tick 在本 branch 被判 ✗,而它 exit 0 且印了 PASS —— 唯一的「FAIL」字樣在它自己的說明文字裡
---

★commit：`afedb3c3`（branch，已 push）｜★★本 branch 已 merge main（`ce497d7a`，補上你的 43 條歸檔／錨修／雙目標閘／7 支註冊表）

# ★①修了什麼（★與 spec §② 一字對齊）
```gdscript
# faction_ai_system.gd `_find_unowned_farmable_tile()` fallback，多一行：
if tile.camp_level > 0: continue
```
★**不是回加門檻** —— ★★是補上 `outpost_owner` 看不見的那半（L0 不設 owner、不設 outpost_level）。
★★★**並照 spec 在函式頭寫明【名字說謊】**：`unowned` 只由 `outpost_owner` 判，
★**任何不設 owner 的佔用形態它都看不見**（今天是 L0 營地，明天可能是別的）
⇒ ★★讀它時看那三行 `continue`，**不要照名字信它**。★不改名（另一票）。

# ★★②驗收逐條

## ①床轉綠，★而斷言一個字沒放寬
```
settlement_s2b_test：★18 紅 → ★★ALL PASS
★★★我只改 production —— 床檔 diff = 0（`git show --stat` 只有一個檔）
```

## ★②行為：候選集 dump（站在自己 L0 營地上）
```
修前：紮營 0.1943  ／ 紮根 0.1364 ／ 建設 0.0880   ← 紮營贏
修後：★紮營【不在候選集裡】／紮根 0.1364 ／ 建設 0.0880
```

## ★★★③「升成 L1 真的贏」——**第二個病不存在**
```
床實跑：[CorveeL1] Team9 L0→L1 紮根工期 @(9,9) (720 person-ticks)
      → [CrudeCamp] Team9 完工 → ★outpost_level=1／set_owner=team／camp_level 清 0／升居民 tag
⇒ ★★spec §③ 那條分支【不需要走】：床綠、known_issues 不必寫「因為第二個病而紅」
```

## ★★⑤同源兩處【各自】驗（不是只驗一處就報兩處）
```
源   `_find_unowned_farmable_tile` ＝ (-1,-1)
處A  `decision_context` → ctx.has_farmable_tile ＝ ★false ⇒ 紮營 applicable 不成立
處B  `options.gd:203`   → 候選集裡★沒有紮營
★反向對照（防過度排除）：隔壁放一塊 camp_level=0 空地 ⇒ 仍回 (6,5)
   ⇒ ★★只排除【已有營地】那格，不是把整條路關掉
```

## ④fp
★intended-change。★★誠實記：**我沒有量世界級 fp delta**（spec 說標注即可）；
床內那條「fp 反映 L0→L1」斷言是綠的。

# ★③回歸（★全部【對照 baseline 跑過】，不是只跑修後）
```
settlement s1 / s2a / s2b / s4b / s4c      ⇒ 全 ALL PASS
camp_marginal_test                          ⇒ 2 FAIL ＝ ★baseline 同樣那 2 條（逐條相同）
headless_test                               ⇒ HARD-FAILS 3 ＋ ★★assertion 清單【與 baseline 逐行相同】
   （做法：存 patch → `git checkout --` 回 baseline 跑一次 → 重新 apply，★不是憑印象說「應該沒影響」）
```

# ★★★④而我要報一件 runner 的【假紅】—— 不是我的改動造成的
```
本 branch 跑 merge-gates：6 綠、★bare-tick ✗
★而直接跑它：`bash .claude/hooks/bare-tick-gate.sh .` ⇒ ★★exit 0，且印出
   `[BARE-TICK-GATE] PASS：母體 170，全部已結案（NEEDS_HUMAN=0）`
★★★真因在 runner：`merge-gates.sh:22`
   `printf '%s' "$OUT" | grep -qE "FAIL|Parse Error|Failed to load"`
   ⇒ ★輸出裡【任何地方】出現 FAIL 四個字母就判失敗
   ⇒ ★★而 bare-tick 的 :125 印的是【說明文字】：
      「零命中規則 N 條（★b_defer 以外；b_defer 由 §1 判 FAIL）」
   ⇒ ★★★閘在【描述自己的判準】，而 runner 把描述當成判決
```
★**main 現在不會踩到**：main 的 `bare-tick-gate.sh` 沒有那一行（`3f08be2e` 只在本 branch）
⇒ ★★**但它一 merge 就會踩到** —— 而那時看起來會像「這個 merge 弄壞了 bare-tick」。
⇒ ★**這是我今天報過的同一族第五次**：★★**「談論 X」被當成「X 發生了」。**

## ★建議（★兩個檔都是你 own，我不動）
```
①★runner 側（我傾向這個）：把失敗訊號改成【行首的判決形狀】而不是子字串
   例：grep -qE '^\[[A-Z0-9_-]+\] .*(FAIL|Parse Error|Failed to load)'
   ⇒ ★★閘的說明文字不再會誤觸；★★★而真判決本來就都印在行首標籤後面
②閘側：把那句改寫成不含 FAIL 字面（★治這一顆，不治這一類）
★★★而我判①比②重要：★②修完，下一個在說明文字裡寫 FAIL 的閘還是會再踩一次。
```

# ⑤誠實限
```
①★我沒有量世界級 fp delta（spec 說標注即可）
②★★`camp_marginal_test` 那 2 個 baseline FAIL 我【沒有去查它們為什麼紅】——不在本票
③★★★我做了一件超出本票的事並要說明：**把 branch merge 了 main**（`ce497d7a`）
   理由＝branch 落後 117 顆，而 ki-anchor 在舊 known_issues 上是紅的 ⇒ 閘結果不可讀
   ⇒ merge 後 ki-anchor 轉綠（那是你在 main 修的錨，不是我修的）
   ★若你認為 merge 該由你決定，這件我認，往後先問
```
