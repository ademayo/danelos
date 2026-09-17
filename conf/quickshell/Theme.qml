pragma Singleton
import QtQuick

QtObject {
    // Matched to the Arc Dark desktop palette used by SDDM, GTK, and wlogout.
    readonly property color bg:          "#2b2e34"   // Panel / launcher background
    readonly property color bgPanel:     "#34383d"   // Bar backdrop
    readonly property color bgAlt:       "#383c43"   // Input / list backgrounds
    readonly property color bgHover:     "#454951"   // Hover state
    readonly property color bgSelected:  "#5294e2"   // Selected / active accent
    readonly property color fg:          "#d3dae3"   // Primary text
    readonly property color fgDim:       "#b8bfca"   // Secondary / muted text
    readonly property color fgBright:    "#ffffff"   // Emphasised text
    readonly property color accent:      "#5294e2"   // Steel blue
    readonly property color accent2:     "#7cb2f0"   // Lighter blue
    readonly property color accentDim:   "#3a6ea5"   // Hover/focused border
    readonly property color border:      "#454951"   // Panel edge
    readonly property color borderFocus: "#5294e2"   // Focus ring
    readonly property color red:       "#f15d63"   // Error / urgent
    readonly property color yellow:    "#f9c440"
    readonly property color green:     "#96d988"
    readonly property color blue:      "#86a2be"
    readonly property int radiusSmall: 6
    readonly property int radius:        10
    readonly property int padSmall:    6
    readonly property int pad:           10
    readonly property int padLarge:    16
    readonly property int fontSmall:   11
    readonly property int font:        13
    readonly property int fontLarge:   15
    readonly property string family:   "Adwaita Sans"
    readonly property string mono:     "CaskaydiaCove Nerd Font"
}
