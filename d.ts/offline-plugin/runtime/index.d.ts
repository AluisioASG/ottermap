// Type definitions for offline-plugin 4.5.3
// Project: https://github.com/NekR/offline-plugin
// Definitions by: Aluísio Augusto Silva Gonçalves <https://github.com/AluisioASG>


export function install(options?: OfflinePluginOptions): void

export function applyUpdate(callback?: () => void, errback?: () => void): void

interface OfflinePluginOptions {
    onError?(evt: OfflinePluginEvent): void
    onUpdateFailed?(evt: OfflinePluginEvent): void
    onUpdating?(evt: OfflinePluginEvent): void
    onUpdateReady?(evt: OfflinePluginEvent): void
    onUpdated?(evt: OfflinePluginEvent): void
    onInstalled?(evt: OfflinePluginEvent): void
}

interface OfflinePluginEvent {
    source: "AppCache" | "ServiceWorker"
}
