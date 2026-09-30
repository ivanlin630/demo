# scripts/ui/text_ui_layout.gd
# 文字介面版面的【寬度地基】（spec 2026-09-30 版面 v2 §2①／§6②）。
#
# ★★★為什麼這支要先寫：reviewer grep 全庫 ⇒ **零 CJK 顯示寬度計算函式**。
#   而 `team_ui_helper.gd:9 _pad()` 用的是 `s.length()` ＝**字元數**，不是**顯示寬度**
#   ⇒ 一行「國隊人口糧」在它眼裡是 5，在終端上佔 10 格。
#   ★★而只驗「比較那一步讀了 COLS」抓不到這件事：一個永遠回 `length()` 的函式
#     **一樣會通過 COLS 擾動測試**（spec §6② 逐字）⇒ 所以 P3b 用【2N+M 定樁】獨立驗它。
#
# ★誠實限（逐條，寫在這裡因為它決定了「寬度」這個詞在本專案的意思）：
#   1. 本函式**不是**完整的 Unicode East Asian Width 表 —— 它涵蓋下面 `_WIDE_RANGES`
#      那幾段（CJK／假名／諺文／全形形式），逐段註明出處。
#   2. ★**Ambiguous 一律算 1**（例如框線 `─` U+2500、`★` U+2605、`⇒` U+21D2）。
#      這是【刻意的選擇】不是遺漏：本專案的分隔線是用框線字元畫的，
#      算 2 會讓每一條分隔線的長度變成兩倍 ⇒ 版面自己就對不齊。
#      ★★代價：在把 Ambiguous 畫成全形的終端上，含 `★` 的那幾行會比算出來的寬
#      ⇒ 那一類只有**用戶的終端**能回答（同 spec §5：「120 是不是對的寬度」機器判不了）。
#   3. 組合附加符號（U+0300–U+036F）算 0；其餘 combining／ZWJ／emoji 序列**不處理**
#      —— 本專案的玩家面字串裡沒有它們，出現了要回來補這一段，而不是讓它悄悄算錯。
class_name TextUiLayout
extends Node

# ★★★版面寬度的【唯一一份】（spec §2①：禁第二處寫 120）
const COLS: int = 120

# 全形（East Asian Wide ＋ Fullwidth）的碼位段 —— 逐段註明它是什麼
const _WIDE_RANGES: Array = [
	[0x1100, 0x115F],    # 諺文字母（初聲）
	[0x2E80, 0x303E],    # CJK 部首補充／康熙部首／CJK 符號與標點
	[0x3041, 0x33FF],    # 平假名／片假名／注音／諺文相容／CJK 相容
	[0x3400, 0x4DBF],    # CJK 擴充 A
	[0x4E00, 0x9FFF],    # CJK 統一表意文字（本專案的中文都在這一段）
	[0xA000, 0xA4CF],    # 彝文
	[0xAC00, 0xD7A3],    # 諺文音節
	[0xF900, 0xFAFF],    # CJK 相容表意文字
	[0xFE10, 0xFE19],    # 豎排形式
	[0xFE30, 0xFE6F],    # CJK 相容形式／小型變體／全形標點變體
	[0xFF00, 0xFF60],    # 全形 ASCII 變體（全形數字／全形英文／全形標點）
	[0xFFE0, 0xFFE6],    # 全形貨幣等記號
	[0x20000, 0x2FFFD],  # CJK 擴充 B 以後
	[0x30000, 0x3FFFD],  # CJK 擴充 G 以後
]


# 一個碼位佔幾格（0／1／2）
static func char_width(cp: int) -> int:
	if cp >= 0x0300 and cp <= 0x036F:
		return 0   # 組合附加符號（見誠實限 3）
	for r in _WIDE_RANGES:
		if cp >= int(r[0]) and cp <= int(r[1]):
			return 2
	return 1

# ★★★一個字串在終端上佔幾格。
#   ★判準（P3b）：餵 N 個全形 ＋ M 個半形 ⇒ 必須**精確等於** 2N+M
#     —— 那個期望值來自算術，不是來自本支 code ⇒ 兩邊不同源。
static func display_width(s: String) -> int:
	var w: int = 0
	for i in range(s.length()):
		w += char_width(s.unicode_at(i))
	return w

# 把字串補到 `width` 格寬（不足補空白；★超過【不截斷】——
#   ★★截斷會讓「這一行太寬」變成一個看不見的錯，而版面票的 P3 要的是它**紅**）
static func pad_to(s: String, width: int) -> String:
	var out: String = s
	var w: int = display_width(s)
	while w < width:
		out += " "
		w += 1
	return out

# 依【顯示寬度】截到不超過 `width` 格（需要截的地方才呼它，例如一欄放不下的長名字）
#   ★回傳的寬度保證 <= width；★★而它不補齊（補齊是 `pad_to` 的事）
static func clip_to(s: String, width: int) -> String:
	var out: String = ""
	var w: int = 0
	for i in range(s.length()):
		var cw: int = char_width(s.unicode_at(i))
		if w + cw > width:
			break
		out += s[i]
		w += cw
	return out
