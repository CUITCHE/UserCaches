//
//  ConfRead.swift
//  UserCaches
//
//  Created by He,Junqiu on 2018/6/7.
//

import Foundation

enum Conf: String {
    case cache_filepath
}

func confRead(forKey key: String, configFilepath: String) -> String? {
    guard let context = try? String(contentsOfFile: configFilepath) else { return nil }
    let lines = context.split(separator: "\n")
    var value: String? = nil
    for line in lines {
        let line = line.trimmingCharacters(in: .whitespaces)
        guard line.starts(with: "#") == false else { continue }
        let real_content: String.SubSequence
        if let idx = line.index(of: "#") {
            real_content = line[..<idx]
        } else {
            real_content = line[...]
        }
        guard let idx = real_content.index(of: "="), real_content[..<idx] == key else { continue }
        value = String(real_content[real_content.index(after: idx)...])
        break
    }
    return value
}

let configFilepath: String = {
    #if os(Linux)
    return URL(fileURLWithPath: CommandLine.arguments.first!).deletingLastPathComponent().appendingPathComponent("usercaches_config").path
    #else
    return "/tmp/usercaches_config"
    #endif
}()

extension Conf {
    func stringValue() -> String? {
        return confRead(forKey: rawValue, configFilepath: configFilepath)
    }
}
