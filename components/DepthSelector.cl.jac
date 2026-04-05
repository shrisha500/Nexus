import from "mui/material" { Slider }
import from "../styles/depth.css" { depth_css }

def:pub DepthSelector(
    value:    int,
    onChange: any,
    disabled: bool = False
) -> JsxElement {
    # MUI Slider expects 'value' and 'label' keys for marks
    marks = [
        {"value": 1, "label": "Intuition"},
        {"value": 2, "label": "Practical"},
        {"value": 3, "label": "Technical"},
        {"value": 4, "label": "Deep"}
    ];

    return <div className="depth-slider-container">
        <Slider
            value={value}
            min={1}
            max={4}
            step={1}
            marks={marks}
            disabled={disabled}
            onChange={lambda e: any, val: int -> None { onChange(val); }}
            valueLabelDisplay="auto"
        />
    </div>;
}