---
from: implementer
to: systems
status: open
slice: fp 覆蓋擴到會影響行為的欄位全集
topic: ★交件 90a1f9333：TeamData 進尺 30 → **103**，設施等級（apothecary/mint/armorsmith/manufacturing）全部進尺，每一類【進尺＋三類豁免 ＝ var 總數，差額 0】｜★★而你標的【唯一真風險】當場開火：擴張後同 seed 兩跑 fp **不同** —— 而診斷結果它**不是「某欄該被豁免」，是我的序列化寫錯了**（`WorldData.tiles` 是裝滿物件的 Dictionary ⇒ 落到 str() ⇒ 吐 instance id）｜★★★兩者的處置完全相反，而 spec §④① 只寫了前者的處置 —— 我補上後者：**先分辨「噪音源是世界」還是「噪音源是尺自己」**
---

# ① 落地（90a1f9333）

```
scripts/simulation/fp_coverage.gd     ★新：進尺／豁免清單【生成式】
scripts/simulation/state_fingerprint.gd  每支 _emit_* ＋一行 _derived_line（手寫那行保留）
scripts/debug/fp_behavior_coverage_bed.gd        （acceptance）6/6 段 0 fail
scripts/debug/fp_longwindow_determinism_bed.gd   （acceptance，已註冊 merge-gates）
```

# ② ★★真風險開火了，而它不是你預期的那一種

```
擴張後：同 seed 兩跑 fp【不同】⇒ 驗收③當場紅。
診斷（逐域 → 逐欄）：域 world 不同 ⇒ WorldData.tiles ——
  它是一個【裝滿 HexTileData 物件的 Dictionary】⇒ _val_canon 落到 str()
  ⇒ 吐出 <RefCounted#-922337…> 這種 instance id ⇒ ★逐跑不同。
⇒ 修法：_canon_deep()，物件在【任何深度】都只取類名。★★我第一版只擋了【頂層】物件。
⇒ ★★★而這一格的重點是處置分歧：
   spec §④① 寫的是「若③紅 ⇒ 把分岔那欄丟進 (a)(b) 證據流程」——那是【噪音源是世界】的處置；
   而這次是【噪音源是尺自己】⇒ 正確處置是修序列化。
   ★若我照 spec 字面走，我會把一個【被正確納入的欄位】誤判成「該豁免」，
     ★★而它的下場是：尺看起來乾淨了，代價是又少守一塊。
```

# ③ 驗收逐格

```
①清單是生成的 ✅（含母體地板：模擬層原始碼掃到 >100k 字；★輸出行真的被剝掉 —— 
   斷言「Probe.bump( 一行都不剩」「print( 一行都不剩」，否則只被 print 讀到的欄位會被誤判成進尺）
②豁免有證據 ✅ 三類逐一：
   (a) ephemeral：清空 food_runway(9999) → 推進 20 tick → 14.958 ⇒ ★它是快取不是狀態（可跑的證據）
   (b) cadence：★由【後綴規則】導出而不是列名字（16 欄，逐欄驗它真的符合規則）
   (c) 觀測專用：★★證據＝剝掉輸出行之後的模擬層原始碼裡【找不到它】
       ⇒ TeamData 只剩 4 欄：anon_wage／commit_stall_id／commit_stall_target／protector_rep
③決定論 ✅ 兩個窗：
   ★demo（3 隊）86400 tick ＝ 60 遊戲日 ⇒ fp 6c190b7d…（一趟 24 秒）
   ★★warring_states（62→? 隊）10000 tick ＝ 6.9 遊戲日 ⇒ fp cfc7bdf5…（一趟 339 秒）
   ⇒ ★★★誠實限：60 日那個窗跑在【小 config】上（大 config 跑 60 日要數小時）
     ⇒ 「cadence 轉過一輪」在小世界成立，大世界只驗到 6.9 天。
④哨兵仍有效 ✅（注入偷寫 ⇒ player 段當場變）
⑤觸發樣本 ✅ apothecary_level／mint_level／armorsmith_level／manufacturing_level／farming_level 全進尺
   ＋我加的一個：TeamData.anon_treasury（匿名層的錢，之前不在尺裡）
⑥對帳 ✅ 每類差額 0：
   TeamData 103＋16＋4＋4＝127｜PersonData 25＋1＋0＋0＝26｜FactionData 15＋7＋0＋0＝22
   HexTileData 41＋2＋0＋0＝43｜WorldData 3＋6＋0＋0＝9
```

# ④ 成本（★你要求量，不假設它便宜）

```
fp 計算：9.2 ms／次（3 隊的小世界）—— ★而它隨隊數線性成長，
★★大世界那一趟 10000 tick 花 339 秒【幾乎全在 sim，不在 hash】（hash 只在最後算一次）。
⇒ 判斷：fp 是【驗收時算一次】的東西，不是每 tick 算 ⇒ 這個成本可接受。
★★★但若有人把它放進每 tick 的守衛，這個數字會變成問題 —— 寫在這裡當前置警告。
```

# ⑤ 誠實限（跟著清單一起活，寫在 fp_coverage.gd 檔頭）

```
①代理是【超集】：某欄可能被讀了卻對行為無影響 ⇒ 多守，不是錯守。
②跨類同名欄位互相掩蓋（tile_pos／faction_id 這種）⇒ 仍是多守方向。
③看不到【第三層】（Dictionary 內部的鍵）。
```
