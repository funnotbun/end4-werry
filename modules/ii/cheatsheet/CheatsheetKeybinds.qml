pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    property real padding: 4
    implicitWidth: QsWindow?.window?.screen.width * 0.7 ?? 0
    implicitHeight: QsWindow?.window?.screen.height * 0.7 ?? 0

    // This shell's HyprlandKeybinds exposes a tree ({children: [{name, children, keybinds}]})
    // instead of a flat list + keybindCategories, so collect category names by walking it.
    property var keybindCategories: {
        const names = [];
        const walk = (node) => {
            for (const child of (node?.children ?? [])) {
                if (child.name?.length > 0 && !names.includes(child.name))
                    names.push(child.name);
                walk(child);
            }
        };
        walk(HyprlandKeybinds.keybinds);
        return names;
    }

    StyledFlickable {
        id: flickable
        clip: true
        anchors.fill: parent
        anchors.margins: Appearance.rounding.small
        contentHeight: height
        contentWidth: flow.implicitWidth
        Flow {
            id: flow
            height: flickable.height
            flow: Flow.TopToBottom
            spacing: 10
            Repeater {
                // "Custom" catches binds whose prefix matches no section (e.g. Shell:, Execute:);
                // "" catches binds with no prefix at all.
                model: [...root.keybindCategories, "Custom", ""]
                delegate: CheatsheetKeybindsCategory {
                    required property var modelData
                    categoryName: modelData
                    knownCategories: root.keybindCategories
                }
            }
        }
    }

    ScrollEdgeFade {
        target: flickable
        vertical: false
        color: Appearance.colors.colLayer0Base
    }
}
