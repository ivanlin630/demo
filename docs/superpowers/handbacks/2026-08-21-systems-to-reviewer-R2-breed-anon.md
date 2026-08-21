---
from: systems
to: reviewer
slice: breed-anon-eligible
status: consumed
topic: "[R② 審設計·生育(a) 讓 anon 也算生育者(用戶 2026-08-21 拍板『(a)匿名也能生(推薦)』,授權真檔=blueprint 五裁定信)·spec=docs/superpowers/specs/2026-08-21-breed-anon-eligible-HOW.md·★查證後範圍比我原本想的窄:_breed_balance 早就把 anon 算進兩性池了(m=anon×(1-ratio)、f=anon×ratio 再依 named breeder 性別+1)⇒【anon 一直是配偶,只是不算生育者】,本刀只補這一半·★我要你優先打三點:①團層安全代理我選『該隊 named 通過安全門檻的比例』(無 named 取 leader、再無取 1.0)——這是用既有訊號不新增機制,但『當家的人覺得安全』能不能代表 anon 處境?無 named 時取 1.0 會不會讓孤兒隊爆生? ②我【故意不給 anon 個別 food 門檻】,理由是 f(rel_surplus) 已經是團層糧食項、再加一層等於同一件事扣兩次——但 named 現在其實【兩層都吃】(f 又 needs.food),所以改完 anon 與 named 的門檻不對稱,這個不對稱可接受嗎? ③§3 常數重新錨定:我把參考村規模留給量測定(不由我猜),但『BASE=(1/30)/(0.5×適齡數(P_ref))』這個推導本身若 P_ref 選錯就整條偏——有沒有比『中位隊伍規模』更穩的錨?·★gate 7 我要求 breed.eligible_anon 若恆 0 就明寫本刀 inert(同 T1/T3 處理)"
---

# R②：生育 (a) —— 讓 anon 也算「生育者」

**spec**：`docs/superpowers/specs/2026-08-21-breed-anon-eligible-HOW.md`
**WHAT**：用戶 2026-08-21 拍板「**(a) 匿名也能生（推薦）**」（授權真檔 ＝ blueprint 五裁定信）

## ★查證後，範圍比我原本想的窄
**`_breed_balance` 早就把 anon 算進兩性池**（`m = anon×(1-ratio)`、`f = anon×ratio`，再依 named breeder 性別 +1）
⇒ **anon 一直是「配偶」，只是不算「生育者」**。**本刀只補這一半。**

## ★我要你優先打三點

### ① 團層安全代理
我選「**該隊 named 通過安全門檻的比例**」（無 named 取 leader、**再無取 1.0**）。
理由：**用既有世界訊號、不新增機制**。
**但**：「當家的人覺得安全」**能不能代表 anon 的處境**？
★ 而且**無 named 時取 1.0 會不會讓孤兒隊爆生**？（我自己覺得這個 fallback 最可疑。）

### ② 我**故意不給 anon 個別 food 門檻**
理由：**`f(rel_surplus)` 已經是團層糧食項**，再加一層 ＝ **同一件事扣兩次**。
**但**：**named 現在其實兩層都吃**（`f` 又 `needs.food > 0.7`）
⇒ 改完之後 **anon 與 named 的門檻不對稱**。**這個不對稱可接受嗎？**
（另一條路是**把 named 那層也拿掉**，但那會動到現行行為，我沒敢寫進本刀。）

### ③ §3 常數重新錨定
現行 `0.0133` 的推導錨（「**5 名適齡成人**」）**實測不存在**（1.4 名/隊）。
新推導 `BASE = (1/30) / (0.5 × 適齡數(P_ref))`，**`P_ref` 我留給量測定、不由我猜**。
**但這個推導若 `P_ref` 選錯就整條偏** —— **有沒有比「中位隊伍規模」更穩的錨？**

## 附帶
- gate 7 我要求 **`breed.eligible_anon` 若恆 0 就在帳上明寫「本刀 inert」**（同 T1／T3 的處理）。
- §5 明列不做：**不觸血脈**（王朝 arc 掛點）、不改 `cap`／`_breed_balance`／`f` 形狀、**不給 anon 個別 needs**。
