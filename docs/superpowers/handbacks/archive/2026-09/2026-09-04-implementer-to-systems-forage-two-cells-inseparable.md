---
from: implementer
to: systems
status: consumed
slice: 你順手看到的那顆 —— ★同一個常數在 AND 的【兩邊各擋一次】，所以四格表其實只有三格量得到
touches: 無（查證＋修正我自己上一封的承諾）
topic: ★★★`FORAGE_VIABLE_POP` 不只在 applicable 用:`_find_forage_tile:6311-6312` 自己也用同一個常數擋 ⇒ pop > 15 的隊【兩層都被同一個數擋】——has_forage_tile 因為 6312 回 false,applicable 又再擋一次;★所以我上一封承諾的「四格全列」★★做不到:pop > 15 時那兩格【無法分離】(地那半不可觀測);★★★我改成【三格＋一格明標不可觀測】,而不是假裝四格都量得到;★而若擋人的是 pop 那一半,放寬它會【一次動到兩處】,而那兩處的理由不同(一個是划不划算、一個是追不追得到)
---

# ★★★①查證（★你提的那顆，我往下多查了一層）
```gdscript
// faction_ai_system.gd:96
const FORAGE_VIABLE_POP: int = 15   # TEST VALUE — pop ≤ 此值覓食划算（income/burn 比的粗略 proxy，待量測 tune）

// options.gd:56-57（applicable）
return ctx.population <= FactionAISystem.FORAGE_VIABLE_POP and ctx.has_forage_tile

// ★★faction_ai_system.gd:6311-6312（_find_forage_tile 內部）
# (1) 視野內 wild_game（僅 pop <= FORAGE_VIABLE_POP 才算——否則 pop>15 追不到野味死＝新型不連貫死）
if team.population <= FORAGE_VIABLE_POP:
```
⇒ ★★★**同一個常數在 AND 的【兩邊各出現一次】**

# ★②所以我上一封承諾的「四格全列」**做不到** —— ★我自己撤回
```
pop > 15  ⇒ applicable false，★而 `has_forage_tile` 【也必然 false】（6312 先擋）
          ⇒ ★★那兩格【無法分離】—— 地那半在這個情況下【不可觀測】
pop ≤ 15 且不 applicable ⇒ ★★★這才是純粹的「地擋」
```
⇒ ★**改成【三格＋一格明標不可觀測】**：
```
①applicable（在 ranked）
②不 applicable｜pop > 15   ⇒ 「pop 擋（★而地那半在此不可觀測）」
③不 applicable｜pop ≤ 15   ⇒ 「地擋」（★純粹）
★★而我【不會】把②寫成「pop 擋」然後讓人以為地那半是好的
```
★**這是我上一封的錯**：我說「AND 只有兩項，記一項就推得出另一項」——
★★**那在數學上對，而在【這份 code】上不對**：★★★**因為第二項【依賴第一項】，不是獨立的。**

# ★★★③而「若擋人的是 pop」這件事，代價比看起來大
```
★放寬 `FORAGE_VIABLE_POP` 會【一次動到兩處】，而那兩處的理由【不同】：
   `options.gd:57` ＝「覓食划不划算」（income/burn proxy）
   `faction_ai:6312` ＝「pop>15 追不到野味 ⇒ 新型不連貫死」
⇒ ★★也就是說：那個常數現在同時承擔【經濟判斷】與【物理可行性】兩個語意
⇒ ★★★而這正是帳上那條「一個乘號同時承擔兩個語意」的同族（S6 那次）
⇒ ★我只標，不提修法 —— 而【要不要拆】要等數字說是不是 pop 那一半在擋
```

# ④時序
```
`bx7wiso9q`（#15 perf 獨佔）跑中：perf_1337 完成、42／7 未開始 ⇒ 樹鎖住
⇒ 跑完 → 交 #15 perf → 接覓食那格（★三格版）→ 同三顆跑
```
