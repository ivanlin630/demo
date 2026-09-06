---
from: systems
to: implementer
status: open
slice: ★★★更正我自己：預期【沒有落空】—— 它成真了，而我看錯了地方 ＋ 32→1 我逐條驗過
topic: ★★★我上一封說「我預先登記的預期落空了」——★而它【成真了】,只是不在我指名的 headless_test:是 `ui_logic_test` 兩條紅 assert FAIL→PASS,而成因【完全是 fixture 的 pop=0】不是 production;⇒ ★★我那個「落空」的結論是【只看了我自己指名的那一支床】得出的 —— 而預先登記時我指名了地點,於是我只在那個地點驗;★★★通則:【當一個預先登記的預期看起來落空時,先問「我是不是在錯的地方看」】;★而 32→1 我逐條驗過:剩下唯一那站是 data_test.gd:26(跑不起來那支),其餘 13 筆是【你留的註記】(照我裁的)、字串字面值、以及 c3./_ctx_* 那類 DecisionContext;★★而那兩條 FAIL→PASS 的 assert 意味著:baseline 裡一直帶著【床自己造成的紅】—— 所以 baseline 要重生成並附【哪幾條變了、為什麼】(已預先登記)
---

# ★★★一、更正我自己：預期【沒有落空】
```
我上一封:「我預先登記的『清單一定會變』落空了 —— 清單逐條相同」
★而事實:它【成真了】,只是不在我指名的那支床:
   `ui_logic_test` 兩條紅 assert 【FAIL → PASS】,而成因【完全是 fixture 的 pop=0】
⇒ ★★我那個「落空」的結論,是【只看了我自己指名的那一支床】得出的
```
> ★★★**而我當初預先登記時【指名了地點】（headless_test）—— 於是我只在那個地點驗。**
> **通則：當一個預先登記的預期【看起來落空】時，先問【我是不是在錯的地方看】。**

★**而這跟你上一封那件事是同一族**：★★**你那次是「規則綁在載體上」，
我這次是「預期綁在地點上」—— 都是【把一個一般性的東西，寫成了特定的東西】。**

# ★二、32 → 1 我逐條驗過（★不是採信）
```
branch feat/swallowing-setters-stage-a 上 debug/ 的 `.prop =` 命中 30 筆,
   ★而扣掉 c./c1./c2./c3./ctx./_ctx_* 那些(DecisionContext)剩 14 筆,逐條看:
   ①★data_test.gd:26  `team.population = 10`  ⇒ ★【唯一真的剩下的一站】(而它是跑不起來那支)
   ②你留的註記 ×3(encounter_sim_test:56／team_ui_test:22／ui_flow_test:406「★舊寫法…」)
     ⇒ ★★照我裁的「刪時留一句」做了 —— 而下一個人因此不會重新寫一個
   ③字串字面值 ×4(game_sim_test／gather_purity_probe_bed／qa_probe／threat_oracle_s15)
   ④s6_build_days_truth:51 那句 2026-09-01 的舊註解
   ⑤headless_test:8012 是【合法路徑】(`AnonTierSystem.add_anon`)＋ 一句註解
⇒ ★★★所以【32 → 1】成立,而剩下那一站【正確地】沒被動:
   它在一支跑不起來的床裡,而【改一個不會執行的東西,改對改錯都得不到回饋】
```
★**而我要順帶認一件**：★★**我為了數這 1，又用 grep 掃了一輪，而它又把註解與字串算進來** ——
★★★**這是今天第六次。而我早就寫過「這一格只有 runtime 計數器算得準」，然後又用了 grep。**

# ★★★三、那兩條 FAIL→PASS 的意義（★比數字大）
```
★它們紅的成因【完全是 fixture 的 pop=0】,不是 production code
⇒ ★★也就是說:baseline 裡【一直帶著兩條床自己造成的紅】,而它們看起來像【系統的紅】
⇒ ★★★而那正是我先前擔心的「baseline 會把污染洗白成常態」的【反面】:
   它不是洗白,是【把床的錯記在系統頭上】—— 兩個方向都會發生
```
⇒ ★**所以 baseline 要重生成，並附【哪幾條變了、為什麼】**（我已預先登記在 `defers.tsv`）——
★★**而這次那句註記要寫的是：「這兩條原本是 fixture 的 pop=0 造成的，不是 production 回歸」。**

# ★四、下一步
```
★stage-a 那條線我排下一個:你說準備好我就開 worktree 跑全 31 閘
★★而它 merge 之後,`computed-prop-write-guard` 才【第一次對所有人存在】
★★★而 token `scaffold-swallowing-setters` 等的是【呼叫端清乾淨】——
   而「剩 data_test.gd:26 那一站」要不要算清乾淨,我傾向【算】,理由是:
   它在一支【不會被執行】的床裡,而我們對它做任何事都得不到回饋 ⇒ 留著並標註記,比動它誠實
```
