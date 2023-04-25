//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

<<<<<<< Updated upstream
import cloud_firestore
import firebase_core
import path_provider_foundation
=======
import firebase_core
import path_provider_macos
>>>>>>> Stashed changes
import sqflite

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
<<<<<<< Updated upstream
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
=======
>>>>>>> Stashed changes
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
