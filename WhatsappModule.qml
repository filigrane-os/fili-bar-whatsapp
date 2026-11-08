// Unread WhatsApp messages (hidden when there are none), click = open the web app and clear
import QtQuick
import qs
import qs.bar.modules.alert

AlertModule {
    kind: "whatsapp"
    title: "WhatsApp"
    glyph: String.fromCodePoint(0xf05a3)
}
