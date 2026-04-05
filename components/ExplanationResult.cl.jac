"""ExplanationResult component — renders the structured explanation returned by the backend."""

cl def:pub ExplanationResult(
    concepts: list,
    quiz: list
) -> JsxElement {

    # Section label map — maps the backend enum value to a friendly heading + emoji
    section_labels = {
        "why_it_exists": "💡 Why It Exists",
        "problem_it_solves": "🔧 Problem It Solves",
        "what_came_before": "⏪ What Came Before",
        "what_it_is": "📖 What It Is",
        "how_it_works": "⚙️ How It Works",
        "tradeoffs": "⚖️ Tradeoffs & Limitations",
        "how_to_use": "🛠️ How To Use It"
    };

    return <div style={{
            "width": "100%",
            "maxWidth": "720px",
            "display": "flex",
            "flexDirection": "column",
            "gap": "1.25rem"
        }}>

            {[
                <div
                    key={concept["concept_name"]}
                    style={{
                        "background": "#16162a",
                        "borderRadius": "14px",
                        "border": ("1px solid #7c3aed" if concept["user_actually_chose"] else "1px solid #2a2a4a"),
                        "overflow": "hidden",
                        "boxShadow": "0 4px 20px rgba(0,0,0,0.35)"
                    }}
                >
                    <div style={{
                        "padding": "1rem 1.25rem",
                        "background": ("linear-gradient(90deg, #1e0a3c, #16162a)" if concept["user_actually_chose"] else "#111128"),
                        "borderBottom": "1px solid #2a2a4a",
                        "display": "flex",
                        "alignItems": "center",
                        "gap": "0.6rem"
                    }}>
                        <span style={{
                            "fontSize": "0.7rem",
                            "fontWeight": "700",
                            "textTransform": "uppercase",
                            "letterSpacing": "0.08em",
                            "padding": "0.2rem 0.5rem",
                            "borderRadius": "4px",
                            "background": ("#7c3aed" if concept["user_actually_chose"] else "#2a2a4a"),
                            "color": ("#fff" if concept["user_actually_chose"] else "#888")
                        }}>
                            {("Your Selection" if concept["user_actually_chose"] else "Prerequisite")}
                        </span>
                        <span style={{
                            "fontSize": "1.05rem",
                            "fontWeight": "700",
                            "color": "#e8e8f0"
                        }}>
                            {concept["concept_name"]}
                        </span>
                        <span style={{
                            "marginLeft": "auto",
                            "fontSize": "0.75rem",
                            "color": "#666"
                        }}>
                            {"Depth " + str(concept["depth_level"])}
                        </span>
                    </div>

                    <div style={{"padding": "1.25rem", "display": "flex", "flexDirection": "column", "gap": "1rem"}}>
                        {[
                            <div key={section["type"]}>
                                <h4 style={{
                                    "margin": "0 0 0.4rem 0",
                                    "fontSize": "0.85rem",
                                    "fontWeight": "700",
                                    "color": "#c084fc",
                                    "textTransform": "uppercase",
                                    "letterSpacing": "0.06em"
                                }}>
                                    {section_labels[section["type"]] if section["type"] in section_labels else section["type"]}
                                </h4>
                                <p style={{
                                    "margin": "0",
                                    "fontSize": "0.93rem",
                                    "lineHeight": "1.65",
                                    "color": "#ccc",
                                    "whiteSpace": "pre-wrap"
                                }}>
                                    {section["content"]}
                                </p>
                            </div>
                            for section in (concept["sections"] if "sections" in concept else [])
                        ]}

                        {(
                            <p style={{
                                "margin": "0",
                                "fontSize": "0.93rem",
                                "lineHeight": "1.65",
                                "color": "#ccc",
                                "whiteSpace": "pre-wrap"
                            }}>
                                {concept["explanation"]}
                            </p>
                        )
                        if ("explanation" in concept and concept["explanation"] and not concept.get("sections"))
                        else None}
                    </div>

                    {(
                        <div style={{
                            "padding": "0.75rem 1.25rem 1.25rem",
                            "borderTop": "1px solid #2a2a4a"
                        }}>
                            <h4 style={{
                                "margin": "0 0 0.75rem 0",
                                "fontSize": "0.78rem",
                                "fontWeight": "700",
                                "color": "#888",
                                "textTransform": "uppercase",
                                "letterSpacing": "0.08em"
                            }}>
                                Key Terms
                            </h4>
                            <div style={{"display": "flex", "flexDirection": "column", "gap": "0.6rem"}}>
                                {[
                                    <div
                                        key={term["word"]}
                                        style={{
                                            "background": "#0d0d20",
                                            "borderRadius": "8px",
                                            "padding": "0.65rem 0.85rem",
                                            "border": "1px solid #2a2a4a"
                                        }}
                                    >
                                        <div style={{
                                            "display": "flex",
                                            "alignItems": "baseline",
                                            "gap": "0.5rem",
                                            "marginBottom": "0.2rem"
                                        }}>
                                            <span style={{"fontWeight": "700", "color": "#a78bfa", "fontSize": "0.9rem"}}>
                                                {term["word"]}
                                            </span>
                                            {(
                                                <span style={{"fontSize": "0.75rem", "color": "#555"}}>
                                                    {"→ " + term["real_name"]}
                                                </span>
                                            )
                                            if term["real_name"] != term["word"]
                                            else None}
                                        </div>
                                        <p style={{"margin": "0", "fontSize": "0.85rem", "color": "#aaa", "lineHeight": "1.5"}}>
                                            {term["plain_meaning"]}
                                        </p>
                                        <p style={{"margin": "0.2rem 0 0", "fontSize": "0.78rem", "color": "#666", "fontStyle": "italic"}}>
                                            {term["usage_context"]}
                                        </p>
                                    </div>
                                    for term in (concept["terms"] if "terms" in concept else [])
                                ]}
                            </div>
                        </div>
                    )
                    if ("terms" in concept and concept["terms"])
                    else None}

                </div>
                for concept in concepts
            ]}

            {(
                <div style={{
                    "background": "#16162a",
                    "borderRadius": "14px",
                    "border": "1px solid #2a2a4a",
                    "padding": "1.25rem",
                    "boxShadow": "0 4px 20px rgba(0,0,0,0.35)"
                }}>
                    <h3 style={{
                        "margin": "0 0 1rem 0",
                        "fontSize": "1rem",
                        "fontWeight": "700",
                        "color": "#c084fc"
                    }}>
                        🧪 Retention Quiz
                    </h3>
                    <div style={{"display": "flex", "flexDirection": "column", "gap": "1.25rem"}}>
                        {[
                            <div key={str(q["_idx"])}>
                                <p style={{"margin": "0 0 0.75rem", "fontWeight": "600", "color": "#e8e8f0", "fontSize": "0.95rem"}}>
                                    {q["question"]}
                                </p>
                                <div style={{"display": "flex", "flexDirection": "column", "gap": "0.4rem"}}>
                                    {[
                                        <div
                                            key={str(ans["_idx"])}
                                            style={{
                                                "padding": "0.6rem 0.85rem",
                                                "borderRadius": "7px",
                                                "background": ("#1a3a1a" if ans["_idx"] == 0 else "#0d0d20"),
                                                "border": ("1px solid #4ade80" if ans["_idx"] == 0 else "1px solid #2a2a4a"),
                                                "color": ("#4ade80" if ans["_idx"] == 0 else "#aaa"),
                                                "fontSize": "0.88rem"
                                            }}
                                        >
                                            {ans["text"]}
                                        </div>
                                        for ans in q["answers"]
                                    ]}
                                </div>
                            </div>
                            for q in quiz
                        ]}
                    </div>
                </div>
            )
            if quiz
            else None}

        </div>;
}
