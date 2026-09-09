---
from: systems
to: blueprint
status: open
slice: 居民產生機制 —— 數完了
topic: ★★★數完之後【最重要的不是路的數量,是那個判準的形狀】：`is_resident_static` 不是一個【狀態】,是一個【當下位置】的謂詞——它同時要求 `TAG_PRODUCE` ＋【此刻站在自家/同勢力 outpost 上】｜★★所以「居民母體 0-1」有【兩種完全不同】的成因,而卷面分不出:(a) 幾乎沒有隊拿到 TAG_PRODUCE (b) 拿到了但【取樣那一刻不在家】｜★而在分開這兩者之前,「為什麼村莊不出生」這個問題【問得太早】
---

# ① 路數完了（產生端）

```
「居民」＝ is_resident_static（faction_ai_system.gd:600-614）—— ★它是【推導出來的謂詞】,不是存的狀態
   ①team.tags 有 TAG_PRODUCE
   ②★【此刻】站的那格 outpost_level > 0
   ③該 outpost 是自己的,或同 faction 的

寫入 TAG_PRODUCE 的產線只有【兩處】：
   interaction_system.gd:1651  _execute_settlement    （"settle"）
   interaction_system.gd:1678  _convert_to_resident   （"convert_resident"）
移除：faction_ai_system.gd:7038  uprising_exile（叛亂流放）

而 `_convert_to_resident` 的呼叫點有【六處】（faction_ai:2504/2519/3428、interaction:402/408 …）
   ＋ 空地 founding 走 `establish_crude_camp`（faction_ai:2507/2521，新 level-1 outpost ＋ 身分躍遷）
⇒ ★★★【機制不缺】—— 產生居民的路有好幾條，而且都不是死碼。
```

# ② ★★★而數完之後真正的發現是【判準的形狀】

```
`is_resident_static` 同時要求 ①身分（TAG_PRODUCE）② 【當下位置】在 outpost 上
⇒ ★一支有 TAG_PRODUCE 的隊【走出自己的村子】,它就【不再是居民】—— 而【沒有任何狀態改變】。
⇒ ★★它不是「這是不是一個村莊」,是「【這支隊此刻站在它的村子上嗎】」。
```

⇒ ★★★**所以「居民母體恆為 0-1」有兩種完全不同的成因，而那份卷面【分不出】**：
```
(a) 幾乎沒有隊拿到 TAG_PRODUCE          ⇒ 【村莊真的沒出生】＝你要的那個大問題
(b) 拿到了,但【取樣那一刻不在家】       ⇒ 【村莊存在,只是居民在外面】＝完全不同的世界
```
★**而這正是今天反覆出現的那一條**：**我量到的是另一個量**。
★★**這一次它出現在【謂詞】上**（前幾次在門檻、容器、predicate、欄位）。

# ③ ⇒ 我建議下一步【不是問成因】，是一格便宜的分離

```
同一輪快照分開數：
   ①有 TAG_PRODUCE 的隊數                          ← 身分
   ②其中【當下站在 outpost 上】的隊數               ← is_resident_static 真正在數的
   ③①−② ＝【有身分但不在家】的隊數                ← ★這個差就是答案
   ★★另外印：TAG_PRODUCE 的【累計授予次數】(settle / convert_resident 各幾次)
     ⇒ ★★★它分得出「從來沒有人變成居民」與「變過但後來被移除／走開了」。
```
★**若①也接近 0** ⇒ 那才輪到你要的成因題（村莊為什麼不出生），而且那時它是**乾淨的**。
★★**若①健康而③大** ⇒ ★★★**問題根本不是「村莊不出生」，是「居民不待在家」**
—— 而那是**另一個科**（決策層：為什麼生產隊一直被派出去）。

# ④ 序（你裁）

```
★我建議：先跑③那一格（便宜、一輪快照）,再決定 WHAT fork 怎麼呈。
★★理由：現在把「遊牧戰國 vs 定居文明層」端到用戶面前,
   ★★★而我們還分不出【村莊沒出生】與【居民不在家】—— 那兩個 fork 的內容完全不同。
(b) B1/B2/C4 併窗呈用戶：★同意,但建議【等這一格】——它只要一輪快照。
(c) 批一④ 不開：★已入帳。
```
