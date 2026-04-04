glob explanation_preferences: dict = {
    "selected_text": "Docker uses OS-level virtualization to package software into containers.",
    "prior_knowledge": "I know basic web development, but not infrastructure.",
    "preferred_style": "Explain it like a clear YouTube tutorial mixed with casual internet language.",
    "learning_style": "Hands-on + visual",
    "depth": "Level 2",
    "retention_mode": True
};

def build_unknown_terms(source: str) -> list {
    lowered = source.lower();
    terms = [];

    if "docker" in lowered or "container" in lowered {
        terms.append({
            "term": "container",
            "plain": "a lightweight app package",
            "usage": "A container bundles an app with what it needs so it can run more consistently across machines."
        });
        terms.append({
            "term": "virtualization",
            "plain": "making one computer act like many environments",
            "usage": "Virtualization lets software create isolated environments instead of using one machine in only one way."
        });
    }

    if "semiconductor" in lowered {
        terms.append({
            "term": "semiconductor",
            "plain": "a material that can partly control electricity",
            "usage": "A semiconductor is useful because engineers can control how easily electricity moves through it."
        });
        terms.append({
            "term": "doping",
            "plain": "adding tiny amounts of other material",
            "usage": "In semiconductors, doping changes how the material handles electric charge."
        });
        terms.append({
            "term": "junction",
            "plain": "a meeting point between two regions",
            "usage": "A semiconductor junction is where differently prepared regions meet and create useful electrical behavior."
        });
    }

    if "artifact" in lowered or "sdlc" in lowered {
        terms.append({
            "term": "artifact",
            "plain": "a thing created during work",
            "usage": "In software, an artifact can be a document, design, build file, or other output made during development."
        });
        terms.append({
            "term": "SDLC",
            "plain": "the software-building process",
            "usage": "SDLC stands for Software Development Life Cycle, which means the stages teams go through to plan, build, test, and ship software."
        });
    }

    if not terms {
        terms = [
            {
                "term": "directory",
                "plain": "folder",
                "usage": "People often say directory in technical settings, but for most beginners it helps to think of it as the same thing as a folder."
            },
            {
                "term": "context",
                "plain": "the background you need first",
                "usage": "Context is the supporting information that makes the main idea easier to understand."
            }
        ];
    }

    return terms;
}

def build_sections(source: str, depth: str, prior_note: str, learning_note: str, style_note: str) -> list {
    short_source = source[:280] + "..." if len(source) > 280 else source;

    why_exists = "This explanation exists because many definitions throw you into expert language too early. Instead of assuming background knowledge, it rebuilds the idea in a way that matches how you learn.";
    problem = "The original text can hide prerequisites, use unfamiliar words, and skip the reason the concept matters. That makes it hard to form a mental model.";
    before = "Before a tool like this, learners usually had to open many tabs, decode jargon one term at a time, and hope one tutorial finally matched their level.";
    what_it_is = "In simple terms, the selected text is about: " + short_source;
    how_it_works = "The engine starts from your prior knowledge, explains missing terms first, then walks through the concept in a structured order using a " + style_note + " tone and a " + learning_note + " learning approach.";
    tradeoffs = "A simpler explanation is easier to start with, but it can leave out precision. That is why the product also teaches the real terminology so you can use it in the real world.";
    how_to_use = "Paste text into the website, choose your depth and preferences, click Explain Better, then use the optional retention prompts if you want the idea to stick.";

    if prior_note != "" {
        problem = problem + " Since you already know " + prior_note + ", the explanation should skip those basics and focus on the gap instead.";
    }

    if depth == "Level 1" {
        what_it_is = "At a high level, this text is talking about: " + short_source;
        how_it_works = "It gives you the big picture first, avoids heavy jargon, and only introduces terms when they are truly needed.";
        tradeoffs = "This level is fast and beginner-friendly, but it intentionally leaves out deeper mechanics.";
    } elif depth == "Level 3" {
        how_it_works = "It combines context reconstruction, terminology bridging, and a more technical walkthrough so you understand both the idea and how it behaves in practice.";
        tradeoffs = "This level gives stronger understanding, but it takes more reading and can feel heavier if you only wanted intuition.";
    } elif depth == "Level 4" {
        before = "Before this concept, people often relied on older workflows, more manual steps, or less efficient mental models. Understanding that contrast helps explain why the concept became important.";
        how_it_works = "This level treats the explanation like a dependency graph: define prerequisites, connect them in order, then explain the internal mechanics and terminology with more precision.";
        tradeoffs = "This level is the most complete, but it can overwhelm users who only need practical understanding right now.";
    }

    return [
        {"title": "Why it exists", "body": why_exists},
        {"title": "What problem it solves", "body": problem},
        {"title": "What came before", "body": before},
        {"title": "What it is", "body": what_it_is},
        {"title": "How it works", "body": how_it_works},
        {"title": "Tradeoffs", "body": tradeoffs},
        {"title": "How to use it", "body": how_to_use}
    ];
}

def:pub save_preferences(selected_text: str = "", prior_knowledge: str = "", preferred_style: str = "", learning_style: str = "", depth: str = "Level 2", retention_mode: bool = False) -> dict {
    explanation_preferences = {
        "selected_text": selected_text,
        "prior_knowledge": prior_knowledge,
        "preferred_style": preferred_style,
        "learning_style": learning_style,
        "depth": depth,
        "retention_mode": retention_mode
    };
    return explanation_preferences;
}

def:pub load_preferences() -> dict {
    return explanation_preferences;
}

def:pub generate_explanation(text: str, depth: str = "Level 2", prior_knowledge: str = "", learning_style: str = "", retention_mode: bool = False, preferred_style: str = "") -> dict {
    source = text.strip() if text else explanation_preferences["selected_text"];
    chosen_depth = depth if depth else explanation_preferences["depth"];
    prior_note = prior_knowledge.strip() if prior_knowledge else explanation_preferences["prior_knowledge"];
    learning_note = learning_style.strip() if learning_style else explanation_preferences["learning_style"];
    style_note = preferred_style.strip() if preferred_style else explanation_preferences["preferred_style"];
    retention_enabled = retention_mode;

    explanation_preferences = {
        "selected_text": source,
        "prior_knowledge": prior_note,
        "preferred_style": style_note,
        "learning_style": learning_note,
        "depth": chosen_depth,
        "retention_mode": retention_enabled
    };

    retention = [];
    if retention_enabled {
        retention = [
            "Quick quiz: What problem does this concept solve?",
            "Explain it back in one sentence using your own words.",
            "Mini application: give one real situation where this concept would be useful."
        ];
    }

    return {
        "input": source,
        "profile": explanation_preferences,
        "sections": build_sections(source, chosen_depth, prior_note, learning_note, style_note),
        "style_preview": "Explain this in a " + style_note + " style while still teaching the real terms.",
        "context_from_zero": "Start by defining any hidden prerequisite before using it in the main explanation.",
        "unknown_terms": build_unknown_terms(source),
        "retention": retention
    };
}
