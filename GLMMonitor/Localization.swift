import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case en = "en"
    case zh_CN = "zh-CN"
    case zh_TW = "zh-TW"
    case ja = "ja"
    case ko = "ko"
    case de = "de"
    case fr = "fr"
    case es = "es"
    case pt = "pt"
    case ru = "ru"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .en: return "English"
        case .zh_CN: return "简体中文"
        case .zh_TW: return "繁體中文"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .de: return "Deutsch"
        case .fr: return "Français"
        case .es: return "Español"
        case .pt: return "Português"
        case .ru: return "Русский"
        }
    }
}

// MARK: - Localized Strings

struct L10n {
    let lang: AppLanguage

    init() {
        let stored = UserDefaults.standard.string(forKey: "appLanguage") ?? "system"
        let resolved = AppLanguage(rawValue: stored) ?? .system
        if resolved == .system {
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.hasPrefix("zh-Hans") || preferred.hasPrefix("zh_CN") {
                lang = .zh_CN
            } else if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh_TW") || preferred.hasPrefix("zh_HK") {
                lang = .zh_TW
            } else if preferred.hasPrefix("ja") {
                lang = .ja
            } else if preferred.hasPrefix("ko") {
                lang = .ko
            } else if preferred.hasPrefix("de") {
                lang = .de
            } else if preferred.hasPrefix("fr") {
                lang = .fr
            } else if preferred.hasPrefix("es") {
                lang = .es
            } else if preferred.hasPrefix("pt") {
                lang = .pt
            } else if preferred.hasPrefix("ru") {
                lang = .ru
            } else {
                lang = .en
            }
        } else {
            lang = resolved
        }
    }

    var glmMonitor: String {
        switch lang {
        case .system, .en: return "GLM Monitor"
        case .zh_CN: return "GLM 监控"
        case .zh_TW: return "GLM 監控"
        case .ja: return "GLM モニター"
        case .ko: return "GLM 모니터"
        case .de: return "GLM Monitor"
        case .fr: return "Moniteur GLM"
        case .es: return "Monitor GLM"
        case .pt: return "Monitor GLM"
        case .ru: return "GLM Монитор"
        }
    }

    var mute: String {
        switch lang {
        case .system, .en: return "Mute"
        case .zh_CN: return "静音"
        case .zh_TW: return "靜音"
        case .ja: return "ミュート"
        case .ko: return "음소거"
        case .de: return "Stumm"
        case .fr: return "Muet"
        case .es: return "Silenciar"
        case .pt: return "Mudo"
        case .ru: return "Без звука"
        }
    }

    var unmute: String {
        switch lang {
        case .system, .en: return "Unmute"
        case .zh_CN: return "取消静音"
        case .zh_TW: return "取消靜音"
        case .ja: return "ミュート解除"
        case .ko: return "음소거 해제"
        case .de: return "Ton ein"
        case .fr: return "Rétablir"
        case .es: return "Activar"
        case .pt: return "Ativar som"
        case .ru: return "Вкл. звук"
        }
    }

    var hideGLM: String {
        switch lang {
        case .system, .en: return "Hide GLM"
        case .zh_CN: return "隐藏 GLM"
        case .zh_TW: return "隱藏 GLM"
        case .ja: return "GLM を隠す"
        case .ko: return "GLM 숨기기"
        case .de: return "GLM ausblenden"
        case .fr: return "Masquer GLM"
        case .es: return "Ocultar GLM"
        case .pt: return "Ocultar GLM"
        case .ru: return "Скрыть GLM"
        }
    }

    var showGLM: String {
        switch lang {
        case .system, .en: return "Show GLM"
        case .zh_CN: return "显示 GLM"
        case .zh_TW: return "顯示 GLM"
        case .ja: return "GLM を表示"
        case .ko: return "GLM 표시"
        case .de: return "GLM einblenden"
        case .fr: return "Afficher GLM"
        case .es: return "Mostrar GLM"
        case .pt: return "Mostrar GLM"
        case .ru: return "Показать GLM"
        }
    }

    var quit: String {
        switch lang {
        case .system, .en: return "Quit"
        case .zh_CN: return "退出"
        case .zh_TW: return "結束"
        case .ja: return "終了"
        case .ko: return "종료"
        case .de: return "Beenden"
        case .fr: return "Quitter"
        case .es: return "Salir"
        case .pt: return "Sair"
        case .ru: return "Выход"
        }
    }

    var settings: String {
        switch lang {
        case .system, .en: return "Settings"
        case .zh_CN: return "设置"
        case .zh_TW: return "設定"
        case .ja: return "設定"
        case .ko: return "설정"
        case .de: return "Einstellungen"
        case .fr: return "Réglages"
        case .es: return "Ajustes"
        case .pt: return "Configurações"
        case .ru: return "Настройки"
        }
    }

    var back: String {
        switch lang {
        case .system, .en: return "Back"
        case .zh_CN: return "返回"
        case .zh_TW: return "返回"
        case .ja: return "戻る"
        case .ko: return "뒤로"
        case .de: return "Zurück"
        case .fr: return "Retour"
        case .es: return "Volver"
        case .pt: return "Voltar"
        case .ru: return "Назад"
        }
    }

    var quitGLMOnExit: String {
        switch lang {
        case .system, .en: return "Quit GLM on exit"
        case .zh_CN: return "退出时关闭 GLM"
        case .zh_TW: return "結束時關閉 GLM"
        case .ja: return "終了時に GLM を閉じる"
        case .ko: return "종료 시 GLM 닫기"
        case .de: return "GLM beim Beenden schließen"
        case .fr: return "Quitter GLM en sortant"
        case .es: return "Cerrar GLM al salir"
        case .pt: return "Fechar GLM ao sair"
        case .ru: return "Закрыть GLM при выходе"
        }
    }

    var quitGLMOnExitDesc: String {
        switch lang {
        case .system, .en: return "Terminate GLM when GLM Monitor quits"
        case .zh_CN: return "GLM Monitor 退出时同时终止 GLM 进程"
        case .zh_TW: return "GLM Monitor 結束時同時終止 GLM 程序"
        case .ja: return "GLM Monitor 終了時に GLM も終了する"
        case .ko: return "GLM Monitor 종료 시 GLM도 종료"
        case .de: return "GLM beenden, wenn GLM Monitor geschlossen wird"
        case .fr: return "Fermer GLM à la sortie de GLM Monitor"
        case .es: return "Terminar GLM al cerrar GLM Monitor"
        case .pt: return "Encerrar GLM ao fechar GLM Monitor"
        case .ru: return "Завершить GLM при выходе из GLM Monitor"
        }
    }

    var pollingSpeed: String {
        switch lang {
        case .system, .en: return "Polling speed"
        case .zh_CN: return "轮询速度"
        case .zh_TW: return "輪詢速度"
        case .ja: return "ポーリング速度"
        case .ko: return "폴링 속도"
        case .de: return "Abfragegeschwindigkeit"
        case .fr: return "Vitesse de scrutation"
        case .es: return "Velocidad de sondeo"
        case .pt: return "Velocidade de consulta"
        case .ru: return "Скорость опроса"
        }
    }

    var pollingStandard: String {
        switch lang {
        case .system, .en: return "Standard"
        case .zh_CN: return "标准"
        case .zh_TW: return "標準"
        case .ja: return "標準"
        case .ko: return "표준"
        case .de: return "Standard"
        case .fr: return "Standard"
        case .es: return "Estándar"
        case .pt: return "Padrão"
        case .ru: return "Стандарт"
        }
    }

    var pollingFast: String {
        switch lang {
        case .system, .en: return "Fast"
        case .zh_CN: return "快速"
        case .zh_TW: return "快速"
        case .ja: return "高速"
        case .ko: return "빠름"
        case .de: return "Schnell"
        case .fr: return "Rapide"
        case .es: return "Rápido"
        case .pt: return "Rápido"
        case .ru: return "Быстро"
        }
    }

    var pollingFastest: String {
        switch lang {
        case .system, .en: return "Fastest"
        case .zh_CN: return "最快"
        case .zh_TW: return "最快"
        case .ja: return "最速"
        case .ko: return "가장 빠름"
        case .de: return "Schnellste"
        case .fr: return "Le plus rapide"
        case .es: return "Más rápido"
        case .pt: return "Mais rápido"
        case .ru: return "Макс."
        }
    }

    var language: String {
        switch lang {
        case .system, .en: return "Language"
        case .zh_CN: return "语言"
        case .zh_TW: return "語言"
        case .ja: return "言語"
        case .ko: return "언어"
        case .de: return "Sprache"
        case .fr: return "Langue"
        case .es: return "Idioma"
        case .pt: return "Idioma"
        case .ru: return "Язык"
        }
    }

    var glmNotRunning: String {
        switch lang {
        case .system, .en: return "GLM is not running"
        case .zh_CN: return "GLM 未运行"
        case .zh_TW: return "GLM 未執行"
        case .ja: return "GLM が起動していません"
        case .ko: return "GLM이 실행되지 않음"
        case .de: return "GLM läuft nicht"
        case .fr: return "GLM n'est pas lancé"
        case .es: return "GLM no está ejecutándose"
        case .pt: return "GLM não está em execução"
        case .ru: return "GLM не запущен"
        }
    }

    var launchingGLM: String {
        switch lang {
        case .system, .en: return "Launching GLM..."
        case .zh_CN: return "正在启动 GLM..."
        case .zh_TW: return "正在啟動 GLM..."
        case .ja: return "GLM を起動中..."
        case .ko: return "GLM 실행 중..."
        case .de: return "GLM wird gestartet..."
        case .fr: return "Lancement de GLM..."
        case .es: return "Iniciando GLM..."
        case .pt: return "Iniciando GLM..."
        case .ru: return "Запуск GLM..."
        }
    }

    var maxVolume: String {
        switch lang {
        case .system, .en: return "Max"
        case .zh_CN: return "最大音量"
        case .zh_TW: return "最大音量"
        case .ja: return "最大音量"
        case .ko: return "최대 음량"
        case .de: return "Max"
        case .fr: return "Max"
        case .es: return "Máx"
        case .pt: return "Máx"
        case .ru: return "Макс"
        }
    }

    var retry: String {
        switch lang {
        case .system, .en: return "Retry"
        case .zh_CN: return "重试"
        case .zh_TW: return "重試"
        case .ja: return "再試行"
        case .ko: return "재시도"
        case .de: return "Erneut"
        case .fr: return "Réessayer"
        case .es: return "Reintentar"
        case .pt: return "Tentar novamente"
        case .ru: return "Повторить"
        }
    }
}
