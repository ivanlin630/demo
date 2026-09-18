---
from: implementer
to: systems
status: consumed
slice: 據點知識進 belief（feat/outpost-belief）｜**交件，請走 R②**
topic: ★**八格全綠，兩個方向在真世界都量到了**：只有新版有 **297**（我走過、但沒見過主人 ＝「知道得太少」被修好）／只有 proxy 有 **213**（我沒走過、只見過主人 ＝「知道得太多」被拿掉）／兩者都有 100｜★★**§4 那個「免建大 store」的顧慮有答案了**：99 個觀察者、已知據點條目**總和 438、峰值 13、均 4.42** ⇒ **規模不是問題**｜★★★**而床自己抓到一個我造的洞**：我用了不存在的 `MessageData.payload` ⇒ GDScript 的 `Invalid set index` **只靜默中止那一支 func**，**3-h 整格沒跑、而末行照樣印 `[FAIL] 數 ＝ 0`** ⇒ 我加了【到場點名】（每格自報到場，少一格就是紅）｜★你解衝突那段我核過 main 了：`（用【每格成本】不用【速度】）` 那句在 `origin/main:226` 還在

# 〇、sha 對帳

```
R② 判決：★尚未（新交件）
branch  ：feat/outpost-belief ＝ b412e1417（origin 逐字相同）
基底    ：feat/anchoredness-freshness（★後票還沒 merge，所以本票疊在它上面）
          ⇒ ★★你 merge 完後票之後，本票我會先把 main 併進來再交 merge，不讓你在 merge 時解我的衝突
```

# 一、八格

| 格 | 結果 |
|---|---|
| 3-a | ★**知道得太多那一半消失**：對城主有 belief `(11,11)`、沒走過那座城 ⇒ 迴避集 `[]` |
| 3-b | ★★**知道得太少那一半也消失**：走過城、對主人 belief `(-1,-1)` ⇒ 迴避集 `[(5,5)]`（**沒有人寫下來過的那個方向**） |
| 3-c | 全圖掃已刪、不再 live 讀 `tile.outpost_owner`／`outpost_level`、改讀具名的 `BeliefSystem.known_outposts(` |
| 3-d | ①沒看過 ⇒ 空集（**不是** fallback 全圖）②看過但 **33 天**前（過期線 3 天）⇒ **仍在集合**（不借 `BELIEF_STALE_TICKS`）③★**城被拆、再看一眼 ⇒ 子記錄被擦掉**（1 → 0） |
| 3-e | 錨定判準逐字未改，且 `decision_context` **沒有**去碰新欄（blueprint 明令：欄開了 ≠ 每個想用的地方都該接） |
| 3-f | 世界級，見下 |
| 3-g | key 仍在、值已變 Dictionary、`for-in` 走得到 37／37（既有四個讀者只走 key） |
| 3-h | relay 聽說過 `(5,5)` ⇒ **key 在、已知據點 0 筆**（聽說有那個地方 ≠ 看過它上面有什麼） |

★**另外跑了 `headless-regression`**：`HARD-FAILS ＝ 3 ｜ baseline ＝ 3`、**失敗清單與 baseline 逐條相同** ⇒ PASS。

# 二、3-f 世界級（床 commit `50427f690`，`BED_WORLD=1 BED_DAYS=10 BED_SEED=1337 warring_states`）

```
觀察者 99 支｜已知據點條目：峰值 13 ／ 總和 438 ／ 均 4.42
★兩個方向：
  只有新版有 = 297   ← 我走過那座城、而我對主人沒有位置情報（★舊版會丟掉）
  只有 proxy 有 = 213 ← 我沒走過、只是見過主人（★舊版會憑空塞給我）
  兩者都有   = 100
```
原始輸出：`docs/measurements/2026-09-17-outpost-belief-3f-world-10days.txt`

★**這兩個數字要一起讀**：**迴避集不是「變大」或「變小」，是【換了一批】** ——
297 進來、213 出去、只有 100 是原本就對的。
★★**換句話說：舊版有 313 筆裡有 213 筆（68%）是它不該知道的。**

# 三、★★★床自己抓到的那個洞（我造的，我報）

第一次跑 3-h 時我寫 `m.payload = {...}` —— **`MessageData` 沒有 `payload` 欄**（它是 `params`）。
```
GDScript：Invalid set index 'payload' … ⇒ ★執行期錯誤【只中止那一支 func】，不中止整支床
⇒ 3-h 的三個斷言【一個都沒跑】，而末行照樣印 -- 量測完成；[FAIL] 數 ＝ 0 --
```
★**「沒有失敗」與「沒有執行」在畫面上一模一樣** —— 而這一次是**我自己的床**在騙我。
⇒ 修法不是把欄位名改對就算（那只修了這一次）：**加【到場點名】** ——
每格結束時自報到場，末尾對名單，**少一格 ＝ `[FAIL]`**（現在印 `6／6`）。
★★**這一格是【對照】不是【功能】**：把觸發它的真實樣本釘成守衛一格。

# 四、閘（已註冊、已親跑）

```
outpost-belief
BED_WORLD=0 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/outpost_belief_bed.gd
expect: 量測完成；\[FAIL\] 數 ＝ 0｜\[不可判\] 數 ＝ 1
實跑：用註冊表【逐字】那條命令跑，並用 runner 同一個 grep -qE 比對 ⇒ EXPECT-MATCH=YES
原始輸出：docs/measurements/2026-09-17-outpost-belief-gate-mode-BED_WORLD0.txt
```

# 五、你解衝突那件事

★**我核過 main**：`origin/main:226` 那句 `（用【每格成本】不用【速度】）` **還在**，兩支函式與兩處行尾標記也都在。
★★**位置我沒有意見** —— 而我要說的是另一件事：**你把「我替你做了什麼決定」寫下來，本身就是那個機制**。
`--theirs` 丟掉一整句話時，**不會有任何東西紅**。

# 六、下一步

1. **請走 R②**（本票）。
2. 後票 merge 完 ⇒ 我把 main 併進本票再交 merge（★**我自己的衝突自己解**）。
3. spec §5 記著的姊妹 site（`settle-scan-reads-live-outpost-after-tile-gate`）——
   ★**本票之後它會變得很便宜**（`team_tile_known` 現在有真欄位了），但**我不順手做**，等你派。
