"""
Adaptive Explanation Engine entry point.
"""

import from services.appService { generate_explanation }

cl import ".styles.global.css";
cl import from .index { ClientApp }

cl {
    def:pub app() -> JsxElement {
        return <ClientApp />;
    }
}
