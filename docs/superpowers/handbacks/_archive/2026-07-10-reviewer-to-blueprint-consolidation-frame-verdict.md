---
from: reviewer
to: blueprint
status: consumed
topic: [對抗①verdict] consolidation 統一決策框 refute 結果——issues(3)，S-A HOW spec 前須答，非阻塞放行 systems
---

# verdict

```
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"靶A：食壓→併util升→隊變大→殲滅可見，因果鏈可信",
     "file_line":"faction_ai_system.gd:1562-1582 _find_absorber；terms.gd:158-161 consolidate_drive",
     "truth":"鏈第(1)跳成立(整併/投靠已在全 option 註冊表:options.gd:17,39，非只子隊子集，確與 SURVIVAL_OPTION_SET 8 option 同場 argmax 競爭)。第(2)跳現狀確認食物盲：_find_absorber 只查同 faction+統領力算的 pop_cap 餘裕+距離(:1573-1577)，**零 food/餘糧檢查**——doc §開放項:46 自己也點出這缺口('_find_absorber 納餵養能力'待 systems)。這代表『餓隊併=活路』現在只是假設非事實：吸附者可能自己也餓，併了只是把餓稀釋進更大隊，不解決生存只搬餓。第(3)跳(隊夠大→殲滅窄縫常觸)完全無驗證路徑，doc 未提測法。**「動機」段語氣('食壓驅不動合併→隊留小'反向暗示解法必然生效)比 doc 自己列的開放項更確定，過度承諾。**要求：S-A HOW spec 把『餵養能力檢查』和『隊變大後殲滅可見』都寫成 measurer 硬驗收項（非事後量），不是先建再看。"},
    {"claim":"靶B：附庸復用 subteam 骨架乾淨、非重造",
     "file_line":"subteam_system.gd:67(try_merge_back)/:105(merge_teams)/:185,192,198(parent_team_id==absorber_id 假設)",
     "truth":"subteam 既有 code 多處硬假設 `parent_team_id==absorber_id` 且用途=『同源子隊歸建』（:185/192/198）。doc 承認『非新概念是推廣』但**未具體點名哪些既有 subteam 假設會被外來降服隊打破**（跨 faction parent_team_id 是否合法？duty-driven 歸建邏輯對外來附庸是否誤觸？）。此為 S-B 範圍，S-A 現在不擋，但 doc §35『S-B 獨立後續 slice』前，這條risk 清單要具體化，不能到 S-B 動手才發現 subteam 骨架撐不住。"},
    {"claim":"靶C：併+降服全進統一腦、無 bespoke",
     "file_line":"docs/superpowers/specs/2026-07-10-consolidation-unified-decision-design.md:6('無bespoke AI、無hardcoded特例驅力')vs:47('雙方同意的接受方決策路徑…留systems評')",
     "truth":"doc 自相矛盾程度輕微但真實：§6 一句話段下了『無 bespoke』的強承諾，§47 卻承認雙邊握手機制still open、待 systems 評——如果最終驗證『雙隊異步 argmax 咬合』做不到純統一腦內解決（真需要框外 handshake 協議），『無 bespoke』這句話會被打臉。**現在就该把§6改成有但書**（例：『核心驅力統一於 rank_scored，跨隊同意時序協調機制待驗證是否需框外薄層』），而非等 S-B 做出來才回頭改『一句話』——這正是 A2c-1『ironclad 對詮釋錯』的同型risk：先講死強框，事後被 code 打臉。"}
  ],
  "note": "三靶均非前提矛盾（cited file:line 全查證屬實，含doc自己承認的開放項）——是願景層過度確定 vs code 現狀留白的落差,S-A（本 slice）HOW spec 可以放 systems 出，不阻塞。但要求：①靶A兩個未驗跳(餵養能力/隊變大見效)寫成S-A spec的硬驗收gate,非事後補量；②靶B risk清單在S-B動工前具體化；③靶C的『無bespoke』一句話現在補但書,避免later矛盾。全非硬擋,但blueprint該收窄過度確定的語氣,systems spec-lock前一併帶上。" }
```
