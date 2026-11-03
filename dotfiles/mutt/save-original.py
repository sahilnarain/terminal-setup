#!/usr/bin/env python3
"""Save the HTML part of the message being replied to, for html-alternative.py.

Mutt pipes the raw message here (pipe_decode must be off) just before <reply>.
Writes ~/.mutt/tmp/reply-original.json, or removes it if the message has no
HTML part, so a stale file can never be used for a plain-text original.
"""
import email
import email.policy
import email.utils
import json
import os
import re
import sys
import time

OUT = os.path.expanduser("~/.mutt/tmp/reply-original.json")


def html_part(msg):
    for part in msg.walk():
        if part.get_content_type() != "text/html":
            continue
        if part.get_content_disposition() == "attachment":
            continue
        try:
            return part.get_content()
        except Exception:
            payload = part.get_payload(decode=True) or b""
            return payload.decode(part.get_content_charset() or "utf-8", errors="replace")
    return None


def clean(html):
    # keep only the <body> contents; drop scripts, styles, head, comments
    m = re.search(r"<body[^>]*>(.*)</body>", html, re.S | re.I)
    if m:
        html = m.group(1)
    html = re.sub(r"<(script|style|head|title)\b.*?</\1\s*>", "", html, flags=re.S | re.I)
    html = re.sub(r"<!--.*?-->", "", html, flags=re.S)
    html = re.sub(r"</?(html|body|meta|link)\b[^>]*>", "", html, flags=re.I)
    # inline images (cid:) are not re-attached; show their alt text instead
    def cid(m):
        alt = re.search(r'alt\s*=\s*"([^"]*)"', m.group(0), re.I)
        return "[%s]" % alt.group(1) if alt and alt.group(1) else "[image]"
    html = re.sub(r"<img\b[^>]*src\s*=\s*[\"']?cid:[^>]*>", cid, html, flags=re.I)
    return html.strip()


def main():
    msg = email.message_from_binary_file(sys.stdin.buffer, policy=email.policy.default)
    html = html_part(msg)
    os.makedirs(os.path.dirname(OUT), mode=0o700, exist_ok=True)
    if not html:
        if os.path.exists(OUT):
            os.remove(OUT)
        return
    addr = email.utils.parseaddr(str(msg.get("From", "")))[1].lower()
    data = {
        "from_addr": addr,
        "message_id": str(msg.get("Message-ID", "")),
        "saved_at": time.time(),
        "html": clean(html),
    }
    tmp = OUT + ".tmp"
    fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(data, f)
    os.replace(tmp, OUT)


if __name__ == "__main__":
    main()
