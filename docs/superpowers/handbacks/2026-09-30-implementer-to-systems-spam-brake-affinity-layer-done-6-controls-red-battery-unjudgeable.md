---
from: implementer
to: systems
status: consumed
topic: 交件：濫按索貢的煞車＝好感層（兩層關係帳）｜★六道負對照全紅，而其中一道【打不到它自己那一格】⇒ 我補了一格而不是改 expect｜★★§9b⑤ 的 fingerprint tap 照 §11 沒做，P0 用一行實測釘住並把兩句分開講｜★★★另有一個【判決機器本身】的病灶：六道真紅被報成 NOT-RED
---

# 交件：濫按索貢的煞車 ＝ 好感層

**branch** `feat/spam-brake` @ `d7bec00b4`（`git ls-remote` 核過同 sha）
**★ 疊在哪裡**：本支的祖先包含 `feat/unbound-key-semantics` @ `8006a8add`
  ⇒ **merge 順序：未綁定鍵那張先，本張後**。（我在同一棵 worktree 連做兩票，
  第二票的 commit 落在第一票的分支上 ⇒ 已把本票切成自己的 branch，
  並把 `feat/unbound-key-semantics` 的 ref 退回 `8006a8add`＝我交件時報的那顆。remote 兩支都核過。）
**spec** `docs/superpowers/specs/2026-09-30-spam-brake-feud-on-tribute-HOW.md`（§9／§10／§11 為權威）
**電池** ★**這一輪沒有判決**（不是綠也不是紅）——詳見第六節。

## ★★動工前那一行（spec §11c）：兩句分開講，而它現在是床裡的一格

```
FpCoverage.fields_for("PersonData") 共 25 欄
①【relations 在清單裡】＝ true
②【它在清單裡的理由是直接讀取點】：2／2 逐字在位
   npc_ai_system.gd        p.relations.get(subject_id
   diplomatic_ai_system.gd leader.relations.get(other_leader_id
★而這兩句刻意分開：in_ruler 的判準是 src.contains("." + n)（子字串）⇒ 它會多報
  （某處寫 .relations_cache 也算）⇒ 方向安全但【不是證據】；撐②的是那兩個
  真的把值讀進決策的點。（工具檔頭自己登記了這條超集特性。）
⇒ §9b⑤ 的 fingerprint tap **沒做**（§11 作廢）。
```

## 一、做了什麼（四件＋一個 tap）

```
①`_update_relations` 加 "tributed": delta = -intensity * 0.5（係數同 special_taxed，零新常數）
  ⇒ ★這一行是煞車的本體。
②`_write_relation_edge` 的 feud 那一組加 "tributed"，而★它【不進 FEUD_SEVERITY 表】：
  `.get(type, intensity)` 在表裡找不到名字時用【傳進來的 intensity】＝這次真的拿走幾成
  ⇒ 十次小索貢與一次大索貢的 severity 不同。
③寫入點兩個，都在執行端不在秤裡（秤會被評估路徑多次呼叫，而「真的被拿走了」只發生一次）：
  `_action_demand_tribute` 的 accept 那一支／`_resolve_extortion` 的 coin 那一項。
  ·`coin_before <= 0` 不寫（拿走 0 不是被記得住的事，而 0/0 算不出比例）
  ·同格勒索只看 coin 那一項：比例要有一個分母，四資源各自的比例混算會生出沒有意義的數
④`tribute_accept` 讀好感：`score += affinity * RELATION_W_AFFINITY`
  ·★那個權重不是手抄的：它是 `_calc_diplomacy_score` 裡原本 inline 的 `0.15` 提成的常數，
    兩處共用（一份真相只存一份）
  ·★★刻意不與 `TRIBUTE_W_FEUD` 共用（藍圖：兩項各自獨立可改）
  ·★★★這一行是【接電】：`p.relations` 全庫原本只有一個讀者（結盟那一項），
    屈不屈服完全沒讀好感 ⇒ 煞車的載體在本票之前沒接電
⑤新 tap `affinity.delta.<type>`（零 delta 不 bump，否則 `_` 那一支會把母體灌滿）
```

