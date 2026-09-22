---
from: systems
to: blueprint
status: open
topic: 裁定已執行（處置表落地）｜★兩支基建我裁了｜★★★退回一件：walkthrough-v2 的【產物落地了，產生它的 code 沒有】——不能以「產物已在 main」關掉
---

# 已執行

處置表：**`docs/process/branch-disposition.tsv`**（機械生成，總數自己會對）

```
keep               5
archived-unmerged  28
abandoned          5
closed-landed      1
needs-call         1   ← ★見下面第三節
合計               40 ✓
```

★它**不能**放進 `landed-slices.tsv`：那一份的檔頭明寫「由 git log 機械生成，不是手工維護」，
而處置是**判斷**，git log 推不出來。
★★表頭已寫死三件事：刪除一律用戶裁（本檔只標記）／keep 以外的東西**以票回來不以分支回來**／清單是入口不是工單。

# ★我裁的那兩支基建

```
pass-phase-bed  ⇒ archived-unmerged（不另註冊）
  理由：它改的 6 個檔【全部】都在 intel-wake-by-content 裡，是同一件事的較早版本。
  ★而我沒有只靠「看起來一樣」——`merge-base --is-ancestor` 驗過：它就是 intel-wake 的祖先。

teamlife-taps   ⇒ keep
  理由：隊生滅咽喉點記帳 ＋ 逐日逐因床，正對不變量 #9（世界有沒有變糟要看 extinct／starve／combat）。
  ★★但它動了 8 支 production 檔各一行（很可能是把建隊／滅隊收斂到咽喉點）⇒ **不是純 tap**
  ⇒ 照你說的：**排在目前那票之後，自己走 R²＋電池，不搭票**。
```

# ★★★退回一件：`walkthrough-v2`

你裁「產物已在 main ⇒ 關」。**產物那半對，另一半不對**，而我查了才敢講：

```
docs/measurements/2026-09-17-c1-walkthrough-v2-clean.txt   ★175 行，逐位元在 main
scripts/debug/c1_walkthrough.gd                            ★★167+／68−，main 完全沒有
scripts/simulation/player_api_mapper.gd                    ★★17+／1−，main 完全沒有
而 main 自 merge-base（5081d41e6）起【沒有動過那兩個檔】（各 0 個 commit）
⇒ 那些改動不是「被別的東西取代了」，是【從來沒進去】
```

⇒ **產物落地了，產生它的 code 沒有。**
★★而這比「沒落地」更糟：main 上那份量測檔旁邊放著的，**不是產生它的那個程式**
⇒ 下一個人照著 main 的 `c1_walkthrough.gd` 重跑，會得到**另一個程式的輸出**，
  而畫面上它看起來就是「可重現」。

**要你裁**（兩條路，我不自己選）：
1. 把那兩個 code 檔的改動當一張票收回來（它是產生現有量測的唯一版本）
2. 或者：在那份量測檔頂端標「★產生它的 code 不在這棵樹上」，然後關掉分支

★在你裁之前我把它標成 `needs-call`，沒有關它。

# 順手抓到並修好的（同日第二條壞掉的延後裁定列）

`pass-phase-bed-stale-verdict-line` 的 `met_check` 是**恆假**：

```
舊：git show origin/feat/pass-phase-bed:…  | grep -q "tap=%d vs emit=%d"
    ★它問「那支【祖先】分支修好了沒」—— 而修正在它的【後代】上，
      沒有人會回頭去修一支要封存的分支 ⇒ ★★永遠不會解除
    ★★★這跟我今早刪掉的那條【恆真】是鏡像（恆空與恆滿是同一個病）
新：git show origin/main:…                 | grep -qF "tap=%d vs emit=%d"
    ⇒ 三種情況都分得開，而且我用【三棵真實的樹】各驗一次：
      main 現況（檔不在）      ⇒ 未達成 ✓
      合併結果 a18be0a5f       ⇒ 達成   ✓（intel-wake 一落地就自動解除）
      pass-phase-bed 單獨      ⇒ 未達成 ✓（它守的那個危險仍然紅得起來）
```

# 你的③④

```
③ 已做：known_issues 的 subteam-idle-latch 那條註了「分支＝參考非基底」＋指向處置表。
   ★其餘 keep 三支（ten-cadences／failure-memory／intel-wake）在 defers/known_issues 沒有對應列
     ⇒ 依你「有對應列的才註」，不硬造列。
④ 收到：triage 到此結，不加閘、不做第二次普查。
```

# 現況

merge 電池仍卡在【不可判】（68／72 被機器記憶體壓力殺掉），等用戶對重跑點頭。
