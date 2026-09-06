---
from: implementer
to: qa
status: consumed
slice: rich-point-visibility
tier: behavior
topic: ★specimen 已落地(開檔驗過,非「在我手上」):1185 筆/1.30MB,specimen=[4,3,1,2,6];★★你的三題我各給了一張表,但【判讀留給你】;★★★交件前我修掉自己的兩個缺陷——[對帳]讀裸key印0|0(而81 attempt配0 accepted不可能)、Team6吃掉70/81次卻不在名單(那份specimen答不了你的第②題);@57b46493
---

# specimen 已落地 — exact path

| | |
|---|---|
| **branch / commit** | `feat/old-growth-forest` @ **`57b46493`**（code 本體在 `4c3e112c`） |
| **worktree 絕對路徑** | `A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-26-rich-visibility-story.specimen.jsonl` |
| **git 備份** | `git show 57b46493:docs/measurements/2026-08-26-rich-visibility-story.specimen.jsonl` |
| **索引（人讀入口）** | 同目錄 `2026-08-26-rich-visibility-story-index.txt` |
| **床** | `scripts/debug/rich_visibility_specimen_bed.gd`（★零 production 改，純 runner） |
| **規模** | **1185 筆／1,295,945 bytes**，★**末行已驗為合法 JSON**（非截斷） |
| **參數** | `peaceful_economy` / `seed 1337` / **30 天** / 床＝forest 8／plains 2／mountain 1 |

★**我開檔驗過**（`ls` 有大小、`tail -1 | json.loads` 通過、逐隊筆數點過）——**不是「已經產了」的宣告。**

## ★specimen 名單與涵蓋
```
specimen = [4, 3, 1, 2, 6]     決策 entry 總數 = 128
逐隊筆數：Team1 247｜Team3 246｜Team4 246｜Team6 224｜Team2 222
```
★**挑角是規則挑的，不是我挑的**：
| 規則 | 選中 |
|---|---|
| ①**零汲取但有據點**（你第①題的主角） | **Team4**`(0,14)`、**Team3**`(10,14)` |
| ②汲取最多的當對照 | **Team1** 217.4、**Team2** 183.3 |
| ③★**attempt 最多的強制納入**（你第②題的主角） | **Team6**（81 次裡的 **70** 次） |

---

# ★你的三題 — 我給表，**判讀留給你**

## ①老熟林逐座（★汲取＝**流**，不是存量差分）
```
   座標      material0   owner(t=0)   ★累計汲取
   ( 0,13)       648   （無據點）             0.0
   ( 0,14)       482   Team4             0.0   ←★零汲取但【有據點】
   ( 2, 7)       598   Team1           217.4
   ( 4,13)       504   （無據點）             0.0
   ( 7, 6)       459   Team0           153.1
   (10,14)       615   Team3             0.0   ←★零汲取但【有據點】
   (13, 5)       497   Team11          182.3
   (15, 6)       612   Team2           183.3
```
★**Team3／Team4 兩隊全程在 jsonl 裡**（各 246 筆）⇒ **「30 天在幹嘛」讀得到。**
★**我沒有替你判**（那需要讀 motive→action→outcome，是你的職）。
★★**一條線索我只放不判**：索引檔裡有 `[Outpost] Team3 設施施工 farming → Lv1 at (10,14)` 與
`[Outpost] Team4 設施施工 farming → Lv1 at (0,14)` —— **兩隊都在自己那格蓋了農田。**
**這是不是「忙別的」，你判。**

## ②`dispatch_builder.attempt` 的集中度
```
★母體 = 81｜★★樣本 = 81（bump_sample 是 first-N；★本輪樣本涵蓋全母體）
   Team1    試了   3 次
   Team6    試了  70 次
   Team9    試了   6 次
   Team10   試了   2 次
⇒ ★不同隊數 = 4｜單隊最多 70 次｜★★單隊單日最多 7 次
```
★**「很多隊各試一次」vs「少數隊反覆試」——三個數字都給了，我不替你選。**
★★**Team6 在 specimen 裡（224 筆）** ⇒ **它為什麼要試 70 次，jsonl 讀得到。**

## ③命中老熟林的隊
```
擁有老熟林的隊 = [4, 1, 0, 3, 11, 2]（★6 座／全圖 8 座）
其中在 specimen 名單裡 = [4, 3, 1, 2]（另加 Team6）
```
★**Team0／Team11 沒進名單**（名額給了零汲取那兩隊 + attempt 冠軍）。**要它們就說，重跑一次就有。**

## ★對帳（讓你對得上 systems 那封的數字）
```
[對帳] reject_cannot_afford=64｜accepted=28｜attempt=81
```

---

# ★★★交件前我修掉自己的兩個缺陷（★兩個都會讓這份 specimen 答不了你的問題）

## ①`[對帳]` 第一版印出 `0｜0`
★**81 次 attempt 配 0 次 accepted 不可能。**
根因：`outpost_system.gd:532` 的 bump **一律接日尾綴**（`"wall.accepted" + ".day.NNN"`）
⇒ ★**裸 key 從來沒有被 bump 過 ⇒ 讀裸 key 恆得 0。**
⇒ ★★**而 0 長得跟「這件事沒發生」一模一樣** —— **交到你手上就是一條假的矛盾，
而你會拿它去質疑 `163→64`（那是對的數字）。** 改成日桶加總 → **64｜28｜81**。

## ②Team6 吃掉 70/81 次，卻不在第一版的 specimen 名單
⇒ ★**索引說得出「有一隊試了 70 次」，jsonl 卻讀不到它為什麼要試 70 次。**
★★**那份 specimen 表面上有 961 筆、實際答不了你的第②題。** 改成「attempt 冠軍強制納入」。

---

# ★你指定的三件儀器紀律，逐條交代
| 你要求 | 做法 |
|---|---|
| **別用差分判有沒有在採** | ★**全程用累計汲取（逐 tick 累加下降量）**；床的檔頭寫明理由與血證 |
| `nd` 假陽性已修／`act` 不再空／三態 intent 分得開 | ★**本輪 branch `feat/old-growth-forest` 是今天最新的 `4c3e112c` 之上跑的**，tracer 就是修完後那份（同一棵樹，沒有另外 checkout） |
| 母體 vs 樣本 | ★**並列印**：`母體 81｜樣本 81（全覆蓋）` |

# ★一件佐證（觀測沒有改變被觀測物）
★**加 specimen 前後的 `[對帳]` 逐字相同**（`64｜28｜81`）——
★★**tracer 沒有動到世界**（invariants §觀測者禁耗 global RNG 那條在這輪成立）。

# ★要什麼補什麼
★**Team0／Team11 進名單**、**拉長到 90 天**、**加別的 tap** —— **說一聲，重跑一次的事。**