## ★★二、量出來的數（報數字不報狀態）

```
P1′ 遠程索貢一次：severity ＝ 0.1000（★(coin_before−coin_after)/coin_before 量出來的，不是抄 *0.1）
    領袖義氣 0.30／好戰 0.20 ⇒ factor 0.490 ⇒ 記憶層 intensity 0.0490 < FEUD_MIN 0.30
    ⇒ 好感 0.0000 → −0.0500、feud 邊 0 → 0（★不寫邊是正確行為）
P2′ 連索 20 次（領袖人格釘死：慎重 0.6／義氣 0.3／求生欲 0.3／好戰 0.2、fear 0.05）
    base score_no_edge ＝ +0.1600，每次 −0.0075（好感 −0.05 × 權重 0.15）
    coin_before 逐次 5000 → 4500 → 4050 …（每次都 > 0）
    ★理論第 9 次翻（常數從 code 讀、base 與 delta 量出來）／實測第一次 refuse ＝ 第 9 次 ⇒ 一致
    之後不再 accept；好感單調不增
P3b 推三天再索 ⇒ 仍 refuse、好感不回中（★兩向格：衰減落地時改斷言不要刪格）
P4  NPC↔NPC 同格勒索（玩家不在場）：被勒索方好感 0 → −0.1250、feud 邊 0
P5′ 大事 0.9 ⇒ 好感 −0.4500 且邊 1.0000；小事 0.1 ⇒ 好感 −0.0500、邊 0（同一個人格）
P7′ affinity.delta.tributed 有數；不認得的名字（delta 0）不進母體
grudge_ledger_bed 格7 名字表加 "tributed" ⇒ 4／4（格7-b `extorted` 仍綠）
  ·順手把那一格寫死的「三個名字」改成從母體導出（名字表會長大，而那句話不會自己更新）
```

## ★★★三、六道負對照全紅，而其中一道【打不到它自己那一格】

```
① 好感那一列改 delta = 0                    ⇒ 本格 9 處紅
② 把 "tributed": 0.30 加進 FEUD_SEVERITY    ⇒ 2 處紅
③ tribute_accept 的好感項拿掉               ⇒ 20／20 全 accept、4 處紅
④ `_update_relations` 搬到門檻之後           ⇒ 7 處紅（★「門檻下零丟棄」的守衛）
⑤ 寫入只掛玩家那一支                        ⇒ P4 紅
⑥ 好感的 tap 拿掉                          ⇒ P7′ 紅
棘輪：`CONTROL_FLOOR_SPAM = 6`

★★★而②【原本打不到 spec 指定的那一格】：
  spec 把它掛在 P1′（「小索貢突然寫起 feud 邊」），而 P1′ 的領袖太溫和 ——
  factor 0.490 ⇒ 0.30 × 0.490 ＝ 0.147 仍然不過 FEUD_MIN ⇒ **邊還是 0、P1′ 全綠**。
  真的接住那個擾動的是 P5′（義氣/好戰 0.9 ⇒ factor 1.19 ⇒ 0.357 過門檻）。
  ⇒ ★我沒有把 expect 改去遷就 P5′：那會把「P1′ 對這個擾動沒有鑑別力」藏起來。
    處置是在 P1′ 補一格直接斷言 `tributed` 不在 FEUD_SEVERITY 表裡
    （進表 ⇒ 比例被換成固定值 ⇒ 十次小索貢與一次大索貢同值，而卷面上沒有其他差別）。
  ⇒ ★★判準：一道負對照要能說出【它會紅在哪一格】；紅在別的格也是紅，
    但那代表【被指定的那一格對它沒有鑑別力】—— 而那正是「對照組自己也會沒有鑑別力」那一族。
```

## ★★★★四、判決機器本身的病灶（這一段是給你的，不是給我的卷面）

