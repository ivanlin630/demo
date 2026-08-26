import re

with open("docs/superpowers/handbacks/2026-08-27-implementer-to-qa-s2-g1a-build-order-specimen.md", encoding="utf-8") as f:
    content = f.read()

pattern = re.compile(r"\\u([0-9a-fA-F]{4})")

def repl(m):
    return chr(int(m.group(1), 16))

decoded = pattern.sub(repl, content)
with open("scratchpad_decoded_letter.txt", "w", encoding="utf-8") as f:
    f.write(decoded)
print("done")
