import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Uygulama başlatıldığında yapılacak işlemler
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Yeni bir scene session oluşturulduğunda çağrılır
        // Yeni scene için uygun bir konfigürasyon seçilir
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Kullanıcı bir scene session'ı sildiğinde çağrılır
        // Silinen session'lara ait kaynakları buradan serbest bırakabilirsin
    }

    // MARK: - Core Data stack

    // Core Data'nın persistent container'ı
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WalletApp") // Modelin adını doğru yazdığınızdan emin olun
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Eğer bir hata oluşursa, hata mesajını loglayın
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    // Core Data context'ini kaydetmek için kullanılan fonksiyon
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save() // Değişiklikler varsa kaydeder
            } catch {
                // Hata oluşursa uygun şekilde handle et
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
