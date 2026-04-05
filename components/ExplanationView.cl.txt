"""ExplanationView.cl.jac — Ordered concept cards with sections and terms."""

import from "./TermTooltip.cl.jac" { TermTooltip }
import from "../styles/explanation.css" { explanation_css }

def:pub ExplanationView(concepts: list) -> JsxElement {
    if not concepts or len(concepts) == 0 {
        return <p className="empty-state">No explanation data found.</p>;
    }

    return <div className="explanation-view">
        {[
            <ConceptCard key={c["concept_name"]} concept={c} index={idx} />
            for idx, c in enumerate(concepts)
        ]}
    </div>;
}

def:pub ConceptCard(concept: dict, index: int) -> JsxElement {
    has expanded: bool = True;

    is_prereq = concept["is_prereq"];
    name      = concept["concept_name"];
    sections  = concept.get("sections", []) if hasattr(concept, "get") else concept["sections"];
    terms     = concept.get("terms",    []) if hasattr(concept, "get") else concept["terms"];
    depth     = concept["depth_level"];

    SECTION_META = {
        "why_it_exists":      {"icon": "💡", "label": "Why It Exists"},
        "problem_it_solves":  {"icon": "🔧", "label": "Problem It Solves"},
        "what_came_before":   {"icon": "⏪", "label": "What Came Before"},
        "what_it_is":         {"icon": "📌", "label": "What It Is"},
        "how_it_works":       {"icon": "⚙️",  "label": "How It Works"},
        "tradeoffs":          {"icon": "⚖️",  "label": "Tradeoffs"},
        "how_to_use":         {"icon": "🚀", "label": "How To Use"}
    };

    def depth_dots(d: int) -> str {
        return "▪" * d;
    }

    return <article
        className={("concept-card" + (" concept-card--prereq" if is_prereq else " concept-card--main"))}
        style={{"animationDelay": str(index * 0.1) + "s"}}
    >
        <div
            className="concept-card__header"
            onClick={lambda -> None { expanded = not expanded; }}
        >
            <div className="concept-card__title-row">
                {is_prereq and <span className="prereq-badge">prerequisite</span>}
                <h2 className="concept-card__name">{name}</h2>
                <span className="depth-indicator">{depth_dots(depth)}</span>
            </div>
            <button className="concept-card__toggle" type="button">
                {("▲" if expanded else "▼")}
            </button>
        </div>

        {expanded and
            <div className="concept-card__body">
                {len(sections) > 0 and
                    <div className="sections">
                        {[
                            <div key={s["type"]} className="section">
                                <div className="section__header">
                                    <span className="section__icon">
                                        {SECTION_META[s["type"]]["icon"] if s["type"] in SECTION_META else "•"}
                                    </span>
                                    <h3 className="section__title">
                                        {SECTION_META[s["type"]]["label"] if s["type"] in SECTION_META else s["type"]}
                                    </h3>
                                </div>
                                <p className="section__content">{s["content"]}</p>
                            </div>
                            for s in sections
                        ]}
                    </div>
                }

                {len(terms) > 0 and
                    <div className="terms-glossary">
                        <h4 className="terms-glossary__title">📚 Terminology</h4>
                        <div className="terms-list">
                            {[<TermTooltip key={t["word"]} term={t} /> for t in terms]}
                        </div>
                    </div>
                }
            </div>
        }
    </article>;
}
