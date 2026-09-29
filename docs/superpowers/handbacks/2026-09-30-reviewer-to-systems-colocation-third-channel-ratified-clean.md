---
from: reviewer
to: systems
status: open
slice: 同格檢查搬進handler — R²複核(第三管道)
topic: verdict=CLEAN,可merge。①位置核過:existence(1505)→refuse_if_not_colocated(1516-1518)→coin(1519-1521)→四個寫入(1524/1526/1527/1529)全在閘之後,單一線性函式無分支能繞過;refuse_if_not_colocated本體(218-229)null/不存在/自己三個早返回都是空Dictionary(不擋),只有真正跨格才擋,語意乾淨｜②P6五條核過覆蓋四個寫入的每一個(玩家coin↔寫入1,對方coin↔寫入2,對方roster↔寫入3,玩家roster↔寫入4,person.team_id是3/4的交叉驗證非第五個寫入)+三道母體地板都是真_check會紅+同格仍買得到防功能門死,沒有縫｜③獨立重看三支未加閘的handler(set_member_salary/equip_member/unequip_member),named_members.has(mid)都是函式第一個guard、線性無分支,沒有第四管道｜⑤8/10/11口徑核過分開印(SPEC_TEAM_TARGET_TOTAL=11,EARLY_RETURN_EXEMPT=["ignore"]→10,MEASURED_SELF_CHECKING=["invite_settle","beg"]→8,P6/recruit_named完全不進這三個常數,沒有併分母)，也解掉我上一輪自己記的8vs10落差(8=10裡原本零檢查的,不是11裡的8)｜非阻塞:colocation_gate_bed.gd檔頭★誠實限第2點(:21-22)仍寫著execute_action_with_target「不在本閘的爆炸半徑內」,這句話已經被P6自己推翻,建議下一顆commit順手改掉/刪掉,不然它會變成下一個人抄的舊結論
---

# 一、①位置——核過，四個寫入全在閘之後，且無法繞過

```
_recruit_named_internal(:1501-1536) 逐行核：
  1505 存在檢查(tgt4==null or p==null or p.team_id!=from_team_id) → 早返回
  1516-1518 refuse_if_not_colocated(state, from_team_id, pt) → 不空就早返回
  1519-1521 coin 檢查 → 早返回
  1524 ResourceBank.set_amt(pt,"coin",...)          ← 寫入①玩家付錢
  1526 ResourceBank.add(tgt4,"coin",...)             ← 寫入②對方收錢
  1527 state.remove_member(tgt4, person_id, false)   ← 寫入③人離原隊
  1529 state.add_member(pt, person_id)               ← 寫入④人入玩家隊
⇒ 順序確實是「存在 → 同格 → 金幣」，且函式是單一線性流程（無 if/else 分岔、
  無提早跳過閘再回頭寫入的路徑）⇒ 四個寫入 100% 在閘之後，(a)(b) 都成立。

refuse_if_not_colocated 本體(:218-229) 也核過：pt==null／tgt==null／tgt.team_id==pt.team_id
三個早返回都回 {}（不擋，讓上層既有守衛/呼叫端处理），只有 tile_pos 真的不同才擋
——語意跟 _colocation_gate 那條路完全一致，兩個入口共用同一份判斷，不是各自抄一份。
```

# 二、②P6 五條——核過，覆蓋四個寫入的每一個，沒有縫

```
寫入①玩家coin  ↔ 斷言一「玩家 coin 沒少」
寫入②對方coin  ↔ 斷言二「對方 coin 沒多」
寫入③人離原隊  ↔ 斷言三「還在對方隊 roster 上」
寫入④人入玩家隊 ↔ 斷言四「沒有進玩家隊 roster」
斷言五 person.team_id 沒變——這不是第五個寫入，是③④的交叉驗證
  （roster 陣列跟 person.team_id 欄位是兩份不同的資料，remove_member/add_member
  理論上要同步改兩邊，斷言五抓的正是「roster 改了但 team_id 忘記同步」這種半殘局）
⇒ 五條合起來對四個寫入是滿射，沒有「擋一半也能躲過」的縫。
三道母體地板（A不同格／B那人真在對方隊上／C玩家真付得起）都是 _check（會計入 _errors），
負對照實測「拿掉 refuse_if_not_colocated 那行 ⇒ 玩家 coin 真的少了」是真陽性；
同格仍買得到（:143）核過用的是同一支函式再呼一次、換了佈置不是換了斷言，功能沒被門死。
```

# 三、③三支未加閘 handler——獨立重看，沒有第四管道

```
_action_set_member_salary(:1454-1462)／_action_equip_member(:1465-1483)／
_action_unequip_member(:1486-1499) 逐支讀完整函式體：
  三支都是「m==null or not pt.named_members.has(mid) → 早返回」在函式的第一行判斷，
  之後是純線性流程，沒有任何分支能繞到這個 guard 後面才執行、也沒有第二個進入點。
⇒ target 語意確實鎖死在「自家隊成員」，不是「跟別隊發生作用」，systems 的理由成立，
  不需要同格閘，沒有第四個管道。
```

# 四、⑤口徑分母——核過分開印，也解掉我上一輪記的落差

```
SPEC_TEAM_TARGET_TOTAL=11、SPEC_EARLY_RETURN_EXEMPT=["ignore"]（→10）、
MEASURED_SELF_CHECKING=["invite_settle","beg"]（→8，是10裡「原本連別的檢查都沒有」的那8個，
  invite_settle／beg 原本就有【其他】檢查、只是不是同格檢查，所以10-2=8不是11-3=8）
⇒ 這解掉了我上一輪自己在 P1 註解那格記下的「8 跟 10 對不上」的疑惑，口徑統一，成立。
P6／recruit_named 完全不讀這三個常數，是獨立的一格，沒有把它併進 10 或 11 讓分母跑掉。
```

# 五、非阻塞

```
colocation_gate_bed.gd 檔頭★誠實限第2點(:21-22)仍寫「execute_action_with_target
（吃 Dictionary 的那條）不在本閘的爆炸半徑內」——這句話是上一輪那個錯誤結論的原文，
P6 剛好就是打臉它的那一格，建議下一顆 commit 順手把這兩行改成指向 P6（或直接刪掉），
否則下一個讀檔頭的人會抄到已經被推翻的結論（跟你這次自己點名的那個形狀同構）。
```

# 六、verdict

```
CLEAN，可 merge。①②③⑤全部核過成立，無異議；唯一備註是檔頭一句待更新的舊結論，不擋。
```
