def:pub generate_explanation(text: str, depth: str = "Level 2", prior_knowledge: str = "", learning_style: str = "", retention_mode: bool = False, preferred_style: str = "") -> dict {
    source = text.strip() if text else "Docker uses OS-level virtualization to package software into containers.";

    why_exists = "People run into explanations that assume too much background knowledge. This engine exists to rebuild the idea in a way that matches the learner instead of forcing the learner to match the explanation.";
    problem = "The original text may use hidden prerequisites, unfamiliar terms, and expert vocabulary without explaining them first.";
    before = "Before a tool like this, people usually had to search many tabs, decode jargon one term at a time, and hope a tutorial happened to match their level.";
    what_it_is = "The Adaptive Explanation Engine is a system that takes confusing text, detects what may be missing, and rewrites the idea in a clearer step-by-step form.";
    how_it_works = "It checks the selected text, spots terms that may need context, uses your chosen depth and prior knowledge, then produces a structured explanation in a style that feels easier for you to read.";
    tradeoffs = "A simpler explanation is easier to start with, but it can hide some technical precision. That is why the product should also teach the real terminology alongside the plain-language version.";
    how_to_use = "Highlight text on a page, click Explain Better, choose depth and learning preferences, then read the rebuilt explanation and optionally do a quick retention activity.";

    if depth == "Level 1" {
        how_it_works = "It turns hard text into a simpler explanation with the missing background filled in.";
        tradeoffs = "Very simple explanations are easier to understand, but they leave out deeper technical details.";
    }
    elif depth == "Level 3" {
        how_it_works = "It combines term detection, context reconstruction, user-profile inputs, and a structured explanation template so the answer is both personalized and logically ordered.";
    }
    elif depth == "Level 4" {
        how_it_works = "It can be thought of as a knowledge-restructuring pipeline: parse the input, infer prerequisite concepts, rank likely unknown terms, condition the explanation on user profile signals, then generate a layered response with terminology bridging and optional retention prompts.";
        tradeoffs = "Deeper explanations improve transfer and precision, but they take more time and can overwhelm users who only need practical understanding.";
    }

    style_note = preferred_style.strip() if preferred_style else "casual internet-friendly";
    prior_note = prior_knowledge.strip() if prior_knowledge else "No prior knowledge provided, so the explanation should start from near zero and avoid assumptions.";
    learning_note = learning_style.strip() if learning_style else "general";

    unknown_terms = [
        {"term": "artifact", "plain": "a thing created during work", "usage": "In software, an artifact can be a document, design, build file, or other output made during development."},
        {"term": "SDLC", "plain": "the software-building process", "usage": "SDLC stands for Software Development Life Cycle, which means the stages teams go through to plan, build, test, and ship software."},
        {"term": "directory", "plain": "folder", "usage": "People often say directory in technical settings, but for most beginners it helps to think of it as the same thing as a folder."}
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
            "depth": depth,
            "prior_knowledge": prior_note,
            "learning_style": learning_note,
            "preferred_style": style_note,
            "retention_mode": retention_mode
        },
        "sections": [
            {"title": "Why it exists", "body": why_exists},
            {"title": "What problem it solves", "body": problem},
            {"title": "What came before", "body": before},
            {"title": "What it is", "body": what_it_is},
            {"title": "How it works", "body": how_it_works},
            {"title": "Tradeoffs", "body": tradeoffs},
            {"title": "How to use it", "body": how_to_use}
        ],
        "style_preview": "Explain this in a " + style_note + " style while still teaching the real terms.",
        "context_from_zero": "Start by defining any hidden prerequisite before using it in the main explanation.",
        "unknown_terms": unknown_terms,
        "retention": retention
    };
}
