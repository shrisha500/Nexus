def:pub generate_explanation(text: str, depth: str = "Level 2", prior_knowledge: str = "", learning_style: str = "", retention_mode: bool = False, preferred_style: str = "") -> dict {
    source = text.strip() if text else "Docker uses OS-level virtualization to package software into containers.";
    chosen_depth = depth if depth else "Level 2";
    prior_note = prior_knowledge.strip() if prior_knowledge else "No prior knowledge provided, so the explanation should start from near zero and avoid assumptions.";
    learning_note = learning_style.strip() if learning_style else "general";
    style_note = preferred_style.strip() if preferred_style else "casual internet-friendly";

    unknown_terms = [
        {"term": "directory", "plain": "folder", "usage": "People often say directory in technical settings, but for most beginners it helps to think of it as the same thing as a folder."},
        {"term": "context", "plain": "the background you need first", "usage": "Context is the supporting information that makes the main idea easier to understand."}
    ];

    retention = [];
    if retention_mode {
        retention = [
            "Quick quiz: What problem does this concept solve?",
            "Explain it back in one sentence using your own words.",
            "Mini application: give one real situation where this concept would be useful."
        ];
    }

    return {
        "input": source,
        "profile": {
            "depth": chosen_depth,
            "prior_knowledge": prior_note,
            "learning_style": learning_note,
            "preferred_style": style_note,
            "retention_mode": retention_mode
        },
        "sections": [
            {"title": "Why it exists", "body": "This explanation exists because many definitions assume too much background knowledge and skip the reason the concept matters."},
            {"title": "What problem it solves", "body": "It fills in missing context, translates jargon, and adapts the explanation to the learner instead of forcing the learner to adapt to the explanation."},
            {"title": "What came before", "body": "Before this kind of tool, learners usually had to search many tabs and piece together the explanation themselves."},
            {"title": "What it is", "body": "In simple terms, the selected text is about: " + source},
            {"title": "How it works", "body": "The engine uses your depth, prior knowledge, learning style, and preferred tone to rebuild the explanation in a clearer order."},
            {"title": "Tradeoffs", "body": "Simpler explanations are easier to start with, but they can hide precision, so the real terminology still needs to be taught."},
            {"title": "How to use it", "body": "Paste text into the website, choose your preferences, click Explain Better, and optionally use the retention prompts."}
        ],
        "style_preview": "Explain this in a " + style_note + " style while still teaching the real terms.",
        "context_from_zero": "Start by defining any hidden prerequisite before using it in the main explanation.",
        "unknown_terms": unknown_terms,
        "retention": retention
    };
}