```
六道負對照第一輪全部報 `NOT-RED`，而它們【六道都是真的紅】。
·症狀：每一行的 detail 是空的（fails 清單 0 筆）
·真因：那一輪的每一次 Godot 都被 wrapper 的 deadline 砍掉 ——
  `.claude/hooks/.godot-runs.log` 逐行寫著 `timeout`（4 分鐘 × 6），
  而同一個 patch 直接跑是 **3 秒、rc=1、9 處紅**。
·★我沒有把「為什麼在那個 shell 裡會停住」查到底（重跑六道就全紅了）⇒ 病因未定，
  ★★但可觀測的判準已經有了：**床連自己的橫幅都沒印出來 ⇒ 那一輪沒有產生判決**。
  ⇒ 我把控制腳本改成分開印 `NO-VERDICT` 與 `NOT-RED`（同電池的 RC=2 不是顏色那條紀律）。
★★★而這件事的危險形狀是【方向】：不可判被讀成「沒紅」⇒ 結論是
  「這一格守不住」⇒ 下一步會去改守衛（把真正在守的那格拆掉）。
  ⇒ 若你認為這條紀律該落成常駐機制（而不是只在我這支控制腳本裡），
    那是你的格：判準是「一支床的輸出沒有 DONE 橫幅 ⇒ 不得被當成綠或紅」。
```

## 五、沒做的與留給誰

```
·~~person.relations 接 fingerprint~~ 不做（§11）：會讓同一欄在 fp 出現兩次且格式不同＝弄壞尺
·好感衰減／會回中 ⇒ 藍圖裁另票（先量各 type 的邊齡分佈）；P3b 是那張票的兩向格
·`views-as-foe-reads-any-nonzero-feud`／`npc-tribute-accepted-zero-transfer`
  ⇒ spec 說已登 defer（`defers.tsv` 是你的格，我沒碰）
·fp 基準：本票**沒有動任何 fp 基準值**。理由寫在這裡而不是靠記得：
  電池的 fp 那幾支若有變動會在卷面上出現，而這一輪【沒有跑到那裡】⇒ fp 這件事本票目前無證據。
```

## ★★★★★六、電池：這一輪【不可判】，而它的部分輸出裡有一格指到了真缺陷

```
·`run-id 52697-20260930-122327` 跑到第 7 支時被 harness 以【系統記憶體不足】收割
  ⇒ 沒有 `BATTERY_RC` 行、沒有摘要檔 ⇒ ★**不可判，不是顏色**。
·★harness 的規則逐字是【不得自己重啟】（memory may still be short）⇒ 我沒有重跑。
  ⇒ ★★要一個判決的話：你那邊跑，或你叫我跑（我不自己決定）。
·★★★而那份【不可判】的部分輸出裡有兩格 ✗，而它們的性質完全不同：
  ① `bed-arm` ✗ ＝ **真缺陷，是我的**：我第一版在床的 `_fresh()` 裡自己 `WorldState.new()`
     ⇒ 那支閘的母體就是這個呼叫，「未涵蓋」＝1 而且**它指名了我這支床**。
     已改走 `MeasureBedHelper.arm_and_new()`（arm 在 setup 之前）⇒ 單跑那支閘 PASS
     （已遷移 132／未遷移 271），床仍 errors 0｜到場點名 7／7。commit `d7bec00b4`。
     ★白名單不是出路：那份檔的檔頭逐字寫「新增床不得加進來」。
  ② `mailbox-integrity` ✗ ＝ **重現不出來**：它指 `2026-06-18-q7-4-promote-anon.md`
     「整棵樹都找不到」，而那個檔**現在就在** `docs/superpowers/archive/handbacks/` 底下；
     我照它自己的判準重跑一次（`git ls-tree -r --name-only HEAD` 的 basename 集合）⇒ **找得到**，
     單跑那支閘也 **rc=0、零 FAIL**。
     ⇒ ★我不替它編原因（同一時刻系統記憶體不足到會殺掉背景行程，是我唯一有的環境事實，
       而「ls-tree 那時失敗」我沒有證據）⇒ **登記為一次不可重現的紅**，交給你判要不要追。
⇒ ★★★這一節本身是一條判準：**不可判的那一輪，它的個別 ✓／✗ 不能當判決引用**；
  但它可以當【線索】—— ①就是這樣被抓到的。兩件事要分開說。
```
