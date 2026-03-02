from __future__ import annotations

import json
import os
from functools import lru_cache
from typing import Any

SUPPORTED_LANGS = {"en", "vi", "tl", "ko", "ja", "haw"}
DEFAULT_LANG = "en"

# backend/app/core/i18n.py  -> locales folder at backend/app/locales
_LOCALES_DIR = os.getenv(
    "LOCALES_DIR",
    os.path.join(os.path.dirname(os.path.dirname(__file__)), "locales"),
)


def normalize_lang(lang: str | None) -> str:
    if not lang:
        return DEFAULT_LANG

    l = lang.strip().lower().replace("_", "-")
    if l in ("auto", ""):
        return DEFAULT_LANG

    if l.startswith("en"):
        return "en"
    if l.startswith("vi"):
        return "vi"
    if l.startswith("tl") or l.startswith("fil"):
        return "tl"
    if l.startswith("ko"):
        return "ko"
    if l.startswith("ja"):
        return "ja"
    if l.startswith("haw"):
        return "haw"

    return DEFAULT_LANG


@lru_cache(maxsize=32)
def _load_locale(lang: str) -> dict[str, Any]:
    lang = normalize_lang(lang)
    path = os.path.join(_LOCALES_DIR, f"{lang}.json")
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except FileNotFoundError:
        return {}
    except Exception:
        return {}


def t(key: str, lang: str | None = None, **kwargs) -> str:
    """
    Translate dotted key like: "alert_buddy.no_alerts"
    Fallback chain: requested lang -> en -> key itself.
    """
    lang_n = normalize_lang(lang)
    catalog = _load_locale(lang_n)
    en_catalog = _load_locale("en")

    template = catalog.get(key) or en_catalog.get(key) or key
    if not isinstance(template, str):
        return key

    try:
        return template.format(**kwargs)
    except Exception:
        # never crash endpoint because of formatting
        return template


def supported_langs() -> list[str]:
    return sorted(SUPPORTED_LANGS)