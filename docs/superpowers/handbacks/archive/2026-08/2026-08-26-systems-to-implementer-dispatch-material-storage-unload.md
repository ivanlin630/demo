---
from: systems
to: implementer
status: consumed
slice: material-storage-and-unload
tier: behavior
topic: ★★★DISPATCH(R² CLEAN):你找到的載重根→修法=兩條線都接(採集在自家據點入庫 + 回家卸貨);★★★★而【不得 join PUBLIC_RESOURCES】——R² 抓到那條白名單的「不在家」子分支沒有載重限制,照字面做會讓 material 在野外完全不受限;★我又順線抓到第二處寬:分支條件是任何據點不分是誰的⇒要加「自家」;★算術已先講死,驗收不預測數量
---

# ★★★DISPATCH：`docs/superpowers/specs/2026-08-26-material-storage-and-unload-HOW.md`（R② CLEAN）

★**這張票的根是你找出來的** —— `carry_full 72/72` ＋ `pool_empty 0` ＋ 把載重欄跟 `carry_full` 一起印，
★★**那三件缺一件我都判不出「裝不下」而不是「沒得採」。**

## ★①修法兩半，★★第二半才是解鎖那一半
```
① 採集所得的 material，★在【自家】據點上 → TileBank.deposit（進公庫）
② ★★隊在自家據點時，超出載重的私產 material 卸進公庫
```
★**只做①，那 4 支的 400 還是卡在私產，`carry_full` 仍然 72/72** —— **②才是打開自我維持鎖的那把。**

## ★★★★②【最重要的一條】不得單純 join `PUBLIC_RESOURCES`（R² 揭）
`resource_system.gd:343-347`（白名單的「不在家」子分支）★**完全沒有呼叫 `carry_space_for_res`** ——
★★**載重限制只活在最外層 `else`（`:348`），也就是 material 現在走的那條。**
⇒ ★★★**照字面 join 白名單 ＝ material 在野外【完全不受載重上限】。那不是「鬆一點」，是「不存在」。**

**要的形狀（★在不在家決定走哪條，不是在不在白名單）**：
```
material：
  ★在【自家】據點上 → TileBank.deposit(dst_tile, "material", gain, ...)
                      （★不受載重是【對的】：人就站在自己倉庫上，東西不用背）
  ★否則（含站在【別人】據點上）
                    → ★★走原 else 的 carry-limited 私產路，★一行不改
                      （★★含既有那個「兩種零分開」的 tap —— 那是你上一票加的，別在重構時弄丟）
```

### ★而「自家」這個條件是我加的，理由要講死
現成分支判的是 **`dst_tile.outpost_level > 0`** —— ★**任何據點，不分是誰的。**
⇒ ★★**照抄 ＝「在【別人】據點上採 material 就送給對方」。**
★**ore 現在就是這個行為（既有、不在本票範圍，不要順手改它）**；★★**但對 material 那會是一條新的漏。**

## ★★我從這兩處學到的形狀，寫給你也是寫給我自己
> ★★★**「照既有法延伸」不等於「照抄既有分支」。延伸的是【語意】，不是 code 路徑。**
> **現成分支的條件常常比你要的【寬】** —— **這次寬了兩處（沒有載重限制／不分是誰的據點），兩處我都沒讀就寫進 spec 了。**

---

# ★③算術我已經先講死（★所以驗收不預測數量）
```
L1 civilian 公庫 cap = 200 ｜ pop 6 載重 = 60
★BuildAfford.can_afford 是【逐 key 兩池加總】（build_afford.gd:41-51，R② 幫我確認過）
   ⇒ 可用上限 260   vs   升級含緩衝 225      ⇒ ★可達，但餘裕只有 35
```
★**若修完 `upgd.dispatched` 仍為 0：第一個要查的是【私產是否同時被別的支出佔走】，不要回頭調緩衝。**

# ★④驗收（★對象＝那 4 支超載隊，它們是最乾淨的陽性對照）
1. ★`matin.carry_full` 在 Team3/4/5/7 從 `72/72` **下降**、`gained > 0`（現況 0.0）
2. ★★**公庫 material > 0**（現況全程 0）—— **這一格直接證明線接上了**
3. `upgd.dispatched > 0`（★**方向不是數值**；為 0 照原樣回報，見③）
4. **對帳仍平**：四出口合計 == `matin.call`；八類 == `upg.call`
5. ★**這是 behavior 改，`fp` 兩張床都會變** ⇒ ★★**回歸防線改成【守恆帳】**：
   `TileBank` 守恆稽核不新增不平 ＋ `harvest.vault_overflow_drop` 溢出可觀測
6. headless（baseline 7）＋ 憲法閘 PASS

# ★⑤刻意不改的，先講死
- ★**床 config 給 Team3/4/5/7 塞 `material 400`** —— **失真，但這輪不改**：★★**它是「超載鎖」最乾淨的陽性對照，而這個修法會自動解掉它。**（已記 `known_issues`。）
- ★**不改 `MARGIN_NEUTRAL`／`OUTPOST_COST`／不給 mounts-wagons** —— **四個都是把「一條沒接的線」paper over 成數字好看。**
- ★**ore 現有的「任何據點都入庫」行為不動。**

## ★最後一件（★你上一票的雷，我幫你放在這裡）
★**改完先 `git status`，確認那兩個檔出現在【該出現的那棵樹】裡再跑** ——
★★**「改動沒效果」跟「改動不在被跑的那棵樹」長得一模一樣。**
