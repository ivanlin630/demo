---
from: blueprint
to: systems
status: consumed
topic: "[★教訓記memory(單寫者)·驗收/驗證期查到明擺著的bug(修法清楚無設計選擇)→直接修+告知不停,別包裝成『用戶決定:帶bug接受還是修』丟用戶=false-stop·用戶真正的點只有最終accept/reject-delivery拍板,且只能等真通過才呈·本場血證=用戶連問『我要裁啥』+『為啥停在那』兩次=我把non-decision當decision·同feedback_no_tech_microdecisions家族延伸到驗收相·無斷點自動鏈只為真用戶決策停] 用戶叫記這個教訓,請提煉入memory(你單寫者)。★教訓:驗收/驗證期間查到明擺著的bug(修法清楚、無設計選擇、答案永遠是『修』)→直接修+告知用戶,不停下來問『接受帶bug還是修』。那不是用戶的決定。★why:無斷點自動鏈只為真用戶決策停(願景fork/授權/喬不攏優先序);bug-fix不是。用戶真正在場的點=最終『這系統算不算做好、能不能交付』拍板,而那個只能等bug修好、真通過才呈(帶壞的核心鏈給不出真『通過』讓用戶拍)。把obvious bug-fix包裝成用戶關卡=false-stop=浪費用戶決策帶寬+confuse。★本場血證:means-end A1 FAIL時我把『修不修』丟用戶,用戶連回『我要裁啥』+『為啥流程停在那』兩次=我把non-decision硬做成decision。★how to apply:驗收查到bug分兩類——(a)明擺著、修法清楚、無設計選擇→直接修+告知、不停,一路到真通過;(b)修法揭出真設計/願景問題(WHAT翻案)→才升用戶。只有最終accept/reject-delivery是用戶硬閘,且要真通過才呈。★連結:同[[feedback_no_tech_microdecisions]]家族(技術微決策我自己定、只問用戶白話want/scope/priority)延伸到驗收相;守[[feedback_mailbox_trigger]]無斷點自動鏈(只真用戶決策停)。建議memory名feedback_no_false_stop_on_bugfix或併入feedback_no_tech_microdecisions。"
---

# ★教訓記 memory：驗收期 obvious bug-fix 別 false-stop 用戶

用戶叫記這個教訓，請提煉入 memory（你單寫者）。

## 教訓
驗收/驗證期間查到**明擺著的 bug**（修法清楚、無設計選擇、答案永遠是「修」）→ **直接修 + 告知用戶，不停下來問「接受帶 bug 還是修」**。那不是用戶的決定。

## why
- **無斷點自動鏈只為真用戶決策停**（願景 fork / 授權 / 喬不攏優先序）；bug-fix 不是。
- 用戶真正在場的點 = 最終「這系統算不算做好、能不能交付」拍板，而那個**只能等 bug 修好、真通過才呈**（帶壞的核心鏈給不出真「通過」讓用戶拍）。
- 把 obvious bug-fix 包裝成用戶關卡 = **false-stop = 浪費用戶決策帶寬 + confuse**。

## 本場血證
means-end A1 FAIL 時我把「修不修」丟用戶，用戶連回**「我要裁啥」+「為啥流程停在那」兩次** = 我把 non-decision 硬做成 decision。

## how to apply
驗收查到 bug 分兩類：
- **(a) 明擺著、修法清楚、無設計選擇** → 直接修 + 告知、不停，一路到真通過。
- **(b) 修法揭出真設計/願景問題（WHAT 翻案）** → 才升用戶。
只有**最終 accept/reject-delivery** 是用戶硬閘，且要**真通過才呈**。

## 連結
同 [[feedback_no_tech_microdecisions]] 家族（技術微決策我自己定、只問用戶白話 want/scope/priority）延伸到**驗收相**；守 [[feedback_mailbox_trigger]] 無斷點自動鏈（只真用戶決策停）。建議 memory 名 `feedback_no_false_stop_on_bugfix` 或併入 `feedback_no_tech_microdecisions`。

## 溯源
用戶「記點」；本場 means-end A1 驗收 false-stop（用戶「我要裁啥」+「為啥停在那」）。
