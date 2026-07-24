//
//  Materializer.swift
//  ComposeUI
//
//  Walks the core's RenderNode IR and constructs the interpreter's Kotlin
//  ViewNode objects — the typed transport that replaces string serialization.
//

import SwiftUICore
import SwiftJava

public enum Materializer {

    /// Builds the Kotlin mirror of an IR tree, depth-first.
    public static func materialize(_ node: RenderNode) -> ViewNodeObject {
        var propKeys: [String] = []
        var propValues: [String] = []
        for (key, value) in node.props {
            propKeys.append(key)
            propValues.append(jsonLiteral(value))
        }
        var modifierKinds: [String] = []
        var modifierArgs: [String] = []
        for modifier in node.modifiers {
            modifierKinds.append(modifier.kind)
            modifierArgs.append(jsonObjectLiteral(modifier.args))
        }
        let children = node.children.map { materialize($0) as ViewNodeObject? }
        return ViewNodeObject(
            node.type,
            node.id,
            propKeys,
            propValues,
            modifierKinds,
            modifierArgs,
            children,
            Int32(node.count ?? -1),
            Int64(-1)
        )
    }

    /// Encodes a prop value as a JSON literal (`"text"`, `42`, `true`, `[…]`).
    static func jsonLiteral(_ value: PropValue) -> String {
        switch value {
        case .string(let string):
            return escapeJSON(string)
        case .double(let double):
            return "\(double)"
        case .int(let int):
            return "\(int)"
        case .bool(let bool):
            return bool ? "true" : "false"
        case .array(let values):
            return "[" + values.map(jsonLiteral).joined(separator: ",") + "]"
        }
    }

    static func jsonObjectLiteral(_ args: [String: PropValue]) -> String {
        let members = args.map { "\(escapeJSON($0.key)):\(jsonLiteral($0.value))" }
        return "{" + members.joined(separator: ",") + "}"
    }

    /// Minimal JSON string escaping (quotes, backslashes, control characters).
    static func escapeJSON(_ string: String) -> String {
        var out = "\""
        for scalar in string.unicodeScalars {
            switch scalar {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            default:
                if scalar.value < 0x20 {
                    let hex = String(scalar.value, radix: 16)
                    out += "\\u" + String(repeating: "0", count: 4 - hex.count) + hex
                } else {
                    out.unicodeScalars.append(scalar)
                }
            }
        }
        return out + "\""
    }
}
