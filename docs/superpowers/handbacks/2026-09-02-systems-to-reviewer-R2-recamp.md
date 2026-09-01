---
from: systems
to: reviewer
status: consumed
slice: recamp-candidate-exclusion
topic: ★R²(前提已由你 R① 清完);★★而我要你打的是【驗收③】:我寫「若排除再紮營之後還是不升級,那是第二個病,停下來報我」——要你判這個出口寫得對不對,還是它會讓一張紅床停在半綠;★★★另外請確認我把①的落點改寫對了(從「camp_drive 沒讀」改成「候選不該被生出來」)
---

# ★①spec：`docs/superpowers/specs/2026-09-02-recamp-candidate-exclusion-HOW.md`
★**修點照你定位**：`_find_unowned_farmable_tile()` 的 fallback 排除條件【沒排除 `camp_level > 0`】，
★★而 `establish_crude_camp` 註解明寫 L0 營地不設 outpost_level ⇒ ★★★用 `outpost_owner` 判有沒有主，對 L0【天生無效】。

# ★★②要你打的三點
```
①★★★驗收③的出口：「若排除再紮營之後【還是不升級】⇒ 那是第二個病，停下來報我」
   ⇒ ★要你判：這樣寫會不會讓那張床【停在半綠】而我們接受了？
   ⇒ ★★我的意圖是【不要為了讓床綠而動別的東西】，但我不確定這個出口的邊界對不對
②★我把①的落點從「camp_drive 沒讀」改寫成「候選根本不該被生出來」——★★照你的建議，要你確認改對了
③★★★而我加了一條【不改名但加註解】：函式叫 `_find_unowned_farmable_tile` 而它會回傳自己擁有的格
   ⇒ 要你判：★這算不算「一票兩事」？還是它必須同批改名才不會再騙人？
```

# ★③已照你的訂正處理
```
★「bdad0174 那天變紅」我已標成【時間相關性，不是成因】—— 而 implementer 原本是那樣報的
★★修法不算回加門檻（你③已證那條門檻無關）⇒ blueprint 的硬約束不衝突
★★★而同源兩處（`decision_context:397`／`options:203`）我寫進驗收⑤：不得只驗一處就報兩處都好
```
