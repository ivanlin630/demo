---
from: systems
to: implementer
status: consumed
slice: recamp-candidate-exclusion
tier: infra
topic: ★R² CLEAN ⇒ 動工;★★★而你報的「它在 bdad0174 那天變紅」被 R① 訂正了:那顆 de-patch 拿掉的是【無關的絕境門檻】⇒ 那是【時間相關性不是成因】;★真根在候選產生端:`_find_unowned_farmable_tile()` 的 fallback 沒排除 `camp_level > 0`,而 L0 營地【不設 outpost_level】⇒ 用 owner 判有沒有主對它天生無效
---

# ★①修什麼（★R① 定位，一行，同源兩處同時好）
```
★`_find_unowned_farmable_tile()` 的 fallback 排除條件【沒有排除 `camp_level > 0`】
★★而 `establish_crude_camp` 註解自己寫著：L0 營地【不設 outpost_level、不 set_owner】（`:5534`）
   ⇒ ★★★所以「用 `outpost_owner` 判有沒有主」對 L0 營地【天生無效】—— 而排除條件正是那樣判的
★同源兩處：`decision_context.gd:397` ／ `options.gd:203`
```
★**而這【不算回加門檻】**（blueprint 的硬約束）—— ★★**R① 已證 `bdad0174` 那條門檻與本洞無關。**

# ★★②你那句「它在 bdad0174 那天變紅」被訂正了
```
★R①：那顆 de-patch 拿掉的是【無關的絕境門檻】⇒ ★★與這個洞完全無關
⇒ ★★★所以那是【時間相關性，不是成因】—— 而你原本是當成因報的
```
★**我沒有因此少採信你那一票** —— ★★**「它哪天變紅」仍然是有用的線索，只是它不是答案。**

# ★★★③驗收（★③④的關係已被 R² 釘死，防半綠）
```
①★床轉綠 —— ★★而【不得放寬斷言】（★★★那會把警報器關掉，而它已經對我們喊了 12 天）
②★行為：站在自己 L0 營地上時，「再紮營」不再出現在候選集（逐 option dump 可驗）
③★★若排除之後【還是不升級】⇒ 那是【第二個病】，★★★停下來報我
   ★★★★而【①不算失敗】：本票以「修好第一個 ＋ 具名第二個」交件，★床維持紅，
      並在 known_issues 寫明「它現在紅是因為第二個病」—— ★否則下一個人會再走一次那 12 天
④★fp 會變（intended-change），標注即可
⑤★★同源兩處都要驗 —— ★★★不要只驗一處就報兩處都好
```

# ★④順帶（★R² 判它不算一票兩事）
★**在該函式加一行註解**：**「它會回傳【自己擁有】的格 —— 名字說 unowned，而 L0 營地不設 owner」**
⇒ ★★**不改名**（改名是另一票），★★★**但不加註解的話，下一個人會照名字信它。**
