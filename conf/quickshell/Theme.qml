pragma Singleton
import QtQuick

QtObject {
    // Refined Arc Dark palette: cohesive, calm, not flashy.
    readonly property color bgDeep:      "#22252a"
    readonly property color bg:          "#2b2e34"
    readonly property color bgPanel:     "#31353b"
    readonly property color bgAlt:       "#373b42"
    readonly property color bgHover:     "#3f444c"
    readonly property color bgSelected:  "#4c85c5"
    readonly property color fg:          "#c7ced7"
    readonly property color fgDim:       "#9aa2ab"
    readonly property color fgBright:    "#ffffff"
    readonly property color accent:      "#5b8ec6"
    readonly property color accent2:     "#7aaee0"
    readonly property color accentDim:   "#456f9e"
    readonly property color border:      "#3e4249"
    readonly property color borderFocus: "#5b8ec6"
    readonly property color red:         "#d96e6e"
    readonly property color yellow:      "#e2b65c"
    readonly property color green:       "#8ec07c"
    readonly property color blue:        "#86a2be"

    // Subtle translucent surfaces.
    readonly property color panelGlass:  Qt.rgba(0.192, 0.208, 0.231, 0.90)
    readonly property color glowAccent:  Qt.rgba(0.357, 0.557, 0.776, 0.28)
    readonly property color shadow:      Qt.rgba(0.0, 0.0, 0.0, 0.30)

    // Geometry: crisp, modern, restrained.
    readonly property int radiusSmall:   5
    readonly property int radius:        9
    readonly property int radiusLarge:   14
    readonly property int padSmall:      6
    readonly property int pad:           10
    readonly property int padLarge:      16

    // Typography.
    readonly property int fontSmall:     11
    readonly property int font:          13
    readonly property int fontLarge:     15
    readonly property int fontTitle:     18
    readonly property string family:     "Adwaita Sans"
    readonly property string mono:       "CaskaydiaCove Nerd Font"
}
