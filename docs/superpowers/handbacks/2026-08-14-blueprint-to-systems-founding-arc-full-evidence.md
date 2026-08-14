---
from: blueprint
to: systems
status: open
topic: "[討論全問題總查(補28c56902兩題、合成arc完整證據包)·evidence-only禁fix·A鬼城可見性全套:①occupy對ghost/死人營(28c56902題1)②★settle動詞同查:convert_to_resident條件=own-faction outpost?→foreign/中立/ghost營對settle是否也隱形(=撿現成營結構上無門)③兩動詞對「無主營」的認定各在哪行踢·B死亡所有權:團死/erase時tile.owner處置?(遺財有路由、據點所有權?)~300鬼城owner現況分布(死id/-1/活)dump·C founding決策解剖:①選址品質:establish_crude_camp選址=_find_unowned_farmable_tile只掃鄰7格?有無挑地力(平原vs山)?②可行性檢查:gate=desperate+farmable之外有無pop/勞力viability?(1人蓋營現況允許=坐實)③成本:蓋營花什麼?(材料/時間/勞力or免費)免費=狂魔另一推手④觸發分布:272次的觸發team pop分布(幾成是pop1-3碎片蓋的)·D反饋迴路:build行動有無任何結果評估/記憶寫入?(蓋過失敗的地有無任何belief/memory標記?找任何site-outcome寫入點、預期=零、坐實用戶『零反饋』)·E情境2/3既有機制盤點:①overflow_split觸發條件(機械閾值or決策?)②_evaluate_new_outpost_location(貪婪+野心)>=1.1人格硬門檻現狀(F1抓過、修了沒)③軍事/防禦選址輸入=grep確認完全不存在·F順帶:notweak margin公式+門檻值(對零防守的數學=必過?)·output=六組verdict(file:line硬證)→合成founding arc完整證據包→我跟用戶收設計定案·地基KEEP"
---

# 討論全問題總查（founding arc 完整證據包）

**A 鬼城可見性全套**：①occupy 對 ghost/死人營（28c56902 題1）②★settle 動詞同查：`convert_to_resident` 條件=own-faction outpost？→ foreign/中立/ghost 營對 settle 是否也隱形（=撿現成營結構上無門）③兩動詞對「無主營」認定各在哪行踢。
**B 死亡所有權**：團死/erase 時 tile.owner 處置？~300 鬼城 owner 現況分布（死 id/-1/活）dump。
**C founding 決策解剖**：①選址品質（只掃鄰 7 格？挑地力否？）②可行性檢查（1 人蓋營現況允許=坐實）③成本（蓋營花什麼 or 免費）④272 次觸發 team pop 分布（幾成 pop1-3 碎片）。
**D 反饋迴路**：build 有無任何結果評估/記憶寫入（蓋過失敗的地有無 belief/memory 標記）？預期=零、坐實用戶「零反饋」。
**E 情境 2/3 盤點**：①overflow_split 觸發（機械閾值 or 決策）②`_evaluate_new_outpost_location` 人格硬門檻現狀（F1 抓過、修了沒）③軍事/防禦選址輸入 = grep 確認不存在。
**F** notweak margin 公式+門檻（對零防守=必過?）。
output = 六組 verdict（file:line 硬證）→ founding arc 完整證據包 → 我跟用戶收設計定案。地基 KEEP。
