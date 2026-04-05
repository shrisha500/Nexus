"""TermTooltip.cl.jac — Click-to-expand jargon definition chip."""

import from "../styles/term.css" { term_css }

def:pub TermTooltip(term: dict) -> JsxElement {
    has open: bool = False;

    word          = term["word"];
    plain_meaning = term["plain_meaning"];
    real_name     = term["real_name"];
    usage_context = term["usage_context"];
    already_seen  = term.get("is_defined_before_use", False) if hasattr(term, "get") else False;

    return <div
        className={("term-chip" + (" term-chip--seen" if already_seen else ""))}
        onClick={lambda -> None { open = not open; }}
    >
        <span className="term-chip__word">{word}</span>

        {open and
            <div className="term-chip__popover">
                <div className="term-chip__popover-inner">
                    <div className="term-row">
                        <span className="term-label">Plain meaning</span>
                        <span className="term-value">{plain_meaning}</span>
                    </div>
                    {real_name != word and
                        <div className="term-row">
                            <span className="term-label">Real name</span>
                            <span className="term-value term-value--name">{real_name}</span>
                        </div>
                    }
                    <div className="term-row">
                        <span className="term-label">Used in</span>
                        <span className="term-value term-value--context">{usage_context}</span>
                    </div>
                    {already_seen and
                        <span className="term-chip__seen-badge">defined earlier</span>
                    }
                </div>
            </div>
        }
    </div>;
}
